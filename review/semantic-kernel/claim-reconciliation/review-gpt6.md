# Nonauthor advisory review

**Verdict: ACCEPT WITH LIMITATIONS.** The reconciliation direction is sound. Four corrections below are required before the packet is reused. This verdict is advisory source review, not an OpenSpec gate, implementation authorization, whole-paper acceptance or mathematical certification.

I reviewed all 18 findings and 59 cited excerpts against the 20 frozen source files at `4d42600082d4213d34ac5ab4b0dfc3eefde23d5e`, including surrounding definitions and theorem statements. I did not author the root packet. I previously authored kernel fixtures and corpus triage/research, but not the corpus-provenance-adjudication normative proposal, design, specs or tasks. Requested identity: GPT-6 through the stock Codex harness. Provider model/request telemetry is unavailable; none is invented.

## Required corrections

1. **CL03 — wrong locator.** `algebra/MODEL.md:59–62` discusses the parser bug. Non-idempotence is stated at **55–58**, opposed to the idempotence claim at **77–79**. The diagnosis is correct; rebind the supporting excerpt.
2. **CL02 — families, not constructors.** `Independence.Term` has nine constructors. The result distinguishes four primitive families through `usesLed`, `usesProp`, `usesCmp` and `usesPost`. Replace “four constructors” accordingly. This remains syntactic independence, not denotational minimality.
3. **CL08 — incomplete locator.** `MODEL.md:98–107` includes the 3,140 figure but misses the eight-rule assertion at **94–97**. Use **94–104** to support both. Ledger R9 supplies the historical correction; this review does not verify its large cardinality estimate.
4. **CL11 — stale breadth.** “The proposed operational sprints remain unimplemented” is too broad at this revision. `DefiKernel.Metatheory.runGroup_assoc` and `groupEquivalent_assoc` already exist. Name the remaining operational Interface/n-ary work specifically. Historical `Defialgebra.Nary` itself still proves static binding agreement only.

## Mathematical scope checks

**CL04: one pass versus stabilization.** The correction properly avoids treating one-pass non-idempotence as a refutation of finite stabilization. A deflationary map on a finite powerset stabilizes; monotonicity carries through iteration. The stabilized map is idempotent and has the original fixed points. These facts do not show preservation of the requirement family, and do not recover the rejected meet formula. Keep those questions separate.

**CL06: closure versus induced order.** The proposed distinction is correct. For example, `{∅,{a},{b},{a,b,c}}` is a lattice under inclusion although the union of `{a}` and `{b}` is absent. There is, however, a valid stronger route for a *purely negative prohibition*: if two fully admissible sets have a union containing a forbidden set, every common upper bound contains it too. That pair then has no admissible upper bound. Preserve this conditional argument; do not call the stronger conclusion false merely because the cited corollary proves less. The packet has not established such a full-instance witness. Clause polarity alone remains insufficient.

**CL09: construction versus framework.** The bounding-pair obstruction is exactly the chain `x ≤ Γ(x) ≤ Δ(x) ≤ x`. It does not exclude other approximators. The bilattice result relies on the particular rectangle-preserving construction family and a diagonal with at least two elements. Add `paper/atlas.tex:498–552` to bind that grammar and argument directly. No external representation theorem was re-audited here.

**CL15: concrete correspondence.** `reachCl_antiExchange_iff` quantifies over an arbitrary relation and characterizes antisymmetry of its reflexive-transitive closure. Acyclicity suffices; the theorem does not encode the concrete 58-element extraction. Sampled equality cannot supply the missing all-input bridge. A structural correspondence proof would suffice—enumerating all `2^58` inputs is not required. The conflicting arc tables must retain their separate identities.

**CL17: width versus majority.** The correction is justified. The formula `x₁ ∧ (x₁ ∨ ⋯ ∨ x₃₄)` has a wide clause but is equivalent to `x₁`, whose model relation is majority-closed. A triple satisfying one clause may fail other clauses. Require a full-instance argument; an explicitly checked triple is sufficient, but an exact analytic proof of its existence is also legitimate. Do not make enumeration the only allowable proof method.

The remaining directions are supported with their declared limits: CL01 is a model-source counterexample; CL05 preserves the full predicate; CL07 distinguishes universal closure from existential failure; CL10 restricts the selector grammar and original aggregate; CL12 retains confinement, neutrality, initialization and protected totals; CL13–14 retain syntax/keyword scope; CL16 preserves incompatible measurement identities. CL18 correctly preserves repaired meet and acyclicity statements. Its cited formalization paragraph still attributes complexity to `thm:excomp` although the current cost claim is in `prop:excost`; repair that cross-reference during editing.

## Evidence boundary

[The JSON review](review-gpt6.json) records every claim assessment, exact input hashes and **353 passing provenance checks**. All 88 frozen Sprint 10 inputs, source snapshots and packet artifacts remained unchanged. The first mechanical hash pass followed initial read-only inspection; exact frozen manifest and Git bytes bind those reads, but no pre-read hash measurement is claimed.

Packet manifest SHA-256: `9f886ac32fa99d913d8ba132256c84b9a2b813a5691f59301e108554186d4d6b`.
JSON review SHA-256: `73a7fe07dff879d97b9a6c88ee9060d5bb0e01352cdb460da2b693d347964581`.

No old generators, numerical probes, native tools, Lean builds or axiom audits were executed. Historical `Independence.lean` uses `native_decide`; this review does not recertify it under current kernel proof policy. The elementary arguments above are review reasoning, not newly machine-checked results. Originals remain untouched.
