import { shallowMount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { useParticleLifeStore } from '~/stores/particleLifeStore'

// ---------------------------------------------------------------------------
// Particle Life (CPU) component tests
//
// The repo's vitest config runs under the `happy-dom` environment (see
// vitest.config.ts), so there is NO Nuxt app instance (globalThis.__unctx__) and
// therefore `mountSuspended` cannot resolve a Vue app. We instead mount the real
// component with a plain Vue + Pinia app via @vue/test-utils, exactly as the GPU
// test does. The component's load/render behaviour lives entirely in its root
// setup + onMounted (canvas -> 2d context -> initLife -> first animation frame),
// so shallowMount runs that full lifecycle while stubbing every child UI component.
//
// happy-dom has no real canvas rendering, so we hand the component a vi.fn()-based
// 2D context and assert on it: a successful particle load must (a) size the world
// grid from the canvas, (b) build the interaction matrices (incl. electrical rows),
// and (c) actually clear + paint the canvas on the first frame while keeping the
// animation loop alive. If any of that fails to happen (particles refusing to
// load), the corresponding assertion fails.
// ---------------------------------------------------------------------------

// A fresh, spy-backed 2D context for every test so call counts never leak across tests.
function makeMockCtx(): Record<string, any> {
    return {
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
        moveTo: vi.fn(),
        lineTo: vi.fn(),
        roundRect: vi.fn(),
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
}

let mockCtx: Record<string, any>
// Captured rAF callbacks (we do NOT auto-run them, to avoid an infinite loop).
let rafCallbacks: ((time: number) => void)[] = []
const originalGetContext = HTMLCanvasElement.prototype.getContext

beforeEach(() => {
    mockCtx = makeMockCtx()
    rafCallbacks = []

    vi.stubGlobal('requestAnimationFrame', (cb: FrameRequestCallback) => {
        rafCallbacks.push(cb as (time: number) => void)
        return rafCallbacks.length
    })
    vi.stubGlobal('cancelAnimationFrame', () => {})
    vi.stubGlobal('ResizeObserver', class {
        observe = vi.fn()
        unobserve = vi.fn()
        disconnect = vi.fn()
    })

    // The component grabs its canvas via document.getElementById('lifeCanvas') and a 2d ctx.
    HTMLCanvasElement.prototype.getContext = function (type: string) {
        return type === '2d' ? mockCtx : null
    } as any

    // Give the canvas a non-zero client size so grid/resize math produces sane dimensions.
    Object.defineProperty(HTMLCanvasElement.prototype, 'clientWidth', { configurable: true, get: () => 800 })
    Object.defineProperty(HTMLCanvasElement.prototype, 'clientHeight', { configurable: true, get: () => 600 })

    // Silence per-frame / key-press logging noise (errors & warnings stay visible).
    vi.spyOn(console, 'log').mockImplementation(() => {})
})

afterEach(() => {
    HTMLCanvasElement.prototype.getContext = originalGetContext
    vi.unstubAllGlobals()
    vi.restoreAllMocks()
    // Remove any canvas we attached to the document so ids never collide between tests.
    document.body.innerHTML = ''
})

// Mount the real component with a plain Vue + Pinia app, attached to the document so
// its `document.getElementById('lifeCanvas')` resolves to the rendered canvas.
async function mountCpuComponent() {
    const ParticleLifeCpu = (await import('~/components/particle-life/ParticleLifeCpu.vue')).default
    const pinia = createPinia()
    setActivePinia(pinia)
    const container = document.createElement('div')
    document.body.appendChild(container)
    return shallowMount(ParticleLifeCpu, {
        global: { plugins: [pinia] },
        attachTo: container,
    })
}

// Drive the simulation one step by invoking the live (most recently scheduled) frame.
async function runFrame() {
    const cb = rafCallbacks[rafCallbacks.length - 1]
    expect(cb).toBeDefined()
    await cb(performance.now())
}

describe('particleLifeCpu Component', () => {
    it('mounts without errors and renders the main container + canvas', async () => {
        const wrapper = await mountCpuComponent()

        // Main container section exists.
        expect(wrapper.find('#mainContainer').exists()).toBe(true)
        // The life canvas is in the DOM and really is a <canvas>.
        const canvas = wrapper.find('#lifeCanvas')
        expect(canvas.exists()).toBe(true)
        expect(canvas.element.tagName).toBe('CANVAS')
    })

    it('initializes the world on load (grid sized from the canvas)', async () => {
        await mountCpuComponent()
        const store = useParticleLifeStore()

        // initLife -> setGridSizeBasedOnScreen writes the canvas-derived grid back to
        // the store. If particle/world init never completed, these stay at 0.
        expect(store.gridWidth).toBeGreaterThan(0)
        expect(store.gridHeight).toBeGreaterThan(0)
    })

    it('builds interaction matrices sized for the electrical layer', async () => {
        await mountCpuComponent()
        const store = useParticleLifeStore()

        // The matrix dimension is numColors (matter rows) + 2 extra rows (urge + neuron/sense).
        // This only holds once initLife has generated and stored the matrices.
        expect(store.rulesMatrix.length).toBe(store.numColors + 2)
        expect(store.maxRadiusMatrix.length).toBe(store.numColors + 2)
        expect(store.minRadiusMatrix.length).toBe(store.numColors + 2)
    })

    it('loads particles: the first frame clears and paints the canvas', async () => {
        await mountCpuComponent()

        // onMounted scheduled the first animation frame (initLife did not throw).
        expect(rafCallbacks.length).toBeGreaterThan(0)
        const before = rafCallbacks.length

        // Run one real frame.
        await runFrame()

        // A running frame clears the background and paints particles onto the canvas.
        expect(mockCtx.clearRect).toHaveBeenCalledTimes(1)
        // Background fill + per-particle squares/circles -> many draw ops, not zero.
        const drawOps = mockCtx.fillRect.mock.calls.length + mockCtx.arc.mock.calls.length
        expect(drawOps).toBeGreaterThan(50)

        // The frame rescheduled itself -> the animation loop is alive.
        expect(rafCallbacks.length).toBeGreaterThan(before)
    })

    it('store initializes with visible particle configuration', () => {
        setActivePinia(createPinia())
        const store = useParticleLifeStore()
        expect(store.numParticles).toBeGreaterThan(0)
        expect(store.particleSize).toBeGreaterThan(0)
        expect(store.isRunning).toBe(true)
    })

    it('particle count includes electrical particles when enabled', () => {
        setActivePinia(createPinia())
        const store = useParticleLifeStore()
        expect(store.isElectricalEnabled).toBe(true)
        const total = store.numParticles + store.numUrges + store.numNeurons + store.numSenseNeurons
        expect(total).toBeGreaterThan(store.numParticles)
    })
})
