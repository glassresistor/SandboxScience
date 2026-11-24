import { describe, it, expect } from 'vitest'
import { readFileSync, readdirSync, statSync } from 'node:fs'
import { join } from 'node:path'

// ---------------------------------------------------------------------------
// Regression test: every 2D GPU shader that declares a `struct Particle` must
// have EXACTLY 11 f32 fields (stride = 44 bytes). A mismatch means the GPU
// reads particle N+1 at the wrong byte offset, interpreting drive params as
// x/y coordinates — the "stride bug" that causes apparent axis swapping.
// ---------------------------------------------------------------------------

const SHADER_DIR = join(process.cwd(), 'assets', 'particle-life-gpu', 'shaders')
const EXPECTED_PARTICLE_FIELDS = 11 // x,y,vx,vy,type,control,signal,goalB,driveTarget,driveScale,driveGain

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

function extractParticleFields(source: string): string[] | null {
    const match = source.match(/struct\s+Particle\s*\{([^}]+)\}/)
    if (!match) return null
    // Strip ALL line comments BEFORE splitting so commas in comments don't break parsing
    const body = match[1].replace(/\/\/[^\n]*/g, '')
    const fields: string[] = []
    for (const raw of body.split(/[;,]/)) {
        const line = raw.trim()
        if (!line) continue
        const m = line.match(/^(\w+)\s*:\s*\w+/)
        if (m) fields.push(m[1])
    }
    return fields.length > 0 ? fields : null
}

describe('WGSL Particle Stride Consistency', () => {
    it('all 2D GPU shaders declare exactly 11 Particle fields', () => {
        const files = collectWgslFiles(SHADER_DIR)
        expect(files.length).toBeGreaterThan(0)

        const mismatches: string[] = []
        let checkedCount = 0

        for (const file of files) {
            const source = readFileSync(file, 'utf-8')
            const fields = extractParticleFields(source)
            if (!fields) continue

            checkedCount++
            if (fields.length !== EXPECTED_PARTICLE_FIELDS) {
                const rel = file.replace(process.cwd() + '/', '')
                mismatches.push(`${rel}: has ${fields.length} fields [${fields.join(', ')}]`)
            }
        }

        expect(checkedCount).toBeGreaterThanOrEqual(10)
        if (mismatches.length > 0) {
            throw new Error(
                `Stride mismatch! Expected ${EXPECTED_PARTICLE_FIELDS} fields per Particle struct.\n` +
                mismatches.join('\n')
            )
        }
    })

    it('Particle field ORDER is consistent (x,y,vx,vy first)', () => {
        const files = collectWgslFiles(SHADER_DIR)
        const expectedOrder = ['x', 'y', 'vx', 'vy']

        for (const file of files) {
            const source = readFileSync(file, 'utf-8')
            const fields = extractParticleFields(source)
            if (!fields || fields.length < 4) continue

            const rel = file.replace(process.cwd() + '/', '')
            for (let i = 0; i < 4; i++) {
                expect(fields[i], `${rel}: field[${i}]`).toBe(expectedOrder[i])
            }
        }
    })

    it('no JS code uses stale *8 particle stride', () => {
        const vueFile = readFileSync(join(process.cwd(), 'components', 'particle-life', 'ParticleLifeGpu.vue'), 'utf-8')
        const lines = vueFile.split('\n')
        const suspicious: string[] = []

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            const m = line.match(/(\w+)\s*\*\s*8(?!\d)/)
            if (m) {
                const lower = line.toLowerCase()
                if (lower.includes('color') || lower.includes('matrix') || lower.includes('0x')) continue
                suspicious.push(`  L${i + 1}: ${line.trim()}`)
            }
        }

        expect(suspicious, `Stale *8 stride references:\n${suspicious.join('\n')}`).toHaveLength(0)
    })
})
