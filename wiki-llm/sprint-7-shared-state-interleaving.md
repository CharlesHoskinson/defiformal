# Sprint 7: shared-state interleaving

Status on 2026-09-07: **OpenSpec candidate in preparation; implementation gated**.
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

No Sprint 7 implementation, new proof, runtime result or reviewer approval is
claimed here yet. Planning requires separate GPT-6 and native Fable 5.1 passing
verdicts on the same frozen candidate. Substantive implementation will require
native Grok/Fable review, full regressions and exact source binding. The stock
GPT harness implements with GPT-6; Foreman is excluded.
