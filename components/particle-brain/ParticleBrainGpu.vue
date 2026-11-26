<template>
    <section id="mainContainer" relative h-screen flex flex-col justify-center overflow-hidden>
        <SidebarLeft v-model="particleLife.sidebarLeftOpen">
            <template #controls />
            <template #default>
                <div h-full flex flex-col px-2>
                    <div mb-1.5 flex items-end justify-between px-1>
                        <div flex items-center>
                            <div i-lets-icons-bubble mr-2 text-2xl class="text-[#2a9d8f] -mt-0.5" />
                            <h1 text-lg font-800 tracking-widest class="text-[#dff6f3] drop-shadow-[0_1.2px_1.2px_rgba(0,0,0,0.8)]">
                                Particle Life
                            </h1>
                            <p class="ml-2 justify-center rounded-lg bg-fuchsia-600/20 px-2 py-0.5 text-fuchsia-400 font-bold font-mono uppercase ring-1 ring-fuchsia-500/30">
                                GPU
                            </p>
                            <p ml-1.5 justify-center rounded-lg px-2 py-0.5 font-bold font-mono uppercase ring-1 class="bg-cyan-600/20 text-cyan-400 ring-cyan-500/30">
                                2D
                            </p>
                        </div>
                        <button h-full flex items-center rounded-lg px-2 font-semibold class="bg-amber-500/15 text-amber-100 ring-1 ring-amber-300/45 transition-all hover:bg-amber-500/25" title="Switch to 3D version" @click="switchTo3D">
                            <span class="i-tabler-cube mr-0.75 text-sm" />
                            <span class="text-xs -mb-px">Try 3D</span>
                        </button>
                        <!--                        <ToggleSwitch inactive-label="2D" label="3D" colorful-label v-model="particleLife.is3D" /> -->
                    </div>
                    <hr border-slate-500>
                    <div mt-2 flex flex-1 flex-col gap-2 overflow-auto pb-12 class="scrollableArea">
                        <Collapse
                            label="Presets" icon="i-tabler-sparkles text-amber-500"
                            tooltip="Choose predefined configurations to quickly set up your simulation."
                        >
                            <PresetPanel
                                :store="particleLife"
                                @update-colors="updateColors"
                                @update-rules-matrix="updateRulesMatrix"
                                @update-particle-positions="updateParticlePositions"
                                @load-preset="loadPreset"
                            />
                        </Collapse>
                        <Collapse
                            label="Matrix Settings" icon="i-tabler-grid-4x4 text-indigo-500"
                            tooltip="Modify matrix values by clicking on cells in the grid. <br>
                                  Adjust individual cell values with the slider, or click and drag to change them directly. <br>
                                  Use Ctrl + Click to select multiple cells for group adjustments. <br>
                                  If no cells are selected, the slider will adjust all values."
                        >
                            <MatrixSettings
                                :store="particleLife"
                                @update-rules-matrix="updateRulesMatrixValue"
                                @random-rules-matrix="newRandomRulesMatrix"
                                @update-min-matrix="updateMinMatrixValue"
                                @update-max-matrix="updateMaxMatrixValue"
                                @update-color="updateSingleColor"
                            />
                        </Collapse>
                        <Collapse
                            label="Randomizer Settings" icon="i-game-icons-perspective-dice-six-faces-random text-teal-500"
                            tooltip="Adjust the parameters for randomizing particle attributes. <br> Configure the ranges for minimum and maximum interaction radii."
                        >
                            <RadiusVisualizer
                                v-model:min-radius-range="particleLife.minRadiusRange"
                                v-model:max-radius-range="particleLife.maxRadiusRange"
                                @randomize-radius="randomizeRadius"
                                @randomize-rules-and-radius="randomizeRulesAndRadius"
                                @randomize-all="regenerateLife"
                            />

                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Electrical Layer
                                    <TooltipInfo container="#mainContainer" tooltip="Master switch for the brain/neuron layer. <br> Changing counts regenerates the map." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isElectricalEnabled" label="On" colorful-label />
                            </div>

                            <RangeInput
                                v-model="particleLife.numBrains" input
                                label="Brain Count"
                                tooltip="Number of brain particles. Each owns a private neural net + captured neurons. Changing this regenerates the map." :min="0" :max="2000" :step="1"
                                :disabled="!particleLife.isElectricalEnabled"
                            />
                            <RangeInput
                                v-model="particleLife.numNeurons" input label="Neuron Count"
                                mt-2
                                tooltip="Number of neuron particles. Changing this regenerates the map." :min="0" :max="2000" :step="1"
                                :disabled="!particleLife.isElectricalEnabled"
                            />
                        </Collapse>
                        <Collapse label="World Settings" icon="i-tabler-world-cog text-cyan-500" opened>
                            <RangeInput
                                v-model="particleLife.numParticles" input
                                label="Particle Count"
                                tooltip="Adjust the total number of particles. <br> More particles may reveal complex interactions but can increase computational demand." :min="16" :max="1048576" :step="16" @update:model-value="setNewNumParticles"
                            />
                            <RangeInput
                                v-model="particleLife.numColors" input
                                label="Species Count"
                                tooltip="Specify the number of particle colors. <br> Each color interacts with all others, with distinct forces and interaction ranges." :min="1" :max="16" :step="1" mt-2 @update:model-value="setNewNumTypes"
                            />
                            <div flex items-center class="mt-0.5">
                                <p class="mt-1 w-2/3 text-2sm">
                                    World Size
                                    <TooltipInfo container="#mainContainer" tooltip="Adjust the size of the area where particles are contained." />
                                </p>
                                <Input v-model="particleLife.simWidth" label="x" mr-2 @change="updateSimWidth" />
                                <Input v-model="particleLife.simHeight" label="y" mr-2 @change="updateSimHeight" />
                                <button type="button" btn flex items-center rounded-full p2 bg="slate-950/90 hover:slate-950/50" @click="particleLife.linkProportions = !particleLife.linkProportions">
                                    <span :class="particleLife.linkProportions ? 'i-tabler-link' : 'i-tabler-unlink'" text-sm />
                                </button>
                            </div>

                            <hr mb-2 mt-1 border-gray-500>
                            <p class="-mt-0.5" mb-2 text-gray-300 underline>
                                Boundary Settings :
                            </p>

                            <OptionBar
                                v-model="particleLife.wallState" name="wallStateGpu" mb-2 :options="[
                                    { id: 'none', label: 'None' },
                                    { id: 'repel', label: 'Repel' },
                                    { id: 'wrap', label: 'Wrap' }]"
                            />

                            <div mb-1 flex justify-around>
                                <div class="mt-1 w-2/3 text-2sm">
                                    Wrapping Mode
                                    <TooltipInfo container="#mainContainer" tooltip="Wrapping render modes : <br> <small><u>Normal:</u> Simple wrap. <br> <u>Edges:</u> Wrap + finite grayscale edge tiling. <br> <u>Infinite:</u> wrap + tiles fill the viewport (higher GPU cost).</small>" />
                                </div>
                                <WrapModeSelection :store="particleLife" />
                            </div>
                            <div flex justify-between>
                                <div class="mt-1 w-2/3 text-2sm">
                                    Edges Tiling
                                    <TooltipInfo container="#mainContainer" tooltip="Sets neighbor tiles count for Edges mode (grayscale)." />
                                </div>
                                <div flex>
                                    <SelectButton :id="5" v-model="particleLife.mirrorWrapCount" label="Cross 5" :disabled="!particleLife.isMirrorWrap" mr-2 />
                                    <SelectButton :id="9" v-model="particleLife.mirrorWrapCount" label="3x3" :disabled="!particleLife.isMirrorWrap" />
                                </div>
                            </div>
                        </Collapse>
                        <Collapse label="Physics Settings" icon="i-tabler-atom text-fuchsia-500" opened>
                            <RangeInput
                                v-model="particleLife.repel" input
                                label="Repel Force"
                                tooltip="Adjust the force that repels particles from each other. <br> Higher values increase the separation distance." :min="0.01" :max="4" :step="0.01"
                            />
                            <RangeInput
                                v-model="particleLife.forceFactor" input
                                label="Force Multiplier"
                                tooltip="Scales the interaction forces between particles. <br> Higher values make forces stronger and particles move faster." :min="0.01" :max="2" :step="0.01" mt-2
                            />
                            <RangeInput
                                v-model="particleLife.frictionFactor" input
                                label="Friction"
                                tooltip="Controls how much friction slows particles down. <br> Higher values reduce speed and help stabilize the system." :min="0" :max="1" :step="0.01" mt-2
                            />
                            <RangeInput
                                v-model="particleLife.magneticStrength" input
                                label="Magnetic Field"
                                tooltip="Lorentz force strength. Each matter species has a derived charge (golden-angle hash), so non-zero values create spiral/circular motion. <br> 0 = off. Positive/negative curves in opposite directions per species." :min="-2" :max="2" :step="0.01" mt-2
                            />

                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between gap-2>
                                <p text-gray-300 underline>
                                    Delta Time :
                                </p>
                                <div flex-1>
                                    <button
                                        type="button" pointer-events-auto flex cursor-pointer items-center gap-1 rounded-full px-2 py-0.5 text-sm text-gray-300 ring-1 transition-colors class="bg-slate-700/40 ring-slate-500/50 hover:bg-slate-600/50"
                                        :title="particleLife.showLiveDeltaTime ? 'Hide live Δt' : 'Show live Δt'"
                                        @click="particleLife.showLiveDeltaTime = !particleLife.showLiveDeltaTime"
                                    >
                                        <Transition name="dt-fade" mode="out-in">
                                            <span v-if="!particleLife.showLiveDeltaTime" key="show" flex items-center gap-1 text-gray-300>
                                                <span i-tabler-eye text-sm />
                                                Show live Δt
                                            </span>
                                            <span v-else key="value" flex items-center gap-1 text-gray-300>
                                                <span i-tabler-eye-off text-sm text-gray-500 />
                                                1/{{ Math.round(1 / displayedDeltaTime) }} <span text-gray-500>({{ displayedDeltaTime.toFixed(4) }}s)</span>
                                            </span>
                                        </Transition>
                                    </button>
                                </div>
                                <ToggleSwitch v-model="particleLife.manualDeltaTimeEnabled" label="Manual Δt" />
                            </div>
                            <RangeInput
                                v-if="particleLife.manualDeltaTimeEnabled"
                                v-model="particleLife.manualDeltaTime" input
                                :label="`Δt = 1/${Math.round(1 / particleLife.manualDeltaTime)}`"
                                tooltip="Manually set the simulation time step (Δt), shown as a frame fraction (1/x). <br> <b>Higher Δt</b> → faster but particles overshoot <br> <b>Lower Δt</b> → slower but more stable. <br> <i>Disable to keep the automatic, framerate-independent Δt.</i>" :min="0.0041" :max="0.05" :step="0.0001" mt-2
                            />
                        </Collapse>
                        <Collapse
                            label="Brains" icon="i-tabler-bolt text-lime-400"
                            tooltip="Per-brain neural networks with homeostatic needs. <br> <b>Brains</b> own a private net + captured sense/motor neurons. Their needs define teaching signals; the net maps sense inputs to motor drives. <br> <b>Motor neurons</b> are actuators for one color, driven solely by their owning brain's net output. <br> <b>Sense neurons</b> feed perception into their owner's net as inputs."
                        >
                            <p mb-2 text-2sm text-gray-400>
                                Counts & toggle are in <b>Randomizer Settings</b>. Changing counts regenerates the map.
                            </p>

                            <hr my-2 border-gray-500>
                            <RangeInput
                                v-model="particleLife.urgeRadius" input
                                label="Brain Radius"
                                tooltip="Radius over which a brain measures its need metrics, and the range at which a motor neuron pushes/pulls its color." :min="4" :max="160" :step="1"
                            />
                            <RangeInput
                                v-model="particleLife.neuronRadius" input label="Capture Radius"
                                mt-2
                                tooltip="Distance within which a brain can capture free sense/motor neurons (organic growth)." :min="4" :max="160" :step="1"
                            />
                            <RangeInput
                                v-model="particleLife.urgeForce" input label="Neuron Force"
                                mt-2
                                tooltip="Strength of a motor neuron's actuation on its target color, scaled by the drive from its owning brain's net output." :min="0" :max="4" :step="0.01"
                            />

                            <hr my-2 border-gray-500>
                            <p class="-mt-0.5" mb-1 text-gray-300 underline>
                                Brain Network :
                            </p>
                            <RangeInput
                                v-model="particleLife.brainGain" input label="Brain Gain"
                                mt-2
                                tooltip="Global brain network output gain added to neuron drive. 0 = no global modulation, high = over-control." :min="0" :max="3" :step="0.01"
                            />
                            <RangeInput
                                v-model="particleLife.brainLearnRate" input label="Brain Learn Rate"
                                mt-2
                                tooltip="Delta-rule learning rate for brain weights. 0 = frozen (weights change only via heredity); >0 lets each brain's net adapt from its need errors." :min="0" :max="0.1" :step="0.005"
                            />

                            <hr my-2 border-gray-500>
                            <RangeInput
                                v-model="particleLife.cohesion" input
                                label="Cohesion"
                                tooltip="How strongly urges and neurons cling to the body (so they coat it) and avoid overlapping each other. 0 = they drift freely." :min="0" :max="3" :step="0.01"
                            />

                            <!-- Sense Neurons: sensors that perceive one target color (no actuation) -->
                            <template v-if="particleLife.isElectricalEnabled">
                                <hr my-2 border-gray-500>
                                <p class="-mt-0.5" mb-1 text-gray-300 underline>
                                    Sense Neurons :
                                </p>
                                <RangeInput
                                    v-model="particleLife.numSenseNeurons" input
                                    label="Sense Count"
                                    tooltip="Number of sense neuron particles (sensors). Each senses EXACTLY ONE color = index % species and stores its perception in the particle's signal (magnitude 0–1) and control (bearing, radians) fields. They never push or pull matter." :min="0" :max="2000" :step="1"
                                />
                                <RangeInput
                                    v-model="particleLife.senseRadius" input label="Sense Radius"
                                    mt-2
                                    tooltip="Perception radius (world units) shared by all three senses: sight cone range, smell/sound scan disk." :min="4" :max="160" :step="1"
                                />
                                <RangeInput
                                    v-model="particleLife.senseConeHalfAngleDeg" input label="Sight Cone Half-Angle"
                                    mt-2
                                    tooltip="Half-angle of the sight cone in the direction of motion. Sight only counts target-color matter inside this forward cone (magnitude only, no bearing)." :min="1" :max="90" :step="1"
                                />
                                <div mt-2 flex items-center justify-between gap-2>
                                    <p class="w-1/3 shrink-0 text-2sm">
                                        Sense Mode
                                        <TooltipInfo container="#mainContainer" tooltip="Which sense each sense neuron uses. <br> <b>Cycle All</b>: senses cycle sight / smell / sound by index — a diverse population. <br> <b>All Sight</b>: forward cone, magnitude only (nothing behind is seen). <br> <b>All Smell</b>: bearing toward the NEAREST high-density cluster of the target color (near-biased weighting). <br> <b>All Sound</b>: bearing + loudness with NO far/near discrimination (uniform weight)." />
                                    </p>
                                    <SelectInput
                                        v-model="particleLife.senseMode" name="sense-mode"
                                        class="max-w-full!"
                                        :options="[
                                            { id: 0, name: 'Cycle All', category: 'Sense' },
                                            { id: 1, name: 'All Sight', category: 'Sense' },
                                            { id: 2, name: 'All Smell', category: 'Sense' },
                                            { id: 3, name: 'All Sound', category: 'Sense' },
                                        ]"
                                    />
                                </div>
                            </template>

                            <hr my-2 border-gray-500>
                            <div mb-1 flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Brain Cloning
                                    <TooltipInfo container="#mainContainer" tooltip="When an urge's metric stays above the threshold, it gives birth: a dormant clone-pool particle is activated as a copy of that urge plus ALL its in-range neurons, shot outward with an impulse. <b>On every birth the parent's metric is split in half</b> — half stays with the parent, half goes to the clone. Urges keep giving birth for as long as their metric stays above the threshold, so highly successful urges (and urge+neuron combinations) keep replicating, while marginal ones stall or starve." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isCloningEnabled" label="On" colorful-label :disabled="!particleLife.isElectricalEnabled || particleLife.numBrains === 0" />
                            </div>

                            <template v-if="particleLife.isCloningEnabled">
                                <RangeInput
                                    v-model="particleLife.cloneMetricThreshold" input
                                    label="Metric Threshold"
                                    tooltip="An urge gives birth only while its metric stays above this value. Each birth halves the metric, so an urge must re-accumulate past this value before it can reproduce again — higher = rarer replication. Typical metrics range 0–20 depending on local density." :min="0.1" :max="10" :step="0.1" mt-1
                                />
                                <RangeInput
                                    v-model="particleLife.birthSustainedTicks" input
                                    label="Birth Sustained Ticks"
                                    tooltip="Consecutive checks (500 ms each) that an urge's metric must stay above the threshold before it gives birth. 1 = reproduce immediately whenever above threshold (fastest replication). Higher = slower, steadier reproduction. After a birth the counter resets and the halved metric must climb back above threshold." :min="1" :max="30" :step="1" mt-1
                                />
                                <RangeInput
                                    v-model="particleLife.cloneImpulse" input
                                    label="Clone Impulse"
                                    tooltip="Initial velocity given to a clone so it shoots outside the original's radius but stays in the general area. Higher = flies further. Typical sim sizes are ~800–2000 px." :min="200" :max="5000" :step="50" mt-1
                                />
                                <RangeInput
                                    v-model="particleLife.numClonePool" input
                                    label="Clone Pool Size"
                                    tooltip="Number of dormant slots reserved for cloning. Each clone permanently consumes one slot. Total particles = matter + urges + neurons + sense + pool. Changing this re-labels the population." :min="0" :max="1000" :step="10" mt-1
                                />
                            </template>

                            <!-- Brain Lifecycle: Death -->
                            <div class="mt-2 flex items-center justify-between">
                                <p class="w-2/3 text-2sm">
                                    Brain Death (Starvation)
                                    <TooltipInfo container="#mainContainer" tooltip="When an urge's metric stays below the threshold for the sustained time, it dies: its particle becomes dormant (invisible) and all neurons within neuronRadius of it also die. Death is permanent for the session." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isDeathEnabled" label="On" colorful-label :disabled="!particleLife.isElectricalEnabled || particleLife.numBrains === 0" />
                            </div>
                            <template v-if="particleLife.isDeathEnabled">
                                <RangeInput
                                    v-model="particleLife.deathMetricThreshold" input label="Utility Threshold"
                                    tooltip="Utility below this counts as 'starved'. Utility = how well the brain meets its own needs (1 = all met, 0 = none), so a low value kills brains that can't satisfy their goals. Effectively 0..1 (>1 = never starves)." :min="0" :max="2" :step="0.01" mt-1
                                />
                                <RangeInput
                                    v-model="particleLife.deathSustainedTicks" input label="Sustained Ticks"
                                    tooltip="Consecutive 500 ms ticks below threshold before death. 12 ticks ≈ 6 seconds." :min="3" :max="60" :step="1" mt-1
                                />
                            </template>

                            <!-- Brain Lifecycle: Merges -->
                            <div class="mt-2 flex items-center justify-between">
                                <p class="w-2/3 text-2sm">
                                    Brain Merges
                                    <TooltipInfo container="#mainContainer" tooltip="When two live brains stay within the merge radius for the sustained time, they merge: the higher-utility brain survives (better at satisfying its own goals) and absorbs the other's neurons. The merged genome is weighted by each brain's utility, so the fitter one's goals dominate. Tie → lower display id wins." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isMergeEnabled" label="On" colorful-label :disabled="!particleLife.isElectricalEnabled || particleLife.numBrains === 0" />
                            </div>
                            <template v-if="particleLife.isMergeEnabled">
                                <RangeInput
                                    v-model="particleLife.mergeRadius" input label="Merge Radius"
                                    tooltip="World-unit distance within which two urges are considered close enough to merge. Default ≈ urgeRadius × 0.6." :min="5" :max="200" :step="1" mt-1
                                />
                                <RangeInput
                                    v-model="particleLife.mergeSustainedTicks" input label="Sustained Ticks"
                                    tooltip="Consecutive 500 ms ticks of proximity before merge fires. 8 ticks ≈ 4 seconds." :min="3" :max="60" :step="1" mt-1
                                />
                            </template>

                            <!-- Brain Lifecycle: Murders -->
                            <div class="mt-2 flex items-center justify-between">
                                <p class="w-2/3 text-2sm">
                                    Brain Murders
                                    <TooltipInfo container="#mainContainer" tooltip="When two live urges collide (distance below murderRadius) and their power gap exceeds the margin, the weaker dies immediately. No sustained requirement — instant collision event. Near-equal powers do not kill each other." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isMurderEnabled" label="On" colorful-label :disabled="!particleLife.isElectricalEnabled || particleLife.numBrains === 0" />
                            </div>
                            <template v-if="particleLife.isMurderEnabled">
                                <RangeInput
                                    v-model="particleLife.murderRadius" input label="Murder Radius"
                                    tooltip="World-unit distance for a 'collision'. Tighter than merge radius. Default ≈ urgeRadius × 0.35." :min="2" :max="100" :step="1" mt-1
                                />
                                <RangeInput
                                    v-model="particleLife.murderPowerMargin" input label="Power Margin"
                                    tooltip="Minimum |powerA − powerB| (in signal units) before the weaker one dies. Higher = more tolerant of near-equal powers." :min="0.1" :max="5" :step="0.1" mt-1
                                />
                            </template>

                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Debug links
                                    <TooltipInfo container="#mainContainer" tooltip="Shows the live wiring: light dotted lines from every urge to each motor neuron within Neuron Radius (the urges currently driving it), a dotted ring at each urge's Neuron Radius, enlarged neurons (diamond = motor, ring = sense) with their own dotted ring, and the perception circle around sense neurons." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isDebugConnections" label="On" colorful-label />
                            </div>
                        </Collapse>
                        <Collapse
                            label="Brain Inspector" icon="i-tabler-telescope text-sky-400"
                            tooltip="Read-only telemetry for the Quantum / Electrical layer. <br> Flip <b>Live readback</b> on to sample each urge’s <b>control</b> and <b>metric</b> from the GPU a few times per second — off means zero overhead."
                        >
                            <div mb-1 flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Live readback
                                    <TooltipInfo container="#mainContainer" tooltip="Throttled GPU readback of every urge’s control & metric. Never runs while a resize/erase is mutating buffers, and stops immediately when off." />
                                </p>
                                <ToggleSwitch v-model="urgeInspectorOpen" label="On" colorful-label :disabled="!particleLife.isElectricalEnabled" />
                            </div>

                            <UrgeInspector
                                v-if="urgeInspectorOpen" key="urge-inspector-panel"
                                v-model:selected-id="selectedUrgeId"
                                :stats="urgeStats"
                                :params="electricalParams"
                                :control-max="1"
                                :target-colors="colorRgbStrings"
                                :num-types="particleLife.numColors"
                                :objective-label-for="objectiveLabelFor"
                            />

                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Experiment telemetry
                                    <TooltipInfo container="#mainContainer" tooltip="Opt-in, throttled read-only sampling of matter entropy, novelty rate and control gap (for parameter sweeps). Off = zero overhead. Samples land in the component's experimentLog for export as JSON." />
                                </p>
                                <ToggleSwitch v-model="isExperimentTelemetry" label="On" colorful-label :disabled="!particleLife.isElectricalEnabled" />
                            </div>
                            <div mt-2 flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Samples captured
                                    <TooltipInfo container="#mainContainer" tooltip="Number of telemetry samples in the ring buffer (capped at 1000; oldest dropped)." />
                                </p>
                                <div flex items-center gap-2>
                                    <span class="text-2sm text-gray-300">{{ experimentLog.length }}</span>
                                    <button type="button" class="bg-gray-700 px-2 py-1 text-xs hover:bg-gray-600" @click="clearExperimentLog">
                                        Clear
                                    </button>
                                </div>
                            </div>
                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Environmental drift
                                    <TooltipInfo container="#mainContainer" tooltip="Opt-in: periodically perturbs the MATTER×MATTER interaction rules with small centered Gaussian noise (urges/neurons untouched) to simulate a slowly changing environment. Off = no perturbation." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isDriftEnabled" label="On" colorful-label />
                            </div>
                            <RangeInput
                                v-model="particleLife.driftStrength" input label="Drift Strength"
                                mt-2
                                tooltip="σ of the per-cell Gaussian noise applied at each drift step. 0 = no-op." :min="0" :max="0.5" :step="0.01"
                            />
                            <RangeInput
                                v-model="particleLife.driftInterval" input label="Drift Interval (frames)"
                                mt-2
                                tooltip="Simulated frames between drift steps (~3.3 s at 60 fps)." :min="10" :max="2000" :step="10"
                            />
                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between gap-2>
                                <p class="w-2/3 text-2sm">
                                    Neuron damage
                                    <TooltipInfo container="#mainContainer" tooltip="Opt-in: randomly knocks one healthy motor neuron offline per frame with the probability below. Damaged neurons keep firing but cannot actuate matter, for the duration (frames). Toggling off heals all." />
                                </p>
                                <ToggleSwitch v-model="particleLife.isDamageEnabled" label="On" colorful-label />
                            </div>
                            <RangeInput
                                v-model="particleLife.neuronDamageProbability" input label="Damage Probability"
                                mt-2
                                tooltip="Per-frame probability of damaging ONE random healthy neuron." :min="0" :max="0.1" :step="0.001"
                            />
                            <RangeInput
                                v-model="particleLife.neuronDamageDuration" input label="Damage Duration (frames)"
                                mt-2
                                tooltip="Frames a damaged neuron stays offline (~1 s at 60 fps)." :min="5" :max="600" :step="5"
                            />
                        </Collapse>
                        <Collapse label="Graphics Settings" icon="i-tabler-photo-cog text-emerald-500">
                            <RangeInput
                                v-model="particleLife.particleSize" input
                                label="Particle Size"
                                tooltip="Controls the overall size of the particles in the simulation, allowing you to make them larger or smaller depending on your preference. This setting does not impact performance." :min="0.1" :max="6" :step="0.1"
                            />
                            <RangeInput
                                v-model="particleLife.particleOpacity" input
                                label="Particle Opacity"
                                tooltip="Adjust the opacity of the particles in the simulation. <br> This setting allows you to control how transparent or opaque the particles appear." :min="0" :max="1" :step="0.01" mt-2
                            />
                            <div mt-1 flex justify-between>
                                <div class="mt-1 w-2/3 text-2sm">
                                    Particle Blending
                                    <TooltipInfo container="#mainContainer" tooltip="Particle blending modes. <br> <small><u>Normal:</u> Alpha blend (standard colors). <br> <u>Additive:</u> Adds color values. Overlaps accumulate brightness (glow-like).</small>" />
                                </div>
                                <div flex>
                                    <SelectButton :id="false" v-model="particleLife.isAdditiveBlending" label="Normal" mr-2 />
                                    <SelectButton :id="true" v-model="particleLife.isAdditiveBlending" label="Additive" />
                                </div>
                            </div>

                            <hr my-2 border-gray-500>
                            <div mb-2 flex items-start justify-between>
                                <p mb-1 text-gray-300 underline>
                                    Glow Settings :
                                </p>
                                <ToggleSwitch v-model="particleLife.isParticleGlow" label="Particle Glowing" colorful-label />
                            </div>

                            <RangeInput
                                v-model="particleLife.glowSize" input
                                label="Glow Size"
                                tooltip="Adjust the size of the glow effect around particles." :min="0" :max="32" :step="0.1" mt-2
                            />
                            <RangeInput
                                v-model="particleLife.glowIntensity" input
                                label="Glow Intensity"
                                tooltip="Adjust the intensity of the glow effect around particles." :min="0" :max="0.5" :step="0.005" mt-2
                            />
                            <RangeInput
                                v-model="particleLife.glowSteepness" input
                                label="Glow Steepness"
                                tooltip="Adjust the steepness of the glow effect around particles. <br> Higher values create a sharper transition between glowing and non-glowing areas." :min="0" :max="12" :step="1" mt-2
                            />
                        </Collapse>
                        <Collapse label="Camera Settings" icon="i-tabler-camera-cog text-violet-500">
                            <RangeInput
                                v-model="particleLife.zoomSmoothing" input
                                label="Zoom Smoothing"
                                tooltip="Adjusts the smoothness of the zoom. <br> Lower values result in a slower, more fluid zoom, while higher values make it faster and more abrupt." :min="0.01" :max="0.5" :step="0.01"
                            />
                            <RangeInput
                                v-model="particleLife.panSmoothing" input
                                label="Pan Smoothing"
                                tooltip="Adjusts the smoothness of camera panning. <br> Lower values create more inertia for a gliding effect, while higher values make the movement stop more abruptly." :min="0.01" :max="0.5" :step="0.01" mt-2
                            />

                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between>
                                <p text-gray-300 underline>
                                    Cinematic Mode :
                                </p>
                                <button
                                    btn relative flex items-center rounded-full px-3 py-1 text-xs font-medium ring-1 transition-all
                                    :class="particleLife.isDriftCamActive
                                        ? 'bg-violet-600/80 hover:bg-violet-500/80 ring-violet-400/50 text-white'
                                        : 'bg-violet-900/60 hover:bg-violet-800/70 ring-violet-500/30 text-violet-300'"
                                    @click="particleLife.isDriftCamActive = !particleLife.isDriftCamActive"
                                >
                                    <span v-if="particleLife.isDriftCamActive" class="absolute size-3 flex -right-1 -top-1">
                                        <span class="absolute h-full w-full inline-flex animate-ping rounded-full bg-violet-400 opacity-75 ring-1 ring-violet-300/50" />
                                        <span class="relative size-3 inline-flex rounded-full bg-violet-400" />
                                    </span>
                                    <span i-tabler-video mr-1 text-xs />
                                    {{ particleLife.isDriftCamActive ? 'Drifting...' : 'Enable Drift' }}
                                </button>
                            </div>
                            <p v-if="!particleLife.isDriftCamActive" class="mt-1 text-sm text-gray-500">
                                Auto camera panning & zooming.
                            </p>
                            <div v-else mt-2 flex flex-col gap-2>
                                <ToggleSwitch
                                    v-model="particleLife.driftCamResetOnPan" label="Reset Path on Pan" colorful-label
                                    tooltip="Starts a new drift trajectory after manual panning or zooming, instead of resuming the previous path."
                                />
                                <RangeInput
                                    v-model="particleLife.driftCamSpeed" input
                                    label="Drift Speed"
                                    tooltip="Controls the automatic camera movement speed. <br> - <b>Higher</b> → faster tracking. <br> - <b>Lower</b> → smoother cinematic effect." :min="0.01" :max="1.0" :step="0.01"
                                />
                                <RangeInput
                                    v-model="particleLife.driftCamAmplitude" input
                                    label="Pan Amplitude"
                                    tooltip="Controls how far the camera moves from center. <br> - <b>0.5</b> → half the simulation area. <br> - <b>1.0</b> → full edges." :min="0.05" :max="1.0" :step="0.05"
                                />
                                <RangeInputMinMax
                                    v-model="particleLife.driftCamZoomRange" input label="Zoom Range"
                                    mt-2
                                    tooltip="Sets the min/max zoom levels for automatic cinematic zoom." :min="0.1" :max="5" :step="0.05" :range-offset="0.1"
                                />
                            </div>

                            <hr my-2 border-gray-500>
                            <div flex items-center justify-between>
                                <p text-gray-300 underline>
                                    Creature Tracking :
                                </p>
                                <button
                                    btn relative flex items-center rounded-full px-3 py-1 text-xs font-medium ring-1 transition-all
                                    :class="particleLife.isTrackerSelectionActive
                                        ? 'bg-amber-700/80 hover:bg-amber-600/80 ring-amber-500/50 text-white animate-pulse'
                                        : particleLife.isTrackerActive
                                            ? 'bg-rose-600/80 hover:bg-rose-500/80 ring-rose-400/50 text-white'
                                            : 'bg-rose-900/60 hover:bg-rose-800/70 ring-rose-500/30 text-rose-300'"
                                    @click="particleLife.isTrackerSelectionActive ? cancelTrackerSelection() : particleLife.isTrackerActive ? stopTracker() : startTrackerSelection()"
                                >
                                    <span v-if="particleLife.isTrackerActive" class="absolute size-3 flex -right-1 -top-1">
                                        <span class="absolute h-full w-full inline-flex animate-ping rounded-full bg-rose-400 opacity-75 ring-1 ring-rose-300/50" />
                                        <span class="relative size-3 inline-flex rounded-full bg-rose-400" />
                                    </span>
                                    <span :class="particleLife.isTrackerSelectionActive ? 'i-tabler-marquee-2' : 'i-tabler-current-location'" mr-1 text-xs />
                                    {{ particleLife.isTrackerSelectionActive ? 'Selecting...' : particleLife.isTrackerActive ? 'Tracking...' : 'Select & Track' }}
                                </button>
                            </div>
                            <p v-if="!particleLife.isTrackerActive && !particleLife.isTrackerSelectionActive" class="mt-1 text-sm text-gray-500">
                                Track & follow a creature in real time.
                            </p>
                            <p v-else-if="particleLife.isTrackerSelectionActive" class="mt-1 text-sm text-amber-500/80">
                                Draw around a creature to start tracking.
                            </p>
                            <div v-else mt-2 flex flex-col gap-2>
                                <ToggleSwitch
                                    v-model="particleLife.isTrackerCameraActive" label="Camera Follow" colorful-label
                                    tooltip="When enabled, the camera will smoothly follow the tracked creature."
                                />
                                <ToggleSwitch
                                    v-model="particleLife.isTrackerIndicatorVisible" label="Show Indicator" colorful-label
                                    tooltip="Show or hide the visual tracker indicator overlay."
                                />
                                <RangeInput
                                    v-model="particleLife.trackerCameraSmoothing" input
                                    label="Smoothing"
                                    tooltip="Controls how smoothly the camera follows the tracked creature. <br> Lower values give a slower, cinematic follow. Higher values make the camera snap to the target." :min="0.01" :max="1" :step="0.01"
                                />
                            </div>
                        </Collapse>
                        <Collapse
                            label="Debug Tools" icon="i-tabler-bug text-rose-500"
                            tooltip="Provides tools for visualizing the simulation's internal state. <br> Toggle the grid view to see spatial bins or activate a heatmap to analyze particle density. <br> These features are useful for debugging and performance tuning."
                        >
                            <div v-show="particleLife.useSpatialHash">
                                <p mb-1 text-2sm text-gray-300 underline class="-mt-0.5">
                                    Spatial Bins Overlay :
                                </p>
                                <div flex items-center gap-2>
                                    <SelectInput
                                        name="debug-bins-mode"
                                        :model-value="particleLife.isDebugHeatmapActive ? 'heatmap' : 'grid'"
                                        :options="[
                                            { id: 'grid', name: 'Grid', icon: 'i-tabler-grid-dots', category: 'Display Mode' },
                                            { id: 'heatmap', name: 'Heatmap', icon: 'i-tabler-flame', category: 'Display Mode' },
                                        ]"
                                        @update:model-value="particleLife.isDebugHeatmapActive = $event === 'heatmap'"
                                    />
                                    <ToggleSwitch v-model="particleLife.isDebugBinsActive" label="Active" colorful-label />
                                </div>
                                <RangeInput
                                    v-show="particleLife.isDebugHeatmapActive" v-model="particleLife.debugMaxParticleCount" input
                                    label="Heatmap Scale"
                                    tooltip="Sets the number of particles in a cell that maps to the highest value on the heatmap gradient. <br> Adjusting this value scales the density visualization, helping to fine-tune how particle concentrations are displayed." :min="640" :max="16000" :step="16" mt-2
                                />
                                <hr my-2 border-gray-500>
                            </div>

                            <p mb-1 text-2sm text-gray-300 underline class="-mt-0.5">
                                Neighbor Search :
                            </p>
                            <SelectInput
                                name="algorithm-mode"
                                :model-value="particleLife.useSpatialHash ? 'spatial' : 'brute'"
                                :options="[
                                    { id: 'spatial', name: 'Spatial Hash', icon: 'i-tabler-topology-ring-3', category: 'Method' },
                                    { id: 'brute', name: 'Brute Force', icon: 'i-tabler-cpu', category: 'Method' },
                                ]"
                                @update:model-value="particleLife.useSpatialHash = $event === 'spatial'"
                            />
                            <RangeInput
                                v-show="particleLife.useSpatialHash" v-model="particleLife.cellSubdivisions" input label="Cell Subdivisions"
                                mt-2
                                tooltip="Subdivides the interaction radius into smaller grid cells. <br> Default: 2 (fastest in most cases). <br> Increasing subdivisions can improve performance for simulations with very large radii." :min="1" :max="5" :step="1"
                            />
                        </Collapse>
                    </div>
                    <div absolute bottom-2 right-0 z-100 class="-mr-px">
                        <button flex items-center border border-slate-600 rounded-l-lg p-1 bg="slate-900/85 hover:slate-950/85" @click="particleLife.sidebarLeftOpen = false">
                            <span i-tabler-chevron-left text-2xl />
                        </button>
                    </div>
                </div>
            </template>
            <template #bottom-actions>
                <button
                    type="button" name="Cinematic Camera" aria-label="Cinematic Camera" title="Cinematic Camera"
                    btn pointer-events-auto flex items-center justify-center rounded-full p-2 backdrop-blur-sm
                    :class="particleLife.isDriftCamActive ? 'bg-violet-600/90 hover:bg-violet-500/90' : 'bg-violet-900/80 hover:bg-violet-800/80'"
                    :disabled="particleLife.isHudLocked" @click="particleLife.isDriftCamActive = !particleLife.isDriftCamActive"
                >
                    <span i-tabler-video :class="particleLife.isDriftCamActive ? 'text-white' : 'text-violet-300'" />
                    <span v-if="particleLife.isDriftCamActive" class="absolute size-3 flex -right-0.5 -top-0.5">
                        <span class="absolute h-full w-full inline-flex animate-ping rounded-full bg-violet-400 opacity-75 ring-1 ring-violet-300/50" />
                        <span class="relative size-3 inline-flex rounded-full bg-violet-400" />
                    </span>
                </button>
                <TrackerToggle
                    @toggle="particleLife.isTrackerSelectionActive ? cancelTrackerSelection() : particleLife.isTrackerActive ? stopTracker() : startTrackerSelection()"
                />
                <CenterViewButton
                    :disabled="particleLife.isHudLocked"
                    @center-all="smoothCenterView()"
                    @center-position="smoothCenterView(true, false)"
                    @reset-zoom="smoothCenterView(false, true)"
                />
                <button
                    type="button" name="Randomize" aria-label="Randomize" title="Randomize simulation"
                    btn pointer-events-auto flex items-center justify-center rounded-full p-2
                    class="bg-[#094F5D]/90 backdrop-blur-sm hover:bg-[#0B5F6F]/90"
                    :disabled="particleLife.isHudLocked" @click="regenerateLife"
                >
                    <span i-game-icons-perspective-dice-six-faces-random text-2xl />
                </button>
            </template>
        </SidebarLeft>
        <canvas id="canvasRef" ref="canvasRef" h-full w-full cursor-crosshair @contextmenu.prevent />
        <!-- Urge tracking overlay: the marker position is set imperatively every frame (no GPU work);
             it simply projects the selected urge's last-known world position through the camera. -->
        <div class="pointer-events-none absolute inset-0 z-20 overflow-hidden" aria-hidden="true">
            <div
                v-show="selectedUrgeId !== -1 && particleLife.isElectricalEnabled"
                ref="urgeMarkerEl" class="absolute left-0 top-0 will-change-transform" style="opacity: 0; transform: translate(-9999px, -9999px)"
            >
                <!-- ring centred on the point -->
                <div class="-translate-x-1/2 -translate-y-1/2">
                    <div
                        class="h-4 w-4 animate-pulse border-2 rounded-full"
                        :style="{ borderColor: markerColor, boxShadow: `0 0 9px ${markerColor}` }"
                    />
                </div>
                <!-- label offset to the right of the point -->
                <div
                    class="absolute left-3.5 top-0 whitespace-nowrap rounded-md bg-slate-900/85 px-2 py-1 text-[0.7rem] leading-tight ring-1 backdrop-blur-sm -translate-y-1/2"
                    :style="{ borderColor: markerColor }"
                >
                    <div class="flex items-center gap-1.5">
                        <span class="font-semibold font-mono" :class="selectedUrgeId < 0 ? 'text-violet-300' : 'text-zinc-100'">{{ markerLabel }}</span>
                        <span class="text-amber-300">{{ markerObjective }}</span>
                    </div>
                    <div ref="urgeMarkerStatEl" class="text-[0.62rem] text-emerald-300 font-mono" />
                </div>
            </div>
        </div>
        <ClientOnly>
            <TrackerOverlay v-if="particleLife.isTrackerSelectionActive" @tracker-zone-selected="onTrackerZoneSelected" />
        </ClientOnly>
        <SaveModal :store="particleLife" />
        <div pointer-events-none absolute right-0 top-0 flex flex-col items-end text-right>
            <div flex items-center rounded-bl-xl bg-slate-800 pl-4 pr-1 text-start text-xs style="padding-bottom: 1px; opacity: 75%">
                <div flex>
                    Fps: <div ml-1 min-w-8>
                        {{ fps }}
                    </div>
                </div>
                <!--                <div flex ml-3>Process: <div ml-1 min-w-7>{{ Math.round(executionTime) }}</div></div> -->
            </div>
            <BrushSettings :store="particleLife" pointer-events-auto mr-1 mt-2 :class="particleLife.isHudLocked && '!pointer-events-none [&_*]:!pointer-events-none opacity-40'" />

            <div class="faded-hover-effect" mr-1>
                <button
                    type="button" title="Debugger" aria-label="Debugger" bg="#D62839 hover:#DC4151" btn mt-2 aspect-square w-8 flex items-center justify-center rounded-full p1
                    :disabled="particleLife.isHudLocked" @click="particleLife.isDebugBinsActive = !particleLife.isDebugBinsActive"
                >
                    <span text-sm :class="particleLife.isDebugBinsActive ? 'i-tabler-bug-filled' : 'i-tabler-bug'" />
                </button>
            </div>
        </div>
        <div pointer-events-none fixed bottom-2 z-10 flex items-end justify-center class="left-1/2 transform -translate-x-1/2">
            <!-- faded-hover-effect -->
            <button type="button" name="Toggle Fullscreen" aria-label="Toggle Fullscreen" btn mx-1 flex items-center rounded-full p2 backdrop-blur-sm bg="slate-800/80 hover:slate-700/80" :disabled="particleLife.isHudLocked" @click="toggleFullscreen">
                <span :class="isFullscreen ? 'i-tabler-maximize-off' : 'i-tabler-maximize'" />
            </button>
            <button type="button" name="Zoom Out" aria-label="Zoom Out" btn mx-1 flex items-center rounded-full p2 backdrop-blur-sm bg="slate-800/80 hover:slate-700/80" :disabled="particleLife.isHudLocked" @click="handleZoom(-1, true)">
                <span i-tabler-zoom-out />
            </button>
            <button type="button" name="Play/Pause" aria-label="Play/Pause" btn mx-1 flex items-center rounded-full p3 backdrop-blur-sm bg="slate-800/80 hover:slate-700/80" :disabled="particleLife.isHudLocked" @click="particleLife.isRunning = !particleLife.isRunning">
                <span text-xl :class="particleLife.isRunning ? 'i-tabler-player-pause-filled' : 'i-tabler-player-play-filled'" />
            </button>
            <button type="button" name="Step" aria-label="Step" btn mx-1 flex items-center rounded-full p2 backdrop-blur-sm bg="slate-800/80 hover:slate-700/80" :disabled="particleLife.isRunning || particleLife.isHudLocked" @click="step">
                <span i-tabler-player-skip-forward-filled />
            </button>
            <button type="button" name="Zoom In" aria-label="Zoom In" btn mx-1 flex items-center rounded-full p2 backdrop-blur-sm bg="slate-800/80 hover:slate-700/80" :disabled="particleLife.isHudLocked" @click="handleZoom(1, true)">
                <span i-tabler-zoom-in />
            </button>
        </div>
        <SocialLinks />
    </section>
</template>

<script lang="ts">
import type { BrainNet, ElectricalParams, NeedStat, UrgeStat } from "~/components/particle-brain/UrgeInspector.vue"
import heatmapImage from 'assets/particle-life-gpu/images/heatmap_red4x_256x1.png'
import composeHdrShaderCode from 'assets/particle-brain-gpu/shaders/compose/compose_hdr.wgsl?raw'
import infiniteCompositorShaderCode from 'assets/particle-brain-gpu/shaders/compose/infinite_compositor.wgsl?raw'
import binFillSizeShaderCode from 'assets/particle-brain-gpu/shaders/compute/binFillSize.wgsl?raw'
import binPrefixSumShaderCode from 'assets/particle-brain-gpu/shaders/compute/binPrefixSum.wgsl?raw'
import bruteForceShaderCode from 'assets/particle-brain-gpu/shaders/compute/compute_bruteForce.wgsl?raw'
import debugConnectionsShaderCode from 'assets/particle-brain-gpu/shaders/compute/debugConnections.wgsl?raw'
import particleAdvanceShaderCode from 'assets/particle-brain-gpu/shaders/compute/particleAdvance.wgsl?raw'
import particleAdvanceBrushShaderCode from 'assets/particle-brain-gpu/shaders/compute/particleAdvance_brush.wgsl?raw'
import particleCompactShaderCode from 'assets/particle-brain-gpu/shaders/compute/particleCompact.wgsl?raw'

import brainMutateShaderCode from 'assets/particle-brain-gpu/shaders/compute/brainMutate.wgsl?raw'
import brainStepShaderCode from 'assets/particle-brain-gpu/shaders/compute/brainStep.wgsl?raw'
import captureReleaseShaderCode from 'assets/particle-brain-gpu/shaders/compute/captureRelease.wgsl?raw'
import particleComputeForcesShaderCode from 'assets/particle-brain-gpu/shaders/compute/particleComputeForces.wgsl?raw'
import particleDrawShaderCode from 'assets/particle-brain-gpu/shaders/compute/particleDraw.wgsl?raw'
import particleEraseShaderCode from 'assets/particle-brain-gpu/shaders/compute/particleErase.wgsl?raw'
import particleSortShaderCode from 'assets/particle-brain-gpu/shaders/compute/particleSort.wgsl?raw'

import trackerCameraUpdateShaderCode from 'assets/particle-brain-gpu/shaders/compute/trackerCameraUpdate.wgsl?raw'

import trackerComputeShaderCode from 'assets/particle-brain-gpu/shaders/compute/trackerCompute.wgsl?raw'
import offscreenShaderCode from 'assets/particle-brain-gpu/shaders/render/offscreen_render_vertex.wgsl?raw'
import renderGlowShaderCode from 'assets/particle-brain-gpu/shaders/render/particle_render_glow.wgsl?raw'
import renderBinsShaderCode from 'assets/particle-brain-gpu/shaders/render/render_bins.wgsl?raw'
import renderBrushCircleShaderCode from 'assets/particle-brain-gpu/shaders/render/render_brush_circle.wgsl?raw'
import renderConnectionsShaderCode from 'assets/particle-brain-gpu/shaders/render/render_connections.wgsl?raw'
import renderInfiniteShaderCode from 'assets/particle-brain-gpu/shaders/render/render_infinite.wgsl?raw'

import renderMirrorShaderCode from 'assets/particle-brain-gpu/shaders/render/render_mirror.wgsl?raw'
import renderShaderCode from 'assets/particle-brain-gpu/shaders/render/render_normal.wgsl?raw'
import renderTrackerShaderCode from 'assets/particle-brain-gpu/shaders/render/render_tracker.wgsl?raw'
import { defineComponent, onMounted, ref } from 'vue'
import BrushSettings from "~/components/particle-life/BrushSettings.vue"

import CenterViewButton from "~/components/particle-life/CenterViewButton.vue"
import MatrixSettings from "~/components/particle-brain/MatrixSettings.vue"

import PresetPanel from "~/components/particle-life/PresetPanel.vue"
import RadiusVisualizer from "~/components/particle-life/RadiusVisualizer.vue"
import SaveModal from "~/components/particle-life/SaveModal.vue"
import TrackerOverlay from "~/components/particle-life/TrackerOverlay.vue"
import TrackerToggle from "~/components/particle-life/TrackerToggle.vue"
import UrgeInspector from "~/components/particle-brain/UrgeInspector.vue"
import WrapModeSelection from "~/components/particle-life/WrapModeSelection.vue"
import { hexToRgb } from '~/helpers/utils/colorConversion'
import { generateColors, PALETTE_OPTIONS } from "~/helpers/utils/colorsGenerator"
import { generatePositions, POSITION_OPTIONS } from "~/helpers/utils/positionsGeneratorBrain"
import { PARTICLE_STRIDE, PARTICLE_BYTES } from '~/constants/particleStride'
import { driftInteractionMatrix, measureControlGap, measureMatterEntropy, noveltyRate, scheduleNeuronDamage } from '~/helpers/utils/experimentMetrics'
import { assignCloneIds, compareUrgeRows, pruneCloneRegistry } from '~/helpers/utils/cloneIdentity'
import { generateRules, RULES_OPTIONS } from '~/helpers/utils/rulesGenerator'

export default defineComponent({
    name: 'ParticleLifeGpu',
    components: { PresetPanel, SaveModal, BrushSettings, MatrixSettings, WrapModeSelection, TrackerOverlay, TrackerToggle, CenterViewButton, RadiusVisualizer, UrgeInspector },
    emits: ['switch-renderer'],
    setup(props, { emit }) {
        // Define refs and variables
        const mainContainer = ref<HTMLElement | null>(null)
        const { isFullscreen, toggle: toggleFullscreen } = useFullscreen(mainContainer)
        const { success, error } = useToasts()
        const particleLife = useParticleBrainGPUStore()
        const rulesOptions = RULES_OPTIONS
        const paletteOptions = PALETTE_OPTIONS
        const positionOptions = POSITION_OPTIONS
        const fps = useFps()
        const executionTime = ref<number>(0)
        const canvasRef = ref<HTMLCanvasElement | null>(null)
        let ctx: GPUCanvasContext
        let DEVICE_PIXEL_RATIO: number = 1
        let animationFrameId: number | null = null
        let lastFrameTime: number = performance.now()
        let isRunning: boolean = particleLife.isRunning
        let isInitializing: boolean = true
        let isUpdatingParticles: boolean = false // Flag to prevent multiple additions at once
        let isUpdateNumParticlesPending: boolean = false
        let isUpdateNumTypesPending: boolean = false
        let isUpdateElectricalPending: boolean = false
        let hasUpdateNumParticles: boolean = false

        const displayedDeltaTime = ref<number>(1 / 60) // Reactive readout of the live auto Δt (refreshed only a few times/sec)
        let lastDisplayedDtUpdate: number = 0 // Throttle timestamp for the displayedDeltaTime UI readout
        let showLiveDeltaTime: boolean = particleLife.showLiveDeltaTime // Hidden by default: only refreshed/rendered when the user reveals it (avoids permanent reactivity)
        let manualDeltaTimeEnabled: boolean = particleLife.manualDeltaTimeEnabled // Override auto Δt with a fixed value
        let manualDeltaTime: number = particleLife.manualDeltaTime // Fixed Δt (seconds) used when manualDeltaTimeEnabled
        let smoothedDeltaTime: number = 0.0083 // Smoothed delta time (s) — fed to the shaders AND used for brush velocity

        let CANVAS_WIDTH: number = 0
        let CANVAS_HEIGHT: number = 0
        let SIM_WIDTH: number = 0
        let SIM_HEIGHT: number = 0
        let SIM_WIDTH_HALF: number = 0
        let SIM_HEIGHT_HALF: number = 0
        let CELL_SIZE: number = 0
        let CELL_SUBDIVISIONS: number = particleLife.cellSubdivisions
        let baseSimWidth: number = 0
        let baseSimHeight: number = 0
        let GRID_WIDTH: number = 0
        let GRID_HEIGHT: number = 0
        let binCount: number = 0
        let prefixSumIterations: number = 0

        let EXTENDED_GRID_WIDTH: number = 0
        let EXTENDED_GRID_HEIGHT: number = 0
        let GRID_OFFSET_X: number = 0
        let GRID_OFFSET_Y: number = 0
        let EXTENDED_SIM_WIDTH: number = 0
        let EXTENDED_SIM_HEIGHT: number = 0

        // Define color list and rules matrix for the particles
        let rulesMatrix: number[][] = [] // Rules matrix (numColors+2)×(numColors+2): matter + urge + neuron rows/cols
        let maxRadiusMatrix: number[][] = [] // Max radius matrix, same layout
        let minRadiusMatrix: number[][] = [] // Min radius matrix, same layout
        // The interaction matrix includes 2 extra types beyond matter: "urge" (row numColors)
        // and "neuron" (row numColors+1). All urges share the urge row; all neurons share the neuron row.
        const MATRIX_EXTRA_TYPES = 2
        let currentMaxRadius: number = 0 // Max value between all colors max radius (for cell size)

        // Define the simulation properties
        let initialParticles: Float32Array // Initial particle x, y, vx, vy, type
        let colors: Float32Array // Particle colors

        // Define the properties for dragging and zooming
        let zoomFactor: number = 1.0
        let targetZoomFactor: number = 1.0 // Target zoom factor for smooth zooming
        let zoomSmoothing: number = particleLife.zoomSmoothing // Smoothing factor for zooming
        let panSmoothing: number = particleLife.panSmoothing // Smoothing factor for panning
        let cameraCenter = { x: CANVAS_WIDTH / 2, y: CANVAS_HEIGHT / 2 }
        let targetCameraCenter = { x: CANVAS_WIDTH / 2, y: CANVAS_HEIGHT / 2 } // Target camera center for smooth movement
        let cameraScaleX: number = 1.0 // Scale factor for X axis
        let cameraScaleY: number = 1.0 // Scale factor for Y axis
        let isDragging: boolean = false // Flag to check if the mouse is being dragged
        let lastZoomPositionX: number = 0 // Last zoom position X for smooth zooming
        let lastZoomPositionY: number = 0 // Last zoom position Y for smooth zooming
        let lastPointerX: number = 0 // For dragging
        let lastPointerY: number = 0 // For dragging
        let pointerX: number = 0 // Pointer X
        let pointerY: number = 0 // Pointer Y
        let lastFramePointerX: number = 0
        let lastFramePointerY: number = 0
        let cameraChanged: boolean = true
        let infiniteTotalInstances: number = 0 // Total number of instances for infinite rendering

        // Define properties for the drift camera
        let isDriftCamActive: boolean = particleLife.isDriftCamActive // Enable drift camera mode (slow automatic movement)
        let driftCamResetOnPan: boolean = particleLife.driftCamResetOnPan // Reset drift camera trajectory when user pans/zooms
        const driftCamSmoothing: number = 0.0003 // Smoothing factor for camera movement (affects panning and zooming, 0.1 = fast, 0.01 = slow)
        let driftCamSpeed: number = particleLife.driftCamSpeed // Drift camera speed (0.1 = slow, 1.0 = fast)
        let driftCamAmplitude: number = particleLife.driftCamAmplitude // Amplitude of camera movement (0.5 = half the simulation size, 1.0 = full simulation size)
        let driftCamZoomRange: number[] = particleLife.driftCamZoomRange // Range of zoom levels for driftCam (min, max)
        let driftCamZoomCenter: number = (driftCamZoomRange[1] + driftCamZoomRange[0]) * 0.5 // Center zoom level for driftCam
        let driftCamZoomAmplitude: number = (driftCamZoomRange[1] - driftCamZoomRange[0]) * 0.5 // Amplitude of zoom changes for driftCam
        let driftCamTime: number = 0 // Time variable for the drift camera, incremented each frame based on the driftCamSpeed to create continuous movement
        let driftCamLastTime: number = 0 // Last timestamp when the drift camera was updated, used to calculate elapsed time for consistent movement regardless of frame rate
        let driftCamTransitionProgress: number = 0 // Smoothly blend camera position from its current location to the drift trajectory when driftCam is enabled, and reset to 0 whenever the user manually pans/zooms the camera, allowing for a seamless transition back to the drift movement
        let driftCamPhase = { x1: 0, x2: 0, y1: 0, y2: 0, z1: 0, z2: 0 } // Phase offsets for the sine waves controlling camera movement and zoom

        // Define variables for the simulation
        let repel: number = particleLife.repel // Repel force between particles
        let forceFactor: number = particleLife.forceFactor // Adjust the overall force applied between particles (can't be 0)
        let frictionFactor: number = particleLife.frictionFactor // Slow down the particles (0 to 1, where 0 is no friction)
        let NUM_PARTICLES: number = particleLife.numParticles
        // The matter count the user actually asked for. Special particles (urges/neurons/sense)
        // and the dormant clone pool are ADDED on top of this, so growing/shrinking the pool never steals
        // slots from real matter (which previously made ~numClonePool matter particles invisible).
        let baseMatterCount: number = NUM_PARTICLES
        let NEW_NUM_PARTICLES: number = NUM_PARTICLES
        let PARTICLE_SIZE: number = particleLife.particleSize
        let NUM_TYPES: number = particleLife.numColors // matter colors only
        let MATRIX_TYPES: number = NUM_TYPES + MATRIX_EXTRA_TYPES // total interaction matrix dimension
        let NEW_NUM_TYPES: number = NUM_TYPES
        // Quantum / electrical layer counts (each urge/neuron is a distinct type above the matter range)
        let numUrges: number = particleLife.numBrains
        let numNeurons: number = particleLife.numNeurons
        let numSenseNeurons: number = particleLife.numSenseNeurons // sense neurons (sensors; one target color each)
        let numClonePool: number = particleLife.numClonePool // dormant slots for the cloning system
        // Tracks the non-pool particle count (matter + urges + neurons + sense neurons) after the last
        // successful resize. Used to detect pool-only resizes at execution time (robust against watcher ordering).
        let lastNonPoolCount: number = baseMatterCount + numUrges + numNeurons + numSenseNeurons
        let isParticleGlow: boolean = particleLife.isParticleGlow // Enable glow effect for the particles
        let isDebugConnections: boolean = particleLife.isDebugConnections // Debug: draw urge<->neuron dotted lines
        let isAdditiveBlending = particleLife.isAdditiveBlending // Use additive blending for rendering particles
        let isWallRepel: boolean = particleLife.isWallRepel // Enable walls X and Y for the particles
        let isWallWrap: boolean = particleLife.isWallWrap // Enable wrapping for the particles
        let isMirrorWrap: boolean = particleLife.isMirrorWrap // Enable mirroring for the particles (only if isWallWrap is true)
        let isInfiniteMirrorWrap: boolean = particleLife.isInfiniteMirrorWrap // Enable infinite wrapping for the particles (only if isWallWrap is true)
        let mirrorWrapCount: number = particleLife.mirrorWrapCount // Number of mirrors to render if isMirrorWrap is true (5 or 9)
        let useSpatialHash: boolean = particleLife.useSpatialHash // Use spatial hash or brute force
        let isDebugBinsActive: boolean = particleLife.isDebugBinsActive // Flag to show/hide the bins
        let debugMaxParticleCount: number = particleLife.debugMaxParticleCount // Maximum number of particles for debugging purposes
        let isDebugHeatmapActive: boolean = particleLife.isDebugHeatmapActive // Flag to show/hide the heatmap

        let glowSize: number = particleLife.glowSize
        let glowIntensity: number = particleLife.glowIntensity
        let glowSteepness: number = particleLife.glowSteepness
        let particleOpacity: number = particleLife.particleOpacity

        let isBrushActive: boolean = particleLife.isBrushActive
        let isBrushErasing: boolean = false
        let isBrushDrawing: boolean = false
        let isApplyingBrushForce: boolean = false
        let isEraseCompletionPending: boolean = false
        let isEraseCompleting: boolean = false
        let brushType: number = particleLife.brushType // 0: Erase, 1: Draw, 2: Repulse, 3: Attract
        let brushes: number[] = particleLife.brushes
        let brushRadius: number = particleLife.brushRadius
        let brushIntensity: number = particleLife.brushIntensity
        let attractForce: number = -Math.abs(particleLife.attractForce)
        let repulseForce: number = particleLife.repulseForce
        let brushDirectionalForce: number = particleLife.brushDirectionalForce // Force applied in the direction of the brush movement
        let showBrushCircle: boolean = particleLife.showBrushCircle // Show the brush circle when using the brush

        // Define GPU resources
        let device: GPUDevice
        let currentPositionBuffer: GPUBuffer | undefined
        let nextPositionBuffer: GPUBuffer | undefined
        let velocityBuffer: GPUBuffer | undefined
        let typeBuffer: GPUBuffer | undefined
        let typeBufferPacked: GPUBuffer | undefined // Packed type buffer for compute shader
        let colorBuffer: GPUBuffer | undefined
        let deltaTimeBuffer: GPUBuffer | undefined
        let cameraBuffer: GPUBuffer | undefined
        let interactionMatrixBuffer: GPUBuffer | undefined

        let electricalOptionsBuffer: GPUBuffer | undefined // Urge/neuron (quantum-electrical) layer parameters
        let connDotsBuffer: GPUBuffer | undefined // debug connection dots (pos + color)
        let connCountBuffer: GPUBuffer | undefined // atomic count of emitted connection dots
        let simOptionsBuffer: GPUBuffer | undefined
        let particleHashesBuffer: GPUBuffer | undefined
        let cellHeadsBuffer: GPUBuffer | undefined
        let particleNextIndicesBuffer: GPUBuffer | undefined
        let glowOptionsBuffer: GPUBuffer | undefined
        let infiniteRenderOptionsBuffer: GPUBuffer | undefined
        let brushOptionsBuffer: GPUBuffer | undefined

        let binOffsetBuffer: GPUBuffer | undefined
        let binOffsetTempBuffer: GPUBuffer | undefined
        let particleBuffer: GPUBuffer | undefined
        let particleTempBuffer: GPUBuffer | undefined
        let binPrefixSumStepSizeBuffer: GPUBuffer | undefined

        let offscreenTexture: GPUTexture | undefined
        let offscreenTextureView: GPUTextureView
        let offscreenSampler: GPUSampler
        let hdrTexture: GPUTexture | undefined
        let hdrTextureView: GPUTextureView

        let renderPipeline: GPURenderPipeline
        // eslint-disable-next-line unused-imports/no-unused-vars
        let renderConnectionsPipeline: GPURenderPipeline // debug dotted urge<->neuron lines
        let renderGlowPipeline: GPURenderPipeline
        let renderCirclePipeline: GPURenderPipeline
        let renderMirrorPipeline: GPURenderPipeline
        let renderMirrorGlowPipeline: GPURenderPipeline
        let renderMirrorCirclePipeline: GPURenderPipeline
        let renderInfinitePipeline: GPURenderPipeline
        let renderInfiniteGlowPipeline: GPURenderPipeline
        let renderInfiniteCirclePipeline: GPURenderPipeline
        let renderOffscreenPipeline: GPURenderPipeline
        let composeInfinitePipeline: GPURenderPipeline
        let composeHdrPipeline: GPURenderPipeline
        let renderTrackerPipeline: GPURenderPipeline

        let renderPipelineAdditive: GPURenderPipeline
        let renderMirrorPipelineAdditive: GPURenderPipeline
        let renderInfinitePipelineAdditive: GPURenderPipeline
        let renderCirclePipelineAdditive: GPURenderPipeline
        let renderMirrorCirclePipelineAdditive: GPURenderPipeline
        let renderInfiniteCirclePipelineAdditive: GPURenderPipeline

        let binClearSizePipeline: GPUComputePipeline
        let binFillSizePipeline: GPUComputePipeline
        let binPrefixSumPipeline: GPUComputePipeline
        let particleSortClearSizePipeline: GPUComputePipeline
        let particleSortPipeline: GPUComputePipeline
        let bruteForceComputePipeline: GPUComputePipeline
        let particleComputeForcesPipeline: GPUComputePipeline
        let brainStepPipeline: GPUComputePipeline | undefined
        let brainValid = false // set true only after successful pipeline creation
        let genomeBuffer: GPUBuffer | undefined // per-brain genome (needs + weights), numBrains * GENOME_STRIDE floats
        let neuronOwnersBuffer: GPUBuffer | undefined // per-neuron ownership: [numSense + numMotor] u32 entries
        let neuronModsBuffer: GPUBuffer | undefined // per-motor-neuron drive output from brain forward pass
        let brainMetricsBuffer: GPUBuffer | undefined // per-brain per-need live metric (numBrains * K floats), written by brainStep for the inspector
        let brainOptsBuffer: GPUBuffer | undefined
        let brainBindGroup: GPUBindGroup
        let brainOptsBindGroup: GPUBindGroup
        let brainMutatePipeline: GPUComputePipeline | undefined
        let brainMutateBindGroup: GPUBindGroup
        let brainMutateOptsBindGroup: GPUBindGroup
        let brainMutateOptsBuffer: GPUBuffer | undefined
        let brainFrameCount = 0
        let captureReleasePipeline: GPUComputePipeline | undefined
        let captureReleaseBindGroup: GPUBindGroup
        let captureReleaseOptsBindGroup: GPUBindGroup
        let captureReleaseOptsBuffer: GPUBuffer | undefined
        // ---- Experiment buffers (damage) -------------------------
        let neuronHealthBuffer: GPUBuffer | undefined // per-neuron health [0..1]; < 0.5 = damaged (cannot actuate)
        let particleAdvancePipeline: GPUComputePipeline
        // eslint-disable-next-line unused-imports/no-unused-vars
        let debugConnectionsPipeline: GPUComputePipeline // emits debug connection dots
        let particleAdvanceBrushPipeline: GPUComputePipeline

        let particleBufferReadOnlyBindGroup: GPUBindGroup
        let binFillSizeBindGroup: GPUBindGroup
        let binPrefixSumBindGroup: GPUBindGroup[] = []
        let particleSortBindGroup: GPUBindGroup
        let bruteForceBindGroup: GPUBindGroup
        let particleComputeForcesBindGroup: GPUBindGroup
        let particleBufferBindGroup: GPUBindGroup
        let simOptionsBindGroup: GPUBindGroup
        let deltaTimeBindGroup: GPUBindGroup
        let cameraBindGroup: GPUBindGroup
        let offscreenTextureBindGroup: GPUBindGroup
        let composeHdrBindGroup: GPUBindGroup
        let glowOptionsBindGroup: GPUBindGroup
        let infiniteRenderOptionsBindGroup: GPUBindGroup
        let brushOptionsBindGroup: GPUBindGroup
        let electricalBindGroup: GPUBindGroup
        // eslint-disable-next-line unused-imports/no-unused-vars
        let connectionsComputeBindGroup: GPUBindGroup // debug lines compute (particles + dots + count)
        // eslint-disable-next-line unused-imports/no-unused-vars
        let connectionsRenderBindGroup: GPUBindGroup // debug lines render (dots + count)

        let particleBufferBindGroupLayout: GPUBindGroupLayout
        let binPrefixSumBindGroupLayout: GPUBindGroupLayout
        let particleBufferReadOnlyBindGroupLayout: GPUBindGroupLayout
        let binFillSizeBindGroupLayout: GPUBindGroupLayout
        let particleSortBindGroupLayout: GPUBindGroupLayout
        let bruteForceBindGroupLayout: GPUBindGroupLayout
        let particleComputeForcesBindGroupLayout: GPUBindGroupLayout
        let simOptionsBindGroupLayout: GPUBindGroupLayout
        let deltaTimeBindGroupLayout: GPUBindGroupLayout
        let electricalBindGroupLayout: GPUBindGroupLayout
        let connectionsComputeBindGroupLayout: GPUBindGroupLayout
        let connectionsRenderBindGroupLayout: GPUBindGroupLayout
        let cameraBindGroupLayout: GPUBindGroupLayout
        let offscreenTextureBindGroupLayout: GPUBindGroupLayout
        let composeHdrBindGroupLayout: GPUBindGroupLayout
        let glowOptionsBindGroupLayout: GPUBindGroupLayout
        let infiniteRenderOptionsBindGroupLayout: GPUBindGroupLayout
        let brushOptionsBindGroupLayout: GPUBindGroupLayout
        let trackerRenderBindGroupLayout: GPUBindGroupLayout

        let particleErasePipeline: GPUComputePipeline
        let particleCompactPipeline: GPUComputePipeline
        let particleEraseBindGroupLayout: GPUBindGroupLayout
        let particleCompactBindGroupLayout: GPUBindGroupLayout
        let particleEraseBindGroup: GPUBindGroup
        let particleCompactBindGroup: GPUBindGroup
        let particleKeepFlagsBuffer: GPUBuffer | undefined
        let newParticleCountBuffer: GPUBuffer | undefined
        let newParticleCountReadBuffer: GPUBuffer | undefined
        let particleCompactBuffer: GPUBuffer | undefined

        let particleDrawPipeline: GPUComputePipeline
        let particleDrawBindGroupLayout: GPUBindGroupLayout
        let particleDrawBindGroup: GPUBindGroup

        let brushesBuffer: GPUBuffer | undefined

        let renderBrushCirclePipeline: GPURenderPipeline
        let renderBrushCircleBindGroupLayout: GPUBindGroupLayout
        let renderBrushCircleBindGroup: GPUBindGroup

        let renderDebugBinsPipeline: GPURenderPipeline
        let renderDebugBinsBindGroupLayout: GPUBindGroupLayout
        let renderDebugBinsBindGroup: GPUBindGroup
        let debugOptionsBindGroupLayout: GPUBindGroupLayout
        let debugOptionsBindGroup: GPUBindGroup

        let heatmapTexture: GPUTexture | undefined
        let heatmapTextureView: GPUTextureView
        let heatmapSampler: GPUSampler

        let debugOptionsBuffer: GPUBuffer | undefined

        onMounted(async () => {
            await initWebGPU()
            await createHeatmapTexture()
            handleResize()
            setSimSizeBasedOnScreen()
            await initLife()

            useEventListener('resize', handleResize)
            useEventListener(canvasRef.value, ['mousedown'], (e) => {
                lastPointerX = (e.x - canvasRef.value!.getBoundingClientRect().left) * DEVICE_PIXEL_RATIO
                lastPointerY = (e.y - canvasRef.value!.getBoundingClientRect().top) * DEVICE_PIXEL_RATIO
                if (e.buttons === 2 && isBrushActive) { // if secondary button is pressed (right click)
                    if (brushType === 0)
                        isBrushErasing = true
                    else if (brushType === 1)
                        isBrushDrawing = true
                    else isApplyingBrushForce = true
                }
            })
            useEventListener(canvasRef.value, ['mousemove'], (e) => {
                pointerX = (e.x - canvasRef.value!.getBoundingClientRect().left) * DEVICE_PIXEL_RATIO
                pointerY = (e.y - canvasRef.value!.getBoundingClientRect().top) * DEVICE_PIXEL_RATIO

                if (e.buttons > 0) { // if mouse is pressed
                    if (particleLife.isLockedPointer)
                        return // Prevent canvas dragging if the pointer is locked
                    if (e.buttons === 1) { // if primary button is pressed (left click)
                        isDragging = true
                        handleMove()
                    }
                    if (e.buttons === 2 && isBrushActive) { // if secondary button is pressed (right click)
                        if (brushType === 0)
                            isBrushErasing = true
                        else if (brushType === 1)
                            isBrushDrawing = true
                        else isApplyingBrushForce = true
                    }
                }
                else if (e.buttons === 0) {
                    isDragging = false
                    isBrushErasing = false
                    isBrushDrawing = false
                    isApplyingBrushForce = false
                }
            })
            useEventListener(canvasRef.value, ['mouseup'], () => {
                if (isDragging && isDriftCamActive && driftCamResetOnPan)
                    initDriftCamera()
                isDragging = false
                isBrushErasing = false
                isBrushDrawing = false
                isApplyingBrushForce = false
            })
            useEventListener(canvasRef.value, 'mouseleave', () => {
                isDragging = false
                isBrushErasing = false
                isBrushDrawing = false
                isApplyingBrushForce = false
            })
            useEventListener(canvasRef.value, 'wheel', (e) => {
                if (e.deltaY < 0)
                    handleZoom(1) // Zoom in
                else handleZoom(-1) // Zoom out
                if (isDriftCamActive) {
                    driftCamTransitionProgress = 0 // Reset drift cam transition when user interacts with the camera
                    if (driftCamResetOnPan)
                        initDriftCamera()
                }
            })
        })
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        function handleResize() {
            DEVICE_PIXEL_RATIO = window.devicePixelRatio || 1
            CANVAS_WIDTH = canvasRef.value!.width = Math.round(canvasRef.value!.clientWidth * DEVICE_PIXEL_RATIO)
            CANVAS_HEIGHT = canvasRef.value!.height = Math.round(canvasRef.value!.clientHeight * DEVICE_PIXEL_RATIO)
            updateCameraScaleFactors()
            updateHdrTexture()
            cameraChanged = true
        }
        function updateCameraScaleFactors() {
            cameraScaleY = zoomFactor * 2.0 / CANVAS_HEIGHT
            cameraScaleX = cameraScaleY / (CANVAS_WIDTH / CANVAS_HEIGHT)
        }
        function setSimSizeBasedOnScreen() {
            particleLife.simWidth = SIM_WIDTH = baseSimWidth = CANVAS_WIDTH
            particleLife.simHeight = SIM_HEIGHT = baseSimHeight = CANVAS_HEIGHT
            SIM_WIDTH_HALF = SIM_WIDTH * 0.5
            SIM_HEIGHT_HALF = SIM_HEIGHT * 0.5
            updateCameraScaleFactors()
        }
        function setSimSize() {
            const oldWidth = SIM_WIDTH
            const oldHeight = SIM_HEIGHT
            if (useSpatialHash && isWallWrap) {
                particleLife.simWidth = SIM_WIDTH = CELL_SIZE * Math.round(baseSimWidth / CELL_SIZE)
                particleLife.simHeight = SIM_HEIGHT = CELL_SIZE * Math.round(baseSimHeight / CELL_SIZE)
            }
            SIM_WIDTH_HALF = SIM_WIDTH * 0.5
            SIM_HEIGHT_HALF = SIM_HEIGHT * 0.5
            updateCameraScaleFactors()
            // If the sim dimensions changed, flag camera as dirty so the GPU camera buffer
            // is synced on the next frame (prevents mismatch between infinite tile layout and camera transform).
            if (SIM_WIDTH !== oldWidth || SIM_HEIGHT !== oldHeight)
                cameraChanged = true
            updateBinningParameters()
            updateOffscreenMirrorResources()
            updateInfiniteRenderOptions()
        }
        const updateBinningParameters = () => {
            const oldBinCount = binCount
            const oldPrefixSumIterations = prefixSumIterations

            // If no walls, set a larger grid size for better performance
            if (!isWallWrap && !isWallRepel) {
                const requestedFactor = 16
                const maxWorkgroups = device.limits.maxComputeWorkgroupsPerDimension
                const maxBinCount = maxWorkgroups * 64
                const baseBinCount = Math.ceil(SIM_WIDTH / CELL_SIZE) * Math.ceil(SIM_HEIGHT / CELL_SIZE)
                const maxPossibleFactor = Math.sqrt(maxBinCount / baseBinCount)
                const safeFactor = Math.min(requestedFactor, maxPossibleFactor * 0.9)
                const extensionX = (SIM_WIDTH * safeFactor - SIM_WIDTH) / 2
                const extensionY = (SIM_HEIGHT * safeFactor - SIM_HEIGHT) / 2

                EXTENDED_SIM_WIDTH = SIM_WIDTH + (extensionX * 2)
                EXTENDED_SIM_HEIGHT = SIM_HEIGHT + (extensionY * 2)
                EXTENDED_GRID_WIDTH = Math.ceil(EXTENDED_SIM_WIDTH / CELL_SIZE)
                EXTENDED_GRID_HEIGHT = Math.ceil(EXTENDED_SIM_HEIGHT / CELL_SIZE)
                GRID_OFFSET_X = Math.ceil(extensionX / CELL_SIZE)
                GRID_OFFSET_Y = Math.ceil(extensionY / CELL_SIZE)
                GRID_WIDTH = Math.ceil(SIM_WIDTH / CELL_SIZE)
                GRID_HEIGHT = Math.ceil(SIM_HEIGHT / CELL_SIZE)
                binCount = EXTENDED_GRID_WIDTH * EXTENDED_GRID_HEIGHT
            }
            else {
                GRID_WIDTH = Math.ceil(SIM_WIDTH / CELL_SIZE)
                GRID_HEIGHT = Math.ceil(SIM_HEIGHT / CELL_SIZE)
                binCount = GRID_WIDTH * GRID_HEIGHT
            }
            prefixSumIterations = Math.ceil(Math.ceil(Math.log2(binCount + 1)) / 2) * 2

            if (device && (oldBinCount !== binCount || oldPrefixSumIterations !== prefixSumIterations)) {
                updateBinningBuffers()
                if (!isInitializing) {
                    updateBinningBindGroups()
                    updateParticleBindGroups()
                }
            }
        }
        function centerView() {
            cameraCenter = { x: SIM_WIDTH_HALF, y: SIM_HEIGHT_HALF }
            targetCameraCenter = { x: SIM_WIDTH_HALF, y: SIM_HEIGHT_HALF }
        }
        function smoothCenterView(position: boolean = true, zoom: boolean = true) {
            if (position)
                targetCameraCenter = { x: SIM_WIDTH_HALF, y: SIM_HEIGHT_HALF }
            if (zoom) {
                targetZoomFactor = Math.min(CANVAS_WIDTH / SIM_WIDTH, CANVAS_HEIGHT / SIM_HEIGHT)
                lastZoomPositionX = CANVAS_WIDTH / 2
                lastZoomPositionY = CANVAS_HEIGHT / 2
            }
        }
        function handleMove() {
            const dx = pointerX - lastPointerX
            const dy = pointerY - lastPointerY
            const worldDx = dx / (cameraScaleX * CANVAS_WIDTH * 0.5)
            const worldDy = dy / (cameraScaleY * CANVAS_HEIGHT * 0.5)
            if (isCameraTracking) {
                targetTrackerCameraOffset.x -= worldDx
                targetTrackerCameraOffset.y -= worldDy
            }
            else {
                targetCameraCenter.x -= worldDx
                targetCameraCenter.y -= worldDy
            }
            lastPointerX = pointerX
            lastPointerY = pointerY
        }
        const handleMoveSmoothing = () => {
            const panXDiff = targetCameraCenter.x - cameraCenter.x
            const panYDiff = targetCameraCenter.y - cameraCenter.y
            if (Math.abs(panXDiff) < 0.001 && Math.abs(panYDiff) < 0.001)
                return

            cameraCenter.x += panXDiff * panSmoothing
            cameraCenter.y += panYDiff * panSmoothing
            cameraChanged = true
        }
        function handleZoom(delta: number, isCentered: boolean = false) {
            lastZoomPositionX = isCentered ? cameraCenter.x : pointerX
            lastZoomPositionY = isCentered ? cameraCenter.y : pointerY
            const zoomIntensity = 0.1
            const zoomDelta = delta * zoomIntensity
            targetZoomFactor = Math.max(0.15, Math.min(1000.0, targetZoomFactor * (1 + zoomDelta)))
        }
        const handleZoomSmoothing = () => {
            const zoomDiff = targetZoomFactor - zoomFactor
            if (Math.abs(zoomDiff) < 0.001)
                return

            const mouseClipX = (lastZoomPositionX / CANVAS_WIDTH) * 2 - 1
            const mouseClipY = (lastZoomPositionY / CANVAS_HEIGHT) * 2 - 1

            const worldXBefore = cameraCenter.x + mouseClipX / cameraScaleX
            const worldYBefore = cameraCenter.y + mouseClipY / cameraScaleY

            zoomFactor += zoomDiff * zoomSmoothing
            updateCameraScaleFactors()

            const worldXAfter = cameraCenter.x + mouseClipX / cameraScaleX
            const worldYAfter = cameraCenter.y + mouseClipY / cameraScaleY

            const worldXCenter = worldXBefore - worldXAfter
            const worldYCenter = worldYBefore - worldYAfter
            cameraCenter.x += worldXCenter
            cameraCenter.y += worldYCenter
            targetCameraCenter.x += worldXCenter
            targetCameraCenter.y += worldYCenter

            cameraChanged = true
        }
        // -------------------------------------------------------------------------------------------------------------
        const initDriftCamera = () => {
            driftCamTransitionProgress = 0
            driftCamTime = 0
            driftCamLastTime = performance.now() / 1000

            const clamp = (v: number) => Math.max(-1, Math.min(1, v))
            // Calculates sine wave phase offsets so the drift camera starts smoothly from the current position without jumping and follows a "randomized" trajectory
            const findMatchingPhases = (target: number) => {
                const p2 = Math.random() * Math.PI * 2 // Random initial phase for the secondary wave
                const primaryWaveValue = (clamp(target) - Math.sin(p2) * 0.4) / 0.6 // Calculate the required phase for the primary wave to achieve the target position, given the random secondary wave phase and their respective amplitudes (0.6 and 0.4)
                const p1 = Math.asin(clamp(primaryWaveValue)) // Calculate the primary wave phase using arcsin, which gives a value between -π/2 and π/2. This ensures that the combined sine waves will start at the current camera position
                return { p1, p2 }
            }

            // Calculate the initial phases for X, Y, and Z (zoom) based on the current camera position and zoom level to ensure that when driftCam is enabled, the camera starts moving smoothly from its current position without any sudden jumps.
            const phasesX = findMatchingPhases((cameraCenter.x - SIM_WIDTH_HALF) / (SIM_WIDTH_HALF * driftCamAmplitude))
            const phasesY = findMatchingPhases((cameraCenter.y - SIM_HEIGHT_HALF) / (SIM_HEIGHT_HALF * driftCamAmplitude))
            const phasesZ = findMatchingPhases((zoomFactor - driftCamZoomCenter) / driftCamZoomAmplitude)

            driftCamPhase = { x1: phasesX.p1, x2: phasesX.p2, y1: phasesY.p1, y2: phasesY.p2, z1: phasesZ.p1, z2: phasesZ.p2 }
        }
        const handleDriftCamera = () => {
            const now = performance.now() / 1000
            if (isDragging) {
                driftCamLastTime = now // Update last time to prevent large jumps in camera position when the user stops dragging after a long interaction
                driftCamTransitionProgress = 0 // Reset transition when users pans to allow for a smooth blend back to the drift trajectory when they stop interacting
                return
            }

            driftCamTransitionProgress += (1 - driftCamTransitionProgress) * driftCamSmoothing // Progressive transition towards the drift trajectory after pans/zooms, creating a smooth blending effect
            driftCamTime += (now - driftCamLastTime) * driftCamSpeed // Increment the drift camera's internal time based on the elapsed real time and the configured speed, ensuring consistent movement regardless of frame rate variations
            driftCamLastTime = now

            // Drift pan movement only when tracking is disabled
            if (!isTrackerActive) {
                // Horizontal pan using two combined sine waves
                const driftTargetX = SIM_WIDTH_HALF + (
                    Math.sin(driftCamTime * 1.0 + driftCamPhase.x1) * 0.6 // Primary wave (60%), base freq
                    + Math.sin(driftCamTime * 1.618 + driftCamPhase.x2) * 0.4 // Secondary wave (40%), golden ratio freq
                ) * SIM_WIDTH_HALF * driftCamAmplitude

                // Vertical pan with offset frequencies for diagonal drift
                const driftTargetY = SIM_HEIGHT_HALF + (
                    Math.sin(driftCamTime * 1.1 + driftCamPhase.y1) * 0.6 // Primary wave (60%), slightly faster than X
                    + Math.sin(driftCamTime * 1.414 + driftCamPhase.y2) * 0.4 // Secondary wave (40%), sqrt(2) freq
                ) * SIM_HEIGHT_HALF * driftCamAmplitude

                // Smoothly interpolate camera center towards the drift targets
                targetCameraCenter.x += (driftTargetX - targetCameraCenter.x) * driftCamTransitionProgress
                targetCameraCenter.y += (driftTargetY - targetCameraCenter.y) * driftCamTransitionProgress
            }

            // Zoom level with slower frequencies for smooth transitions
            const driftTargetZoom = driftCamZoomCenter + (
                Math.sin(driftCamTime * 0.7 + driftCamPhase.z1) * 0.6 // Primary wave (60%), slow zoom
                + Math.sin(driftCamTime * 1.3 + driftCamPhase.z2) * 0.4 // Secondary wave (40%), faster variation
            ) * driftCamZoomAmplitude

            // Smoothly interpolate zoom towards the drift targets
            targetZoomFactor += (driftTargetZoom - targetZoomFactor) * driftCamTransitionProgress
        }
        const handleCameraTrackingMoveSmoothing = () => {
            if (!isDragging) {
                targetTrackerCameraOffset.x += (0 - targetTrackerCameraOffset.x) * panSmoothing
                targetTrackerCameraOffset.y += (0 - targetTrackerCameraOffset.y) * panSmoothing
            }

            const dx = targetTrackerCameraOffset.x - trackerCameraOffset.x
            const dy = targetTrackerCameraOffset.y - trackerCameraOffset.y
            if (Math.abs(dx) < 0.001 && Math.abs(dy) < 0.001) {
                if (!isDragging) {
                    trackerCameraOffset.x = 0
                    trackerCameraOffset.y = 0
                    targetTrackerCameraOffset.x = 0
                    targetTrackerCameraOffset.y = 0
                }
                return
            }
            trackerCameraOffset.x += dx * panSmoothing
            trackerCameraOffset.y += dy * panSmoothing
            device.queue.writeBuffer(trackerCameraOptionsBuffer!, 0, new Float32Array([
                trackerCameraOffset.x,
                trackerCameraOffset.y,
            ]))
        }
        const handleCameraTrackingZoomSmoothing = () => {
            const zoomDiff = targetZoomFactor - zoomFactor
            if (Math.abs(zoomDiff) < 0.001)
                return

            zoomFactor += zoomDiff * zoomSmoothing
            updateCameraScaleFactors()

            cameraChanged = true
        }
        // -------------------------------------------------------------------------------------------------------------
        // GPU Tracker buffers
        let trackerStateBuffer: GPUBuffer | undefined
        let trackerLevelsBuffer: GPUBuffer | undefined
        let trackerCameraOptionsBuffer: GPUBuffer | undefined
        let trackerAccumulatePipeline: GPUComputePipeline
        let trackerFinalizePipeline: GPUComputePipeline
        let trackerCameraUpdatePipeline: GPUComputePipeline
        let trackerComputeBindGroupLayout: GPUBindGroupLayout
        let trackerComputeBindGroup: GPUBindGroup
        let trackerCameraUpdateBindGroupLayout: GPUBindGroupLayout
        let trackerCameraUpdateBindGroup: GPUBindGroup
        let trackerRenderBindGroup: GPUBindGroup

        let isTrackerActive: boolean = particleLife.isTrackerActive
        let isTrackerCameraActive: boolean = particleLife.isTrackerCameraActive
        let isTrackerIndicatorVisible: boolean = particleLife.isTrackerIndicatorVisible
        let isCameraTracking: boolean = isTrackerActive && isTrackerCameraActive
        let trackerCameraOffset: { x: number, y: number } = { x: 0, y: 0 }
        let targetTrackerCameraOffset: { x: number, y: number } = { x: 0, y: 0 }

        const startTrackerSelection = () => {
            particleLife.isTrackerSelectionActive = true
            particleLife.isRunning = false // Pause the simulation while selecting the tracker zone
            particleLife.isBrushActive = false // Disable brush while selecting tracker zone
            particleLife.isDriftCamActive = false
        }
        const cancelTrackerSelection = () => {
            particleLife.isTrackerSelectionActive = false
            particleLife.isRunning = true // Resume the simulation if tracker selection is canceled
        }
        const stopTracker = async () => {
            if (isTrackerCameraActive)
                await syncCameraFromGPU()
            resetTrackerCameraOffset()
            particleLife.isTrackerActive = false
            particleLife.isTrackerSelectionActive = false
            particleLife.isDriftCamActive = false
        }
        const resetTrackerCameraOffset = () => {
            trackerCameraOffset = { x: 0, y: 0 }
            targetTrackerCameraOffset = { x: 0, y: 0 }
            device.queue.writeBuffer(trackerCameraOptionsBuffer!, 0, new Float32Array([0, 0]))
        }
        // Syncs CPU camera to GPU camera position (used when switching between tracker camera and free camera modes to prevent jumps)
        const syncCameraFromGPU = async () => {
            if (!cameraBuffer)
                return

            const arrayBuffer = await readBufferFromGPU(cameraBuffer, 16)
            const cameraData = new Float32Array(arrayBuffer)

            cameraCenter.x = targetCameraCenter.x = cameraData[0] // centerX
            cameraCenter.y = targetCameraCenter.y = cameraData[1] // centerY
            cameraChanged = true
        }
        const onTrackerZoneSelected = async (zone: { x: number, y: number, width: number, height: number }) => {
            const scaledX = zone.x * DEVICE_PIXEL_RATIO
            const scaledY = zone.y * DEVICE_PIXEL_RATIO
            const scaledWidth = zone.width * DEVICE_PIXEL_RATIO
            const scaledHeight = zone.height * DEVICE_PIXEL_RATIO

            const centerScreenX = scaledX + scaledWidth / 2
            const centerScreenY = scaledY + scaledHeight / 2

            // Convert screen coordinates to world coordinates
            const worldX = cameraCenter.x + (centerScreenX / CANVAS_WIDTH * 2 - 1) / cameraScaleX
            const worldY = cameraCenter.y + (centerScreenY / CANVAS_HEIGHT * 2 - 1) / cameraScaleY

            // Calculate the world size of the selected zone based on the current camera zoom level
            const worldWidth = (scaledWidth / CANVAS_WIDTH) * 2 / cameraScaleX
            const worldHeight = (scaledHeight / CANVAS_HEIGHT) * 2 / cameraScaleY

            const success = await initializeTrackerFromZone({ x: worldX, y: worldY, width: worldWidth, height: worldHeight })

            if (success)
                particleLife.isTrackerActive = true
            particleLife.isTrackerSelectionActive = false
            particleLife.isRunning = true
        }
        // Initialize tracker state based on a user-selected zone, calculating the center of mass
        const initializeTrackerFromZone = async (zone: { x: number, y: number, width: number, height: number }): Promise<boolean> => {
            // Read the current particle positions and velocities from the GPU to calculate the center of mass and average
            const arrayBuffer = await readBufferFromGPU(particleBuffer!, NUM_PARTICLES * PARTICLE_BYTES)
            const particles = new Float32Array(arrayBuffer)

            const zoneHalfW = zone.width * 0.5
            const zoneHalfH = zone.height * 0.5
            let sumX = 0; let sumY = 0; let sumVx = 0; let sumVy = 0; let count = 0

            // Get the center of mass and average velocity of particles within the selected zone
            for (let i = 0; i < NUM_PARTICLES; i++) {
                const idx = i * PARTICLE_STRIDE
                const px = particles[idx]
                const py = particles[idx + 1]

                if (Math.abs(px - zone.x) <= zoneHalfW && Math.abs(py - zone.y) <= zoneHalfH) {
                    sumX += px
                    sumY += py
                    sumVx += particles[idx + 2]
                    sumVy += particles[idx + 3]
                    count++
                }
            }

            if (count < 8) {
                error(`Not enough particles to track. <br> <b>${count}</b> found, <b>8</b> minimum.`)
                return false
            }

            // Calculate center of mass and average velocity for the selected particles
            const centerX = sumX / count
            const centerY = sumY / count
            const avgVx = sumVx / count
            const avgVy = sumVy / count

            // Determine the initial search radius
            const minRadius = Math.max(currentMaxRadius * 0.8, 16)
            const zoneRadius = Math.max(zoneHalfW, zoneHalfH)
            const initialSearchRadius = Math.max(zoneRadius, minRadius)

            // Initialize tracker state on GPU (32 bytes)
            const stateData = new ArrayBuffer(32)
            const view = new DataView(stateData)
            view.setFloat32(0, centerX, true) // x
            view.setFloat32(4, centerY, true) // y
            view.setFloat32(8, avgVx, true) // vx
            view.setFloat32(12, avgVy, true) // vy
            view.setFloat32(16, initialSearchRadius, true) // searchRadius
            view.setUint32(20, count, true) // expectedCount
            view.setFloat32(24, cameraCenter.x, true) // baseCameraX
            view.setFloat32(28, cameraCenter.y, true) // baseCameraY
            device.queue.writeBuffer(trackerStateBuffer!, 0, stateData)

            // Clear levels buffer
            device.queue.writeBuffer(trackerLevelsBuffer!, 0, new ArrayBuffer(32 * 4)) // 128 bytes for 4 levels

            if (isTrackerCameraActive) {
                targetCameraCenter.x = centerX
                targetCameraCenter.y = centerY
            }

            success(`Creature <b>locked</b> - now tracking.`)
            return true
        }
        const computeTracking = (encoder: GPUCommandEncoder) => {
            if (!trackerStateBuffer || !trackerLevelsBuffer)
                return

            const accumulatePass = encoder.beginComputePass()
            accumulatePass.setPipeline(trackerAccumulatePipeline)
            accumulatePass.setBindGroup(0, trackerComputeBindGroup)
            accumulatePass.setBindGroup(1, simOptionsBindGroup)
            accumulatePass.setBindGroup(2, deltaTimeBindGroup)
            accumulatePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 256))
            accumulatePass.end()

            const finalizePass = encoder.beginComputePass()
            finalizePass.setPipeline(trackerFinalizePipeline)
            finalizePass.setBindGroup(0, trackerComputeBindGroup)
            finalizePass.setBindGroup(1, simOptionsBindGroup)
            finalizePass.setBindGroup(2, deltaTimeBindGroup)
            finalizePass.dispatchWorkgroups(1)
            finalizePass.end()

            if (isTrackerCameraActive)
                computeTrackerCameraUpdate(encoder)
        }
        const computeTrackerCameraUpdate = (encoder: GPUCommandEncoder) => {
            const cameraUpdatePass = encoder.beginComputePass()
            cameraUpdatePass.setPipeline(trackerCameraUpdatePipeline)
            cameraUpdatePass.setBindGroup(0, trackerCameraUpdateBindGroup)
            cameraUpdatePass.dispatchWorkgroups(1)
            cameraUpdatePass.end()
        }
        const renderTrackerIndicator = (encoder: GPUCommandEncoder) => {
            const renderPass = encoder.beginRenderPass({
                colorAttachments: [{
                    view: ctx.getCurrentTexture().createView(),
                    loadOp: 'load',
                    storeOp: 'store',
                }],
            })
            renderPass.setPipeline(renderTrackerPipeline)
            renderPass.setBindGroup(0, cameraBindGroup)
            renderPass.setBindGroup(1, trackerRenderBindGroup)
            renderPass.setBindGroup(2, deltaTimeBindGroup)
            renderPass.setBindGroup(3, simOptionsBindGroup)
            renderPass.draw(4, 1, 0, 0)
            renderPass.end()
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const initWebGPU = async () => {
            const adapter = await navigator.gpu.requestAdapter({ powerPreference: 'high-performance' })
            if (!adapter)
                throw new Error("WebGPU adapter not found")
            // Bind-group budget: our force + brain + render shaders only ever use bind
            // groups 0-3 (four groups total). WebGPU's DEFAULT maxBindGroups limit is 4, and
            // browsers cap it at 4 in practice (the spec maximum is 8, but most devices expose
            // exactly 4), so requesting more than 4 makes requestDevice() throw and the entire
            // sim fails to load — no particles, black canvas.
            //
            // DO NOT raise this above 4. The regression test tests/wgslBindGroupLimit.test.ts
            // hard-errors if any shader declares @group(4)+ or if requiredLimits requests more
            // than 4, so a 5th group is caught at CI time. If you truly need one, consolidate
            // existing bind groups first instead of raising the cap.
            if ((adapter.limits.maxBindGroups ?? 4) < 4) {
                console.warn('[particle-life-gpu] GPU reports maxBindGroups < 4; the force shaders need 4 bind groups (0-3) and will not work on this device.')
            }
            device = await adapter.requestDevice({
                requiredLimits: {
                    // Keep at 4 — this is the browser cap, not a tunable. See comment above.
                    maxBindGroups: Math.min(4, adapter.limits.maxBindGroups ?? 4),
                },
            })
            ctx = canvasRef.value!.getContext('webgpu')!
            ctx.configure({
                device,
                format: navigator.gpu.getPreferredCanvasFormat(),
                alphaMode: 'opaque',
                colorSpace: 'srgb',
            })
        }
        const initLife = async (autoCenter: boolean = true) => {
            isInitializing = true
            // The buffer must hold the full layout: base matter + urges + neurons + clone pool.
            // Do this SYNCHRONOUSLY, before initParticles()/createBuffers() run, so every buffer
            // is created at the final size. (An async resize here would read back and rebuild the
            // particle buffers on frame 1, racing the render pass and leaving it black.)
            NUM_PARTICLES = baseMatterCount + numUrges + numNeurons + numSenseNeurons + numClonePool
            NEW_NUM_PARTICLES = NUM_PARTICLES
            if (NUM_PARTICLES !== particleLife.numParticles)
                particleLife.numParticles = NUM_PARTICLES
            // Main interaction matrix: (numColors+2)×(numColors+2) — matter + urge + neuron rows/cols.
            // The extra 2 rows/cols are for the shared "urge" and "neuron" types.
            setRulesMatrix(generateRules(0, MATRIX_TYPES))
            setMinRadiusMatrix(makeRandomMinRadiusMatrix())
            setMaxRadiusMatrix(makeRandomMaxRadiusMatrix())
            // setRulesMatrix([[-0.2758, -0.9341, -0.7292, -0.2024, -0.4367, -0.4714, -0.8962],[0.3548, -0.4365, -0.5117, -0.3945, -0.7828, 0.7885, 0.4696],[-0.9114, -0.8742, -0.5724, 0.1277, 0.3471, 0.3468, -0.6377],[0.3619, 0.6267, -0.6251, -0.1823, -0.285, -0.7255, 0.4615],[-0.2717, 0.9975, -0.4783, -0.9001, -0.2176, -0.9916, -0.4428],[-0.133, -0.342, -0.5631, 0.1238, -0.2723, -0.7484, 0.8461],[0.571, -0.7669, 0.0851, 0.5078, 0.8143, -0.7627, 0.7893]])
            // setMinRadiusMatrix([[25, 39, 37, 31, 31, 40, 30],[33, 27, 37, 33, 40, 33, 40],[26, 31, 25, 30, 32, 34, 39],[33, 27, 33, 39, 34, 25, 38],[28, 32, 31, 30, 40, 37, 30],[39, 39, 38, 35, 25, 31, 40],[33, 36, 29, 35, 30, 25, 40]])
            // setMaxRadiusMatrix([[65, 72, 80, 66, 72, 67, 79],[69, 61, 75, 73, 69, 70, 73],[80, 69, 71, 74, 67, 62, 61],[73, 79, 70, 70, 70, 72, 79],[67, 65, 74, 76, 64, 77, 71],[61, 68, 72, 64, 69, 64, 79],[72, 68, 77, 74, 63, 70, 75]])
            // particleLife.currentMaxRadius = 80

            console.log("Rules Matrix:", rulesMatrix)
            console.log("Min Radius Matrix:", minRadiusMatrix)
            console.log("Max Radius Matrix:", maxRadiusMatrix)

            await nextTick()
            if (autoCenter)
                centerView()

            initColors()
            initParticles()
            createBuffers()
            createBindGroupLayouts()
            createPipelines()
            createBindGroups()

            isInitializing = false
            lastFrameTime = performance.now()
            animationFrameId = requestAnimationFrame(frame)
        }
        const regenerateLife = async () => {
            if (isTrackerActive)
                await stopTracker()
            cancelAnimationLoop()
            destroyPipelinesAndBindGroups()
            await destroyBuffers(true)
            await initLife(false)
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // eslint-disable-next-line unused-imports/no-unused-vars
        const pendingFrames: number = 0
        const frame = async () => {
            // Wait for the GPU to finish processing before starting a new frame (to avoid overloading the GPU)
            // Produces flickering if the GPU is not fast enough
            // if (pendingFrames > 3) {
            //     animationFrameId = requestAnimationFrame(frame)
            //     return
            // }
            if (isDriftCamActive)
                handleDriftCamera()
            if (isCameraTracking) {
                handleCameraTrackingMoveSmoothing()
                handleCameraTrackingZoomSmoothing()
            }
            else {
                handleMoveSmoothing()
                handleZoomSmoothing()
            }

            if (isBrushActive && showBrushCircle)
                updateBrushOptionsBuffer()
            if (!isEraseCompleting) { // Prevent buffer mutations while async erase completion is pending
                if (isBrushErasing)
                    eraseWithBrush()
                else if (isEraseCompletionPending)
                    completeEraseWithBrush()
                else if (isBrushDrawing)
                    drawWithBrush()
                else if (isUpdateNumParticlesPending)
                    await updateNumParticles(NEW_NUM_PARTICLES)
                else if (isUpdateNumTypesPending)
                    await updateNumTypes(NEW_NUM_TYPES)
                else if (isUpdateElectricalPending)
                    await updateElectricalCounts()
            }

            applyNeuronDamage() // Opt-in neuron damage scheduling + health upload (no-op when off).
            const startExecutionTime = performance.now()
            if (isRunning && !isLifecycleInFlight) {
                // Pause simulation while the lifecycle check holds a buffer snapshot in memory.
                // Without this, the GPU keeps modifying particleBuffer during the async readback,
                // and the subsequent write-back reverts all frames computed in between.
                handleDeltaTime(startExecutionTime)
                step()
            }
            else {
                const encoder = device.createCommandEncoder()
                if (isCameraTracking)
                    computeTrackerCameraUpdate(encoder)
                computeDebugConnections(encoder) // Debug links still show while paused
                renderParticles(encoder)
                renderDebugConnections(encoder)
                if (isDebugBinsActive && useSpatialHash)
                    renderDebugBins(encoder)
                if (isBrushActive && showBrushCircle)
                    renderBrushCircle(encoder)
                if (isTrackerActive && isTrackerIndicatorVisible)
                    renderTrackerIndicator(encoder)
                device.queue.submit([encoder.finish()])
            }
            // device.queue.onSubmittedWorkDone().then(() => executionTime.value = performance.now() - startExecutionTime) // Approximate execution time of the GPU commands
            lastFramePointerX = pointerX
            lastFramePointerY = pointerY
            hasUpdateNumParticles = false

            // // Wait for the GPU to finish processing before starting a new frame
            // ++pendingFrames
            // device.queue.onSubmittedWorkDone().then(() => { --pendingFrames })

            updateUrgeMarker() // Move the on-canvas marker for the tracked urge (no GPU work).
            sampleExperimentTelemetry() // Opt-in throttled experiment metrics (no-op when off).
            applyEnvironmentDrift() // Opt-in periodic drift of matter×matter rules (no-op when off).
            animationFrameId = requestAnimationFrame(frame)
        }
        // -------------------------------------------------------------------------------------------------------------
        const DT_SMOOTHING_TAU: number = 1.0 // Smoothing time constant (s). Framerate-independent (1 - exp(-dt/tau)): same convergence time in wall-clock at any fps. Higher = steadier, lower = snappier.
        const handleDeltaTime = (startExecutionTime: number) => {
            const deltaTime = Math.min((startExecutionTime - lastFrameTime) / 1000, smoothedDeltaTime * 2) // Cap deltaTime to avoid spikes
            lastFrameTime = startExecutionTime
            const lastSmoothedDeltaTime = smoothedDeltaTime
            const smoothing = 1 - Math.exp(-deltaTime / DT_SMOOTHING_TAU)
            smoothedDeltaTime = smoothedDeltaTime * (1 - smoothing) + deltaTime * smoothing // Smooth the delta time

            if (showLiveDeltaTime && startExecutionTime - lastDisplayedDtUpdate > 400) {
                lastDisplayedDtUpdate = startExecutionTime
                displayedDeltaTime.value = smoothedDeltaTime
            }
            if (manualDeltaTimeEnabled)
                return

            // Only update the delta time buffer if it has changed significantly
            if (Math.round(lastSmoothedDeltaTime * 1000) !== Math.round(smoothedDeltaTime * 1000)) {
                updateDeltaTimeBuffer(smoothedDeltaTime)
            }
        }
        const updateDeltaTimeBuffer = (deltaTime: number) => {
            device.queue.writeBuffer(deltaTimeBuffer!, 0, new Float32Array([deltaTime, (1 - frictionFactor) ** (deltaTime * 60)]))
        }
        // -------------------------------------------------------------------------------------------------------------
        const step = () => {
            const encoder = device.createCommandEncoder()

            // ---- BRAIN STEP: per-brain forward pass + delta-rule learning ----
            // One workgroup per brain. Runs first so the force pass can read neuronMods.
            if (brainValid && particleLife.isElectricalEnabled && numUrges > 0) {
                const brainPass = encoder.beginComputePass()
                brainPass.setPipeline(brainStepPipeline!)
                brainPass.setBindGroup(0, brainBindGroup)
                brainPass.setBindGroup(1, brainOptsBindGroup)
                brainPass.dispatchWorkgroups(numUrges) // one workgroup per brain
                brainPass.end()
            }

            // ---- CAPTURE/RELEASE: organic neuron gain/loss (gated on frame counter) ----
            if (brainValid && captureReleasePipeline && particleLife.isElectricalEnabled && numUrges > 0) {
                device.queue.writeBuffer(captureReleaseOptsBuffer!, 20, new Uint32Array([brainFrameCount])) // frameCount
                const capPass = encoder.beginComputePass()
                capPass.setPipeline(captureReleasePipeline!)
                capPass.setBindGroup(0, captureReleaseBindGroup)
                capPass.setBindGroup(1, captureReleaseOptsBindGroup)
                capPass.dispatchWorkgroups(numUrges) // one workgroup per brain
                capPass.end()
            }

            if (!useSpatialHash) {
                encoder.copyBufferToBuffer(particleBuffer!, 0, particleTempBuffer!, 0, particleBuffer!.size)
            }
            if (useSpatialHash)
                computeBinning(encoder)
            else computeBruteForce(encoder)
            computeAdvance(encoder)

            // ---- BRAIN MUTATE: slow drift of genome NEEDS (not weights) ----
            if (brainValid && particleLife.isElectricalEnabled && numUrges > 0) {
                brainFrameCount++
                device.queue.writeBuffer(brainMutateOptsBuffer!, 4, new Uint32Array([brainFrameCount]))
                const mutatePass = encoder.beginComputePass()
                mutatePass.setPipeline(brainMutatePipeline!)
                mutatePass.setBindGroup(0, brainMutateBindGroup)
                mutatePass.setBindGroup(1, brainMutateOptsBindGroup)
                mutatePass.dispatchWorkgroups(numUrges) // one workgroup per brain
                mutatePass.end()
            }

            if (isTrackerActive)
                computeTracking(encoder)

            computeDebugConnections(encoder) // Debug links: emit urge<->neuron line dots (no-op when off)

            renderParticles(encoder)

            renderDebugConnections(encoder) // Debug links: draw the dotted lines on top of particles
            if (isDebugBinsActive && useSpatialHash)
                renderDebugBins(encoder)
            if (isBrushActive && showBrushCircle)
                renderBrushCircle(encoder)
            if (isTrackerActive && isTrackerIndicatorVisible)
                renderTrackerIndicator(encoder)

            device.queue.submit([encoder.finish()])
        }
        // -------------------------------------------------------------------------------------------------------------
        const computeBruteForce = (encoder: GPUCommandEncoder) => {
            const computePass = encoder.beginComputePass()
            computePass.setPipeline(bruteForceComputePipeline)
            computePass.setBindGroup(0, bruteForceBindGroup)
            computePass.setBindGroup(1, simOptionsBindGroup)
            computePass.setBindGroup(2, deltaTimeBindGroup)
            computePass.setBindGroup(3, electricalBindGroup)
            computePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
            computePass.end()
        }
        const computeBinning = (encoder: GPUCommandEncoder) => {
            const binningComputePass = encoder.beginComputePass()
            binningComputePass.setPipeline(binClearSizePipeline)
            binningComputePass.setBindGroup(0, particleBufferReadOnlyBindGroup)
            binningComputePass.setBindGroup(1, simOptionsBindGroup)
            binningComputePass.setBindGroup(2, binFillSizeBindGroup)
            binningComputePass.dispatchWorkgroups(Math.ceil((binCount + 1) / 64))

            binningComputePass.setPipeline(binFillSizePipeline)
            binningComputePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))

            binningComputePass.setPipeline(binPrefixSumPipeline)
            for (let i = 0; i < prefixSumIterations; ++i) {
                binningComputePass.setBindGroup(0, binPrefixSumBindGroup[i % 2], [i * 256])
                binningComputePass.dispatchWorkgroups(Math.ceil((binCount + 1) / 64))
            }

            binningComputePass.setPipeline(particleSortClearSizePipeline)
            binningComputePass.setBindGroup(0, particleSortBindGroup)
            binningComputePass.dispatchWorkgroups(Math.ceil((binCount + 1) / 64))

            binningComputePass.setPipeline(particleSortPipeline)
            binningComputePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
            binningComputePass.end()

            const forcesComputePass = encoder.beginComputePass()
            forcesComputePass.setPipeline(particleComputeForcesPipeline)
            forcesComputePass.setBindGroup(0, particleComputeForcesBindGroup)
            forcesComputePass.setBindGroup(1, simOptionsBindGroup)
            forcesComputePass.setBindGroup(2, deltaTimeBindGroup)
            forcesComputePass.setBindGroup(3, electricalBindGroup)
            forcesComputePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
            forcesComputePass.end()
        }
        const computeAdvance = (encoder: GPUCommandEncoder) => {
            if (isApplyingBrushForce) {
                if (!showBrushCircle)
                    updateBrushOptionsBuffer() // Condition prevents duplicate updates

                const advanceBrushComputePass = encoder.beginComputePass()
                advanceBrushComputePass.setPipeline(particleAdvanceBrushPipeline)
                advanceBrushComputePass.setBindGroup(0, particleBufferBindGroup)
                advanceBrushComputePass.setBindGroup(1, simOptionsBindGroup)
                advanceBrushComputePass.setBindGroup(2, deltaTimeBindGroup)
                advanceBrushComputePass.setBindGroup(3, brushOptionsBindGroup)
                advanceBrushComputePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
                advanceBrushComputePass.end()
            }
            else {
                const advanceComputePass = encoder.beginComputePass()
                advanceComputePass.setPipeline(particleAdvancePipeline)
                advanceComputePass.setBindGroup(0, particleBufferBindGroup)
                advanceComputePass.setBindGroup(1, simOptionsBindGroup)
                advanceComputePass.setBindGroup(2, deltaTimeBindGroup)
                advanceComputePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
                advanceComputePass.end()
            }
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const renderParticles = (encoder: GPUCommandEncoder) => {
            if (cameraChanged) {
                if (isCameraTracking) { // Only update zoom factors when tracking (position is handled by the tracker camera compute shader)
                    device.queue.writeBuffer(cameraBuffer!, 8, new Float32Array([cameraScaleX, cameraScaleY]))
                }
                else {
                    device.queue.writeBuffer(cameraBuffer!, 0, new Float32Array([
                        cameraCenter.x,
                        cameraCenter.y,
                        cameraScaleX,
                        cameraScaleY,
                    ]))
                }
                updateInfiniteRenderOptions()
                cameraChanged = false
            }

            if (isParticleGlow) {
                const hdrRenderPass = encoder.beginRenderPass({
                    colorAttachments: [{
                        view: hdrTextureView,
                        clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
                        loadOp: 'clear',
                        storeOp: 'store',
                    }],
                })
                hdrRenderPass.setBindGroup(0, particleBufferReadOnlyBindGroup)
                hdrRenderPass.setBindGroup(1, simOptionsBindGroup)
                hdrRenderPass.setBindGroup(2, cameraBindGroup)
                if (isMirrorWrap) {
                    hdrRenderPass.setBindGroup(3, glowOptionsBindGroup)
                    hdrRenderPass.setPipeline(renderMirrorGlowPipeline)
                    hdrRenderPass.draw(4, NUM_PARTICLES * mirrorWrapCount)
                    hdrRenderPass.setPipeline(isAdditiveBlending ? renderMirrorCirclePipelineAdditive : renderMirrorCirclePipeline)
                    hdrRenderPass.draw(4, NUM_PARTICLES * mirrorWrapCount)
                    hdrRenderPass.end()
                }
                else if (isInfiniteMirrorWrap) {
                    hdrRenderPass.setBindGroup(3, infiniteRenderOptionsBindGroup)
                    hdrRenderPass.setPipeline(renderInfiniteGlowPipeline)
                    hdrRenderPass.draw(4, infiniteTotalInstances)
                    hdrRenderPass.setPipeline(isAdditiveBlending ? renderInfiniteCirclePipelineAdditive : renderInfiniteCirclePipeline)
                    hdrRenderPass.draw(4, infiniteTotalInstances)
                    hdrRenderPass.end()
                }
                else {
                    hdrRenderPass.setBindGroup(3, glowOptionsBindGroup)
                    hdrRenderPass.setPipeline(renderGlowPipeline)
                    hdrRenderPass.draw(4, NUM_PARTICLES)
                    hdrRenderPass.setPipeline(isAdditiveBlending ? renderCirclePipelineAdditive : renderCirclePipeline)
                    hdrRenderPass.draw(4, NUM_PARTICLES)
                    hdrRenderPass.end()
                }
                const composePass = encoder.beginRenderPass({
                    colorAttachments: [{
                        view: ctx.getCurrentTexture().createView(),
                        loadOp: 'clear',
                        storeOp: 'store',
                    }],
                })
                composePass.setPipeline(composeHdrPipeline)
                composePass.setBindGroup(0, composeHdrBindGroup)
                composePass.draw(3)
                composePass.end()
            }
            else if (isMirrorWrap) {
                const renderPass = encoder.beginRenderPass({
                    colorAttachments: [{
                        view: ctx.getCurrentTexture().createView(),
                        loadOp: 'clear',
                        storeOp: 'store',
                        clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
                    }],
                })
                renderPass.setPipeline(isAdditiveBlending ? renderMirrorPipelineAdditive : renderMirrorPipeline)
                renderPass.setBindGroup(0, particleBufferReadOnlyBindGroup)
                renderPass.setBindGroup(1, simOptionsBindGroup)
                renderPass.setBindGroup(2, cameraBindGroup)
                renderPass.setBindGroup(3, glowOptionsBindGroup)
                renderPass.draw(4, NUM_PARTICLES * mirrorWrapCount)
                renderPass.end()
            }
            else if (isInfiniteMirrorWrap) {
                // renderInfiniteMirrorWithOffscreenTexture(encoder)

                const renderPass = encoder.beginRenderPass({
                    colorAttachments: [{
                        view: ctx.getCurrentTexture().createView(),
                        loadOp: 'clear',
                        clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
                        storeOp: 'store',
                    }],
                })
                renderPass.setPipeline(isAdditiveBlending ? renderInfinitePipelineAdditive : renderInfinitePipeline)
                renderPass.setBindGroup(0, particleBufferReadOnlyBindGroup)
                renderPass.setBindGroup(1, simOptionsBindGroup)
                renderPass.setBindGroup(2, cameraBindGroup)
                renderPass.setBindGroup(3, infiniteRenderOptionsBindGroup)
                renderPass.draw(4, infiniteTotalInstances)
                renderPass.end()
            }
            else {
                const renderPass = encoder.beginRenderPass({
                    colorAttachments: [{
                        view: ctx.getCurrentTexture().createView(),
                        loadOp: 'clear',
                        clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
                        storeOp: 'store',
                    }],
                })
                renderPass.setPipeline(isAdditiveBlending ? renderPipelineAdditive : renderPipeline)
                renderPass.setBindGroup(0, particleBufferReadOnlyBindGroup)
                renderPass.setBindGroup(1, simOptionsBindGroup)
                renderPass.setBindGroup(2, cameraBindGroup)
                renderPass.draw(4, NUM_PARTICLES)
                renderPass.end()
            }

        }
        // -------------------------------------------------------------------------------------------------------------
        // ---- Debug links: urge<->neuron dotted lines ----------------------------------
        // The debugConnections compute pass emits one soft dot per step of every
        // (urge, motor-neuron within neuronRadius) segment; render_connections draws them
        // as a light dotted line ON TOP of the particles. Zero-cost when off.
        const computeDebugConnections = (encoder: GPUCommandEncoder) => {
            if (!isDebugConnections || !particleLife.isElectricalEnabled || numUrges <= 0)
                return
            // Reset the dot counter before the dispatch (queue writes order before this encoder's submit).
            device.queue.writeBuffer(connCountBuffer!, 0, new Uint32Array([0]))
            const pass = encoder.beginComputePass()
            pass.setPipeline(debugConnectionsPipeline)
            pass.setBindGroup(0, connectionsComputeBindGroup)
            pass.setBindGroup(1, simOptionsBindGroup)
            pass.setBindGroup(2, electricalBindGroup)
            pass.dispatchWorkgroups(Math.ceil(numUrges / 64))
            pass.end()
        }
        const renderDebugConnections = (encoder: GPUCommandEncoder) => {
            if (!isDebugConnections || !particleLife.isElectricalEnabled || numUrges <= 0)
                return
            const pass = encoder.beginRenderPass({
                colorAttachments: [{
                    view: ctx.getCurrentTexture().createView(),
                    loadOp: 'load',
                    storeOp: 'store',
                }],
            })
            pass.setPipeline(renderConnectionsPipeline)
            pass.setBindGroup(0, connectionsRenderBindGroup)
            pass.setBindGroup(1, cameraBindGroup)
            pass.setBindGroup(2, simOptionsBindGroup)
            pass.draw(4, MAX_CONN_DOTS)
            pass.end()
        }
        // -------------------------------------------------------------------------------------------------------------
        const renderBrushCircle = (encoder: GPUCommandEncoder) => {
            const renderPass = encoder.beginRenderPass({
                colorAttachments: [{
                    view: ctx.getCurrentTexture().createView(),
                    loadOp: 'load',
                    storeOp: 'store',
                }],
            })
            renderPass.setPipeline(renderBrushCirclePipeline)
            renderPass.setBindGroup(0, cameraBindGroup)
            renderPass.setBindGroup(1, renderBrushCircleBindGroup)
            renderPass.draw(4, 1, 0, 0)
            renderPass.end()
        }
        // -------------------------------------------------------------------------------------------------------------
        const renderDebugBins = (encoder: GPUCommandEncoder) => {
            if (!isRunning && hasUpdateNumParticles) { // Compute binning for debug rendering only when not running so new particles are ordered correctly
                const binningComputePass = encoder.beginComputePass()
                binningComputePass.setPipeline(binClearSizePipeline)
                binningComputePass.setBindGroup(0, particleBufferReadOnlyBindGroup)
                binningComputePass.setBindGroup(1, simOptionsBindGroup)
                binningComputePass.setBindGroup(2, binFillSizeBindGroup)
                binningComputePass.dispatchWorkgroups(Math.ceil((binCount + 1) / 64))
                binningComputePass.setPipeline(binFillSizePipeline)
                binningComputePass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
                binningComputePass.setPipeline(binPrefixSumPipeline)
                for (let i = 0; i < prefixSumIterations; ++i) {
                    binningComputePass.setBindGroup(0, binPrefixSumBindGroup[i % 2], [i * 256])
                    binningComputePass.dispatchWorkgroups(Math.ceil((binCount + 1) / 64))
                }
                binningComputePass.end()
            }

            const renderPass = encoder.beginRenderPass({
                colorAttachments: [{
                    view: ctx.getCurrentTexture().createView(),
                    loadOp: 'load',
                    clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
                    storeOp: 'store',
                }],
            })
            renderPass.setPipeline(renderDebugBinsPipeline)
            renderPass.setBindGroup(0, renderDebugBinsBindGroup)
            renderPass.setBindGroup(1, debugOptionsBindGroup)
            renderPass.setBindGroup(2, simOptionsBindGroup)
            renderPass.setBindGroup(3, cameraBindGroup)
            renderPass.draw(4, binCount, 0, 0)
            renderPass.end()
        }
        // -------------------------------------------------------------------------------------------------------------
        // eslint-disable-next-line unused-imports/no-unused-vars
        const renderInfiniteMirrorWithOffscreenTexture = (encoder: GPUCommandEncoder) => {
            const renderOffscreenPass = encoder.beginRenderPass({
                colorAttachments: [{
                    view: offscreenTextureView,
                    loadOp: 'clear',
                    clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
                    storeOp: 'store',
                }],
            })
            renderOffscreenPass.setPipeline(renderOffscreenPipeline)
            renderOffscreenPass.setBindGroup(0, particleBufferReadOnlyBindGroup)
            renderOffscreenPass.setBindGroup(1, simOptionsBindGroup)
            renderOffscreenPass.draw(4, NUM_PARTICLES)
            renderOffscreenPass.end()

            const renderInfinitePass = encoder.beginRenderPass({
                colorAttachments: [{
                    view: ctx.getCurrentTexture().createView(),
                    loadOp: 'clear',
                    clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
                    storeOp: 'store',
                }],
            })
            renderInfinitePass.setPipeline(composeInfinitePipeline)
            renderInfinitePass.setBindGroup(0, cameraBindGroup)
            renderInfinitePass.setBindGroup(1, simOptionsBindGroup)
            renderInfinitePass.setBindGroup(2, offscreenTextureBindGroup)
            renderInfinitePass.draw(3, 1)
            renderInfinitePass.end()
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const updateElectricalOptionsBuffer = () => {
            // 72 bytes: the original 56 + sense-neuron fields at 52/56/60/64 + brainGain at 68 (see ElectricalOptions in particleComputeForces.wgsl)
            const data = new ArrayBuffer(72)
            const v = new DataView(data)
            v.setUint32(0, particleLife.isElectricalEnabled ? 1 : 0, true)
            v.setUint32(4, 0, true) // metricMode: deprecated (goal modes gone)
            v.setUint32(8, numUrges, true)
            v.setUint32(12, numNeurons, true)
            v.setFloat32(16, particleLife.urgeRadius, true)
            v.setFloat32(20, particleLife.neuronRadius, true) // repurposed: capture radius
            v.setFloat32(24, particleLife.urgeForce, true)
            v.setFloat32(28, 0, true) // controlGain: deprecated (no per-frame control learning)
            v.setFloat32(32, 0, true) // controlMax: deprecated
            v.setFloat32(36, 0, true) // neuronInfluence: legacy unused
            v.setFloat32(40, 0, true) // neuronAuthority: legacy unused
            v.setFloat32(44, 0, true) // maxAuthority: legacy unused
            v.setFloat32(48, particleLife.cohesion, true)
            // Sense-neuron fields (must match the WGSL ElectricalOptions struct field order)
            v.setUint32(52, numSenseNeurons, true)
            v.setFloat32(56, particleLife.senseRadius, true)
            v.setFloat32(60, particleLife.senseConeHalfAngleDeg * Math.PI / 180, true) // radians
            v.setUint32(64, particleLife.senseMode, true)
            // brainGain is appended at the END (offset 68) so no existing offset shifts. Must match the WGSL struct field order.
            v.setFloat32(68, particleLife.brainGain, true)

            if (!electricalOptionsBuffer) {
                electricalOptionsBuffer = device.createBuffer({
                    size: data.byteLength,
                    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                    mappedAtCreation: true,
                })
                new Uint8Array(electricalOptionsBuffer.getMappedRange()).set(new Uint8Array(data))
                electricalOptionsBuffer.unmap()
            }
            else {
                device.queue.writeBuffer(electricalOptionsBuffer, 0, data)
            }
        }
        const MAX_CONN_DOTS: number = 32768 // must match MAX_CONN_DOTS in debugConnections.wgsl
        const CONN_DOT_STRIDE: number = 24 // ConnDot { pos: vec2f; col: vec3f } -> 24 bytes array stride
        const createConnectionBuffers = () => {
            if (connDotsBuffer)
                connDotsBuffer.destroy(); connDotsBuffer = undefined
            if (connCountBuffer)
                connCountBuffer.destroy(); connCountBuffer = undefined
            connDotsBuffer = device.createBuffer({
                size: MAX_CONN_DOTS * CONN_DOT_STRIDE,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
            })
            connCountBuffer = device.createBuffer({
                size: 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
            })
        }
        const createBuffers = () => {
            updateSimOptionsBuffer() // Set simulation options based on the store state
            updateAllInteractionBuffers() // Set matter + electrical interaction matrices from the store state
            updateElectricalOptionsBuffer() // Urge/neuron (quantum-electrical) layer parameters
            createConnectionBuffers() // Debug urge<->neuron line buffers
            updateParticleBuffers(true)
            updateBrainBuffers()
            updateEraseCompactBuffers()
            updateBinningBuffers()
            updateColorBuffer()
            updateGlowOptionsBuffer()
            updateBrushOptionsBuffer()
            updateBrushesBuffer()
            updateDebugOptionsBuffer()
            createTrackerComputeBuffers()
            // ----------------------------------------------------------------------------------------------
            const cameraData = new Float32Array([cameraCenter.x, cameraCenter.y, cameraScaleX, cameraScaleY])
            cameraBuffer = device.createBuffer({
                size: cameraData.byteLength,
                usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC,
                mappedAtCreation: true,
            })
            new Float32Array(cameraBuffer.getMappedRange()).set(cameraData)
            cameraBuffer.unmap()

            deltaTimeBuffer = device.createBuffer({
                size: 8, // [deltaTime, friction] -> friction = pre-computed pow(1 - frictionFactor, deltaTime * 60)
                usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                mappedAtCreation: true,
            })
            new Float32Array(deltaTimeBuffer.getMappedRange()).set([smoothedDeltaTime, (1 - frictionFactor) ** (smoothedDeltaTime * 60)])
            deltaTimeBuffer.unmap()

            const infiniteRenderOptionsData = new Int32Array(4) // startX, startY, numCopiesX, numCopiesY
            infiniteRenderOptionsBuffer = device.createBuffer({
                size: infiniteRenderOptionsData.byteLength,
                usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                mappedAtCreation: true,
            })
            new Int32Array(infiniteRenderOptionsBuffer.getMappedRange()).set(infiniteRenderOptionsData)
            infiniteRenderOptionsBuffer.unmap()
            updateInfiniteRenderOptions()

            newParticleCountBuffer = device.createBuffer({
                size: 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC,
            })
            newParticleCountReadBuffer = device.createBuffer({
                size: 4,
                usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
            })
        }
        const updateColorBuffer = () => {
            const paddedSize = Math.ceil(colors.byteLength / 16) * 16 // Ensure padded to 16 bytes
            if (!colorBuffer || colorBuffer.size !== paddedSize) {
                if (colorBuffer)
                    colorBuffer?.destroy(); colorBuffer = undefined
                colorBuffer = device.createBuffer({
                    size: paddedSize,
                    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
                    mappedAtCreation: true,
                })
                new Float32Array(colorBuffer.getMappedRange()).set(colors)
                colorBuffer.unmap()
            }
            else {
                const paddedColors = new Float32Array(paddedSize / 4)
                paddedColors.set(colors)
                device.queue.writeBuffer(colorBuffer!, 0, paddedColors)
            }
        }
        const updateParticleBuffers = (hasInitialParticles: boolean = false) => {
            if (particleBuffer)
                particleBuffer?.destroy(); particleBuffer = undefined
            if (particleTempBuffer)
                particleTempBuffer?.destroy(); particleTempBuffer = undefined

            particleBuffer = device.createBuffer({
                size: NUM_PARTICLES * PARTICLE_BYTES, // 11 floats: x,y,vx,vy,type,control,signal,goalB,driveTarget,driveScale,driveGain
                usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC | GPUBufferUsage.STORAGE,
                mappedAtCreation: hasInitialParticles,
            })
            if (hasInitialParticles) {
                new Float32Array(particleBuffer.getMappedRange()).set(initialParticles)
                particleBuffer.unmap()
            }
            particleTempBuffer = device.createBuffer({
                size: particleBuffer.size,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
            })
        }
        // ---- BRAIN BUFFERS: per-brain genome (needs + private net) + neuron ownership ----
        const GENOME_K = 8 // needs per brain
        const GENOME_W_BUDGET = 1024 // weight budget per brain
        const GENOME_NEEDS_SIZE = GENOME_K * 4 // 32 floats for needs
        const GENOME_STRIDE = GENOME_NEEDS_SIZE + GENOME_W_BUDGET // 1056 floats/brain
        const NEURON_HEALTH_CAPACITY = 2000 // UI max for numNeurons; sizes the damage health buffer
        const MAX_NEURONS_PER_BRAIN = 16 // cap on S and M per brain (keeps W_used < 1024)

        const updateBrainBuffers = () => {
            if (genomeBuffer) genomeBuffer.destroy()
            if (neuronOwnersBuffer) neuronOwnersBuffer.destroy()
            if (neuronModsBuffer) neuronModsBuffer.destroy()
            if (brainMetricsBuffer) brainMetricsBuffer.destroy()
            if (brainOptsBuffer) brainOptsBuffer.destroy()
            if (neuronHealthBuffer) neuronHealthBuffer.destroy()
            if (captureReleaseOptsBuffer) captureReleaseOptsBuffer.destroy()

            // Genome buffer: numBrains * GENOME_STRIDE floats, initialized with random needs + small weights
            const genomeSize = numUrges * GENOME_STRIDE
            // COPY_SRC so the inspector can map it back (copyBufferToBuffer needs a copy source).
            genomeBuffer = device.createBuffer({
                size: genomeSize * 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC,
            })
            // Initialize each brain's genome: DISTINCT needs + small-random weights.
            // Every brain gets its own shuffled color palette (its "diet") and varied
            // setpoints, so brains have genuinely different goals — a precondition for
            // merge/death to mean anything in terms of utility.
            const genomeData = new Float32Array(genomeSize)
            for (let b = 0; b < numUrges; b++) {
                const base = b * GENOME_STRIDE
                // Shuffle the color palette so each brain wants a different mix of colors.
                const palette = Array.from({ length: NUM_TYPES }, (_, c) => c)
                for (let i = palette.length - 1; i > 0; i--) {
                    const j = Math.floor(Math.random() * (i + 1))
                    ;[palette[i], palette[j]] = [palette[j], palette[i]]
                }
                // Needs: K=8, each { targetColor(u32-as-f32), setpoint, scale, gain }
                for (let k = 0; k < GENOME_K; k++) {
                    const nb = base + k * 4
                    genomeData[nb] = palette[k % NUM_TYPES] // distinct target color per brain
                    genomeData[nb + 1] = 0.3 + Math.random() * 1.7 // setpoint [0.3, 2.0] — varied intensity
                    genomeData[nb + 2] = 0.3 + Math.random() * 0.5 // scale [0.3, 0.8]
                    genomeData[nb + 3] = 0.5 + Math.random() * 1.0 // gain [0.5, 1.5]
                }
                // Weights: small random init (±0.3)
                for (let w = GENOME_NEEDS_SIZE; w < GENOME_STRIDE; w++) {
                    genomeData[base + w] = (Math.random() - 0.5) * 0.6
                }
            }
            device.queue.writeBuffer(genomeBuffer, 0, genomeData)

            // Neuron ownership: [numSenseNeurons + numNeurons] u32 entries, all FREE (0xFFFFFFFF)
            const totalNeurons = numSenseNeurons + numNeurons
            // COPY_SRC so the inspector can map ownership back.
            neuronOwnersBuffer = device.createBuffer({
                size: totalNeurons * 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC,
            })
            const ownersData = new Uint32Array(totalNeurons).fill(0xFFFFFFFF)
            device.queue.writeBuffer(neuronOwnersBuffer, 0, ownersData)

            // Neuron modulations output: numNeurons floats (one per motor neuron).
            // COPY_SRC so the inspector can read back the live net outputs.
            neuronModsBuffer = device.createBuffer({
                size: Math.max(numNeurons, 1) * 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
            })

            // Per-neuron health buffer (damage experiment)
            neuronHealthBuffer = device.createBuffer({
                size: NEURON_HEALTH_CAPACITY * 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
            })
            device.queue.writeBuffer(neuronHealthBuffer, 0, new Float32Array(NEURON_HEALTH_CAPACITY).fill(1))

            // Per-brain per-need live metric buffer (numBrains * K floats), written by brainStep each frame.
            // Sized for COPY_SRC so the inspector can map it back. Zeroed until the first brain pass runs.
            brainMetricsBuffer = device.createBuffer({
                size: Math.max(numUrges, 1) * GENOME_K * 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
            })
            device.queue.writeBuffer(brainMetricsBuffer, 0, new Float32Array(Math.max(numUrges, 1) * GENOME_K))

            // Brain step opts uniform: numBrains, numNeurons, numSenseNeurons, numTypes (4 u32s = 16 bytes)
            // + learnRate(f32), simWidth(f32), simHeight(f32), urgeRadius(f32) = 32 bytes total
            brainOptsBuffer = device.createBuffer({
                size: 32,
                usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
            })
            const optsData = new ArrayBuffer(32)
            const ov = new DataView(optsData)
            ov.setUint32(0, numUrges, true)       // numBrains
            ov.setUint32(4, numNeurons, true)     // numNeurons (motor)
            ov.setUint32(8, numSenseNeurons, true) // numSenseNeurons
            ov.setUint32(12, NUM_TYPES, true)     // numTypes
            ov.setFloat32(16, particleLife.brainLearnRate, true) // learnRate
            ov.setFloat32(20, SIM_WIDTH, true)     // simWidth
            ov.setFloat32(24, SIM_HEIGHT, true)    // simHeight
            ov.setFloat32(28, particleLife.urgeRadius, true)       // urgeRadius
            device.queue.writeBuffer(brainOptsBuffer, 0, optsData)

            // Brain mutate opts: numBrains, frameCount (2 u32s = 8 bytes)
            if (brainMutateOptsBuffer) brainMutateOptsBuffer.destroy()
            brainMutateOptsBuffer = device.createBuffer({
                size: 8,
                usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
            })
            const mutateOptsData = new Uint32Array([numUrges, 0])
            device.queue.writeBuffer(brainMutateOptsBuffer, 0, mutateOptsData)

            // Capture release opts: numBrains, numNeurons, numSenseNeurons, captureRadius(f32), maxPerBrain, frameCount, captureInterval = 28 bytes (pad to 32)
            if (captureReleaseOptsBuffer) captureReleaseOptsBuffer.destroy()
            captureReleaseOptsBuffer = device.createBuffer({
                size: 32,
                usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
            })
            const capData = new ArrayBuffer(32)
            const cv = new DataView(capData)
            cv.setUint32(0, numUrges, true)         // numBrains
            cv.setUint32(4, numNeurons, true)       // numNeurons (motor)
            cv.setUint32(8, numSenseNeurons, true)  // numSenseNeurons
            cv.setFloat32(12, particleLife.neuronRadius, true) // captureRadius
            cv.setUint32(16, MAX_NEURONS_PER_BRAIN, true)     // maxPerBrain
            cv.setUint32(20, 0, true)               // frameCount (updated per dispatch below)
            cv.setUint32(24, 600, true)             // captureInterval (~10s at 60fps)
            cv.setUint32(28, NUM_TYPES, true)       // numTypes (special types start here)
            device.queue.writeBuffer(captureReleaseOptsBuffer, 0, capData)

            // Initialize neuron ownership: give each brain a starter set of 1-2 sense + 1-2 motor neurons.
            // The rest stay FREE (0xFFFFFFFF) for organic capture over time.
            if (numUrges > 0 && (numSenseNeurons > 0 || numNeurons > 0)) {
                const owners = new Uint32Array(numSenseNeurons + numNeurons).fill(0xFFFFFFFF)
                // Assign starter neurons: brain b gets sense neurons [b*2, b*2+1) and motor neurons [b*2, b*2+1)
                for (let b = 0; b < numUrges; b++) {
                    // 1-2 sense neurons (use 2 if available, else 1)
                    const sStart = b * 2
                    for (let s = 0; s < 2 && (sStart + s) < numSenseNeurons; s++) {
                        owners[sStart + s] = b
                    }
                    // 1-2 motor neurons
                    const mStart = b * 2
                    for (let m = 0; m < 2 && (mStart + m) < numNeurons; m++) {
                        owners[numSenseNeurons + mStart + m] = b
                    }
                }
                device.queue.writeBuffer(neuronOwnersBuffer, 0, owners)
            }
        }

        const updateEraseCompactBuffers = () => {
            if (particleKeepFlagsBuffer)
                particleKeepFlagsBuffer.destroy(); particleKeepFlagsBuffer = undefined
            if (particleCompactBuffer)
                particleCompactBuffer.destroy(); particleCompactBuffer = undefined
            particleKeepFlagsBuffer = device.createBuffer({
                size: NUM_PARTICLES * 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
            })
            particleCompactBuffer = device.createBuffer({
                size: NUM_PARTICLES * PARTICLE_BYTES,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
            })
        }
        const updateBinningBuffers = () => {
            if (binOffsetBuffer)
                binOffsetBuffer.destroy(); binOffsetBuffer = undefined
            if (binOffsetTempBuffer)
                binOffsetTempBuffer.destroy(); binOffsetTempBuffer = undefined
            if (binPrefixSumStepSizeBuffer)
                binPrefixSumStepSizeBuffer.destroy(); binPrefixSumStepSizeBuffer = undefined

            binOffsetBuffer = device.createBuffer({
                size: (binCount + 1) * 4,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
            })
            binOffsetTempBuffer = device.createBuffer({
                size: (binCount + 1) * 4,
                usage: GPUBufferUsage.STORAGE,
            })

            const binPrefixSumStepSize = new Uint32Array(prefixSumIterations * 64)
            for (let i = 0; i < prefixSumIterations; ++i) {
                binPrefixSumStepSize[i * 64] = 2 ** i
            }
            binPrefixSumStepSizeBuffer = device.createBuffer({
                size: prefixSumIterations * 256,
                usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.UNIFORM,
                mappedAtCreation: true,
            })
            new Uint32Array(binPrefixSumStepSizeBuffer.getMappedRange()).set(binPrefixSumStepSize)
            binPrefixSumStepSizeBuffer.unmap()
        }
        // -------------------------------------------------------------------------------------------------------------
        const updateBrushesBuffer = () => {
            if (brushesBuffer)
                brushesBuffer.destroy(); brushesBuffer = undefined

            const selectedTypes = new Uint32Array(brushes)
            const bufferSize = 8 + selectedTypes.byteLength

            brushesBuffer = device.createBuffer({
                size: bufferSize,
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
            })

            device.queue.writeBuffer(brushesBuffer, 0, new Uint32Array([selectedTypes.length]))
            if (selectedTypes.length > 0) {
                device.queue.writeBuffer(brushesBuffer, 4, selectedTypes)
            }
            if (brushOptionsBindGroup)
                updateBrushesBindGroup()
        }
        const updateBrushOptionsBuffer = () => {
            const brushClipX = pointerX / CANVAS_WIDTH * 2 - 1
            const brushClipY = pointerY / CANVAS_HEIGHT * 2 - 1
            const deltaTime = manualDeltaTimeEnabled ? manualDeltaTime : smoothedDeltaTime
            const brushVx = (pointerX - lastFramePointerX) / (cameraScaleX * CANVAS_WIDTH * 0.5) / deltaTime
            const brushVy = (pointerY - lastFramePointerY) / (cameraScaleY * CANVAS_HEIGHT * 0.5) / deltaTime

            const brushForce = brushType === 1 ? brushIntensity : brushType === 2 ? repulseForce : attractForce

            const brushOptionsData = new ArrayBuffer(28)
            const brushOptionsView = new DataView(brushOptionsData)
            brushOptionsView.setFloat32(0, brushClipX, true)
            brushOptionsView.setFloat32(4, brushClipY, true)
            brushOptionsView.setFloat32(8, brushVx, true)
            brushOptionsView.setFloat32(12, brushVy, true)
            brushOptionsView.setFloat32(16, brushRadius, true)
            brushOptionsView.setFloat32(20, brushForce, true)
            brushOptionsView.setFloat32(24, brushDirectionalForce, true)

            if (!brushOptionsBuffer) {
                brushOptionsBuffer = device.createBuffer({
                    size: brushOptionsData.byteLength,
                    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                    mappedAtCreation: true,
                })
                new Uint8Array(brushOptionsBuffer.getMappedRange()).set(new Uint8Array(brushOptionsData))
                brushOptionsBuffer.unmap()
            }
            else {
                device.queue.writeBuffer(brushOptionsBuffer, 0, brushOptionsData)
            }
        }
        const updateInfiniteRenderOptions = () => {
            if (!isInfiniteMirrorWrap)
                return

            const viewWidth = 2.0 / cameraScaleX
            const viewHeight = 2.0 / cameraScaleY

            const viewLeft = cameraCenter.x - viewWidth / 2
            const viewRight = cameraCenter.x + viewWidth / 2
            const viewTop = cameraCenter.y - viewHeight / 2
            const viewBottom = cameraCenter.y + viewHeight / 2

            const startX = Math.floor(viewLeft / SIM_WIDTH)
            const endX = Math.ceil(viewRight / SIM_WIDTH)
            const startY = Math.floor(viewTop / SIM_HEIGHT)
            const endY = Math.ceil(viewBottom / SIM_HEIGHT)

            const numCopiesX = endX - startX
            const numCopiesY = endY - startY

            infiniteTotalInstances = NUM_PARTICLES * numCopiesX * numCopiesY

            device.queue.writeBuffer(infiniteRenderOptionsBuffer!, 0, new Int32Array([startX, startY, numCopiesX, numCopiesY]))
        }
        const updateGlowOptionsBuffer = () => {
            const glowOptionsData = new ArrayBuffer(12)
            const glowOptionsView = new DataView(glowOptionsData)
            glowOptionsView.setFloat32(0, glowSize, true)
            glowOptionsView.setFloat32(4, glowIntensity, true)
            glowOptionsView.setFloat32(8, glowSteepness, true)

            if (!glowOptionsBuffer) {
                glowOptionsBuffer = device.createBuffer({
                    size: glowOptionsData.byteLength,
                    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                    mappedAtCreation: true,
                })
                new Uint8Array(glowOptionsBuffer.getMappedRange()).set(new Uint8Array(glowOptionsData))
                glowOptionsBuffer.unmap()
            }
            else {
                device.queue.writeBuffer(glowOptionsBuffer, 0, glowOptionsData)
            }
        }
        const updateSimOptionsBuffer = () => {
            // 108 bytes: core (84) + render fields numUrges/neuronRadius/isDebugConnections (84/88/92)
            // + numSenseNeurons (96, splits motor vs sense in the render shaders)
            // + senseRadius (100, world-unit radius for the sense debug dotted circle)
            // + magneticStrength (104, Lorentz force field strength — 0 = off)
            const simOptionsData = new ArrayBuffer(108)
            const simOptionsView = new DataView(simOptionsData)
            simOptionsView.setFloat32(0, SIM_WIDTH, true)
            simOptionsView.setFloat32(4, SIM_HEIGHT, true)
            simOptionsView.setUint32(8, GRID_WIDTH, true)
            simOptionsView.setUint32(12, GRID_HEIGHT, true)
            simOptionsView.setFloat32(16, CELL_SIZE, true)
            simOptionsView.setUint32(20, NUM_PARTICLES, true)
            simOptionsView.setUint32(24, NUM_TYPES, true)
            simOptionsView.setFloat32(28, PARTICLE_SIZE, true)
            simOptionsView.setFloat32(32, particleOpacity, true)
            simOptionsView.setUint32(36, isWallRepel ? 1 : 0, true)
            simOptionsView.setUint32(40, isWallWrap ? 1 : 0, true)
            simOptionsView.setFloat32(44, forceFactor, true)
            simOptionsView.setFloat32(48, frictionFactor, true)
            simOptionsView.setFloat32(52, repel, true)
            // Extended grid parameters for spatial hashing no walls
            simOptionsView.setUint32(56, EXTENDED_GRID_WIDTH, true)
            simOptionsView.setUint32(60, EXTENDED_GRID_HEIGHT, true)
            simOptionsView.setUint32(64, GRID_OFFSET_X, true)
            simOptionsView.setUint32(68, GRID_OFFSET_Y, true)
            simOptionsView.setUint32(72, mirrorWrapCount, true)
            simOptionsView.setUint32(76, CELL_SUBDIVISIONS, true)
            simOptionsView.setUint32(80, MATRIX_TYPES, true) // matrixStride for the interaction matrix
            // Render-layer fields (offset 84+)
            simOptionsView.setUint32(84, numUrges, true)
            simOptionsView.setFloat32(88, Math.max(particleLife.neuronRadius, 1), true)
            simOptionsView.setUint32(92, isDebugConnections ? 1 : 0, true)
            simOptionsView.setUint32(96, numSenseNeurons, true)
            simOptionsView.setFloat32(100, particleLife.senseRadius, true)
            simOptionsView.setFloat32(104, particleLife.magneticStrength, true)

            if (!simOptionsBuffer) {
                simOptionsBuffer = device.createBuffer({
                    size: simOptionsData.byteLength,
                    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                    mappedAtCreation: true,
                })
                new Uint8Array(simOptionsBuffer.getMappedRange()).set(new Uint8Array(simOptionsData))
                simOptionsBuffer.unmap()
            }
            else if (isEraseCompletionPending) {
                // Skip writing numParticles during erase to avoid conflicts with GPU-side copyBufferToBuffer
                device.queue.writeBuffer(simOptionsBuffer, 0, simOptionsData, 0, 20)
                device.queue.writeBuffer(simOptionsBuffer, 24, simOptionsData, 24, 84)
            }
            else {
                device.queue.writeBuffer(simOptionsBuffer, 0, simOptionsData)
            }
        }
        const updateDebugOptionsBuffer = () => {
            const debugOptionsData = new ArrayBuffer(8)
            const debugOptionsView = new DataView(debugOptionsData)
            debugOptionsView.setUint32(0, isDebugHeatmapActive ? 1 : 0, true)
            debugOptionsView.setFloat32(4, debugMaxParticleCount, true)

            if (!debugOptionsBuffer) {
                debugOptionsBuffer = device.createBuffer({
                    size: debugOptionsData.byteLength,
                    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                    mappedAtCreation: true,
                })
                new Uint8Array(debugOptionsBuffer.getMappedRange()).set(new Uint8Array(debugOptionsData))
                debugOptionsBuffer.unmap()
            }
            else {
                device.queue.writeBuffer(debugOptionsBuffer, 0, debugOptionsData)
            }
        }
        const createTrackerComputeBuffers = () => {
            trackerStateBuffer = device.createBuffer({
                size: 32, // x, y, vx, vy, searchRadius, expectedCount, _padding1, _padding2
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC | GPUBufferUsage.COPY_DST,
            })
            trackerLevelsBuffer = device.createBuffer({
                size: 32 * 4, // 128 bytes for 4 levels
                usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
            })
            trackerCameraOptionsBuffer = device.createBuffer({
                size: 16, // panOffsetX, panOffsetY, smoothing, _padding
                usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
                mappedAtCreation: true,
            })
            new Float32Array(trackerCameraOptionsBuffer.getMappedRange()).set([0, 0, particleLife.trackerCameraSmoothing, 0])
            trackerCameraOptionsBuffer.unmap()
            trackerCameraOffset = { x: 0, y: 0 }
            targetTrackerCameraOffset = { x: 0, y: 0 }
        }
        const updateInteractionMatrixBuffer = () => {
            const stride = 4 // 4 octets per entry
            const interactionData = new Uint8Array(MATRIX_TYPES * MATRIX_TYPES * stride)
            for (let a = 0; a < MATRIX_TYPES; a++) {
                for (let b = 0; b < MATRIX_TYPES; b++) {
                    const index = (a * MATRIX_TYPES + b) * stride
                    interactionData[index] = Math.round((rulesMatrix[a][b] + 1) * 0.5 * 255) // rule u8
                    interactionData[index + 1] = Math.round(minRadiusMatrix[a][b]) // minR u8
                    const maxR = maxRadiusMatrix[a][b]
                    interactionData[index + 2] = maxR & 0xFF // maxR low byte
                    interactionData[index + 3] = (maxR >> 8) & 0xFF // maxR high byte
                }
            }

            const paddedSize = Math.ceil(interactionData.byteLength / 16) * 16 // Ensure padded to 16 bytes
            const paddedInteractionData = new Uint8Array(paddedSize)
            paddedInteractionData.set(interactionData)

            if (!interactionMatrixBuffer || interactionMatrixBuffer.size !== paddedSize) {
                if (interactionMatrixBuffer)
                    interactionMatrixBuffer.destroy(); interactionMatrixBuffer = undefined
                interactionMatrixBuffer = device.createBuffer({
                    size: paddedSize,
                    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
                    mappedAtCreation: true,
                })
                new Uint8Array(interactionMatrixBuffer.getMappedRange()).set(paddedInteractionData)
                interactionMatrixBuffer.unmap()
            }
            else {
                device.queue.writeBuffer(interactionMatrixBuffer, 0, paddedInteractionData)
            }
        }
        // Upload the interaction matrix (matter + urge + neuron rows) to the GPU.
        const updateAllInteractionBuffers = () => {
            updateInteractionMatrixBuffer()
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const createBindGroups = () => {
            updateBinningBindGroups()
            updateParticleBindGroups()
            updateEraseCompactBindGroups()
            updateOffscreenTextureBindGroup()
            updateComposeHdrBindGroup()
            updateBrushesBindGroup()
            // ---------------------------------------------------------------------------------------------------------
            simOptionsBindGroup = device.createBindGroup({
                layout: simOptionsBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: simOptionsBuffer! } },
                ],
            })
            deltaTimeBindGroup = device.createBindGroup({
                layout: deltaTimeBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: deltaTimeBuffer! } },
                ],
            })
            electricalBindGroup = device.createBindGroup({
                layout: electricalBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: electricalOptionsBuffer! } },
                ],
            })
            connectionsComputeBindGroup = device.createBindGroup({
                layout: connectionsComputeBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                    { binding: 1, resource: { buffer: connDotsBuffer! } },
                    { binding: 2, resource: { buffer: connCountBuffer! } },
                ],
            })
            connectionsRenderBindGroup = device.createBindGroup({
                layout: connectionsRenderBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: connDotsBuffer! } },
                    { binding: 1, resource: { buffer: connCountBuffer! } },
                ],
            })
            cameraBindGroup = device.createBindGroup({
                layout: cameraBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: cameraBuffer! } },
                ],
            })
            glowOptionsBindGroup = device.createBindGroup({
                layout: glowOptionsBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: glowOptionsBuffer! } },
                ],
            })
            infiniteRenderOptionsBindGroup = device.createBindGroup({
                layout: infiniteRenderOptionsBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: glowOptionsBuffer! } },
                    { binding: 1, resource: { buffer: infiniteRenderOptionsBuffer! } },
                ],
            })
            renderBrushCircleBindGroup = device.createBindGroup({
                layout: renderBrushCircleBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: brushOptionsBuffer! } },
                ],
            })
            debugOptionsBindGroup = device.createBindGroup({
                layout: debugOptionsBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: debugOptionsBuffer! } },
                ],
            })
            trackerRenderBindGroup = device.createBindGroup({
                layout: trackerRenderBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: trackerStateBuffer! } },
                ],
            })
            trackerCameraUpdateBindGroup = device.createBindGroup({
                layout: trackerCameraUpdateBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: trackerStateBuffer! } },
                    { binding: 1, resource: { buffer: cameraBuffer! } },
                    { binding: 2, resource: { buffer: trackerCameraOptionsBuffer! } },
                ],
            })
        }
        const updateBrushesBindGroup = () => {
            brushOptionsBindGroup = undefined as any
            brushOptionsBindGroup = device.createBindGroup({
                layout: brushOptionsBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: brushOptionsBuffer! } },
                    { binding: 1, resource: { buffer: brushesBuffer! } },
                    { binding: 2, resource: { buffer: cameraBuffer! } },
                ],
            })
        }
        const updateBinningBindGroups = () => {
            binFillSizeBindGroup = device.createBindGroup({
                layout: binFillSizeBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: binOffsetBuffer! } },
                ],
            })
            binPrefixSumBindGroup[0] = device.createBindGroup({
                layout: binPrefixSumBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: binOffsetBuffer! } },
                    { binding: 1, resource: { buffer: binOffsetTempBuffer! } },
                    { binding: 2, resource: { buffer: binPrefixSumStepSizeBuffer!, size: 4 } },
                ],
            })
            binPrefixSumBindGroup[1] = device.createBindGroup({
                layout: binPrefixSumBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: binOffsetTempBuffer! } },
                    { binding: 1, resource: { buffer: binOffsetBuffer! } },
                    { binding: 2, resource: { buffer: binPrefixSumStepSizeBuffer!, size: 4 } },
                ],
            })
            renderDebugBinsBindGroup = device.createBindGroup({
                layout: renderDebugBinsBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: binOffsetBuffer! } },
                    { binding: 1, resource: heatmapTextureView! },
                    { binding: 2, resource: heatmapSampler! },
                ],
            })
        }
        const updateParticleBindGroups = () => {
            particleBufferBindGroup = undefined as any
            particleBufferReadOnlyBindGroup = undefined as any
            particleSortBindGroup = undefined as any
            particleComputeForcesBindGroup = undefined as any
            bruteForceBindGroup = undefined as any
            trackerComputeBindGroup = undefined as any

            particleBufferBindGroup = device.createBindGroup({
                layout: particleBufferBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                    { binding: 1, resource: { buffer: interactionMatrixBuffer! } },
                ],
            })
            particleBufferReadOnlyBindGroup = device.createBindGroup({
                layout: particleBufferReadOnlyBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                    { binding: 1, resource: { buffer: colorBuffer! } },
                ],
            })
            particleSortBindGroup = device.createBindGroup({
                layout: particleSortBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                    { binding: 1, resource: { buffer: particleTempBuffer! } },
                    { binding: 2, resource: { buffer: binOffsetBuffer! } },
                    { binding: 3, resource: { buffer: binOffsetTempBuffer! } },
                ],
            })
            particleComputeForcesBindGroup = device.createBindGroup({
                layout: particleComputeForcesBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleTempBuffer! } },
                    { binding: 1, resource: { buffer: particleBuffer! } },
                    { binding: 2, resource: { buffer: binOffsetBuffer! } },
                    { binding: 3, resource: { buffer: interactionMatrixBuffer! } },
                    { binding: 4, resource: { buffer: neuronModsBuffer! } }, // brain output
                    { binding: 5, resource: { buffer: neuronHealthBuffer! } }, // experiment: per-neuron health
                ],
            })
            // ---- Brain bind groups (only if pipeline was created successfully) ----
            if (brainValid && brainStepPipeline) {
                brainBindGroup = device.createBindGroup({
                    layout: brainStepPipeline.getBindGroupLayout(0),
                    entries: [
                        { binding: 0, resource: { buffer: particleBuffer! } },        // read particles (prev frame)
                        { binding: 1, resource: { buffer: genomeBuffer! } },          // per-brain genome (read_write)
                        { binding: 2, resource: { buffer: neuronOwnersBuffer! } },    // neuron ownership (read-only)
                        { binding: 3, resource: { buffer: neuronModsBuffer! } },      // output drives (read_write)
                        { binding: 4, resource: { buffer: brainMetricsBuffer! } },    // per-need live metrics (read_write, inspector)
                    ],
                })
                brainOptsBindGroup = device.createBindGroup({
                    layout: brainStepPipeline.getBindGroupLayout(1),
                    entries: [
                        { binding: 0, resource: { buffer: brainOptsBuffer! } },       // brain opts uniform
                    ],
                })

                // Brain mutate bind groups
                if (brainMutatePipeline) {
                    brainMutateBindGroup = device.createBindGroup({
                        layout: brainMutatePipeline.getBindGroupLayout(0),
                        entries: [
                            { binding: 0, resource: { buffer: genomeBuffer! } },      // genome (read_write)
                        ],
                    })
                    brainMutateOptsBindGroup = device.createBindGroup({
                        layout: brainMutatePipeline.getBindGroupLayout(1),
                        entries: [
                            { binding: 0, resource: { buffer: brainMutateOptsBuffer! } }, // numBrains, frameCount
                        ],
                    })
                }

                // Capture/release bind groups
                if (captureReleasePipeline) {
                    captureReleaseBindGroup = device.createBindGroup({
                        layout: captureReleasePipeline.getBindGroupLayout(0),
                        entries: [
                            { binding: 0, resource: { buffer: particleBuffer! } },        // particles (read-only)
                            { binding: 1, resource: { buffer: neuronOwnersBuffer! } },    // ownership (read_write)
                        ],
                    })
                    captureReleaseOptsBindGroup = device.createBindGroup({
                        layout: captureReleasePipeline.getBindGroupLayout(1),
                        entries: [
                            { binding: 0, resource: { buffer: captureReleaseOptsBuffer! } },
                        ],
                    })
                }
            }
            bruteForceBindGroup = device.createBindGroup({
                layout: bruteForceBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleTempBuffer! } },
                    { binding: 1, resource: { buffer: particleBuffer! } },
                    { binding: 2, resource: { buffer: interactionMatrixBuffer! } },
                    { binding: 3, resource: { buffer: neuronModsBuffer! } }, // brain output drive
                ],
            })
            trackerComputeBindGroup = device.createBindGroup({
                layout: trackerComputeBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                    { binding: 1, resource: { buffer: trackerStateBuffer! } },
                    { binding: 2, resource: { buffer: trackerLevelsBuffer! } },
                ],
            })
        }
        const updateEraseCompactBindGroups = () => {
            particleEraseBindGroup = undefined as any
            particleCompactBindGroup = undefined as any

            particleEraseBindGroup = device.createBindGroup({
                layout: particleEraseBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                    { binding: 1, resource: { buffer: particleKeepFlagsBuffer! } },
                ],
            })
            particleCompactBindGroup = device.createBindGroup({
                layout: particleCompactBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                    { binding: 1, resource: { buffer: particleCompactBuffer! } },
                    { binding: 2, resource: { buffer: particleKeepFlagsBuffer! } },
                    { binding: 3, resource: { buffer: newParticleCountBuffer! } },
                ],
            })
        }
        const updateOffscreenTextureBindGroup = () => {
            if (offscreenTextureView && offscreenSampler) {
                offscreenTextureBindGroup = device.createBindGroup({
                    layout: offscreenTextureBindGroupLayout,
                    entries: [
                        { binding: 0, resource: offscreenTextureView },
                        { binding: 1, resource: offscreenSampler },
                    ],
                })
            }
        }
        const updateComposeHdrBindGroup = () => {
            composeHdrBindGroup = device.createBindGroup({
                layout: composeHdrBindGroupLayout,
                entries: [
                    { binding: 0, resource: hdrTextureView },
                ],
            })
        }
        const updateDrawBindGroup = () => {
            particleDrawBindGroup = undefined as any
            particleDrawBindGroup = device.createBindGroup({
                layout: particleDrawBindGroupLayout,
                entries: [
                    { binding: 0, resource: { buffer: particleBuffer! } },
                ],
            })
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const createBindGroupLayouts = () => {
            particleBufferBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // particleBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // interactionMatrixBuffer
                ],
            })
            particleBufferReadOnlyBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX | GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleBuffer
                    { binding: 1, visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: 'read-only-storage' } }, // colorBuffer
                ],
            })
            binFillSizeBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // binOffsetBuffer
                ],
            })
            binPrefixSumBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // binOffsetBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // binOffsetTempBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'uniform', hasDynamicOffset: true } }, // binPrefixSumStepSizeBuffer
                ],
            })
            particleSortBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // particleTempBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // binOffsetBuffer
                    { binding: 3, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // binOffsetTempBuffer
                ],
            })
            particleComputeForcesBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleTempBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // particleBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // binOffsetBuffer
                    { binding: 3, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // interactionMatrixBuffer (includes urge + neuron rows)
                    { binding: 4, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // neuronModsBuffer (brain output)
                    { binding: 5, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // neuronHealthBuffer (experiment damage)
                ],
            })
            electricalBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'uniform' } }, // electricalOptionsBuffer
                ],
            })
            connectionsComputeBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // connDotsBuffer (write)
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // connCountBuffer (atomic write)
                ],
            })
            connectionsRenderBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX, buffer: { type: 'read-only-storage' } }, // connDotsBuffer
                    { binding: 1, visibility: GPUShaderStage.VERTEX, buffer: { type: 'read-only-storage' } }, // connCountBuffer
                ],
            })
            bruteForceBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleTempBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // particleBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // interactionMatrixBuffer
                    { binding: 3, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // neuronMods (brain output)
                ],
            })
            simOptionsBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE | GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: 'uniform' } },
                ],
            })
            deltaTimeBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE | GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: 'uniform' } }, // deltaTimeBuffer
                ],
            })
            cameraBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX, buffer: { type: 'uniform' } }, // cameraBuffer
                ],
            })
            offscreenTextureBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.FRAGMENT, texture: { viewDimension: '2d' } }, // offscreenTextureView
                    { binding: 1, visibility: GPUShaderStage.FRAGMENT, sampler: { type: 'filtering' } }, // offscreenSampler
                ],
            })
            composeHdrBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.FRAGMENT, texture: { sampleType: 'unfilterable-float' } }, // Texture for HDR rendering
                ],
            })
            glowOptionsBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: 'uniform' } }, // glowOptionsBuffer
                ],
            })
            infiniteRenderOptionsBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: 'uniform' } }, // glowOptionsBuffer
                    { binding: 1, visibility: GPUShaderStage.VERTEX, buffer: { type: 'uniform' } }, // infiniteRenderOptionsBuffer
                ],
            })
            brushOptionsBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'uniform' } }, // brushOptionsBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // brushesBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'uniform' } }, // cameraBuffer
                ],
            })
            particleEraseBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // particleKeepFlagsBuffer
                ],
            })
            particleCompactBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // oldParticleBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // newParticleBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleKeepFlags
                    { binding: 3, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // newParticleCount
                ],
            })
            particleDrawBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // particleBuffer
                ],
            })
            renderBrushCircleBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX, buffer: { type: 'uniform' } }, // brushOptionsBuffer
                ],
            })
            renderDebugBinsBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX, buffer: { type: 'read-only-storage' } }, // binOffsetBuffer
                    { binding: 1, visibility: GPUShaderStage.FRAGMENT, texture: { sampleType: 'float', viewDimension: '2d' } }, // heatmapTextureView
                    { binding: 2, visibility: GPUShaderStage.FRAGMENT, sampler: { type: 'filtering' } }, // heatmapSampler
                ],
            })
            debugOptionsBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: 'uniform' } }, // debugOptionsBuffer
                ],
            })
            trackerRenderBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: 'read-only-storage' } }, // trackerStateBuffer
                ],
            })
            trackerComputeBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particleBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // trackerStateBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // trackerLevelsBuffer
                ],
            })
            trackerCameraUpdateBindGroupLayout = device.createBindGroupLayout({
                entries: [
                    { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // trackerStateBuffer
                    { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // cameraBuffer
                    { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'uniform' } }, // trackerCameraOptionsBuffer
                ],
            })
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const createPipelines = () => {
            createComputePipelines()
            createRenderPipelines()
            createHdrGlowPipelines()
        }
        const createComputePipelines = () => {
            const binFillSizeShader = device.createShaderModule({ code: binFillSizeShaderCode })
            binClearSizePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        particleBufferReadOnlyBindGroupLayout,
                        simOptionsBindGroupLayout,
                        binFillSizeBindGroupLayout,
                    ],
                }),
                compute: { module: binFillSizeShader, entryPoint: 'clearBinSize' },
            })
            binFillSizePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        particleBufferReadOnlyBindGroupLayout,
                        simOptionsBindGroupLayout,
                        binFillSizeBindGroupLayout,
                    ],
                }),
                compute: { module: binFillSizeShader, entryPoint: 'fillBinSize' },
            })
            const binPrefixSumShader = device.createShaderModule({ code: binPrefixSumShaderCode })
            binPrefixSumPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        binPrefixSumBindGroupLayout,
                    ],
                }),
                compute: { module: binPrefixSumShader, entryPoint: 'prefixSumStep' },
            })
            const particleSortShader = device.createShaderModule({ code: particleSortShaderCode })
            particleSortClearSizePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        particleSortBindGroupLayout,
                        simOptionsBindGroupLayout,
                    ],
                }),
                compute: { module: particleSortShader, entryPoint: 'clearBinSize' },
            })
            particleSortPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        particleSortBindGroupLayout,
                        simOptionsBindGroupLayout,
                    ],
                }),
                compute: { module: particleSortShader, entryPoint: 'sortParticles' },
            })
            const particleComputeForcesShader = device.createShaderModule({ code: particleComputeForcesShaderCode })
            particleComputeForcesPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        particleComputeForcesBindGroupLayout,
                        simOptionsBindGroupLayout,
                        deltaTimeBindGroupLayout,
                        electricalBindGroupLayout,
                    ],
                }),
                compute: { module: particleComputeForcesShader, entryPoint: 'computeForces' },
            })
            // ---- Brain step pipeline (per-brain forward + delta-rule learning) ----
            try {
            const brainStepShader = device.createShaderModule({ code: brainStepShaderCode })
            brainStepPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        device.createBindGroupLayout({
                            entries: [
                                { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particles
                                { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } },           // genome (read_write)
                                { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // neuronOwners
                                { binding: 3, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } },           // neuronMods (read_write)
                                { binding: 4, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } },           // brainMetrics (read_write, inspector)
                            ],
                        }),
                        device.createBindGroupLayout({
                            entries: [
                                { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: {} }, // brainOpts (uniform)
                            ],
                        }),
                    ],
                }),
                compute: { module: brainStepShader, entryPoint: 'main' },
            })
            brainValid = true

            // Brain mutate pipeline (slow drift of genome needs only)
            const brainMutateShader = device.createShaderModule({ code: brainMutateShaderCode })
            brainMutatePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        device.createBindGroupLayout({
                            entries: [
                                { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } }, // genome (read_write)
                            ],
                        }),
                        device.createBindGroupLayout({
                            entries: [
                                { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: {} }, // mutateOpts
                            ],
                        }),
                    ],
                }),
                compute: { module: brainMutateShader, entryPoint: 'main' },
            })

            // Capture/release pipeline (organic neuron gain/loss)
            const captureReleaseShader = device.createShaderModule({ code: captureReleaseShaderCode })
            captureReleasePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        device.createBindGroupLayout({
                            entries: [
                                { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'read-only-storage' } }, // particles
                                { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: 'storage' } },           // neuronOwners (read_write)
                            ],
                        }),
                        device.createBindGroupLayout({
                            entries: [
                                { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: {} }, // captureOpts (uniform)
                            ],
                        }),
                    ],
                }),
                compute: { module: captureReleaseShader, entryPoint: 'main' },
            })
            } catch (e) {
                console.warn('[brain] pipeline creation failed, brain disabled:', e)
                brainStepPipeline = undefined
            }
            const bruteForceShader = device.createShaderModule({ code: bruteForceShaderCode })
            bruteForceComputePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        bruteForceBindGroupLayout,
                        simOptionsBindGroupLayout,
                        deltaTimeBindGroupLayout,
                        electricalBindGroupLayout,
                    ],
                }),
                compute: { module: bruteForceShader, entryPoint: 'main' },
            })
            const particleAdvanceShader = device.createShaderModule({ code: particleAdvanceShaderCode })
            particleAdvancePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        particleBufferBindGroupLayout,
                        simOptionsBindGroupLayout,
                        deltaTimeBindGroupLayout,
                    ],
                }),
                compute: { module: particleAdvanceShader, entryPoint: 'particleAdvance' },
            })
            const debugConnectionsShader = device.createShaderModule({ code: debugConnectionsShaderCode })
            debugConnectionsPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        connectionsComputeBindGroupLayout,
                        simOptionsBindGroupLayout,
                        electricalBindGroupLayout,
                    ],
                }),
                compute: { module: debugConnectionsShader, entryPoint: 'emitConnections' },
            })
            const particleAdvanceBrushShader = device.createShaderModule({ code: particleAdvanceBrushShaderCode })
            particleAdvanceBrushPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [
                        particleBufferBindGroupLayout,
                        simOptionsBindGroupLayout,
                        deltaTimeBindGroupLayout,
                        brushOptionsBindGroupLayout,
                    ],
                }),
                compute: { module: particleAdvanceBrushShader, entryPoint: 'particleAdvance' },
            })
            const particleEraseShader = device.createShaderModule({ code: particleEraseShaderCode })
            particleErasePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleEraseBindGroupLayout, simOptionsBindGroupLayout, brushOptionsBindGroupLayout],
                }),
                compute: { module: particleEraseShader, entryPoint: 'markForErase' },
            })
            const particleCompactShader = device.createShaderModule({ code: particleCompactShaderCode })
            particleCompactPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleCompactBindGroupLayout, simOptionsBindGroupLayout],
                }),
                compute: { module: particleCompactShader, entryPoint: 'compactParticles' },
            })
            const particleDrawShader = device.createShaderModule({ code: particleDrawShaderCode })
            particleDrawPipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleDrawBindGroupLayout, simOptionsBindGroupLayout, brushOptionsBindGroupLayout],
                }),
                compute: { module: particleDrawShader, entryPoint: 'drawParticles' },
            })

            const trackerComputeShader = device.createShaderModule({ code: trackerComputeShaderCode })
            trackerAccumulatePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [trackerComputeBindGroupLayout, simOptionsBindGroupLayout, deltaTimeBindGroupLayout],
                }),
                compute: { module: trackerComputeShader, entryPoint: 'accumulateParticles' },
            })
            trackerFinalizePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [trackerComputeBindGroupLayout, simOptionsBindGroupLayout, deltaTimeBindGroupLayout],
                }),
                compute: { module: trackerComputeShader, entryPoint: 'finalizeTracker' },
            })
            const trackerCameraUpdateShader = device.createShaderModule({ code: trackerCameraUpdateShaderCode })
            trackerCameraUpdatePipeline = device.createComputePipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [trackerCameraUpdateBindGroupLayout],
                }),
                compute: { module: trackerCameraUpdateShader, entryPoint: 'main' },
            })
        }
        const particleNormalBlending: GPUBlendState = {
            color: { operation: 'add', srcFactor: 'src-alpha', dstFactor: 'one-minus-src-alpha' },
            alpha: { operation: 'add', srcFactor: 'one', dstFactor: 'one-minus-src-alpha' },
        }
        const particleAdditiveBlending: GPUBlendState = {
            color: { operation: 'add', srcFactor: 'src-alpha', dstFactor: 'one' },
            alpha: { operation: 'add', srcFactor: 'one', dstFactor: 'one' },
        }
        const createRenderPipelines = () => {
            const renderShader = device.createShaderModule({ code: renderShaderCode })
            renderPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout],
                }),
                vertex: { module: renderShader, entryPoint: 'vertexMain' },
                fragment: { module: renderShader, entryPoint: 'fragmentMain', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderPipelineAdditive = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout],
                }),
                vertex: { module: renderShader, entryPoint: 'vertexMain' },
                fragment: { module: renderShader, entryPoint: 'fragmentMain', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleAdditiveBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            const renderConnectionsShader = device.createShaderModule({ code: renderConnectionsShaderCode })
            renderConnectionsPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [connectionsRenderBindGroupLayout, cameraBindGroupLayout, simOptionsBindGroupLayout],
                }),
                vertex: { module: renderConnectionsShader, entryPoint: 'vertexMain' },
                fragment: { module: renderConnectionsShader, entryPoint: 'fragmentMain', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    // Normal (alpha) blending: lines draw ON TOP of bright matter so they stay visible.
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const renderMirrorShader = device.createShaderModule({ code: renderMirrorShaderCode })
            renderMirrorPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderMirrorShader, entryPoint: 'mirrorVertex' },
                fragment: { module: renderMirrorShader, entryPoint: 'mirrorFragment', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderMirrorPipelineAdditive = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderMirrorShader, entryPoint: 'mirrorVertex' },
                fragment: { module: renderMirrorShader, entryPoint: 'mirrorFragment', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleAdditiveBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const renderInfiniteShader = device.createShaderModule({ code: renderInfiniteShaderCode })
            renderInfinitePipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, infiniteRenderOptionsBindGroupLayout],
                }),
                vertex: { module: renderInfiniteShader, entryPoint: 'infiniteVertex' },
                fragment: { module: renderInfiniteShader, entryPoint: 'infiniteFragment', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip', stripIndexFormat: 'uint32' },
            })
            renderInfinitePipelineAdditive = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, infiniteRenderOptionsBindGroupLayout],
                }),
                vertex: { module: renderInfiniteShader, entryPoint: 'infiniteVertex' },
                fragment: { module: renderInfiniteShader, entryPoint: 'infiniteFragment', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleAdditiveBlending,
                }] },
                primitive: { topology: 'triangle-strip', stripIndexFormat: 'uint32' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const offscreenVertexShader = device.createShaderModule({ code: offscreenShaderCode })
            renderOffscreenPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout],
                }),
                vertex: { module: offscreenVertexShader, entryPoint: 'vertexMain' },
                fragment: { module: renderShader, entryPoint: 'fragmentMain', targets: [{ format: 'rgba8unorm' }],
                },
                primitive: { topology: 'triangle-strip' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const infiniteCompositorShader = device.createShaderModule({ code: infiniteCompositorShaderCode })
            composeInfinitePipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [cameraBindGroupLayout, simOptionsBindGroupLayout, offscreenTextureBindGroupLayout],
                }),
                vertex: { module: infiniteCompositorShader, entryPoint: 'vertexInfinite' },
                fragment: { module: infiniteCompositorShader, entryPoint: 'fragmentInfinite', targets: [{ format: navigator.gpu.getPreferredCanvasFormat() }],
                },
                primitive: { topology: 'triangle-list' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const renderBrushCircleShader = device.createShaderModule({ code: renderBrushCircleShaderCode })
            renderBrushCirclePipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [cameraBindGroupLayout, renderBrushCircleBindGroupLayout],
                }),
                vertex: { module: renderBrushCircleShader, entryPoint: 'vertexMain' },
                fragment: { module: renderBrushCircleShader, entryPoint: 'fragmentMain', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            const renderBinsShader = device.createShaderModule({ code: renderBinsShaderCode })
            renderDebugBinsPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [renderDebugBinsBindGroupLayout, debugOptionsBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout],
                }),
                vertex: { module: renderBinsShader, entryPoint: 'vertexMain' },
                fragment: { module: renderBinsShader, entryPoint: 'fragmentMain', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const renderTrackerShader = device.createShaderModule({ code: renderTrackerShaderCode })
            renderTrackerPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [cameraBindGroupLayout, trackerRenderBindGroupLayout, deltaTimeBindGroupLayout, simOptionsBindGroupLayout],
                }),
                vertex: { module: renderTrackerShader, entryPoint: 'vertexMain' },
                fragment: { module: renderTrackerShader, entryPoint: 'fragmentMain', targets: [{
                    format: navigator.gpu.getPreferredCanvasFormat(),
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
        }
        const createHdrGlowPipelines = () => {
            const glowBlendOptions: GPUBlendState = {
                color: { operation: 'add', srcFactor: 'src-alpha', dstFactor: 'one' },
                alpha: { operation: 'add', srcFactor: 'one', dstFactor: 'one' },
            }
            // ---------------------------------------------------------------------------------------------------------
            const renderGlowShader = device.createShaderModule({ code: renderGlowShaderCode })
            renderGlowPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderGlowShader, entryPoint: 'vertexGlow' },
                fragment: { module: renderGlowShader, entryPoint: 'fragmentGlow', targets: [{
                    format: 'rgba16float',
                    blend: glowBlendOptions,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderCirclePipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderGlowShader, entryPoint: 'vertexCircle' },
                fragment: { module: renderGlowShader, entryPoint: 'fragmentCircle', targets: [{
                    format: 'rgba16float',
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderCirclePipelineAdditive = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderGlowShader, entryPoint: 'vertexCircle' },
                fragment: { module: renderGlowShader, entryPoint: 'fragmentCircle', targets: [{
                    format: 'rgba16float',
                    blend: particleAdditiveBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const renderMirrorShader = device.createShaderModule({ code: renderMirrorShaderCode })
            renderMirrorGlowPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderMirrorShader, entryPoint: 'mirrorVertexGlow' },
                fragment: { module: renderMirrorShader, entryPoint: 'mirrorFragmentGlow', targets: [{
                    format: 'rgba16float',
                    blend: glowBlendOptions,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderMirrorCirclePipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderMirrorShader, entryPoint: 'mirrorVertexCircle' },
                fragment: { module: renderMirrorShader, entryPoint: 'mirrorFragmentCircle', targets: [{
                    format: 'rgba16float',
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderMirrorCirclePipelineAdditive = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, glowOptionsBindGroupLayout],
                }),
                vertex: { module: renderMirrorShader, entryPoint: 'mirrorVertexCircle' },
                fragment: { module: renderMirrorShader, entryPoint: 'mirrorFragmentCircle', targets: [{
                    format: 'rgba16float',
                    blend: particleAdditiveBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const renderInfiniteShader = device.createShaderModule({ code: renderInfiniteShaderCode })
            renderInfiniteGlowPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, infiniteRenderOptionsBindGroupLayout],
                }),
                vertex: { module: renderInfiniteShader, entryPoint: 'infiniteVertexGlow' },
                fragment: { module: renderInfiniteShader, entryPoint: 'infiniteFragmentGlow', targets: [{
                    format: 'rgba16float',
                    blend: glowBlendOptions,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderInfiniteCirclePipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, infiniteRenderOptionsBindGroupLayout],
                }),
                vertex: { module: renderInfiniteShader, entryPoint: 'infiniteVertexCircle' },
                fragment: { module: renderInfiniteShader, entryPoint: 'infiniteFragmentCircle', targets: [{
                    format: 'rgba16float',
                    blend: particleNormalBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            renderInfiniteCirclePipelineAdditive = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [particleBufferReadOnlyBindGroupLayout, simOptionsBindGroupLayout, cameraBindGroupLayout, infiniteRenderOptionsBindGroupLayout],
                }),
                vertex: { module: renderInfiniteShader, entryPoint: 'infiniteVertexCircle' },
                fragment: { module: renderInfiniteShader, entryPoint: 'infiniteFragmentCircle', targets: [{
                    format: 'rgba16float',
                    blend: particleAdditiveBlending,
                }] },
                primitive: { topology: 'triangle-strip' },
            })
            // ---------------------------------------------------------------------------------------------------------
            const composeShader = device.createShaderModule({ code: composeHdrShaderCode })
            composeHdrPipeline = device.createRenderPipeline({
                layout: device.createPipelineLayout({
                    bindGroupLayouts: [composeHdrBindGroupLayout],
                }),
                vertex: { module: composeShader, entryPoint: 'vertexMain' },
                fragment: { module: composeShader, entryPoint: 'fragmentMain', targets: [{ format: navigator.gpu.getPreferredCanvasFormat() }],
                },
                primitive: { topology: 'triangle-list' },
            })
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const updateHdrTexture = () => {
            if (hdrTexture)
                hdrTexture.destroy(); hdrTexture = undefined

            hdrTexture = device.createTexture({
                size: [CANVAS_WIDTH, CANVAS_HEIGHT],
                format: 'rgba16float',
                usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING,
                mipLevelCount: 1, // No mipmaps for HDR = -33% performance hit
                sampleCount: 1, // No multisampling (MSAA) for HDR = -75% memory and compute hit
            })
            hdrTextureView = hdrTexture.createView()

            if (composeHdrPipeline) {
                updateComposeHdrBindGroup()
            }
        }
        const createHeatmapTexture = async () => {
            const response = await fetch(heatmapImage)
            const blob = await response.blob()
            const imageBitmap = await createImageBitmap(blob, {
                colorSpaceConversion: "none",
                premultiplyAlpha: "none",
            })

            heatmapTexture = device.createTexture({
                size: [imageBitmap.width, imageBitmap.height, 1],
                format: 'rgba8unorm',
                usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
            })

            device.queue.copyExternalImageToTexture(
                { source: imageBitmap },
                { texture: heatmapTexture },
                [imageBitmap.width, imageBitmap.height, 1],
            )

            heatmapSampler = device.createSampler({
                addressModeU: 'clamp-to-edge',
                addressModeV: 'clamp-to-edge', // maybe repeat
                magFilter: 'linear',
                minFilter: 'linear',
            })

            heatmapTextureView = heatmapTexture.createView()
        }
        const updateOffscreenMirrorResources = () => {
            if (offscreenTexture) {
                offscreenTexture.destroy(); offscreenTexture = undefined
            }
            if (!isInfiniteMirrorWrap)
                return

            const maxDimension = device.limits.maxTextureDimension2D
            const aspectRatio = SIM_WIDTH / SIM_HEIGHT
            const baseResolution2K = 2048

            let desiredWidth = SIM_WIDTH * 3.5
            let desiredHeight = SIM_HEIGHT * 3.5

            if (desiredWidth > maxDimension || desiredHeight > maxDimension) {
                if (aspectRatio > 1) {
                    desiredWidth = maxDimension
                    desiredHeight = Math.round(desiredWidth / aspectRatio)
                }
                else {
                    desiredHeight = maxDimension
                    desiredWidth = Math.round(desiredHeight * aspectRatio)
                }
            }
            if (desiredWidth < baseResolution2K || desiredHeight < baseResolution2K) {
                if (aspectRatio > 1) {
                    desiredWidth = Math.max(desiredWidth, baseResolution2K)
                    desiredHeight = Math.round(desiredWidth / aspectRatio)
                }
                else {
                    desiredHeight = Math.max(desiredHeight, baseResolution2K)
                    desiredWidth = Math.round(desiredHeight * aspectRatio)
                }
            }
            const maxWidth = Math.min(desiredWidth, maxDimension)
            const maxHeight = Math.min(desiredHeight, maxDimension)
            offscreenTexture = device.createTexture({
                size: [maxWidth, maxHeight],
                // format: navigator.gpu.getPreferredCanvasFormat(),
                format: 'rgba8unorm',
                usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING,
            })
            offscreenTextureView = offscreenTexture.createView()

            if (!offscreenSampler) {
                offscreenSampler = device.createSampler({
                    magFilter: 'linear',
                    minFilter: 'linear',
                    addressModeU: 'repeat',
                    addressModeV: 'repeat',
                })
            }

            if (isInfiniteMirrorWrap && composeInfinitePipeline)
                updateOffscreenTextureBindGroup()
        }
        const drawWithBrush = () => {
            if (isUpdatingParticles || isEraseCompleting || !isBrushActive || brushType !== 1)
                return
            isUpdatingParticles = true

            try {
                if (!showBrushCircle)
                    updateBrushOptionsBuffer() // Condition prevents duplicate updates

                const oldNumParticles = NUM_PARTICLES
                const numParticlesToAdd = Math.floor(brushIntensity)
                const newNumParticles = oldNumParticles + numParticlesToAdd

                const newParticleBuffer = device.createBuffer({
                    size: newNumParticles * PARTICLE_BYTES,
                    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC | GPUBufferUsage.COPY_DST,
                })

                const encoder = device.createCommandEncoder({ label: 'Draw Brush Encoder' })
                encoder.copyBufferToBuffer(particleBuffer!, 0, newParticleBuffer, 0, oldNumParticles * PARTICLE_BYTES)

                const oldParticleBuffer = particleBuffer
                particleBuffer = newParticleBuffer

                updateDrawBindGroup()

                const drawPass = encoder.beginComputePass({ label: 'Draw Pass' })
                drawPass.setPipeline(particleDrawPipeline)
                drawPass.setBindGroup(0, particleDrawBindGroup)
                drawPass.setBindGroup(1, simOptionsBindGroup)
                drawPass.setBindGroup(2, brushOptionsBindGroup)
                drawPass.dispatchWorkgroups(Math.ceil(numParticlesToAdd / 64))
                drawPass.end()

                device.queue.submit([encoder.finish()])

                oldParticleBuffer?.destroy()

                NUM_PARTICLES = newNumParticles
                particleLife.numParticles = newNumParticles

                if (particleTempBuffer)
                    particleTempBuffer?.destroy(); particleTempBuffer = undefined
                particleTempBuffer = device.createBuffer({
                    size: particleBuffer.size,
                    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
                })

                updateSimOptionsBuffer()
                updateEraseCompactBuffers()
                updateParticleBindGroups()
                updateEraseCompactBindGroups()
                updateInfiniteRenderOptions()
                hasUpdateNumParticles = true
            }
            catch (error) {
                console.error("Error drawing with brush:", error)
            }
            finally {
                isUpdatingParticles = false
            }
        }
        const eraseWithBrush = () => {
            if (isUpdatingParticles || isEraseCompleting || !isBrushActive || brushType !== 0)
                return
            isUpdatingParticles = true

            try {
                if (!showBrushCircle)
                    updateBrushOptionsBuffer() // Condition prevents duplicate updates

                const encoder = device.createCommandEncoder({ label: 'Erase and Compact Encoder' })
                encoder.clearBuffer(newParticleCountBuffer!, 0, 4)

                const markPass = encoder.beginComputePass({ label: 'Mark Pass' })
                markPass.setPipeline(particleErasePipeline)
                markPass.setBindGroup(0, particleEraseBindGroup)
                markPass.setBindGroup(1, simOptionsBindGroup)
                markPass.setBindGroup(2, brushOptionsBindGroup)
                markPass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
                markPass.end()

                const compactPass = encoder.beginComputePass({ label: 'Compact Pass' })
                compactPass.setPipeline(particleCompactPipeline)
                compactPass.setBindGroup(0, particleCompactBindGroup)
                compactPass.setBindGroup(1, simOptionsBindGroup)
                compactPass.dispatchWorkgroups(Math.ceil(NUM_PARTICLES / 64))
                compactPass.end()

                // Copy compacted particles back to particleBuffer (full old size)
                encoder.copyBufferToBuffer(particleCompactBuffer!, 0, particleBuffer!, 0, NUM_PARTICLES * PARTICLE_BYTES)
                // Update GPU-side numParticles from the atomic counter (no CPU readback needed)
                encoder.copyBufferToBuffer(newParticleCountBuffer!, 0, simOptionsBuffer!, 20, 4)

                device.queue.submit([encoder.finish()])
                isEraseCompletionPending = true
            }
            catch (error) {
                console.error("Error during erase and compact operation:", error)
            }
            finally {
                isUpdatingParticles = false
            }
        }
        const completeEraseWithBrush = () => {
            if (isEraseCompleting || !isEraseCompletionPending)
                return
            isEraseCompleting = true

            // Copy new particle count to readback buffer
            const readEncoder = device.createCommandEncoder({ label: 'Read Erase Count Encoder' })
            readEncoder.copyBufferToBuffer(newParticleCountBuffer!, 0, newParticleCountReadBuffer!, 0, 4)
            device.queue.submit([readEncoder.finish()])

            // .then() instead of await prevents blocking the main loop during GPU readback
            newParticleCountReadBuffer!.mapAsync(GPUMapMode.READ).then(() => {
                const newCount = new Uint32Array(newParticleCountReadBuffer!.getMappedRange())[0]
                newParticleCountReadBuffer!.unmap()

                if (newCount < NUM_PARTICLES) {
                    const oldParticleBuffer = particleBuffer

                    NUM_PARTICLES = newCount
                    particleLife.numParticles = newCount

                    particleBuffer = device.createBuffer({
                        size: newCount * PARTICLE_BYTES,
                        usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC | GPUBufferUsage.STORAGE,
                    })

                    const copyEncoder = device.createCommandEncoder({ label: 'Copy to Resized Buffer' })
                    copyEncoder.copyBufferToBuffer(oldParticleBuffer!, 0, particleBuffer!, 0, newCount * PARTICLE_BYTES)
                    device.queue.submit([copyEncoder.finish()])
                    oldParticleBuffer?.destroy()

                    if (particleTempBuffer)
                        particleTempBuffer.destroy(); particleTempBuffer = undefined
                    particleTempBuffer = device.createBuffer({
                        size: particleBuffer.size,
                        usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
                    })

                    updateSimOptionsBuffer()
                    updateEraseCompactBuffers()
                    updateParticleBindGroups()
                    updateEraseCompactBindGroups()
                    updateInfiniteRenderOptions()
                    hasUpdateNumParticles = true
                }
            }).catch((error) => {
                console.error("Error during erase completion:", error)
            }).finally(() => {
                isEraseCompletionPending = false
                isEraseCompleting = false
            })
        }
        const setNewNumParticles = (newCount: number) => {
            // The particle-count slider sets the MATTER count; urges/neurons/clone pool are added on top.
            baseMatterCount = newCount
            NEW_NUM_PARTICLES = newCount + numUrges + numNeurons + numSenseNeurons + numClonePool
            isUpdateNumParticlesPending = true
        }
        const updateNumParticles = async (newCount: number) => {
            if (isUpdatingParticles || newCount === NUM_PARTICLES) {
                isUpdateNumParticlesPending = false
                return
            }
            isUpdatingParticles = true
            await device.queue.onSubmittedWorkDone()

            try {
                const oldCount = NUM_PARTICLES
                const oldParticlesData = await readBufferFromGPU(particleBuffer!, oldCount * PARTICLE_BYTES)
                const oldParticles = new Float32Array(oldParticlesData)
                initialParticles = new Float32Array(newCount * PARTICLE_STRIDE)

                // Detect pool-only resize: the non-pool count (matter+urges+neurons+sense) is unchanged.
                // This is robust against watcher ordering — if matter/urges/neurons/sense also changed,
                // lastNonPoolCount won't match and we fall through to the full relabel path.
                const currentNonPool = baseMatterCount + numUrges + numNeurons + numSenseNeurons
                const isPoolOnly = (currentNonPool === lastNonPoolCount)

                if (isPoolOnly) {
                    // Pool-only resize: preserve every existing particle's type/position/velocity.
                    // The spatial sort scatters particles throughout the buffer, so we CANNOT use
                    // index-based layout. Instead:
                    //   Grow  → keep all old data, append new dormant pool entries at the tail.
                    //   Shrink → keep ALL non-dormant particles (matter/urges/neurons/sense/clones),
                    //             then fill remaining slots with dormants. Never drop a real particle.
                    const dormantType = NUM_TYPES + numUrges + numNeurons + numSenseNeurons

                    if (newCount > oldCount) {
                        // Grow: copy everything, append new dormant particles at the end.
                        initialParticles.set(oldParticles)
                        for (let i = oldCount; i < newCount; i++) {
                            const baseIndex = i * PARTICLE_STRIDE
                            initialParticles[baseIndex] = Math.random() * SIM_WIDTH
                            initialParticles[baseIndex + 1] = Math.random() * SIM_HEIGHT
                            initialParticles[baseIndex + 2] = 0
                            initialParticles[baseIndex + 3] = 0
                            initialParticles[baseIndex + 4] = dormantType // invisible, no forces
                            initialParticles[baseIndex + 5] = 0
                            initialParticles[baseIndex + 6] = 0
                        }
                    }
                    else {
                        // Shrink: keep all non-dormant particles first, then fill with dormants.
                        const nonDormant: number[] = []
                        const dormant: number[] = []
                        for (let i = 0; i < oldCount; i++) {
                            const t = Math.floor(oldParticles[i * PARTICLE_STRIDE + 4])
                            if (t === dormantType)
                                dormant.push(i)
                            else nonDormant.push(i)
                        }
                        let writeIdx = 0
                        // All non-dormant particles are preserved (matter, urges, neurons, clones).
                        for (const src of nonDormant) {
                            if (writeIdx >= newCount)
                                break // safety: shouldn't happen
                            const dst = writeIdx * PARTICLE_STRIDE
                            const src8 = src * PARTICLE_STRIDE
                            for (let c = 0; c < 11; c++) initialParticles[dst + c] = oldParticles[src8 + c]
                            writeIdx++
                        }
                        // Fill remaining slots with dormant particles.
                        for (const src of dormant) {
                            if (writeIdx >= newCount)
                                break
                            const dst = writeIdx * PARTICLE_STRIDE
                            const src8 = src * PARTICLE_STRIDE
                            for (let c = 0; c < 11; c++) initialParticles[dst + c] = oldParticles[src8 + c]
                            writeIdx++
                        }
                        // If somehow still short (shouldn't happen), pad with fresh dormants.
                        while (writeIdx < newCount) {
                            const baseIndex = writeIdx * PARTICLE_STRIDE
                            initialParticles[baseIndex] = Math.random() * SIM_WIDTH
                            initialParticles[baseIndex + 1] = Math.random() * SIM_HEIGHT
                            initialParticles[baseIndex + 2] = 0
                            initialParticles[baseIndex + 3] = 0
                            initialParticles[baseIndex + 4] = dormantType
                            initialParticles[baseIndex + 5] = 0
                            initialParticles[baseIndex + 6] = 0
                            writeIdx++
                        }
                    }
                }
                else {
                    // Full resize (matter count / urge / neuron change): re-label everything.
                    if (newCount > oldCount) {
                        initialParticles.set(oldParticles)
                        for (let i = oldCount; i < newCount; i++) {
                            const baseIndex = i * PARTICLE_STRIDE
                            initialParticles[baseIndex] = Math.random() * SIM_WIDTH
                            initialParticles[baseIndex + 1] = Math.random() * SIM_HEIGHT
                        }
                    }
                    else {
                        initialParticles.set(oldParticles.subarray(0, newCount * PARTICLE_STRIDE))
                        for (let i = newCount; i < oldCount; i++) {
                            const j = Math.floor(Math.random() * (i + 1))
                            if (j < newCount) {
                                const oldStartIndex = i * PARTICLE_STRIDE
                                const newIndex = j * PARTICLE_STRIDE
                                for (let c = 0; c < 11; c++) initialParticles[newIndex + c] = oldParticles[oldStartIndex + c]
                            }
                        }
                    }
                    applyTypeLayout(initialParticles) // re-assign matter/urge/neuron types for the new population
                }

                NUM_PARTICLES = newCount
                lastNonPoolCount = baseMatterCount + numUrges + numNeurons + numSenseNeurons
                // Keep the slider in sync only when the change came from the matter slider;
                // pool/urge/neuron-driven resizes must not clobber the user's matter count.
                if (newCount === NEW_NUM_PARTICLES && !isPoolOnly)
                    particleLife.numParticles = newCount
                updateParticleBuffers(true) // Destroy and recreate particle buffers
                updateEraseCompactBuffers()
                updateParticleBindGroups() // Recreate bind groups that depend on particle buffers
                updateEraseCompactBindGroups()
                updateSimOptionsBuffer() // Update simulation options buffer
                updateInfiniteRenderOptions() // Update infinite render options buffer
                hasUpdateNumParticles = true
            }
            finally {
                isUpdatingParticles = false
                isUpdateNumParticlesPending = NEW_NUM_PARTICLES !== NUM_PARTICLES
            }
        }
        const setNewNumTypes = (newNumTypes: number) => {
            NEW_NUM_TYPES = newNumTypes
            isUpdateNumTypesPending = true
        }
        const updateNumTypes = async (newNumTypes: number) => {
            if (isUpdatingParticles || newNumTypes === NUM_TYPES) {
                isUpdateNumTypesPending = false
                return
            }
            isUpdatingParticles = true
            await device.queue.onSubmittedWorkDone()

            try {
                // eslint-disable-next-line unused-imports/no-unused-vars
                const oldNumTypes = NUM_TYPES
                const oldMatrixTypes = MATRIX_TYPES
                NUM_TYPES = newNumTypes
                MATRIX_TYPES = newNumTypes + MATRIX_EXTRA_TYPES

                // Resize the main matrix (includes urge + neuron rows/cols) from (old+2)² to (new+2)².
                setRulesMatrix(resizeMatrix(rulesMatrix, oldMatrixTypes, MATRIX_TYPES, () => {
                    return Math.round((Math.random() * 2 - 1) * 100) / 100
                }))
                setMinRadiusMatrix(resizeMatrix(minRadiusMatrix, oldMatrixTypes, MATRIX_TYPES, () => {
                    return Math.floor(Math.random() * (particleLife.minRadiusRange[1] - particleLife.minRadiusRange[0] + 1) + particleLife.minRadiusRange[0])
                }))
                setMaxRadiusMatrix(resizeMatrix(maxRadiusMatrix, oldMatrixTypes, MATRIX_TYPES, () => {
                    return Math.floor(Math.random() * (particleLife.maxRadiusRange[1] - particleLife.maxRadiusRange[0] + 1) + particleLife.maxRadiusRange[0])
                }))

                updateAllInteractionBuffers()
                await relabelPopulation() // re-assign matter/urge/neuron types for the new color count
                colors = generateExtendedColors(particleLife.selectedColorPaletteOption)
                particleLife.currentColors = new Float32Array(colors)
                updateColorBuffer()
                updateSimOptionsBuffer()
                updateParticleBindGroups()
            }
            finally {
                isUpdatingParticles = false
                isUpdateNumTypesPending = NEW_NUM_TYPES !== NUM_TYPES
            }
        }
        const setNewElectricalCounts = () => { isUpdateElectricalPending = true }
        const updateElectricalCounts = async () => {
            if (isUpdatingParticles)
                return
            isUpdatingParticles = true
            await device.queue.onSubmittedWorkDone()
            try {
                // No matrix resize needed: the main matrix has fixed urge/neuron rows regardless of count.
                // (Sense neurons do NOT get their own matrix row — they ride the neuron row for drift.)
                numUrges = particleLife.numBrains
                numNeurons = particleLife.numNeurons
                numSenseNeurons = particleLife.numSenseNeurons
                updateAllInteractionBuffers() // rebuild the GPU buffer before relabeling
                await relabelPopulation()
                // Regenerate positions to avoid black-screen artifacts from stale spatial-hash state.
                // The in-place relabel can leave particles at positions that are inconsistent with
                // the new type layout (especially when the urge/neuron band boundaries shift), causing
                // the force pass to read garbage for one frame and produce a black flash.
                void updateParticlePositions()
                colors = generateExtendedColors(particleLife.selectedColorPaletteOption)
                particleLife.currentColors = new Float32Array(colors)
                updateColorBuffer()
                updateElectricalOptionsBuffer()
                updateSimOptionsBuffer()
            }
            finally {
                isUpdatingParticles = false
                isUpdateElectricalPending = false
            }
        }
        const loadPreset = async (options: { presetRules?: number[][], presetMinRadius?: number[][], presetMaxRadius?: number[][], presetColors?: Float32Array }, presetTypeCount: number, matchPresetCount: boolean) => {
            const { presetRules, presetMinRadius, presetMaxRadius, presetColors } = options

            if (isUpdatingParticles)
                return
            isUpdatingParticles = true
            await device.queue.onSubmittedWorkDone()

            try {
                const oldNumTypes = NUM_TYPES
                const newNumTypes = presetTypeCount
                if (newNumTypes === 0)
                    return

                if (!matchPresetCount) {
                    const typesToUpdate = Math.min(NUM_TYPES, newNumTypes)
                    if (presetColors)
                        await adjustColors(presetColors, NUM_TYPES, typesToUpdate, true) // Update only the colors that fit within the current NUM_TYPES
                    if (presetRules)
                        setRulesMatrix(applyPresetSubMatrix(rulesMatrix, presetRules, NUM_TYPES, typesToUpdate))
                    if (presetMinRadius)
                        setMinRadiusMatrix(applyPresetSubMatrix(minRadiusMatrix, presetMinRadius, NUM_TYPES, typesToUpdate))
                    if (presetMaxRadius)
                        setMaxRadiusMatrix(applyPresetSubMatrix(maxRadiusMatrix, presetMaxRadius, NUM_TYPES, typesToUpdate))
                }
                else {
                    if (presetColors) {
                        colors = presetColors
                        particleLife.currentColors = colors
                    }
                    else if (newNumTypes !== oldNumTypes) {
                        await adjustColors(colors, oldNumTypes, newNumTypes)
                    }

                    if (newNumTypes !== oldNumTypes) {
                        NUM_TYPES = newNumTypes
                        particleLife.numColors = NUM_TYPES

                        await adjustParticleTypes(oldNumTypes, newNumTypes)

                        if (presetRules) {
                            setRulesMatrix(presetRules)
                        }
                        else {
                            setRulesMatrix(resizeMatrix(rulesMatrix, oldNumTypes, newNumTypes, () => {
                                return Math.round((Math.random() * 2 - 1) * 100) / 100
                            }))
                        }
                        if (presetMinRadius) {
                            setMinRadiusMatrix(presetMinRadius)
                        }
                        else {
                            setMinRadiusMatrix(resizeMatrix(minRadiusMatrix, oldNumTypes, newNumTypes, () => {
                                return Math.floor(Math.random() * (particleLife.minRadiusRange[1] - particleLife.minRadiusRange[0] + 1) + particleLife.minRadiusRange[0])
                            }))
                        }
                        if (presetMaxRadius) {
                            setMaxRadiusMatrix(presetMaxRadius)
                        }
                        else {
                            setMaxRadiusMatrix(resizeMatrix(maxRadiusMatrix, oldNumTypes, newNumTypes, () => {
                                return Math.floor(Math.random() * (particleLife.maxRadiusRange[1] - particleLife.maxRadiusRange[0] + 1) + particleLife.maxRadiusRange[0])
                            }))
                        }

                        updateSimOptionsBuffer()
                    }
                    else {
                        if (presetRules)
                            setRulesMatrix(presetRules)
                        if (presetMinRadius)
                            setMinRadiusMatrix(presetMinRadius)
                        if (presetMaxRadius)
                            setMaxRadiusMatrix(presetMaxRadius)
                    }
                }

                updateColorBuffer()
                updateAllInteractionBuffers()
                // NOTE: presets only affect the matter↔matter block of the main matrix;
                // the urge/neuron rows/cols keep their current values across preset loads.
                // Keep the quantum/electrical layout consistent after a preset load
                await relabelPopulation()
                colors = generateExtendedColors(particleLife.selectedColorPaletteOption)
                particleLife.currentColors = new Float32Array(colors)
                updateColorBuffer()
                if (matchPresetCount && (newNumTypes !== oldNumTypes))
                    updateParticleBindGroups()
            }
            finally {
                isUpdatingParticles = false
                success("Preset loaded.")
            }
        }
        const applyPresetSubMatrix = (current: number[][], preset: number[][], numTypes: number, typesToUpdate: number): number[][] => {
            const result = current.map(row => row.slice())
            for (let i = 0; i < numTypes; i++) {
                for (let j = 0; j < numTypes; j++) {
                    if (i < typesToUpdate && j < typesToUpdate) {
                        result[i][j] = preset[i][j]
                    }
                }
            }
            return result
        }
        const adjustColors = async (oldColors: Float32Array, oldNumTypes: number, newNumTypes: number, keepExtraColors: boolean = false) => {
            const newColors = new Float32Array((keepExtraColors ? oldNumTypes : newNumTypes) * 4)
            if (keepExtraColors)
                newColors.set(colors)

            for (let i = 0; i < newNumTypes; i++) {
                const idx = i * 4
                newColors[idx] = oldColors[idx] ?? Math.random()
                newColors[idx + 1] = oldColors[idx + 1] ?? Math.random()
                newColors[idx + 2] = oldColors[idx + 2] ?? Math.random()
                newColors[idx + 3] = oldColors[idx + 3] ?? 1
            }
            colors = newColors
            particleLife.currentColors = colors // Ensure the store is updated with the new colors
        }
        const adjustParticleTypes = async (oldNumTypes: number, newNumTypes: number) => {
            const particleDataBuffer = await readBufferFromGPU(particleBuffer!, NUM_PARTICLES * PARTICLE_BYTES)
            const particles = new Float32Array(particleDataBuffer)

            if (newNumTypes < oldNumTypes) {
                for (let i = 0; i < NUM_PARTICLES; i++) {
                    const typeIndex = i * PARTICLE_STRIDE + 4
                    if (particles[typeIndex] >= newNumTypes && particles[typeIndex] < oldNumTypes) {
                        particles[typeIndex] = Math.floor(Math.random() * newNumTypes)
                    }
                }
            }
            else if (newNumTypes > oldNumTypes) {
                for (let i = 0; i < NUM_PARTICLES; i++) {
                    const typeIndex = i * PARTICLE_STRIDE + 4
                    const t = particles[typeIndex]
                    if (t < oldNumTypes && Math.random() < (newNumTypes - oldNumTypes) / newNumTypes) {
                        particles[typeIndex] = oldNumTypes + Math.floor(Math.random() * (newNumTypes - oldNumTypes))
                    }
                }
            }
            device.queue.writeBuffer(particleBuffer!, 0, particles)
        }
        // -------------------------------------------------------------------------------------------------------------
        async function readBufferFromGPU(buffer: GPUBuffer, size: number): Promise<ArrayBuffer> {
            const readBuffer = device.createBuffer({
                size,
                usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
            })
            const encoder = device.createCommandEncoder()
            encoder.copyBufferToBuffer(buffer, 0, readBuffer, 0, size)
            device.queue.submit([encoder.finish()])
            await readBuffer.mapAsync(GPUMapMode.READ)
            const arrayBuffer = readBuffer.getMappedRange().slice(0)
            readBuffer.unmap()
            readBuffer.destroy()
            return arrayBuffer
        }
        function resizeMatrix(matrix: number[][], oldNumTypes: number, newNumTypes: number, randomFn: () => number) {
            const newMatrix: number[][] = []
            for (let i = 0; i < newNumTypes; i++) {
                const row: number[] = []
                for (let j = 0; j < newNumTypes; j++) {
                    if (i < oldNumTypes && j < oldNumTypes) {
                        row.push(matrix[i][j])
                    }
                    else {
                        row.push(randomFn())
                    }
                }
                newMatrix.push(row)
            }
            return newMatrix
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // Build a full color table covering matter + urges + motor neurons + sense neurons + dormant
        // so the render pass can look up colors[u32(particleType)] for every type. Matter uses the
        // chosen palette; urges are a cyan->white ramp, motor neurons a red-orange->orange ramp,
        // sense neurons a cool cyan->magenta ramp (distinct from both), dormant is invisible (alpha=0).
        function generateExtendedColors(paletteId: number): Float32Array {
            const total = NUM_TYPES + numUrges + numNeurons + numSenseNeurons + 1 // +1 for the dormant type entry
            const out = new Float32Array(total * 4)
            const base = generateColors(paletteId, NUM_TYPES)
            out.set(base.subarray(0, Math.min(base.length, NUM_TYPES * 4)), 0)
            for (let k = 0; k < numUrges; k++) {
                const t = numUrges <= 1 ? 0 : k / (numUrges - 1)
                out[(NUM_TYPES + k) * 4] = 0.35 + 0.65 * t
                out[(NUM_TYPES + k) * 4 + 1] = 0.85
                out[(NUM_TYPES + k) * 4 + 2] = 1.0
                out[(NUM_TYPES + k) * 4 + 3] = 1
            }
            for (let m = 0; m < numNeurons; m++) {
                const t = numNeurons <= 1 ? 0 : m / (numNeurons - 1)
                out[(NUM_TYPES + numUrges + m) * 4] = 1.0
                out[(NUM_TYPES + numUrges + m) * 4 + 1] = 0.25 + 0.5 * t
                out[(NUM_TYPES + numUrges + m) * 4 + 2] = 0.15 * (1 - t)
                out[(NUM_TYPES + numUrges + m) * 4 + 3] = 1
            }
            for (let s = 0; s < numSenseNeurons; s++) {
                const t = numSenseNeurons <= 1 ? 0 : s / (numSenseNeurons - 1)
                // Cool cyan -> magenta ramp: clearly distinct from urges (light blue->white)
                // and motor neurons (red-orange->orange), so sensors read as their own class.
                out[(NUM_TYPES + numUrges + numNeurons + s) * 4] = 0.10 + 0.55 * t
                out[(NUM_TYPES + numUrges + numNeurons + s) * 4 + 1] = 0.85 - 0.60 * t
                out[(NUM_TYPES + numUrges + numNeurons + s) * 4 + 2] = 0.95
                out[(NUM_TYPES + numUrges + numNeurons + s) * 4 + 3] = 1
            }
            // Dormant type: invisible (alpha=0) — clone pool slots when not activated
            const dormantIdx = NUM_TYPES + numUrges + numNeurons + numSenseNeurons
            out[dormantIdx * 4] = 0; out[dormantIdx * 4 + 1] = 0; out[dormantIdx * 4 + 2] = 0; out[dormantIdx * 4 + 3] = 0
            return out
        }
        // Assign every particle a type according to the matter/urge/neuron/sense/clone-pool layout
        // and reset its electrical state.
        // Layout: [0, matterCount) matter (cycled colors), then urges, then motor neurons,
        // then sense neurons, then clone pool.
        // Clone pool particles get DORMANT_TYPE = NUM_TYPES + numUrges + numNeurons + numSenseNeurons
        // (invisible, no forces).
        function applyTypeLayout(arr: Float32Array): void {
            const dormantType = NUM_TYPES + numUrges + numNeurons + numSenseNeurons
            // Layout is [matterCount matter][numUrges urges][numNeurons neurons][numSenseNeurons sense][numClonePool pool]
            // and matterCount is the user's base count — the buffer was sized to hold all of it.
            const matterCount = Math.min(baseMatterCount, NUM_PARTICLES)
            for (let i = 0; i < NUM_PARTICLES; i++) {
                const k = i * PARTICLE_STRIDE
                let t: number
                if (i < matterCount)
                    t = i % NUM_TYPES
                else if (i < matterCount + numUrges)
                    t = NUM_TYPES + (i - matterCount)
                else if (i < matterCount + numUrges + numNeurons)
                    t = NUM_TYPES + numUrges + (i - matterCount - numUrges)
                else if (i < matterCount + numUrges + numNeurons + numSenseNeurons)
                    t = NUM_TYPES + numUrges + numNeurons + (i - matterCount - numUrges - numNeurons)
                else t = dormantType // clone pool: dormant
                arr[k + 4] = t
                arr[k + 5] = 0 // control
                // Urges start at signal=1.0 (the normalized mean) so nothing dies on frame 0
                // and there's no spurious dM kick. Sense neurons must NOT start at 1.0 — they
                // start at 0 (nothing sensed yet) so they don't fake a strong reading.
                arr[k + 6] = (t >= NUM_TYPES && t < NUM_TYPES + numUrges) ? 1.0 : 0
                arr[k + 7] = -1 // goalB: no secondary goal
                // Drive params are non-authoritative (genome buffer is source of truth).
                // Zero them for clarity.
                arr[k + 8] = 0
                arr[k + 9] = 0
                arr[k + 10] = 0
            }
        }
        // Re-label the live population to the current layout, preserving positions/velocities.
        async function relabelPopulation(): Promise<void> {
            const data = await readBufferFromGPU(particleBuffer!, NUM_PARTICLES * PARTICLE_BYTES)
            const arr = new Float32Array(data)
            applyTypeLayout(arr)
            device.queue.writeBuffer(particleBuffer!, 0, arr)
        }
        function initColors() {
            colors = generateExtendedColors(particleLife.selectedColorPaletteOption)
            particleLife.currentColors = new Float32Array(colors) // Ensure the store is updated with the initial colors
        }
        function initParticles() {
            initialParticles = generatePositions(particleLife.selectedSpawnPositionOption, NUM_PARTICLES, NUM_TYPES, SIM_WIDTH, SIM_HEIGHT)
            applyTypeLayout(initialParticles)
        }
        function makeRandomMinRadiusMatrix() {
            const matrix: number[][] = []
            const min: number = particleLife.minRadiusRange[0]
            const max: number = particleLife.minRadiusRange[1]
            for (let i = 0; i < MATRIX_TYPES; i++) {
                matrix.push([])
                for (let j = 0; j < MATRIX_TYPES; j++) {
                    const random = Math.floor(Math.random() * (max - min + 1) + min)
                    matrix[i].push(random)
                }
            }
            return matrix
        }
        function makeRandomMaxRadiusMatrix() {
            const matrix: number[][] = []
            const min: number = particleLife.maxRadiusRange[0]
            const max: number = particleLife.maxRadiusRange[1]
            for (let i = 0; i < MATRIX_TYPES; i++) {
                matrix.push([])
                for (let j = 0; j < MATRIX_TYPES; j++) {
                    const random = Math.floor(Math.random() * (max - min + 1) + min)
                    matrix[i].push(random)
                }
            }
            return matrix
        }
        const randomizeRadius = () => {
            setMinRadiusMatrix(makeRandomMinRadiusMatrix())
            setMaxRadiusMatrix(makeRandomMaxRadiusMatrix())
            updateAllInteractionBuffers()
        }
        const randomizeRulesAndRadius = () => {
            setRulesMatrix(generateRules(0, MATRIX_TYPES))
            setMinRadiusMatrix(makeRandomMinRadiusMatrix())
            setMaxRadiusMatrix(makeRandomMaxRadiusMatrix())
            updateAllInteractionBuffers()
        }
        const updateColors = async (useRandomGenerator: boolean | Event = false) => {
            const shouldRandom = typeof useRandomGenerator === 'boolean' ? useRandomGenerator : false
            if (shouldRandom)
                particleLife.selectedColorPaletteOption = paletteOptions[Math.floor(Math.random() * paletteOptions.length)].id

            colors = generateExtendedColors(particleLife.selectedColorPaletteOption)
            particleLife.currentColors = new Float32Array(colors)
            updateColorBuffer()
        }
        const updateRulesMatrix = async (useRandomGenerator: boolean | Event = false) => {
            const shouldRandom = typeof useRandomGenerator === 'boolean' ? useRandomGenerator : false
            if (shouldRandom)
                particleLife.selectedRulesOption = rulesOptions[Math.floor(Math.random() * rulesOptions.length)].id

            setRulesMatrix(generateRules(particleLife.selectedRulesOption, NUM_TYPES))
            updateAllInteractionBuffers()
        }
        const updateParticlePositions = async (useRandomGenerator: boolean | Event = false) => {
            const shouldRandom = typeof useRandomGenerator === 'boolean' ? useRandomGenerator : false
            if (shouldRandom)
                particleLife.selectedSpawnPositionOption = positionOptions[Math.floor(Math.random() * positionOptions.length)].id

            initialParticles = generatePositions(particleLife.selectedSpawnPositionOption, NUM_PARTICLES, NUM_TYPES, SIM_WIDTH, SIM_HEIGHT)
            device.queue.writeBuffer(particleBuffer!, 0, initialParticles.buffer)
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const updateSimWidth = (newWidth: number | Event) => {
            if (typeof (newWidth) !== 'number')
                return // Prevent input event like unfocus
            if (particleLife.linkProportions)
                particleLife.simHeight = SIM_HEIGHT = baseSimHeight = Math.round(SIM_HEIGHT * (newWidth / SIM_WIDTH))
            particleLife.simWidth = SIM_WIDTH = baseSimWidth = newWidth
            applySimResize()
        }
        const updateSimHeight = (newHeight: number | Event) => {
            if (typeof (newHeight) !== 'number')
                return // Prevent input event like unfocus
            if (particleLife.linkProportions)
                particleLife.simWidth = SIM_WIDTH = baseSimWidth = Math.round(SIM_WIDTH * (newHeight / SIM_HEIGHT))
            particleLife.simHeight = SIM_HEIGHT = baseSimHeight = newHeight
            applySimResize()
        }
        const applySimResize = async () => {
            if (isTrackerActive)
                await stopTracker()
            cancelAnimationLoop()
            setSimSize()
            updateSimOptionsBuffer()
            void updateParticlePositions()
            animationFrameId = requestAnimationFrame(frame)
        }
        const updateRulesMatrixValue = (x: number, y: number, value: number) => {
            const roundedValue = Math.round(value * 100) / 100
            particleLife.rulesMatrix[x][y] = roundedValue
            rulesMatrix[x][y] = roundedValue
            updateInteractionMatrixBuffer()
        }
        const updateMinMatrixValue = (x: number, y: number, value: number) => {
            particleLife.minRadiusMatrix[x][y] = value
            minRadiusMatrix[x][y] = value
            if (value > particleLife.maxRadiusMatrix[x][y]) {
                particleLife.maxRadiusMatrix[x][y] = value
                maxRadiusMatrix[x][y] = value
                setCurrentMaxRadius(getCurrentMaxRadius())
            }
            updateInteractionMatrixBuffer()
        }
        const updateMaxMatrixValue = (x: number, y: number, value: number) => {
            particleLife.maxRadiusMatrix[x][y] = value
            maxRadiusMatrix[x][y] = value
            setCurrentMaxRadius(getCurrentMaxRadius())
            if (value < particleLife.minRadiusMatrix[x][y]) {
                particleLife.minRadiusMatrix[x][y] = value
                minRadiusMatrix[x][y] = value
            }
            updateInteractionMatrixBuffer()
        }
        const newRandomRulesMatrix = () => {

        }
        function setRulesMatrix(newRules: number[][]) {
            rulesMatrix = newRules
            particleLife.rulesMatrix = rulesMatrix
        }
        function setMinRadiusMatrix(newMinRadius: number[][]) {
            minRadiusMatrix = newMinRadius
            particleLife.minRadiusMatrix = minRadiusMatrix
        }
        function setMaxRadiusMatrix(newMaxRadius: number[][]) {
            maxRadiusMatrix = newMaxRadius
            particleLife.maxRadiusMatrix = maxRadiusMatrix
            setCurrentMaxRadius(getCurrentMaxRadius())
        }
        // -------------------------------------------------------------------------------------------------------------
        const getCurrentMaxRadius = () => {
            let maxRandom = 0
            for (let i = 0; i < MATRIX_TYPES; i++) {
                for (let j = 0; j < MATRIX_TYPES; j++) {
                    if (maxRadiusMatrix[i][j] > maxRandom)
                        maxRandom = maxRadiusMatrix[i][j]
                }
            }
            return maxRandom
        }
        // The neighbor scan window is a SQUARE of (2*cellSubdivisions+1) cells. Any interaction
        // radius larger than that window gets clipped to the square -> axis-aligned "empty squares".
        // So CELL_SIZE must be sized from the LARGEST radius in play: matter maxRadius, urgeRadius,
        // or senseRadius (the sense scan must see the full perception disk).
        const effectiveMaxRadius = () => Math.max(currentMaxRadius, particleLife.isElectricalEnabled ? Math.max(particleLife.urgeRadius, particleLife.senseRadius) : 0)
        const recomputeCellSize = () => {
            const newSize = Math.max(1, Math.ceil(effectiveMaxRadius() / CELL_SUBDIVISIONS))
            if (newSize === CELL_SIZE)
                return // only rebuild the grid when it actually changes
            CELL_SIZE = newSize
            setSimSize()
            updateSimOptionsBuffer()
        }
        const setCurrentMaxRadius = (value: number) => {
            if (currentMaxRadius === value)
                return
            currentMaxRadius = value
            particleLife.currentMaxRadius = value
            recomputeCellSize()
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        const colorRgbStrings = computed(() => {
            const arr = particleLife.currentColors
            if (!arr)
                return []
            const result: string[] = []
            for (let i = 0; i < arr.length; i += 4) {
                const r = Math.round(arr[i] * 255)
                const g = Math.round(arr[i + 1] * 255)
                const b = Math.round(arr[i + 2] * 255)
                result.push(`rgb(${r}, ${g}, ${b})`)
            }
            return result
        })
        // -------------------------------------------------------------------------------------------------------------
        const updateSingleColor = (colorId: number, hex: string) => {
            const rgb = hexToRgb(hex)
            if (!rgb)
                return
            const idx = colorId * 4
            colors[idx] = rgb[0] / 255
            colors[idx + 1] = rgb[1] / 255
            colors[idx + 2] = rgb[2] / 255
            particleLife.currentColors = new Float32Array(colors) // New reference to trigger reactivity
            updateColorBuffer()
        }
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------
        function watchAndUpdateSimOptions(effect: any, callback: any) {
            watch(effect, (value) => {
                callback(value)
                updateSimOptionsBuffer()
            })
        }
        function watchAndUpdateGlowOptions(effect: any, callback: any) {
            watch(effect, (value) => {
                callback(value)
                updateGlowOptionsBuffer()
            })
        }
        watch(() => particleLife.isRunning, (value: boolean) => isRunning = value)
        watch(() => particleLife.useSpatialHash, (value: boolean) => useSpatialHash = value)
        watch(() => particleLife.isParticleGlow, (value: boolean) => isParticleGlow = value)
        watch(() => particleLife.isAdditiveBlending, (value: boolean) => isAdditiveBlending = value)
        watch(() => particleLife.isBrushActive, (value: boolean) => isBrushActive = value)
        watch(() => particleLife.brushType, (value: number) => brushType = value)
        watch(() => particleLife.brushes, (value: number[]) => { brushes = value; updateBrushesBuffer() }, { deep: true })
        watch(() => particleLife.brushRadius, (value: number) => brushRadius = value)
        watch(() => particleLife.brushIntensity, (value: number) => brushIntensity = value)
        watch(() => particleLife.repulseForce, (value: number) => repulseForce = value)
        watch(() => particleLife.attractForce, (value: number) => attractForce = -value)
        watch(() => particleLife.brushDirectionalForce, (value: number) => brushDirectionalForce = value)
        watch(() => particleLife.showBrushCircle, (value: boolean) => showBrushCircle = value)
        watch(() => particleLife.zoomSmoothing, (value: number) => zoomSmoothing = value)
        watch(() => particleLife.panSmoothing, (value: number) => panSmoothing = value)
        watch(() => particleLife.isDriftCamActive, (value: boolean) => { value && initDriftCamera(); isDriftCamActive = value })
        watch(() => particleLife.driftCamResetOnPan, (value: boolean) => driftCamResetOnPan = value)
        watch(() => particleLife.driftCamSpeed, (value: number) => driftCamSpeed = value)
        watch(() => particleLife.driftCamAmplitude, (value: number) => driftCamAmplitude = value)
        watch(() => particleLife.driftCamZoomRange, (value: number[]) => {
            driftCamZoomRange = value
            driftCamZoomCenter = (driftCamZoomRange[1] + driftCamZoomRange[0]) * 0.5 // Center zoom level for driftCam
            driftCamZoomAmplitude = (driftCamZoomRange[1] - driftCamZoomRange[0]) * 0.5 // Amplitude of zoom changes for driftCam
        }, { deep: true })

        watch(() => particleLife.isTrackerIndicatorVisible, (value: boolean) => isTrackerIndicatorVisible = value)
        watch(() => particleLife.isTrackerSelectionActive, (value: boolean) => particleLife.isHudLocked = value)
        watch(() => particleLife.isTrackerActive, (value: boolean) => {
            isTrackerActive = value
            isCameraTracking = isTrackerActive && isTrackerCameraActive
        })
        watch(() => particleLife.isTrackerCameraActive, async (value: boolean) => {
            if (isTrackerActive && !value)
                await syncCameraFromGPU()
            // Update baseCameraX/Y to current camera position so smoothing starts from here when tracker camera is re-enabled.
            if (isTrackerActive && value)
                device.queue.writeBuffer(trackerStateBuffer!, 24, new Float32Array([cameraCenter.x, cameraCenter.y]))
            resetTrackerCameraOffset()
            isTrackerCameraActive = value
            isCameraTracking = isTrackerActive && isTrackerCameraActive
        })
        watch(() => particleLife.trackerCameraSmoothing, (value: number) => {
            device.queue.writeBuffer(trackerCameraOptionsBuffer!, 8, new Float32Array([value]))
        })

        watchAndUpdateGlowOptions(() => particleLife.glowSize, (value: number) => glowSize = value)
        watchAndUpdateGlowOptions(() => particleLife.glowIntensity, (value: number) => glowIntensity = value)
        watchAndUpdateGlowOptions(() => particleLife.glowSteepness, (value: number) => glowSteepness = value)

        watchAndUpdateSimOptions(() => particleLife.particleOpacity, (value: number) => particleOpacity = value)
        watchAndUpdateSimOptions(() => particleLife.mirrorWrapCount, (value: number) => mirrorWrapCount = value)
        watchAndUpdateSimOptions(() => particleLife.particleSize, (value: number) => PARTICLE_SIZE = value)
        watchAndUpdateSimOptions(() => particleLife.repel, (value: number) => repel = value)
        watchAndUpdateSimOptions(() => particleLife.forceFactor, (value: number) => forceFactor = value)
        watchAndUpdateSimOptions(() => particleLife.frictionFactor, (value: number) => {
            frictionFactor = value
            updateDeltaTimeBuffer(manualDeltaTimeEnabled ? manualDeltaTime : smoothedDeltaTime)
        })
        watchAndUpdateSimOptions(() => particleLife.magneticStrength, () => {})

        // ---- Quantum / Electrical layer watchers -----------------------------------------
        // Changing the counts re-labels the population (matter/urge/neuron layout).
        watch(() => particleLife.numBrains, () => setNewElectricalCounts())
        watch(() => particleLife.numNeurons, () => setNewElectricalCounts())
        // Sense count changes are different: sense neurons are part of the NON-POOL population,
        // so the buffer must be resized to include them (like matter), and the following frame
        // re-labels + recolors for the new sense band (colors/electrical/sim option buffers).
        watch(() => particleLife.numSenseNeurons, () => {
            numSenseNeurons = particleLife.numSenseNeurons
            const target = baseMatterCount + numUrges + numNeurons + numSenseNeurons + numClonePool
            if (target !== NUM_PARTICLES) {
                NEW_NUM_PARTICLES = target
                isUpdateNumParticlesPending = true
            }
            setNewElectricalCounts()
        })
        // Changing a parameter just rewrites the electrical uniform.
        const watchElectrical = (effect: any) => watch(effect, () => updateElectricalOptionsBuffer())
        watchElectrical(() => particleLife.isElectricalEnabled)
        watchElectrical(() => particleLife.urgeRadius)
        watchElectrical(() => particleLife.neuronRadius)
        watchElectrical(() => particleLife.urgeForce)
        watchElectrical(() => particleLife.brainGain)
        watchElectrical(() => particleLife.cohesion)
        watchElectrical(() => particleLife.senseRadius)
        watchElectrical(() => particleLife.senseConeHalfAngleDeg)
        watchElectrical(() => particleLife.senseMode)
        watch(() => particleLife.isDebugConnections, (value: boolean) => { isDebugConnections = value; updateSimOptionsBuffer() })
        // A larger urge radius needs a coarser grid so its field isn't clipped to the square scan window.
        watch(() => particleLife.urgeRadius, () => {
            if (particleLife.isElectricalEnabled)
                recomputeCellSize()
        })
        // Same for the sense perception disk: the bin scan must cover the full senseRadius.
        watch(() => particleLife.senseRadius, () => {
            if (particleLife.isElectricalEnabled)
                recomputeCellSize()
        })
        watch(() => particleLife.isElectricalEnabled, () => recomputeCellSize())

        // ---- Brain Inspector: throttled, READ-ONLY GPU telemetry ---------------------------
        // Off by default and zero-cost when off: no interval, no allocation, no readback.
        // It only ever reads `particleBuffer` — it never mutates particle state or the buffer.
        const URGE_READBACK_INTERVAL_MS = 200
        const urgeInspectorOpen = ref<boolean>(false)
        const urgeStats = ref<UrgeStat[]>([])
        let isReadingBackUrges = false // concurrency guard: one readback in flight at a time
        let urgeReadbackTimer: number | null = null
        // Previous per-urge values (keyed by urge id) so we can show a trend between readbacks.
        let prevUrgeValues = new Map<number, { control: number, signal: number }>()

        // ---- Stable clone identity across readbacks --------------------------------------
        // Clones have no persistent GPU-side id (a dormant-pool slot re-labeled with a fractional
        // type tag), so we match each live clone to its previous-readback identity by NEAREST
        // POSITION — clones move continuously, so at 200 ms apart they can't teleport past each
        // other. This gives every clone a STABLE UNIQUE id: every clone gets its own tracking
        // card that doesn't vanish (old bug: all siblings shared one id and dedup dropped them)
        // and rows don't jump around when siblings are born or die.
        // The matching itself is pure + unit-tested in helpers/utils/cloneIdentity.ts.
        const cloneRegistry = new Map<number, Map<number, { x: number, y: number }>>() // parentK -> cloneId -> last pos
        const cloneSeq = new Map<number, number>() // parentK -> next clone sequence number

        // ---- On-canvas tracking of a single selected urge -------------------------------
        const selectedUrgeId = ref<number>(-1) // which urge (local index) to highlight on the canvas (-1 = none)
        const urgeMarkerEl = ref<HTMLElement | null>(null) // moving marker element (positioned imperatively)
        const urgeMarkerStatEl = ref<HTMLElement | null>(null) // live control/metric readout in the marker label
        // Last-known world position + velocity of every urge, refreshed on each throttled readback.
        let urgeWorldPos = new Map<number, { x: number, y: number, vx: number, vy: number }>()
        let lastReadTimeMs = 0 // wall-clock time of the most recent readback (for velocity extrapolation)

        // Snapshot of the global electrical parameters for the parameter card (reactive).
        // These are the ACTIVE knobs the brain layer responds to — no deprecated/legacy zeros.
        const electricalParams = computed<ElectricalParams>(() => ({
            brainGain: particleLife.brainGain,
            brainLearnRate: particleLife.brainLearnRate,
            urgeRadius: particleLife.urgeRadius,
            neuronRadius: particleLife.neuronRadius,
            urgeForce: particleLife.urgeForce,
            cohesion: particleLife.cohesion,
            senseRadius: particleLife.senseRadius,
            senseMode: particleLife.senseMode,
        }))

        // A brain's objective is homeostasis across its K genome needs (need i targets color
        // i % NUM_TYPES at a per-need setpoint). That mapping is fixed at init, so the label is
        // stable; the live per-need metrics are shown in the card from the readback.
        // (kept as a 1-arg function for the existing prop contract; the label is uniform
        // across brains, so the index is intentionally unused.)
        const objectiveLabelFor = (_k?: number): string => {
            return `Homeostasis across ${GENOME_K} need-colors (keep each near its setpoint)`
        }

        // Colour + short objective for the on-canvas marker (reactive; only changes on selection/metric change).
        // Resolve the parent urge k for the currently selected row (clones use their parent's k).
        const selectedParentK = computed(() => {
            const id = selectedUrgeId.value
            if (id >= 0)
                return id // original urge: id IS the parent k
            const row = urgeStats.value.find(s => s.id === id)
            return row?.cloneOf ?? 0
        })
        const markerColor = computed(() => {
            if (selectedUrgeId.value === -1)
                return '#ffffff'
            const k = selectedParentK.value
            const idx = ((k % particleLife.numColors) + particleLife.numColors) % particleLife.numColors
            return colorRgbStrings.value[idx] ?? '#ffffff'
        })
        const markerObjective = computed(() => {
            if (selectedUrgeId.value === -1)
                return ''
            return objectiveLabelFor(selectedParentK.value)
        })
        // Display label for the on-canvas marker (clones show their lineage, e.g. "#3-C1").
        const markerLabel = computed(() => {
            const id = selectedUrgeId.value
            if (id >= 0)
                return `#${id}`
            const row = urgeStats.value.find(s => s.id === id)
            if (row?.isClone && row.cloneOf !== undefined)
                return `#${row.cloneOf}-C${row.cloneId ?? 1}`
            return `#${id}`
        })

        // Build an accurate per-brain neural-network snapshot from the real GPU buffers.
        // k = local brain index. genome holds needs + weights; neuronMods holds the live net
        // outputs (one per motor neuron); brainMetrics holds the per-need live density metric;
        // owners maps each sense/motor neuron to its owning brain (0xFFFFFFFF = free).
        const buildBrainNet = (
            k: number,
            genome: Float32Array,
            neuronMods: Float32Array | null,
            brainMetrics: Float32Array | null,
            owners: Uint32Array,
        ): BrainNet => {
            const base = k * GENOME_STRIDE

            // K needs (targetColor stored as u32-as-f32) + live metric + teaching error.
            const needs: NeedStat[] = []
            let teachSum = 0
            let metricSum = 0
            let metNeeds = 0
            for (let i = 0; i < GENOME_K; i++) {
                const nb = base + i * 4
                const targetColor = Math.round(genome[nb]) % NUM_TYPES
                const setpoint = genome[nb + 1]
                const scale = Math.max(genome[nb + 2], 0.1)
                const gain = genome[nb + 3]
                const metric = brainMetrics ? brainMetrics[k * GENOME_K + i] : 0
                // Mirror brainStep.wgsl: err = clamp((setpoint - metric)/scale, ±1) * gain
                const error = Math.max(-1, Math.min(1, (setpoint - metric) / scale)) * gain
                needs.push({ targetColor, setpoint, scale, gain, metric, error })
                teachSum += error
                metricSum += metric
                // Homeostasis met when the live metric sits inside the target band.
                if (Math.abs(metric - setpoint) <= scale)
                    metNeeds++
            }
            const teach = teachSum / GENOME_K
            const meanMetric = metricSum / GENOME_K

            // Ownership: which sense + motor neurons this brain controls.
            let ownedSense = 0
            for (let s = 0; s < numSenseNeurons; s++) {
                if (owners[s] === k) {
                    ownedSense++
                }
            }
            const ownedMotorIdx: number[] = []
            for (let m = 0; m < numNeurons; m++) {
                if (owners[numSenseNeurons + m] === k) {
                    ownedMotorIdx.push(m)
                }
            }

            // Net shape must mirror brainStep.wgsl exactly (S/M capped at MAX_S/MAX_M=32).
            const S = Math.min(ownedSense, 32)
            const M = Math.min(ownedMotorIdx.length, 32)
            let H: number
            let depth: number
            if (S + M <= 8) {
                H = Math.max(4, Math.min(32, Math.floor((S * M + 1) / 2)))
                depth = 1
            }
            else {
                const hCalc = Math.sqrt(Math.max(S, 1) * Math.max(M, 1))
                H = Math.min(32, Math.max(4, Math.round(hCalc)))
                depth = 2
            }

            // Live net outputs (neuronMods is the pre-brainGain drive, signed [-1,1]).
            let meanDrive = 0
            let maxAbsDrive = 0
            let activeMuscles = 0
            if (neuronMods && ownedMotorIdx.length) {
                let sum = 0
                for (const m of ownedMotorIdx) {
                    const d = neuronMods[m]
                    sum += d
                    const a = Math.abs(d)
                    if (a > maxAbsDrive)
                        maxAbsDrive = a
                    if (a > 0.1)
                        activeMuscles++
                }
                meanDrive = sum / ownedMotorIdx.length
            }

            // Weight statistics over the USED region of the net (first usedWeights floats).
            const usedWeights = S * H + H + (depth === 2 ? H * H + H : 0) + H * M + M
            let strongWeights = 0
            let weightMaxAbs = 0
            for (let w = 0; w < usedWeights; w++) {
                const a = Math.abs(genome[base + GENOME_NEEDS_SIZE + w])
                if (a > 0.5)
                    strongWeights++
                if (a > weightMaxAbs)
                    weightMaxAbs = a
            }

            return { S, M, H, depth, meanDrive, maxAbsDrive, activeMuscles, teach, metNeeds, meanMetric, usedWeights, strongWeights, weightMaxAbs, needs }
        }

        // A single guarded readback. Never runs while a resize/erase is mutating buffers.
        const readUrgeStats = async () => {
            if (!urgeInspectorOpen.value)
                return
            if (isReadingBackUrges)
                return
            if (isUpdatingParticles || isEraseCompleting)
                return
            if (!particleBuffer || !device)
                return

            // No urges to sample: show the empty state and stop here (no GPU work).
            if (!particleLife.isElectricalEnabled || numUrges <= 0) {
                if (urgeStats.value.length !== 0)
                    urgeStats.value = [] // avoid reactive churn when already empty
                prevUrgeValues.clear()
                cloneRegistry.clear()
                cloneSeq.clear()
                return
            }

            isReadingBackUrges = true
            try {
                const arrayBuffer = await readBufferFromGPU(particleBuffer, NUM_PARTICLES * PARTICLE_BYTES)
                // Re-check guards after the await — a resize/erase may have started meanwhile.
                if (!urgeInspectorOpen.value || isUpdatingParticles || isEraseCompleting)
                    return

                const particles = new Float32Array(arrayBuffer)

                // ---- Read back the REAL brain data. The particle-buffer control/signal fields
                // are non-authoritative for brains (hardcoded 0 / stale proxy); the genome,
                // neuronMods, brainMetrics and ownership buffers are the source of truth.
                let genome: Float32Array | null = null
                let neuronMods: Float32Array | null = null
                let brainMetrics: Float32Array | null = null
                let owners: Uint32Array | null = null
                if (genomeBuffer && numUrges > 0) {
                    genome = new Float32Array(await readBufferFromGPU(genomeBuffer, numUrges * GENOME_STRIDE * 4))
                    if (!urgeInspectorOpen.value || isUpdatingParticles || isEraseCompleting)
                        return
                }
                if (neuronModsBuffer && numNeurons > 0) {
                    neuronMods = new Float32Array(await readBufferFromGPU(neuronModsBuffer, numNeurons * 4))
                    if (!urgeInspectorOpen.value || isUpdatingParticles || isEraseCompleting)
                        return
                }
                if (brainMetricsBuffer && numUrges > 0) {
                    brainMetrics = new Float32Array(await readBufferFromGPU(brainMetricsBuffer, numUrges * GENOME_K * 4))
                    if (!urgeInspectorOpen.value || isUpdatingParticles || isEraseCompleting)
                        return
                }
                if (neuronOwnersBuffer && (numNeurons > 0 || numSenseNeurons > 0)) {
                    owners = new Uint32Array(await readBufferFromGPU(neuronOwnersBuffer, (numSenseNeurons + numNeurons) * 4))
                    if (!urgeInspectorOpen.value || isUpdatingParticles || isEraseCompleting)
                        return
                }

                // Build one accurate neural-network snapshot per local brain k.
                const brainNets = new Map<number, BrainNet>()
                if (genome && owners) {
                    for (let k = 0; k < numUrges; k++)
                        brainNets.set(k, buildBrainNet(k, genome, neuronMods, brainMetrics, owners))
                }

                // Collect urges (originals + clones), motor neurons, and sense neurons.
                // Clones are identified by the fractional part of their type float (set to .5 at
                // activation; the shader truncates via u32() so it sees the same integer type).
                const urgeEntries: { k: number, isClone: boolean, x: number, y: number, vx: number, vy: number, displayId: number }[] = []
                const motorNeuronPos: { x: number, y: number }[] = []
                const senseNeuronPos: { x: number, y: number, mode: number }[] = [] // mode: 0=sight, 1=smell, 2=sound

                for (let i = 0; i < NUM_PARTICLES; i++) {
                    const idx = i * PARTICLE_STRIDE
                    const rawType = particles[idx + 4]
                    const intType = Math.floor(rawType)
                    if (intType < NUM_TYPES)
                        continue // matter (control/signal are always 0)
                    const localType = intType - NUM_TYPES
                    if (localType < numUrges) {
                        const isClone = rawType - intType > 0.1 // fractional tag = clone
                        urgeEntries.push({ k: localType, isClone, x: particles[idx], y: particles[idx + 1], vx: particles[idx + 2], vy: particles[idx + 3], displayId: 0 })
                    }
                    else if (localType - numUrges < numNeurons) {
                        // Motor neuron (muscle)
                        motorNeuronPos.push({ x: particles[idx], y: particles[idx + 1] })
                    }
                    else if (localType - numUrges - numNeurons < numSenseNeurons) {
                        // Sense neuron: determine its sense mode (mirrors shader logic)
                        const sIdx = localType - numUrges - numNeurons
                        let sMode: number
                        switch (particleLife.senseMode % 4) {
                            case 0: sMode = sIdx % 3; break // cycle all three
                            case 1: sMode = 0; break // all sight
                            case 2: sMode = 1; break // all smell
                            default: sMode = 2; break // all sound
                        }
                        senseNeuronPos.push({ x: particles[idx], y: particles[idx + 1], mode: sMode })
                    }
                }

                // Assign stable display ids: originals = k; clones matched to their identity by
                // nearest position (see matchCloneIds). Every live clone ends up with a UNIQUE id,
                // so multi-clone parents no longer lose rows to dedup.
                for (const u of urgeEntries)
                    u.displayId = u.isClone ? -1 : u.k
                {
                    const cloneLists = new Map<number, { x: number, y: number, id: number }[]>()
                    for (const u of urgeEntries) {
                        if (!u.isClone)
                            continue
                        let list = cloneLists.get(u.k)
                        if (!list) {
                            list = []
                            cloneLists.set(u.k, list)
                        }
                        list.push({ x: u.x, y: u.y, id: -1 })
                    }
                    // Match each parent's clones to their known identities (pure helper).
                    const idByParent = new Map<number, number[]>()
                    for (const [k, list] of cloneLists)
                        idByParent.set(k, assignCloneIds(k, list, cloneRegistry, cloneSeq))
                    // Write matched ids back onto the entries (scan order per parent is preserved).
                    const cursor = new Map<number, number>()
                    for (const u of urgeEntries) {
                        if (!u.isClone)
                            continue
                        const i = cursor.get(u.k) ?? 0
                        u.displayId = idByParent.get(u.k)![i]
                        cursor.set(u.k, i + 1)
                    }
                    pruneCloneRegistry(new Set(cloneLists.keys()), cloneRegistry, cloneSeq)
                }

                // Build rows. Clone sequence number (C1, C2, ...) is recovered from the id scheme.
                const muscleR2 = particleLife.neuronRadius * particleLife.neuronRadius
                const senseR2 = particleLife.senseRadius * particleLife.senseRadius
                const next: UrgeStat[] = urgeEntries.map((u) => {
                    let muscles = 0
                    let eyes = 0
                    let ears = 0
                    let nose = 0
                    for (let n = 0; n < motorNeuronPos.length; n++) {
                        const dx = u.x - motorNeuronPos[n].x
                        const dy = u.y - motorNeuronPos[n].y
                        if (dx * dx + dy * dy <= muscleR2)
                            muscles++
                    }
                    for (let s = 0; s < senseNeuronPos.length; s++) {
                        const dx = u.x - senseNeuronPos[s].x
                        const dy = u.y - senseNeuronPos[s].y
                        if (dx * dx + dy * dy <= senseR2) {
                            if (senseNeuronPos[s].mode === 0)
                                eyes++
                            else if (senseNeuronPos[s].mode === 1)
                                nose++
                            else
                                ears++
                        }
                    }
                    const wired = muscles + eyes + ears + nose
                    const id = u.displayId
                    // Clones share their parent's genome slot, so they show the same net.
                    const brain = brainNets.get(u.k)
                    return {
                        id,
                        type: NUM_TYPES + u.k,
                        targetColor: u.k % NUM_TYPES,
                        control: brain ? brain.maxAbsDrive : 0, // peak actuation 0..1 (mean cancels to ~0 across colors)
                        signal: brain ? brain.meanMetric : 0, // live aggregate metric (was stale proxy)
                        trendControl: 0,
                        trendSignal: 0,
                        wiredNeurons: wired,
                        wiredMuscles: muscles,
                        wiredEyes: eyes,
                        wiredEars: ears,
                        wiredNose: nose,
                        brain,
                        ...(u.isClone ? { isClone: true as const, cloneOf: u.k, cloneId: -id - (u.k + 1) * 1000 } : {}),
                    }
                })

                // Deduplicate by id (defensive: prevents stale buffer data from producing repeated rows).
                const seen = new Set<number>()
                const deduped = next.filter((s) => {
                    if (seen.has(s.id))
                        return false; seen.add(s.id); return true
                })

                // Stable row order: group by parent (original + its clones together), original
                // first, then clones in birth order. Rows only move when their own urge dies —
                // never when an unrelated clone is born elsewhere.
                deduped.sort(compareUrgeRows)
                const newPrev = new Map<number, { control: number, signal: number }>()
                for (const s of deduped) {
                    const prev = prevUrgeValues.get(s.id)
                    if (prev) {
                        // Net output + aggregate metric change readback to readback as the net runs.
                        s.trendControl = s.control - prev.control
                        s.trendSignal = s.signal - prev.signal
                    }
                    newPrev.set(s.id, { control: s.control, signal: s.signal })
                }
                prevUrgeValues = newPrev // prunes ids that no longer exist
                urgeStats.value = deduped

                // Auto-deselect if the currently selected urge died (its id is missing from new stats)
                if (selectedUrgeId.value !== -1 && !deduped.some(s => s.id === selectedUrgeId.value)) {
                    selectedUrgeId.value = -1
                }

                // Refresh the on-canvas tracking data (positions + velocities) keyed by row id.
                const posMap = new Map<number, { x: number, y: number, vx: number, vy: number }>()
                for (const u of urgeEntries)
                    posMap.set(u.displayId, { x: u.x, y: u.y, vx: u.vx, vy: u.vy })
                urgeWorldPos = posMap
                lastReadTimeMs = performance.now()

                // Refresh the live control/metric readout in the on-canvas marker (if one is tracked).
                if (urgeMarkerStatEl.value && selectedUrgeId.value !== -1) {
                    const sel = deduped.find(s => s.id === selectedUrgeId.value)
                    urgeMarkerStatEl.value.textContent = sel ? `net ${sel.control >= 0 ? '+' : ''}${sel.control.toFixed(2)} · metric ${sel.signal.toFixed(2)}` : ''
                }
            }
            catch {
                // Ignore transient readback failures (e.g. a buffer swap mid-flight); the next tick retries.
            }
            finally {
                isReadingBackUrges = false
            }
        }

        const stopUrgeReadback = () => {
            if (urgeReadbackTimer !== null) {
                window.clearInterval(urgeReadbackTimer)
                urgeReadbackTimer = null
            }
        }
        const startUrgeReadback = () => {
            stopUrgeReadback()
            if (!urgeInspectorOpen.value)
                return
            prevUrgeValues.clear()
            void readUrgeStats() // immediate first sample so the panel isn't blank
            urgeReadbackTimer = window.setInterval(() => { void readUrgeStats() }, URGE_READBACK_INTERVAL_MS)
        }

        // ---- Experiment telemetry: opt-in, throttled, READ-ONLY -------------------------
        // Off by default and zero-cost when off (no readback, no allocation). Mirrors the
        // Brain Inspector pattern: a single guarded GPU readback of `particleBuffer`, parsed
        // into a Float32Array and fed to the pure helpers in helpers/utils/experimentMetrics.ts.
        //
        // MVE sweep protocol (control-gap inverted-U): fix numParticles=64000, numColors=7,
        // frictionFactor=0.3, magneticStrength=0; enable telemetry; vary `urgeForce` 0.0→1.5
        // in 0.1 steps (and/or sweep `brainGain`); export `experimentLog` as JSON and plot
        // noveltyRate (or entropy) vs the control gap.
        // Body-autonomy grid (no extra code): set frictionFactor ∈ {0.05,0.1,0.2,0.3,0.5,0.7}
        // × magneticStrength ∈ {0,0.3,0.8,1.5} via the sliders — both are already captured
        // in every sample above; run each cell with telemetry on and compare novelty/entropy.
        const EXPERIMENT_SAMPLE_INTERVAL_FRAMES = 50 // sample every N rendered frames
        const EXPERIMENT_LOG_CAP = 1000 // ring-buffer cap (drop oldest beyond this)
        interface ExperimentSample {
            frame: number
            urgeForce: number
            brainGain: number
            frictionFactor: number
            magneticStrength: number
            entropy: number
            noveltyRate: number
            controlGap: number
        }
        const isExperimentTelemetry = ref(false)
        const experimentLog = ref<ExperimentSample[]>([])
        let experimentFrameCounter = 0
        let prevExperimentEntropy: number | null = null
        let isSamplingExperiment = false // concurrency guard: one readback in flight at a time

        const clearExperimentLog = () => {
            experimentLog.value = []
            prevExperimentEntropy = null
        }

        // One guarded, throttled sample. Runs at most once every EXPERIMENT_SAMPLE_INTERVAL_FRAMES
        // rendered frames and never while a resize/erase is mutating buffers.
        const sampleExperimentTelemetry = () => {
            if (!isExperimentTelemetry.value)
                return
            experimentFrameCounter++
            if (experimentFrameCounter % EXPERIMENT_SAMPLE_INTERVAL_FRAMES !== 0)
                return
            if (isSamplingExperiment)
                return
            if (isUpdatingParticles || isEraseCompleting)
                return
            if (!particleBuffer || !device)
                return

            isSamplingExperiment = true
            void (async () => {
                try {
                    const arrayBuffer = await readBufferFromGPU(particleBuffer, NUM_PARTICLES * PARTICLE_BYTES)
                    // Re-check guards after the await — a resize/erase may have started meanwhile.
                    if (!isExperimentTelemetry.value || isUpdatingParticles || isEraseCompleting)
                        return
                    const particles = new Float32Array(arrayBuffer)
                    const entropy = measureMatterEntropy(particles, { numTypes: NUM_TYPES, simWidth: SIM_WIDTH, simHeight: SIM_HEIGHT })
                    const novelty = prevExperimentEntropy === null ? 0 : noveltyRate(prevExperimentEntropy, entropy)
                    prevExperimentEntropy = entropy
                    const controlGap = measureControlGap(particles, { numTypes: NUM_TYPES, numUrges, numNeurons, urgeRadius: particleLife.urgeRadius })
                    experimentLog.value.push({
                        frame: experimentFrameCounter,
                        urgeForce: particleLife.urgeForce,
                        brainGain: particleLife.brainGain,
                        frictionFactor: particleLife.frictionFactor,
                        magneticStrength: particleLife.magneticStrength,
                        entropy,
                        noveltyRate: novelty,
                        controlGap,
                    })
                    if (experimentLog.value.length > EXPERIMENT_LOG_CAP)
                        experimentLog.value.splice(0, experimentLog.value.length - EXPERIMENT_LOG_CAP)
                }
                catch {
                    // Ignore transient readback failures; the next sample retries.
                }
                finally {
                    isSamplingExperiment = false
                }
            })()
        }

        // ---- Environmental drift: opt-in, slow perturbation of MATTER×MATTER rules -------------
        // Off by default and zero-cost when off (one boolean check per frame). When on, every
        // `particleLife.driftInterval` simulated frames it adds centered Gaussian noise to the
        // matter×matter submatrix of `rulesMatrix` (source of truth for the GPU upload; the store
        // copy shares the same array) and re-uploads the interaction matrix. Urge/neuron rows are
        // never touched. Skipped while a resize/erase is mutating buffers.
        let driftFrameCounter = 0

        const applyEnvironmentDrift = () => {
            if (!isRunning || !particleLife.isDriftEnabled || particleLife.driftStrength <= 0)
                return
            if (isUpdatingParticles || isEraseCompleting)
                return
            driftFrameCounter++
            const interval = Math.max(1, Math.floor(particleLife.driftInterval))
            if (driftFrameCounter % interval !== 0)
                return
            driftInteractionMatrix(rulesMatrix, NUM_TYPES, particleLife.driftStrength)
            updateAllInteractionBuffers()
        }

        // ---- Neuron damage: opt-in random offline events for motor neurons -----------------
        // Off by default and zero-cost when off (one boolean check per frame). Damaged state
        // lives in a SEPARATE per-neuron health buffer (NOT a Particle field — the stride is a
        // hard 11-float contract) which the force pass reads at binding 5: neurons with
        // health < 0.5 keep firing locally but cannot actuate matter. The pure, unit-tested
        // `scheduleNeuronDamage` owns all state transitions; this block only uploads changes.
        let damagedNeurons = new Map<number, number>() // localIdx -> framesRemaining
        const neuronHealthData = new Float32Array(NEURON_HEALTH_CAPACITY).fill(1)
        let damageFrameCounter = 0 // monotonic sim-frame index for event timestamps (advances only while running)

        const damageEventLog = ref<{ frame: number, neuron: number }[]>([])
        const DAMAGE_EVENT_LOG_CAP = 1000

        const uploadNeuronHealth = () => {
            if (!neuronHealthBuffer || !device)
                return
            neuronHealthData.fill(1)
            for (const idx of damagedNeurons.keys())
                if (idx < NEURON_HEALTH_CAPACITY) neuronHealthData[idx] = 0
            device.queue.writeBuffer(neuronHealthBuffer, 0, neuronHealthData)
        }

        const applyNeuronDamage = () => {
            if (!isRunning)
                return
            damageFrameCounter++
            if (!particleLife.isDamageEnabled) {
                // Toggling off heals everyone still damaged.
                if (damagedNeurons.size > 0) {
                    damagedNeurons = new Map()
                    uploadNeuronHealth()
                }
                return
            }
            const { next, newlyDamaged, healed } = scheduleNeuronDamage(
                damagedNeurons,
                particleLife.neuronDamageProbability,
                particleLife.neuronDamageDuration,
                numNeurons,
            )
            if (newlyDamaged.length === 0 && healed.length === 0) {
                damagedNeurons = next // durations unchanged this frame; keep the new map
                return
            }
            damagedNeurons = next
            uploadNeuronHealth()
            for (const idx of newlyDamaged) {
                damageEventLog.value.push({ frame: damageFrameCounter, neuron: idx })
            }
            if (damageEventLog.value.length > DAMAGE_EVENT_LOG_CAP)
                damageEventLog.value.splice(0, damageEventLog.value.length - DAMAGE_EVENT_LOG_CAP)
        }

        // Project the selected urge onto the canvas and move its marker. Runs every frame (cheap:
        // pure math + one style write, no GPU work). Position is extrapolated with velocity so the
        // marker glides smoothly between throttled readbacks.
        const updateUrgeMarker = () => {
            const el = urgeMarkerEl.value
            if (!el)
                return
            const id = selectedUrgeId.value
            // Hide when nothing is selected, the layer is off, or the camera is GPU-tracked
            // (its centre lives on the GPU and we don't read it back every frame).
            if (id === -1 || !particleLife.isElectricalEnabled || isCameraTracking) {
                el.style.opacity = '0'
                return
            }
            const p = urgeWorldPos.get(id)
            if (!p) { el.style.opacity = '0'; return } // not yet read back (or count changed)

            let dt = (performance.now() - lastReadTimeMs) / 1000
            if (dt < 0)
                dt = 0
            else if (dt > 0.3)
                dt = 0.3 // don't extrapolate too far ahead of the last sample
            const wx = p.x + p.vx * dt
            const wy = p.y + p.vy * dt

            // World -> NDC, exactly matching render_normal.wgsl (note: scale.y is negated there).
            const clipX = (wx - cameraCenter.x) * cameraScaleX
            const clipY = (wy - cameraCenter.y) * (-cameraScaleY)
            // NDC -> device pixels -> CSS pixels (the canvas backing store is DPR-scaled).
            const dpr = DEVICE_PIXEL_RATIO || 1
            const px = ((clipX + 1) / 2 * CANVAS_WIDTH) / dpr
            const py = ((1 - clipY) / 2 * CANVAS_HEIGHT) / dpr
            el.style.opacity = '1'
            el.style.transform = `translate(${px.toFixed(1)}px, ${py.toFixed(1)}px)`
        }

        watch(urgeInspectorOpen, (open) => {
            if (open) {
                startUrgeReadback()
            }
            else {
                stopUrgeReadback()
                urgeStats.value = []
                prevUrgeValues.clear()
                cloneRegistry.clear()
                cloneSeq.clear()
                // Drop on-canvas tracking state so nothing lingers once the panel is closed.
                selectedUrgeId.value = -1
                urgeWorldPos = new Map()
            }
        })

        // ---- Brain Lifecycle: Death, Murder, Merge & Clone (unified pass) -------------------------
        // Single buffer readback per tick (500 ms). Precedence order within a pass:
        //   1. Death (starvation) — sustained low metric → dormant sentinel + neurons die
        //   2. Murder — instant collision event, power gap > margin → weaker dies
        //   3. Merge — sustained proximity → higher-power survives, loser dies
        //   4. Clone — existing logic (absorbed into same pass to share the readback)
        // A particle killed in an earlier phase is excluded from all later phases.
        //
        // Power definition: power = signal + 0.1 * |control|
        //   - signal is the smoothed objective metric (higher = better at its goal)
        //   - |control| adds a small tiebreak for urges that have learned strong actuation
        //   - Single scalar, easy to tune and display
        //
        // Merge absorption: survivor gets max(signalA, signalB) for signal and
        //   avg(controlA, controlB) for control. This preserves the best metric while
        //   blending the learned controls so the merge is meaningful.
        //
        // Resurrection on urge-count change: applyTypeLayout() re-labels by index and
        // would resurrect dead particles. This is accepted (it's a reset) — consistent with
        // clonedUrges being cleared when numUrges changes. Death state is NOT persisted
        // across a full relabel.

        const LIFECYCLE_CHECK_INTERVAL_MS = 500
        let lifecycleCheckTimer: number | null = null
        let isLifecycleInFlight = false // concurrency guard (replaces isCloningInFlight)

        // --- Death state ---
        // Per-urge sustained-below counter, keyed by display id (originals = k, clones = -(k+1)*10 - 1)
        let sustainedBelow = new Map<number, number>()

        // --- Clone state (preserved from original cloning system) ---
        const clonedUrges = new Set<number>()
        let sustainedAboveThreshold = new Map<number, number>()

        // --- Merge state ---
        // Per-pair sustained proximity counter. Key: min(idA,idB)*10000 + max(idA,idB) for unique pairs.
        // (Display ids can be negative; we use a string key instead to avoid collisions.)
        let sustainedProximity = new Map<string, number>()

        // Helper: display id for an urge entry (matches readUrgeStats scheme)
        const urgeDisplayId = (k: number, isClone: boolean): number => isClone ? -((k + 1) * 10 + 1) : k

        // Helper: compute power for a live urge (single scalar)
        const urgePower = (signal: number, control: number): number => signal + 0.1 * Math.abs(control)

        // Helper: kill an urge particle (set to dormant). Neurons and sense neurons are NOT
        // killed — they remain alive for other urges (or the killer) to acquire.
        // Mutates the particles Float32Array in place. Returns nothing.
        const killUrge = (
            particles: Float32Array,
            urgeBufIdx: number,
            dormantType: number,
        ) => {
            const u8 = urgeBufIdx * PARTICLE_STRIDE
            particles[u8 + 4] = dormantType // type → dormant sentinel (invisible, inert)
            particles[u8 + 5] = 0 // zero control
            particles[u8 + 6] = 0 // zero signal
            particles[u8 + 7] = -1 // clear secondary goal
            particles[u8 + 2] = 0 // zero velocity x
            particles[u8 + 3] = 0 // zero velocity y
        }

        const checkUrgeLifecycle = async () => {
            // Run if ANY lifecycle feature is enabled (or cloning, which is always available)
            const anyEnabled = particleLife.isDeathEnabled || particleLife.isMergeEnabled
                || particleLife.isMurderEnabled || particleLife.isCloningEnabled
            if (!anyEnabled || !particleLife.isElectricalEnabled)
                return
            if (numUrges <= 0)
                return
            if (isLifecycleInFlight || isUpdatingParticles || isEraseCompleting)
                return
            if (!particleBuffer || !device)
                return

            isLifecycleInFlight = true
            try {
                const arrayBuffer = await readBufferFromGPU(particleBuffer, NUM_PARTICLES * PARTICLE_BYTES)
                // Re-check guards after the await — a resize/erase may have started meanwhile.
                if (isUpdatingParticles || isEraseCompleting)
                    return

                const particles = new Float32Array(arrayBuffer)
                // Read genome + ownership buffers for heredity operations
                let genome: Float32Array | null = null
                let owners: Uint32Array | null = null
                if (genomeBuffer && neuronOwnersBuffer) {
                    const genomeBuf = await readBufferFromGPU(genomeBuffer, numUrges * GENOME_STRIDE * 4)
                    if (isUpdatingParticles || isEraseCompleting) return
                    genome = new Float32Array(genomeBuf)
                    const ownersBuf = await readBufferFromGPU(neuronOwnersBuffer, (numSenseNeurons + numNeurons) * 4)
                    if (isUpdatingParticles || isEraseCompleting) return
                    owners = new Uint32Array(ownersBuf)
                }
                // Read live per-need metrics so merge/death can act on real utility (not the
                // stale particle-buffer signal proxy).
                let metrics: Float32Array | null = null
                if (brainMetricsBuffer && numUrges > 0) {
                    const mBuf = await readBufferFromGPU(brainMetricsBuffer, numUrges * GENOME_K * 4)
                    if (isUpdatingParticles || isEraseCompleting)
                        return
                    metrics = new Float32Array(mBuf)
                }
                // Utility of brain k = mean over its K needs of how close the LIVE metric is to
                // its setpoint: 1 = every need exactly at target, 0 = everything off by a full
                // scale or more. This "how well does this brain satisfy its own goals" number now
                // drives merge (who survives + genome weighting) and death (starvation).
                const utilityOf = (k: number): number => {
                    if (!genome || !metrics || k < 0 || k >= numUrges)
                        return 0
                    const base = k * GENOME_STRIDE
                    let sum = 0
                    for (let i = 0; i < GENOME_K; i++) {
                        const nb = base + i * 4
                        const setpoint = genome[nb + 1]
                        const scale = Math.max(genome[nb + 2], 0.1)
                        const metric = metrics[k * GENOME_K + i]
                        sum += Math.min(1, Math.max(0, 1 - Math.abs(metric - setpoint) / scale))
                    }
                    return sum / GENOME_K
                }
                // Dormant sentinel must include the sense band, or clone-pool slots are misread.
                const dormantType = NUM_TYPES + numUrges + numNeurons + numSenseNeurons
                const motorBase = NUM_TYPES + numUrges
                const senseBase = NUM_TYPES + numUrges + numNeurons
                const neuronRadius = Math.max(particleLife.neuronRadius, 4)
                const urgeRadius = Math.max(particleLife.urgeRadius, 10)

                // --- Collect all particles by category (single pass over buffer) ---
                interface UrgeEntry { bufIdx: number, k: number, isClone: boolean, x: number, y: number, vx: number, vy: number, control: number, signal: number }
                interface NeuronEntry { idx: number, localM: number, x: number, y: number }
                interface SenseEntry { idx: number, localS: number, x: number, y: number }

                const urges: UrgeEntry[] = []
                const neurons: NeuronEntry[] = []
                const senses: SenseEntry[] = [] // live sense neurons (sensors) — die with their urge
                const dormantSlots: number[] = [] // buffer indices of dormant particles (for cloning)

                for (let i = 0; i < NUM_PARTICLES; i++) {
                    const idx8 = i * PARTICLE_STRIDE
                    const rawType = particles[idx8 + 4]
                    const ptype = Math.floor(rawType) // floor (not round!) to handle clone fractional tags
                    if (ptype === dormantType) {
                        dormantSlots.push(i)
                    }
                    else if (ptype >= NUM_TYPES && ptype < motorBase) {
                        const localK = ptype - NUM_TYPES
                        const isClone = rawType - ptype > 0.1 // fractional tag = clone
                        urges.push({ bufIdx: i, k: localK, isClone, x: particles[idx8], y: particles[idx8 + 1], vx: particles[idx8 + 2], vy: particles[idx8 + 3], control: particles[idx8 + 5], signal: particles[idx8 + 6] })
                    }
                    else if (ptype >= motorBase && ptype < senseBase) {
                        const localM = ptype - motorBase
                        neurons.push({ idx: i, localM, x: particles[idx8], y: particles[idx8 + 1] })
                    }
                    else if (ptype >= senseBase && ptype < dormantType) {
                        const localS = ptype - senseBase
                        senses.push({ idx: i, localS, x: particles[idx8], y: particles[idx8 + 1] })
                    }
                }

                // Track which urges are dead this pass (by buffer index) so later phases skip them.
                const deadBufIdx = new Set<number>()
                let bufferModified = false

                // ===================================================================
                // PHASE 1: DEATH (starvation) — sustained low metric → die
                // ===================================================================
                if (particleLife.isDeathEnabled) {
                    const deathThreshold = particleLife.deathMetricThreshold
                    const deathTicks = Math.max(1, particleLife.deathSustainedTicks)
                    const newSustainedBelow = new Map<number, number>()

                    for (const u of urges) {
                        if (deadBufIdx.has(u.bufIdx))
                            continue // already dead this pass
                        const id = urgeDisplayId(u.k, u.isClone)
                        // Starve on low UTILITY (can't satisfy its own goals), not the stale signal.
                        if (utilityOf(u.k) < deathThreshold) {
                            const prev = sustainedBelow.get(id) ?? 0
                            const count = prev + 1
                            newSustainedBelow.set(id, count)
                            if (count >= deathTicks) {
                                // THIS BRAIN DIES NOW
                                killUrge(particles, u.bufIdx, dormantType)
                                deadBufIdx.add(u.bufIdx)
                                bufferModified = true
                                // Free all neurons owned by this brain back to the pool
                                if (owners) {
                                    const FREE = 0xFFFFFFFF
                                    for (let ni = 0; ni < owners.length; ni++) {
                                        if (owners[ni] === u.k) owners[ni] = FREE
                                    }
                                }
                                // Clear all tracking for this id
                                sustainedBelow.delete(id)
                                sustainedAboveThreshold.delete(u.k)
                                // Drop proximity entries involving this id (exact part match, not substring)
                                const idStr = String(id)
                                for (const key of [...sustainedProximity.keys()]) {
                                    const parts = key.split('_')
                                    if (parts[0] === idStr || parts[1] === idStr)
                                        sustainedProximity.delete(key)
                                }
                            }
                        }
                        else {
                            // Above threshold: reset counter (don't add to newSustainedBelow)
                        }
                    }
                    sustainedBelow = newSustainedBelow
                }

                // ===================================================================
                // PHASE 2: MURDER — instant collision, power gap > margin → weaker dies
                // ===================================================================
                if (particleLife.isMurderEnabled) {
                    const murderR = Math.max(particleLife.murderRadius, 1)
                    const murderR2 = murderR * murderR
                    const powerMargin = particleLife.murderPowerMargin

                    for (let a = 0; a < urges.length; a++) {
                        if (deadBufIdx.has(urges[a].bufIdx))
                            continue // skip dead as killer
                        for (let b = a + 1; b < urges.length; b++) {
                            if (deadBufIdx.has(urges[b].bufIdx))
                                continue // skip dead as victim
                            const dx = urges[a].x - urges[b].x
                            const dy = urges[a].y - urges[b].y
                            if (dx * dx + dy * dy >= murderR2)
                                continue

                            const pA = urgePower(urges[a].signal, urges[a].control)
                            const pB = urgePower(urges[b].signal, urges[b].control)
                            const gap = Math.abs(pA - pB)
                            if (gap <= powerMargin)
                                continue // dead-band: neither dies

                            // Weaker one dies immediately
                            const victim = pA < pB ? urges[a] : urges[b]
                            killUrge(particles, victim.bufIdx, dormantType)
                            deadBufIdx.add(victim.bufIdx)
                            bufferModified = true
                            // Free the victim's neurons
                            if (owners) {
                                const FREE = 0xFFFFFFFF
                                for (let ni = 0; ni < owners.length; ni++) {
                                    if (owners[ni] === victim.k) owners[ni] = FREE
                                }
                            }

                            // Clear tracking for the victim
                            const vid = urgeDisplayId(victim.k, victim.isClone)
                            sustainedBelow.delete(vid)
                            sustainedAboveThreshold.delete(victim.k)
                            const vidStr = String(vid)
                            for (const key of [...sustainedProximity.keys()]) {
                                const parts = key.split('_')
                                if (parts[0] === vidStr || parts[1] === vidStr)
                                    sustainedProximity.delete(key)
                            }
                        }
                    }
                }

                // ===================================================================
                // PHASE 3: MERGE — sustained proximity → higher-power survives
                // ===================================================================
                if (particleLife.isMergeEnabled) {
                    const mergeR = Math.max(particleLife.mergeRadius, 1)
                    const mergeR2 = mergeR * mergeR
                    const mergeTicks = Math.max(1, particleLife.mergeSustainedTicks)

                    // Build set of live urge ids for proximity tracking
                    const newProximity = new Map<string, number>()

                    for (let a = 0; a < urges.length; a++) {
                        if (deadBufIdx.has(urges[a].bufIdx))
                            continue
                        for (let b = a + 1; b < urges.length; b++) {
                            if (deadBufIdx.has(urges[b].bufIdx))
                                continue
                            const dx = urges[a].x - urges[b].x
                            const dy = urges[a].y - urges[b].y
                            if (dx * dx + dy * dy >= mergeR2)
                                continue

                            // Within merge radius: track sustained proximity for this pair
                            const idA = urgeDisplayId(urges[a].k, urges[a].isClone)
                            const idB = urgeDisplayId(urges[b].k, urges[b].isClone)
                            // Sorted string key ensures unique unordered pair
                            const key = idA < idB ? `${idA}_${idB}` : `${idB}_${idA}`
                            const prev = sustainedProximity.get(key) ?? 0
                            const count = prev + 1

                            if (count >= mergeTicks) {
                                // MERGE: higher UTILITY survives — the brain better at satisfying its
                                // own goals wins, so a merge represents the parents' utilities.
                                const uA = utilityOf(urges[a].k)
                                const uB = utilityOf(urges[b].k)
                                let survivor: UrgeEntry, loser: UrgeEntry
                                if (uA > uB) { survivor = urges[a]; loser = urges[b] }
                                else if (uB > uA) { survivor = urges[b]; loser = urges[a] }
                                else { survivor = idA < idB ? urges[a] : urges[b]; loser = survivor === urges[a] ? urges[b] : urges[a] }

                                // Survivor absorbs: max signal, zero control (no per-frame control anymore)
                                const s8 = survivor.bufIdx * PARTICLE_STRIDE
                                particles[s8 + 6] = Math.max(survivor.signal, loser.signal) // signal = best metric
                                particles[s8 + 5] = 0 // control: no longer used for brains
                                particles[s8 + 7] = -1 // goalB: cleared (genome handles multi-need)
                                // Zero non-authoritative drive fields
                                particles[s8 + 8] = 0
                                particles[s8 + 9] = 0
                                particles[s8 + 10] = 0

                                // Genome heredity weighted by UTILITY: the fitter brain's goals and
                                // weights dominate the merged genome (w in [0.5, 1] since it is the
                                // higher-utility survivor), so the merge encodes both parents' fitness.
                                if (genome) {
                                    const sBase = survivor.k * GENOME_STRIDE
                                    const lBase = loser.k * GENOME_STRIDE
                                    const uS = utilityOf(survivor.k)
                                    const uL = utilityOf(loser.k)
                                    const totalU = uS + uL
                                    const w = totalU > 1e-6 ? uS / totalU : 0.5
                                    for (let gi = 0; gi < GENOME_STRIDE; gi++) {
                                        genome[sBase + gi] = w * genome[sBase + gi] + (1 - w) * genome[lBase + gi]
                                    }
                                }
                                // Ownership union: re-point loser's neurons to survivor
                                if (owners) {
                                    for (let ni = 0; ni < owners.length; ni++) {
                                        if (owners[ni] === loser.k) owners[ni] = survivor.k
                                    }
                                }

                                // Loser dies
                                killUrge(particles, loser.bufIdx, dormantType)
                                deadBufIdx.add(loser.bufIdx)
                                bufferModified = true

                                // Clear all tracking for the loser id
                                const lid = urgeDisplayId(loser.k, loser.isClone)
                                sustainedBelow.delete(lid)
                                sustainedAboveThreshold.delete(loser.k)
                                // Drop ALL proximity entries involving the loser (exact part match)
                                const lidStr = String(lid)
                                for (const k of [...sustainedProximity.keys()]) {
                                    const parts = k.split('_')
                                    if (parts[0] === lidStr || parts[1] === lidStr)
                                        sustainedProximity.delete(k)
                                }
                            }
                            else {
                                newProximity.set(key, count)
                            }
                        }
                    }
                    sustainedProximity = newProximity
                }

                // ===================================================================
                // PHASE 4: CLONE — existing logic (absorbed into same pass)
                // ===================================================================
                if (particleLife.isCloningEnabled && numClonePool > 0 && dormantSlots.length > 0) {
                    const threshold = particleLife.cloneMetricThreshold
                    const impulse = particleLife.cloneImpulse
                    const birthTicks = Math.max(1, particleLife.birthSustainedTicks) // consecutive ticks above threshold before a birth
                    const neuronR2 = neuronRadius * neuronRadius

                    const newSustainedAbove = new Map<number, number>()
                    const readyToClone: { k: number, bufIdx: number, x: number, y: number, signal: number, neuronsInRange: NeuronEntry[], sensesInRange: SenseEntry[] }[] = []

                    const senseR2 = particleLife.senseRadius * particleLife.senseRadius
                    for (const u of urges) {
                        if (deadBufIdx.has(u.bufIdx))
                            continue // skip dead urges
                        // NOTE: there is NO one-time restriction. An urge keeps giving birth for as long
                        // as its metric stays above the threshold. Each birth halves its metric, so only
                        // genuinely high-metric ("highly successful") urges recover past the threshold
                        // fast enough to replicate again — marginal ones stall or starve.

                        // Collect motor neurons within neuronRadius (cloned along with the urge)
                        const inRange: NeuronEntry[] = []
                        for (const n of neurons) {
                            const dx = n.x - u.x
                            const dy = n.y - u.y
                            if (dx * dx + dy * dy <= neuronR2)
                                inRange.push(n)
                        }
                        // Collect sense neurons within senseRadius (also cloned)
                        const sensesInRange: SenseEntry[] = []
                        for (const s of senses) {
                            const dx = s.x - u.x
                            const dy = s.y - u.y
                            if (dx * dx + dy * dy <= senseR2)
                                sensesInRange.push(s)
                        }

                        if (u.signal > threshold) {
                            const prev = sustainedAboveThreshold.get(u.k) ?? 0
                            const count = prev + 1
                            newSustainedAbove.set(u.k, count)
                            if (count >= birthTicks) {
                                readyToClone.push({ k: u.k, bufIdx: u.bufIdx, x: u.x, y: u.y, signal: u.signal, neuronsInRange: inRange, sensesInRange })
                            }
                        }
                    }
                    sustainedAboveThreshold = newSustainedAbove

                    // Activate clones: each ready urge consumes 1 slot for itself + N slots for its neurons.
                    // On birth the PARENT's metric is split in half — half stays with the parent and half
                    // goes to the clone (metric mass is conserved). The parent's sustained counter is reset
                    // so it must re-accumulate above threshold before reproducing again; a high-metric urge
                    // climbs back fast and keeps replicating, a marginal one does not.
                    let slotPtr = 0
                    for (const urge of readyToClone) {
                        const totalNeeded = 1 + urge.neuronsInRange.length + urge.sensesInRange.length
                        if (slotPtr + totalNeeded > dormantSlots.length)
                            break // not enough pool remaining

                        const halfMetric = urge.signal * 0.5 // the split: parent and clone each keep half

                        // --- Clone the brain itself ---
                        const slotIdx = dormantSlots[slotPtr++]
                        const s8 = slotIdx * PARTICLE_STRIDE
                        particles[s8 + 4] = NUM_TYPES + urge.k + 0.5 // fractional tag marks clone
                        particles[s8 + 5] = 0
                        particles[s8 + 6] = halfMetric // child inherits the other half of the parent's metric
                        particles[s8 + 7] = -1 // goalB: unused
                        // Drive params are non-authoritative (genome is source of truth)
                        particles[s8 + 8] = 0
                        particles[s8 + 9] = 0
                        particles[s8 + 10] = 0

                        // Genome heredity: jitter the parent's genome (shared slot for same type k)
                        if (genome) {
                            const gBase = urge.k * GENOME_STRIDE
                            // Needs: Gaussian jitter on setpoint/scale/gain
                            for (let k2 = 0; k2 < GENOME_K; k2++) {
                                const nb = gBase + k2 * 4
                                genome[nb + 1] = Math.min(3.0, Math.max(0.1, genome[nb + 1] + (Math.random() - 0.5) * 0.2)) // setpoint ±0.1
                                genome[nb + 2] = Math.min(2.0, Math.max(0.05, genome[nb + 2] + (Math.random() - 0.5) * 0.12)) // scale ±0.06
                                genome[nb + 3] = Math.min(3.0, Math.max(0.0, genome[nb + 3] + (Math.random() - 0.5) * 0.12)) // gain ±0.06
                            }
                            // Weights: light jitter (σ=0.05), clamped ±2
                            for (let w = GENOME_NEEDS_SIZE; w < GENOME_STRIDE; w++) {
                                genome[gBase + w] = Math.min(2.0, Math.max(-2.0,
                                    genome[gBase + w] + (Math.random() - 0.5) * 0.1))
                            }
                        }

                        const angle = Math.random() * Math.PI * 2
                        const offsetDist = urgeRadius * 0.3 + Math.random() * urgeRadius * 0.3
                        particles[s8] = urge.x + Math.cos(angle) * offsetDist
                        particles[s8 + 1] = urge.y + Math.sin(angle) * offsetDist

                        const shootAngle = angle + (Math.random() - 0.5) * 1.0
                        particles[s8 + 2] = Math.cos(shootAngle) * impulse
                        particles[s8 + 3] = Math.sin(shootAngle) * impulse

                        // --- Split the parent's metric in half & reset its birth cooldown ---
                        const p8 = urge.bufIdx * PARTICLE_STRIDE
                        particles[p8 + 6] = halfMetric // parent keeps the other half → must re-accumulate to reproduce again
                        sustainedAboveThreshold.delete(urge.k) // reset so it re-sustains above threshold before the next birth

                        clonedUrges.add(urge.k)

                        // --- Clone ALL motor neurons in range of this urge ---
                        for (const srcNeuron of urge.neuronsInRange) {
                            if (slotPtr >= dormantSlots.length)
                                break
                            const nSlotIdx = dormantSlots[slotPtr++]
                            const n8 = nSlotIdx * PARTICLE_STRIDE
                            particles[n8 + 4] = NUM_TYPES + numUrges + srcNeuron.localM
                            particles[n8 + 5] = 0
                            particles[n8 + 6] = 0
                            const relX = srcNeuron.x - urge.x
                            const relY = srcNeuron.y - urge.y
                            particles[n8] = particles[s8] + relX * 0.5
                            particles[n8 + 1] = particles[s8 + 1] + relY * 0.5
                            particles[n8 + 2] = particles[s8 + 2] * 0.7
                            particles[n8 + 3] = particles[s8 + 3] * 0.7
                        }
                        // --- Clone ALL sense neurons in range of this urge ---
                        for (const srcSense of urge.sensesInRange) {
                            if (slotPtr >= dormantSlots.length)
                                break
                            const ssSlotIdx = dormantSlots[slotPtr++]
                            const ss8 = ssSlotIdx * PARTICLE_STRIDE
                            particles[ss8 + 4] = NUM_TYPES + numUrges + numNeurons + srcSense.localS
                            particles[ss8 + 5] = 0
                            particles[ss8 + 6] = 0
                            const relX = srcSense.x - urge.x
                            const relY = srcSense.y - urge.y
                            particles[ss8] = particles[s8] + relX * 0.5
                            particles[ss8 + 1] = particles[s8 + 1] + relY * 0.5
                            particles[ss8 + 2] = particles[s8 + 2] * 0.7
                            particles[ss8 + 3] = particles[s8 + 3] * 0.7
                        }
                        bufferModified = true
                    }
                }

                // --- Upload modified buffers back to GPU (only if something changed) ---
                if (bufferModified) {
                    device.queue.writeBuffer(particleBuffer, 0, particles)
                    // Write back genome + ownership if they were read and modified
                    if (genome && genomeBuffer)
                        device.queue.writeBuffer(genomeBuffer, 0, genome)
                    if (owners && neuronOwnersBuffer)
                        device.queue.writeBuffer(neuronOwnersBuffer, 0, owners)
                }
            }
            catch {
                // Ignore transient readback failures
            }
            finally {
                isLifecycleInFlight = false
            }
        }

        const startLifecycleCheck = () => {
            stopLifecycleCheck()
            // Reset state when (re-)enabling
            clonedUrges.clear()
            sustainedAboveThreshold.clear()
            sustainedBelow.clear()
            sustainedProximity.clear()
            void checkUrgeLifecycle()
            lifecycleCheckTimer = window.setInterval(() => { void checkUrgeLifecycle() }, LIFECYCLE_CHECK_INTERVAL_MS)
        }
        const stopLifecycleCheck = () => {
            if (lifecycleCheckTimer !== null) {
                window.clearInterval(lifecycleCheckTimer)
                lifecycleCheckTimer = null
            }
        }

        // Watchers: start/stop the lifecycle pass when any feature is toggled
        const anyLifecycleEnabled = () => particleLife.isDeathEnabled || particleLife.isMergeEnabled
            || particleLife.isMurderEnabled || particleLife.isCloningEnabled
        watch([
            () => particleLife.isCloningEnabled,
            () => particleLife.isDeathEnabled,
            () => particleLife.isMergeEnabled,
            () => particleLife.isMurderEnabled,
        ], () => {
            if (anyLifecycleEnabled())
                startLifecycleCheck()
            else stopLifecycleCheck()
        })
        // Reset all lifecycle state when urge count changes (indices are no longer valid)
        watch(() => particleLife.numBrains, () => {
            clonedUrges.clear()
            sustainedAboveThreshold.clear()
            sustainedBelow.clear()
            sustainedProximity.clear()
        })

        // Handle numClonePool changes: the pool ADDS dormant slots on top of the base matter
        // population, so resize the buffer accordingly (never steal slots from real matter).
        const desiredTotalParticles = () => baseMatterCount + numUrges + numNeurons + numSenseNeurons + numClonePool
        watch(() => particleLife.numClonePool, (newPool) => {
            numClonePool = newPool
            const target = desiredTotalParticles()
            if (target === NUM_PARTICLES)
                return // nothing to do
            NEW_NUM_PARTICLES = target
            isUpdateNumParticlesPending = true
        })

        watch(() => particleLife.showLiveDeltaTime, (value: boolean) => showLiveDeltaTime = value)
        watch(() => particleLife.manualDeltaTimeEnabled, (value: boolean) => {
            manualDeltaTimeEnabled = value
            updateDeltaTimeBuffer(value ? manualDeltaTime : smoothedDeltaTime)
        })
        watch(() => particleLife.manualDeltaTime, (value: number) => {
            manualDeltaTime = value
            if (manualDeltaTimeEnabled)
                updateDeltaTimeBuffer(value)
        })

        watch(() => particleLife.minRadiusRange, (value: number[]) => {
            if (value[0] > value[1])
                particleLife.minRadiusRange[0] = value[1]
            if (value[1] > particleLife.maxRadiusRange[0])
                particleLife.maxRadiusRange[0] = value[1]
        }, { deep: true })
        watch(() => particleLife.maxRadiusRange, (value: number[]) => {
            if (value[0] > value[1])
                particleLife.maxRadiusRange[1] = value[0]
            if (value[0] < particleLife.minRadiusRange[1])
                particleLife.minRadiusRange[1] = value[0]
        }, { deep: true })

        watch(() => particleLife.isDebugBinsActive, (value: boolean) => {
            isDebugBinsActive = value
            if (!isRunning && isDebugBinsActive)
                step() // Force step for debug bins update
        })
        watch(() => particleLife.isDebugHeatmapActive, (value: boolean) => {
            isDebugHeatmapActive = value
            updateDebugOptionsBuffer()
            particleLife.isDebugBinsActive = true
        })
        watch(() => particleLife.debugMaxParticleCount, (value: number) => { debugMaxParticleCount = value; updateDebugOptionsBuffer() })
        watch(() => particleLife.cellSubdivisions, (value: number) => {
            CELL_SUBDIVISIONS = value
            recomputeCellSize()
        })

        let isUpdatingWallState = false
        watch([
            () => particleLife.isWallRepel,
            () => particleLife.isWallWrap,
            () => particleLife.isMirrorWrap,
            () => particleLife.isInfiniteMirrorWrap,
        ], ([newRepel, newWrap, newMirror, newInfinite], [oldRepel, oldWrap, oldMirror, oldInfinite]) => {
            if (isUpdatingWallState)
                return

            let changedProp = ''
            if (newRepel !== oldRepel)
                changedProp = 'isWallRepel'
            else if (newWrap !== oldWrap)
                changedProp = 'isWallWrap'
            else if (newMirror !== oldMirror)
                changedProp = 'isMirrorWrap'
            else if (newInfinite !== oldInfinite)
                changedProp = 'isInfiniteMirrorWrap'

            if (!changedProp)
                return

            isUpdatingWallState = true

            if (changedProp === 'isWallRepel' && newRepel) {
                particleLife.isWallWrap = false
                particleLife.isMirrorWrap = false
                particleLife.isInfiniteMirrorWrap = false
            }
            else if (changedProp === 'isWallWrap') {
                if (newWrap) {
                    particleLife.isWallRepel = false
                    if (!newMirror && !newInfinite)
                        particleLife.isMirrorWrap = true
                }
                else {
                    particleLife.isMirrorWrap = false
                    particleLife.isInfiniteMirrorWrap = false
                }
            }
            else if (changedProp === 'isMirrorWrap' && newMirror) {
                particleLife.isWallWrap = true
                particleLife.isWallRepel = false
                particleLife.isInfiniteMirrorWrap = false
            }
            else if (changedProp === 'isInfiniteMirrorWrap' && newInfinite) {
                particleLife.isWallWrap = true
                particleLife.isWallRepel = false
                particleLife.isMirrorWrap = false
            }

            isWallRepel = particleLife.isWallRepel
            isWallWrap = particleLife.isWallWrap
            isMirrorWrap = particleLife.isMirrorWrap
            isInfiniteMirrorWrap = particleLife.isInfiniteMirrorWrap

            setSimSize()
            if (changedProp === 'isWallWrap' || changedProp === 'isWallRepel' || (changedProp === 'isMirrorWrap' && newMirror && !oldWrap) || (changedProp === 'isInfiniteMirrorWrap' && newInfinite && !oldWrap)) {
                updateSimOptionsBuffer()
                // Regenerate positions to match the new sim bounds (snapped to cell grid when wrapping).
                // Without this, particles outside the new bounds cause a one-frame stride-mismatch artifact
                // because the spatial hash clamps them all into edge cells simultaneously.
                void updateParticlePositions()
                if (!isRunning && isDebugBinsActive)
                    step() // Force step for debug bins update
            }

            nextTick(() => {
                isUpdatingWallState = false
            })
        })
        // -------------------------------------------------------------------------------------------------------------
        const destroyBuffers = async (keepTexture: boolean = false) => {
            currentPositionBuffer?.destroy(); currentPositionBuffer = undefined
            nextPositionBuffer?.destroy(); nextPositionBuffer = undefined
            velocityBuffer?.destroy(); velocityBuffer = undefined
            typeBuffer?.destroy(); typeBuffer = undefined
            typeBufferPacked?.destroy(); typeBufferPacked = undefined
            colorBuffer?.destroy(); colorBuffer = undefined
            deltaTimeBuffer?.destroy(); deltaTimeBuffer = undefined
            cameraBuffer?.destroy(); cameraBuffer = undefined
            interactionMatrixBuffer?.destroy(); interactionMatrixBuffer = undefined
            simOptionsBuffer?.destroy(); simOptionsBuffer = undefined
            glowOptionsBuffer?.destroy(); glowOptionsBuffer = undefined
            infiniteRenderOptionsBuffer?.destroy(); infiniteRenderOptionsBuffer = undefined
            debugOptionsBuffer?.destroy(); debugOptionsBuffer = undefined
            brushOptionsBuffer?.destroy(); brushOptionsBuffer = undefined
            brushesBuffer?.destroy(); brushesBuffer = undefined
            particleHashesBuffer?.destroy(); particleHashesBuffer = undefined
            cellHeadsBuffer?.destroy(); cellHeadsBuffer = undefined
            particleNextIndicesBuffer?.destroy(); particleNextIndicesBuffer = undefined
            particleBuffer?.destroy(); particleBuffer = undefined
            particleTempBuffer?.destroy(); particleTempBuffer = undefined
            genomeBuffer?.destroy(); genomeBuffer = undefined
            neuronOwnersBuffer?.destroy(); neuronOwnersBuffer = undefined
            neuronModsBuffer?.destroy(); neuronModsBuffer = undefined
            neuronHealthBuffer?.destroy(); neuronHealthBuffer = undefined
            captureReleaseOptsBuffer?.destroy(); captureReleaseOptsBuffer = undefined
            brainOptsBuffer?.destroy(); brainOptsBuffer = undefined
            brainMutateOptsBuffer?.destroy(); brainMutateOptsBuffer = undefined
            binOffsetBuffer?.destroy(); binOffsetBuffer = undefined
            binOffsetTempBuffer?.destroy(); binOffsetTempBuffer = undefined
            binPrefixSumStepSizeBuffer?.destroy(); binPrefixSumStepSizeBuffer = undefined

            particleKeepFlagsBuffer?.destroy(); particleKeepFlagsBuffer = undefined
            newParticleCountBuffer?.destroy(); newParticleCountBuffer = undefined
            newParticleCountReadBuffer?.destroy(); newParticleCountReadBuffer = undefined
            particleCompactBuffer?.destroy(); particleCompactBuffer = undefined

            trackerStateBuffer?.destroy(); trackerStateBuffer = undefined
            trackerLevelsBuffer?.destroy(); trackerLevelsBuffer = undefined
            trackerCameraOptionsBuffer?.destroy(); trackerCameraOptionsBuffer = undefined

            if (!keepTexture) {
                offscreenTexture?.destroy(); offscreenTexture = undefined
                offscreenTextureView = undefined as any
                offscreenSampler = undefined as any
                hdrTexture?.destroy(); hdrTexture = undefined
                hdrTextureView = undefined as any
            }

            await nextTick() // Ensure GPU resources are cleaned up before creating new ones
        }
        const destroyPipelinesAndBindGroups = () => {
            particleErasePipeline = undefined as any
            particleCompactPipeline = undefined as any
            particleCompactBindGroup = undefined as any
            particleCompactBindGroupLayout = undefined as any
            particleEraseBindGroup = undefined as any
            particleEraseBindGroupLayout = undefined as any

            renderPipeline = undefined as any
            renderOffscreenPipeline = undefined as any
            composeInfinitePipeline = undefined as any
            renderMirrorPipeline = undefined as any
            renderGlowPipeline = undefined as any
            renderCirclePipeline = undefined as any
            renderMirrorGlowPipeline = undefined as any
            renderMirrorCirclePipeline = undefined as any
            composeHdrPipeline = undefined as any

            renderPipelineAdditive = undefined as any
            renderMirrorPipelineAdditive = undefined as any
            renderInfinitePipelineAdditive = undefined as any
            renderCirclePipelineAdditive = undefined as any
            renderMirrorCirclePipelineAdditive = undefined as any
            renderInfiniteCirclePipelineAdditive = undefined as any

            binClearSizePipeline = undefined as any
            binFillSizePipeline = undefined as any
            binPrefixSumPipeline = undefined as any
            particleSortClearSizePipeline = undefined as any
            particleSortPipeline = undefined as any
            bruteForceComputePipeline = undefined as any
            particleComputeForcesPipeline = undefined as any
            particleAdvancePipeline = undefined as any

            particleBufferReadOnlyBindGroup = undefined as any
            binFillSizeBindGroup = undefined as any
            if (binPrefixSumBindGroup) {
                for (let i = 0; i < binPrefixSumBindGroup.length; i++) {
                    binPrefixSumBindGroup[i] = undefined as any
                }
            }
            binPrefixSumBindGroup = []
            particleSortBindGroup = undefined as any
            bruteForceBindGroup = undefined as any
            particleComputeForcesBindGroup = undefined as any

            particleBufferBindGroup = undefined as any
            simOptionsBindGroup = undefined as any
            deltaTimeBindGroup = undefined as any
            cameraBindGroup = undefined as any
            offscreenTextureBindGroup = undefined as any
            composeHdrBindGroup = undefined as any
            glowOptionsBindGroup = undefined as any
            brushOptionsBindGroup = undefined as any

            trackerAccumulatePipeline = undefined as any
            trackerFinalizePipeline = undefined as any
            trackerCameraUpdatePipeline = undefined as any
            renderTrackerPipeline = undefined as any
            trackerComputeBindGroup = undefined as any
            trackerCameraUpdateBindGroup = undefined as any
            trackerRenderBindGroup = undefined as any
        }
        const cancelAnimationLoop = () => {
            if (animationFrameId) {
                cancelAnimationFrame(animationFrameId)
                animationFrameId = null
            }
        }
        // -------------------------------------------------------------------------------------------------------------
        watch(() => particleLife.isLockedPointer, (value) => {
            const sidebarLeftElement = document.getElementById('sidebarLeft')
            if (sidebarLeftElement) {
                if (value) {
                    sidebarLeftElement.classList.add('force-hover-effect')
                }
                else {
                    sidebarLeftElement.classList.remove('force-hover-effect')
                }
            }
        })
        onUnmounted(() => {
            stopUrgeReadback()
            cancelAnimationLoop()
            destroyPipelinesAndBindGroups()
            destroyBuffers()
            releaseGpuDevice()
            // particleLife.$reset()
        })

        const releaseGpuDevice = () => {
            if (!device && !ctx)
                return
            cancelAnimationLoop()
            // if (device) device.onuncapturederror = null

            try { ctx?.unconfigure?.() }
            catch {}
            try { device?.destroy?.() }
            catch {}
            device = undefined as any
            ctx = undefined as any
        }

        const switchTo3D = () => {
            emit('switch-renderer', 'gpu3d')
        }

        return {
            particleLife,
            canvasRef,
            fps,
            executionTime,
            displayedDeltaTime,
            showLiveDeltaTime,
            colorRgbStrings,
            urgeInspectorOpen,
            urgeStats,
            isExperimentTelemetry,
            experimentLog,
            clearExperimentLog,
            damageEventLog,
            electricalParams,
            selectedUrgeId,
            urgeMarkerEl,
            urgeMarkerStatEl,
            markerColor,
            markerObjective,
            markerLabel,
            objectiveLabelFor,
            handleZoom,
            toggleFullscreen,
            isFullscreen,
            smoothCenterView,
            regenerateLife,
            step,
            randomizeRadius,
            randomizeRulesAndRadius,
            updateSimWidth,
            updateSimHeight,
            updateNumParticles,
            setNewNumParticles,
            setNewNumTypes,
            updateRulesMatrixValue,
            updateMinMatrixValue,
            updateMaxMatrixValue,
            newRandomRulesMatrix,
            updateRulesMatrix,
            updateParticlePositions,
            updateColors,
            loadPreset,
            updateSingleColor,
            startTrackerSelection,
            cancelTrackerSelection,
            stopTracker,
            onTrackerZoneSelected,
            rulesOptions,
            paletteOptions,
            positionOptions,
            switchTo3D,
        }
    },
})
</script>

<style scoped>
canvas {
    background: black;
}

.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.2s ease, transform 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
    transform: translateX(-50%) translateY(8px);
}

.fade-enter-to,
.fade-leave-from {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
}

.dt-fade-enter-active,
.dt-fade-leave-active {
    transition: opacity 0.2s ease;
}
.dt-fade-enter-from,
.dt-fade-leave-to {
    opacity: 0;
}
</style>
