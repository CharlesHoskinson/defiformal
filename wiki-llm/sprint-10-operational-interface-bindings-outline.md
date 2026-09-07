# Sprint 10: operational interface and binding preservation

The [OpenSpec planning candidate](../openspec/changes/operational-interface-binding-preservation/proposal.md)
fixes increment M2: exact finite-region accounting, conditional declared-total
preservation, and initialized global balance bindings over actual execution.
It has four capabilities,17 requirements,57 scenarios,34 unchecked tasks,
20 fixture contracts,14 planned source mutations and65 inherited CLI controls.
No M2 implementation or planning acceptance is claimed.

Sprint9 is accepted and delivered. Its authoritative identities are:

- Lean source `eec499d613688137a341f3556cd80ca461dd2ee9`.
- Source/evidence delivery `ec9ed80457d7a9c4064d26ab193591579027abae`.
- Archive and verified remote `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff` on
  `semantic-kernel-pivot`, without a main merge.

[Archive delivery](../review/semantic-kernel/sprint9/archive-delivery.json) and
[final acceptance](../review/semantic-kernel/sprint9/acceptance/final-acceptance.json)
retain exact review and delivery identities. The
[M2 dependency/baseline binding](../review/semantic-kernel/sprint10/planning/official-preparation/dependency-baseline.json)
checks relevant source equality through delivery and preserves original execution
identities:16 Lean commands,14 Metatheory detections and65 controls at eec499d;
13 historical suites at c880acf with scoped dependency equivalence. These are
accepted predecessor evidence, not executions of new Interface code.

Implementation waits for the same frozen S10 candidate to receive nonauthor stock
GPT-6 and native Fable5.1 medium planning acceptance. Request
`claude-fable-5-1[1m]` with `--effort medium`, recording the actual returned model.
Substantive implementation/evidence reviews use native Grok and Fable5.1 medium.
Stock GPT-6 implements through the Codex harness. No Foreman.

## Mathematical and runtime scope

Use the existing typed state, actual evaluated receipts, static component resource
ports, sequential cursors and binary Interleaving. Introduce no new storage alias,
financial primitive, participant scheduler or transaction operator. Preserve the
historical `Defialgebra.Interface` and `Defialgebra.Nary` statements.

New modules belong in `lean/DefiKernel/Interface/`. `Regions.lean` supplies finite
set-valued regions, `balanceSum`, actual `receiptDelta`, and an explicit same-domain/
asset well-formedness premise. `Accounting.lean` lifts the actual exact-cell
receipt equation to finite sums, including administrative identity and signed
mint/burn or boundary-crossing deltas. The bridge starts from actual executeStep
success and `Composition.executeStep_sound`, then `Atomic.step_receipt_balance`;
it cannot assume the desired accounting equation or substitute a chosen receipt.

`Bindings.lean` resolves globally qualified resource exports and queries exact
same-domain/asset balance equalities. Live resource names are distinct from
historical output observations. Actual imports identify the same exported cell;
a binding between different cells demands an initialized invariant. The query
has catalog-first and exact left/right/type/balance precedence as fixed in the
[design](../openspec/changes/operational-interface-binding-preservation/design.md).
It is a concrete query, not an inferred semantic certificate.

`Preservation.lean` derives every-prefix invariants from initialization and locally
quantified actual-step obligations. Region conservation needs actual write
confinement and neutrality over the region's shared portion. A state-dependent
declared total additionally needs value-valued support and writes excluding that
support. Equal initial balances alone, catalog validity and whole-asset supply
neutrality do not establish those premises. Equal actual endpoint receipt effects
preserve initialized edge equality; refusal and skip identities preserve balances
while administrative store changes remain observable.

The accepted M1 equation `Metatheory.runGroup_eq_continueRun cfg boundaries cursor group`
relates the actual recursive group executor to continuation on its flattening.
Use its full cursor equality. Arbitrary supplied cursors require actual advance/
continuation induction or an entry-indexed suffix trace: existing genesis
`TraceSound.nil` cannot justify arbitrary old history or a nonzero entry index.
Count only new successful event receipts after the supplied entry-event prefix.

Global edge-list concatenation, reorientation, duplicate/permutation and
associativity laws concern agreement or query success, not identical first-error
payloads or participant regrouping. Equal symmetric closures are sufficient for
agreement equivalence, not necessary: transitive equalities give the explicit
counterexample. No finite-participant executor is introduced by three port names.

## Concrete witnesses and evidence

The design specifies the complete finite universe,20-cell ledgers,17-entry initial
store, operation templates, exact permissions, receipts, outputs and failures.
Expected observations must be constructed independently of production queries and
executors. Nonzero transfer, boundary loss, minting, repeated receipt targets,
private/exposed total support, aliasing and deliberately broken initialized
bindings provide distinct successful and refused cases.

F07 retains its single paired-debit witness and adds an actual M1 seq of two
op102 leaves from5/5/0:4/4/2 then3/3/4. Each prefix has an independent full expected
cursor and successful A=B query. This witnesses initialized group-binding
preservation. F16 starts at6/4, absolute index2 and supplied old output history;
its snapshot-driven group returns to6/4 at nextIndex4. It tests total/history/full
cursor preservation and is explicitly not an initialized A=B witness.

F17 executes paired debit, peer paired debit and refusal. F19 orders left success,
left refusal, then peer success; F20 also skips a failed left suffix before that
peer. Expected4/4/2 refusal retention and later3/3/4 peer state, exact stores,
histories, local indices and actual successful receipt counts are mandatory.

All14 planned mutants must compile, flip their designated independent comparison
and preserve their specified sibling. Two schema-level global positives and the
per-mutant sibling matrix remain distinct; neither may silently stand in for the
other. The full65-case predecessor adaptation binds payloads, names, root/namespace,
proof/error patterns and expected exits. Command/harness timeouts are600/1500
seconds with actual wall time; blocked or compile-only outcomes get no financial
detection credit. Complete proof inventories retain full statements, actual axioms,
private/generated names and generic/instance/counterexample distinctions.

## Remaining gate and roadmap

The [author preparation](../review/semantic-kernel/sprint10/planning/official-preparation/READINESS.md)
will support an exact committed planning bundle. It does not replace independent
planning review, implementation evidence, native source/evidence acceptance or
verified delivery. New runtime definitions precede `-- BEGIN PROOFS`; Lean checks
run from `lean/` with the pinned toolchain and no sorry/custom axioms/native_decide.

M3 remains finite-participant execution and initialized causal induction. M4–M6
retain tree simulation, compatible schedules, active extension and stronger Atomic
conditions. Claims/liabilities/asynchrony, capability provenance, serialized
certificates, corpus provenance, untouched evaluation, machine arithmetic,
financial libraries and deployed fidelity remain separate roadmap obligations.
