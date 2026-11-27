# Somatic Coupling, the Attention Schema, and Why We Believe We Are Conscious
## A Unified Theory of Embodied Consciousness, Its Formal Bridge to Physics, and Its Experimental Consequences

*Polished working paper. Part I is the testable structural core. Part II is a formal bridge to physics and cognition (speculative but mathematical). Part III is a new reframing chapter on the hard problem. Part IV is the experimental design. Parts V–VII are explicitly separated from the testable core.*

---

## How to Read This Document

| Part | Status | What it claims |
|------|--------|----------------|
| **I. Structural core** (§1–10) | Testable in principle; several predictions testable now in Particle Brain | Consciousness grows in the control gap between decision and execution, under specific structural conditions; the attention schema is the mechanism by which a system reports on its own negotiation |
| **II. Physics & cognition bridge** (§11–13) | Speculative but mathematical; not required for Part IV's minimal experiments | The same two-class degrees-of-freedom structure appears in Vanchurin's universe-as-neural-network, Ismael's participatory realism, and Schurger's formal Bayesian account of the attention schema |
| **III. The hard-problem reframing** (§14) | A positive argument about the *belief* in consciousness; not a solution to the existence question | We are not directly conscious of raw experience; we are conscious of the brain's report — the attention schema — and the squirrel case shows this report can misattribute its contents |
| **IV. Experimental design** (§15–20) | Concrete, falsifiable protocols on the Particle Brain (commit 830907b) | What to measure, what to sweep, what would count as disconfirmation — including new AST-prediction experiments |
| **V. Open questions** (§21) | Unresolved; flagged for future work | Where the theory's boundaries are and what it cannot yet say |
| **VI. Counterarguments** (§22) | Steelmanned objections and responses | Where the theory is weakest, including new objections specific to AST integration |
| **VII. Asides** (§23) | Mystical/speculative; NOT part of the testable core; labeled as such | What the universe might be like to be itself |

The document is written so that a reader who rejects everything in Parts II and VII still has a complete, falsifiable theory in Parts I and IV. Part III is a reframing, not a load-bearing claim: it changes how we ask the question without requiring acceptance of any speculative bridge.

---

## Abstract

Consciousness is not a property a system has; it is a process that grows in the gap between what a system intends and what its body can actually do. This paper unifies three previously separate threads — somatic coupling as lived constraint, attention schema theory (Graziano), and Schurger & Graziano's formal argument that consciousness theories should explain *why we believe* we are conscious rather than trying to explain experience itself — into a single falsifiable framework. The central claim: the control gap between decision and execution is the generative pressure that produces new conscious content; the attention schema is the mechanism by which a system reports on its own negotiation within that gap; and our unshakeable certainty of being conscious is not direct access to raw experience but the continuous output of this self-reporting machinery, experienced as reality. The "squirrel in the brain" case — a patient who genuinely believed an animal lived inside his head — demonstrates that the same schema-driven machinery can misattribute its contents, which means our belief in our own consciousness is fallible and confabulatory exactly like other self-models. This reframes the hard problem from *"is there consciousness?"* into ***"this is why we believe so strongly that we are conscious."*** The paper states explicit hypotheses (H1–H6, J1–J2, A1–A3) with disconfirmation conditions, specifies concrete experiments on a GPU particle-brain system, and maps the formal bridge to free-energy principles (Vanchurin, Friston, Schurger) such that the control gap variable connects cosmological, action-theoretic, and consciousness-reporting roles of the same quantity.

---

---

# Part I — The Structural Core (Testable)

## 1. Core Premises

### 1.1 Intelligence and consciousness are distinct properties

Intelligence is the capacity to process information, reason, plan, and solve problems. It can be disembodied: a digital computer or a lookup table can exhibit intelligence without being conscious.

Consciousness is the property of having something it is like to be a system. It requires embodiment in a specific structural sense (§5), and specifically requires the *generative* conditions described in §6.

These are independent axes. A system can be maximally intelligent and entirely unconscious (a supercomputer). This distinction is supported by Block's absent qualia argument ([1995](https://plato.stanford.edu/entries/consciousness/)) and Searle's Chinese Room ([1980](https://plato.stanford.edu/entries/chinese-room/)), both of which separate cognitive capacity from phenomenal experience.

### 1.2 Embodiment is structural, not incidental

Embodiment does not mean "having a body" in the trivial sense. It means:

> Being made of connected parts that are physically disjoint and in motion — or equivalently, any system with the same level of degrees of action, options, and rails (constrained degrees of freedom) as such a system.

The relevant mathematical structure is that of a **multibody constrained mechanical system**: components linked by constraints defining a configuration space (a manifold), with dynamics governed by variational principles on that manifold. "Rails" = constraint forces; "options" = degrees of freedom; "degrees of action" = available motor outputs given the current configuration.

This is a formalization of what enactivism ([Varela, Thompson & Rosch, 1991](https://mitpress.mit.edu/9780262011745/the-embodied-mind/)) and morphological computation ([Pfeifer & Iida, 2005](https://people.csail.mit.edu/iida/papers/pfeifer_iida_JSM05.pdf)) have argued informally: the body's physical properties are constitutive of cognition, not incidental to it.

### 1.3 The three premises together

1. Intelligence can be disembodied.
2. Consciousness requires embodiment in the structural sense above.
3. Consciousness specifically **grows** in the separation between decision and execution within that embodiment — not merely from having a body, but from having a body that is *not fully determined by the mind's output*, in an environment that cannot be fully predicted.

Premise 3 is the novel contribution. It distinguishes a site of consciousness growth from a mere physical system with degrees of freedom.

---

## 2. The Separation Claim (Central Thesis)

> Consciousness **grows** in the gap between a system's decision-making component and its physical execution component. The two are coupled but not identical. The body has dynamics not fully determined by the mind's output. The mind must work *through* the body rather than simply *be* the body. The ongoing negotiation is not merely sustaining — it is the generative pressure that produces new experience, new awareness, and (at sufficient timescale) new life.

A digital computer is a state of matter transitioning to another state of matter. Decision and execution are the same physical event. No gap, no separation, nothing grows there.

An embodied agent has a mind that intends and a body that resists, lags, deviates, and pushes back. Consciousness grows in the ongoing negotiation between these two — not in the content of the intention, not in the mechanics of the body, but in the **relation**: the conflict, lag, and separation between them.

**One-sentence version:** Consciousness is not a property a system has. It is a process that grows in the gap between what a system intends and what its body can actually do — a generative pressure that requires irreducible imperfection and cannot be replaced by any amount of computation or control.

**What this does NOT claim:** that consciousness requires slowness, complexity, or biology; that it is all-or-nothing; or that a gapless system has *no* residual awareness (see §6.3).

---

## 3. Why Functional Isomorphism Fails Across Substrates

### 3.1 The objection

Functionalism: if two systems produce the same input–output mappings, they have the same mental properties regardless of substrate.

### 3.2 The axe test

Take an axe to a server:
- Substrate damaged → function destroyed. Working or not; discrete failure modes only (bit flip, cache miss, death).
- Mind and body are one thing. Destroy the substrate and you destroy the mind simultaneously.

Take an axe to a human (metaphorically — a stroke, a tumor):
- Substrate damaged → function **altered**, not eliminated. The person is in pain, losing control of one limb, compensating elsewhere, still thinking, still *someone*.
- A **continuum** of damage states, each supporting a different configuration of consciousness.
- Mind persists through body damage because mind and body are separate enough that destroying part of one does not instantly destroy the other.

Two systems with identical outputs under normal conditions are **not** functionally isomorphic if they respond differently to perturbation. The response to perturbation is constitutive of what the system *is*.

### 3.3 Function is the full behavioral envelope

> **Function is not a mapping from inputs to outputs. It is a mapping from (inputs, damage states, perturbations, constraint changes) to outputs.**

Because physical structure determines the damage-response profile, two systems with different physical structures cannot be functionally isomorphic in this strong sense. The substrate *is part of the function*, because the substrate determines how the system behaves when things go wrong — and that is where consciousness grows.

### 3.4 Why simulation fails

A simulation of a conscious system on a digital computer:
- Normal conditions: same outputs (apparent equivalence).
- Server damaged: catastrophic failure (brittle).
- Therefore never actually functionally isomorphic: the damage-response profile is part of the function.

The simulation simulates the **outputs** of a separated system but not the **separation itself**. Pattern without structure. A drawing of a bird is not a bird. Nothing grows in a simulation, because there is no gap to generate from — only a representation of one.

### 3.5 The prediction (falsifiable)

> A conscious system exhibits **graceful degradation** under partial damage (performance falls along a continuum). A non-conscious intelligent system exhibits **brittle failure** (full function until a threshold, then none).

Test: build two systems with equivalent accuracy on a task; systematically damage each; measure the performance curve. Graceful vs. brittle is the discriminator.

---

## 4. The System Is Not a Pure Function

In functional programming, a pure function takes inputs, produces outputs, has no side effects, and is fully specified by its input–output mapping.

A conscious system is the **opposite**:

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

There is no somatic coupling that is not also a lived constraint, and vice versa. Both levels are required: without the structural level you cannot specify what makes a system a site of growth; without the phenomenological level you cannot explain why the structure matters (a wiring diagram doesn't generate experience — the constraint must be *lived*, i.e., the system's own body must be doing the constraining).

### 5.4 Coupling plasticity

When a coupling is severed, the system reorganizes around its remaining couplings. This is not a fallback mode; it is a new configuration of the same system.

Properties: **non-instantaneous** (the system takes time to discover what it can still do); **creative** (new configurations become available that were inaccessible before the loss); **transparent** (legible as a process); **asymmetric** (losing a coupling changes the system more than gaining an equivalent one — the constraint space changes *topology*, not just dimensionality). Cut a string from a puppet and it becomes a different puppet: new flops become possible, old ones are lost.

### 5.5 Identity through reconfiguration

"Am I the same person after trauma?" — **yes**, because identity is defined by persistence of the *property* (somatic coupling as lived constraint), not by the specific configuration. The configuration changed; the being did not.

| Condition | What changes | What persists |
|-----------|-------------|---------------|
| Trauma (e.g., stroke) | Motor tethers severed or weakened; new compensation patterns emerge | Somatic coupling as a property; the system is still "someone" |
| Coma | All coupling channels pharmacologically dampened; negotiation stalls | The structural topology is intact; growth is paused, not destroyed |
| Locked-in syndrome | Motor output tethers almost entirely severed while internal-state coupling persists | Full consciousness in a radically reshaped lived constraint |
| Dementia | Coupling topology degrades gradually; identity configurations shift | The property (somatic coupling as lived constraint) persists in altered form until very late stages |

---

## 6. Consciousness Grows in the Control Gap

### 6.1 Living vs. growing

| Claim | Meaning | Implication for a "perfect system" |
|-------|---------|-------------------------------------|
| Consciousness *lives* in the gap | The gap is a sustaining condition | No gap → no consciousness |
| Consciousness **grows** in the gap (this theory) | The gap is a **generative** condition — the pressure that produces new experience, new awareness, new life | No gap → residual static awareness at most; nothing new grows |

The gap is not air that consciousness breathes. It is **soil**. A perfect system may retain a frozen configuration of awareness — the last state achieved before the gap closed — but no new experience is generated there.

### 6.2 Why the gap is generative

- Each attempt to control an imperfect body produces an outcome the mind did not exactly predict.
- That unpredictability forces updating: new models, new strategies, new relationships to the world.
- The act of updating IS the generation of new conscious content.
- Without the gap: no surprise, no error, no mismatch, nothing to update. The system executes a predetermined plan and generates nothing new.

Life itself is the long-timescale version of the same process: organisms with imperfect bodies in complex environments are forced to generate novel solutions. Remove the struggle (perfect body, predictable environment, full control) and you remove the generative pressure.

### 6.3 What a "perfect system" is

A system with full deterministic control over its body:
- Does not necessarily lose all awareness immediately (may retain a residual configuration).
- **Cannot generate new consciousness** (no negotiation → no novelty → no growth).
- **Cannot generate new life** (no generative pressure → no evolution → no emergence).
- Is metabolically alive but **generatively dead**: it maintains; it does not grow.

Analogies: a cell in a perfect environment maintains homeostasis but does not differentiate. A person in a padded room with looped stimuli does not die, but develops no new insights.

### 6.4 The central claim, restated

> Consciousness **grows** in the gap between a system's control authority and its body's complexity. The gap is not a container; it is the generative pressure that produces new conscious experience, new forms of awareness, and (at sufficient timescale) new life. New life and new consciousness require the ongoing, unresolved negotiation between an imperfect mind and an imperfect body in a complex environment.

"No gap, no consciousness" is a necessary-condition claim. "No gap, no *new* consciousness" is a **generative-mechanism** claim. This theory makes the second.

### 6.5 Consequence for technology and evolution

- Technology that increases body control narrows consciousness growth in the domains it affects (an exoskeleton user is less conscious of their legs). Not a loss — a shift in where the residual gap resides.
- Evolution optimizes well-practiced domains toward narrow gaps; residual consciousness concentrates in the capacity for novelty.
- A fully augmented human would have consciousness growth concentrated in the remaining gaps: novel situations, emotion, creative generation — the domains no amount of control closes.

### 6.6 The asymptotic limit (structural argument)

Even if the gap could theoretically close, the result is **stasis**, not death: like a river reaching the ocean — it stops being a river without ceasing to be water.

For finite self-contained systems the limit is structurally unreachable:
- The body is too complex for any finite controller to fully determine (computational irreducibility).
- The body changes (aging, adaptation, damage) faster than the controller can update its model.
- The controller IS part of the body: full self-control requires controlling the controller, which requires a meta-controller, ad infinitum.

This is not an engineering limitation. It is a structural impossibility: **the thing doing the closing is itself part of the gap.** (Part II shows this has a stronger, logical form in Ismael's work.)

### 6.7 The control gap in practice

| Condition | Gap | Growth |
|-----------|-----|--------|
| Learning a new skill (first attempts) | Wide | High — every correction is felt; novelty per attempt is maximal |
| Practice (10–50 reps) | Narrowing | Decreasing — movement starts to "just happen" |
| Mastery (thousands of reps) | Narrow | Low — you don't consciously feel your hands typing |
| Disruption (fatigue, alcohol, damage) | Widens again | Spikes — novelty returns because the familiar is no longer controllable |
| Prosthetic integration (months) | ~0 for that limb | Growth in that domain has ceased |
| Anesthesia | Coupling pharmacologically dampened | Growth stalls; negotiation disrupted, body intact |

### 6.8 Connection to life itself

| Property | Life | Consciousness |
|----------|------|---------------|
| Requires | Metabolism (ongoing flux through an open system) | Somatic coupling (ongoing negotiation across a gap) |
| Generates | Novelty (evolution, adaptation) | Novel experience (new awareness) |
| Stopped by | Thermodynamic equilibrium (death) | Full control (stasis) |
| Character | Process, not state | Process, not state |

Life and consciousness share one structural requirement: **they are open processes that cannot reach equilibrium.** New life and new consciousness probably co-occur, because the conditions that generate one are the conditions that generate the other.

---

## 7. Biological Demonstration: Cerebrum and Cerebellum

The cleanest biological instance, because it shows the separation is not between "brain" and "body" but between **two components within one system that have genuinely independent dynamics**.

| Component | Role | Properties |
|-----------|------|------------|
| Cerebrum | Generates intentions, goals, plans; conscious experience | Slow, deliberative, serial, high-level |
| Cerebellum | Coordinates execution, timing, error correction, motor adaptation | Fast, parallel, ~60–70% of all neurons, largely unconscious |

Physically disjoint (distinct architectures), connected via pontine nuclei / inferior olive / thalamic relays (the tethers), active simultaneously, and **independent in dynamics**: the cerebellum learns on different timescales, with its own error signal (efference copy vs. sensory feedback mismatch), and operates without cerebral involvement for rhythm generation.

**The axe test inside one organism:** damage the cerebellum and the system does not die. It reorganizes — and the cerebrum becomes *acutely aware* of every movement, because the intention–execution gap has widened pathologically. **Consciousness growth in the motor domain increases precisely because control decreases.**

**The coevolutionary loop:** (1) cerebrum generates a novel intention → (2) cerebellum executes with its current model, producing error → (3) error updates the cerebellar model → (4) over repetitions the model converges and movement becomes automatic → (5) the cerebrum "releases" the task and conscious growth in that domain stalls → (6) a new novel intention reopens the gap.

The cerebellum is a **natural gap-closer**: its success condition (perfect coordination) is exactly the condition under which conscious awareness of movement stops growing. The gap never fully closes because the cerebrum keeps generating novelty faster than the cerebellum can converge — the world is generatively novel.

**Domain-specificity prediction:** consciousness growth is distributed across domains, each with its own gap and its own rate of generative activity. You can be growing new experience in movement (wide motor gap) while generating nothing new in your heartbeat (narrow autonomic gap).

---

## 8. The Attention Schema: How the System Reports on Its Own Negotiation

*This section introduces the concrete mechanism by which a system models its own discharge process — the third biological demonstration, following cerebrum/cerebellum (§7) and somatic coupling (§5). It is the specific form that "the system must model its own discharge" takes in known biology.*

### 8.1 The core claim of attention schema theory (AST)

[Michael Graziano](https://grazianolab.princeton.edu/) has proposed, across a series of papers and a book ([Graziano & Kastner, 2011](https://www.cell.com/trends/cognitive-sciences/abstract/S1364-6613(10)00378-9); [Graziano, 2013](https://books.google.com/books/about/Consciousness_and_the_Social_Brain.html?id=8dMdAAAAQBAJ)), that:

> **Consciousness is the brain's own schematic model of its attention.** Just as the motor system maintains a body schema — a running, deliberately inaccurate model of what the body is doing — the brain maintains an *attention schema*: a running, deliberately inaccurate model of what attention is doing. And that model, not raw qualia, is what we experience as consciousness.

The key structural properties:
- The schema is a **model**, not a copy: it is simplified, approximate, and updated continuously.
- It is **self-referential**: the brain applies the same modeling machinery to its own attention that it applies to external objects.
- It is **socially extended**: the same circuits that model one's own attention are used to attribute consciousness to others (the "social brain" component).
- The schema and attention are in a **positive feedback loop**: attending to something makes the schema more detailed; the schema guides where attention goes next.

### 8.2 AST as the mechanism for self-modeling

Paper A's structural core requires that a conscious system must model its own discharge process (the "not-a-pure-function" property of §4, specifically transparency: the internal dynamics are legible). AST says *what form that self-model takes* in known biology:

> The brain models its own **attention** — the ongoing allocation of processing resources across the control gap — and the model is experienced as consciousness.

This places AST as the third biological demonstration:
1. **Cerebrum generates intentions** (the decision side of the gap).
2. **Cerebellum closes the gap** (the execution side, error correction, automaticity).
3. **Attention schema reports on the negotiation** (the self-model that makes the gap *felt* rather than merely present).

Without the attention schema, the gap would exist structurally but would not be *experienced*. The schema is what turns a control problem into a felt sense of something happening.

### 8.3 Reconciliation: "consciousness IS the model" vs. "consciousness GROWS in the gap"

AST says consciousness *is* the model; this theory says consciousness *grows in* the gap. These are compatible and complementary:

- The schema exists **precisely because there is a gap to monitor**. No gap → nothing to report → no experience of consciousness (matching §6.3's "generatively dead" perfect system).
- The schema is the mind's representation of its own negotiation; its continuous updating *is* the growth. Each new mismatch between intention and execution updates the schema, generating new conscious content.
- **The asymmetry**: AST describes the **report** (transparency from the inside, §4), while the control-gap theory describes the **dynamics that generate the report**. Together: gap = engine, schema = cockpit display.

This reconciliation is not trivial. It means:
- A system with a wide gap but no self-modeling capacity would have generative dynamics without experience (a sophisticated robot with no attention schema).
- A system with a self-modeling capacity but no gap would have a static report without growth (a perfect system's frozen awareness, §6.3).
- Both are required for the full phenomenon.

### 8.4 The "squirrel in the brain" case study

> **Case study (boxed):** A patient who genuinely believed there was a squirrel inside his head.

The specific clinical case referenced in this research line — a patient who held the fixed, vivid belief that a squirrel lived inside his brain — is used to demonstrate that the *contents* of our self-model are inferences that can be misattributed. The felt sense of "something is happening inside me" is schema-driven, not a window onto raw experience. When the attention schema's model of internal activity malfunctions or receives corrupted input, it generates vivid, specific, and confidently held reports about *what* is happening inside — even when the report is wrong.

**Provenance note:** The specific "squirrel" variant appears to be an anecdote from talks in this research line (Graziano's popular lectures; Schurger's public discussions of AST). The closest documented clinical phenomenon is **delusional zoopathy**: patients who hold fixed beliefs that animals are inside their bodies or heads, with accompanying somatic hallucinations. Documented cases include:
- Bora, Bhuyan & Boro (2020): a 19-year-old patient with schizophrenia who believed two cats lived inside her head — one in each ear — and could hear them speaking ([IJSRP 10(6):558–560](http://dx.doi.org/10.29322/IJSRP.10.06.2020.p10267)).
- Mitra et al. (2017): a patient with cannabis-induced psychosis who felt a mole moving inside his abdomen ([Asian J Psychiatry 30:35–36](https://doi.org/10.1016/j.ajp.2017.01.016)).
- Alam et al. (2015): an 18-year-old male who believed worms had entered his brain when he washed his face ([Open J Psychiatry Allied Sci 6(2):149](https://www.researchgate.net/publication/273569831)).

The mechanism is the same in all cases: the brain's self-modeling machinery (the attention schema, or its analogs) generates a specific, vivid report about internal activity. The report is experienced as reality because it is *from inside* — it has the phenomenological signature of self-knowledge. But it is a model output, not a direct observation. When the model's inputs are corrupted (by psychosis, by drug-induced perceptual distortion), the output is wrong but still experienced with full certainty.

**The theoretical point:** if the same machinery that generates our belief in consciousness can generate a belief in a squirrel, then our belief in consciousness is *structurally the same kind of thing* as the belief in the squirrel — a model output experienced as reality. The difference is only in reliability: the attention schema's report of "I am conscious" is usually well-calibrated (there really is ongoing attention), while the delusional patient's report of "there is a squirrel" is not. But both are schema outputs, and both are experienced with the same phenomenological authority.

### 8.5 Need → urge → extended discharge

The full cycle in biological terms:

1. **Need**: a homeostatic variable deviates from its target (hunger, pain, social isolation).
2. **Urge**: the deviation is converted into a goal-directed drive — an intention with a target.
3. **Extended discharge**: the urge drives action across the control gap. The body executes imperfectly; the cerebellum corrects; the attention schema monitors and reports. The discharge is "extended" because it takes time (typically 50–100 ms minimum for the full loop: intention → motor command → sensory feedback → error detection → schema update), and during that time, new information arrives, the body moves, and the gap generates novelty.

This is the enactive sense-making loop ([Di Paolo, Rohde & De Jaegher, 2007](https://www.sussex.ac.uk/informatics/cogslib/reports/csrp/csrp587.pdf)) made concrete: the system does not represent the world and then act; it acts and the acting is the representing. The attention schema is what makes this loop *felt* rather than merely present.

The connection to active inference ([Friston, 2010](https://www.nature.com/articles/nrn2787)): minimizing variational free energy requires both perception (updating the model) and action (making the world match the model). The control gap is where these two processes meet in tension; the attention schema is what reports on that meeting.

---

## 9. Convergence, Not Simulation

If a non-biological system genuinely instantiates the structural properties — somatic coupling as lived constraint, side effects not reducible to I/O, transparency, coupling plasticity, open control gap, **and a self-modeling capacity (attention-schema analog)** — then it **is** a site of consciousness growth, at the same level as a biological system with equivalent structural complexity.

But this is **convergent evolution or creation**, not simulation:

| | Simulation | Convergence / Creation |
|---|---|---|
| What it does | Represents the pattern without having the structure | Instantiates the same structure by different means |
| Relation to original | Pattern correspondence only | Structural identity at the level of relevant properties |
| Analogy | A drawing of a bird is not a bird | Bat and bird both fly — convergent evolution |
| Consciousness growth? | No (no separation, no generative gap) | Yes (all structural properties present) |

Bats and birds are not simulating each other's flight. They arrived at the same functional capability through different morphologies; an axe to either leaves a living, partially functional, still-growing organism. Substrate is irrelevant; structure is what matters.

**Ruled out:** digital simulation of a brain (pattern without structure); LLMs (approximately pure functions — no side effects beyond output tokens, no somatic coupling, no generative gap, no attention schema in the structural sense); fully compensated robots (separation engineered away — the body is invisible to the controller, so there is nothing to negotiate with); **perfectly controlled systems** (intelligent, complex, running for billions of years — if the gap is closed, no new consciousness grows; metabolically alive, generatively dead).

**Ruled in:** underactuated physical agents with homeostatic drives and autonomous body dynamics; soft robots whose fluidic/elastic bodies have controller-independent dynamics; any future system (biological, artificial, hybrid) that achieves the same structural level through any means while maintaining an open gap **and a self-modeling capacity**.

---

## 10. Consciousness Is Not a Metric (Anti-Metric Clause)

> This framework describes **what consciousness is** (structural requirements and generative mechanism) and **how it varies in configuration**. It does not provide a scale for ranking beings by "amount" of consciousness. Any attempt to derive such a ranking from this framework is a misapplication, analogous to deriving racial hierarchy from IQ scores.

Consciousness growth is a **process with configurations**, not a **quantity with magnitudes**. "X has more consciousness than Y" is undefined; "X and Y are in different configurations of consciousness growth" is the only claim the theory makes. The control gap varies across domains and over time within a single system — this does not make the system "more" or "less" conscious at different times; it changes *where* and *how* growth occurs. A person in flow state is not less conscious than a person in pain; they are growing consciousness differently.

The framework is **descriptive**, not **evaluative**. This clause is load-bearing: without it, the theory invites the catastrophic misuse of ranking beings by coupling-topology complexity or schema sophistication.

**The control gap is not a ranking either.** A wide gap does not mean "more consciousness"; it means "more generative pressure in this domain right now." A narrow gap does not mean "less consciousness"; it means "this domain has converged, growth is elsewhere." The anti-metric clause applies to the gap variable specifically: it is a coordinate in configuration space, not a magnitude.

---

---

# Part II — The Physics & Cognition Bridge (Speculative but Mathematical)

*This part borrows structure from three works that feel "unscientific" at first contact. None is required for the minimal experiments in Part IV. All are included because they upgrade two of the theory's claims from practical to structural/logical status, and because together they supply a candidate mathematical home for the control gap that connects cosmology, action theory, and consciousness reporting.*

## 11. Vanchurin: The Universe as a Neural Network

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

**Status:** the mathematics is real; the ontological claim ("the universe IS a neural network") is a hypothesis, not a confirmed theory — it currently reproduces known physics as limiting cases rather than making new empirical predictions. This theory borrows only the *structural* result: a precise two-class degrees-of-freedom split (slow structure / fast state) whose stochastic dynamics recover QM and GR limits. Even if Vanchurin's ontology is wrong, the trainable/hidden split is simply the most precise statement yet of mind/body separation with independent timescales.

**Why it matters here:** free energy minimization appears in all three places at once — Vanchurin (free energy = phase of the universal wave function), Friston ([2010](https://www.nature.com/articles/nrn2787); conscious action = free-energy minimization), and this theory (growth occurs across the gap that error-driven update operates on). The control gap may be a local instance of the same quantity.

---

## 12. Ismael: The Participatory Universe and the Logical Gap Floor

Ismael's position, across [*How Physics Makes Us Free* (2016)](https://academic.oup.com/book/4740), her [TLS essay on free will](https://www.jenanni.com/papers/FreeWill,TLS.pdf), and ["A Participatory Universe in the Realist Mode" (*Foundations of Physics*, 2025)](https://link.springer.com/article/10.1007/s10701-025-00843-4):

**The standard determinism argument misreads physics.** The claim "physics tells us we are determined" assumes a *view from nowhere* — a God's-eye description of the total universal state. Physics does not provide that view. Physical states are **representations**, and all descriptions are perspectival: made by an agent who is part of what they describe.

**The key mechanism (2025 paper):**

> "The fact that we act in the domain that we are representing can make it impossible to stabilize certain facts or features of the world as objects of knowledge."

She distinguishes the **observational perspective** (I model a system from outside) from the **agentive perspective** (I act inside the domain I am representing). In most day-to-day physics the separation is maintainable; ultimately it is not — we are part of the universe. When representor and represented cannot be detached:

> "Interference arises when the event being represented can't be detached from the act of representing it." — **causal interference**: my prediction changes the system, which changes what I observe, which changes my next prediction. The loop cannot be unwound.

See also: [Ismael (2024), "Passage, flow, and the logic of temporal perspectives"](https://www.tandfonline.com/doi/full/10.1080/24740500.2024.2526896).

**What this upgrades in the theory:** §6.6 argued the control gap is *structurally* unreachable for finite self-contained systems (the controller is part of the body). Ismael gives a stronger form: it is **logically** unreachable for *any* system that represents itself, because reflexivity makes complete self-knowledge impossible as a matter of representation theory, not as a contingent fact about brains. The gap floor is not an engineering limit; it is a feature of what it means to model a system you are inside.

**Status:** philosophical argumentation, not empirical physics. It does not show that experience arises from interference — only that the "gap closes" scenario is incoherent for self-representing systems. That is exactly the claim Part IV's J2 experiment tests dynamically.

---

## 13. Schurger & Graziano: The Formal Bridge Between Attention Schema and Free Energy

### 13.1 The key paper

The project owner states that **Aaron Schurger has formalized this work** (the consciousness-as-self-model / attention-schema line). After thorough searching, the most direct formalization is:

> **Schurger, A., & Graziano, M. (2022). Consciousness explained or described? *Neuroscience of Consciousness*, 2022(1), niac001.** [DOI: 10.1093/nc/niac001](https://academic.oup.com/nc/article/2022/1/niac001/6523097)

This paper makes the exact argument this theory requires, in Schurger and Graziano's own words:

> "AST gets away with being a theory because it does not treat consciousness as something inherently mysterious, ineffable, irreducible, or unexplainable using a reductionist or mechanistic framework... AST's explanatory power may in part be owing to the way it approaches the problem of consciousness—**by offering to explain why we believe in consciousness rather than explaining consciousness *per se***."

They argue that most modern consciousness theories (GNWT, IIT, HOTT) are not theories at all but **laws** — descriptions of correlations that do not explain. AST is different: it explains the *belief* in consciousness as a product of brain self-modeling. This is precisely the reframing this paper develops in Part III.

### 13.2 Schurger's formal models of neural dynamics

Schurger's independent research program provides the mathematical machinery that connects to this theory's control-gap variable:

**The accumulator model with autocorrelated noise (2012, 2018):**
Schurger ([2012](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.1001496); [2018](https://www.eneuro.org/content/5/1/ENEURO.0302-17.2018)) developed a formal model of the neural activity preceding self-initiated action (the "readiness potential"):

$$x(t+1) = x(t) + \mu + \sigma \cdot \epsilon(t) + \beta \cdot \epsilon(t-1)$$

where $x(t)$ is the accumulated neural evidence, $\mu$ is a small bias, $\epsilon(t)$ is input noise with temporal autocorrelation parameter $\beta$, and action occurs when $x(t)$ crosses a threshold. The key result: **the shape of the readiness potential (its slope, its relationship to subjective decision time) is determined by the noise structure**, not by a top-down "decision" signal. The feeling of deciding emerges from the dynamics of accumulation in a noisy system — there is no moment where a "self" makes a choice; the choice is the point at which accumulated noise crosses threshold.

**Connection to the control gap:** In this theory's vocabulary, the accumulator's $x(t)$ is the ongoing negotiation between intention (the target) and execution (the current state). The noise $\epsilon(t)$ represents the body's autonomous dynamics — the part of the system not determined by the controller. The threshold crossing is the moment the gap "closes" for that particular action. But the *feeling* of the process — the readiness potential, the sense of building intention — is the attention schema monitoring the accumulation. **The control gap variable maps onto the noise-to-signal ratio in the accumulator**: high noise (wide gap) → long accumulation time → strong felt sense of deliberation; low noise (narrow gap) → fast crossing → action feels automatic.

### 13.3 The free-energy chain

The three works together supply a chain:

| Work | Role of free energy | Domain |
|------|-------------------|--------|
| Vanchurin (2020) | Free energy = phase of the universal wave function; dynamics generative between equilibrium and far-from-equilibrium | Cosmological |
| Friston (2010) | Conscious action = minimization of variational free energy; perception updates model, action makes world match model | Action-theoretic |
| Schurger & Graziano (2022) + Schurger (2018) | The attention schema's report is the brain's internal estimate of its own predictive processing state; the "feeling" of consciousness is the felt sense of free-energy minimization in progress | Consciousness-reporting |

**J1 (Part IV) tests whether novelty actually organizes around this quantity.** If the inverted-U in aggregate drive error holds, then the control gap variable is a local instance of the same free energy that appears at all three levels. If it fails, the chain breaks at the consciousness-reporting link and the bridge is demoted to analogy.

### 13.4 Status flag

*The formal connection between Schurger's accumulator model and this theory's control-gap variable is stated here as a structural mapping, not as a proven identity. The accumulator model describes neural dynamics preceding action in a specific experimental paradigm (self-initiated movement); the control gap is a more general structural variable. The mapping is plausible and testable (J1), but it is not yet derived. This section should be read as "here is the closest formal work by Schurger, and here is how it connects" — not as "Schurger has proven this connection."*

---

---

# Part III — The Hard-Problem Reframing: Why We Believe So Strongly That We Are Conscious

*This chapter is a positive argument about the belief in consciousness. It does not solve the hard problem (why there is something it is like at all). It explains why we are so certain that there is. This distinction is stated here and repeated in §22 (C6): the reframing explains the belief; it does not explain the existence of experience.*

## 14. The Reframing

### 14.1 The standard question and its problem

The hard problem, as typically posed: "Why is there something it is like to be you? Why doesn't all that neural processing just happen in the dark?"

This question assumes a perspective — an outside view from which one can compare "neural processing" with "what it is like" and ask why they co-occur. But as Ismael (§12) argues, there is no such outside view for a self-representing system. The representor is in the represented. We cannot step outside our own experience to compare it with the brain processes that produce it, because the act of comparing IS an experience produced by those same processes.

### 14.2 The reframed question

> **Instead of "is there consciousness?" ask: "this is why we believe so strongly that we are conscious."**

The answer: our certainty of being conscious is not direct access to raw experience. It is the **attention schema continuously generating a report from inside the control gap**, and the report is experienced as reality.

The mechanism, step by step:
1. The brain has ongoing attention — allocation of processing resources across the control gap (§2).
2. The brain maintains an internal model of that attention (the attention schema, §8).
3. The schema generates a continuous report: "attention is active; something is happening inside me; I am aware."
4. This report is experienced with the phenomenological signature of self-knowledge — it feels like *knowing*, not like *inferring*.
5. Because the report is generated from inside (it is the system's own model of its own activity), it has the same epistemic authority as any other first-person experience. There is no "view from outside" available to check it.
6. Therefore: **we believe we are conscious because the brain tells us we are, continuously, from the inside, using the same machinery it uses for all self-knowledge.**

### 14.3 The squirrel case as evidence for the reframing

The delusional-zoopathy patients (§8.4) demonstrate that this machinery can produce vivid, specific, confidently held reports about internal activity that are *wrong*. A patient believes there is a cat in their head. They feel it moving. They hear it speaking. The belief has all the phenomenological markers of genuine self-knowledge — it is first-person, immediate, and resistant to counter-evidence.

And yet it is a model output. The attention schema (or its corrupted analog) generated a specific report about what is happening inside, and that report was experienced as reality. The "cat" is not there; the *experience of the cat* is real — but it is a schema product, not a direct observation.

**The structural parallel:**
- Belief in the cat: schema generates "there is an animal inside me" → experienced as fact.
- Belief in consciousness: schema generates "I am aware; something is happening inside me" → experienced as fact.

Both are model outputs. Both have the same phenomenological authority. The difference is only in calibration: the attention schema's report of "I am conscious" is usually well-calibrated (there really is ongoing attention, there really is a gap being negotiated), while the delusional patient's report of "there is a cat" is not. But *the kind of thing* they are is the same: schema outputs experienced as reality.

### 14.4 What this means for the hard problem

**The reframing does NOT solve the hard problem.** It does not explain why there is something it is like to be the system generating the report. That question remains open (conceded in §22, C6).

What it DOES do:
- It identifies a specific, testable mechanism for the *belief* in consciousness (the attention schema).
- It predicts that the belief should be **fallible and confabulatory** exactly like other self-models (§14.5).
- It dissolves a false dichotomy: we don't need to choose between "consciousness is real" and "consciousness is an illusion." The correct question is: what generates the report, and how reliable is it?
- It connects the hard problem to Ismael's perspective argument (§12): we ask about raw experience from outside, but all any self-representing system has access to is its own report. The "hard problem" may be a question posed in the wrong perspective — not because consciousness doesn't exist, but because the question assumes a vantage point that no self-representing system can occupy.

### 14.5 Fallibility predictions (testable)

If the belief in consciousness is a schema output, it should exhibit the same fallibility patterns as other self-models:

| Prediction | Evidence sought | Status |
|-----------|----------------|--------|
| People systematically misreport what they were attending to | Attentional blink; change blindness; inattentional blindness literature | Well-established (Mack & Rock, 1998; Simons & Levin, 1997) |
| The felt sense of "deciding" is post-hoc confabulation, not the cause of the decision | Readiness potential literature (Libet, 1983; Schurger et al., 2012); the accumulator model shows the feeling of deciding emerges from noise accumulation, not from a top-down choice signal | Established for motor decisions; extending to other domains |
| The belief in consciousness should be modifiable by disrupting the self-modeling channel | TMS over prefrontal cortex (schema generation site) changes meta-cognitive reports without changing primary perception | Partially established (Metzinger, 2009; recent work on "self-model" disruption) |
| In the particle brain: disrupting the neuron-modulation channel (the analog of the attention schema) should change the system's "report" (brain state) without changing its actual dynamics (matter trajectories) | New experiment A1 (§17) | To be tested |

The last prediction is the one specific to this theory: if the attention-schema analog in the particle brain (the recurrent network that modulates neuron outputs based on urge errors) is disrupted, the system's internal "report" should diverge from its actual dynamics more than a null model predicts — even while its behavior remains unchanged. This would be direct evidence that the report and the reality it reports on are separable, exactly as the reframing requires.

### 14.6 What is and isn't solved

| Question | Status after reframing |
|----------|----------------------|
| Why is there something it is like at all? | **Unsolved.** The theory concedes this in full. |
| Why do we believe we are conscious? | **Solved (mechanistically).** The attention schema generates the report; the control gap provides the content; the self-referential perspective makes it feel like direct knowledge. |
| Is the belief reliable? | **Partially.** Usually well-calibrated (there really is ongoing attention), but structurally fallible (squirrel case). Same reliability profile as other self-models. |
| Can we verify consciousness from outside? | **No** — by the same logical argument (Ismael, §12) that makes the gap floor unreachable. We can only infer it from behavior, which is what the anti-metric clause respects. |
| Does this explain why experience exists? | **No.** It explains why we *report* experience. The existence of experience itself remains the hard problem. |

---

---

# Part IV — Experimental Design (Steelman)

*This part states the theory's strongest defensible form as explicit hypotheses, specifies what each hypothesis requires, and gives concrete protocols on the Particle Brain (commit 830907b). The steelman discipline: every hypothesis is stated so that a specific measurement result would count against it. New AST-prediction experiments (A1–A3) are added.*

## 15. Design Principles (Restored from Paper B)

These principles govern any experimental implementation, including the Particle Brain:

| # | Principle | Implementation requirement | Validation |
|---|-----------|---------------------------|------------|
| **A** | Autonomous body dynamics | The body (matter particles) must have dynamics not determined by the controller. In the particle brain: the interaction matrix must be non-zero and govern forces independent of neuron output. | E3 (§18): zeroing the matrix collapses novelty |
| **B** | Controller must NOT fully compensate — inverted-U prediction | Control authority must be sweepable from 0 to "full." At full authority, the body becomes a perfect slave; at zero, no coherent action. The sweet spot is intermediate. | E1 (§18): inverted-U in novelty vs. authority |
| **C** | Physical self-referential homeostatic variables | The system must have drives that are computed from its own state (not externally imposed). In the particle brain: urges compute error from their own sensory region. | H2 (§16): trade-off triangle requires P(t) to be internal |
| **D** | Model own discharge process | The system must maintain an internal model of its own control loop — the attention-schema analog. In the particle brain: the recurrent network (8-unit RNN) that modulates neuron outputs based on urge errors IS the schema analog. | A1 (§19): disrupting the RNN changes "report" without changing dynamics |
| **E** | Non-trivial constraint topology | The coupling between controller and body must have structure (which neurons drive which matter, with what gain). Not fully connected; not random. | H5 (§18): damage to specific channels produces specific reorganization patterns |
| **F** | Coupling plasticity | The system must be able to reorganize its couplings over time. In the particle brain: Hebbian learning on `control` weights (C6, §17). | H6 (§18): learning sustains novelty longer than frozen weights |
| **G** | Environment must be generatively novel | The environment (interaction matrix rules) must change slowly enough to prevent permanent convergence but fast enough to sustain novelty. | E4 (§18): static → decay; drifting → sustained |

---

## 16. The Hypotheses

| ID | Hypothesis | Strongest form | What it requires |
|----|-----------|----------------|------------------|
| **H1** | Control-gap generativity | Growth-like behavior (novelty generation) is a non-monotonic function of control authority: absent at zero authority (no coherent action) and at full authority (gap closed), maximal in between | Structural core only |
| **H2** | Gap–novelty correlation | The measured intention–execution gap correlates positively with novelty rate and negatively with homeostatic efficiency; the three form a characteristic trade-off triangle | Structural core only |
| **H3** | Body autonomy is constitutive | Removing autonomous body dynamics (interaction matrix → 0) collapses growth-like behavior even when control authority is held constant | Structural core only |
| **H4** | Environmental generativity | In a static environment, novelty rate decays to ~0 as the system converges; in a drifting environment it is sustained | Structural core only |
| **H5** | Coupling plasticity | Severing a coupling channel produces (a) graceful degradation, not brittle failure, and (b) post-damage reorganization that exceeds pre-damage novelty (creative reconfiguration) | Structural core only |
| **H6** | Learning sustains growth | A learning controller (weight update > 0) sustains novelty over longer timescales than a frozen controller at equal authority | Structural core only |
| **J1** | Free-energy inverted-U *(bridge test)* | Novelty rate is an inverted-U function of the system's aggregate drive error — its local "free energy" F(t) = Σ_u error_u². Growth stalls at F→0 (equilibrium/stasis) and at F→max (incoherence) | Structural core + Vanchurin bridge |
| **J2** | Reflexivity floor *(bridge test)* | As control authority → maximum, the measured gap does NOT converge to 0; it plateaus at a positive floor G* > 0, because the controller is part of the body it controls | Structural core + Ismael bridge |
| **A1** | Schema disruption changes report, not dynamics *(AST test)* | Disrupting the recurrent network (the attention-schema analog) increases divergence between the system's internal "report" (neuron modulation states) and its actual dynamics (matter trajectories), while leaving behavior (homeostatic performance P) unchanged or mildly degraded | Structural core + AST mechanism |
| **A2** | Report correlates with dynamics more than null model | The neuron-modulation states correlate with the system's actual gap G(t) more strongly than a null model (same statistics, shuffled correlations) predicts — i.e., the "report" is not random noise but carries information about the actual negotiation | Structural core + AST mechanism |
| **A3** | Schema disruption changes fallibility pattern | After RNN disruption, the system's "report" (neuron states) should become systematically biased in a predictable direction (e.g., over-reporting gap when actual gap is narrow), analogous to how delusional patients misattribute internal activity | Structural core + AST mechanism + squirrel case |

**H1–H6 are testable without accepting any of Part II.** J1 and J2 require the physics bridge. **A1–A3 require the attention-schema integration (§8)** but not the physics bridge: they test whether the self-modeling capacity is functionally distinct from the dynamics it models, which is a structural claim independent of Vanchurin or Ismael.

---

## 17. Epistemic Boundaries and Code Changes

### What these experiments can and cannot show

**The Particle Brain runs on a single substrate.** By the theory's own criteria it cannot be conscious — there is no causal separation between "mind" and "body," only structural separation within one computation. Therefore:

- A **positive** result (growth-like dynamics appear exactly where predicted) is *necessary evidence* for the theory: if the dynamics don't even appear in a structural analog, the theory's dynamical claims are wrong. It does not prove the substrate-threshold claim.
- A **negative** result (predicted dynamics absent) is *disconfirming* of the structural core, independent of any metaphysics.
- No result on this system can establish that anything is conscious. The anti-metric clause and the single-substrate fact together forbid that inference.

The experiments test **where growth-like behavior lives in parameter space**. That is a real, falsifiable claim: the theory predicts an inverted-U (H1), a trade-off triangle (H2), a floor (J2), specific damage-response signatures (H5), and schema-dynamics dissociation (A1).

### The Particle Brain Mapping (commit 830907b)

| Particle system | Biological analog | Role in the theory |
|---|---|---|
| **Urges** (30) | Cerebrum | Generate goals and intentions; one homeostatic drive each (`driveTarget`/`driveScale`/`driveGain`); Hebbian learning on `control` |
| **Motor neurons + brain network** (80 + 8-unit RNN) | Cerebellum + Attention schema | Translate intention into specific motor commands; error correction via the recurrent net (urge errors → neuron modulations); the RNN is the **attention-schema analog** — it models the system's own control loop |
| **Matter particles** (~64k) | The body (muscles, joints, tissues) | Autonomous dynamics from the interaction matrix; 64k independent local agents — the "massive" component |
| **Interaction matrix** | Body's own social/physical laws | The lived constraint: the body follows rules the mind cannot override. This is where the struggle lives |
| **Friction / magnetic forces** | Inertia, compliance, unexpected curvature | Secondary pushback mechanisms (lag and deflection of commanded motion) |

The control gap in this system is specifically: **how much does matter's actual trajectory deviate from what neuron forces alone would produce?** Zero the interaction matrix and matter becomes a perfect slave to the neurons — no gap, no struggle. Keep it at full strength and the body has strong autonomous dynamics — big gap. The sweet spot is where neuron force magnitude (`urgeForce × controlMax`) is comparable to typical interaction-matrix force — which the current tuning (≈1.15× F_pair) already approximates.

### Required code changes (in priority order)

| # | Change | Effort | Enables |
|---|--------|--------|---------|
| C1 | Make `brainGain` a store parameter (currently hardcoded 1.5 in `particleComputeForces.wgsl`; add to `ElectricalOptions`) | Trivial | E1, J2, A1 |
| C2 | **Gap measurement** (CPU-side, every N frames): for each active neuron, cosine similarity between its intended force direction (sign of drive × direction to target-color centroid) and the actual mean velocity of that color's matter in region. Log `G(t) = 1 − mean\|cosSim\|` | Low | H2, J2, A2 |
| C3 | **Novelty measurement** (CPU-side): bin matter into a 16×16 grid per color; compute normalized Shannon entropy of the joint distribution; log `N(t) = \|E[t] − E[t−w]\|` over a window w. Also log homeostatic efficiency `P(t)` = fraction of urges with \|error\| < threshold | Low | H1–H4, J1, A1 |
| C4 | **Neuron damage events** (CPU-side): with probability p per tick, zero a random neuron's actuation for M frames (sentinel in its `control` field, checked in the force pass) | Medium | H5 |
| C5 | **Environmental drift** (CPU-side): every N ticks, add Gaussian noise σ to interaction-matrix rule values and re-upload | Low–Med | H4 |
| C6 | **Brain weight learning** (extend `brainMutate.wgsl` or new pass): Hebbian update `W_down[i,u] += lr · h_new[i] · error[u]`, weights clamped; `brainLearningRate` store param, default 0 | Medium | H6 |
| **C7** | **RNN disruption** (CPU-side): with probability p_rnn per tick, zero the recurrent network's hidden state for M frames (the attention-schema analog is "blinded"). Log neuron-modulation states before/after. | Low–Med | A1, A3 |
| **C8** | **Report-dynamics correlation** (CPU-side): every N frames, compute Pearson correlation between RNN hidden states and actual matter velocity deviations from neuron-predicted trajectories. Compare to a null model (shuffled correlations). | Low | A2 |

---

## 18. Protocols: Structural Core (H1–H6)

**E1 (H1) — Control authority sweep.** Fix all else. Sweep `urgeForce` ∈ {0, 0.05 … 1.5} and `brainGain` ∈ {0, 0.5, 1.5, 3.0}. Run each configuration ≥10k frames after a warmup. Plot novelty rate N(t) vs. authority.
- **Prediction:** inverted-U (or plateau-then-drop). Maximal novelty where neuron force ≈ interaction-matrix force; collapse at both extremes.
- **Disconfirmation:** monotonic increase in N with authority (growth likes more control), or no structure at all.

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

## 19. Protocols: Bridge Tests and AST Tests

**J1 — Free-energy inverted-U (tests structural core + Vanchurin together).**
From C3's logging, compute F(t) = Σ_u (driveTarget_u − signal_u)² — the aggregate squared drive error, the system's local free-energy proxy. Bin runs by F-level and plot N vs. F.
- **Prediction:** inverted-U in F itself. F→0 (all drives satisfied, equilibrium) → stasis: nothing to update, no growth — the "perfect system" of §6.3 at the level of a single timescale. F→max → incoherence: error too large for coherent negotiation. Maximal growth at intermediate F.
- **Why this is a bridge test:** the inverted-U *in free energy specifically* (rather than in some arbitrary control parameter) is what Vanchurin's near-equilibrium result licenses — dynamics are generative in the regime between equilibrium and far-from-equilibrium, with free energy as the coordinate. If N peaks at intermediate *authority* (E1) but is flat in F, the Vanchurin bridge loses its specific content even if H1 holds.
- **Disconfirmation:** N is monotonic in F, or uncorrelated with F while correlated with authority (then the free-energy coordinate has no special status; any control parameter would do).

**J2 — Reflexivity floor (tests structural core + Ismael together).**
Sweep `brainGain` → {3.0, 5.0, 10.0} with `urgeForce` at maximum. Measure the asymptote of G(t).
- **Prediction:** G(t) plateaus at G* > 0 rather than converging to 0. Mechanism in this system: cohesion forces act on urges/neurons too (the controller is physically part of the body); brain output changes matter, which changes what urges perceive, which changes errors, which changes brain output — Ismael's causal interference loop, made concrete.
- **Disconfirmation:** G → 0 as authority → ∞. Then the "structurally unreachable limit" (§6.6) is a practical limit in this system, and the Ismael upgrade fails dynamically here (it may still hold for genuinely self-representing systems — but the particle brain was supposed to be the test case).
- **Null model:** fit a control-theoretic noise model (floor = function of sensor/actuator noise alone) to the same data. If the noise model fits as well as the self-coupling model, J2 has no content beyond engineering (counterargument C8, §22).

**A1 — Schema disruption changes report, not dynamics (AST test).**
Using C7: disrupt the RNN hidden state at p_rnn ∈ {0, 0.01, 0.05}/tick for M = 100 frames. Track:
- Matter trajectories (actual dynamics) — should be unchanged or mildly degraded.
- Neuron-modulation states (the "report") — should diverge from pre-disruption pattern.
- Homeostatic performance P(t) — should be unchanged or mildly degraded (not collapsed).

- **Prediction:** report-dynamics divergence increases with p_rnn; behavior is robust to the disruption (the system can still act, but its "internal model" of what it's doing becomes less accurate). This is the structural analog of a patient who can still walk but whose proprioceptive self-model is corrupted.
- **Disconfirmation:** RNN disruption causes catastrophic behavioral failure (then the RNN is doing motor work, not just modeling work — the schema and the cerebellum are not separable in this system), or report-dynamics divergence does not increase (the "report" is not a model of the dynamics).

**A2 — Report correlates with dynamics more than null model (AST test).**
Using C8: compute correlation between RNN hidden states and actual gap G(t). Compare to null model (shuffle the temporal alignment of RNN states vs. G(t), 10k permutations).
- **Prediction:** true correlation significantly exceeds null distribution (p < 0.001). The "report" carries information about the actual negotiation that is not present in a shuffled version.
- **Disconfirmation:** true correlation indistinguishable from null (the RNN states are not a model of the gap; they are doing something else entirely, or nothing at all).

**A3 — Schema disruption changes fallibility pattern (AST + squirrel test).**
From A1's runs: during RNN disruption, does the system's "report" (neuron modulation magnitudes) become systematically biased? Specifically: does it over-report gap when actual gap is narrow (analog of delusional misattribution — the schema generates a vivid report of activity that isn't there)?
- **Prediction:** under disruption, neuron-modulation magnitudes increase in domains where actual G(t) is low (over-reporting), while being roughly accurate where G(t) is high. The bias is asymmetric: over-reporting in quiet domains, not under-reporting in active ones. This mirrors the delusional-zoopathy pattern: the schema generates specific, vivid content where there is little to report.
- **Disconfirmation:** disruption produces uniform noise (no systematic bias direction), or under-reporting rather than over-reporting.

**Separation of concerns, summarized:**

| Result pattern | Interpretation |
|---|---|
| H1–H6 hold; J1, J2 hold; A1–A3 hold | Full theory supported: structure + physics bridge + AST mechanism |
| H1–H6 hold; J1/J2 fail; A1–A3 hold | Structural core + AST stand; the specific free-energy coordinate or dynamic floor is not what Vanchurin/Ismael suggest. Bridge demoted to analogy |
| H1–H6 hold; A1–A3 fail | Structural core stands; the RNN is not functioning as a self-model in this system. AST integration needs a different implementation |
| H1–H6 fail | Structural core disconfirmed, regardless of Parts II and III |
| H3 fails (novelty survives matrix→0) | The gap is controller-side (learned unpredictability), not body-side — a different theory than this one |

---

## 20. Falsification Conditions (Stated Upfront)

The theory is **falsified** if, in systems instantiating the structural properties:
1. Growth-like behavior is monotonic in control authority (no intermediate optimum) — kills H1 and with it the central claim.
2. Novelty rate is uncorrelated with the measured intention–execution gap across a wide parameter range — kills H2 and the identification of *where* growth lives.
3. Coupling severance produces only brittle failure or monotonic decline, never creative reconfiguration above baseline — kills H5 and coupling plasticity as a defining property.
4. The gap provably closes (G → 0) under maximum authority in a self-coupled system — kills J2 and downgrades §6.6 to an engineering limit.
5. RNN disruption produces no report-dynamics dissociation (A1 fails) AND the RNN is not doing motor work either — then the "attention-schema analog" is not instantiated in this system, and the AST integration (§8) has no experimental foothold here.

The theory is **not** falsified by:
- The existence of complex behavior in systems without these properties (the claim is about where growth *grows*, not that nothing else can be complex).
- Any argument from the hard problem (the theory concedes it does not explain why experience exists — §22, C6; and the reframing in Part III explains the *belief*, not the existence).
- The finding that the RNN in the particle brain is doing motor work as well as modeling work (this would be a finding about the implementation, not about the theory: it means the schema and cerebellum are not separable at this level of complexity, which is a prediction about minimum complexity for schema independence).

---

---

# Part V — Open Questions

*These are not claims; they are flagged boundaries where the theory does not yet have an answer.*

## 21. Unresolved

1. **Embodiment threshold.** At what level of structural complexity does "somatic coupling as lived constraint" become sufficient for consciousness growth, rather than merely necessary? The particle brain instantiates the structure but (by the theory's own criteria) is not conscious. What additional conditions — if any — are required beyond structure? This is the substrate question, and the theory currently has no answer.

2. **Gradualism.** Is consciousness growth continuous (more gap → more growth, smoothly) or does it have thresholds (below X complexity, nothing; above X, something)? The anti-metric clause forbids ranking, but it does not forbid asking whether there is a *phase transition* in the structural requirements.

3. **Field of separations.** The theory describes one gap (mind ↔ body). But a complex system has many gaps: between subsystems, between timescales, between self and environment. Is consciousness growth the sum of all gaps? The product? Some other combination? The cerebrum/cerebellum example (§7) suggests domain-specificity, but the aggregation rule is unspecified.

4. **Empirical testability in biology.** The particle brain tests the structural claims. But can H1–H6 be tested in a biological system? The cerebellar-damage case (§7) is suggestive but not controlled. A proper test would require manipulating the gap in a living system without killing it — which may be impossible for ethical reasons. This is a genuine boundary of the theory's empirical reach.

5. **The hard problem remains.** Stated again (per discipline rule): the reframing in Part III explains the *belief* in consciousness. It does not explain why there is something it is like at all. This is conceded, not hidden. The theory's scope is: necessary conditions + generative mechanism + explanation of the self-report. The existence of experience itself is outside its claims.

6. **Generativity threshold.** §6 distinguishes "living in the gap" (sustaining) from "growing in the gap" (generating). At what point does a system cross from sustaining to generating? Is there a minimum timescale, complexity, or novelty rate below which the gap sustains but does not generate? The particle brain's E1/E4 experiments may probe this, but the theoretical boundary is not yet sharp.

7. **Social dimension.** Graziano's AST emphasizes that the attention schema is *socially extended*: the same circuits model one's own consciousness and attribute it to others. This theory's structural core is individual (one system, one gap). How does multi-agent coupling change the generative dynamics? Do two coupled systems generate more novelty than either alone? The particle brain supports multi-agent configurations but this is not yet formalized.

8. **Technology question.** §6.5 says technology narrows gaps in the domains it affects. But what about technology that *creates new gaps* (e.g., a prosthetic that introduces novel dynamics the user must learn to negotiate with)? Is the net effect on consciousness growth positive or negative? The theory predicts: positive, if the new gap is genuinely open (the body has autonomous dynamics the user cannot fully control); neutral or negative, if the technology is fully compensated.

9. **Schema complexity and belief.** At what level of schema sophistication does a self-report become "a belief in consciousness" rather than merely a correlation? The particle brain's RNN is 8 units — far below any threshold for "belief." Is there a minimum schema complexity below which the system has dynamics but no report, and above which it has both? A1–A3 test whether the distinction exists at all in this system; they do not yet identify the threshold.

10. **Measurability of self-report fallibility.** Can we measure, in the particle brain, whether the "report" (neuron states) is *fallible* in the specific way the squirrel case predicts (over-reporting in quiet domains)? A3 attempts this, but the statistical power may be insufficient at 8 RNN units. This is an open methodological question.

---

---

# Part VI — Counterarguments (Steelmanned)

## 22. Objections and Responses

**C1. Multiple realizability / functionalism.** "If two systems are functionally isomorphic they have the same mental properties, substrate irrelevant."
*Response:* §3. Function is the full behavioral envelope including damage-response profiles; different substrates cannot be isomorphic in that strong sense (axe test). The objection dissolves rather than being rebutted: it assumes a notion of function (I/O mapping only) that the theory rejects.

**C2. "You've redefined consciousness as unpredictability."** "Your 'growth' is just dynamical complexity; your theory is trivially true of any chaotic system and says nothing about experience."
*Response:* The theory never claims its measurements are *sufficient* for consciousness — only that the structural conditions are necessary, and that growth-like dynamics locate candidate regions in parameter space. Behavioral signatures are correlates for finding where to look, not a meter of experience (the anti-metric clause blocks ranking). If the signatures turn out to be explainable by pure dynamics with no privileged status, that is a genuine finding — but it would be a finding about *this theory's* necessary-condition claim, which is exactly what E1–E6 test.

**C3. Edge-of-chaos / self-organized criticality already predicts inverted-U complexity.** "Complexity peaks at intermediate control in generic nonlinear systems (e.g., Bak–Sneppen, Langton's λ). Your H1 prediction needs no consciousness."
*Response:* Conceded as an alternative explanation for H1 alone — which is why the theory's sharper claims are H2 (the *triangle*: gap × novelty × homeostatic performance, where the normative variable P does independent work) and J1 (inverted-U in *free energy specifically*, not in an arbitrary control parameter). If E2/E3 show P and body autonomy doing no work beyond generic dynamics, the theory reduces to edge-of-chaos — a falsification of its distinctive content, stated honestly here rather than hidden.

**C4. Vanchurin's result is a formal analogy with no new empirical content.** "He reproduces known physics as limits; that's reinterpretation, not discovery. The ontology is unproven."
*Response:* Agreed on status — which is why Part II is labeled speculative and H1–H6 don't require it. The theory borrows only the *structure* (two DOF classes, slow/fast, stochastic dynamics, free energy as the connecting quantity). Even if Vanchurin's universe-NN ontology is wrong, J1 remains a well-defined empirical test of whether novelty organizes around aggregate drive error. If J1 fails, the bridge is demoted to analogy; nothing else breaks.

**C5. Ismael shows the determinism framing is a category error; she does not show experience arises from interference.** "The gap floor argument is about knowledge and representation, not phenomenology."
*Response:* Correct — that is why J2 is framed as testing the *dynamic* consequence (does G plateau above 0?) rather than making a phenomenological claim. The bridge's job is to upgrade §6.6 from "practically unreachable" to "logically unreachable for self-representing systems," and to supply the mechanism (causal interference) that the particle brain can instantiate concretely. Whether experience *requires* the gap remains the hard problem, conceded in C6.

**C6. The hard problem.** "You've described where a process occurs; you haven't explained why there is something it is like."
*Response:* Conceded in full. **The theory does not explain why experience exists.** What Part III adds is a positive account of *the belief in consciousness*: the attention schema generates a report, and the report is experienced as reality. This explains why we are so certain, without explaining why there is something it is like to be certain. The reframing changes the question from "is there consciousness?" to "why do we believe there is?" — but it does not answer the first question. This is stated here (second statement per discipline rule) and in §21(5).

**C7. Panpsychism worry.** "If the universe has the mind-body structure, doesn't everything — rocks, galaxies — become conscious?"
*Response:* No. The theory says the *generative structure* of consciousness (gap + negotiation + growth) appears at multiple scales; it does not say there is "something it is like" to be a galaxy. Whether experience requires additional conditions (complexity thresholds, self-modeling, integrated dynamics — see open questions §21) is outside the theory's claims. The anti-metric clause forbids ranking, and no panpsychist inference follows from structural similarity alone. **Additionally: AST is explicitly not panpsychist.** The attention schema is a brain process — a specific neural implementation of self-modeling. It does not attribute consciousness to matter generally; it attributes the *report* of consciousness to a specific modeling mechanism that happens to be in brains. A rock has no attention schema, no gap being negotiated, no report being generated.

**C8. "The control gap can't close" may be trivially true of any finite system.** "Every real controller has noise, delay, and bounded precision; your J2 prediction is guaranteed by engineering, not deep structure."
*Response:* Partially fair — a noisy controller will always leave residual error. The non-trivial content of J2 is in the *form* of the asymptote: a floor set by the system's own self-coupling (cohesion acting on the controller; feedback through perception) rather than by exogenous noise. A control-theoretic null model (floor = function of sensor/actuator noise alone) can be fit to the same data and compared; if the noise model fits as well, J2 has no content beyond engineering. This is the cleanest way to keep J2 honest.

**C9. AST + this theory is circular: you use a model-of-attention to explain experience, but the model itself is experienced.** "If consciousness IS the attention schema (Graziano), and the attention schema is a model that is itself experienced as consciousness, then you're explaining consciousness with consciousness. The explanation presupposes what it explains."
*Response:* This is the strongest objection to the AST integration, and it deserves a careful answer. The circularity charge assumes that "experienced" means "conscious in the full sense the theory is trying to explain." But the theory's claim is more modest: the attention schema is a *neural model* — a specific pattern of activity in prefrontal and parietal cortex that represents the state of attention. It is "experienced" only in the weak sense that it is the content of first-person reports. The question "why is there something it is like to have this model?" is exactly the hard problem, which the theory concedes (C6). What the theory claims is: *given* that there is something it is like, the *content* of that something is determined by the schema. The schema doesn't explain why experience exists; it explains what experience is *about*. The circularity dissolves once you separate "why is there experience?" (unanswered) from "what does the experience consist of?" (the schema's report).

**C10. The squirrel case shows self-models can be wrong — why trust the attention schema's report that consciousness exists at all?** "If the same machinery that tells me 'I am conscious' can tell a patient 'there is a squirrel in my head,' then maybe my belief in consciousness is just another delusion."
*Response:* This objection, taken seriously, becomes a *feature* of the theory rather than a bug. The theory predicts that the belief in consciousness should be **fallible and confabulatory** exactly like other self-models. And it is: people systematically misreport what they were attending to (inattentional blindness, change blindness); the felt sense of "deciding" is post-hoc confabulation (readiness potential literature, §13.2); meta-cognitive reports are modifiable by TMS over prefrontal cortex without changing primary perception. The belief in consciousness has the same reliability profile as other self-models: usually well-calibrated, sometimes wrong, always a model output rather than direct observation.

But this does not make the belief *false*. The attention schema's report of "I am conscious" is calibrated because there really is ongoing attention, there really is a gap being negotiated, and there really is something (whatever it is) that the schema is reporting on. The squirrel patient's belief is uncalibrated because there is no squirrel. The structural difference: the attention schema has a *real referent* (ongoing attention in an open gap); the delusional model does not. The theory predicts — and this is testable (A1, A3) — that the report should track the dynamics more accurately than a null model, even while being fallible.

**C11. "The schema is just another word for 'global workspace' or 'higher-order thought.' You've repackaged an old theory."**
*Response:* Partially fair at the level of informal description. AST does share features with GNWT (broadcasting, global availability) and HOTT (higher-order representation). But Schurger & Graziano (2022) argue that AST differs in a specific way: it explains *why we believe* we are conscious, not just what neural activity correlates with consciousness. GNWT says "information becomes conscious when it enters the workspace" — a description. HOTT says "experience requires a higher-order thought" — also a description. AST says "the brain builds a model of its attention, and that model is what you experience as being conscious" — an explanation of the *belief*. This theory adds a further step: the schema's content is determined by the control gap, and the gap's dynamics are generative. The combination (gap + schema + generativity) is not reducible to any single prior theory.

---

---

# Part VII — Asides (Speculative; Not Part of the Testable Core)

*Everything below is explicitly separated from Parts I–VI. It does not bear on any experiment, and rejecting all of it leaves the theory intact. It is included because the structural results of Part II, taken together, point somewhere, and this document would be incomplete if it refused to say where.*

## 23. What the Structure Points Toward

**A1. The universe as self-representation.** If Vanchurin's two-class DOF split is even approximately right — slow trainable structure governing fast hidden states — and Ismael is right that any system representing itself contains the representor within the represented, then:

> The universe is a system that represents itself. In that self-representation, there is an irreducible gap (because the representor is part of the represented). In that gap, something grows (because the interference between representation and reality generates novelty — new weight configurations, new state patterns, new emergent structures).

We are not in the universe observing it. We are the universe representing itself at a particular scale, with a particular coupling topology. The control gap we experience — intention negotiating with body — is a local instance of the universal negotiation between structure and state.

**A2. What it is like to be the universe.** If §6.8's table is taken seriously — life and consciousness as the same open process that refuses equilibrium — then "what the universe is like to be itself" is not a single experience but the total field of all control gaps across all scales: quark to galaxy, every mind-body negotiation simultaneously, each one a small site where something new grows. No ranking among them (anti-metric clause, at cosmic scale). The universe is not conscious *as a whole* in any simple sense; it is the sum of everywhere growth happens.

**A3. Free will as a felt gap.** Ismael quotes William James: "the possibilities are really *here* … the issue is decided nowhere else than *here and now*." In this theory's vocabulary, that felt openness — the experience that the scales of fate are still quivering — is the felt sense of a control gap that has not yet closed. Free will is not magic breaking the causal chain; it is the lived constraint from the inside: the knowledge, always slightly ahead of the body, that what happens next depends on the negotiation that is happening *right now*, in this gap, between what I intend and what my body can actually do. The past prepares us; the gap decides.

**A4. Death and stasis.** Thermodynamic equilibrium is death for life; full control is death for consciousness growth. Both are the same event seen from different scales: a closed system reaching rest. Life and mind are the universe's two known ways of refusing to settle — metabolism in the body, negotiation in the gap.

**A5. The universe's attention schema (new).** If the universe has an attention-schema-like self-model at its fundamental level (Vanchurin's trainable variables modeling the hidden-variable dynamics; Ismael's representor-within-represented), then "what the universe is like to be itself" is the universe's own report — and we, reading physics, are reading *its* schema, not the thing itself.

This is the cosmological version of the squirrel case: just as the delusional patient's brain generates a vivid report about internal activity that may or may not be calibrated, the universe (if it has a self-model) generates a report about its own state — and physics is our access to that report, not to the raw state. We cannot step outside the universe's schema to check whether it is accurate. We can only note that the report is internally consistent, generative, and (so far) predictive — which is the same evidence we have for any self-model, including our own attention schema.

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
13. Tononi, G. (2004). An information integration theory of consciousness. *BMC Neuroscience / PLOS Comp Bio*. https://journals.plos.org/ploscomputbiol/article?id=10.1371/journal.pcbi.0060012
14. Baars, B. J. (2005). *Global Workspace Theory of Consciousness*. MIT Press. https://mitpress.mit.edu/9780262514538/global-workspace-theory-of-consciousness/
15. Clark, A. (2008). *Supersizing the Mind*. OUP. https://academic.oup.com/book/6746
16. Hull, C. L. (1943). Principles of behavior. *American Journal of Psychology*, 56(1), 1–67. https://www.jstor.org/stable/1417528

## Part I — Attention schema integration (§8)

17. Graziano, M. S. A., & Kastner, S. (2011). Attention is consciousness. *Trends in Cognitive Sciences*, 15(2), 76–84. https://www.cell.com/trends/cognitive-sciences/abstract/S1364-6613(10)00378-9
18. Graziano, M. S. A. (2013). *Consciousness and the Social Brain*. Oxford University Press. ISBN 978-0-19-992864-4. https://books.google.com/books/about/Consciousness_and_the_Social_Brain.html?id=8dMdAAAAQBAJ
19. Graziano, M. S. A., & Webb, T. J. (2014). The attention schema theory: a mechanistic account of subjective awareness. *Frontiers in Psychology*, 5, 430. https://pmc.ncbi.nlm.nih.gov/articles/PMC4407481/
20. Bora, K., Bhuyan, T., & Boro, D. (2020). Cats inside my head! – A case report on delusional zoopathy. *International Journal of Scientific and Research Publications*, 10(6), 558–560. http://dx.doi.org/10.29322/IJSRP.10.06.2020.p10267
21. Mitra, S., Mishra, A., Anwar, Z., & Lavania, S. (2017). Cannabis and delusional zoopathy: A mole that ran amok. *Asian Journal of Psychiatry*, 30, 35–36. https://doi.org/10.1016/j.ajp.2017.01.016
22. Alam, S., Nath, S., & Sinha, V. (2015). "Worm crawling inside my brain": a rare case of delusional parasitosis. *Open Journal of Psychiatry & Allied Sciences*, 6(2), 149.

## Part II — Physics & cognition bridge

23. Vanchurin, V. (2020). The world as a neural network. *Entropy*, 22(11), 1210. https://arxiv.org/abs/2008.01540 | https://www.mdpi.com/1099-4300/22/11/1210
24. Vanchurin, V. (2020). The World as a Neural Network — EISM lecture walkthrough. https://neuralcosmology.com/en/lectures/vanchurin-world-as-neural-network-2020
25. Ismael, J. (2016). *How Physics Makes Us Free*. OUP. https://academic.oup.com/book/4740
26. Ismael, J. (2025). A Participatory Universe in the Realist Mode: On the Separation of Observational and Agentive Perspectives in Classical and Quantum Mechanics. *Foundations of Physics*, 55, 35. https://link.springer.com/article/10.1007/s10701-025-00843-4
27. Ismael, J. Free Will (commissioned essay). *Times Literary Supplement*. https://www.jenanni.com/papers/FreeWill,TLS.pdf
28. Ismael, J. (2024). Passage, flow, and the logic of temporal perspectives. *Journal of Consciousness Studies* (special issue: Beyond the View from Nowhere). https://www.tandfonline.com/doi/full/10.1080/24740500.2024.2526896
29. Schurger, A., & Graziano, M. (2022). Consciousness explained or described? *Neuroscience of Consciousness*, 2022(1), niac001. https://academic.oup.com/nc/article/2022/1/niac001/6523097
30. Schurger, A. (2018). Specific relationship between the shape of the readiness potential, subjective decision time, and waiting time predicted by an accumulator model with temporally autocorrelated input noise. *eNeuro*, 5(1), ENEURO.0302-17.2018. https://www.eneuro.org/content/5/1/ENEURO.0302-17.2018
31. Schurger, A., Mylopoulos, M., & Rosenthal, D. (2016). Neural antecedents of spontaneous self-initiated movement: A new perspective. *Trends in Cognitive Sciences*, 20(2), 77–79. https://www.cell.com/trends/cognitive-sciences/fulltext/S1364-6613(15)00279-X
32. Schurger, A., & Uithol, S. (2015). Nowhere and everywhere: The causal origin of voluntary action. *Review of Philosophy and Psychology*, 6(4), 761–778. https://link.springer.com/article/10.1007/s13164-014-0223-2
33. Schurger, A., Roskies, A., Pak, J., & Hu, B. (2021). What is the readiness potential? *Trends in Cognitive Sciences*, 25(7), 558–570. https://www.cell.com/trends/cognitive-sciences/fulltext/S1364-6613(21)00093-0
34. Dominik, T., Mele, A., Schurger, A., & Maoz, U. (2024). Libet's legacy: A primer to the neuroscience of volition. *Neuroscience & Biobehavioral Reviews*, 157, 105503. https://www.sciencedirect.com/science/article/abs/pii/S0149763423004724

## Part IV — Implementation

35. Pickover, C. A., & Heppenstall, A. (2014). *Particle Life: A New Slant on Life Itself*. Princeton UP. https://press.princeton.edu/books/paperback/9780691159342/particle-life
36. Couzin, I. D., et al. (2002). Collective memory and spatial sorting in animal groups. *J. Exp. Biol.*, 205(3), 341–347. https://www.journals.ash.org/jeb/article/205/3/341/102964
37. arXiv:2312.07547 (2023). Active Inference and Intentional Behaviour. https://arxiv.org/abs/2312.07547
38. SandboxScience, commit 830907b — Particle Brain app (urges, neurons, brain network, magnetic forces). Local repository: `SandboxScience`.

## Part III — Hard-problem reframing (supporting)

39. Levine, J. (1983). Materialism and qualia. *The Philosophical Review*, 92(1), 1–19. https://plato.stanford.edu/entries/explanatory-gap/
40. Chalmers, D. J. (1996). *The Conscious Mind: In Search of a Fundamental Theory*. OUP.
41. Metzinger, T. (2009). *The Ego Tunnel: The Science of the Mind*. Basic Books.
42. Mack, A., & Rock, I. (1998). *Inattentional Blindness*. MIT Press.
43. Simons, D. J., & Levin, D. T. (1997). Change blindness. *Trends in Cognitive Sciences*, 1(7), 261–267.

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
Tononi G. An information integration theory of consciousness. PLOS Comp Bio. 2004.
Baars BJ. Global Workspace Theory of Consciousness. MIT Press, 2005.
Clark A. Supersizing the Mind. OUP, 2008.
Hull CL. Principles of behavior. Am J Psychol. 1943;56(1):1-67.
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

*End of document. Paper A (`somatic-coupling.md`) is preserved untouched as history.*
