// =============================================================================
// Particle Life — 2D GPU force pass  (with Urge / Neuron "quantum-electrical" layer)
//
// Particle type layout (see CPU side):
//   [0, numTypes)                       -> matter colors (classic particle life rules)
//   [numTypes, numTypes + numUrges)     -> urges.  local index k = type - numTypes
//                                         Each urge has its OWN goal, derived deterministically
//                                         from k (no extra buffer fields): a target color and an
//                                         objective polarity. Some attract their color, some repel.
//   [numTypes+numUrges, TOTAL_TYPES)    -> neurons. local index m = type - numTypes - numUrges
//                                         target color = m % numTypes  (fixed for its lifetime)
//
// MODEL: urges modulate NEURONS; neurons actuate MATTER.
//   * An urge learns a signed `control` (+ attract / − repel) toward ITS OWN goal. The sign is
//     NOT fixed in advance — the learning rule finds it, so the population ends up with a mix of
//     attracting and repelling urges (diverse by construction via the per-urge goal).
//   * A neuron is a pure actuator for ONE matter color. In its own branch it scans for urges within
//     `neuronRadius` OF THE NEURON, sums their previous-frame signed `control` (falloff-weighted)
//     into a `drive`, then pushes/pulls ONLY matter of its single target color by that drive.
//   * So an urge's effect on matter is mediated through neurons: it recruits nearby neurons to
//     attract or repel the color those neurons own. There is no direct urge->matter field.
//
// Each particle carries two persistent "electrical" scalars that survive across frames:
//   control : for an urge, its current attract(+) / repel(-) bias (its learned intent). A neuron
//             reads it to decide how hard to push/pull its color. For a neuron it is 0.
//   signal  : for an urge, the running value of the objective metric it tracks (prior frame).
//             Comparing this frame's metric with `signal` gives a dM/dt gradient that drives a
//             simple Hebbian learning rule on `control`. For a neuron it is its firing activity.
//
// SINGLE PASS: the force pass reads last frame's state (particleTempBuffer) and writes the new one,
// so every particle sees only PREVIOUS-frame values of all others. No second pass, no ordering
// dependency between urge-control learning and neuron actuation — the 1-frame delay doubles as
// smoothing.
// =============================================================================
struct InteractionMatrix { data: array<u32> };
struct SimOptions {
    simWidth: f32,
    simHeight: f32,
    gridWidth: u32,
    gridHeight: u32,
    cellSize: f32,
    numParticles: u32,
    numTypes: u32,
    particleSize: f32,
    particleOpacity: f32,
    isWallRepel: u32,
    isWallWrap: u32,
    forceFactor: f32,
    frictionFactor: f32,
    repel: f32,
    extendedGridWidth: u32,
    extendedGridHeight: u32,
    gridOffsetX: u32,
    gridOffsetY: u32,
    mirrorWrapCount: u32,
    cellSubdivisions: u32,
};
struct Particle {
    x : f32,
    y : f32,
    vx : f32,
    vy : f32,
    particleType : f32,
    control : f32, // urge: learned attract(+) / repel(-) intent — read by nearby neurons. Persists.
    signal  : f32, // urge: prior-frame objective metric (for dM/dt). neuron: firing activity. Persists.
}
struct ElectricalOptions {
    enabled: u32,        // master switch for the whole electrical layer
    metricMode: u32,     // 0 local density of target color / 1 local fraction / 2 own-type density
    numUrges: u32,       // number of urge particles (== number of distinct urge types)
    numNeurons: u32,     // number of neuron particles
    urgeRadius: f32,     // radius over which an urge acts on matter & measures its metric
    neuronRadius: f32,   // radius over which a neuron modulates an urge
    urgeForce: f32,      // strength of an urge's attract/repel field on matter
    controlGain: f32,    // learning rate: how strongly dM/dt pushes an urge's control toward its goal sign
    controlMax: f32,     // clamp on |control|
    neuronInfluence: f32,// (legacy) strength of a single neuron's vote on an urge's control — unused now
    neuronAuthority: f32,// (legacy) extra authority gained per nearby neuron — unused now
    maxAuthority: f32,   // (legacy) cap on the accumulated neuron authority — unused now
    cohesion: f32,       // how strongly urges/neurons cling to the body & avoid overlapping
};

struct BinInfo {
    gridSize : vec2i,
    binId : vec2i,
    binIndex : i32,
}

fn getBinInfo(position: vec2f, options: SimOptions) -> BinInfo {
    var gridSize: vec2i;
    var adjustedPosition = position;

    if (options.isWallWrap == 0u && options.isWallRepel == 0u) {
        gridSize = vec2i(i32(options.extendedGridWidth), i32(options.extendedGridHeight));
        adjustedPosition = position + vec2f(f32(options.gridOffsetX) * options.cellSize, f32(options.gridOffsetY) * options.cellSize);
    } else {
        gridSize = vec2i(i32(options.gridWidth), i32(options.gridHeight));
    }

    let binId = vec2i(
        clamp(i32(floor(adjustedPosition.x / options.cellSize)), 0, gridSize.x - 1),
        clamp(i32(floor(adjustedPosition.y / options.cellSize)), 0, gridSize.y - 1)
    );
    let binIndex = binId.y * gridSize.x + binId.x;
    return BinInfo(gridSize, binId, binIndex);
}
fn get_interaction(index: u32) -> vec3<f32> {
    let word = interactions.data[index];
    let rule = fma(f32((word >> 0u) & 0xFFu), 1.0 / 127.5, -1.0);
    let minR = f32((word >> 8u) & 0xFFu);
    let maxR = f32((word >> 16u) & 0xFFFFu);
    return vec3<f32>(rule, minR, maxR);
}

// Extended interaction matrix for the electrical layer. Same 4-byte (rule u8, minR u8, maxR u16)
// encoding as `interactions`, laid out as [numUrges rows × numTypes cols] followed by
// [numNeurons rows × numTypes cols]. kind: 0 = urge rows, 1 = neuron rows.
fn get_electrical_interaction(kind: u32, localIndex: u32, targetColor: u32) -> vec3<f32> {
    let offset = select(electrical.numUrges, electrical.numUrges + electrical.numNeurons, kind == 1u);
    let word = electricalInteractions.data[(offset + localIndex) * options.numTypes + targetColor];
    let rule = fma(f32((word >> 0u) & 0xFFu), 1.0 / 127.5, -1.0);
    let minR = f32((word >> 8u) & 0xFFu);
    let maxR = f32((word >> 16u) & 0xFFFFu);
    return vec3<f32>(rule, minR, maxR);
}

// Classic (rule, minR, maxR) force for a distance `dist` — identical math to branch 1.
// Returns the scalar along the direction from self toward the other particle
// (positive = attract, negative = repel). Caller adds `dir * force`.
fn interaction_force(interaction: vec3<f32>, dist: f32) -> f32 {
    let maxR = interaction.z;
    if (dist >= maxR) { return 0.0; }
    let minR = interaction.y;
    var force : f32;
    if (dist < minR) {
        force = fma(dist / minR, options.repel, -options.repel);
    } else {
        let rule = interaction.x;
        let mid = (minR + maxR) * 0.5;
        let slope = rule / (mid - minR);
        force = fma(-slope, abs(dist - mid), rule);
    }
    return force;
}

// particle category: 0 matter, 1 urge, 2 neuron
fn cat(t: u32) -> u32 {
    if (t < options.numTypes) { return 0u; }
    if (t < options.numTypes + electrical.numUrges) { return 1u; }
    return 2u;
}

// Per-urge goal, derived deterministically from the urge's local index k so the population is
// diverse with NO extra buffer fields. metricMode picks the *family* of goals; the index then
// varies both the objective type and its polarity (attract + / repel −) within that family.
struct UrgeGoal {
    polarity: f32,  // +1 = wants to attract its color, -1 = wants to repel it
    useCount: u32,  // metric is a raw count (density) when set, else a local fraction
}
fn urgeGoal(k: u32) -> UrgeGoal {
    let numTypes = options.numTypes;
    if (numTypes == 0u) { return UrgeGoal(1.0, 1u); }
    var polarity: f32 = 1.0;
    var useCount: u32 = 1u;
    switch (electrical.metricMode % 4u) {
        case 0u: { // mix of attract & repel, all by local density
            if ((k % 2u) != 0u) { polarity = -1.0; }
        }
        case 1u: { // mix of attract & repel, all by local fraction
            if ((k % 2u) != 0u) { polarity = -1.0; }
            useCount = 0u;
        }
        case 2u: { // attract-by-density / repel-by-fraction
            if ((k % 2u) != 0u) { polarity = -1.0; useCount = 0u; }
        }
        default: { // cycle attract/repel AND density/fraction across the population
            let quad = (k / 2u) % 4u;
            if ((quad == 1u) || (quad == 3u)) { polarity = -1.0; }
            if ((quad == 1u) || (quad == 2u)) { useCount = 0u; }
        }
    }
    return UrgeGoal(polarity, useCount);
}

@group(0) @binding(0) var<storage, read> particlesSource : array<Particle>;
@group(0) @binding(1) var<storage, read_write> particlesDestination : array<Particle>;
@group(0) @binding(2) var<storage, read> binOffset : array<u32>;
@group(0) @binding(3) var<storage, read> interactions: InteractionMatrix;

// Extended interaction matrix for urges/neurons vs matter (see get_electrical_interaction).
@group(4) @binding(0) var<storage, read> electricalInteractions: InteractionMatrix;

@group(1) @binding(0) var<uniform> options : SimOptions;
@group(2) @binding(0) var<uniform> deltaTime : f32;
@group(3) @binding(0) var<uniform> electrical : ElectricalOptions;

@compute @workgroup_size(64)
fn computeForces(@builtin(global_invocation_id) id : vec3u) {
    if (id.x >= options.numParticles) { return; }

    let half_width = options.simWidth * 0.5;
    let half_height = options.simHeight * 0.5;
    let is_wrapping = options.isWallWrap == 1u;
    let cellSubdivisions = i32(options.cellSubdivisions);

    var particle = particlesSource[id.x];
    let myType = u32(particle.particleType);
    let myCat = cat(myType);
    let isMatter = myCat == 0u;
    let isUrge = myCat == 1u;
    let isNeuron = myCat == 2u;

    // Per-urge goal: the target color it acts on and the objective polarity/type it wants.
    let kIdx = myType - options.numTypes;                       // local urge index (valid if isUrge)
    let mIdx = myType - options.numTypes - electrical.numUrges; // local neuron index (valid if isNeuron)
    let goal = urgeGoal(kIdx);
    let urgeTarget = kIdx % options.numTypes;   // the color this urge acts on (only meaningful when isUrge)
    let neuronTarget = mIdx % options.numTypes; // the single color this neuron actuates (valid if isNeuron)

    let binInfo = getBinInfo(vec2f(particle.x, particle.y), options);

    var binXMin = binInfo.binId.x - cellSubdivisions;
    var binYMin = binInfo.binId.y - cellSubdivisions;
    var binXMax = binInfo.binId.x + cellSubdivisions;
    var binYMax = binInfo.binId.y + cellSubdivisions;

    if (!is_wrapping) {
        binXMin = max(0, binXMin);
        binYMin = max(0, binYMin);
        binXMax = min(binInfo.gridSize.x - 1, binXMax);
        binYMax = min(binInfo.gridSize.y - 1, binYMax);
    }

    var totalForce = vec2f(0.0, 0.0);
    let particlePosition = vec2f(particle.x, particle.y);

    // accumulators used by the electrical layer
    var metricCount: f32 = 0.0;   // this urge's target-color matter within urgeRadius (density metric)
    var matterTotal: f32 = 0.0;   // all matter within urgeRadius (denominator for the fraction metric)
    var drive: f32 = 0.0;         // neuron: signed sum of nearby urges' previous-frame control
    var firing: f32 = 0.0;        // neuron: magnitude of that drive (its "firing activity")
    var cohesionForce = vec2f(0.0, 0.0);

    let eOn = electrical.enabled != 0u;
    let eR = max(electrical.urgeRadius, 1.0);
    let nR = max(electrical.neuronRadius, 1.0);

    for (var binX = binXMin; binX <= binXMax; binX += 1) {
        for (var binY = binYMin; binY <= binYMax; binY += 1) {
            var realBinX = binX;
            var realBinY = binY;
            if (is_wrapping) {
                if (binX < 0) { realBinX = binX + binInfo.gridSize.x; }
                else if (binX >= binInfo.gridSize.x) { realBinX = binX - binInfo.gridSize.x; }
                if (binY < 0) { realBinY = binY + binInfo.gridSize.y; }
                else if (binY >= binInfo.gridSize.y) { realBinY = binY - binInfo.gridSize.y; }
            }
            let binIndex = u32(realBinY * binInfo.gridSize.x + realBinX);
            let binStart = binOffset[binIndex];
            let binEnd = binOffset[binIndex + 1u];

            for (var j = binStart; j < binEnd; j += 1u) {
                if (j == id.x) { continue; }

                let other = particlesSource[j];
                let oType = u32(other.particleType);
                let oCat = cat(oType);

                var r = vec2f(other.x, other.y) - particlePosition;
                if (is_wrapping) {
                    if (abs(r.x) >= half_width) { r.x -= sign(r.x) * options.simWidth; }
                    if (abs(r.y) >= half_height) { r.y -= sign(r.y) * options.simHeight; }
                }

                let distSquared = dot(r, r);
                if (distSquared < 0.0001) { continue; }
                let dist = sqrt(distSquared);
                let dir = r / dist;

                // ---- 1) classic matter <-> matter rule -----------------------------------
                if (isMatter && oCat == 0u) {
                    let myTypeOffset = myType * options.numTypes;
                    let interaction = get_interaction(myTypeOffset + oType);
                    totalForce += dir * interaction_force(interaction, dist);
                }

                if (!eOn) { continue; } // electrical layer off -> only classic forces apply

                // ---- 1b) electrical <-> matter via the extended interaction matrix --------
                // Urges and neurons push/pull matter with the SAME rule math as matter↔matter,
                // using their own per-particle row (local index) vs the matter color column.
                // Convention: only the ROW particle's entry is used, so a special particle
                // contributes its force to totalForce while the matter side gets the reaction in
                // ITS OWN pass (Newton's third law emerges from the two independent reads).
                if ((isUrge && oCat == 0u) || (isNeuron && oCat == 0u)) {
                    let kind = select(0u, 1u, isNeuron);
                    let localIndex = select(kIdx, mIdx, isNeuron);
                    let interaction = get_electrical_interaction(kind, localIndex, oType);
                    totalForce += dir * interaction_force(interaction, dist);
                }
                // ---- 1c) special <-> special: simple symmetric rule ------------------------
                // Convention chosen (documented per the spec): each party applies HALF of its own
                // row's entry toward the other special particle. Since both parties read their
                // own row in their own pass, this keeps the pair force bounded and symmetric-ish.
                if ((isUrge || isNeuron) && (oCat == 1u || oCat == 2u)) {
                    let myKind = select(0u, 1u, isNeuron);
                    let theirKind = select(0u, 1u, oCat == 2u);
                    let myLocal = select(kIdx, mIdx, isNeuron);
                    let theirLocal = select(oType - options.numTypes, oType - options.numTypes - electrical.numUrges, oCat == 2u);
                    let interaction = get_electrical_interaction(myKind, myLocal, theirLocal);
                    totalForce += dir * (0.5 * interaction_force(interaction, dist));
                }

                // ---- 2) an urge gathering the metric for ITS OWN goal ----------------------
                // (There is no direct urge->matter field anymore: urges act on matter ONLY by
                //  driving neurons, which then push/pull their single color.)
                if (isUrge && oCat == 0u && dist < eR) {
                    matterTotal += 1.0;
                    if (oType == urgeTarget) { metricCount += 1.0; }
                }

                // ---- 3) a neuron driven by nearby urges, measured FROM THE NEURON ----------
                // The reference point is this neuron: it scans for urges within `neuronRadius`
                // of itself and accumulates their previous-frame signed control (falloff-weighted).
                if (isNeuron && oCat == 1u && dist < nR) {
                    let fall = max(0.0, 1.0 - dist / nR);
                    drive += other.control * fall;   // other is the urge; .control is last frame's value
                }
                // ---- 4) a neuron actuating ONLY its own color ------------------------------
                if (isNeuron && oCat == 0u && oType == neuronTarget && dist < eR) {
                    let fall = max(0.0, 1.0 - dist / eR);
                    totalForce += dir * (drive * electrical.urgeForce * fall); // drive>0 attracts, <0 repels
                }

                // ---- 5) cohesion: specials cling to the body and avoid overlapping ----------
                if (isUrge || isNeuron) {
                    if (oCat == 0u && dist < eR) {
                        let fall = max(0.0, 1.0 - dist / eR);
                        cohesionForce += dir * (fall * electrical.cohesion);      // pull toward matter
                    } else if (oCat == 1u || oCat == 2u) {
                        if (dist < 8.0) {
                            cohesionForce -= dir * (electrical.cohesion * 2.0);   // hard anti-overlap
                        } else if (dist < eR * 0.6) {
                            cohesionForce += dir * (electrical.cohesion * 0.3);   // mild clumping
                        }
                    }
                }
            }
        }
    }

    let forceFactor = options.forceFactor * deltaTime * 60.0;

    if (isMatter) {
        particle.vx = fma(totalForce.x, forceFactor, particle.vx);
        particle.vy = fma(totalForce.y, forceFactor, particle.vy);
        // matter keeps control/signal = 0
    } else {
        // Special particles move under the extended interaction-matrix forces (branch 1b/1c,
        // already in totalForce and scaled by options.forceFactor like everything else) PLUS the
        // cohesion term, which stays scaled by the global cohesion slider so it can be zeroed out.
        // The matrix forces move the specials at full strength; cohesion is an additional
        // clump/anti-overlap term scaled by its own slider (zeroing it removes only that part).
        let cf = electrical.cohesion * 0.5;
        particle.vx = fma(totalForce.x + cohesionForce.x, forceFactor, particle.vx);
        particle.vy = fma(totalForce.y + cohesionForce.y, forceFactor, particle.vy);

        if (isUrge) {
            // The metric value for this urge's OWN goal, evaluated from the previous frame.
            let M = select(metricCount, select(0.0, metricCount / matterTotal, matterTotal > 0.0), goal.useCount == 1u);

            // Hebbian rule toward the goal's polarity: when the metric moves in the direction the
            // urge wants (dM has the sign of its polarity) it pushes harder; otherwise it backs off.
            let dM = M - particle.signal; // gradient vs the previous frame's stored value
            var newControl = particle.control + electrical.controlGain * goal.polarity * dM;
            newControl = clamp(newControl, -electrical.controlMax, electrical.controlMax);

            particle.control = newControl;
            particle.signal = mix(particle.signal, M, 0.15); // smooth the stored metric
        } else { // neuron: activity = magnitude of the drive it is under (it "fires" when recruited)
            firing = abs(drive);
            particle.signal = mix(particle.signal, firing, 0.2);
            particle.control = 0.0;
        }
    }

    particlesDestination[id.x] = particle;
}
