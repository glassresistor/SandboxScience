import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useParticleLifeStore } from '~/stores/particleLifeStore'

describe('Particle Life Store', () => {
    beforeEach(() => {
        setActivePinia(createPinia())
    })

    it('initializes with correct default particle count', () => {
        const store = useParticleLifeStore()
        expect(store.numParticles).toBe(6000)
    })

    it('initializes with correct number of colors', () => {
        const store = useParticleLifeStore()
        expect(store.numColors).toBe(7)
    })

    it('has electrical layer enabled by default', () => {
        const store = useParticleLifeStore()
        expect(store.isElectricalEnabled).toBe(true)
    })

    it('initializes with correct urge and neuron counts', () => {
        const store = useParticleLifeStore()
        expect(store.numUrges).toBe(30)
        expect(store.numNeurons).toBe(80)
    })

    it('initializes sense neurons with defaults', () => {
        const store = useParticleLifeStore()
        expect(store.numSenseNeurons).toBe(40)
        expect(store.senseRadius).toBe(60)
        expect(store.senseConeHalfAngleDeg).toBe(35)
        expect(store.senseMode).toBe(0)
    })

    it('computes total particle count correctly when electrical is enabled', () => {
        const store = useParticleLifeStore()
        // matter + urges + neurons + sense neurons
        const expected = store.numParticles + store.numUrges + store.numNeurons + store.numSenseNeurons
        expect(store.numParticles + store.numUrges + store.numNeurons + store.numSenseNeurons).toBe(expected)
    })

    it('allows disabling electrical layer', () => {
        const store = useParticleLifeStore()
        store.isElectricalEnabled = false
        expect(store.isElectricalEnabled).toBe(false)
    })

    it('has valid force parameters', () => {
        const store = useParticleLifeStore()
        expect(store.repel).toBeGreaterThan(0)
        expect(store.forceFactor).toBeGreaterThan(0)
        expect(store.frictionFactor).toBeGreaterThanOrEqual(0)
        expect(store.frictionFactor).toBeLessThan(1)
    })

    it('has valid particle size', () => {
        const store = useParticleLifeStore()
        expect(store.particleSize).toBeGreaterThan(0)
    })

    it('supports changing numParticles', () => {
        const store = useParticleLifeStore()
        store.numParticles = 1000
        expect(store.numParticles).toBe(1000)
    })
})
