# Sprint 7: shared-state interleaving

Status on 2026-09-07: **Implementation/evidence accepted with limitations; delivery underway**.
Base: `850d785d41dc311785dc33cdb3f65c368756434c`.

Authoritative links: [proposal](../openspec/changes/shared-state-interleaving/proposal.md),
[design](../openspec/changes/shared-state-interleaving/design.md),
[tasks](../openspec/changes/shared-state-interleaving/tasks.md).

## Decision summaries

1. **Use a shared evolving world.** Two withdrawals can each be valid on their own
   and compete for the same liquidity. With USD10, withdrawals of7 and6 cannot
   both succeed. Preserve accounting and authority while exposing which attempt
   succeeds under each schedule.
2. **Keep schedules explicit and finite.** A token selects the next static slot
   of its branch. Exact counts make replay and completeness independent of whether
   an invocation succeeds. After a refusal, remaining own slots skip. An adaptive
   scheduler or fairness result would add a separate semantic obligation.
3. **Keep partial progress.** Earlier successful effects survive a later refusal;
   the peer continues. All-or-nothing rollback belongs to atomic synchronization.
4. **Separate histories from shared balances.** A live ledger read sees peer
   changes, while an earlier output snapshot retains its captured value. Output
   references remain branch-local even when keys coincide.
5. **Make interference assumptions explicit.** Independent local guarantees must
   fit the peer's rely relation, and the peer invariant must be stable under that
   relation. Both invariants must hold initially. These are proof premises, not
   silently satisfied runtime checks or automatically discovered invariants.
6. **Require a universal disjoint recovery proof.** Sprint 6's dependency lemmas
   should support a simulation for every schedule, including exact failures.
   Enumerating six 2+2 schedules is useful regression evidence but cannot replace
   that theorem. Full trace order remains observable; only a named projection
   recovers the existing canonical parallel observation.
7. **Keep the first scope bounded.** Capabilities remain fixed during execution.
   Initial revoked grants are tested; revocation races, provenance, unbounded
   liveness and deployed financial fidelity remain future work.

## Review questions

- Does the schedule/skip convention distinguish consumed slots from successful
  local indices everywhere, including failure locations and canonical recovery?
- Can every required mutation compile and be discriminated by a real production
  path with an independently expected outcome and a funded successful sibling?
- Does the rely/guarantee instance exercise overlapping support with nontrivial
  local proofs, rather than premises that merely restate the whole-run result?
- Does the generic disjoint simulation preserve exact histories and refusal
  precedence without requiring equality of unrelated foreign event worlds?

These are audit questions against the concrete candidate, not unspecified behavior.
The design resolves the behavior; reviewers can require a corrected candidate.

## Evidence status

The planning candidate `bf3fb509` passed independent GPT-6 and native Fable reviews.
Final source `bea105ec` passed native Grok/Fable original Lean and final proof/evidence
scopes. Actual runtime/mutation/legacy Python runs retain revision `6de24fe`; all 25
runtime closure inputs and three runner/spec/harness files are byte-identical.
The only source supplement adds three directly named admission/completion theorems
and the Verify import. Fresh final integration checks that supplement.

Acceptance evidence:116 runtime comparisons,14 actual source mutants,52 actual CLI
controls, nine historical Python suites,12 final Lean commands, and262 theorem/271
supplemental imported axiom checks with zero forbidden dependencies. Of127 explicit
theorems,107 are generic,15 reference instances and five are counterexample
constructions/corollaries. Generated theorem counts are separate.

[Adjudication](../review/semantic-kernel/sprint7/implementation/ADJUDICATION.md)
and [final coverage](../review/semantic-kernel/sprint7/coverage-final.md) retain exact
inputs, findings and limitations. Cancelled or tool-markup-only native attempts
received no acceptance credit; substantive native final verdicts closed those
review obligations. Branch delivery and OpenSpec archive are in progress.

## Adopted review guidance

- Make supply aggregation an executable production function over actual attempts,
  with an independent nonzero supply oracle for both branches.
- Keep the canonical projection in the new namespace so failure omission can be
  tested on the function recovery actually uses.
- Recompute snapshot values only in the mutation, by resolving catalog output
  cells against the current world; correct execution retains stored snapshots.
- Exercise halted suffix behavior with a real later static slot after peer
  replenishment. Swapping coinciding own counters would be a surviving mutation;
  wrong-index mutations must instead use global or peer position.
- Label the total-preservation instance accurately: its local proof does not need
  the conditional invariant premise, though the generic theorem supports it.

Both reviewers treat these as implementation watchpoints, not blockers or changes
to the accepted semantics. All required native result scopes now pass with limitations. Broader projection syntax guards and more discriminating wrong-world labels remain explicit infrastructure follow-ups.
