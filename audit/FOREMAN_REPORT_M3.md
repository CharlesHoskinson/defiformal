# Cold Audit Report: M3 Nary with M1 and M2 Context

## Verdict

**APPROVE**

M3 meets the stated constraint-level milestone. It defines a global binding set and proves bracket-independent agreement through associative union.

The negative companion is load-bearing and has a concrete three-port witness. The file does not claim operational `⋈` associativity, `GlueSt` reachability, or corpus adequacy.

The remaining gaps concern integration and stronger API statements. They do not invalidate the M3 theorem package.

## Audit Snapshot

- Audit date: 2026-08-07
- Repository commit: `f559c47`
- Branch: `positive-program/phase2-honest-corpus`
- Lean toolchain: `4.33.0-rc2`
- Lake version: `5.0.0-src+d8b1897`
- Primary file: `lean/Defialgebra/Nary.lean`
- Context files: `Interface.lean` and `FlowPolarity.lean`
- Specification: `INTERFACE-COUNCIL.md` sections 2 and 6, plus `M3-DESIGN.md`

The M2 and M3 source files were untracked at this snapshot. `Defialgebra.lean` and `Axioms.lean` contained related uncommitted changes.

## Criteria Summary

| Criterion | Result | Evidence summary |
|---|---|---|
| 1. Build hygiene | **PASS** | Project and scoped files compile. No `sorry`, `admit`, or custom axiom occurs in scope. |
| 2. Global binding and bracket independence | **PASS** | `Binding`, `Agrees`, `Binding.union`, `union_assoc`, and `agrees_union_assoc` implement the constraint-level contract. |
| 3. Negative companion | **PASS** | `pairLocal_excludes_skip` uses cut disjointness. `skip_not_pairLocal_witness` supplies a concrete inhabited skip case. |
| 4. Scope honesty | **PASS** | The module excludes transitions, reachability, M1 lifting, and M4 corpus work. It does not define operational `⋈`. |
| 5. Council-plan gaps and risks | **PARTIAL** | The core result is present. Port exposure, finite-family composition, and quotient-loss modeling remain outside the theorem package. |
| 6. M4 next actions | **PASS** | The ranked list below contains corpus work only. |

## 1. Build Hygiene: PASS

The following command completed successfully from `lean/`:

```text
lake build
Build completed successfully (977 jobs).
```

These scoped file gates also returned exit code zero:

```text
lake env lean Defialgebra/Nary.lean
lake env lean Defialgebra/Interface.lean
lake env lean Defialgebra/FlowPolarity.lean
```

A source scan found no `sorry`, `admit`, top-level `axiom`, or top-level `opaque` declaration in the audited files.

`lake env lean Axioms.lean` reported only standard axioms for the M1, M2, and M3 declarations:

```text
propext
Classical.choice
Quot.sound
```

The M3 declarations checked were:

- `Defialgebra.Nary.agrees_union_assoc`
- `Defialgebra.Nary.pairLocal_excludes_skip`
- `Defialgebra.Nary.skip_not_pairLocal_witness`

`Nary.lean` compiled without file-local warnings. The full build replayed existing lint warnings, mainly from `Interface.lean` and older modules.

The `Interface.lean` warnings concern header and module-doc placement. They do not affect theorem soundness or M3 approval.

## 2. Global Binding and Bracket-Independent Agreement: PASS

The council requires stable global names and an n-ary global binding set. `M3-DESIGN.md` narrows this to constraint-level composition by set union.

`Nary.lean:43-59` uses one global index type for machines, bindings, and states. `Binding.pairs` is a finite set of global index pairs.

`Nary.lean:61-75` proves that agreement depends on symmetric closure. Pair orientation therefore does not change the agreement predicate.

`Nary.lean:77-89` defines binding union and proves:

```lean
Agrees (B₁.union B₂) s ↔ Agrees B₁ s ∧ Agrees B₂ s
```

`Nary.lean:91-105` proves exact binding equality under reassociation. It then transports that equality to agreement.

```lean
(B₁.union B₂).union B₃ = B₁.union (B₂.union B₃)
```

This result establishes bracket independence for the modeled constraint union. It does not establish operational associativity for composite transition systems.

## 3. Negative Companion: PASS

`Nary.lean:107-119` defines a binary cut with disjoint sides. `PairLocal` requires each listed edge to cross that cut.

`SkipEdge` requires two distinct endpoints on the left side. This property can hold because the left side need not be a singleton.

`pairLocal_excludes_skip` at lines 122-127 is load-bearing. Its proof uses all three relevant facts:

- The edge belongs to the pair-local set.
- Pair locality puts one endpoint on the right side.
- Cut disjointness contradicts the skip edge's left-side membership.

The concrete witness at lines 129-151 prevents an empty-domain proof. Its cut is `{0,2} | {1}`, and `(0,2)` is a proved skip edge.

For every edge set containing `(0,2)`, the witness proves that the set is not pair-local for this cut. The membership premise is satisfiable by the singleton set.

The theorem is intentionally cut-local. It does not formalize quotient-class name loss in the original binary `⋈` design.

## 4. Scope Honesty: PASS

`Nary.lean:31-35` explicitly excludes these claims:

- Operational transition systems and reachability
- Lifting M1 conservation through transitions
- Corpus adequacy

The file defines no `⋈` operator and no `GlueSt` type. It also makes no reachability or corpus theorem.

The strongest prose claim is bracket independence for constraint union. The proved theorem supports that claim exactly.

The prior files also state honest boundaries. `Interface.lean:24-28` excludes polarity and associativity. `FlowPolarity.lean:27-31` excludes M3 and M4.

## 5. Gaps and Risks Relative to the Council M3 Plan: PARTIAL

### A. Exposed ports are not connected to bindings

`Machine.ports` is declared at `Nary.lean:45-47`, but no later declaration uses it. A binding can contain indices outside every machine footprint.

This omission does not affect union associativity. It leaves stable port exposure as a modeling convention instead of a checked invariant.

### B. N-ary composition is represented by repeated binary union

The file proves ternary reassociation and commutativity. It does not define a finite-family union, fold, or explicit n-ary composite object.

Repeated union gives the intended algebraic result. A future corpus mapping must still construct the global binding set itself.

### C. Symmetric-closure extensionality is derivable but not stated directly

The design contract requests agreement invariance when two bindings have equal symmetric closures. `agrees_iff_agrees_sym` supplies the key lemma.

The file does not package the requested two-binding implication as a named theorem. This is an API gap, not a proof gap.

### D. The negative theorem is cut-local

The theorem proves that a same-side edge cannot occur in one cross-cut edge set. It does not quantify over binary composition schedules.

It also does not model the quotient classes mentioned in `INTERFACE-COUNCIL.md` section 2. Therefore, it does not prove operational unstatability of binary `⋈`.

This limitation is consistent with the module's stated scope. It must remain visible during M4 interpretation.

### E. M1, M2, and M3 remain separate models

M1 uses ledger states and confined transitions. M2 uses natural-number flows and polarity. M3 uses integer-valued states and binding constraints.

No theorem connects these representations. The separation is acceptable for M3, but M4 cannot infer corpus adequacy from their coexistence.

## Prior M1 and M2 Context

The M1 and M2 headline declarations compile and use only standard axioms. Their negative companions also compile.

M1 establishes the non-shareable-total discipline for its abstract ledger model. M2 establishes local and directed anti-caller inequalities for its flow model.

Neither result upgrades M3 into an operational composition theorem. The report treats them as context only.

## 6. Ranked Next Actions for M4 Only

1. **Fix the Pendle backing invariant first.** Evaluate backing at the true `syRate`. Add the stale-index reachable-state case as a regression test.
2. **Re-annotate L3 `total*` fields.** Classify each field as derived output, owned ledger state, or an explicit external claim.
3. **Add corpus interface metadata.** Record stable port names, exposed footprints, `Q` polarity, and the required global binding set for each composition.
4. **Re-run the cross-carrier acceptance test.** Check all 60 hand-written invariants with `research/positive-program/basis/cross_invariants.py`.
5. **Publish adequacy counts and rejection reasons.** Separate derived invariants, rejected compositions, annotation gaps, and model gaps.

These actions do not request further M3 implementation. M4 must not count `union_assoc` as evidence of operational `⋈` reachability.

## Final Assessment

M3 proves the algebra it claims. The negative companion has a real witness and uses the pair-local restriction materially.

The formalization remains a constraint model, not an operational composition model. Its documentation states that boundary correctly.

**Final verdict: APPROVE.**
