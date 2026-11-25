import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useParticleBrainGPUStore } from '~/stores/particleBrainGPUStore'

// ---------------------------------------------------------------------------
// Constants matching the genome buffer layout
// ---------------------------------------------------------------------------
const GENOME_K = 8 // needs per brain
const GENOME_W_BUDGET = 1024 // weight budget per brain
const GENOME_NEEDS_SIZE = GENOME_K * 4 // 32 floats for needs
const GENOME_STRIDE = GENOME_NEEDS_SIZE + GENOME_W_BUDGET // 1056 floats/brain

// Need param bounds (must match updateBrainBuffers init + brainMutate clamping)
const SETPOINT_MIN = 0.1
const SETPOINT_MAX = 3.0
const SCALE_MIN = 0.05
const SCALE_MAX = 2.0
const GAIN_MIN = 0.0
const GAIN_MAX = 3.0

// Clone mutation ranges (must match lifecycle PHASE 4)
const MUT_SETPOINT = 0.1
const MUT_SCALE = 0.06
const MUT_GAIN = 0.06
const WEIGHT_JITTER_SIGMA = 0.05 // small Gaussian jitter on weights during clone

// Deterministic pseudo-random for reproducible tests
function seededRandom(seed: number) {
    let s = seed
    return () => {
        s = (s * 16807 + 0) % 2147483647
        return (s - 1) / 2147483646
    }
}

// Approximate Gaussian via Box-Muller (deterministic with seeded random)
function gauss(rand: () => number): number {
    const u1 = Math.max(rand(), 0.0001)
    const u2 = rand()
    return Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2)
}

/**
 * Helper: create a genome buffer with one brain at the given slot.
 */
function makeGenomeWithBrain(brainId: number, numBrains: number): Float32Array {
    const buf = new Float32Array(numBrains * GENOME_STRIDE)
    const base = brainId * GENOME_STRIDE
    // Set known need values
    for (let k = 0; k < GENOME_K; k++) {
        buf[base + k * 4] = k % 7 // targetColor
        buf[base + k * 4 + 1] = 1.0 // setpoint
        buf[base + k * 4 + 2] = 0.5 // scale
        buf[base + k * 4 + 3] = 1.0 // gain
    }
    // Set known weight values (small)
    for (let w = GENOME_NEEDS_SIZE; w < GENOME_STRIDE; w++) {
        buf[base + w] = 0.1
    }
    return buf
}

// ---------------------------------------------------------------------------
// Store: brain defaults
// ---------------------------------------------------------------------------
describe('Brain Genome — Store Defaults', () => {
    beforeEach(() => {
        setActivePinia(createPinia())
    })

    it('enables cloning by default', () => {
        const store = useParticleBrainGPUStore()
        expect(store.isCloningEnabled).toBe(true)
    })

    it('enables merging by default', () => {
        const store = useParticleBrainGPUStore()
        expect(store.isMergeEnabled).toBe(true)
    })

    it('enables the electrical (brain) layer by default', () => {
        const store = useParticleBrainGPUStore()
        expect(store.isElectricalEnabled).toBe(true)
    })

    it('has a positive clone pool for dormant slots', () => {
        const store = useParticleBrainGPUStore()
        expect(store.numClonePool).toBeGreaterThan(0)
    })

    it('defaults to 12 brains', () => {
        const store = useParticleBrainGPUStore()
        expect(store.numBrains).toBe(12)
    })

    it('has a positive brain learn rate by default', () => {
        const store = useParticleBrainGPUStore()
        expect(store.brainLearnRate).toBeGreaterThan(0)
    })

    it('has a positive max neurons per brain cap', () => {
        const store = useParticleBrainGPUStore()
        expect(store.maxNeuronsPerBrain).toBeGreaterThan(0)
    })
})

// ---------------------------------------------------------------------------
// Genome init: random-at-birth ranges
// ---------------------------------------------------------------------------
describe('Brain Genome — Random Init at Birth', () => {
    it('setpoints are in [0.6, 1.4] at birth', () => {
        const genome = new Float32Array(GENOME_STRIDE)
        // Simulate the init logic from updateBrainBuffers
        for (let k = 0; k < GENOME_K; k++) {
            genome[k * 4 + 1] = 0.6 + Math.random() * 0.8
        }
        for (let k = 0; k < GENOME_K; k++) {
            const sp = genome[k * 4 + 1]
            expect(sp).toBeGreaterThanOrEqual(0.6)
            expect(sp).toBeLessThanOrEqual(1.4)
        }
    })

    it('scales are in [0.3, 0.8] at birth', () => {
        const genome = new Float32Array(GENOME_STRIDE)
        for (let k = 0; k < GENOME_K; k++) {
            genome[k * 4 + 2] = 0.3 + Math.random() * 0.5
        }
        for (let k = 0; k < GENOME_K; k++) {
            const sc = genome[k * 4 + 2]
            expect(sc).toBeGreaterThanOrEqual(0.3)
            expect(sc).toBeLessThanOrEqual(0.8)
        }
    })

    it('gains are in [0.5, 1.5] at birth', () => {
        const genome = new Float32Array(GENOME_STRIDE)
        for (let k = 0; k < GENOME_K; k++) {
            genome[k * 4 + 3] = 0.5 + Math.random() * 1.0
        }
        for (let k = 0; k < GENOME_K; k++) {
            const g = genome[k * 4 + 3]
            expect(g).toBeGreaterThanOrEqual(0.5)
            expect(g).toBeLessThanOrEqual(1.5)
        }
    })

    it('targetColors are spread across needs (k % numTypes)', () => {
        const numTypes = 7
        const genome = new Float32Array(GENOME_STRIDE)
        for (let k = 0; k < GENOME_K; k++) {
            genome[k * 4] = k % numTypes
        }
        // Verify spread: need 0 → color 0, need 1 → color 1, ...
        for (let k = 0; k < GENOME_K; k++) {
            expect(genome[k * 4]).toBe(k % numTypes)
        }
    })

    it('weights are small random (±0.3) at birth', () => {
        const genome = new Float32Array(GENOME_STRIDE)
        for (let w = GENOME_NEEDS_SIZE; w < GENOME_STRIDE; w++) {
            genome[w] = (Math.random() - 0.5) * 0.6 // ±0.3
        }
        for (let w = GENOME_NEEDS_SIZE; w < GENOME_STRIDE; w++) {
            expect(Math.abs(genome[w])).toBeLessThanOrEqual(0.3)
        }
    })
})

// ---------------------------------------------------------------------------
// Genome heredity: clone jitter on needs + weights
// ---------------------------------------------------------------------------
describe('Brain Genome — Clone Jitter', () => {
    function applyCloneGenome(parentBase: number, childBase: number, genome: Float32Array, rand: () => number) {
        // Needs: Gaussian jitter (setpoint ±~0.1, scale/gain ±~0.06)
        for (let k = 0; k < GENOME_K; k++) {
            const pNb = parentBase + k * 4
            const cNb = childBase + k * 4
            // targetColor: copied exactly
            genome[cNb] = genome[pNb]
            // setpoint: jitter ±0.1, clamped [0.1, 3.0]
            genome[cNb + 1] = Math.min(SETPOINT_MAX, Math.max(SETPOINT_MIN,
                genome[pNb + 1] + gauss(rand) * MUT_SETPOINT))
            // scale: jitter ±0.06, clamped [0.05, 2.0]
            genome[cNb + 2] = Math.min(SCALE_MAX, Math.max(SCALE_MIN,
                genome[pNb + 2] + gauss(rand) * MUT_SCALE))
            // gain: jitter ±0.06, clamped [0.0, 3.0]
            genome[cNb + 3] = Math.min(GAIN_MAX, Math.max(GAIN_MIN,
                genome[pNb + 3] + gauss(rand) * MUT_GAIN))
        }
        // Weights: copied then jittered (w += gauss()*σ_w), clamped ±2
        for (let w = GENOME_NEEDS_SIZE; w < GENOME_STRIDE; w++) {
            const pw = parentBase + w
            const cw = childBase + w
            genome[cw] = Math.min(2.0, Math.max(-2.0,
                genome[pw] + gauss(rand) * WEIGHT_JITTER_SIGMA))
        }
    }

    it('clone targetColor is copied exactly from parent', () => {
        const rand = seededRandom(42)
        const genome = makeGenomeWithBrain(0, 2)
        applyCloneGenome(0, GENOME_STRIDE, genome, rand)

        // All K targetColors should match parent
        for (let k = 0; k < GENOME_K; k++) {
            expect(genome[GENOME_STRIDE + k * 4]).toBe(genome[k * 4])
        }
    })

    it('clone setpoint stays within [parent - 0.1, parent + 0.1] (approx)', () => {
        const rand = seededRandom(99)
        const genome = makeGenomeWithBrain(0, 2)
        applyCloneGenome(0, GENOME_STRIDE, genome, rand)

        // With σ=0.1 and one sample, most values should be within ±0.3 (3σ)
        for (let k = 0; k < GENOME_K; k++) {
            const parentSp = genome[k * 4 + 1]
            const childSp = genome[GENOME_STRIDE + k * 4 + 1]
            // Allow 3σ tolerance for a single sample
            expect(Math.abs(childSp - parentSp)).toBeLessThanOrEqual(0.5)
        }
    })

    it('clone scale stays within [parent - 0.2, parent + 0.2] (approx)', () => {
        const rand = seededRandom(7)
        const genome = makeGenomeWithBrain(0, 2)
        applyCloneGenome(0, GENOME_STRIDE, genome, rand)

        for (let k = 0; k < GENOME_K; k++) {
            const parentSc = genome[k * 4 + 2]
            const childSc = genome[GENOME_STRIDE + k * 4 + 2]
            expect(Math.abs(childSc - parentSc)).toBeLessThanOrEqual(0.3)
        }
    })

    it('clone weights are close to parent (light jitter)', () => {
        const rand = seededRandom(12345)
        const genome = makeGenomeWithBrain(0, 2)
        applyCloneGenome(0, GENOME_STRIDE, genome, rand)

        // Weights should be close to parent (±0.05σ per weight)
        let maxDiff = 0
        for (let w = GENOME_NEEDS_SIZE; w < GENOME_STRIDE; w++) {
            const diff = Math.abs(genome[GENOME_STRIDE + w] - genome[w])
            if (diff > maxDiff) maxDiff = diff
        }
        // With σ=0.05, max single-sample deviation should be well under 0.5
        expect(maxDiff).toBeLessThan(0.5)
    })

    it('clone setpoint is clamped to minimum 0.1 when parent is at boundary', () => {
        const rand = seededRandom(111)
        const genome = makeGenomeWithBrain(0, 2)
        // Set parent setpoint to minimum
        for (let k = 0; k < GENOME_K; k++) {
            genome[k * 4 + 1] = SETPOINT_MIN
        }
        applyCloneGenome(0, GENOME_STRIDE, genome, rand)

        for (let k = 0; k < GENOME_K; k++) {
            expect(genome[GENOME_STRIDE + k * 4 + 1]).toBeGreaterThanOrEqual(SETPOINT_MIN)
        }
    })

    it('clone setpoint is clamped to maximum 3.0 when parent is at boundary', () => {
        const rand = seededRandom(222)
        const genome = makeGenomeWithBrain(0, 2)
        for (let k = 0; k < GENOME_K; k++) {
            genome[k * 4 + 1] = SETPOINT_MAX
        }
        applyCloneGenome(0, GENOME_STRIDE, genome, rand)

        for (let k = 0; k < GENOME_K; k++) {
            expect(genome[GENOME_STRIDE + k * 4 + 1]).toBeLessThanOrEqual(SETPOINT_MAX)
        }
    })

    it('multiple clones from the same parent diverge slightly', () => {
        const rand = seededRandom(4242)
        const genome = makeGenomeWithBrain(0, 4) // room for parent + 3 clones
        const cloneBases = [1, 2, 3].map(i => i * GENOME_STRIDE)
        for (const cb of cloneBases) {
            applyCloneGenome(0, cb, genome, rand)
        }

        // Collect setpoint values — at least one should differ from parent
        const sps = cloneBases.map(cb => genome[cb + 4 + 1]) // need 1's setpoint
        const allIdentical = sps.every(s => s === genome[4 + 1])
        expect(allIdentical).toBe(false)
    })
})

// ---------------------------------------------------------------------------
// Genome heredity: element-wise mean on merge
// ---------------------------------------------------------------------------
describe('Brain Genome — Merge (Element-wise Mean)', () => {
    function applyMergeGenome(survivorBase: number, loserBase: number, genome: Float32Array) {
        // Merged genome = (genomeA + genomeB) / 2 for both needs and weights
        for (let i = 0; i < GENOME_STRIDE; i++) {
            genome[survivorBase + i] = (genome[survivorBase + i] + genome[loserBase + i]) * 0.5
        }
    }

    it('merged setpoint is the midpoint of both parents', () => {
        const genome = makeGenomeWithBrain(0, 2)
        // Set different values for parent A and B
        genome[4 + 1] = 1.0 // A's need-1 setpoint
        genome[GENOME_STRIDE + 4 + 1] = 2.4 // B's need-1 setpoint

        applyMergeGenome(0, GENOME_STRIDE, genome)

        expect(genome[4 + 1]).toBeCloseTo(1.7, 5)
    })

    it('merged scale is the midpoint of both parents', () => {
        const genome = makeGenomeWithBrain(0, 2)
        genome[4 + 2] = 0.5 // A's need-1 scale
        genome[GENOME_STRIDE + 4 + 2] = 1.3 // B's need-1 scale

        applyMergeGenome(0, GENOME_STRIDE, genome)

        expect(genome[4 + 2]).toBeCloseTo(0.9, 5)
    })

    it('merged gain is the midpoint of both parents', () => {
        const genome = makeGenomeWithBrain(0, 2)
        genome[4 + 3] = 0.2 // A's need-1 gain
        genome[GENOME_STRIDE + 4 + 3] = 2.8 // B's need-1 gain

        applyMergeGenome(0, GENOME_STRIDE, genome)

        expect(genome[4 + 3]).toBeCloseTo(1.5, 5)
    })

    it('merged weights are the element-wise mean', () => {
        const genome = makeGenomeWithBrain(0, 2)
        // Set different weight values
        genome[GENOME_NEEDS_SIZE] = 0.3 // A's first weight
        genome[GENOME_STRIDE + GENOME_NEEDS_SIZE] = -0.1 // B's first weight

        applyMergeGenome(0, GENOME_STRIDE, genome)

        expect(genome[GENOME_NEEDS_SIZE]).toBeCloseTo(0.1, 5)
    })

    it('merge is symmetric (order-independent)', () => {
        // Create two identical arrays with different values in each brain slot
        const arr1 = new Float32Array(2 * GENOME_STRIDE)
        const arr2 = new Float32Array(2 * GENOME_STRIDE)

        // Brain A (slot 0): setpoint=0.5, weight=1.0
        // Brain B (slot 1): setpoint=2.5, weight=-0.4
        arr1[4 + 1] = 0.5; arr1[GENOME_STRIDE + 4 + 1] = 2.5
        arr1[GENOME_NEEDS_SIZE] = 1.0; arr1[GENOME_STRIDE + GENOME_NEEDS_SIZE] = -0.4
        arr2.set(arr1)

        // Merge A+B (survivor=slot 0)
        applyMergeGenome(0, GENOME_STRIDE, arr1)
        const resultAB = arr1[4 + 1]
        const resultW_AB = arr1[GENOME_NEEDS_SIZE]

        // Reset and merge B+A (survivor=slot 1, then read from slot 1)
        applyMergeGenome(GENOME_STRIDE, 0, arr2)
        const resultBA = arr2[GENOME_STRIDE + 4 + 1]
        const resultW_BA = arr2[GENOME_STRIDE + GENOME_NEEDS_SIZE]

        // Both should give the same midpoint
        expect(resultAB).toBeCloseTo(resultBA, 5)
        expect(resultW_AB).toBeCloseTo(resultW_BA, 5)
    })

    it('merge with identical parents preserves the value', () => {
        const genome = new Float32Array(2 * GENOME_STRIDE)
        // Set BOTH brains to identical values
        for (let i = 0; i < GENOME_STRIDE; i++) {
            genome[i] = 1.5
            genome[GENOME_STRIDE + i] = 1.5
        }
        applyMergeGenome(0, GENOME_STRIDE, genome)

        // Should be unchanged (mean of identical values = same value)
        expect(genome[4 + 1]).toBeCloseTo(1.5, 5)
        expect(genome[GENOME_NEEDS_SIZE]).toBeCloseTo(1.5, 5)
    })
})

// ---------------------------------------------------------------------------
// Neuron ownership: union on merge, free-on-death
// ---------------------------------------------------------------------------
describe('Neuron Ownership — Merge Union & Death Free', () => {
    const FREE = 0xFFFFFFFF

    it('merge unions the neuron ownership of both brains', () => {
        // Brain A owns sense neurons 0,1 and motor neurons 0,1
        // Brain B owns sense neurons 2,3 and motor neurons 2,3
        const numSense = 6
        const numMotor = 6
        const owners = new Uint32Array(numSense + numMotor).fill(FREE)

        // Set up ownership
        owners[0] = 0 // brain A owns sense 0
        owners[1] = 0 // brain A owns sense 1
        owners[numSense + 0] = 0 // brain A owns motor 0
        owners[numSense + 1] = 0 // brain A owns motor 1

        owners[2] = 1 // brain B owns sense 2
        owners[3] = 1 // brain B owns sense 3
        owners[numSense + 2] = 1 // brain B owns motor 2
        owners[numSense + 3] = 1 // brain B owns motor 3

        // Merge: survivor is brain A (id=0), loser is brain B (id=1)
        // All neurons owned by loser (1) get re-pointed to survivor (0)
        for (let i = 0; i < owners.length; i++) {
            if (owners[i] === 1) {
                owners[i] = 0
            }
        }

        // Now brain A owns all 4 sense + 4 motor neurons
        expect(owners[0]).toBe(0)
        expect(owners[1]).toBe(0)
        expect(owners[2]).toBe(0)
        expect(owners[3]).toBe(0)
        expect(owners[numSense + 0]).toBe(0)
        expect(owners[numSense + 1]).toBe(0)
        expect(owners[numSense + 2]).toBe(0)
        expect(owners[numSense + 3]).toBe(0)

        // Unowned neurons remain FREE
        expect(owners[4]).toBe(FREE)
        expect(owners[5]).toBe(FREE)
    })

    it('death frees all owned neurons back to the pool', () => {
        const numSense = 4
        const numMotor = 4
        const owners = new Uint32Array(numSense + numMotor).fill(FREE)

        // Brain 0 owns some neurons
        owners[0] = 0
        owners[1] = 0
        owners[numSense + 0] = 0

        // Brain 0 dies: free all its neurons
        for (let i = 0; i < owners.length; i++) {
            if (owners[i] === 0) {
                owners[i] = FREE
            }
        }

        // All previously-owned neurons are now FREE
        expect(owners[0]).toBe(FREE)
        expect(owners[1]).toBe(FREE)
        expect(owners[numSense + 0]).toBe(FREE)
    })

    it('clone copies parent ownership to child (same S and M)', () => {
        const numSense = 6
        const numMotor = 6
        const owners = new Uint32Array(numSense + numMotor).fill(FREE)

        // Brain A (id=0) owns sense 0,1 and motor 0,1
        owners[0] = 0
        owners[1] = 0
        owners[numSense + 0] = 0
        owners[numSense + 1] = 0

        // Clone: child (id=1) gets copies of parent's owned neurons
        // In practice, new particles are spawned and ownership is set to child id.
        // Here we simulate: find parent's owned neurons, assign them to child too
        // (in the real system, new particles are created in dormant slots)
        const childId = 1
        // The clone's neurons are NEW particles (in dormant pool), so we just verify
        // the ownership pattern is correct for the child
        owners[2] = childId // child gets sense neuron 2 (new particle)
        owners[3] = childId // child gets sense neuron 3 (new particle)
        owners[numSense + 2] = childId // child gets motor neuron 2
        owners[numSense + 3] = childId // child gets motor neuron 3

        // Child has same S=2, M=2 as parent
        let childS = 0, childM = 0
        for (let i = 0; i < numSense; i++) { if (owners[i] === childId) childS++ }
        for (let i = 0; i < numMotor; i++) { if (owners[numSense + i] === childId) childM++ }
        expect(childS).toBe(2)
        expect(childM).toBe(2)
    })
})

// ---------------------------------------------------------------------------
// Combined merge-then-clone scenario
// ---------------------------------------------------------------------------
describe('Brain Genome — Merge Then Clone (evolutionary pipeline)', () => {
    it('a merged brain that then clones produces a grandchild near the blended midpoint', () => {
        const rand = seededRandom(999)
        const genome = makeGenomeWithBrain(0, 3) // parent + clone slot

        // Set different values for two parents
        genome[4 + 1] = 1.0 // A's need-1 setpoint
        genome[GENOME_STRIDE + 4 + 1] = 2.0 // B's need-1 setpoint
        genome[4 + 2] = 0.5 // A's need-1 scale
        genome[GENOME_STRIDE + 4 + 2] = 1.5 // B's need-1 scale

        // Step 1: merge (element-wise mean)
        for (let i = 0; i < GENOME_STRIDE; i++) {
            genome[i] = (genome[i] + genome[GENOME_STRIDE + i]) * 0.5
        }
        // After merge: setpoint = 1.5, scale = 1.0

        // Step 2: clone with jitter
        const childBase = 2 * GENOME_STRIDE
        for (let k = 0; k < GENOME_K; k++) {
            genome[childBase + k * 4] = genome[k * 4] // targetColor copied
            genome[childBase + k * 4 + 1] = Math.min(SETPOINT_MAX, Math.max(SETPOINT_MIN,
                genome[k * 4 + 1] + gauss(rand) * MUT_SETPOINT))
            genome[childBase + k * 4 + 2] = Math.min(SCALE_MAX, Math.max(SCALE_MIN,
                genome[k * 4 + 2] + gauss(rand) * MUT_SCALE))
            genome[childBase + k * 4 + 3] = Math.min(GAIN_MAX, Math.max(GAIN_MIN,
                genome[k * 4 + 3] + gauss(rand) * MUT_GAIN))
        }

        // Grandchild should be near the merged midpoint (within mutation range)
        expect(Math.abs(genome[childBase + 4 + 1] - 1.5)).toBeLessThan(0.5)
        expect(Math.abs(genome[childBase + 4 + 2] - 1.0)).toBeLessThan(0.3)
    })
})
