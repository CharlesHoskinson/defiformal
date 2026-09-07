VERDICT: REVISE

Scope of this review: I read the supplied OpenSpec bundle, the sixteen Lean files, the two Python drivers, the mutation specification and the planning adjudication as text. I did not run Lean, Python, Git, or hash recomputation, and I make no claim about compile status beyond what the supplied text shows. The verdict is REVISE because of one concrete blocker in the evidence tooling on the frozen source; the Lean semantics and proofs are otherwise in good shape and I would accept them as source pending the separate hash-bound evidence audit.

BLOCKERS

B1. The production runtime audit and the mutation runner disagree on the failure-message shape, so no production mutant can qualify as a detection on this frozen source.

- lean/DefiKernel/Atomic/Audit.lean, def main: on failure it throws
  IO.userError s!"Atomic runtime comparisons failed: {failures}"
  where failures is a List String. The rendered text is a bracketed name list, for example
  "Atomic runtime comparisons failed: [atomic.fixture.abort.middle.public]".
- scripts/check_atomic_mutations.py, mutant branch inside the variant loop: it requires
  len(errors) == 1 and errors[0].endswith(f'error: Atomic runtime comparisons failed: {len(false)}')
  i.e. the message must end with the integer count of false comparisons.
- Consequence: the unchanged control passes (no error line), but every one of the eighteen mutants raises "failure is not solely the expected runtime comparison failure" and is classified BLOCKED (exit 3), never "violated". Design §5 and the regression-evidence spec require each mutant to fail its designated oracle in a qualified run; that cannot happen with these two files as frozen.
- Note the harness fixture in scripts/test_atomic_mutation_runner.py (AUDIT template) throws the count via throwError, so all sixty-plus CLI control cases pass without ever exercising the production message format. The harness therefore does not protect against this mismatch.
- Fix is one line in either file (print failures.length in Audit.lean, or accept the list form in the runner), but it changes a frozen production/driver input, so the source candidate must be re-frozen and the evidence rerun. I did not execute the runner; this finding is from reading both files, and I am confident in the string mismatch itself.

REQUIRED CHANGES

R1. Resolve B1 and re-freeze. Prefer changing Audit.lean to report the count, since the runner's count check is the established Sprint 7 contract; add a harness control whose fixture audit uses the same throw form as the production Audit.lean (IO.userError from #eval) so the parse path used in production is actually covered.

R2. Confirm in the evidence audit that #eval output lines under the pinned Lean version appear as bare "name: true" lines in the lake env lean log (not wrapped as position-prefixed info messages). The runner's observation regex is anchored at line start; the CLI harness only validates the run_cmd/liftIO path, not the #eval path used by the production Audit.lean. If they differ, the control itself will block. This is an execution question I could not settle by reading.

R3. Reconcile the CLI control count. Design/tasks/spec say "all 52 established" cases; I count 63 case dictionaries in test_atomic_mutation_runner.py cases(). Either the Atomic harness is a strict superset (then say so and map the 52) or the normative number is stale. Not a source defect, but the evidence inventory must not cite 52 for a 63-case run.

NONBLOCKING LIMITATIONS

L1. Fixture reuse. The live-read, peer-only, own-snapshot, both-own and local-principal/time scenarios are exercised through oldRun with empty lanes and the accepted Parallel/Interleaving expected tables (liveWorld, ownWorld, timedWorld, snapshotWorld). Their independence rests on the earlier sprints' oracles, not on new Atomic-native ones. The Atomic-native timed and live templates in Examples.lean (ops 110, 111, timedDraw, liveDraw, localBoundary) are defined but unused. Acceptable, but say so in the scenario map.

L2. Diagnostic separation is by projection, not by type. Result.aborted carries the full speculative Machine; only observe/committedHistory/committedSupply erase it. That is exactly Design §2's accepted choice, and the erasure is proved (observe_aborted_history, observe_aborted_supply, runAtomic_noncommit_identity), but consumers who pattern-match on Result directly see diagnostics.

L3. checkSupply reports only the first violating lane in policy order and does not check unconfigured assets; that is the stated restricted policy, not a general no-supply claim. Also, checkSupply is domain-qualified: a mint of the lane asset in a different domain is not a lane violation. Consistent with spec wording ("lane domain/asset"), but worth stating explicitly.

L4. Comment fidelity nits (untrusted, checked against code): Soundness.lean docstrings say "actual interleaving preTokens" and "literal preTokens of the supplied schedule" where "prefix" is meant (search/replace artifact). Design §3 says "Return 8 after draw 7 leaves residual −1"; code and fixtures agree (afterOver, overResiduals), so only the comment wording needed checking.

L5. Overlapping oracles are real and disclosed: stale-entry-world, peer-history-leakage, global-boundary-index and resurrect-revoked-grants all edit the same needle line in Atomic.advance and each would trip many comparisons beyond its designated one. That is permitted by the design as long as the designated comparison is the one recorded.

L6. Heavy kernel evaluation: InvariantFixtures.underlying_success_does_not_imply_commit decides a full runAtomic by decide +kernel. Fine if it elaborates within default limits (the reported development check suggests it does), but it is a compile-time cost item for the evidence run.

L7. The "continue-after-first-failure" mutant matches on a literal none discriminant with a some arm; I expect it to compile with an unreachable-arm warning at most, but that is an execution fact for the evidence audit, not something I verified.

CLAIM/SCOPE CHECK

Actual-prefix connection. Atomic.advance calls Interleaving.advance exactly once and inspects next.attempts at the previous length; interleaving_advance_appended and interleaving_advance_attempt (Soundness.lean) fix the appended entry as the real executeStep at the local boundary, own outputs and current speculative world. Reachable.interleaving embeds every diagnostic machine into Interleaving.Reachable; continueRun_prefix/runPrefix_prefix give a literal schedule prefix with suffix empty when active; continueRun_aborted is the global stop theorem; runPrefix_complete_active_exhaustion gives exhaustion. This satisfies the "actual trace and stop soundness" requirement. Exhausted-token skips cannot occur post-admission because checkSchedule enforces exact counts, and the proofs do not depend on that.

Signed typed receipt effect. receiptEffect sums every evaluated delta at the exact cell (Evaluated.effect); step_receipt_balance ties it to the real post-balance via applyEvaluated_ok_iff. updateOutstanding subtracts it at the invoker key only (updateOutstanding_own/other/unconfigured/zero_effect). Draw 7 gives +7, return gives −7, repeated deltas sum (repeatedTemplate fixture), no-op preserves debt. Matches the settlement spec.

Participant completeness. uncoveredFrom walks every static invocation of both branches with the fixed boundary at that index, including unreachable suffixes (participant.suffix fixture); checkPolicy_ok_iff and checkPolicy_covers make coverage available to the cash induction. Duplicate lanes are keyed on (domain, asset) so an alternate vault is still a duplicate (lane.alternate.vault fixture). Extra participants allowed (extra.participant fixture).

Debt conservation including policy abort. Reachable.cash_owed inducts on Atomic.Reachable with the admitted-coverage and participant-nodup premises; the accepted branch uses accepted_cash_owed, which is built from executeStep_sound and updateOutstanding_sum. Because advance_outstanding and advance_speculative are stated for m.abort = none regardless of whether the step then sets a laneSupply abort, the machine after a policy abort is covered (this is the required "including the successful step that triggers policy abort"). The supply.lane.after.draw fixtures confirm the diagnostic retains movement and table.

All-key clearance. residuals enumerates lanes × participants (lane-major, participant-minor, residuals_eq_filterMap_product) with exact signed amounts; residuals_eq_nil_iff is pointwise; finish commits only on the empty list; Reachable.cleared_cash and runAtomic_commit_cash restore each vault cell. Scalar netting is refuted twice: as a checked table counterexample (scalar_netting_counterexample) and as a production run (cross.principal fixture). Cross-asset, cross-domain, last-lane and last-participant fixtures exist with independent expected residual tables.

Local principal/history/time. The boundary is boundaries b nextIndex with nextIndex = consumed when active (Interleaving attempt_index); the debt update uses the same boundary via attempt.index. Global position is recorded separately in AbortReason. The global-boundary-index mutant and boundary.local fixture target exactly this.

Supply restrictions. Every successful receipt is checked against every configured lane's (domain, asset) across all principals (checkSupply_none_iff); the nonvault mint fixture aborts with the exact lane and amount even though vault cash is unchanged; nonlane supply commits with its nonzero supply summary through committedSupply = speculative.supply. This is a restricted policy, not a general claim.

Full rollback. Result.publicWorld returns the whole entry World (ledger plus capability store) for refused and aborted; Reachable.entry pins entryWorld to the initial world; runAtomic_noncommit_identity covers every non-commit constructor including unsettled, with empty committed history and zero committed supply. The aborted-mint fixtures show real speculative supply in diagnostics and zero public supply. Follow-up fixtures show fresh histories after an abort.

Noncircular converse. runAtomic_commit_of_interleaving assumes only admission, GoodAttempts over the real Interleaving.runPrefix attempts, and clearance of the independent outstandingFromAttempts fold; Reachable.outstanding_fold equates that fold with the maintained table. runAtomic_commit_iff_interleaving gives both directions; runAtomic_commit_interleaving gives agreement with runInterleaving on commit. The unpaid-draw counterexample refutes dropping clearance. No premise mentions the Atomic result.

Invariant premises. runAtomic_two_invariants takes initialization, LocalObligation, CrossInclusion and Stable from the Interleaving rely/guarantee framework and discharges commit via the actual-prefix theorem and abort via rollback; no zero-table or whole-result premise appears. The collateral instance (draw_return_public_invariant, nonempty_transient_invariant) holds with a live nonzero obligation and nonempty lane. Missing-support counterexample is concrete.

Full public field comparison. observationEq compares label, schedule, outcome (whole AdmissionFailure/AbortReason payload including residual lists by derived DecidableEq), full world via worldEq, the committed event list (branch, index, invocation, receipt, outputs), and supply pointwise; observationEq_iff proves it equals Observation.Equivalent. The observation checks change each of these fields individually and include an equal control; the two observation mutants edit this production comparator.

Independent fixtures. Expected worlds are literal balance tables, expected receipts are hand-built Evaluated records, residual tables are literal lists interpreted by expectedOutstanding, and machineMatches/tableMatches compare against them without consulting a second execution. I checked arithmetic for draw/return, under, over, credit, peer, asset, domain, last-lane, last-participant, no-op, repeated, lane/nonlane mints, first/middle failures, revoked, order sensitivity, admission precedence and follow-up cases; all expected values are consistent with the operations and the initial world. My count of runtime comparison entries is 129, matching the reported development figure.

Mutation design. All eighteen needles appear exactly once in the pre-marker text of their modules, target real production definitions (advance, publicWorld, committedHistory, committedSupply, updateOutstanding, residuals, checkSupply, observationEq), and by inspection would flip their designated comparisons while leaving the six positive controls true. Omission mutants use fixtures with two lanes or two participants. The design-level obligation is met; qualification is blocked only by B1.

Defensive runner. The runner enforces outside-repo fresh output, exact Git object equality for every captured input, drift checks before and after each variant, a conservative post-marker declaration guard, complete-inventory and partial-execution checks, and never counts compile failure as detection. Source fidelity: the projection inlines local imports fresh and strips only Atomic proof tails; the mutation-spec module list is confined to Atomic runtime roots.

Not claimed and correctly absent. No deployed Balancer fidelity, machine arithmetic, fairness, provenance, associativity, nested savepoints, in-transaction capability changes, fees, or order independence. Initial store and authenticated boundaries remain trust premises, as the authority theorems state.

Bottom line. Merge-quality Lean; the atomic model, settlement policy and proof obligations match the accepted OpenSpec. The single blocker is a message-format mismatch between Audit.lean and the mutation runner that would turn all eighteen required detections into BLOCKED results. Fix it, re-freeze, then proceed to the hash-bound evidence audit with R2 and R3 on its checklist.
