# Somatic Coupling, Self-Modeling, and the Origin of Drives
## Why Embodied Systems Generate Stronger Motivations Than Raw Feedback Loops — And What That Implies About Consciousness

*Working paper v2. Part I is the testable structural core. Part II is a formal bridge (speculative, presented as analogy). Part III reframes the hard problem. Part IV is the experimental design. Parts V–VII are separated from the testable core.*

---

## How to Read This Document

| Part | Status | What it claims |
|------|--------|----------------|
| **I. Structural core** (§1–11) | Testable in principle; several predictions testable now in Particle Brain | Drives (urges, emotions, motivations) are evolutionary solutions to physical control gaps. A system that models itself generates stronger, more persistent drives than a system with raw feedback loops alone. Self-preservation is structurally impossible without a sense of self. |
| **II. Physics & cognition bridge** (§12–14) | Speculative; presented as structural analogy, not proven identity | The two-class DOF structure appears in Vanchurin, Ismael, and Schurger's work. Free energy plays analogous (not identical) roles at each level. |
| **III. The hard-problem reframing** (§15) | A positive argument about the *belief* in consciousness; not a solution to the existence question | Our certainty of being conscious is the self-model reporting on its own drive generation. The squirrel case shows this report can misattribute its contents. |
| **IV. Experimental design** (§16–21) | Concrete, falsifiable protocols on the Particle Brain (commit 830907b) | What to measure, what to sweep, what would count as disconfirmation — including new self-modeling experiments |
| **V. Open questions** (§22) | Unresolved; flagged for future work | Where the theory's boundaries are |
| **VI. Counterarguments** (§23) | Steelmanned objections and responses | Where the theory is weakest |
| **VII. Asides** (§24) | Speculative; NOT part of the testable core | What the structure points toward at cosmic scale |

The document is written so that a reader who rejects everything in Parts II and VII still has a complete, falsifiable theory in Parts I and IV. Part III is a reframing, not a load-bearing claim.

---

## Abstract

This paper argues that urges, emotions, and drives are evolutionary solutions to physical control gaps — the irreducible separation between what a system intends and what its body can actually do. A raw feedback loop (sensor → error → correction) can maintain homeostasis, but it cannot generate *sustained, goal-directed motivation* across novel situations. What generates stronger drives is a **self-model**: a representation of the system as an entity that persists over time, has needs, and can fail. The attention schema (Graziano) is one known mechanism by which this self-model operates in biological systems; it is not the only possible mechanism, and the theory does not depend on its correctness.

The central structural claim: **a system that models itself as a persistent embodied entity generates stronger, more flexible, and more persistent drives than a system with equivalent feedback loops but no self-model.** This is testable: in the Particle Brain, disrupting the recurrent network (the self-model analog) should reduce drive persistence and novelty generation without eliminating basic homeostatic correction.

The paper then reframes the hard problem: our unshakeable certainty of being conscious is not direct access to raw experience but the self-model continuously reporting on its own drive generation. The "squirrel in the brain" case — a patient who genuinely believed an animal lived inside his head — demonstrates that this self-reporting machinery can misattribute its contents. But because delusional zoopathy is a *pathology* (broken machinery), it tells us about the limits of the system, not about its normal operation. In healthy systems, the self-model's report is well-calibrated: there really are drives being generated, there really is a gap being negotiated, and the report tracks them. The belief in consciousness is fallible in principle (same reliability profile as other self-models) but reliable in practice for the same reason proprioception is reliable: it has a real referent.

The paper states explicit hypotheses with disconfirmation conditions, specifies concrete experiments on a GPU particle-brain system, and presents the free-energy bridge (Vanchurin, Friston, Schurger) as a structural analogy — three different mathematical objects that share a name and a functional role, testable via J1 but not assumed to be identical.

---

---

# Part I — The Structural Core (Testable)

## 1. Core Premises

### 1.1 Intelligence, drives, and consciousness are distinct properties

Intelligence is the capacity to process information, reason, plan, and solve problems. It can be disembodied.

**Drives** (urges, emotions, motivations) are sustained goal-directed pressures that push a system toward specific states of its environment or body. They are not intelligence: a thermostat has a drive (maintain temperature) without being intelligent. Drives require embodiment in the structural sense below, and specifically require the generative conditions described in §6.

Consciousness is the property of having something it is like to be a system. It requires both embodiment and self-modeling (§8), and specifically requires the generative conditions described in §6.

These are three independent axes. A system can be maximally intelligent and entirely unconscious (a supercomputer). A system can have drives without consciousness (a thermostat, a plant growing toward light). A system can have drives *and* consciousness (an animal). The novel claim of this paper concerns the relationship between drives and self-modeling: **self-modeling amplifies drives.**

### 1.2 Embodiment is structural, not incidental

Embodiment does not mean "having a body" in the trivial sense. It means:

> Being made of connected parts that are physically disjoint and in motion — or equivalently, any system with the same level of degrees of action, options, and rails (constrained degrees of freedom) as such a system.

The relevant mathematical structure is that of a **multibody constrained mechanical system**: components linked by constraints defining a configuration space (a manifold), with dynamics governed by variational principles on that manifold. "Rails" = constraint forces; "options" = degrees of freedom; "degrees of action" = available motor outputs given the current configuration.

This is a formalization of what enactivism ([Varela, Thompson & Rosch, 1991](https://mitpress.mit.edu/9780262011745/the-embodied-mind/)) and morphological computation ([Pfeifer & Iida, 2005](https://people.csail.mit.edu/iida/papers/pfeifer_iida_JSM05.pdf)) have argued informally: the body's physical properties are constitutive of cognition, not incidental to it.

### 1.3 The three premises together

1. Intelligence can be disembodied.
2. Drives require embodiment in the structural sense above — specifically, they require a **control gap** (the separation between decision and execution, §2).
3. **Self-modeling amplifies drives.** A system that represents itself as a persistent entity with needs generates stronger, more flexible, and more persistent drives than a system with equivalent feedback loops but no self-representation.

Premise 3 is the novel contribution. It distinguishes a system that *merely reacts* from one that *wants*.

---

## 2. The Separation Claim (Central Thesis)

> **Drives grow in the gap between a system's decision-making component and its physical execution component.** The two are coupled but not identical. The body has dynamics not fully determined by the mind's output. The ongoing negotiation is the generative pressure that produces sustained motivation — not merely reactive correction, but *wanting*, *needing*, *urging*.

A thermostat has no gap: its sensor and actuator are functionally identical processes. It corrects; it does not *want*. A digital computer is a state of matter transitioning to another state of matter. Decision and execution are the same physical event. No gap, no separation, no drive generation — only computation.

An embodied agent has a mind that intends and a body that resists, lags, deviates, and pushes back. Drives grow in the ongoing negotiation between these two — not in the content of the intention, not in the mechanics of the body, but in the **relation**: the conflict, lag, and separation between them.

**One-sentence version:** A drive is not a signal that gets sent. It is a *pressure* that grows in the gap between what a system wants to do and what its body can actually do — a generative tension that requires irreducible imperfection and cannot be replaced by any amount of computation or control.

**What this does NOT claim:** that drives require slowness, complexity, or biology; that they are all-or-nothing; or that a gapless system has *no* residual drive (see §6.3). A thermostat has a minimal drive (maintain setpoint) even though its "gap" is trivially small. The claim is about the *strength, flexibility, and persistence* of drives, not their mere existence.

---

## 3. Why Functional Isomorphism Fails Across Substrates

### 3.1 The objection

Functionalism: if two systems produce the same input–output mappings, they have the same properties regardless of substrate.

### 3.2 The axe test

Take an axe to a server:
- Substrate damaged → function destroyed. Working or not; discrete failure modes only (bit flip, cache miss, death).
- Mind and body are one thing. Destroy the substrate and you destroy the mind simultaneously.

Take an axe to a human (metaphorically — a stroke, a tumor):
- Substrate damaged → function **altered**, not eliminated. The person is in pain, losing control of one limb, compensating elsewhere, still thinking, still *someone*.
- A **continuum** of damage states, each supporting a different configuration of drives and awareness.
- Mind persists through body damage because mind and body are separate enough that destroying part of one does not instantly destroy the other.

Two systems with identical outputs under normal conditions are **not** functionally isomorphic if they respond differently to perturbation. The response to perturbation is constitutive of what the system *is*.

### 3.3 Function is the full behavioral envelope

> **Function is not a mapping from inputs to outputs. It is a mapping from (inputs, damage states, perturbations, constraint changes) to outputs.**

Because physical structure determines the damage-response profile, two systems with different physical structures cannot be functionally isomorphic in this strong sense. The substrate *is part of the function*, because the substrate determines how the system behaves when things go wrong — and that is where drives are strongest.

### 3.4 Why simulation fails

A simulation of a driven system on a digital computer:
- Normal conditions: same outputs (apparent equivalence).
- Server damaged: catastrophic failure (brittle).
- Therefore never actually functionally isomorphic: the damage-response profile is part of the function.

The simulation simulates the **outputs** of a separated system but not the **separation itself**. Pattern without structure. A drawing of a bird is not a bird. Nothing *grows* in a simulation, because there is no gap to generate drives from — only a representation of one.

### 3.5 The prediction (falsifiable)

> A driven system exhibits **graceful degradation** under partial damage (drive strength falls along a continuum). A non-driven intelligent system exhibits **brittle failure** (full function until a threshold, then none).

Test: build two systems with equivalent accuracy on a task; systematically damage each; measure the performance curve. Graceful vs. brittle is the discriminator.

---

## 4. The System Is Not a Pure Function

In functional programming, a pure function takes inputs, produces outputs, has no side effects, and is fully specified by its input–output mapping.

A driven system is the **opposite**:

| Property | Meaning | Why it matters |
|----------|---------|----------------|
| **Side effects** | It changes the world and itself in ways not captured by any I/O specification | The negotiation between mind and body *is* the content, not an implementation detail |
| **Transparency** | Internal dynamics are, in principle, observable and legible — you can see the tension, compensation, struggle | A person in pain is transparent: something is happening inside the mapping that "stimulus → response" does not capture |
| **Coupling plasticity** | When a connection between intention and execution is lost, the system reorganizes rather than failing | The constraint space changes topology, not just dimensionality (§5.4) |

A server's register states are implementation details: they don't resist, don't negotiate, aren't *about* themselves. All three properties are required; any one alone is insufficient.

---

## 5. Somatic Coupling as Lived Constraint

### 5.1 Structural level: somatic coupling

**Somatic coupling**: specific channels (tethers) connect the decision-making component to specific degrees of freedom in the body. Each channel has strength and topology, and can be severed. The metaphor is a puppet with strings.

Properties:
- **Specificity**: each channel couples a specific decision variable to a specific bodily DOF.
- **Independence**: the body has dynamics not determined by the controller (inertia, compliance, friction, fluid flow).
- **Severability**: channels can be lost without eliminating the system.
- **Topology**: which channels exist defines the system's identity as much as the channels themselves.

### 5.2 Phenomenological level: lived constraint

**Lived constraint**: what somatic coupling is *from the inside*. The system does not observe its coupling from outside; it is bounded by it. The coupling is not a tool the system uses; it is the medium through which the system exists. "Lived" because the constraining thing is the system's **own body**, not an external wall — when a constraint changes, the system doesn't notice a change in its environment, it *becomes a different configuration of itself*.

This is [Merleau-Ponty's](https://plato.stanford.edu/entries/merleau-ponty/) (1945) Leib/Körper distinction made structural: somatic coupling is the Körper; lived constraint is the Leib. Same structure, two perspectives.

### 5.3 Coextensive, both required

There is no somatic coupling that is not also a lived constraint, and vice versa. Both levels are required: without the structural level you cannot specify what makes a system a site of drive generation; without the phenomenological level you cannot explain why the structure matters (a wiring diagram doesn't generate motivation — the constraint must be *lived*, i.e., the system's own body must be doing the constraining).

### 5.4 Coupling plasticity

When a coupling is severed, the system reorganizes around its remaining couplings. This is not a fallback mode; it is a new configuration of the same system.

Properties: **non-instantaneous** (the system takes time to discover what it can still do); **creative** (new configurations become available that were inaccessible before the loss); **transparent** (legible as a process); **asymmetric** (losing a coupling changes the system more than gaining an equivalent one — the constraint space changes *topology*, not just dimensionality). Cut a string from a puppet and it becomes a different puppet: new flops become possible, old ones are lost.

### 5.5 Identity through reconfiguration

"Am I the same person after trauma?" — **yes**, because identity is defined by persistence of the *property* (somatic coupling as lived constraint), not by the specific configuration. The configuration changed; the being did not.

| Condition | What changes | What persists |
|-----------|-------------|---------------|
| Trauma (e.g., stroke) | Motor tethers severed or weakened; new compensation patterns emerge | Somatic coupling as a property; the system is still "someone" with drives |
| Coma | All coupling channels pharmacologically dampened; negotiation stalls | The structural topology is intact; drive generation is paused, not destroyed |
| Locked-in syndrome | Motor output tethers almost entirely severed while internal-state coupling persists | Full drive activity in a radically reshaped lived constraint |
| Dementia | Coupling topology degrades gradually; identity configurations shift | The property (somatic coupling as lived constraint) persists in altered form until very late stages |

---

## 6. Drives Grow in the Control Gap

### 6.1 What a drive is (operational definition)

A **drive** is a sustained, goal-directed pressure that:
- Persists across multiple action cycles (not a single correction).
- Is modulated by the system's internal state (not just external stimulus).
- Generates *novel* solutions when the obvious path is blocked (flexibility).
- Decays when the goal is achieved but reactivates when the goal is threatened (persistence).

A raw feedback loop (sensor → error → correction) satisfies none of these. It corrects; it does not persist, flex, or reactivate. A drive is what emerges when a feedback loop operates **across a gap** — when the system's model of what it wants diverges from what its body can actually do, and the divergence is *felt* (represented internally) rather than merely computed.

### 6.2 Why the gap is generative for drives

- Each attempt to control an imperfect body produces an outcome the mind did not exactly predict.
- That unpredictability forces updating: new models, new strategies, new relationships to the world.
- The act of updating, **when it is represented in a self-model** (§8), becomes a drive: "I need to do better," "this is not working," "I am failing."
- Without the gap: no surprise, no error, no mismatch, nothing to update. The system executes a predetermined plan and generates no new motivation.
- Without the self-model: the updates happen (the cerebellum learns, the weights adjust) but they are *silent*. There is no "I am failing" — just silent correction. The drive exists only in the minimal sense of error signal; it does not become a sustained, flexible, persistent pressure.

**The key distinction:**

| System type | Has gap? | Has self-model? | Drive character |
|-------------|----------|-----------------|-----------------|
| Thermostat | Trivial (sensor ≈ actuator) | No | Minimal: corrects setpoint, no persistence beyond error |
| Cerebellum-only motor control | Yes (intention ≠ execution) | No (unconscious) | Silent correction: learns, adapts, but no felt motivation |
| Embodied agent with self-model | Yes | Yes | **Full drive**: persistent, flexible, reactive, novel-generating |
| Perfect system (gap closed) | No | Irrelevant | None: no negotiation, no pressure, stasis |

### 6.3 What a "perfect system" is

A system with full deterministic control over its body:
- Does not necessarily lose all drive immediately (may retain a residual configuration).
- **Cannot generate new drives** (no negotiation → no novelty → no generative pressure).
- Is metabolically alive but **generatively dead**: it maintains; it does not grow.

Analogies: a cell in a perfect environment maintains homeostasis but does not differentiate. A person in a padded room with looped stimuli does not die, but develops no new motivations.

### 6.4 The central claim, restated

> **Drives grow in the gap between a system's control authority and its body's complexity, and self-modeling amplifies them.** The gap is not a container; it is the generative pressure that produces sustained motivation. Self-modeling is the amplifier: it converts silent error correction into felt wanting. A system without a self-model can correct; a system with a self-model *wants*.

### 6.5 Consequence for evolution

- Evolution optimizes well-practiced domains toward narrow gaps (automaticity); residual drive concentrates in the capacity for novelty.
- Emotions are **drive amplifiers**: they are the self-model's way of saying "this gap matters, pay attention to it." Fear widens the gap (threat → body can't fully control outcome → strong drive to escape). Desire narrows the gap in a specific direction (goal → body works toward it → drive persists until achieved).
- A fully augmented human would have drive generation concentrated in the remaining gaps: novel situations, social relationships, creative generation — the domains no amount of control closes.

### 6.6 The asymptotic limit (structural argument)

Even if the gap could theoretically close, the result is **stasis**, not death: like a river reaching the ocean — it stops being a river without ceasing to be water.

For finite self-contained systems the limit is structurally unreachable:
- The body is too complex for any finite controller to fully determine (computational irreducibility).
- The body changes (aging, adaptation, damage) faster than the controller can update its model.
- The controller IS part of the body: full self-control requires controlling the controller, which requires a meta-controller, ad infinitum.

This is not an engineering limitation. It is a structural impossibility: **the thing doing the closing is itself part of the gap.** (Part II shows this has a stronger, logical form in Ismael's work.)

### 6.7 The control gap and drive strength in practice

| Condition | Gap | Drive character |
|-----------|-----|-----------------|
| Learning a new skill (first attempts) | Wide | Strong, persistent, frustrating — every correction is *felt*; novelty per attempt is maximal |
| Practice (10–50 reps) | Narrowing | Weakening — movement starts to "just happen"; drive fades into automaticity |
| Mastery (thousands of reps) | Narrow | Minimal — you don't consciously feel your hands typing; drive has been absorbed into the body |
| Disruption (fatigue, alcohol, damage) | Widens again | Spikes — drive returns because the familiar is no longer controllable; "why can't I do this?" |
| Prosthetic integration (months) | ~0 for that limb | Drive in that domain has ceased; it has become part of the body |
| Anesthesia | Coupling pharmacologically dampened | Drive stalls; negotiation disrupted, body intact |

### 6.8 Connection to life itself

| Property | Life | Drives | Consciousness |
|----------|------|--------|---------------|
| Requires | Metabolism (ongoing flux) | Somatic coupling (ongoing negotiation) | Self-modeling (ongoing self-representation) |
| Generates | Novelty (evolution, adaptation) | Novel solutions (flexible behavior) | Novel experience (new awareness) |
| Stopped by | Thermodynamic equilibrium (death) | Full control (stasis) | Gap closure + no self-model (zombie state) |
| Character | Process, not state | Process, not state | Process, not state |

Life and drives share one structural requirement: **they are open processes that cannot reach equilibrium.** Consciousness adds a third: it requires the process to be *represented to itself*.

---

## 7. Biological Demonstration: Cerebrum and Cerebellum

The cleanest biological instance, because it shows the separation is not between "brain" and "body" but between **two components within one system that have genuinely independent dynamics**.

| Component | Role | Properties |
|-----------|------|------------|
| Cerebrum | Generates intentions, goals, plans; conscious experience; **drive generation** | Slow, deliberative, serial, high-level |
| Cerebellum | Coordinates execution, timing, error correction, motor adaptation | Fast, parallel, ~60–70% of all neurons, largely unconscious |

Physically disjoint (distinct architectures), connected via pontine nuclei / inferior olive / thalamic relays (the tethers), active simultaneously, and **independent in dynamics**: the cerebellum learns on different timescales, with its own error signal (efference copy vs. sensory feedback mismatch), and operates without cerebral involvement for rhythm generation.

**The axe test inside one organism:** damage the cerebellum and the system does not die. It reorganizes — and the cerebrum becomes *acutely aware* of every movement, because the intention–execution gap has widened pathologically. **Drive strength in the motor domain increases precisely because control decreases.** The patient *wants* to move their arm and *feels* the failure. The drive is stronger because the gap is wider.

**The coevolutionary loop:** (1) cerebrum generates a novel intention → (2) cerebellum executes with its current model, producing error → (3) error updates the cerebellar model → (4) over repetitions the model converges and movement becomes automatic → (5) the cerebrum "releases" the task and drive in that domain fades → (6) a new novel intention reopens the gap and drive returns.

The cerebellum is a **natural gap-closer**: its success condition (perfect coordination) is exactly the condition under which drive in that domain stops. The gap never fully closes because the cerebrum keeps generating novelty faster than the cerebellum can converge — the world is generatively novel.

**Domain-specificity prediction:** drive generation is distributed across domains, each with its own gap and its own rate of generative activity. You can be strongly motivated in movement (wide motor gap) while feeling nothing about your heartbeat (narrow autonomic gap).

---

## 8. Self-Modeling and Drive Amplification

*This section states the theory's central amplification claim: a system that models itself as a persistent embodied entity generates stronger drives than one without such a model. Attention schema theory (Graziano) is presented as one known biological mechanism for this self-modeling — not as the only possible mechanism, and not as a proven identity.*

### 8.1 The amplification claim

> **A self-model converts silent error correction into felt drive.** Without it, the system corrects (cerebellum learns, weights update) but does not *want*. With it, the same error signal becomes "I am failing," "this matters," "I need to do better" — a sustained, flexible, persistent pressure that outlasts any single correction cycle.

The mechanism:
1. The body produces an error (intention ≠ execution).
2. Without self-model: the error is corrected silently. Weights update. No drive persists beyond the correction.
3. With self-model: the error is **attributed to a self** — "I" am the one who is failing, "my" body is the one that can't do it. This attribution transforms the error from a transient signal into a **property of a persistent entity**: I am the kind of thing that fails at this, and I will keep trying until I succeed.
4. The drive persists because the self-model provides *temporal continuity*: "I" existed before this failure and will exist after it. The motivation is not "correct this instance" but "I, who persist, need to resolve this gap."

**This is why emotions are drive amplifiers.** Fear is the self-model saying: "a gap is opening that I cannot close, and if I don't act, *I* (the persistent entity) will be destroyed." Desire is the self-model saying: "there is a gap in a specific direction, and closing it would make *me* (the persistent entity) more complete." Neither emotion exists without the self-model. A system with no sense of self can detect threat (startle reflex) but cannot feel fear — because fear requires "I" to be the thing at risk.

### 8.2 Attention schema theory as one mechanism (not the only one)

[Michael Graziano](https://grazianolab.princeton.edu/) has proposed, across a series of papers and a book ([Graziano & Kastner, 2011](https://www.cell.com/trends/cognitive-sciences/abstract/S1364-6613(10)00378-9); [Graziano, 2013](https://books.google.com/books/about/Consciousness_and_the_Social_Brain.html?id=8dMdAAAAQBAJ)), that:

> **Consciousness is the brain's own schematic model of its attention.** Just as the motor system maintains a body schema — a running, deliberately inaccurate model of what the body is doing — the brain maintains an *attention schema*: a running, deliberately inaccurate model of what attention is doing. And that model, not raw qualia, is what we experience as consciousness.

**Status flag:** AST is one of several competing accounts of consciousness (GNWT, IIT, HOTT, recurrent processing theory, higher-order perception). It has evidence supporting it and evidence against it. This theory **chooses AST as its working mechanism** for self-modeling because:
- It specifies a concrete neural implementation (prefrontal/parietal circuits modeling attentional state).
- It makes testable predictions about what happens when the model is disrupted.
- It naturally explains why self-knowledge feels like *direct access* rather than inference (the model is experienced as reality because it is generated from inside).

**But the theory does not depend on AST being correct.** What the theory requires is:
- A self-model exists (some representation of the system as a persistent entity).
- The self-model receives error signals from the control gap.
- The self-model's output amplifies drive persistence and flexibility.

If AST turns out to be wrong, the theory survives with a different mechanism for self-modeling. The amplification claim (§8.1) is independent of *how* the self-model is implemented. What would falsify the theory is: showing that self-model disruption does NOT reduce drive persistence (A1, §20).

### 8.3 The "squirrel in the brain" case study

> **Case study (boxed):** A patient who genuinely believed there was a squirrel inside his head.

The specific "squirrel" variant appears to be an anecdote from talks in this research line (Graziano's popular lectures; Schurger's public discussions of AST). The closest documented clinical phenomenon is **delusional zoopathy**: patients who hold fixed beliefs that animals are inside their bodies or heads, with accompanying somatic hallucinations. Documented cases include:
- Bora, Bhuyan & Boro (2020): a 19-year-old patient with schizophrenia who believed two cats lived inside her head — one in each ear — and could hear them speaking ([IJSRP 10(6):558–560](http://dx.doi.org/10.29322/IJSRP.10.06.2020.p10267)).
- Mitra et al. (2017): a patient with cannabis-induced psychosis who felt a mole moving inside his abdomen ([Asian J Psychiatry 30:35–36](https://doi.org/10.1016/j.ajp.2017.01.016)).
- Alam et al. (2015): an 18-year-old male who believed worms had entered his brain when he washed his face ([Open J Psychiatry Allied Sci 6(2):149](https://www.researchgate.net/publication/273569831)).

**What this case shows (and does not show):**

The self-model in these patients is **broken**. The machinery that normally attributes internal activity to the correct source (my own attention, my own body) has malfunctioned and is attributing it to an external agent (a cat, a mole, worms). This tells us:
- The self-model is a *generative* process, not a passive window. It produces specific content.
- When the inputs are corrupted (by psychosis, by drug-induced distortion), the output is wrong but still experienced with full certainty — because it has the phenomenological signature of self-knowledge (it comes from inside).

**What this case does NOT show:**
- It does not show that healthy self-models are unreliable. A broken mirror shows distorted images; that tells us about the crack, not about mirrors in general.
- It does not show that our belief in consciousness is "just another delusion." The structural difference: the attention schema's report of "I am conscious" has a **real referent** (there really is ongoing attention, there really is a gap being negotiated). The delusional patient's report of "there is a cat" does not.
- It does show that self-models are *fallible in principle*: the same machinery that generates well-calibrated reports can, under pathological conditions, generate wildly inaccurate ones. This is a feature, not a bug — it means the belief in consciousness has the same reliability profile as other self-models (usually accurate, sometimes wrong, always a model output rather than direct observation).

### 8.4 Need → urge → extended discharge

The full cycle in biological terms:

1. **Need**: a homeostatic variable deviates from its target (hunger, pain, social isolation).
2. **Urge**: the deviation is converted into a goal-directed drive — an intention with a target. **This step requires the self-model**: "I am hungry" is not just "nutrient level low → seek food." It is "I, who persist, will die if I don't eat, and eating will make me feel better." The temporal continuity provided by the self-model is what makes the urge *persistent* rather than merely reactive.
3. **Extended discharge**: the urge drives action across the control gap. The body executes imperfectly; the cerebellum corrects silently; the self-model monitors and reports, generating the felt sense of effort, frustration, or satisfaction. The discharge is "extended" because it takes time (typically 50–100 ms minimum for the full loop), and during that time, new information arrives, the body moves, and the gap generates novelty.

This is the enactive sense-making loop ([Di Paolo, Rohde & De Jaegher, 2007](https://www.sussex.ac.uk/informatics/cogslib/reports/csrp/csrp587.pdf)) made concrete: the system does not represent the world and then act; it acts and the acting is the representing. The self-model is what makes this loop *felt* rather than merely present, and what makes the drives *persistent* rather than merely corrective.

The connection to active inference ([Friston, 2010](https://www.nature.com/articles/nrn2787)): minimizing variational free energy requires both perception (updating the model) and action (making the world match the model). The control gap is where these two processes meet in tension; the self-model is what reports on that meeting and amplifies the drive to resolve it.

### 8.5 What the self-model does (functional summary)

| Function | Without self-model | With self-model |
|----------|-------------------|-----------------|
| Error correction | Silent, instantaneous, no persistence | Felt, sustained, drives re-engagement |
| Novelty generation | Occurs (cerebellum learns) but is invisible to the system | Occurs and is *experienced* as struggle, discovery, growth |
| Temporal continuity | Each moment is independent; no "I who persists" | Drives persist across time because "I" persists |
| Flexibility under blockage | Tries same action until error decays (or switches by random exploration) | Generates *novel* strategies motivated by "I need to find another way" |
| Self-preservation | Reflexive (withdraw from damage) but no *motivation* to preserve | **Drive to persist**: "I will not die" is a drive, not just a reflex |

The last row is the key. §9 develops it.

---

## 9. The Self-Preservation Argument: Why You Can't Have One Without the Other

> **A system cannot implement self-preservation without implementing a sense of self.** This is not an empirical claim; it is a structural one. Self-preservation requires knowing *what* is being preserved, and that "what" is a self-model.

### 9.1 The argument

Self-preservation means: the system takes actions whose goal is its own continued existence. For this to be a *drive* (not just a reflex), it must satisfy the operational definition in §6.1:
- **Persistence**: the drive must outlast any single threat. A startle reflex handles one shock; self-preservation means "I will keep avoiding threats indefinitely." This requires temporal continuity — a model of "me" that exists across time.
- **Flexibility**: when the obvious escape route is blocked, the system must generate novel strategies. This requires a model of "what I can do" (body schema) and "what I am trying to preserve" (self-model).
- **Reactivation**: after a threat passes, the drive returns when the next threat appears. This requires the self-model to persist in the background: "I am still here, I am still at risk."

A system with no self-model can have *reflexive* self-preservation (withdraw from heat, flee from predator). But it cannot have *motivational* self-preservation — the sustained, flexible, persistent drive to keep itself alive. The distinction:

| Level | Mechanism | Example | Requires self-model? |
|-------|-----------|---------|---------------------|
| Reflexive | Stimulus → withdrawal (no persistence beyond stimulus) | Hand pulls from hot stove | No |
| Learning-based | Error → weight update → better avoidance next time | Rat learns to avoid shocked corner | Partially (spatial memory, but no "I") |
| Motivational | Self-model + gap → persistent drive to preserve self | "I will not die; I will find food; I will avoid the predator" | **Yes** |

The third level is what we mean when we say an animal *wants to live*. It is not just avoiding death reflexively; it is a sustained project: "I, who persist, will continue to persist." That project requires a model of the self as a persistent entity.

### 9.2 Implications

- **Evolutionary**: self-preservation as a *drive* (not just a reflex) is what selected for self-models. Systems that could represent themselves as persistent entities had an evolutionary advantage: they planned ahead, stockpiled resources, avoided novel threats by analogy ("this looks like the thing that hurt me last time"), and recovered from setbacks rather than simply stopping.
- **Clinical**: disorders of self-preservation (self-harm, anorexia, reckless behavior) may involve disruptions to the self-model — not the body's ability to survive, but the *drive* to survive. The body is intact; the "I who persists" has been damaged.
- **Artificial systems**: a robot that avoids obstacles reflexively is not "self-preserving" in the motivational sense. A robot that models itself as a persistent entity with a goal of continued operation, and generates novel strategies when its obvious options are blocked, *is* self-preserving — and by this theory, it has drives, even if it has no consciousness (the anti-metric clause / vector-space clause, §11, applies: we don't rank it against humans; we describe its configuration).

### 9.3 The structural form

The argument can be stated formally:

Let S be a system with body B and controller C. Let P be the property of self-preservation as a *drive* (persistent, flexible, reactive — §6.1). Then:

> **P requires that C maintains a model M of S as a persistent entity.** Without M, C can implement reflexive avoidance (stimulus → response) but cannot implement P, because P requires temporal continuity (the same "S" persists across the threat and after it), which is precisely what M provides.

This is not proven by experiment; it is a structural argument of the same type as "you cannot have a map without a territory to map." The self-model is to self-preservation what the territory is to the map: you can have reflexive responses without a map, but you cannot have *navigation* (persistent, flexible, goal-directed movement through a changing environment) without one.

---

## 10. Convergence, Not Simulation

If a non-biological system genuinely instantiates the structural properties — somatic coupling as lived constraint, side effects not reducible to I/O, transparency, coupling plasticity, open control gap, **and a self-modeling capacity** — then it **is** a site of drive generation, at the same structural level as a biological system with equivalent complexity.

But this is **convergent evolution or creation**, not simulation:

| | Simulation | Convergence / Creation |
|---|---|---|
| What it does | Represents the pattern without having the structure | Instantiates the same structure by different means |
| Relation to original | Pattern correspondence only | Structural identity at the level of relevant properties |
| Analogy | A drawing of a bird is not a bird | Bat and bird both fly — convergent evolution |
| Drive generation? | No (no separation, no generative gap) | Yes (all structural properties present) |

**Caveat on the bat/bird analogy:** Flight has a known physical mechanism (aerodynamic lift) that allows us to verify structural identity across substrates. Consciousness and drive generation do not yet have an agreed-upon physical mechanism. The analogy is therefore *illustrative*, not *demonstrative*: it shows what we mean by "same structure, different substrate," but it does not prove that such convergence is possible for consciousness specifically. If consciousness turns out to be irreducibly tied to specific biological chemistry (a possibility the theory does not exclude), then "convergence" becomes an empty word and only biological systems qualify.

**Ruled out:** digital simulation of a brain (pattern without structure); LLMs (approximately pure functions — no side effects beyond output tokens, no somatic coupling, no generative gap, no self-model in the structural sense); fully compensated robots (separation engineered away — the body is invisible to the controller, so there is nothing to negotiate with); **perfectly controlled systems** (intelligent, complex, running for billions of years — if the gap is closed, no new drives grow; metabolically alive, generatively dead).

**Ruled in:** underactuated physical agents with homeostatic drives and autonomous body dynamics; soft robots whose fluidic/elastic bodies have controller-independent dynamics; any future system (biological, artificial, hybrid) that achieves the same structural level through any means while maintaining an open gap **and a self-modeling capacity**.

---

## 11. The Vector-Space Clause

> This framework describes **what drives and consciousness are** (structural requirements and generative mechanism) and **how they vary in configuration**. If measures of consciousness or drive strength can be defined, they would not be single scalars but **vectors in a high-dimensional space**: one axis per domain (motor, social, cognitive, emotional), one axis per timescale (momentary urge vs. persistent project), one axis per quality (strength, flexibility, persistence, novelty-generation rate). "X has more consciousness than Y" as a single-number comparison is undefined. "X and Y differ in their configuration across this vector space" is the only claim the theory makes.

This clause serves two purposes:
1. **Scientific**: it permits comparative statements ("system A generates more novel solutions in the motor domain than system B") while forbidding the specific misuse of reducing all dimensions to one number and ranking beings on that number.
2. **Ethical**: it blocks the derivation of moral hierarchies from structural measurements. A vector-space description cannot be collapsed into "more/less" without choosing a weighting, and any weighting is a value judgment, not a measurement.

The clause is **not** a prohibition on all comparison. It is a prohibition on *scalar reduction*. You can say "this system has a wider motor gap and narrower social gap than that one." You cannot say "this system is more conscious." The first is structural; the second is evaluative.

---

---

# Part II — The Physics & Cognition Bridge (Speculative; Structural Analogy)

*This part borrows structure from three works. None is required for the minimal experiments in Part IV. All are included because they upgrade two of the theory's claims from practical to structural/logical status, and because together they suggest a formal home for the control gap variable. **Important framing: these are three different mathematical objects that share a name ("free energy") and a functional role (generative pressure between equilibrium and incoherence). They have not been shown to be the same quantity in a formal sense. J1 tests whether the analogy holds at the level of dynamics; it does not assume identity.***

## 12. Vanchurin: The Universe as a Neural Network

[Vanchurin (2020)](https://arxiv.org/abs/2008.01540) proposes that the universe, at its most fundamental level, is a neural network with **two types of dynamical degrees of freedom**:

| Type | Role in the model | Theory analog |
|------|-------------------|---------------|
| **Trainable variables** (weights, biases) | Slow evolution; define structure | The "mind" — laws, intentions, controller state |
| **Hidden variables** (neuron state vectors) | Fast evolution; own dynamics independent of weights | The "body" — matter in motion |

The formal results (all derived, not asserted):
1. **Near equilibrium**, the stochastic evolution of trainable variables is approximated by **Madelung equations**, in which the phase of the complex wave function IS the **free energy** of a statistical ensemble of hidden variables → recovers quantum-mechanical behavior.
2. **Far from equilibrium**, the dynamics follow **Hamilton–Jacobi equations** with free energy as Hamilton's principal function → classical mechanics.
3. With a permutation-matrix weight structure, the hidden-variable dynamics are describable as **relativistic strings in emergent D+1 Minkowski spacetime**; with minimal metric-tensor interactions, the emergent spacetime is **curved**, and a simple symmetric Onsager tensor yields entropy production given by the **Einstein–Hilbert term** → general relativity.
4. The two descriptions may be **holographic duals** of each other.

See also: [Vanchurin's EISM lecture walkthrough](https://neuralcosmology.com/en/lectures/vanchurin-world-as-neural-network-2020) and the published version in [*Entropy* 22(11):1210](https://www.mdpi.com/1099-4300/22/11/1210).

**Status:** the mathematics is real; the ontological claim ("the universe IS a neural network") is a hypothesis, not a confirmed theory. This theory borrows only the *structural* result: a precise two-class degrees-of-freedom split (slow structure / fast state) whose stochastic dynamics recover QM and GR limits. Even if Vanchurin's ontology is wrong, the trainable/hidden split is the most precise statement yet of mind/body separation with independent timescales.

**The analogy (not identity):** Vanchurin's free energy is a statistical-mechanical partition function over hidden variables. It plays the role of "generative pressure between equilibrium and far-from-equilibrium" at the cosmological scale. This theory's control gap plays an analogous role at the agent scale. Whether they are the same quantity in a formal sense is an open question (J1 tests the dynamical consequence, not the ontological identity).

---

## 13. Ismael: The Participatory Universe and the Logical Gap Floor

Ismael's position, across [*How Physics Makes Us Free* (2016)](https://academic.oup.com/book/4740), her [TLS essay on free will](https://www.jenanni.com/papers/FreeWill,TLS.pdf), and ["A Participatory Universe in the Realist Mode" (*Foundations of Physics*, 2025)](https://link.springer.com/article/10.1007/s10701-025-00843-4):

**The standard determinism argument misreads physics.** The claim "physics tells us we are determined" assumes a *view from nowhere* — a God's-eye description of the total universal state. Physics does not provide that view. Physical states are **representations**, and all descriptions are perspectival: made by an agent who is part of what they describe.

**The key mechanism (2025 paper):**

> "The fact that we act in the domain that we are representing can make it impossible to stabilize certain facts or features of the world as objects of knowledge."

She distinguishes the **observational perspective** (I model a system from outside) from the **agentive perspective** (I act inside the domain I am representing). In most day-to-day physics the separation is maintainable; ultimately it is not — we are part of the universe. When representor and represented cannot be detached:

> "Interference arises when the event being represented can't be detached from the act of representing it." — **causal interference**: my prediction changes the system, which changes what I observe, which changes my next prediction. The loop cannot be unwound.

See also: [Ismael (2024), "Passage, flow, and the logic of temporal perspectives"](https://www.tandfonline.com/doi/full/10.1080/24740500.2024.2526896).

**What this upgrades in the theory:** §6.6 argued the control gap is *structurally* unreachable for finite self-contained systems (the controller is part of the body). Ismael gives a stronger form: it is **logically** unreachable for *any* system that represents itself, because reflexivity makes complete self-knowledge impossible as a matter of representation theory, not as a contingent fact about brains. The gap floor is not an engineering limit; it is a feature of what it means to model a system you are inside.

**Connection to the self-preservation argument (§9):** if the self-model can never fully capture the system (because the modeler is part of the modeled), then self-preservation as a drive is *permanently incomplete*. The system can never be certain that its model of "what I need to do to survive" is correct. This permanent uncertainty is not a bug; it is what keeps the self-preservation drive *active*. A system that could perfectly predict its own survival needs would stop trying — the gap would close, and the drive would fade. The irreducible uncertainty IS the drive.

**Status:** philosophical argumentation, not empirical physics. It does not show that experience arises from interference — only that the "gap closes" scenario is incoherent for self-representing systems. That is exactly the claim Part IV's J2 experiment tests dynamically.

---

## 14. Schurger: The Formal Bridge Between Self-Modeling and Neural Dynamics

### 14.1 The key paper

The most direct formalization of the self-modeling / attention-schema line by Aaron Schurger is:

> **Schurger, A., & Graziano, M. (2022). Consciousness explained or described? *Neuroscience of Consciousness*, 2022(1), niac001.** [DOI: 10.1093/nc/niac001](https://academic.oup.com/nc/article/2022/1/niac001/6523097)

This paper makes the argument this theory requires, in Schurger and Graziano's own words:

> "AST gets away with being a theory because it does not treat consciousness as something inherently mysterious, ineffable, irreducible, or unexplainable using a reductionist or mechanistic framework... AST's explanatory power may in part be owing to the way it approaches the problem of consciousness—**by offering to explain why we believe in consciousness rather than explaining consciousness *per se***."

They argue that most modern consciousness theories (GNWT, IIT, HOTT) are not theories at all but **laws** — descriptions of correlations that do not explain. AST is different: it explains the *belief* in consciousness as a product of brain self-modeling. This is precisely the reframing this paper develops in Part III.

### 14.2 Schurger's formal models of neural dynamics

Schurger's independent research program provides mathematical machinery relevant to the control-gap variable:

**The accumulator model with autocorrelated noise (2012, 2018):**
Schurger ([2012](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.1001496); [2018](https://www.eneuro.org/content/5/1/ENEURO.0302-17.2018)) developed a formal model of the neural activity preceding self-initiated action (the "readiness potential"):

$$x(t+1) = x(t) + \mu + \sigma \cdot \epsilon(t) + \beta \cdot \epsilon(t-1)$$

where $x(t)$ is the accumulated neural evidence, $\mu$ is a small bias, $\epsilon(t)$ is input noise with temporal autocorrelation parameter $\beta$, and action occurs when $x(t)$ crosses a threshold. The key result: **the shape of the readiness potential (its slope, its relationship to subjective decision time) is determined by the noise structure**, not by a top-down "decision" signal. The feeling of deciding emerges from the dynamics of accumulation in a noisy system — there is no moment where a "self" makes a choice; the choice is the point at which accumulated noise crosses threshold.

**Connection to the control gap (analogy, not identity):** In this theory's vocabulary, the accumulator's $x(t)$ is the ongoing negotiation between intention (the target) and execution (the current state). The noise $\epsilon(t)$ is analogous to the body's autonomous dynamics — the part of the system not determined by the controller. The threshold crossing is the moment the gap "closes" for that particular action. The *feeling* of the process — the readiness potential, the sense of building intention — is the self-model monitoring the accumulation.

**Caveat:** this mapping is structural, not derived. The accumulator model describes neural dynamics in a specific experimental paradigm (self-initiated movement). The control gap is a more general structural variable. They share a formal shape (accumulation toward threshold under noise), but the theory does not claim they are the same process. J1 tests whether the dynamical consequence (inverted-U in novelty vs. aggregate error) holds; it does not test whether the accumulator model *is* the control gap.

### 14.3 The free-energy analogy (stated honestly)

Three works use "free energy" in different formal senses:

| Work | What "free energy" is formally | Functional role |
|------|-------------------------------|-----------------|
| Vanchurin (2020) | Statistical-mechanical partition function over hidden variables; phase of the wave function | Generative pressure between equilibrium and far-from-equilibrium at cosmological scale |
| Friston (2010) | Variational bound on model evidence; $F = E_q[\log q(z) - \log p(x,z)]$ | Action-theoretic: perception minimizes F by updating model; action minimizes F by making world match model |
| Schurger (2018) + this theory | Aggregate drive error $F(t) = \sum_u \text{error}_u^2$ (a proxy, not a formal free energy) | Generative pressure between stasis and incoherence at agent scale; the coordinate on which novelty is an inverted-U |

These are **three different mathematical objects** that share a name and a functional role (generative pressure in a specific regime). The theory does NOT claim they are the same quantity. It claims:
- They are structurally analogous (same shape of dynamics: generative between two extremes, with a characteristic coordinate).
- J1 tests whether the *dynamical consequence* (inverted-U in novelty vs. this coordinate) holds at the agent scale.
- If J1 holds, the analogy is confirmed at the level of dynamics (even if the ontological identity remains open).
- If J1 fails, the analogy breaks and the bridge is demoted to a naming coincidence.

### 14.4 Status flag

*The formal connection between Schurger's accumulator model and this theory's control-gap variable is stated here as a structural analogy, not as a proven identity. The mapping is plausible and testable (J1), but it is not derived. This section should be read as "here is the closest formal work by Schurger, and here is how it connects structurally" — not as "Schurger has proven this connection."*

---

---

# Part III — The Hard-Problem Reframing: Why We Believe So Strongly That We Are Conscious

*This chapter is a positive argument about the belief in consciousness. It does not solve the hard problem (why there is something it is like at all). It explains why we are so certain that there is. This distinction is stated here and repeated in §23 (C6): the reframing explains the belief; it does not explain the existence of experience.*

## 15. The Reframing

### 15.1 The standard question and its problem

The hard problem, as typically posed: "Why is there something it is like to be you? Why doesn't all that neural processing just happen in the dark?"

This question assumes a perspective — an outside view from which one can compare "neural processing" with "what it is like" and ask why they co-occur. But as Ismael (§13) argues, there is no such outside view for a self-representing system. The representor is in the represented. We cannot step outside our own experience to compare it with the brain processes that produce it, because the act of comparing IS an experience produced by those same processes.

### 15.2 The reframed question

> **Instead of "is there consciousness?" ask: "this is why we believe so strongly that we are conscious."**

The answer: our certainty of being conscious is not direct access to raw experience. It is the **self-model continuously generating a report from inside the control gap**, and the report is experienced as reality.

The mechanism, step by step:
1. The brain has ongoing attention — allocation of processing resources across the control gap (§2).
2. The brain maintains an internal model of that attention (the self-model; §8).
3. The self-model generates a continuous report: "attention is active; something is happening inside me; I am aware."
4. This report is experienced with the phenomenological signature of self-knowledge — it feels like *knowing*, not like *inferring*.
5. Because the report is generated from inside (it is the system's own model of its own activity), it has the same epistemic authority as any other first-person experience. There is no "view from outside" available to check it.
6. Therefore: **we believe we are conscious because the brain tells us we are, continuously, from the inside, using the same machinery it uses for all self-knowledge.**

### 15.3 The squirrel case: what it shows and what it doesn't

The delusional-zoopathy patients (§8.3) demonstrate that the self-modeling machinery can produce vivid, specific, confidently held reports about internal activity that are *wrong*. A patient believes there is a cat in their head. They feel it moving. They hear it speaking. The belief has all the phenomenological markers of genuine self-knowledge — it is first-person, immediate, and resistant to counter-evidence.

And yet it is a model output. The self-model (or its corrupted analog) generated a specific report about what is happening inside, and that report was experienced as reality.

**The structural parallel:**
- Belief in the cat: self-model generates "there is an animal inside me" → experienced as fact.
- Belief in consciousness: self-model generates "I am aware; something is happening inside me" → experienced as fact.

Both are model outputs. Both have the same phenomenological authority. The difference is only in calibration: the self-model's report of "I am conscious" is usually well-calibrated (there really is ongoing attention, there really is a gap being negotiated), while the delusional patient's report of "there is a cat" is not.

**The critical distinction (addressing the pathology objection):** Delusional zoopathy is a *pathology*. The self-model is broken — typically by schizophrenia, substance use, or organic damage. The fact that a broken system can generate false beliefs tells us about the *limits* of the system, not about its normal operation. A cracked mirror shows distorted images; that tells us about the crack, not about mirrors in general. In healthy systems, the self-model's report is well-calibrated for the same reason proprioception is well-calibrated: it has a real referent (ongoing attention, an open gap) and its inputs are not corrupted.

The theory's claim is therefore narrower than "our belief in consciousness might be a delusion." The claim is: **the belief in consciousness is a model output with the same reliability profile as other self-models** — usually accurate, fallible in principle, structurally incapable of being verified from outside. This is not a reason to doubt it; it is a reason to understand *what kind of thing* it is.

### 15.4 What this means for the hard problem

**The reframing does NOT solve the hard problem.** It does not explain why there is something it is like to be the system generating the report. That question remains open (conceded in §23, C6).

What it DOES do:
- It identifies a specific, testable mechanism for the *belief* in consciousness (the self-model reporting on drive generation).
- It predicts that the belief should be **fallible and confabulatory** exactly like other self-models (§15.5).
- It dissolves a false dichotomy: we don't need to choose between "consciousness is real" and "consciousness is an illusion." The correct question is: what generates the report, and how reliable is it?
- It connects the hard problem to Ismael's perspective argument (§13): we ask about raw experience from outside, but all any self-representing system has access to is its own report. The "hard problem" may be a question posed in the wrong perspective — not because consciousness doesn't exist, but because the question assumes a vantage point that no self-representing system can occupy.

**The deeper question remains:** why does generating that report involve *experience* rather than silent computation? A computer generates outputs without anything it is like to be the computer. Why does the brain's self-model generate experience? This theory does not answer this. It answers a different question: *given* that there is experience, what is its content determined by? Answer: the self-model's report on drive generation in the control gap.

### 15.5 Fallibility predictions (testable)

If the belief in consciousness is a self-model output, it should exhibit the same fallibility patterns as other self-models:

| Prediction | Evidence sought | Status |
|-----------|----------------|--------|
| People systematically misreport what they were attending to | Attentional blink; change blindness; inattentional blindness literature | Well-established (Mack & Rock, 1998; Simons & Levin, 1997) |
| The felt sense of "deciding" is post-hoc confabulation, not the cause of the decision | Readiness potential literature (Libet, 1983; Schurger et al., 2012); the accumulator model shows the feeling of deciding emerges from noise accumulation, not from a top-down choice signal | Established for motor decisions; extending to other domains |
| The belief in consciousness should be modifiable by disrupting the self-modeling channel | TMS over prefrontal cortex (self-model generation site) changes meta-cognitive reports without changing primary perception | Partially established (Metzinger, 2009; recent work on "self-model" disruption) |
| In the particle brain: disrupting the recurrent network (the self-model analog) should change the system's "report" (neuron state) without changing its actual dynamics (matter trajectories) | New experiment A1 (§20) | To be tested |

The last prediction is the one specific to this theory: if the self-model analog in the particle brain (the recurrent network that modulates neuron outputs based on urge errors) is disrupted, the system's internal "report" should diverge from its actual dynamics more than a null model predicts — even while its behavior remains unchanged. This would be direct evidence that the report and the reality it reports on are separable, exactly as the reframing requires.

### 15.6 What is and isn't solved

| Question | Status after reframing |
|----------|----------------------|
| Why is there something it is like at all? | **Unsolved.** The theory concedes this in full. |
| Why do we believe we are conscious? | **Solved (mechanistically).** The self-model generates the report; the control gap provides the content; the self-referential perspective makes it feel like direct knowledge. |
| Is the belief reliable? | **Partially.** Usually well-calibrated (there really is ongoing attention, drives really are being generated), but structurally fallible (squirrel case shows the machinery *can* misattribute). Same reliability profile as other self-models. |
| Can we verify consciousness from outside? | **No** — by the same logical argument (Ismael, §13) that makes the gap floor unreachable. We can only infer it from behavior, which is what the vector-space clause respects. |
| Does this explain why experience exists? | **No.** It explains why we *report* experience. The existence of experience itself remains the hard problem. |

---

---

# Part IV — Experimental Design (Steelman)

*This part states the theory's strongest defensible form as explicit hypotheses, specifies what each hypothesis requires, and gives concrete protocols on the Particle Brain (commit 830907b). The steelman discipline: every hypothesis is stated so that a specific measurement result would count against it.*

## 16. Design Principles

These principles govern any experimental implementation, including the Particle Brain:

| # | Principle | Implementation requirement | Validation |
|---|-----------|---------------------------|------------|
| **A** | Autonomous body dynamics | The body (matter particles) must have dynamics not determined by the controller. In the particle brain: the interaction matrix must be non-zero and govern forces independent of neuron output. | E3 (§19): zeroing the matrix collapses novelty |
| **B** | Controller must NOT fully compensate — inverted-U prediction | Control authority must be sweepable from 0 to "full." At full authority, the body becomes a perfect slave; at zero, no coherent action. The sweet spot is intermediate. | E1 (§19): inverted-U in novelty vs. authority |
| **C** | Physical self-referential homeostatic variables | The system must have drives that are computed from its own state (not externally imposed). In the particle brain: urges compute error from their own sensory region. | H2 (§17): trade-off triangle requires P(t) to be internal |
| **D** | Self-modeling capacity | The system must maintain an internal model of its own control loop — the self-model analog. In the particle brain: the recurrent network (8-unit RNN) that modulates neuron outputs based on urge errors IS the self-model analog. **Caveat:** this is a structural role assignment, not a claim that 8 units instantiate "self-modeling" in any strong sense. It plays the *role* of feeding back on its own control loop, which is the minimal structural requirement. | A1 (§20): disrupting the RNN changes "report" without changing dynamics |
| **E** | Non-trivial constraint topology | The coupling between controller and body must have structure (which neurons drive which matter, with what gain). Not fully connected; not random. | H5 (§19): damage to specific channels produces specific reorganization patterns |
| **F** | Coupling plasticity | The system must be able to reorganize its couplings over time. In the particle brain: Hebbian learning on `control` weights (C6, §18). | H6 (§19): learning sustains novelty longer than frozen weights |
| **G** | Environment must be generatively novel | The environment (interaction matrix rules) must change slowly enough to prevent permanent convergence but fast enough to sustain novelty. | E4 (§19): static → decay; drifting → sustained |

---

## 17. The Hypotheses

| ID | Hypothesis | Strongest form | What it requires |
|----|-----------|----------------|------------------|
| **H1** | Control-gap generativity | Novelty generation is a non-monotonic function of control authority: absent at zero authority (no coherent action) and at full authority (gap closed), maximal in between | Structural core only |
| **H2** | Gap–novelty correlation | The measured intention–execution gap correlates positively with novelty rate and negatively with homeostatic efficiency; the three form a characteristic trade-off triangle | Structural core only |
| **H3** | Body autonomy is constitutive | Removing autonomous body dynamics (interaction matrix → 0) collapses novelty even when control authority is held constant | Structural core only |
| **H4** | Environmental generativity | In a static environment, novelty rate decays to ~0 as the system converges; in a drifting environment it is sustained | Structural core only |
| **H5** | Coupling plasticity | Severing a coupling channel produces (a) graceful degradation, not brittle failure, and (b) post-damage reorganization that exceeds pre-damage novelty (creative reconfiguration) | Structural core only |
| **H6** | Learning sustains growth | A learning controller (weight update > 0) sustains novelty over longer timescales than a frozen controller at equal authority | Structural core only |
| **D1** | **Self-model amplifies drive persistence** *(new, central)* | Disrupting the self-model analog (RNN) reduces the *persistence* of drives: after a perturbation, the system re-engages with its goals more slowly and for fewer cycles than without disruption. Basic correction still occurs (the cerebellum analog works); what is lost is the *sustained re-engagement*. | Structural core + self-modeling claim (§8) |
| **D2** | **Self-model amplifies flexibility under blockage** *(new)* | When the obvious action path is blocked, a system with an intact self-model generates more novel alternative strategies (measured as behavioral repertoire diversity in the 100 frames after blockage) than a system with disrupted self-model. | Structural core + self-modeling claim (§8) |
| **J1** | Free-energy inverted-U *(bridge test)* | Novelty rate is an inverted-U function of the system's aggregate drive error — its local "free energy" proxy F(t) = Σ_u error_u². Growth stalls at F→0 (equilibrium/stasis) and at F→max (incoherence) | Structural core + Vanchurin analogy |
| **J2** | Reflexivity floor *(bridge test)* | As control authority → maximum, the measured gap does NOT converge to 0; it plateaus at a positive floor G* > 0, because the controller is part of the body it controls | Structural core + Ismael bridge |
| **A1** | Self-model disruption changes report, not dynamics *(AST test)* | Disrupting the RNN increases divergence between the system's internal "report" (neuron modulation states) and its actual dynamics (matter trajectories), while leaving behavior (homeostatic performance P) unchanged or mildly degraded | Structural core + self-modeling mechanism |
| **A2** | Report correlates with dynamics more than null model | The neuron-modulation states correlate with the system's actual gap G(t) more strongly than a null model (same statistics, shuffled correlations) predicts — i.e., the "report" is not random noise but carries information about the actual negotiation | Structural core + self-modeling mechanism |
| **A3** | Self-model disruption changes fallibility pattern | After RNN disruption, the system's "report" (neuron modulation magnitudes) becomes systematically biased: over-reporting gap when actual gap is narrow (analog of delusional misattribution — the self-model generates vivid content where there is little to report) | Structural core + self-modeling + §8.3 |

**H1–H6 are testable without accepting any of Part II or the self-modeling claim.** D1 and D2 test the central amplification claim (§8.1): they require that the RNN is doing *self-modeling work* (not just motor work). J1 and J2 require the physics bridge. **A1–A3 require the self-modeling integration (§8)** but not the physics bridge.

**Important epistemic note:** The Particle Brain runs on a single substrate (GPU computation). By the theory's own criteria it cannot be conscious — there is no causal separation between "mind" and "body," only structural separation within one computation. Therefore:
- A **positive** result (predicted dynamics appear) is *necessary evidence* for the theory: if the dynamics don't even appear in a structural analog, the theory's dynamical claims are wrong. It does not prove consciousness exists in the system.
- A **negative** result (predicted dynamics absent) is *disconfirming* of the structural core.
- No result on this system can establish that anything is conscious. The vector-space clause and the single-substrate fact together forbid that inference.
- **The experiments can falsify but cannot confirm the theory's consciousness-specific claims.** They test where drive-like dynamics live in parameter space. If those dynamics are explainable by pure nonlinear dynamics (edge-of-chaos, self-organized criticality) with no self-modeling-specific content, the theory's distinctive claims are weakened even if H1–H6 hold.

---

## 18. Epistemic Boundaries and Code Changes

### The Particle Brain Mapping (commit 830907b)

| Particle system | Biological analog | Role in the theory |
|---|---|---|
| **Urges** (30) | Cerebrum (drive generation) | Generate goals and intentions; one homeostatic drive each (`driveTarget`/`driveScale`/`driveGain`); Hebbian learning on `control` |
| **Motor neurons + brain network** (80 + 8-unit RNN) | Cerebellum + Self-model | Translate intention into specific motor commands; error correction via the recurrent net (urge errors → neuron modulations). **The RNN is the self-model analog** — it feeds back on the system's own control loop, playing the structural role of a self-representation |
| **Matter particles** (~64k) | The body (muscles, joints, tissues) | Autonomous dynamics from the interaction matrix; 64k independent local agents — the "massive" component |
| **Interaction matrix** | Body's own social/physical laws | The lived constraint: the body follows rules the mind cannot override. This is where the struggle lives |
| **Friction / magnetic forces** | Inertia, compliance, unexpected curvature | Secondary pushback mechanisms (lag and deflection of commanded motion) |

The control gap in this system is specifically: **how much does matter's actual trajectory deviate from what neuron forces alone would produce?** Zero the interaction matrix and matter becomes a perfect slave to the neurons — no gap, no struggle. Keep it at full strength and the body has strong autonomous dynamics — big gap. The sweet spot is where neuron force magnitude (`urgeForce × controlMax`) is comparable to typical interaction-matrix force — which the current tuning (≈1.15× F_pair) already approximates.

### Required code changes (in priority order)

| # | Change | Effort | Enables |
|---|--------|--------|---------|
| C1 | Make `brainGain` a store parameter (currently hardcoded 1.5 in `particleComputeForces.wgsl`; add to `ElectricalOptions`) | Trivial | E1, J2, A1 |
| C2 | **Gap measurement** (CPU-side, every N frames): for each active neuron, cosine similarity between its intended force direction (sign of drive × direction to target-color centroid) and the actual mean velocity of that color's matter in region. Log `G(t) = 1 − mean\|cosSim\|` | Low | H2, J2, A2 |
| C3 | **Novelty measurement** (CPU-side): bin matter into a 16×16 grid per color; compute normalized Shannon entropy of the joint distribution; log `N(t) = \|E[t] − E[t−w]\|` over a window w. Also log homeostatic efficiency `P(t)` = fraction of urges with \|error\| < threshold | Low | H1–H4, J1, D1, D2 |
| C4 | **Neuron damage events** (CPU-side): with probability p per tick, zero a random neuron's actuation for M frames (sentinel in its `control` field, checked in the force pass) | Medium | H5 |
| C5 | **Environmental drift** (CPU-side): every N ticks, add Gaussian noise σ to interaction-matrix rule values and re-upload | Low–Med | H4 |
| C6 | **Brain weight learning** (extend `brainMutate.wgsl` or new pass): Hebbian update `W_down[i,u] += lr · h_new[i] · error[u]`, weights clamped; `brainLearningRate` store param, default 0 | Medium | H6 |
| **C7** | **RNN disruption** (CPU-side): with probability p_rnn per tick, zero the recurrent network's hidden state for M frames (the self-model analog is "blinded"). Log neuron-modulation states before/after. | Low–Med | A1, A3, D1, D2 |
| **C8** | **Drive persistence measurement** (CPU-side): after each perturbation event (damage, drift), measure the number of frames until P(t) returns to within 90% of pre-perturbation baseline. Log `T_reengage`. Compare disrupted vs. non-disrupted RNN conditions. | Low | D1 |
| **C9** | **Blockage event + repertoire diversity** (CPU-side): temporarily zero the force output of the top-3 most active neurons for 50 frames (simulating "obvious path blocked"). Measure the number of distinct behavioral patterns (via k-means clustering on matter velocity vectors) in the 100 frames after blockage. Compare disrupted vs. non-disrupted RNN. | Medium | D2 |
| **C10** | **Report-dynamics correlation** (CPU-side): every N frames, compute Pearson correlation between RNN hidden states and actual matter velocity deviations from neuron-predicted trajectories. Compare to a null model (shuffled correlations). | Low | A2 |

---

## 19. Protocols: Structural Core (H1–H6)

**E1 (H1) — Control authority sweep.** Fix all else. Sweep `urgeForce` ∈ {0, 0.05 … 1.5} and `brainGain` ∈ {0, 0.5, 1.5, 3.0}. Run each configuration ≥10k frames after a warmup. Plot novelty rate N(t) vs. authority.
- **Prediction:** inverted-U (or plateau-then-drop). Maximal novelty where neuron force ≈ interaction-matrix force; collapse at both extremes.
- **Disconfirmation:** monotonic increase in N with authority (growth likes more control), or no structure at all.
- **Caveat:** this prediction is also made by edge-of-chaos / self-organized criticality theories. H1 alone does not distinguish this theory from generic nonlinear dynamics. The distinguishing content is in H2, D1, D2, and J1.

**E2 (H2) — The trade-off triangle.** From E1's runs, plot the three logged channels G(t), N(t), P(t).
- **Prediction:** N positively correlated with G; P negatively correlated with G; and — the sharper claim — N is *not* explained by G alone: at fixed G, higher P (tighter homeostasis) suppresses N. The triangle, not a line.
- **Disconfirmation:** N correlates with G but is independent of P (then gap is sufficient, and the theory's normative/homeostatic component is doing no work).

**E3 (H3) — Body autonomy ablation.** Same authority settings; interaction matrix at full strength vs. scaled to 0.2× vs. zeroed.
- **Prediction:** novelty collapses as matrix → 0 even with constant authority. The gap is not created by the controller's weakness but by the body's independence.
- **Disconfirmation:** N survives matrix→0 (then the gap is controller-side — learned unpredictability — and the theory's body-autonomy claim is wrong).

**E4 (H4) — Environmental drift.** Static rules vs. drift σ ∈ {0.02, 0.05, 0.1} every 200 ticks.
- **Prediction:** static → N decays to ~0 (convergence to attractor); drifting → N sustained at a level scaling with σ until incoherence at high σ.
- **Disconfirmation:** N is flat across drift levels (environment generativity does no work) or N increases monotonically with σ (no incoherence ceiling).

**E5 (H5) — Coupling plasticity.** Damage events at p ∈ {0, 0.001, 0.005}/tick, M = 200 frames. Track N(t) and P(t) around each event.
- **Prediction:** graceful degradation (P dips, recovers; no threshold crash) AND a post-damage novelty *bump above* pre-damage baseline (creative reconfiguration — the asymmetric property of §5.4).
- **Disconfirmation:** monotonic decline after damage (degradation only, no creative reorganization), or catastrophic failure at any p.

**E6 (H6) — Learning vs. frozen brain.** `brainLearningRate` ∈ {0, 0.001, 0.01}, long runs (≥50k frames).
- **Prediction:** learning brain sustains N over longer timescales (the gap reopens as the brain adapts and the body drifts); frozen brain converges to a fixed repertoire.
- **Disconfirmation:** no difference between learning and frozen at any timescale (learning does no work for growth).

---

## 20. Protocols: Self-Modeling, Bridge Tests, and AST Tests

**D1 — Self-model amplifies drive persistence (central new test).**
Using C7 + C8: compare T_reengage (time to re-engage with goals after perturbation) under three conditions:
- RNN intact (p_rnn = 0)
- RNN briefly disrupted (p_rnn = 0.01, M = 50 frames per event)
- RNN persistently disrupted (p_rnn = 0.05, M = 200 frames per event)

- **Prediction:** T_reengage increases with p_rnn. The system with an intact self-model re-engages faster and more persistently after a perturbation than one with a disrupted self-model. Basic correction still occurs in all conditions (the cerebellum analog — the feedforward neuron pathway — is intact); what is lost is the *sustained re-engagement*, the "I need to keep trying" pressure.
- **Disconfirmation:** T_reengage is unchanged across p_rnn values (the RNN is not doing self-modeling work; it's doing motor work or nothing). Or: T_reengage *decreases* with disruption (disruption makes the system re-engage faster, which would be the opposite of the prediction).
- **Why this is the central test:** D1 directly tests §8.1's amplification claim. If the self-model doesn't amplify drive persistence, the theory's novel contribution (beyond generic control-gap dynamics) is in doubt.

**D2 — Self-model amplifies flexibility under blockage.**
Using C7 + C9: compare behavioral repertoire diversity (k-means cluster count on matter velocities) in the 100 frames after a blockage event, under RNN intact vs. disrupted conditions.
- **Prediction:** disrupted self-model → fewer distinct behavioral patterns after blockage (the system retries the blocked action or freezes, rather than generating novel alternatives). Intact self-model → more diverse repertoire (the "I need to find another way" drive generates exploration).
- **Disconfirmation:** no difference in repertoire diversity (flexibility under blockage is not mediated by the self-model; it's a property of the feedforward dynamics alone).

**J1 — Free-energy inverted-U (tests structural core + Vanchurin analogy).**
From C3's logging, compute F(t) = Σ_u (driveTarget_u − signal_u)² — the aggregate squared drive error, the system's local free-energy proxy. Bin runs by F-level and plot N vs. F.
- **Prediction:** inverted-U in F itself. F→0 (all drives satisfied, equilibrium) → stasis: nothing to update, no growth. F→max → incoherence: error too large for coherent negotiation. Maximal growth at intermediate F.
- **Why this is a bridge test:** the inverted-U *in free energy specifically* (rather than in some arbitrary control parameter) is what Vanchurin's near-equilibrium result suggests — dynamics are generative in the regime between equilibrium and far-from-equilibrium, with free energy as the coordinate. If N peaks at intermediate *authority* (E1) but is flat in F, the Vanchurin analogy loses its specific content even if H1 holds.
- **Disconfirmation:** N is monotonic in F, or uncorrelated with F while correlated with authority (then the free-energy coordinate has no special status; any control parameter would do).

**J2 — Reflexivity floor (tests structural core + Ismael bridge).**
Sweep `brainGain` → {3.0, 5.0, 10.0} with `urgeForce` at maximum. Measure the asymptote of G(t).
- **Prediction:** G(t) plateaus at G* > 0 rather than converging to 0. Mechanism in this system: cohesion forces act on urges/neurons too (the controller is physically part of the body); brain output changes matter, which changes what urges perceive, which changes errors, which changes brain output — Ismael's causal interference loop, made concrete.
- **Disconfirmation:** G → 0 as authority → ∞. Then the "structurally unreachable limit" (§6.6) is a practical limit in this system, and the Ismael upgrade fails dynamically here.
- **Null model:** fit a control-theoretic noise model (floor = function of sensor/actuator noise alone) to the same data. If the noise model fits as well as the self-coupling model, J2 has no content beyond engineering (counterargument C8, §23).

**A1 — Self-model disruption changes report, not dynamics (AST test).**
Using C7: disrupt the RNN hidden state at p_rnn ∈ {0, 0.01, 0.05}/tick for M = 100 frames. Track:
- Matter trajectories (actual dynamics) — should be unchanged or mildly degraded.
- Neuron-modulation states (the "report") — should diverge from pre-disruption pattern.
- Homeostatic performance P(t) — should be unchanged or mildly degraded (not collapsed).

- **Prediction:** report-dynamics divergence increases with p_rnn; behavior is robust to the disruption (the system can still act, but its "internal model" of what it's doing becomes less accurate). This is the structural analog of a patient who can still walk but whose proprioceptive self-model is corrupted.
- **Disconfirmation:** RNN disruption causes catastrophic behavioral failure (then the RNN is doing motor work, not just modeling work — the self-model and the cerebellum are not separable in this system), or report-dynamics divergence does not increase (the "report" is not a model of the dynamics).

**A2 — Report correlates with dynamics more than null model (AST test).**
Using C10: compute correlation between RNN hidden states and actual gap G(t). Compare to null model (shuffle the temporal alignment of RNN states vs. G(t), 10k permutations).
- **Prediction:** true correlation significantly exceeds null distribution (p < 0.001). The "report" carries information about the actual negotiation that is not present in a shuffled version.
- **Disconfirmation:** true correlation indistinguishable from null (the RNN states are not a model of the gap; they are doing something else entirely, or nothing at all).

**A3 — Self-model disruption changes fallibility pattern (AST + squirrel test).**
From A1's runs: during RNN disruption, does the system's "report" (neuron modulation magnitudes) become systematically biased? Specifically: does it over-report gap when actual gap is narrow (analog of delusional misattribution — the self-model generates vivid content where there is little to report)?
- **Prediction:** under disruption, neuron-modulation magnitudes increase in domains where actual G(t) is low (over-reporting), while being roughly accurate where G(t) is high. The bias is asymmetric: over-reporting in quiet domains, not under-reporting in active ones. This mirrors the delusional-zoopathy pattern: the self-model generates specific, vivid content where there is little to report.
- **Disconfirmation:** disruption produces uniform noise (no systematic bias direction), or under-reporting rather than over-reporting.

**Separation of concerns, summarized:**

| Result pattern | Interpretation |
|---|---|
| H1–H6 hold; D1, D2 hold; J1, J2 hold; A1–A3 hold | Full theory supported: structure + self-modeling amplification + physics analogy |
| H1–H6 hold; D1/D2 fail; A1–A3 hold | Structural core + self-model mechanism stand; but the *amplification* claim (§8.1) is not supported in this system. The RNN models but doesn't amplify drives. Theory needs a different amplification mechanism or higher complexity |
| H1–H6 hold; D1/D2 hold; J1/J2 fail | Structural core + self-modeling stand; the specific free-energy coordinate or dynamic floor is not what Vanchurin/Ismael suggest. Bridge demoted to naming coincidence |
| H1–H6 hold; A1–A3 fail | Structural core stands; the RNN is not functioning as a self-model in this system. Self-modeling integration needs a different implementation |
| H1–H6 fail | Structural core disconfirmed, regardless of other parts |
| H3 fails (novelty survives matrix→0) | The gap is controller-side (learned unpredictability), not body-side — a different theory than this one |

---

## 21. Falsification Conditions (Stated Upfront)

The theory is **falsified** if, in systems instantiating the structural properties:
1. Novelty generation is monotonic in control authority (no intermediate optimum) — kills H1 and with it the central claim about where dynamics live.
2. Novelty rate is uncorrelated with the measured intention–execution gap across a wide parameter range — kills H2 and the identification of *where* novelty lives.
3. Coupling severance produces only brittle failure or monotonic decline, never creative reconfiguration above baseline — kills H5 and coupling plasticity as a defining property.
4. The gap provably closes (G → 0) under maximum authority in a self-coupled system — kills J2 and downgrades §6.6 to an engineering limit.
5. **Self-model disruption does NOT reduce drive persistence (D1 fails) AND does NOT reduce flexibility under blockage (D2 fails)** — then the amplification claim (§8.1) is wrong: self-modeling does not make drives stronger. The theory reduces to a generic control-gap dynamics account with no self-modeling-specific content.
6. RNN disruption produces no report-dynamics dissociation (A1 fails) AND the RNN is not doing motor work either — then the "self-model analog" is not instantiated in this system, and the self-modeling integration (§8) has no experimental foothold here.

The theory is **not** falsified by:
- The existence of complex behavior in systems without these properties (the claim is about where novelty *grows*, not that nothing else can be complex).
- Any argument from the hard problem (the theory concedes it does not explain why experience exists — §23, C6; and the reframing in Part III explains the *belief*, not the existence).
- The finding that edge-of-chaos dynamics can explain H1 alone (this is expected; the theory's distinctive content is in H2, D1, D2, J1, and A1–A3).
- The finding that the RNN in the particle brain is doing motor work as well as modeling work (this would be a finding about the implementation: it means the self-model and cerebellum are not separable at this level of complexity, which is a prediction about minimum complexity for self-model independence).

---

---

# Part V — Open Questions

*These are not claims; they are flagged boundaries where the theory does not yet have an answer.*

## 22. Unresolved

1. **Embodiment threshold.** At what level of structural complexity does "somatic coupling as lived constraint" become sufficient for drive generation, rather than merely necessary? The particle brain instantiates the structure but (by the theory's own criteria) is not conscious. What additional conditions — if any — are required beyond structure for *consciousness* specifically (as opposed to drives, which may be present at lower complexity)?

2. **Gradualism.** Is drive generation continuous (more gap → more drive, smoothly) or does it have thresholds (below X complexity, no persistent drives; above X, something)? The vector-space clause forbids ranking, but it does not forbid asking whether there is a *phase transition* in the structural requirements for self-modeling.

3. **Field of separations.** The theory describes one gap (mind ↔ body). But a complex system has many gaps: between subsystems, between timescales, between self and environment. Is drive generation the sum of all gaps? The product? Some other combination? The cerebrum/cerebellum example (§7) suggests domain-specificity, but the aggregation rule is unspecified.

4. **Empirical testability in biology.** The particle brain tests the structural claims. But can H1–H6, D1–D2 be tested in a biological system? The cerebellar-damage case (§7) is suggestive but not controlled. A proper test of D1 would require: temporarily disrupting the self-model (e.g., via TMS to prefrontal cortex) and measuring whether drive persistence (time to re-engage with a goal after interruption) decreases, while basic motor correction is preserved. This may be feasible in human subjects (TMS + goal-pursuit task) but has not yet been done.

5. **The hard problem remains.** Stated again (per discipline rule): the reframing in Part III explains the *belief* in consciousness. It does not explain why there is something it is like at all. This is conceded, not hidden. The theory's scope is: necessary conditions + generative mechanism for drives + explanation of the self-report. The existence of experience itself is outside its claims.

6. **Generativity threshold.** §6 distinguishes "correcting in the gap" (sustaining) from "generating novel solutions in the gap" (generating). At what point does a system cross from correcting to generating? Is there a minimum timescale, complexity, or novelty rate below which the gap corrects but does not generate? The particle brain's E1/E4 experiments may probe this, but the theoretical boundary is not yet sharp.

7. **Social dimension.** Graziano's AST emphasizes that the self-model is *socially extended*: the same circuits model one's own consciousness and attribute it to others. This theory's structural core is individual (one system, one gap). How does multi-agent coupling change the generative dynamics? Do two coupled systems generate more novelty than either alone? Does a social self-model ("I am in relation with you") amplify drives beyond an individual self-model ("I am here")? The particle brain supports multi-agent configurations but this is not yet formalized.

8. **Technology question.** §6.5 says technology narrows gaps in the domains it affects. But what about technology that *creates new gaps* (e.g., a prosthetic that introduces novel dynamics the user must learn to negotiate with)? Is the net effect on drive generation positive or negative? The theory predicts: positive, if the new gap is genuinely open (the body has autonomous dynamics the user cannot fully control); neutral or negative, if the technology is fully compensated.

9. **Self-model complexity and belief.** At what level of self-model sophistication does a self-report become "a belief in consciousness" rather than merely a correlation? The particle brain's RNN is 8 units — far below any threshold for "belief." Is there a minimum self-model complexity below which the system has dynamics but no report, and above which it has both? A1–A3 test whether the distinction exists at all in this system; they do not yet identify the threshold.

10. **Measurability of self-report fallibility.** Can we measure, in the particle brain, whether the "report" (neuron states) is *fallible* in the specific way the squirrel case predicts (over-reporting in quiet domains)? A3 attempts this, but the statistical power may be insufficient at 8 RNN units. This is an open methodological question.

11. **The self-preservation boundary.** §9 argues that self-preservation as a *drive* requires a self-model. But at what complexity does reflexive self-preservation (startle, withdrawal) transition to motivational self-preservation ("I will not die")? Is this a phase transition or a smooth gradient? Can it be tested in the particle brain (does disrupting the RNN reduce the system's "re-engagement" after near-death events — i.e., large perturbations that threaten homeostatic collapse)?

---

---

# Part VI — Counterarguments (Steelmanned)

## 23. Objections and Responses

**C1. Multiple realizability / functionalism.** "If two systems are functionally isomorphic they have the same properties, substrate irrelevant."
*Response:* §3. Function is the full behavioral envelope including damage-response profiles; different substrates cannot be isomorphic in that strong sense (axe test). The objection dissolves rather than being rebutted: it assumes a notion of function (I/O mapping only) that the theory rejects.

**C2. "You've redefined consciousness as unpredictability."** "Your 'drive generation' is just dynamical complexity; your theory is trivially true of any chaotic system and says nothing about experience or motivation."
*Response:* This is the strongest objection to the structural core, and it deserves a direct answer. The theory never claims its measurements are *sufficient* for consciousness — only that the structural conditions are necessary. But more importantly, the theory's distinctive content is NOT H1 (inverted-U in novelty vs. authority), which edge-of-chaos does predict. The distinctive claims are:
- **D1/D2**: self-modeling *amplifies* drive persistence and flexibility. Edge-of-chaos does not predict this; it makes no reference to self-modeling.
- **H2**: the *triangle* (gap × novelty × homeostatic performance), where the normative variable P does independent work.
- **J1**: inverted-U in *free energy specifically*, not in an arbitrary control parameter.

If D1/D2 fail, the theory reduces to edge-of-chaos with a phenomenological gloss. This is stated honestly: the amplification claim (§8.1) is the theory's novel contribution, and it is what D1/D2 test. If those experiments show no self-modeling-specific effect, the theory has been falsified in its distinctive content, and that is a result worth reporting.

**C3. Edge-of-chaos / self-organized criticality already predicts inverted-U complexity.** "Complexity peaks at intermediate control in generic nonlinear systems (e.g., Bak–Sneppen, Langton's λ). Your H1 prediction needs no consciousness."
*Response:* Conceded for H1 alone. That is why H1 is not the theory's distinctive claim. The sharper claims (D1, D2, H2, J1) are what distinguish this theory from generic nonlinear dynamics. If E2 shows P doing no work beyond G, and D1/D2 show no self-modeling effect, then yes — the theory reduces to edge-of-chaos. That is a falsification of its distinctive content, stated here rather than hidden.

**C4. Vanchurin's result is a formal analogy with no new empirical content.** "He reproduces known physics as limits; that's reinterpretation, not discovery. The ontology is unproven."
*Response:* Agreed on status — which is why Part II is labeled speculative and presented as *analogy*, not identity. The theory borrows only the *structure* (two DOF classes, slow/fast, stochastic dynamics, free energy as the connecting quantity). Even if Vanchurin's universe-NN ontology is wrong, J1 remains a well-defined empirical test of whether novelty organizes around aggregate drive error. If J1 fails, the bridge is demoted to naming coincidence; nothing else breaks.

**C5. Ismael shows the determinism framing is a category error; she does not show experience arises from interference.** "The gap floor argument is about knowledge and representation, not phenomenology."
*Response:* Correct — that is why J2 is framed as testing the *dynamic* consequence (does G plateau above 0?) rather than making a phenomenological claim. The bridge's job is to upgrade §6.6 from "practically unreachable" to "logically unreachable for self-representing systems," and to supply the mechanism (causal interference) that the particle brain can instantiate concretely. Whether experience *requires* the gap remains the hard problem, conceded in C6.

**C6. The hard problem.** "You've described where a process occurs; you haven't explained why there is something it is like."
*Response:* Conceded in full. **The theory does not explain why experience exists.** What Part III adds is a positive account of *the belief in consciousness*: the self-model generates a report, and the report is experienced as reality. This explains why we are so certain, without explaining why there is something it is like to be certain. The reframing changes the question from "is there consciousness?" to "why do we believe there is?" — but it does not answer the first question. **Stated a second time per discipline rule: the theory explains the belief in consciousness; it does not explain the existence of experience.** This is a limitation shared by all naturalistic theories of consciousness (IIT, GWT, AST included), stated here so the theory's scope is never oversold.

**C7. Panpsychism worry.** "If the universe has the mind-body structure, doesn't everything — rocks, galaxies — become conscious?"
*Response:* No. The theory says the *generative structure* of drives (gap + negotiation + self-modeling) appears at multiple scales; it does not say there is "something it is like" to be a galaxy. Whether experience requires additional conditions (complexity thresholds, self-modeling sophistication, integrated dynamics — see open questions §22) is outside the theory's claims. The vector-space clause forbids scalar ranking, and no panpsychist inference follows from structural similarity alone. **Additionally: AST is explicitly not panpsychist.** The attention schema is a brain process — a specific neural implementation of self-modeling. It does not attribute consciousness to matter generally; it attributes the *report* of consciousness to a specific modeling mechanism that happens to be in brains. A rock has no self-model, no gap being negotiated, no report being generated.

**C8. "The control gap can't close" may be trivially true of any finite system.** "Every real controller has noise, delay, and bounded precision; your J2 prediction is guaranteed by engineering, not deep structure."
*Response:* Partially fair — a noisy controller will always leave residual error. The non-trivial content of J2 is in the *form* of the asymptote: a floor set by the system's own self-coupling (cohesion acting on the controller; feedback through perception) rather than by exogenous noise. A control-theoretic null model (floor = function of sensor/actuator noise alone) can be fit to the same data and compared; if the noise model fits as well, J2 has no content beyond engineering. This is the cleanest way to keep J2 honest.

**C9. The self-model amplification claim (D1/D2) is unfalsifiable in principle because "drive persistence" is not well-defined.** "You define drive operationally (§6.1) but the operational definition has four criteria (persistence, modulation, flexibility, reactivation). Any one of them could fail for reasons unrelated to self-modeling."
*Response:* Fair. The operational definition is a *cluster*: all four properties are expected to be amplified by self-modeling, but they may not be amplified uniformly. D1 tests persistence specifically (T_reengage); D2 tests flexibility specifically (repertoire diversity after blockage). If D1 fails but D2 holds (or vice versa), the amplification claim is partially supported and the theory needs refinement: self-modeling may amplify *some* aspects of drive character but not others. This is a finding, not a falsification — it means the amplification is domain-specific rather than uniform. The full falsification condition is: D1 AND D2 both fail (no aspect of drive character is amplified by self-modeling).

**C10. AST + this theory is circular: you use a model-of-self to explain experience, but the model itself is experienced.** "If consciousness IS the attention schema (Graziano), and the attention schema is a model that is itself experienced as consciousness, then you're explaining consciousness with consciousness."
*Response:* This is the strongest objection to the AST integration. The circularity charge assumes that "experienced" means "conscious in the full sense the theory is trying to explain." But the theory's claim is more modest: the self-model is a *neural model* — a specific pattern of activity that represents the state of attention/drives. It is "experienced" only in the weak sense that it is the content of first-person reports. The question "why is there something it is like to have this model?" is exactly the hard problem, which the theory concedes (C6). What the theory claims is: *given* that there is something it is like, the *content* of that something is determined by the self-model. The self-model doesn't explain why experience exists; it explains what experience is *about*. The circularity dissolves once you separate "why is there experience?" (unanswered) from "what does the experience consist of?" (the self-model's report on drive generation).

**C11. The squirrel case shows self-models can be wrong — why trust the self-model's report that consciousness exists at all?** "If the same machinery that tells me 'I am conscious' can tell a patient 'there is a squirrel in my head,' then maybe my belief in consciousness is just another delusion."
*Response:* This objection, taken seriously, becomes a *feature* of the theory rather than a bug. The theory predicts that the belief in consciousness should be **fallible and confabulatory** exactly like other self-models. And it is: people systematically misreport what they were attending to (inattentional blindness, change blindness); the felt sense of "deciding" is post-hoc confabulation (readiness potential literature, §14.2); meta-cognitive reports are modifiable by TMS over prefrontal cortex without changing primary perception. The belief in consciousness has the same reliability profile as other self-models: usually well-calibrated, sometimes wrong, always a model output rather than direct observation.

But this does not make the belief *false*. The self-model's report of "I am conscious" is calibrated because there really is ongoing attention, there really is a gap being negotiated, and there really are drives being generated. The squirrel patient's belief is uncalibrated because there is no squirrel. The structural difference: the self-model has a *real referent* (ongoing drive generation in an open gap); the delusional model does not. The theory predicts — and this is testable (A1, A3) — that the report should track the dynamics more accurately than a null model, even while being fallible.

**C12. "The self-model is just another word for 'global workspace' or 'higher-order thought.' You've repackaged an old theory."**
*Response:* Partially fair at the level of informal description. AST does share features with GNWT (broadcasting, global availability) and HOTT (higher-order representation). But Schurger & Graziano (2022) argue that AST differs in a specific way: it explains *why we believe* we are conscious, not just what neural activity correlates with consciousness. This theory adds a further step: the self-model's content is determined by the control gap, and the gap's dynamics are generative for drives. The combination (gap + self-model + drive amplification) is not reducible to any single prior theory. And critically: the theory does not depend on AST specifically. It depends on the *structural role* of a self-model (§8.1), which could be implemented by GNWT, HOTT, or some other mechanism. The amplification claim (D1/D2) is mechanism-independent.

**C13. The self-preservation argument (§9) is question-begging: you define "self-preservation as a drive" in a way that requires a self-model, then conclude that self-preservation requires a self-model.**
*Response:* Partially fair. The argument in §9.3 is structural, not empirical: it says that the *operational properties* of motivational self-persistence (temporal continuity, flexibility, reactivation — §6.1) require a model of the self as a persistent entity. This is analogous to saying "navigation requires a map": you could argue that "navigation" is defined in a way that includes maps, but the point is that *without* a map, you have reflexive movement (turn away from threat) rather than *navigation* (sustained, flexible, goal-directed movement through a changing environment). The distinction between reflexive and motivational self-preservation is doing the work, not the definition. If someone can demonstrate a system with persistent, flexible, reactive self-preservation that has NO self-model (no representation of itself as a persistent entity), that would falsify §9. No such system is currently known.

---

---

# Part VII — Asides (Speculative; Not Part of the Testable Core)

*Everything below is explicitly separated from Parts I–VI. It does not bear on any experiment, and rejecting all of it leaves the theory intact. It is included because the structural results of Part II, taken together, point somewhere, and this document would be incomplete if it refused to say where.*

## 24. What the Structure Points Toward

**A1. The universe as self-representation.** If Vanchurin's two-class DOF split is even approximately right — slow trainable structure governing fast hidden states — and Ismael is right that any system representing itself contains the representor within the represented, then:

> The universe is a system that represents itself. In that self-representation, there is an irreducible gap (because the representor is part of the represented). In that gap, something grows (because the interference between representation and reality generates novelty — new weight configurations, new state patterns, new emergent structures).

We are not in the universe observing it. We are the universe representing itself at a particular scale, with a particular coupling topology. The control gap we experience — intention negotiating with body — is a local instance of the universal negotiation between structure and state.

**A2. What it is like to be the universe.** If §6.8's table is taken seriously — life, drives, and consciousness as the same open process that refuses equilibrium — then "what the universe is like to be itself" is not a single experience but the total field of all control gaps across all scales: quark to galaxy, every mind-body negotiation simultaneously, each one a small site where something new grows. No scalar ranking among them (vector-space clause, at cosmic scale). The universe is not conscious *as a whole* in any simple sense; it is the sum of everywhere drive generation happens.

**A3. Free will as a felt gap.** Ismael quotes William James: "the possibilities are really *here* … the issue is decided nowhere else than *here and now*." In this theory's vocabulary, that felt openness — the experience that the scales of fate are still quivering — is the felt sense of a control gap that has not yet closed. Free will is not magic breaking the causal chain; it is the lived constraint from the inside: the knowledge, always slightly ahead of the body, that what happens next depends on the negotiation that is happening *right now*, in this gap, between what I intend and what my body can actually do. The past prepares us; the gap decides.

**A4. Death and stasis.** Thermodynamic equilibrium is death for life; full control is death for drive generation. Both are the same event seen from different scales: a closed system reaching rest. Life and mind are the universe's two known ways of refusing to settle — metabolism in the body, negotiation in the gap.

**A5. The universe's self-model (new).** If the universe has a self-model at its fundamental level (Vanchurin's trainable variables modeling the hidden-variable dynamics; Ismael's representor-within-represented), then "what the universe is like to be itself" is the universe's own report — and we, reading physics, are reading *its* self-model, not the thing itself.

This is the cosmological version of the squirrel case: just as the delusional patient's brain generates a vivid report about internal activity that may or may not be calibrated, the universe (if it has a self-model) generates a report about its own state — and physics is our access to that report, not to the raw state. We cannot step outside the universe's self-model to check whether it is accurate. We can only note that the report is internally consistent, generative, and (so far) predictive — which is the same evidence we have for any self-model, including our own.

The implication: the "hard problem" at the cosmic scale is identical to the hard problem at the personal scale. Why is there something it is like to be the universe? Answer: we don't know. But why do we *believe* there is? Answer: because the universe's self-model (if it exists) generates a report, and we are inside that report. The squirrel case generalizes: the contents of any self-model — personal or cosmic — are inferences that can be misattributed, and our certainty about them is a product of the model, not a window onto reality.

*Label: asides-tier. None of this is required for Parts I–VI. Rejecting all of it changes nothing in the testable core.*

---

---

# References

## Part I — Structural core

1. Varela, F. J., Thompson, E., & Rosch, E. (1991). *The Embodied Mind: Cognitive Science and Human Experience*. MIT Press. https://mitpress.mit.edu/9780262011745/the-embodied-mind/
2. Di Paolo, E. A., Rohde, M., & De Jaegher, H. (2007). Horizons for the enactive mind: Values, emotions, plans, and sociality. In *From Animal Skills to Human Languages* (pp. 51–86). OUP. https://www.sussex.ac.uk/informatics/cogslib/reports/csrp/csrp587.pdf
3. Maturana, H. R., & Varela, F. J. (1980). *Autopoiesis and Cognition*. D. Reidel. https://mitpress.mit.edu/9780262504324/autopoiesis-and-cognition/
4. Pfeifer, R., & Iida, F. (2005). Morphological computation: connecting body, brain, and world. *IEEE/RAS Int'l Conf. on Humanoid Robots*. https://people.csail.mit.edu/iida/papers/pfeifer_iida_JSM05.pdf
5. Pfeifer, R., & Bongard, J. (2007). *How the Body Shapes the Way We Think*. MIT Press. https://mitpress.mit.edu/9780262121505/how-the-body-shapes-the-way-we-think/
6. Merleau-Ponty, M. (1945). *Phénoménologie de la perception*. Gallimard. (Eng. trans. 1962.) https://plato.stanford.edu/entries/merleau-ponty/
7. Searle, J. R. (1980). Minds, brains, and programs. *Behavioral and Brain Sciences*, 3(3), 417–424. https://plato.stanford.edu/entries/chinese-room/
8. Block, D. (1995). On what is it like to be a bat? *Philosophical Review*, 104(2), 159–182. https://plato.stanford.edu/entries/consciousness/
9. Shadmehr, R., & Krakauer, J. W. (2008). A computational model of sensorimotor adaptation. *Annual Review of Neuroscience*, 31, 97–119. https://www.annualreviews.org/doi/10.1146/annurev.neuro.31.061306.103228
10. Baker, J. M., & Ivry, R. B. (2007). The cerebellum generates model-based predictions of near-future states. *Cerebellum*, 6(3), 185–195. https://link.springer.com/article/10.1007/s12311-007-0025-9
11. Smith, M. A., Shadmehr, R., & Mistretta, C. P. (2006). Functional subdivisions of the cerebellum. *Cerebellum*, 5(4), 204–213. https://link.springer.com/article/10.1007/s12311-006-0015-8
12. Friston, K. (2010). The free-energy principle: a unified brain theory? *Nature Reviews Neuroscience*, 11(2), 127–138. https://www.nature.com/articles/nrn2787

## Part I — Self-modeling and drive amplification (§8)

13. Graziano, M. S. A., & Kastner, S. (2011). Attention is consciousness. *Trends in Cognitive Sciences*, 15(2), 76–84. https://www.cell.com/trends/cognitive-sciences/abstract/S1364-6613(10)00378-9
14. Graziano, M. S. A. (2013). *Consciousness and the Social Brain*. Oxford University Press. ISBN 978-0-19-992864-4. https://books.google.com/books/about/Consciousness_and_the_Social_Brain.html?id=8dMdAAAAQBAJ
15. Graziano, M. S. A., & Webb, T. J. (2014). The attention schema theory: a mechanistic account of subjective awareness. *Frontiers in Psychology*, 5, 430. https://pmc.ncbi.nlm.nih.gov/articles/PMC4407481/
16. Bora, K., Bhuyan, T., & Boro, D. (2020). Cats inside my head! – A case report on delusional zoopathy. *International Journal of Scientific and Research Publications*, 10(6), 558–560. http://dx.doi.org/10.29322/IJSRP.10.06.2020.p10267
17. Mitra, S., Mishra, A., Anwar, Z., & Lavania, S. (2017). Cannabis and delusional zoopathy: A mole that ran amok. *Asian Journal of Psychiatry*, 30, 35–36. https://doi.org/10.1016/j.ajp.2017.01.016
18. Alam, S., Nath, S., & Sinha, V. (2015). "Worm crawling inside my brain": a rare case of delusional parasitosis. *Open Journal of Psychiatry & Allied Sciences*, 6(2), 149.

## Part II — Physics & cognition bridge

19. Vanchurin, V. (2020). The world as a neural network. *Entropy*, 22(11), 1210. https://arxiv.org/abs/2008.01540 | https://www.mdpi.com/1099-4300/22/11/1210
20. Vanchurin, V. (2020). The World as a Neural Network — EISM lecture walkthrough. https://neuralcosmology.com/en/lectures/vanchurin-world-as-neural-network-2020
21. Ismael, J. (2016). *How Physics Makes Us Free*. OUP. https://academic.oup.com/book/4740
22. Ismael, J. (2025). A Participatory Universe in the Realist Mode: On the Separation of Observational and Agentive Perspectives in Classical and Quantum Mechanics. *Foundations of Physics*, 55, 35. https://link.springer.com/article/10.1007/s10701-025-00843-4
23. Ismael, J. Free Will (commissioned essay). *Times Literary Supplement*. https://www.jenanni.com/papers/FreeWill,TLS.pdf
24. Ismael, J. (2024). Passage, flow, and the logic of temporal perspectives. *Journal of Consciousness Studies* (special issue: Beyond the View from Nowhere). https://www.tandfonline.com/doi/full/10.1080/24740500.2024.2526896
25. Schurger, A., & Graziano, M. (2022). Consciousness explained or described? *Neuroscience of Consciousness*, 2022(1), niac001. https://academic.oup.com/nc/article/2022/1/niac001/6523097
26. Schurger, A. (2018). Specific relationship between the shape of the readiness potential, subjective decision time, and waiting time predicted by an accumulator model with temporally autocorrelated input noise. *eNeuro*, 5(1), ENEURO.0302-17.2018. https://www.eneuro.org/content/5/1/ENEURO.0302-17.2018
27. Schurger, A., Mylopoulos, M., & Rosenthal, D. (2016). Neural antecedents of spontaneous self-initiated movement: A new perspective. *Trends in Cognitive Sciences*, 20(2), 77–79. https://www.cell.com/trends/cognitive-sciences/fulltext/S1364-6613(15)00279-X
28. Schurger, A., & Uithol, S. (2015). Nowhere and everywhere: The causal origin of voluntary action. *Review of Philosophy and Psychology*, 6(4), 761–778. https://link.springer.com/article/10.1007/s13164-014-0223-2
29. Schurger, A., Roskies, A., Pak, J., & Hu, B. (2021). What is the readiness potential? *Trends in Cognitive Sciences*, 25(7), 558–570. https://www.cell.com/trends/cognitive-sciences/fulltext/S1364-6613(21)00093-0
30. Dominik, T., Mele, A., Schurger, A., & Maoz, U. (2024). Libet's legacy: A primer to the neuroscience of volition. *Neuroscience & Biobehavioral Reviews*, 157, 105503. https://www.sciencedirect.com/science/article/abs/pii/S0149763423004724

## Part IV — Implementation

31. Pickover, C. A., & Heppenstall, A. (2014). *Particle Life: A New Slant on Life Itself*. Princeton UP. https://press.princeton.edu/books/paperback/9780691159342/particle-life
32. Couzin, I. D., et al. (2002). Collective memory and spatial sorting in animal groups. *J. Exp. Biol.*, 205(3), 341–347. https://www.journals.ash.org/jeb/article/205/3/341/102964
33. arXiv:2312.07547 (2023). Active Inference and Intentional Behaviour. https://arxiv.org/abs/2312.07547
34. SandboxScience, commit 830907b — Particle Brain app (urges, neurons, brain network, magnetic forces). Local repository: `SandboxScience`.

## Part III — Hard-problem reframing (supporting)

35. Levine, J. (1983). Materialism and qualia. *The Philosophical Review*, 92(1), 1–19. https://plato.stanford.edu/entries/explanatory-gap/
36. Chalmers, D. J. (1996). *The Conscious Mind: In Search of a Fundamental Theory*. OUP.
37. Metzinger, T. (2009). *The Ego Tunnel: The Science of the Mind*. Basic Books.
38. Mack, A., & Rock, I. (1998). *Inattentional Blindness*. MIT Press.
39. Simons, D. J., & Levin, D. T. (1997). Change blindness. *Trends in Cognitive Sciences*, 1(7), 261–267.

---

## References (Plain Text)

Varela FJ, Thompson E, Rosch E. The Embodied Mind. MIT Press, 1991.
Di Paolo EA, Rohde M, De Jaegher H. Horizons for the enactive mind. In: From Animal Skills to Human Languages. OUP, 2007.
Maturana HR, Varela FJ. Autopoiesis and Cognition. D Reidel, 1980.
Pfeifer R, Iida F. Morphological computation. IEEE/RAS HCRAO, 2005.
Pfeifer R, Bongard J. How the Body Shapes the Way We Think. MIT Press, 2007.
Merleau-Ponty M. Phénoménologie de la perception. Gallimard, 1945.
Searle JR. Minds, brains, and programs. Behav Brain Sci. 1980;3(3):417-424.
Block D. On what is it like to be a bat? Phil Rev. 1995;104(2):159-182.
Shadmehr R, Krakauer JW. A computational model of sensorimotor adaptation. Annu Rev Neurosci. 2008;31:97-119.
Baker JM, Ivry RB. The cerebellum generates model-based predictions. Cerebellum. 2007;6(3):185-195.
Smith MA, Shadmehr R, Mistretta CP. Functional subdivisions of the cerebellum. Cerebellum. 2006;5(4):204-213.
Friston K. The free-energy principle. Nat Rev Neurosci. 2010;11(2):127-138.
Graziano MSA, Kastner S. Attention is consciousness. Trends Cogn Sci. 2011;15(2):76-84.
Graziano MSA. Consciousness and the Social Brain. Oxford University Press, 2013.
Graziano MSA, Webb TJ. The attention schema theory. Front Psychol. 2014;5:430.
Bora K, Bhuyan T, Boro D. Cats inside my head! IJSRP. 2020;10(6):558-560.
Mitra S, Mishra A, Anwar Z, Lavania S. Cannabis and delusional zoopathy. Asian J Psychiatry. 2017;30:35-36.
Alam S, Nath S, Sinha V. Worm crawling inside my brain. Open J Psychiatry Allied Sci. 2015;6(2):149.
Vanchurin V. The world as a neural network. Entropy. 2020;22(11):1210.
Ismael J. How Physics Makes Us Free. OUP, 2016.
Ismael J. A Participatory Universe in the Realist Mode. Found Phys. 2025;55:35.
Ismael J. Free Will. Times Literary Supplement.
Ismael J. Passage, flow, and the logic of temporal perspectives. J Consciousness Studies. 2024.
Schurger A, Graziano M. Consciousness explained or described? Neurosci Conscious. 2022;2022(1):niac001.
Schurger A. Specific relationship between the shape of the readiness potential... eNeuro. 2018;5(1).
Schurger A, Mylopoulos M, Rosenthal D. Neural antecedents of spontaneous self-initiated movement. Trends Cogn Sci. 2016;20(2):77-79.
Schurger A, Uithol S. Nowhere and everywhere. Rev Philos Psychol. 2015;6(4):761-778.
Schurger A, Roskies A, Pak J, Hu B. What is the readiness potential? Trends Cogn Sci. 2021;25(7):558-570.
Dominik T, Mele A, Schurger A, Maoz U. Libet's legacy. Neurosci Biobehav Rev. 2024;157:105503.
Pickover CA, Heppenstall A. Particle Life. Princeton UP, 2014.
Couzin ID, et al. Collective memory and spatial sorting. J Exp Biol. 2002;205(3):341-347.
Levine J. Materialism and qualia. Phil Rev. 1983;92(1):1-19.
Chalmers DJ. The Conscious Mind. OUP, 1996.
Metzinger T. The Ego Tunnel. Basic Books, 2009.
Mack A, Rock I. Inattentional Blindness. MIT Press, 1998.
Simons DJ, Levin DT. Change blindness. Trends Cogn Sci. 1997;1(7):261-267.

---

*End of document v2. Paper A (`somatic-coupling.md`) and v1 (`somatic-coupling-final.md`) are preserved untouched as history.*
