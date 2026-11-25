// =============================================================================
// Particle Life — 2D GPU force pass  (with Brain / Neuron "quantum-electrical" layer)
//
// Particle type layout:
//   [0, numTypes)                       -> matter colors (classic particle life rules)
//   [numTypes, numTypes + numBrains)    -> brains.  local index k = type - numTypes
//   [numTypes+numBrains, TOTAL_TYPES)   -> motor neurons. local m = type - numTypes - numBrains
//                                          target color = m % numTypes
//   [sense band]                        -> sense neurons (sensors, one target color each)
//   DORMANT sentinel                    -> clone pool slots
//
// MODEL: brains own private neural nets; the force pass is pure actuation.
//   * A brain particle has NO per-frame control and does NOT learn in this pass.
//     Its genome (needs + weights) lives in a separate GPU buffer.
//   * A motor neuron reads its drive ONLY from `neuronMods` (written by the brain
//     forward pass) and pushes/pulls its single target color by `drive * urgeForce`.
//   * Sense neurons perceive their one target color (unchanged perception math).
//   * Nothing in this pass scans for brains or learns.
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
    matrixStride: u32,
    numUrges: u32,       // renamed: now "numBrains" but kept for buffer layout compat
    neuronRadius: f32,   // repurposed as capture radius
    isDebugConnections: u32,
    numSenseNeurons: u32,
    senseRadius: f32,
    magneticStrength: f32,
};
struct Particle {
    x : f32,
    y : f32,
    vx : f32,
    vy : f32,
    particleType : f32,
    control : f32, // brain: unused (genome is source of truth). neuron: 0. sense: bearing.
    signal  : f32, // brain: prior-frame metric (unused for learning now). neuron: firing. sense: magnitude.
    goalB   : f32, // legacy: secondary goal index (-1 if none)
    driveTarget : f32, // non-authoritative (genome buffer is source of truth)
    driveScale  : f32, // non-authoritative
    driveGain   : f32, // non-authoritative
}
struct ElectricalOptions {
    enabled: u32,
    metricMode: u32,     // deprecated (goal modes gone); kept for buffer layout
    numUrges: u32,       // = numBrains
    numNeurons: u32,
    urgeRadius: f32,
    neuronRadius: f32,   // repurposed: capture radius
    urgeForce: f32,      // strength of a motor neuron's actuation on its color
    controlGain: f32,    // deprecated (no per-frame control learning)
    controlMax: f32,     // deprecated
    neuronInfluence: f32,// legacy unused
    neuronAuthority: f32,// legacy unused
    maxAuthority: f32,   // legacy unused
    cohesion: f32,
    numSenseNeurons: u32,
    senseRadius: f32,
    senseConeHalfAngle: f32,
    senseMode: u32,
    brainGain: f32,      // global brain network output gain (sole drive source for neurons)
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

// particle category: 0 matter, 1 brain, 2 motor neuron, 4 sense neuron, 3 dormant
fn cat(t: u32) -> u32 {
    if (t < options.numTypes) { return 0u; }
    if (t < options.numTypes + electrical.numUrges) { return 1u; }                       // brain
    if (t < options.numTypes + electrical.numUrges + electrical.numNeurons) { return 2u; } // motor neuron
    if (t < options.numTypes + electrical.numUrges + electrical.numNeurons + electrical.numSenseNeurons) { return 4u; } // sense neuron
    if (t == options.numTypes + electrical.numUrges + electrical.numNeurons + electrical.numSenseNeurons) { return 3u; } // dormant
    return 2u;
}

const PI_CONST = 3.14159265;
const TWO_PI_CONST = 6.2831853;
const SENSE_SECTORS: u32 = 12u;

@group(0) @binding(0) var<storage, read> particlesSource : array<Particle>;
@group(0) @binding(1) var<storage, read_write> particlesDestination : array<Particle>;
@group(0) @binding(2) var<storage, read> binOffset : array<u32>;
@group(0) @binding(3) var<storage, read> interactions: InteractionMatrix;
@group(0) @binding(4) var<storage, read> neuronMods : array<f32>; // brain output: per-neuron drive [-1,1]
@group(0) @binding(5) var<storage, read> neuronHealth : array<f32>; // per-neuron health [0..1]

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
    if (myCat == 3u) { particlesDestination[id.x] = particle; return; } // dormant: pass through
    let isMatter = myCat == 0u;
    let isBrain = myCat == 1u;
    let isNeuron = myCat == 2u;
    let isSense = myCat == 4u;

    let kIdx = myType - options.numTypes;                       // local brain index (valid if isBrain)
    let mIdx = myType - options.numTypes - electrical.numUrges; // local motor neuron index (valid if isNeuron)
    let neuronTarget = mIdx % options.numTypes;                 // the single color this motor neuron actuates

    // Sense-neuron setup (unchanged perception model)
    let sIdx = myType - options.numTypes - electrical.numUrges - electrical.numNeurons;
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

    var localMagneticB: f32 = 0.0;

    // Accumulators (brain does NOT gather metrics here — that moved to brainStep')
    var drive: f32 = 0.0;         // neuron: drive from neuronMods (set after the loop)
    var firing: f32 = 0.0;        // neuron: magnitude of drive
    var cohesionForce = vec2f(0.0, 0.0);
    // Sense accumulators:
    var seenCount: f32 = 0.0;
    var sectorScores = array<f32, SENSE_SECTORS>(
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0
    );
    var soundVec = vec2f(0.0, 0.0);
    var soundCount: f32 = 0.0;

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
                if (oCat == 3u) { continue; } // dormant: skip

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
                    let myTypeOffset = myType * options.matrixStride;
                    let interaction = get_interaction(myTypeOffset + oType);
                    totalForce += dir * interaction_force(interaction, dist);
                }

                if (!eOn) { continue; }

                // ---- 1b) electrical <-> matter via the main interaction matrix ------------
                if ((isBrain && oCat == 0u) || (isNeuron && oCat == 0u) || (isSense && oCat == 0u)) {
                    let rowIdx = options.numTypes + select(0u, 1u, isNeuron || isSense);
                    let interaction = get_interaction(rowIdx * options.matrixStride + oType);
                    totalForce += dir * interaction_force(interaction, dist);
                }

                // ---- 2) DELETED: urge metric gathering (moved to brainStep') ---------------
                // (brains no longer scan for matter in the force pass)

                // ---- 3) DELETED: neuron local-proximity drive from nearby brains -----------
                // (neurons no longer scan for brains; their drive comes ONLY from neuronMods)

                // ---- 4) a motor neuron actuating ONLY its own color ------------------------
                if (isNeuron && oCat == 0u && oType == neuronTarget && dist < eR) {
                    let fall = max(0.0, 1.0 - dist / eR);
                    if (neuronHealth[mIdx] >= 0.5) {
                        totalForce += dir * (drive * electrical.urgeForce * fall);
                    }
                }

                // ---- 4b) matter feels local B from nearby motor neurons --------------------
                if (isMatter && oCat == 2u && dist < nR) {
                    let fall = max(0.0, 1.0 - dist / nR);
                    localMagneticB += other.signal * fall;
                }

                // ---- 5) a sense neuron perceiving its ONE target color (UNCHANGED) ----------
                if (isSense && oCat == 0u && oType == senseTarget && dist < sR) {
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

                // ---- 6) cohesion: specials cling to the body and avoid overlapping ----------
                if (isBrain || isNeuron || isSense) {
                    if (oCat == 0u && dist < eR) {
                        let fall = max(0.0, 1.0 - dist / eR);
                        cohesionForce += dir * (fall * electrical.cohesion);
                    } else if (oCat == 1u || oCat == 2u || oCat == 4u) {
                        if (dist < 8.0) {
                            cohesionForce -= dir * (electrical.cohesion * 2.0);
                        } else if (dist < eR * 0.6) {
                            cohesionForce += dir * (electrical.cohesion * 0.3);
                        }
                    }
                }
            }
        }
    }

    // ---- BRAIN MODULATION: the SOLE drive source for motor neurons --------
    if (isNeuron && eOn) {
        drive = neuronMods[mIdx] * electrical.brainGain;
    }

    let forceFactor = options.forceFactor * deltaTime * 60.0;

    if (isMatter) {
        particle.vx = fma(totalForce.x, forceFactor, particle.vx);
        particle.vy = fma(totalForce.y, forceFactor, particle.vy);

        // Neuron-local magnetic (Lorentz) force (unchanged)
        if (options.magneticStrength != 0.0 && localMagneticB > 0.001) {
            let pTypeF = particle.particleType;
            let angle = pTypeF * 2.3999632;
            let q = sin(angle);
            let bLocal = options.magneticStrength * localMagneticB;
            let oldVx = particle.vx;
            let oldVy = particle.vy;
            particle.vx += q * oldVy * bLocal * deltaTime;
            particle.vy -= q * oldVx * bLocal * deltaTime;
        }
    } else {
        let cf = electrical.cohesion * 0.5;
        particle.vx = fma(totalForce.x + cohesionForce.x, forceFactor, particle.vx);
        particle.vy = fma(totalForce.y + cohesionForce.y, forceFactor, particle.vy);

        if (isBrain) {
            // Brain: no per-frame control learning. Signal is maintained for lifecycle metrics.
            // The genome buffer is the source of truth; particle fields are non-authoritative.
            particle.control = 0.0;
            // Keep signal as a smoothed proxy for lifecycle (death/clone thresholds)
            // We don't compute the full metric here (that's in brainStep'), so we keep
            // the previous signal value unchanged (it was set by brainStep' or lifecycle).
        } else if (isNeuron) {
            firing = abs(drive);
            particle.signal = mix(particle.signal, firing, 0.2);
            particle.control = 0.0;
        } else if (isSense) {
            // Sense neuron perception (UNCHANGED from before)
            let numTypesF = f32(options.numTypes);
            let area = options.simWidth * options.simHeight;
            let numMatterApprox = max(f32(options.numParticles) - f32(electrical.numUrges + electrical.numNeurons + electrical.numSenseNeurons), 1.0);
            let expectedCount = numMatterApprox * PI_CONST * sR * sR / area / numTypesF;

            var newSignal: f32 = 0.0;
            var newControl: f32 = 0.0;
            if (senseModeLocal == 0u) {
                let expectedInCone = expectedCount * (electrical.senseConeHalfAngle / PI_CONST);
                newSignal = clamp(seenCount / max(expectedInCone, 0.001), 0.0, 1.0);
                newControl = 0.0;
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

    particlesDestination[id.x] = particle;
}
