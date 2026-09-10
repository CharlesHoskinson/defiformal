# P24 source-diagnostic independent review

**Decision: diagnostic source evidence is usable, with the limitations listed below.**

This is a fresh independent audit of ROOT-authored P24 source diagnostics only. It does not accept P24, planning task 25.1, a Lean correspondence, or a production model. The production P24 model and Lean implementation have not started. Root will verify and adjudicate this review before use.

Bound evidence: 115 files in `inputs.json`, all SHA-256-identical to the frozen sandbox. Source pin Morpho Blue `8e26ca6a8dbc5089edcd67fb576248810fd2870a`. Private replay directory: `replay/` under this review output. Original root runners were not executed; their paths target original evidence.

## Identities

| Item | Result |
| --- | --- |
| 115 bound files | 115/115 SHA-256 match `inputs.json`; no extra or missing sandbox files |
| solc 0.8.19+commit.7dd6d404 | SHA-256 `7a5c1d3dc9a8eba62bb2ec37192c9178ae5fe8a54a56e5573fd3c9c17cd9eb48`; `--version` stdout SHA-256 `044c0f45afe7cb0dc214fe559421886b399979f22d60350175d476970a5e2683` |
| geth evm 1.15.11 | SHA-256 `d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c`; `--version` stdout SHA-256 `49af542659aefc62a0ec07a860388d6afc05ff1d97bd8be6e7994a7c3afa5954` |
| Compiler settings | viaIR, optimizer runs 999999, evmVersion paris, metadata bytecodeHash none |
| Morpho creation/runtime | 16014/15582 bytes; SHA-256 `4ceb4afc3d61b043adfc4653565457e3b63bba6636b6765a63457e2d7fcf497a` / `6bde416e205d9c375ba8452eab14b8d3bc53256b196a6b93decd794de4db760b` |
| Match to p24-compile-readiness | Exact object match for both diagnostic compiles |
| Fresh compile stdout | Bit-identical to pinned `compile.stdout` for both diagnostics and for attempt 1 |
| Git blobs | 27 snapshot files: recorded git blob SHA-1 equals `sha1("blob "+len+"\\0"+bytes)` computed from the bound files; SHA-256 matches readiness records |

Every compiler-embedded source in the diagnostic standard-json inputs matches a bound snapshot. Production Morpho closure sources are identical across source-closure, public-call, attempt 1, attempt 2, and two-supplier inputs. Mocks used by both probes match `p24-liquidation-test-entry-preparation/upstream` and the two-supplier `upstream/` copies.

Missing pins (none of these are compiled production Morpho sources):

- `PublicCallProbe.sol` and `TwoSupplierProbe.sol` are root harnesses. They have SHA-256 pins in `inputs.json` and no Morpho git blob.
- `evm-source/runner.go` and `evm-source/runtime.go` are geth 1.15.11 launcher sources, SHA-256-bound, not Morpho blobs.
- `src/mocks/IrmMock.sol` is git-blob-pinned in the liquidation-test package and is not imported by either diagnostic compile (IRM is the zero address).
- `runner-r3.py` cites a p16 istanbul genesis template outside this 115-file sandbox. The resulting `paris-genesis.json` is fully specified and hash-bound (`32cb182e5e233a1e276d61ee2ff2cdcb87a518b6528a5a6ff5ef2fcf6b6bf11d`).

## Replay

Source and bytecode were checked before EVM runs. Fresh compiles produced the pinned probe runtimes (`4010cd1bd58a0aad…` public-call, `26943eb0575e63da…` two-supplier). Five `evm run` cases were executed in the private directory with copied genesis, copied/recompiled runtimes, sender `0x100`, receiver `0x200`. All five returned exit 0. Decoded arrays match the pinned `results.json` / `decoded-observations.json`. Raw stdout SHA-256 values are bit-identical to the original evidence.

| Case | Selector / input | Decoded observation |
| --- | --- | --- |
| Healthy refusal | `probe(uint256)` scenario 0 | Exact `HEALTHY_POSITION` flag 1; market and position structs unchanged; seized/repaid 0 |
| One repaid asset, zero seized collateral | scenario 1 | Returned seized 0, repaid 1; borrow assets 300→299; collateral stays 400; supply assets unchanged |
| Partial no-loss liquidation | scenario 2 | Seized 1e18; repaid 92500000000000001; collateral remains 9e18; total supply assets stay 2e18 |
| Full bad-debt clamp | scenario 3 | Seized 10e18; repaid 92500000000000002; reconstructed unclamped 907499999999999999 > remaining 907499999999999998; borrow assets/shares and collateral become 0; supply assets fall by the remaining amount |
| Two-supplier rounding | `probe()` | Market supply 2→1; `expectedSupplyAssets` [1,1]→[0,0]; each supplier keeps 1000000 shares; seized 10, repaid 1; borrow assets and borrower collateral 0 |

Genesis used for the five successful runs: London and merge enabled, no `shanghaiTime`, no `cancunTime`, block `0x0`, timestamp `0x1`, empty `alloc`. The bound geth runtime sets a non-null `Random` (empty hash). `evm run` installs wrapper runtime with `SetCode` on the receiver and does not use `--create` for the probe. Production Morpho, mocks, and oracle are constructed with `new` inside the probe. This is a configured Paris local diagnostic, not an observation of a deployed network or of arbitrary transaction reachability.

## Classified failures (not production defects, not success)

Attempt 1: solc process exit 0 with JSON `DeclarationError` 2904 (`WAD` is declared in `MathLib.sol`, not `ConstantsLib.sol`). Independent recompile of the archived attempt-1 input reproduced process 0, one error, and bit-identical stdout. Zero EVM executions. The successful harness imports `WAD` from `MathLib`.

Attempt 2: compiled successfully (same standard-json and compile stdout as the successful run) then `evm run` exited 2 with `panic: can't commit genesis block with number > 0` before Morpho code. Archived `attempt2/paris-genesis.json` has `"number": "0x1"`. Independent replay of that genesis with the successful probe runtime reproduced the same panic text, empty stdout, and exit 2. Go panic stack pointer bytes differ across runs; the panic line and `MustCommit` site do not. The later successful runner reuses that exact compile with genesis block 0.

## Semantics in scope

**Healthy refusal.** The harness requires `Error(string)` with `ErrorsLib.HEALTHY_POSITION` and compares `keccak256(abi.encode(beforeMarket, beforePosition))` only. It does not compare global token balances, owner, `feeRecipient`, or other storage.

**Zero-seized successful liquidation.** `UtilsLib.exactlyOneZero` constrains the requested `(seizedAssets, repaidShares)` pair. Scenario 1 requests `(0, 1)` and Morpho returns seized 0, repaid 1. Returned seized collateral is a computed quantity, not the input constraint. Collateral remains 400.

**Extra borrow share and the min branch.** Scenario 3 borrows 1e18 assets then one extra share, drops the oracle to `ORACLE_PRICE_SCALE/100`, and seizes all 10e18 collateral. After repayment, remaining borrow assets are 907499999999999998. Morpho `liquidate` takes `UtilsLib.min(totalBorrowAssets, badDebtShares.toAssetsUp(...))`. The harness reconstructs the unclamped conversion with the pinned arithmetic libraries; Morpho does not return that figure. Observable Morpho state is independent of that reconstruction: collateral 0, borrow assets/shares 0, supply-asset loss equals remaining-after-repay. The reconstructed unclamped value is remaining+1, which is consistent with the min branch taking remaining assets. Stored supplier shares are unchanged in all four public-call cases.

**Two-supplier counterexample.** Two distinct supplier addresses `0x1001` and `0x1002` each receive 1 supplied asset (1e6 shares). The harness posts 10 collateral, borrows 2, then sets oracle 1e36→1e10 and liquidates 10 collateral at LLTV 0.75. Market loss is 1. Pinned `MorphoBalancesLib.expectedSupplyAssets` uses `MorphoLib` `extSloads` and `SharesMathLib.toAssetsDown` with virtual shares 1e6 / virtual assets 1. Getters go [1,1]→[0,0]; summed getter decrease is 2. This disproves equality between market loss and the sum of those rounded getter decreases for this source case. It does not prescribe an allocation policy and does not execute supplier withdrawals or sequential redemption.

**feeRecipient caveat.** `expectedSupplyAssets` is documented as wrong for `feeRecipient` because fee-share minting is omitted. Constructor sets `owner` to the probe (`address(this)` = receiver `0x200`) and leaves `feeRecipient` at `address(0)`. Fee is never set (market fee 0). Timestamp is 1 and `lastUpdate` is 1, so `expectedMarketBalances` skips interest (`elapsed == 0`). The two suppliers are not `feeRecipient`. The caveat does not apply to this case.

The earlier local `rounded-claims-probe.py` is an arithmetic diagnostic only (`source_execution: false`). The two-supplier EVM case is the reachable-state counterpart of that integer formula, still not an allocation theorem.

## Upstream liquidation tests

`LiquidateIntegrationTest.sol` and `BaseTest.sol` are source references. `tests_executed` is 0. They were not run as Foundry tests and are not newly passing.

- `testBadDebtOverTotalBorrowAssets` calls `liquidate` after one extra borrow share and has no explicit post-state assertions.
- `testSeizedAssetsRoundUp` expects seized 0 / repaid 1 at LLTV 0.75, collateral 400, borrow 300, price `ORACLE_PRICE_SCALE - 0.01e18`.
- Tests use mocks and cheatcodes (`vm.prank`, `vm.warp`, `vm.expectRevert`, `vm.expectEmit`, `vm.assume`).
- Single-supplier fixtures do not define a multi-supplier rounded-loss allocation.

The four public-call EVM cases are independent deterministic observations that correspond in intent to healthy refusal, zero-seizure repayment, partial no-loss seizure, and the extra-share clamp. They do not execute the Foundry suite.

## Runtime and coverage limits

Configured fork: genesis enables forks through London and the merge; Shanghai and Cancun times are absent. Bound `runtime.go` `setDefaults` would enable Shanghai/Cancun only if `ChainConfig` were nil; `runner.go` supplies the genesis config, so that path is not taken. No unobserved deployed-network or arbitrary-transaction reachability claim follows.

Not covered: supplier withdrawals; interest; time progress; fees; callback reentrancy; nonzero IRM; multi-actor authorization beyond the harness owner/borrower/liquidator (and the two funded supplier positions in the second probe); global-state comparison on healthy refusal.

The two-supplier probe runtime is 29052 bytes. Solc warns that this exceeds the 24576-byte Spurious Dragon limit. `evm run` injects that runtime locally. This is not a mainnet-deployability claim for the harness.

Attempt-2 `commands.json` records `--prestate` as the original working-directory genesis path, which later holds the successful block-0 file. The failed genesis is the archived `attempt2/paris-genesis.json`. Classification is taken from that archive plus the panic, not from the later path contents.

## What this review does not accept

- P24 implementation or task 25.1
- Lean model or proofs
- A general loss-conservation theorem
- An allocation/remainder contract
- Foundry test passage
- Mainnet or historical-deployment claims

A correctly scoped diagnostic does not require an extra full-program proof in order to be used as source evidence for later modeling. The allocation contract, mutants, nonzero-interest and callback coverage, and independent planning-gate acceptance remain open.
