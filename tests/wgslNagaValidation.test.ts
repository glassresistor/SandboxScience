import { describe, it, expect } from 'vitest'
import { readFileSync, readdirSync, statSync } from 'node:fs'
import { join } from 'node:path'
// naga-wasm is the exact validator WebGPU runs on createShaderModule(). If a shader
// fails here, device.createShaderModule() rejects at runtime -> invalid pipeline ->
// particles never render (black canvas). See https://github.com/gfx-rs/naga.
import { init, parseWgsl, validate } from 'naga-wasm'

// ---------------------------------------------------------------------------
// Regression test: every particle-brain WGSL shader must pass full naga
// validation (parse + semantic). This is the same gate WebGPU applies.
//
// It was added because recent brain refactors introduced shader bugs that
// only surface at runtime as "Error while parsing WGSL" / invalid pipeline
// errors, leaving the canvas black:
//   1. `let H : u32;`            -> "expected '=' for 'let' declaration" (parse)
//   2. workgroupBarrier() after a non-uniform early-return
//                                  -> "'workgroupBarrier' must only be called from
//                                     uniform control flow" (semantic)
//   3. `electrical.brainGain`     -> "struct member brainGain not found" (semantic)
// Text/regex checks cannot catch these; only real WGSL validation can.
// ---------------------------------------------------------------------------

const SHADER_DIR = join(process.cwd(), 'assets', 'particle-brain-gpu', 'shaders')

function collectWgslFiles(dir: string): string[] {
    const results: string[] = []
    for (const entry of readdirSync(dir)) {
        if (entry === 'old') continue // legacy, not compiled
        const full = join(dir, entry)
        const st = statSync(full)
        if (st.isDirectory()) {
            results.push(...collectWgslFiles(full))
        } else if (entry.endsWith('.wgsl')) {
            results.push(full)
        }
    }
    return results
}

// naga-wasm is an async WebAssembly module; initialize it once.
let nagaReady = false
async function ensureNaga() {
    if (!nagaReady) {
        await init()
        nagaReady = true
    }
}

describe('WGSL naga validation (particle-brain-gpu)', () => {
    it('discovers brain shaders', async () => {
        const files = collectWgslFiles(SHADER_DIR)
        expect(files.length).toBeGreaterThan(0)
    })

    it('every brain shader passes naga parse + validate (no black-screen regressions)', async () => {
        await ensureNaga()
        const files = collectWgslFiles(SHADER_DIR)
        expect(files.length).toBeGreaterThan(0)

        const failures: string[] = []
        for (const file of files) {
            const source = readFileSync(file, 'utf-8')
            const rel = file.replace(process.cwd() + '/', '')
            try {
                // parseWgsl throws NagaError on any parse failure.
                parseWgsl(source)
                // validate performs full semantic analysis (uniform control flow,
                // struct member access, type checks, ...) - same as WebGPU.
                validate(parseWgsl(source))
            } catch (e: any) {
                const formatted = e?.formatted || e?.message || String(e)
                failures.push(`${rel}\n${String(formatted).split('\n').map(l => '    ' + l).join('\n')}`)
            }
        }

        expect(
            failures,
            `The following brain shaders fail naga validation (WebGPU would reject them -> black canvas):\n\n${failures.join('\n\n')}`,
        ).toHaveLength(0)
    })
})

// ---------------------------------------------------------------------------
// Regression: uniform control flow for workgroupBarrier() in one-workgroup-per-
// brain shaders.
//
// brainStep.wgsl is dispatched as ONE WORKGROUP PER BRAIN (dispatchWorkgroups(numBrains))
// and calls workgroupBarrier() after an early-return keyed on the per-brain id:
//
//     let brainId = <builtin>.x;
//     if (brainId >= opts.numBrains) { return; }   // must be UNIFORM across the workgroup
//     ...
//     workgroupBarrier();                          // every thread in the WG must reach this
//
// If the per-brain id is derived from @builtin(global_invocation_id).x, each of the 64
// threads in a workgroup has a DIFFERENT id, so the early-return becomes non-uniform and
// modern WebGPU rejects the shader with:
//     "'workgroupBarrier' must only be called from uniform control flow"
// -> invalid pipeline -> particles never render.
//
// NOTE: naga-wasm 30.2.0 (the version pinned here) does NOT statically flag this case, so
// the generic naga pass above would still go green if someone regressed brainId back to
// global_invocation_id.x. We therefore assert the invariant directly: the per-brain id must
// come from @builtin(workgroup_id), which IS uniform within a workgroup.
// ---------------------------------------------------------------------------
describe('WGSL uniform control flow (one workgroup per brain)', () => {
    /** Strip // line comments and /* block *\/ comments so we only inspect executable code. */
    function stripComments(src: string): string {
        return src
            .replace(/\/\*[\s\S]*?\*\//g, '')   // block comments
            .replace(/(^|[^:])\/\/[^\n]*/g, '$1') // line comments (avoid URLs like https://)
    }

    it('brainStep.wgsl derives its per-brain id from workgroup_id (uniform), not global_invocation_id', () => {
        const file = join(SHADER_DIR, 'compute', 'brainStep.wgsl')
        const code = stripComments(readFileSync(file, 'utf-8'))

        // It uses workgroup barriers, so the brain-id early-return must be uniform.
        expect(code, 'brainStep.wgsl should use workgroupBarrier()').toMatch(/workgroupBarrier\s*\(/)

        // The per-brain id MUST come from a workgroup-uniform builtin...
        expect(
            code,
            'brainStep.wgsl must read the per-brain id from @builtin(workgroup_id) so the '
            + 'early-return before workgroupBarrier() stays in uniform control flow',
        ).toMatch(/@builtin\(workgroup_id\)/)

        // ...and MUST NOT come from global_invocation_id (non-uniform within a workgroup).
        expect(
            code,
            'brainStep.wgsl must NOT derive the per-brain id from @builtin(global_invocation_id) '
            + '- that makes the early-return non-uniform and deadlocks/invalidates workgroupBarrier() '
            + 'in modern WebGPU ("workgroupBarrier must only be called from uniform control flow")',
        ).not.toMatch(/@builtin\(global_invocation_id\)/)
    })
})
