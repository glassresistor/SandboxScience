import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it } from 'vitest'
import { useParticleLifeGPU3DStore } from '~/stores/particleLifeGPU3DStore'

// The 3D GPU store is the largest engine config in the repo and had no coverage.
// These tests pin its defaults (so a refactor that silently changes an engine
// default is caught) and exercise the reactive wallState computed both ways.

describe('particleLifeGPU3D Store', () => {
    beforeEach(() => {
        setActivePinia(createPinia())
    })

    it('defaults to the GPU3D engine with a running simulation', () => {
        const store = useParticleLifeGPU3DStore()
        expect(store.engineType).toBe('GPU3D')
        expect(store.isRunning).toBe(true)
    })

    it('initializes with sensible particle / species defaults', () => {
        const store = useParticleLifeGPU3DStore()
        expect(store.numParticles).toBeGreaterThan(0)
        expect(store.particleSize).toBeGreaterThan(0)
        expect(store.particleOpacity).toBeGreaterThanOrEqual(0)
        expect(store.particleOpacity).toBeLessThanOrEqual(1)
        expect(store.numColors).toBeGreaterThan(0)
    })

    it('has valid force parameters', () => {
        const store = useParticleLifeGPU3DStore()
        expect(store.repel).toBeGreaterThan(0)
        expect(store.forceFactor).toBeGreaterThan(0)
        expect(store.frictionFactor).toBeGreaterThanOrEqual(0)
        expect(store.frictionFactor).toBeLessThan(1)
    })

    it('uses spatial binning in grid mode by default', () => {
        const store = useParticleLifeGPU3DStore()
        expect(store.useBinning).toBe(true)
        expect(store.binningMode).toBe('grid')
    })

    it('keeps camera smoothing factors within [0, 1]', () => {
        const store = useParticleLifeGPU3DStore()
        expect(store.zoomSmoothing).toBeGreaterThanOrEqual(0)
        expect(store.zoomSmoothing).toBeLessThanOrEqual(1)
        expect(store.panSmoothing).toBeGreaterThanOrEqual(0)
        expect(store.panSmoothing).toBeLessThanOrEqual(1)
    })

    it('exposes a 3-component light direction for sphere shading', () => {
        const store = useParticleLifeGPU3DStore()
        expect(store.sphereLightDir).toHaveLength(3)
        for (const c of store.sphereLightDir)
            expect(Number.isFinite(c)).toBe(true)
    })

    it('wallState defaults to none and reflects the wall flags', () => {
        const store = useParticleLifeGPU3DStore()
        expect(store.isWallRepel).toBe(false)
        expect(store.isWallWrap).toBe(false)
        expect(store.wallState).toBe('none')
    })

    it('wallState setter drives the wall flags in both directions', () => {
        const store = useParticleLifeGPU3DStore()

        store.wallState = 'repel'
        expect(store.isWallRepel).toBe(true)
        expect(store.isWallWrap).toBe(false)

        store.wallState = 'wrap'
        expect(store.isWallWrap).toBe(true)
        expect(store.isWallRepel).toBe(false)

        store.wallState = 'none'
        expect(store.wallState).toBe('none')
    })

    it('supports mutating particle count and radius ranges', () => {
        const store = useParticleLifeGPU3DStore()
        store.numParticles = 5000
        expect(store.numParticles).toBe(5000)
        store.minRadiusRange = [10, 20]
        expect(store.minRadiusRange).toEqual([10, 20])
    })
})
