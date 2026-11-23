import { shallowMount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { useParticleLifeGPUStore } from '~/stores/particleLifeGPUStore'

// ---------------------------------------------------------------------------
// WebGPU mock
// ---------------------------------------------------------------------------
// happy-dom has no real WebGPU implementation. The 2D GPU Particle Life component
// drives a large slice of the WebGPU API during load (adapter -> device -> canvas
// context configure) and on every frame (compute + render passes, queue.submit).
//
// To confirm the component *loads* (its async init path runs to completion) and
// *renders* (a frame issues GPU work), we install a callable Proxy mock that
// transparently answers any WebGPU call, while keeping targeted vi.fn() spies on
// the lifecycle calls we specifically want to assert on.

let callLog: { path: string, args: unknown[] }[] = []
const calledMethods = new Set<string>()

// Real WebGPU `buffer.getMappedRange()` returns an ArrayBuffer. The component does
// `new Float32Array(buffer.getMappedRange()).set(initialParticles)`, so the mock must
// hand back a real (sized) buffer or the typed-array is created at length 0 and `.set`
// throws. A single shared ArrayBuffer is enough: each `new Float32Array(it)` is only a
// cheap view, so we never re-allocate.
const sharedMapBuffer = new ArrayBuffer(32 * 1024 * 1024)

function recordCall(path: string, args: unknown[]) {
    callLog.push({ path, args })
    // Record the last segment (the actual method name) for easy assertions.
    const method = path.split('.').pop() ?? path
    calledMethods.add(method)
}

// A thenable GPU object. Returned by every *method call* so that both awaited
// (`await device.queue.onSubmittedWorkDone()`) and synchronous creation calls
// resolve cleanly.
function makeThenable(label: string) {
    const target = function () {} as any
    return new Proxy(target, {
        apply(_t, _this, args) {
            recordCall(label, args)
            return makeThenable(`${label}()`)
        },
        get(_t, prop) {
            if (prop === Symbol.toPrimitive || prop === 'valueOf')
                return () => 65535
            if (prop === 'toString')
                return () => label
            if (prop === 'then')
                // Awaitable: resolves to a fresh plain GPU object.
                return (resolve: (v: unknown) => void) => resolve(makeUniversal(label))
            if (prop === 'getMappedRange')
                return () => sharedMapBuffer
            if (typeof prop === 'symbol')
                return undefined
            return makeUniversal(`${label}.${String(prop)}`)
        },
    })
}

// A plain callable GPU object. Returned for *property access* (e.g. `device.queue`,
// `navigator.gpu.requestAdapter`). It is callable (so `.requestDevice(...)` works),
// numeric-friendly in arithmetic (`toPrimitive` -> number) but NOT thenable, so it
// is never accidentally awaited.
function makeUniversal(label: string) {
    const target = function () {} as any
    return new Proxy(target, {
        apply(_t, _this, args) {
            recordCall(label, args)
            return makeThenable(`${label}()`)
        },
        get(_t, prop) {
            if (prop === Symbol.toPrimitive || prop === 'valueOf')
                return () => 65535
            if (prop === 'toString')
                return () => label
            // Critical: a property result must NOT be thenable. `device` is assigned
            // via `await adapter.requestDevice(...)`, and if the resolved value exposed
            // a callable `.then`, the await would keep unwrapping it forever.
            if (prop === 'then')
                return undefined
            if (prop === 'getMappedRange')
                return () => sharedMapBuffer
            if (typeof prop === 'symbol')
                return undefined
            return makeUniversal(`${label}.${String(prop)}`)
        },
    })
}

// Minimal 2D fallback in case any child component grabs a 2d context.
const mock2dCtx: Record<string, any> = {
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
    globalAlpha: 1,
    fillStyle: '',
    strokeStyle: '',
    lineWidth: 1,
    font: '',
    textAlign: '',
    textBaseline: '',
}

// Per-test handles we assert against.
let gpuContextMock: { configure: ReturnType<typeof vi.fn>, getCurrentTexture: ReturnType<typeof vi.fn> }
let requestAdapterSpy: ReturnType<typeof vi.fn>
let requestDeviceSpy: ReturnType<typeof vi.fn>
let deviceProxy: any
let rafCallbacks: ((time: number) => void)[] = []

const originalGetContext = HTMLCanvasElement.prototype.getContext

beforeEach(() => {
    callLog = []
    calledMethods.clear()
    rafCallbacks = []

    // The component logs its generated rules/radius matrices during init; silence the
    // noise (errors/warnings stay visible) so test output is readable.
    vi.spyOn(console, 'log').mockImplementation(() => {})

    // The canvas WebGPU context — targeted so we can assert configure().
    gpuContextMock = {
        configure: vi.fn(),
        getCurrentTexture: vi.fn(() => makeUniversal('GPUTexture')),
    }

    deviceProxy = makeUniversal('device')
    const adapter = {
        limits: { maxBindGroups: 8, maxComputeWorkgroupsPerDimension: 65535 },
        requestDevice: (requestDeviceSpy = vi.fn(async () => deviceProxy)),
    }
    navigator.gpu = {
        requestAdapter: (requestAdapterSpy = vi.fn(async () => adapter)),
        getPreferredCanvasFormat: vi.fn(() => 'bgra8unorm'),
    } as any

    // Route canvas.getContext('webgpu') to our mock; fall back to a 2d stub otherwise.
    HTMLCanvasElement.prototype.getContext = function (type: string) {
        return type === 'webgpu' ? gpuContextMock : mock2dCtx
    } as any

    // Give the canvas a non-zero client size so resize math produces sane dimensions.
    Object.defineProperty(HTMLCanvasElement.prototype, 'clientWidth', { configurable: true, get: () => 800 })
    Object.defineProperty(HTMLCanvasElement.prototype, 'clientHeight', { configurable: true, get: () => 600 })

    // Capture rAF callbacks instead of auto-running them (avoids an infinite loop).
    vi.stubGlobal('requestAnimationFrame', (cb: (time: number) => void) => {
        rafCallbacks.push(cb)
        return rafCallbacks.length
    })
    vi.stubGlobal('cancelAnimationFrame', () => {})
    vi.stubGlobal('ResizeObserver', class {
        observe = vi.fn()
        unobserve = vi.fn()
        disconnect = vi.fn()
    })

    // createHeatmapTexture() fetches the heatmap PNG and turns it into a bitmap.
    // happy-dom has no real network/WebGPU, so stub both to let init proceed to initLife.
    vi.stubGlobal('fetch', vi.fn(async () => ({
        ok: true,
        blob: async () => new Blob(['x'], { type: 'image/png' }),
    })))
    vi.stubGlobal('createImageBitmap', vi.fn(async () => ({ width: 256, height: 256 })))

    // WebGPU flag enums are browser globals that happy-dom does not provide. The
    // component only uses them to compute usage/stage bit flags that are passed into
    // (mocked) device calls, so the standard spec values are all we need.
    vi.stubGlobal('GPUBufferUsage', { MAP_READ: 1, MAP_WRITE: 2, COPY_SRC: 4, COPY_DST: 8, UNIFORM_BUFFER: 16, STORAGE_BUFFER: 32, INDEX_BUFFER: 64, VERTEX_BUFFER: 128 })
    vi.stubGlobal('GPUShaderStage', { VERTEX: 1, FRAGMENT: 2, COMPUTE: 4 })
    vi.stubGlobal('GPUTextureUsage', { COPY_SRC: 1, COPY_DST: 2, TEXTURE_BINDING: 4, STORAGE_BINDING: 8, RENDER_ATTACHMENT: 16 })
    vi.stubGlobal('GPUMapMode', { READ: 1, WRITE: 2 })
})

afterEach(() => {
    HTMLCanvasElement.prototype.getContext = originalGetContext
    delete (navigator as any).gpu
    vi.unstubAllGlobals()
    vi.restoreAllMocks()
})

// Mount the real component with a plain Vue + Pinia app.
//
// We intentionally do NOT use `mountSuspended`: the repo's vitest config runs under
// the `happy-dom` environment, and @nuxt/test-utils only bootstraps the Nuxt app
// context (globalThis.__unctx__ / "nuxt-app") when `environment: 'nuxt'`. Under
// happy-dom that context is absent, so mountSuspended cannot resolve the Vue app.
//
// The 2D GPU component's load/render behaviour lives entirely in its root setup +
// onMounted (WebGPU init -> buffers/pipelines -> first animation frame), and it only
// uses @vueuse/core composables + Pinia there (no useNuxtApp/navigateTo/etc). So
// shallowMount runs that full lifecycle while stubbing every child component, which
// is exactly what we want to assert on.
async function mountGpuComponent() {
    const ParticleLifeGpu = (await import('~/components/particle-life/ParticleLifeGpu.vue')).default
    const pinia = createPinia()
    setActivePinia(pinia)
    return shallowMount(ParticleLifeGpu, {
        global: { plugins: [pinia] },
    })
}

// Resolve once the async onMounted init path has finished (ctx.configure is called at
// the end of initWebGPU, and initLife registers the first animation frame after it).
async function waitForInit() {
    await vi.waitFor(() => expect(gpuContextMock.configure).toHaveBeenCalled(), { timeout: 5000 })
}

// ---------------------------------------------------------------------------
// Component: loads & renders
// ---------------------------------------------------------------------------
describe('particleLifeGpu (2D GPU) Component', () => {
    it('mounts without errors and renders the main container', async () => {
        const wrapper = await mountGpuComponent()
        expect(wrapper.find('#mainContainer').exists()).toBe(true)
    })

    it('renders a WebGPU canvas element for the simulation', async () => {
        const wrapper = await mountGpuComponent()
        const canvas = wrapper.find('#canvasRef')
        expect(canvas.exists()).toBe(true)
        expect(canvas.element.tagName).toBe('CANVAS')
    })

    it('requests a WebGPU adapter and device, then configures the canvas context', async () => {
        await mountGpuComponent()

        // The async onMounted init path must complete: adapter -> device -> ctx.configure.
        await waitForInit()

        expect(requestAdapterSpy).toHaveBeenCalledTimes(1)
        expect(requestDeviceSpy).toHaveBeenCalledTimes(1)

        // requestDevice asked for the >=5 bind-group limit the force shaders need.
        const deviceOptions = requestDeviceSpy.mock.calls[0][0]
        expect(deviceOptions.requiredLimits.maxBindGroups).toBeGreaterThanOrEqual(5)

        // configure received a device and a canvas pixel format.
        const configureArgs = gpuContextMock.configure.mock.calls[0][0]
        expect(configureArgs.device).toBeDefined()
        expect(typeof configureArgs.format).toBe('string')
    })

    it('runs frames that issue GPU compute + render work and submit to the queue', async () => {
        const wrapper = await mountGpuComponent()

        // Wait until init finishes (ctx.configure done) so buffers/pipelines exist.
        await waitForInit()

        // Several rAF callbacks are registered (the component's frame loop plus
        // @vueuse's useFps). Run every pending one once so the component's frame runs.
        const pending = [...rafCallbacks]
        expect(pending.length).toBeGreaterThan(0)
        for (const cb of pending)
            await cb(performance.now())

        // A render pass was begun against the canvas texture and work was submitted.
        expect(calledMethods.has('beginRenderPass')).toBe(true)
        expect(calledMethods.has('submit')).toBe(true)
        // Spatial hashing is enabled by default, so a compute pass runs too.
        expect(calledMethods.has('beginComputePass')).toBe(true)

        // The frame reschedules itself -> the animation loop is alive.
        expect(rafCallbacks.length).toBeGreaterThan(pending.length - 1)
        expect(wrapper.find('#canvasRef').exists()).toBe(true)
    })
})

// ---------------------------------------------------------------------------
// Store: GPU engine defaults
// ---------------------------------------------------------------------------
describe('particle Life GPU Store', () => {
    beforeEach(() => {
        setActivePinia(createPinia())
    })

    it('defaults to the GPU engine and a running simulation', () => {
        const store = useParticleLifeGPUStore()
        expect(store.engineType).toBe('GPU')
        expect(store.isRunning).toBe(true)
    })

    it('initializes with sensible particle / species defaults', () => {
        const store = useParticleLifeGPUStore()
        expect(store.numParticles).toBeGreaterThan(0)
        expect(store.numColors).toBeGreaterThan(0)
        expect(store.particleSize).toBeGreaterThan(0)
    })

    it('has valid force parameters', () => {
        const store = useParticleLifeGPUStore()
        expect(store.repel).toBeGreaterThan(0)
        expect(store.forceFactor).toBeGreaterThan(0)
        expect(store.frictionFactor).toBeGreaterThanOrEqual(0)
        expect(store.frictionFactor).toBeLessThan(1)
    })

    it('enables the electrical (urge/neuron) layer by default', () => {
        const store = useParticleLifeGPUStore()
        expect(store.isElectricalEnabled).toBe(true)
        expect(store.numUrges).toBeGreaterThan(0)
        expect(store.numNeurons).toBeGreaterThan(0)
    })
})
