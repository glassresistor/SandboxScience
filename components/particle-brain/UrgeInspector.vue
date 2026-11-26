<template>
    <div class="flex flex-col gap-2">
        <!-- Empty / disabled state -->
        <div v-if="!stats.length" class="rounded-lg bg-slate-800/40 p-3 text-center ring-1 ring-slate-600/40">
            <p class="text-2sm text-zinc-300">
                No urges to inspect.
            </p>
            <p class="mt-1 text-2sm text-zinc-500">
                Enable the <b>Quantum / Electrical</b> layer and set a non-zero
                <b>Urge Count</b> to see live per-urge telemetry.
            </p>
        </div>

        <template v-else>
            <!-- ============ GLOBAL PARAMETER CARD ============ -->
            <div class="rounded-lg bg-slate-800/40 p-2 ring-1 ring-cyan-500/30">
                <div class="mb-1.5 flex items-center gap-2">
                    <span class="i-tabler-settings text-cyan-400" />
                    <p class="text-2sm text-cyan-200 font-semibold">
                        Global electrical parameters
                    </p>
                    <span class="ml-auto rounded bg-cyan-500/15 px-1.5 py-0.5 text-[0.6rem] text-cyan-300 tracking-wide font-mono uppercase ring-1 ring-cyan-500/40">shared</span>
                </div>
                <p class="mb-2 text-[0.72rem] text-zinc-400 leading-snug">
                    These knobs apply to <b>every</b> brain &amp; neuron at once. The per-brain cards below show
                    each brain’s live <span class="text-emerald-300">net output</span>, its neural-net shape, and the
                    <span class="text-amber-300">metric vs setpoint</span> for every genome need.
                </p>
                <ul class="flex flex-col gap-1">
                    <li
                        v-for="meta in paramMeta" :key="meta.key"
                        class="rounded bg-slate-900/40 px-2 py-1 ring-1 ring-slate-700/40"
                    >
                        <div class="flex items-center justify-between gap-2">
                            <span class="text-2sm text-zinc-200">{{ meta.label }}</span>
                            <span class="shrink-0 text-2sm text-cyan-300 font-mono tabular-nums">{{ displayValue(meta) }}</span>
                        </div>
                        <p class="mt-0.5 text-[0.7rem] text-zinc-500 leading-snug">
                            {{ meta.desc }}
                        </p>
                    </li>
                </ul>
            </div>

            <!-- ============ PER-URGE LIVE LIST ============ -->
            <div class="rounded-lg bg-slate-800/40 p-2 ring-1 ring-slate-600/40">
                <div class="mb-1.5 flex items-center gap-2">
                    <span class="i-tabler-list-details text-emerald-400" />
                    <p class="text-2sm text-emerald-200 font-semibold">
                        Per-urge live state
                    </p>
                    <span class="ml-auto rounded bg-emerald-500/15 px-1.5 py-0.5 text-[0.6rem] text-emerald-300 tracking-wide font-mono uppercase ring-1 ring-emerald-500/40">
                        {{ stats.length }} cards · {{ cloneCount }} clones
                    </span>
                </div>
                <p class="mb-2 text-[0.72rem] text-zinc-400 leading-snug">
                    One tracking card per live brain — every clone gets its own card (grouped under its parent,
                    e.g. <span class="text-violet-300 font-mono">#3-C1</span>), and rows keep their place as clones
                    are born or die. The <span class="text-emerald-300">net output</span> bar is the brain’s real drive to its
                    motor neurons (centred at 0: <span class="text-rose-300">left = repel</span>,
                    <span class="text-emerald-300">right = attract</span>); the table below it shows each need’s live metric against its setpoint.<br>
                    <span class="text-sky-300">Click a row to track that brain on the canvas.</span>
                </p>

                <ul class="flex flex-col gap-1.5">
                    <li
                        v-for="s in stats" :key="s.id"
                        class="cursor-pointer rounded bg-slate-900/50 px-2 py-1.5 ring-1 transition-all"
                        :class="selectedId === s.id ? 'ring-2 ring-sky-400/80 bg-sky-500/10' : 'ring-slate-700/40 hover:ring-slate-500/60'"
                        @click="select(s.id)"
                    >
                        <!-- objective (stable) + identity -->
                        <div class="flex items-center gap-2">
                            <span
                                class="h-3.5 w-3.5 shrink-0 rounded-full ring-1 ring-white/40"
                                :style="{ backgroundColor: colorFor(s.targetColor) }"
                            />
                            <!-- Clone rows show their lineage label (e.g. #3-C1) in violet; originals show #k -->
                            <span v-if="s.isClone && s.cloneOf !== undefined" class="text-2sm text-violet-300 font-semibold font-mono">#{{ s.cloneOf }}-C{{ s.cloneId ?? 1 }}</span>
                            <span v-else class="text-2sm text-zinc-100 font-mono">#{{ s.id }}</span>
                            <!-- Lineage badge for clones: "from #k" -->
                            <span
                                v-if="s.isClone && s.cloneOf !== undefined"
                                class="rounded bg-violet-500/15 px-1.5 py-0.5 text-[0.62rem] text-violet-300 font-mono ring-1 ring-violet-500/40" title="Clone of this urge"
                            >
                                from #{{ s.cloneOf }}
                            </span>
                            <span v-if="selectedId === s.id" class="i-tabler-crosshair shrink-0 text-sky-400" title="Tracking on canvas" />
                            <!-- Neuron breakdown: muscles (motor) + senses (eyes/ears/nose) -->
                            <span
                                v-if="s.wiredMuscles !== undefined || s.wiredEyes !== undefined"
                                class="ml-auto flex items-center gap-1.5 rounded bg-fuchsia-500/10 px-1.5 py-0.5 text-[0.68rem] font-mono ring-1 ring-fuchsia-500/30"
                            >
                                <span v-if="(s.wiredMuscles ?? 0) > 0" class="flex items-center gap-0.5 text-fuchsia-200" title="Motor neurons (muscles) within neuronRadius">
                                    <span class="i-tabler-bolt" />{{ s.wiredMuscles }}
                                </span>
                                <span v-if="(s.wiredEyes ?? 0) > 0" class="flex items-center gap-0.5 text-sky-300" title="Sight neurons (eyes) within senseRadius">
                                    <span class="i-tabler-eye" />{{ s.wiredEyes }}
                                </span>
                                <span v-if="(s.wiredEars ?? 0) > 0" class="flex items-center gap-0.5 text-violet-300" title="Sound neurons (ears) within senseRadius">
                                    <span class="i-tabler-ear" />{{ s.wiredEars }}
                                </span>
                                <span v-if="(s.wiredNose ?? 0) > 0" class="flex items-center gap-0.5 text-emerald-300" title="Smell neurons (nose) within senseRadius">
                                    <span class="i-carbon-smell" />{{ s.wiredNose }}
                                </span>
                                <span v-if="!(s.wiredMuscles ?? 0) && !(s.wiredEyes ?? 0) && !(s.wiredEars ?? 0) && !(s.wiredNose ?? 0)" class="text-fuchsia-300/50">—</span>
                            </span>
                        </div>

                        <!-- objective (live): homeostasis + how many needs are met right now -->
                        <div class="mt-1">
                            <p v-if="s.brain" class="flex items-center gap-1.5 text-[0.74rem] leading-tight">
                                <span class="i-tabler-target shrink-0 text-amber-400" />
                                <span class="text-zinc-200">Homeostasis</span>
                                <span
                                    class="rounded px-1 py-px font-mono ring-1"
                                    :class="metBadgeClass(s.brain)"
                                    :title="`${s.brain.metNeeds} of ${s.brain.needs.length} needs currently inside their target band`"
                                >
                                    {{ s.brain.metNeeds }}/{{ s.brain.needs.length }} met
                                </span>
                            </p>
                            <p v-else class="flex items-center gap-1.5 text-[0.74rem] text-zinc-200 leading-tight">
                                <span class="i-tabler-target shrink-0 text-amber-400" />
                                <span>{{ objectiveLabelFor(s.cloneOf ?? s.id) }}</span>
                            </p>
                        </div>

                        <!-- actuation: how hard the brain is pushing its muscles right now (peak |drive|, 0..1) -->
                        <div class="mt-1.5 flex items-center gap-2">
                            <span class="w-14 shrink-0 text-[0.68rem] text-zinc-400" title="Strongest motor-neuron drive right now (|drive|, 0..1). The mean across colors cancels out, so we show the peak.">Actuation</span>
                            <div class="relative h-2 flex-1 overflow-hidden rounded-full bg-slate-700/70">
                                <div class="absolute bottom-0 left-0 top-0 rounded-full bg-emerald-500/80" :style="{ width: actFill(s.control) }" />
                            </div>
                            <span class="w-14 shrink-0 text-right text-[0.72rem] text-emerald-300 font-mono tabular-nums">{{ fmt(s.control) }}</span>
                            <span v-if="s.brain" class="w-auto flex shrink-0 items-center gap-0.5 text-[0.68rem] text-fuchsia-200 font-mono" :title="`${s.brain.activeMuscles} of ${s.brain.M} motor neurons firing (|drive| > 0.1)`">
                                <span class="i-tabler-bolt inline-block align-middle" />{{ s.brain.activeMuscles }}/{{ s.brain.M }}
                            </span>
                            <span v-if="s.trendControl > TREND_EPS || s.trendControl < -TREND_EPS" class="w-4 shrink-0 text-center" title="Δ actuation vs previous readback">
                                <span v-if="s.trendControl > TREND_EPS" class="i-tabler-arrow-up text-emerald-400" />
                                <span v-else class="i-tabler-arrow-down text-rose-400" />
                            </span>
                        </div>

                        <!-- neural network summary (accurate, from genome + ownership buffers) -->
                        <div v-if="s.brain" class="mt-1.5 flex flex-wrap items-center gap-x-2 gap-y-1 rounded bg-fuchsia-500/5 px-1.5 py-1 text-[0.68rem] font-mono tabular-nums ring-1 ring-fuchsia-500/20">
                            <span class="flex items-center gap-1 text-fuchsia-200" title="Net shape: sense inputs × hidden units × motor outputs; ×N means N hidden layers">
                                <span class="i-tabler-brain shrink-0 text-fuchsia-300" />{{ s.brain.S }}·{{ s.brain.H }}·{{ s.brain.M }}{{ s.brain.depth > 1 ? `×${s.brain.depth}` : '' }}
                            </span>
                            <span class="text-zinc-600">|</span>
                            <span class="flex items-center gap-1 text-indigo-200" title="Teaching signal: mean of the K need errors — drives delta-rule learning">
                                teach {{ fmt(s.brain.teach, 3) }}
                            </span>
                            <span class="text-zinc-600">|</span>
                            <span class="flex items-center gap-1 text-sky-200" title="Weights: strong (|w|>0.5) over total, and max magnitude (clamped at ±2). Grows as the net learns.">
                                w {{ s.brain.strongWeights }}/{{ s.brain.usedWeights }} · max {{ fmt(s.brain.weightMaxAbs, 2) }}
                            </span>
                        </div>

                        <!-- per-need live table: each genome need's target color vs its setpoint -->
                        <div v-if="s.brain" class="mt-1.5">
                            <p class="mb-1 text-[0.62rem] text-zinc-500 leading-snug">
                                <span class="tracking-wide font-mono uppercase">Needs</span>
                                <span class="ml-1">— needle = live density, green band = target zone (setpoint ± scale). Needle in the band = need met.</span>
                            </p>
                            <ul class="flex flex-col gap-0.5">
                                <li v-for="(n, i) in s.brain.needs" :key="i" class="flex items-center gap-1.5 text-[0.68rem] font-mono tabular-nums">
                                    <span class="h-2.5 w-2.5 shrink-0 rounded-full ring-1 ring-white/30" :style="{ backgroundColor: colorFor(n.targetColor) }" />
                                    <span class="w-7 shrink-0 text-zinc-400">C{{ n.targetColor + 1 }}</span>
                                    <!-- homeostasis gauge: green band = target zone (setpoint ± scale),
                                         white line = exact setpoint, needle = live metric -->
                                    <div
                                        class="relative h-2.5 flex-1 overflow-hidden rounded-full bg-slate-700/70"
                                        :title="`metric ${fmt(n.metric)} · target ${fmt(n.setpoint)} ± ${fmt(n.scale)}`"
                                    >
                                        <div class="absolute bottom-0 top-0 bg-emerald-400/15 ring-1 ring-emerald-400/30 ring-inset" :style="{ left: bandLeft(n, cardCap(s.brain)), width: bandWidth(n, cardCap(s.brain)) }" />
                                        <div class="absolute bottom-0 top-0 w-px bg-white/70" :style="{ left: pct(n.setpoint, cardCap(s.brain)) }" title="setpoint" />
                                        <div class="absolute top-1/2 h-3.5 w-[3px] rounded-full ring-1 ring-black/50 -translate-x-1/2 -translate-y-1/2" :class="needleClass(n)" :style="{ left: metricPos(n, cardCap(s.brain)) }" title="live metric" />
                                    </div>
                                    <span class="w-12 shrink-0 text-right text-zinc-300">{{ fmt(n.metric) }}</span>
                                    <span class="w-16 shrink-0 text-right" :class="needErrClass(n)" title="error = clamp((setpoint − metric)/scale, ±1) × gain — + wants more of this color, − has too much">
                                        {{ n.error >= 0 ? '+' : '−' }}{{ fmt(Math.abs(n.error), 2) }}
                                    </span>
                                </li>
                            </ul>
                        </div>

                        <!-- fallback: no genome/net buffers for this renderer (CPU), or first GPU tick -->
                        <p v-else class="mt-1.5 text-[0.68rem] text-zinc-500">
                            No neural-net telemetry available.
                        </p>
                    </li>
                </ul>
            </div>
        </template>
    </div>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'

// One genome need of a brain, with its LIVE metric read back from the GPU.
// targetColor = which matter color this need wants; setpoint/scale/gain are the homeostasis
// parameters (mutate slowly via brainMutate); metric is the current normalized density of that
// color near the brain (written by brainStep each frame); error is the teaching contribution.
export interface NeedStat {
    targetColor: number // matter color index this need wants (0..numTypes-1)
    setpoint: number // homeostasis target for the metric (normalized density)
    scale: number // error normalisation — smaller = more sensitive to deviation
    gain: number // weight of this need's error into the teaching signal
    metric: number // LIVE normalized density of targetColor within urgeRadius of the brain
    error: number // clamp((setpoint - metric) / scale, ±1) * gain  (mirrors brainStep)
}

// A full per-brain neural-network snapshot, read back from the real GPU buffers
// (genome + neuronMods + brainMetrics + ownership). Accurate source of truth.
export interface BrainNet {
    S: number // sense neurons owned → net inputs
    M: number // motor neurons owned → net outputs
    H: number // hidden units (mirrors brainStep.wgsl shape)
    depth: number // 1 or 2 hidden layers
    meanDrive: number // mean signed net output across owned motor neurons (can cancel to ~0)
    maxAbsDrive: number // strongest |drive| among owned motor neurons (peak actuation, 0..1)
    activeMuscles: number // count of owned motor neurons firing (|drive| > 0.1)
    teach: number // scalar teaching signal = mean of the K need errors
    metNeeds: number // count of needs whose live metric is inside their target band (homeostasis met)
    meanMetric: number // mean of the K live need metrics (aggregate activity)
    usedWeights: number // total weights in the net (S*H + H [+H*H+H] + H*M + M)
    strongWeights: number // count of |w| > 0.5 (net has learned structure)
    weightMaxAbs: number // max |w| across used weights (clamped at ±2 by the shader)
    needs: NeedStat[] // the K genome needs with live metrics
}

// A single brain's live telemetry, read back from the GPU a few times per second.
export interface UrgeStat {
    id: number // local urge index k (originals) or stable negative id (clones)
    type: number // NUM_TYPES + k (the particle type code, always the parent's)
    targetColor: number // k % NUM_TYPES (representative matter color for the dot)
    control: number // signed net output [-1, 1] (meanDrive) — real brain→muscle drive
    signal: number // aggregate live metric (mean of the K need metrics)
    trendControl: number // control - prevControl (0 if no prior readback)
    trendSignal?: number // signal - prevSignal (0/undefined if no prior readback)
    wiredNeurons?: number // optional: total neurons within radius of this brain
    wiredMuscles?: number // motor neurons within neuronRadius ("muscles")
    wiredEyes?: number // sense neurons with mode=sight within senseRadius ("eyes")
    wiredEars?: number // sense neurons with mode=sound within senseRadius ("ears")
    wiredNose?: number // sense neurons with mode=smell within senseRadius ("nose")
    isClone?: boolean // true if this row represents a clone particle
    cloneOf?: number // parent urge k (only set when isClone)
    cloneId?: number // per-parent sequential clone number (1 = first clone of that parent)
    brain?: BrainNet // accurate per-brain neural-network data (clones share their parent's)
}

// Snapshot of the ACTIVE global parameters that apply to every brain/neuron.
// brainGain/brainLearnRate are optional: the legacy CPU renderer has no brain net,
// so it omits them (the card shows "—" for those two).
export interface ElectricalParams {
    brainGain?: number // global net output gain — scales neuronMods into motor force
    brainLearnRate?: number // delta-rule learning rate for brain weights (0 = frozen)
    urgeRadius: number // radius a brain measures its metric & a neuron pushes/pulls its color
    neuronRadius: number // capture radius: within it a brain can grab free neurons
    urgeForce: number // strength of a motor neuron's actuation on its target color
    cohesion: number // how strongly brains/neurons cling to the body & avoid overlap
    senseRadius: number // perception radius shared by all three senses
    senseMode: number // 0=cycle, 1=all sight, 2=all smell, 3=all sound
}

interface ParamMeta {
    key: keyof ElectricalParams
    label: string
    desc: string
    isSelect?: boolean
}

// One-line "what it does" for each active shared parameter (mirrors the brain docs).
const PARAM_META: ParamMeta[] = [
    { key: 'brainGain', label: 'Brain Gain', desc: 'Global output gain — scales each net’s drive into the force its motor neurons apply to their color. Higher = stronger actuation.' },
    { key: 'brainLearnRate', label: 'Learn Rate', desc: 'Delta-rule learning rate for brain weights. 0 = frozen; >0 lets each net adapt from its need errors.' },
    { key: 'urgeRadius', label: 'Urge Radius', desc: 'Radius over which a brain measures its need metrics and a motor neuron pushes/pulls its color.' },
    { key: 'neuronRadius', label: 'Capture Radius', desc: 'Within this distance a brain can capture free sense/motor neurons into its net.' },
    { key: 'urgeForce', label: 'Neuron Force', desc: 'Strength of a motor neuron’s actuation on its target color, scaled by the drive it receives.' },
    { key: 'cohesion', label: 'Cohesion', desc: 'How strongly brains/neurons cling to the body and avoid overlapping each other.' },
    { key: 'senseRadius', label: 'Sense Radius', desc: 'Perception radius shared by all three senses (sight / smell / sound).' },
    { key: 'senseMode', label: 'Sense Mode', isSelect: true, desc: 'Which sense each sense neuron uses. Cycle gives a mix; the others specialise.' },
]

const SENSE_MODE_NAMES: Record<number, string> = {
    0: 'Cycle all',
    1: 'All sight',
    2: 'All smell',
    3: 'All sound',
}

// Below this |Δ| a trend is shown as "flat" to avoid flicker from float noise.
const TREND_EPS = 1e-3

type ObjectiveLabelFn = (k: number) => string

export default defineComponent({
    name: 'UrgeInspector',
    props: {
        stats: { type: Array as () => UrgeStat[], required: true },
        params: { type: Object as () => ElectricalParams, required: true },
        controlMax: { type: Number, required: true },
        targetColors: { type: Array as () => string[], required: true }, // rgb() strings, index = matter color id
        numTypes: { type: Number, required: true },
        selectedId: { type: Number, required: false, default: -1 }, // urge id currently tracked on the canvas (-1 = none)
        objectiveLabelFor: { type: Function as unknown as () => ObjectiveLabelFn, required: true }, // per-brain goal label
    },
    emits: ['update:selectedId'],
    setup(props, { emit }) {
        const TREND_EPS_LOCAL = TREND_EPS
        const paramMeta = PARAM_META

        // How many of the live cards are clones (shown in the list header).
        const cloneCount = computed(() => props.stats.filter(s => s.isClone).length)

        // Toggle tracking of a single urge on the canvas (click again to deselect).
        const select = (id: number) => {
            emit('update:selectedId', props.selectedId === id ? -1 : id)
        }

        const fmt = (n: number | undefined, digits = 2): string => {
            if (n === undefined || Number.isNaN(n))
                return '—'
            return n.toFixed(digits)
        }

        const senseModeName = (mode: number): string => SENSE_MODE_NAMES[mode] ?? `Mode ${mode}`

        const displayValue = (meta: ParamMeta): string => {
            if (meta.isSelect)
                return senseModeName(props.params.senseMode)
            return fmt(props.params[meta.key])
        }

        // Actuation bar fill: peak |drive| is a 0..1 magnitude, so it fills left→right.
        const actFill = (v: number): string => `${(Math.min(Math.max(v, 0), 1) * 100).toFixed(1)}%`

        // Color of the "N/K met" badge by the fraction of needs inside their target band.
        const metBadgeClass = (brain: BrainNet): string => {
            const frac = brain.needs.length ? brain.metNeeds / brain.needs.length : 0
            if (frac >= 0.75)
                return 'bg-emerald-500/15 text-emerald-300 ring-emerald-500/40'
            if (frac >= 0.4)
                return 'bg-amber-500/15 text-amber-300 ring-amber-500/40'
            return 'bg-rose-500/15 text-rose-300 ring-rose-500/40'
        }

        // ---- Per-need homeostasis gauge (live metric vs target zone) -------------------
        // A need is "met" when its live metric sits inside the target band
        // [setpoint − scale, setpoint + scale] — exactly where |error| stays below `gain`
        // (the teaching signal hasn't saturated). All needs in a card share ONE scale so their
        // gauges are directly comparable and none pin at 0%/100%.

        // Shared density scale for every need in a card: covers the highest setpoint with a
        // little headroom, clamped to a sane range.
        const cardCap = (brain: BrainNet): number => {
            let m = 1
            for (const n of brain.needs) {
                if (n.setpoint > m)
                    m = n.setpoint
            }
            return Math.min(Math.max(Math.ceil(m), 1), 4)
        }

        const pct = (v: number, cap: number): string => `${(Math.min(Math.max(v / cap, 0), 1) * 100).toFixed(1)}%`

        // Target-band left edge + width (setpoint ± scale), clamped to the track.
        const bandLeft = (n: NeedStat, cap: number): string => pct(n.setpoint - n.scale, cap)
        const bandWidth = (n: NeedStat, cap: number): string => {
            const lo = Math.max(0, (n.setpoint - n.scale) / cap)
            const hi = Math.min(1, (n.setpoint + n.scale) / cap)
            return `${((hi - lo) * 100).toFixed(1)}%`
        }

        // Needle position = the live metric on the shared scale.
        const metricPos = (n: NeedStat, cap: number): string => pct(n.metric, cap)

        // Needle color: green inside the target band (homeostasis met), rose below it (brain
        // wants MORE of that color), amber above it (has too much).
        const needleClass = (n: NeedStat): string => {
            if (Math.abs(n.metric - n.setpoint) <= n.scale)
                return 'bg-emerald-400'
            return n.metric < n.setpoint ? 'bg-rose-400' : 'bg-amber-400'
        }

        // Error readout color: small = satisfied, large = far from setpoint.
        const needErrClass = (n: NeedStat): string => {
            const a = Math.abs(n.error)
            if (a > 0.6)
                return 'text-rose-300'
            if (a > 0.25)
                return 'text-amber-300'
            return 'text-emerald-300/80'
        }

        const colorFor = (colorId: number): string => {
            const idx = ((colorId % props.numTypes) + props.numTypes) % props.numTypes
            return props.targetColors[idx] ?? '#ffffff'
        }

        // Per-urge goal label, supplied by the parent (it mirrors the shader's urgeGoal so the
        // text always matches what the GPU is actually doing). STABLE over time for a given index.
        const objectiveLabelFor = (k: number): string => props.objectiveLabelFor(k)

        // Arrow class for a live trend value (drives tick every readback). Flat below TREND_EPS.
        const trendIcon = (delta?: number): string => {
            if (delta === undefined || Math.abs(delta) <= TREND_EPS_LOCAL)
                return 'i-tabler-minus text-zinc-500'
            return delta > 0 ? 'i-tabler-arrow-up text-emerald-400' : 'i-tabler-arrow-down text-rose-400'
        }

        return { paramMeta, cloneCount, displayValue, fmt, actFill, metBadgeClass, colorFor, objectiveLabelFor, cardCap, pct, bandLeft, bandWidth, metricPos, needleClass, needErrClass, trendIcon, select, TREND_EPS: TREND_EPS_LOCAL }
    },
})
</script>

<style scoped></style>
