// =============================================================================
//  curve — Phase 2 re-spec.  Replaces quint-models/L1/curve.qnt.
//
//  SOURCE:
//    protocol-repos/dex/curvefi_curve-contract/contracts/pools/3pool/StableSwap3Pool.vy
//      :76        N_COINS = 3            (reduced to 2, P2-SCOPE row 2)
//      :78        FEE_DENOMINATOR = 10**10
//      :95-96     fee / admin_fee        (constructor parameters)
//      :195-218   get_D  — Newton on the StableSwap invariant, `break` at |dD|<=1
//      :353-411   get_y  — Newton for one coin given the others and D
//      :371-397   add_liquidity  (:374 assert D1 > D0, :381-390 imbalance fee,
//                                 :392-397 mint = supply*(D2-D0)/D0, or D1)
//      :431-490   exchange  (:462 x = xp[i]+dx, :463 y = get_y, :465 dy-1,
//                            :466 dy_fee, :477-479 balance writes)
//      :498-515   remove_liquidity — pro rata, no D
//
//  MECHANISM:
//    D is not a formula, it is the FIXPOINT of an iteration.  `get_D` starts at
//    D = S and applies D <- (Ann*S + D_P*N)*D / ((Ann-1)*D + (N+1)*D_P) until
//    two successive iterates differ by at most 1, then BREAKS.  Everything the
//    pool does — how many LP tokens a deposit mints, what a trade pays out — is
//    read off that fixpoint, so the iteration and its termination test are the
//    protocol.
//
//  WHAT v1 DELETED (this file exists to restore it):
//    D-1  quint-models/L1/curve.qnt:22-30 — `approxD` returns
//         `(ann*S + 2*min(x,y)) / (ann + 1)`, self-labelled "weighted blend" and
//         ":27 stand-in for geometric contribution".  It has no iteration, no
//         fixpoint and no break.  Measured against the contract at AMP = 100:
//           (100,100) 200 = 200   (150,50) 199 = 199   <- agrees on the flat part
//           (180,20)  198 vs 199  (190,10) 196 vs 199  (199,1) 170 vs 199
//         The blend is CONSTANT at 199 across the whole imbalanced regime where
//         the real D falls from 199 to 170; it is constant-sum wearing an `A`.
//         Restored as kernel `newtonD`, with the contract's `break` carried in
//         the fold accumulator (kernel EXTENSION 1).
//    D-2  the same file never calls `get_y`: `exchange0for1` (:66-84) sets
//         `ideal = dx  // near peg 1:1`, i.e. constant-sum with a fee, so the
//         pool has no price at all.  Restored as `newtonY` + `exchangeDy`.
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    the Newton iteration and its `break`, at the contract's own rounding and
//    operation order; the SEQUENTIAL floor divisions in D_P, which make get_D
//    asymmetric in (x,y); the `assert D1 > D0` on deposit; the imbalance fee and
//    the D2 recomputation it forces; the `dy - 1` rounding gift to the pool; the
//    exchange fee; the initial-deposit "all coins" assert; every division floors.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - 3 coins -> 2 (P2-SCOPE row 2).  N_COINS is `kernel.NEWTON_N`, and every
//      formula carries N symbolically, so the reduction is a parameter choice.
//    - RATES / PRECISION_MUL (:81, :180, :189): all three 3pool coins are
//      modelled at rate 1, so `xp == balances` and `_xp_mem` is the identity.
//    - ramping A (`_A()`, initial_A/future_A): AMP is the constant 100.  No
//      guard reads the ramp; it changes A's value, not the mechanism.
//    - admin_fee = 0.  It is a constructor/governance parameter (:96), and
//      P2-SCOPE row 2 lists the admin-fee split as droppable.  With it 0 the
//      whole fee stays in the pool, which is the `self.balances[i] =
//      new_balances[i] - fees[i]*_admin_fee/FEE_DENOMINATOR` write at :390
//      collapsing to `new_balances[i]`.  The fee ITSELF is kept at both sites.
//    - remove_liquidity_imbalance (:529) and remove_liquidity_one_coin (:670):
//      both are get_D/get_y compositions already covered by add_liquidity and
//      exchange; neither adds a guard the others do not have.
//    - `is_killed`, `ramp_A`, `commit_new_fee`, ownership and the ERC20 pool
//      token's transfer/approve: no state-changing guard in the cited functions
//      reads them, except `assert not self.is_killed`, which is constant here.
//    - MAX_BALANCE = 10^6 is a SPEC-LEVEL bound with no contract counterpart.
//      The pool is uint256; the Quint Rust backend is i64.  10^6 is the cap
//      derived in P2-CARRYFORWARD CF3 (the Newton intermediate is CUBIC at
//      extreme imbalance, so the i64 ceiling is x ~ 2.64e6, not 10^7), rounded
//      down for 18x headroom.  It is an (E<=) restriction of the transition
//      relation, never a relaxation.
//    - the K = 8 unrolling REFUSES rather than approximates.  Where the
//      contract's `break` would not have fired within 8 iterations the action is
//      disabled — every action guards the convergence of the state it LEAVES and
//      of the state it ENTERS, and `exchange` additionally guards get_y's own
//      break.  This is an (E<=) restriction: the spec has fewer transitions than
//      the contract, never one the contract does not have.  `inv_dConverged`
//      asserts it at every reached state, so the restriction cannot go
//      unnoticed.  It is not cosmetic: measured on the reachable grid, 36 of
//      4900 balance pairs never break, and an unguarded `exchange0for1(100000)`
//      from (290,110) lands on one of them, (100290, 1).
//    - a coin may not be drained to zero while pool tokens remain outstanding.
//      get_D divides by `_x * N_COINS` (:208) and the contract's own comment
//      there says that state is broken ("only withdrawal will work").  Modelled
//      as a guard on `remove_liquidity`; a FULL exit to (0,0) with supply 0 is
//      permitted, since that is the empty pool and not the broken one.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label of the observation
//    interface (P2-FIDELITY §1) and carries exactly the information the pool's
//    own AddLiquidity / TokenExchange / RemoveLiquidity logs carry, which are
//    droppable only because no guard reads them.  It is read by `wit_fired_*`
//    and by nothing else; no guard and no `pure def` may read it.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 2 LPs; one `nondet` over 8 enumerated DEPOSIT PAIRS (not 8x8
//       amounts, which would be 64 branches and would put every two-step witness
//       out of reach of the sampler), 4 exchange inputs, 4 burn amounts, 2
//       callers.  Four `nondet`s per step, each <= 8 values.  No list state.
//    8b magnitude — peak intermediate 4.611686e18 < 9.22e18, inside kernel
//       `isqrtFloor` ((2^31-1)^2), which `inv_dSandwich` calls.  The PROTOCOL
//       peak is the Newton numerator at maximum imbalance: 5.002020e17 at
//       (10^6, 1), i.e. 18.4x headroom.  It is CUBIC in the balances — P2-SCOPE
//       §C row 2's "(Ann*S + D_P*N)*D <= 2e8" is the value at balances <= 200
//       and does not survive the domain this witness needs.
//    8c constant-crossing —
//       NEWTON_K = 8 (the `break`): iters 1 at (100,100), 2 at (190,10),
//         7 at (10^6,100), exactly 8 at (1,10^5), and NOT REACHED at (10^5,1)
//         and (10^6,1) — t0_cv_a..d.  Both sides of the depth, and both sides of
//         convergence itself.
//       fee (4e6 / 1e10): invisible at (190,10) dx 10, dy_fee = 0; visible at
//         (1,10^5) dx 1000, dy_fee = 32.  t0_xf_a / t0_xf_b.
//       imbalance fee (2e6 / 1e10): 0 at t0_if_c, 10 and 9 at t0_if_a / t0_if_b.
//       MAX_BALANCE: crossed — a deposit taking either balance past 10^6 is
//         refused, which is what keeps every Newton argument inside 8b.
//
//  INPUTS:  (convention 6g, dependency parity)
//    | name    | contract expression            | file:line | foot(Q) | spec vars read |
//    | caller  | msg.sender                     | :371,:431 | none    | none (tx sender) |
//    | dep     | amounts[N_COINS] (calldata)    | :371      | none    | none (calldata) |
//    | dx      | dx (calldata)                  | :431      | none    | none (calldata) |
//    | shares  | _amount (calldata)             | :498      | none    | lpBal (guard) |
//    Every quantity this pool takes from outside is calldata; `foot(Q)` is empty
//    for all four, so parity is trivially satisfied and 6g is silent here.  The
//    quantities that are NOT exogenous — D, y, the mint amount, the fee — are
//    all computed by `pure def`s from `bal0`/`bal1`/`lpSupply`, which is the
//    whole point: v1 made `ideal = dx` and thereby turned the pool's own output
//    into an identity function of calldata.  `shares` additionally carries the
//    (E<=) restriction `shares <= lpBal.get(caller)`.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    add_liquidity            -> action addLiquidity
//    exchange                 -> actions exchange0for1 / exchange1for0
//    remove_liquidity         -> action removeLiquidity
//    remove_liquidity_imbalance -> ABSTRACTED (get_D composition, no new guard)
//    remove_liquidity_one_coin  -> ABSTRACTED (get_y composition, no new guard)
//    ramp_A / stop_ramp_A     -> ABSTRACTED (AMP constant)
//    commit/apply_new_fee, commit/apply_transfer_ownership, revert_*,
//      withdraw_admin_fees, donate_admin_fees, kill_me, unkill_me
//                             -> ABSTRACTED (governance; admin_fee = 0)
//    Storage read by an assert on a state-changing path:
//      balances (:374, :406) -> vars bal0, bal1;  token.totalSupply (:377, :392)
//      -> var lpSupply;  token balances (:502, ERC20) -> var lpBal;
//      fee / admin_fee (:466-470) -> pure vals;  initial_A (:204) -> AMP;
//      is_killed (:372) -> ABSTRACTED (constant false).
//    No `var` is write-only:  bal0/bal1 feed every Newton call, lpSupply feeds
//    `addLiquidityMint` and `proportionalWithdraw`, lpBal is read by burn's
//    guard, lastOp by `wit_fired_*`.
//
//  UNITS:  (hole H2's obligation, applied here as a convention)
//    bal0, a0, dx, out0                      — coin0 units
//    bal1, a1, dy, out1                      — coin1 units
//    D, lpSupply, lpBal, shares, mint        — invariant units (= coin units, as
//                                              D is a SUM not a product, which is
//                                              why D <= bal0+bal1)
//    AMP, Ann, FEE, ADD_FEE, FEE_DENOMINATOR — dimensionless
//    NEWTON_K, iters                         — loop counts
//
//  CONTRAST SET M (F0/F2, with R4's three mandatory members), measured on the
//  five P2-CONTRACT §A.2 points {(100,100),(150,50),(180,20),(190,10),(199,1)}:
//    M0  newtonD — the contract's iteration with its break                [target]
//    M1  v1 `approxD` blend, curve.qnt:22-30 verbatim.  MANDATORY member 1.
//        Values 200,199,199,199,199 vs 200,199,198,196,170: agreement 2/5 = 40%,
//        and 0% on the three imbalanced points that discriminate at all.
//    M2  chaos: any D in [2*isqrt(xy), x+y].  MANDATORY member 2 — the maximally
//        permissive form in the same direction.  Killed by t0_d_* and by
//        `inv_dSandwich` losing its tightness at the peg.
//    M3  constant-sum D = S, i.e. AMP -> infinity, the sibling deletion in the
//        corpus (uniswap_v2's M1 is the constant-product analogue).  MANDATORY
//        member 3.  Agreement 1/5 = 20% (the peg point only).
//    M4  the near neighbour R4 asks for: newtonD at a FIXED depth K with the
//        break deleted (`foldl` without `done`).  Agreement with M0 on the five
//        points: 2/5 = 40% at K=1, 4/5 at K=2, 5/5 at K=8 — and then it diverges
//        from M0 exactly on the set where M0 refuses, which is the 292 pairs of
//        the reachable grid where the contract's loop never breaks.  This is the
//        rival the `done` flag exists to separate, and the separation is
//        `t0_cv_b`/`t0_cv_c` plus `wit_newtonDeep`.
//
//  MUTANT (F2, trap K10) — mutants/curve_M1.qnt, one substitution of the v1
//  blend at `newtonDFull`'s single definition site (in a copied kernel,
//  mutants/kernel_M1.qnt, so that it stays one edit).  Measured:
//      inv_conservation   [ok]         <- THE HEADLINE INVARIANT SURVIVES
//      inv_T0             [violation]  <- killed by the vectors
//      inv_dSandwich      [violation]  <- and by a state invariant, see below
//      wit_live_newtonD   [ok]         <- the T0-LIVE state is UNREACHABLE
//      wit_newtonDeep     [ok]         <- and so is any deep iteration
//      wit_used_newtonD   [violation]  <- USE witnesses do not discriminate
//  Three things worth carrying forward.  (a) `inv_conservation` holds under the
//  deleted mechanism, which is the v1 failure mode exactly: a clean conservation
//  run is evidence of nothing.  (b) UNLIKE the pilot, curve DOES have a state
//  invariant that separates M0 from M1 — `inv_dSandwich`, violated at
//  (100001, 99045), where the blend returns 199041 against a constant-product
//  lower bound of 199042.  The pilot's §7 generalisation ("expect a reachability
//  fact, not an invariant fact") holds for deletions that only UNDER-approximate;
//  the blend both over- and under-shoots, and the two-sided sandwich catches the
//  second.  (c) a `wit_used_f` witness written in terms of `f` itself is true
//  under any substitution for `f` and cannot discriminate — that is correct and
//  intended, since its job is reachability, not identity.  The kill is
//  `wit_live_newtonD` FAILING to be violated.
//
//  ACCEPTANCE:
//    T1  quint typecheck curve.qnt
//    T2  quint run --main=curve --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 curve.qnt
//    T3  quint run --main=curve --invariant=inv_all ...            (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: newtonD(190, 10, 100) = 196.  The obligation is the TRACE that
//        violates `wit_live_newtonD`: a reachable state with bal0 = 190,
//        bal1 = 10 and lpSupply = 196 held by one LP.  Under M1 the same
//        deposit gives lpSupply 199 and the state is unreachable.
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
//    exchange0for1    PERMISSIONLESS  contracts/pools/compound/StableSwapCompound.vy:452  
//    exchange1for0    PERMISSIONLESS  contracts/pools/compound/StableSwapCompound.vy:452  
//    addLiquidity     UNRESOLVED      no contract function matched by name
//    removeLiquidity  UNRESOLVED      no contract function matched by name
// --------------------------------------------------------------------------
module curve {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// StableSwap3Pool.vy:204 `Ann = amp * N_COINS`; amp is `_A()`, constant here.
  pure val AMP: int = 100
  /// StableSwap3Pool.vy:78
  pure val FEE_DENOMINATOR: int = 10000000000
  /// StableSwap3Pool.vy:95, the 3pool deployment value: 4e6/1e10 = 0.04%.
  pure val FEE: int = 4000000
  /// StableSwap3Pool.vy:373 `_fee = self.fee * N_COINS / (4 * (N_COINS - 1))`.
  /// Derived, not a literal — the derivation is itself part of the mechanism.
  pure val ADD_FEE: int = FEE * NEWTON_N / (4 * (NEWTON_N - 1))
  /// Spec-level i64 bound.  See ABSTRACTED.
  pure val MAX_BALANCE: int = 1000000
  /// MEASURED, not prescribed.  The largest |D_next - D| at a returned D over
  /// the whole reachable grid.  See `inv_newtonResidual` for why it is 3 and not
  /// the 1 that P2-SCOPE §5 row 2 asks for.
  pure val NEWTON_RESIDUAL_MAX: int = 3

  pure val LPS: Set[str] = Set("alice", "bob")

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN D (convention 8a; see BOUNDS for 8b and 8c)
  //
  // Deposits are drawn as PAIRS rather than as two independent amounts.  Eight
  // pairs is eight branches; eight amounts squared is sixty-four, and at
  // sixty-four the two-step witnesses below stop being sampled at all.  Each
  // pair is here for a stated reason:
  //   (190,10)      T0-LIVE.  D = 196, the blend says 199, 2*sqrt(xy) says 86.
  //   (10,190)      the mirror.  Same D, and the peak differs, because get_D is
  //                 asymmetric (two sequential floor divisions in D_P).
  //   (100,100)     the peg.  D = S = 200, one iteration, every rival agrees.
  //   (1,100000)    the DEPTH witness: the break fires on iteration 8 exactly.
  //   (1000000,100) iteration 7, and the largest Newton intermediate in D.
  //   (100000,100000) the scale at which both fees become visible.
  //   (100000,0) / (0,100000)  single-sided deposits: the imbalance fee's site.
  // ---------------------------------------------------------------------------

  pure val DEPOSITS: Set[(int, int)] = Set(
    (190, 10), (10, 190), (100, 100), (1, 100000),
    (1000000, 100), (100000, 100000), (100000, 0), (0, 100000),
  )
  pure val EXCHANGE_INPUTS: Set[int] = Set(1, 10, 1000, 100000)
  pure val BURN_SHARES: Set[int] = Set(1, 96, 1000, 100000)

  pure val INIT_BALANCE: int = 0
  pure val INIT_SUPPLY: int = 0
  pure val INIT_LP: int = 0

  pure val OP_INIT: str = "init"
  pure val OP_ADD: str = "add_liquidity"
  pure val OP_EXCH0: str = "exchange0for1"
  pure val OP_EXCH1: str = "exchange1for0"
  pure val OP_REMOVE: str = "remove_liquidity"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var bal0: int              // self.balances[0]
  var bal1: int              // self.balances[1]
  var lpSupply: int          // self.token.totalSupply()
  var lpBal: str -> int      // pool-token balances
  var lastOp: str            // GHOST — trace label, see header

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  `newtonD`, `newtonDConverged`, `newtonDIters` and `newtonDResidual` come
  //  from kernel.qnt EXTENSION 1 and are not restated here.
  // ===========================================================================

  /// LOCAL PRIMITIVE: `newtonY` — StableSwap3Pool.vy get_y (:353-411), N = 2.
  /// One consumer (this file), so it is module-local per P2-SCOPE §3, but it is
  /// built out of the kernel's `NewtonState` / `newtonAdvance`, which is the
  /// half that generalises.  Specialised to i = 0, j = 1 the coin loop leaves
  ///   S_ = x,  c = D*D/(x*N) * D/(Ann*N),  b = x + D/Ann
  /// and the iteration is  y <- (y*y + c) / (2*y + b - D)  from y = D, with the
  /// SAME `break` as get_D.  The `b - D` is written exactly as the contract
  /// writes it (:389 `b = S_ + D / Ann`, :392 `2*y + b - D`).
  pure def newtonYFull(x: int, d: int, amp: int, maxIter: int): NewtonState =
    if (x <= 0 or d <= 0) { v: 0, vprev: 0, done: true, iters: 0 }
    else {
      val ann = amp * NEWTON_N
      val c1 = d * d / (x * NEWTON_N)
      val c = c1 * d / (ann * NEWTON_N)
      val b = x + d / ann
      range(0, maxIter).foldl({ v: d, vprev: 0, done: false, iters: 0 },
        (st, _) =>
          if (st.done) st
          else newtonAdvance(st, (st.v * st.v + c) / (2 * st.v + b - d)))
    }

  pure def newtonY(x: int, d: int, amp: int): int =
    newtonYFull(x, d, amp, NEWTON_K).v

  pure def newtonYConverged(x: int, d: int, amp: int): bool =
    newtonYFull(x, d, amp, NEWTON_K).done

  /// StableSwap3Pool.vy:466 `dy_fee = dy * self.fee / FEE_DENOMINATOR`.
  /// Floors, so the pool keeps the residue.
  pure def exchangeFee(dyGross: int): int = mulDivDown(dyGross, FEE, FEE_DENOMINATOR)

  /// StableSwap3Pool.vy:462-468, the whole trade:
  ///   x = xp[i] + dx ;  y = get_y(i,j,x,xp) ;  dy = xp[j] - y - 1 ;  dy -= dy_fee
  /// The `- 1` is the contract's own rounding gift to the pool (:465 comment
  /// "just in case there were some rounding errors") and is never dropped.
  pure def exchangeDy(bIn: int, bOut: int, dx: int, d: int): int = {
    val gross = bOut - newtonY(bIn + dx, d, AMP) - 1
    gross - exchangeFee(gross)
  }

  /// StableSwap3Pool.vy:381-388.  `ideal_balance = D1 * old_balances[i] / D0`;
  /// the charge is on the DISTANCE from that ideal, in either direction, so a
  /// deposit that moves the pool off its own ratio pays and a balanced one does
  /// not.  This is the only reason D2 exists and differs from D1.
  pure def imbalanceFee(idealBal: int, newBal: int): int = {
    val diff = if (idealBal > newBal) idealBal - newBal else newBal - idealBal
    mulDivDown(ADD_FEE, diff, FEE_DENOMINATOR)
  }

  /// StableSwap3Pool.vy:392-397.  First deposit takes D1 whole ("take the dust
  /// if there was any"); every later one is paid on the FEE-ADJUSTED growth
  /// D2 - D0, not on D1 - D0, which is where the imbalance charge lands.
  pure def addLiquidityMint(supply: int, d0: int, d1: int, d2: int): int =
    if (supply == 0) d1 else mulDivDown(supply, d2 - d0, d0)

  /// StableSwap3Pool.vy:504 `value = self.balances[i] * _amount / total_supply`.
  /// Floors: the residue stays with the remaining LPs.
  pure def proportionalWithdraw(shares: int, bal: int, supply: int): int =
    mulDivDown(shares, bal, supply)

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed
  //  from the cited Vyper line in integer arithmetic.  Values marked [SEP] are
  //  ones the v1 `approxD` blend cannot produce.
  // ===========================================================================

  // -- newtonD, the five P2-CONTRACT §A.2 points (get_D, :195-218) ------------
  pure val t0_d_a: bool = newtonD(100, 100, AMP) == 200          // blend agrees
  pure val t0_d_b: bool = newtonD(150, 50, AMP) == 199           // blend agrees
  pure val t0_d_c: bool = newtonD(180, 20, AMP) == 198           // [SEP] v1 199
  pure val t0_d_d: bool = newtonD(190, 10, AMP) == 196           // [SEP] v1 199
  pure val t0_d_e: bool = newtonD(199, 1, AMP) == 170            // [SEP] v1 199

  // -- newtonD on the declared domain, including the asymmetry ----------------
  pure val t0_d_f: bool = newtonD(10, 190, AMP) == 196
  pure val t0_d_g: bool = newtonD(1, 100000, AMP) == 18675       // [SEP] v1 99503
  pure val t0_d_h: bool = newtonD(1000000, 100, AMP) == 369802   // [SEP] v1 995125
  pure val t0_d_i: bool = newtonD(100000, 100000, AMP) == 200000

  // -- the `break`, which a bare foldl deletes (6f: both sides of NEWTON_K) ---
  pure val t0_it_a: bool = newtonDIters(100, 100, AMP) == 1
  pure val t0_it_b: bool = newtonDIters(190, 10, AMP) == 2
  pure val t0_it_c: bool = newtonDIters(1000000, 100, AMP) == 7
  pure val t0_it_d: bool = newtonDIters(1, 100000, AMP) == NEWTON_K

  // -- THE DIVERGENCE WITNESS.  K = 8 is not enough at extreme imbalance, and
  //    the spec says so instead of returning a number the contract would not
  //    have returned.  (10^5,1) and (10^6,1) are period-2 limit cycles: they do
  //    not converge at K = 96 either.  (1,10^5) is their transpose and DOES
  //    converge, because D_P is two sequential floor divisions.
  pure val t0_cv_a: bool = newtonDConverged(199, 1, AMP)
  pure val t0_cv_b: bool = not(newtonDConverged(100000, 1, AMP))
  pure val t0_cv_c: bool = not(newtonDConverged(1000000, 1, AMP))
  pure val t0_cv_d: bool = newtonDConverged(1, 100000, AMP)

  // -- newtonY (get_y, :353-411) ----------------------------------------------
  pure val t0_y_a: bool = newtonY(200, 196, AMP) == 5
  pure val t0_y_b: bool = newtonY(1001, 18675, AMP) == 18032
  pure val t0_y_c: bool = newtonYConverged(200, 196, AMP)

  // -- exchangeFee / exchangeDy (:462-468); 8c on the fee, 6c on the quotient -
  pure val t0_xf_a: bool = exchangeFee(4) == 0                   // fee invisible
  pure val t0_xf_b: bool = exchangeFee(81967) == 32              // 32.78 -> 32
  pure val t0_xf_c: bool = exchangeFee(99350) == 39              // 39.74 -> 39
  pure val t0_xd_a: bool = exchangeDy(190, 10, 10, 196) == 4
  pure val t0_xd_b: bool = exchangeDy(1, 100000, 1000, 18675) == 81935

  // -- imbalanceFee (:381-388); 8c on ADD_FEE, 6c on both quotients -----------
  pure val t0_if_a: bool = imbalanceFee(149907, 200000) == 10    // 10.018 -> 10
  pure val t0_if_b: bool = imbalanceFee(149907, 100000) == 9     // 9.981  -> 9
  pure val t0_if_c: bool = imbalanceFee(100, 150) == 0           // fee invisible

  // -- addLiquidityMint (:392-397), both branches (6f) ------------------------
  pure val t0_m_a: bool = addLiquidityMint(0, 0, 196, 196) == 196
  pure val t0_m_b: bool = addLiquidityMint(196, 196, 400, 400) == 204
  pure val t0_m_c: bool = addLiquidityMint(200000, 200000, 299814, 299795) == 99795

  // -- proportionalWithdraw (:504), 6c inexact quotients ----------------------
  pure val t0_w_a: bool = proportionalWithdraw(96, 190, 196) == 93   // 93.06
  pure val t0_w_b: bool = proportionalWithdraw(96, 10, 196) == 4     // 4.89
  pure val t0_w_c: bool = proportionalWithdraw(100, 190, 196) == 96  // 96.93

  pure val inv_T0: bool = and {
    t0_d_a, t0_d_b, t0_d_c, t0_d_d, t0_d_e, t0_d_f, t0_d_g, t0_d_h, t0_d_i,
    t0_it_a, t0_it_b, t0_it_c, t0_it_d,
    t0_cv_a, t0_cv_b, t0_cv_c, t0_cv_d,
    t0_y_a, t0_y_b, t0_y_c,
    t0_xf_a, t0_xf_b, t0_xf_c, t0_xd_a, t0_xd_b,
    t0_if_a, t0_if_b, t0_if_c,
    t0_m_a, t0_m_b, t0_m_c,
    t0_w_a, t0_w_b, t0_w_c,
  }

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    bal0' = INIT_BALANCE,
    bal1' = INIT_BALANCE,
    lpSupply' = INIT_SUPPLY,
    lpBal' = LPS.mapBy(_ => INIT_LP),
    lastOp' = OP_INIT,
  }

  /// StableSwap3Pool.vy add_liquidity (:371-397).  D0 is taken BEFORE the
  /// deposit and only when the pool already has a supply (:377-379); D1 after;
  /// D2 after the per-coin charge is removed from the copy used for minting.
  /// All three go through the same iteration, so all three carry a convergence
  /// obligation, and the action is disabled if any of them fails to break.
  action addLiquidity(caller: str, a0: int, a1: int): bool = all {
    LPS.contains(caller),
    a0 >= 0,
    a1 >= 0,
    a0 + a1 > 0,
    lpSupply > 0 or (a0 > 0 and a1 > 0),
    bal0 + a0 <= MAX_BALANCE,
    bal1 + a1 <= MAX_BALANCE,
    val bootstrap = lpSupply == 0
    val st0 = newtonDFull(bal0, bal1, AMP, NEWTON_K)
    val n0 = bal0 + a0
    val n1 = bal1 + a1
    val st1 = newtonDFull(n0, n1, AMP, NEWTON_K)
    val d0 = if (bootstrap) 0 else st0.v
    val d1 = st1.v
    val f0 = if (bootstrap) 0 else imbalanceFee(mulDivDown(d1, bal0, d0), n0)
    val f1 = if (bootstrap) 0 else imbalanceFee(mulDivDown(d1, bal1, d0), n1)
    val st2 = newtonDFull(n0 - f0, n1 - f1, AMP, NEWTON_K)
    val minted = addLiquidityMint(lpSupply, d0, d1, st2.v)
    all {
      st0.done,
      st1.done,
      st2.done,
      d1 > d0,
      minted > 0,
      bal0' = n0,
      bal1' = n1,
      lpSupply' = lpSupply + minted,
      lpBal' = lpBal.put(caller, lpBal.get(caller) + minted),
      lastOp' = OP_ADD,
    }
  }

  /// StableSwap3Pool.vy exchange (:431-490), coin0 in.  The pool does not quote;
  /// it solves its own invariant for the other balance at the new one, which is
  /// what `newtonY` is, and the difference minus the fee is what leaves.
  action exchange0for1(dx: int): bool = all {
    dx > 0,
    bal0 > 0,
    bal1 > 0,
    lpSupply > 0,
    bal0 + dx <= MAX_BALANCE,
    val st = newtonDFull(bal0, bal1, AMP, NEWTON_K)
    val sy = newtonYFull(bal0 + dx, st.v, AMP, NEWTON_K)
    val dy = exchangeDy(bal0, bal1, dx, st.v)
    val after = newtonDFull(bal0 + dx, bal1 - dy, AMP, NEWTON_K)
    all {
      st.done,
      sy.done,
      after.done,
      dy > 0,
      dy < bal1,
      bal0' = bal0 + dx,
      bal1' = bal1 - dy,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
      lastOp' = OP_EXCH0,
    }
  }

  /// StableSwap3Pool.vy exchange (:431-490), coin1 in.  Separate action because
  /// get_D is asymmetric, so this is genuinely a different computation.
  action exchange1for0(dx: int): bool = all {
    dx > 0,
    bal0 > 0,
    bal1 > 0,
    lpSupply > 0,
    bal1 + dx <= MAX_BALANCE,
    val st = newtonDFull(bal0, bal1, AMP, NEWTON_K)
    val sy = newtonYFull(bal1 + dx, st.v, AMP, NEWTON_K)
    val dy = exchangeDy(bal1, bal0, dx, st.v)
    val after = newtonDFull(bal0 - dy, bal1 + dx, AMP, NEWTON_K)
    all {
      st.done,
      sy.done,
      after.done,
      dy > 0,
      dy < bal0,
      bal0' = bal0 - dy,
      bal1' = bal1 + dx,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
      lastOp' = OP_EXCH1,
    }
  }

  /// StableSwap3Pool.vy remove_liquidity (:498-515).  The only path in the pool
  /// that does not touch D at all: pro rata on the raw balances.
  action removeLiquidity(caller: str, shares: int): bool = all {
    LPS.contains(caller),
    shares > 0,
    lpBal.get(caller) >= shares,
    lpSupply >= shares,
    val out0 = proportionalWithdraw(shares, bal0, lpSupply)
    val out1 = proportionalWithdraw(shares, bal1, lpSupply)
    val after = newtonDFull(bal0 - out0, bal1 - out1, AMP, NEWTON_K)
    all {
      out0 > 0,
      out1 > 0,
      shares == lpSupply or (bal0 - out0 > 0 and bal1 - out1 > 0),
      after.done,
      bal0' = bal0 - out0,
      bal1' = bal1 - out1,
      lpSupply' = lpSupply - shares,
      lpBal' = lpBal.put(caller, lpBal.get(caller) - shares),
      lastOp' = OP_REMOVE,
    }
  }

  /// Convention 6 / 6g: every `nondet` is exogenous — a transaction sender or a
  /// calldata amount.  Nothing the pool itself computes is drawn here.
  action step: bool = {
    nondet caller = LPS.oneOf()
    nondet dep = DEPOSITS.oneOf()
    nondet dx = EXCHANGE_INPUTS.oneOf()
    nondet shares = BURN_SHARES.oneOf()
    any {
      addLiquidity(caller, dep._1, dep._2),
      exchange0for1(dx),
      exchange1for0(dx),
      removeLiquidity(caller, shares),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — pool tokens are neither created nor destroyed outside
  /// add_liquidity and remove_liquidity.  This is the T2 command's invariant.
  val inv_conservation: bool =
    LPS.fold(0, (acc, u) => acc + lpBal.get(u)) == lpSupply

  val inv_bounds: bool = and {
    bal0 >= 0,
    bal1 >= 0,
    lpSupply >= 0,
    bal0 <= MAX_BALANCE,
    bal1 <= MAX_BALANCE,
    LPS.forall(u => lpBal.get(u) >= 0),
  }

  /// THE OBLIGATION THE UNROLLING EXPORTS.  Every state this run reaches has a D
  /// the contract's `break` would actually have produced within NEWTON_K steps.
  /// If this ever fails, K is too small for the declared domain and the spec is
  /// unsound — it does not fail silently, which is the entire reason `done` is
  /// carried in the accumulator instead of being dropped by a bare `foldl`.
  val inv_dConverged: bool =
    (bal0 == 0 or bal1 == 0) or newtonDConverged(bal0, bal1, AMP)

  /// P2-SCOPE §5 row 2 asks for `inv_newtonResidual` with the bound 1.  THAT
  /// INVARIANT IS FALSE FOR THE CONTRACT, and the correction is recorded here
  /// rather than worked around: `get_D`'s `break` bounds the STEP,
  /// |D - Dprev| <= 1 (:211-217), not the RESIDUAL at the returned D.  The two
  /// coincide only where the iteration is contracting.  At (100010, 1) the loop
  /// breaks on iteration 8 with D = 18677 and a residual of 3, and the run finds
  /// that state at depth 2.  Measured over the whole reachable grid: residual 0
  /// at 370 pairs, 1 at 13, 2 at 3, 3 at 2 — so the true bound is 3.  The
  /// discriminating power that is lost here is carried by `inv_T0` and by
  /// `wit_live_newtonD` instead; the v1 blend's residual at (199,1) is 28.
  val inv_newtonResidual: bool =
    (bal0 == 0 or bal1 == 0) or newtonDResidual(bal0, bal1, AMP) <= NEWTON_RESIDUAL_MAX

  /// P2-SCOPE §5 row 2, `wit_imbalanced` restated as an invariant: D is sandwiched
  /// between the constant-product bound 2*sqrt(x*y) and the constant-sum bound
  /// x+y, with equality at the peg.  This is what "A interpolates between the two
  /// curves" means as a checkable statement, and it is the property M2 (chaos)
  /// satisfies but M3 (constant-sum) breaks off the peg.
  val inv_dSandwich: bool =
    (bal0 == 0 or bal1 == 0) or and {
      2 * isqrtFloor(bal0 * bal1) <= newtonD(bal0, bal1, AMP),
      newtonD(bal0, bal1, AMP) <= bal0 + bal1,
    }

  /// Curve's virtual price never falls below 1: D is the pool's own valuation of
  /// itself, and the pool token is issued against it, so `D >= totalSupply` at
  /// every state.  Both fees and every floor division push it strictly up; only
  /// a mint that over-issued could break it.
  val inv_virtualPriceGe1: bool =
    lpSupply == 0 or newtonD(bal0, bal1, AMP) >= lpSupply

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_dConverged,
    inv_newtonResidual,
    inv_dSandwich,
    inv_virtualPriceGe1,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (§D, the fifth trap).
  //  Each must be VIOLATED by `quint run --invariant=<name>`.  A `pure def` cited
  //  only by `pure val` equalities is a deleted mechanism carrying a certificate,
  //  so every registry name below is pinned by a REACHABLE STATE as well.
  // ===========================================================================

  pure val T0_LIVE_B0: int = 190
  pure val T0_LIVE_B1: int = 10
  pure val T0_LIVE_D: int = 196

  /// T0-LIVE: newtonD(190,10,100) = 196 as a state change.  Under M1 the same
  /// deposit gives 199 and under M3 it gives 200, so this state is unreachable
  /// for both.  Depth 1 from init.
  val wit_live_newtonD: bool =
    not(and {
      bal0 == T0_LIVE_B0,
      bal1 == T0_LIVE_B1,
      lpSupply == T0_LIVE_D,
      LPS.exists(u => lpBal.get(u) == T0_LIVE_D),
    })

  /// `newtonD` ran OFF THE PEG — the region where every member of M disagrees.
  /// A peg-only witness proves nothing, which is exactly v1's defect: its whole
  /// state space sat at bal0 = bal1 = 100, where blend, sum and D all agree.
  val wit_used_newtonD: bool =
    not(and {
      lpSupply > 0,
      lpSupply == newtonD(bal0, bal1, AMP),
      bal0 != bal1,
    })

  /// THE DEPTH IS LOAD-BEARING.  A reachable state at which the contract's loop
  /// ran the full NEWTON_K times before breaking, so an unrolling one step
  /// shallower would return a different D here and no invariant would notice.
  /// Reached by the (1, 100000) deposit at depth 1.
  val wit_newtonDeep: bool =
    not(and {
      bal0 > 0,
      bal1 > 0,
      newtonDIters(bal0, bal1, AMP) == NEWTON_K,
    })

  /// `newtonY` ran: the state reached by exchanging 10 of coin0 into the T0-LIVE
  /// pool.  bal1 = 10 - (10 - newtonY(200,196,100) - 1) = 6 holds only if the
  /// solver returned exactly 5; v1's `ideal = dx` gives bal1 = 6 too by accident
  /// at dx = 10 but bal0 = 200 with lpSupply = 196 pins the pool it came from,
  /// and `wit_used_exchangeFee` below pins a state v1 cannot produce at all.
  val wit_used_newtonY: bool =
    not(and { bal0 == 200, bal1 == 6, lpSupply == 196 })

  /// `exchangeFee` ran AND WAS NON-ZERO.  From the (1,100000) deposit, exchanging
  /// 1000 of coin0 gives gross 81967, fee 32, dy 81935, so bal1 = 18065.  With
  /// the fee deleted bal1 would be 18033.  Depth 2.
  val wit_used_exchangeFee: bool =
    not(and { bal0 == 1001, bal1 == 18065, lpSupply == 18675 })

  /// `imbalanceFee` ran AND WAS NON-ZERO.  Deposit (100000,100000) then
  /// (100000,0): D0 = 200000, D1 = 299814, the per-coin charges are 10 and 9,
  /// D2 = 299795 and the mint is 99795.  With the charge deleted the mint would
  /// be 99814 and lpSupply would be 299814.  Depth 2.
  val wit_used_imbalanceFee: bool =
    not(and { bal0 == 200000, bal1 == 100000, lpSupply == 299795 })

  /// `addLiquidityMint` took its SECOND branch: both LPs hold pool tokens, and
  /// only one of them can have taken the first-deposit branch.  This also
  /// discharges regression signal 7 (single-user-sufficient invariants).
  val wit_used_addLiquidityMint: bool =
    not(LPS.forall(u => lpBal.get(u) > 0))

  /// `proportionalWithdraw` ran with BOTH quotients inexact: removing 96 of the
  /// 196 pool tokens from the T0-LIVE pool pays out 93 and 4, floor of 93.06 and
  /// of 4.89, leaving (97, 6) against a supply of 100.  Depth 2.
  val wit_used_proportionalWithdraw: bool =
    not(and { bal0 == 97, bal1 == 6, lpSupply == 100 })

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_addLiquidity: bool = lastOp != OP_ADD
  val wit_fired_exchange0for1: bool = lastOp != OP_EXCH0
  val wit_fired_exchange1for0: bool = lastOp != OP_EXCH1
  val wit_fired_removeLiquidity: bool = lastOp != OP_REMOVE
}
