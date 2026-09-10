# P23 ordered-redemption source-entry audit

**SOURCE_ENTRY_DIAGNOSTIC_ONLY_NO_ACCEPTANCE**

Disposition: **source candidate usable with obligations** (Liquity V1 pin `3e64ee1b52c50d51587c64c1cf75e0ba82934979`). This audit does not accept a pin, freeze observations, close tasks 24.1–24.3, or close P23 / P10 / R12.

Independent auditor: native Grok 4.6 high, fresh session, requested model `grok-4.6` from `dispatch.json`. `native.jsonl` usage records contain token counts and signatures but no provider-returned model name. Root preserves actual `modelUsage` separately. No compiler, EVM, Lean, or network was used. Source inspection is not execution.

All 41 `inputs.json` hashes matched. Three logging probes failed and are preserved (`probes/02-archive-members-failed`, `probes/08-hash-verify-argv-failed`, `probes/09-manifest-false-literal-failed`). They are script errors, not hash mismatches.

## Binding contract

Tasks 24.1–24.3 and the `source-bound-library-families` requirement bind P23:

- Freeze ordered-redemption observations and select the **actual empty-set guard** from a pin, distinct from P10. Locate a pin or record `blocked_missing_source`. Do not invent a refusal.
- If pinned, implement `lean/DefiKernel/Redemption/` and prove ordered eligible redemption with matching payment/debt reduction.
- Add partial-fill success, empty-set refusal, a skip-first-eligible mutant, and a source-independent payment-without-debt-reduction negative. Do not close R12.

The spec scenario is: when no trove is redeemable under the pinned order, redemption refuses, without rewriting the liquidation-source overlay.

The binding text is **Liquity-style ordered redemption**. It does not name Liquity V2, BOLD, or interest-rate order.

Historical `P2-SCOPE.md` / `P2-CONTRACT.md` (hashes verified) are a different, superseded positive-program liquity re-spec: BOLD `TroveManager.sol:770,785`, prefix of **interest-rate** order, `redeemPrefix` vectors on rate-ascending troves. AGENTS.md treats those documents as evidence, not as the current P23 instruction. They are preserved and not closed by this V1 candidate.

These two captures are **new development source entries**, not untouched holdouts and not proof that an old development revision was restored.

## Question 1 — is V1 a legitimate candidate?

Yes, as a **candidate** for the generic P23 requirement. Source-entry selection is not acceptance.

V1 ordered redemption walks the NICR-sorted list from the tail (lowest collateral ratio), skipping `ICR < MCR` (110%), then redeems a prefix until the request is filled or cancelled. That is Liquity-style ordered eligible redemption with partial fills. It does **not** implement V2 interest-rate order (lowest annual interest first, with pending-zombie first).

No binding P23 task or `source-bound-library-families` sentence requires V2 interest order. Selecting V1 therefore does **not** silently replace a P23-required interest-order mechanism.

Concrete historical conflict, preserved rather than relabelled:

- Historical P2 liquity mechanism is BOLD interest-rate prefix at V2 lines 770/785.
- V1 `SortedTroves` is ordered by NICR, not annual interest (`SortedTroves.sol:17–18, 69–70, 271`).
- A later attempt to discharge the historical P2 `redeemPrefix` / `inv_redeemPrefix` obligation using V1 ICR order would be a contract conflict. That obligation is not P23.
- P23 implementation against V1 must name ICR/MCR order as the pinned order and must not claim interest-rate prefix.

V2 remains the captured mismatch: its named no-fill require is commented out. Do not discard that record.

## Question 2 — empty / no-fill guards

### V2 BOLD `c8a5a4ee2e9dc024905856b6698a77d849c68c7e`

Public entry is `CollateralRegistry.redeemCollateral` (`CollateralRegistry.sol:92`). Earlier checks: max fee in `[0.5%, 100%]`, amount `> 0`, then fee `redemptionRate <= _maxFeePercentage` computed from the **requested** amount (`144–147`). Branch redeemability is `TCR >= SCR && shutdownTime == 0` (`TroveManager.sol:1217–1227`).

`TroveManager.redeemCollateral` is registry-only (`754`). Traversal: pending zombie if `lastZombieTroveId != 0`, else `sortedTroves.getLast()`, then `getPrev`; skip `ICR < 100%` (`765–794`). `_maxIterations == 0` becomes `type(uint256).max` (`778`). Lot is `min(remaining, entireDebt)` (`682`). Collateral uses floor division; fee is skimmed from collateral and left in the trove (`685–689`).

The named no-fill require is explicitly removed:

```
826:        // We are removing this condition to prevent blocking redemptions
827:        //require(totals.totalCollDrawn > 0, "TroveManager: Unable to redeem any amount");
```

The live code then emits, updates the active pool, sends `collDecrease` (which may be 0), and **returns `debtDecrease`** (`838–844`). Registry burns only `if (totals.redeemedAmount > 0)` (`171–174`). There is no named empty-set require on the public path.

Source-level consequence: a call that passes amount/fee checks and then matches no redeemable trove/branch can complete with `redeemedAmount == 0` and no burn. That is a **zero-fill success path in source text**, the opposite of the required empty-set refusal. Independent reverts (price feed, 0.8 underflow if `collLot > entireColl`, division by zero if `_totalBoldSupply == 0` at `221`) must not be relabelled as that missing guard.

V2 cannot satisfy 24.1/24.3 empty-set refusal without inventing a guard. The root readiness mismatch is confirmed.

### V1 `3e64ee1b52c50d51587c64c1cf75e0ba82934979`

Public entry is `TroveManager.redeemCollateral` (`925`). After traversal:

```
999:        require(totals.totalETHDrawn > 0, "TroveManager: Unable to redeem any amount");
```

That predicate is live. It refuses **zero collateral drawn**, which includes empty iteration but is broader than “empty eligible set”.

Earlier guards, in order, before the loop:

1. `_requireValidMaxFeePercentage`: fee in `[REDEMPTION_FEE_FLOOR, 1e18]` (`1505–1507`).
2. `_requireAfterBootstrapPeriod`: `block.timestamp >= lqtyToken.getDeploymentStartTime() + 14 days` (`51, 1500–1502`). LQTY token is not in the selected files.
3. `priceFeed.fetchPrice()` (`950`). PriceFeed is not in the selected files; it can revert independently.
4. `_requireTCRoverMCR`: `_getTCR(price) >= MCR` (110%) (`1496–1497`). Zero debt yields TCR `2**256-1` (`LiquityMath.sol:102–110`).
5. `_requireAmountGreaterThanZero` (`1492–1493`).
6. `_requireLUSDBalanceCoversRedemption`: user LUSD `>=` amount (`1484–1485`).
7. `assert(balance <= entire system debt)` (`957`). Solidity 0.6 `assert` is an invalid-opcode failure, not the named require.

Hint and list:

- Valid first hint, else `getLast()` then skip `ICR < MCR` (`962–969`, `_isValidFirstRedemptionHint` `892–901`).
- Loop: `_maxIterations == 0` becomes `uint(-1)` (`973`), **not** zero iterations.
- Apply pending rewards before the lot (`979`).
- Full close when `newDebt == LUSD_GAS_COMPENSATION` (`837–841`).
- Partial cancel if NICR hint stale or `_getNetDebt(newDebt) < MIN_NET_DEBT` (`1800e18`) (`853–855`); outer loop `break` without adding that lot (`991`).
- Last-trove restriction: `_closeTrove` requires `TroveOwners.length > 1 && sortedTroves.getSize() > 1` (`1248, 1488–1489`). Full redemption of the last remaining trove reverts **here**, not at line 999.

Fee check `_requireUserAcceptsFee` is **after** line 999 (`1008`), so it cannot block the no-coll-drawn require.

### Distinguishing cases (source, not execution)

| Case | V1 source behaviour | Is the required empty-set refusal? |
|---|---|---|
| Empty sorted list | Loop does not run; line 999 fires **if** earlier guards pass | Only if that state is reachable at line 999 |
| All remaining `ICR < MCR` | Hint walk consumes them; loop does not start; line 999 would fire **if** TCR still `>= MCR` | Not shown. Debt-weighted ICR average vs TCR makes this in tension with `_requireTCRoverMCR`; rounding/extra pool balances are unverified |
| Cancelled first partial (stale NICR or resulting net debt `< MIN_NET_DEBT`) with no prior fill | `break` at 991; `totalETHDrawn == 0`; line 999 fires | **No.** Eligible trove exists |
| `ETHLot == 0` by floor(`LUSDLot * 1e18 / price`) on every added lot | Line 999 fires even if `LUSDLot > 0` | **No.** Rounding-zero collateral |
| Prior partial fills then leftover request | `totalETHDrawn > 0`; require passes; leftover LUSD remains | Success with remainder, not refusal |
| Last-trove full close | `_closeTrove` reverts “Only one trove in the system” | **No.** Last-trove restriction |
| `maxIterations` small enough that no lot is added | If caller passes `0`, it becomes unlimited. A **positive** tiny cap can exit with `totalETHDrawn == 0` | **No.** Iteration cap, not empty set |
| Bootstrap / TCR / amount / balance / assert / price-feed revert | Never reaches 999 | Other failure class |

`_closeTrove` is the only close path in the selected files and always requires more than one trove. That is a **source constraint against emptying the list through close**, not a proof that an empty eligible set cannot exist (initialization, leftover pool balances, reward-rounding TCR/ICR disagreement, or missing contracts are unproven).

**Empty-set refusal is not established.** This audit does not claim it unreachable.

### What would establish the empty-set case

A pinned compiler/EVM execution (solc 0.6.11, optimizer 100, evmVersion istanbul from `hardhat.config.js` solidity block; not from running that config) of public `redeemCollateral` that:

1. Passes max-fee, bootstrap, `fetchPrice`, TCR `>= MCR`, amount `> 0`, user balance, and the entire-debt assert.
2. Has **no** trove with current ICR `>= MCR` under the pinned NICR-tail order (empty eligible set), documented with list contents, ICRs, TCR, pool coll/debt, and pending rewards.
3. Reverts at `totals.totalETHDrawn > 0` / `"TroveManager: Unable to redeem any amount"`.
4. Is recorded separately from cancelled-first-partial, rounding-zero `ETHLot`, last-trove close, iteration-cap, bootstrap, TCR, amount, and balance failures.

If that construction cannot be produced, the next author must report the **actual** revert and state. They must not substitute another failure for empty-set, and they must not close 24.1.

Assumptions that would still be required even after a green execution: PriceFeed authenticity, LQTY deployment timestamp, bytecode identity of omitted imports, and that the fixture is not an impossible world relative to BorrowerOperations invariants. Those stay assumptions, not proofs.

## Question 3 — traversal and payment/debt boundary

Smallest honest V1 source boundary for the **full** P23 task is public `TroveManager.redeemCollateral` plus the selected helpers it actually uses:

- Order: validated first hint or `getLast`/`getPrev`, skip `ICR < MCR`.
- Pending rewards applied onto trove coll/debt and moved DefaultPool → ActivePool before the lot.
- Lot: `min(remaining, debt - LUSD_GAS_COMPENSATION)`; `ETHLot = LUSDLot * 1e18 / price` (SafeMath floor).
- Full close: extra burn of `LUSD_GAS_COMPENSATION` from `gasPoolAddress` and matching `activePool.decreaseLUSDDebt`; surplus ETH to CollSurplusPool (`882–889`).
- Partial cancel: stale NICR or net debt `< MIN_NET_DEBT`; earlier fills kept.
- After the no-coll-drawn require: base-rate update, ETH fee, fee transfer to LQTY staking, burn `totalLUSDToRedeem` from `msg.sender`, `decreaseLUSDDebt` by the same amount, send net ETH (`1014–1022`).

Redeemer LUSD burn **does not** equal system debt reduction when any trove is fully closed: the gas-reserve burn is extra. A payment/debt proof must include that reserve or explicitly restrict the domain to partial-only fills and name full-close as out of domain. Naive `burn == debtDecrease` is false on full close.

Required observations (none executed here):

1. Ordinary success: prefix of lowest-ICR eligible troves, `>= 2` eligible, at least one full close or a declared partial-only domain.
2. Partial-fill success: last touched trove remains open with net debt `>= MIN_NET_DEBT` and matching NICR hint.
3. Empty-set refusal as specified above, or an explicit blocked construction with the actual revert.
4. Skip-first-eligible mutant: skip the lowest-ICR eligible trove; designated observation changes; an unaffected sibling stays true.
5. Source-independent payment-without-debt-reduction negative: token burn / collateral send without the corresponding debt reduction, **after** accounting for gas reserve so the reserve is not mistaken for the negative.

Flags (source, not comments-as-proof):

- `uint(-1)` / `_maxIterations == 0` is unlimited, not zero iterations (`973`).
- Solidity 0.6.11 + SafeMath add/sub/mul/div; division floors toward zero; ETHLot can be 0 while LUSDLot `> 0`.
- `assert` at 957 is not the named guard.
- Selected files are not a compile closure: V1 is missing 31 static imports (Interfaces, Ownable, CheckContract, console.sol including `LiquityMath.sol:6`, PriceFeed, CollSurplusPool, LQTY token/staking). V2 is missing 29, including `Dependencies/LiquityBase.sol`.

Do not implement V2 zombie/batch/interest-weighted debt inside a V1-bounded library.

## Question 4 — disposition

**Source candidate usable with obligations.** V1 is a legitimate P23 candidate with a live no-collateral-drawn require. V2 is not usable for the empty-set observation. 24.1 is not complete: observations are not frozen by execution, and empty-set reachability is open.

Not “missing exact source requirement”: a pin with a live no-fill require exists. Not “source-entry repair required” for honesty of the readiness records: both readiness files already leave 24.1 open and deny execution/reachability claims. Repair **is** required before any author dispatch that would compile or prove: complete import/compiler closure, observation schema with the case table above, and an empty-set witness or a root-adjudicated contract change. Inventing a V2 require, or treating cancelled-partial as empty-set, would be a repair-blocking defect.

This audit cannot close 24.1, 24.2, 24.3, P23, P10, or R12.

### Smallest next AGY task that can satisfy the full binding scope

One bounded author task, after root adjudication of this diagnostic:

1. Preserve V2 mismatch bytes and historical P2 interest-order evidence. Do not implement against V2 for empty-set.
2. Capture a **complete** V1 compile/import closure for `redeemCollateral` at pin `3e64ee1b52c50d51587c64c1cf75e0ba82934979` (interfaces, Ownable, CheckContract, console.sol, PriceFeed, CollSurplusPool, LQTY token/staking, gas pool, BorrowerOperations as needed for a legal pre-state). Compiler identity: solc **0.6.11**, optimizer enabled, **100** runs, **istanbul**, from inspection of `hardhat.config.js` — do not execute that config.
3. Freeze an observation schema that separately names: ordinary prefix success; partial-fill success; empty eligible set; cancelled-first-partial; rounding-zero collateral; last-trove close refusal; iteration-cap no-fill; bootstrap/TCR/amount/balance/assert/price-feed.
4. Execute those cases under the pinned compiler/EVM. Empty-set must be the specified witness or an explicit failed construction with the actual revert. Do not substitute.
5. Only after a real empty-set observation exists (or root accepts a written contract change) implement `lean/DefiKernel/Redemption/` with payment/debt including gas reserve, skip-first-eligible mutant, and payment-without-debt-reduction negative.
6. Fresh independent Grok review of that candidate. Do not close R12/P10.

If step 4 cannot produce empty-set, stop and return to root. Do not start 24.2 by widening the refusal class in silence.

## Unverified runtime / reachability items

Source inspection is not execution. Unverified:

- Any actual transaction, revert data, or gas behaviour.
- Reachability of line 999 with an empty eligible set.
- Whether all-`ICR < MCR` can coexist with TCR `>= MCR` under pending-reward rounding.
- Whether leftover ActivePool/DefaultPool balances can exist without sorted-list members.
- PriceFeed, LQTY `getDeploymentStartTime`, CollSurplusPool, LQTY staking, StabilityPool, BorrowerOperations, gas pool.
- Compiler output, optimizer effects, Istanbul vs later EVM, SafeMath vs 0.8 checked math on a live run.
- V2 zero-fill success on a reachable empty branch set (source **allows** it; not executed).
- Sorted-list invariants, hint validation against live NICR after rewards, last-trove interaction with liquidation (liquidation is out of P23 scope; `_closeTrove` is shared).
- Deployment, bytecode, or historical-pin restoration.
- Lean model, mutants, or proofs.

## Identities

| Item | Value |
|---|---|
| Requested model | `grok-4.6` (`dispatch.json`) |
| Effort | high |
| Fresh session | true |
| Reported runtime model in `native.jsonl` | unavailable (usage rows have tokens/signatures, no model name) |
| V2 commit | `c8a5a4ee2e9dc024905856b6698a77d849c68c7e` |
| V1 commit | `3e64ee1b52c50d51587c64c1cf75e0ba82934979` |
| `inputs.json` SHA-256 | `63e0c4a95557f1871659676543d60be34d02a64568662db1bca7cffd03b82151` |
| Hash verify | 41/41 match, exit 0 |
| Compiler/EVM execution | none |
| Acceptance | false |
