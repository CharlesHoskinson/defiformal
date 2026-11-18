# Shared-liquidity ordering counterexample

Two fresh executions of the existing `Interleaving.Examples` development fixture refute order-independent withdrawal outcomes. They use one shared evolving ledger and the existing `runInterleaving` executor. Initially Alice and Bob have zero USD and the vault has 10. The left invocation transfers 7 USD from the vault to Alice; the right transfers 6 USD from the vault to Bob.

| Complete schedule | Final Alice USD | Final Bob USD | Final vault USD | Located refusal |
| --- | ---: | ---: | ---: | --- |
| left, right | 7 | 0 | 3 | right invocation, local index 0, kernel insufficient funds |
| right, left | 0 | 6 | 4 | left invocation, local index 0, kernel insufficient funds |

The replay checks all 32 ledger cells, the entire capability store, both consumed-slot counts, exact schedules, full branch event/output observations and failure invocation/reason/index. It also checks the two actual attempt chains, including their complete before-worlds and successful receipts/outputs. Alice's protected collateral cell remains 9 and every other cell follows the complete expected table. Neither refusal is an admission failure or an unrelated authority error: the first invocation succeeds in each schedule, and the second has the exact insufficient-funds refusal. No historical fixture or executor source was changed.

Both branches authenticate **Alice** in domain `main`, using the original development boundary with its `fresh` observations and time 100. Bob is the right transfer's recipient. Both calls supply the original 12 live capability IDs, including Alice's invocation and vault-USD debit rights for operations 10 and 11. The catalog grants the declared broad cell access. These are explicit model authority assumptions, not evidence of Bob authenticating himself. Amounts are exact rational USD units; the fixture has no fees, share redemption, external prices or gas model.

In each observed run, Alice USD + Bob USD + vault USD = 10, total paid to Alice/Bob is at most 10, and all actual supply deltas are zero. This suggests the shared-liquidity conservation bound for such transfers. Here it is checked for these two runs, not proved for arbitrary programs or schedules. The counterexample concerns order-dependent allocation and which request refuses; it establishes no profit optimum, sandwich attack, deployed semantics or complete adversary model. The inputs remain development examples.

After building the existing dependency with the pinned Lean 4.33.0-rc2 toolchain, run from any directory:

```sh
python3 /absolute/checkout/scripts/replay_ordering.py \
  --toolchain /absolute/lean-4.33.0-rc2-darwin_aarch64
```

The CLI launches the actual Lean source, prints both full ledgers/capability stores and all 12 assertion results, and requires the exact nonempty completion record. Exit 0 means this finite replay passed; exit 1 means a false comparison or compiler/replay failure; exit 3 means missing/unreadable source, unavailable tools, timeout, or empty/duplicate assertion evidence. It does not install dependencies. The native binary version/hash and source hash appear in the successful result. The [input/assumption record](../../benchmarks/ordering/shared-liquidity.json) supplies exact source pins and complete expected ledgers.

Actual CLI negative controls changed the new source's left/right expected ledger from `(7,0,3)` to `(8,0,2)` and observed `left_right_full_result false` with exit 1; emptying its assertion list produced blocked exit 3. Unreadable-source control also produced exit 3. Each mutation was restored. These exercise the real executor comparison and gate, rather than a duplicate arithmetic implementation. Fresh kernel replay checks this module's definitions; the nonempty imported Interleaving axiom audit checks theorem and supplemental declarations. The counterexample remains finite execution evidence, not a new universal financial theorem.

The accepted five-target compiled package is preserved. This new module's proposed extra package target is recorded separately for a reviewed refresh; this document does not claim the earlier archive contains it. Third-party reproduction, historical effort and corroborated adoption remain open. The new implementation interval is recorded separately as agent wall time, with package repair/waits included where shared; no human/person-hours or missing historical effort are inferred.
