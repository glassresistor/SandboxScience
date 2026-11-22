// =============================================================================
// Particle Life — 2D GPU force pass  (with Urge / Neuron "quantum-electrical" layer)
//
// Particle type layout (see CPU side):
//   [0, numTypes)                       -> matter colors (classic particle life rules)
//   [numTypes, numTypes + numUrges)     -> urges.  local index k = type - numTypes
//                                         target color = k % numTypes (the metric it maximises)
//   [numTypes+numUrges, TOTAL_TYPES)    -> neurons. local index m = type - numTypes - numUrges
//                                         mode       = m % 3        (0 attract / 1 repel / 2 self-attract)
//                                         target color = floor(m/3) % numTypes
//
// Each particle carries two persistent "electrical" scalars that survive across frames:
//   control : for an urge, its current attract(+) / repel(-) bias applied to nearby matter.
//             A neuron within `neuronRadius` nudges this value in real time; the more neurons
//             are around, the more authority (bigger allowed change) the urge gets.
//   signal  : for an urge, the running value of the objective metric it is maximising.
//             Comparing this frame's metric with `signal` (the previous frame's value) gives a
//             dM/dt gradient that drives a simple Hebbian learning rule on `control`.
//
// Because these fields live in the particle buffer, the sort pass carries them to next frame's
// source automatically -> "the next iteration uses information from the prior" with a SINGLE pass.
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
    control : f32, // urge attract/repel bias (modified by neurons) — persists across frames
    signal  : f32, // urge running objective-metric value (prior frame) for dM/dt learning
}
struct ElectricalOptions {
    enabled: u32,        // master switch for the whole electrical layer
    metricMode: u32,     // 0 local density of target color / 1 local fraction / 2 own-type density
    numUrges: u32,       // number of urge particles (== number of distinct urge types)
    numNeurons: u32,     // number of neuron particles
    urgeRadius: f32,     // radius over which an urge acts on matter & measures its metric
    neuronRadius: f32,   // radius over which a neuron modulates an urge
    urgeForce: f32,      // strength of an urge's attract/repel field on matter
    controlGain: f32,    // learning rate: how strongly dM/dt pushes the urge's control
    controlMax: f32,     // clamp on |control|
    neuronInfluence: f32,// strength of a single neuron's vote on an urge's control
    neuronAuthority: f32,// extra authority gained per nearby neuron (more neurons = more control)
    maxAuthority: f32,   // cap on the accumulated neuron authority
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

// particle category: 0 matter, 1 urge, 2 neuron
fn cat(t: u32) -> u32 {
    if (t < options.numTypes) { return 0u; }
    if (t < options.numTypes + electrical.numUrges) { return 1u; }
    return 2u;
}

@group(0) @binding(0) var<storage, read> particlesSource : array<Particle>;
@group(0) @binding(1) var<storage, read_write> particlesDestination : array<Particle>;
@group(0) @binding(2) var<storage, read> binOffset : array<u32>;
@group(0) @binding(3) var<storage, read> interactions: InteractionMatrix;

@group(1) @binding(0) var<uniform> options : SimOptions;
@group(2) @binding(0) var<uniform> deltaTime : f32;
@group(3) @binding(0) var<uniform> electrical : ElectricalOptions;

@compute @workgroup_size(64)
fn computeForces(@builtin(global_invocation_id) id : vec3u) {
    if (id.x >= options.numParticles) { return; }

    let half_width = options.simWidth * 0.5;
    let half_height = options.simHeight * 0.5;
    let is_wrapping = options.isWallWrap == 1u;
    let repelForce = options.repel;
    let cellSubdivisions = i32(options.cellSubdivisions);

    var particle = particlesSource[id.x];
    let myType = u32(particle.particleType);
    let myCat = cat(myType);
    let isMatter = myCat == 0u;
    let isUrge = myCat == 1u;
    let isNeuron = myCat == 2u;
    // the color this urge wants to maximise (only meaningful when isUrge)
    let urgeTarget = (myType - options.numTypes) % options.numTypes;

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
    var metricCount: f32 = 0.0;   // target-color matter within urgeRadius  (metric mode 0)
    var matterTotal: f32 = 0.0;   // all matter within urgeRadius           (metric mode 1)
    var nearUrges: f32 = 0.0;     // urges within range                     (metric mode 2 / neuron activity)
    var neuronBias: f32 = 0.0;    // sum of nearby neurons' votes on this urge's control
    var neuronCount: u32 = 0u;    // number of nearby neurons (drives authority)
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
                    let maxR = interaction.z;
                    if (dist < maxR) {
                        let minR = interaction.y;
                        var force : f32;
                        if (dist < minR) {
                            force = fma(dist / minR, repelForce, -repelForce);
                        } else {
                            let rule = interaction.x;
                            let mid = (minR + maxR) * 0.5;
                            let slope = rule / (mid - minR);
                            force = fma(-slope, abs(dist - mid), rule);
                        }
                        totalForce += dir * force;
                    }
                }

                if (!eOn) { continue; } // electrical layer off -> only classic forces apply

                // ---- 2) urge field acting on this matter particle (additive when clumped) --
                if (isMatter && oCat == 1u && dist < eR) {
                    let fall = max(0.0, 1.0 - dist / eR);
                    totalForce += dir * (other.control * fall * electrical.urgeForce);
                }

                // ---- 3) an urge gathering its metric + neuron modulation ------------------
                if (isUrge) {
                    if (oCat == 0u && dist < eR) {
                        matterTotal += 1.0;
                        if (oType == urgeTarget) { metricCount += 1.0; }
                    }
                    if (oCat == 2u && dist < nR) {
                        let mIdx = oType - options.numTypes - electrical.numUrges;
                        let mode = mIdx % 3u;                       // 0 attract / 1 repel / 2 self
                        let nTarget = (mIdx / 3u) % options.numTypes;
                        var s: f32 = 1.0;
                        if (mode == 1u) { s = -1.0; }
                        else if (mode == 2u) { s = 0.5; }
                        let w = select(0.3, 1.0, nTarget == urgeTarget); // neurons sharing the urge's interest weigh more
                        let fall = max(0.0, 1.0 - dist / nR);
                        neuronBias += s * fall * w;
                        neuronCount += 1u;
                    }
                    if (oCat == 1u && dist < eR) { nearUrges += 1.0; }
                }

                // ---- 4) a neuron measuring how many urges it is wired to --------------------
                if (isNeuron && oCat == 1u && dist < nR) { nearUrges += 1.0; }

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
        // special particles move only under cohesion (friction is applied in the advance pass)
        let cf = electrical.cohesion * 0.5;
        particle.vx = fma(cohesionForce.x, forceFactor * cf, particle.vx);
        particle.vy = fma(cohesionForce.y, forceFactor * cf, particle.vy);

        if (isUrge) {
            // the metric value this urge is trying to maximise, evaluated this frame
            var M: f32;
            if (electrical.metricMode == 1u) {
                M = select(0.0, metricCount / matterTotal, matterTotal > 0.0);
            } else if (electrical.metricMode == 2u) {
                M = nearUrges;
            } else {
                M = metricCount;
            }

            let dM = M - particle.signal; // gradient vs the previous frame's stored value
            var newControl = particle.control + electrical.controlGain * dM;

            // neurons grant authority: more nearby neurons -> bigger allowed change
            let authority = min(1.0 + f32(neuronCount) * electrical.neuronAuthority, electrical.maxAuthority);
            newControl += neuronBias * electrical.neuronInfluence * authority;
            newControl = clamp(newControl, -electrical.controlMax, electrical.controlMax);

            particle.control = newControl;
            particle.signal = mix(particle.signal, M, 0.15); // smooth the stored metric
        } else { // neuron: activity = how many urges it is close to (it "fires" more when busy)
            particle.signal = mix(particle.signal, nearUrges, 0.2);
            particle.control = 0.0;
        }
    }

    particlesDestination[id.x] = particle;
}
