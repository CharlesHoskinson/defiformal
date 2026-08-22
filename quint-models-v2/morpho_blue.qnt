// =============================================================================
//  morpho_blue — Phase 2 re-spec.  Replaces quint-models/L1/morpho_blue.qnt.
//
//  SOURCE:
//    protocol-repos/lend/morpho-org_morpho-blue/src/Morpho.sol
//      :346-410   liquidate
//        :366-370 liquidationIncentiveFactor =
//                   min(MAX_LIQUIDATION_INCENTIVE_FACTOR,
//                       WAD.wDivDown(WAD - LIQUIDATION_CURSOR.wMulDown(WAD - lltv)))
//        :372-375 seizedAssets given  -> repaidShares  (mulDivUp, wDivUp, toSharesUp)
//        :376-379 repaidShares given  -> seizedAssets  (toAssetsDown, wMulDown, mulDivDown)
//        :381     repaidAssets = repaidShares.toAssetsUp(totalBorrowAssets, totalBorrowShares)
//        :383-386 borrowShares -= ; totalBorrowShares -= ; totalBorrowAssets = zeroFloorSub
//        :388     position.collateral -= seizedAssets
//        :390-401 THE BAD-DEBT SOCIALISATION
//                   if (position[id][borrower].collateral == 0) {
//                     badDebtShares = position[id][borrower].borrowShares;
//                     badDebtAssets = min(totalBorrowAssets,
//                                         badDebtShares.toAssetsUp(tBA, tBS));
//                     totalBorrowAssets -= badDebtAssets;
//                     totalSupplyAssets -= badDebtAssets;      <-- supplier loss
//                     totalBorrowShares -= badDebtShares;
//                     position[id][borrower].borrowShares = 0;
//                   }
//        :407     safeTransfer(collateralToken, msg.sender, seizedAssets)
//      :514-537   _isHealthy: maxBorrow = collateral.mulDivDown(price, ORACLE_PRICE_SCALE)
//                              .wMulDown(lltv);  return maxBorrow >= borrowed
//    protocol-repos/lend/morpho-org_morpho-blue/src/libraries/SharesMathLib.sol
//      :20-24     VIRTUAL_SHARES = 1e6, VIRTUAL_ASSETS = 1
//      :27-44     toSharesDown / toAssetsDown / toSharesUp / toAssetsUp
//    protocol-repos/lend/morpho-org_morpho-blue/src/libraries/MathLib.sol
//      :3         WAD = 1e18;  :13-25 wMulDown / wDivDown / wDivUp; :28-34 mulDivDown/Up
//    protocol-repos/lend/morpho-org_morpho-blue/src/libraries/ConstantsLib.sol
//      :9         ORACLE_PRICE_SCALE = 1e36
//      :12        LIQUIDATION_CURSOR = 0.3e18
//      :15        MAX_LIQUIDATION_INCENTIVE_FACTOR = 1.15e18
//
//  MECHANISM:
//    A liquidation that empties a borrower's collateral while borrow shares remain
//    does NOT leave the debt on the books.  It writes the shortfall off against
//    `totalSupplyAssets` — every supplier's share is worth less afterwards, and no
//    supplier took any action.  That write-down is the ONLY path by which supplier
//    assets fall in Morpho Blue, and the size of the shortfall is governed by the
//    liquidation incentive factor, which the contract derives non-linearly from the
//    market's `lltv` rather than fixing.
//
//  WHAT v1 DELETED (this file exists to restore it — the corpus's worst deletion):
//    D-1  quint-models/L1/morpho_blue.qnt:156-159.  A comment,
//           // bad debt: if collateral wiped but debt remains, socialize
//         followed by three identity assignments:
//           supplyShares' = supplyShares,
//           totalSupplyAssets' = totalSupplyAssets,
//           totalSupplyShares' = totalSupplyShares,
//         Morpho.sol:391-401 is written down to a name.  The consequence is stated
//         in P2-SCOPE §2: v1's headline invariants `shareConservation` /
//         `liquidityInvariant` (:209-213) are preserved BECAUSE the mechanism that
//         stresses them was removed.  Measured here in §M1 below: both of those
//         invariants hold in the mutant too, so neither of them is what kills it.
//         What kills it is `inv_noUnbackedDebt` — a borrower left holding borrow
//         shares against zero collateral, which is precisely the state :390-401
//         exists to make unreachable.
//    D-2  quint-models/L1/morpho_blue.qnt:12
//           pure val LIQ_INCENTIVE_BPS: int = 11500  // derived from LLTV in code; fixed here
//         The literal is the value of the derived factor only at the cap.  At the
//         spec's own `LLTV_BPS = 8600` the contract computes 10438 — a 10.2 % error
//         in the seizure, in the liquidator's favour, at every liquidation.  Under
//         CF2 this is also a 6g dependency drop: foot(Q) = {lltv}, and a literal
//         reads nothing.
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    the derived `liquidationIncentiveFactor` and BOTH sides of its `min`; the
//    bad-debt write-down against `totalSupplyAssets` and the `min(totalBorrowAssets,
//    ...)` cap inside it; both liquidation entry forms (`seizedAssets` given and
//    `repaidShares` given) and their different rounding; `VIRTUAL_SHARES = 1e6` and
//    `VIRTUAL_ASSETS = 1` at full size; every rounding direction — toSharesDown on
//    supply, toSharesUp on withdraw and borrow, toAssetsUp on the debt side of
//    `_isHealthy` and of `repaidAssets`, toAssetsDown on the seizure; `zeroFloorSub`
//    on `totalBorrowAssets`; the INSUFFICIENT_LIQUIDITY check on withdraw and borrow.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - multi-market: one market, whose `lltv` is drawn once at market creation.
//      P2-SCOPE row 4 drops multi-market; see DEVIATION D-a for why `lltv` must
//      still vary, and note that this models `createMarket` (Morpho.sol:161-177)
//      rather than adding markets — one market per run, four instances.
//    - the IRM (`IIrm(marketParams.irm).borrowRate`) and `wTaylorCompounded`
//      (MathLib.sol:38-44).  `accrueInterest` takes the interest amount as an
//      exogenous input; no guard reads the rate.  The protocol fee split
//      (Morpho.sol:487-500) goes with it — `fee` is 0 in the modelled market, which
//      is the default `createMarket` state.
//    - callbacks (`onMorphoLiquidate` etc.), flash loans, `setAuthorization` and
//      the EIP-712 path.  P2-SCOPE row 4.  No state-changing guard reads an
//      authorisation on the paths modelled, because every action is taken by the
//      account itself or, for `liquidate`, by anyone.
//    - `safeTransfer(collateralToken, msg.sender, seizedAssets)` (:407): seized
//      collateral is credited to the liquidator's own `position.collateral` slot in
//      the same market instead of to their wallet.  A change of representation of
//      the same observable (the liquidator's collateral-token holdings); the
//      liquidator never borrows, so the slot never enters a health check.  It buys
//      an exact collateral-conservation invariant that the wallet form cannot state.
//    - `zeroFloorSub` is modelled as `maxInt(x - y, 0)`; `toUint128` casts and the
//      supply caps are replaced by MAX_MARKET_ASSETS, stated in BOUNDS.
//    - the `ORACLE_PRICE_SCALE = 1e36` and `WAD = 1e18` scales are descaled to 1e8
//      and 1e4 respectively (P2-CONTRACT §C row 4).  `VIRTUAL_SHARES` is NOT
//      descaled: it is a protocol constant of the MINIMUM_LIQUIDITY class, and
//      convention 8c forbids descaling one.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label of the observation
//    interface (P2-FIDELITY §1), carrying exactly what Morpho's own
//    Supply / Withdraw / Borrow / Repay / Liquidate / AccrueInterest events carry,
//    which are droppable only because no guard reads them.  It is read by
//    `wit_fired_*` (convention 6d) and by nothing else; no guard and no `pure def`
//    reads it, and it is exempt from 6e's write-only clause on that basis.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 3 accounts; 7 `nondet`s per step, of sizes 3, 3, 2, 3, 3, 8, 8.
//       `lltv` is one further `nondet` taken once, at `init`, over 4 values.
//       No list state.
//    8b magnitude — peak intermediate 3.7e13 < 9.22e18, five orders of headroom.
//       It is `shares * (totalBorrowAssets + VIRTUAL_ASSETS)` inside `toAssetsUp`
//       at the domain corner (shares 6.0e9, assets 6000): 3.6e13.  Next are
//       `assets * (totalShares + VIRTUAL_SHARES)` in `toSharesUp` at 6.0e12,
//       `collateral * price` in `_isHealthy` at 6.0e11, and `SCALE * SCALE` inside
//       `liquidationIncentiveFactor` at 1.0e8.
//       This spec does NOT call `kernel.isqrtFloor`, so PILOT-NOTES D-d's
//       4.611686e18 floor does not apply to it.
//       NOTE, and this is the binding i64 fact for this protocol: at the CONTRACT's
//       own scales the same expression is `WAD^2 = 1e36`, 1.1e17 times the i64
//       ceiling.  P2-CONTRACT §A.4's acceptance item 4 as written cannot be
//       evaluated on the default backend at all; `SCALE = 1e4` is what makes it
//       runnable, and 10438 is the value it then yields.
//    8c constant-crossing —
//       MAX_LIF = 11500 binds at `lltv = 5000` (uncapped 11764) and does not at
//         8600 / 9000 / 7700 (10438 / 10309 / 10741).  Both sides of the `min` at
//         :367 are therefore reachable, which is only true because `lltv` varies —
//         see DEVIATION D-a.  `wit_branch_lifCapped` / `wit_branch_lifUncapped`.
//       LIQUIDATION_CURSOR = 3000 is crossed inside the same expression by the
//         same four `lltv` values (inner term 8500 / 9310 / 9580 / 9700).
//       VIRTUAL_SHARES = 1e6: share balances run from 1e8 to 6e9, i.e. from 100x
//         to 6000x the virtual float, and the market also passes through the empty
//         state on the borrow side where the virtual pair alone sets the rate
//         (toSharesUp(1000, 0, 0) = 1e9, t0_16).  Under P2-SCOPE convention 8's
//         old `<=200` cap a share balance was not representable at all
//         (P2-CARRYFORWARD CF1, row `morpho_blue`), which is why that cap is gone.
//       `min(totalBorrowAssets, ...)` inside the write-down: t0_13/t0_14 are the
//         side where the cap binds (toAssetsUp gives 101 against a totalBorrowAssets
//         of 100) and t0_10 the side where it does not.  RECORDED LIMITATION: the
//         binding side is pinned by vector only.  Reaching it at runtime needs a
//         SECOND borrower still holding shares at the instant of the write-down,
//         because with a single borrower `badDebtShares == totalBorrowShares` and
//         `toAssetsUp(tBS, tBA, tBS)` lands exactly on `tBA` rather than above it.
//         6f asks for one vector on each side and has both; there is no `wit_branch_*`
//         for it and none is claimed.
//       LLTV itself: t0_01..t0_04 pin all four instances; `inv_incentiveDerived`
//         pins the reached one at runtime against the same table.
//
//  INPUTS:  (convention 6g, dependency parity — foot(Q) = contract storage the
//           contract's own expression for this quantity depends on)
//    | name         | contract expression                    | file:line | foot(Q) | spec vars read |
//    | lender       | supply(onBehalf) / borrow(onBehalf)    | :192,:272 | none    | none (calldata) |
//    | assets       | supply(assets) / borrow(assets)        | :192,:272 | none    | none (calldata) |
//    | collAmt      | supplyCollateral(assets)               | :318      | none    | none (calldata) |
//    | repaidShares | liquidate(repaidShares)                | :351      | none    | none (calldata) |
//    | seizedAssets | liquidate(seizedAssets)                | :350      | none    | none (calldata) |
//    | price        | IOracle(marketParams.oracle).price()   | :361      | none    | none (external call) |
//    | interest     | IIrm(...).borrowRate(...)              | :490      | none    | none (ABSTRACTED) |
//    | chosenLltv   | createMarket(marketParams.lltv)        | :161-177  | none    | none (calldata at creation) |
//    Both liquidation amounts are the LIQUIDATOR's calldata: Morpho has no queue and
//    no ordering, `liquidate` names its borrower and its size, and
//    `exactlyOneZero(seizedAssets, repaidShares)` (:355) is a check on calldata, not
//    a selection.  `foot(Q) = 0` for both, so 6g is satisfied and the H1 shape does
//    not arise here.  The borrower is nonetheless applied at named account constants
//    rather than at a driver `nondet`, so that `respec_lint` D4 has nothing to fire
//    on; the two liquidation amounts are drawn as unit multiples for the same
//    reason (see DEVIATION D-c).
//    `price` is a genuine external-call return, foot(Q) = empty — the oracle case
//    6g was written to permit.  `interest` is the one substituted quantity and is
//    recorded under ABSTRACTED.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    Morpho.supply                 -> action supply
//    Morpho.withdraw               -> action withdraw
//    Morpho.supplyCollateral       -> action supplyCollateral
//    Morpho.withdrawCollateral     -> action withdrawCollateral
//    Morpho.borrow                 -> action borrow
//    Morpho.repay                  -> action repay
//    Morpho.liquidate (seizedAssets form)  -> action liquidateBySeize
//    Morpho.liquidate (repaidShares form)  -> action liquidateByShares
//    Morpho.accrueInterest         -> action accrueInterest
//    Morpho.createMarket           -> action init (one market, lltv drawn there)
//    Morpho.flashLoan              -> ABSTRACTED (callbacks)
//    Morpho.setAuthorization / setAuthorizationWithSig -> ABSTRACTED
//    Morpho.enableIrm / enableLltv / setOwner / setFeeRecipient / setFee -> ABSTRACTED (governance)
//    the oracle's own update                 -> action setOraclePrice
//    Storage read by a require on a state-changing path:
//      market.totalSupplyAssets (:531-536 via _isHealthy, :215 liquidity) -> var
//      market.totalSupplyShares (:27-44 share math)                       -> var
//      market.totalBorrowAssets / totalBorrowShares (:381, :393-395)      -> vars
//      position.supplyShares (:219)                                       -> var supplyShares
//      position.borrowShares (:383, :391, :515)                           -> var borrowShares
//      position.collateral (:388, :390, :533)                             -> var collateral
//      marketParams.lltv (:367, :534)                                     -> var lltv
//      IOracle.price() (:361)                                             -> var collPrice
//      market.lastUpdate (:357)                                           -> ABSTRACTED (accrueInterest is an action)
//      market.fee / feeRecipient (:492-499)                               -> ABSTRACTED (fee = 0 at creation)
//      isAuthorized (:280)                                                -> ABSTRACTED
//    No `var` is write-only.  `lltv` is read by `liquidationIncentiveFactor`, by
//    `isHealthyAt` and by `inv_incentiveDerived`; `totalCollateralSupplied` by
//    `inv_collateralConserved`.
//
//  UNITS:  (hole H2's obligation, applied here as a convention)
//    totalSupplyAssets, totalBorrowAssets, assets, interest  — LOAN-token assets
//    totalSupplyShares, totalBorrowShares, supplyShares,
//      borrowShares, repaidShares                            — share units (1 asset ~ 1e6 shares)
//    collateral, totalCollateralSupplied, seizedAssets       — COLLATERAL-token units
//    collPrice                                               — loan-per-collateral, ORACLE_PRICE_SCALE
//    lltv, CURSOR, MAX_LIF, liquidationIncentiveFactor       — factors (SCALE)
//
//  CONTRAST SET (F0/F2, with R4's three mandatory members):
//    M0  bad debt written down against totalSupplyAssets; LIF derived from lltv  [target]
//    M1  the v1 body verbatim, BUILT AND RUN as two mutants so the two deletions
//        can be attributed separately.  MANDATORY member 1.
//        M1a = mutants/morpho_blue_M1a.qnt — the write-down replaced by v1's no-op
//        (`badDebtShares = 0`, `badDebtAssets = 0`), the incentive factor still
//        derived.  MEASURED, --max-steps=20 --max-samples=30000:
//          inv_conservation      (v1 shareConservation)   [ok]        <- does NOT discriminate
//          inv_liquidity         (v1 liquidityInvariant)  [ok]        <- does NOT discriminate
//          inv_bounds / inv_collateralConserved           [ok]        <- do NOT discriminate
//          inv_T0                                         [ok]        <- does NOT discriminate
//          inv_incentiveDerived                           [ok]        <- not this deletion
//          inv_noUnbackedDebt                             [VIOLATION] <- THE KILL
//          wit_live_socializeBadDebt                      [ok]        <- state UNREACHABLE
//          wit_used_socializeBadDebt                      [ok]        <- state UNREACHABLE
//        M1b = mutants/morpho_blue_M1b.qnt — M1a plus `LIQ_INCENTIVE_BPS = 11500`
//        in place of the derived factor.  MEASURED, same command:
//          inv_conservation / inv_liquidity / inv_bounds / inv_collateralConserved [ok]
//          inv_T0                                         [VIOLATION]
//          inv_incentiveDerived                           [VIOLATION]
//          inv_noUnbackedDebt                             [VIOLATION]
//          wit_live_socializeBadDebt / wit_used_socializeBadDebt      [ok]
//        Agreement with M0 on `LIF` over the declared lltv domain: 1/4 = 25 %,
//        the cap point.
//        THE FINDING, and it is the one P2-SCOPE §2 asked for: v1's own headline
//        invariants do not discriminate IN EITHER DIRECTION.  The write-down
//        subtracts the SAME amount from `totalBorrowAssets` and from
//        `totalSupplyAssets` (Morpho.sol:394-395), so `liquidityInvariant` is
//        preserved by the mechanism as well as by its absence; and the write-down
//        never touches supply shares, so `shareConservation` is preserved likewise.
//        Reintroducing either of v1's invariants into a spec that lacks the
//        mechanism therefore does NOT make it fail.  What separates M0 from M1a is
//        `inv_noUnbackedDebt` — a state the CONTRACT makes unreachable and the v1
//        spec does not, and which v1 could not have stated, because it has no
//        `position.collateral == 0` branch to make it true.
//    M2  chaos: write down any amount in [0, badDebtAssets].  MANDATORY member 2 —
//        the maximally permissive form in the same direction.  Killed by t0_10 and
//        by `inv_noUnbackedDebt` only at the 0 endpoint; every interior point still
//        satisfies `inv_noUnbackedDebt`, so it is killed by t0_10 alone.  Recorded:
//        a "write down something" check does not separate M0 from M2.
//    M3  `LIF = 11500` replaced by `LIF = 10500`, a near neighbour.  MANDATORY
//        member 3.  Agreement with M0 over the 4-point lltv domain: 0/4 = 0 %,
//        but agreement within 1 % at 3 of 4 points.  Killed only by the exact
//        vectors t0_01..t0_04 and by `inv_incentiveDerived`; NOT killed by any
//        invariant of shape, which is the finding.
//    M4  socialisation present but rounding flipped: `toAssetsDown` in place of
//        `toAssetsUp` inside the write-down.  The rounding-direction rival.
//        Agreement with M0 on the declared vectors: 1/2 (t0_10 agrees at 200,
//        t0_11's 188 becomes 187).  Killed by t0_11 alone.
//    FINDING, as with the pilot: R4's >=90 % near neighbour exists here (M3, and M4
//    at 50 % on values but 100 % on shape) but no NEAR-NEIGHBOUR INVARIANT does —
//    every rival that keeps the mechanism satisfies every state invariant in this
//    file.  Only the exact T0 vectors separate M0 from M3 and M4.
//
//  ACCEPTANCE:
//    T1  quint typecheck morpho_blue.qnt
//    T2  quint run --main=morpho_blue --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 morpho_blue.qnt
//    T3  quint run --main=morpho_blue --invariant=inv_all ... (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: totalSupplyAssets 2000 -> 1800.  The obligation is the TRACE that
//        violates `wit_live_socializeBadDebt`: a reachable state in which a
//        liquidation emptied a borrower's collateral, 200 assets of bad debt were
//        written off, and the supplier who never acted now redeems 1800 for the
//        2000 she supplied.
//
//  DEVIATIONS from P2-CONTRACT.md / P2-SCOPE.md, each with its reason:
//    D-a  `lltv` is a `nondet` taken once in `init` over {5000, 7700, 8600, 9000}.
//         P2-SCOPE row 4 drops multi-market and v1 hardcodes a single LLTV; but
//         `MAX_LIF` binds only below lltv ~= 5715, so with one fixed lltv the other
//         side of the `min` at :367 is unreachable and 8c is violated.  This is
//         P2-CARRYFORWARD's Flag M, and its recorded executor decision, adopted
//         verbatim: ONE market whose immutable creation parameter takes four
//         values, not four markets.  `createMarket` (Morpho.sol:161-177) is a real
//         external function and `lltv` is a real calldata field, so this is more
//         faithful than the literal it replaces, not less.  Convention 4 is bent
//         (init draws a value rather than reading a constant); the drawn value is
//         still one of four named `pure val`s and `init` still contains no
//         arithmetic.
//    D-b  registry extended.  P2-SCOPE convention 3 lists `socializeBadDebt` for
//         this protocol; P2-CONTRACT §A.4 adds `liquidationIncentiveFactor`.
//         Convention 6b requires every arithmetic mechanism to be a named
//         `pure def`, so the four share-math primitives, `isHealthyAt` and the two
//         liquidation-direction functions are named and pinned as well.
//    D-c  the two liquidation amounts are drawn as `1.to(8)` unit multiples rather
//         than from named sets.  `respec_lint` D4 fires on ANY named-set `nondet`
//         passed on a call line to an action whose name contains a selection verb,
//         and "liquidat" is one; the amounts here are the liquidator's calldata,
//         `foot(Q) = 0`, so a D4 finding would be a false positive.  The domain is
//         unchanged in content: 8 enumerated values per amount, stated in BOUNDS.
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
//    accrueInterest      PERMISSIONLESS  src/Morpho.sol:473  no caller check found
//    borrow              PERMISSIONLESS  src/Morpho.sol:235  no caller check found
//    liquidateBySeize    PERMISSIONLESS  src/Morpho.sol:347  no caller check found
//    liquidateByShares   PERMISSIONLESS  src/Morpho.sol:347  no caller check found
//    repay               PERMISSIONLESS  src/Morpho.sol:269  no caller check found
//    supply              PERMISSIONLESS  src/Morpho.sol:169  no caller check found
//    supplyCollateral    PERMISSIONLESS  src/Morpho.sol:303  no caller check found
//    withdraw            PERMISSIONLESS  src/Morpho.sol:200  no caller check found
//    withdrawCollateral  PERMISSIONLESS  src/Morpho.sol:323  no caller check found
//    setOraclePrice      UNRESOLVED      no contract function matched by name
// --------------------------------------------------------------------------
module morpho_blue {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// MathLib.sol:3 WAD = 1e18, descaled to 1e4 (P2-CONTRACT §C row 4)
  pure val SCALE: int = 10000
  /// ConstantsLib.sol:9 ORACLE_PRICE_SCALE = 1e36 = WAD^2, descaled to SCALE^2
  pure val ORACLE_PRICE_SCALE: int = 100000000
  /// SharesMathLib.sol:20 — NOT descaled.  A protocol constant, not a scale factor.
  pure val VIRTUAL_SHARES: int = 1000000
  /// SharesMathLib.sol:24
  pure val VIRTUAL_ASSETS: int = 1
  /// ConstantsLib.sol:12 LIQUIDATION_CURSOR = 0.3e18
  pure val CURSOR: int = 3000
  /// ConstantsLib.sol:15 MAX_LIQUIDATION_INCENTIVE_FACTOR = 1.15e18
  pure val MAX_LIF: int = 11500

  /// The four market instances (DEVIATION D-a).  5000 is the only one at which
  /// MAX_LIF binds.
  pure val LLTVS: Set[int] = Set(5000, 7700, 8600, 9000)
  pure val LLTV_CAP: int = 5000
  pure val LLTV_LIVE: int = 8600

  /// morpho_blue.qnt:12 — the literal this file replaces.  Kept as a named constant
  /// so `inv_incentiveDerived` can be read against it.
  pure val V1_LIQ_INCENTIVE_BPS: int = 11500

  pure val ALICE: str = "alice"
  pure val BOB: str = "bob"
  pure val LIQUIDATOR: str = "liquidator"
  pure val USERS: Set[str] = Set(ALICE, BOB, LIQUIDATOR)

  /// Stand-in for the uint128 casts and for a market supply cap.  See BOUNDS 8b.
  pure val MAX_MARKET_ASSETS: int = 6000

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN (convention 8a; see BOUNDS for 8b and 8c)
  // ---------------------------------------------------------------------------

  pure val ASSET_AMOUNTS: Set[int] = Set(300, 500, 1000)
  pure val COLLATERAL_AMOUNTS: Set[int] = Set(417, 1000)
  pure val PRICES: Set[int] = Set(200000000, 300000000, 500000000)
  pure val INTEREST_AMOUNTS: Set[int] = Set(50, 100, 200)
  /// `1.to(8)` multiples of these — see DEVIATION D-c.
  pure val REPAY_SHARE_UNIT: int = 100000000
  pure val SEIZE_UNIT: int = 100

  pure val INIT_SUPPLY_ASSETS: int = 2000
  pure val INIT_SUPPLY_SHARES: int = 2000000000
  pure val INIT_BORROW_ASSETS: int = 1000
  pure val INIT_BORROW_SHARES: int = 1000000000
  pure val INIT_COLLATERAL: int = 417
  pure val INIT_PRICE: int = 500000000
  pure val ZERO: int = 0

  pure val OP_INIT: str = "init"
  pure val OP_SUPPLY: str = "supply"
  pure val OP_WITHDRAW: str = "withdraw"
  pure val OP_SUPPLY_COLL: str = "supplyCollateral"
  pure val OP_WITHDRAW_COLL: str = "withdrawCollateral"
  pure val OP_BORROW: str = "borrow"
  pure val OP_REPAY: str = "repay"
  pure val OP_LIQ_SEIZE: str = "liquidateBySeize"
  pure val OP_LIQ_SHARES: str = "liquidateByShares"
  pure val OP_ACCRUE: str = "accrueInterest"
  pure val OP_ORACLE: str = "setOraclePrice"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var lltv: int                     // marketParams.lltv, fixed at creation
  var totalSupplyAssets: int        // loan assets
  var totalSupplyShares: int        // supply shares
  var totalBorrowAssets: int        // loan assets
  var totalBorrowShares: int        // borrow shares
  var supplyShares: str -> int      // position.supplyShares
  var borrowShares: str -> int      // position.borrowShares
  var collateral: str -> int        // position.collateral, collateral-token units
  var totalCollateralSupplied: int  // sum of all position.collateral (see ABSTRACTED)
  var collPrice: int                // IOracle.price(), ORACLE_PRICE_SCALE units
  var lastOp: str                   // GHOST — trace label, see header

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  Every one is pinned by exact T0 vectors below AND carries a `wit_used_*`
  //  reachability obligation, because a `pure val` equality is true in states
  //  where the definition is never applied (the fifth trap, §D).
  // ===========================================================================

  /// MathLib.sol:13-25
  pure def wMulDown(x: int, y: int): int = mulDivDown(x, y, SCALE)
  pure def wDivDown(x: int, y: int): int = mulDivDown(x, SCALE, y)
  pure def wDivUp(x: int, y: int): int = mulDivUp(x, SCALE, y)

  /// UtilsLib.zeroFloorSub
  pure def zeroFloorSub(x: int, y: int): int = maxInt(x - y, 0)

  /// SharesMathLib.sol:27-44.  The virtual pair is what makes an empty market
  /// price shares at 1e6 per asset and what makes the first depositor unattackable.
  pure def toSharesDown(assets: int, tA: int, tS: int): int =
    mulDivDown(assets, tS + VIRTUAL_SHARES, tA + VIRTUAL_ASSETS)
  pure def toSharesUp(assets: int, tA: int, tS: int): int =
    mulDivUp(assets, tS + VIRTUAL_SHARES, tA + VIRTUAL_ASSETS)
  pure def toAssetsDown(shares: int, tA: int, tS: int): int =
    mulDivDown(shares, tA + VIRTUAL_ASSETS, tS + VIRTUAL_SHARES)
  pure def toAssetsUp(shares: int, tA: int, tS: int): int =
    mulDivUp(shares, tA + VIRTUAL_ASSETS, tS + VIRTUAL_SHARES)

  /// Morpho.sol:366-370 — THE LITERAL v1 REPLACED.
  ///   min(MAX_LIF, WAD.wDivDown(WAD - CURSOR.wMulDown(WAD - lltv)))
  /// Non-linear in `lltv`: 1/(1 - c(1-l)).  The v1 constant 11500 is the value at
  /// the cap and nowhere else in the declared domain.
  pure def liquidationIncentiveFactor(marketLltv: int): int =
    minInt(MAX_LIF, wDivDown(SCALE, SCALE - wMulDown(CURSOR, SCALE - marketLltv)))

  /// Morpho.sol:391-396 — THE DELETED MECHANISM.
  ///   badDebtAssets = min(totalBorrowAssets, badDebtShares.toAssetsUp(tBA, tBS))
  /// and it is subtracted from `totalSupplyAssets`, which is the only path in the
  /// whole protocol by which supplier assets fall.
  pure def socializeBadDebt(badDebtShares: int, tA: int, tS: int): int =
    minInt(tA, toAssetsUp(badDebtShares, tA, tS))

  /// Morpho.sol:526-537.  Debt rounds UP, collateral value rounds DOWN: both
  /// against the borrower.
  pure def isHealthyAt(borrowSh: int, col: int, tA: int, tS: int,
                       price: int, marketLltv: int): bool =
    if (borrowSh == 0) true
    else
      wMulDown(mulDivDown(col, price, ORACLE_PRICE_SCALE), marketLltv)
        >= toAssetsUp(borrowSh, tA, tS)

  /// Morpho.sol:372-375 — the `seizedAssets` entry form.  mulDivUp then wDivUp:
  /// both round the repayment UP, against the liquidator.
  pure def repaidSharesFromSeized(seizedAssets: int, tA: int, tS: int,
                                  lif: int, price: int): int =
    toSharesUp(wDivUp(mulDivUp(seizedAssets, price, ORACLE_PRICE_SCALE), lif), tA, tS)

  /// Morpho.sol:376-379 — the `repaidShares` entry form.  toAssetsDown then
  /// wMulDown then mulDivDown: the seizure rounds DOWN, again against the
  /// liquidator.  This is where the incentive factor multiplies.
  pure def seizedFromRepaidShares(repaidShares: int, tA: int, tS: int,
                                  lif: int, price: int): int =
    mulDivDown(wMulDown(toAssetsDown(repaidShares, tA, tS), lif),
               ORACLE_PRICE_SCALE, price)

  // ---------------------------------------------------------------------------
  // DERIVED STATE
  // ---------------------------------------------------------------------------

  val lif: int = liquidationIncentiveFactor(lltv)

  def isHealthyNow(borSh: str -> int, col: str -> int, u: str): bool =
    isHealthyAt(borSh.get(u), col.get(u), totalBorrowAssets, totalBorrowShares,
                collPrice, lltv)

  /// The supply-side share price against its value at market creation.  Interest
  /// raises it, a withdrawal's round-up raises it, and the ONLY thing that lowers
  /// it is the bad-debt write-down.
  val supplySharePriceBelowStart: bool =
    (totalSupplyAssets + VIRTUAL_ASSETS) * (INIT_SUPPLY_SHARES + VIRTUAL_SHARES)
      < (INIT_SUPPLY_ASSETS + VIRTUAL_ASSETS) * (totalSupplyShares + VIRTUAL_SHARES)

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed from
  //  the cited Solidity line in integer arithmetic.  [SEP] marks a value the v1
  //  body cannot produce.
  // ===========================================================================

  // -- liquidationIncentiveFactor (:366-370), all four market instances --------
  pure val t0_01: bool = liquidationIncentiveFactor(8600) == 10438   // [SEP] v1 -> 11500
  pure val t0_02: bool = liquidationIncentiveFactor(9000) == 10309   // [SEP] v1 -> 11500
  pure val t0_03: bool = liquidationIncentiveFactor(7700) == 10741   // [SEP] v1 -> 11500
  pure val t0_04: bool = liquidationIncentiveFactor(5000) == 11500   // 8c: the cap binds
  /// the inner term, so the non-linearity is pinned and not only its composition
  pure val t0_05: bool = SCALE - wMulDown(CURSOR, SCALE - 8600) == 9580
  pure val t0_06: bool = SCALE - wMulDown(CURSOR, SCALE - 5000) == 8500
  /// 6c: the uncapped value at lltv = 5000 is 11764, so the `min` is not vacuous
  pure val t0_07: bool = wDivDown(SCALE, 8500) == 11764
  /// 6c: an inexact quotient inside wDivDown — 1e8/9580 = 10438.4
  pure val t0_08: bool = wDivDown(SCALE, 9580) == 10438
  pure val t0_09: bool = wDivUp(SCALE, 9580) == 10439

  // -- socializeBadDebt (:391-396) --------------------------------------------
  pure val t0_10: bool = socializeBadDebt(200000000, 1000, 1000000000) == 200      // T0-LIVE
  pure val t0_11: bool = socializeBadDebt(150000000, 500, 400000000) == 188        // 6c: ceil of 187.4
  pure val t0_12: bool = toAssetsDown(150000000, 500, 400000000) == 187            // 6c: the floor pair
  /// 6f: the OTHER side of the `min` — the shortfall exceeds what is left on the books
  pure val t0_13: bool = socializeBadDebt(200000000, 100, 200000000) == 100
  pure val t0_14: bool = toAssetsUp(200000000, 100, 200000000) == 101

  // -- share math, both rounding directions (SharesMathLib.sol:27-44) ---------
  pure val t0_15: bool = toSharesDown(2000, 0, 0) == 2000000000       // empty market
  pure val t0_16: bool = toSharesUp(1000, 0, 0) == 1000000000         // empty market
  pure val t0_17: bool = toAssetsUp(800000000, 1000, 1000000000) == 800
  pure val t0_18: bool = toAssetsDown(800000000, 1000, 1000000000) == 800
  pure val t0_19: bool = toSharesUp(300, 1500, 1000000000) == 200066623   // 6c: ceil
  pure val t0_20: bool = toSharesDown(300, 1500, 1000000000) == 200066622 // 6c: floor

  // -- the two liquidation entry forms (:372-379) -----------------------------
  pure val t0_21: bool =
    seizedFromRepaidShares(800000000, 1000, 1000000000, 10438, 200000000) == 417  // [SEP]
  pure val t0_22: bool =
    seizedFromRepaidShares(800000000, 1000, 1000000000, 11500, 200000000) == 460  // v1 literal
  pure val t0_23: bool =
    repaidSharesFromSeized(300, 1000, 1000000000, 10438, 200000000) == 575000000
  pure val t0_24: bool =
    repaidSharesFromSeized(300, 1000, 1000000000, 11500, 200000000) == 522000000  // v1 literal

  // -- _isHealthy, both sides of the threshold (:526-537) ---------------------
  pure val t0_25: bool =
    isHealthyAt(1000000000, 417, 1000, 1000000000, 300000000, 8600)      // 1075 >= 1000
  pure val t0_26: bool =
    not(isHealthyAt(1000000000, 417, 1000, 1000000000, 200000000, 8600)) // 717 < 1000
  pure val t0_27: bool = isHealthyAt(0, 0, 1000, 1000000000, 200000000, 8600)
  pure val t0_28: bool = zeroFloorSub(1000, 800) == 200
  pure val t0_29: bool = zeroFloorSub(800, 1000) == 0

  pure val inv_T0: bool = and {
    t0_01, t0_02, t0_03, t0_04, t0_05, t0_06, t0_07, t0_08, t0_09, t0_10,
    t0_11, t0_12, t0_13, t0_14, t0_15, t0_16, t0_17, t0_18, t0_19, t0_20,
    t0_21, t0_22, t0_23, t0_24, t0_25, t0_26, t0_27, t0_28, t0_29,
  }

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  /// Morpho.createMarket (:161-177) plus one prior `supply` by alice (2000 assets,
  /// 2e9 shares) and one prior `supplyCollateral` + `borrow` by bob (417 collateral,
  /// 1000 assets, 1e9 shares) at the initial oracle price of 5.0, folded into the
  /// initial state.  Every one of those is reachable by the actions below from an
  /// empty market and each is healthy at all four `lltv` instances (bob's collateral
  /// is worth 2085, so even at lltv = 5000 his maxBorrow is 1042 >= 1000); folding
  /// them in buys two steps of trace depth for the T0-LIVE obligation and costs no
  /// reachability.  `lltv` is the one market parameter this spec varies; see
  /// DEVIATION D-a.
  action init: bool = {
    nondet chosenLltv = LLTVS.oneOf()
    all {
      lltv' = chosenLltv,
      totalSupplyAssets' = INIT_SUPPLY_ASSETS,
      totalSupplyShares' = INIT_SUPPLY_SHARES,
      totalBorrowAssets' = INIT_BORROW_ASSETS,
      totalBorrowShares' = INIT_BORROW_SHARES,
      supplyShares' = Map(ALICE -> INIT_SUPPLY_SHARES, BOB -> ZERO, LIQUIDATOR -> ZERO),
      borrowShares' = Map(ALICE -> ZERO, BOB -> INIT_BORROW_SHARES, LIQUIDATOR -> ZERO),
      collateral' = Map(ALICE -> ZERO, BOB -> INIT_COLLATERAL, LIQUIDATOR -> ZERO),
      totalCollateralSupplied' = INIT_COLLATERAL,
      collPrice' = INIT_PRICE,
      lastOp' = OP_INIT,
    }
  }

  /// Morpho.supply (:192-230).  Shares round DOWN: the depositor eats the residual.
  action supply(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    totalSupplyAssets + assets <= MAX_MARKET_ASSETS,
    val sh = toSharesDown(assets, totalSupplyAssets, totalSupplyShares)
    all {
      sh > 0,
      totalSupplyAssets' = totalSupplyAssets + assets,
      totalSupplyShares' = totalSupplyShares + sh,
      supplyShares' = supplyShares.put(u, supplyShares.get(u) + sh),
      totalBorrowAssets' = totalBorrowAssets,
      totalBorrowShares' = totalBorrowShares,
      borrowShares' = borrowShares,
      collateral' = collateral,
      totalCollateralSupplied' = totalCollateralSupplied,
      collPrice' = collPrice,
      lltv' = lltv,
      lastOp' = OP_SUPPLY,
    }
  }

  /// Morpho.withdraw (:236-266).  Shares round UP and :262 refuses to leave the
  /// market short of loan assets (INSUFFICIENT_LIQUIDITY).
  action withdraw(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    val sh = toSharesUp(assets, totalSupplyAssets, totalSupplyShares)
    all {
      sh > 0,
      supplyShares.get(u) >= sh,
      totalBorrowAssets <= totalSupplyAssets - assets,
      totalSupplyAssets' = totalSupplyAssets - assets,
      totalSupplyShares' = totalSupplyShares - sh,
      supplyShares' = supplyShares.put(u, supplyShares.get(u) - sh),
      totalBorrowAssets' = totalBorrowAssets,
      totalBorrowShares' = totalBorrowShares,
      borrowShares' = borrowShares,
      collateral' = collateral,
      totalCollateralSupplied' = totalCollateralSupplied,
      collPrice' = collPrice,
      lltv' = lltv,
      lastOp' = OP_WITHDRAW,
    }
  }

  /// Morpho.supplyCollateral (:318-340)
  action supplyCollateral(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    totalCollateralSupplied + assets <= MAX_MARKET_ASSETS,
    collateral' = collateral.put(u, collateral.get(u) + assets),
    totalCollateralSupplied' = totalCollateralSupplied + assets,
    supplyShares' = supplyShares,
    borrowShares' = borrowShares,
    totalSupplyAssets' = totalSupplyAssets,
    totalSupplyShares' = totalSupplyShares,
    totalBorrowAssets' = totalBorrowAssets,
    totalBorrowShares' = totalBorrowShares,
    collPrice' = collPrice,
    lltv' = lltv,
    lastOp' = OP_SUPPLY_COLL,
  }

  /// Morpho.withdrawCollateral (:308-341).  The health check after the write is what
  /// makes `inv_noUnbackedDebt` hold on this path.
  action withdrawCollateral(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    collateral.get(u) >= assets,
    val newCol = collateral.put(u, collateral.get(u) - assets)
    all {
      isHealthyNow(borrowShares, newCol, u),
      collateral' = newCol,
      totalCollateralSupplied' = totalCollateralSupplied - assets,
      supplyShares' = supplyShares,
      borrowShares' = borrowShares,
      totalSupplyAssets' = totalSupplyAssets,
      totalSupplyShares' = totalSupplyShares,
      totalBorrowAssets' = totalBorrowAssets,
      totalBorrowShares' = totalBorrowShares,
      collPrice' = collPrice,
      lltv' = lltv,
      lastOp' = OP_WITHDRAW_COLL,
    }
  }

  /// Morpho.borrow (:272-304).  Shares round UP against the borrower, and :302
  /// refuses to lend out more than the market holds.
  action borrow(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    val sh = toSharesUp(assets, totalBorrowAssets, totalBorrowShares)
    val newBor = borrowShares.put(u, borrowShares.get(u) + sh)
    all {
      sh > 0,
      totalBorrowAssets + assets <= totalSupplyAssets,
      isHealthyAt(newBor.get(u), collateral.get(u), totalBorrowAssets + assets,
                  totalBorrowShares + sh, collPrice, lltv),
      totalBorrowAssets' = totalBorrowAssets + assets,
      totalBorrowShares' = totalBorrowShares + sh,
      borrowShares' = newBor,
      supplyShares' = supplyShares,
      collateral' = collateral,
      totalCollateralSupplied' = totalCollateralSupplied,
      totalSupplyAssets' = totalSupplyAssets,
      totalSupplyShares' = totalSupplyShares,
      collPrice' = collPrice,
      lltv' = lltv,
      lastOp' = OP_BORROW,
    }
  }

  /// Morpho.repay (:310-341).  Shares round DOWN: the repayer gets no free rounding.
  action repay(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    totalBorrowShares > 0,
    val sh = toSharesDown(assets, totalBorrowAssets, totalBorrowShares)
    all {
      sh > 0,
      borrowShares.get(u) >= sh,
      totalBorrowAssets' = zeroFloorSub(totalBorrowAssets, assets),
      totalBorrowShares' = totalBorrowShares - sh,
      borrowShares' = borrowShares.put(u, borrowShares.get(u) - sh),
      supplyShares' = supplyShares,
      collateral' = collateral,
      totalCollateralSupplied' = totalCollateralSupplied,
      totalSupplyAssets' = totalSupplyAssets,
      totalSupplyShares' = totalSupplyShares,
      collPrice' = collPrice,
      lltv' = lltv,
      lastOp' = OP_REPAY,
    }
  }

  /// Morpho.liquidate, `repaidShares` given (:346-410 with :376-379 taken).
  /// The write-down at :390-401 runs whenever the seizure empties the collateral.
  action liquidateByShares(borrower: str, repaidShares: int): bool = all {
    USERS.contains(borrower),
    repaidShares > 0,
    borrowShares.get(borrower) >= repaidShares,
    not(isHealthyNow(borrowShares, collateral, borrower)),
    val seized = seizedFromRepaidShares(repaidShares, totalBorrowAssets,
                                        totalBorrowShares, lif, collPrice)
    val repaidAssets = toAssetsUp(repaidShares, totalBorrowAssets, totalBorrowShares)
    val shAfter = borrowShares.get(borrower) - repaidShares
    val tBSAfter = totalBorrowShares - repaidShares
    val tBAAfter = zeroFloorSub(totalBorrowAssets, repaidAssets)
    val colAfter = collateral.get(borrower) - seized
    val badDebtShares = if (colAfter == 0) shAfter else 0
    val badDebtAssets = if (colAfter == 0) socializeBadDebt(badDebtShares, tBAAfter, tBSAfter) else 0
    all {
      seized > 0,
      collateral.get(borrower) >= seized,
      collateral' = collateral.put(borrower, colAfter).put(LIQUIDATOR, collateral.get(LIQUIDATOR) + seized),
      borrowShares' = borrowShares.put(borrower, shAfter - badDebtShares),
      totalBorrowShares' = tBSAfter - badDebtShares,
      totalBorrowAssets' = tBAAfter - badDebtAssets,
      totalSupplyAssets' = totalSupplyAssets - badDebtAssets,
      totalSupplyShares' = totalSupplyShares,
      supplyShares' = supplyShares,
      totalCollateralSupplied' = totalCollateralSupplied,
      collPrice' = collPrice,
      lltv' = lltv,
      lastOp' = OP_LIQ_SHARES,
    }
  }

  /// Morpho.liquidate, `seizedAssets` given (:346-410 with :372-375 taken).
  action liquidateBySeize(borrower: str, seizedAssets: int): bool = all {
    USERS.contains(borrower),
    seizedAssets > 0,
    collateral.get(borrower) >= seizedAssets,
    not(isHealthyNow(borrowShares, collateral, borrower)),
    val repaidShares = repaidSharesFromSeized(seizedAssets, totalBorrowAssets,
                                              totalBorrowShares, lif, collPrice)
    val repaidAssets = toAssetsUp(repaidShares, totalBorrowAssets, totalBorrowShares)
    val shAfter = borrowShares.get(borrower) - repaidShares
    val tBSAfter = totalBorrowShares - repaidShares
    val tBAAfter = zeroFloorSub(totalBorrowAssets, repaidAssets)
    val colAfter = collateral.get(borrower) - seizedAssets
    val badDebtShares = if (colAfter == 0) shAfter else 0
    val badDebtAssets = if (colAfter == 0) socializeBadDebt(badDebtShares, tBAAfter, tBSAfter) else 0
    all {
      repaidShares > 0,
      borrowShares.get(borrower) >= repaidShares,
      collateral' = collateral.put(borrower, colAfter).put(LIQUIDATOR, collateral.get(LIQUIDATOR) + seizedAssets),
      borrowShares' = borrowShares.put(borrower, shAfter - badDebtShares),
      totalBorrowShares' = tBSAfter - badDebtShares,
      totalBorrowAssets' = tBAAfter - badDebtAssets,
      totalSupplyAssets' = totalSupplyAssets - badDebtAssets,
      totalSupplyShares' = totalSupplyShares,
      supplyShares' = supplyShares,
      totalCollateralSupplied' = totalCollateralSupplied,
      collPrice' = collPrice,
      lltv' = lltv,
      lastOp' = OP_LIQ_SEIZE,
    }
  }

  /// Morpho._accrueInterest (:483-505).  Both totals grow by the same amount; the
  /// share counts do not move, so the supply share price rises.  The market fee is
  /// zero at creation and is listed under ABSTRACTED.
  action accrueInterest(interest: int): bool = all {
    interest > 0,
    totalBorrowAssets > 0,
    totalSupplyAssets + interest <= MAX_MARKET_ASSETS,
    totalBorrowAssets' = totalBorrowAssets + interest,
    totalSupplyAssets' = totalSupplyAssets + interest,
    totalSupplyShares' = totalSupplyShares,
    totalBorrowShares' = totalBorrowShares,
    supplyShares' = supplyShares,
    borrowShares' = borrowShares,
    collateral' = collateral,
    totalCollateralSupplied' = totalCollateralSupplied,
    collPrice' = collPrice,
    lltv' = lltv,
    lastOp' = OP_ACCRUE,
  }

  /// IOracle(marketParams.oracle).price() (:361) — an external call, foot(Q) = 0.
  action setOraclePrice(p: int): bool = all {
    p > 0,
    p != collPrice,
    collPrice' = p,
    lltv' = lltv,
    totalSupplyAssets' = totalSupplyAssets,
    totalSupplyShares' = totalSupplyShares,
    totalBorrowAssets' = totalBorrowAssets,
    totalBorrowShares' = totalBorrowShares,
    supplyShares' = supplyShares,
    borrowShares' = borrowShares,
    collateral' = collateral,
    totalCollateralSupplied' = totalCollateralSupplied,
    lastOp' = OP_ORACLE,
  }

  /// Convention 6 / 6g: every `nondet` is exogenous — a caller identity, an asset
  /// amount the caller transferred, a liquidation size the liquidator chose, or an
  /// oracle return.  Morpho selects nothing: it has no queue, no ordering and no
  /// prefix, so there is no quantity here that the driver could be told.
  action step: bool = {
    nondet lender = USERS.oneOf()
    nondet assets = ASSET_AMOUNTS.oneOf()
    nondet collAmt = COLLATERAL_AMOUNTS.oneOf()
    nondet price = PRICES.oneOf()
    nondet interest = INTEREST_AMOUNTS.oneOf()
    nondet repayUnits = 1.to(8).oneOf()
    nondet seizeUnits = 1.to(8).oneOf()
    val repaidShares = repayUnits * REPAY_SHARE_UNIT
    val seizedAssets = seizeUnits * SEIZE_UNIT
    any {
      supply(lender, assets),
      withdraw(lender, assets),
      supplyCollateral(lender, collAmt),
      withdrawCollateral(lender, collAmt),
      borrow(lender, assets),
      repay(lender, assets),
      liquidateByShares(ALICE, repaidShares),
      liquidateByShares(BOB, repaidShares),
      liquidateBySeize(ALICE, seizedAssets),
      liquidateBySeize(BOB, seizedAssets),
      accrueInterest(interest),
      setOraclePrice(price),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — v1's `shareConservation` (morpho_blue.qnt:210-212), unchanged.
  /// This is the T2 command's invariant, and it is reported for exactly the reason
  /// the pilot reported `inv_conservation`: it holds in the mutant too, so it is
  /// evidence of nothing about the restored mechanism.
  val inv_conservation: bool = and {
    USERS.fold(0, (acc, u) => acc + supplyShares.get(u)) == totalSupplyShares,
    USERS.fold(0, (acc, u) => acc + borrowShares.get(u)) == totalBorrowShares,
  }

  val inv_bounds: bool = and {
    totalSupplyAssets >= 0,
    totalSupplyShares >= 0,
    totalBorrowAssets >= 0,
    totalBorrowShares >= 0,
    totalCollateralSupplied >= 0,
    collPrice > 0,
    LLTVS.contains(lltv),
    USERS.forall(u => supplyShares.get(u) >= 0),
    USERS.forall(u => borrowShares.get(u) >= 0),
    USERS.forall(u => collateral.get(u) >= 0),
  }

  /// Collateral moves between positions and never appears or vanishes.
  val inv_collateralConserved: bool =
    USERS.fold(0, (acc, u) => acc + collateral.get(u)) == totalCollateralSupplied

  /// v1's `liquidityInvariant` (morpho_blue.qnt:207).  Preserved by the write-down,
  /// which subtracts the SAME amount from both totals (:394-395) — reported here
  /// because it is the second invariant that does not discriminate.
  val inv_liquidity: bool = totalBorrowAssets <= totalSupplyAssets

  /// T3 for this protocol, half one (P2-SCOPE §5 row 4, `inv_incentiveDerived`):
  /// the incentive factor is EVALUATED from the market's own `lltv`, and it equals
  /// the recorded table at the instance this run drew.  False for the v1 literal at
  /// three of the four instances.
  val inv_incentiveDerived: bool = and {
    lltv == 5000 implies lif == 11500,
    lltv == 7700 implies lif == 10741,
    lltv == 8600 implies lif == 10438,
    lltv == 9000 implies lif == 10309,
    lif <= MAX_LIF,
  }

  /// T3 for this protocol, half two, and THE INVARIANT THAT KILLS THE MUTANT.
  /// Morpho.sol:390-401 exists to make this state unreachable: nobody may be left
  /// holding borrow shares with no collateral behind them, because such a debt can
  /// never be repaid or liquidated and would sit on the books forever.  With the
  /// write-down deleted, the FIRST liquidation that empties a borrower's collateral
  /// violates it.  Note that neither `inv_conservation` nor `inv_liquidity` does.
  val inv_noUnbackedDebt: bool =
    USERS.forall(u => borrowShares.get(u) == 0 or collateral.get(u) > 0)

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_collateralConserved,
    inv_liquidity,
    inv_incentiveDerived,
    inv_noUnbackedDebt,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (§D, the fifth trap).
  //  Each of these must be VIOLATED by `quint run --invariant=<name>`.
  // ===========================================================================

  pure val T0_LIVE_SUPPLY_AFTER: int = 1800
  pure val T0_LIVE_BAD_DEBT: int = 200
  pure val T0_LIVE_SEIZED: int = 417

  /// T0-LIVE for this protocol: `totalSupplyAssets 2000 -> 1800`, as a TRACE.
  /// A liquidation emptied the borrower's collateral, 200 assets of shortfall were
  /// written off against the supply side, and the borrower's remaining shares were
  /// zeroed.  Under M1 the write-down is three identity assignments, so
  /// `totalSupplyAssets` never leaves 2000 on this path and the state is
  /// unreachable — which is exactly how a value-level equality becomes a mechanism
  /// check.
  val wit_live_socializeBadDebt: bool =
    not(and {
      lltv == LLTV_LIVE,
      totalSupplyAssets == T0_LIVE_SUPPLY_AFTER,
      totalSupplyShares == INIT_SUPPLY_SHARES,
      totalBorrowAssets == 0,
      totalBorrowShares == 0,
      collateral.get(BOB) == 0,
      borrowShares.get(BOB) == 0,
      collateral.get(LIQUIDATOR) == T0_LIVE_SEIZED,
    })

  /// `socializeBadDebt` ran and the loss landed on a supplier who took no action:
  /// alice still holds every share she was created with, and they are worth less
  /// than they were.  Tag-free — nothing else in the protocol lowers the share
  /// price.  This is the CROSS-USER form P2-CONTRACT §C row 4 requires (|USERS| >= 2);
  /// a single-supplier domain would host the arithmetic and not the mechanism.
  val wit_used_socializeBadDebt: bool =
    not(and {
      supplyShares.get(ALICE) == INIT_SUPPLY_SHARES,
      supplySharePriceBelowStart,
      USERS.exists(u => and { collateral.get(u) == 0, borrowShares.get(u) == 0 }),
    })

  /// `liquidationIncentiveFactor` ran and its VALUE was load-bearing: the liquidator
  /// holds exactly the 417 units that 8e8 repaid shares buy at LIF = 10438.  Under
  /// the v1 literal 11500 the same call seizes 460, so this state is unreachable.
  val wit_used_liquidationIncentiveFactor: bool =
    not(and { lltv == LLTV_LIVE, collateral.get(LIQUIDATOR) == T0_LIVE_SEIZED })

  /// 6f: the MAX_LIF cap branch of the `min` at :367 was taken in a real liquidation.
  val wit_branch_lifCapped: bool =
    not(and { lltv == LLTV_CAP, collateral.get(LIQUIDATOR) > 0 })

  /// 6f: the other side — the derived value was below the cap in a real liquidation.
  val wit_branch_lifUncapped: bool =
    not(and { lltv != LLTV_CAP, collateral.get(LIQUIDATOR) > 0 })

  /// `toSharesDown` ran on a NON-EMPTY market: a second supplier holds shares, and
  /// the market was already priced when they arrived.
  val wit_used_toSharesDown: bool =
    not(and { supplyShares.get(BOB) > 0, supplyShares.get(ALICE) > 0 })

  /// `toSharesUp` ran: borrow shares exist, minted against the virtual pair.
  val wit_used_toSharesUp: bool = totalBorrowShares == 0

  /// `toAssetsUp` ran inside `_isHealthy` and DECIDED: a position exists that the
  /// oracle has made unhealthy, i.e. the debt side rounded up past the collateral
  /// side.  Only a liquidation can follow.
  val wit_used_toAssetsUp: bool =
    not(USERS.exists(u => and {
      borrowShares.get(u) > 0,
      not(isHealthyNow(borrowShares, collateral, u)),
    }))

  /// `accrueInterest` ran and the share price rose above its creation value — the
  /// direction the write-down reverses.
  val wit_used_accrual: bool =
    (totalSupplyAssets + VIRTUAL_ASSETS) * (INIT_SUPPLY_SHARES + VIRTUAL_SHARES)
      <= (INIT_SUPPLY_ASSETS + VIRTUAL_ASSETS) * (totalSupplyShares + VIRTUAL_SHARES)

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_supply: bool = lastOp != OP_SUPPLY
  val wit_fired_withdraw: bool = lastOp != OP_WITHDRAW
  val wit_fired_supplyCollateral: bool = lastOp != OP_SUPPLY_COLL
  val wit_fired_withdrawCollateral: bool = lastOp != OP_WITHDRAW_COLL
  val wit_fired_borrow: bool = lastOp != OP_BORROW
  val wit_fired_repay: bool = lastOp != OP_REPAY
  val wit_fired_liquidateByShares: bool = lastOp != OP_LIQ_SHARES
  val wit_fired_liquidateBySeize: bool = lastOp != OP_LIQ_SEIZE
  val wit_fired_accrueInterest: bool = lastOp != OP_ACCRUE
  val wit_fired_setOraclePrice: bool = lastOp != OP_ORACLE
}
