# Claim disposition for the semantic-kernel pivot

This document records scope corrections adopted on 2026-09-06. It does not
regenerate historical measurements or certify new deployed behavior.

| Existing claim or artifact | Current disposition | Repository evidence |
| --- | --- | --- |
| Q/Sigma as a semantic provenance partition; four-element basis | Withdrawn as kernel design claims. Assignment form does not establish provenance. | `research/positive-program/sigma/QSIGMA-VERDICT.md`, sections 3–5 |
| Delta is an idempotent interior/kernel operator | Withdrawn for the operator described in MODEL.md. Its own correction records non-idempotence. Use the warrant operator/predicate unless a repaired definition and proof are supplied. | `algebra/MODEL.md`, section 1 correction versus section 2 |
| Mixed Horn/dual-Horn polarity proves the admissible poset is not a lattice | Unsupported inference. Report explicit failures of particular set operations separately from the induced order structure. | `lean/Defialgebra/Lattice.lean`, `completeLattice` and `meet_ne_inter`; `lean/Defialgebra/Polarity.lean` |
| Independence.lean establishes semantic or financial minimality | It establishes constructor independence in its declared toy syntax. Retain that result at its actual scope. | `lean/Defialgebra/Independence.lean`, module description and `uses` predicates |
| Extremal allocation requires a new universal primitive | The separation concerns the declared sum-local/conjunction grammar. It does not prohibit a library using ordered state and traversal. | `lean/Defialgebra/Extremal.lean`, declared grammar and separation theorem |
| Nary.lean proves operational composition associativity | It proves binding union and agreement properties. Operational reachability and conservation lifting remain separate obligations. | `lean/Defialgebra/Nary.lean`, “What is not proved” |
| Interface.lean automatically infers safe interfaces | Conservation depends on stated confinement/neutrality and non-shareable-total premises. Retain theorem and negative witness. | `lean/Defialgebra/Interface.lean`, `cons_of_portConfined`, `cons_broken_if_sup_is_port` |
| Gate 3.3 PASS certifies financial construction semantics | It checks keyword tagging and input non-emptiness. Retain as a historical prototype, not semantic certification. | `research/positive-program/sigma/gate33_cert_check.py`; `formal/v3/GATE-REGISTER.md` |
| Syntactic generation is domain-relative semantic completeness | Retain as a benchmark with the exact grammar and denominator. Do not promote its rates to semantic completeness or minimality. | `research/positive-program/basis/GENERATION.md`; `sigma/GATE-3.1-GENERATION.md` |
| Bounded anti-exchange executions independently establish the entire finite instance | Keep bounded execution separate from general structural Lean theorems and their application to the concrete instance. Audit the instance correspondence and counting argument before restating exhaustive totals. | `lean/Defialgebra/ConvexGeometry.lean`; `formal/v3/VERIFICATION.md` |

The empirical atlas, hazard data, corpus residue, exact-arithmetic work, fidelity
criteria and negative tests remain reusable research. Their original input
identities and scopes remain attached. No historical theorem is deleted or
weakened to make the new pilot pass.

The paper and all downstream claim sites still need a dedicated reconciliation
pass. These corrections govern new work and override conflicting historical
prose; they are not a claim that every old occurrence has been edited.
