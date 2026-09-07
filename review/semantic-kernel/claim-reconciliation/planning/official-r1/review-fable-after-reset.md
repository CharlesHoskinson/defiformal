**Verdict: NEEDS REVISION.** The mathematics of the bridge is sound at its stated scope and the plan is concrete enough to implement. Four planning defects must be corrected in the frozen bundle before implementation. None requires re-scoping the change.

## Authorship, conflicts, checks performed

I am native Fable 5.1 acting as the second planning reviewer. I did not author the proposal, design, specs, tasks, control inventory, the preparation-r2 packet, or the historical-instance audit. I performed no build, no script execution, no source acquisition, and no numerical run. I read the full bundle and did the following by hand:

- Counted the claim ledger. The map and claims.json hold exactly 18 records, 63 site excerpts, 22 distinct files, 10 register rows mapping to 17 findings, and CL09 as a separate preparation finding. Scenario map, requirement count, 27 unchecked tasks and 22 controls all reconcile with the report.
- Re-derived the unary edges from the 29 law strings in viz/src/data.ts under the corrected parser. PARSED_NEW yields 16 occurrences and 15 distinct arcs, LSTAR 13 and 12, matching the audit log. No self-loops exist, so self-loop removal is vacuous rather than a normalization.
- Recomputed the loop denominators from the m5 loop bounds. They agree with the design table.

| Counter | Formula | Value |
| --- | --- | --- |
| Equality seeds | 58 + C(58,2) + C(58,3) | 32,567 |
| Union splits | C(58,3) | 30,856 |
| Generator indices | 58 + C(58,2) | 1,711 |
| Index pairs, i ≤ j | 1711 × 1712 / 2 | 1,464,616 |

- Checked the orientation of the extreme-point definitions. The m5 maximal filter, the paper's reversed specialization order, and the generic theorem that identifies intrinsic extreme points with reachability-minimal elements all agree.
- Checked that the design's CL06 no-upper-bound route is valid: any inclusion upper bound of A ∪ B contains the purely negative forbidden set, and the shipped X2 and X21 predicates are monotone in the set, so no admissible common upper bound exists.

## Findings requiring revision

1. **Blocking. The bridge cannot be built without editing a frozen Sprint 10 input.** The design and proposal say no frozen review package or accepted module changes, and the report says all 88 frozen S10 inputs are preserved. Task 5.1 adds a dedicated target under a new `DefiHistorical` namespace. That namespace has no `lean_lib` entry in lakefile.toml, which lists only two libraries. Lake will not build or resolve imports for modules outside a declared library, so `lake env lean` on the verify file also fails once it imports a sibling module. The plan must state that lakefile.toml will gain a third library, acknowledge that this file is in the S10 frozen bundle, and require an explicit relevant-closure equivalence record for S10 rather than a silent hash drift. Alternatively state a single-file layout with no imports, which the five-file plan in the proposal contradicts.

2. **Blocking. The frozen-environment set is underspecified and it decides three claim sites.** Design section 2 freezes theorem, lemma, proposition and corollary environments and their proofs. It is silent on `definition`, `measurement`, `conjecture`, `remark` and `example`. CL04's site is the Warrant definition environment, CL16's and CL17's sites are the appendix measurement environments, and CL06's and CL09's sites include the abstract. HC06 and H18 promise unchanged theorem text, but H17 and H16 promise corrected wording at measurement sites. State explicitly which environments are byte-frozen and which are prose. If definitions and measurements are frozen, route CL04, CL16 and CL17 through the erratum path and say so in the scenario map.

3. **Major. The Lean literal comparison mechanism is unspecified and defaults to a source grep.** Design section 3 requires a checker to compare every vocabulary item and extraction decision against literal Lean data. Nothing says how the Lean side is read. Parsing Lean source with regular expressions is the footgun the register warns about. Require a Lean-side export, for example an `#eval` or `IO` dump of the encoded tables in canonical JSON, produced by the same module the theorems import, and compare that output to the extractor output. Record the dump as bounded execution, not as proof.

4. **Major. The vocabulary boundary between 59 parsed symbols and 58 mechanism vertices is not recorded.** The element regex in tables.mjs matches the constant-sum entry with status `limit`, so the symbol set has 59 members while the mechanism list has 58. The parser filters law alternatives against the 59-member set. No law names the extra symbol today, but B01 and B02 must include an explicit checked decision that no subject or alternative in either instance lies outside the 58 encoded names. Otherwise an edge to a non-vertex could pass extraction and fail only at encoding.

## Findings to record, not blocking

- **CL06 has a candidate full-instance witness already in the bundle.** The paper's non-congruence theorem exhibits the Uniswap and Aave v3 decompositions, both asserted operationally admissible, whose union arms X2. X2 is purely negative, so the design's stronger route applies directly. Under inclusion, the operational admissible family then has no join for that pair. The plan may still defer this, but the ledger record for CL06 should name the candidate and require actual predicate evaluation of both sets before choosing between the narrow and the strong correction. The paper's open problem asks whether the family is a lattice "under any order". Every finite set is a chain under some order, so that phrasing is vacuous. The correction should say "under inclusion".
- **CL08 multiplicity.** Ledger row R9 says sixteen rules. The bridge distinguishes 16 occurrences from 15 distinct arcs. The reconciled wording must say which number is meant.
- **CL09.** The current theorem statement disclaims approximation fixpoint theory while its proof paragraph still speaks of approximators. That is a mismatch inside a frozen environment. Record it as a linked erratum.
- **Decidability instance.** The generic reachability closure takes a decidability instance as a parameter. The universal equality theorem should note that different instances give propositionally equal filtered sets, so the saturation-derived decider does not create a circular dependency. This is routine but worth one sentence in Saturation.lean's docstring.
- **HC-C19 and HC-C22.** The first is a declared-evidence-class control and the second an executed algorithm mutant. Task 4.4 must label them distinctly in the inventory output, which the control kinds already do. Say which executable the intrinsic-deletion mutant runs in, Lean evaluation or Python, and label that run as bounded execution.
- **Node binary provenance.** The audit's Node binary lives under a Foreman tools directory. The rule forbids the Foreman orchestrator, not the binary, but the plan should pin the binary path and hash explicitly rather than inherit it.

## What holds as planned

The separation of evidence layers is correct and complete: fixed-source extraction validation, universal Lean instance proof, reviewed algorithm translation, and bounded JavaScript execution. The unary fragment is kept distinct from full admissibility, and neither the depth-limited UI helper nor the F8 saturation is allowed to stand in for the intended closure. The saturation argument by n rounds with strict growth is sound. Closed-input premises for the oplus form are stated. The exit 0/1/3 contract, nonempty denominators, index-versus-state distinction, and the exit-zero-with-violation mutant are all present and realistic, since m5 never sets an exit code. Eager reads of the blind set and lanes are bound as input access with no holdout credit. S9 is cited as accepted, S10/M3/M4 remain pending, corpus packets remain proposed identities, and no future runtime API is imported. The reviewer bindings match the latest instruction.

## Limitations

Line numbers in the claim sites were not independently recounted; I relied on the preparation packet's checks. Hashes were taken from the manifests. I did not verify the 5,169,336 and 5,142,758 anti-exchange counts beyond plausibility. I cannot confirm that the paper's two witness sets satisfy the operational predicate without executing it. Rendered PDF behaviour, Lake behaviour on the specific toolchain, and kernel reduction cost of the 58-vertex rank check are expectations, not observations.
