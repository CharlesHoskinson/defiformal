**VERDICT: ACCEPT WITH LIMITATIONS**

Reviewer identity: Claude Fable 5.1 (model id `claude-fable-5-1`), native, no tools, read-only reasoning over the supplied bundle. Candidate bound to `bea105ec72e633a2dd66c663b96d0b552e1814a8`, payload SHA256 `73ad1356e9951f57216743e4d24ff42e082826cea3891d39dea14fb4197de35c`. I ran no Lean, Git, or Python commands. Every execution claim below is the parent's evidence, checked for internal consistency only.

**Blockers: none.**

## Proof supplement (Completion.lean and Verify import)

All three corollaries are well-formed against the supplied source and I accept them.

- `runInterleaving_admission_refusal`: the definition of `runInterleaving` matches on the qualified `Interleaving.admit`, so `simp only [runInterleaving, h]` closes it. The explicit `DefiKernel.Interleaving.admit` qualification correctly avoids `Parallel.admit` under `open Parallel`.
- `runPrefix_complete_active_exhaustion`: composes `Reachable.active_index` (nextIndex equals the minimum of consumed and static length), `runPrefix_consumed`, the two `Complete` count equalities, and `Nat.min_self`. The case split on the branch is needed because `selectBranch` reduces only per constructor. Sound.
- `runPrefix_complete_exhausted_or_refused`: case analysis on the recorded failure option plus `Reachable.failure_index`. Sound.

The final Verify audit log lists exactly these three plus the generated `runInterleaving.eq_1` under module `Completion`, giving the stated 262 theorem and 271 supplemental constants with only `propext`, `Classical.choice`, and `Quot.sound`. The inventory execution, integration-final run, and coverage validation all cite the same driver and log hashes. Consistent.

Two non-blocking observations. First, the exhausted-or-refused corollary asserts that the retained failure sits at the successful index, not that it is the *first* refusal; that stronger reading of scenario S25 relies on `continueRun_refusal_stable`, which the scenario map does cite. Second, the module docstring correctly discloses that `observationsEqual` ignores the supplied schedule on refused results; this is a comparator boundary, not a runtime change.

## Mutation runner and harness

The runner's discipline is sound for its threat model of mistakes and stale evidence:

- Fresh single-file projection with only external imports, so local `.lake/build` oleans cannot leak in. The `fresh-dependency-source-failure` control confirms a stale olean is not consulted.
- Each mutant needle must occur exactly once in the runtime prefix, so edits cannot land in stripped proof tails or apply ambiguously.
- Mutants must reproduce the exact control inventory, fail only through the single expected runtime diagnostic, hit their designated labels, and keep all nine protected positives true. Compile-only failures and survivors are blocked or failed, never credited.
- Byte-level Git blob binding before the run and source, spec, runner, and HEAD re-hashing after every variant, with success flags cleared before re-reading.

Harness: I count 52 cases in the source, matching the recorded 52 passes with six accepted, four failed-assertion, and 42 blocked classifications. Discriminating cases additionally require the exact real Lean observations, and the drift cases check the manifest flags. The self-hash checks on runner and harness at completion are present.

Runner limitations worth fixing later, none blocking today:

- The proof-boundary guard only catches `def`-family keywords at line start. A `@[simp] def` on one line, or `macro`, `notation`, `deriving instance`, or `axiom` after the boundary, would be silently dropped from the projection. Current Interleaving runtime modules have nothing after the boundary but theorems, so this is latent.
- Any unexpected Lean diagnostic continuation line other than the two hard-coded prefixes blocks the run. That is conservative rather than unsound.

## Execution evidence

Mutation results: all fourteen designated labels appear in their variant's false list, each mutant log ends with exactly one error whose failure count equals the false count, and every protected positive reads true in every mutant log I inspected. The needles are genuine runtime edits in `Schedule` and `Execution`; none touches test expectations. Spot checks of the trickier ones (constant-`none` match, global position mutants, catalog-driven snapshot reread, `Parallel.runBranch` replay) are consistent with compiling and reaching runtime only.

| Item | Supplied evidence |
| --- | --- |
| Control comparisons | 116, all true, log hash equal to integration-final Audit log |
| Mutants discriminated | 14 of 14, single expected error each |
| Runner CLI controls | 52 of 52 |
| Legacy suites | 9, all exit 0, 1617 verification assertions |
| Lean commands at final candidate | 12 of 12 passed |

Binding across revisions: the 25 closure inputs and three driver/spec/harness files carry identical SHA256 values in the 6de24fe source manifest and the bea105ec scenario map, and only `Verify.lean` differs, which is outside the Audit-rooted mutation closure. Retaining the 6de24fe execution identity rather than relabeling is the correct treatment. The integration-final Audit log hash equals the mutation control log hash, which independently corroborates unchanged runtime behavior.

Disclosed evidence limits I concur with: the stale-initial-world and isolated-branch-world designated labels fail under both mutants and do not separate those faults; the legacy 128-file binding was captured at 6de24fe and includes the old Verify; `preservation.json` was generated at 6de24fe, not regenerated at bea105ec, though the delta is one new file plus one new-file edit.

## Spec compliance

Independent financial evidence, production mutation sensitivity, runner controls, source drift, imported proof coverage, and legacy preservation are all satisfied by the supplied artifacts. Planning gate is recorded as passed at its historical candidate. Scenarios S42 and S43 remain correctly pending; the "independent artifact check" was authored by the implementing GPT-6 agent and is disclosed as reconciliation, not a non-author audit. This review is one native Fable review and does not by itself close S42 or authorize delivery or archive.

## Conditions of this verdict

Acceptance is conditional on the parent evidence being what it claims: I did not rehash blobs, rerun Lean, or re-execute the runner. Material limits remain as documented: trusted configuration and initial capability store, exact rationals, finite schedules, explicit rely/guarantee and support premises, recovery only under actual Parallel admission, and development fixtures with no deployed-protocol fidelity claim. Suggested follow-ups: strengthen the proof-boundary declaration guard, regenerate the preservation record at the final candidate, and add a label that separates the two wrong-world mutants.
