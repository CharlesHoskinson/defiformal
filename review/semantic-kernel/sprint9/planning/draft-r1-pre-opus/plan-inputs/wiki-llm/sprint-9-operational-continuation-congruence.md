# Sprint 9: operational continuation congruence

Status: author planning draft. No Metatheory implementation, proof or production
mutation result is claimed here. All35 implementation tasks are unchecked. The
plan currently contains four capabilities, 17 requirements and 55 scenarios; these
counts come from the actual OpenSpec files and are checked by the planning map.
Independent GPT-6/native Fable planning reviews have not been performed. Because
the GPT-6 worker wrote this plan, another agent must perform the independent GPT-6
planning review. Native result/evidence reviews and delivery remain later gates.

The implementation prerequisite is final accepted, archived and verified delivered
Sprint8. The inspected semantic source is provisional candidate
`a52fb748272fdc08f07d4ad8d2e2a06805b92dd6`; refresh this binding to the final accepted
Sprint8 source/evidence revision before freezing the Sprint9 planning bundle.
Sprint8's runner review added two real production audit-output controls, so the
required final inherited control inventory is 65: 52 earlier controls, 11 proof-tail
parser controls and 2 production-form controls. The current 65-case working-source
inventory has been inspected, but its final accepted source hash is a freeze-time
binding obligation. Planning can proceed while that acceptance completes;
Metatheory implementation cannot.

The change is [operational-continuation-congruence](../openspec/changes/operational-continuation-congruence/proposal.md),
with [design](../openspec/changes/operational-continuation-congruence/design.md),
[requirements](../openspec/changes/operational-continuation-congruence/specs/) and
[unchecked tasks](../openspec/changes/operational-continuation-congruence/tasks.md).
It implements only increment M1 of the
[operational metatheory draft](operational-metatheory-planning-draft.md).

## Operational boundary

A new recursive SeqGroup has empty, action and sequential-child nodes. Leaves
call actual Composition.advance. A sequence passes the entire first-child cursor
to the second. Flatten is separately defined and used to prove correspondence to
existing Composition.continueRun; it is not the implementation of the new runner.
The simulation quantifies over arbitrary existing cursors, including events with
raw worlds, frozen outputs, nonzero absolute indices, complete administrative
stores and first refusals. Associativity is derived for ordered sequential groups,
including issue/invoke/revoke and failed suffixes. It does not swap shared actions
or move a transaction boundary.

The observer records all current typed balances and complete store plus exact
ordered event actions/indices/receipts/outputs, frozen qualified history, nextIndex
and located failure. Past raw event worlds and proof terms are omitted explicitly.
The context grammar is one hole with fixed sequential groups before or after it,
using the same configuration/boundaries. Group equivalence quantifies over every
pair of equivalent input cursors. This is sufficient for actual continuation
substitution; one-entry equality and ledger-only equality are not sufficient.

## Configuration agreement

Agreement is an explicit proposition, not a new admission or certificate checker.
Both complete catalogs must validate. Every supported invocation's registry value
and full component/interface lookup pair must agree, including None and access
fields. Every issue Grant.operation is also supported even when never invoked.
Trusted administrators agree on all domains because an arbitrary starting cursor
can revoke a capability whose domain is read dynamically from its current store.
Identity types, boundaries, histories, indices and complete starting world/store
are fixed. These sufficient hypotheses deliberately remain visible.

Prove exact actual single-step equality including invocation refusal and receipt
extraction, issuance and revocation. Lift through supported sequential lists and
recursive groups, then unchanged invocation-only Parallel, Interleaving and Atomic
operators. Include static suffix admission, shared own-history/index behavior and
all Atomic commit/abort/refusal outcomes under the same policy/label/schedule.
No equality of executions or successful results may be a field of agreement.

## Concrete evidence

The main nonempty three-group fixture starts Alice10/Bob0/Carol0, transfers7 to
Bob while exporting Alice3, consumes that frozen3 to transfer to Carol, then
returns1 from Bob: final Alice1/Bob6/Carol3. Every intermediate world, receipt and
snapshot is independently specified. Other fixtures cover transfer7/refused6 with
an inert funded suffix, nonzero initial indices, issue/use/revoke/denied-use,
index-dependent trusted actors/time, and valid unrelated configuration additions.

Counterexamples separately cover changed old registry/access/output, invalid
added catalog, changed grant-only operation domain, changed trusted admin and
same-ledger/different-store fresh issuance. Continuation negatives omit history,
index, store or universal-input equivalence. Shared-order competition and
one-transaction versus separate-boundary rollback limit stronger claims.

The 14 planned real mutations comprise 8 recursive execution defects (world/store/
history/index reset, failure clearing, skipped/reversed child, constant boundary)
and 6 observation omissions (world/store/history/failure/receipt/nextIndex). The
design binds each to a real production source site, named independent negative
oracle and protected nonempty sibling. Configuration premises receive actual
counterexamples, not invented certificate-checker mutations. Every mutant must
compile; compiler failures are blocked and receive no semantic detection credit.
All 65 inherited actual CLI controls must execute with exact classifications.

## Files and acceptance

New modules are `lean/DefiKernel/Metatheory/{SequentialGroups,Observation,Contexts,
Configuration,ConfigurationGroups,OperatorLifting,Examples,Tests,Audit,Verify}.lean`.
New dedicated mutation scripts and `mutations/metatheory.json` accompany them;
root `lean/DefiKernel.lean` gains one import. Existing kernel/proof namespaces and toolchains
remain unchanged. Every executable declaration precedes its proof marker.

Planning coverage and author validation live under
`review/semantic-kernel/sprint9/planning/`. The future implementation must preserve
full Lean statements, axiom/private-name provenance, exact source/Git/tool/log
bindings, nonempty runtime checks, 14 actual mutants, 65 controls and every prior
regression. Independent planning approval precedes implementation; native Grok and
Fable review substantive results and final evidence before accepted OpenSpec
archive and user-authorized branch push with remote verification. No Foreman or
merge to main.

M2 interface/binding theory, new finite participants, parallel tree routing,
causal monitors, active-peer conservative extension, identity/provenance theory
and atomic-boundary regrouping remain separate later increments. This plan does
not close those roadmap obligations by analogy with sequential list algebra.
