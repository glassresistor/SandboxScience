import { describe, it, expect } from 'vitest'
import { readFileSync, readdirSync, statSync } from 'node:fs'
import { join } from 'node:path'

// ---------------------------------------------------------------------------
// Regression: the bind-group budget must stay within the browser cap of 4.
//
// Browsers expose maxBindGroups = 4 (the WebGPU default; the spec maximum is 8,
// but the vast majority of devices report exactly 4). If ANY compute/render
// pipeline needs more than 4 bind groups, createPipeline()/requestDevice() fail
// and the whole sim renders nothing — no particles, black canvas.
//
// The historical bug: initWebGPU requested
//     requiredLimits: { maxBindGroups: Math.min(5, adapter.limits.maxBindGroups) }
// on the (false) assumption that "the force shaders use 5 bind groups." They do
// not — every shader only ever uses @group(0..3), i.e. 4 groups total. Requesting
// 5 made device/pipeline creation fail on the common 4-group devices, so particles
// never loaded.
//
// This test guards BOTH sides of that contract so it cannot silently regress:
//   1. Shader side (ground truth): scan every WGSL @group(N) and HARD-ERROR if any
//      index is >= 4 (i.e. > 4 groups total). This is the real cause of a black
//      screen, so it must be a hard failure.
//   2. JS side: the value passed to requiredLimits.maxBindGroups must be <= 4.
//      While it was 5 this test FAILED; after lowering it to 4 it PASSES.
//   3. "Particles load" proxy (headless): the requested limit must be large enough
//      to cover every shader's group usage (so all pipelines can be created) while
//      staying at or below the browser cap — exactly the condition under which
//      requestDevice + createPipeline succeed and particles render. There is no
//      headless WebGPU in CI, so this is the strongest achievable stand-in for
//      "particles actually load."
//
// DO NOT raise BROWSER_BIND_GROUP_CAP above 4. If you genuinely need a 5th bind
// group, consolidate existing groups first; raising the cap will break every
// device that exposes the default 4.
// ---------------------------------------------------------------------------

const SHADER_DIR = join(process.cwd(), 'assets', 'particle-brain-gpu', 'shaders')
const VUE_FILE = join(process.cwd(), 'components', 'particle-brain', 'ParticleBrainGpu.vue')

// The browser cap we must never exceed. WebGPU default maxBindGroups is 4 and most
// devices expose exactly this. Keep at 4 — do not raise.
const BROWSER_BIND_GROUP_CAP = 4

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

/** Highest @group(N) index referenced anywhere across the given shader files (-1 if none). */
function maxGroupIndexAcrossShaders(files: string[]): number {
    let max = -1
    for (const file of files) {
        const source = readFileSync(file, 'utf-8')
        const re = /@group\(\s*(\d+)\s*\)/g
        let m: RegExpExecArray | null
        while ((m = re.exec(source)) !== null) {
            max = Math.max(max, parseInt(m[1], 10))
        }
    }
    return max
}

/**
 * The integer(s) the app requests for requiredLimits.maxBindGroups in initWebGPU.
 * Matches object-literal forms only ("maxBindGroups: 4" or "maxBindGroups: Math.min(5, ...)"),
 * so it ignores reads like `adapter.limits.maxBindGroups` (no colon after the name).
 */
function requestedMaxBindGroups(vueSource: string): number[] {
    const re = /maxBindGroups\s*:\s*(?:Math\.(?:min|max)\(\s*)?(\d+)/g
    const values: number[] = []
    let m: RegExpExecArray | null
    while ((m = re.exec(vueSource)) !== null) {
        values.push(parseInt(m[1], 10))
    }
    return values
}

describe('WGSL bind-group budget (must stay <= browser cap of 4)', () => {
    it('no shader uses @group(4) or higher — browsers cap at 4 groups (hard error)', () => {
        const files = collectWgslFiles(SHADER_DIR)
        expect(files.length).toBeGreaterThan(0)

        const maxIdx = maxGroupIndexAcrossShaders(files)
        const groupsNeeded = maxIdx + 1 // index 3 -> 4 groups (0,1,2,3)

        expect(
            groupsNeeded,
            `A shader declares @group(${maxIdx}), i.e. ${groupsNeeded} bind groups total, but browsers cap ` +
            `maxBindGroups at ${BROWSER_BIND_GROUP_CAP}. That pipeline would fail to create and particles would not ` +
            `load (black canvas). Consolidate the shaders to <= ${BROWSER_BIND_GROUP_CAP} groups (indices 0..${BROWSER_BIND_GROUP_CAP - 1}).`,
        ).toBeLessThanOrEqual(BROWSER_BIND_GROUP_CAP)
    })

    it('initWebGPU requests at most the browser cap of 4 bind groups', () => {
        const vue = readFileSync(VUE_FILE, 'utf-8')
        const values = requestedMaxBindGroups(vue)

        expect(
            values.length,
            'Could not find a requiredLimits.maxBindGroups value in initWebGPU — add it back so the cap is explicit.',
        ).toBeGreaterThan(0)

        const offenders = values.filter(v => v > BROWSER_BIND_GROUP_CAP)
        expect(
            offenders,
            `initWebGPU requests maxBindGroups: ${offenders.join(', ')} but browsers cap at ${BROWSER_BIND_GROUP_CAP}. ` +
            `Requesting more makes requestDevice() throw and the sim fails to load (no particles). Lower it to ${BROWSER_BIND_GROUP_CAP}.`,
        ).toHaveLength(0)
    })

    it('requested limit covers every shader (particles can load) without exceeding the cap', () => {
        const files = collectWgslFiles(SHADER_DIR)
        const groupsNeeded = maxGroupIndexAcrossShaders(files) + 1
        const values = requestedMaxBindGroups(readFileSync(VUE_FILE, 'utf-8'))
        expect(values.length).toBeGreaterThan(0)
        // Use the largest requested value as the effective device limit.
        const requested = Math.max(...values)

        // Enough for all pipelines to be created (otherwise some pipeline fails -> no particles)...
        expect(
            requested,
            `requested maxBindGroups (${requested}) is less than the ${groupsNeeded} groups the shaders need — ` +
            `some pipeline would fail to create and particles would not load.`,
        ).toBeGreaterThanOrEqual(groupsNeeded)

        // ...and within what browsers actually allow.
        expect(
            requested,
            `requested maxBindGroups (${requested}) exceeds the browser cap of ${BROWSER_BIND_GROUP_CAP}.`,
        ).toBeLessThanOrEqual(BROWSER_BIND_GROUP_CAP)
    })
})