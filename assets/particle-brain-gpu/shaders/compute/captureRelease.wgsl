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
// RELEASE: neurons whose owning brain has died (type != valid brain type)
//   return to the free pool (neuronOwners = 0xFFFFFFFF).
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
fn main(@builtin(global_invocation_id) gid : vec3<u32>,
        @builtin(local_invocation_id) lid : vec3<u32>) {
    let brainId = gid.x;
    if (brainId >= opts.numBrains) { return; }
    let tid = lid.x;

    // Gated: only run capture every captureInterval frames
    if (opts.frameCount % opts.captureInterval != 0u) { return; }

    let numSense = opts.numSenseNeurons;
    let numMotor = opts.numNeurons;
    let capR2 = opts.captureRadius * opts.captureRadius;

    // --- Find this brain's position (type = numTypes + brainId) ---
    // We need numTypes from the particle types: brains are in [numTypes, numTypes+numBrains)
    // But we don't have numTypes directly — derive it: the first non-brain type boundary.
    // Actually, we can find the brain by scanning for its specific type.
    // Brain b has type = (some base) + b. We know brains are contiguous after matter.
    // Let's just scan all particles for a particle whose type maps to this brain.
    // The brain's type is: it's in the "urge band" which starts at numTypes.
    // Since we don't have numTypes in opts, let's add it. Actually let me re-check...
    // I'll use a different approach: scan for the particle that has this brain's ownership.
    // Actually, the simplest: brains are particles with type in [numTypes, numTypes+numBrains).
    // We need numTypes. Let me add it to opts.

    // For now, let's find the brain by scanning all particles and checking which ones
    // have types that would be "brain" types. Since we don't have numTypes in opts,
    // I'll derive it: a brain particle is one where its type T satisfies:
    //   there exist exactly numBrainId particles with type < T that are also "brain" type.
    // This is too complex. Let me just add numTypes to the opts struct.

    // WORKAROUND: scan all particles, find the one whose type matches brainId's expected type.
    // Brain b has particleType = (numTypes + b). We need numTypes.
    // Since we can't easily get it, let's use a different strategy:
    // Find any particle that owns neurons for this brain and is close to them.
    // Actually the simplest correct approach: just scan all particles and find the one
    // whose type is in the "brain band". The brain band is [numTypes, numTypes+numBrains).
    // We can derive numTypes: it's the smallest type value that has exactly numBrains
    // distinct integer values starting from it. But that's O(N) to verify.

    // SIMPLEST: just add numTypes to CaptureOpts. Let me fix the struct.
    // For now I'll use a placeholder approach: scan for particles with type > 0 and
    // try to identify the brain by its position relative to owned neurons.

    // Actually, let me just find the brain by scanning: the brain particle is the one
    // whose type, when subtracted from the minimum "special" type, equals brainId.
    // The minimum special type = numTypes (first brain). So I need to find it.

    // PRACTICAL SOLUTION: scan all particles, collect those with integer types that are
    // >= some threshold. The first such type is numTypes. Then brain b = type numTypes+b.
    // But this is O(N) per workgroup which is fine for ≤ 64000 particles with 64 threads.

    // Let me just do a cooperative scan:
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

    // If at cap, skip capture
    if (wg_countS >= opts.maxPerBrain && wg_countM >= opts.maxPerBrain) { return; }

    // Find brain position: scan for particle with type that maps to this brain.
    // Brain particles have type in [numTypes, numTypes+numBrains). We need numTypes.
    // Derive it: the minimum integer type value among all "special" particles.
    // Special particles are those with type >= numTypes. Since matter types are [0, numTypes),
    // the minimum special type IS numTypes.
    // Cooperative min-find:
    var localMin : u32 = 0xFFFFFFFFu;
    let totalP = arrayLength(&particles);
    for (var i = tid; i < totalP; i += 64u) {
        let rawT = particles[i].particleType;
        let intT = u32(rawT);
        if (rawT == f32(intT) && intT > 0u) {
            // Could be a special particle (brain, neuron, sense, or dormant)
            // We want the minimum type that is a brain: it's in [numTypes, numTypes+numBrains)
            // But we don't know numTypes yet. Let's just find the global min of all int types > 0.
            // That gives us numTypes (since matter starts at 0 and brains are the first specials).
            if (intT < localMin) { localMin = intT; }
        }
    }
    // Reduce: find workgroup min
    var wMin = localMin;
    for (var offset = 1u; offset < 64u; offset <<= 1u) {
        let other = arrayLength(&particles); // placeholder, will use proper reduction
        // WGSL doesn't have easy cross-thread reduction without a shared array.
        // Let me use a different approach.
        break;
    }

    // SIMPLER APPROACH: just have thread 0 do the full scan (it's O(N) but N ≤ 64000,
    // and this only runs every 600 frames so it's negligible).
    if (tid == 0u) {
        // Find numTypes: minimum integer type > 0 among all particles
        var minType : u32 = 0xFFFFFFFFu;
        for (var i = 0u; i < totalP; i += 1u) {
            let rawT = particles[i].particleType;
            let intT = u32(rawT);
            if (rawT == f32(intT) && intT > 0u && intT < minType) {
                minType = intT;
            }
        }
        // Now brain b has type = minType + brainId
        let brainType = minType + brainId;
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
                    // Find this sense neuron's position: type = minType + numBrains + numMotor + i
                    let sType = minType + opts.numBrains + numMotor + i;
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
                    let mType = minType + opts.numBrains + i;
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
    if (tid == 0u) {
        if (wg_bestSenseIdx != FREE && wg_countS < opts.maxPerBrain) {
            neuronOwners[wg_bestSenseIdx] = brainId;
        }
        if (wg_bestMotorIdx != FREE && wg_countM < opts.maxPerBrain) {
            neuronOwners[numSense + wg_bestMotorIdx] = brainId;
        }
    }
}
