// =============================================================================
//  apex — Phase 2 re-spec.  Replaces quint-models/L3/apex.qnt.
//
//  SOURCE:
//    protocol-repos/perp/ApeX-Protocol_apex-protocol/contracts/core/Amm.sol
//      :24        MINIMUM_LIQUIDITY = 10**3
//      :68-125    mint   (:96 sqrt bootstrap, :97 the permanent lock,
//                         :99-101 pro rata against getRealBaseReserve,
//                         :103 INSUFFICIENT_LIQUIDITY_MINTED,
//                         :106-114 the two price-invariance requires)
//      :129-174   burn   (:151-153 pro rata out, :154 INSUFFICIENT_LIQUIDITY_BURNED,
//                         :157 maxWithdrawCheck, :159-166 the price requires)
//      :176-190   maxWithdrawCheck
//      :192-219   getRealBaseReserve — the base reserve NET of open positions
//      :239-266   forceSwap — how a liquidation actually reaches the reserves
//      :467-478   _getAmountOut — 999/1000
//      :481-492   _getAmountIn  — 1000/999 and the `+ 1`
//    .../core/Margin.sol
//      :50-61     addMargin
//      :111-206   openPosition (:159-161 quoteAmountMax, :197 INIT_MARGIN_RATIO,
//                               :198-201 WILL_BE_LIQUIDATED)
//      :208-251   closePosition (:224-228 DEBT_RATIO_OVER, :242-245 the shortfall
//                               force-swap)
//      :253-300   liquidate (:268 ZERO_POSITION, :273-276 NOT_LIQUIDATABLE)
//      :302-362   _executeSettle (:316 the bonus, :319-321 forceSwap,
//                               :330-337 the residue, :340-357 the shortfall)
//      :608-636   _calDebtRatio — the liquidation TRIGGER
//    .../core/PriceOracle.sol:273-308  getMarkPriceAcc
//    .../core/Config.sol:11,16,17,18,20,21  beta, initMarginRatio,
//                       liquidateThreshold, liquidateFeeRatio, lpWithdraw*
//
//  MECHANISM:
//    A position is worth what the POOL will pay for it.  Opening, closing and
//    liquidating all price against the same constant-product reserves through
//    `_getAmountOut` / `_getAmountIn` at 999/1000, and the decision to liquidate
//    is taken by simulating the close against those reserves with a size-scaled
//    skew (`getMarkPriceAcc`).  There is no exogenous price anywhere on the
//    liquidation path, and LP shares are the geometric mean of the reserves.
//
//  WHAT v1 DELETED — SIX deletions, not the three P2-SCOPE row 6 lists:
//    D-1  quint-models/L3/apex.qnt:47-49 — `swapOut` is `y*dx/(x+dx)`, FEE-FREE.
//         `Amm._getAmountOut` (:467-478) charges 999/1000, which is the only
//         reason k grows and the only reason an LP is paid.  Restored as
//         `ammAmountOut`.
//    D-2  :183-185 — the LP bootstrap is `newShares = baseIn`, LINEAR in one
//         reserve.  `Amm.mint:96` is `Math.sqrt(baseAmount*quoteAmount) -
//         MINIMUM_LIQUIDITY` with :97 locking MINIMUM_LIQUIDITY at address(0)
//         forever.  Both the geometric mean AND THE LOCK were deleted; the lock
//         is a separate mechanism and v1 has no trace of it.  Note that
//         PILOT-NOTES §7 records this shortcut as `(a0+a1)/2 - MIN_LIQ`; the
//         file says `baseIn`, i.e. `a0`, which agrees with M0 on 0 of the 49
//         pairs of the pilot's mint domain rather than on 7 — it never subtracts
//         MINIMUM_LIQUIDITY, so it cannot agree even on the diagonal.  See
//         CONTRAST SET M below; P2-CONTRACT §A.6 has it right ("4000 (linear)").
//    D-3  :138-153 — `liquidate` sets `reserveBase' = reserveBase,
//         reserveQuote' = reserveQuote, marginPool' = marginPool` with the
//         trailing comment ":145 simplified: collateral absorbed, not
//         redistributed".  `Margin._executeSettle` (:302-362) pushes the whole
//         position back through `IAmm.forceSwap`, so a liquidation is a TRADE.
//         Restored: `liquidate` moves both reserves and can lower k.
//    D-4  there is NO close path at all in v1 — no `closePosition`, no `burn`.
//         So the 999/1000 is absent on EXIT as well as on entry, and an LP can
//         never leave.  Restored as `closePosition` and `burn`.
//    D-5  the branch at :184, `if (lpShares == 0) baseIn`, is DEAD: v1 seeds
//         `lpShares' = 100` in `init` (:39) and `lpShares` is only ever
//         incremented, so `lpShares == 0` is unreachable.  The bootstrap is
//         therefore not merely wrong, it is never evaluated — the fifth trap
//         already live in the corpus (P2-CONTRACT §D).  Restored by starting the
//         pool EMPTY, so the branch is taken at depth 1 and witnessed.
//    D-6  the liquidation TRIGGER, not only its settlement.  v1 asks
//         `canLiquidate(position, markPrice, MAINT_BPS)` against `var markPrice`
//         set by `action setMarkPrice(p)` from `nondet price = 5.to(20)`.
//         `Margin._calDebtRatio` (:608-636) instead calls
//         `getMarkPriceAcc(amm, beta, |quoteSize|, ·)`, whose value depends on
//         `baseReserve`, `quoteReserve` AND on the position's own size — the
//         skew term `rvalue = quoteAmount*beta/100` sits inside a SQUARED
//         denominator.  foot(Q) = {reserveBase, reserveQuote, size} against a
//         nondet footprint of empty: three dropped dependencies, hole H1.
//         Restored as `markPriceAccBase` + `debtRatio`; `var markPrice` is gone.
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    999/1000 on entry AND on exit; `_getAmountIn`'s `+ 1` round-up; the exact
//    integer sqrt bootstrap; the permanent MINIMUM_LIQUIDITY lock; both
//    price-invariance requires on mint and on burn; maxWithdrawCheck; the
//    getRealBaseReserve net-position adjustment; INIT_MARGIN_RATIO's
//    quoteAmountMax; WILL_BE_LIQUIDATED and DEBT_RATIO_OVER; NOT_LIQUIDATABLE;
//    the liquidator bonus; the shortfall force-swap on close and on liquidate;
//    getMarkPriceAcc's SLIPPAGE_TOO_LARGE require; every rounding direction.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - funding / CPF (`updateCPF`, `_calFundingFee`, Margin.sol:429-441,:593-606).
//      P2-SCOPE row 6 lists CPF precision as droppable.  fundingFee enters this
//      spec as the constant 0.  It is a scalar transfer between longs and shorts
//      that touches neither the reserves, nor the 999/1000, nor the bootstrap,
//      nor `getMarkPriceAcc`, i.e. none of the six deletions.
//    - `AmmFactory.feeTo == address(0)`, the deployed default.  Consequences,
//      both taken: `_mintFee` (:494-514) mints nothing and `kLast` is never
//      written, so it is NOT declared as a write-only var; and in
//      `_executeSettle` the treasury transfer at :326-329 is not taken, so the
//      residue goes back into the pool through `forceSwap` (:330-337) — which
//      is the branch modelled.  The protocol-cut formula itself is identical to
//      UniswapV2Pair._mintFee and is exercised in full in the uniswap_v2
//      re-spec; duplicating it here would add no mechanism.
//    - the index-price branch of `getMarkPriceAcc` (:296-307) and
//      `getMarkPriceInRatio`.  It needs a Uniswap-V3 TWAP oracle; the AMM branch
//      (:283-295) is the one that carries the size dependence H1 is about, and
//      `isIndexPrice` is false whenever the AMM is the price source.
//    - `Position.tradeSize` (IMargin.sol) and `removeMargin` / `getWithdrawable`
//      (:64-110, :552-592).  tradeSize is entry-price bookkeeping read by no
//      state-changing require on the cited paths.  With it dropped, opening
//      AGAINST an existing opposite position (:176-186) is dropped too and
//      `openLong`/`openShort` require side agreement.  This is an (E<=)
//      restriction, never a relaxation.
//    - `rebase` (:270-309), `collectFee` (:311-318), `initialize`, the Router /
//      RouterForKeeper / OrderBook / PCVTreasury layer, `routerMap` and the
//      `nonReentrant` modifier (constant across an atomic Quint action).
//    - LiquidityERC20 approve/transfer/permit: no guard in Amm reads an
//      allowance.  LP balances survive as `lpBal`.
//    - the uint112 `_update` overflow guard is kept but DESCALED to MAX_RESERVE.
//    - `Math.sqrt`'s Babylonian loop is the kernel's restoring binary algorithm.
//      Not a relaxation: both are exact floor(sqrt) on every uint.
//    - `liquidate`'s second argument `to` (M:253, :294), the address the keeper
//      pays the bonus to.  Base token balances OUTSIDE the vault are not
//      modelled, so `to` has no observable; the bonus is observable exactly as
//      the debit to `vaultBase`, which is kept.
//
//  LINT:  `respec_lint.py apex.qnt` reports ONE finding and it is a false
//    positive, recorded here rather than worked around:
//      [D4] liquidate(target): driver picks `target` from USERS and passes it to
//           a selection action; used as a map key
//    D4 exists because of liquity, where the contract calls `getLast()` and then
//    walks `getPrev()` — the protocol computes WHICH trove, and the v1 spec was
//    told which.  `Margin.liquidate(address trader, address to)` is not that
//    shape: both arguments are calldata, any keeper may call it on any trader,
//    and the map key is the contract's own `traderPositionMap[trader]`.  What
//    the protocol computes here is not WHICH but WHETHER — `_calDebtRatio` ->
//    `getMarkPriceAcc` — and that computation is precisely deletion D-6, which
//    this file restores and which `wit_used_markPriceAccBase` and
//    `wit_sizeDependentLiquidation` prove is live.  A transliteration of the
//    Solidity itself would score the same finding.  Suggested detector
//    refinement for the linter owner: D4 should not fire when the action's guard
//    set contains a `pure def` whose arguments include the same key's state
//    (here `quoteSize.get(target)`, `baseSize.get(target)`) — that is the
//    signature of "the protocol decides by reverting" as opposed to "the
//    protocol decides by selecting".
//
//  GHOST:
//    `lastOp` is the trace label of the observation interface (P2-FIDELITY §1),
//    carrying what the contract's own Mint / Burn / Swap / ForceSwap /
//    Liquidate logs carry.  `kBefore` is the product of the two reserves as of
//    immediately before the current action — exactly what an observer computes
//    from the Swap and ForceSwap events, and the only way to state P2-SCOPE §5
//    row 6's `inv_kMonotone` at all, since a Quint `--invariant` is a
//    SINGLE-STATE predicate (trap K6).  Both are read only by `inv_kMonotone`
//    and by `wit_*`; no guard and no `pure def` reads either.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 2 users (+ the address(0) lock, never selected); six
//       `nondet`s per step, of sizes 2, 5, 4, 3, 2, 2.  No list state.
//    8b magnitude — peak intermediate 4.611686e18 < 9.22e18, inside kernel
//       `isqrtFloor` ((2^31-1)^2), which the bootstrap calls.  The PROTOCOL peak
//       is `quoteAmountMax`'s numerator, quoteReserve*10000*quoteAmount
//       <= 1.0e14; next is `markPriceAccBase`'s quoteAmount*(base*quote)
//       <= 3.0e14 and the mint price-check product <= 2.0e13.
//    8c constant-crossing —
//       MINIMUM_LIQUIDITY = 1000 (a protocol constant, NOT a scale, so it is
//         never descaled): bootstrap (1000,1000) gives 0 and is REFUSED;
//         (1000,2000) gives 414 and is accepted; (4000,9000) gives 5000 with
//         1000 locked.  t0_bm_a..e.  Both sides.
//       fee 999/1000: INVISIBLE at (in 200, rIn 1000, rOut 1000) where the
//         zero-fee form also returns 166 — a "safe small trade" domain would
//         re-delete the fee silently, so the domain is chosen so that the
//         opening trades sit at amountIn/reserveIn >= 0.1 with reserves at 4000,
//         where (4000,4000,9000) gives 4497 against 4500.  t0_ao_d vs t0_ao_e/f.
//       liquidateThreshold 10000: t0_dr_a (2955, safe) / t0_dr_f (12343, liquid-
//         atable) at the SAME reserves and the SAME margin ratio.
//       liquidateFeeRatio 100: bonus 0 at remain 50, 23 at remain 2398.
//       beta's SLIPPAGE_TOO_LARGE (:280): satisfied at size 3000 against a
//         9000 quote reserve, violated at 4000.  t0_mp_e / t0_mp_f.
//       MAX_RESERVE: crossed — repeated mints of 20000 are eventually refused.
//
//  INPUTS:  (convention 6g, dependency parity — foot(Q) is the CONTRACT storage
//           the contract's own expression for this quantity depends on)
//    | name        | contract expression                  | file:line | foot(Q) | spec vars read |
//    | caller      | msg.sender / trader                  | M:50,111  | none    | none (calldata) |
//    | target      | liquidate(address trader)            | M:253     | none    | quoteSize, baseSize (guards) |
//    | baseAmount  | IERC20(baseToken).balanceOf(this)    | A:89      | none*   | none (transfer amount) |
//    | oracleQuote | IPriceOracle.quote(base,quote,amt)   | A:92      | none    | none (external call) |
//    | qty         | openPosition(uint256 quoteAmount)    | M:114     | none    | none (calldata) |
//    | margin      | addMargin(uint256 depositAmount)     | M:50      | none    | none (calldata) |
//    | lpBurn      | balanceOf[address(this)]             | A:142     | none*   | lpBal (guard) |
//    * an ERC20 staging slot the caller wrote in the immediately preceding
//      transfer; its VALUE is caller-chosen calldata, so foot(Q) is empty.
//    `oracleQuote` is a genuine external-call return (PriceOracle.quote reads a
//    Uniswap V3 pool, not this contract's storage), foot(Q) = empty — the oracle
//    case 6g exists to PERMIT.  Contrast the quantity 6g FORBIDS and which v1
//    supplied the same way: `markPrice`.  Its contract expression is
//    `_calDebtRatio -> getMarkPriceAcc(amm, beta, quoteAmount, ·) ->
//    IAmm.getReserves()` (M:616-634, PO:279-295), foot(Q) = {baseReserve,
//    quoteReserve, quoteSize}, all three modelled.  It is NOT in this table
//    because it is no longer an input: it is `markPriceAccBase`, computed.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    Amm.mint                 -> action mint
//    Amm.burn                 -> action burn
//    Amm.swap                 -> reached only from Margin; the two directions are
//                                inside openLong / openShort / closePosition
//    Amm.forceSwap            -> inside closePosition and liquidate
//    Amm.rebase / collectFee / initialize -> ABSTRACTED
//    Margin.addMargin         -> action addMargin
//    Margin.openPosition      -> actions openLong / openShort
//    Margin.closePosition     -> action closePosition
//    Margin.liquidate         -> action liquidate
//    Margin.removeMargin      -> ABSTRACTED (needs tradeSize)
//    Margin.updateCPF / deposit / withdraw -> ABSTRACTED (funding; vault
//                                deposit and withdraw are inlined as vaultBase)
//    Config setters, AmmFactory, LiquidityERC20 -> ABSTRACTED
//    Storage read by a require on a state-changing path:
//      baseReserve, quoteReserve (A:106-114,:159-166,:434) -> vars;
//      totalSupply (A:90,:150) -> var lpSupply;  balanceOf (A:142) -> var lpBal;
//      traderPositionMap (M:121,:217,:265) -> vars quoteSize, baseSize;
//      totalQuoteLong / totalQuoteShort (A:195 via netPosition) -> vars;
//      Margin.reserve (M:52) -> var vaultBase;
//      kLast (A:263) -> ABSTRACTED (feeTo == address(0), never written);
//      traderCPF (M:292) -> ABSTRACTED (funding);
//      config.* -> pure vals, values from Config.sol's own initialisers.
//    No `var` is write-only: totalQuoteLong / totalQuoteShort are read by
//    `apexRealBaseReserve` and by maxWithdrawCheck, vaultBase by the bonus
//    guard and by `inv_vaultSolvent`, lastOp and kBefore by `inv_kMonotone`
//    and `wit_*`.
//
//  UNITS:  (hole H2's obligation — v1 recorded `posSize` in BASE units for a
//           short (:123) and in QUOTE units for a long (:111) and then applied
//           one formula to both, common.qnt:120.  Here every position field is
//           in one unit and the unit is named.)
//    reserveBase, baseSize, vaultBase, margin, baseAmount, MAX_RESERVE — base units
//    reserveQuote, quoteSize, qty, oracleQuote, quoteAmount              — quote units
//    lpSupply, lpBal, lpBurn, MINIMUM_LIQUIDITY                          — LP-share units
//    kBefore, reserveBase*reserveQuote                                   — base*quote
//    isqrtFloor(baseAmount*oracleQuote)                                  — sqrt(base*quote) == LP units
//    debtRatio, BETA, INIT_MARGIN_RATIO, LIQUIDATE_*, FEE_*, RATIO_DEN   — dimensionless
//    quoteSize is SIGNED: negative is a long (quote owed), positive a short.
//    baseSize is SIGNED: negative means the trader owes base to the vault.
//
//  CONTRAST SET M (F0/F2, with R4's three mandatory members), for the LP
//  bootstrap, measured over the 49 pairs of the pilot's mint domain:
//    M0  isqrtFloor(b*q) - MINIMUM_LIQUIDITY                            [target]
//    M1  v1 `newShares = baseIn`, apex.qnt:184 verbatim.  MANDATORY member 1.
//        Agreement 0/49 — it does not subtract MINIMUM_LIQUIDITY at all, so it
//        cannot agree anywhere, not even on the diagonal.
//    M2  chaos: any liquidity in [1, isqrtFloor(b*q)].  MANDATORY member 2.
//    M3  the pilot's own uniswap_v2 M1, `if (a0==a1) a0 else min(a0,a1)`
//        (common.qnt:76-92), the sibling deletion in the corpus.  MANDATORY
//        member 3.  Agreement 7/49 = 14.3%.
//    M4  ceil-sqrt, the rounding-direction rival.  Agreement 15/49 = 30.6%.
//  and for the swap:
//    M0' ammAmountOut with 999/1000;  M1' the v1 fee-free `y*dx/(x+dx)`
//        (apex.qnt:47-49).  These AGREE at (200,1000,1000) — both 166 — which is
//        why the declared domain puts the opening trades at reserves of 4000.
//
//  MUTANT (F2, trap K10) — mutants/apex_M1.qnt, the v1 bodies substituted at
//  their definition sites: `ammAmountOut` -> `reserveOut*amountIn/(reserveIn +
//  amountIn)` (apex.qnt:47-49) and the bootstrap branch -> `baseAmount` with no
//  lock (apex.qnt:183-185).  Measured:
//      inv_conservation             [ok]         <- THE HEADLINE SURVIVES
//      inv_kMonotone                [ok]         <- SO DOES P2-SCOPE's OWN T3
//      inv_T0                       [violation]  <- killed by the vectors
//      inv_permanentLock            [violation]  <- killed by the lock invariant
//      wit_live_apexBootstrapMint   [ok]         <- T0-LIVE state UNREACHABLE
//  The second line is the one that matters and it confirms P2-CONTRACT §A.6's
//  recorded finding at the level of the whole state machine: P2-SCOPE §5 row 6
//  prescribes `inv_kMonotone` as apex's positive check, and the FEE-FREE
//  mechanism satisfies it, because integer flooring alone already makes k
//  non-decreasing.  The fee is separated only by T0 and only at
//  amountIn / reserveIn large enough for the 1/1000 to survive truncation.
//  The lock, by contrast, IS separated by a state invariant — the two halves of
//  deletion D-2 need different instruments, which is why both are shipped.
//
//  ACCEPTANCE:
//    T1  quint typecheck apex.qnt
//    T2  quint run --main=apex --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 apex.qnt
//    T3  quint run --main=apex --invariant=inv_all ...              (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: apexBootstrapMint(4000, 9000) = 5000.  The obligation is the TRACE
//        that violates `wit_live_apexBootstrapMint`: a reachable state with
//        reserveBase 4000, reserveQuote 9000, lpSupply 6000, address(0) holding
//        1000 and one LP holding 5000.  Under M1 the same call gives 4000 with
//        nothing locked, so the state is unreachable.
// =============================================================================
module apex {
  import kernel.* from "../kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// Amm.sol:24
  pure val MINIMUM_LIQUIDITY: int = 1000
  /// Amm.sol:475-477 — amountInWithFee = amountIn * 999; denom = rIn*1000 + it
  pure val FEE_NUM: int = 999
  pure val FEE_DEN: int = 1000
  /// Config.sol:11 — 50-200, 100 means 1.0
  pure val BETA: int = 120
  /// Config.sol:16
  pure val INIT_MARGIN_RATIO: int = 800
  /// Config.sol:17 — debt ratio >= this is liquidatable
  pure val LIQUIDATE_THRESHOLD: int = 10000
  /// Config.sol:18 — 100 means the liquidator bot takes 1%
  pure val LIQUIDATE_FEE_RATIO: int = 100
  /// Config.sol:20, :21 — used by Amm.maxWithdrawCheck (:182-189)
  pure val LP_WITHDRAW_NET: int = 10
  pure val LP_WITHDRAW_TOTAL: int = 50
  /// the basis-point denominator every Config ratio is quoted against
  pure val RATIO_DEN: int = 10000
  /// Amm._update's uint112 guard, descaled.  See BOUNDS.
  pure val MAX_RESERVE: int = 100000

  /// Amm.sol:97 — address(0), holder of the permanent lock.
  pure val LOCK: str = "addressZero"
  pure val USERS: Set[str] = Set("alice", "bob")
  pure val ACCOUNTS: Set[str] = USERS.union(Set(LOCK))

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN D (convention 8a; see BOUNDS for 8b and 8c)
  //
  // ONE range, per P2-CARRYFORWARD Flag A: P2-CONTRACT §C row 6's two ranges
  // (swap reserves [100,2000], mint amounts [1000,20000]) are mutually
  // unreachable, because once the sqrt bootstrap has run the reserves are >=
  // 4000 and never re-enter [100,2000].  Mints are drawn as (baseAmount,
  // oracleQuote) PAIRS so that the MINIMUM_LIQUIDITY crossing is one branch
  // rather than a product of two.
  // ---------------------------------------------------------------------------

  pure val MINTS: Set[(int, int)] = Set(
    (4000, 9000), (1000, 1000), (1000, 2000), (2000, 8000), (20000, 20000),
  )
  pure val QTYS: Set[int] = Set(500, 1000, 2000, 3000)
  pure val MARGINS: Set[int] = Set(500, 2000, 4000)
  pure val LP_BURNS: Set[int] = Set(1000, 5000)

  pure val INIT_RESERVE: int = 0
  pure val INIT_SUPPLY: int = 0
  pure val INIT_LP: int = 0
  pure val INIT_SIZE: int = 0
  pure val INIT_TOTAL: int = 0
  pure val INIT_VAULT: int = 0
  pure val INIT_K: int = 0

  pure val OP_INIT: str = "init"
  pure val OP_MINT: str = "mint"
  pure val OP_BURN: str = "burn"
  pure val OP_ADDMARGIN: str = "addMargin"
  pure val OP_OPENLONG: str = "openLong"
  pure val OP_OPENSHORT: str = "openShort"
  pure val OP_CLOSE: str = "closePosition"
  pure val OP_LIQUIDATE: str = "liquidate"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var reserveBase: int          // Amm.baseReserve
  var reserveQuote: int         // Amm.quoteReserve
  var lpSupply: int             // LiquidityERC20.totalSupply
  var lpBal: str -> int         // LiquidityERC20.balanceOf
  var quoteSize: str -> int     // Position.quoteSize, signed
  var baseSize: str -> int      // Position.baseSize, signed
  var totalQuoteLong: int       // Margin.totalQuoteLong
  var totalQuoteShort: int      // Margin.totalQuoteShort
  var vaultBase: int            // Margin.reserve
  var lastOp: str               // GHOST — trace label, see header
  var kBefore: int              // GHOST — reserve product before this action

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  // ===========================================================================

  /// Amm.sol:467-478.  `amountInWithFee = amountIn * 999` and the denominator
  /// carries the unfee'd `reserveIn * 1000`, so the pool keeps one part in a
  /// thousand of every input.  This is D-1: v1's `y*dx/(x+dx)` is this with
  /// 999 replaced by 1000, and the two AGREE at ordinary trade sizes.
  pure def ammAmountOut(amountIn: int, reserveIn: int, reserveOut: int): int =
    mulDivDown(reserveOut, amountIn, reserveIn + amountIn)

  /// Amm.sol:481-492.  The exact-output side: `reserveIn*amountOut*1000 /
  /// ((reserveOut - amountOut)*999) + 1`.  The `+ 1` is an unconditional
  /// round-up in the pool's favour and is a rounding direction, not a detail —
  /// it is what makes the fee visible on EXIT, which v1 has no path for at all.
  pure def ammAmountIn(amountOut: int, reserveIn: int, reserveOut: int): int =
    mulDivDown(reserveIn, amountOut * FEE_DEN, (reserveOut - amountOut) * FEE_NUM) + 1

  /// Amm.sol:96 — the FIRST deposit only.  Same geometric mean as
  /// UniswapV2Pair:120; the quote side comes from the oracle (:92) because an
  /// empty pool has no price of its own.  A negative result is SafeMath
  /// reverting, and :103's `require(liquidity > 0)` is exactly that refusal.
  pure def apexBootstrapMint(baseAmount: int, quoteAmount: int): int =
    baseAmount + 0 * quoteAmount

  /// Amm.sol:100 — every later deposit, PRO RATA AGAINST realBaseReserve, not
  /// against baseReserve.  The distinction is the whole of D-6's sibling: an LP
  /// joining a pool that is already net-long is diluted by the position.
  pure def apexProportionalMint(baseAmount: int, supply: int, realBase: int): int =
    mulDivDown(baseAmount, supply, realBase)

  /// Amm.sol:151 — `baseAmount = liquidity * realBaseReserve / totalSupply`.
  pure def apexBurnBase(liquidity: int, realBase: int, supply: int): int =
    mulDivDown(liquidity, realBase, supply)

  /// Amm.sol:192-219.  `netPosition = totalQuoteShort - totalQuoteLong`
  /// (Margin.sol:507-510).  Net LONG (negative) means the pool is short and must
  /// buy the quote back, so the base it really holds is larger; net SHORT the
  /// reverse.  Both branches are the same `_estimateSwap` the traders use.
  pure def apexRealBaseReserve(base: int, quote: int, netPosition: int): int =
    if (netPosition == 0) base
    else if (netPosition < 0) base + ammAmountIn(0 - netPosition, base, quote)
    else base - ammAmountOut(netPosition, quote, base)

  /// PriceOracle.sol:280 — SLIPPAGE_TOO_LARGE.  Also what keeps the squared
  /// denominator below strictly positive, so every call site guards on it.
  pure def markPriceAccOk(quoteAmount: int, quote: int): bool =
    quoteAmount * BETA * 2 / 100 < quote

  /// PriceOracle.sol:283-295 — THE RESTORED DEPENDENCY (D-6 / hole H1).
  ///   price      = (y +/- beta*quoteAmount)^2 / (x*y)
  ///   baseAmount = quoteAmount * x * y / (y +/- beta*quoteAmount/100)^2
  /// `negative` is the close-a-long simulation, which skews the price DOWN so
  /// the debt is overvalued; `false` is close-a-short and skews it up.  The size
  /// enters twice — once as a factor and once inside the squared denominator —
  /// so this is not homogeneous of degree 0 in the position, and that is exactly
  /// what an exogenous scalar `markPrice` cannot reproduce.
  pure def markPriceAccBase(quoteAmount: int, base: int, quote: int,
                            negative: bool): int = {
    val rvalue = mulDivDown(quoteAmount, BETA, 100)
    val den = if (negative) quote - rvalue else quote + rvalue
    mulDivDown(quoteAmount, base * quote, den * den)
  }

  /// Margin.sol:608-636.  Four branches, all four kept (convention 6f):
  ///   flat, or a short fully covered in base            -> 0
  ///   a long whose base is gone                         -> RATIO_DEN
  ///   a short (quoteSize > 0, baseSize < 0)             -> |bs|*1e4 / mpa(+)
  ///   a long  (quoteSize < 0, baseSize > 0)             -> mpa(-)*1e4 / |bs|
  pure def debtRatio(qs: int, bs: int, base: int, quote: int): int =
    if (qs == 0 or (qs > 0 and bs >= 0)) 0
    else if (qs < 0 and bs <= 0) RATIO_DEN
    else if (qs > 0) {
      val b = markPriceAccBase(absInt(qs), base, quote, false)
      if (b == 0) RATIO_DEN else mulDivDown(absInt(bs), RATIO_DEN, b)
    } else {
      val b = markPriceAccBase(absInt(qs), base, quote, true)
      mulDivDown(b, RATIO_DEN, absInt(bs))
    }

  /// Margin.sol:273-276.  A revert inside `getMarkPriceAcc` disables the call,
  /// so a position whose size exceeds the oracle's slippage bound cannot be
  /// liquidated at these reserves — modelled, not silently ignored.
  pure def positionLiquidatable(qs: int, bs: int, base: int, quote: int): bool =
    if (qs == 0 or (qs > 0 and bs >= 0)) false
    else if (qs < 0 and bs <= 0) true
    else if (markPriceAccOk(absInt(qs), quote))
      debtRatio(qs, bs, base, quote) >= LIQUIDATE_THRESHOLD
    else false

  /// Margin.sol:198-201 (WILL_BE_LIQUIDATED) and :224-228 (DEBT_RATIO_OVER).
  /// Not the negation of `positionLiquidatable`: a slippage revert refuses BOTH,
  /// which is what a revert means.
  pure def debtRatioOk(qs: int, bs: int, base: int, quote: int): bool =
    if (qs == 0 or (qs > 0 and bs >= 0)) true
    else if (qs < 0 and bs <= 0) false
    else if (markPriceAccOk(absInt(qs), quote))
      debtRatio(qs, bs, base, quote) < LIQUIDATE_THRESHOLD
    else false

  /// The two branches of `_calDebtRatio` that actually CALL `getMarkPriceAcc`
  /// (:613-634), separated from the two that short-circuit to 0 or to RATIO_DEN
  /// (:609-612).  A witness that only reaches the short-circuits would prove the
  /// trigger fired and NOT that the restored dependency was consulted, which is
  /// the fifth trap one level down.
  pure def liquidatableByMarkPrice(qs: int, bs: int, base: int, quote: int): bool =
    if ((qs < 0 and bs > 0) or (qs > 0 and bs < 0))
      if (markPriceAccOk(absInt(qs), quote))
        debtRatio(qs, bs, base, quote) >= LIQUIDATE_THRESHOLD
      else false
    else false

  /// Margin.sol:159-161 — the initial-margin cap on position size, in quote.
  ///   quoteReserve*10000*q / (initMarginRatio*quoteReserve + 200*q*beta)
  /// where q is the margin valued through the pool.  Endogenous in the reserves.
  pure def quoteAmountMax(marginQuote: int, quote: int): int =
    mulDivDown(quote, RATIO_DEN * marginQuote,
               INIT_MARGIN_RATIO * quote + 200 * marginQuote * BETA)

  /// Margin.sol:316 — the keeper's cut of whatever is left after the close.
  pure def liquidateBonus(remainBase: int): int =
    mulDivDown(absInt(remainBase), LIQUIDATE_FEE_RATIO, RATIO_DEN)

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed
  //  from the cited Solidity line in integer arithmetic.  [SEP] marks a value
  //  the v1 shortcut cannot produce.
  // ===========================================================================

  // -- ammAmountOut (Amm.sol:467-478); P2-CONTRACT §A.6 rows 1-3 --------------
  pure val t0_ao_a: bool = ammAmountOut(100, 100, 100) == 49        // [SEP] v1 50
  pure val t0_ao_b: bool = ammAmountOut(50, 200, 200) == 39         // [SEP] v1 40
  pure val t0_ao_c: bool = ammAmountOut(200, 200, 100) == 49        // [SEP] v1 50
  /// 8c, the recorded finding: at this size the fee is INVISIBLE — the zero-fee
  /// form returns 166 as well.  A "safe small trade" domain deletes the fee.
  pure val t0_ao_d: bool = ammAmountOut(200, 1000, 1000) == 166
  pure val t0_ao_e: bool = ammAmountOut(1000, 1000, 1000) == 499    // [SEP] v1 500
  pure val t0_ao_f: bool = ammAmountOut(4000, 4000, 9000) == 4497   // [SEP] v1 4500
  pure val t0_ao_g: bool = ammAmountOut(1000, 9000, 4000) == 399    // [SEP] v1 400

  // -- ammAmountIn (Amm.sol:481-492); 6c, the `+1` round-up -------------------
  pure val t0_ai_a: bool = ammAmountIn(100, 1000, 1000) == 112      // [SEP] v1 111
  pure val t0_ai_b: bool = ammAmountIn(1000, 4000, 9000) == 501     // [SEP] v1 500
  pure val t0_ai_c: bool = ammAmountIn(2000, 4000, 9000) == 1145    // [SEP] v1 1142
  pure val t0_ai_d: bool = ammAmountIn(1000, 3601, 10000) == 401

  // -- apexBootstrapMint (Amm.sol:96); 8c on MINIMUM_LIQUIDITY (6f both sides) -
  pure val t0_bm_a: bool = apexBootstrapMint(4000, 9000) == 5000    // [SEP] v1 4000
  pure val t0_bm_b: bool = apexBootstrapMint(2000, 8000) == 3000    // [SEP] v1 2000
  pure val t0_bm_c: bool = apexBootstrapMint(1000, 2000) == 414     // [SEP] v1 1000
  pure val t0_bm_d: bool = apexBootstrapMint(1000, 1000) == 0       // == MIN_LIQ
  pure val t0_bm_e: bool = apexBootstrapMint(900, 900) == -100      // <  MIN_LIQ

  // -- apexProportionalMint / apexBurnBase / apexRealBaseReserve --------------
  /// The pair that shows realBaseReserve is load-bearing: the same deposit into
  /// the same pool mints 1499 against the real base 4002 and 1666 against the
  /// raw reserve 3601.  v1 has no netPosition adjustment at all.
  pure val t0_pm_a: bool = apexProportionalMint(1000, 6000, 4002) == 1499
  pure val t0_pm_b: bool = apexProportionalMint(1000, 6000, 3601) == 1666
  pure val t0_rb_a: bool = apexRealBaseReserve(3601, 10000, -1000) == 4002
  pure val t0_rb_b: bool = apexRealBaseReserve(3601, 10000, 0) == 3601
  pure val t0_rb_c: bool = apexRealBaseReserve(5145, 7000, 2000) == 4003
  pure val t0_bb_a: bool = apexBurnBase(1000, 4002, 6000) == 667    // 667.0
  pure val t0_bb_b: bool = apexBurnBase(5000, 4002, 6000) == 3335   // 3335.0

  // -- markPriceAccBase (PriceOracle.sol:283-295) -----------------------------
  pure val t0_mp_a: bool = markPriceAccBase(1000, 4000, 9000, true) == 591
  pure val t0_mp_b: bool = markPriceAccBase(2000, 4000, 9000, true) == 1652
  pure val t0_mp_c: bool = markPriceAccBase(3000, 4000, 9000, true) == 3703
  pure val t0_mp_d: bool = markPriceAccBase(1000, 4000, 9000, false) == 346
  pure val t0_mp_e: bool = markPriceAccOk(3000, 9000)
  pure val t0_mp_f: bool = not(markPriceAccOk(4000, 9000))

  // -- debtRatio (Margin.sol:608-636), all four branches (6f) -----------------
  pure val t0_dr_a: bool = debtRatio(-1000, 2000, 4000, 9000) == 2955
  pure val t0_dr_b: bool = debtRatio(0, 5000, 4000, 9000) == 0
  pure val t0_dr_c: bool = debtRatio(1000, 500, 4000, 9000) == 0
  pure val t0_dr_d: bool = debtRatio(-1000, -100, 4000, 9000) == RATIO_DEN
  pure val t0_dr_e: bool = debtRatio(1000, -600, 4000, 9000) == 17341

  // -- HOLE H1, as two vectors.  Same reserves, same baseSize/|quoteSize| ratio,
  //    DIFFERENT liquidatability.  Any exogenous scalar markPrice — v1's
  //    `canLiquidate(p, markPrice, MAINT_BPS)` — is homogeneous of degree 0 in
  //    the position and must return the same verdict for both.  These two
  //    vectors are the whole of H1 and they cannot both be satisfied by it.
  pure val t0_dr_f: bool = debtRatio(-3000, 3000, 4000, 9000) == 12343
  pure val t0_dr_g: bool = debtRatio(-1000, 1000, 4000, 9000) == 5910
  pure val t0_h1_a: bool = not(positionLiquidatable(-1000, 1000, 4000, 9000))
  pure val t0_h1_b: bool = positionLiquidatable(-3000, 3000, 4000, 9000)

  // -- quoteAmountMax (Margin.sol:159-161) and liquidateBonus (:316) ----------
  pure val t0_qm_a: bool = quoteAmountMax(2998, 9000) == 3408
  pure val t0_qm_b: bool = quoteAmountMax(1000, 9000) == 2884
  pure val t0_lb_a: bool = liquidateBonus(2398) == 23              // 23.98 -> 23
  pure val t0_lb_b: bool = liquidateBonus(50) == 0                 // 8c: fee 0

  pure val inv_T0: bool = and {
    t0_ao_a, t0_ao_b, t0_ao_c, t0_ao_d, t0_ao_e, t0_ao_f, t0_ao_g,
    t0_ai_a, t0_ai_b, t0_ai_c, t0_ai_d,
    t0_bm_a, t0_bm_b, t0_bm_c, t0_bm_d, t0_bm_e,
    t0_pm_a, t0_pm_b, t0_rb_a, t0_rb_b, t0_rb_c, t0_bb_a, t0_bb_b,
    t0_mp_a, t0_mp_b, t0_mp_c, t0_mp_d, t0_mp_e, t0_mp_f,
    t0_dr_a, t0_dr_b, t0_dr_c, t0_dr_d, t0_dr_e, t0_dr_f, t0_dr_g,
    t0_h1_a, t0_h1_b,
    t0_qm_a, t0_qm_b, t0_lb_a, t0_lb_b,
  }

  // ===========================================================================
  //  DERIVED STATE READERS
  // ===========================================================================

  val netPosition: int = totalQuoteShort - totalQuoteLong
  val realBaseReserve: int =
    apexRealBaseReserve(reserveBase, reserveQuote, netPosition)
  val currentK: int = reserveBase * reserveQuote

  /// Amm.sol:182-189 — an LP may not withdraw so much quote that the outstanding
  /// net and total positions exceed their thresholds against what is left.
  pure def maxWithdrawOk(quoteLeft: int, netAbs: int, totalPos: int): bool = and {
    netAbs * 100 <= quoteLeft * LP_WITHDRAW_NET,
    totalPos * 100 <= quoteLeft * LP_WITHDRAW_TOTAL,
  }

  /// Amm.sol:106-114 and :159-166 — the price before and after must agree to
  /// within one part in a thousand, in both directions.
  pure def priceUnchanged(b0: int, q0: int, b1: int, q1: int): bool = and {
    b1 * q0 * FEE_NUM <= q1 * b0 * FEE_DEN,
    q1 * b0 * FEE_DEN <= b1 * q0 * (FEE_DEN + 1),
  }

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    reserveBase' = INIT_RESERVE,
    reserveQuote' = INIT_RESERVE,
    lpSupply' = INIT_SUPPLY,
    lpBal' = ACCOUNTS.mapBy(_ => INIT_LP),
    quoteSize' = ACCOUNTS.mapBy(_ => INIT_SIZE),
    baseSize' = ACCOUNTS.mapBy(_ => INIT_SIZE),
    totalQuoteLong' = INIT_TOTAL,
    totalQuoteShort' = INIT_TOTAL,
    vaultBase' = INIT_VAULT,
    lastOp' = OP_INIT,
    kBefore' = INIT_K,
  }

  /// Amm.mint (:68-125).  The pool starts EMPTY, which is what makes :96 the
  /// live branch — D-5.  The quote side of the first deposit comes from the
  /// oracle (:92); every later deposit is priced by the pool itself (:99) and
  /// sized against realBaseReserve (:101).
  action mint(recipient: str, baseAmount: int, oracleQuote: int): bool = all {
    USERS.contains(recipient),
    baseAmount > 0,
    val bootstrap = lpSupply == 0
    val quoteAmount = if (bootstrap) oracleQuote
                      else mulDivDown(baseAmount, reserveQuote, reserveBase)
    val liquidity = if (bootstrap) apexBootstrapMint(baseAmount, quoteAmount)
                    else apexProportionalMint(baseAmount, lpSupply, realBaseReserve)
    val locked = if (bootstrap) 0 else 0
    val b1 = reserveBase + baseAmount
    val q1 = reserveQuote + quoteAmount
    all {
      quoteAmount > 0,
      liquidity > 0,
      b1 <= MAX_RESERVE,
      q1 <= MAX_RESERVE,
      bootstrap or priceUnchanged(reserveBase, reserveQuote, b1, q1),
      reserveBase' = b1,
      reserveQuote' = q1,
      lpSupply' = lpSupply + liquidity + locked,
      lpBal' = lpBal.put(LOCK, lpBal.get(LOCK) + locked)
        .put(recipient, lpBal.get(recipient) + liquidity),
      quoteSize' = quoteSize,
      baseSize' = baseSize,
      totalQuoteLong' = totalQuoteLong,
      totalQuoteShort' = totalQuoteShort,
      vaultBase' = vaultBase + baseAmount,
      lastOp' = OP_MINT,
      kBefore' = currentK,
    }
  }

  /// Amm.burn (:129-174).  The LP exit v1 has no path for at all — D-4.  Sized
  /// against realBaseReserve, gated by maxWithdrawCheck and by the same
  /// price-invariance pair as mint.
  action burn(holder: str, liquidity: int): bool = all {
    USERS.contains(holder),
    liquidity > 0,
    lpBal.get(holder) >= liquidity,
    lpSupply > liquidity,
    reserveBase > 0,
    val baseAmount = apexBurnBase(liquidity, realBaseReserve, lpSupply)
    val quoteAmount = mulDivDown(baseAmount, reserveQuote, reserveBase)
    val b1 = reserveBase - baseAmount
    val q1 = reserveQuote - quoteAmount
    all {
      baseAmount > 0,
      quoteAmount > 0,
      b1 > 0,
      q1 > 0,
      vaultBase >= baseAmount,
      maxWithdrawOk(q1, absInt(netPosition), totalQuoteLong + totalQuoteShort),
      priceUnchanged(reserveBase, reserveQuote, b1, q1),
      reserveBase' = b1,
      reserveQuote' = q1,
      lpSupply' = lpSupply - liquidity,
      lpBal' = lpBal.put(holder, lpBal.get(holder) - liquidity),
      quoteSize' = quoteSize,
      baseSize' = baseSize,
      totalQuoteLong' = totalQuoteLong,
      totalQuoteShort' = totalQuoteShort,
      vaultBase' = vaultBase - baseAmount,
      lastOp' = OP_BURN,
      kBefore' = currentK,
    }
  }

  /// Margin.addMargin (:50-61).  Base collateral into the vault; the position's
  /// baseSize is what the vault credits.
  action addMargin(trader: str, amount: int): bool = all {
    USERS.contains(trader),
    amount > 0,
    reserveBase' = reserveBase,
    reserveQuote' = reserveQuote,
    lpSupply' = lpSupply,
    lpBal' = lpBal,
    quoteSize' = quoteSize,
    baseSize' = baseSize.put(trader, baseSize.get(trader) + amount),
    totalQuoteLong' = totalQuoteLong,
    totalQuoteShort' = totalQuoteShort,
    vaultBase' = vaultBase + amount,
    lastOp' = OP_ADDMARGIN,
    kBefore' = currentK,
  }

  /// Margin.openPosition side 0 (:111-206) through `_addPositionWithAmm`
  /// (:399-411): quote INTO the pool, base out.  quoteSize goes negative.
  /// `marginAcc` (:128-149) values the existing position by simulating its close
  /// against the pool, and `quoteAmountMax` (:159-161) caps the new size by it.
  /// The final require (:198-201) is evaluated at the UPDATED reserves.
  action openLong(trader: str, qty: int): bool = all {
    USERS.contains(trader),
    qty > 0,
    reserveBase > 0,
    reserveQuote > 0,
    quoteSize.get(trader) <= 0,
    val qs = quoteSize.get(trader)
    val bs = baseSize.get(trader)
    val marginAcc = if (qs == 0) bs
                    else bs - ammAmountIn(absInt(qs), reserveBase, reserveQuote)
    val baseOut = ammAmountOut(qty, reserveQuote, reserveBase)
    val b1 = reserveBase - baseOut
    val q1 = reserveQuote + qty
    val newQs = qs - qty
    val newBs = bs + baseOut
    all {
      marginAcc > 0,
      baseOut > 0,
      baseOut < reserveBase,
      q1 <= MAX_RESERVE,
      absInt(qs) < reserveQuote,
      absInt(newQs) <= quoteAmountMax(ammAmountOut(marginAcc, reserveBase, reserveQuote),
                                      reserveQuote),
      markPriceAccOk(absInt(newQs), q1),
      debtRatioOk(newQs, newBs, b1, q1),
      reserveBase' = b1,
      reserveQuote' = q1,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
      quoteSize' = quoteSize.put(trader, newQs),
      baseSize' = baseSize.put(trader, newBs),
      totalQuoteLong' = totalQuoteLong + qty,
      totalQuoteShort' = totalQuoteShort,
      vaultBase' = vaultBase,
      lastOp' = OP_OPENLONG,
      kBefore' = currentK,
    }
  }

  /// Margin.openPosition side 1 (:111-206).  `_getSwapParam(true, ·)` puts the
  /// pool on the exact-OUTPUT side, so the cost is `_getAmountIn` with its `+1`
  /// and the base leg is a debit: baseSize goes down, and can go negative.
  action openShort(trader: str, qty: int): bool = all {
    USERS.contains(trader),
    qty > 0,
    reserveBase > 0,
    reserveQuote > 0,
    quoteSize.get(trader) >= 0,
    qty < reserveQuote,
    val qs = quoteSize.get(trader)
    val bs = baseSize.get(trader)
    val marginAcc = if (qs == 0) bs
                    else bs + ammAmountOut(absInt(qs), reserveQuote, reserveBase)
    val baseIn = ammAmountIn(qty, reserveBase, reserveQuote)
    val b1 = reserveBase + baseIn
    val q1 = reserveQuote - qty
    val newQs = qs + qty
    val newBs = bs - baseIn
    all {
      marginAcc > 0,
      baseIn > 0,
      b1 <= MAX_RESERVE,
      q1 > 0,
      absInt(newQs) <= quoteAmountMax(ammAmountOut(marginAcc, reserveBase, reserveQuote),
                                      reserveQuote),
      markPriceAccOk(absInt(newQs), q1),
      debtRatioOk(newQs, newBs, b1, q1),
      reserveBase' = b1,
      reserveQuote' = q1,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
      quoteSize' = quoteSize.put(trader, newQs),
      baseSize' = baseSize.put(trader, newBs),
      totalQuoteLong' = totalQuoteLong,
      totalQuoteShort' = totalQuoteShort + qty,
      vaultBase' = vaultBase,
      lastOp' = OP_OPENSHORT,
      kBefore' = currentK,
    }
  }

  /// Margin.closePosition (:208-251) — D-4, the exit v1 does not have.  The
  /// same pool, the same 999/1000, the opposite direction; :242-245 pushes any
  /// remaining base shortfall back into the pool through `forceSwap`, which is
  /// how a loss reaches the LPs.
  action closePosition(trader: str, qty: int): bool = all {
    USERS.contains(trader),
    qty > 0,
    reserveBase > 0,
    reserveQuote > 0,
    quoteSize.get(trader) != 0,
    qty <= absInt(quoteSize.get(trader)),
    val qs = quoteSize.get(trader)
    val bs = baseSize.get(trader)
    val isLong = qs < 0
    val baseAmount = if (isLong) ammAmountIn(qty, reserveBase, reserveQuote)
                     else ammAmountOut(qty, reserveQuote, reserveBase)
    val newQs = if (isLong) qs + qty else qs - qty
    val midBs = if (isLong) bs - baseAmount else bs + baseAmount
    val shortfall = newQs == 0 and midBs < 0
    val mb = if (isLong) reserveBase + baseAmount else reserveBase - baseAmount
    val mq = if (isLong) reserveQuote - qty else reserveQuote + qty
    val b1 = if (shortfall) mb - absInt(midBs) else mb
    val newBs = if (shortfall) 0 else midBs
    all {
      qty < reserveQuote,
      markPriceAccOk(absInt(qs), reserveQuote),
      debtRatioOk(qs, bs, reserveBase, reserveQuote),
      baseAmount > 0,
      b1 > 0,
      b1 <= MAX_RESERVE,
      mq > 0,
      mq <= MAX_RESERVE,
      reserveBase' = b1,
      reserveQuote' = mq,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
      quoteSize' = quoteSize.put(trader, newQs),
      baseSize' = baseSize.put(trader, newBs),
      totalQuoteLong' = if (isLong) totalQuoteLong - qty else totalQuoteLong,
      totalQuoteShort' = if (isLong) totalQuoteShort else totalQuoteShort - qty,
      vaultBase' = vaultBase,
      lastOp' = OP_CLOSE,
      kBefore' = currentK,
    }
  }

  /// Margin.liquidate (:253-300) and `_executeSettle` (:302-362) — D-3 and D-6
  /// together.  The trigger is `debtRatio` at the LIVE reserves, and the
  /// settlement is a real trade: the whole position goes back through
  /// `forceSwap`, the keeper takes `liquidateBonus` out of the vault, and with
  /// `feeTo == address(0)` whatever is left is pushed into the pool as well.
  /// `target` is calldata: any address may call this on any trader, and the
  /// protocol decides by REVERTING, not by selecting.  See LINT below.
  action liquidate(target: str): bool = all {
    USERS.contains(target),
    reserveBase > 0,
    reserveQuote > 0,
    quoteSize.get(target) != 0,
    positionLiquidatable(quoteSize.get(target), baseSize.get(target),
                         reserveBase, reserveQuote),
    val qs = quoteSize.get(target)
    val bs = baseSize.get(target)
    val isLong = qs < 0
    val qty = absInt(qs)
    val baseAmount = if (isLong) ammAmountIn(qty, reserveBase, reserveQuote)
                     else ammAmountOut(qty, reserveQuote, reserveBase)
    val remain = if (isLong) bs - baseAmount else bs + baseAmount
    val bonus = if (remain >= 0) liquidateBonus(remain) else 0
    val settleBase = if (remain >= 0) baseAmount + remain - bonus else absInt(bs)
    val b1 = if (isLong) reserveBase + settleBase else reserveBase - settleBase
    val q1 = if (isLong) reserveQuote - qty else reserveQuote + qty
    all {
      qty < reserveQuote,
      baseAmount > 0,
      b1 > 0,
      b1 <= MAX_RESERVE,
      q1 > 0,
      q1 <= MAX_RESERVE,
      vaultBase >= bonus,
      reserveBase' = b1,
      reserveQuote' = q1,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
      quoteSize' = quoteSize.put(target, 0),
      baseSize' = baseSize.put(target, 0),
      totalQuoteLong' = if (isLong) totalQuoteLong - qty else totalQuoteLong,
      totalQuoteShort' = if (isLong) totalQuoteShort else totalQuoteShort - qty,
      vaultBase' = vaultBase - bonus,
      lastOp' = OP_LIQUIDATE,
      kBefore' = currentK,
    }
  }

  /// Convention 6 / 6g: every `nondet` is exogenous — a transaction sender, a
  /// calldata amount, or an external oracle return.  Nothing the protocol itself
  /// computes is drawn here; in particular there is no `nondet price`, which is
  /// what v1 had and what 6g forbids.
  action step: bool = {
    nondet caller = USERS.oneOf()
    nondet target = USERS.oneOf()
    nondet mintPair = MINTS.oneOf()
    nondet qty = QTYS.oneOf()
    nondet margin = MARGINS.oneOf()
    nondet lpBurn = LP_BURNS.oneOf()
    any {
      mint(caller, mintPair._1, mintPair._2),
      burn(caller, lpBurn),
      addMargin(caller, margin),
      openLong(caller, qty),
      openShort(caller, qty),
      closePosition(caller, qty),
      liquidate(target),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — LP shares are neither created nor destroyed outside mint and
  /// burn, and the permanently locked 1000 is counted.  T2's invariant.
  val inv_conservation: bool =
    ACCOUNTS.fold(0, (acc, a) => acc + lpBal.get(a)) == lpSupply

  val inv_bounds: bool = and {
    reserveBase >= 0,
    reserveQuote >= 0,
    reserveBase <= MAX_RESERVE,
    reserveQuote <= MAX_RESERVE,
    lpSupply >= 0,
    vaultBase >= 0,
    totalQuoteLong >= 0,
    totalQuoteShort >= 0,
    ACCOUNTS.forall(a => lpBal.get(a) >= 0),
  }

  /// Amm.sol:97 — the lock is minted once, to an account with no burn path, so
  /// once the pool exists the supply can never fall below it.  v1 has neither
  /// the lock nor an account to hold it.
  val inv_permanentLock: bool =
    lpSupply > 0 implies and {
      lpBal.get(LOCK) == MINIMUM_LIQUIDITY,
      lpSupply >= MINIMUM_LIQUIDITY,
    }

  /// The outstanding position totals are the sum of the individual positions,
  /// which is what makes `netPosition` — and through it `realBaseReserve` — an
  /// honest reading of the book rather than a free variable.
  val inv_positionTotals: bool = and {
    totalQuoteLong == USERS.fold(0, (acc, u) =>
      acc + (if (quoteSize.get(u) < 0) absInt(quoteSize.get(u)) else 0)),
    totalQuoteShort == USERS.fold(0, (acc, u) =>
      acc + (if (quoteSize.get(u) > 0) quoteSize.get(u) else 0)),
  }

  /// P2-SCOPE §5 row 6 asks for `inv_kMonotone`: the reserve product never falls
  /// across a swap.  TRUE, and it is exactly the 999/1000 — but it is true only
  /// for the OPENING trades.  A close that settles a shortfall (:242-245) and a
  /// liquidation of an underwater position (:340-357) both push LESS base back
  /// into the pool than the position owed, so k FALLS, and that is the bad debt
  /// reaching the LPs.  Scoping the invariant to the opens is the correction;
  /// the falling side is not swept up, it is asserted as `wit_kFellOnSettlement`.
  val inv_kMonotone: bool =
    (lastOp == OP_OPENLONG or lastOp == OP_OPENSHORT)
      implies currentK >= kBefore

  /// The vault holds real base tokens; it is credited by addMargin and by
  /// Amm.mint's `IVault.deposit` (:123) and debited by burn and by the keeper
  /// bonus (:294).  It may never go negative.
  val inv_vaultSolvent: bool = vaultBase >= 0

  /// The trigger is a function of the LIVE reserves, so a position admitted at
  /// one state can be liquidatable at the next without anybody touching it.
  /// That is the mechanism, not a defect, and it is why there is no invariant
  /// here saying "no trader is ever liquidatable" — such an invariant is what a
  /// spec with an inert `liquidate` and an exogenous price can afford to have.
  /// The corresponding positive obligation is `wit_used_markPriceAccBase`.

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_permanentLock,
    inv_positionTotals,
    inv_kMonotone,
    inv_vaultSolvent,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (§D, the fifth trap).
  //  Each must be VIOLATED by `quint run --invariant=<name>`.
  // ===========================================================================

  pure val T0_LIVE_BASE: int = 4000
  pure val T0_LIVE_QUOTE: int = 9000
  pure val T0_LIVE_SUPPLY: int = 6000
  pure val T0_LIVE_LP: int = 5000

  /// T0-LIVE: apexBootstrapMint(4000, 9000) = 5000 as a state change, with 1000
  /// permanently locked.  Under M1 (`newShares = baseIn`) the same call gives
  /// 4000, nothing is locked and lpSupply is 4000, so this state is unreachable —
  /// and in v1 the branch is not even evaluated, because `lpShares` is seeded at
  /// 100.  Depth 1 from init.
  val wit_live_apexBootstrapMint: bool =
    not(and {
      reserveBase == T0_LIVE_BASE,
      reserveQuote == T0_LIVE_QUOTE,
      lpSupply == T0_LIVE_SUPPLY,
      lpBal.get(LOCK) == MINIMUM_LIQUIDITY,
      USERS.exists(u => lpBal.get(u) == T0_LIVE_LP),
    })

  /// `apexBootstrapMint` ran and the TRUNCATION was load-bearing: supply is the
  /// strict floor of sqrt(k) plus the lock.  False for ceil-sqrt (M4) and for
  /// any linear rival (M1, M3).
  val wit_used_apexBootstrapMint: bool =
    not(and {
      lpSupply > MINIMUM_LIQUIDITY,
      lpSupply == isqrtFloor(currentK),
      lpSupply * lpSupply < currentK,
    })

  /// `ammAmountOut` ran: the reserve product has risen strictly above what it
  /// was before the action, which only the 999/1000 can do.  Under the fee-free
  /// v1 form k is preserved exactly on every open, so this is unreachable.
  val wit_used_ammAmountOut: bool =
    not(and { lastOp == OP_OPENLONG, currentK > kBefore })

  /// `ammAmountIn` ran, on the EXIT side: a short was opened, which puts the
  /// pool on the exact-output leg, and the `+1` round-up means k rose there too.
  val wit_used_ammAmountIn: bool =
    not(and { lastOp == OP_OPENSHORT, currentK > kBefore })

  /// `apexProportionalMint` ran: both users hold LP shares, and only one of them
  /// can have taken the bootstrap branch.  Discharges regression signal 7.
  val wit_used_apexProportionalMint: bool =
    not(USERS.forall(u => lpBal.get(u) > 0))

  /// `apexRealBaseReserve` ran on a NON-ZERO net position — its second or third
  /// branch, the one that distinguishes it from `reserveBase`.  The tag pins
  /// which action was evaluating it; the net-position condition pins which
  /// branch inside it, so this is not a tag-only witness.
  val wit_used_apexRealBaseReserve: bool =
    not(and { lastOp == OP_MINT, lpSupply > 0, netPosition != 0 })

  /// `apexBurnBase` ran: an LP left.  v1 has no burn path at all, so any state
  /// whose supply has fallen below its own high-water mark is out of reach for
  /// it; here the observable is that a user holds strictly less than the pool's
  /// non-locked supply while the lock is intact.
  val wit_used_apexBurnBase: bool =
    not(and { lastOp == OP_BURN, lpSupply > MINIMUM_LIQUIDITY })

  /// `markPriceAccBase` and `debtRatio` ran and the TRIGGER FIRED: some trader
  /// is liquidatable at the live reserves THROUGH THE PRICED BRANCH, not through
  /// `_calDebtRatio`'s two short-circuits.  No exogenous price was involved; the
  /// verdict is a function of the reserves and of the position's own size.
  val wit_used_markPriceAccBase: bool =
    not(USERS.exists(u =>
      liquidatableByMarkPrice(quoteSize.get(u), baseSize.get(u),
                              reserveBase, reserveQuote)))

  /// HOLE H1, as a REACHABLE state.  At the live reserves, two positions with
  /// the SAME baseSize/|quoteSize| ratio and different sizes differ in
  /// liquidatability.  Every exogenous scalar `markPrice` — v1's `canLiquidate`
  /// — is homogeneous of degree 0 in the position and cannot make this state
  /// exist.  Reached at depth 1, as soon as the pool is at (4000, 9000).
  val wit_sizeDependentLiquidation: bool =
    not(and {
      reserveBase > 0,
      reserveQuote > 0,
      not(positionLiquidatable(-1000, 1000, reserveBase, reserveQuote)),
      positionLiquidatable(-3000, 3000, reserveBase, reserveQuote),
    })

  /// P2-SCOPE §5 row 6's `wit_ammClose`: "no liquidation changed the reserves"
  /// — must be violated.  This is D-3 exactly: v1's `liquidate` writes
  /// `reserveBase' = reserveBase, reserveQuote' = reserveQuote`.
  val wit_ammClose: bool =
    not(and { lastOp == OP_LIQUIDATE, currentK != kBefore })

  /// The other side of `inv_kMonotone`: a settlement that pushed back LESS than
  /// the position owed, so the reserve product FELL and the loss landed on the
  /// LPs.  Unreachable in v1 for two independent reasons — liquidate is inert
  /// and there is no close path.
  val wit_kFellOnSettlement: bool =
    not(and {
      lastOp == OP_LIQUIDATE or lastOp == OP_CLOSE,
      kBefore > 0,
      currentK < kBefore,
    })

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_mint: bool = lastOp != OP_MINT
  val wit_fired_burn: bool = lastOp != OP_BURN
  val wit_fired_addMargin: bool = lastOp != OP_ADDMARGIN
  val wit_fired_openLong: bool = lastOp != OP_OPENLONG
  val wit_fired_openShort: bool = lastOp != OP_OPENSHORT
  val wit_fired_closePosition: bool = lastOp != OP_CLOSE
  val wit_fired_liquidate: bool = lastOp != OP_LIQUIDATE
}
