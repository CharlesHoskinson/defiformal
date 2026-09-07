# Sprint 8: atomic synchronization

Status: OpenSpec candidate prepared; independent planning gate remains pending.

[Proposal](../openspec/changes/atomic-synchronization/proposal.md),
[design](../openspec/changes/atomic-synchronization/design.md),
[tasks](../openspec/changes/atomic-synchronization/tasks.md), and
[planned coverage](../review/semantic-kernel/sprint8/planning/coverage.json)
define four capabilities, 16 requirements and 49 scenarios. The separate
[design investigation](sprint-8-atomic-synchronization-draft.md) records alternatives
and historical Interface/Nary scope. This proposed design choice remains subject
to the independent plan audits; no Atomic implementation is claimed.

## Decisions

1. Run the existing interleaving advance once per token in an isolated speculative
   machine. Abort the whole event at the first kernel or settlement-policy error.
   Public atomicity does not imply internal order independence.
2. Keep public committed events and aborted diagnostics in distinct projections.
   Rollback restores the exact entry ledger/store. Speculative minted supply and
   snapshots do not become committed financial observations.
3. Derive signed transient obligations from actual accepted receipt effects at
   typed vault cells, attributed to authenticated local principals. This gives a
   cash-plus-obligations equality that can be proved from execution.
4. Require every typed lane/participant entry to clear. Equal numeric debt/credit
   across principals, assets or domains cannot cancel. Intermediate credit is
   permitted; unresolved over-return at completion aborts exactly.
5. Reject lane-asset supply anywhere in that asset while permitting authorized
   nonlane supply. This is a bounded loan/return policy, with full Balancer, hooks,
   machine arithmetic and deployed fidelity left to later library/refinement work.
6. Use 18 fixed production mutation obligations and all 52 defensive runner
   controls. Source review, kernel proof, financial runtime and compiler controls
   remain separate evidence categories.

The user's AFK instruction authorizes execution after the same-candidate GPT-6 and
native Fable planning gate passes. Native Grok/Fable final audits, exact source
bindings, verified branch delivery and OpenSpec archive remain required. No Foreman.
