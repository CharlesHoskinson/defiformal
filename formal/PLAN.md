# DeFi Atlas Quint Model Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans`. Steps use checkbox syntax for tracking.

**Goal:** Build and check a layered Quint model of the DeFi taxonomy.

**Architecture:** Encode source data as pure Quint relations. Add raw, legal, and reflexive state machines. Use a separate analyzer for graph and bounded-set calculations.

**Tech Stack:** Quint 0.32.0, Node.js 24, ECMAScript modules.

## Global Constraints

- Do not run Graphify.
- Do not build a knowledge graph.
- Do not modify files outside `/root/DefiElements/formal/`.
- Preserve source defects in the report.
- Report every reduced model-checking bound.
- Do not commit because a commit modifies `.git` outside `formal/`.

---

### Task 1: Findings Skeleton and Data Contract

**Files:**

- Create: `formal/FINDINGS.md`
- Create: `formal/atlas_test.qnt`
- Create: `formal/atlas.qnt`

**Interfaces:**

- Consumes: the four authoritative source files.
- Produces: `Element`, `Law`, `Hazard`, and `Protocol` relations.

- [ ] Write `FINDINGS.md` with the confirmed intake discrepancies.
- [ ] Write a Quint test that imports the absent `atlas` module.
- [ ] Run `quint typecheck formal/atlas_test.qnt` and confirm the missing-module failure.
- [ ] Add the smallest `atlas` module and vocabulary types.
- [ ] Run `quint typecheck formal/atlas.qnt` and `quint run formal/atlas.qnt`.

### Task 2: Closure and Protocol Checks

**Files:**

- Modify: `formal/atlas.qnt`
- Modify: `formal/atlas_test.qnt`

**Interfaces:**

- Consumes: `laws`, `protocolElements`, and `satisfiesClosure`.
- Produces: fixed checks for all 12 protocol sets.

- [ ] Add failing protocol expectations before the closure implementation.
- [ ] Confirm that the tests fail because `satisfiesClosure` is absent.
- [ ] Implement fired-law and requirement-term evaluation.
- [ ] Run `quint typecheck`, `quint test`, and sampled `quint run`.
- [ ] Record each protocol result and each missing term.

### Task 3: Assembly Machines and Hazard Projection

**Files:**

- Modify: `formal/atlas.qnt`
- Modify: `formal/atlas_test.qnt`

**Interfaces:**

- Consumes: closure and projected hazard relations.
- Produces: `rawAssembly`, `legalAssembly`, `closure`, and `hazardFree`.

- [ ] Add tests for one-element addition and projected hazard polarity.
- [ ] Confirm the tests fail before actions and predicates exist.
- [ ] Implement `init`, `addOne`, and `step` in the raw module.
- [ ] Implement guarded `addLegal` and `step` in the legal module.
- [ ] Run simulation witnesses for nonempty assembly states.
- [ ] Run bounded verification on the full universe if feasible.
- [ ] Run bounded verification on named reduced universes if full verification is infeasible.

### Task 4: Reflexive Temporal Model

**Files:**

- Modify: `formal/atlas.qnt`
- Modify: `formal/atlas_test.qnt`

**Interfaces:**

- Consumes: the `As`, `Rd`, `Ex`, `Pl`, `Ix`, and `Em` Terra set.
- Produces: reflexive transitions and the `eventualRecovery` temporal property.

- [ ] Add a failing reachability test for a depegged reflexive state.
- [ ] Implement shock, endogenous defense, and exogenous recovery actions.
- [ ] Run sampled traces that witness the reflexive spiral.
- [ ] Run bounded temporal verification where Quint supports the property.
- [ ] Record any fairness or backend limitation.

### Task 5: Independent Static and Bounded Analysis

**Files:**

- Create: `formal/analyze.mjs`
- Create: `formal/analyze_test.mjs`

**Interfaces:**

- Consumes: `data.ts` and `protocols.ts` only.
- Produces: JSON results for closure, ranks, hazard projections, and legal-set order.

- [ ] Write failing analyzer tests for OR terms, unsupported subjects, polarity, and lattice meets.
- [ ] Implement an independent parser without importing `laws.ts`.
- [ ] Compute protocol closure results.
- [ ] Compute strict and choice-aware graph ranks.
- [ ] Compare graph ranks with hand strata.
- [ ] Enumerate bounded legal sets and candidate-property counterexamples.
- [ ] Test whether the bounded legal order has joins and meets.

### Task 6: Findings and Final Verification

**Files:**

- Modify: `formal/FINDINGS.md`

**Interfaces:**

- Consumes: fresh Quint and analyzer output.
- Produces: the final evidence-based report.

- [ ] State what the model covers and excludes.
- [ ] List exact commands, bounds, and results.
- [ ] Separate confirmed hazards, projected hazards, and hypotheses.
- [ ] Answer questions 10 through 14.
- [ ] Explain visualization implications.
- [ ] End with the single most surprising finding.
- [ ] Run all typechecks, tests, simulations, verifications, and analyzer checks again.
- [ ] Inspect `git diff -- formal` and confirm that no requested artifact is missing.

