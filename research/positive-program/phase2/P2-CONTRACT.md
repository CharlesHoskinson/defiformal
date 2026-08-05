# P2 — REPAIRED EXECUTION CONTRACT (repairs 2, 3, 5)

Repairs 1 and 4 are applied in `P2-FIDELITY.md`. This document supplies the other three and
is binding on the pilot and W1–W4. Where it conflicts with `P2-SCOPE.md`, this wins.

**How the numbers were produced.** Every vector was computed by replaying the cited
Solidity/Vyper line in Python integer arithmetic — uint `/` = floor, `mulDivUp`/`ceilDiv` =
ceiling — at the descaled constants named in each row (`scratchpad/p2vec.py`, `p2vec2.py`).
`Math.sqrt` (`Math.sol:11-20`) was replayed as exact floor-sqrt. Nothing needs chain state
except where flagged **NOT DERIVABLE**.

---

## A. REPAIR 2 — T0 conformance vectors

Assert each as a `pure val t0_<n>: bool = <lhs> == <rhs>`, conjoined into `inv_T0`. T0 is
part of every protocol's acceptance test, ahead of T1.

### 1. `uniswap_v2` — `isqrtFloor`, `geometricMint`, `mintFee` (`UniswapV2Pair.sol:120, 95-99`)
| input | output |
|---|---|
| `isqrtFloor(36000000)` | `6000` |
| `isqrtFloor(15)` , `isqrtFloor(8)` | `3` , `2` |
| `geometricMint(4000, 9000)` | `5000` (v1 `min` → 4000; mean → 5500) |
| `geometricMint(2000, 8000)` | `3000` (v1 → 2000) |
| `mintFeeLiquidity(kLast=1000000, r0=1200, r1=1200, ts=1000)` | `28` (= `1000·200/(6000+1000)`) |
| `mintFeeLiquidity(kLast=1000000, r0=2000, r1=2000, ts=1000)` | `90` |
| `mintFeeLiquidity(kLast=1000000, r0=1000, r1=1000, ts=1000)` | `0` |

### 2. `curve` — `newtonD`, N=2, AMP=100, K=8 (`StableSwap3Pool.vy:195-217`)
| `(x, y)` | `D` | iters | `S` | `2·isqrt(xy)` | v1 blend |
|---|---|---|---|---|---|
| `(100,100)` | `200` | 1 | 200 | 200 | 200 |
| `(150,50)` | `199` | 1 | 200 | 172 | 199 |
| `(180,20)` | `198` | 2 | 200 | 120 | 199 |
| `(190,10)` | `196` | 2 | 200 | 86 | 199 |
| `(199,1)` | `170` | 2 | 200 | 28 | 199 |

`(190,10)` and `(199,1)` separate `M₀` from constant-sum, constant-product **and** the v1
blend simultaneously. `(100,100)` and `(150,50)` do not — do not use them alone.

### 3. `compound_v3` — `absorbHaircut`, `quoteCollateral` (`:1076-1077`, `:1154-1160`)
Descaled `SCALE = 10⁴`; `liquidationFactor = 9000`, `storeFrontPriceFactor = 5000`,
`assetPrice = 50000`, `basePrice = 10000`, all scales `10⁴`.
| input | output |
|---|---|
| `absorbValue(seize=1000)` | `5000` |
| `absorbHaircut(5000, 9000)` | `4500` — **v1 credits 5000** |
| `absorbHaircut(1500, 9000)` (seize=300) | `1350` |
| `discountFactor` , `assetPriceDiscounted` | `500` , `47500` |
| `quoteCollateral(4500)` | `947` |
| `quoteCollateral(950)` | `200` |

Load-bearing identity: absorbing 1000 units credits 4500 base, and 4500 base buys back only
**947**. The 53-unit residue is the store-front margin, `0` under the v1 shortcut and under
any "haircut of one unit".

### 4. `morpho_blue` — `liquidationIncentiveFactor`, `socializeBadDebt` (`:366-370`, `:391-401`)
`SCALE = 10⁴`, `CURSOR = 3000`, `MAX_LIF = 11500`, `VIRTUAL_SHARES = 10⁶`, `VIRTUAL_ASSETS = 1`.
| input | output |
|---|---|
| `LIF(lltv=8600)` | `10438` (inner `9580`) — **v1 literal is 11500** |
| `LIF(lltv=9000)` | `10309` |
| `LIF(lltv=7700)` | `10741` |
| `LIF(lltv=5000)` | `11500` (cap binds — the other side of `min`) |
| `badDebtAssets(shares=200·10⁶, tBA=1000, tBS=1000·10⁶)` | `200`; `totalSupplyAssets 2000 → 1800` |
| `badDebtAssets(shares=150·10⁶, tBA=500, tBS=400·10⁶)` | `188` (ceil of 187.4 — rounding up is the vector) |

### 5. `liquity` — `redeemPrefix` (`TroveManager.sol:682-689, 770, 785`)
Troves `(rate 5, debt 100), (rate 8, 100), (rate 12, 300)`; `redemptionPrice = 1`,
`redemptionRate = 0` (**NOT DERIVABLE** — `_redemptionRate` is chain state; fixed at 0 and
declared in `ABSTRACTED:`; the fee is a scalar skim and does not touch the order).
| `amount` | touched | remaining | debts, rate-ascending |
|---|---|---|---|
| `50` | 1 | 0 | `[50,100,300]` |
| `150` | **2** | 0 | `[0,50,300]` |
| `250` | **3** | 0 | `[0,0,250]` |
| `600` | 3 | **100** | `[0,0,0]` |

v1's `redeem(u, amt)` cannot produce `touched > 1` for any input.

### 6. `apex` — `_getAmountOut`, `_getAmountIn`, LP bootstrap (`Amm.sol:474-477, 490, 96`)
| input | output | zero-fee v1 |
|---|---|---|
| `ammOut(in=100, rIn=100, rOut=100)` | `49` | `50` |
| `ammOut(in=50, rIn=200, rOut=200)` | `39` | `40` |
| `ammOut(in=200, rIn=200, rOut=100)` | `49` | `50` |
| `ammIn(out=100, rIn=1000, rOut=1000)` | `112` | `111` (the `+1` round-up) |
| `apexMint(4000, 9000)` | `5000` | `4000` (linear) |

**Recorded finding.** At `(in=200, rIn=1000, rOut=1000)` both forms return `166` and
`k' = 1000800`. `inv_kMonotone` is satisfied by the deleted mechanism at ordinary trade
sizes. Only T0 separates them, and only at `amountIn ≳ reserveIn`.

### 7. `gmx` — `impactUsd` (`PricingUtils.sol:61-77, 104-111`; `Precision.sol:88-109`)
`SCALE = 10⁴`, `impactFactor = 50`, `exponentFactor = 2·SCALE`.
| input | output | exponent-1 linearisation |
|---|---|---|
| `applyImpactFactor(d=5000)` | `0` (cliff, `Precision.sol:93`) | `0` |
| `applyImpactFactor(d=10000)` | `50` | `50` |
| `applyImpactFactor(d=20000)` | `200` | `100` |
| `applyImpactFactor(d=30000)` | `450` | `150` |
| `sameSide(init=20000, next=10000)` | `+150` | `+50` |
| `sameSide(init=30000, next=20000)` | `+250` | `+50` |
| `sameSide(init=0, next=20000)` | `−200` | `−100` |

Rows 5 and 6 are the convexity witness: identical ΔOI of `10000`, impact `150` vs `250`.
Every linear impact function returns the same number twice. This is why the linearisation
permission in `P2-SCOPE.md` row 7 is **revoked**.

### 8. `huma` — `juniorRedeemableCap` (`EpochManager.sol:352-357`)
`maxSeniorJuniorRatio = 4`.
| input | `minJuniorAmount` | `maxRedeemableAmount` |
|---|---|---|
| `senior=700, junior=200` | `175` | `25` |
| `senior=750, junior=250` | `188` (ceil of 187.5) | `62` |
| `senior=800, junior=200` | `200` | `0` (early return) |

v1's `fillJ = min(req, cash)` returns `min(req, cash)` in all three.

### 9. `derive` — `worstScenarioMargin` (`PMRMLib.sol:99-111, 162-163, 212-224`)
**NOT DERIVABLE:** option-leg MtM needs `Black76.prices` plus on-chain vol/forward params.
**Substitute:** the empty-`options` path — a real contract path — where `scenarioMtM` reduces
exactly to `_getBaseValue` + `_getShockedPerpValue`. `UNIT = 100`, `spot = perpPrice = 10000`,
`stablePrice = 100`, `spotShocks = [80,90,100,110,120]`.
| portfolio | `scenarioMtM` vector | `margin` | `worstScenario` |
|---|---|---|---|
| `base=200, perp=−300` | `[2000,1000,0,−1000,−2000]` | `−2000` | `4` |
| `base=200, perp=0` | `[−4000,−2000,0,2000,4000]` | `−4000` | `0` |
| `base=0, perp=−300` | `[6000,3000,0,−3000,−6000]` | `−6000` | `4` |

Rows 1 and 2 differ in `worstScenario`. The decorated-constant cheat in the review cannot
produce both, because its `scenarioMtM` does not read the base/perp split.

### 10. `polymarket` — `matchTakerAgainstMakers` (`Trading.sol:405-428, 577-590`; `CalculatorHelper.sol:10`)
| input | output |
|---|---|
| `matchType(BUY, BUY)` | `MINT` (1) |
| `matchType(SELL, SELL)` | `MERGE` (2) |
| `matchType(BUY, SELL)` , `(SELL, BUY)` | `COMPLEMENTARY` (0) |
| `takingAmount(making=50, makerAmount=100, takerAmount=40)` | `20` |
| `takingAmount(30, 100, 40)` | `12` |
| `takingAmount(20, 100, 65)` | `13` |
| batch: makers `[(BUY,100,40,fill 50), (BUY,100,40,fill 30), (SELL,100,65,fill 20)]` | `totalMintAmount = 32`, `totalMergeAmount = 0`, exactly one `_mint(32)` |

The price is `takerAmount/makerAmount` off the order — never a driver `oneOf`.

---

## B. REPAIR 3 — extended selection conventions

Convention 6 stands unchanged. Add:

**6b — Arithmetic identity.** Every arithmetic mechanism is a registry-named `pure def` and
is pinned by its §A vectors as `pure val` equalities. At least one vector must lie outside
the symmetric/near-symmetric regime and at least one must be a value where the v1 shortcut
disagrees. A shape invariant may never be the only check on a `pure def`.

**6c — Rounding direction.** Every division in a cited formula carries the contract's
rounding direction, and at least one T0 vector per `pure def` must be an inexact quotient
where floor and ceil differ (`apex` 111→112, `huma` 187.5→188, `morpho` 187.4→188).

**6d — No-op and dead branch.** No action branch may have every primed variable equal to its
unprimed variable. Every action carries `wit_fired_<action>` ("this action never fired"),
which `quint run` must violate. Enabledness is witnessed, never assumed.

**6e — Coverage table.** A written table in the header: every external state-changing
function of every cited contract is an action or an `ABSTRACTED:` line with a reason; every
storage slot read by a `require` on a state-changing path is a `var` or an `ABSTRACTED:`
line. No `var` may be write-only.

**6f — Branch and threshold coverage.** Every conditional inside a cited formula — an early
return, a `min` cap, a magnitude cliff — is a branch of the `pure def` with one T0 vector on
each side.

### Mapping: the ten deletions to their covering convention

| # | deletion | caught by |
|---|---|---|
| 1 | `uniswap_v2` `geometricMint → min` | **6b**; dead `kLast` by **6e** |
| 2 | `curve` `approxD` blend | **6b**; the `break` by **6f** |
| 3 | `compound_v3` missing haircut / no inventory | **6b** + **6c**; absent `buyCollateral` by **6e** |
| 4 | `morpho_blue` bad-debt no-op | **6d**; `LIQ_INCENTIVE` literal by **6b** + **6f** |
| 5 | `liquity` trove as parameter | **6** (unchanged) |
| 6 | `apex` fee-free swap / linear mint / inert liquidate | **6b** + **6c**; inert liquidate by **6d**; absent close path by **6e** |
| 7 | `gmx` absent impact function | **6e** (write-only `impactPool`) + **6b** + **6f** (cliff, exponent) |
| 8 | `huma` uncapped junior redemption | **6b** + **6c** + **6f** (early return) |
| 9 | `derive` `MAINT_PER_SHORT` constant | **6** + **6b** |
| 10 | `polymarket` exogenous price, no match type | **6** + **6b**; absent dispute path by **6e** |

### Holes — named, not covered

- **H1 — `apex`'s liquidation *trigger*.** `_calDebtRatio → getMarkPriceAcc` makes
  liquidatability size-dependent; the spec's scalar `markPrice` is a *legal* exogenous input
  under convention 6, not an arithmetic site under 6b, not missing state under 6e. No
  convention covers "an endogenous argument replaced by a legitimate exogenous one". Bespoke
  obligation: `wit_sizeDependentLiquidation` — two positions of different size at the same
  `markPrice` must differ in liquidatability.
- **H2 — `apex` unit mismatch.** `openShortPos` records `posSize` in base units,
  `openLongPos` in quote (`apex.qnt:123`); `common.qnt:120` applies one formula to both. A
  type error inside `int`; no convention sees it. Obligation: a `UNITS:` header line naming
  the unit of every quantitative field.
- **H3 — reachability of the T0 regime.** Nothing forces the spec to enter a state where a
  pinned function is applied. This is the fifth trap; see §D.
- **H4 — `polymarket` contract boundary.** A 6e table built from `Trading.sol` alone does not
  reach `UmaCtfAdapter.sol`. It must name both contracts.

---

## C. REPAIR 5 — descaled domains and their witness-hosting arguments

i64 ceiling ≈ `9.22×10¹⁸`. All peak intermediates below are stated.

| # | protocol | descale | ranges | peak intermediate |
|---|---|---|---|---|
| 1 | `uniswap_v2` | none (token units) | amounts `[1000, 20000]`, reserves ≤ `40000` | `a0·a1 ≤ 4×10⁸`; use `isqrtBits(n,16)`, `cand² ≤ 4.3×10⁹` |
| 2 | `curve` | 1 unit = 1 token, `AMP = 100` | balances `[1, 200]`, `N=2`, `K=8` | `(Ann·S + D_P·N)·D ≤ 2×10⁸` |
| 3 | `compound_v3` | `SCALE = 10⁴` for both `FACTOR_SCALE` and price scale | balances ≤ 2000, prices ≤ `10·SCALE` | `basePrice·baseAmount·assetScale ≤ 4.5×10¹¹` |
| 4 | `morpho_blue` | `SCALE = 10⁴` (`SCALE² = 10⁸`); `VIRTUAL_SHARES` stays `10⁶` | assets ≤ 2000, shares ≤ `2×10⁹` | `shares·(assets+1) ≈ 4×10¹²` |
| 5 | `liquity` | 1 unit = 1 BOLD, price = 1 | ≤5 troves, debts ≤ 300, amounts ≤ 600 | `< 10⁶` |
| 6 | `apex` | none | swap: reserves `[100, 2000]`, `amountIn [1, 200]`; mint: amounts `[1000, 20000]` | `amountIn·999·reserveOut ≈ 4×10⁸` |
| 7 | `gmx` | `SCALE = 10⁴` for `FLOAT_PRECISION`; **exponent = 2** | `diffUsd ≤ 4×10⁴`, `impactFactor ≤ 10²` | `d² = 1.6×10⁹` |
| 8 | `huma` | `SCALE = 10⁴` for `DEFAULT_DECIMALS_FACTOR`; ratio `4` unscaled | senior ≤ 800, junior ≤ 300, price ≤ `2·SCALE` | `6×10⁶` |
| 9 | `derive` | `UNIT = 10²` | spot = perp = `10⁴`, base `[0,3]·UNIT`, perp `[−3,3]·UNIT` | `3×10⁶` |
| 10 | `polymarket` | none; price as an integer `(makerAmount, takerAmount)` pair | order amounts ≤ 200, ≥2 makers | `4×10⁴` |

**Witness hosting, per row.**

1. `MINIMUM_LIQUIDITY = 1000` is a protocol constant, not a scale factor, so it may not be
   descaled. Convention 8's "integer ranges ≤ 200" therefore makes the first-mint mechanism
   **unreachable** — `sqrt(200·200) = 200 < 1000` and `.sub` underflows. The pilot's headline
   mechanism cannot fire under the plan's own bounds. Domain raised as above; witness
   `geometricMint(4000,9000) = 5000 ≠ 4000` is inside it.
2. The `≤ 200` cap is **not** the conflict — `(190,10)` is inside it. The conflict is `init`
   at `100/100` plus trade sizes too small to reach `19:1`. Directive: `init` at `150/50`,
   trade sizes up to 90, reachable imbalance stated in `BOUNDS:`. Convergence swept over all
   `200×200` pairs at `AMP=100`, `K=8`: **zero** non-converging, worst iters 3 (`AMP=1` has
   one bad point, `(33,1)`; fix `AMP=100`). At this descale the `≤1` break tolerance is one
   whole token, not 1 wei — a real relaxation, `ABSTRACTED:` line.
3. Chained `mulPrice→mulFactor` peaks at `4.5×10¹¹`. Witness = the 53-unit residue between
   absorb-credit and buy-back, reachable at seize `1000`.
4. `WAD² = 10³⁶` becomes `SCALE² = 10⁸`; T3 item 4 now runs, yielding `10438`. The bad-debt
   witness is a *cross-user* loss, so `|USERS| ≥ 2` — a single-supplier domain hosts the
   arithmetic and not the mechanism (regression signal 7).
5. `touched = 3` needs ≥3 troves and an amount exceeding the two smallest debts summed, so
   `amounts` must reach 250. At `amounts ≤ 100` the prefix walk never walks.
6. The fee witness needs `amountIn ≳ reserveIn`; at `amountIn/reserveIn = 0.2` the two forms
   coincide exactly (measured). A "safe small trade" domain silently re-deletes the fee — the
   review's second-order damage path, instantiated. The mint witness needs row 1's
   `[1000, 20000]`, so `apex` declares **two** ranges.
7. `applyExponentFactor` returns `0` for `d < SCALE` (`Precision.sol:93`), so a cap at
   `d ≤ 10⁴` — the review's suggestion — leaves exactly one non-zero point and cannot host
   the convexity witness. Raised to `d ≤ 4×10⁴`, hosting the `150` vs `250` pair at peak
   `1.6×10⁹`. Exponent 2 costs nothing; linearisation is revoked.
8. `wit_juniorCapped` needs cash `>` request while fill `<` request, i.e. the ratio must
   bind: `init` at `senior=700, junior=200`, not at a comfortable ratio.
9. The witness is `worstScenario` differing across two portfolios: needs a base and a perp leg
   with opposite exposure and ≥2 shocks. `base=100, perp=−100` is delta-neutral and gives an
   all-zero vector — it must not be `init`.
10. `wit_mintMatch` needs ≥2 makers on the taker's side in **one** action; a one-maker action
    cannot host it whatever the arithmetic.

**Standing directive.** Any domain reduction taken to escape `QNT601` is re-checked against
F4 and recorded in the header as `BOUNDS:` plus a sentence naming which witness still fits.

---

## D. The fifth trap — in this contract

**The trap.** T0 vectors are `pure val` equalities, and a `pure val` is true in every state —
including in a spec whose reachable state space never applies the pinned function. A worker
can satisfy all thirty-odd vectors with a correct, fully cited, registry-named `pure def`
that **no action ever calls**: the arithmetic present as a library, absent as a mechanism.
Same shape as the other four — the check passes because the stressing states, here the states
in which the definition is applied, were never entered. It is already live in the corpus
(`apex.qnt:184`'s unreachable bootstrap branch), and this repair makes it *easier*, because
T0 grants shape-plus-value credit at zero reachability cost.

**The check.** Two parts, both mechanical.

1. **Use witness.** For each registry name in convention 3, `grep` that it occurs at least
   once inside an `action` body — not only inside `inv_*`/`val` blocks — and ship
   `wit_used_<f>`, a state predicate that can hold only if `f`'s result was written into a
   `var`. `quint run --invariant=wit_used_<f>` must report a violation. A `pure def` cited
   only by invariants is a deleted mechanism carrying a certificate.
2. **`T0-LIVE:`.** A decorative call satisfies part 1, so exactly one vector per protocol is
   marked `T0-LIVE:` in the header and its obligation is a *trace*: a run in which some `var`
   changes by exactly the T0 output at the T0 input. Use, in order:
   `geometricMint(4000,9000)=5000`; `get_D(190,10)=196`; `absorbHaircut → 4500` then
   `quoteCollateral → 947`; `totalSupplyAssets 2000 → 1800`; `redeem(250)` touching 3;
   `ammOut(100,100,100)=49`; `sameSide(30000,20000)=+250`; `maxRedeemable(700,200)=25`;
   `worstScenario = 4` then `= 0`; `totalMintAmount = 32`.

One vector reachable as a transition is the difference between a spec that contains the
mechanism and a spec that merely knows its value.
