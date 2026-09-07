The revised financial fixtures retain all 148 runtime IDs and pass the focused Tests build and direct Audit execution. This is author development verification; no successor production or native acceptance is inferred.

The four designated routing comparisons now run different programs against explicit complete expected cursors:

- `world-chain`: transfer 7 from Alice to Bob, then a literal transfer 1 from Alice to Carol. Expected balances are 2/7/1, with both raw events and snapshots 3/2.
- `history-chain`: a zero-dollar producer preserves the entry ledger and publishes USD10, then the second child consumes that qualified frozen snapshot. Expected balances are 0/0/10, with raw events and snapshots 10/0.
- `index-chain`: literal timed transfers 2 and 1 start at index 9, with times 209/210 and Alice as principal. Expected balances are 7/2/1, event positions 9/10, snapshots 8/7, and next position 11.
- `child-executed`: an empty first child followed by a funded transfer 2 to Bob. The first child leaves the complete entry cursor unchanged; the second child must produce the independently specified event, world 8/2/0, snapshot 8, and next position 1.

Each comparison uses `fullCursorEq`, preserving exact world/store, raw before/post worlds, request/evaluated receipt, outputs, index and failure. Expected data never calls `runGroup`, `flatten` or the production observer. Distinct programs do not imply disjoint mutation false inventories; successor production execution must measure overlap.

The designated `receipt-diff` still changes the evaluated transfer amount from 7 to 6. The supplemental `event.evaluated` changes only the evaluated `declaredStateReads` list from empty to the protected collateral cell. Both are explicitly synthetic observer pairs; no reachable-trace claim follows.

`build-attempt1.*` preserves a development compiler failure caused by using nonexistent field `declaredReads`; it was corrected to `declaredStateReads`. The final successful build and runtime commands have separate records. That compiler failure receives no financial mutation detection credit. The initial Examples LSP check passed; the Tests LSP reported stale imports, resolved by the targeted build.

The original c880 source, native reviews, official execution artifacts, and original development reports remain untouched. Fresh source bindings and actual command identities are in `runtime-inventory-148.json`; full current scenario development reconciliation is in `../../coverage-development-r2/coverage.json`. Only Examples.lean and Tests.lean were changed by this task; OperatorFixtures.lean is unchanged. Parent-owned prose changes are separate.
