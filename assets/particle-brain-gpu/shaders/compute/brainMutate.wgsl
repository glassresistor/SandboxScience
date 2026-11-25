// =============================================================================
// Brain Mutate — Slow Drift of Genome NEEDS (setpoint/scale/gain)
//
// One workgroup per brain. Runs AFTER the force pass each frame.
// Applies a tiny random perturbation to each brain's K needs in the genome buffer.
// Weights are NOT mutated here (decision D3: weights move via learning & heredity only).
//
// Mutation model (per need i of brain b):
//   changeability = 0.02 + 0.98 * hash(b*40 + i)
//   setpoint += gauss() * 0.005 * changeability
//   scale    *= 1 + gauss() * 0.003 * changeability
//   gain     += gauss() * 0.003 * changeability
// All clamped to valid ranges.
// =============================================================================

const K : u32 = 8u;
const NEEDS_SIZE : u32 = K * 4u; // 32 floats per brain for needs

struct BrainMutateOpts {
    numBrains : u32,
    frameCount : u32,
};

@group(0) @binding(0) var<storage, read_write> genome : array<f32>;
@group(1) @binding(0) var<uniform> opts : BrainMutateOpts;

fn hash(n: u32) -> f32 {
    var x = n * 747796405u + 2891336453u;
    x = (x ^ (x >> 16u)) * 2246822507u;
    x = (x ^ (x >> 13u)) * 3266489909u;
    x = x ^ (x >> 16u);
    return f32(x) / 4294967295.0;
}

fn gauss3(salt: u32, seed: u32) -> f32 {
    let a = hash(salt * 31u + seed);
    let b = hash(salt * 61u + seed + 1u);
    let c = hash(salt * 97u + seed + 2u);
    return (a + b + c - 1.5) * 1.1547;
}

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>,
        @builtin(local_invocation_id) lid : vec3<u32>) {
    let brainId = gid.x;
    if (brainId >= opts.numBrains) { return; }
    let tid = lid.x;

    // Each thread handles one need (K=8, so only threads 0..7 do work)
    if (tid >= K) { return; }

    let genomeBase = brainId * NEEDS_SIZE; // needs start at the beginning of each slot
    let needBase = genomeBase + tid * 4u;

    // Per-need changeability: deterministic from (brainId, needIndex)
    let changeability = 0.02 + 0.98 * hash(brainId * 40u + tid);
    let seed = opts.frameCount;

    // Apply small perturbations to setpoint, scale, gain (NOT targetColor)
    var setpoint = genome[needBase + 1u];
    var scale = genome[needBase + 2u];
    var gain = genome[needBase + 3u];

    setpoint += gauss3(brainId * 40u + tid, seed) * 0.005 * changeability;
    scale *= 1.0 + gauss3(brainId * 40u + tid + 100u, seed) * 0.003 * changeability;
    gain += gauss3(brainId * 40u + tid + 200u, seed) * 0.003 * changeability;

    // Clamp to valid ranges
    genome[needBase + 1u] = clamp(setpoint, 0.1, 3.0);
    genome[needBase + 2u] = clamp(scale, 0.05, 2.0);
    genome[needBase + 3u] = clamp(gain, 0.0, 3.0);
}
