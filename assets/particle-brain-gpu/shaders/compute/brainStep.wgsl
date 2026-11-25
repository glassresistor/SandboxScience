// =============================================================================
// Brain Step — Per-Brain Forward Pass + Delta-Rule Learning
//
// One workgroup per brain. Runs BEFORE the force pass each frame.
// For each brain:
//   1. Gather inputs: read signal of owned sense neurons (net inputs)
//   2. Forward: run the net (sense→motor) → write drives to neuronMods
//   3. Teaching signal: compute K need errors from genome + prev-frame metrics
//   4. Learning: delta-rule weight update (replaces old brainLearn pass)
//
// Genome layout per brain (flat f32 array, stride = GENOME_STRIDE):
//   [0 .. K*4)      needs: for need i → { targetColor(u32-as-f32), setpoint, scale, gain }
//   [K*4 .. K*4+W)  weights: the brain's private net (≤ W = 1024 floats)
//
// Weight layout within the W region (offset from genome base + K*4):
//   Single layer:  [W1: S*H][b1: H][Wout: H*M][bout: M]
//   Two layers:    [W1: S*H][b1: H][W2: H*H][b2: H][Wout: H*M][bout: M]
// =============================================================================

const K : u32 = 8u;            // needs per brain
const W_BUDGET : u32 = 1024u;  // weight budget per brain
const NEEDS_SIZE : u32 = K * 4u; // 32 floats for needs
const GENOME_STRIDE : u32 = NEEDS_SIZE + W_BUDGET; // 1056 floats/brain

const MAX_S : u32 = 32u;  // max sense neurons per brain (capture cap)
const MAX_M : u32 = 32u;  // max motor neurons per brain (capture cap)
const MAX_H : u32 = 32u;  // max hidden units

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

struct BrainStepOpts {
    numBrains : u32,
    numNeurons : u32,      // motor neurons total
    numSenseNeurons : u32, // sense neurons total
    numTypes : u32,
    learnRate : f32,
    simWidth : f32,
    simHeight : f32,
    urgeRadius : f32,      // for O(1) metric normalization
};

@group(0) @binding(0) var<storage, read> particles : array<Particle>;
@group(0) @binding(1) var<storage, read_write> genome : array<f32>;
@group(0) @binding(2) var<storage, read> neuronOwners : array<u32>; // [numSense + numMotor]
@group(0) @binding(3) var<storage, read_write> neuronMods : array<f32>; // per-motor-neuron drive output

@group(1) @binding(0) var<uniform> opts : BrainStepOpts;

// Workgroup memory (one workgroup per brain, 64 threads)
var<workgroup> wg_senseList : array<u32, MAX_S>;   // buffer indices of owned sense neurons
var<workgroup> wg_motorList : array<u32, MAX_M>;   // local indices of owned motor neurons
var<workgroup> wg_inputs : array<f32, MAX_S>;      // gathered sense signals (net inputs)
var<workgroup> wg_hidden1 : array<f32, MAX_H>;     // hidden layer 1 activations
var<workgroup> wg_hidden2 : array<f32, MAX_H>;     // hidden layer 2 activations
var<workgroup> wg_outputs : array<f32, MAX_M>;     // output drives
var<workgroup> wg_S : u32;                         // count of owned sense neurons
var<workgroup> wg_M : u32;                         // count of owned motor neurons
var<workgroup> wg_H : u32;                         // hidden width
var<workgroup> wg_depth : u32;                     // 1 or 2
var<workgroup> wg_errors : array<f32, K>;          // need errors (teaching signal)
var<workgroup> wg_metricCounts : array<u32, K>;    // per-need target-color matter counts

// O(1) metric: expected count of a color in a disk of radius r at baseline uniform distribution
fn expectedCount(r : f32) -> f32 {
    let numTypesF = f32(opts.numTypes);
    let area = opts.simWidth * opts.simHeight;
    let numMatterApprox = max(f32(arrayLength(&particles)) - f32(opts.numNeurons + opts.numSenseNeurons), 1.0);
    return numMatterApprox * 3.14159265 * r * r / area / numTypesF;
}

// NOTE: dispatched as ONE WORKGROUP PER BRAIN (dispatchWorkgroups(numBrains)).
// brainId MUST be uniform across the workgroup so that early-returns keep every
// subsequent workgroupBarrier() in uniform control flow. Using gid.x would give each
// thread a different brain id -> non-uniform branch -> naga rejects the barriers.
@compute @workgroup_size(64)
fn main(@builtin(workgroup_id) wid : vec3<u32>,
        @builtin(local_invocation_id) lid : vec3<u32>) {
    let brainId = wid.x;
    if (brainId >= opts.numBrains) { return; }
    let tid = lid.x;

    let genomeBase = brainId * GENOME_STRIDE;
    let weightBase = genomeBase + NEEDS_SIZE; // offset to the weight region

    let numSense = opts.numSenseNeurons;
    let numMotor = opts.numNeurons;

    // =====================================================================
    // PHASE 1: Build ownership lists (which sense/motor neurons belong to this brain)
    // =====================================================================
    // Sense neurons occupy neuronOwners[0 .. numSense)
    // Motor neurons occupy neuronOwners[numSense .. numSense+numMotor)
    // Thread 0 does the linear scan (arrays are small: ≤ 200 + 80 = 280 entries)
    if (tid == 0u) {
        var countS : u32 = 0u;
        for (var i = 0u; i < numSense && countS < MAX_S; i += 1u) {
            if (neuronOwners[i] == brainId) {
                wg_senseList[countS] = i; // store the local sense index
                countS += 1u;
            }
        }
        wg_S = countS;

        var countM : u32 = 0u;
        for (var i = 0u; i < numMotor && countM < MAX_M; i += 1u) {
            if (neuronOwners[numSense + i] == brainId) {
                wg_motorList[countM] = i; // store the local motor index
                countM += 1u;
            }
        }
        wg_M = countM;
    }
    workgroupBarrier();

    let S = wg_S;
    let M = wg_M;

    // If no neurons owned, nothing to compute — write zero drives and return
    if (S == 0u && M == 0u) {
        // Still need to zero the neuronMods for any motor that might reference this brain
        // (but if M==0 there are none, so just return)
        return;
    }

    // =====================================================================
    // PHASE 2: Compute net shape from S and M
    // =====================================================================
    var H : u32 = 0u;
    var depth : u32 = 0u;
    if (S + M <= 8u) {
        // Single hidden layer, square-ish
        H = max(4u, min(MAX_H, (S * M + 1u) / 2u)); // small: at least 4
        if (H < 4u) { H = 4u; }
        depth = 1u;
    } else {
        // Two hidden layers once S+M > 8
        let hCalc = sqrt(f32(max(S, 1u) * max(M, 1u)));
        H = min(MAX_H, max(4u, u32(hCalc + 0.5)));
        depth = 2u;
    }
    wg_H = H;
    wg_depth = depth;

    // =====================================================================
    // PHASE 3: Gather inputs (sense neuron signals)
    // =====================================================================
    // Find the buffer index of each sense neuron by its local index.
    // Sense neurons have type = numTypes + numUrges + numNeurons + localS
    let senseTypeBase = opts.numTypes + opts.numBrains + opts.numNeurons;
    if (tid < S) {
        let sLocal = wg_senseList[tid];
        // Scan particles to find this sense neuron (sorted by spatial hash, so we scan all)
        var found : f32 = 0.0;
        for (var p = 0u; p < arrayLength(&particles); p += 1u) {
            let pt = u32(particles[p].particleType);
            if (pt == senseTypeBase + sLocal && particles[p].particleType == f32(pt)) {
                found = particles[p].signal; // perception magnitude [0,1]
                break;
            }
        }
        wg_inputs[tid] = found;
    } else {
        wg_inputs[tid] = 0.0;
    }
    workgroupBarrier();

    // =====================================================================
    // PHASE 4: Forward pass (sense → motor)
    // =====================================================================
    let hW = f32(H);
    let sW = f32(S);
    let mW = f32(M);

    if (depth == 1u) {
        // Single layer: h[i] = tanh(W1[:,i]·x + b1[i])
        if (tid < H) {
            var val : f32 = genome[weightBase + S * H + tid]; // b1[tid]
            for (var j = 0u; j < S; j += 1u) {
                val += genome[weightBase + j * H + tid] * wg_inputs[j];
            }
            wg_hidden1[tid] = tanh(val);
        }
        workgroupBarrier();

        // Output: o[m] = clamp(tanh(Wout[:,m]·h + bout[m]), -1, 1)
        if (tid < M) {
            var val : f32 = genome[weightBase + S * H + H + H * M + tid]; // bout[tid]
            for (var i = 0u; i < H; i += 1u) {
                val += genome[weightBase + S * H + H + i * M + tid] * wg_hidden1[i];
            }
            let out = clamp(tanh(val), -1.0, 1.0);
            wg_outputs[tid] = out;
        }
    } else {
        // Two layers: h1 → h2 → output
        if (tid < H) {
            var val : f32 = genome[weightBase + S * H + tid]; // b1[tid]
            for (var j = 0u; j < S; j += 1u) {
                val += genome[weightBase + j * H + tid] * wg_inputs[j];
            }
            wg_hidden1[tid] = tanh(val);
        }
        workgroupBarrier();

        if (tid < H) {
            var val : f32 = genome[weightBase + S * H + H + H * H + tid]; // b2[tid]
            for (var j = 0u; j < H; j += 1u) {
                val += genome[weightBase + S * H + H + j * H + tid] * wg_hidden1[j];
            }
            wg_hidden2[tid] = tanh(val);
        }
        workgroupBarrier();

        if (tid < M) {
            var val : f32 = genome[weightBase + S * H + H + H * H + H + H * M + tid]; // bout[tid]
            for (var i = 0u; i < H; i += 1u) {
                val += genome[weightBase + S * H + H + H * H + H + i * M + tid] * wg_hidden2[i];
            }
            let out = clamp(tanh(val), -1.0, 1.0);
            wg_outputs[tid] = out;
        }
    }
    workgroupBarrier();

    // =====================================================================
    // PHASE 5: Write outputs to neuronMods (at the motor neuron's local index)
    // =====================================================================
    if (tid < M) {
        let mLocal = wg_motorList[tid];
        neuronMods[mLocal] = wg_outputs[tid];
    }

    // =====================================================================
    // PHASE 6: Compute teaching signal (K need errors)
    // =====================================================================
    // For each need i: err[i] = clamp((setpoint_i - metric_i) / scale_i, ±1) * gain_i
    // Metric = normalized density of the need's target color within urgeRadius.
    // We compute this by scanning matter particles for each target color.
    // (O(N*K) but K=8 and we only scan once per brain workgroup.)

    if (tid < K) {
        let needBase = genomeBase + tid * 4u;
        let targetColor = u32(genome[needBase]);       // stored as f32, cast back
        let setpoint = genome[needBase + 1u];
        let scale = max(genome[needBase + 2u], 0.1);
        let gain = genome[needBase + 3u];

        // Count target-color matter within urgeRadius of this brain's position
        // Find the brain particle (type = numTypes + brainId)
        var count : f32 = 0.0;
        let brainType = opts.numTypes + brainId;
        var brainPos = vec2f(0.0, 0.0);
        var foundBrain = false;
        let r2 = opts.urgeRadius * opts.urgeRadius;
        for (var p = 0u; p < arrayLength(&particles); p += 1u) {
            let pt = u32(particles[p].particleType);
            if (!foundBrain && pt == brainType && particles[p].particleType == f32(pt)) {
                brainPos = vec2f(particles[p].x, particles[p].y);
                foundBrain = true;
            }
            if (pt < opts.numTypes && pt == targetColor) {
                let dx = particles[p].x - brainPos.x;
                let dy = particles[p].y - brainPos.y;
                if (dx * dx + dy * dy < r2) {
                    count += 1.0;
                }
            }
        }

        // Normalize to O(1): expected count at baseline
        let expC = max(expectedCount(opts.urgeRadius), 0.001);
        let metric = count / expC;
        wg_metricCounts[tid] = u32(count); // store for potential debugging

        let err = clamp((setpoint - metric) / scale, -1.0, 1.0);
        wg_errors[tid] = err * gain;
    } else {
        wg_errors[tid % K] = wg_errors[tid % K]; // no-op for threads >= K (barrier sync)
    }
    workgroupBarrier();

    // =====================================================================
    // PHASE 7: Delta-rule learning (only if learnRate > 0)
    // =====================================================================
    let lr = opts.learnRate;
    if (lr <= 0.0 || S == 0u || M == 0u) { return; }

    // Scalar teaching signal: mean of K need errors
    var teach : f32 = 0.0;
    for (var k = 0u; k < K; k += 1u) { teach += wg_errors[k]; }
    teach /= f32(K);

    if (abs(teach) < 0.001) { return; } // no learning needed

    // Delta rule: reinforce active pathways scaled by teaching signal
    // Output layer: ΔWout[i,m] = lr * teach * h_last[i]
    // Input layer:  ΔW1[j,i]   = lr * teach * x[j] * mean(h)

    let wBase = weightBase;
    if (depth == 1u) {
        // Output weights: [H*M] at offset S*H + H
        let outOff = S * H + H;
        for (var idx = tid; idx < H * M; idx += 64u) {
            let i = idx / M;
            let m = idx % M;
            let wIdx = wBase + outOff + i * M + m;
            let updated = genome[wIdx] + lr * teach * wg_hidden1[i];
            genome[wIdx] = clamp(updated, -2.0, 2.0);
        }
        workgroupBarrier();

        // Input weights: [S*H] at offset 0
        for (var idx = tid; idx < S * H; idx += 64u) {
            let j = idx / H;
            let i = idx % H;
            let wIdx = wBase + j * H + i;
            let updated = genome[wIdx] + lr * teach * wg_inputs[j];
            genome[wIdx] = clamp(updated, -2.0, 2.0);
        }
    } else {
        // Two-layer: update all three weight matrices
        // Wout: [H*M] at offset S*H + H + H*H + H
        let outOff = S * H + H + H * H + H;
        for (var idx = tid; idx < H * M; idx += 64u) {
            let i = idx / M;
            let m = idx % M;
            let wIdx = wBase + outOff + i * M + m;
            let updated = genome[wIdx] + lr * teach * wg_hidden2[i];
            genome[wIdx] = clamp(updated, -2.0, 2.0);
        }
        workgroupBarrier();

        // W2: [H*H] at offset S*H + H
        let w2Off = S * H + H;
        for (var idx = tid; idx < H * H; idx += 64u) {
            let j = idx / H;
            let i = idx % H;
            let wIdx = wBase + w2Off + j * H + i;
            let updated = genome[wIdx] + lr * teach * wg_hidden1[j];
            genome[wIdx] = clamp(updated, -2.0, 2.0);
        }
        workgroupBarrier();

        // W1: [S*H] at offset 0
        for (var idx = tid; idx < S * H; idx += 64u) {
            let j = idx / H;
            let i = idx % H;
            let wIdx = wBase + j * H + i;
            let updated = genome[wIdx] + lr * teach * wg_inputs[j];
            genome[wIdx] = clamp(updated, -2.0, 2.0);
        }
    }
}
