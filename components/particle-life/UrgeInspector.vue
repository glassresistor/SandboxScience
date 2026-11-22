<template>
    <div class="flex flex-col gap-2">
        <!-- Empty / disabled state -->
        <div v-if="!stats.length" class="rounded-lg bg-slate-800/40 ring-1 ring-slate-600/40 p-3 text-center">
            <p class="text-2sm text-zinc-300">No urges to inspect.</p>
            <p class="text-2sm text-zinc-500 mt-1">
                Enable the <b>Quantum / Electrical</b> layer and set a non-zero
                <b>Urge Count</b> to see live per-urge telemetry.
            </p>
        </div>

        <template v-else>
            <!-- ============ GLOBAL PARAMETER CARD ============ -->
            <div class="rounded-lg bg-slate-800/40 ring-1 ring-cyan-500/30 p-2">
                <div class="flex items-center gap-2 mb-1.5">
                    <span class="i-tabler-settings text-cyan-400"></span>
                    <p class="text-2sm font-semibold text-cyan-200">Global electrical parameters</p>
                    <span class="ml-auto px-1.5 py-0.5 rounded ring-1 text-[0.6rem] uppercase tracking-wide bg-cyan-500/15 text-cyan-300 ring-cyan-500/40 font-mono">shared</span>
                </div>
                <p class="text-[0.72rem] leading-snug text-zinc-400 mb-2">
                    These knobs apply to <b>every</b> urge &amp; neuron at once. The per-urge values below
                    (<span class="text-emerald-300">control</span>,
                    <span class="text-amber-300">metric</span>, target color) are what each individual urge carries.
                </p>
                <ul class="flex flex-col gap-1">
                    <li v-for="meta in paramMeta" :key="meta.key"
                        class="rounded bg-slate-900/40 px-2 py-1 ring-1 ring-slate-700/40">
                        <div class="flex items-center justify-between gap-2">
                            <span class="text-2sm text-zinc-200">{{ meta.label }}</span>
                            <span class="font-mono text-2sm text-cyan-300 tabular-nums shrink-0">{{ displayValue(meta) }}</span>
                        </div>
                        <p class="text-[0.7rem] leading-snug text-zinc-500 mt-0.5">{{ meta.desc }}</p>
                    </li>
                </ul>
            </div>

            <!-- ============ PER-URGE LIVE LIST ============ -->
            <div class="rounded-lg bg-slate-800/40 ring-1 ring-slate-600/40 p-2">
                <div class="flex items-center gap-2 mb-1.5">
                    <span class="i-tabler-list-details text-emerald-400"></span>
                    <p class="text-2sm font-semibold text-emerald-200">Per-urge live state</p>
                    <span class="ml-auto px-1.5 py-0.5 rounded ring-1 text-[0.6rem] uppercase tracking-wide bg-emerald-500/15 text-emerald-300 ring-emerald-500/40 font-mono">per urge</span>
                </div>
                <p class="text-[0.72rem] leading-snug text-zinc-400 mb-2">
                    Each row’s top line is its <b>objective</b> (what it wants) — fixed unless you change the
                    metric or species count. The <span class="text-emerald-300">control</span> bar is centred at 0:
                    <span class="text-rose-300">left = repel</span>, <span class="text-emerald-300">right = attract</span>.<br>
                    <span class="text-sky-300">Click a row to track that urge on the canvas.</span>
                </p>

                <ul class="flex flex-col gap-1.5">
                    <li v-for="s in stats" :key="s.id"
                        @click="select(s.id)"
                        class="cursor-pointer rounded bg-slate-900/50 px-2 py-1.5 ring-1 transition-all"
                        :class="selectedId === s.id ? 'ring-2 ring-sky-400/80 bg-sky-500/10' : 'ring-slate-700/40 hover:ring-slate-500/60'">
                        <!-- objective (stable) + identity -->
                        <div class="flex items-center gap-2">
                            <span class="w-3.5 h-3.5 rounded-full ring-1 ring-white/40 shrink-0"
                                  :style="{ backgroundColor: colorFor(s.targetColor) }"></span>
                            <!-- Clone rows show their lineage label (e.g. #3-C1) in violet; originals show #k -->
                            <span v-if="s.isClone && s.cloneOf !== undefined" class="font-mono text-2sm font-semibold text-violet-300">#{{ s.cloneOf }}-C{{ s.cloneId ?? 1 }}</span>
                            <span v-else class="font-mono text-2sm text-zinc-100">#{{ s.id }}</span>
                            <!-- Lineage badge for clones: "from #k" -->
                            <span v-if="s.isClone && s.cloneOf !== undefined"
                                  class="px-1.5 py-0.5 rounded bg-violet-500/15 ring-1 ring-violet-500/40 text-violet-300 text-[0.62rem] font-mono" title="Clone of this urge">
                                from #{{ s.cloneOf }}
                            </span>
                            <span v-if="selectedId === s.id" class="i-tabler-crosshair text-sky-400 shrink-0" title="Tracking on canvas"></span>
                            <span v-if="s.wiredNeurons !== undefined"
                                  class="ml-auto flex items-center gap-1 px-1.5 py-0.5 rounded bg-fuchsia-500/10 ring-1 ring-fuchsia-500/30 text-fuchsia-200 text-[0.68rem] font-mono" :title="'Neurons within neuronRadius driving this urge’s authority'">
                                <span class="i-tabler-brain"></span>{{ s.wiredNeurons }}
                            </span>
                        </div>

                        <!-- what it wants (STABLE over time; derived from the parent urge's index) -->
                        <p class="mt-1 flex items-center gap-1.5 text-[0.74rem] leading-tight text-zinc-200">
                            <span class="i-tabler-target text-amber-400 shrink-0"></span>
                            <span>{{ objectiveLabelFor(s.cloneOf ?? s.id) }}</span>
                        </p>

                        <!-- control signed bar -->
                        <div class="mt-1.5 flex items-center gap-2">
                            <span class="text-[0.68rem] text-zinc-400 w-12 shrink-0">Control</span>
                            <div class="relative flex-1 h-2 rounded-full bg-slate-700/70 overflow-hidden">
                                <!-- center divider -->
                                <div class="absolute top-0 bottom-0 left-1/2 w-px bg-white/40"></div>
                                <!-- signed fill -->
                                <div class="absolute top-0 bottom-0 rounded-full"
                                     :class="s.control >= 0 ? 'bg-emerald-500/80' : 'bg-rose-500/80'"
                                     :style="barFill(s.control)"></div>
                            </div>
                            <span class="w-14 text-right font-mono text-[0.72rem] tabular-nums shrink-0"
                                  :class="s.control >= 0 ? 'text-emerald-300' : 'text-rose-300'">{{ fmt(s.control) }}</span>
                            <span class="w-4 text-center shrink-0" :title="'Δ control vs previous readback'">
                                <span v-if="s.trendControl > TREND_EPS" class="i-tabler-arrow-up text-emerald-400"></span>
                                <span v-else-if="s.trendControl < -TREND_EPS" class="i-tabler-arrow-down text-rose-400"></span>
                                <span v-else class="i-tabler-minus text-zinc-500"></span>
                            </span>
                        </div>

                        <!-- metric / signal value (the live number) -->
                        <div class="mt-1 flex items-center gap-2">
                            <span class="text-[0.68rem] text-zinc-400 w-12 shrink-0">Metric</span>
                            <div class="relative flex-1 h-1.5 rounded-full bg-slate-700/70 overflow-hidden">
                                <div class="absolute top-0 bottom-0 left-0 rounded-full bg-amber-500/70"
                                     :style="{ width: signalFill(s.signal) }"></div>
                            </div>
                            <span class="w-14 text-right font-mono text-[0.72rem] tabular-nums text-amber-300 shrink-0">{{ fmt(s.signal) }}</span>
                            <span v-if="s.trendSignal !== undefined && Math.abs(s.trendSignal) > TREND_EPS"
                                  class="w-4 text-center shrink-0 font-mono text-[0.62rem]"
                                  :class="s.trendSignal > 0 ? 'text-emerald-400' : 'text-rose-400'">
                                {{ s.trendSignal > 0 ? '+' : '' }}{{ fmt(s.trendSignal) }}
                            </span>
                        </div>
                    </li>
                </ul>
            </div>
        </template>
    </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

// A single urge's live telemetry, read back from the GPU a few times per second.
export interface UrgeStat {
    id: number            // local urge index k (originals) or stable negative id (clones)
    type: number          // NUM_TYPES + k (the particle type code, always the parent's)
    targetColor: number   // k % NUM_TYPES (the matter color this urge maximises)
    control: number       // signed, [-controlMax, +controlMax]  (+ attract / - repel)
    signal: number        // smoothed objective metric value
    trendControl: number  // control - prevControl (0 if no prior readback)
    trendSignal?: number  // signal - prevSignal (0/undefined if no prior readback)
    wiredNeurons?: number // optional: neurons within neuronRadius of this urge
    isClone?: boolean     // true if this row represents a clone particle
    cloneOf?: number      // parent urge k (only set when isClone)
    cloneId?: number      // per-parent sequential clone number (1 = first clone of that parent)
}

// Snapshot of the global electrical parameters that apply to all urges/neurons.
export interface ElectricalParams {
    metricMode: number
    urgeRadius: number
    neuronRadius: number
    urgeForce: number
    controlGain: number
    controlMax: number
    neuronInfluence: number
    neuronAuthority: number
    maxAuthority: number
    cohesion: number
}

interface ParamMeta {
    key: keyof ElectricalParams
    label: string
    desc: string
    isSelect?: boolean
}

// One-line "what it does" for each shared parameter (mirrors the Quantum/Electrical docs).
const PARAM_META: ParamMeta[] = [
    { key: 'metricMode', label: 'Goal Family', isSelect: true, desc: 'The family of per-urge goals; the exact goal (attract/repel, density/fraction) still varies by index.' },
    { key: 'urgeRadius', label: 'Urge Radius', desc: 'Radius over which an urge measures its goal metric and a neuron pushes/pulls its color.' },
    { key: 'neuronRadius', label: 'Neuron Radius', desc: 'Radius (from the neuron) within which an urge drives it.' },
    { key: 'urgeForce', label: 'Urge Field Strength', desc: 'Strength of a neuron’s field on its color, scaled by the drive it receives from nearby urges.' },
    { key: 'controlGain', label: 'Control Gain', desc: 'Learning rate: how strongly the metric change (vs last frame) pushes an urge’s control toward its goal sign.' },
    { key: 'controlMax', label: 'Control Max', desc: 'Clamp on |control| — attract is +, repel is −.' },
    { key: 'neuronInfluence', label: 'Neuron Influence', desc: '(Legacy, unused) How strongly a nearby neuron nudged an urge’s control.' },
    { key: 'neuronAuthority', label: 'Authority / Neuron', desc: '(Legacy, unused) Extra authority gained per nearby neuron.' },
    { key: 'maxAuthority', label: 'Max Authority', desc: '(Legacy, unused) Cap on the accumulated neuron authority.' },
    { key: 'cohesion', label: 'Cohesion', desc: 'How strongly urges/neurons cling to the body and avoid overlapping each other.' },
]

const METRIC_MODE_NAMES: Record<number, string> = {
    0: 'Mixed Density',
    1: 'Mixed Fraction',
    2: 'Density / Fraction',
    3: 'Cycle All',
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
        objectiveLabelFor: { type: Function as unknown as () => ObjectiveLabelFn, required: true }, // per-urge goal label by index k
    },
    emits: ['update:selectedId'],
    setup(props, { emit }) {
        const TREND_EPS_LOCAL = TREND_EPS
        const paramMeta = PARAM_META

        // Toggle tracking of a single urge on the canvas (click again to deselect).
        const select = (id: number) => {
            emit('update:selectedId', props.selectedId === id ? -1 : id)
        }

        const fmt = (n: number | undefined, digits = 2): string => {
            if (n === undefined || Number.isNaN(n)) return '—'
            return n.toFixed(digits)
        }

        const metricModeName = (mode: number): string => METRIC_MODE_NAMES[mode] ?? `Mode ${mode}`

        const displayValue = (meta: ParamMeta): string => {
            if (meta.isSelect) return metricModeName(props.params.metricMode)
            return fmt(props.params[meta.key])
        }

        // Signed bar centred at 0: left half = repel, right half = attract.
        const barFill = (control: number): Record<string, string> => {
            const max = Math.max(props.controlMax, 1e-6)
            let f = control / max
            if (f > 1) f = 1
            else if (f < -1) f = -1
            const widthPct = Math.abs(f) * 50 // each side is at most half the bar
            if (f >= 0) return { left: '50%', right: 'auto', width: `${widthPct}%` }
            return { right: '50%', left: 'auto', width: `${widthPct}%` }
        }

        // Metric bar: the scale depends on metricMode (count vs 0..1 fraction), so we only
        // normalise the "fraction" mode; counts are capped at a soft ceiling for display.
        const signalFill = (signal: number): string => {
            let ratio: number
            if (props.params.metricMode === 1) ratio = Math.min(Math.max(signal, 0), 1)
            else ratio = Math.min(Math.max(signal, 0) / 40, 1) // soft cap for count-based metrics
            return `${(ratio * 100).toFixed(1)}%`
        }

        const colorFor = (colorId: number): string => {
            const idx = ((colorId % props.numTypes) + props.numTypes) % props.numTypes
            return props.targetColors[idx] ?? '#ffffff'
        }

        // Per-urge goal label, supplied by the parent (it mirrors the shader's urgeGoal so the
        // text always matches what the GPU is actually doing). STABLE over time for a given index.
        const objectiveLabelFor = (k: number): string => props.objectiveLabelFor(k)

        return { paramMeta, displayValue, fmt, barFill, signalFill, colorFor, objectiveLabelFor, select, TREND_EPS: TREND_EPS_LOCAL }
    },
})
</script>

<style scoped></style>