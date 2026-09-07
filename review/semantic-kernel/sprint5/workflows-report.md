# Sprint 5 reference workflows

Implemented with GPT-6 through the stock Codex harness. Foreman was not used.
This report covers `Composition/Examples.lean` and `Composition/Tests.lean`.

## Executed evidence

From `lean/`, these commands completed with exit 0:

```text
lake env lean -o .lake/build/lib/lean/DefiKernel/Composition/Examples.olean DefiKernel/Composition/Examples.lean
lake env lean DefiKernel/Composition/Tests.lean
```

The second command executed 30 named, nonempty comparisons. Every comparison
returned true; output is in `workflows-runtime.log`.

Source SHA-256 at this check:

- Examples.lean: `348a60d9428fdbe2854dbb8919d1f6bbb915d73179da7515be1b7ecc0d0e8956`
- Tests.lean: `61975390eff56be020246b63b7a42f15e3115d5e1ff0b95a785c137cc0c3932f`

## Completed bounded tasks

- Task 2.5: An initialized collateral contract has proved obligations. Preservation
  uses the explicit boundary assumption `1 ≤ price`; the local guarantee alone
  is not advertised as establishing it. A boundary adapter and
  `workflow_conditional_invariant` instantiate `run_contract` with a visible
  `localGuarantee` premise.
- Task 6.1: Three components have unique operation/port identities, private
  cells, and an exact shared USD import/export. The complete initial 32-cell
  ledger and all twelve capability entries are compared to independent tables.
- Task 6.2: Transfer 3, deposit 4, withdraw 2 produces Alice USD 7/shares 4,
  Bob USD 3, vault USD 20. Ordered receipts contain share supplies +2 and -2.
- Task 6.3: Transfer 8 before deposit 4 retains Alice USD 2/Bob USD 8;
  deposit 4 before transfer 8 retains Alice USD 6/shares 6/vault USD 24.
  Each rejects the second action and skips a funded transfer suffix.
- Task 6.4: Transfer 3 emits historical USD 7; its deposit consumes 7 and leaves
  Alice USD 0/shares 15/2, Bob USD 3, vault USD 27. A two-transfer sibling
  distinguishes output index 1 (USD 5) from index 0 (USD 7). Share-unit,
  forward/unavailable, and unknown-port bindings refuse with exact provenance.
- Task 6.5: Issue/use/revoke/use retains the first funded transfer, then refuses
  invocation authority at the second use. Complete stores include the issued
  entry and final tombstone. The live-repeat sibling makes two funded transfers.
- Task 6.6: Funded vault withdrawal has a live debit capability but refuses
  foreign-private access. Matching shared-write succeeds; read-only refuses.
  A read hidden in an unselected expression branch refuses, as does the wrong
  component. Separate actor/configuration fixtures retain complete initial state.
- Task 6.7: Empty, first/middle refusal, failed continuation, protected collateral,
  and append/resume are checked. The suffix consumes an earlier output under
  absolute position 2, with administrator at position 0, Alice afterward, and
  time `100 + index`. A time guard requires 102; a constant-time 100 sibling
  refuses. One-pass and resumed results each match the same independent oracle.

For every successful expected event, comparison includes absolute index, full
step identity, full pre/post ledger and stores, receipt request arguments,
evaluated guard/deltas/supplies/read/write declarations, effects on all cells,
supply on all domain/asset pairs, and output identities/values/order. Cursor
comparisons include the whole output history and exact failure index/step/reason.
Expected balances and tables are constants; expected operation deltas use the
reference arithmetic directly and never invoke the implementation under test.

## Proof evidence and limits

Examples adds twelve named Lean theorems: two contract-obligation witnesses,
initialization, support, two counterexamples, two accounting instances,
nonnegativity, concrete protected-write disjointness, concrete collateral framing,
and conditional workflow invariant preservation. `workflow_protected_writes`
uses `decide +kernel`; no `native_decide`, `sorry`, or custom axiom is introduced.
The frame proof applies the general preservation theorem after that concrete
write-disjointness proof. The counterexamples exhibit a predicate of Alice USD
that cannot be framed using collateral support, or without disjointness from
Alice USD writes. A runtime transfer separately confirms that balance changes.

These are finite reference examples and proof instances. The boundary truth and
local guarantee in the conditional invariant remain explicit premises. Mutation
results, project-wide axiom audits, full build, and external review are recorded
by the integration tasks, not claimed by this file-level report.
# Integration follow-up

The initial file-level handoff below predates final formatting and the boundary
contract correction. The final boundary fixture assumes `now = 100` and guarantees
nondecreasing collateral; it does not interpret time as a price. Its conditional
invariant still requires local guarantee premises. Current source hashes and all
30 workflow comparisons are covered by the integrated `build-verification.json`
and `final-runtime.log` (93 total comparisons). Initial handoff hashes are retained
as historical evidence.
