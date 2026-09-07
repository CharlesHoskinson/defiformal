# Independent Sprint 7 artifact and requirement check

**ACCEPT WITH LIMITATIONS for this check. No unresolved semantic or artifact-binding blocker.** Final proof candidate: `bea105ec72e633a2dd66c663b96d0b552e1814a8`. Original runtime/regression execution candidate: `6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`. Final native review and delivery remain open; this report does not accept or archive the sprint.

Stock GPT-6 agent `/root/sprint7_plan_gpt6` performed the check without Foreman. Requested model is `gpt-6-astra`; independent provider/build telemetry is unavailable. This is an independent reconciliation of the parent's evidence generation, not a non-author implementation audit: this agent authored Schedule, LocalOrder, Recovery, and the supplemental Completion module. Required native implementation reviews remain separate.

## Actual checks

`independent-artifact-check.py` passed **1,781 assertions**. It reconciled the 39-file planning bundle against candidate `bf3fb509b211d7cd92eb68410fb49dc5f4e20e7d`; its SHA-256 remains `b8bd48445352214c3e2f09004c5cbe29928bf388adf256d01759b307fc952997`. The original implementation bundle's 49 Git source files and two execution-log sections match their recorded bytes and hash `3b9a5e05bddc2f2ea32f37fdd55e70383972ef59ce3d7cef44fa715c90bcc2bf`. Proposal, design, and four normative specs remain unchanged from the approved plan.

The final 12-command integration record has all zero exits and 89 source files matching final Git objects. Its runtime audit executes 116 unique true comparisons. The final inventory has exactly 262 theorem and 271 supplemental declarations; names, elaborated statements, module provenance, and axiom lists agree with the actual environment log and Verify audit. Bindings were refreshed against the inventory frozen at 2026-09-07T07:33:13Z with `pp.proofs true`; all 533 literal statement types contain no hidden proof ellipsis. All 127 explicit source theorem statements are located in source. Only `propext`, `Classical.choice`, and `Quot.sound` occur in these accepted audits. No parent Lean execution was rerun or misrepresented as this agent's execution.

All 43 normative scenarios, across 15 requirements and four specs, match exact spec headings and line locations. The 268 evidence records have resolved references and matching hashes. Runtime names, theorem categories/statements, mutation fields, runner commands/exits, and legacy commands/exits match their underlying evidence. The map correctly records 41 verified scenarios and two pending native-review/delivery scenarios, with whole-sprint acceptance false. Inputs remained stable throughout the check.

`independent-mutation-check.py` separately passed **810 assertions**: all 14 production edits differ exactly from the unchanged control by their unique specified replacement; each executes all 116 comparisons, fails its designated comparisons, and preserves protected positives. Each failure is the intended runtime diagnostic; compiler-only failures receive no production detection credit. All 52 actual runner CLI classifications and all 629 artifact byte/hash entries reconcile. The 25 runtime closure files and three driver/spec/harness files are byte-identical between original and final commits. Fixture Git history is archived with its bound bundle; no embedded repository remains.

The nine legacy Python suites were actually rerun by this agent at the original revision, with the results and 1,617 saved-evidence assertions in `../regressions/REPORT.md` and `../regression-runs.json`. Of their broad 128-file binding, only `Interleaving/Verify.lean` differs at the final revision. The actual typed/composition/Parallel mutation closures contain 13/18/27 files and exclude that changed root; runner controls use isolated fixture modules, typing imports Types/Expr, and axiom controls copy AxiomAudit. Original execution identities are retained. Fresh final Lean integration checks the added proof module/import.

## Normative statement assessment

| Requirement family | Actual support and boundary |
| --- | --- |
| Complete schedules and shared-state admission | `checkSchedule_ok_iff`, exact error-count characterization, `admit_ok`/`admit_of_checks`, and count laws; admission definition checks configuration, left, right, schedule and never requires compatibility. |
| Evolving world, local refusal/history, complete observations | Actual `AdvanceSound` equations and `Reachable`; `attempt_chain`, `branch_projection`, `local_history`, `local_order`, and refusal stability; exact projection definitions retain full ledger/store, receipts, requests, outputs, successful indices, and failures. |
| Trace soundness and complete consumption | `runPrefix_reachable`, `runPrefix_complete_counts`, and the new explicit Completion corollaries described below. |
| Accounting, authority, nonnegativity | Actual receipt-supply accounting; authority at actual pre-world and local boundary with immutable initial store. Nonnegativity uses the proof-carrying State premise, not an inferred solvency theorem. |
| Locality and supported frames | Actual/analyzed-write locality and predicate frames require explicit exclusion and `Supports`; concrete missing-support counterexample. |
| Initialized interference composition | `LocalObligation` ranges over arbitrary own-invariant worlds/history/selected positions and successful `StepSound`; no peer invariant or final equality premise. Initialization, guarantee-to-peer-rely inclusion, and peer stability are independent hypotheses. |
| Universal disjoint recovery and specializations | Actual `Parallel.admit` success plus `Complete` suffice for canonical equality, including refusals and retained prefixes; dependency/frame simulation proves it. Empty/one-empty and real serial LR/RL corollaries share these boundaries. No arbitrary shared-state commutation. |
| Independent financial and mutation evidence | 116 checks, 14 real source edits, 52 actual runner controls, and explicit development-fixture labels; finite observations remain distinct from generic proofs. |
| Proof inventory, regressions, planning/delivery gates | Exact imported inventory and fresh legacy results are bound as above. Planning gate passes at its historical candidate; final native review and delivery are still pending. |

## The two flagged corollaries

Neither flag exposed a semantic counterexample or missing inductive invariant in the original source. Admission refusal identity follows by `simp only [runInterleaving, h]` from actual admission failure. Active exhaustion follows from `Reachable.active_index`, `runPrefix_consumed`, the two `Complete` count equalities, and `Nat.min_self`. A failure alternative follows by cases on the actual recorded option and `Reachable.failure_index`; existing continuation refusal stability preserves that first record.

To make these obligations directly named and inventoried, final `Completion.lean` now supplies:

- `runInterleaving_admission_refusal`: actual preflight error implies exact `.refused reason initial schedule`, whose constructor has no attempts or outputs.
- `runPrefix_complete_active_exhaustion`: under `Complete` and no local failure, the branch's successful index equals its static length.
- `runPrefix_complete_exhausted_or_refused`: every branch is exhausted without failure or retains an exact located failure at its successful index.

Only this new proof module and the Verify import changed after the original freeze. Literal Lean LSP diagnostics are clean. This agent's targeted build passed 934 jobs, and actual axiom printing for all three corollaries reports only the standard three axioms. `completion-runs.json`, `completion-lsp.json`, and their complete logs retain this execution. The exploratory standalone proof attempt and its corrected successful check are also retained; no failed exploratory proof is counted as accepted evidence.

The module documentation explicitly states that the canonical comparator ignores the supplied schedule even for refused results; raw Result equality retains it. This is a documented observation boundary, not a change to runtime semantics. Trusted configuration/boundaries/authority-store authenticity, exact rational arithmetic, finite schedules, explicit support and rely/guarantee premises, and disjoint recovery admission remain material limits.
