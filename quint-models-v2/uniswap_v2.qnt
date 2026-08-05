// =============================================================================
//  uniswap_v2 — Phase 2 re-spec (PILOT).  Replaces quint-models/L1/uniswap_v2.qnt.
//
//  SOURCE:
//    protocol-repos/dex/Uniswap_v2-core/contracts/UniswapV2Pair.sol
//      :15        MINIMUM_LIQUIDITY = 10**3
//      :28        kLast — "reserve0 * reserve1, as of immediately after the most
//                 recent liquidity event"
//      :74        require(balance0 <= uint112(-1) && balance1 <= uint112(-1))
//      :89-107    _mintFee — protocol cut of sqrt(k) growth
//      :110-131   mint  (:120 bootstrap, :121 permanent lock, :123 pro rata,
//                        :125 INSUFFICIENT_LIQUIDITY_MINTED, :129 kLast write)
//      :134-156   burn  (:144-145 pro rata out, :146 INSUFFICIENT_LIQUIDITY_BURNED)
//      :159-187   swap  (:162 liquidity guard, :180-182 the K guard)
//    protocol-repos/dex/Uniswap_v2-core/contracts/libraries/Math.sol:11-20
//                 Math.sqrt — Babylonian, exact floor
//    protocol-repos/dex/Uniswap_v2-core/contracts/UniswapV2Factory.sol:7,40-43
//                 feeTo / setFeeTo — the governance switch that gates _mintFee
//
//  MECHANISM:
//    LP shares ARE the constant-product invariant: the first deposit mints the
//    exact integer geometric mean sqrt(a0*a1) minus a permanently locked
//    MINIMUM_LIQUIDITY, every later deposit mints pro rata, and the protocol's
//    own cut is one sixth of the growth in sqrt(k) measured against kLast.
//
//  WHAT v1 DELETED (both deletions, and this file exists to restore them):
//    D-1  quint-models/L1/common.qnt:76-92 — geometricMint returns
//         `if (a0 == a1) a0 else min(a0, a1)`, self-documented "unrolled for
//         quint purity without loops".  Correct exactly on the diagonal, which
//         is the one set where sqrt, min, mean and a0 all agree, so it killed
//         zero mutants.  Restored as `geometricMint` over kernel `isqrtFloor`.
//    D-2  quint-models/L1/uniswap_v2.qnt:28,48,69 write `kLast` and NOTHING
//         reads it.  The reader is `_mintFee` (:89-107), which is absent from
//         v1 entirely — so the protocol's own revenue mechanism, the feeTo
//         governance switch, and the `kLast = 0` teardown branch (:104-106) are
//         all missing.  Restored as `mintFeeLiquidity` + `var feeOn`.
//         D-2 was undiagnosed before this pilot; see PILOT-NOTES.md §2.
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    exact integer sqrt; the permanent MINIMUM_LIQUIDITY lock at address(0);
//    INSUFFICIENT_LIQUIDITY_MINTED; the 997/1000 swap fee; the K guard at
//    :180-182 as a guard, not as a comment; kLast and its three writers; the
//    protocol fee mint to feeTo; the feeTo on/off switch and the kLast teardown;
//    every rounding direction (all floors: :100, :123, :144-145).
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - ERC20 plumbing (UniswapV2ERC20.sol): approve/transfer/permit.  Dropped by
//      the droppability rule — no state-changing guard in Pair reads an
//      allowance.  LP balances survive as `lpBalance`, a change of
//      representation of an observable, not a loss of one.
//    - token balances vs reserves.  `mint`/`burn` read balanceOf(pair) (:112-115,
//      :138-139); with `skim`/`sync` dropped and no donations modelled, balance
//      is identically reserve, so amounts are action arguments.  This also makes
//      burn's `liquidity = balanceOf[address(this)]` (:140) an exogenous
//      argument — the caller chose what to send.  See INPUTS row `shares`.
//    - `skim` / `sync` (:190-200): reachable only from a donation, which needs
//      the dropped balance/reserve split.
//    - flash-swap callback (:172) and the `lock` reentrancy modifier (:31-36):
//      the guard is constant across an atomic Quint action, hence vacuous.
//    - TWAP cumulatives (:26-27, :79-80) and `blockTimestampLast`: written by
//      `_update`, read by no guard on any state-changing path.
//    - `initialize` (:66-70) and Factory `createPair` (:23-38): one fixed pair.
//    - Factory `setFeeToSetter` (:45-48): authority over the authority; no rival
//      in the contrast set turns on it.
//    - the uint112 overflow guard (:74) is kept but DESCALED to MAX_RESERVE.
//    - `Math.sqrt`'s Babylonian iteration is replaced by the restoring binary
//      algorithm.  Not a relaxation: both are exact floor(sqrt) on every uint,
//      and `inv_sqrtExact` asserts the defining property at every reached state.
//    - the two revert paths below sqrt(a0*a1) = MINIMUM_LIQUIDITY are merged.
//      `SafeMath.sub` reverts when sqrt < 1000 and `require` (:125) reverts when
//      sqrt == 1000; both are refusals of the same action at the same argument,
//      indistinguishable in the failures model, and both are exactly `liq <= 0`.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label Λ of the observation
//    interface (P2-FIDELITY §1) — the same information the contract's own Mint /
//    Burn / Swap / Sync events carry, which are droppable only because no guard
//    reads them.  It is read by `wit_fired_*` (convention 6d) and by nothing
//    else, and no guard or `pure def` may read it.  It is exempt from 6e's
//    write-only rule on that basis.  See PILOT-NOTES.md §5.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 2 LPs (+ 2 protocol accounts, neither ever selected);
//       mint amounts 7 values, swap inputs 5, burn shares 3, fee switch 2.
//       Six `nondet`s per step, each <= 8 values.  No list state.
//    8b magnitude — peak intermediate 4.611686e18 < 9.22e18, and it is inside
//       kernel `isqrtFloor` ((2^31-1)^2), not in protocol arithmetic.  The
//       protocol peak is the K guard product (MAX_RESERVE*FEE_DEN)^2 = 1.0e16;
//       next is a0*a1 <= 4.0e8 and kLast <= 1.0e10.
//    8c constant-crossing —
//       MINIMUM_LIQUIDITY = 1000:  sqrt(a0*a1) = 1000 at (1000,1000) -> 0 LP,
//         the INSUFFICIENT_LIQUIDITY_MINTED refusal;  = 6000 at (4000,9000) ->
//         5000 LP with 1000 locked.  Below (t0_08, geometricMint(900,900) =
//         -100) is the SafeMath.sub refusal, merged per ABSTRACTED above.
//       fee 997/1000:  invisible at amountIn/reserveIn = 0.1 (t0_13: 90 = 90
//         against the zero-fee form), visible at 1.0 (t0_14: 499 != 500).
//         SWAP_INPUTS spans 100..20000 against reserves from 2000 up.
//       FEE_MINT_SHARE = 5 / the rootK > rootKLast test:  t0_11 is the equal
//         side (0), t0_09 and t0_10 the greater side (28, 90).
//       kLast = 0 test (:94, :104):  t0_12 is the zero side, t0_09 the non-zero
//         side; `wit_branch_feeOff` reaches the teardown at runtime.
//       MAX_RESERVE:  crossed by five mints of 20000.
//
//  INPUTS:  (convention 6g, dependency parity — foot(Q) = contract storage the
//           contract's own expression for this quantity depends on)
//    | name      | contract expression           | file:line | foot(Q) | spec vars read |
//    | caller    | mint(address to) / msg.sender | :110,:134 | none    | none (calldata) |
//    | a0, a1    | balanceX - _reserveX          | :114-115  | none*   | none (transfer amount) |
//    | shares    | balanceOf[address(this)]      | :140      | none*   | lpBalance (guard) |
//    | amountIn  | balanceX - (_reserveX - outX) | :176-177  | none*   | none (transfer amount) |
//    | switchOn  | IUniswapV2Factory(f).feeTo()  | :90-91    | none    | none (external call) |
//    * the storage read is `balanceOf[pair]`, an ERC20 staging slot the caller
//      wrote immediately before the call.  Its VALUE is caller-chosen calldata,
//      so foot(Q) is empty and parity holds; the staging slot itself is dropped
//      under ABSTRACTED.  `shares` additionally carries the (E<=) restriction
//      `shares <= lpBalance.get(holder)` — you cannot send LP you do not hold.
//    `on` is a genuine external-call return (Factory.feeTo), foot(Q) = empty,
//    exactly the oracle case 6g was written to permit.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    UniswapV2Pair.mint          -> action mint
//    UniswapV2Pair.burn          -> action burn
//    UniswapV2Pair.swap          -> actions swap0for1 / swap1for0
//    UniswapV2Pair.skim          -> ABSTRACTED (needs balance/reserve split)
//    UniswapV2Pair.sync          -> ABSTRACTED (needs balance/reserve split)
//    UniswapV2Pair.initialize    -> ABSTRACTED (one fixed pair)
//    UniswapV2ERC20.approve/transfer/transferFrom/permit -> ABSTRACTED (plumbing)
//    UniswapV2Factory.setFeeTo   -> action setFeeTo
//    UniswapV2Factory.setFeeToSetter -> ABSTRACTED (authority over authority)
//    UniswapV2Factory.createPair -> ABSTRACTED (one fixed pair)
//    Storage read by a require on a state-changing path:
//      reserve0, reserve1 (:74, :162) -> var;  totalSupply (:119) -> var;
//      balanceOf (:140, ERC20 _burn) -> var lpBalance;  kLast (:94, :104) -> var;
//      factory.feeTo (:90) -> var feeOn;  unlocked (:32) -> ABSTRACTED (vacuous);
//      blockTimestampLast (:76) -> ABSTRACTED (no guard reads it).
//    No `var` is write-only.  kLast is read by `mintFeeLiquidity`, by
//    `inv_kLastMeaning` and by `wit_used_ammAmountOut`.
//
//  UNITS:  (hole H2's obligation, applied here as a convention)
//    reserve0, a0, amountIn, MAX_RESERVE      — token0 units
//    reserve1, a1                              — token1 units
//    totalSupply, lpBalance, shares, feeLiq, MINIMUM_LIQUIDITY — LP-share units
//    kLast, a0*a1                              — token0*token1
//    isqrtFloor(kLast), isqrtFloor(a0*a1)      — sqrt(token0*token1) == LP units
//    FEE_NUM / FEE_DEN / FEE_MINT_SHARE        — dimensionless
//
//  CONTRAST SET 𝔐 (F0/F2, with R4's three mandatory members):
//    M0  geometricMint = isqrtFloor(a0*a1) - MINIMUM_LIQUIDITY          [target]
//    M1  the v1 shortcut body verbatim: `if (a0==a1) a0 else min(a0,a1)`
//        (common.qnt:76-92).  MANDATORY member 1.  Agreement with M0 over the
//        49-point mint domain: 7/49 = 14.3%.  Killed by t0_04/05/06 and by
//        wit_live_geometricMint, whose state is unreachable under M1.
//    M2  chaos: any liquidity in [1, isqrtFloor(a0*a1)].  MANDATORY member 2 —
//        the maximally permissive form in the same relaxation direction.
//        Killed by t0_04 and by inv_conservation losing its equality.
//    M3  apex's linear LP bootstrap `(a0+a1)/2 - MINIMUM_LIQUIDITY`
//        (quint-models/L3/apex.qnt:183-185).  MANDATORY member 3, sourced from
//        a sibling protocol already in the corpus.  Agreement 7/49 = 14.3%.
//    M4  ceil-sqrt: `isqrtFloor(a0*a1) + (0 if exact else 1) - MINIMUM_LIQUIDITY`
//        — the rounding-direction rival.  Agreement 15/49 = 30.6% (exactly the
//        perfect-square products).  Killed by t0_06 (414, not 415).
//    NOTE, and it is a finding: R4 asks for a near neighbour agreeing on >= 90%
//    of the declared domain.  For `geometricMint` NO SUCH RIVAL EXISTS.  All
//    four candidates were enumerated exhaustively over all 49 domain pairs; the
//    best is M4 at 30.6%.  The geometric mean is extremal, so every rival
//    separates from it off the diagonal.  See PILOT-NOTES.md §7.
//
//  ACCEPTANCE:
//    T1  quint typecheck uniswap_v2.qnt
//    T2  quint run --main=uniswap_v2 --invariant=inv_conservation \
//          --max-steps=20 --max-samples=500 uniswap_v2.qnt
//    T3  quint run --main=uniswap_v2 --invariant=inv_all \
//          --max-steps=20 --max-samples=500 uniswap_v2.qnt          (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: geometricMint(4000, 9000) = 5000.  Obligation is the TRACE that
//        violates `wit_live_geometricMint`, i.e. a reachable state with
//        reserve0 = 4000, reserve1 = 9000, totalSupply = 6000, one LP holding
//        5000 and address(0) holding 1000.
// =============================================================================
module uniswap_v2 {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// UniswapV2Pair.sol:15
  pure val MINIMUM_LIQUIDITY: int = 1000
  /// UniswapV2Pair.sol:180-181 — balanceAdjusted = balance*1000 - amountIn*3
  pure val FEE_NUM: int = 997
  pure val FEE_DEN: int = 1000
  pure val FEE_BPS: int = 3
  /// UniswapV2Pair.sol:99 — denominator = rootK*5 + rootKLast
  pure val FEE_MINT_SHARE: int = 5
  /// UniswapV2Pair.sol:74, descaled from uint112(-1).  See BOUNDS.
  pure val MAX_RESERVE: int = 100000

  /// UniswapV2Pair.sol:121 — address(0), holder of the permanent lock.
  pure val LOCK: str = "addressZero"
  /// UniswapV2Factory.sol:7 — feeTo, holder of the protocol cut.
  pure val PROTOCOL_FEE_TO: str = "feeTo"
  pure val LPS: Set[str] = Set("alice", "bob")
  pure val ACCOUNTS: Set[str] = LPS.union(Set(LOCK, PROTOCOL_FEE_TO))

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN 𝒟 (convention 8a; see BOUNDS for 8b and 8c)
  // ---------------------------------------------------------------------------

  pure val MINT_AMOUNTS: Set[int] = Set(1000, 2000, 4000, 8000, 9000, 12000, 20000)
  pure val SWAP_INPUTS: Set[int] = Set(100, 500, 1000, 5000, 20000)
  pure val BURN_SHARES: Set[int] = Set(500, 1000, 5000)
  pure val FEE_SWITCH: Set[bool] = Set(true, false)

  pure val INIT_RESERVE: int = 0
  pure val INIT_SUPPLY: int = 0
  pure val INIT_BALANCE: int = 0
  pure val INIT_KLAST: int = 0
  pure val INIT_FEE_ON: bool = true

  pure val OP_INIT: str = "init"
  pure val OP_MINT: str = "mint"
  pure val OP_BURN: str = "burn"
  pure val OP_SWAP0: str = "swap0for1"
  pure val OP_SWAP1: str = "swap1for0"
  pure val OP_SETFEE: str = "setFeeTo"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var reserve0: int          // token0
  var reserve1: int          // token1
  var totalSupply: int       // LP shares
  var lpBalance: str -> int  // LP shares, by account
  var kLast: int             // token0*token1 at the last liquidity event (:28)
  var feeOn: bool            // Factory.feeTo != address(0)   (:90-91)
  var lastOp: str            // GHOST — trace label, see header

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  Every one of these is pinned by exact T0 vectors below AND carries a
  //  `wit_used_*` reachability obligation, because a `pure val` equality is true
  //  in states where the definition is never applied (the fifth trap, §D).
  // ===========================================================================

  /// FIRST DEPOSIT — UniswapV2Pair.sol:120
  ///   liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY)
  /// The geometric mean is the unique symmetric degree-1-homogeneous function
  /// whose level sets are the constant-product curve, so "shares == the
  /// invariant" IS the mechanism.  A negative result is `SafeMath.sub`
  /// reverting; the caller's `liq > 0` guard is exactly that refusal.
  pure def geometricMint(a0: int, a1: int): int =
    isqrtFloor(a0 * a1) - MINIMUM_LIQUIDITY

  /// LATER DEPOSITS — UniswapV2Pair.sol:123
  ///   Math.min(amount0.mul(_totalSupply)/_reserve0,
  ///            amount1.mul(_totalSupply)/_reserve1)
  /// Both quotients floor: the pool keeps the residual, not the depositor.
  pure def proportionalMint(a0: int, a1: int, r0: int, r1: int, ts: int): int =
    minInt(mulDivDown(a0, ts, r0), mulDivDown(a1, ts, r1))

  /// EXIT — UniswapV2Pair.sol:144-145
  ///   amountX = liquidity.mul(balanceX) / _totalSupply
  /// Floors again: the residual stays with the remaining LPs.
  pure def proportionalBurn(shares: int, poolAmount: int, ts: int): int =
    mulDivDown(shares, poolAmount, ts)

  /// PROTOCOL CUT — UniswapV2Pair.sol:92-103.  Reads kLast, which is what makes
  /// kLast live; v1 wrote kLast at three sites and had no reader at all.
  ///   rootK > rootKLast  =>  totalSupply*(rootK - rootKLast)
  ///                          / (rootK*5 + rootKLast)
  /// Caller supplies the feeOn gate (:93).  kLast == 0 is the first-ever
  /// liquidity event (:94), which mints nothing.
  pure def mintFeeLiquidity(kLastIn: int, r0: int, r1: int, ts: int): int =
    if (kLastIn == 0) 0
    else {
      val rootK = isqrtFloor(r0 * r1)
      val rootKLast = isqrtFloor(kLastIn)
      if (rootK > rootKLast)
        mulDivDown(ts, rootK - rootKLast, rootK * FEE_MINT_SHARE + rootKLast)
      else 0
    }

  /// EXACT FILL against the pair's own admissibility test.  The pair does not
  /// compute an output; it accepts any (in, out) satisfying the K guard at
  /// :180-182.  This is the largest such `out`, which is what a router sends.
  /// The 997/1000 is why k strictly grows and why LPs are paid at all.
  pure def ammAmountOut(reserveIn: int, reserveOut: int, amountIn: int): int = {
    val amountInWithFee = amountIn * FEE_NUM
    mulDivDown(amountInWithFee, reserveOut, reserveIn * FEE_DEN + amountInWithFee)
  }

  /// THE PAIR'S OWN GUARD — UniswapV2Pair.sol:180-182, verbatim:
  ///   balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3))
  ///   balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3))
  ///   require(balance0Adjusted.mul(balance1Adjusted)
  ///           >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K')
  /// Peak intermediate: (MAX_RESERVE*FEE_DEN)^2 = 1.0e16.
  pure def kGuardHolds(r0: int, r1: int, b0: int, b1: int,
                       in0: int, in1: int): bool = {
    val b0adj = b0 * FEE_DEN - in0 * FEE_BPS
    val b1adj = b1 * FEE_DEN - in1 * FEE_BPS
    b0adj * b1adj >= r0 * r1 * FEE_DEN * FEE_DEN
  }

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed
  //  from the cited Solidity line in integer arithmetic.  Values marked [SEP]
  //  are ones the v1 `min(a0,a1)` shortcut cannot produce.
  // ===========================================================================

  // -- isqrtFloor (Math.sol:11-20) --------------------------------------------
  pure val t0_01: bool = isqrtFloor(36000000) == 6000
  pure val t0_02: bool = isqrtFloor(15) == 3            // 6c: floor 3, ceil 4
  pure val t0_03: bool = isqrtFloor(8) == 2             // 6c: floor 2, ceil 3
  pure val t0_04: bool = isqrtFloor(2000000) == 1414    // 6c: 1414^2 < 2e6

  // -- geometricMint (UniswapV2Pair.sol:120) ----------------------------------
  pure val t0_05: bool = geometricMint(4000, 9000) == 5000   // [SEP] v1 -> 3000
  pure val t0_06: bool = geometricMint(2000, 8000) == 3000   // [SEP] v1 -> 1000
  pure val t0_07: bool = geometricMint(1000, 2000) == 414    // [SEP] v1 -> 0; 6c
  pure val t0_08: bool = geometricMint(1000, 1000) == 0      // 8c: == MIN_LIQ
  pure val t0_09: bool = geometricMint(900, 900) == -100     // 8c: <  MIN_LIQ

  // -- mintFeeLiquidity (UniswapV2Pair.sol:92-103) ----------------------------
  pure val t0_10: bool = mintFeeLiquidity(1000000, 1200, 1200, 1000) == 28
  pure val t0_11: bool = mintFeeLiquidity(1000000, 2000, 2000, 1000) == 90
  pure val t0_12: bool = mintFeeLiquidity(1000000, 1000, 1000, 1000) == 0
  pure val t0_13: bool = mintFeeLiquidity(0, 2000, 2000, 1000) == 0

  // -- ammAmountOut (UniswapV2Pair.sol:180-182, exact fill) -------------------
  pure val t0_14: bool = ammAmountOut(1000, 1000, 100) == 90
  pure val t0_15: bool = ammAmountOut(1000, 1000, 1000) == 499
  pure val t0_16: bool = ammAmountOut(4000, 9000, 20000) == 7496

  // -- proportionalMint / proportionalBurn (:123, :144-145) -------------------
  pure val t0_17: bool = proportionalMint(1000, 1000, 24000, 1504, 6000) == 250
  pure val t0_18: bool = proportionalMint(1000, 1000, 7000, 7000, 6000) == 857
  pure val t0_19: bool = proportionalBurn(5000, 4000, 6000) == 3333
  pure val t0_20: bool = proportionalBurn(5000, 9000, 6000) == 7500

  // -- kGuardHolds, both sides of the K constant (:182) -----------------------
  pure val t0_21: bool = kGuardHolds(1000, 1000, 2000, 501, 1000, 0)
  pure val t0_22: bool = not(kGuardHolds(1000, 1000, 2000, 500, 1000, 0))

  pure val inv_T0: bool = and {
    t0_01, t0_02, t0_03, t0_04, t0_05, t0_06, t0_07, t0_08,
    t0_09, t0_10, t0_11, t0_12, t0_13, t0_14, t0_15, t0_16,
    t0_17, t0_18, t0_19, t0_20, t0_21, t0_22,
  }

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    reserve0' = INIT_RESERVE,
    reserve1' = INIT_RESERVE,
    totalSupply' = INIT_SUPPLY,
    lpBalance' = ACCOUNTS.mapBy(_ => INIT_BALANCE),
    kLast' = INIT_KLAST,
    feeOn' = INIT_FEE_ON,
    lastOp' = OP_INIT,
  }

  /// UniswapV2Pair.mint (:110-131).  _mintFee runs FIRST (:117), against the
  /// pre-update reserves and the pre-mint totalSupply, and its result changes
  /// the denominator of the pro-rata branch (:118 exists for exactly that).
  action mint(recipient: str, a0: int, a1: int): bool = all {
    LPS.contains(recipient),
    a0 > 0,
    a1 > 0,
    reserve0 + a0 <= MAX_RESERVE,
    reserve1 + a1 <= MAX_RESERVE,
    val feeLiq = if (feeOn) mintFeeLiquidity(kLast, reserve0, reserve1, totalSupply) else 0
    val supplyAfterFee = totalSupply + feeLiq
    val bootstrap = supplyAfterFee == 0
    val liquidity =
      if (bootstrap) geometricMint(a0, a1)
      else proportionalMint(a0, a1, reserve0, reserve1, supplyAfterFee)
    val locked = if (bootstrap) MINIMUM_LIQUIDITY else 0
    val r0n = reserve0 + a0
    val r1n = reserve1 + a1
    all {
      liquidity > 0,
      reserve0' = r0n,
      reserve1' = r1n,
      totalSupply' = supplyAfterFee + liquidity + locked,
      lpBalance' = lpBalance.put(PROTOCOL_FEE_TO, lpBalance.get(PROTOCOL_FEE_TO) + feeLiq)
        .put(LOCK, lpBalance.get(LOCK) + locked)
        .put(recipient, lpBalance.get(recipient) + liquidity),
      kLast' = if (feeOn) r0n * r1n else 0,
      feeOn' = feeOn,
      lastOp' = OP_MINT,
    }
  }

  /// UniswapV2Pair.burn (:134-156).  `shares` is the LP the caller transferred
  /// to the pair before the call; the guard below is (E<=) on that transfer.
  action burn(holder: str, shares: int): bool = all {
    LPS.contains(holder),
    shares > 0,
    lpBalance.get(holder) >= shares,
    val feeLiq = if (feeOn) mintFeeLiquidity(kLast, reserve0, reserve1, totalSupply) else 0
    val supplyAfterFee = totalSupply + feeLiq
    val out0 = proportionalBurn(shares, reserve0, supplyAfterFee)
    val out1 = proportionalBurn(shares, reserve1, supplyAfterFee)
    val r0n = reserve0 - out0
    val r1n = reserve1 - out1
    all {
      supplyAfterFee > 0,
      out0 > 0,
      out1 > 0,
      reserve0' = r0n,
      reserve1' = r1n,
      totalSupply' = supplyAfterFee - shares,
      lpBalance' = lpBalance.put(PROTOCOL_FEE_TO, lpBalance.get(PROTOCOL_FEE_TO) + feeLiq)
        .put(holder, lpBalance.get(holder) - shares),
      kLast' = if (feeOn) r0n * r1n else 0,
      feeOn' = feeOn,
      lastOp' = OP_BURN,
    }
  }

  /// UniswapV2Pair.swap (:159-187), token0 in.  The pair transfers out first
  /// and then checks the K guard on the resulting balances (:180-182).
  action swap0for1(amountIn: int): bool = all {
    amountIn > 0,
    reserve0 > 0,
    reserve1 > 0,
    reserve0 + amountIn <= MAX_RESERVE,
    val out = ammAmountOut(reserve0, reserve1, amountIn)
    val b0 = reserve0 + amountIn
    val b1 = reserve1 - out
    all {
      out > 0,
      out < reserve1,
      kGuardHolds(reserve0, reserve1, b0, b1, amountIn, 0),
      reserve0' = b0,
      reserve1' = b1,
      totalSupply' = totalSupply,
      lpBalance' = lpBalance,
      kLast' = kLast,
      feeOn' = feeOn,
      lastOp' = OP_SWAP0,
    }
  }

  /// UniswapV2Pair.swap (:159-187), token1 in.
  action swap1for0(amountIn: int): bool = all {
    amountIn > 0,
    reserve0 > 0,
    reserve1 > 0,
    reserve1 + amountIn <= MAX_RESERVE,
    val out = ammAmountOut(reserve1, reserve0, amountIn)
    val b0 = reserve0 - out
    val b1 = reserve1 + amountIn
    all {
      out > 0,
      out < reserve0,
      kGuardHolds(reserve0, reserve1, b0, b1, 0, amountIn),
      reserve0' = b0,
      reserve1' = b1,
      totalSupply' = totalSupply,
      lpBalance' = lpBalance,
      kLast' = kLast,
      feeOn' = feeOn,
      lastOp' = OP_SWAP1,
    }
  }

  /// UniswapV2Factory.setFeeTo (:40-43).  Governance flips the switch; kLast is
  /// NOT touched here.  The teardown at UniswapV2Pair.sol:104-106 happens on the
  /// next liquidity event, which is where `kLast' = if (feeOn) ... else 0` sits.
  action setFeeTo(switchOn: bool): bool = all {
    switchOn != feeOn,
    reserve0' = reserve0,
    reserve1' = reserve1,
    totalSupply' = totalSupply,
    lpBalance' = lpBalance,
    kLast' = kLast,
    feeOn' = switchOn,
    lastOp' = OP_SETFEE,
  }

  /// Convention 6: every `nondet` is exogenous — a caller identity, a token
  /// amount the caller transferred, or the factory's governance switch.  The
  /// protocol selects nothing here that the driver could be told.
  action step: bool = {
    nondet caller = LPS.oneOf()
    nondet a0 = MINT_AMOUNTS.oneOf()
    nondet a1 = MINT_AMOUNTS.oneOf()
    nondet shares = BURN_SHARES.oneOf()
    nondet amountIn = SWAP_INPUTS.oneOf()
    nondet switchOn = FEE_SWITCH.oneOf()
    any {
      mint(caller, a0, a1),
      burn(caller, shares),
      swap0for1(amountIn),
      swap1for0(amountIn),
      setFeeTo(switchOn),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — LP shares are neither created nor destroyed outside mint,
  /// burn and the protocol cut.  This is the T2 command's invariant.
  val inv_conservation: bool =
    ACCOUNTS.fold(0, (acc, a) => acc + lpBalance.get(a)) == totalSupply

  val inv_bounds: bool = and {
    reserve0 >= 0,
    reserve1 >= 0,
    totalSupply >= 0,
    kLast >= 0,
    reserve0 <= MAX_RESERVE,
    reserve1 <= MAX_RESERVE,
    ACCOUNTS.forall(a => lpBalance.get(a) >= 0),
  }

  /// T3 for this protocol (P2-SCOPE §5 row 1): `isqrtFloor` is the exact floor
  /// at every product this run actually reaches.  False for any inexact rival.
  val inv_sqrtExact: bool = and {
    isqrtExactAt(reserve0 * reserve1),
    isqrtExactAt(kLast),
  }

  /// UniswapV2Pair.sol:121 — the lock is permanent.  It is minted once, at the
  /// bootstrap, to an account with no burn path, so once the pool exists the
  /// supply can never fall below it.
  val inv_permanentLock: bool =
    totalSupply > 0 implies and {
      lpBalance.get(LOCK) == MINIMUM_LIQUIDITY,
      totalSupply >= MINIMUM_LIQUIDITY,
    }

  /// UniswapV2Pair.sol:28 — kLast is the product AT THE LAST LIQUIDITY EVENT,
  /// and swaps only raise the product (that is what the 997/1000 buys), so a
  /// live kLast never exceeds the current product.  This is the invariant that
  /// v1 could not even state, because nothing in v1 read kLast.
  val inv_kLastMeaning: bool =
    (kLast == 0) or (kLast <= reserve0 * reserve1)

  /// LP supply never exceeds the geometric mean of the reserves.  Tight at the
  /// bootstrap (equality), and preserved by every action including the protocol
  /// cut, whose 1/6-of-growth form is chosen precisely so it cannot break this.
  val inv_supplyBelowGeometric: bool =
    totalSupply * totalSupply <= reserve0 * reserve1

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_sqrtExact,
    inv_permanentLock,
    inv_kLastMeaning,
    inv_supplyBelowGeometric,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (§D, the fifth trap).
  //  Each of these must be VIOLATED by `quint run --invariant=<name>`.  A
  //  violation is a trace; a trace is the proof the definition actually ran on
  //  the declared domain.  A `pure def` cited only by `pure val` equalities is a
  //  deleted mechanism carrying a certificate.
  // ===========================================================================

  pure val T0_LIVE_A0: int = 4000
  pure val T0_LIVE_A1: int = 9000
  pure val T0_LIVE_SUPPLY: int = 6000
  pure val T0_LIVE_LP: int = 5000

  /// T0-LIVE for this protocol: geometricMint(4000, 9000) = 5000, as a TRACE.
  /// Under M1 (v1's min) the same trace gives totalSupply 5000 and minter LP
  /// 3000, so this state is unreachable and the witness is never violated —
  /// which is exactly how a value-level equality is turned into a mechanism
  /// check.  Reached at depth 1 from init.
  val wit_live_geometricMint: bool =
    not(and {
      reserve0 == T0_LIVE_A0,
      reserve1 == T0_LIVE_A1,
      totalSupply == T0_LIVE_SUPPLY,
      lpBalance.get(LOCK) == MINIMUM_LIQUIDITY,
      LPS.exists(u => lpBalance.get(u) == T0_LIVE_LP),
    })

  /// `isqrtFloor` ran and its TRUNCATION was load-bearing: a state whose supply
  /// is the strict floor of sqrt(k).  Reached at (1000, 2000): 1414^2 < 2e6.
  val wit_used_isqrtFloor: bool =
    not(and {
      totalSupply > 0,
      totalSupply == isqrtFloor(reserve0 * reserve1),
      totalSupply * totalSupply < reserve0 * reserve1,
    })

  /// `geometricMint` ran OFF THE DIAGONAL — the region where every member of
  /// 𝔐 disagrees with M0.  A diagonal-only witness would prove nothing, which
  /// is precisely v1's defect.
  val wit_used_geometricMint: bool =
    not(and {
      totalSupply > 0,
      totalSupply == isqrtFloor(reserve0 * reserve1),
      reserve0 != reserve1,
    })

  /// `proportionalMint` ran: two distinct LPs hold shares, and only one of them
  /// can have taken the bootstrap branch.  Also discharges regression signal 7
  /// (single-user-sufficient invariants).
  val wit_used_proportionalMint: bool =
    not(LPS.forall(u => lpBalance.get(u) > 0))

  /// `proportionalBurn` ran: every non-locked share has been redeemed and the
  /// pool still holds reserves against the 1000 that can never come out.
  val wit_used_proportionalBurn: bool =
    not(and {
      lpBalance.get(LOCK) == MINIMUM_LIQUIDITY,
      totalSupply == MINIMUM_LIQUIDITY,
      reserve0 > 0,
      reserve1 > 0,
    })

  /// `mintFeeLiquidity` ran and PAID: feeTo holds shares.  No other writer
  /// exists for that account.  This is the witness v1 could not host at all.
  val wit_used_mintFeeLiquidity: bool = lpBalance.get(PROTOCOL_FEE_TO) == 0

  /// `ammAmountOut` (and with it `kGuardHolds`) ran: the product has risen above
  /// its value at the last liquidity event, which only a swap can do.  This is
  /// kLast being read as an observable, not merely written.
  val wit_used_ammAmountOut: bool =
    not(and { feeOn, kLast > 0, reserve0 * reserve1 > kLast })

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_mint: bool = lastOp != OP_MINT
  val wit_fired_burn: bool = lastOp != OP_BURN
  val wit_fired_swap0for1: bool = lastOp != OP_SWAP0
  val wit_fired_swap1for0: bool = lastOp != OP_SWAP1
  val wit_fired_setFeeTo: bool = lastOp != OP_SETFEE

  // -- convention 6f: both sides of the kLast teardown branch (:104-106) -------

  /// The pool exists, governance has switched the cut off, and the next
  /// liquidity event has zeroed kLast.  Under v1 this branch does not exist.
  val wit_branch_feeOff: bool =
    not(and { totalSupply > 0, not(feeOn), kLast == 0 })
}
