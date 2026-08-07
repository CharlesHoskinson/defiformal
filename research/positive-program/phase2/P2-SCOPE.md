# P2-SCOPE — per-protocol scope and execution plan for the ten re-specs

Paths: specs `SP = /root/DefiElements/quint-models/`, contracts
`CP = /root/DefiElements/protocol-repos/`.

## 1. The ten rows

| # | protocol | spec | contract | mechanism that MUST survive | may be dropped | the deletion (file:line) | diff |
|---|---|---|---|---|---|---|---|
| 1 | `uniswap_v2` | `SP L1/uniswap_v2.qnt` | `CP dex/Uniswap_v2-core/contracts/UniswapV2Pair.sol:120,95-99` | integer `√` — first-mint `sqrt(a0·a1) − MIN_LIQ`, and `_mintFee` comparing `√k` to `√kLast` | ERC20 plumbing, flash-swap callback, TWAP cumulatives, `skim`/`sync` | `SP L1/common.qnt:76-92` `geometricMint` → `if (a0==a1) a0 else min(a0,a1)`; `uniswap_v2.qnt:28,48` write `kLast` and **nothing ever reads it** | M |
| 2 | `curve` | `SP L1/curve.qnt` | `CP dex/curvefi_curve-contract/.../3pool/StableSwap3Pool.vy:195-217` | Newton iteration on `D = (Ann·S + D_P·n)·D / ((Ann−1)·D + (n+1)·D_P)` to fixpoint ±1 | 3→2 coin reduction, admin-fee split, ramping `A`, `get_y` if `D` is exact | `curve.qnt:22-30` `approxD` — "weighted blend"; `:27` `2*min(x,y)` self-labelled *"stand-in for geometric contribution"* | H |
| 3 | `compound_v3` | `SP L1/compound_v3.qnt` | `CP lend/compound-finance_comet/contracts/CometWithExtendedAssetList.sol:1068-1084,1149-1161` | **absorb seizes collateral into protocol inventory at a `liquidationFactor` haircut, and it leaves only via `buyCollateral` at a store-front discount** | multi-asset bitmask (one collateral is fine), governance, rewards, `numAssets` loop | `compound_v3.qnt:164` credits reserves the **full** `col*collPrice` (no `mulFactor(value, liquidationFactor)`); `:162` collateral teleports to `"absorber"` — no protocol inventory, no `buyCollateral` action exists | M |
| 4 | `morpho_blue` | `SP L1/morpho_blue.qnt` | `CP lend/morpho-org_morpho-blue/src/Morpho.sol:366-370,391-401` | **bad-debt socialisation: collateral hits 0 ⇒ `totalSupplyAssets -= badDebtAssets`** (supplier loss), with `liquidationIncentiveFactor = min(MAX, 1/(1−cursor·(1−lltv)))` | callbacks, flash loans, authorisation, IRM, multi-market | `morpho_blue.qnt:156-159` — comment *"bad debt: if collateral wiped but debt remains, socialize"* followed by `supplyShares' = supplyShares, totalSupplyAssets' = totalSupplyAssets`. Pure no-op. `:12` `LIQ_INCENTIVE_BPS = 11500 // derived from LLTV in code; fixed here` | M |
| 5 | `liquity` | `SP L2/liquity.qnt` | `CP cdp/liquity_bold/contracts/src/TroveManager.sol:770,785` | extremal selection: `getLast()` then walk `getPrev()`, consuming a **prefix** of the interest-rate order, cut off endogenously by `remainingBold` | zombie-trove path, batch interest, `_maxIterations`, surplus pool | `liquity.qnt:130` `action redeem(u: int, boldAmt: int)` — the trove is a *parameter* fed by `nondet u = USERS.oneOf()` | H |
| 6 | `apex` | `SP L3/apex.qnt` | `CP perp/ApeX-Protocol_apex-protocol/contracts/core/Amm.sol:96,467-478` + `Margin.sol:253-299,608-636` | **positions are priced and closed against the reserves**: `_getAmountOut` with 999/1000 fee, and `liquidate` valuing via `getMarkPriceAcc(amm,beta,qty,·)` then writing back through `forceSwap` | oracle `beta` skew detail, router/config layer, CPF precision | `apex.qnt:47-49` `swapOut` has **no fee**; `:138-153` liquidate leaves `reserveBase/reserveQuote/marginPool` all unchanged (`:145 // simplified: collateral absorbed, not redistributed`); `:183-185` LP mint is linear, no `sqrt` bootstrap | M |
| 7 | `gmx` | `SP L3/gmx.qnt` | `CP perp/gmx-io_gmx-synthetics/contracts/pricing/PricingUtils.sol:61-111` + `market/MarketUtils.sol:1854-1876` | **OI-imbalance price impact**: `f(initialDiffUsd) − f(nextDiffUsd)` under `applyImpactFactor`, signed by whether balance improved, settled through the impact pool | exponent ≠ 1 (linear impact is acceptable), multi-market, swap impact, virtual inventory | `gmx.qnt:20` declares `var impactPool`, written **only** at `:140` (residual liquidation collateral) — the impact function is absent entirely; `:64,:88` replace `validateReserve`'s `reservedUsd ≤ poolUsd·reserveFactor` with `poolAmount * markPrice >= longOI + sizeUsd` | M |
| 8 | `huma` | `SP L3/huma.qnt` | `CP yield/00labs_huma-contracts-v2/contracts/liquidity/EpochManager.sol:342-360` | **subordination binds the exit, not just the entry**: `minJuniorAmount = ceilDiv(senior, maxSeniorJuniorRatio)`, junior redeemable `= junior − minJuniorAmount`, senior processed first | per-lender request queue across epochs, yield reinvest, credit line | `huma.qnt:200-202` — `fillJ = min(juniorAssetsReq, rem)`, cash-bounded only, **no ratio cap**. `:257-258` the spec then downgrades its own invariant to `val solvent: bool = trancheNonNeg` with the comment *"may break after losses — finding"* | M |
| 9 | `derive` | `SP L5/derive.qnt` | `CP opt/derivexyz_v2-core/src/risk-managers/PMRMLib.sol:92-128` | **argmin over a shock-scenario set**: `minSPAN = min_i scenarioMtM(portfolio, scenarios[i])`, `worstScenario` = the index | scenario *content* (a 3-5 point spot/vol grid suffices), contingencies, dutch-auction path, subaccount NFTs | `derive.qnt:22` `MAINT_PER_SHORT: int = 15  // abstract maintenance per short unit`, applied at `:86` as `qty * MAINT_PER_SHORT`. Header `:12` admits it: *"NOT covered: full PMRM scenario matrix"* | M |
| 10 | `polymarket` | `SP L6/polymarket.qnt` | `CP pred/Polymarket_ctf-exchange-v2/src/exchange/mixins/Trading.sol:390-430,577-598` | **taker crossed against an ordered maker list, match type derived from side agreement** — same-side crossings settle by batched CTF `MINT` / `MERGE`, opposite-side by `COMPLEMENTARY` transfer | EIP-712 signing, fee accounting, operator roles, UMA dispute window | `polymarket.qnt:75-97` `tradeYes(seller,buyer,yesAmt,price)` — one peer, and the **price is exogenous**: `:143 nondet price = 1.to(3).oneOf()`. `split`/`merge` exist only as standalone user actions, never as the settlement of a match | H |

## 2. The seven-deletion hunt, in detail

The three known ones (rows 1, 2, 5) are given. The other seven, each traced from
`GENERATION.md`'s stated failure to the concrete line:

**`compound_v3` — "N2 mark-to-market", `col * collPrice` at `:164`.** The raw `*`
is a symptom. Comet's `absorbInternal` (`:1076-1077`) computes
`value = mulPrice(seizeAmount, price, scale)` then credits only
`mulFactor(value, assetInfo.liquidationFactor)`. The haircut is the protocol's
liquidation margin. The spec credits reserves the *undiscounted* value, and then
hands the collateral straight to an `"absorber"` account (`:162`), collapsing
Comet's two-phase absorb→`buyCollateral` (`quoteCollateral`, `:1149-1161`,
`discount = storeFrontPriceFactor · (1 − liquidationFactor)`) into one step. The
protocol never holds inventory, so no discount can exist.

**`morpho_blue` — "N2", `seizedCol * collPrice` at `:143`.** The real deletion is
larger and sits four lines lower. `Morpho.sol:391-401` writes down
`totalSupplyAssets` when a borrower's collateral is fully seized: it is the only
path by which supplier assets fall. `morpho_blue.qnt:156-159` names it in a
comment and implements nothing. Consequence: the spec's own headline invariant
`shareConservation`/`liquidityInvariant` (`:209-213`) is preserved *because the
mechanism that stresses it was removed*. Second, `LIQ_INCENTIVE_BPS` (`:12`) is a
literal where the contract derives it nonlinearly from `lltv` (`:366-370`).

**`apex` — "N1 trading function", `y * dx` and `baseIn * reserveQuote`.** Three
concrete losses. (a) `swapOut` (`:47-49`) is fee-free; `Amm._getAmountOut`
(`:467-478`) charges 999/1000, which is what makes `k` strictly increase.
(b) `Amm.mint` bootstraps with `Math.sqrt(baseAmount * quoteAmount) −
MINIMUM_LIQUIDITY` (`:96`) — the same `√` as row 1; the spec linearises (`:183-185`).
(c) `Margin.liquidate` values the position by *simulating its close against the
pool* (`_calDebtRatio` → `getMarkPriceAcc`, `Margin.sol:608-636`) and then
actually pushes it through `forceSwap`; `apex.qnt:138-153` uses an exogenous
`markPrice` and leaves every reserve untouched. Liquidation in the spec has no
market impact at all.

**`gmx` — "N2", `poolAmount * markPrice`.** `var impactPool` is declared
(`gmx.qnt:20`), initialised to 0, and written at exactly one site (`:140`) with
residual liquidation collateral. It is **dead state**: nothing in the spec
computes an impact. The contract's `getPriceImpactUsdForSameSideRebalance` /
`...CrossoverRebalance` (`PricingUtils.sol:61-98`) is the mechanism — impact is a
function of how much a trade widens or narrows `|longOI − shortOI|`, and the sign
flips on `balanceWasImproved`. Separately, `:64`/`:88` substitute a raw product
for `validateReserve`'s `reservedUsd ≤ applyFactor(poolUsd, reserveFactor)`.

**`huma` — "N4 tranche subordination", `MAX_SENIOR_RATIO * max(1, junior)`.**
The spec enforces the senior:junior cap on *deposit* (`:49`) and nowhere else.
`EpochManager._processJuniorRedemptionRequests` (`:342-360`) enforces it on
*redemption*: `minJuniorAmount = ceilDiv(tranchesAssets[SENIOR], maxRatio)` and
`maxRedeemableAmount = junior − minJuniorAmount`, returning early when the cap
binds. `huma.qnt:200-202` computes `fillJ = min(juniorAssetsReq, rem)` — cash is
the only constraint. The spec then admits the loss at `:257-258`, replacing the
ratio invariant with `trancheNonNeg`. Restoring the cap makes
`senior ≤ 4·junior` an assertable invariant again.

**`derive` — "N2, per-unit margin", `qty * MAINT_PER_SHORT`.** The contract's
margin is an **argmin**: `PMRMLib.getMarginAndMarkToMarket:99-111` initialises
`minSPAN` and loops the scenario array keeping the minimum and its index
(`worstScenario`). `derive.qnt:22` replaces the whole search with the constant
`15`. This is the corpus's clearest instance of the missing pattern — the residue
note that *no* `fold` in 57 specs is an extremal selection is exactly this
deletion. It is also the cheapest to restore: `SCENARIOS` is a small `Set`, and
`fold(+∞, (acc,s) => min(acc, mtm(port,s)))` is four lines.

**`polymarket` — "N2 ×3", `yesAmt * price`.** The price is not a valuation input;
it is the *outcome of a crossing*. `Trading._settleMakerOrders:390-430` walks the
maker array in order, derives a `MatchType` per maker from side agreement
(`_deriveMatchType:577-590` — taker and maker on the **same** side means the
trade must be settled by minting or merging a complementary pair, not by
transfer), accumulates `totalMintAmount`/`totalMergeAmount`, and then executes
one batched `_mint`/`_merge`. `polymarket.qnt:75-97` is a single bilateral
transfer at a price drawn by the driver (`:143`). Split and merge exist in the
spec (`:40-67`) but are user actions, never the settlement of a trade — the
identity that connects the order book to the CTF is severed.

## 3. Execution split

**Four workers, one pilot, no shared-file writes.**

Output tree is new: `quint-models-v2/<Ln>/<protocol>.qnt`, mirroring v1. Each
lane's `common.qnt` is **copied verbatim and frozen** — no worker edits any
`common.qnt`, which removes every write conflict and keeps v1 intact as the
baseline. New shared machinery goes in one file, `quint-models-v2/kernel/kernel.qnt`,
authored during the pilot and frozen before lanes start; it holds exactly three
things: `isqrtFloor`, `newtonD`, and sorted-list ops (`insertSorted`, `popHead`,
`takePrefixWhile`). Anything else is declared module-locally with a
`// LOCAL PRIMITIVE:` marker for later promotion.

- **Pilot (blocking):** `uniswap_v2`.
- **W1 — iterative arithmetic:** `curve`, `apex`.
- **W2 — valuation and haircut:** `compound_v3`, `morpho_blue`, `gmx`.
- **W3 — ordered structures:** `liquity`, `polymarket`.
- **W4 — extremal and waterfall:** `derive`, `huma`.

Grouping is by *technique*, not by lane, so each worker solves one hard problem
once and applies it twice or three times. W3 is the heaviest (both members need a
sorted/ordered list plus prefix consumption) and gets the fewest protocols.

**Shared conventions — binding on all four:**

1. **Module name unchanged** from v1 (`module uniswap_v2 { … }`), so
   `quint parse --out` and the generation checker run unmodified over v2.
2. **Header block, six mandatory lines**, in this order: `SOURCE:` (repo path +
   line range), `MECHANISM:` (the must-survive, one sentence), `PRESERVED:`,
   `ABSTRACTED:` (an explicit list — anything simplified and *not* listed here is
   a defect), `BOUNDS:` (state-space sizes), `ACCEPTANCE:` (the three commands).
3. **The mechanism is a named `pure def`**, never inlined into an action, and its
   name comes from a fixed registry: `isqrtFloor`, `newtonD`, `absorbHaircut`,
   `socializeBadDebt`, `redeemPrefix`, `ammQuoteClose`, `impactUsd`,
   `juniorRedeemableCap`, `worstScenarioMargin`, `matchTakerAgainstMakers`.
   Naming it is what makes the acceptance check mechanical.
4. **Init:** exactly one `action init`, every `var` assigned, every value a named
   `pure val` constant declared at the top in `UPPER_SNAKE`. No literal
   arithmetic inside `init` (this is what produced `kLast' = 100 * 100`).
5. **Ordered state is `List`**, maintained by kernel ops. Never a `Set` the driver
   selects from.
6. **Driver rule (the one that would have caught liquity):** `action step` may
   `nondet` only over *exogenous* inputs — prices, amounts, time, user identity
   for deposits. **Never over the identity of an element the protocol itself
   selects.** If the contract computes *which*, the spec computes *which*.
7. **Invariants:** at least three, named `inv_*` — `inv_conservation` (a sum that
   is constant or monotone), `inv_<mechanism>` (false if the mechanism is
   bypassed), `inv_bounds` (non-negativity) — plus one witness `wit_*` (§5).
8. **Bounds:** ≤3 users, ≤5 list entries, integer ranges ≤200, so
   `quint run --max-steps=20 --max-samples=500` finishes under 60s. Measured
   baseline: v1 `uniswap_v2` did 100×10 in 0.6s, so there is roughly two orders
   of magnitude of headroom.
9. **Prohibited:** any `var` never read; any doc comment containing "abstract",
   "simplified", "stand-in" or "approx" without a matching `ABSTRACTED:` entry.

## 4. Ordering — pilot is `uniswap_v2`

(a) Its missing mechanism, integer `√`, is the one **two other protocols also
need** — `curve`'s Newton seed and `apex`'s LP bootstrap — so `kernel.isqrtFloor`
gets three consumers before anyone else writes a line. (b) Its state is the
smallest of the ten, so convention review is about conventions, not about the
protocol. (c) Its deletion sits in `common.qnt`, i.e. in the *shared* layer —
fixing it first exercises the "no worker edits common, everything new goes in
kernel" rule rather than assuming it. (d) It has a second, undiagnosed deletion
(`kLast` dead, `_mintFee` absent), making it a real test of convention 9 rather
than a rubber stamp. The pilot is not done until a reviewer has signed off on the
header block, the kernel API, and the three acceptance commands; only then do
W1-W4 start.

## 5. Acceptance test, per protocol

Three parts for every one of the ten. **T1** `quint typecheck <file>` exits 0.
**T2** `quint run --main=<mod> --invariant=inv_conservation --max-steps=20
--max-samples=500` reports no violation in under 60s. **T3** the positive check,
in two halves: a **witness** — a `val wit_X: bool` asserting the mechanism has
*never fired*, which `quint run --invariant=wit_X` must **violate**, producing a
trace that exercises it; and a **mutation** — restore the v1 shortcut body and
confirm `inv_<mechanism>` now fails. T3 per protocol:

1. `uniswap_v2` — `inv_sqrtExact`: for every reached `p`, `isqrtFloor(p)^2 ≤ p <
   (isqrtFloor(p)+1)^2`. `wit_firstMint`: no state has `totalSupply ==
   isqrtFloor(r0*r1) − MIN_LIQ` — must be violated. `kLast` is read by `mintFee`.
2. `curve` — `inv_newtonResidual`: at the returned `D`, `|(Ann·S + D_P·n)·D −
   ((Ann−1)·D + (n+1)·D_P)·D| ≤ 1`. `wit_imbalanced`: no state has
   `max(bal0,bal1) ≥ 2·min(bal0,bal1)` with `2·isqrtFloor(bal0·bal1) < D < S`.
3. `compound_v3` — `wit_haircut`: no absorb has credited reserves strictly less
   than `col*collPrice/basePrice`. `inv_storeFront`: protocol-held collateral is
   reachable and leaves only via `buyCollateral` at the discounted quote.
4. `morpho_blue` — `wit_badDebt`: no state follows a liquidation that left
   `collateral==0, borrowShares>0` and strictly decreased `totalSupplyAssets`.
   `inv_incentiveDerived`: `LIQ_INCENTIVE == min(MAX_LIF, WAD²/(WAD −
   CURSOR·(WAD−LLTV)/WAD))` evaluated, not a literal.
5. `liquity` — `inv_redeemPrefix`: every redemption touched a prefix of
   `sortedByRate`; no untouched trove ranks below a touched one. `wit_multiTrove`:
   no redemption consumed ≥2 troves — must be violated.
6. `apex` — `inv_kMonotone`: `reserveBase·reserveQuote` non-decreasing across
   every swap (the 999/1000 fee). `wit_ammClose`: no liquidation changed the
   reserves — must be violated.
7. `gmx` — `wit_impact`: no `increase`/`decrease` changed `impactPool`. 
   `inv_impactSign`: every impact debit is negative iff `|longOI − shortOI|` grew,
   and `impactPool ≥ 0`.
8. `huma` — `inv_seniorRatio`: `junior > 0 implies senior ≤ MAX_RATIO·junior`, at
   every state (the invariant v1 abandoned). `wit_juniorCapped`: no epoch had
   `availableCash > juniorAssetsReq` yet `fillJ < juniorAssetsReq`.
9. `derive` — `inv_marginIsMin`: `SCENARIOS.forall(s => scenarioMtM(p,s) ≥
   margin)` and `SCENARIOS.exists(s => scenarioMtM(p,s) == margin)`.
   `wit_nonTrivialArgmin`: `worstScenario` is always index 0 — must be violated.
10. `polymarket` — `inv_matchConserves`: within one match, `lockedCollateral`
    changes only by the batched mint/merge total, and taker remaining is monotone
    to 0 across the maker prefix. `wit_mintMatch`: no trade settled by MINT (two
    same-side buys crossed) — must be violated.
