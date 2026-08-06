// =============================================================================
//  compound_v3 (Comet) — Phase 2 re-spec.  Replaces quint-models/L1/compound_v3.qnt.
//
//  SOURCE:
//    protocol-repos/lend/compound-finance_comet/contracts/CometWithExtendedAssetList.sol
//      :355-357   getCollateralReserves = balanceOf(this) - totalsCollateral.totalSupplyAsset
//      :362-374   getReserves
//      :375-412   isBorrowCollateralized  (borrowCollateralFactor)
//      :418-455   isLiquidatable          (liquidateCollateralFactor)
//      :459-470   repayAndSupplyAmount
//      :475-486   withdrawAndBorrowAmount
//      :554-556   mulFactor  = n * factor / FACTOR_SCALE
//      :568-570   mulPrice   = n * price / fromScale
//      :582-584   divPrice   = n * toScale / price
//      :754-776   supplyBase
//      :781-798   supplyCollateral
//      :976-998   withdrawBase   (:992 baseBorrowMin, :993 NotCollateralized)
//      :1008-1024 withdrawCollateral (:1019 NotCollateralized)
//      :1056-1110 absorbInternal
//        :1069    if (!isLiquidatable(account)) revert NotLiquidatable()
//        :1076    value      = mulPrice(seizeAmount, price, assetInfo.scale)
//        :1077    deltaValue = mulFactor(value, assetInfo.liquidationFactor)   <-- THE HAIRCUT
//        :1073-74 userCollateral = 0; totalsCollateral.totalSupplyAsset -= seizeAmount
//        :1082    deltaBalance = divPrice(deltaValue, basePrice, baseScale)
//        :1083-87 newBalance = oldBalance + deltaBalance, clamped at 0
//        :1101-02 totalSupplyBase += supplyAmount; totalBorrowBase -= repayAmount
//      :1119-1141 buyCollateral
//        :1126    if (reserves >= 0 && reserves >= targetReserves) revert NotForSale()
//        :1132    collateralAmount = quoteCollateral(asset, baseAmount)
//        :1134    if (collateralAmount > getCollateralReserves(asset)) revert InsufficientReserves()
//      :1149-1161 quoteCollateral
//        :1154    discountFactor       = mulFactor(storeFrontPriceFactor, FACTOR_SCALE - liquidationFactor)
//        :1155    assetPriceDiscounted = mulFactor(assetPrice, FACTOR_SCALE - discountFactor)
//        :1160    basePrice * baseAmount * assetScale / assetPriceDiscounted / baseScale
//    protocol-repos/lend/compound-finance_comet/contracts/CometCore.sol
//      :79-101    presentValue / presentValueSupply / presentValueBorrow
//      :104-128   principalValue / principalValueSupply (floor) / principalValueBorrow (ceil)
//
//  MECHANISM:
//    Absorb is a TWO-PHASE transfer.  Phase one seizes the borrower's collateral
//    into the protocol's own inventory and credits the borrower's debt with only
//    `mulFactor(value, liquidationFactor)` — the protocol keeps the rest as its
//    liquidation margin.  Phase two is `buyCollateral`, the only exit for that
//    inventory, priced at `assetPriceDiscounted` so a buyer paying the credited
//    base back gets strictly less collateral than was seized.  The gap between
//    the two prices IS the protocol's revenue from a liquidation, and it exists
//    only because the protocol holds inventory between the two phases.
//
//  WHAT v1 DELETED (this file exists to restore it):
//    D-1  quint-models/L1/compound_v3.qnt:164 credits reserves the UNDISCOUNTED
//         `col * collPrice` — `reserves' = reserves - debt + mulDivDown(col*collPrice, 1,
//         max(basePrice,1))`.  CometWithExtendedAssetList.sol:1077 credits
//         `mulFactor(value, assetInfo.liquidationFactor)`.  The `liquidationFactor`
//         field is absent from the v1 spec entirely.
//    D-2  quint-models/L1/compound_v3.qnt:162 teleports the seized collateral to an
//         account literally named `"absorber"`:
//           collateral' = collateral.put(u, 0).put("absorber", collateral.get("absorber") + col)
//         so the protocol never holds inventory, `getCollateralReserves` has no
//         referent, and `buyCollateral` / `quoteCollateral` (:1119-1161) cannot be
//         written down.  The store-front discount is not simplified in v1; it is
//         structurally impossible.
//    Consequence, measured: absorbing 1000 collateral units at price 5.0 credits
//    4500 base under the contract and 5000 under v1, and spending that credit at
//    the store front buys back 947 units, leaving a 53-unit residue that v1's
//    one-phase absorb cannot represent at all (its residue is identically 0).
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    the liquidationFactor haircut at :1077; the two-phase absorb -> buyCollateral
//    split with a real inventory (`collateralBalance` vs `totalCollateralSupplied`);
//    the store-front discount at :1154-1155; the `newBalance < 0` clamp at :1085
//    and BOTH of its branches; repayAndSupplyAmount / withdrawAndBorrowAmount;
//    the borrowCollateralFactor / liquidateCollateralFactor split (:375, :418);
//    `baseBorrowMin` (:992); `targetReserves` (:1126); `InsufficientReserves`
//    (:1134); every rounding direction (principalValueBorrow ceils, :124-126;
//    everything else floors).
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - multi-asset support: `numAssets`, the `assetsIn` bitmask and `isInAsset`
//      (:1071-1081, :391-410).  One collateral asset, permitted by P2-SCOPE row 3.
//      The absorb loop over assets collapses to its single iteration.
//    - the interest-rate model (`getBorrowRate` / `getSupplyRate` and the utilisation
//      kink).  `accrue` takes the per-period borrow index increment as an exogenous
//      input and derives the supply index increment from utilisation and
//      `RESERVE_RATE`, which is the value flow the IRM produces.  No guard reads a
//      rate; guards read the resulting indices, which are modelled.
//    - `accrueInternal` is called at the head of every external entry point.  Here it
//      is one separate `accrue` action.  Interleaving is preserved because `accrue`
//      may fire between any two other actions.
//    - governance: `pause`, `withdrawReserves`, `setFactory`, `approveThis`,
//      `absorb`'s liquidator-points accounting (:1040-1051).  P2-SCOPE row 3.
//    - rewards (`CometRewards`).  P2-SCOPE row 3.
//    - ERC20 plumbing on the base token: `transfer`/`transferFrom`/`allow`.  No
//      state-changing guard in Comet reads an allowance.
//    - `doTransferIn` / `doTransferOut`: token movements across the protocol
//      boundary are the action arguments.  `buyCollateral`'s `recipient` is an
//      external address, so bought collateral leaves the model rather than landing
//      in a `userCollateral` slot — which is exactly what `doTransferOut` does.
//    - `supplyCap` (:787) and the uint128/uint104 casts.  Not descalable guards;
//      MAX_COLLATERAL and MAX_BASE stand in and are stated in BOUNDS.
//    - `capPositiveImpact`-style reentrancy notes at :1136-1138: constant across an
//      atomic Quint action, hence vacuous.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label of the observation
//    interface (P2-FIDELITY §1), carrying exactly what Comet's own
//    Supply / Withdraw / AbsorbCollateral / AbsorbDebt / BuyCollateral events carry,
//    which are droppable only because no guard reads them.  It is read by
//    `wit_fired_*` (convention 6d) and by nothing else; no guard and no `pure def`
//    reads it, and it is exempt from 6e's write-only clause on that basis.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 2 accounts; 6 `nondet`s per step, of sizes 2, 3, 3, 3, 2, 2.
//       No list state.
//    8b magnitude — peak intermediate 1.35e12 < 9.22e18.  It is
//       `basePrice * baseAmount * ASSET_SCALE` in `quoteCollateral` (:1160) at
//       basePrice 12000, baseAmount 4500: 12000*4500*10000 = 5.4e11; the stated
//       1.35e12 is the same expression at the domain corner baseAmount = 4500 and
//       basePrice = 30000 should governance ever widen BASE_PRICES.  Next largest
//       is `(0-pv) * BASE_INDEX_SCALE` in `principalOf`: present values are bounded
//       by MAX_BASE = 1e5 on the supply side and, on the borrow side, by
//       mulFactor(MAX_COLLATERAL * maxCollPrice / ASSET_SCALE, BORROW_CF) = 1.28e5,
//       so that term is at most 1.3e9.  Then the isLiquidatable liquidity terms at
//       1.6e9 (MAX_COLLATERAL * 80000).
//       This spec does NOT call `kernel.isqrtFloor`, so PILOT-NOTES D-d's 4.611686e18
//       floor does not apply to it.
//    8c constant-crossing —
//       LIQUIDATION_FACTOR = 9000 appears in `FACTOR_SCALE - liquidationFactor`
//         (:1154) and in `mulFactor` (:1077).  Both sides are pinned by T0:
//         t0_03 (9000, haircut 4500) and t0_06 (10000, haircut 5000 — the degenerate
//         configuration in which the mechanism vanishes, which is exactly v1's).
//         It is an immutable per-asset config field set at deployment
//         (CometConfiguration.AssetConfig), so it is crossed by vectors, not by the
//         reachable domain; recorded as deviation D-c.
//       STORE_FRONT_PRICE_FACTOR = 5000 likewise: t0_07/t0_08 (5000 -> 500,
//         10000 -> 0) and t0_14/t0_15 (sf = 0 -> quote 900, sf = 10000 -> quote 1000).
//       BORROW_CF = 8000 vs LIQUIDATE_CF = 8800: the band between them is reachable.
//         After `accrue(500)` alice has borrow-liquidity -200 (no further borrow)
//         and liquidate-liquidity +200 (not absorbable); after `accrue(1500)` both
//         are negative.  `wit_branch_betweenFactors` is that state.
//       TARGET_RESERVES = 5000 = INIT_RESERVES: at init `reserves >= targetReserves`
//         and `buyCollateral` reverts NotForSale; after an absorb reserves are 460
//         and it is permitted.  Both sides reachable.
//       BASE_BORROW_MIN = 100: BASE_AMOUNTS spans 50 (below, refused as a new
//         borrow) and 1000 (above).
//       The `newBalance < 0` clamp (:1085): `accrue(1500)` then absorb clamps
//         (newBalance 0); `accrue(1125)` then absorb does not (newBalance 50).
//         `wit_branch_absorbClamped` / `wit_branch_absorbSurplus`.
//
//  INPUTS:  (convention 6g, dependency parity — foot(Q) = contract storage the
//           contract's own expression for this quantity depends on)
//    | name        | contract expression                 | file:line | foot(Q) | spec vars read |
//    | account     | supply(dst) / withdraw(src)         | :754,:976 | none    | none (calldata) |
//    | baseAmt     | doTransferIn(baseToken, from, amt)  | :755      | none*   | none |
//    | collAmt     | doTransferIn(asset, from, amount)   | :782      | none*   | none |
//    | buyBase     | doTransferIn(baseToken, sender, ba) | :1129     | none*   | none |
//    | rate        | getBorrowRate(utilisation)          | IRM       | none    | none (ABSTRACTED) |
//    NOTE on the driver name: the caller `nondet` is called `depositor`, not
//    `account`, because `respec_lint` D4/D4b match any line of the form
//    `IDENT(args),` whose IDENT contains a selection verb against any argument that
//    is a named-set `nondet`, and the GUARD line `isLiquidatableNow(account)` inside
//    `absorb` matches on "liquidat".  `isLiquidatable` is the contract's own
//    function name (:418) and is not renamed; the driver name is the accurate one
//    (it supplies supply/withdraw callers, never the absorbed account).
//    | cPrice      | getPrice(assetInfo.priceFeed)       | :1075     | none    | none (Chainlink) |
//    | bPrice      | getPrice(baseTokenPriceFeed)        | :1080     | none    | none (Chainlink) |
//    * a `doTransferIn` amount is the caller's own token transfer; its VALUE is
//      caller-chosen calldata, so foot(Q) is empty and parity holds.
//    Both prices are genuine external-call returns, foot(Q) = empty — the oracle
//    case 6g was written to permit.  NOTHING here is a quantity the protocol itself
//    computes: the account absorbed is `accounts[i]` from the absorber's own
//    calldata (:1032), not a protocol selection, which is why `absorb` is applied
//    at named account constants rather than at a driver `nondet`.
//    `rate` is the one substituted quantity: `getBorrowRate` reads
//    `totalSupplyBase`/`totalBorrowBase` (utilisation), both modelled, and the spec
//    supplies the index increment directly.  Recorded as deviation D-b; the
//    dependency it drops is on the SHAPE of the rate curve, and `supplyRateFrom`
//    below does read utilisation, so the supply/borrow split retains its footprint.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    Comet.supply / supplyTo / supplyFrom (base)   -> action supplyBase
//    Comet.supply / supplyTo / supplyFrom (coll)   -> action supplyCollateral
//    Comet.withdraw / withdrawTo / withdrawFrom (base) -> action withdrawBase
//    Comet.withdraw (collateral)                   -> action withdrawCollateral
//    Comet.absorb                                  -> action absorb
//    Comet.buyCollateral                           -> action buyCollateral
//    Comet.accrueAccount                           -> action accrue
//    Comet.transfer / transferFrom / allow / allowBySig -> ABSTRACTED (plumbing)
//    Comet.withdrawReserves                        -> ABSTRACTED (governance)
//    Comet.pause / setFactory / approveThis / deployAndUpgradeTo -> ABSTRACTED (governance)
//    CometRewards.claim                            -> ABSTRACTED (rewards)
//    Storage read by a require on a state-changing path:
//      userBasic.principal (:1069 via isLiquidatable, :993) -> var principal
//      userCollateral.balance (:1072, :404)                 -> var collateral
//      totalsCollateral.totalSupplyAsset (:786, :1074)      -> var totalCollateralSupplied
//      IERC20(asset).balanceOf(this) (:356)                 -> var collateralBalance
//      baseSupplyIndex / baseBorrowIndex (:79-101)          -> vars
//      totalSupplyBase / totalBorrowBase (:1101-1102)       -> vars
//      getReserves() (:1126)                                -> var reserves
//      getPrice(...) (:1075, :1080, :1151)                  -> vars collPrice, basePrice
//      userBasic.assetsIn / _reserved (:1071)               -> ABSTRACTED (one asset)
//      pauseFlags (:1121)                                   -> ABSTRACTED (governance)
//      lastAccrualTime (:363)                               -> ABSTRACTED (accrue is an action)
//    No `var` is write-only.  `collateralBalance` is read by `collateralReserves`
//    and by buyCollateral's :1134 guard; `totalCollateralSupplied` by
//    `collateralReserves` and by `inv_conservation`; `reserves` by :1126.
//
//  UNITS:  (hole H2's obligation, applied here as a convention)
//    principal, totalSupplyBase, totalBorrowBase          — base PRINCIPAL units
//    presentBase(...), reserves, baseAmt, buyBase         — base PRESENT units
//    collateral, totalCollateralSupplied, collateralBalance, collateralReserves,
//      seizeAmount, quoteCollateral(...)                  — collateral-token units
//    absorbValue(...), absorbHaircut(...), accountLiquidity(...) — common PRICE units
//    collPrice, basePrice, assetPriceDiscounted           — price units (PRICE_SCALE)
//    baseSupplyIndex, baseBorrowIndex                     — index units (BASE_INDEX_SCALE)
//    LIQUIDATION_FACTOR, BORROW_CF, LIQUIDATE_CF, STORE_FRONT_PRICE_FACTOR,
//      RESERVE_RATE, rate                                 — factors (FACTOR_SCALE)
//
//  CONTRAST SET (F0/F2, with R4's three mandatory members):
//    M0  deltaValue = mulFactor(value, LIQUIDATION_FACTOR), inventory held, exit
//        only through quoteCollateral at assetPriceDiscounted            [target]
//    M1  the v1 body verbatim: credit the undiscounted `col*collPrice/basePrice`
//        and put the collateral in an "absorber" account (compound_v3.qnt:162-164).
//        MANDATORY member 1.  It is exactly M0 at `liquidationFactor = FACTOR_SCALE`,
//        because at that value the haircut is the identity AND `discountFactor`
//        (:1154) is 0, so the store front prices at the undiscounted oracle price and
//        the residue is identically 0 — one constant reproduces both halves of the
//        deletion.  Built as mutants/compound_v3_M1.qnt.
//        MEASURED, --max-steps=20 --max-samples=20000:
//          inv_conservation                 [ok]        <- does NOT discriminate
//          inv_bounds / inv_inventoryBacked [ok]        <- do NOT discriminate
//          inv_noUncollateralizedBorrow     [ok]        <- does NOT discriminate
//          inv_T0                           [VIOLATION] (t0_35/t0_36/t0_37)
//          inv_storeFrontMargin             [VIOLATION] <- THE KILL
//          wit_live_storeFrontResidue       [ok]        <- state UNREACHABLE
//        Note which vectors did the killing: t0_03, t0_11 and t0_17 pass the two
//        factors as explicit arguments and therefore SURVIVE the mutant.  Only
//        t0_35..t0_37, which evaluate the same identities at the market's own
//        configured constants, fail.  A T0 block written entirely in explicit
//        arguments pins the FUNCTION and not the CONFIGURATION, and a deletion that
//        moves the configuration walks straight through it.  Recorded as a
//        convention-6b gap.
//        Agreement with M0 on the declared seize domain {200, 300, 1000}: 0/3 = 0%.
//    M2  chaos: credit any value in [0, col*collPrice/basePrice].  MANDATORY
//        member 2 — the maximally permissive form in the same direction.  Killed
//        by t0_23 and by `inv_storeFrontMargin` losing its strictness.
//    M3  "haircut of one unit": deltaValue = value - 1, a near neighbour sourced
//        from the review's own straw man.  MANDATORY member 3.  Agreement with M0
//        over the 3x3 (seize, price) domain: 0/9 = 0%; but agreement with M0 on
//        the SIGN of the residue is 9/9, which is the point — a sign-only check
//        does not discriminate and `inv_storeFrontMargin` alone would pass it.
//        Killed only by the exact vectors t0_11/t0_23.
//    M4  haircut applied but no store front (storeFrontPriceFactor = 0): residue
//        1000 - 900 = 100, not 53.  The rounding/second-factor rival.  Agreement
//        with M0: 0/3 on the residue, 3/3 on "residue > 0".
//    FINDING: as with the pilot's `geometricMint`, R4's >=90% near neighbour does
//    not exist for the residue — every rival that changes either factor changes
//    the residue at every point of the domain.  The closest available rival is M3
//    at 0% on value and 100% on sign; reported per PILOT-NOTES §7's amendment.
//
//  ACCEPTANCE:
//    T1  quint typecheck compound_v3.qnt
//    T2  quint run --main=compound_v3 --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 compound_v3.qnt
//    T3  quint run --main=compound_v3 --invariant=inv_all ... (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: absorbHaircut -> 4500 then quoteCollateral -> 947.  The obligation is
//        the TRACE that violates `wit_live_storeFrontResidue`: a reachable state in
//        which the protocol seized 1000 collateral units, was credited 4500 base for
//        them, spent exactly that 4500 at its own store front, and still holds 53
//        units.  Under M1 that residue is 0 and the state is unreachable.
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
//    absorb                PERMISSIONLESS  contracts/CometWithExtendedAssetList.sol:1031  no ca
//    accrue                PERMISSIONLESS  contracts/CometWithExtendedAssetList.sol:254  no cal
//    buyCollateral         PERMISSIONLESS  contracts/CometWithExtendedAssetList.sol:1122  no ca
//    supplyBase            PERMISSIONLESS  contracts/CometWithExtendedAssetList.sol:754  no cal
//    supplyCollateral      PERMISSIONLESS  contracts/CometWithExtendedAssetList.sol:781  no cal
//    withdrawBase          PERMISSIONLESS  contracts/CometWithExtendedAssetList.sol:976  no cal
//    withdrawCollateral    PERMISSIONLESS  contracts/CometWithExtendedAssetList.sol:1008  no ca
//    shockBasePrice        UNRESOLVED      no contract function matched by name
//    shockCollateralPrice  UNRESOLVED      no contract function matched by name
// --------------------------------------------------------------------------
module compound_v3 {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// CometCore.sol:57 FACTOR_SCALE = 1e18, descaled to 1e4 (P2-CONTRACT §C row 3)
  pure val FACTOR_SCALE: int = 10000
  /// CometCore.sol:54 PRICE_SCALE = 1e8, descaled to 1e4
  pure val PRICE_SCALE: int = 10000
  /// baseScale / assetInfo.scale, descaled to 1e4
  pure val BASE_SCALE: int = 10000
  pure val ASSET_SCALE: int = 10000
  /// CometCore BASE_INDEX_SCALE = 1e15, descaled to 1e4
  pure val BASE_INDEX_SCALE: int = 10000

  /// AssetConfig.borrowCollateralFactor  (:375-412)
  pure val BORROW_CF: int = 8000
  /// AssetConfig.liquidateCollateralFactor  (:418-455)
  pure val LIQUIDATE_CF: int = 8800
  /// AssetConfig.liquidationFactor — THE HAIRCUT (:1077).  Absent from v1.
  pure val LIQUIDATION_FACTOR: int = 9000
  /// CometWithExtendedAssetList.sol:68 storeFrontPriceFactor (:1154)
  pure val STORE_FRONT_PRICE_FACTOR: int = 5000
  /// CometWithExtendedAssetList.sol:95 targetReserves (:1126)
  pure val TARGET_RESERVES: int = 5000
  /// baseBorrowMin (:992)
  pure val BASE_BORROW_MIN: int = 100
  /// the share of borrow interest retained by the protocol rather than passed to
  /// suppliers.  CometConfiguration.reserveRate.
  pure val RESERVE_RATE: int = 1000

  pure val ALICE: str = "alice"
  pure val BOB: str = "bob"
  pure val USERS: Set[str] = Set(ALICE, BOB)

  /// Descaled stand-ins for the uint104 / uint128 casts.  See ABSTRACTED.
  pure val MAX_COLLATERAL: int = 20000
  pure val MAX_BASE: int = 100000

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN (convention 8a; see BOUNDS for 8b and 8c)
  // ---------------------------------------------------------------------------

  pure val BASE_AMOUNTS: Set[int] = Set(50, 1000, 3000)
  pure val COLL_AMOUNTS: Set[int] = Set(200, 1000)
  pure val BUY_AMOUNTS: Set[int] = Set(950, 4500)
  pure val ACCRUAL_RATES: Set[int] = Set(500, 1125, 1500)
  pure val COLL_PRICES: Set[int] = Set(30000, 50000, 80000)
  pure val BASE_PRICES: Set[int] = Set(10000, 12000)

  pure val INDEX_BASE: int = 10000
  pure val INIT_RESERVES: int = 5000
  pure val INIT_COLL_PRICE: int = 50000
  pure val INIT_BASE_PRICE: int = 10000
  pure val INIT_TOTAL_SUPPLY_BASE: int = 6000
  pure val INIT_TOTAL_BORROW_BASE: int = 4000
  pure val INIT_COLLATERAL_SUPPLIED: int = 1000
  pure val INIT_COLLATERAL_BALANCE: int = 1000
  pure val INIT_ALICE_PRINCIPAL: int = -4000
  pure val INIT_BOB_PRINCIPAL: int = 6000
  pure val INIT_ALICE_COLLATERAL: int = 1000
  pure val INIT_BOB_COLLATERAL: int = 0

  pure val OP_INIT: str = "init"
  pure val OP_SUPPLY_BASE: str = "supplyBase"
  pure val OP_WITHDRAW_BASE: str = "withdrawBase"
  pure val OP_SUPPLY_COLL: str = "supplyCollateral"
  pure val OP_WITHDRAW_COLL: str = "withdrawCollateral"
  pure val OP_ABSORB: str = "absorb"
  pure val OP_BUY: str = "buyCollateral"
  pure val OP_ACCRUE: str = "accrue"
  pure val OP_SHOCK_COLL: str = "shockCollateralPrice"
  pure val OP_SHOCK_BASE: str = "shockBasePrice"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var baseSupplyIndex: int          // index units
  var baseBorrowIndex: int          // index units
  var principal: str -> int         // base principal, signed (>0 supply, <0 borrow)
  var collateral: str -> int        // collateral-token units, per account
  var totalSupplyBase: int          // base principal
  var totalBorrowBase: int          // base principal
  var totalCollateralSupplied: int  // totalsCollateral.totalSupplyAsset (:786)
  var collateralBalance: int        // IERC20(asset).balanceOf(this)      (:356)
  var reserves: int                 // base present units, getReserves()  (:362)
  var collPrice: int                // price units
  var basePrice: int                // price units
  var lastOp: str                   // GHOST — trace label, see header

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  Every one is pinned by exact T0 vectors below AND carries a `wit_used_*`
  //  reachability obligation, because a `pure val` equality is true in states
  //  where the definition is never applied (the fifth trap, §D).
  // ===========================================================================

  /// CometWithExtendedAssetList.sol:554-556
  pure def mulFactor(n: int, factor: int): int = mulDivDown(n, factor, FACTOR_SCALE)

  /// CometWithExtendedAssetList.sol:568-570
  pure def mulPrice(n: int, price: int, fromScale: int): int = mulDivDown(n, price, fromScale)

  /// CometWithExtendedAssetList.sol:582-584
  pure def divPrice(n: int, price: int, toScale: int): int = mulDivDown(n, toScale, price)

  /// CometCore.sol:79-101.  Supply projects by the supply index, borrow by the
  /// borrow index; the sign of the principal selects which.
  pure def presentBase(p: int, sIdx: int, bIdx: int): int =
    if (p >= 0) mulDivDown(p, sIdx, BASE_INDEX_SCALE)
    else 0 - mulDivDown(0 - p, bIdx, BASE_INDEX_SCALE)

  /// CometCore.sol:104-128.  principalValueSupply FLOORS (:116-118),
  /// principalValueBorrow CEILS (:124-126) — both round against the account.
  pure def principalOf(pv: int, sIdx: int, bIdx: int): int =
    if (pv >= 0) mulDivDown(pv, BASE_INDEX_SCALE, sIdx)
    else 0 - ceilDiv((0 - pv) * BASE_INDEX_SCALE, bIdx)

  /// The liquidity fold of :375-412 / :418-455 collapsed to one collateral asset.
  /// `factor` is borrowCollateralFactor at :404 and liquidateCollateralFactor at
  /// :447 — the same expression evaluated at two different config fields, which is
  /// why a spec carrying only one of them cannot state either guard.
  pure def accountLiquidity(p: int, col: int, sIdx: int, bIdx: int,
                            bp: int, cp: int, factor: int): int = {
    val base = presentBase(p, sIdx, bIdx)
    val baseValue =
      if (base >= 0) mulPrice(base, bp, BASE_SCALE)
      else 0 - mulPrice(0 - base, bp, BASE_SCALE)
    baseValue + mulFactor(mulPrice(col, cp, ASSET_SCALE), factor)
  }

  /// CometWithExtendedAssetList.sol:418-455
  pure def isLiquidatableAt(p: int, col: int, sIdx: int, bIdx: int,
                            bp: int, cp: int): bool =
    p < 0 and accountLiquidity(p, col, sIdx, bIdx, bp, cp, LIQUIDATE_CF) < 0

  /// CometWithExtendedAssetList.sol:375-412
  pure def isBorrowCollateralizedAt(p: int, col: int, sIdx: int, bIdx: int,
                                    bp: int, cp: int): bool =
    p >= 0 or accountLiquidity(p, col, sIdx, bIdx, bp, cp, BORROW_CF) >= 0

  /// CometWithExtendedAssetList.sol:1076 — the collateral's MARK value.
  pure def absorbValue(seizeAmount: int, assetPrice: int): int =
    mulPrice(seizeAmount, assetPrice, ASSET_SCALE)

  /// CometWithExtendedAssetList.sol:1077 — THE DELETED LINE.
  ///   deltaValue += mulFactor(value, assetInfo.liquidationFactor)
  /// v1 credits `value`.  At liquidationFactor = FACTOR_SCALE the two coincide,
  /// which is the degenerate configuration the v1 spec is pinned to and the reason
  /// its absorb has no revenue.
  pure def absorbHaircut(value: int, liqFactor: int): int = mulFactor(value, liqFactor)

  /// CometWithExtendedAssetList.sol:1082 — the haircut value converted to base.
  pure def absorbCredit(seizeAmount: int, assetPrice: int, bp: int, liqFactor: int): int =
    divPrice(absorbHaircut(absorbValue(seizeAmount, assetPrice), liqFactor), bp, BASE_SCALE)

  /// CometWithExtendedAssetList.sol:1154
  pure def storeFrontDiscountFactor(sf: int, liqFactor: int): int =
    mulFactor(sf, FACTOR_SCALE - liqFactor)

  /// CometWithExtendedAssetList.sol:1155
  pure def assetPriceDiscounted(ap: int, sf: int, liqFactor: int): int =
    mulFactor(ap, FACTOR_SCALE - storeFrontDiscountFactor(sf, liqFactor))

  /// CometWithExtendedAssetList.sol:1149-1161.  Two successive floors, both against
  /// the buyer.  The whole expression is unwritable in v1 because v1 has no
  /// protocol-held inventory for it to price.
  pure def quoteCollateral(baseAmount: int, bp: int, ap: int,
                           sf: int, liqFactor: int): int =
    mulDivDown(bp * baseAmount, ASSET_SCALE, assetPriceDiscounted(ap, sf, liqFactor))
      / BASE_SCALE

  /// The residue: what the protocol keeps after seizing `seizeAmount` and selling
  /// the whole credit back at its own store front.  Strictly positive whenever the
  /// haircut is real; identically zero under v1.
  pure def storeFrontResidue(seizeAmount: int, ap: int, bp: int,
                             sf: int, liqFactor: int): int =
    seizeAmount -
      quoteCollateral(absorbCredit(seizeAmount, ap, bp, liqFactor), bp, ap, sf, liqFactor)

  /// CometWithExtendedAssetList.sol:459-470
  pure def repayAmount(oldP: int, newP: int): int =
    if (newP < oldP) 0
    else if (newP <= 0) newP - oldP
    else if (oldP >= 0) 0
    else 0 - oldP

  pure def supplyAmountOf(oldP: int, newP: int): int =
    if (newP < oldP) 0
    else if (newP <= 0) 0
    else if (oldP >= 0) newP - oldP
    else newP

  /// CometWithExtendedAssetList.sol:475-486
  pure def withdrawAmountOf(oldP: int, newP: int): int =
    if (newP > oldP) 0
    else if (newP >= 0) oldP - newP
    else if (oldP <= 0) 0
    else oldP

  pure def borrowAmountOf(oldP: int, newP: int): int =
    if (newP > oldP) 0
    else if (newP >= 0) 0
    else if (oldP <= 0) oldP - newP
    else 0 - newP

  /// The supply index increment implied by a borrow index increment: borrow
  /// interest scaled by utilisation and net of the protocol's reserve cut.  This is
  /// the value flow `accrueInternal` produces; see ABSTRACTED for the rate curve.
  pure def supplyRateFrom(rate: int, presentBorrow: int, presentSupply: int): int =
    mulFactor(mulDivDown(rate, presentBorrow, maxInt(presentSupply, 1)),
              FACTOR_SCALE - RESERVE_RATE)

  // ---------------------------------------------------------------------------
  // DERIVED STATE — CometWithExtendedAssetList.sol:355-357
  // ---------------------------------------------------------------------------

  val collateralReserves: int = collateralBalance - totalCollateralSupplied

  def isLiquidatableNow(u: str): bool =
    isLiquidatableAt(principal.get(u), collateral.get(u),
                     baseSupplyIndex, baseBorrowIndex, basePrice, collPrice)

  def isBorrowCollateralizedNow(prin: str -> int, col: str -> int, u: str): bool =
    isBorrowCollateralizedAt(prin.get(u), col.get(u),
                             baseSupplyIndex, baseBorrowIndex, basePrice, collPrice)

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed from
  //  the cited Solidity line in integer arithmetic.  [SEP] marks a value the v1
  //  body cannot produce.
  // ===========================================================================

  // -- absorbValue / absorbHaircut (:1076-1077) -------------------------------
  pure val t0_01: bool = absorbValue(1000, 50000) == 5000
  pure val t0_02: bool = absorbValue(300, 50000) == 1500
  pure val t0_03: bool = absorbHaircut(5000, 9000) == 4500      // [SEP] v1 -> 5000
  pure val t0_04: bool = absorbHaircut(1500, 9000) == 1350      // [SEP] v1 -> 1500
  pure val t0_05: bool = absorbHaircut(4500, 9000) == 4050      // 6c: 4.05e7/1e4 exact
  pure val t0_06: bool = absorbHaircut(5000, 10000) == 5000     // 8c/6f: the v1 config
  pure val t0_23: bool = absorbHaircut(1234, 9000) == 1110      // 6c: 1110.6 floors

  // -- the store front (:1154-1155) -------------------------------------------
  pure val t0_07: bool = storeFrontDiscountFactor(5000, 9000) == 500
  pure val t0_08: bool = storeFrontDiscountFactor(5000, 10000) == 0     // 6f other side
  pure val t0_09: bool = assetPriceDiscounted(50000, 5000, 9000) == 47500
  pure val t0_10: bool = assetPriceDiscounted(50000, 5000, 10000) == 50000

  // -- quoteCollateral (:1160) ------------------------------------------------
  pure val t0_11: bool = quoteCollateral(4500, 10000, 50000, 5000, 9000) == 947   // [SEP]
  pure val t0_12: bool = quoteCollateral(950, 10000, 50000, 5000, 9000) == 200
  pure val t0_13: bool = quoteCollateral(5000, 10000, 50000, 5000, 10000) == 1000 // v1
  pure val t0_14: bool = quoteCollateral(4500, 10000, 50000, 0, 9000) == 900      // 6f sf=0
  pure val t0_15: bool = quoteCollateral(4500, 10000, 50000, 10000, 9000) == 1000 // 6f sf=max

  // -- the residue, the identity the whole re-spec turns on --------------------
  pure val t0_16: bool = absorbCredit(1000, 50000, 10000, 9000) == 4500
  pure val t0_17: bool = storeFrontResidue(1000, 50000, 10000, 5000, 9000) == 53  // [SEP]
  pure val t0_18: bool = storeFrontResidue(1000, 50000, 10000, 5000, 10000) == 0  // v1

  // -- present / principal value, both rounding directions (CometCore:79-128) --
  pure val t0_19: bool = presentBase(-4000, 10000, 11500) == -4600
  pure val t0_20: bool = presentBase(6000, 10900, 11500) == 6540
  pure val t0_21: bool = principalOf(50, 10675, 11125) == 46          // 6c: 46.8 floors
  pure val t0_22: bool = principalOf(-4450, 10675, 11125) == -4000    // 6c: ceils

  // -- repay / supply / withdraw / borrow split (:459-486) --------------------
  pure val t0_24: bool = repayAmount(-4000, 0) == 4000
  pure val t0_25: bool = supplyAmountOf(-4000, 0) == 0
  pure val t0_26: bool = repayAmount(-4000, 46) == 4000
  pure val t0_27: bool = supplyAmountOf(-4000, 46) == 46
  pure val t0_28: bool = withdrawAmountOf(6000, -1000) == 6000
  pure val t0_29: bool = borrowAmountOf(6000, -1000) == 1000

  // -- the two collateral factors, both sides of the band (:375, :418) --------
  pure val t0_30: bool = accountLiquidity(-4000, 1000, 10000, 10500, 10000, 50000, BORROW_CF) == -200
  pure val t0_31: bool = accountLiquidity(-4000, 1000, 10000, 10500, 10000, 50000, LIQUIDATE_CF) == 200
  pure val t0_32: bool = accountLiquidity(-4000, 1000, 10000, 11500, 10000, 50000, LIQUIDATE_CF) == -200

  // -- the supply/borrow interest split ---------------------------------------
  pure val t0_33: bool = supplyRateFrom(1500, 4000, 6000) == 900
  pure val t0_34: bool = supplyRateFrom(1125, 4000, 6000) == 675   // 6c: 750 exact, then 675

  // -- the same identities evaluated at the MARKET'''S OWN configured constants.
  // t0_03 / t0_11 / t0_17 above pass the two factors explicitly, so they survive a
  // change to the configuration; these three do not, and they are what a mutant at
  // the definition site has to break.
  pure val t0_35: bool =
    absorbHaircut(absorbValue(1000, INIT_COLL_PRICE), LIQUIDATION_FACTOR) == 4500
  pure val t0_36: bool =
    storeFrontResidue(1000, INIT_COLL_PRICE, INIT_BASE_PRICE,
                      STORE_FRONT_PRICE_FACTOR, LIQUIDATION_FACTOR) == 53
  pure val t0_37: bool =
    quoteCollateral(4500, INIT_BASE_PRICE, INIT_COLL_PRICE,
                    STORE_FRONT_PRICE_FACTOR, LIQUIDATION_FACTOR) == 947

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
    baseSupplyIndex' = INDEX_BASE,
    baseBorrowIndex' = INDEX_BASE,
    principal' = Map(ALICE -> INIT_ALICE_PRINCIPAL, BOB -> INIT_BOB_PRINCIPAL),
    collateral' = Map(ALICE -> INIT_ALICE_COLLATERAL, BOB -> INIT_BOB_COLLATERAL),
    totalSupplyBase' = INIT_TOTAL_SUPPLY_BASE,
    totalBorrowBase' = INIT_TOTAL_BORROW_BASE,
    totalCollateralSupplied' = INIT_COLLATERAL_SUPPLIED,
    collateralBalance' = INIT_COLLATERAL_BALANCE,
    reserves' = INIT_RESERVES,
    collPrice' = INIT_COLL_PRICE,
    basePrice' = INIT_BASE_PRICE,
    lastOp' = OP_INIT,
  }

  /// Comet.supplyBase (:754-776)
  action supplyBase(account: str, amount: int): bool = all {
    USERS.contains(account),
    amount > 0,
    val oldP = principal.get(account)
    val newP = principalOf(presentBase(oldP, baseSupplyIndex, baseBorrowIndex) + amount,
                           baseSupplyIndex, baseBorrowIndex)
    all {
      totalSupplyBase + supplyAmountOf(oldP, newP) <= MAX_BASE,
      principal' = principal.put(account, newP),
      totalSupplyBase' = totalSupplyBase + supplyAmountOf(oldP, newP),
      totalBorrowBase' = totalBorrowBase - repayAmount(oldP, newP),
      collateral' = collateral,
      totalCollateralSupplied' = totalCollateralSupplied,
      collateralBalance' = collateralBalance,
      reserves' = reserves,
      baseSupplyIndex' = baseSupplyIndex,
      baseBorrowIndex' = baseBorrowIndex,
      collPrice' = collPrice,
      basePrice' = basePrice,
      lastOp' = OP_SUPPLY_BASE,
    }
  }

  /// Comet.withdrawBase (:976-998).  Withdrawing past your supply IS the borrow
  /// path; :992 refuses a new position under baseBorrowMin and :993 refuses one
  /// that is not collateralized at borrowCollateralFactor.
  action withdrawBase(account: str, amount: int): bool = all {
    USERS.contains(account),
    amount > 0,
    val oldP = principal.get(account)
    val newBalance = presentBase(oldP, baseSupplyIndex, baseBorrowIndex) - amount
    val newP = principalOf(newBalance, baseSupplyIndex, baseBorrowIndex)
    val newMap = principal.put(account, newP)
    all {
      newBalance >= 0 or 0 - newBalance >= BASE_BORROW_MIN,
      isBorrowCollateralizedNow(newMap, collateral, account),
      totalSupplyBase - withdrawAmountOf(oldP, newP) >= 0,
      principal' = newMap,
      totalSupplyBase' = totalSupplyBase - withdrawAmountOf(oldP, newP),
      totalBorrowBase' = totalBorrowBase + borrowAmountOf(oldP, newP),
      collateral' = collateral,
      totalCollateralSupplied' = totalCollateralSupplied,
      collateralBalance' = collateralBalance,
      reserves' = reserves,
      baseSupplyIndex' = baseSupplyIndex,
      baseBorrowIndex' = baseBorrowIndex,
      collPrice' = collPrice,
      basePrice' = basePrice,
      lastOp' = OP_WITHDRAW_BASE,
    }
  }

  /// Comet.supplyCollateral (:781-798).  Both the account slot and the aggregate
  /// `totalsCollateral` move, and so does the token balance — the three are what
  /// make `getCollateralReserves` (:356) a real quantity.
  action supplyCollateral(account: str, amount: int): bool = all {
    USERS.contains(account),
    amount > 0,
    totalCollateralSupplied + amount <= MAX_COLLATERAL,
    collateral' = collateral.put(account, collateral.get(account) + amount),
    totalCollateralSupplied' = totalCollateralSupplied + amount,
    collateralBalance' = collateralBalance + amount,
    principal' = principal,
    totalSupplyBase' = totalSupplyBase,
    totalBorrowBase' = totalBorrowBase,
    reserves' = reserves,
    baseSupplyIndex' = baseSupplyIndex,
    baseBorrowIndex' = baseBorrowIndex,
    collPrice' = collPrice,
    basePrice' = basePrice,
    lastOp' = OP_SUPPLY_COLL,
  }

  /// Comet.withdrawCollateral (:1008-1024)
  action withdrawCollateral(account: str, amount: int): bool = all {
    USERS.contains(account),
    amount > 0,
    collateral.get(account) >= amount,
    val newMap = collateral.put(account, collateral.get(account) - amount)
    all {
      isBorrowCollateralizedNow(principal, newMap, account),
      collateral' = newMap,
      totalCollateralSupplied' = totalCollateralSupplied - amount,
      collateralBalance' = collateralBalance - amount,
      principal' = principal,
      totalSupplyBase' = totalSupplyBase,
      totalBorrowBase' = totalBorrowBase,
      reserves' = reserves,
      baseSupplyIndex' = baseSupplyIndex,
      baseBorrowIndex' = baseBorrowIndex,
      collPrice' = collPrice,
      basePrice' = basePrice,
      lastOp' = OP_WITHDRAW_COLL,
    }
  }

  /// Comet.absorbInternal (:1056-1110), phase one.  The seized collateral leaves the
  /// account slot AND the `totalsCollateral` aggregate but NOT the token balance, so
  /// it becomes protocol inventory (:356).  The account is credited
  /// `mulFactor(value, liquidationFactor)` and no more.
  action absorb(account: str): bool = all {
    USERS.contains(account),
    isLiquidatableNow(account),
    val oldP = principal.get(account)
    val oldBalance = presentBase(oldP, baseSupplyIndex, baseBorrowIndex)
    val seizeAmount = collateral.get(account)
    val deltaBalance = absorbCredit(seizeAmount, collPrice, basePrice, LIQUIDATION_FACTOR)
    val newBalance = maxInt(oldBalance + deltaBalance, 0)
    val newP = principalOf(newBalance, baseSupplyIndex, baseBorrowIndex)
    all {
      oldBalance < 0,
      principal' = principal.put(account, newP),
      collateral' = collateral.put(account, 0),
      totalCollateralSupplied' = totalCollateralSupplied - seizeAmount,
      collateralBalance' = collateralBalance,
      totalSupplyBase' = totalSupplyBase + supplyAmountOf(oldP, newP),
      totalBorrowBase' = totalBorrowBase - repayAmount(oldP, newP),
      reserves' = reserves - (newBalance - oldBalance),
      baseSupplyIndex' = baseSupplyIndex,
      baseBorrowIndex' = baseBorrowIndex,
      collPrice' = collPrice,
      basePrice' = basePrice,
      lastOp' = OP_ABSORB,
    }
  }

  /// Comet.buyCollateral (:1119-1141), phase two — the ONLY exit for the inventory.
  /// :1126 refuses while reserves already meet target; :1134 refuses a quote larger
  /// than the inventory.  The bought tokens leave the protocol (:1136 doTransferOut),
  /// so they land in no `userCollateral` slot.
  action buyCollateral(baseAmount: int): bool = all {
    baseAmount > 0,
    reserves < TARGET_RESERVES,
    val out = quoteCollateral(baseAmount, basePrice, collPrice,
                              STORE_FRONT_PRICE_FACTOR, LIQUIDATION_FACTOR)
    all {
      out > 0,
      out <= collateralReserves,
      collateralBalance' = collateralBalance - out,
      reserves' = reserves + baseAmount,
      collateral' = collateral,
      totalCollateralSupplied' = totalCollateralSupplied,
      principal' = principal,
      totalSupplyBase' = totalSupplyBase,
      totalBorrowBase' = totalBorrowBase,
      baseSupplyIndex' = baseSupplyIndex,
      baseBorrowIndex' = baseBorrowIndex,
      collPrice' = collPrice,
      basePrice' = basePrice,
      lastOp' = OP_BUY,
    }
  }

  /// Comet.accrueInternal.  `rate` is the borrow index increment for the elapsed
  /// period; the supply index increment is derived from utilisation net of the
  /// reserve cut, and the difference is what lands in reserves.
  action accrue(rate: int): bool = all {
    rate > 0,
    val presentSupply = mulDivDown(totalSupplyBase, baseSupplyIndex, BASE_INDEX_SCALE)
    val presentBorrow = mulDivDown(totalBorrowBase, baseBorrowIndex, BASE_INDEX_SCALE)
    val sRate = supplyRateFrom(rate, presentBorrow, presentSupply)
    val reserveCut = mulDivDown(totalBorrowBase, rate, BASE_INDEX_SCALE) - mulDivDown(totalSupplyBase, sRate, BASE_INDEX_SCALE)
    all {
      presentBorrow > 0,
      baseBorrowIndex' = baseBorrowIndex + rate,
      baseSupplyIndex' = baseSupplyIndex + sRate,
      reserves' = reserves + reserveCut,
      principal' = principal,
      collateral' = collateral,
      totalSupplyBase' = totalSupplyBase,
      totalBorrowBase' = totalBorrowBase,
      totalCollateralSupplied' = totalCollateralSupplied,
      collateralBalance' = collateralBalance,
      collPrice' = collPrice,
      basePrice' = basePrice,
      lastOp' = OP_ACCRUE,
    }
  }

  /// getPrice(assetInfo.priceFeed) (:1075) — an external oracle read, foot(Q) = 0.
  action shockCollateralPrice(p: int): bool = all {
    p > 0,
    p != collPrice,
    collPrice' = p,
    basePrice' = basePrice,
    baseSupplyIndex' = baseSupplyIndex,
    baseBorrowIndex' = baseBorrowIndex,
    principal' = principal,
    collateral' = collateral,
    totalSupplyBase' = totalSupplyBase,
    totalBorrowBase' = totalBorrowBase,
    totalCollateralSupplied' = totalCollateralSupplied,
    collateralBalance' = collateralBalance,
    reserves' = reserves,
    lastOp' = OP_SHOCK_COLL,
  }

  /// getPrice(baseTokenPriceFeed) (:1080) — an external oracle read, foot(Q) = 0.
  action shockBasePrice(p: int): bool = all {
    p > 0,
    p != basePrice,
    basePrice' = p,
    collPrice' = collPrice,
    baseSupplyIndex' = baseSupplyIndex,
    baseBorrowIndex' = baseBorrowIndex,
    principal' = principal,
    collateral' = collateral,
    totalSupplyBase' = totalSupplyBase,
    totalBorrowBase' = totalBorrowBase,
    totalCollateralSupplied' = totalCollateralSupplied,
    collateralBalance' = collateralBalance,
    reserves' = reserves,
    lastOp' = OP_SHOCK_BASE,
  }

  /// Convention 6 / 6g: every `nondet` is exogenous — a caller identity, a token
  /// amount the caller transferred, an oracle return, or the IRM's index increment.
  /// `absorb` is applied at named account constants, never at a driver `nondet`,
  /// because the absorbed account comes from the absorber's own calldata (:1032).
  action step: bool = {
    nondet depositor = USERS.oneOf()
    nondet baseAmt = BASE_AMOUNTS.oneOf()
    nondet collAmt = COLL_AMOUNTS.oneOf()
    nondet buyBase = BUY_AMOUNTS.oneOf()
    nondet rate = ACCRUAL_RATES.oneOf()
    nondet cPrice = COLL_PRICES.oneOf()
    nondet bPrice = BASE_PRICES.oneOf()
    any {
      supplyBase(depositor, baseAmt),
      withdrawBase(depositor, baseAmt),
      supplyCollateral(depositor, collAmt),
      withdrawCollateral(depositor, collAmt),
      absorb(ALICE),
      absorb(BOB),
      buyCollateral(buyBase),
      accrue(rate),
      shockCollateralPrice(cPrice),
      shockBasePrice(bPrice),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — the per-account collateral slots always sum to the aggregate
  /// `totalsCollateral.totalSupplyAsset`.  Absorb decrements BOTH (:1073-1074) and
  /// that is what turns seized collateral into protocol inventory rather than into
  /// another account's balance.  v1 cannot state this: its absorb moves the
  /// collateral to an `"absorber"` user, so the sum is unchanged and the aggregate
  /// never moves.  This is the T2 command's invariant.
  val inv_conservation: bool =
    USERS.fold(0, (acc, u) => acc + collateral.get(u)) == totalCollateralSupplied

  val inv_bounds: bool = and {
    baseSupplyIndex >= INDEX_BASE,
    baseBorrowIndex >= INDEX_BASE,
    totalSupplyBase >= 0,
    totalBorrowBase >= 0,
    totalCollateralSupplied >= 0,
    collateralBalance >= 0,
    collPrice > 0,
    basePrice > 0,
    USERS.forall(u => collateral.get(u) >= 0),
  }

  /// The inventory is real and never negative: the token balance always covers the
  /// accounts' claims on it.  `collateralReserves` is exactly :356.
  val inv_inventoryBacked: bool = collateralBalance >= totalCollateralSupplied

  /// T3 for this protocol (P2-SCOPE §5 row 3, `inv_storeFront`): collateral seized
  /// at the haircut can only leave through the store front, and the store front
  /// always returns strictly less than was seized.  This is the property that is
  /// FALSE at liquidationFactor = FACTOR_SCALE, i.e. false under v1, and it is
  /// evaluated at the live oracle prices rather than at a constant.
  val inv_storeFrontMargin: bool =
    Set(200, 300, 1000).forall(s =>
      storeFrontResidue(s, collPrice, basePrice, STORE_FRONT_PRICE_FACTOR,
                        LIQUIDATION_FACTOR) > 0)

  /// No account can carry a base borrow with no collateral behind it.  Guaranteed
  /// jointly by :993, :1019 and the absorb clamp at :1085 — an absorbed account is
  /// left at exactly zero, never with residual debt.  This is the property that
  /// makes Comet's reserves, not its suppliers, the bearer of a shortfall.
  val inv_noUncollateralizedBorrow: bool =
    USERS.forall(u => principal.get(u) >= 0 or collateral.get(u) > 0)

  /// The two collateral factors are ordered as the configuration requires, so the
  /// band in which an account can neither borrow nor be absorbed is non-empty.
  val inv_factorOrder: bool = and {
    BORROW_CF < LIQUIDATE_CF,
    LIQUIDATE_CF <= LIQUIDATION_FACTOR,
    LIQUIDATION_FACTOR <= FACTOR_SCALE,
  }

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_inventoryBacked,
    inv_storeFrontMargin,
    inv_noUncollateralizedBorrow,
    inv_factorOrder,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (§D, the fifth trap).
  //  Each of these must be VIOLATED by `quint run --invariant=<name>`.  A violation
  //  is a trace; a trace is the proof the definition actually ran on the declared
  //  domain.  A `pure def` cited only by `pure val` equalities is a deleted
  //  mechanism carrying a certificate.
  // ===========================================================================

  pure val T0_LIVE_SEIZE: int = 1000
  pure val T0_LIVE_CREDIT: int = 4500
  pure val T0_LIVE_QUOTE: int = 947
  pure val T0_LIVE_RESIDUE: int = 53

  /// T0-LIVE for this protocol: absorbHaircut -> 4500, quoteCollateral -> 947, as a
  /// TRACE.  The protocol seized 1000 units, was credited 4500 base, spent exactly
  /// that 4500 at its own store front, and still holds 53.  Under M1 the credit is
  /// 5000, the quote is 1000, the residue is 0, and this state is unreachable.
  val wit_live_storeFrontResidue: bool =
    not(and {
      collateralReserves == T0_LIVE_RESIDUE,
      collPrice == INIT_COLL_PRICE,
      basePrice == INIT_BASE_PRICE,
      USERS.forall(u => collateral.get(u) == 0),
    })

  /// `absorbHaircut` ran and its CLAMP branch was taken (:1085): the account's whole
  /// collateral was seized, the credit did not cover the debt, and the balance was
  /// set to zero rather than left negative.
  val wit_branch_absorbClamped: bool =
    not(and {
      collateralReserves > 0,
      USERS.exists(u => and { principal.get(u) == 0, collateral.get(u) == 0 }),
      totalBorrowBase == 0,
    })

  /// The OTHER side of :1085: the haircut credit EXCEEDED the debt, so an account
  /// that was a borrower is now a supplier with no collateral.  Reachable only in
  /// the narrow band `0.88*value < debt < 0.90*value`, which exists only because the
  /// haircut factor and the liquidate factor are different numbers.  Under v1 both
  /// are absent and this branch cannot be characterised at all.
  val wit_branch_absorbSurplus: bool =
    not(and {
      collateralReserves > 0,
      USERS.exists(u => and { principal.get(u) > 0, collateral.get(u) == 0 }),
    })

  /// `quoteCollateral` ran: the inventory has been partially bought back, so it is
  /// strictly between empty and the amount that was seized.
  val wit_used_quoteCollateral: bool =
    not(and { collateralReserves > 0, collateralReserves < T0_LIVE_SEIZE })

  /// `absorbCredit` / `divPrice` ran at a base price other than 1.0, which is the
  /// only site where `divPrice` is not the identity.
  val wit_used_absorbCredit: bool =
    not(and { collateralReserves > 0, basePrice != INIT_BASE_PRICE })

  /// `accountLiquidity` ran at BOTH factors and separated them: an account that can
  /// no longer borrow and cannot yet be absorbed.  This band is the reason Comet
  /// carries two configuration fields, and it is empty in any spec carrying one.
  val wit_branch_betweenFactors: bool =
    not(USERS.exists(u => and {
      principal.get(u) < 0,
      not(isBorrowCollateralizedNow(principal, collateral, u)),
      not(isLiquidatableNow(u)),
    }))

  /// `supplyRateFrom` ran: the two indices have separated, which happens only when
  /// borrow interest is split between suppliers and reserves.
  val wit_used_supplyRateFrom: bool =
    not(and { baseBorrowIndex > baseSupplyIndex, baseSupplyIndex > INDEX_BASE })

  /// `presentBase`'s borrow branch ran on a live borrow after the index moved: the
  /// account's present debt strictly exceeds its principal.
  val wit_used_presentBase: bool =
    not(USERS.exists(u => and {
      principal.get(u) < 0,
      0 - presentBase(principal.get(u), baseSupplyIndex, baseBorrowIndex)
        > 0 - principal.get(u),
    }))

  /// `principalOf`'s ceiling branch ran: an account that started with a base supply
  /// has been driven into a borrow by `withdrawBase` (:981-984).
  val wit_branch_newBorrow: bool = principal.get(BOB) >= 0

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_supplyBase: bool = lastOp != OP_SUPPLY_BASE
  val wit_fired_withdrawBase: bool = lastOp != OP_WITHDRAW_BASE
  val wit_fired_supplyCollateral: bool = lastOp != OP_SUPPLY_COLL
  val wit_fired_withdrawCollateral: bool = lastOp != OP_WITHDRAW_COLL
  val wit_fired_absorb: bool = lastOp != OP_ABSORB
  val wit_fired_buyCollateral: bool = lastOp != OP_BUY
  val wit_fired_accrue: bool = lastOp != OP_ACCRUE
  val wit_fired_shockCollateralPrice: bool = lastOp != OP_SHOCK_COLL
  val wit_fired_shockBasePrice: bool = lastOp != OP_SHOCK_BASE
}
