// Particle Life — 2D GPU BRUTE-FORCE force pass (with Urge / Neuron "quantum-electrical" layer)
// Same particle layout & electrical semantics as particleComputeForces.wgsl; O(N^2) neighbor scan.
// MODEL: urges modulate NEURONS; neurons actuate MATTER. Each urge has its own goal (derived from
// its index k); a neuron scans for urges within `neuronRadius` OF ITSELF, sums their previous-frame
// signed control into a drive, then pushes/pulls ONLY matter of its single color (m % numTypes).
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
    cellSubdivisions: u32,  // (unused in brute force, present for struct layout alignment)
    matrixStride: u32,  // stride of the interaction matrix (= numTypes + 2)
};
struct Particle {
    x : f32,
    y : f32,
    vx : f32,
    vy : f32,
    particleType : f32,
    control : f32,
    signal  : f32,
    goalB   : f32, // secondary goal index (local k), -1 if none
}
struct ElectricalOptions {
    enabled: u32,
    metricMode: u32,
    numUrges: u32,
    numNeurons: u32,
    urgeRadius: f32,
    neuronRadius: f32,
    urgeForce: f32,
    controlGain: f32,
    controlMax: f32,
    neuronInfluence: f32,
    neuronAuthority: f32,
    maxAuthority: f32,
    cohesion: f32,
};

// Per-urge goal (see particleComputeForces.wgsl): each urge has a target color and a goal mode.
struct UrgeGoal {
    mode: u32,        // 0 = maximize density, 1 = minimize density, 2 = homeostasis
    targetValue: f32, // for homeostasis: the desired normalized metric value (O(1) scale)
}
fn urgeGoal(k: u32) -> UrgeGoal {
    let numTypes = options.numTypes;
    if (numTypes == 0u) { return UrgeGoal(0u, 1.0); }
    var mode: u32;
    switch (electrical.metricMode % 4u) {
        case 0u: { mode = k % 3u; break; } // cycle all three
        case 1u: { mode = 0u; break; }     // all maximize
        case 2u: { mode = 1u; break; }     // all minimize
        default: { mode = 2u; break; }     // all homeostasis
    }
    var targetValue: f32 = 1.0;
    if (mode == 2u) {
        let hash = fract(sin(f32(k) * 12.9898 + 78.233) * 43758.5453);
        targetValue = 0.6 + hash * 0.8;
    }
    return UrgeGoal(mode, targetValue);
}

fn get_interaction(index: u32, numTypes: u32) -> vec3<f32> {
    let word = interactions.data[index];
    let rule = (f32((word >> 0u) & 0xFFu) / 255.0) * 2.0 - 1.0;
    let minR = f32((word >> 8u) & 0xFFu);
    let maxR = f32((word >> 16u) & 0xFFFFu);
    return vec3<f32>(rule, minR, maxR);
}

// Classic (rule, minR, maxR) force for a distance `dist` — identical math to the matter branch.
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

// particle category: 0 matter, 1 urge, 2 neuron, 3 dormant (clone pool slot)
// Default is NEURON (the historical behavior for any type >= numTypes+numUrges); only a type
// strictly above the whole known population (matter+urges+neurons) is treated as a dormant
// clone-pool slot. This keeps stale/mis-labeled types behaving like neurons instead of vanishing.
fn cat(t: u32) -> u32 {
    if (t < options.numTypes) { return 0u; }
    if (t < options.numTypes + electrical.numUrges) { return 1u; }
    // Dormant ONLY when the type is exactly the dormant slot code. Any other out-of-range value
    // falls through to neuron so stale/mis-labeled particles stay visible and keep moving.
    if (t == options.numTypes + electrical.numUrges + electrical.numNeurons) { return 3u; }
    return 2u;
}

@group(0) @binding(0) var<storage, read> particles: array<Particle>;
@group(0) @binding(1) var<storage, read_write> particlesDestination : array<Particle>;
@group(0) @binding(2) var<storage, read> interactions: InteractionMatrix;
@group(1) @binding(0) var<uniform> options: SimOptions;
@group(2) @binding(0) var<uniform> deltaTime: f32;
@group(3) @binding(0) var<uniform> electrical : ElectricalOptions;

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) id: vec3<u32>) {
    let i = id.x;
    if (i >= options.numParticles) { return; }

    let half_width = options.simWidth * 0.5;
    let half_height = options.simHeight * 0.5;
    let is_wrapping = options.isWallWrap == 1u;

    var particle = particles[i];
    let typeA = u32(particle.particleType);
    let myCat = cat(typeA);
    if (myCat == 3u) { particlesDestination[i] = particle; return; } // dormant: pass through unchanged
    let isMatter = myCat == 0u;
    let isUrge = myCat == 1u;
    let isNeuron = myCat == 2u;

    let kIdx = typeA - options.numTypes;                       // local urge index (valid if isUrge)
    let mIdx = typeA - options.numTypes - electrical.numUrges; // local neuron index (valid if isNeuron)
    let goal = urgeGoal(kIdx);
    let urgeTarget = kIdx % options.numTypes;   // the color this urge acts on
    let neuronTarget = mIdx % options.numTypes; // the single color this neuron actuates

    var velocitySum = vec2<f32>(0.0, 0.0);
    var metricCount: f32 = 0.0;
    var metricCountB: f32 = 0.0; // secondary goal target-color count (for merged urges)
    var drive: f32 = 0.0;      // neuron: signed sum of nearby urges' previous-frame control
    var firing: f32 = 0.0;     // neuron: magnitude of that drive (its "firing activity")
    var cohesionForce = vec2<f32>(0.0, 0.0);

    // Secondary goal setup (for merged urges)
    let hasGoalB = particle.goalB >= 0.0;
    var goalB_kIdx: u32 = 0u;
    var goalB_target: u32 = 0u;
    if (hasGoalB) {
        goalB_kIdx = u32(particle.goalB);
        goalB_target = goalB_kIdx % options.numTypes;
    }

    let eOn = electrical.enabled != 0u;
    let eR = max(electrical.urgeRadius, 1.0);
    let nR = max(electrical.neuronRadius, 1.0);

    for (var j = 0u; j < options.numParticles; j = j + 1u) {
        if (i == j) { continue; }

        var other = particles[j];
        let typeB = u32(other.particleType);
        let oCat = cat(typeB);
        if (oCat == 3u) { continue; } // dormant clone slot — skip
        var dx = other.x - particle.x;
        var dy = other.y - particle.y;

        if (is_wrapping) {
            if (dx > half_width) { dx -= options.simWidth; }
            else if (dx < -half_width) { dx += options.simWidth; }
            if (dy > half_height) { dy -= options.simHeight; }
            else if (dy < -half_height) { dy += options.simHeight; }
        }

        let dist = sqrt(dx * dx + dy * dy);
        if (dist < 0.0001) { continue; }
        let dir = vec2f(dx, dy) / dist;

        // ---- classic matter <-> matter rule --------------------------------------------
        if (isMatter && oCat == 0u) {
            let index = typeA * options.matrixStride + typeB;
            let params = get_interaction(index, options.numTypes);
            velocitySum += dir * interaction_force(params, dist);
        }

        if (!eOn) { continue; }

        // ---- electrical <-> matter via the main interaction matrix -----------------------
        // Shared rows: row numTypes = "urge", row numTypes+1 = "neuron" (applies to all).
        if ((isUrge && oCat == 0u) || (isNeuron && oCat == 0u)) {
            let rowIdx = options.numTypes + select(0u, 1u, isNeuron);
            let params = get_interaction(rowIdx * options.matrixStride + typeB, options.numTypes);
            velocitySum += dir * interaction_force(params, dist);
        }
        // Note: special<->special interactions are handled by the cohesion force below;
        // the electrical interaction matrix only stores special-vs-matter rows.

        // ---- an urge gathering the metric for ITS OWN goal ------------------------------
        // (no direct urge->matter field: urges act on matter only by driving neurons)
        if (isUrge && oCat == 0u && dist < eR) {
            if (typeB == urgeTarget) { metricCount += 1.0; }
            if (hasGoalB && typeB == goalB_target) { metricCountB += 1.0; }
        }

        // ---- a neuron driven by nearby urges, measured FROM THE NEURON ------------------
        if (isNeuron && oCat == 1u && dist < nR) {
            let fall = max(0.0, 1.0 - dist / nR);
            drive += other.control * fall;   // other is the urge; .control is last frame's value
        }
        // ---- a neuron actuating ONLY its own color -------------------------------------
        if (isNeuron && oCat == 0u && typeB == neuronTarget && dist < eR) {
            let fall = max(0.0, 1.0 - dist / eR);
            velocitySum += dir * (drive * electrical.urgeForce * fall); // drive>0 attracts, <0 repels
        }

        // ---- cohesion ------------------------------------------------------------------
        if (isUrge || isNeuron) {
            if (oCat == 0u && dist < eR) {
                let fall = max(0.0, 1.0 - dist / eR);
                cohesionForce += dir * (fall * electrical.cohesion);
            } else if (oCat == 1u || oCat == 2u) {
                if (dist < 8.0) { cohesionForce -= dir * (electrical.cohesion * 2.0); }
                else if (dist < eR * 0.6) { cohesionForce += dir * (electrical.cohesion * 0.3); }
            }
        }
    }

    let forceFactor = options.forceFactor * deltaTime * 60.0;

    if (isMatter) {
        particle.vx += velocitySum.x * forceFactor;
        particle.vy += velocitySum.y * forceFactor;
    } else {
        // Special particles move under the extended interaction-matrix forces (already in
        // velocitySum, scaled by options.forceFactor like everything else) PLUS the cohesion
        // term, which stays scaled by the global cohesion slider so it can be zeroed out.
        let cf = electrical.cohesion * 0.5;
        particle.vx += (velocitySum.x + cohesionForce.x) * forceFactor;
        particle.vy += (velocitySum.y + cohesionForce.y) * forceFactor;

        if (isUrge) {
            // Normalize metric to O(1): mean=1.0 at baseline uniform distribution.
            let numTypesF = f32(options.numTypes);
            let area = options.simWidth * options.simHeight;
            let numMatterApprox = max(f32(options.numParticles) - f32(electrical.numUrges + electrical.numNeurons), 1.0);
            let eR = max(electrical.urgeRadius, 1.0);
            let expectedCount = numMatterApprox * 3.14159265 * eR * eR / area / numTypesF;

            let M = metricCount / max(expectedCount, 0.001);

            // Combined metric: if a secondary goal exists (merged urge), add its contribution.
            var M_combined = M;
            if (hasGoalB) {
                let M_B = metricCountB / max(expectedCount, 0.001);
                M_combined = M + M_B;
            }

            // Learning rule depends on the urge's goal mode:
            let dM = M_combined - particle.signal;
            var newControl: f32;
            if (goal.mode == 0u) {
                newControl = particle.control + electrical.controlGain * dM; // maximize
            } else if (goal.mode == 1u) {
                newControl = particle.control - electrical.controlGain * dM; // minimize
            } else {
                let error = goal.targetValue - M_combined;
                let targetCtrl = clamp(error, -1.0, 1.0) * electrical.controlMax;
                newControl = mix(particle.control, targetCtrl, electrical.controlGain); // homeostasis
            }
            newControl = clamp(newControl, -electrical.controlMax, electrical.controlMax);
            particle.control = newControl;
            particle.signal = mix(particle.signal, M_combined, 0.15);
        } else {
            firing = abs(drive);
            particle.signal = mix(particle.signal, firing, 0.2);
            particle.control = 0.0;
        }
    }

    particlesDestination[i] = particle;
};
