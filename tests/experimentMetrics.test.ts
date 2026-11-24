import { describe, expect, it } from 'vitest'
import { P, PARTICLE_STRIDE } from '~/constants/particleStride'
import { driftInteractionMatrix, hebbianUpdateWeight, measureControlGap, measureMatterEntropy, noveltyRate, scheduleNeuronDamage } from '~/helpers/utils/experimentMetrics'

/** Deterministic PRNG so tests are reproducible. */
function mulberry32(seed: number): () => number {
    let a = seed >>> 0
    return () => {
        a |= 0; a = (a + 0x6D2B79F5) | 0
        let t = Math.imul(a ^ (a >>> 15), 1 | a)
        t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296
    }
}

/** Append one particle record to a growing array, returning the new length. */
function addParticle(
    out: number[],
    x: number,
    y: number,
    vx: number,
    vy: number,
    type: number,
    control = 0,
    signal = 0,
): void {
    out.push(x, y, vx, vy, type, control, signal, 0, 0, 0, 0) // stride 11; trailing zeros
}

describe('noveltyRate', () => {
    it('is 0 when the two samples are equal', () => {
        expect(noveltyRate(0.42, 0.42)).toBe(0)
    })

    it('returns |Δ| and is symmetric', () => {
        expect(noveltyRate(0.2, 0.5)).toBeCloseTo(0.3)
        expect(noveltyRate(0.5, 0.2)).toBeCloseTo(0.3)
    })

    it('is always non-negative', () => {
        expect(noveltyRate(0.9, 0.1)).toBeGreaterThan(0)
    })
})

describe('measureMatterEntropy', () => {
    const opts = { numTypes: 3, simWidth: 100, simHeight: 100 }

    it('is always within [0,1]', () => {
        const data: number[] = []
        const rng = mulberry32(7)
        for (let i = 0; i < 500; i++)
            addParticle(data, rng() * 100, rng() * 100, 0, 0, i % 3)
        const e = measureMatterEntropy(new Float32Array(data), opts)
        expect(e).toBeGreaterThanOrEqual(0)
        expect(e).toBeLessThanOrEqual(1)
    })

    it('is ~0 when all matter sits in a single cell', () => {
        const data: number[] = []
        for (let i = 0; i < 200; i++)
            addParticle(data, 5 + (i % 3) * 0.1, 5, 0, 0, i % 3) // tight cluster in one corner cell
        const e = measureMatterEntropy(new Float32Array(data), opts)
        expect(e).toBeLessThan(0.05)
    })

    it('is higher for a uniform spread than for a tight cluster', () => {
        const rng = mulberry32(42)
        const spread: number[] = []
        for (let i = 0; i < 2000; i++)
            addParticle(spread, rng() * 100, rng() * 100, 0, 0, i % 3)

        const cluster: number[] = []
        for (let i = 0; i < 2000; i++)
            addParticle(cluster, 50 + (rng() - 0.5) * 4, 50 + (rng() - 0.5) * 4, 0, 0, i % 3)

        const eSpread = measureMatterEntropy(new Float32Array(spread), opts)
        const eCluster = measureMatterEntropy(new Float32Array(cluster), opts)
        expect(eSpread).toBeGreaterThan(eCluster)
    })

    it('returns 0 when there is no matter', () => {
        // only a neuron, no matter
        const data: number[] = []
        addParticle(data, 10, 10, 0, 0, 5) // type 5 >= numTypes(3) → not matter
        expect(measureMatterEntropy(new Float32Array(data), opts)).toBe(0)
    })

    it('ignores non-matter particles (urges/neurons)', () => {
        const data: number[] = []
        addParticle(data, 5, 5, 0, 0, 0) // one matter particle in a single cell
        addParticle(data, 90, 90, 0, 0, 3, 1, 1) // an urge far away — must not affect entropy
        const e = measureMatterEntropy(new Float32Array(data), opts)
        expect(e).toBeLessThan(0.05)
    })
})

describe('measureControlGap', () => {
    // Domain: numTypes=2, numUrges=1, numNeurons=1 → motor neuron intType = 2+1+0 = 3.
    const opts = { numTypes: 2, numUrges: 1, numNeurons: 1, urgeRadius: 60 }

    it('returns 0 when there are no active neurons', () => {
        const data: number[] = []
        addParticle(data, 0, 0, 0, 0, 0) // matter color 0
        addParticle(data, 10, 0, 5, 0, 3, 0, 0) // neuron with signal=0 → inactive
        expect(measureControlGap(new Float32Array(data), opts)).toBe(0)
    })

    it('returns 0 when there are no neurons at all', () => {
        const data: number[] = []
        addParticle(data, 0, 0, 0, 0, 0)
        expect(measureControlGap(new Float32Array(data), opts)).toBe(0)
    })

    it('is ~0 when actual motion aligns with the intended push direction', () => {
        const data: number[] = []
        // Neuron at origin, active (signal=1), target color 0.
        addParticle(data, 0, 0, 0, 0, 3, 0, 1)
        // Target-color matter spread along +x from the neuron, all moving +x.
        for (let i = 0; i < 40; i++)
            addParticle(data, 10 + i * 0.6, 0, 5, 0, 0)
        const g = measureControlGap(new Float32Array(data), opts)
        expect(g).toBeLessThan(0.05)
    })

    it('is ~1 when actual motion is perpendicular to the intended direction', () => {
        const data: number[] = []
        addParticle(data, 0, 0, 0, 0, 3, 0, 1) // neuron at origin, active
        // Matter along +x (intended dir = +x) but moving +y (perpendicular).
        for (let i = 0; i < 40; i++)
            addParticle(data, 10 + i * 0.6, 0, 0, 5, 0)
        const g = measureControlGap(new Float32Array(data), opts)
        expect(g).toBeGreaterThan(0.9)
    })

    it('ignores matter outside the target color', () => {
        const data: number[] = []
        addParticle(data, 0, 0, 0, 0, 3, 0, 1) // neuron, target color 0
        // Only color-1 matter nearby (wrong color) → no measurable target matter → 0.
        for (let i = 0; i < 40; i++)
            addParticle(data, 10 + i * 0.6, 0, 5, 0, 1)
        expect(measureControlGap(new Float32Array(data), opts)).toBe(0)
    })
})

describe('driftInteractionMatrix', () => {
    // 5×5 matrix with numTypes=3 → rows/cols 0..2 are matter, 3..4 are urge/neuron.
    const makeMatrix = (): number[][] => [
        [0.1, -0.2, 0.3, 0.9, -0.7],
        [-0.5, 0.0, 0.4, 0.2, 0.8],
        [0.6, -0.1, -0.3, -0.4, 0.5],
        [0.9, 0.2, -0.4, 0.7, -0.6], // urge row — must stay untouched
        [-0.7, 0.8, 0.5, -0.6, 0.1], // neuron row — must stay untouched
    ]

    it('is a no-op when strength is 0 (or negative)', () => {
        const m = makeMatrix()
        const before = m.map(r => [...r])
        driftInteractionMatrix(m, 3, 0)
        expect(m).toEqual(before)
        driftInteractionMatrix(m, 3, -0.1)
        expect(m).toEqual(before)
    })

    it('only changes matter×matter cells and keeps values in [-1,1]', () => {
        const m = makeMatrix()
        const before = m.map(r => [...r])
        driftInteractionMatrix(m, 3, 0.5, mulberry32(42))

        // Urge/neuron rows (and their columns) are untouched.
        for (let i = 3; i < 5; i++)
            expect(m[i]).toEqual(before[i])
        for (let j = 3; j < 5; j++) {
            expect(m[0][j]).toBe(before[0][j])
            expect(m[1][j]).toBe(before[1][j])
            expect(m[2][j]).toBe(before[2][j])
        }

        // Matter×matter cells: every one stays in [-1,1] and most actually moved.
        let changed = 0
        for (let i = 0; i < 3; i++) {
            for (let j = 0; j < 3; j++) {
                expect(m[i][j]).toBeGreaterThanOrEqual(-1)
                expect(m[i][j]).toBeLessThanOrEqual(1)
                if (m[i][j] !== before[i][j]) {
                    changed++
                }
            }
        }
        expect(changed).toBeGreaterThan(0)
    })

    it('is deterministic for a seeded RNG', () => {
        const m1 = makeMatrix()
        const m2 = makeMatrix()
        driftInteractionMatrix(m1, 3, 0.5, mulberry32(7))
        driftInteractionMatrix(m2, 3, 0.5, mulberry32(7))
        expect(m1).toEqual(m2)
    })

    it('clamps cells that would overshoot [-1,1]', () => {
        const m: number[][] = [[1, 0], [0, -1]]
        // strength large enough that ±1 cells must be clamped, not pushed past.
        driftInteractionMatrix(m, 2, 5, mulberry32(1))
        for (const row of m) {
            for (const v of row) {
                expect(v).toBeGreaterThanOrEqual(-1)
                expect(v).toBeLessThanOrEqual(1)
            }
        }
    })
})

describe('scheduleNeuronDamage', () => {
    it('is a no-op when probability is 0 and nothing is damaged', () => {
        const r = scheduleNeuronDamage(new Map(), 0, 60, 10, mulberry32(1))
        expect(r.next.size).toBe(0)
        expect(r.newlyDamaged).toEqual([])
        expect(r.healed).toEqual([])
    })

    it('damages a neuron for `duration` frames and decrements each frame', () => {
        // rng() < 0.999... always true → damage attempt every frame.
        let r = scheduleNeuronDamage(new Map(), 1, 3, 10, mulberry32(5))
        expect(r.newlyDamaged).toHaveLength(1)
        const idx = r.newlyDamaged[0]
        expect(r.next.get(idx)).toBe(3)

        // Subsequent frames: no new damage (probability 0), duration counts down.
        r = scheduleNeuronDamage(r.next, 0, 3, 10, mulberry32(5))
        expect(r.next.get(idx)).toBe(2)
        expect(r.healed).toEqual([])
        r = scheduleNeuronDamage(r.next, 0, 3, 10, mulberry32(5))
        expect(r.next.get(idx)).toBe(1)
        r = scheduleNeuronDamage(r.next, 0, 3, 10, mulberry32(5))
        expect(r.next.has(idx)).toBe(false)
        expect(r.healed).toContain(idx) // healed exactly when the duration expires
    })

    it('never re-damages a neuron that is still damaged', () => {
        const existing = new Map([[0, 5], [1, 5]])
        // numNeurons=2 with probability 1: every candidate is already damaged → no-op.
        const r = scheduleNeuronDamage(existing, 1, 5, 2, mulberry32(9))
        expect(r.newlyDamaged).toEqual([])
        expect(r.next.get(0)).toBe(4)
        expect(r.next.get(1)).toBe(4)
    })

    it('drops out-of-range entries when numNeurons shrinks (healed)', () => {
        const existing = new Map([[3, 5]]) // was valid for 10 neurons, invalid for 3
        const r = scheduleNeuronDamage(existing, 0, 5, 3, mulberry32(2))
        expect(r.next.has(3)).toBe(false)
        expect(r.healed).toContain(3)
    })

    it('is deterministic for a seeded RNG and does not mutate the input', () => {
        const a = new Map([[0, 10]])
        const b = new Map([[0, 10]])
        const r1 = scheduleNeuronDamage(a, 0.5, 60, 20, mulberry32(7))
        const r2 = scheduleNeuronDamage(b, 0.5, 60, 20, mulberry32(7))
        expect(r1.newlyDamaged).toEqual(r2.newlyDamaged)
        expect([...r1.next.entries()]).toEqual([...r2.next.entries()])
        // input untouched
        expect(a.get(0)).toBe(10)
    })
})

describe('hebbianUpdateWeight', () => {
    it('is a no-op when lr is 0', () => {
        expect(hebbianUpdateWeight(0.7, 0.3, -0.9, 0)).toBe(0.7)
    })

    it('applies w + lr * h * e', () => {
        expect(hebbianUpdateWeight(0.5, 0.25, 1.0, 0.01)).toBeCloseTo(0.5025)
        expect(hebbianUpdateWeight(-0.5, -0.4, 0.5, 0.01)).toBeCloseTo(-0.498)
    })

    it('clamps the result to [-clamp, +clamp]', () => {
        expect(hebbianUpdateWeight(1.9, 1, 1, 0.5)).toBe(2) // would be 2.4
        expect(hebbianUpdateWeight(-1.9, -1, 1, 0.5)).toBe(-2)
        expect(hebbianUpdateWeight(1.9, 1, 1, 0.5, 3)).toBeCloseTo(2.4) // custom clamp
    })
})

// Sanity: the stride constant the helpers rely on is unchanged (guards Phase-4 temptation).
describe('particleStride sanity', () => {
    it('still has exactly 11 fields and P.signal at offset 6', () => {
        expect(PARTICLE_STRIDE).toBe(11)
        expect(P.signal).toBe(6)
        expect(P.x).toBe(0)
    })
})
