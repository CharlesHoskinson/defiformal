// =============================================================================
//  gmx (GMX v2 Synthetics) — Phase 2 re-spec.  Replaces quint-models/L3/gmx.qnt.
//
//  SOURCE:
//    protocol-repos/perp/gmx-io_gmx-synthetics/contracts/pricing/PricingUtils.sol
//      :61-77     getPriceImpactUsdForSameSideRebalance
//                   balanceWasImproved = nextDiffUsd < initialDiffUsd
//                   deltaDiffUsd = |f(initialDiffUsd) - f(nextDiffUsd)|
//                   priceImpactUsd = toSigned(deltaDiffUsd, balanceWasImproved)
//      :81-98     getPriceImpactUsdForCrossoverRebalance
//                   positive = f(initialDiffUsd, +factor);  negative = f(nextDiffUsd, -factor)
//                   sign = positive > negative
//      :104-111   applyImpactFactor = applyFactor(applyExponentFactor(d, e), factor)
//    protocol-repos/perp/gmx-io_gmx-synthetics/contracts/utils/Precision.sol
//      :23        FLOAT_PRECISION = 10**30
//      :37-39     applyFactor = mulDiv(value, factor, FLOAT_PRECISION)
//      :88-109    applyExponentFactor
//                   :92-94  if (floatValue < FLOAT_PRECISION) return 0     <-- THE CLIFF
//                   :96-98  if (exponentFactor == FLOAT_PRECISION) return floatValue
//                   :101-107 PRBMathUD60x18.pow otherwise
//    protocol-repos/perp/gmx-io_gmx-synthetics/contracts/pricing/PositionPricingUtils.sol
//      :201-240   _getPriceImpactUsd
//                   :202-203 initialDiffUsd / nextDiffUsd = Calc.diff of the two OI legs
//                   :209     isSameSideRebalance = (long <= short) == (nextLong <= nextShort)
//                   :212-213 factors selected by balanceWasImproved
//      :340-374   getNextOpenInterestParams (the OI underflow clamp at :352-356)
//    protocol-repos/perp/gmx-io_gmx-synthetics/contracts/market/MarketUtils.sol
//      :912-960   capPositiveImpactUsdByPositionImpactPool
//      :1085-1130 applyDeltaToPositionImpactPool
//      :1854-1876 validateReserve: reservedUsd <= applyFactor(poolUsd, reserveFactor)
//      :2048-2072 getReservedUsd
//      :263-283   getPoolUsdWithoutPnl = poolAmount * tokenPrice
//    protocol-repos/perp/gmx-io_gmx-synthetics/contracts/position/DecreasePositionCollateralUtils.sol
//      :186-200   positive impact: deduction = roundUpDivision(impactUsd, indexPrice.min);
//                 applyDeltaToPositionImpactPool(-deduction)
//      :437-461   negative impact: applyDeltaToPoolAmount(+paid) and
//                 applyDeltaToPositionImpactPool(+paid)
//
//  MECHANISM:
//    Price impact is a CONVEX function of how far a trade moves the open-interest
//    imbalance: `f(initialDiff) - f(nextDiff)` where `f(d) = d^2 * factor`, signed
//    by whether the imbalance shrank.  Convexity is not decoration — it is the whole
//    mechanism.  Two trades of identical size that move the imbalance by identical
//    amounts are charged DIFFERENT impacts depending on where in the imbalance they
//    sit, and that difference is what makes manipulating the reference price
//    unprofitable.  The charge is settled through the position impact pool, which
//    also caps every rebate: the pool can only pay out what earlier charges put in.
//
//  WHAT v1 DELETED (this file exists to restore it):
//    D-1  quint-models/L3/gmx.qnt:20 declares `var impactPool`, initialises it to 0
//         at :35, frames it as an identity in SIX actions (:47, :77, :96, :117,
//         :152, :166) and writes it at exactly ONE site, :140:
//           impactPool' = impactPool + max(0, p.collateral)
//         which is a LIQUIDATION's residual collateral, not an impact at all.  It is
//         then read once, in `oiCovered` (:174-176).  The whole of
//         `PricingUtils.sol:61-98` — the impact function, the same-side/crossover
//         split, the sign rule and the pool settlement — is absent from the spec.
//         This is the confirmed witness for `respec_lint` D2 ("dead state").
//         Two consequences, both restored here: (a) nothing charges or rebates a
//         trader for moving the imbalance, so the spec cannot express why anyone
//         would rebalance; (b) the residue at :140 goes to the WRONG POOL — the
//         contract credits liquidation residue to `poolAmount`
//         (`MarketUtils.applyDeltaToPoolAmount`, the LP balance), never to the
//         position impact pool, which is fed only by negative price impact.
//    D-2  quint-models/L3/gmx.qnt:64 and :88 replace `validateReserve`
//           reservedUsd <= Precision.applyFactor(poolUsd, reserveFactor)
//         (MarketUtils.sol:1854-1876) with the raw product
//           poolAmount * markPrice >= (longOI + sizeUsd)
//         dropping `reserveFactor` entirely, so the pool is modelled as able to back
//         open interest one-for-one.  Restored as `maxReservedUsd`.
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    the exponent-2 impact function and BOTH branches of `applyExponentFactor`
//    (the sub-FLOAT_PRECISION cliff at :93 and the exponent == FLOAT_PRECISION
//    identity at :97); the same-side / crossover split at :209 and both of its
//    branches; the `balanceWasImproved` sign rule; the positive-impact cap against
//    the pool (:912-960); the pool credit on a charge and debit on a rebate, in the
//    contract's own rounding directions (roundUpDivision both ways, :187 and :444);
//    `validateReserve` with its `reserveFactor`; the OI underflow clamp at :352-356;
//    `isPositionLiquidatable`'s collateral-vs-size floor; liquidation residue to
//    `poolAmount`.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - THE DEFERRAL.  PositionUtils.sol:706-732 applies the increase-leg impact to
//      `sizeDeltaInTokens`, and IncreasePositionUtils.sol:130-136 stores it in
//      `position.pendingImpactAmount` to be realised at decrease
//      (DecreasePositionCollateralUtils.sol:186-200, :437-461).  Here the impact is
//      settled against collateral and the pool at the moment of the order.  The
//      impact FUNCTION, its sign rule, the positive cap against the pool and the
//      direction of every token flow are unchanged; what is dropped is the timing,
//      which no guard reads.  `sizeInTokens` is therefore the un-impacted
//      `sizeDeltaUsd / indexPrice`.
//    - virtual inventory (`getNextOpenInterestForVirtualInventory`,
//      PositionPricingUtils.sol:308-337) and the `min` of the two impact values at
//      :191-197.  P2-SCOPE row 7 drops virtual inventory.
//    - the lending path inside `capPositiveImpactUsdByPositionImpactPool`
//      (:938-960, `lentPositionImpactPoolAmount`): the cap here is the plain
//      `impactPoolAmount * indexPrice`, i.e. the pool lends nothing.  Both sides of
//      the cap are still reachable.
//    - `distributePositionImpactPool` (MarketUtils.sol:2884-2905) and the
//      max-position-impact cap (`capPositiveImpactUsdByMaxPositionImpact`).
//      Governance-configured throttles on a mechanism that is present.
//    - swap impact, deposits/withdrawals of liquidity, multi-market and the
//      long/short-token split.  P2-SCOPE row 7.  One market, one token: `poolAmount`
//      is the single token balance and `getPoolUsdWithoutPnl` is `poolAmount * price`.
//    - funding and borrowing fees (v1's `funding` / `time`).  Separate mechanisms;
//      no guard in the impact path reads them.  Position fees likewise.
//    - `indexTokenPrice.min` / `.max` are one price: the oracle spread is a second
//      mechanism and every rounding direction that depends on it is preserved by
//      using the contract's own `roundUpDivision` / floor at each site.
//    - order keepers, execution fees, the two-step order lifecycle, callbacks.
//    - `Position.Props.sizeInTokens` is carried, but `collateralToken` is fixed to
//      the index token (single-token market), so `collateralTokenPrice == indexTokenPrice`
//      and the conversion at :459 is the identity.
//
//  GHOST:
//    `lastOp` and `lastImpactUsd` are not contract state.  They are the trace label
//    of the observation interface (P2-FIDELITY §1) and carry exactly what GMX's own
//    `PositionIncrease` / `PositionDecrease` (`priceImpactUsd`) and
//    `PositionImpactPoolAmountUpdated` (`delta`) events carry, which are droppable
//    only because no guard reads them.  They are read by `wit_*` and by nothing
//    else; no guard and no `pure def` reads either, and they are exempt from 6e's
//    write-only clause on that basis.  `lastImpactUsd` is a VALUE, not a tag, so
//    the PILOT-NOTES §5 step-3 rule ("never let a `wit_used_<f>` be tag-only") is
//    satisfied: it is the emitted impact, not a label saying an action fired.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 2 traders; 5 `nondet`s per step, of sizes 2, 4, 2, 2, 4.
//       No list state.
//    8b magnitude — peak intermediate 6.0e9 < 9.22e18.  It is `d * d` inside
//       `applyExponentFactor` (Precision.sol:101-107 at exponent 2).  `d` is bounded
//       by `maxReservedUsd` = applyFactor(poolAmount * price, RESERVE_FACTOR); at the
//       domain corner (poolAmount ~ 15000, price 12, factor 4000) that is 72000, so
//       `d^2 <= 5.2e9`.  At the initial price of 10 the bound is exactly the
//       P2-CONTRACT §C row 7 figure, `d <= 4.0e4` and `d^2 = 1.6e9`.
//       Next largest: `applyFactor`'s numerator `(d^2 / SCALE) * factor` at 2.6e7,
//       and `poolAmount * price` at 1.8e5.
//       This spec does NOT call `kernel.isqrtFloor`, so PILOT-NOTES D-d's
//       4.611686e18 floor does not apply to it.
//       LINEARISATION IS REVOKED (P2-CONTRACT §A.7).  Exponent 2 costs nothing at
//       this descale — 5.2e9 is 1.8e9 times under the ceiling — and the exponent IS
//       the mechanism: every linear impact function returns the SAME number for
//       `sameSide(20000,10000)` and `sameSide(30000,20000)`, and those two are the
//       discrimination witness.  See §M1.
//    8c constant-crossing —
//       FLOAT_PRECISION = 10^4 in the cliff at Precision.sol:93.  The imbalance `d`
//         takes the values 0, 5000, 10000, 20000, 30000 and 40000 in the declared
//         domain, i.e. THREE values strictly below the cliff (0, 5000 and every
//         diff a 5000-size order produces) and three at or above it.  t0_01/t0_02
//         pin `d = 5000 -> 0` and `d = 10000 -> 50`; `wit_branch_impactCliff` is
//         the runtime side.  P2-CARRYFORWARD CF1 records that the old `<=200` cap
//         made the whole impact function identically zero, which is why it is gone,
//         and P2-CONTRACT §C row 7 records that the review's proposed `d <= 10^4`
//         leaves exactly ONE non-zero point and cannot host the convexity witness.
//         The cap used here is 4x10^4, which hosts it.
//       IMPACT_EXPONENT = 2*SCALE in the branch at Precision.sol:97.  The
//         `exponentFactor == FLOAT_PRECISION` branch is the LINEARISATION, i.e. the
//         contrast-set member M1; it is pinned by t0_08..t0_10 as vectors and is not
//         a reachable configuration of the modelled market, because a market
//         configures exactly one exponent.  Recorded as DEVIATION D-b.
//       RESERVE_FACTOR = 4000: at the initial price the cap is 40000 of open
//         interest, and SIZE_DELTAS reach 30000, so two orders cross it.
//         `wit_branch_reserveRefused` is the state one order short of the cap.
//       MIN_COLLATERAL_FACTOR = 100: crossed by the price domain, which spans a 40 %
//         drawdown; `wit_fired_liquidatePosition`.
//
//  INPUTS:  (convention 6g, dependency parity — foot(Q) = contract storage the
//           contract's own expression for this quantity depends on)
//    | name      | contract expression                   | file:line | foot(Q) | spec vars read |
//    | trader    | order.account()                       | Order.sol | none    | none (calldata) |
//    | sizeDelta | order.sizeDeltaUsd()                  | Order.sol | none    | none (calldata) |
//    | isLong    | order.isLong()                        | Order.sol | none    | none (calldata) |
//    | collAmt   | order.initialCollateralDeltaAmount()  | Order.sol | none    | none (calldata) |
//    | price     | oracle.getPrimaryPrice(indexToken)    | Oracle.sol| none    | none (external) |
//    NOTHING here is a quantity the protocol computes.  In particular the IMPACT is
//    NOT an input: `initialDiffUsd` and `nextDiffUsd` are derived inside
//    `impactUsd` from `longOI` / `shortOI` / the order size, all modelled, which is
//    exactly the 6g parity v1 could not have (v1 has no impact quantity at all, so
//    CF2's ten-way table marks gmx "—, no spec quantity to compare" and leaves the
//    catch to 6e / lint D2).
//    `price` is a genuine external-call return, foot(Q) = empty — the oracle case
//    6g was written to permit.  Note the contrast with apex's H1: GMX's liquidation
//    trigger reads the ORACLE price and the position's own size, both modelled, and
//    the size dependence is in `applyFactor(sizeUsd, minCollateralFactor)`, so the
//    H1 shape does not arise here.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    ExchangeRouter.sendTokens + createOrder(MarketIncrease) -> actions depositCollateral,
//                                                               increasePosition
//    ExchangeRouter.createOrder(MarketDecrease)              -> action decreasePosition
//    ExchangeRouter.createOrder(MarketDecrease, full close) + collateral out
//                                                            -> action withdrawCollateral
//    LiquidationHandler.executeLiquidation                   -> action liquidatePosition
//    the oracle's own update                                 -> action setMarkPrice
//    ExchangeRouter.createDeposit / createWithdrawal (liquidity) -> ABSTRACTED
//    ExchangeRouter.createShift / createGlvDeposit / swaps       -> ABSTRACTED
//    AdlHandler.executeAdl, Config.setUint (governance)          -> ABSTRACTED
//    MarketUtils.distributePositionImpactPool                    -> ABSTRACTED
//    Storage read by a require on a state-changing path:
//      Position.sizeInUsd (:1854 via getReservedUsd, isPositionLiquidatable) -> var posSizeUsd
//      Position.sizeInTokens (getPositionPnlUsd)                             -> var posSizeInTokens
//      Position.collateralAmount (isPositionLiquidatable)                    -> var posCollateral
//      Position.isLong (:209, :340-360)                                      -> var posIsLong
//      openInterest long / short (:202-203, :2048-2072)                      -> vars longOI, shortOI
//      positionImpactPoolAmount (:924)                                       -> var impactPool
//      poolAmount (:273, :1861)                                              -> var poolAmount
//      indexTokenPrice (:1863, :933)                                         -> var markPrice
//      lentPositionImpactPoolAmount (:946)                                   -> ABSTRACTED (no lending)
//      virtual inventory (:308-337)                                          -> ABSTRACTED
//      collateralSum / minCollateralUsd config                               -> pure vals
//    No `var` is write-only.  `impactPool` is read by `capPositiveImpact` (a GUARD
//    on every rebate), by `inv_impactPoolBacked` and by `wit_*`; contrast v1, where
//    it was read once, by an invariant, and written once, by a liquidation.
//    `totalDeposited` is read by `inv_conservation`.
//
//  UNITS:  (hole H2's obligation, applied here as a convention)
//    longOI, shortOI, sizeDelta, posSizeUsd, initialDiff, nextDiff, impactUsd,
//      lastImpactUsd, maxReservedUsd, poolUsd, pnlUsd  — USD
//    poolAmount, impactPool, posCollateral, collAmt, totalDeposited,
//      posSizeInTokens                                 — INDEX-token units
//    markPrice                                          — USD per index token
//    IMPACT_FACTOR, IMPACT_EXPONENT, RESERVE_FACTOR,
//      MIN_COLLATERAL_FACTOR                            — factors (FLOAT_PRECISION)
//
//  CONTRAST SET (F0/F2, with R4's three mandatory members):
//    M0  f(d) = applyFactor(d^2 / SCALE, IMPACT_FACTOR), same-side / crossover
//        split, settled through the impact pool                        [target]
//    M1  THE LINEARISATION: exponent = FLOAT_PRECISION, i.e. f(d) = applyFactor(d,
//        IMPACT_FACTOR).  MANDATORY member 1 — it is the form P2-SCOPE row 7 listed
//        as droppable and P2-CONTRACT §A.7 revoked.  Built as mutants/gmx_M1.qnt.
//        Agreement with M0 over the declared `d` domain {0, 5000, 10^4, 2e4, 3e4,
//        4e4}: 3/6 = 50 % — and every point of agreement is a point where the impact
//        is 0 or 50, i.e. the degenerate part of the domain.
//        MEASURED, --max-steps=20 --max-samples=40000:
//          inv_conservation      [ok]         <- does NOT discriminate
//          inv_bounds            [ok]         <- does NOT discriminate
//          inv_impactPoolBacked  [ok]         <- does NOT discriminate
//          inv_oiMatchesPositions[ok]         <- does NOT discriminate
//          inv_T0                [VIOLATION] (t0_12/t0_13, the sameSide pair)
//          inv_impactConvex      [VIOLATION] <- THE KILL
//          wit_live_convexImpact [ok]         <- the state is UNREACHABLE
//          wit_used_impactUsd    [VIOLATION] <- still violated: the mutant DOES feed
//                                              the pool, just with the wrong number,
//                                              so a reachability witness alone does
//                                              not separate M0 from M1
//        Note which vectors survived: t0_01..t0_07 and t0_11 pass the exponent as an
//        explicit argument and are unchanged by the mutant.  The kill comes from
//        t0_12/t0_13, which read the market's CONFIGURED exponent through
//        `impactSameSide`.  Same lesson as compound_v3's M1: a T0 block written
//        entirely in explicit arguments pins the function, not the configuration.
//    M2  chaos: any impact in [0, f(maxDiff)].  MANDATORY member 2 — the maximally
//        permissive form in the same direction.  Killed by inv_T0 and by
//        `inv_impactSign` losing its sign rule.
//    M3  v1 itself: NO impact function, `impactPool` fed only by liquidation
//        residue (gmx.qnt:20,140).  MANDATORY member 3, sourced from the corpus.
//        Agreement with M0: 1/6 (only at d = 0 and d = 5000, where both give 0).
//        Killed by `wit_used_impactUsd` — `impactPool` is never fed by an order.
//    M4  exponent 2 but no crossover branch (same-side formula everywhere): the
//        near-neighbour rival.  Agreement with M0 on the declared domain: it differs
//        ONLY when the imbalance changes sides, which is 1 transition in the T0-LIVE
//        trace itself — the very first order.  Killed by t0_13 (crossover from 0)
//        vs t0_11 (same-side).
//    FINDING: unlike the pilot's `geometricMint`, R4's >=90 % near neighbour DOES
//    exist here — M4 agrees with M0 everywhere except at a sign change, which is a
//    measure-zero event in most domains.  A domain in which the OI never crosses
//    would satisfy every check in this file under M4.  The declared domain forces a
//    crossing on the FIRST order (both OIs start at 0), which is why `d = 0` is in
//    the domain and why it must stay there.
//
//  ACCEPTANCE:
//    T1  quint typecheck gmx.qnt
//    T2  quint run --main=gmx --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 gmx.qnt
//    T3  quint run --main=gmx --invariant=inv_all ... (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: sameSide(30000, 20000) = +250.  The obligation is the TRACE that
//        violates `wit_live_convexImpact`: a reachable state at longOI 30000,
//        shortOI 10000 in which the order just executed was rebated exactly 250 USD
//        and the impact pool fell from 45 to 20 tokens.  Under M1 the same order is
//        rebated 50 and the pool holds 10, so the state is unreachable.
//
//  DEVIATIONS from P2-CONTRACT.md / P2-SCOPE.md, each with its reason:
//    D-a  P2-SCOPE row 7 says "exponent != 1 (linear impact is acceptable)".
//         REVOKED by P2-CONTRACT §A.7 and not taken.  See §M1 and BOUNDS 8b.
//    D-b  `applyExponentFactor`'s general `PRBMathUD60x18.pow` is implemented for
//         exponents SCALE and 2*SCALE only.  A market configures exactly one
//         `positionImpactExponentFactor`; both of the contract's own early-return
//         branches (:93, :97) are present, and the third is the pow, whose only
//         reachable argument in this market is 2.
//    D-c  registry extended.  P2-SCOPE convention 3 lists `impactUsd`;
//         convention 6b requires every arithmetic mechanism to be named, so
//         `applyExponentFactor`, `applyImpactFactor`, `impactSameSide`,
//         `impactCrossover`, `capPositiveImpact`, `maxReservedUsd`,
//         `positionPnlUsd` and `isPositionLiquidatableAt` are named and pinned too.
//    D-d  v1's `MAINT_BPS`-style liquidation is replaced by
//         `isPositionLiquidatable`'s own `applyFactor(sizeInUsd, minCollateralFactor)`
//         floor against collateral plus PnL.  This is a restoration, not a
//         deviation from the contract; it is recorded because it changes v1's
//         `canLiquidate` shape.
// =============================================================================
//
//  AUTHORITY (convention 6h).  Generated by phase2/auth_scan.py,
//  which reads the contract's modifiers AND its function bodies, and
//  discards pause/lifecycle guards (`onlyUnpaused`, `nonReentrant`)
//  because they restrict WHEN, not WHO.
//
//  PERMISSIONLESS is a positive claim: the cited line was checked and
//  restricts nobody.  UNRESOLVED means no contract function matched by
//  name; it is NOT a synonym for permissionless.
//
//    decreasePosition    PERMISSIONLESS  contracts/position/DecreasePositionUtils.sol:63  no 
//    depositCollateral   PERMISSIONLESS  contracts/token/IWNT.sol:12  no caller check found
//    increasePosition    PERMISSIONLESS  contracts/position/IncreasePositionUtils.sol:55  no 
//    withdrawCollateral  PERMISSIONLESS  contracts/token/IWNT.sol:13  no caller check found
//    liquidatePosition   UNRESOLVED      no contract function matched by name
//    setMarkPrice        UNRESOLVED      no contract function matched by name
// --------------------------------------------------------------------------
module gmx {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// Precision.sol:23 FLOAT_PRECISION = 10**30, descaled to 1e4 (P2-CONTRACT §C row 7)
  pure val FLOAT_PRECISION: int = 10000
  /// market config `positionImpactExponentFactor` = 2.0
  pure val IMPACT_EXPONENT: int = 20000
  /// market config `positivePositionImpactFactor` / `negativePositionImpactFactor`.
  /// The contract selects between them on `balanceWasImproved`
  /// (MarketUtils.getAdjustedPositionImpactFactor); the selection is modelled and in
  /// THIS market configuration the two values coincide, which is what makes the
  /// P2-CONTRACT §A.7 vectors reproduce exactly.
  pure val POSITIVE_IMPACT_FACTOR: int = 50
  pure val NEGATIVE_IMPACT_FACTOR: int = 50
  pure val POSITIVE_IMPACT_EXPONENT: int = 20000
  pure val NEGATIVE_IMPACT_EXPONENT: int = 20000
  /// market config `reserveFactor` (MarketUtils.sol:1861).  Dropped entirely by v1.
  pure val RESERVE_FACTOR: int = 4000
  /// market config `minCollateralFactor` (PositionUtils.isPositionLiquidatable)
  pure val MIN_COLLATERAL_FACTOR: int = 100

  pure val T1: str = "t1"
  pure val T2: str = "t2"
  pure val TRADERS: Set[str] = Set(T1, T2)

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN (convention 8a; see BOUNDS for 8b and 8c)
  // ---------------------------------------------------------------------------

  pure val SIZE_DELTAS: Set[int] = Set(5000, 10000, 20000, 30000)
  pure val COLLATERAL_AMOUNTS: Set[int] = Set(50, 200)
  pure val MARK_PRICES: Set[int] = Set(5, 8, 10, 12)
  pure val SIDES: Set[bool] = Set(true, false)

  pure val INIT_POOL_AMOUNT: int = 10000
  pure val INIT_IMPACT_POOL: int = 0
  pure val INIT_OI: int = 0
  pure val INIT_MARK_PRICE: int = 10
  pure val INIT_COLLATERAL: int = 200
  pure val INIT_TOTAL_DEPOSITED: int = 400
  pure val INIT_SIZE: int = 0
  pure val INIT_IS_LONG: bool = true
  pure val INIT_IMPACT_USD: int = 0

  pure val OP_INIT: str = "init"
  pure val OP_DEPOSIT: str = "depositCollateral"
  pure val OP_WITHDRAW: str = "withdrawCollateral"
  pure val OP_INCREASE: str = "increasePosition"
  pure val OP_DECREASE: str = "decreasePosition"
  pure val OP_LIQUIDATE: str = "liquidatePosition"
  pure val OP_PRICE: str = "setMarkPrice"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var posSizeUsd: str -> int        // Position.sizeInUsd, USD
  var posSizeInTokens: str -> int   // Position.sizeInTokens, index tokens
  var posCollateral: str -> int     // Position.collateralAmount, index tokens
  var posIsLong: str -> bool        // Position.isLong
  var longOI: int                   // USD
  var shortOI: int                  // USD
  var impactPool: int               // positionImpactPoolAmount, index tokens
  var poolAmount: int               // MarketUtils poolAmount, index tokens
  var totalDeposited: int           // net collateral in, index tokens
  var markPrice: int                // USD per index token
  var lastOp: str                   // GHOST — trace label, see header
  var lastImpactUsd: int            // GHOST — emitted priceImpactUsd, see header

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  `absInt` (SignedMath.abs / Calc.diff) comes from `kernel`.
  //  Every one is pinned by exact T0 vectors below AND carries a `wit_used_*`
  //  reachability obligation, because a `pure val` equality is true in states
  //  where the definition is never applied (the fifth trap, §D).
  // ===========================================================================

  /// Precision.sol:37-39
  pure def applyFactor(value: int, factor: int): int =
    mulDivDown(value, factor, FLOAT_PRECISION)

  /// Precision.sol:88-109.  THE CLIFF at :92-94 is a real early return, not an
  /// approximation: below one unit of FLOAT_PRECISION the impact is exactly zero.
  /// :96-98 is the linearisation branch — see DEVIATION D-b and contrast member M1.
  pure def applyExponentFactor(d: int, exponentFactor: int): int =
    if (d < FLOAT_PRECISION) 0
    else if (exponentFactor == FLOAT_PRECISION) d
    else mulDivDown(d, d, FLOAT_PRECISION)

  /// PricingUtils.sol:104-111
  pure def applyImpactFactor(d: int, factor: int, exponentFactor: int): int =
    applyFactor(applyExponentFactor(d, exponentFactor), factor)

  /// PricingUtils.sol:61-77.  `balanceWasImproved` picks BOTH the sign and the
  /// factor pair (PositionPricingUtils.sol:212-213).
  pure def impactSameSide(initialDiff: int, nextDiff: int): int = {
    val improved = nextDiff < initialDiff
    val factor = if (improved) POSITIVE_IMPACT_FACTOR else NEGATIVE_IMPACT_FACTOR
    val exponent = if (improved) POSITIVE_IMPACT_EXPONENT else NEGATIVE_IMPACT_EXPONENT
    val delta = absInt(applyImpactFactor(initialDiff, factor, exponent)
                         - applyImpactFactor(nextDiff, factor, exponent))
    if (improved) delta else 0 - delta
  }

  /// PricingUtils.sol:81-98.  The two legs use DIFFERENT factors, and the sign is
  /// the comparison of the two impacts rather than of the two imbalances — which is
  /// the anti-gaming clause the comment at PositionPricingUtils.sol:204-208 explains.
  pure def impactCrossover(initialDiff: int, nextDiff: int): int = {
    val positiveImpact =
      applyImpactFactor(initialDiff, POSITIVE_IMPACT_FACTOR, POSITIVE_IMPACT_EXPONENT)
    val negativeImpact =
      applyImpactFactor(nextDiff, NEGATIVE_IMPACT_FACTOR, NEGATIVE_IMPACT_EXPONENT)
    val delta = absInt(positiveImpact - negativeImpact)
    if (positiveImpact > negativeImpact) delta else 0 - delta
  }

  /// PositionPricingUtils.sol:201-240 — the dispatcher.  `isSameSideRebalance` at
  /// :209 is the whole of the crossover test.
  pure def impactUsd(lOI: int, sOI: int, nextL: int, nextS: int): int = {
    val initialDiff = absInt(lOI - sOI)
    val nextDiff = absInt(nextL - nextS)
    val isSameSideRebalance = (lOI <= sOI) == (nextL <= nextS)
    if (isSameSideRebalance) impactSameSide(initialDiff, nextDiff)
    else impactCrossover(initialDiff, nextDiff)
  }

  /// MarketUtils.sol:912-937.  A rebate can never exceed what the pool holds; this
  /// is the guard that makes `impactPool >= 0` an invariant rather than a hope.
  pure def capPositiveImpact(raw: int, pool: int, price: int): int =
    if (raw <= 0) raw else minInt(raw, pool * price)

  /// DecreasePositionCollateralUtils.sol:186-187 (rebate, roundUpDivision) and
  /// :444-450 (charge, the amount the trader paid).  Both round UP.
  pure def impactPoolDelta(capped: int, price: int): int =
    if (capped > 0) 0 - ceilDiv(capped, price) else ceilDiv(0 - capped, price)

  /// MarketUtils.sol:1854-1876 + :263-283.  v1 replaced this whole expression with
  /// `poolAmount * markPrice >= longOI + sizeUsd`.
  pure def maxReservedUsd(pool: int, price: int): int =
    applyFactor(pool * price, RESERVE_FACTOR)

  /// PositionPricingUtils.sol:340-374 — the OI underflow clamp at :352-356.
  pure def nextOpenInterest(oi: int, usdDelta: int): int = maxInt(oi + usdDelta, 0)

  /// MarketUtils.getPositionPnlUsd
  pure def positionPnlUsd(sizeUsd: int, sizeInTokens: int, isLong: bool, price: int): int =
    if (isLong) sizeInTokens * price - sizeUsd else sizeUsd - sizeInTokens * price

  /// PositionUtils.isPositionLiquidatable — the collateral-vs-size floor.
  pure def isPositionLiquidatableAt(sizeUsd: int, sizeInTokens: int, coll: int,
                                    isLong: bool, price: int): bool =
    sizeUsd > 0 and
      coll * price + positionPnlUsd(sizeUsd, sizeInTokens, isLong, price)
        < applyFactor(sizeUsd, MIN_COLLATERAL_FACTOR)

  // ---------------------------------------------------------------------------
  // DERIVED STATE
  // ---------------------------------------------------------------------------

  def pnlOf(t: str): int =
    positionPnlUsd(posSizeUsd.get(t), posSizeInTokens.get(t), posIsLong.get(t), markPrice)

  def liquidatableNow(t: str): bool =
    isPositionLiquidatableAt(posSizeUsd.get(t), posSizeInTokens.get(t),
                             posCollateral.get(t), posIsLong.get(t), markPrice)

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed from
  //  the cited Solidity line in integer arithmetic.  [SEP] marks a value the
  //  linearised form cannot produce.
  // ===========================================================================

  // -- applyImpactFactor, the cliff and the curve (Precision.sol:88-109) -------
  pure val t0_01: bool = applyImpactFactor(5000, 50, 20000) == 0        // 8c: below the cliff
  pure val t0_02: bool = applyImpactFactor(10000, 50, 20000) == 50      // 8c: at the cliff
  pure val t0_03: bool = applyImpactFactor(20000, 50, 20000) == 200     // [SEP] linear -> 100
  pure val t0_04: bool = applyImpactFactor(30000, 50, 20000) == 450     // [SEP] linear -> 150
  pure val t0_05: bool = applyImpactFactor(40000, 50, 20000) == 800     // [SEP] linear -> 200
  pure val t0_06: bool = applyImpactFactor(0, 50, 20000) == 0
  pure val t0_07: bool = applyExponentFactor(9999, 20000) == 0          // 6f: cliff, other side
  // the exponent == FLOAT_PRECISION branch (Precision.sol:96-98) — this IS M1
  pure val t0_08: bool = applyExponentFactor(20000, 10000) == 20000
  pure val t0_09: bool = applyImpactFactor(20000, 50, 10000) == 100
  pure val t0_10: bool = applyImpactFactor(30000, 50, 10000) == 150
  // 6c: an inexact quotient inside applyFactor — 25000^2/1e4 = 62500, *50/1e4 = 312.5
  pure val t0_11: bool = applyImpactFactor(25000, 50, 20000) == 312

  // -- the same-side rebalance (PricingUtils.sol:61-77) ------------------------
  pure val t0_12: bool = impactSameSide(20000, 10000) == 150            // [SEP] linear -> +50
  pure val t0_13: bool = impactSameSide(30000, 20000) == 250            // [SEP] linear -> +50
  pure val t0_14: bool = impactSameSide(20000, 30000) == -250           // worsened
  pure val t0_15: bool = impactSameSide(5000, 0) == 0                   // 6f: both below the cliff

  // -- the crossover rebalance (PricingUtils.sol:81-98) ------------------------
  pure val t0_16: bool = impactCrossover(0, 20000) == -200
  pure val t0_17: bool = impactCrossover(0, 30000) == -450
  pure val t0_18: bool = impactCrossover(20000, 0) == 200

  // -- the dispatcher, both branches (PositionPricingUtils.sol:201-240) --------
  /// long 0 -> 30000 against short 0: the sides SWAP, so this is the crossover
  /// branch even though the imbalance only grew.  M4 gets this one wrong.
  pure val t0_19: bool = impactUsd(0, 0, 30000, 0) == -450
  /// long 30000 against short 0 -> 10000: same side, improved.  THE T0-LIVE VECTOR.
  pure val t0_20: bool = impactUsd(30000, 0, 30000, 10000) == 250
  pure val t0_21: bool = impactUsd(30000, 10000, 30000, 20000) == 150
  /// long 30000 -> 0 against short 20000: the sides swap the other way, so the
  /// CROSSOVER branch fires on a shrinking imbalance (10000 -> 20000 in magnitude,
  /// but measured on opposite sides) and the charge is f(10000) - f(20000).
  pure val t0_22: bool = impactUsd(30000, 20000, 0, 20000) == -150

  // -- the pool cap and the pool delta -----------------------------------------
  pure val t0_23: bool = capPositiveImpact(250, 45, 10) == 250          // 6f: cap loose
  pure val t0_24: bool = capPositiveImpact(250, 2, 10) == 20            // 6f: cap binds
  pure val t0_25: bool = capPositiveImpact(-450, 0, 10) == -450         // negative untouched
  pure val t0_26: bool = impactPoolDelta(250, 10) == -25
  pure val t0_27: bool = impactPoolDelta(-450, 10) == 45
  pure val t0_28: bool = impactPoolDelta(250, 8) == -32                 // 6c: ceil of 31.25
  pure val t0_29: bool = impactPoolDelta(-450, 8) == 57                 // 6c: ceil of 56.25

  // -- validateReserve (MarketUtils.sol:1854-1876) -----------------------------
  pure val t0_30: bool = maxReservedUsd(10000, 10) == 40000             // [SEP] v1 -> 100000
  pure val t0_31: bool = maxReservedUsd(10045, 10) == 40180

  // -- PnL and the liquidation floor -------------------------------------------
  pure val t0_32: bool = positionPnlUsd(30000, 3000, true, 10) == 0
  pure val t0_33: bool = positionPnlUsd(30000, 3000, true, 5) == -15000
  pure val t0_34: bool = positionPnlUsd(30000, 3000, false, 5) == 15000
  pure val t0_35: bool = isPositionLiquidatableAt(30000, 3000, 155, true, 5)
  pure val t0_36: bool = not(isPositionLiquidatableAt(30000, 3000, 155, true, 10))
  pure val t0_37: bool = nextOpenInterest(10000, -30000) == 0           // 6f: the clamp

  pure val inv_T0: bool = and {
    t0_01, t0_02, t0_03, t0_04, t0_05, t0_06, t0_07, t0_08, t0_09, t0_10,
    t0_11, t0_12, t0_13, t0_14, t0_15, t0_16, t0_17, t0_18, t0_19, t0_20,
    t0_21, t0_22, t0_23, t0_24, t0_25, t0_26, t0_27, t0_28, t0_29, t0_30,
    t0_31, t0_32, t0_33, t0_34, t0_35, t0_36, t0_37,
  }

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    posSizeUsd' = TRADERS.mapBy(_ => INIT_SIZE),
    posSizeInTokens' = TRADERS.mapBy(_ => INIT_SIZE),
    posCollateral' = TRADERS.mapBy(_ => INIT_COLLATERAL),
    posIsLong' = TRADERS.mapBy(_ => INIT_IS_LONG),
    longOI' = INIT_OI,
    shortOI' = INIT_OI,
    impactPool' = INIT_IMPACT_POOL,
    poolAmount' = INIT_POOL_AMOUNT,
    totalDeposited' = INIT_TOTAL_DEPOSITED,
    markPrice' = INIT_MARK_PRICE,
    lastOp' = OP_INIT,
    lastImpactUsd' = INIT_IMPACT_USD,
  }

  /// ExchangeRouter.sendTokens + the collateral leg of an increase order.
  action depositCollateral(trader: str, amount: int): bool = all {
    TRADERS.contains(trader),
    amount > 0,
    posCollateral' = posCollateral.put(trader, posCollateral.get(trader) + amount),
    totalDeposited' = totalDeposited + amount,
    posSizeUsd' = posSizeUsd,
    posSizeInTokens' = posSizeInTokens,
    posIsLong' = posIsLong,
    longOI' = longOI,
    shortOI' = shortOI,
    impactPool' = impactPool,
    poolAmount' = poolAmount,
    markPrice' = markPrice,
    lastOp' = OP_DEPOSIT,
    lastImpactUsd' = INIT_IMPACT_USD,
  }

  /// The collateral leg of a decrease order on a flat position.
  action withdrawCollateral(trader: str, amount: int): bool = all {
    TRADERS.contains(trader),
    amount > 0,
    posSizeUsd.get(trader) == 0,
    posCollateral.get(trader) >= amount,
    posCollateral' = posCollateral.put(trader, posCollateral.get(trader) - amount),
    totalDeposited' = totalDeposited - amount,
    posSizeUsd' = posSizeUsd,
    posSizeInTokens' = posSizeInTokens,
    posIsLong' = posIsLong,
    longOI' = longOI,
    shortOI' = shortOI,
    impactPool' = impactPool,
    poolAmount' = poolAmount,
    markPrice' = markPrice,
    lastOp' = OP_WITHDRAW,
    lastImpactUsd' = INIT_IMPACT_USD,
  }

  /// IncreasePositionUtils.increasePosition.  The impact is computed from the OI
  /// imbalance BEFORE and AFTER this order, capped against the pool, charged to or
  /// rebated from the trader's collateral, and settled into the pool.
  action increasePosition(trader: str, isLong: bool, sizeDeltaUsd: int): bool = all {
    TRADERS.contains(trader),
    sizeDeltaUsd > 0,
    posCollateral.get(trader) > 0,
    posSizeUsd.get(trader) == 0 or posIsLong.get(trader) == isLong,
    val nextL = if (isLong) nextOpenInterest(longOI, sizeDeltaUsd) else longOI
    val nextS = if (isLong) shortOI else nextOpenInterest(shortOI, sizeDeltaUsd)
    val raw = impactUsd(longOI, shortOI, nextL, nextS)
    val capped = capPositiveImpact(raw, impactPool, markPrice)
    val poolDelta = impactPoolDelta(capped, markPrice)
    val sizeDeltaInTokens = sizeDeltaUsd / markPrice
    val newSize = posSizeUsd.get(trader) + sizeDeltaUsd
    val newColl = posCollateral.get(trader) - poolDelta
    val newTokens = posSizeInTokens.get(trader) + sizeDeltaInTokens
    all {
      sizeDeltaInTokens > 0,
      newColl > 0,
      (if (isLong) nextL else nextS) <= maxReservedUsd(poolAmount, markPrice),
      not(isPositionLiquidatableAt(newSize, newTokens, newColl, isLong, markPrice)),
      posSizeUsd' = posSizeUsd.put(trader, newSize),
      posSizeInTokens' = posSizeInTokens.put(trader, newTokens),
      posCollateral' = posCollateral.put(trader, newColl),
      posIsLong' = posIsLong.put(trader, isLong),
      longOI' = nextL,
      shortOI' = nextS,
      impactPool' = impactPool + poolDelta,
      poolAmount' = poolAmount + poolDelta,
      totalDeposited' = totalDeposited,
      markPrice' = markPrice,
      lastOp' = OP_INCREASE,
      lastImpactUsd' = capped,
    }
  }

  /// DecreasePositionUtils.decreasePosition.  Same impact path, plus the realised
  /// PnL of the closed fraction settling between the position and the pool.
  action decreasePosition(trader: str, sizeDeltaUsd: int): bool = all {
    TRADERS.contains(trader),
    sizeDeltaUsd > 0,
    posSizeUsd.get(trader) >= sizeDeltaUsd,
    val isLong = posIsLong.get(trader)
    val nextL = if (isLong) nextOpenInterest(longOI, 0 - sizeDeltaUsd) else longOI
    val nextS = if (isLong) shortOI else nextOpenInterest(shortOI, 0 - sizeDeltaUsd)
    val raw = impactUsd(longOI, shortOI, nextL, nextS)
    val capped = capPositiveImpact(raw, impactPool, markPrice)
    val poolDelta = impactPoolDelta(capped, markPrice)
    val pnlFull = pnlOf(trader)
    val pnlPart =
      if (pnlFull >= 0) mulDivDown(pnlFull, sizeDeltaUsd, posSizeUsd.get(trader))
      else 0 - mulDivDown(0 - pnlFull, sizeDeltaUsd, posSizeUsd.get(trader))
    val pnlTokens =
      if (pnlPart >= 0) pnlPart / markPrice else 0 - ceilDiv(0 - pnlPart, markPrice)
    val tokensClosed = mulDivDown(posSizeInTokens.get(trader), sizeDeltaUsd, posSizeUsd.get(trader))
    val newSize = posSizeUsd.get(trader) - sizeDeltaUsd
    val newTokens = posSizeInTokens.get(trader) - tokensClosed
    val newColl = posCollateral.get(trader) - poolDelta + pnlTokens
    all {
      newColl >= 0,
      poolAmount + poolDelta - pnlTokens >= impactPool + poolDelta,
      newSize == 0 or not(isPositionLiquidatableAt(newSize, newTokens, newColl, isLong, markPrice)),
      posSizeUsd' = posSizeUsd.put(trader, newSize),
      posSizeInTokens' = posSizeInTokens.put(trader, newTokens),
      posCollateral' = posCollateral.put(trader, newColl),
      posIsLong' = posIsLong.put(trader, isLong),
      longOI' = nextL,
      shortOI' = nextS,
      impactPool' = impactPool + poolDelta,
      poolAmount' = poolAmount + poolDelta - pnlTokens,
      totalDeposited' = totalDeposited,
      markPrice' = markPrice,
      lastOp' = OP_DECREASE,
      lastImpactUsd' = capped,
    }
  }

  /// LiquidationHandler.executeLiquidation.  The residual collateral goes to
  /// `poolAmount` — `MarketUtils.applyDeltaToPoolAmount`, the LP balance.  v1 wrote
  /// it to `impactPool` (gmx.qnt:140), which is the wrong pool and is the only write
  /// that variable ever received.
  action liquidatePosition(trader: str): bool = all {
    TRADERS.contains(trader),
    liquidatableNow(trader),
    val isLong = posIsLong.get(trader)
    val closedSize = posSizeUsd.get(trader)
    val residue = posCollateral.get(trader)
    all {
      posSizeUsd' = posSizeUsd.put(trader, INIT_SIZE),
      posSizeInTokens' = posSizeInTokens.put(trader, INIT_SIZE),
      posCollateral' = posCollateral.put(trader, INIT_SIZE),
      posIsLong' = posIsLong.put(trader, INIT_IS_LONG),
      longOI' = if (isLong) nextOpenInterest(longOI, 0 - closedSize) else longOI,
      shortOI' = if (isLong) shortOI else nextOpenInterest(shortOI, 0 - closedSize),
      poolAmount' = poolAmount + residue,
      impactPool' = impactPool,
      totalDeposited' = totalDeposited,
      markPrice' = markPrice,
      lastOp' = OP_LIQUIDATE,
      lastImpactUsd' = INIT_IMPACT_USD,
    }
  }

  /// oracle.getPrimaryPrice(indexToken) — an external read, foot(Q) = 0.
  action setMarkPrice(p: int): bool = all {
    p > 0,
    p != markPrice,
    markPrice' = p,
    posSizeUsd' = posSizeUsd,
    posSizeInTokens' = posSizeInTokens,
    posCollateral' = posCollateral,
    posIsLong' = posIsLong,
    longOI' = longOI,
    shortOI' = shortOI,
    impactPool' = impactPool,
    poolAmount' = poolAmount,
    totalDeposited' = totalDeposited,
    lastOp' = OP_PRICE,
    lastImpactUsd' = INIT_IMPACT_USD,
  }

  /// Convention 6 / 6g: every `nondet` is exogenous — an order field or an oracle
  /// return.  The IMPACT is not among them: it is computed from `longOI`, `shortOI`
  /// and the order size, which is the dependency v1 had no quantity to carry.
  action step: bool = {
    nondet orderAccount = TRADERS.oneOf()
    nondet sizeDelta = SIZE_DELTAS.oneOf()
    nondet isLong = SIDES.oneOf()
    nondet collAmt = COLLATERAL_AMOUNTS.oneOf()
    nondet price = MARK_PRICES.oneOf()
    any {
      depositCollateral(orderAccount, collAmt),
      withdrawCollateral(orderAccount, collAmt),
      increasePosition(orderAccount, isLong, sizeDelta),
      decreasePosition(orderAccount, sizeDelta),
      liquidatePosition(T1),
      liquidatePosition(T2),
      setMarkPrice(price),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — index tokens are neither created nor destroyed.  Every token in
  /// the market is either LP-owned (`poolAmount`, of which `impactPool` is a
  /// sub-balance, MarketUtils.sol:1085-1130) or a trader's collateral, and the total
  /// moves only by deposits and withdrawals.  This is the T2 command's invariant,
  /// and it is reported for the reason the pilot reported its own: it holds under
  /// the linearised mutant too, so it is evidence of nothing about the mechanism.
  val inv_conservation: bool =
    poolAmount + TRADERS.fold(0, (acc, t) => acc + posCollateral.get(t))
      == INIT_POOL_AMOUNT + totalDeposited

  val inv_bounds: bool = and {
    longOI >= 0,
    shortOI >= 0,
    poolAmount >= 0,
    markPrice > 0,
    TRADERS.forall(t => posSizeUsd.get(t) >= 0),
    TRADERS.forall(t => posSizeInTokens.get(t) >= 0),
    TRADERS.forall(t => posCollateral.get(t) >= 0),
  }

  /// NOTE on `totalDeposited`: it is NET collateral flow and may be negative once a
  /// trader withdraws realised profit, so it carries no sign bound.  It is read by
  /// `inv_conservation`, which is the property it exists for.

  /// T3 for this protocol, half one (P2-SCOPE §5 row 7, `inv_impactSign`): the pool
  /// is never negative and never exceeds the balance backing it.  Both halves are
  /// consequences of `capPositiveImpact`, which v1 has no occasion to state because
  /// nothing ever pays out of the pool.
  val inv_impactPoolBacked: bool = and {
    impactPool >= 0,
    impactPool <= poolAmount,
  }

  /// Open interest matches the positions that carry it.
  val inv_oiMatchesPositions: bool = and {
    TRADERS.fold(0, (acc, t) => if (posIsLong.get(t)) acc + posSizeUsd.get(t) else acc)
      == longOI,
    TRADERS.fold(0, (acc, t) => if (posIsLong.get(t)) acc else acc + posSizeUsd.get(t))
      == shortOI,
  }

  /// `validateReserve` is a real bound: open interest is covered by the pool at the
  /// configured reserve factor at the moment every order is accepted.  v1's version
  /// of this line dropped `reserveFactor`, so its bound was 2.5x looser.
  val inv_reserveFactorLive: bool = RESERVE_FACTOR < FLOAT_PRECISION

  /// T3 for this protocol, half two, and THE INVARIANT THAT KILLS THE MUTANT.
  /// CONVEXITY, stated over the declared imbalance domain: equal steps of the
  /// imbalance cost strictly MORE the further out they start.  Every linear impact
  /// function makes the two sides equal and violates it.  Evaluated at the live
  /// market configuration rather than at constants.
  val inv_impactConvex: bool = and {
    impactSameSide(30000, 20000) > impactSameSide(20000, 10000),
    impactSameSide(20000, 10000) > impactSameSide(10000, 0),
    applyImpactFactor(40000, NEGATIVE_IMPACT_FACTOR, NEGATIVE_IMPACT_EXPONENT)
      > 2 * applyImpactFactor(20000, NEGATIVE_IMPACT_FACTOR, NEGATIVE_IMPACT_EXPONENT),
  }

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_impactPoolBacked,
    inv_oiMatchesPositions,
    inv_reserveFactorLive,
    inv_impactConvex,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (§D, the fifth trap).
  //  Each of these must be VIOLATED by `quint run --invariant=<name>`.
  // ===========================================================================

  pure val T0_LIVE_LONG_OI: int = 30000
  pure val T0_LIVE_SHORT_OI: int = 10000
  pure val T0_LIVE_IMPACT: int = 250
  pure val T0_LIVE_POOL: int = 20

  /// T0-LIVE for this protocol: `sameSide(30000, 20000) = +250`, as a TRACE.
  /// The pool was filled to 45 tokens by the charge for opening 30000 of long
  /// against nothing, and the 10000 short that narrowed the imbalance from 30000 to
  /// 20000 was rebated exactly 250 USD, i.e. 25 tokens.  Under the linearised
  /// mutant the same two orders give a charge of 150 and a rebate of 50, so the
  /// pool holds 10 and `lastImpactUsd` is 50 — this state is unreachable, which is
  /// exactly how a value-level equality becomes a mechanism check.
  val wit_live_convexImpact: bool =
    not(and {
      longOI == T0_LIVE_LONG_OI,
      shortOI == T0_LIVE_SHORT_OI,
      lastImpactUsd == T0_LIVE_IMPACT,
      impactPool == T0_LIVE_POOL,
      markPrice == INIT_MARK_PRICE,
    })

  /// `impactUsd` ran and CHARGED: the pool holds tokens that only a negative price
  /// impact can have put there.  Tag-free — under v1 the pool is fed by liquidation
  /// residue and by nothing else, which is contrast member M3.
  val wit_used_impactUsd: bool = impactPool == 0

  /// `capPositiveImpact` ran on the REBATE side: the pool paid out, so it fell
  /// while open interest was still open.
  val wit_used_capPositiveImpact: bool =
    not(and { lastImpactUsd > 0, impactPool > 0, longOI > 0, shortOI > 0 })

  /// 6f: the cap BOUND — a rebate was clipped to what the pool could pay.
  val wit_branch_capBinds: bool =
    not(and { lastImpactUsd > 0, impactPool == 0 })

  /// 6f: the sub-FLOAT_PRECISION cliff (Precision.sol:92-94) decided a real order:
  /// open interest moved and the impact was exactly zero.
  val wit_branch_impactCliff: bool =
    not(and { lastOp == OP_INCREASE, lastImpactUsd == 0, longOI + shortOI > 0 })

  /// 6f: the CROSSOVER branch (PositionPricingUtils.sol:209) decided an order — the
  /// imbalance changed sides.  Member M4 of the contrast set gets exactly this
  /// transition wrong.
  val wit_branch_crossover: bool =
    not(and { lastImpactUsd == -450, longOI == 30000, shortOI == 0 })

  /// 6f: the SAME-SIDE branch decided an order and the balance WORSENED, so the
  /// sign rule produced a charge on a side that was already dominant.
  val wit_branch_sameSideWorsened: bool =
    not(and { lastOp == OP_INCREASE, lastImpactUsd < 0, longOI > 0, shortOI > 0 })

  /// `maxReservedUsd` ran and BOUND: open interest sits above the bound v1's
  /// factor-free version would have imposed, and below the real one.
  val wit_used_maxReservedUsd: bool =
    not(and {
      longOI + shortOI > maxReservedUsd(poolAmount, markPrice),
      poolAmount * markPrice > longOI + shortOI,
    })

  /// `positionPnlUsd` ran with a real profit or loss on an open position.
  val wit_used_positionPnlUsd: bool =
    not(TRADERS.exists(t => and { posSizeUsd.get(t) > 0, pnlOf(t) != 0 }))

  /// `nextOpenInterest`'s clamp and the decrease path: open interest returned to
  /// zero after having been positive.
  val wit_used_nextOpenInterest: bool =
    not(and { lastOp == OP_DECREASE, longOI == 0, shortOI == 0 })

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_depositCollateral: bool = lastOp != OP_DEPOSIT
  val wit_fired_withdrawCollateral: bool = lastOp != OP_WITHDRAW
  val wit_fired_increasePosition: bool = lastOp != OP_INCREASE
  val wit_fired_decreasePosition: bool = lastOp != OP_DECREASE
  val wit_fired_liquidatePosition: bool = lastOp != OP_LIQUIDATE
  val wit_fired_setMarkPrice: bool = lastOp != OP_PRICE
}
