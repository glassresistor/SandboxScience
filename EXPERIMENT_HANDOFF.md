# Handoff Prompt — Particle-Brain Experiment Harness

You are implementing an **experiment/sweep harness** for the `particle-brain` GPU simulation in this Nuxt 3 + WebGPU app. The goal: make the theory's central variables *tunable* and *measurable* so we can run parameter sweeps (control-gap inverted-U, body autonomy, environmental drift, neuron damage, brain learning) **without changing core physics**. Keep every existing test green; add tests for the new pure logic.

> This file is self-contained. Everything below was verified against the current tree. Line numbers are approximate — re-grep to locate anchors.

---

## 0. Environment (each terminal is fresh)

```bash
export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh" && nvm use 20   # Node v20 required
cd SandboxScience
npx vitest run        # baseline: 76 tests pass across 6 files
npm run typecheck     # baseline: clean (vue-tsc --noEmit)
```

**Baseline is green.** After every phase, re-run both. If red, stop and fix before continuing.

---

## 1. HARD CONSTRAINTS (why tests exist — do not break these)

Read `tests/wgslStrideConsistency.test.ts` and `tests/wgslShaderCompilation.test.ts` first. They enforce:

1. **The WGSL `struct Particle` must stay EXACTLY 11 f32 fields** in every shader, in the order `x,y,vx,vy,particleType,control,signal,goalB,driveTarget,driveScale,driveGain`. The JS constant `PARTICLE_STRIDE` (`constants/particleStride.ts`) must equal 11. **If you are tempted to add a per-particle field (e.g. a "health" or "damage" flag), STOP.** Put that data in a SEPARATE buffer instead. Adding a Particle field breaks the stride test AND the JS↔WGSL cross-check.
2. **Any `options.<field>` referenced in a shader must be declared in that same shader's local `struct SimOptions`.** (Catches "black screen" bugs.)
3. **No GLSL `mod()`** in WGSL — use `x - y * floor(x / y)`.
4. **Lorentz/magnetic force block** in `particleAdvance.wgsl` and `particleComputeForces.wgsl` must keep the `let oldVx = …; let oldVy = …` save-before-update pattern. Don't touch that block.
5. **ElectricalOptions byte layout**: the WGSL `struct ElectricalOptions` field ORDER must match the CPU `DataView` offsets in `updateElectricalOptionsBuffer()`. Currently 68 bytes, last field `senseMode: u32` at offset 64. **Append new electrical fields at the END** (offset 68+) so you never shift existing offsets.

---

## 2. Key file map (verified)

| Concern | File | Anchor |
|---|---|---|
| Pinia store (all tunables) | `stores/particleBrainGPUStore.ts` | setup-store; add `ref<>` then add to the big `return { … }` at bottom |
| Electrical uniform buffer build | `components/particle-brain/ParticleBrainGpu.vue` | `updateElectricalOptionsBuffer()` — `new ArrayBuffer(68)`, DataView offsets 0..64 |
| Force pass (brain modulation line) | `assets/particle-brain-gpu/shaders/compute/particleComputeForces.wgsl` | `if (isNeuron && eOn) { drive += neuronMods[mIdx] * 1.5; }` and `struct ElectricalOptions { … }` |
| Brain recurrent step | `assets/.../compute/brainStep.wgsl` | writes `wg_errors` (workgroup only), `neuronMods`, `brainState` |
| Brain drive mutation | `assets/.../compute/brainMutate.wgsl` | per-urge driveTarget/Scale/Gain drift |
| Render loop / step() | `ParticleBrainGpu.vue` | `const frame = async () => …` calls `step()`; `readBufferFromGPU(buffer,size)` helper exists |
| Interaction matrix upload | `ParticleBrainGpu.vue` | local `rulesMatrix:number[][]`; `updateInteractionMatrixBuffer()` encodes to Uint8Array → `interactionMatrixBuffer`; `updateAllInteractionBuffers()` wraps it |
| Electrical param watchers | `ParticleBrainGpu.vue` | `const watchElectrical = (effect) => watch(effect, () => updateElectricalOptionsBuffer())` then a list of `watchElectrical(() => particleLife.X)` calls |
| UI sliders | `ParticleBrainGpu.vue` template | `<RangeInput v-model="particleLife.X" label=… :min :max :step />` inside the "Quantum / Electrical" `<Collapse>` |
| Particle stride constants | `constants/particleStride.ts` | `P.x..P.driveGain` offsets, `particleBase(i)` |
| Pure helpers (add yours here) | `helpers/utils/*.ts` | e.g. `rulesGenerator.ts` style: plain exported functions, no Vue imports |

**Particle buffer layout (stride 11):** `[0]x [1]y [2]vx [3]vy [4]particleType [5]control [6]signal [7]goalB [8]driveTarget [9]driveScale [10]driveGain`. Matter = `intType < numTypes`; urges = `[numTypes, +numUrges)`; motor neurons = `[+numUrges, +numNeurons)`; sense neurons after that. Use `import { PARTICLE_STRIDE, P } from '~/constants/particleStride'` in new helpers.

---

## 3. PHASE 1 — Minimum Viable Experiment ✅ DONE (verified: 90/90 tests, typecheck clean)

Goal: invert-U curve of **novelty vs control gap** by sweeping `urgeForce`. = Changes 1+2+3 from the design doc.

### 3a. Make `brainGain` a store param (design Change 1, ~3 lines + buffer)
- `stores/particleBrainGPUStore.ts`: add `const brainGain = ref<number>(1.5) // Brain network output gain (0 = no global modulation, 3+ = over-control)` near the other electrical refs; add `brainGain,` to the returned object.
- `particleComputeForces.wgsl`: append `brainGain: f32,` as the LAST field of `struct ElectricalOptions`; change the brain-modulation line to `drive += neuronMods[mIdx] * electrical.brainGain;`
- `updateElectricalOptionsBuffer()`: change `new ArrayBuffer(68)` → `new ArrayBuffer(72)` and add `v.setFloat32(68, particleLife.brainGain, true)`. (Offset 68 = after senseMode@64. Keep the comment noting it must match WGSL field order.)
- Add watcher: `watchElectrical(() => particleLife.brainGain)`.
- UI: add a `<RangeInput v-model="particleLife.brainGain" label="Brain Gain" :min="0" :max="3" :step="0.01" mt-2 tooltip="Global brain network output gain added to neuron drive. 0 = no global modulation, high = over-control." />` in the Quantum/Electrical collapse.

### 3b. Measurement helpers (design Changes 2 & 3) — pure + unit-tested
Create `helpers/utils/experimentMetrics.ts`. Export **pure** functions (no Vue/WebGPU imports) so they're testable:

```ts
import { PARTICLE_STRIDE, P } from '~/constants/particleStride'

export interface MatterEntropyOpts { numTypes: number, simWidth: number, simHeight: number, gridResolution?: number }
// Normalized Shannon entropy [0,1] of the matter density field on a 2D grid.
// Iterate particles; for intType < numTypes bin (x,y) into gridResolution² cells
// (aggregate all colors, or per-color then sum — pick one and document it).
export function measureMatterEntropy(particles: Float32Array, opts: MatterEntropyOpts): number { … }

// Novelty rate = how fast the configuration changes. |Δentropy| between two samples.
export function noveltyRate(prevEntropy: number, curEntropy: number): number {
    return Math.abs(curEntropy - prevEntropy)
}

export interface ControlGapOpts { numTypes: number, numUrges: number, numNeurons: number, urgeRadius: number }
// For each active motor neuron (|signal|>eps), intended dir = neuron→centroid of its target-color
// matter within urgeRadius; actual dir = mean velocity of that matter. Return mean of
// (1 - |cosine(intended,actual)|) over active neurons → 0=perfectly aligned, 1=orthogonal/opposite.
// Use a coarse spatial grid to find neighbors cheaply (O(N) build + O(1) query); cap work.
export function measureControlGap(particles: Float32Array, opts: ControlGapOpts): number { … }
```

Implementation notes:
- Matter particles only have meaningful x/y/vx/vy/type; `control`/`signal` are 0 for matter.
- A neuron's target color = `(localNeuronIndex) % numTypes`. Its firing activity is `signal` (offset P.signal).
- Keep it robust to empty regions (return 0 when no active neurons / no matter).

Add `tests/experimentMetrics.test.ts` covering at minimum:
- `measureMatterEntropy`: uniform spread → higher entropy than a single tight cluster; always in [0,1]; all-in-one-cell → near 0.
- `noveltyRate`: symmetric, 0 when equal, |Δ| otherwise.
- `measureControlGap`: perfectly aligned motion → ~0; perpendicular → ~1; no active neurons → 0.

### 3c. Wire telemetry into the render loop (CPU-side, throttled)
In `ParticleBrainGpu.vue`, add an **opt-in** telemetry block (off by default, zero-cost when off — mirror the existing "Urge Inspector / Live readback" pattern at ~line 4584):
- Store refs: `isExperimentTelemetry = ref(false)`, plus in-memory `experimentLog = ref<…[]>([])` and a counter.
- Every N frames (e.g. 50) when enabled AND not mid-resize/erase: `const buf = await readBufferFromGPU(particleBuffer, NUM_PARTICLES * PARTICLE_BYTES)`; parse into `Float32Array`; call the three helpers; push `{frame, urgeForce, brainGain, frictionFactor, magneticStrength, entropy, noveltyRate, controlGap}` to a ring buffer (cap length). Keep a `prevEntropy` for novelty.
- Guard with the same `isUpdatingParticles || isEraseCompleting` checks the urge readback uses. Re-check guards after the `await`.
- Expose `experimentLog`, `isExperimentTelemetry`, and a `clearExperimentLog()` in the component `return { … }` so it can be inspected/exported (e.g. as JSON) for plotting.

### 3d. urgeForce sweep is pure parameter — no code needed
`urgeForce` already exists (`particleLife.urgeForce`, default 0.2). The sweep = set telemetry on, vary `urgeForce` 0.0→1.5 in 0.1 steps, log per run. Document the protocol (fix numParticles=64000, numColors=7, frictionFactor=0.3, magneticStrength=0) in a short comment near the telemetry block.

**Verify Phase 1:** `npx vitest run` (new metrics tests pass), `npm run typecheck`, and confirm the app still builds (`npm run build`) if time permits.

---

## 4. PHASE 2 — Body Autonomy sweep (design Change: param only, NO code) ✅ DONE (sliders confirmed at ParticleBrainGpu.vue ~line 155/160; both params already captured per telemetry sample; grid protocol documented in the component's telemetry comment block)

`frictionFactor` and `magneticStrength` are already store params with UI sliders and watchers. The 6×4 grid (friction ∈ {0.05,0.1,0.2,0.3,0.5,0.7}, magnetic ∈ {0,0.3,0.8,1.5}) is run by setting those values + telemetry on. **No code changes.** Just confirm the two sliders exist and document the protocol. (Optional: add them to the `experimentLog` entry — they're already captured in 3c.)

---

## 5. PHASE 3 — Environmental drift (design Change 5) ✅ DONE (verified: 94/94 tests, typecheck clean)

- Store refs: `isDriftEnabled = ref(false)`, `driftStrength = ref(0.05)`, `driftInterval = ref(200)` (frames). Add to return + UI (a toggle + two range inputs).
- Pure helper in `experimentMetrics.ts`:
  ```ts
  // Add small centered Gaussian noise to the MATTER×MATTER submatrix only
  // (rows/cols 0..numTypes-1), clamped to [-1,1]. Leave urge/neuron rows untouched.
  export function driftInteractionMatrix(matrix: number[][], numTypes: number, strength: number): void { … }
  ```
  Use the same 3-uniform-sum Gaussian as `brainMutate.wgsl`'s `gauss3` for consistency (or a Box-Muller; document it).
- Wire in the render loop: keep a frame counter; when `isDriftEnabled && frame % driftInterval === 0`, call `driftInteractionMatrix(rulesMatrix, NUM_TYPES, driftStrength)` then `updateAllInteractionBuffers()` to re-upload. (Local `rulesMatrix` is the source of truth for the GPU buffer.)
- Add a unit test: drift with strength=0 is a no-op; with strength>0 values stay in [-1,1] and only matter×matter cells change.

---

## 6. PHASE 4 — Neuron damage events (design Change 4) ✅ DONE (verified: 102/102 tests, typecheck clean)

**Pitfall:** the neuron branch unconditionally sets `particle.control = 0.0` every frame, so you CANNOT use `control` as a persistent "damaged" sentinel — it gets overwritten. Use a **separate per-neuron health buffer** instead.

- New GPU buffer `neuronHealthBuffer` (`array<f32, MAX_NEURONS>` = 128 floats), initialized to 1.0 (healthy). CPU writes 0.0 for damaged neurons, 1.0 otherwise.
- `particleComputeForces.wgsl`: add a read-only-storage binding for it (next free binding in group 0 — currently bindings 0..4 are used; add binding 5) and a field is not needed in any struct. In the neuron actuation branch, gate on health: if `neuronHealth[mIdx] < 0.5` skip adding drive to matter (and optionally fade `signal`). Keep everything else identical.
- CPU: maintain `damagedNeurons: Map<localIdx, framesRemaining>`; each frame decrement & clear expired; with probability `neuronDamageProbability` pick a random live neuron and set it damaged for `neuronDamageDuration` frames; write the health buffer accordingly (only when something changed).
- Store refs: `isDamageEnabled = ref(false)`, `neuronDamageProbability = ref(0.01)`, `neuronDamageDuration = ref(60)`.
- Measurement: in telemetry, record a timestamp on each damage event so we can compare entropy before/after (reorganization ↑ vs degradation ↓).
- Tests: a pure helper `scheduleNeuronDamage(existing, probability, duration, numNeurons, rng)` returning the updated map — unit-test determinism with a seeded RNG and that durations decrement.

---

## 7. PHASE 5 — Brain weight learning (design Change 6) ✅ DONE (verified: 102/102 tests, typecheck clean)

The most involved; do last. Tests "a learning brain sustains novelty longer than a frozen one."

1. `brainStep.wgsl`: add a storage binding `storedErrors : array<f32, MAX_URGES>` and, at the end of `main`, write `wg_errors[u]` into it for `u < nU` (so the learn pass can read the same errors).
2. New shader `assets/.../compute/brainLearn.wgsl`: reads `brainState` (h_new), `storedErrors`, and `weights` (read_write); applies Hebbian `W_down[i*MAX_URGES + u] += lr * h_new[i] * storedErrors[u]` for `i<H, u<nU`, then clamps each updated weight to [-2, 2]. Dispatch only when `learningRate > 0`. Single workgroup like the others.
3. Vue: create the pipeline + bind groups (mirror `brainStepPipeline`/`brainBindGroup`), add a `brainLearningRate` uniform buffer, run the learn pass in `step()` **after** brainStep and only when `particleLife.brainLearningRate > 0 && brainValid`. Add `brainStateBuffer`/`neuronModsBuffer`/`brainWeightsBuffer` reuse as needed.
4. Store ref `brainLearningRate = ref(0.0)` (0 = frozen) + UI slider (0..0.01).
5. Test: a pure CPU mirror of the Hebbian update + clamp in `experimentMetrics.ts` (`hebbianUpdateWeight(w, h, e, lr, clamp=2)`) — unit-test that lr=0 is a no-op and clamping bounds the result.

---

## 8. Verification checklist (run after EACH phase)

```bash
export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh" && nvm use 20
cd SandboxScience
npx vitest run      # all old tests still pass + your new ones
npm run typecheck   # clean
# optional but recommended once per phase:
npm run lint        # eslint (antfu config) — fix any new complaints
```

Definition of done for the whole task:
- [x] `brainGain` tunable end-to-end (store → buffer → shader → UI), default 1.5, existing behavior unchanged at 1.5.
- [x] `measureMatterEntropy`, `noveltyRate`, `measureControlGap` exist as pure functions with passing unit tests.
- [x] Opt-in telemetry logs `{frame, params…, entropy, noveltyRate, controlGap}` and is zero-cost when off.
- [x] Environmental drift (pure helper + loop hook) with tests; default off.
- [x] Neuron damage via separate health buffer (NOT a Particle field) — stride test still green.
- [x] Brain learning pass (storedErrors + brainLearn.wgsl) gated on `brainLearningRate>0`; frozen by default.
- [x] No `struct Particle` field count changed; no undeclared `options.*`; no `mod()`; Lorentz block untouched.
- [x] All 76 baseline tests + new tests pass (102 total); typecheck clean.

## 9. Priority if you must stop early
1 → Phase 1 (MVE: brainGain + entropy/novelty + control gap + urgeForce sweep). 2 → Phase 3 (drift). 3 → Phase 4 (damage). 4 → Phase 5 (learning). Phase 2 needs no code.
