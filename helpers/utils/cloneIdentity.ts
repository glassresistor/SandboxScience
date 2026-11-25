// ---------------------------------------------------------------------------
// Stable clone identity for the Urge Inspector (pure logic, no Vue/WebGPU imports).
//
// Clones have no persistent GPU-side id — a dormant-pool slot re-labeled with a
// fractional type tag. We therefore match each live clone to its previous-readback
// identity by NEAREST POSITION: clones move continuously, so at 200 ms apart they
// can't teleport past each other. This gives every clone a STABLE UNIQUE id:
//   - every clone keeps its own tracking card (old bug: siblings shared one id and
//     the dedup filter silently dropped all but one of them), and
//   - rows don't jump around when siblings are born or die.
// Id scheme: originals = k; clones of parent k = -(k+1)*1000 - n (n = 1,2,3,... per parent).
// ---------------------------------------------------------------------------

export interface ClonePosition {
    x: number
    y: number
}

/**
 * Greedy nearest-neighbor matching of this readback's clones (of parent `k`) to their
 * known identities from previous readbacks.
 *
 * - `registry` maps parentK -> cloneDisplayId -> last known position. It is pruned and
 *   refreshed for parent `k` in place (unmatched old ids are dropped, new positions stored).
 * - `seqCounter` maps parentK -> next clone sequence number (also updated in place).
 *
 * Returns the display id for each input position, in input order.
 */
export function assignCloneIds(
    k: number,
    positions: ClonePosition[],
    registry: Map<number, Map<number, ClonePosition>>,
    seqCounter: Map<number, number>,
): number[] {
    const reg = registry.get(k) ?? new Map<number, ClonePosition>()
    const nextId = (): number => {
        const n = seqCounter.get(k) ?? 1
        seqCounter.set(k, n + 1)
        return -((k + 1) * 1000 + n)
    }

    // Closest (clone, known-id) pairs first; each side is claimed only once.
    const pairs: { ci: number, oid: number, d2: number }[] = []
    for (let i = 0; i < positions.length; i++) {
        for (const [oid, opos] of reg.entries()) {
            const dx = positions[i].x - opos.x
            const dy = positions[i].y - opos.y
            pairs.push({ ci: i, oid, d2: dx * dx + dy * dy })
        }
    }
    pairs.sort((a, b) => a.d2 - b.d2)

    const ids: number[] = new Array(positions.length).fill(-1) // -1 = not yet matched
    const freeOld = new Set(reg.keys())
    for (const p of pairs) {
        if (ids[p.ci] !== -1 || !freeOld.has(p.oid))
            continue
        ids[p.ci] = p.oid
        freeOld.delete(p.oid)
    }

    // Unmatched clones get a fresh id; unmatched old ids fall out of the new registry.
    const nextReg = new Map<number, ClonePosition>()
    for (let i = 0; i < positions.length; i++) {
        if (ids[i] === -1)
            ids[i] = nextId()
        nextReg.set(ids[i], { x: positions[i].x, y: positions[i].y })
    }
    registry.set(k, nextReg)
    return ids
}

/** Drop registry/sequence entries for parents that have no live clones this readback. */
export function pruneCloneRegistry(
    activeParents: Set<number>,
    registry: Map<number, Map<number, ClonePosition>>,
    seqCounter: Map<number, number>,
): void {
    for (const k of [...registry.keys()]) {
        if (!activeParents.has(k)) {
            registry.delete(k)
            seqCounter.delete(k)
        }
    }
}

export interface UrgeRowLike {
    id: number
    cloneOf?: number
    isClone?: boolean
    cloneId?: number
}

/**
 * Stable row order for the inspector list: group by parent (original + its clones
 * together), original first, then clones in birth order. Rows only move when their own
 * urge dies — never when an unrelated clone is born elsewhere.
 */
export function compareUrgeRows(a: UrgeRowLike, b: UrgeRowLike): number {
    const pa = a.cloneOf ?? a.id
    const pb = b.cloneOf ?? b.id
    if (pa !== pb)
        return pa - pb
    const ca = a.isClone && a.cloneId !== undefined ? a.cloneId : 0
    const cb = b.isClone && b.cloneId !== undefined ? b.cloneId : 0
    return ca - cb
}
