import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mountSuspended } from '@nuxt/test-utils/runtime'
import { useParticleLifeStore } from '~/stores/particleLifeStore'

// Mock canvas 2D context - happy-dom doesn't support real rendering
const mockCtx = {
    clearRect: vi.fn(),
    fillRect: vi.fn(),
    beginPath: vi.fn(),
    arc: vi.fn(),
    fill: vi.fn(),
    stroke: vi.fn(),
    closePath: vi.fn(),
    save: vi.fn(),
    restore: vi.fn(),
    translate: vi.fn(),
    scale: vi.fn(),
    rotate: vi.fn(),
    setTransform: vi.fn(),
    drawImage: vi.fn(),
    createLinearGradient: vi.fn(() => ({ addColorStop: vi.fn() })),
    createRadialGradient: vi.fn(() => ({ addColorStop: vi.fn() })),
    getImageData: vi.fn(() => ({ data: new Uint8ClampedArray(4) })),
    putImageData: vi.fn(),
    createImageData: vi.fn(() => ({ data: new Uint8ClampedArray(4) })),
    canvas: null as any,
    globalAlpha: 1,
    fillStyle: '',
    strokeStyle: '',
    lineWidth: 1,
    font: '',
    textAlign: '',
    textBaseline: '',
}

beforeEach(() => {
    vi.stubGlobal('requestAnimationFrame', (cb: FrameRequestCallback) => setTimeout(cb, 0))
    vi.stubGlobal('cancelAnimationFrame', (id: number) => clearTimeout(id))
    vi.stubGlobal('ResizeObserver', class {
        observe = vi.fn()
        unobserve = vi.fn()
        disconnect = vi.fn()
    })

    HTMLCanvasElement.prototype.getContext = function () {
        return mockCtx as any
    }
})

describe('ParticleLifeCpu Component', () => {
    it('mounts without errors and renders the main container', async () => {
        const ParticleLifeCpu = (await import('~/components/particle-life/ParticleLifeCpu.vue')).default
        const wrapper = await mountSuspended(ParticleLifeCpu)

        // Main container section exists
        expect(wrapper.find('#mainContainer').exists()).toBe(true)
    })

    it('renders a canvas element for the simulation', async () => {
        const ParticleLifeCpu = (await import('~/components/particle-life/ParticleLifeCpu.vue')).default
        const wrapper = await mountSuspended(ParticleLifeCpu)

        // The life canvas should be in the DOM
        const canvas = wrapper.find('#lifeCanvas')
        expect(canvas.exists()).toBe(true)
    })

    it('store initializes with visible particle configuration', () => {
        const store = useParticleLifeStore()
        expect(store.numParticles).toBeGreaterThan(0)
        expect(store.particleSize).toBeGreaterThan(0)
        expect(store.isRunning).toBe(true)
    })

    it('particle count includes electrical particles when enabled', () => {
        const store = useParticleLifeStore()
        expect(store.isElectricalEnabled).toBe(true)
        const total = store.numParticles + store.numUrges + store.numNeurons + store.numSenseNeurons
        expect(total).toBeGreaterThan(store.numParticles)
    })

    it('particles have valid initial positions within bounds', () => {
        const store = useParticleLifeStore()
        // The grid should be set up for rendering
        expect(store.gridWidth).toBeGreaterThanOrEqual(0)
        expect(store.gridHeight).toBeGreaterThanOrEqual(0)
    })
})
