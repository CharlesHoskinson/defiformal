# P27 GMX source-preparation audit

Independent native Grok 4.6 high audit of the frozen P27 GMX source, dependency, and compiler-preparation packet. Requested model is grok-4.6 high. Actual returned model is unknown until terminal telemetry. Current routing is AGY `gemini-3.8-flash-high` as author and Grok 4.6 as independent auditor. This session inspected only the frozen sandbox. AGY P19 work was not read.

**Verdict: usable for source preparation only.** Changes are not required in the captured packet identities. Observation mapping is required before task 28.1 can freeze a contract. P27 and tasks 28.1–28.3 remain open. Compile and source hashes are not a substitute for family acceptance.

## Scope and method

Write directory: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p27-source-grok-r1`. Sandbox: `/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox`. No author worktree, live draft caches, subagents, network, Foreman, extra windows, branches, commits, or pushes. Historic absolute `/home/charl/defiformal/review/...` paths in compiler `result.json` were mapped onto the sandbox. Live cache paths for the failed 100MiB archive, the solc binary, and the solc-build directory were recorded and not opened.

Read-only Python probes hashed sources, Git blobs, HTTP receipts, yarn.lock integrity, npm archives, and decompressed standard-JSON input/output. They did not execute solc, yarn, npm, Hardhat, tests, or capture/verify scripts. Empty-check and altered-byte controls fired as designed: the identity probe refuses an empty packet, and an in-memory comment appended to `PositionUtils.sol` is rejected while the sealed file is unchanged.

## Pin identity

Official repository `gmx-io/gmx-synthetics`, commit `a85ea3491c19c93bb4b5a002d9b358fb769b7849`, tree `0cc923c20087fdfab3659d672af6ce8a02665b19`. Discovery `commit.json` and `tree.json` match those SHAs. HTTP receipts for those bodies hash to the stored JSON. This is observed official main HEAD, not a deployed chain identity. The commit message is a ReferralStorage tier script addition; that does not make the tree a production deployment.

The first archive capture failed the 100MiB limit. `failure.json` records 104857600 partial bytes, `complete_archive: false`, and zero extracted files. Those partial bytes are not in this sandbox and were not followed from the live cache. Successful attempt2 fetched 89 raw files, each with an HTTP receipt and Git blob check against the commit tree.

Independent identity probe results:

| Claim | Measured |
|---|---|
| Attempt2 packet seal | 188 files, hashes match `root-seal.json` |
| Captured files | 89 = 78 Solidity + 3 unexecuted TypeScript + 8 configs/docs |
| Source bytes | 1,535,718 |
| Git blob and HTTP bindings | 89/89, tree blobs match |
| Static navigation anchors | 16 needles present on recorded lines |
| Source-only lexical imports | 213 local edges, 22 external occurrences |
| Failed-archive packet | 7 sealed files, no complete archive |

The lexical graph is an import-string walk. It is not a compiler AST or a runtime proof.

## Dependencies

Selected compile closure uses exact `yarn.lock` OpenZeppelin 4.9.3 and prb-math 2.4.3. Both npm archives are in the dependency packet. Independent SHA-512 of each archive matches the lock `integrity` field. Independent SHA-1 matches the yarn `resolved` fragment (`00d7a8cf35a475b160b3f0293a6403c511099364` and `a0121111aeae49fe5686db4aef422b785101bf7b`). Archives contain 374 + 34 regular members. Selected extracted sources are 11 OpenZeppelin files and 2 PRB files, 13 total, each matching the corresponding archive member.

Closed selected graph: 91 sources, 243 lexical edges, 0 unresolved. Package scripts were not executed. This is selected-import closure, not a full test or node_modules install.

## Compiler packet

Recorded compiler is solc 0.8.29+commit.ab55807c, SHA-256 `18d418a40dc04d17656b1b5c8a7b35cfbab8942b51f38d005d5b59e8aa6637e0`. Packet HTTP receipt and `version.stdout` bind that identity. The live binary path was not hashed or executed in this session. Root version and standard-JSON commands remain prior evidence.

Hardhat config and the stored standard-JSON input declare optimizer enabled, runs 10, `constantOptimizer: true`. Input has no explicit `evmVersion`. Parsed metadata from all 91 contracts reports Cancun. Decompressed `input.json.gz` and `stdout.json.gz` match claimed stdin/stdout SHA-256 values. All 91 standard-JSON sources equal the sandbox files. Diagnostics are empty. Errors 0, warnings 0.

Independent parse of stdout: 91 contracts, 72 nonempty creation objects, 10 with unresolved library links (`CallbackUtils`, `FeeUtils`, `LiquidationUtils`, `MarketUtils`, `DecreasePositionCollateralUtils`, `DecreasePositionUtils`, `IncreasePositionUtils`, `PositionUtils`, `ReferralUtils`, `SwapUtils`). Those objects are not deployable-ready bytecode. Full Hardhat, EVM, and tests were not run.

## Funding, equity, and liquidation source

Collateral tokens, signed PnL, liquidation health, borrowing fees, position fees, and funding claimables are different quantities.

Liquidation health in `PositionUtils.isPositionLiquidatable` adds signed position PnL and price impact to collateral USD and subtracts token costs converted at `collateralTokenPrice.min`. Nonpositive remaining equity, min collateral, and min collateral for leverage are liquidatable conditions. The fee call used for that check sets `isLiquidation` false, so liquidation fees are not part of that health figure. `forLiquidation` only switches the min-collateral factor.

`willPositionCollateralBeSufficient` starts from token collateral USD and deducts negative realized PnL. Positive PnL is not credited. Comments state that including positive PnL could allow price manipulation to bypass the check. Withdrawal is later capped to `remainingCollateralAmount` token units.

Funding in `PositionPricingUtils.getFundingFees` is an unsigned `fundingFeeAmount` rounded up and separate `claimableLongTokenAmount` / `claimableShortTokenAmount` rounded down. `MarketUtils.getFundingAmount` uses an unsigned cumulative-factor difference. Claimable records are keyed by market, token, and account. `claimFundingFees` zeros the account key and `transferOut`s the token. That is not automatic cash in the position.

`payForCost` rounds cost up in collateral-token units, spends output tokens then remaining position collateral, then converts leftover to secondary output with integer division. `remainingCostUsd` is recomputed from the truncated secondary amount. That residual is source-rounded, not exact rational debt.

## Actual guards versus exceptional success

Do not invent a single refusal for P27.

- A liquidation order whose position is not liquidatable reverts `Errors.PositionShouldNotBeLiquidated` in `DecreasePositionUtils` (lines 220–238). Unexecuted `LiquidationOrder.ts` expects that revert at one oracle price and a later successful liquidation at a lower price. The test was not run; the Solidity guard is the authority.
- Ordinary unpaid costs revert `Errors.InsufficientFundsToPayForCosts` from `handleEarlyReturn` when `isInsolventCloseAllowed` is false.
- Insolvent early close is allowed only for a full-size close that is a liquidation order or secondary ADL. That path emits `InsolventClose` with `remainingCostUsd` and the payment step, then returns empty fees. That is successful exceptional behavior, not executor refusal. Comments note that a manual close should still revert when collateral is insufficient, while liquidation should complete.
- `validatePosition` reverts `LiquidatablePosition` if the remaining nonzero position would be liquidatable. Partial manual close of a partially liquidatable position is discussed in source comments as still possible because the remaining-size check is skipped when size is zero.
- Collateral-only withdrawal (`sizeDeltaUsd == 0`) reverts `UnableToWithdrawCollateral` when remaining collateral would be insufficient; otherwise the order may auto-zero the collateral delta.
- Secondary-token funding payment reverts `EmptyHoldingAddress` if the configured holding address is zero. The subsequent increment is claimable collateral for that address, not an executed swap back into the pool.
- `LiquidationUtils.createLiquidationOrder` builds a full-size liquidation order and does not itself call `isPositionLiquidatable`. Admission is at execution.

Funding-shortfall and insolvent-close events mention insurance or pool top-up in comments. Those comments are not executed compensation.

## Assumptions that remain explicit

Oracle truth is an interface plus `OracleUtils` in this slice; `Oracle.sol` is not captured. Bank `transferOut` is `onlyController`. `onlyLiquidationKeeper` exists on `RoleModule`, and `LIQUIDATION_KEEPER` is declared, but `LiquidationHandler` and `AdlHandler` are outside the 89 files. Holding-address configuration, positive prices, token decimals, pool balances, and transaction finality remain assumptions.

## What this does not close

Task 28.1 still needs AGY to freeze signed funding and equity observations and to select the actual source rejection gate, then independent review of that freeze. Candidate actual gates already in this pin include `PositionShouldNotBeLiquidated`, `InsufficientFundsToPayForCosts`, `LiquidatablePosition`, `UnableToWithdrawCollateral`, and `EmptyHoldingAddress`. This audit does not pick one as accepted 28.1.

Task 28.2 (Lean `Margin`, signed reconciliation, explicit bankruptcy residual) and task 28.3 (funding success, allowed liquidation/bankruptcy exceptional success, frozen refusal, PnL-as-cash mutant, source-independent equity-equation negative) remain open.

## Probe evidence

Python 3.14 identity: exit 0. Identity probe: 106 checks, 0 failures, empty-check false, altered-byte control rejected, source unmodified, exit 0, stdout SHA-256 `c3751794684b961d8f01018596e5eaf2c36553a2ad33fe5f69d77beadf241b4e`. Observation extract: 12 excerpts, 0 failures, empty extract blocked false, exit 0, stdout SHA-256 `163ff91dea7b7674e8977072fca1584c24f0ed4cfd37e648ce0a9b81c97e0725`. Exact argv, cwd, timestamps, and hashes are in `commands.json` and `raw/*.command.json`. No probe failures were discarded.

Root source, dependency, and compiler verification packets were classified as prior identity evidence, not this session’s execution or a proof.
