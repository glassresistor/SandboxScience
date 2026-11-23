// =============================================================================
// Brain Network × Particle Life — Evolutionary Prototype (optimized)
//
// Two-tier genome:
//   - DRIVES (slow): urge types with hardcoded changeability
//   - WIRING (fast): small recurrent network mapping urge errors → neuron modulation
//
// Run: node --experimental-strip-types brain.ts
// =============================================================================

const CFG = {
    width: 300, height: 300,
    numParticles: 300, numTypes: 4,
    dt: 1.0, friction: 0.9, forceFactor: 0.4,
    minR: 12, maxR: 45, repel: 1.0,

    numUrges: 20, urgeRadius: 40, urgeCohesion: 0.3,
    numNeurons: 60, neuronGroups: 8, neuronRadius: 35, neuronForce: 1.0,
    hiddenSize: 8,

    populationSize: 15, generations: 200, simTicksPerGen: 150, eliteCount: 3,

    wiringMutRate: 0.4, wiringMutSigma: 0.25,
    driveGainMutRate: 0.15, driveGainMutSigma: 0.1,
    driveParamMutBase: 0.005, driveParamMutSigma: 0.05,
    groupReassignRate: 0.03,

    fitnessRadius: 35,
} as const;

const H = CFG.hiddenSize;
const NU = CFG.numUrges;
const NN = CFG.numNeurons;
const G = CFG.neuronGroups;
const NP = CFG.numParticles;
const NS = NU + NN;
const NT = CFG.numTypes;

// --- Urge Type Definitions (species-level, hardcoded changeability) -----------
interface UrgeTypeDef { name: string; changeability: number; defaultTarget: number; defaultScale: number; minVal: number; maxVal: number }

const URGE_TYPES: UrgeTypeDef[] = [
    { name: 'hunger',    changeability: 0.02, defaultTarget: 1.0, defaultScale: 0.5, minVal: 0.3, maxVal: 2.0 },
    { name: 'thirst',    changeability: 0.03, defaultTarget: 0.8, defaultScale: 0.4, minVal: 0.2, maxVal: 1.5 },
    { name: 'safety',    changeability: 0.08, defaultTarget: 0.6, defaultScale: 0.3, minVal: 0.1, maxVal: 1.2 },
    { name: 'comfort',   changeability: 0.30, defaultTarget: 1.2, defaultScale: 0.6, minVal: 0.2, maxVal: 2.5 },
    { name: 'social',    changeability: 0.45, defaultTarget: 1.0, defaultScale: 0.5, minVal: 0.1, maxVal: 2.0 },
    { name: 'curiosity', changeability: 0.70, defaultTarget: 0.9, defaultScale: 0.4, minVal: 0.0, maxVal: 3.0 },
];

// --- Genome -------------------------------------------------------------------
interface DriveState { typeIdx: number; target: number; scale: number; gain: number }

interface Genome {
    drives: DriveState[];
    W_down: Float32Array;      // [H × NU]
    b_down: Float32Array;      // [H]
    W_recur: Float32Array;     // [H × H]
    groupWeights: Float32Array;// [G × H]
    neuronBiases: Float32Array;// [NN]
    neuronGroups: Uint8Array;  // [NN]
}

interface Individual { genome: Genome; fitness: number; hState: Float32Array }

// --- World (SoA) ---------------------------------------------------------------
class World {
    px = new Float32Array(NP); py = new Float32Array(NP);
    vx = new Float32Array(NP); vy = new Float32Array(NP);
    ptype = new Uint8Array(NP);

    sx = new Float32Array(NS); sy = new Float32Array(NS);
    svx = new Float32Array(NS); svy = new Float32Array(NS);
    scat = new Uint8Array(NS);

    urgeErrors = new Float32Array(NU);
    neuronMod = new Float32Array(NN);

    // Spatial hash
    cellSize: number; gridW: number; gridH: number;
    binHead: Int32Array; binNext: Int32Array;
    // Precomputed per-particle force accumulators
    fx = new Float32Array(NP); fy = new Float32Array(NP);

    constructor() {
        this.cellSize = CFG.maxR;
        this.gridW = Math.ceil(CFG.width / this.cellSize);
        this.gridH = Math.ceil(CFG.height / this.cellSize);
        this.binHead = new Int32Array(this.gridW * this.gridH);
        this.binNext = new Int32Array(NP + NS);
    }

    reset() {
        for (let i = 0; i < NP; i++) {
            this.px[i] = Math.random() * CFG.width;
            this.py[i] = Math.random() * CFG.height;
            this.vx[i] = 0; this.vy[i] = 0;
            this.ptype[i] = i % NT;
        }
        for (let i = 0; i < NS; i++) {
            this.sx[i] = Math.random() * CFG.width;
            this.sy[i] = Math.random() * CFG.height;
            this.svx[i] = 0; this.svy[i] = 0;
            this.scat[i] = i < NU ? 0 : 1;
        }
    }

    buildHash() {
        const { gridW, gridH, cellSize, binHead, binNext } = this;
        binHead.fill(-1);
        for (let i = 0; i < NP; i++) {
            const gx = Math.min(gridW - 1, Math.max(0, (this.px[i] / cellSize) | 0));
            const gy = Math.min(gridH - 1, Math.max(0, (this.py[i] / cellSize) | 0));
            const h = gy * gridW + gx;
            binNext[i] = binHead[h]; binHead[h] = i;
        }
        for (let i = 0; i < NS; i++) {
            const idx = NP + i;
            const gx = Math.min(gridW - 1, Math.max(0, (this.sx[i] / cellSize) | 0));
            const gy = Math.min(gridH - 1, Math.max(0, (this.sy[i] / cellSize) | 0));
            const h = gy * gridW + gx;
            binNext[idx] = binHead[h]; binHead[h] = idx;
        }
    }
}

// --- Interaction Matrix ---------------------------------------------------------
function makeRules(): Float32Array {
    const mat = new Float32Array(NT * NT);
    for (let i = 0; i < NT; i++)
        for (let j = 0; j < NT; j++)
            mat[i * NT + j] = (Math.random() * 2 - 1) * 0.8;
    return mat;
}

// --- Brain Step -----------------------------------------------------------------
function brainStep(ind: Individual, w: World): void {
    const g = ind.genome;
    const hs = ind.hState;

    // 1. Urge errors
    const area = CFG.width * CFG.height;
    const expectedCount = (NP / NT) * Math.PI * CFG.urgeRadius * CFG.urgeRadius / area;
    const r2 = CFG.urgeRadius * CFG.urgeRadius;

    for (let u = 0; u < NU; u++) {
        const drive = g.drives[u];
        const ux = w.sx[u], uy = w.sy[u];
        const targetColor = u % NT;
        let count = 0;

        // Inline neighbor scan for matter only
        const cs = w.cellSize, gw = w.gridW, gh = w.gridH;
        const minGX = Math.max(0, ((ux - CFG.urgeRadius) / cs) | 0);
        const maxGX = Math.min(gw - 1, ((ux + CFG.urgeRadius) / cs) | 0);
        const minGY = Math.max(0, ((uy - CFG.urgeRadius) / cs) | 0);
        const maxGY = Math.min(gh - 1, ((uy + CFG.urgeRadius) / cs) | 0);

        for (let gy = minGY; gy <= maxGY; gy++) {
            for (let gx = minGX; gx <= maxGX; gx++) {
                let idx = w.binHead[gy * gw + gx];
                while (idx !== -1) {
                    if (idx < NP && w.ptype[idx] === targetColor) {
                        const dx = w.px[idx] - ux, dy = w.py[idx] - uy;
                        if (dx * dx + dy * dy < r2) count++;
                    }
                    idx = w.binNext[idx];
                }
            }
        }

        const measured = count / Math.max(expectedCount, 0.1);
        const error = Math.max(-1, Math.min(1, (drive.target - measured) / drive.scale));
        w.urgeErrors[u] = error * drive.gain;
    }

    // 2. Hidden layer: h_new = tanh(W_down @ e + W_recur @ h_prev + b)
    const hNew = new Float32Array(H);
    for (let i = 0; i < H; i++) {
        let val = g.b_down[i];
        const rowOff = i * NU;
        for (let u = 0; u < NU; u++) val += g.W_down[rowOff + u] * w.urgeErrors[u];
        const recOff = i * H;
        for (let j = 0; j < H; j++) val += g.W_recur[recOff + j] * hs[j];
        hNew[i] = Math.tanh(val);
    }
    hs.set(hNew);

    // 3. Neuron modulation via group outputs
    const groupOut = new Float32Array(G);
    for (let gi = 0; gi < G; gi++) {
        let val = 0;
        const off = gi * H;
        for (let i = 0; i < H; i++) val += g.groupWeights[off + i] * hNew[i];
        groupOut[gi] = Math.tanh(val);
    }
    for (let n = 0; n < NN; n++) {
        w.neuronMod[n] = Math.max(-1, Math.min(1, groupOut[g.neuronGroups[n]] + g.neuronBiases[n]));
    }
}

// --- Physics Step (inlined hot loops) -------------------------------------------
function physicsStep(w: World, rules: Float32Array): void {
    const { width, height, friction, forceFactor, minR, maxR, repel } = CFG;
    w.buildHash();

    // Zero forces
    w.fx.fill(0); w.fy.fill(0);

    // Matter-matter
    const cs = w.cellSize, gw = w.gridW, gh = w.gridH;
    const maxR2 = maxR * maxR;
    const mid = (minR + maxR) * 0.5;
    const slopeDenom = mid - minR;

    for (let i = 0; i < NP; i++) {
        const xi = w.px[i], yi = w.py[i], ti = w.ptype[i];
        let fxi = 0, fyi = 0;

        const minGX = Math.max(0, ((xi - maxR) / cs) | 0);
        const maxGX = Math.min(gw - 1, ((xi + maxR) / cs) | 0);
        const minGY = Math.max(0, ((yi - maxR) / cs) | 0);
        const maxGY = Math.min(gh - 1, ((yi + maxR) / cs) | 0);

        for (let gy = minGY; gy <= maxGY; gy++) {
            for (let gx = minGX; gx <= maxGX; gx++) {
                let idx = w.binHead[gy * gw + gx];
                while (idx !== -1) {
                    if (idx < NP && idx !== i) {
                        const dx = w.px[idx] - xi, dy = w.py[idx] - yi;
                        const d2 = dx * dx + dy * dy;
                        if (d2 < maxR2 && d2 > 0.001) {
                            const dist = Math.sqrt(d2);
                            const tj = w.ptype[idx];
                            const rule = rules[ti * NT + tj];
                            let f: number;
                            if (dist < minR) {
                                f = (dist / minR - 1.0) * repel;
                            } else {
                                f = -(rule / slopeDenom) * Math.abs(dist - mid) + rule;
                            }
                            const invD = 1 / dist;
                            fxi += dx * invD * f;
                            fyi += dy * invD * f;
                        }
                    }
                    idx = w.binNext[idx];
                }
            }
        }
        w.fx[i] = fxi; w.fy[i] = fyi;
    }

    // Neuron actuation on matter
    for (let n = 0; n < NN; n++) {
        const si = NU + n;
        const nx = w.sx[si], ny = w.sy[si];
        const mod = w.neuronMod[n];
        if (mod > -0.01 && mod < 0.01) continue;

        const targetColor = n % NT;
        const nr = CFG.neuronRadius, nr2 = nr * nr;

        const minGX = Math.max(0, ((nx - nr) / cs) | 0);
        const maxGX = Math.min(gw - 1, ((nx + nr) / cs) | 0);
        const minGY = Math.max(0, ((ny - nr) / cs) | 0);
        const maxGY = Math.min(gh - 1, ((ny + nr) / cs) | 0);

        for (let gy = minGY; gy <= maxGY; gy++) {
            for (let gx = minGX; gx <= maxGX; gx++) {
                let idx = w.binHead[gy * gw + gx];
                while (idx !== -1) {
                    if (idx < NP && w.ptype[idx] === targetColor) {
                        const dx = w.px[idx] - nx, dy = w.py[idx] - ny;
                        const d2 = dx * dx + dy * dy;
                        if (d2 < nr2 && d2 > 0.001) {
                            const dist = Math.sqrt(d2);
                            const fall = 1 - dist / nr;
                            const f = mod * CFG.neuronForce * fall;
                            const invD = 1 / dist;
                            w.fx[idx] += dx * invD * f;
                            w.fy[idx] += dy * invD * f;
                        }
                    }
                    idx = w.binNext[idx];
                }
            }
        }
    }

    // Integrate matter
    for (let i = 0; i < NP; i++) {
        w.vx[i] = (w.vx[i] + w.fx[i] * forceFactor) * friction;
        w.vy[i] = (w.vy[i] + w.fy[i] * forceFactor) * friction;
        w.px[i] += w.vx[i];
        w.py[i] += w.vy[i];
        if (w.px[i] < 0) w.px[i] += width; else if (w.px[i] >= width) w.px[i] -= width;
        if (w.py[i] < 0) w.py[i] += height; else if (w.py[i] >= height) w.py[i] -= height;
    }

    // Special particles: cohesion to matter + mutual repulsion
    const cohR = CFG.urgeRadius * 0.7, cohR2 = cohR * cohR;
    for (let i = 0; i < NS; i++) {
        const xi = w.sx[i], yi = w.sy[i];
        let cx = 0, cy = 0;

        // Cohesion toward matter
        const minGX = Math.max(0, ((xi - cohR) / cs) | 0);
        const maxGX = Math.min(gw - 1, ((xi + cohR) / cs) | 0);
        const minGY = Math.max(0, ((yi - cohR) / cs) | 0);
        const maxGY = Math.min(gh - 1, ((yi + cohR) / cs) | 0);

        for (let gy = minGY; gy <= maxGY; gy++) {
            for (let gx = minGX; gx <= maxGX; gx++) {
                let idx = w.binHead[gy * gw + gx];
                while (idx !== -1) {
                    if (idx < NP) {
                        const dx = w.px[idx] - xi, dy = w.py[idx] - yi;
                        const d2 = dx * dx + dy * dy;
                        if (d2 < cohR2 && d2 > 0.01) {
                            const d = Math.sqrt(d2);
                            const fall = 1 - d / cohR;
                            cx += dx / d * fall;
                            cy += dy / d * fall;
                        }
                    }
                    idx = w.binNext[idx];
                }
            }
        }

        // Anti-overlap with other specials (brute force, NS is small)
        for (let j = 0; j < NS; j++) {
            if (j === i) continue;
            const dx = w.sx[j] - xi, dy = w.sy[j] - yi;
            const d2 = dx * dx + dy * dy;
            if (d2 < 64 && d2 > 0.01) {
                const d = Math.sqrt(d2);
                cx -= dx / d * 0.8;
                cy -= dy / d * 0.8;
            }
        }

        w.svx[i] = (w.svx[i] + cx * CFG.urgeCohesion * 0.1) * friction;
        w.svy[i] = (w.svy[i] + cy * CFG.urgeCohesion * 0.1) * friction;
        w.sx[i] += w.svx[i]; w.sy[i] += w.svy[i];
        if (w.sx[i] < 0) w.sx[i] += width; else if (w.sx[i] >= width) w.sx[i] -= width;
        if (w.sy[i] < 0) w.sy[i] += height; else if (w.sy[i] >= height) w.sy[i] -= height;
    }
}

// --- Fitness --------------------------------------------------------------------
function computeFitness(w: World): number {
    w.buildHash();
    const r = CFG.fitnessRadius, r2 = r * r;
    const cs = w.cellSize, gw = w.gridW, gh = w.gridH;
    let totalScore = 0;

    for (let i = 0; i < NP; i++) {
        const xi = w.px[i], yi = w.py[i], ti = w.ptype[i];
        let sameType = 0, total = 0;

        const minGX = Math.max(0, ((xi - r) / cs) | 0);
        const maxGX = Math.min(gw - 1, ((xi + r) / cs) | 0);
        const minGY = Math.max(0, ((yi - r) / cs) | 0);
        const maxGY = Math.min(gh - 1, ((yi + r) / cs) | 0);

        for (let gy = minGY; gy <= maxGY; gy++) {
            for (let gx = minGX; gx <= maxGX; gx++) {
                let idx = w.binHead[gy * gw + gx];
                while (idx !== -1) {
                    if (idx < NP && idx !== i) {
                        const dx = w.px[idx] - xi, dy = w.py[idx] - yi;
                        if (dx * dx + dy * dy < r2) {
                            total++;
                            if (w.ptype[idx] === ti) sameType++;
                        }
                    }
                    idx = w.binNext[idx];
                }
            }
        }

        if (total > 0) totalScore += sameType / total;
    }
    return totalScore / NP;
}

// --- Genome Ops -----------------------------------------------------------------
function randomGenome(): Genome {
    const drives: DriveState[] = [];
    for (let u = 0; u < NU; u++) {
        const typeIdx = u % URGE_TYPES.length;
        const def = URGE_TYPES[typeIdx];
        drives.push({
            typeIdx,
            target: def.defaultTarget + (Math.random() - 0.5) * 0.1,
            scale: def.defaultScale,
            gain: 0.5 + Math.random() * 0.5,
        });
    }
    return {
        drives,
        W_down: Float32Array.from({ length: H * NU }, () => (Math.random() - 0.5) * 0.6),
        b_down: new Float32Array(H),
        W_recur: Float32Array.from({ length: H * H }, () => (Math.random() - 0.5) * 0.1),
        groupWeights: Float32Array.from({ length: G * H }, () => (Math.random() - 0.5) * 0.6),
        neuronBiases: Float32Array.from({ length: NN }, () => (Math.random() - 0.5) * 0.3),
        neuronGroups: Uint8Array.from({ length: NN }, () => (Math.random() * G) | 0),
    };
}

function cloneGenome(g: Genome): Genome {
    return {
        drives: g.drives.map(d => ({ ...d })),
        W_down: new Float32Array(g.W_down),
        b_down: new Float32Array(g.b_down),
        W_recur: new Float32Array(g.W_recur),
        groupWeights: new Float32Array(g.groupWeights),
        neuronBiases: new Float32Array(g.neuronBiases),
        neuronGroups: new Uint8Array(g.neuronGroups),
    };
}

function gauss(): number {
    let u = 0, v = 0;
    while (u === 0) u = Math.random();
    while (v === 0) v = Math.random();
    return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v);
}

function mutateGenome(g: Genome): void {
    // FAST tier: wiring
    for (let i = 0; i < H * NU; i++)
        if (Math.random() < CFG.wiringMutRate) g.W_down[i] += gauss() * CFG.wiringMutSigma;
    for (let i = 0; i < H; i++)
        if (Math.random() < CFG.wiringMutRate) g.b_down[i] += gauss() * CFG.wiringMutSigma * 0.5;
    for (let i = 0; i < H * H; i++)
        if (Math.random() < CFG.wiringMutRate * 1.5) g.W_recur[i] += gauss() * CFG.wiringMutSigma * 0.8;
    for (let i = 0; i < G * H; i++)
        if (Math.random() < CFG.wiringMutRate) g.groupWeights[i] += gauss() * CFG.wiringMutSigma;
    for (let i = 0; i < NN; i++)
        if (Math.random() < CFG.wiringMutRate * 0.5) g.neuronBiases[i] += gauss() * CFG.wiringMutSigma * 0.3;
    for (let i = 0; i < NN; i++)
        if (Math.random() < CFG.groupReassignRate) g.neuronGroups[i] = (Math.random() * G) | 0;

    // SLOW tier: drives
    for (let u = 0; u < NU; u++) {
        if (Math.random() < CFG.driveGainMutRate) {
            g.drives[u].gain += gauss() * CFG.driveGainMutSigma;
            g.drives[u].gain = Math.max(0, Math.min(2.0, g.drives[u].gain));
        }
        const def = URGE_TYPES[g.drives[u].typeIdx];
        const rate = CFG.driveParamMutBase * def.changeability;
        if (Math.random() < rate) {
            g.drives[u].target += gauss() * CFG.driveParamMutSigma;
            g.drives[u].target = Math.max(def.minVal, Math.min(def.maxVal, g.drives[u].target));
        }
        if (Math.random() < rate * 0.5) {
            g.drives[u].scale *= 1 + gauss() * CFG.driveParamMutSigma;
            g.drives[u].scale = Math.max(0.1, Math.min(3.0, g.drives[u].scale));
        }
    }
}

// --- Evaluation -----------------------------------------------------------------
function evaluate(ind: Individual, rules: Float32Array): number {
    const w = new World();
    w.reset();
    ind.hState.fill(0);
    for (let t = 0; t < CFG.simTicksPerGen; t++) {
        brainStep(ind, w);
        physicsStep(w, rules);
    }
    return computeFitness(w);
}

// --- Evolution ------------------------------------------------------------------
function evolve(): void {
    const t0 = performance.now();
    console.log('=== Brain × Particle Life — Evolutionary Prototype ===');
    console.log(`${NP} particles, ${NT} types | ${NU} urges, ${NN} neurons | H=${H}, G=${G}`);
    console.log(`Pop: ${CFG.populationSize}, Gens: ${CFG.generations}, Ticks/gen: ${CFG.simTicksPerGen}`);
    console.log('');

    const rules = makeRules();
    const pop: Individual[] = [];
    for (let i = 0; i < CFG.populationSize; i++)
        pop.push({ genome: randomGenome(), fitness: 0, hState: new Float32Array(H) });

    // Gen 0
    for (let i = 0; i < CFG.populationSize; i++)
        pop[i].fitness = evaluate(pop[i], rules);

    let bestEver = 0;
    const history: number[] = [];

    for (let gen = 0; gen < CFG.generations; gen++) {
        pop.sort((a, b) => b.fitness - a.fitness);
        const best = pop[0].fitness;
        const mean = pop.reduce((s, p) => s + p.fitness, 0) / pop.length;
        bestEver = Math.max(bestEver, best);
        history.push(mean);

        if (gen % 20 === 0 || gen === CFG.generations - 1) {
            const elapsed = ((performance.now() - t0) / 1000).toFixed(1);
            console.log(`Gen ${String(gen).padStart(3)} | best: ${best.toFixed(4)} | mean: ${mean.toFixed(4)} | bestEver: ${bestEver.toFixed(4)} | ${elapsed}s`);
        }

        // Reproduction
        const nextPop: Individual[] = [];
        for (let i = 0; i < CFG.eliteCount && i < pop.length; i++)
            nextPop.push({ genome: cloneGenome(pop[i].genome), fitness: 0, hState: new Float32Array(H) });

        while (nextPop.length < CFG.populationSize) {
            let bestIdx = 0, bestFit = -Infinity;
            for (let t = 0; t < 3; t++) {
                const idx = (Math.random() * pop.length) | 0;
                if (pop[idx].fitness > bestFit) { bestFit = pop[idx].fitness; bestIdx = idx; }
            }
            const cg = cloneGenome(pop[bestIdx].genome);
            mutateGenome(cg);
            nextPop.push({ genome: cg, fitness: 0, hState: new Float32Array(H) });
        }

        for (let i = 0; i < nextPop.length; i++)
            nextPop[i].fitness = evaluate(nextPop[i], rules);

        pop.length = 0;
        pop.push(...nextPop);
    }

    const elapsed = ((performance.now() - t0) / 1000).toFixed(1);
    console.log('');
    console.log(`=== Done in ${elapsed}s ===`);
    console.log(`Final best: ${bestEver.toFixed(4)}`);
    console.log(`Mean (last 20 gens): ${(history.slice(-20).reduce((a, b) => a + b, 0) / Math.min(20, history.length)).toFixed(4)}`);

    // Best genome stats
    const best = [...pop].sort((a, b) => b.fitness - a.fitness)[0];
    const g = best.genome;
    console.log('');
    console.log('--- Best Genome ---');
    console.log(`|W_down| mean: ${(g.W_down.reduce((a, b) => a + Math.abs(b), 0) / g.W_down.length).toFixed(4)}`);
    console.log(`|W_recur| mean: ${(g.W_recur.reduce((a, b) => a + Math.abs(b), 0) / g.W_recur.length).toFixed(4)}`);
    console.log(`Drive gain mean: ${(g.drives.reduce((a, d) => a + d.gain, 0) / NU).toFixed(4)}`);
    const groupUsage = new Array(G).fill(0);
    for (let i = 0; i < NN; i++) groupUsage[g.neuronGroups[i]]++;
    console.log(`Groups used: ${groupUsage.filter(x => x > 0).length}/${G} → [${groupUsage.join(',')}]`);

    // Drive targets vs defaults
    console.log('');
    console.log('--- Drive Drift (target: initial → final) ---');
    for (let t = 0; t < URGE_TYPES.length; t++) {
        const def = URGE_TYPES[t];
        const ds = g.drives.filter(d => d.typeIdx === t);
        if (ds.length > 0) {
            const avgTarget = ds.reduce((a, d) => a + d.target, 0) / ds.length;
            const drift = avgTarget - def.defaultTarget;
            console.log(`  ${def.name.padEnd(10)} (ch=${def.changeability.toFixed(2)}): ${def.defaultTarget.toFixed(3)} → ${avgTarget.toFixed(3)} (Δ=${drift >= 0 ? '+' : ''}${drift.toFixed(4)})`);
        }
    }
}

evolve();
