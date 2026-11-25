// Particle Life — 2D GPU BRUTE-FORCE force pass (with Brain / Neuron "quantum-electrical" layer)
// Same particle layout & electrical semantics as particleComputeForces.wgsl; O(N^2) neighbor scan.
// MODEL: brains own private nets; force pass is pure actuation. Motor neurons read drive from
// neuronMods (written by brainStep') and push/pull their single color. No learning in this pass.
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
    matrixStride: u32,
};
struct Particle {
    x : f32,
    y : f32,
    vx : f32,
    vy : f32,
    particleType : f32,
    control : f32,
    signal  : f32,
    goalB   : f32,
    driveTarget : f32,
    driveScale  : f32,
    driveGain   : f32,
}
struct ElectricalOptions {
    enabled: u32,
    metricMode: u32,     // deprecated
    numUrges: u32,       // = numBrains
    numNeurons: u32,
    urgeRadius: f32,
    neuronRadius: f32,   // capture radius (repurposed)
    urgeForce: f32,
    controlGain: f32,    // deprecated
    controlMax: f32,     // deprecated
    neuronInfluence: f32,// legacy
    neuronAuthority: f32,// legacy
    maxAuthority: f32,   // legacy
    cohesion: f32,
    numSenseNeurons: u32,
    senseRadius: f32,
    senseConeHalfAngle: f32,
    senseMode: u32,
};

// NOTE: brute-force path does NOT have neuronMods binding (no brain modulation in O(N^2) mode
// for now — the spatial-hash path is primary). If needed, add it as a separate binding.
// For parity, we include it:
struct ElectricalOptionsFull {
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
    numSenseNeurons: u32,
    senseRadius: f32,
    senseConeHalfAngle: f32,
    senseMode: u32,
};

fn get_interaction(index: u32, numTypes: u32) -> vec3<f32> {
    let word = interactions.data[index];
    let rule = (f32((word >> 0u) & 0xFFu) / 255.0) * 2.0 - 1.0;
    let minR = f32((word >> 8u) & 0xFFu);
    let maxR = f32((word >> 16u) & 0xFFFFu);
    return vec3<f32>(rule, minR, maxR);
}

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

fn cat(t: u32) -> u32 {
    if (t < options.numTypes) { return 0u; }
    if (t < options.numTypes + electrical.numUrges) { return 1u; }
    if (t < options.numTypes + electrical.numUrges + electrical.numNeurons) { return 2u; }
    if (t < options.numTypes + electrical.numUrges + electrical.numNeurons + electrical.numSenseNeurons) { return 4u; }
    if (t == options.numTypes + electrical.numUrges + electrical.numNeurons + electrical.numSenseNeurons) { return 3u; }
    return 2u;
}

const PI_CONST = 3.14159265;
const TWO_PI_CONST = 6.2831853;
const SENSE_SECTORS: u32 = 12u;

@group(0) @binding(0) var<storage, read> particles: array<Particle>;
@group(0) @binding(1) var<storage, read_write> particlesDestination : array<Particle>;
@group(0) @binding(2) var<storage, read> interactions: InteractionMatrix;
@group(0) @binding(3) var<storage, read> neuronMods : array<f32>; // brain output drive

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
    if (myCat == 3u) { particlesDestination[i] = particle; return; }
    let isMatter = myCat == 0u;
    let isBrain = myCat == 1u;
    let isNeuron = myCat == 2u;
    let isSense = myCat == 4u;

    let mIdx = typeA - options.numTypes - electrical.numUrges;
    let neuronTarget = mIdx % options.numTypes;

    // Sense-neuron setup (unchanged)
    let sIdx = typeA - options.numTypes - electrical.numUrges - electrical.numNeurons;
    let senseTarget = sIdx % options.numTypes;
    var senseModeLocal: u32 = 0u;
    switch (electrical.senseMode % 4u) {
        case 0u: { senseModeLocal = sIdx % 3u; }
        case 1u: { senseModeLocal = 0u; break; }
        case 2u: { senseModeLocal = 1u; break; }
        default: { senseModeLocal = 2u; break; }
    }
    let sR = max(electrical.senseRadius, 1.0);
    let vlen = length(vec2f(particle.vx, particle.vy));
    let hasHeading = vlen > 0.001;
    let heading = vec2f(particle.vx, particle.vy) / max(vlen, 0.001);
    let cosHalfAngle = cos(electrical.senseConeHalfAngle);

    var velocitySum = vec2<f32>(0.0, 0.0);
    var drive: f32 = 0.0;
    var firing: f32 = 0.0;
    var cohesionForce = vec2<f32>(0.0, 0.0);
    var seenCount: f32 = 0.0;
    var sectorScores = array<f32, SENSE_SECTORS>(
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0
    );
    var soundVec = vec2f(0.0, 0.0);
    var soundCount: f32 = 0.0;

    let eOn = electrical.enabled != 0u;
    let eR = max(electrical.urgeRadius, 1.0);

    for (var j = 0u; j < options.numParticles; j = j + 1u) {
        if (i == j) { continue; }

        var other = particles[j];
        let typeB = u32(other.particleType);
        let oCat = cat(typeB);
        if (oCat == 3u) { continue; }
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
        if ((isBrain && oCat == 0u) || (isNeuron && oCat == 0u) || (isSense && oCat == 0u)) {
            let rowIdx = options.numTypes + select(0u, 1u, isNeuron || isSense);
            let params = get_interaction(rowIdx * options.matrixStride + typeB, options.numTypes);
            velocitySum += dir * interaction_force(params, dist);
        }

        // ---- DELETED: brain metric gathering (moved to brainStep') ------------------------
        // ---- DELETED: neuron local-proximity drive from nearby brains ----------------------

        // ---- a motor neuron actuating ONLY its own color -----------------------------------
        if (isNeuron && oCat == 0u && typeB == neuronTarget && dist < eR) {
            let fall = max(0.0, 1.0 - dist / eR);
            velocitySum += dir * (drive * electrical.urgeForce * fall);
        }

        // ---- a sense neuron perceiving its ONE target color (UNCHANGED) --------------------
        if (isSense && oCat == 0u && typeB == senseTarget && dist < sR) {
            if (senseModeLocal == 0u) {
                if (hasHeading && dot(dir, heading) > cosHalfAngle) { seenCount += 1.0; }
            } else if (senseModeLocal == 1u) {
                let ang = atan2(dir.y, dir.x) + PI_CONST;
                let sec = u32(ang / (TWO_PI_CONST / f32(SENSE_SECTORS))) % SENSE_SECTORS;
                sectorScores[sec] += (sR - dist) / sR;
            } else {
                soundVec += dir;
                soundCount += 1.0;
            }
        }

        // ---- cohesion ----------------------------------------------------------------------
        if (isBrain || isNeuron || isSense) {
            if (oCat == 0u && dist < eR) {
                let fall = max(0.0, 1.0 - dist / eR);
                cohesionForce += dir * (fall * electrical.cohesion);
            } else if (oCat == 1u || oCat == 2u || oCat == 4u) {
                if (dist < 8.0) { cohesionForce -= dir * (electrical.cohesion * 2.0); }
                else if (dist < eR * 0.6) { cohesionForce += dir * (electrical.cohesion * 0.3); }
            }
        }
    }

    // ---- BRAIN MODULATION: sole drive source for motor neurons --------
    if (isNeuron && eOn) {
        drive = neuronMods[mIdx] * electrical.brainGain;
    }

    let forceFactor = options.forceFactor * deltaTime * 60.0;

    if (isMatter) {
        particle.vx += velocitySum.x * forceFactor;
        particle.vy += velocitySum.y * forceFactor;
    } else {
        let cf = electrical.cohesion * 0.5;
        particle.vx += (velocitySum.x + cohesionForce.x) * forceFactor;
        particle.vy += (velocitySum.y + cohesionForce.y) * forceFactor;

        if (isBrain) {
            // Brain: no per-frame control learning (genome is source of truth)
            particle.control = 0.0;
        } else if (isNeuron) {
            firing = abs(drive);
            particle.signal = mix(particle.signal, firing, 0.2);
            particle.control = 0.0;
        } else if (isSense) {
            let numTypesF = f32(options.numTypes);
            let area = options.simWidth * options.simHeight;
            let numMatterApprox = max(f32(options.numParticles) - f32(electrical.numUrges + electrical.numNeurons + electrical.numSenseNeurons), 1.0);
            let expectedCount = numMatterApprox * PI_CONST * sR * sR / area / numTypesF;

            var newSignal: f32 = 0.0;
            var newControl: f32 = 0.0;
            if (senseModeLocal == 0u) {
                let expectedInCone = expectedCount * (electrical.senseConeHalfAngle / PI_CONST);
                newSignal = clamp(seenCount / max(expectedInCone, 0.001), 0.0, 1.0);
            } else if (senseModeLocal == 1u) {
                var bestScore: f32 = 0.0;
                var bestSector: u32 = 0u;
                for (var sec = 0u; sec < SENSE_SECTORS; sec += 1u) {
                    if (sectorScores[sec] > bestScore) { bestScore = sectorScores[sec]; bestSector = sec; }
                }
                if (bestScore > 0.0001) {
                    newSignal = clamp(bestScore / max(expectedCount / f32(SENSE_SECTORS), 0.001), 0.0, 1.0);
                    newControl = (f32(bestSector) + 0.5) * TWO_PI_CONST / f32(SENSE_SECTORS) - PI_CONST;
                }
            } else {
                if (soundCount > 0.0) {
                    newSignal = clamp(soundCount / max(expectedCount, 0.001), 0.0, 1.0);
                    newControl = atan2(soundVec.y, soundVec.x);
                }
            }
            particle.signal = mix(particle.signal, newSignal, 0.25);
            particle.control = newControl;
        }
    }

    particlesDestination[i] = particle;
};
