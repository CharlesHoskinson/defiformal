# Operational active extension author draft

[M5/Sprint13](../openspec/changes/operational-active-extension/proposal.md) proposes
four capabilities,14 requirements,39 scenarios,25 unchecked tasks,20 reference
fixtures and16 planned mutations. It is not implemented or accepted. Official
freeze is blocked pending accepted S10/M3/M4 APIs and a complete refresh against
their actual fields, proofs and runner contracts.

The theorem preserves old behavior when additional invocation-only participants
execute. Restriction filters their tokens out while retaining old order/counts.
Projection keeps protected balances, the complete store, old receipts/history/
refusals/indices/consumed counters and chronological old attempts, projecting all
embedded worlds to the same protected cells. New events are omitted only from
this old observation. The extended machine itself can change.

All old analyzed reads, writes and output cells must be protected; new writes
must avoid them. New reads can overlap old writes, and new peers can refuse.
The proof follows actual success/refusal/skip branches, including old continuation
after a peer fails. It assumes equal initial protected balances, exact full stores,
old boundaries and supported configuration declarations with all-domain admin
equality. It does not infer these facts from ledger disjointness.

The contextual rule admits supported invocation-only before/after continuations
and isolated peer insertion. Sequential substitution quantifies over every pair
of related input cursors. Inserting peers requires the stronger old-token-prefix
relation and matching static slots; equal final cursors can hide different skipped
suffix lengths. Arbitrary omitted-cell reads, raw diagnostic inspection, grant
mutation and transaction-wide abort are excluded. Fresh-ID and Atomic rollback
examples document why those need separate theories.

The active simulation will use the real M3 executor. Tree transport must use the
actual accepted M4 fixed-schedule representation proof, not merely tree flattening
or reduced equality across different schedules. Accepted S9's full-world cursor
and configuration equivalence remain useful but are not this weaker protected
observation or an existing active-extension result.

All expected reference executions and observations must be constructed
independently. The twenty-schedule funded family includes both a refused new peer
and its skipped suffix while old7/3/1 transfers remain exact. Observation omissions,
snapshot-only support, new supply, different entry funds and store allocations have
separate negative companions. These are planned controls, not reported passes.

The draft author cannot be its nonauthor planning reviewer. GPT-6 stock-harness
implementation requires refreshed same-candidate nonauthor GPT-6/native Fable5.1
medium planning review, then native Grok/Fable result review and scoped delivery.
No Foreman, native invocation, implementation, commit or change to held inputs
occurred in this preparation. Dynamic provenance, Atomic extension, corpus facts,
untouched evaluation and deployed fidelity remain separate obligations.
