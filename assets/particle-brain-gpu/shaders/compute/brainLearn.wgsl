// =============================================================================
// Brain Learn — Hebbian weight update for the recurrent brain (EXPERIMENT)
//
// Runs AFTER brainStep in the same frame, and ONLY when learningRate > 0
// (dispatch is gated on the CPU side; this shader assumes it runs with a
// valid rate). Single workgroup, mirrors brainStep's architecture:
//
//   W_down[i, u] += learningRate * h_new[i] * error[u]      (i < H, u < nU)
//   then clamp every updated weight to [-clamp, +clamp]
//
// W_down lives inside the shared BrainWeights struct buffer (same layout as
// brainStep.wgsl — do NOT change field order there without changing it here).
// Only the W_down block is touched; biases/recurrent/group weights stay frozen.
// =============================================================================

const H : u32 = 8u;        // hidden units (MUST match brainStep.wgsl)
const MAX_URGES : u32 = 64u;
const WEIGHT_CLAMP : f32 = 2.0;

struct BrainWeights {
    W_down : array<f32, 512>,      // [H * MAX_URGES] (padded) — the ONLY field this pass writes
    b_down : array<f32, 8>,        // [H]
    W_recur : array<f32, 64>,      // [H * H]
    groupW : array<f32, 128>,      // [G * H]
    biases : array<f32, 128>,      // [MAX_NEURONS] (padded)
};

struct BrainLearnOpts {
    learningRate : f32,
    numUrges : u32,     // clamped to MAX_URGES below
    _pad0 : u32,
    _pad1 : u32,
};

@group(0) @binding(0) var<storage, read> brainState : array<f32, H>;   // h_new written by brainStep this frame
@group(0) @binding(1) var<storage, read> storedErrors : array<f32, MAX_URGES>; // errors persisted by brainStep
@group(0) @binding(2) var<storage, read_write> weights : BrainWeights;

@group(1) @binding(0) var<uniform> learnOpts : BrainLearnOpts;

@compute @workgroup_size(64)
fn main(@builtin(local_invocation_id) lid : vec3<u32>) {
    let tid = lid.x;
    let nU = min(learnOpts.numUrges, MAX_URGES);
    let lr = learnOpts.learningRate;

    // Each hidden unit i owns the row of W_down: H * nU updates total. With H=8 and
    // nU <= 64 that's at most 512 updates across 64 threads (up to 8 per thread).
    for (var idx = tid; idx < H * nU; idx += 64u) {
        let i = idx / nU;   // hidden unit row
        let u = idx % nU;   // urge column
        let wIdx = i * MAX_URGES + u;
        let updated = weights.W_down[wIdx] + lr * brainState[i] * storedErrors[u];
        weights.W_down[wIdx] = clamp(updated, -WEIGHT_CLAMP, WEIGHT_CLAMP);
    }
}
