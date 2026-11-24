/**
 * Experiment / sweep metrics for the particle-brain GPU simulation.
 *
 * These are PURE functions: no Vue, no WebGPU, no DOM. They operate on a plain
 * `Float32Array` holding particle records in the canonical 11-float stride layout
 * (see `constants/particleStride.ts`). That keeps them trivially unit-testable and
 * reusable by the opt-in telemetry block in `ParticleBrainGpu.vue`.
 *
 * Particle record layout (stride 11):
 *   [0]x [1]y [2]vx [3]vy [4]particleType [5]control [6]signal
 *   [7]goalB [8]driveTarget [9]driveScale [10]driveGain
 *
 * Type bands (intType = floor(particleType)):
 *   matter        : [0, numTypes)
 *   urges         : [numTypes, numTypes + numUrges)
 *   motor neurons : [numTypes + numUrges, + numNeurons)
 *   sense neurons : after that
 *
 * For MATTER particles `control` and `signal` are always 0; only x/y/vx/vy/type
 * carry meaning. A motor neuron's firing activity is its `signal` (offset P.signal).
 */

import { P, PARTICLE_STRIDE } from '~/constants/particleStride'

export interface MatterEntropyOpts {
    numTypes: number
    simWidth: number
    simHeight: number
    /** Grid cells per axis for the density field. Default 64 (→ 4096 cells). */
    gridResolution?: number
}

/**
 * Normalized Shannon entropy [0,1] of the MATTER density field on a 2D grid.
 *
 * Choice documented: all colors are aggregated into a single density field (we bin
 * by position only, not per-color). A uniform spread fills many cells → high entropy;
 * everything in one cell → 0. Returns 0 when there is no matter or no valid domain.
 */
export function measureMatterEntropy(particles: Float32Array, opts: MatterEntropyOpts): number {
    const { numTypes, simWidth, simHeight } = opts
    const res = Math.max(1, Math.floor(opts.gridResolution ?? 64))
    if (numTypes <= 0 || simWidth <= 0 || simHeight <= 0)
        return 0

    const cells = res * res
    const counts = new Uint32Array(cells)
    let matterCount = 0

    for (let i = 0; i < particles.length / PARTICLE_STRIDE; i++) {
        const b = i * PARTICLE_STRIDE
        const intType = Math.floor(particles[b + P.particleType])
        if (intType < 0 || intType >= numTypes)
            continue // matter only
        const x = particles[b + P.x]
        const y = particles[b + P.y]
        let gx = Math.floor((x / simWidth) * res)
        let gy = Math.floor((y / simHeight) * res)
        if (gx < 0)
            gx = 0; else if (gx >= res)
            gx = res - 1
        if (gy < 0)
            gy = 0; else if (gy >= res)
            gy = res - 1
        counts[gy * res + gx]++
        matterCount++
    }

    if (matterCount === 0)
        return 0

    let h = 0
    for (let c = 0; c < cells; c++) {
        const n = counts[c]
        if (n <= 0)
            continue
        const p = n / matterCount
        h -= p * Math.log2(p)
    }

    const maxEntropy = Math.log2(cells)
    if (maxEntropy <= 0)
        return 0
    const normalized = h / maxEntropy
    // Clamp to [0,1] to absorb any float round-off.
    return Math.min(1, Math.max(0, normalized))
}

/** Novelty rate = how fast the configuration changes: |Δentropy| between two samples. */
export function noveltyRate(prevEntropy: number, curEntropy: number): number {
    return Math.abs(curEntropy - prevEntropy)
}

/**
 * Approximate Gaussian via sum of 3 uniform randoms (Irwin-Hall), centered at 0.
 * Mirrors `gauss3` in brainMutate.wgsl so CPU-side rule drift and GPU-side drive
 * drift draw from the same ~N(0,1) approximation. Takes an RNG so tests can seed it.
 */
function gauss3(rng: () => number): number {
    return (rng() + rng() + rng() - 1.5) * 1.1547 // ~N(0,1) approximation
}

/**
 * Add small centered Gaussian noise to the MATTER×MATTER submatrix ONLY
 * (rows/cols 0..numTypes-1), clamped to [-1,1]. Urge/neuron rows and columns are
 * left untouched. Mutates `matrix` in place.
 *
 * `strength` is the σ of the per-cell noise; pass 0 (or negative) for a no-op.
 * Pass a seeded RNG for deterministic tests (defaults to Math.random).
 */
export function driftInteractionMatrix(matrix: number[][], numTypes: number, strength: number, rng: () => number = Math.random): void {
    if (strength <= 0 || numTypes <= 0)
        return
    const n = Math.min(numTypes, matrix.length)
    for (let i = 0; i < n; i++) {
        const row = matrix[i]
        const m = Math.min(n, row.length)
        for (let j = 0; j < m; j++) {
            const v = row[j] + gauss3(rng) * strength
            row[j] = Math.max(-1, Math.min(1, v))
        }
    }
}

export interface ControlGapOpts {
    numTypes: number
    numUrges: number
    numNeurons: number
    /** Radius (world units) over which a neuron measures its target-color matter. */
    urgeRadius: number
    /** Spatial-hash cells across the domain. Default 48. */
    gridResolution?: number
}

const SIGNAL_EPS = 1e-3
const LEN_EPS = 1e-6

/**
 * Control gap: how well each ACTIVE motor neuron's intended push direction matches
 * the actual motion of its target-color matter.
 *
 * For each active neuron (|signal| > eps):
 *   - target color = mIdx % numTypes
 *   - intended dir = neuron → centroid of that color's matter within urgeRadius
 *   - actual dir   = mean velocity of that same matter
 *   - contribution = 1 - |cosine(intended, actual)|
 * Returns the mean over active neurons: 0 = perfectly aligned, 1 = orthogonal/opposite.
 * Returns 0 when there are no active neurons or no target matter to measure against.
 *
 * Uses a coarse spatial hash (O(N) build + local query) so it stays cheap enough for
 * throttled telemetry. The domain is the bounding box of all particles, so no sim dims
 * are required.
 */
export function measureControlGap(particles: Float32Array, opts: ControlGapOpts): number {
    const { numTypes, numUrges, numNeurons, urgeRadius } = opts
    const res = Math.max(1, Math.floor(opts.gridResolution ?? 48))
    if (numNeurons <= 0 || numTypes <= 0)
        return 0

    const n = particles.length / PARTICLE_STRIDE
    if (n <= 0)
        return 0

    // Domain = bounding box of every particle (robust; no external dims needed).
    let minX = Infinity; let minY = Infinity; let maxX = -Infinity; let maxY = -Infinity
    for (let i = 0; i < n; i++) {
        const b = i * PARTICLE_STRIDE
        const x = particles[b + P.x]
        const y = particles[b + P.y]
        if (x < minX)
            minX = x
        if (y < minY)
            minY = y
        if (x > maxX)
            maxX = x
        if (y > maxY)
            maxY = y
    }
    const spanX = Math.max(maxX - minX, 1e-6)
    const spanY = Math.max(maxY - minY, 1e-6)

    const cellXOf = (x: number): number => {
        let c = Math.floor(((x - minX) / spanX) * res)
        if (c < 0)
            c = 0; else if (c >= res)
            c = res - 1
        return c
    }
    const cellYOf = (y: number): number => {
        let c = Math.floor(((y - minY) / spanY) * res)
        if (c < 0)
            c = 0; else if (c >= res)
            c = res - 1
        return c
    }

    // Build the spatial hash of MATTER particles only.
    const buckets: number[][] = new Array(res * res)
    for (let c = 0; c < buckets.length; c++)
        buckets[c] = []
    for (let i = 0; i < n; i++) {
        const b = i * PARTICLE_STRIDE
        const intType = Math.floor(particles[b + P.particleType])
        if (intType < 0 || intType >= numTypes)
            continue
        buckets[cellYOf(particles[b + P.y]) * res + cellXOf(particles[b + P.x])].push(i)
    }

    const r2 = urgeRadius * urgeRadius
    let sum = 0
    let count = 0

    for (let i = 0; i < n; i++) {
        const b = i * PARTICLE_STRIDE
        const intType = Math.floor(particles[b + P.particleType])
        // Motor neuron band only.
        if (intType < numTypes + numUrges || intType >= numTypes + numUrges + numNeurons)
            continue
        const mIdx = intType - numTypes - numUrges
        const signal = particles[b + P.signal]
        if (Math.abs(signal) <= SIGNAL_EPS)
            continue // inactive neuron

        const targetColor = ((mIdx % numTypes) + numTypes) % numTypes
        const nx = particles[b + P.x]
        const ny = particles[b + P.y]

        // Gather this color's matter within urgeRadius via the local grid window.
        const gx0 = cellXOf(nx - urgeRadius)
        const gx1 = cellXOf(nx + urgeRadius)
        const gy0 = cellYOf(ny - urgeRadius)
        const gy1 = cellYOf(ny + urgeRadius)

        let mx = 0; let my = 0; let mvx = 0; let mvy = 0; let mcount = 0
        for (let gy = gy0; gy <= gy1; gy++) {
            for (let gx = gx0; gx <= gx1; gx++) {
                const bucket = buckets[gy * res + gx]
                if (!bucket)
                    continue
                for (const j of bucket) {
                    const b2 = j * PARTICLE_STRIDE
                    if (Math.floor(particles[b2 + P.particleType]) !== targetColor)
                        continue
                    const dx = particles[b2 + P.x] - nx
                    const dy = particles[b2 + P.y] - ny
                    if (dx * dx + dy * dy > r2)
                        continue
                    mx += particles[b2 + P.x]
                    my += particles[b2 + P.y]
                    mvx += particles[b2 + P.vx]
                    mvy += particles[b2 + P.vy]
                    mcount++
                }
            }
        }

        if (mcount === 0)
            continue // no target matter to measure against

        const ix = mx / mcount - nx // intended dir: neuron -> centroid
        const iy = my / mcount - ny
        const ax = mvx / mcount // actual dir: mean velocity
        const ay = mvy / mcount
        const lenI = Math.hypot(ix, iy)
        const lenA = Math.hypot(ax, ay)
        if (lenI < LEN_EPS || lenA < LEN_EPS)
            continue // degenerate (neuron at centroid, or matter not moving)

        const cosine = (ix * ax + iy * ay) / (lenI * lenA)
        sum += 1 - Math.abs(cosine)
        count++
    }

    return count > 0 ? sum / count : 0
}
