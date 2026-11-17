# Focused IV.2 ordering replay

The accepted requirement permits a replayed counterexample; it does not require a new executor or a universal adversary theorem. Reuse the existing `Interleaving.Examples.sharedLR/sharedRL` shared-liquidity fixture and execute it freshly under the pinned toolchain.

The concrete claim to refute is order-independent withdrawal outcomes. Starting from Alice=0, Bob=0 and vault=10, Alice requests 7 and Bob requests 6. The two complete schedules must produce the actual full expected ledger and located insufficient-funds refusal: left/right gives (7,0,3), right/left gives (0,6,4). Check capability state and actual executor results, not just a manually assembled result table. Preserve the protected cell and explicit authority assumptions.

Use a small focused replay artifact with a nonempty assertion inventory and nonzero failure on a changed expected result. State the suggested shared-liquidity conservation bound and distinguish an observed bound in these two runs from a universal theorem. Do not claim fees, gas, adversarial scheduling completeness, profit optimization, deployed source semantics or a sandwich attack. Existing fixtures remain labelled development examples.

Ship commands, exact inputs and source hashes, raw results, assumptions and the counterexample explanation; include any new compiled module in the evidence package. Obtain exact-candidate independent Astra review. This may follow III packaging before IV.1 because both have their actual prerequisite work available; task numbering does not add a dependency.
