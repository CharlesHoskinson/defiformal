# Sprint 9: operational continuation congruence

Status: author planning draft. No Metatheory implementation, proof or production
mutation result is claimed here. All35 implementation tasks are unchecked. The
plan currently contains four capabilities, 17 requirements and 55 scenarios; these
counts come from the actual OpenSpec files and are checked by the planning map.
Frozen r1 independent GPT-6/native Opus planning reviews are preserved; native
Opus returned ACCEPT WITH LIMITATIONS with six required changes. This author
revision addresses those changes and needs review of its new candidate bytes.
The author is not its independent GPT-6 reviewer. Implementation remains gated;
native result/evidence reviews and delivery remain later gates.

The Sprint8 dependency is accepted source
`99e2e2c61a1a3c5249026921efdc6cd41ac8f21d`. Source/evidence commit
`2c038094c031723f3ade35d8b3f506ccff5b1d3b` and archive metadata
`9501f0a4f0480b2a42ff197907d548cf0c610773` were pushed and remotely verified on
`semantic-kernel-pivot`; the exact acceptance and delivery records are bound in
`review/semantic-kernel/sprint9/planning/dependency-baseline-binding.json`.
Fresh baseline14 Lean commands and13 Python suites passed at that accepted source.
The Python metadata correction is retained and its final hashes are used.

The inherited control inventory is65:52 earlier controls (including the base
`runtime-definition-after-proof-boundary` case),11 NEW proof-tail controls and2
production-form controls;12 controls concern proof-tail behavior in total, including the accepted CLI-log pointer correction.
All65 executed in the fresh baseline. Their accepted harness source hash is bound,
not inferred from a case count. All35 plan task boxes remain unchecked until the
actual planning gate; baseline/dependency completion is recorded separately.
Revised-candidate independent GPT-6/native Fable 5.1 acceptance and implementation remain pending.

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
and located failure. The production comparator exposes separate local conjuncts
for ledger/store/events/history/index/failure and event index/step/receipt/outputs;
existing equality reuse is proof-only. Past raw event worlds and proof terms are
omitted explicitly. Observer-only pairs are labeled synthetic arbitrary/unreachable
cursors and are not financial execution traces.
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
are fixed. Identity types and instances are shared theorem binders, not an
agreement field. These sufficient hypotheses deliberately remain visible; the
negative examples establish materiality, not minimality of stronger assumptions.

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
one-transaction versus separate-boundary rollback limit stronger claims. Registry
changes preserve signature/output-domain validity; grant-only domain-changing
operations have no declaring catalog component; changed access/output declarations
preserve ownership/import/export validity so unrelated failures do not mask the
intended counterexample.

The 14 planned real mutations comprise 8 recursive execution defects (world/store/
history/index reset, failure clearing, skipped/reversed child, constant boundary)
and 6 observation omissions (world/store/history/failure/receipt/nextIndex). The
design binds each to a real production source site, named independent negative
oracle and protected nonempty sibling. Configuration premises receive actual
counterexamples, not invented certificate-checker mutations. Every mutant must
compile; compiler failures are blocked and receive no semantic detection credit.
All65 inherited actual CLI controls must execute with exact classifications.
M08 replaces only the new leaf call boundary argument by `(fun _ ↦ boundaries 0)`.
The complete driver namespace/root/proof-regex/error-text/fixture mapping is fixed
in design.md, including `Metatheory runtime comparisons failed: N`. Audit imports
reuse Atomic.Examples/Parallel.Examples and avoid imported Tests/proof-only fixture
modules; Verify imports proof-lifting modules separately. Runner commands have
explicit 600-second limits and harness runner subprocesses1500-second limits, with
measured command/case/variant wall time. Timeouts are blocked exit3, never detections.

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
Fable 5.1 at medium effort review substantive results and final evidence before accepted OpenSpec
archive and user-authorized branch push with remote verification. No Foreman or
merge to main.

M2 interface/binding theory, new finite participants, parallel tree routing,
causal monitors, active-peer conservative extension, identity/provenance theory
and atomic-boundary regrouping remain separate later increments. This plan does
not close those roadmap obligations by analogy with sequential list algebra.

## Focused runner clarification review

The r2 semantic plan was accepted with limitations by GPT-6 and Opus. Three further Opus requests clarify inherited timeout evidence, exhaustive literal adaptation and exact-once mutation needles. The r3 review supplies the full revised plan and runner scripts with the counted adaptation inventory, while binding unchanged semantic source to its already-reviewed r2 Git objects. No implementation begins before both revised verdicts pass. The inaccurate old spec locator is corrected to the actual explicit `review/semantic-kernel/sprint8/mutation-spec.json` input.

The user restored Fable 5.1 at medium effort for future external reviews. The r3 bundle therefore includes the complete unchanged semantic-source closure for Fable to inspect independently, alongside the runner clarifications. Completed Opus reports remain historical evidence under their actual model identity.
