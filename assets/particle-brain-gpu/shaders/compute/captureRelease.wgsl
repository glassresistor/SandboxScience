// =============================================================================
// Capture Release — Organic Neuron Gain/Loss
//
// One workgroup per brain. Runs after brainStep so S and M are current.
// Gated on a frame counter (every ~600 frames ≈ 10s at 60fps).
//
// CAPTURE: each brain looks for the nearest FREE sense neuron and the nearest
//   FREE motor neuron within captureRadius. If found and below S/M caps,
//   sets their neuronOwners = brainId.
//
// RELEASE is handled CPU-side (a dying brain's neurons are set back to FREE in
// JS), so this shader only performs CAPTURE.
//
// NAGA / UNIFORM CONTROL FLOW (why this file looks the way it does):
//   * brainId comes from workgroup_id, NOT global_invocation_id — with one
//     workgroup per brain, gid.x would give every thread a DIFFERENT id and
//     make the early return below non-uniform (naga rejects the barriers that
//     follow it; on top of that, capture would never run for brains ≥ 64).
//   * The only early return is the uniform numBrains guard. The frame gate and
//     the at-cap check are FLAGS so all threads reach all barriers.
// =============================================================================

const MAX_S : u32 = 32u;
const MAX_M : u32 = 32u;
const FREE : u32 = 0xFFFFFFFFu;

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
};

struct CaptureOpts {
    numBrains : u32,
    numNeurons : u32,      // motor neurons total
    numSenseNeurons : u32, // sense neurons total
    captureRadius : f32,
    maxPerBrain : u32,     // cap on S and M per brain
    frameCount : u32,
    captureInterval : u32, // frames between capture attempts (e.g. 600)
    numTypes : u32,        // matter colors; special types start at numTypes
};

@group(0) @binding(0) var<storage, read> particles : array<Particle>;
@group(0) @binding(1) var<storage, read_write> neuronOwners : array<u32>; // [numSense + numMotor]

@group(1) @binding(0) var<uniform> opts : CaptureOpts;

// Workgroup memory
var<workgroup> wg_brainPos : vec2f;
var<workgroup> wg_countS : u32;
var<workgroup> wg_countM : u32;
var<workgroup> wg_bestSenseDist : f32;
var<workgroup> wg_bestSenseIdx : u32;
var<workgroup> wg_bestMotorDist : f32;
var<workgroup> wg_bestMotorIdx : u32;

@compute @workgroup_size(64)
fn main(@builtin(workgroup_id) wid : vec3<u32>,
        @builtin(local_invocation_id) lid : vec3<u32>) {
    let brainId = wid.x;
    // The ONLY early return in this shader. brainId is derived from workgroup_id,
    // which is uniform across the workgroup, so every barrier below is reached by
    // either all 64 threads or none — exactly what naga requires of a barrier.
    if (brainId >= opts.numBrains) { return; }
    let tid = lid.x;

    // Gated: only run capture every captureInterval frames. FLAG, not an early
    // return (the old return sat before the barriers below). The interval guard
    // keeps the modulo well-defined if a zero ever reaches the shader.
    let captureGateOpen = (opts.captureInterval > 0u) && (opts.frameCount % opts.captureInterval == 0u);

    let numSense = opts.numSenseNeurons;
    let numMotor = opts.numNeurons;
    let capR2 = opts.captureRadius * opts.captureRadius;

    // --- Initialize workgroup state (thread 0) ---
    if (tid == 0u) {
        wg_brainPos = vec2f(0.0, 0.0);
        wg_countS = 0u;
        wg_countM = 0u;
        wg_bestSenseDist = 1e10;
        wg_bestSenseIdx = FREE;
        wg_bestMotorDist = 1e10;
        wg_bestMotorIdx = FREE;
    }
    workgroupBarrier();

    // Count current ownership for this brain (to check caps)
    if (tid == 0u) {
        var cs : u32 = 0u;
        for (var i = 0u; i < numSense; i += 1u) {
            if (neuronOwners[i] == brainId) { cs += 1u; }
        }
        var cm : u32 = 0u;
        for (var i = 0u; i < numMotor; i += 1u) {
            if (neuronOwners[numSense + i] == brainId) { cm += 1u; }
        }
        wg_countS = cs;
        wg_countM = cm;
    }
    workgroupBarrier();

    // At-cap check as a FLAG (was a workgroup-memory-keyed early return before
    // the last barrier). doCapture is uniform per workgroup in practice, but
    // naga cannot see through workgroup memory — so it only gates thread-0
    // work below; every thread still reaches the next barrier.
    let atCap = (wg_countS >= opts.maxPerBrain) && (wg_countM >= opts.maxPerBrain);
    let doCapture = captureGateOpen && !atCap;

    // --- Find brain position + nearest free sense/motor neurons (thread 0) ---
    // Type layout: matter [0, numTypes), brains [numTypes, numTypes+numBrains),
    // motors [numTypes+numBrains, ...+numMotor), senses after that. Thread 0
    // does the O(N) scans; this only runs on capture frames, so it is cheap.
    if (doCapture && tid == 0u) {
        let totalP = arrayLength(&particles);
        let brainType = opts.numTypes + brainId;

        // Find the brain particle's position
        for (var i = 0u; i < totalP; i += 1u) {
            let rawT = particles[i].particleType;
            let intT = u32(rawT);
            if (rawT == f32(intT) && intT == brainType) {
                wg_brainPos = vec2f(particles[i].x, particles[i].y);
                break;
            }
        }

        // Find nearest free sense neuron within captureRadius
        if (wg_countS < opts.maxPerBrain) {
            for (var i = 0u; i < numSense; i += 1u) {
                if (neuronOwners[i] == FREE) {
                    // This sense neuron's particle: type = numTypes + numBrains + numMotor + i
                    let sType = opts.numTypes + opts.numBrains + numMotor + i;
                    for (var p = 0u; p < totalP; p += 1u) {
                        let pt = u32(particles[p].particleType);
                        if (particles[p].particleType == f32(pt) && pt == sType) {
                            let dx = particles[p].x - wg_brainPos.x;
                            let dy = particles[p].y - wg_brainPos.y;
                            let d2 = dx * dx + dy * dy;
                            if (d2 < capR2 && d2 < wg_bestSenseDist) {
                                wg_bestSenseDist = d2;
                                wg_bestSenseIdx = i;
                            }
                            break;
                        }
                    }
                }
            }
        }

        // Find nearest free motor neuron within captureRadius
        if (wg_countM < opts.maxPerBrain) {
            for (var i = 0u; i < numMotor; i += 1u) {
                if (neuronOwners[numSense + i] == FREE) {
                    let mType = opts.numTypes + opts.numBrains + i;
                    for (var p = 0u; p < totalP; p += 1u) {
                        let pt = u32(particles[p].particleType);
                        if (particles[p].particleType == f32(pt) && pt == mType) {
                            let dx = particles[p].x - wg_brainPos.x;
                            let dy = particles[p].y - wg_brainPos.y;
                            let d2 = dx * dx + dy * dy;
                            if (d2 < capR2 && d2 < wg_bestMotorDist) {
                                wg_bestMotorDist = d2;
                                wg_bestMotorIdx = i;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    workgroupBarrier();

    // Perform capture (thread 0 writes)
    if (doCapture && tid == 0u) {
        if (wg_bestSenseIdx != FREE && wg_countS < opts.maxPerBrain) {
            neuronOwners[wg_bestSenseIdx] = brainId;
        }
        if (wg_bestMotorIdx != FREE && wg_countM < opts.maxPerBrain) {
            neuronOwners[numSense + wg_bestMotorIdx] = brainId;
        }
    }
}
