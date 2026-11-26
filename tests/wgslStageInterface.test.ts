import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'

// ---------------------------------------------------------------------------
// Regression test: cross-file vertex/fragment stage-interface consistency.
//
// renderOffscreenPipeline pairs the VERTEX entry of offscreen_render_vertex.wgsl
// with the FRAGMENT entry (fragmentMain) of render_normal.wgsl. WGSL validation
// (naga, see wgslNagaValidation.test.ts) checks each module in ISOLATION and cannot
// see that a vertex in one file feeds a fragment in another — so a mismatch there
// only surfaces at runtime as:
//
//   Uncaptured WebGPU error: Validation Error
//     In Device::create_render_pipeline
//       Location[2] Float32 ... is not provided by the previous stage outputs
//       Input is not provided by the earlier stage in the pipeline
//
// which throws during createRenderPipelines() at init -> black screen / stuck on
// "Loading simulation...". This test guards that specific cross-file pairing so it
// can never silently desync again.
// ---------------------------------------------------------------------------

const RENDER_DIR = join(process.cwd(), 'assets', 'particle-brain-gpu', 'shaders', 'render')

/**
 * Extract the `@location(N) name: Type` pairs declared inside a file's
 * `struct VertexOutput { ... }` block, as a Map<location number, type string>.
 */
function vertexOutputLocations(wgslSource: string): Map<number, string> {
    const structMatch = wgslSource.match(/struct\s+VertexOutput\s*\{([\s\S]*?)\}/)
    expect(structMatch, 'no `struct VertexOutput` found').toBeTruthy()
    const body = structMatch![1]

    const locRe = /@location\((\d+)\)\s+\w+\s*:\s*([A-Za-z0-9_]+(?:<[^>]*>)?)/g
    const map = new Map<number, string>()
    let m: RegExpExecArray | null
    while ((m = locRe.exec(body)) !== null) {
        map.set(Number(m[1]), m[2])
    }
    return map
}

describe('WGSL cross-file stage interface (particle-brain render)', () => {
    it('offscreen vertex provides every location the render_normal fragment consumes', () => {
        const offscreenVertex = readFileSync(join(RENDER_DIR, 'offscreen_render_vertex.wgsl'), 'utf-8')
        const renderNormalFrag = readFileSync(join(RENDER_DIR, 'render_normal.wgsl'), 'utf-8')

        // What the vertex stage PRODUCES (locations it writes out).
        const produced = vertexOutputLocations(offscreenVertex)
        // What the fragment stage CONSUMES (fragmentMain takes `in: VertexOutput`,
        // so render_normal's VertexOutput struct is the input interface).
        const consumed = vertexOutputLocations(renderNormalFrag)

        expect(produced.size, 'offscreen vertex should declare at least one @location').toBeGreaterThan(0)
        expect(consumed.size, 'render_normal fragment should consume at least one @location').toBeGreaterThan(0)

        // Every location the fragment needs must be produced by the vertex with the
        // SAME type — otherwise createRenderPipeline throws a stage-matching error.
        const missing: string[] = []
        for (const [loc, type] of consumed.entries()) {
            if (!produced.has(loc)) {
                missing.push(`@location(${loc}) ${type} (not produced by vertex)`)
            } else if (produced.get(loc) !== type) {
                missing.push(`@location(${loc}) type mismatch: vertex=${produced.get(loc)} vs fragment=${type}`)
            }
        }
        expect(missing, `offscreen vertex -> render_normal fragment interface gaps:\n  ${missing.join('\n  ')}`).toEqual([])
    })
})
