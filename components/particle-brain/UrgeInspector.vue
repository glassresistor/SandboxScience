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

                        <!-- objective (stable): homeostasis across its K need-colors -->
                        <div class="mt-1">
                            <p class="flex items-center gap-1.5 text-[0.74rem] text-zinc-200 leading-tight">
                                <span class="i-tabler-target shrink-0 text-amber-400" />
                                <span>{{ objectiveLabelFor(s.cloneOf ?? s.id) }}</span>
                            </p>
                        </div>

                        <!-- net output: the REAL brain→muscle drive (mean of owned motor drives, signed [-1,1]) -->
                        <div class="mt-1.5 flex items-center gap-2">
                            <span class="w-14 shrink-0 text-[0.68rem] text-zinc-400">Net output</span>
                            <div class="relative h-2 flex-1 overflow-hidden rounded-full bg-slate-700/70">
                                <!-- center divider -->
                                <div class="absolute bottom-0 left-1/2 top-0 w-px bg-white/40" />
                                <!-- signed fill -->
                                <div
                                    class="absolute bottom-0 top-0 rounded-full"
                                    :class="s.control >= 0 ? 'bg-emerald-500/80' : 'bg-rose-500/80'"
                                    :style="barFill(s.control)"
                                />
                            </div>
                            <span
                                class="w-14 shrink-0 text-right text-[0.72rem] font-mono tabular-nums"
                                :class="s.control >= 0 ? 'text-emerald-300' : 'text-rose-300'"
                            >{{ fmt(s.control) }}</span>
                            <span class="w-4 shrink-0 text-center" title="Δ net output vs previous readback">
                                <span v-if="s.trendControl > TREND_EPS" class="i-tabler-arrow-up text-emerald-400" />
                                <span v-else-if="s.trendControl < -TREND_EPS" class="i-tabler-arrow-down text-rose-400" />
                                <span v-else class="i-tabler-minus text-zinc-500" />
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
                            <p class="mb-0.5 text-[0.62rem] text-zinc-500 tracking-wide font-mono uppercase">
                                Needs · live metric vs setpoint
                            </p>
                            <ul class="flex flex-col gap-0.5">
                                <li v-for="(n, i) in s.brain.needs" :key="i" class="flex items-center gap-1.5 text-[0.68rem] font-mono tabular-nums">
                                    <span class="h-2.5 w-2.5 shrink-0 rounded-full ring-1 ring-white/30" :style="{ backgroundColor: colorFor(n.targetColor) }" />
                                    <span class="w-7 shrink-0 text-zinc-400">C{{ n.targetColor + 1 }}</span>
                                    <!-- metric bar (fill = live metric vs a soft cap); white tick marks the setpoint -->
                                    <div class="relative h-1.5 flex-1 overflow-hidden rounded-full bg-slate-700/70">
                                        <div class="absolute bottom-0 left-0 top-0 rounded-full" :class="needBarColor(n)" :style="{ width: needFill(n) }" />
                                        <div class="absolute bottom-0 top-0 w-px bg-white/60" :style="{ left: setpointPos(n) }" title="setpoint" />
                                    </div>
                                    <span class="w-12 shrink-0 text-right text-zinc-300">{{ fmt(n.metric) }}</span>
                                    <span class="w-16 shrink-0 text-right" :class="needErrClass(n)" title="error = clamp((setpoint − metric)/scale, ±1) × gain">
                                        {{ n.error >= 0 ? '↑' : '↓' }}{{ fmt(Math.abs(n.error), 2) }}
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
    meanDrive: number // mean signed net output across owned motor neurons (the real "control")
    maxAbsDrive: number // strongest |drive| among owned motor neurons
    teach: number // scalar teaching signal = mean of the K need errors
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

        // Signed bar centred at 0: left half = repel, right half = attract.
        const barFill = (control: number): Record<string, string> => {
            const max = Math.max(props.controlMax, 1e-6)
            let f = control / max
            if (f > 1)
                f = 1
            else if (f < -1)
                f = -1
            const widthPct = Math.abs(f) * 50 // each side is at most half the bar
            if (f >= 0)
                return { left: '50%', right: 'auto', width: `${widthPct}%` }
            return { right: '50%', left: 'auto', width: `${widthPct}%` }
        }

        // ---- Per-need table helpers (live metric vs setpoint) --------------------------
        // Soft cap so one need's bar fill stays comparable to its siblings.
        const needCap = (n: NeedStat): number => Math.max(n.setpoint * 1.6, 0.8)

        const needFill = (n: NeedStat): string => {
            const ratio = Math.min(Math.max(n.metric, 0) / needCap(n), 1)
            return `${(ratio * 100).toFixed(1)}%`
        }

        // Position of the setpoint tick on the same scale as the metric fill.
        const setpointPos = (n: NeedStat): string => {
            const ratio = Math.min(Math.max(n.setpoint, 0) / needCap(n), 1)
            return `${(ratio * 100).toFixed(1)}%`
        }

        // Fill color by how close the live metric is to its setpoint (homeostasis met?).
        const needBarColor = (n: NeedStat): string => {
            const dev = Math.abs(n.metric - n.setpoint) / Math.max(n.setpoint, 0.1)
            if (dev < 0.3)
                return 'bg-emerald-500/70'
            if (dev < 0.8)
                return 'bg-amber-500/70'
            return 'bg-rose-500/70'
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

        return { paramMeta, cloneCount, displayValue, fmt, barFill, colorFor, objectiveLabelFor, needFill, setpointPos, needBarColor, needErrClass, trendIcon, select, TREND_EPS: TREND_EPS_LOCAL }
    },
})
</script>

<style scoped></style>
