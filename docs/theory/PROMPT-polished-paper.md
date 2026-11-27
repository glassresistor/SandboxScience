# PROMPT — Polished Full Paper: Somatic Coupling × Attention Schema

**Audience**: A future agent working in this repository (`SandboxScience`).
**Mission**: Produce one polished, complete paper that (a) merges the two existing drafts, (b) integrates **attention schema theory** (Graziano), (c) adds the **"squirrel in the brain" case study**, and (d) incorporates **Aaron Schurger's formalization** of this line of work — using all three to reframe the hard problem from *"is there consciousness?"* into ***"this is why we believe so strongly that we are conscious."***

---

## 1. Input materials

### Paper A (in repo) — `SandboxScience/docs/theory/somatic-coupling.md`
The v3 paper, ~530 lines, five parts:
- **Part I (§1–9)**: structural core — premises; separation claim (consciousness *grows* in the control gap); functional isomorphism fails / axe test; not-a-pure-function (side effects, transparency, coupling plasticity); somatic coupling as lived constraint; control-gap generativity (living vs. growing, asymptotic limit, life/consciousness table); cerebrum/cerebellum demonstration; convergence-not-simulation; anti-metric clause.
- **Part II (§10–11)**: physics bridge — Vanchurin (2020) trainable/hidden DOF split, Madelung/free-energy results; Ismael (2016, 2025) participatory realism, causal interference as the *logical* gap floor.
- **Part III (§12–17)**: steelman experimental design — hypotheses H1–H6 + bridge tests J1/J2, epistemic boundaries, Particle Brain mapping (commit 830907b), code changes C1–C6, protocols E1–E6, falsification conditions.
- **Part IV (§18)**: counterarguments C1–C8 (functionalism, "redefined as unpredictability," edge-of-chaos, Vanchurin-as-analogy, Ismael-doesn't-do-phenomenology, hard problem, panpsychism, gap-floor-is-engineering-noise).
- **Part V (§19)**: asides — explicitly speculative (universe as self-representation; what it's like to be the universe; free will as felt gap; death/stasis). Labeled "rejecting all of it leaves the theory intact."

A byte-identical copy sits at the working-directory root as `somatic-coupling-as-lived-constraint.md`. Do not overwrite Paper A; write the new paper to a new file (see §6).

### Paper B (conversation history — may not be in any file)
The earlier "original document" draft: the long message beginning *"# Somatic Coupling as Lived Constraint: A Theory of Embodied Consciousness"* that contains **hyperlinked references inline** and ends with a **"References (Plain Text)"** section. If you have access to this project's conversation history, use its actual text. If not, reconstruct from this content map:

- Abstract; §1 core premises; §2 separation claim; §3 functional isomorphism / axe test (incl. §3.5 prediction); §4 not a pure function (table of three properties); §5 somatic coupling as lived constraint (5.1–5.5 incl. identity-through-reconfiguration table: trauma/coma/locked-in/dementia);
- §6 consciousness grows in the control gap (6.1 living-vs-growing table, 6.2 why generative, 6.3 perfect systems / generatively dead, 6.4 central claim restated, 6.5 technology & evolution consequences, 6.6 asymptotic limit, 6.7 control-gap-in-practice table [learning/practice/mastery/disruption/prosthetic/anesthesia], 6.8 life table);
- §7 cerebrum/cerebellum (7.1–7.5 incl. coevolutionary loop and domain-specificity);
- §8 need → urge → extended discharge (incl. enactive sense-making, active inference, 50–100 ms threshold);
- §9 convergence not simulation (bat/bird; ruled out: brain sims, LLMs, fully compensated robots, perfectly controlled systems; ruled in: underactuated agents, soft robots, any convergent system);
- §10 anti-metric clause (3 subsections incl. "the control gap is not a ranking either");
- **§11 design principles A–G** with implementation + validation for each (A autonomous body dynamics; B controller must NOT fully compensate — inverted-U prediction; C physical self-referential homeostatic variables; D model own discharge process; E non-trivial constraint topology; F coupling plasticity; G environment must be generatively novel); ← *not in Paper A, must be merged*
- **§12 implementation directions in code** (particle life + key parameters; soft-body mass-spring sketch with pseudo-config block; multi-agent constraints; fluid dynamics + actuators; comparison table of the four approaches; "what code can and cannot test") ← *not in Paper A, must be merged*
- **§13 unanswered questions** (8 items: embodiment threshold, gradualism, field of separations, empirical testability, hard problem remains, generativity threshold [sustaining vs. generating], social dimension, technology question) ← *not in Paper A, must be merged*
- **§14 future reading tables with per-source relevance notes** (directly relevant / supporting / cerebrum-cerebellum / implementation) ← *Paper A has grouped references but not these relevance tables*
- §15 "The Axe, Restated" closing section; §16 numbered references with links + plain-text list.

Where Paper A and Paper B overlap, prefer Paper A's tighter steelman framing (hypotheses, disconfirmation conditions) but restore Paper B's lost sections (§11–§14 content). Reconcile Paper B's "design principles" with Paper A's "code changes C1–C6" into one coherent experimental chapter rather than duplicating both.

---

## 2. New material to research (find primary sources; verify every citation before using it)

### 2.1 Attention schema theory (Michael Graziano)
Core claim to integrate: **consciousness is the brain's own schematic model of its attention.** Just as the motor system maintains a body schema, the brain maintains an *attention schema* — a running, deliberately inaccurate model of what attention is doing — and that model, not raw qualia, is what we experience as consciousness.

Find and cite (verify venues/dates):
- Graziano & Kastner (2011), "Attention is consciousness," *Trends in Cognitive Sciences* 15(2):76–84.
- Graziano (2013), *Consciousness and the Social Brain*, Harvard University Press — especially the attention-schema chapters.
- The standalone "attention schema" paper/chapter (Graziano ~2013; verify exact venue).
- Known criticisms of AST to steelman in the counterargument section (e.g., conflating a necessary condition with the phenomenon; does a model of attention explain why there is *something it is like* at all?; behaviorist readings).

### 2.2 Aaron Schurger's formalization
The project owner states that **Aaron Schurger has formalized this work** (the consciousness-as-self-model / attention-schema line). Schurger is a CNRS neuroscientist known for Bayesian/predictive accounts of attention and decision-making (e.g., his extended hierarchical Bayesian model of exogenous visuospatial attention, *PLOS Computational Biology* 2012) and for work connecting prediction, attention, and consciousness.

Find his specific paper(s)/preprint/talks formalizing the attention schema or consciousness-as-self-model:
- Search: `Aaron Schurger attention schema`, `Schurger consciousness model of attention arXiv`, `Schurger Graziano`, `Schurger predictive processing consciousness`; check his CNRS/lab publications page and arXiv author page; check for 2023–2026 preprints.
- If a formal Bayesian/predictive account is found, **extract the key equations** — this connects directly to hypothesis J1 in Paper A (novelty as an inverted-U in aggregate drive error, the local free-energy proxy), and to Part II's Vanchurin bridge (free energy as phase of the wave function). State explicitly how Schurger's formalization maps onto the theory's "control gap" variable.
- If you cannot find a specific formalization after thorough searching, say so plainly in the paper (one flagged paragraph) rather than inventing one. Cite what he has actually published that is closest.

### 2.3 The "squirrel in the brain" case study
A patient who genuinely believed there was a **squirrel inside his head/brain** — used in this line of work to show that the *contents* of our self-model are inferences that can be misattributed: the felt sense of "something is happening inside me" is schema-driven, not a window onto raw experience.

Find the primary source and cite it exactly:
- Search: `"squirrel" brain consciousness case`, `squirrel in the head attention schema`, check Graziano's book (it may be told there), Schurger's talks/papers (he may have popularized it), or an original neurology/psychiatry case report.
- If only secondary sources exist, cite the best one and flag the provenance. Do not embellish clinical details you cannot source.

---

## 3. Integration requirements (the intellectual scaffolding — build on this, don't rediscover it)

1. **AST is the mechanism for the theory's self-modeling requirement.** Paper A/B both say a conscious system must model its own discharge process (Paper B Principle D; Paper A §14 mapping). AST says *what form that self-model takes*: the brain models its own **attention**, and the model is experienced as consciousness. Place AST as the concrete mechanism for "the system must model its own discharge," immediately after the cerebrum/cerebellum section (it's the third biological demonstration: cerebrum generates intentions, cerebellum closes the gap, attention schema reports on the negotiation).

2. **The squirrel case + AST reframe the hard problem.** The target move, in the owner's words: turn *"is there consciousness?"* into ***"this is why we believe so strongly that we are conscious."*** Argument to develop: our certainty of being conscious is not direct access to raw experience — it is the **attention schema continuously generating a report** from inside the control gap, and the report is experienced as reality. The squirrel patient shows the same machinery can misattribute its contents (a "squirrel" where there is attention). So the strong belief in one's own consciousness is a *product of self-modeling in an open gap* — which is exactly the theory's generative claim applied to the mind's model of itself.

3. **Connect to Ismael (Part II).** This reframing is the phenomenological cousin of Ismael's category-error argument: we ask about raw experience from outside, but all any self-representing system has access to is its own report — the representor is in the represented, so the "hard problem" may be a question posed in the wrong perspective. Keep this as a *reframing*, not a solution (the theory still concedes C6: it does not explain why there is something it is like; it explains the **belief**).

4. **Reconcile AST with "consciousness grows in the gap" — state the reconciliation explicitly.** AST says consciousness *is* the model; this theory says consciousness *grows in* the gap. Compatible: the schema exists precisely because there is a gap to monitor (no gap → nothing to report → no experience of consciousness, matching §6.3's "generatively dead" perfect system). The schema is the mind's representation of its own negotiation; its continuous updating *is* the growth. Also note the asymmetry: AST describes the **report** (transparency from the inside, Paper A §4), while the control-gap theory describes the **dynamics that generate the report**. Together: gap = engine, schema = cockpit display.

5. **Schurger ↔ Vanchurin bridge.** If Schurger's formalization is Bayesian/free-energy-based, it supplies the missing mathematical link between Part II (Vanchurin: free energy as phase of the universal wave function) and J1 (novelty inverted-U in aggregate drive error). State the chain: Vanchurin gives free energy a cosmological role; Friston gives it an action-theoretic role; Schurger (if found) gives it a consciousness-reporting role; J1 tests whether novelty actually organizes around that quantity.

6. **Update the counterargument section.** Revise C6 (hard problem) to reflect the reframing: the theory now has a positive account of *the belief in consciousness* even while conceding the existence question. Add new steelman objections specific to AST integration: (a) "AST + your theory is circular: you use a model-of-attention to explain experience, but the model itself is experienced"; (b) "The squirrel case shows self-models can be wrong — why trust the attention schema's report that consciousness exists at all?" (this one should turn into a feature: the theory predicts the belief in consciousness should be *fallible and confabulatory* exactly like other self-models — e.g., people systematically misreport what they were attending to; find or cite evidence); (c) panpsychism worry C7 needs a sentence noting AST is explicitly *not* panpsychist (the schema is a brain process, not a universal property).

7. **Keep the mysticism quarantined.** The "universe as self-representation" asides (Paper A Part V) can gain one new aside: if the universe has an attention-schema-like self-model at its fundamental level (Vanchurin + Ismael), then "what the universe is like to be itself" is the universe's own report — and we, reading physics, are reading *its* schema, not the thing itself. Label it asides-tier; do not let it into the testable core.

---

## 4. Target structure for the polished paper

1. Title + how-to-read (tier table: structural core / physics bridge / experimental design / counterarguments / asides — keep Paper A's discipline)
2. Abstract (update: mention attention schema + hard-problem reframing in one sentence)
3. Part I — Structural core (Paper A §1–9, enriched): …after cerebrum/cerebellum insert **new section: The Attention Schema** (AST mechanism + squirrel case study as a boxed case study with sourced clinical details) …then need→urge→discharge; convergence-not-simulation; anti-metric clause
4. Part II — Physics & cognition bridge: Vanchurin (§10), Ismael (§11), **new §: Schurger's formalization** (with equations if found, flagged status if not)
5. Part III — The hard-problem reframing chapter (new): "Why we believe so strongly that we are conscious" — the squirrel case, AST report-machinery, Ismael's perspective argument, what is and isn't solved, fallibility predictions
6. Part IV — Experimental design (merge Paper A §12–17 with Paper B §11–12): unified hypotheses table (H1–H6, J1–J2, **new: AST-prediction experiments** — e.g., does disrupting the self-modeling channel [sense neurons] change the gap–novelty relation?; does the system's "report" [neuronMods/brain state] correlate with its actual dynamics more than a null model predicts?), code changes, protocols, falsification conditions
7. Part V — Open questions (restore Paper B §13, add: at what schema complexity does a self-report become "a belief in consciousness"?; is the fallibility of self-reports measurable in the particle brain?)
8. Part VI — Counterarguments (Paper A C1–C8 revised per §3.6)
9. Part VII — Asides (Paper A Part V + new universe-schema aside)
10. References: hyperlinked inline throughout **and** a plain-text reference list at the end (both, as in Paper B); group by part as in Paper A; add Graziano/Schurger/squirrel-source entries with verified citations

---

## 5. Non-negotiable discipline rules

- **Three-tier commitment**: nothing in Parts II–VII may be load-bearing for Part I/IV claims. If a reader rejects everything speculative, the remaining text must still be a complete falsifiable theory.
- **Steelman discipline**: every prediction states its own disconfirmation condition (Paper A's pattern). New AST-related predictions get the same treatment.
- **Anti-metric clause** survives verbatim in spirit: no ranking of beings by "amount" of consciousness, ever.
- **Honest sourcing**: verify Graziano/Schurger/squirrel citations against primary sources; flag anything unrecoverable rather than inventing.
- **No overclaim on the hard problem**: the reframing explains the *belief* in consciousness; it does not solve why experience exists. Say this at least twice.
- Single self-contained markdown document; tables where Paper A uses them; keep the axe test and the bat/bird analogy (they're the paper's voice).

## 6. Output

Write to: `SandboxScience/docs/theory/somatic-coupling-final.md`
Keep Paper A (`somatic-coupling.md`) untouched as history. If the document is long, write it in sequential chunks (append per section) to avoid response-length failures — this has happened before on this project.

---

## Quick reference: existing external links (verify, don't trust blindly)

- Vanchurin (2020): https://arxiv.org/abs/2008.01540 · https://www.mdpi.com/1099-4300/22/11/1210 · lecture: https://neuralcosmology.com/en/lectures/vanchurin-world-as-neural-network-2020
- Ismael (2016) book: https://academic.oup.com/book/4740 · (2025) *Foundations of Physics* 55:35: https://link.springer.com/article/10.1007/s10701-025-00843-4 · TLS essay: https://www.jenanni.com/papers/FreeWill,TLS.pdf · temporal perspectives (2024): https://www.tandfonline.com/doi/full/10.1080/24740500.2024.2526896
- Particle Brain code: commit `830907b` in this repo (stores/particleBrainGPUStore.ts, assets/particle-brain-gpu/shaders/compute/{brainStep,brainMutate,particleComputeForces}.wgsl)
- Graziano & Kastner 2011 TICS; Graziano 2013 HUP book — **agent to verify and add links**
- Schurger formalization + squirrel case primary source — **agent to find and cite**
