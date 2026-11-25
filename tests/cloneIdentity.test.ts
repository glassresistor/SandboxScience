import { describe, expect, it } from 'vitest'
import { assignCloneIds, compareUrgeRows, pruneCloneRegistry } from '~/helpers/utils/cloneIdentity'

function freshState() {
    return {
        registry: new Map<number, Map<number, { x: number, y: number }>>(),
        seqCounter: new Map<number, number>(),
    }
}

describe('assignCloneIds', () => {
    it('first readback: clones of a parent get sequential ids in input order', () => {
        const { registry, seqCounter } = freshState()
        const ids = assignCloneIds(3, [{ x: 0, y: 0 }, { x: 50, y: 10 }, { x: -20, y: 40 }], registry, seqCounter)
        // Id scheme: -(k+1)*1000 - n for parent k=3 → -4001, -4002, -4003
        expect(ids).toEqual([-4001, -4002, -4003])
    })

    it('second readback: clones that moved a little keep their ids (stable identity)', () => {
        const { registry, seqCounter } = freshState()
        assignCloneIds(3, [{ x: 0, y: 0 }, { x: 50, y: 10 }], registry, seqCounter)
        // Same clones drifted ~2 units between readbacks (200 ms of motion).
        const ids = assignCloneIds(3, [{ x: 2, y: -1 }, { x: 48, y: 12 }], registry, seqCounter)
        expect(ids).toEqual([-4001, -4002])
    })

    it('a new clone gets the next sequence id while existing ones keep theirs', () => {
        const { registry, seqCounter } = freshState()
        assignCloneIds(0, [{ x: 0, y: 0 }], registry, seqCounter)
        // Parent 0 had one clone (-1001); now a second clone appears far away.
        const ids = assignCloneIds(0, [{ x: 1, y: 1 }, { x: 300, y: 300 }], registry, seqCounter)
        expect(ids).toEqual([-1001, -1002])
    })

    it('a dead clone is pruned; survivors keep their ids', () => {
        const { registry, seqCounter } = freshState()
        assignCloneIds(5, [{ x: 0, y: 0 }, { x: 100, y: 0 }, { x: 200, y: 0 }], registry, seqCounter)
        // Middle clone died; the other two remain.
        const ids = assignCloneIds(5, [{ x: 0, y: 0 }, { x: 200, y: 0 }], registry, seqCounter)
        expect(ids).toEqual([-6001, -6003])
    })

    it('two clones swapping positions keep their ids with their previous owners', () => {
        const { registry, seqCounter } = freshState()
        assignCloneIds(2, [{ x: 0, y: 0 }, { x: 10, y: 0 }], registry, seqCounter)
        // They passed each other: positions are now mirrored (each is closer to the
        // OTHER clone's old spot — greedy matching still pairs by nearest distance,
        // so ids follow the closest previous position).
        const ids = assignCloneIds(2, [{ x: 9.5, y: 0 }, { x: 0.5, y: 0 }], registry, seqCounter)
        expect(new Set(ids)).toEqual(new Set([-3001, -3002])) // both identities preserved
    })

    it('parents do not interfere with each other', () => {
        const { registry, seqCounter } = freshState()
        assignCloneIds(0, [{ x: 0, y: 0 }], registry, seqCounter)
        const ids = assignCloneIds(1, [{ x: 0, y: 0 }], registry, seqCounter) // same spot, different parent
        expect(ids).toEqual([-2001]) // fresh sequence for parent 1, not a match to parent 0's clone
    })

    it('never assigns the same id twice within one readback', () => {
        const { registry, seqCounter } = freshState()
        assignCloneIds(7, [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 2, y: 0 }], registry, seqCounter)
        // All three clones are almost on top of each other — the trickiest case.
        const ids = assignCloneIds(7, [{ x: 0.1, y: 0 }, { x: 0.2, y: 0 }, { x: 0.3, y: 0 }], registry, seqCounter)
        expect(new Set(ids).size).toBe(3)
    })
})

describe('pruneCloneRegistry', () => {
    it('drops state for parents with no live clones this readback', () => {
        const { registry, seqCounter } = freshState()
        assignCloneIds(0, [{ x: 0, y: 0 }], registry, seqCounter)
        assignCloneIds(4, [{ x: 0, y: 0 }], registry, seqCounter)
        pruneCloneRegistry(new Set([0]), registry, seqCounter) // only parent 0 has live clones
        expect(registry.has(0)).toBe(true)
        expect(registry.has(4)).toBe(false)
        expect(seqCounter.has(4)).toBe(false)
    })
})

describe('compareUrgeRows', () => {
    const original = (k: number) => ({ id: k })
    const clone = (cloneOf: number, cloneId: number) => ({ id: -((cloneOf + 1) * 1000 + cloneId), cloneOf, isClone: true, cloneId })

    it('groups by parent with the original before its clones', () => {
        const rows = [clone(3, 2), original(1), clone(3, 1), original(3)]
        const sorted = [...rows].sort(compareUrgeRows)
        expect(sorted.map(r => r.id)).toEqual([1, 3, -4001, -4002])
    })

    it('keeps a stable order when an unrelated clone is born elsewhere', () => {
        const before = [original(0), original(1), original(2)].sort(compareUrgeRows)
        // A clone of parent 2 appears — rows for 0 and 1 must not move.
        const after = [original(0), original(1), clone(2, 1), original(2)].sort(compareUrgeRows)
        expect(after.slice(0, before.length).map(r => r.id)).toEqual(before.map(r => r.id))
    })
})
