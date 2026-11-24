import { describe, it, expect } from 'vitest'
import { readFileSync, readdirSync, statSync } from 'node:fs'
import { join } from 'node:path'

// ---------------------------------------------------------------------------
// Regression tests for shader compilation errors that cause a black screen
// when switching to infinite/mirror wrap modes.
// ---------------------------------------------------------------------------

const SHADER_DIR = join(process.cwd(), 'assets', 'particle-brain-gpu', 'shaders')

function collectWgslFiles(dir: string): string[] {
    const results: string[] = []
    for (const entry of readdirSync(dir)) {
        if (entry === 'old') continue
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

// ---------------------------------------------------------------------------
// Regression: `mod()` is a GLSL built-in, NOT valid WGSL.
// Using it causes "unresolved call target 'mod'" → shader module invalid →
// all render pipelines that use it fail → black screen.
// The correct WGSL idiom is: x - y * floor(x / y)
// ---------------------------------------------------------------------------
describe('WGSL Invalid Built-in Functions', () => {
    const GLSL_ONLY_BUILTINS = [
        'mod',       // → use x - y * floor(x / y)
        'mix',       // actually valid in WGSL, but listed for completeness (not tested)
        'clamp',     // valid in WGSL
    ]
    // Only `mod` is genuinely invalid in WGSL. The others are fine.
    const INVALID_IN_WGSL = ['mod']

    it('no shader uses mod() (GLSL-only, not a WGSL built-in)', () => {
        const files = collectWgslFiles(SHADER_DIR)
        expect(files.length).toBeGreaterThan(0)

        const errors: string[] = []
        for (const file of files) {
            const source = readFileSync(file, 'utf-8')
            const lines = source.split('\n')
            for (let i = 0; i < lines.length; i++) {
                // Match `mod(` as a function call (not part of a longer identifier like "modulate")
                if (/\bmod\s*\(/.test(lines[i])) {
                    const rel = file.replace(process.cwd() + '/', '')
                    errors.push(`${rel}:${i + 1}: uses mod() which is not a valid WGSL built-in`)
                }
            }
        }

        expect(errors, `Invalid GLSL built-ins found:\n${errors.join('\n')}`).toHaveLength(0)
    })
})

// ---------------------------------------------------------------------------
// Regression: struct constructor arity mismatch.
// Catches "structure constructor has too few inputs: expected N, found M"
// which invalidates the shader module and all pipelines using it.
// We check every local struct that is used as a constructor (e.g., VertexOutput).
// ---------------------------------------------------------------------------
describe('WGSL Struct Constructor Arity', () => {
    /**
     * Extract named structs from a WGSL source.
     * Returns Map<structName, fieldCount>.
     */
    function extractStructs(source: string): Map<string, number> {
        const structs = new Map<string, number>()
        // Match struct Name { ... } — handle nested braces by counting depth
        const re = /struct\s+(\w+)\s*\{/g
        let m: RegExpExecArray | null
        while ((m = re.exec(source)) !== null) {
            const name = m[1]
            // Find the matching closing brace
            let depth = 1
            let i = m.index + m[0].length
            while (i < source.length && depth > 0) {
                if (source[i] === '{') depth++
                else if (source[i] === '}') depth--
                i++
            }
            const body = source.slice(m.index + m[0].length, i - 1)
            // Count fields: lines with `name : type` pattern (strip comments first)
            const cleanBody = body.replace(/\/\/[^\n]*/g, '')
            const fieldMatches = cleanBody.match(/^[ \t]*(\w+)\s*:/gm)
            if (fieldMatches) {
                structs.set(name, fieldMatches.length)
            }
        }
        return structs
    }

    /**
     * Find all `StructName(...)` constructor calls and count their args.
     * Handles nested parentheses (e.g., Vec2<f32>(x, y) as an argument).
     */
    function findConstructorCalls(source: string, structName: string): Array<{ line: number, argCount: number }> {
        const results: Array<{ line: number, argCount: number }> = []
        const pattern = new RegExp(`\\b${structName}\\s*\\(`, 'g')
        let m: RegExpExecArray | null
        while ((m = pattern.exec(source)) !== null) {
            // Find the matching closing paren by tracking depth
            let i = m.index + m[0].length - 1 // position of the opening '('
            let depth = 1
            while (i < source.length && depth > 0) {
                i++
                if (source[i] === '(') depth++
                else if (source[i] === ')') depth--
            }
            const argsStr = source.slice(m.index + m[0].length, i - 1).trim()
            if (!argsStr) continue // empty parens — not a constructor call

            const argCount = countTopLevelArgs(argsStr)
            const lineNum = source.slice(0, m.index).split('\n').length
            results.push({ line: lineNum, argCount })
        }
        return results
    }

    /** Count top-level arguments in a comma-separated string (respects nested parens/brackets). */
    function countTopLevelArgs(str: string): number {
        let depth = 0
        let count = 1 // at least one arg if non-empty
        for (const ch of str) {
            if (ch === '(' || ch === '[' || ch === '{') depth++
            else if (ch === ')' || ch === ']' || ch === '}') depth--
            else if (ch === ',' && depth === 0) count++
        }
        return count
    }

    it('every struct constructor call passes the correct number of arguments', () => {
        const files = collectWgslFiles(SHADER_DIR)
        expect(files.length).toBeGreaterThan(0)

        const errors: string[] = []
        for (const file of files) {
            const source = readFileSync(file, 'utf-8')
            const structs = extractStructs(source)
            const rel = file.replace(process.cwd() + '/', '')

            for (const [name, fieldCount] of structs) {
                // Only check structs that are actually used as constructors
                const calls = findConstructorCalls(source, name)
                for (const call of calls) {
                    if (call.argCount !== fieldCount) {
                        errors.push(
                            `${rel}:${call.line}: ${name}(...) has ${call.argCount} args but struct declares ${fieldCount} fields`
                        )
                    }
                }
            }
        }

        expect(errors, `Struct constructor arity mismatches:\n${errors.join('\n')}`).toHaveLength(0)
    })
})

// ---------------------------------------------------------------------------
// Regression: Lorentz (magnetic) force must be symmetric.
// The bug: updating vx in-place then using the NEW vx to compute vy introduces
// a systematic bias (q²·vy·B²·dt² term) causing asymmetric "splash" behavior.
// The fix: save both old velocities before either update.
// ---------------------------------------------------------------------------
describe('WGSL Lorentz Force Symmetry', () => {
    const MAGNETIC_SHADERS = [
        join(SHADER_DIR, 'compute', 'particleAdvance.wgsl'),
        join(SHADER_DIR, 'compute', 'particleComputeForces.wgsl'),
    ]

    /**
     * Check that the magnetic force block saves old velocities before updating.
     * Pattern: must have `let oldVx = ...` and `let oldVy = ...` before the += / -= lines.
     */
    function checkLorentzSymmetry(source: string, relPath: string): string[] {
        const errors: string[] = []
        const lines = source.split('\n')

        // Find all magnetic force blocks (lines containing q * ... * bField or bLocal)
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]

            // Detect the anti-pattern: vy update uses particle.vx (already modified)
            // instead of a saved oldVx. The correct pattern uses `oldVx`/`oldVy`.
            if (/particle\.vy\s*-?=\s*q\s*\*\s*particle\.vx/.test(line)) {
                errors.push(
                    `${relPath}:${i + 1}: Lorentz vy update reads particle.vx directly ` +
                    `(should use saved old velocity for symmetry). Line: ${line.trim()}`
                )
            }
            if (/particle\.vx\s*\+=\s*q\s*\*\s*particle\.vy/.test(line)) {
                errors.push(
                    `${relPath}:${i + 1}: Lorentz vx update reads particle.vy directly ` +
                    `(should use saved old velocity for symmetry). Line: ${line.trim()}`
                )
            }
        }

        // Positive check: the file SHOULD contain oldVx/oldVy saves near magnetic code
        if (source.includes('magneticStrength') || source.includes('bLocal')) {
            const hasOldVx = /let\s+oldVx\s*=/.test(source)
            const hasOldVy = /let\s+oldVy\s*=/.test(source)
            if (!hasOldVx || !hasOldVy) {
                errors.push(
                    `${relPath}: magnetic force code present but missing saved old velocities ` +
                    `(need "let oldVx" and "let oldVy" before the velocity updates)`
                )
            }
        }

        return errors
    }

    it('particleAdvance.wgsl uses symmetric Lorentz force', () => {
        const file = MAGNETIC_SHADERS[0]
        const source = readFileSync(file, 'utf-8')
        const rel = file.replace(process.cwd() + '/', '')
        const errors = checkLorentzSymmetry(source, rel)
        expect(errors, errors.join('\n')).toHaveLength(0)
    })

    it('particleComputeForces.wgsl uses symmetric Lorentz force', () => {
        const file = MAGNETIC_SHADERS[1]
        const source = readFileSync(file, 'utf-8')
        const rel = file.replace(process.cwd() + '/', '')
        const errors = checkLorentzSymmetry(source, rel)
        expect(errors, errors.join('\n')).toHaveLength(0)
    })
})

// ---------------------------------------------------------------------------
// Regression: setSimSize must flag cameraChanged when dimensions change.
// Without this, the GPU camera buffer retains stale scale factors while the
// infinite tile layout is already updated → tiles render at wrong positions.
// ---------------------------------------------------------------------------
describe('Infinite Wrap Camera Sync', () => {
    it('setSimSize sets cameraChanged=true when sim dimensions change', () => {
        const vueFile = readFileSync(
            join(process.cwd(), 'components', 'particle-brain', 'ParticleBrainGpu.vue'),
            'utf-8'
        )

        // Find the setSimSize function body
        const match = vueFile.match(/function\s+setSimSize\s*\(\)\s*\{([\s\S]*?)\n\s{8}\}/)
        expect(match, 'Could not find setSimSize function body').not.toBeNull()

        const body = match![1]
        // Must contain a check for dimension change that sets cameraChanged
        expect(
            body,
            'setSimSize must detect dimension changes and set cameraChanged = true'
        ).toMatch(/cameraChanged\s*=\s*true/)
    })
})
