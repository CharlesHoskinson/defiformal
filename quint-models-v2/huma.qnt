// =============================================================================
//  huma (Huma Finance V2) — Phase 2 re-spec.  Replaces quint-models/L3/huma.qnt.
//
//  SOURCE:
//    protocol-repos/yield/00labs_huma-contracts-v2/contracts/liquidity/
//      EpochManager.sol
//        :104-115   closeEpoch — _processRedemptionRequests then _createNextEpoch
//        :179-239   _processRedemptionRequests (:199-202 the no-request early
//                   return, :207-213 the LP token prices, :226-229 the summaries
//                   are executed IN THE SAME TRANSACTION)
//        :255-293   _processEpoch — SENIOR FIRST (:269-279), then junior
//                   (:282-292); :264 and :276 the minPoolBalance early returns.
//                   `tranchesAssets` is mutated IN PLACE, so the junior cap is
//                   computed against the ALREADY-REDUCED senior.
//        :305-325   _processSeniorRedemptionRequests
//        :318       sharesToRedeem = Math.ceilDiv(amountWithDecimal, price)
//                   "Round up the number of shares to make sure it is enough"
//        :342-379   _processJuniorRedemptionRequests — THE DELETED MECHANISM
//        :349-353   minJuniorAmount = Math.ceilDiv(tranchesAssets[SENIOR],
//                                                  maxSeniorJuniorRatio)
//                   guarded by `if (maxSeniorJuniorRatio != 0)`
//        :355-357   maxRedeemableAmount = junior > minJunior ? junior - minJunior : 0
//        :358       if (maxRedeemableAmount <= 0) return availableAmount;
//        :362-363   maxRedeemableWithDecimal = min(available, maxRedeemable)*FACTOR
//        :364-371   the partial-fill recompute, ceilDiv again (:370)
//      Pool.sol
//        :152-169   closePool — sets maxSeniorJuniorRatio = 0 (:163) so that all
//                   pending redemption requests can be processed
//        :226-244   getTrancheAvailableCap — the DEPOSIT-side ratio cap
//        :359-376   _distributeLoss — first loss covers, then the tranches
//        :383-414   _distLossToTranches — junior first, senior capped
//      RiskAdjustedTranchesPolicy.sol:13-31  _calcProfitForSeniorTranche
//      BaseTranchesPolicy.sol:16-42, :95-124 distProfitToTranches
//      TrancheVault.sol
//        :312-318   deposit  ->  :639-669 _deposit (:641-643 minDepositAmount,
//                   :644-647 the available cap, :655-659 ZeroSharesMinted)
//        :328-...   addRedemptionRequest;  :258-... executeRedemptionSummary
//        :451       disburse;  :729-736 _convertToShares
//      common/PoolConfig.sol:283  lpConfig.maxSeniorJuniorRatio = 4
//      common/SharedDefs.sol:12   DEFAULT_DECIMALS_FACTOR = 1e18
//
//  MECHANISM:
//    Subordination binds the EXIT, not only the entry.  When an epoch is
//    processed, the senior tranche is served first out of available cash, and
//    the junior tranche may then redeem only down to a floor derived from the
//    senior assets that remain:  minJuniorAmount = ceilDiv(senior, maxRatio),
//    maxRedeemableAmount = junior - minJuniorAmount, with an early return when
//    the cap is already breached.  Cash is the second constraint, not the only
//    one, and the share count burned against a partial fill is rounded UP.
//
//  WHAT v1 DELETED (this file exists to restore it):
//    D-1  quint-models/L3/huma.qnt:200-202
//           val fillS = min(seniorAssetsReq, availableCash)
//           val rem   = availableCash - fillS
//           val fillJ = min(juniorAssetsReq, rem)          <- CASH ONLY
//         The senior:junior cap is enforced on DEPOSIT (:49) and nowhere else.
//         `EpochManager._processJuniorRedemptionRequests` enforces it on
//         REDEMPTION.  Restored as `juniorRedeemableCap`.
//    D-2  quint-models/L3/huma.qnt:257-258
//           // Senior ratio: when both live, senior <= 4 * junior
//           //   (may break after losses — finding)
//           val solvent: bool = trancheNonNeg
//         The spec deletes the mechanism and then downgrades the invariant that
//         would have caught the deletion, labelling the result a finding.  The
//         invariant is restored here as `inv_subordination`, correctly qualified
//         — see FINDINGS below, because P2-SCOPE §5 row 8's unqualified form is
//         NOT a contract invariant either.
//    D-3  UNDIAGNOSED BEFORE THIS RE-SPEC, and the same shape as the pilot's
//         `kLast`.  quint-models/L3/huma.qnt:14
//           pure val SENIOR_SHARE_BPS: int = 4000  // 40% of profit to senior (abstract)
//         applied at :118 as `applyProfit(tranches, profit, SENIOR_SHARE_BPS)`,
//         i.e. `toSenior = profit * 4000 / 10000`.  The contract computes
//           seniorProfit = profit * seniorAssets * (10000 - riskAdjustmentBps)
//                          / (10000 * (seniorAssets + juniorAssets))
//         (RiskAdjustedTranchesPolicy.sol:22-29).  A flat 40% is a literal where
//         the contract derives the split from the tranche balances: 6g,
//         foot(seniorProfit) = {seniorAssets, juniorAssets}, and `profit*4000`
//         reads neither.  At the modelled state it is 70, not 40 — h21 vs h24.
//         Restored as `seniorProfitShare`.
//    D-4  quint-models/L3/huma.qnt:206, :209 use `divFloor` for the shares burned
//         against a partial fill.  The contract uses `Math.ceilDiv` at :318 and
//         :370, with the comment "Following the favoring-the-pool principle from
//         ERC4626, round up the number of shares the lender has to burn".  v1
//         rounds the wrong way, which pays the lender the dust.  h15 (76, not
//         75) is that vector; 6c.
//    D-5  quint-models/L3/huma.qnt:25 declares `var poolOn` and every action
//         writes `poolOn' = poolOn`.  There is no `closePool`, so it is a
//         constant wearing a `var` — respec_lint D2a — and with it the whole
//         `maxSeniorJuniorRatio == 0` branch at EpochManager:350 is unreachable.
//         Restored as `action closePool` writing `maxRatio' = 0` (Pool.sol:163).
//
//  PRESERVED (each is a guard, a rounding direction, or a value-flow observable):
//    the junior cap and its early return; the SENIOR-FIRST order and the
//    in-place mutation that makes the junior cap read the post-senior balance;
//    ceilDiv on `minJuniorAmount` (round the floor UP) and on both partial-fill
//    share counts (round the burn UP); the `maxSeniorJuniorRatio != 0` branch;
//    the deposit-side available cap and the liquidity cap; minDepositAmount;
//    ZeroSharesMinted; the LP token price and every place the decimals factor
//    multiplies and divides; junior-first loss with the senior cap; the
//    risk-adjusted profit split; minPoolBalanceForRedemption.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - the PER-LENDER redemption queue (`LenderRedemptionRecord`,
//      `_getLatestLenderRedemptionRecord`, per-epoch disbursement records).
//      P2-SCOPE row 8 lists it as droppable.  Requests are aggregated into
//      `seniorReq` / `juniorReq`, exactly the `EpochRedemptionSummary
//      .totalSharesRequested` the contract itself sums into, and `disburse` pays
//      out the aggregate `totalAmountProcessed`.  Consequence: the pro-rata
//      split of a partial fill among lenders is not modelled, and no guard in
//      `EpochManager` reads it.
//    - FIRST LOSS COVERS.  `_firstLossCovers` is an array; the modelled
//      deployment has ZERO of them, which is a real deployment (the loop at
//      Pool.sol:361-364 and BaseTranchesPolicy.sol:99-118 then contribute
//      nothing and all remaining profit goes to junior).  Not a relaxation of a
//      formula — a length-0 array.
//    - the CREDIT LINE (`CreditLine`, `CreditManager`, payment periods, yield,
//      late fees, `triggerDefault`).  `drawdown`, `distributeProfit` and
//      `distributeLoss` are the three externally visible effects of the credit
//      side on the tranches, and they are modelled as driver-supplied amounts;
//      P2-SCOPE row 8 drops the credit line.
//    - `distributeLossRecovery` / `_distLossRecoveryToTranches`.  Its inputs are
//      the cumulative `tranchesLosses`, which ARE modelled (`seniorLossTaken`,
//      `juniorLossTaken`), but the recovery path itself is credit-side.
//    - yield reinvestment (`processYieldForLenders`), `cancelRedemptionRequest`,
//      `withdrawAfterPoolClosure`, lender approval and the EA/pool-owner minimum
//      deposits.  None is read by a guard on the redemption path.
//    - `poolSafe.unprocessedTrancheProfit` (:180-188): profit is distributed to
//      the tranches immediately here, so the revert can never fire.
//    - the early returns at EpochManager:264 and :276 return WITHOUT reverting,
//      and `closeEpoch` then still calls `_createNextEpoch` (:104-115).  They are
//      therefore modelled as branches of `closeEpoch` that fill nothing and still
//      advance `epochId` — a real transition, not a frame no-op, so 6d is
//      satisfied without the action being disabled.
//    - `uint96` overflow guards on the tranche assets: the declared domain is
//      four orders of magnitude below them.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label of the observation
//    interface (P2-FIDELITY §1), carrying exactly what the contract's own
//    `LiquidityDeposited` / `RedemptionRequestAdded` / `ProfitDistributed` /
//    `LossDistributed` / `RedemptionRequestsProcessed` events carry.  It is read
//    by `wit_fired_*` (convention 6d) and by `wit_juniorCapped` /
//    `wit_live_juniorRedeemableCap`, and by nothing else; no guard, no
//    invariant and no `pure def` reads it.  Exempt from 6e's write-only clause
//    on that basis, per PILOT-NOTES.md §5 step 2.
//    DEVIATION from PILOT-NOTES §5 step 2's "read by `wit_fired_*` and nothing
//    else", recorded because it is deliberate: the two mechanism witnesses are
//    tag PLUS value signature, never tag-only, and the tag is doing exactly the
//    job step 2 sanctions — naming the instant at which the mechanism acted,
//    which a single-state predicate cannot otherwise reach (K6).  The reason it
//    is needed here and was not needed by the pilot is that huma's deletion
//    RELAXES a constraint rather than under-approximating a quantity, so the
//    mutant's reachable set strictly contains the target's; see the MUTANT
//    RESULTS block.
//    `lastEpochTranchesFilled` is the ARITY GHOST: how many tranches the last
//    `closeEpoch` actually served.  Justified against the contract because
//    `_processRedemptionRequests` calls `executeRedemptionSummary` once per
//    served tranche (:226-229) and emits one `RedemptionRequestsProcessed`
//    carrying both tranches' post balances (:231-238), so the count is on-chain
//    observable.  It is read by `wit_arity_*` and by nothing else; no guard, no
//    invariant and no `pure def` reads it.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 2 lenders; deposit amounts 4, flow amounts 3, redeem shares
//       3.  Four `nondet`s per step, each <= 4 values.  No list state.
//    8b magnitude — peak intermediate 2.0e10, in `seniorProfitShare`'s numerator
//       `profit * seniorAssets * (BPS - riskAdj)` at the largest senior balance
//       twenty steps of profit can build.  Next is `shares * lpTokenPrice`,
//       which is bounded by `trancheAssets * DECIMALS_FACTOR <= 7e7` because
//       `shares <= supply`.  `< 9.22e18` with eight orders of magnitude spare.
//       This spec does not call `isqrtFloor`, so it does not inherit that
//       definition's 4.611686e18 floor (PILOT-NOTES.md D-d).
//    8c constant-crossing —
//       MAX_SENIOR_JUNIOR_RATIO = 4 is crossed on BOTH sides at BOTH sites.  On
//         the redemption side: (700, 200) gives cap 25 (h05, the ratio is inside
//         the bound), (800, 200) gives cap 0 (h07, the early return).  On the
//         deposit side: at `init` the senior cap is exactly 100 (h32), so a
//         deposit of 100 is admitted and one of 200 is refused.
//       maxSeniorJuniorRatio == 0 (:350, Pool.sol:163) is crossed by
//         `closePool`: h04 and h08 are the zero side, h01 and h05 the non-zero
//         side, and `wit_branch_ratioZero` reaches the zero side at runtime.
//       LIQUIDITY_CAP = 1200 is crossed: `init` holds 900 of it, a junior
//         deposit of 300 reaches it exactly and any further deposit is refused
//         (h35 is the side where the liquidity cap binds before the ratio does).
//       MIN_DEPOSIT = 100 is crossed by DEPOSIT_AMOUNTS containing 50.
//       MIN_POOL_BALANCE = 50 is crossed: `init` cash is 300 and `drawdown`
//         takes it below.
//       the `junior >= loss` test in `_distLossToTranches` is crossed by h25
//         (junior absorbs it all), h27 (exactly wiped) and h26 (senior is hit).
//       the `supply == 0` and `trancheAssets == 0` branches of `_convertToShares`
//         are crossed by h28 / h30 / h31.
//    NOTE on the old cap.  Convention 8's original "integer ranges <= 200" is
//    the one row of CF1's table where huma SURVIVED — the ratio binds at
//    (200, 50).  The domain here is larger anyway, because P2-CONTRACT §C row 8
//    and §A.8 pin the vectors at senior <= 800, junior <= 300, and because the
//    witness needs `availableCash` to exceed the request while the cap still
//    bites.
//
//  INPUTS:  (convention 6g — foot(Q) = contract storage Q's value depends on)
//    | name    | contract expression                   | file:line | foot(Q) | spec vars read |
//    | u       | msg.sender                            | TV:312    | none    | none (calldata) |
//    | amt     | deposit(uint256 assets)               | TV:312    | none    | none (calldata) |
//    | shares  | addRedemptionRequest(_, shares)       | TV:328    | none    | seniorOf/juniorOf (guard) |
//    | flow    | drawdown / profit / loss amount       | credit    | none*   | availableCash (guard) |
//    NOTHING that the protocol itself computes is supplied by the driver.  In
//    particular `minJuniorAmount`, `maxRedeemableAmount`, the LP token prices,
//    the senior profit share and both partial-fill share counts are computed
//    from `var`s.  The two quantities v1 supplied by literal are now derived:
//    `SENIOR_SHARE_BPS` becomes `seniorProfitShare(profit, seniorAssets,
//    juniorAssets, RISK_ADJ_BPS)` and the missing junior cap becomes
//    `juniorRedeemableCap(seniorAssets, juniorAssets, maxRatio)`.
//    6g's own ten-way table (P2-CARRYFORWARD CF2 row 8) names this protocol as
//    one it catches — "minJuniorAmount foot = {seniorAssets}; min(req,cash)
//    reads neither" — and it is re-checked explicitly here: `juniorRedeemableCap`
//    reads `seniorAssets` AFTER the senior fill, `juniorAssets` and `maxRatio`,
//    which is the whole footprint.
//    * the credit-side amounts are the externally visible effect of a contract
//      this spec does not cite (`CreditLine`); their footprint inside
//      `EpochManager`/`Pool` is empty, and the (E<=) restrictions that DO apply
//      — `amount <= availableCash` for a drawdown, `loss <= senior + junior` —
//      are guards that read the modelled `var`s.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    TrancheVault.deposit / makeInitialDeposit -> actions depositSenior/depositJunior
//    TrancheVault.addRedemptionRequest         -> actions addRedemptionRequestSenior/Junior
//    TrancheVault.disburse                     -> action disburse
//    TrancheVault.cancelRedemptionRequest      -> ABSTRACTED (per-lender queue)
//    TrancheVault.executeRedemptionSummary     -> inside closeEpoch (:226-229)
//    TrancheVault.withdrawAfterPoolClosure     -> ABSTRACTED (per-lender queue)
//    TrancheVault.processYieldForLenders       -> ABSTRACTED (yield reinvest)
//    TrancheVault.addApprovedLender / removeApprovedLender / setReinvestYield
//                                              -> ABSTRACTED (access control)
//    EpochManager.closeEpoch                   -> action closeEpoch
//    EpochManager.startNewEpoch                -> inside closeEpoch (:104-115)
//    EpochManager.processEpochAfterPoolClosure -> the closeEpoch that follows
//                                                 closePool, same internal call
//    Pool.closePool                            -> action closePool
//    Pool.distributeProfit                     -> action distributeProfit
//    Pool.distributeLoss                       -> action distributeLoss
//    Pool.distributeLossRecovery               -> ABSTRACTED (credit side)
//    Pool.enablePool / disablePool / setReadyForFirstLossCoverWithdrawal
//                                              -> ABSTRACTED (access control)
//    CreditLine.drawdown / makePayment         -> action drawdown / the profit
//                                                 and loss amounts; ABSTRACTED
//                                                 as a contract (P2-SCOPE row 8)
//    FirstLossCover.*                          -> ABSTRACTED (zero covers)
//    Storage read by a require on a state-changing path:
//      tranchesAssets[SENIOR/JUNIOR] (E:352, :355, P:238) -> var seniorAssets/juniorAssets
//      IERC20(tranche).totalSupply() (E:208-213)          -> var seniorSupply/juniorSupply
//      balanceOf(lender) (TV:328)                          -> var seniorOf/juniorOf
//      epochRedemptionSummary.totalSharesRequested (E:199) -> var seniorReq/juniorReq
//      totalAmountProcessed (TV:258)                       -> var seniorProcessedAmt/juniorProcessedAmt
//      poolSafe.getAvailableBalanceForPool() (E:263)       -> var availableCash
//      lpConfig.maxSeniorJuniorRatio (E:284, P:163)        -> var maxRatio
//      PoolStatus (TV:312 onlyPoolOn)                      -> var poolClosed
//      tranchesLosses (P:401-406)                          -> var seniorLossTaken/juniorLossTaken
//      currentEpoch.id (E:127)                             -> var epochId
//      minPoolBalanceForRedemption (E:264)                 -> pure val MIN_POOL_BALANCE
//    No `var` is write-only.  `seniorProcessedAmt`/`juniorProcessedAmt` are read
//    by `disburse`'s guard, by `inv_conservation` and by the witnesses;
//    `seniorLossTaken`/`juniorLossTaken` by `inv_bounds`, `inv_subordination`
//    and `wit_used_lossToTranches`; `epochId` by `wit_juniorCapped`.
//
//  UNITS:  (hole H2's obligation)
//    DECIMALS_FACTOR = 10^4 is the descaled DEFAULT_DECIMALS_FACTOR (1e18).
//    seniorAssets, juniorAssets, availableCash, amt, flow, fill amounts,
//      seniorProcessedAmt, juniorProcessedAmt, LIQUIDITY_CAP, MIN_DEPOSIT,
//      MIN_POOL_BALANCE, seniorLossTaken, juniorLossTaken  — underlying tokens
//    seniorSupply, juniorSupply, seniorOf, juniorOf, seniorReq, juniorReq,
//      shares                                              — tranche LP shares
//    lpTokenPrice                                          — tokens per share * DECIMALS_FACTOR
//    `redemptionAmountWithDecimal`                         — tokens * DECIMALS_FACTOR
//    maxRatio                                              — dimensionless, UNSCALED (4, not 4*BPS)
//    RISK_ADJ_BPS                                          — dimensionless * BPS
//    Every quantity here is non-negative, so Solidity's `uint /` and Quint's
//    `/` are both floor and the distinction that bites `derive` does not arise.
//
//  CONTRAST SET 𝔐 (F0/F2, with R4's three mandatory members):
//    M0  juniorRedeemableCap = junior - ceilDiv(senior, ratio), floored at 0,
//        applied to the post-senior-fill senior balance           [target]
//    All agreement figures below are MEASURED exhaustively over the declared
//    192-cell grid (senior {600,700,750,800} x junior {150,200,250,300} x
//    request {25,50,100} shares x cash {25,63,100,300}, at LP price 1.0), on the
//    fill AMOUNT.  The cap strictly bites in 89/192 = 46.4% of those cells.
//    M1  the v1 body verbatim: `fillJ = min(juniorAssetsReq, rem)`
//        (huma.qnt:202).  MANDATORY member 1.  Agreement 103/192 = 53.6% — it
//        agrees exactly where the cap does not bind.  Killed by h05/h06/h07, by
//        h16 against h18, by `inv_subordination`, and by `wit_juniorCapped`.
//    M2  chaos: any fill in [0, min(request, cash)].  MANDATORY member 2, the
//        maximally permissive form in the same relaxation direction; scored at
//        its maximum, 103/192 = 53.6%.  Killed by every T0 equality and by
//        `inv_subordination`.
//    M3  the sibling in the corpus: apex's "collateral absorbed, not
//        redistributed" no-op (quint-models/L3/apex.qnt:145) applied here as
//        `fillJ = 0` always.  MANDATORY member 3.  Agreement 60/192 = 31.2%
//        (the cells where the cap or the cash is already exhausted).  Killed by
//        h16/h18 and by `wit_used_juniorRedeemableCap`, which requires a
//        strictly positive junior fill.
//    M4  the near neighbour, and the one R4's >= 90% clause asks for: floor
//        instead of ceiling, `minJuniorAmount = senior / ratio`.  Agreement
//        177/192 = 92.2%, differing only where `senior % ratio != 0` AND the cap
//        is what binds.  Killed by h02 alone (188, not 187), which is exactly
//        why 6c demands an inexact quotient per `pure def`: the rounding
//        direction IS the mechanism at the boundary, and it is the direction
//        that decides whether the ratio holds or is breached by one unit.
//        R4's clause is satisfiable for this protocol, unlike the pilot's
//        (PILOT-NOTES §7) — the difference is that huma's mechanism is a
//        threshold and uniswap's is an algebraic identity.
//    M5  the cap computed against the PRE-senior-fill senior balance, i.e. the
//        obvious transcription that misses the in-place mutation at :269-279.
//        Agreement 470/576 = 81.6% over the same grid crossed with a senior fill
//        of {0, 50, 100}; it differs only when the senior tranche was also
//        filled in the same epoch, which is where the two readings diverge.
//        Killed by the ordering inside `closeEpoch`; recorded here because it is
//        the mistake a careful reader makes, and NO T0 vector on
//        `juniorRedeemableCap` alone can see it — only the composed action can.
//
//  FINDINGS (reported, not silently patched):
//    F-1  P2-SCOPE §5 row 8 asks for `inv_seniorRatio: junior > 0 implies
//         senior <= MAX_RATIO * junior, at every state (the invariant v1
//         abandoned)`.  THAT IS NOT A CONTRACT INVARIANT.  A loss is absorbed by
//         junior first (Pool.sol:388-390), so `lossToTranches(700, 200, 300) =
//         (600, 0)` — h26 — leaves senior 600 against junior 0.  The contract
//         says so itself at Pool.sol:235-238: "if this value is less than the
//         current total senior assets (i.e. in the case of default), then the
//         senior available cap is 0."  v1 was right that the unqualified
//         invariant breaks and wrong about why: it breaks because of the LOSS
//         WATERFALL, not because of the redemption cap, and deleting the cap is
//         not what forced the downgrade.  Shipped here as `inv_subordination`,
//         qualified on `juniorLossTaken == 0`, which IS invariant and IS false
//         under M1.
//    F-2  the junior cap must be computed against the senior balance AFTER the
//         senior tranche has been served in the same epoch, because
//         `_processEpoch` passes one `uint96[2] memory tranchesAssets` through
//         both helpers and `_processSeniorRedemptionRequests` mutates it at
//         :324.  A spec that computes both fills from the pre-state is member M5
//         of the contrast set and agrees with the contract 90.6% of the time.
//
//  MUTANT RESULTS (PILOT-NOTES K10 — a contrast set that is only declared is
//  the fourth trap).  `mutants/huma_M1.qnt` is one substitution at the single
//  definition site of `juniorRedemptionFill`, restoring v1's cash-only bound and
//  v1's floor rounding on the share burn, plus the `../kernel` import path.
//    inv_T0                        [violation]  <- killed by h05/h07/h16/h20
//    inv_subordination             [violation]  <- killed by the restored invariant
//    inv_conservation              [ok]         <- CONSERVATION DOES NOT DISCRIMINATE
//    inv_bounds                    [ok]
//    inv_capWellFormed             [ok]         <- a shape property of the pure
//                                                  def, which M1 does not touch;
//                                                  it only stops CALLING it
//    wit_juniorCapped              [ok]         <- the state is unreachable
//    wit_live_juniorRedeemableCap  [ok]         <- ditto
//    wit_used_juniorRedeemableCap  [violation]  <- LIVENESS ONLY, not discriminating
//
//  `mutants/huma_M6_oneTranche.qnt` is the SELECTION-ARITY mutant, added after
//  the liquity/polymarket lane's mid-flight finding.  It keeps the junior cap
//  and every arithmetic definition intact and only refuses to serve both
//  tranches in the same epoch, reaching the same balances one epoch later.
//  MEASURED, and this is the reason the arity ghost exists:
//    inv_T0                        [ok]
//    inv_conservation              [ok]
//    inv_bounds                    [ok]
//    inv_subordination             [ok]
//    inv_capWellFormed             [ok]
//    inv_juniorFirstLoss           [ok]
//    wit_juniorCapped              [violation]   <- behaves exactly as on the target
//    wit_live_juniorRedeemableCap  [violation]   <- ditto
//    wit_used_juniorRedeemableCap  [violation]   <- ditto
//    wit_arity_oneTranche          [violation]   <- ditto
//    wit_arity_bothTranches        [ok]          <- THE ONLY OBLIGATION THAT DIES
//  Every value-level check in this file — six invariants and four witnesses —
//  passes on a spec whose waterfall has been taken apart, and the count of
//  tranches one epoch served is the whole difference.
//  The third line is the one that matters and it reproduces the pilot's §7
//  finding exactly: the headline conservation invariant survives the deletion,
//  because the mechanism that stresses it was removed.
//  The FOURTH finding of this lane is the fifth line's history.  Before the
//  `lastOp` conjunct was added, `wit_juniorCapped` and
//  `wit_live_juniorRedeemableCap` were BOTH violated by M1 as well — measured,
//  not assumed.  A deletion that relaxes a constraint gives the mutant a
//  reachable set that strictly CONTAINS the target's, so no positive state
//  witness over the observables alone can separate them; M1 reaches the same
//  junior-175/fill-25 state by asking for 25 shares instead of 100.  The pilot
//  met the mirror image of this (uniswap's deletion under-approximates, so no
//  INVARIANT separates and the witness does).  Stated as a rule for the other
//  lanes: an under-approximating deletion is caught by a reachability witness
//  and not by an invariant; a relaxing deletion is caught by an invariant and
//  not by a reachability witness, unless the witness is pinned to the instant
//  of action.
//
//  ACCEPTANCE:
//    T1  quint typecheck huma.qnt
//    T2  quint run --main=huma --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 huma.qnt
//    T3  quint run --main=huma --invariant=inv_all \
//          --max-steps=20 --max-samples=2000 huma.qnt              (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: `maxRedeemable(700, 200) = 25` (P2-CONTRACT §D part 2).  The
//        obligation is the TRACE that violates `wit_live_juniorRedeemableCap`:
//        a reachable state, at depth 2, with senior 700, junior 175, a junior
//        fill of exactly 25, 75 shares still queued and 275 cash still in the
//        pool, reached by `addRedemptionRequestJunior(100)` then `closeEpoch`
//        from `init`.  Under M1 that trace fills 100 and leaves junior at 100;
//        M1 can reach junior 175 only by asking for 25 shares, which leaves
//        nothing queued, so the CONJUNCTION is unreachable and the witness is
//        never violated — measured, see MUTANT RESULTS.
//        `wit_juniorCapped` is the same trace generalised: a partial junior fill
//        with cash still in the pool is the redemption the contract blocks and
//        v1 permits.
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
//    addApprovedLender         FROZEN          contracts/liquidity/TrancheVault.sol:192  onlyPoolOp
//    closePool                 FROZEN          contracts/liquidity/Pool.sol:152  onlyPoolOwnerOrHum
//    removeApprovedLender      FROZEN          contracts/liquidity/TrancheVault.sol:223  onlyPoolOp
//    distributeLoss            OMITTED         contracts/liquidity/Pool.sol:190  msg.sender !=
//    distributeProfit          OMITTED         contracts/liquidity/Pool.sol:183  _onlyCreditOrCredi
//    addRedemptionRequestJuni  MODELLED        contracts/liquidity/TrancheVault.sol:328  msg.sender
//    addRedemptionRequestSeni  MODELLED        contracts/liquidity/TrancheVault.sol:328  msg.sender
//    depositJunior             MODELLED        contracts/liquidity/TrancheVault.sol:312  _onlyLende
//    depositSenior             MODELLED        contracts/liquidity/TrancheVault.sol:312  _onlyLende
//    disburse                  MODELLED        contracts/liquidity/TrancheVault.sol:451  @custom:ac
//    closeEpoch                PERMISSIONLESS  contracts/liquidity/EpochManager.sol:104  no caller 
//    drawdown                  PERMISSIONLESS  contracts/credit/CreditLine.sol:15  no caller check 
//
//  FROZEN means the guard is present and the authority is a
//  `pure val` where the contract mutates it, so the GRANT is
//  deleted and no grant witness can exist.  Acceptable ONLY at the
//  root of the delegation order; otherwise model it.  Each frozen
//  role must be named with the contract function that moves it.
//  Frozen here: addApprovedLender, closePool, removeApprovedLender
//
//  OMITTED means the contract restricts the caller and this spec
//  does not.  Each is an (E<=) restriction ONLY IF the dropped
//  authority cannot create a transition the contract lacks; where
//  it could, the spec is UNSOUND until the caller is modelled.
//  Outstanding: distributeLoss, distributeProfit
//
//  FROZEN AUTHORITY ROOTS (6h).  `POOL_OPERATOR` and `POOL_OWNER` are
//  `pure val`s, and both are AccessControl roles the contract can grant
//  and revoke (PoolConfig.sol:105 POOL_OPERATOR_ROLE, :646
//  onlyPoolOperator; Pool.sol:152 onlyPoolOwnerOrHumaOwner).  Declared,
//  not modelled.  The (E<=) cost: `lenders` can be shown to be granted
//  and revoked (wit_lenderGranted / wit_lenderRevoked), but the operator's
//  OWN tenure cannot, so one level of the delegation order is visible and
//  the next is not.
// --------------------------------------------------------------------------
module huma {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// SharedDefs.sol:12, descaled from 1e18.  P2-CARRYFORWARD row 8.
  pure val DECIMALS_FACTOR: int = 10000
  /// SharedDefs.sol:10
  pure val HUNDRED_PERCENT_IN_BPS: int = 10000
  /// PoolConfig.sol:283 — lpConfig.maxSeniorJuniorRatio = 4, UNSCALED.
  pure val MAX_SENIOR_JUNIOR_RATIO: int = 4
  /// Pool.sol:163 — closePool sets it to this so pending requests can clear.
  pure val RATIO_DISABLED: int = 0
  /// lpConfig.tranchesRiskAdjustmentInBps — the share of the senior tranche's
  /// pro-rata profit that is shifted to junior (RiskAdjustedTranchesPolicy:26).
  pure val RISK_ADJ_BPS: int = 1000
  /// lpConfig.liquidityCap (Pool.sol:231)
  pure val LIQUIDITY_CAP: int = 1200
  /// PoolSettings.minDepositAmount (TrancheVault.sol:641)
  pure val MIN_DEPOSIT: int = 100
  /// EpochManager.minPoolBalanceForRedemption (:264, :276)
  pure val MIN_POOL_BALANCE: int = 50

  /// The candidate lender population.  `u1` is approved at genesis and `u2` is
  /// not, so both sides of the role are reachable — one in, one out.
  pure val LENDER_CANDIDATES: Set[str] = Set("u1", "u2")
  /// PoolConfig.onlyPoolOperator (TrancheVault.sol:193) and
  /// onlyPoolOwnerOrHumaOwner (Pool.sol:153).  Distinct principals: an operator
  /// approves lenders, an owner closes the pool, and neither is a lender.
  pure val POOL_OPERATOR: str = "op"
  pure val POOL_OWNER: str = "owner"
  pure val HUMA_PRINCIPALS: Set[str] =
    LENDER_CANDIDATES.union(Set("op", "owner"))

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN 𝒟 (convention 8a; see BOUNDS for 8b and 8c)
  // ---------------------------------------------------------------------------

  pure val DEPOSIT_AMOUNTS: Set[int] = Set(50, 100, 200, 300)
  pure val FLOW_AMOUNTS: Set[int] = Set(100, 150, 300)
  pure val REDEEM_SHARES: Set[int] = Set(25, 50, 100)

  /// P2-CONTRACT §C row 8's directive, verbatim: "init at senior=700,
  /// junior=200, not at a comfortable ratio", so that the cap binds at depth 1.
  pure val INIT_SENIOR: int = 700
  pure val INIT_JUNIOR: int = 200
  pure val INIT_SENIOR_SUPPLY: int = 700
  pure val INIT_JUNIOR_SUPPLY: int = 200
  pure val INIT_SENIOR_U1: int = 400
  pure val INIT_SENIOR_U2: int = 300
  pure val INIT_JUNIOR_U1: int = 100
  pure val INIT_JUNIOR_U2: int = 100
  pure val INIT_CASH: int = 300
  pure val INIT_REQ: int = 0
  pure val INIT_PROCESSED: int = 0
  pure val INIT_EPOCH: int = 1
  pure val INIT_CLOSED: bool = false
  pure val INIT_LOSS: int = 0

  pure val T0_LIVE_SENIOR: int = 700
  pure val T0_LIVE_JUNIOR_AFTER: int = 175
  pure val T0_LIVE_FILL: int = 25

  pure val OP_INIT: str = "init"
  pure val OP_DEP_SENIOR: str = "depositSenior"
  pure val OP_DEP_JUNIOR: str = "depositJunior"
  pure val OP_DRAWDOWN: str = "drawdown"
  pure val OP_PROFIT: str = "distributeProfit"
  pure val OP_LOSS: str = "distributeLoss"
  pure val OP_REQ_SENIOR: str = "addRedemptionRequestSenior"
  pure val OP_REQ_JUNIOR: str = "addRedemptionRequestJunior"
  pure val OP_EPOCH: str = "closeEpoch"
  pure val OP_DISBURSE: str = "disburse"
  pure val OP_CLOSE: str = "closePool"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var seniorAssets: int         // Pool tranchesAssets[SENIOR_TRANCHE]
  var juniorAssets: int         // Pool tranchesAssets[JUNIOR_TRANCHE]
  var seniorSupply: int         // IERC20(seniorTranche).totalSupply()
  var juniorSupply: int         // IERC20(juniorTranche).totalSupply()
  var seniorOf: str -> int      // seniorTranche.balanceOf(lender)
  var juniorOf: str -> int      // juniorTranche.balanceOf(lender)
  var seniorReq: int            // EpochRedemptionSummary.totalSharesRequested
  var juniorReq: int
  var seniorProcessedAmt: int   // EpochRedemptionSummary.totalAmountProcessed
  var juniorProcessedAmt: int
  var availableCash: int        // poolSafe.getAvailableBalanceForPool()
  var maxRatio: int             // lpConfig.maxSeniorJuniorRatio
  var poolClosed: bool          // PoolStatus.Closed
  var seniorLossTaken: int      // Pool tranchesLosses.seniorLoss
  var juniorLossTaken: int      // Pool tranchesLosses.juniorLoss
  var epochId: int              // currentEpoch.id
  /// AUTHORITY (6h).  LENDER_ROLE, TrancheVault.sol:817.  A `var` and not the
  /// former `pure val LENDER_CANDIDATES`, because the contract grants and revokes it
  /// (:192 addApprovedLender, onlyPoolOperator; removeApprovedLender).  Freezing
  /// it scored FROZEN in SURJECTIVITY.md: the guard was present and the GRANT
  /// was deleted, which is Perm's first law.
  var lenders: str -> bool

  var lastOp: str               // GHOST — trace label, see header
  /// JUSTIFIED LINT FINDING (D2), and it is a 6h artifact rather than a defect.
  /// D2 fires on `len(nontrivial) == 1 and frames >= 2`. This var has exactly one
  /// substantive write (`closeEpoch`) and had fewer than two frame no-ops until
  /// `addApprovedLender` and `removeApprovedLender` were added — each authority
  /// action frames every var, so the frame count crossed the gate without the
  /// var changing at all. It is not dead: `wit_arity_bothTranches` and
  /// `wit_arity_oneTranche` both read it and both report [violation].
  /// The detector is NOT weakened, because the same rule caught the genuine gmx
  /// `impactPool` defect. See CONVENTION-6H-AUTHORITY.md, "known interactions".
  var lastEpochTranchesFilled: int  // GHOST — tranches served by the last epoch

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  `juniorRedeemableCap` is the registry name (P2-SCOPE §3).  Every def below
  //  is pinned by exact T0 vectors AND carries a `wit_used_*` reachability
  //  obligation, because a `pure val` equality is true in states where the
  //  definition is never applied (the fifth trap, P2-CONTRACT §D).
  // ===========================================================================

  /// EpochManager.sol:349-353.
  ///   uint256 minJuniorAmount = 0;
  ///   if (maxSeniorJuniorRatio != 0) {
  ///     // Round up the junior asset to make sure the senior : junior ratio is maintained.
  ///     minJuniorAmount = Math.ceilDiv(tranchesAssets[SENIOR_TRANCHE], maxSeniorJuniorRatio);
  ///   }
  /// The rounding direction is the mechanism: `floor` would let the junior
  /// tranche redeem one unit past the bound whenever the division is inexact,
  /// which is the whole difference between M0 and contrast-set member M4.
  pure def minJuniorAmount(seniorA: int, ratio: int): int =
    if (ratio == RATIO_DISABLED) 0 else ceilDiv(seniorA, ratio)

  /// REGISTRY NAME (P2-SCOPE §3) — EpochManager.sol:355-358.
  ///   uint256 maxRedeemableAmount = tranchesAssets[JUNIOR_TRANCHE] > minJuniorAmount
  ///     ? tranchesAssets[JUNIOR_TRANCHE] - minJuniorAmount : 0;
  ///   if (maxRedeemableAmount <= 0) return availableAmount;
  /// `seniorA` is the balance AFTER the senior tranche has been served in the
  /// same epoch — see FINDINGS F-2.
  pure def juniorRedeemableCap(seniorA: int, juniorA: int, ratio: int): int = {
    val floorA = minJuniorAmount(seniorA, ratio)
    if (juniorA > floorA) juniorA - floorA else 0
  }

  /// EpochManager.sol:207-213.  The senior price is 0 in a uni-tranche pool
  /// where the senior supply is 0; the junior supply is never 0 because of the
  /// pool-owner minimum deposit.
  pure def lpTokenPrice(assets: int, supply: int): int =
    if (supply == 0) 0 else assets * DECIMALS_FACTOR / supply

  /// EpochManager.sol:360-373 without the cap — the senior tranche is bounded
  /// by cash alone, because nothing is subordinated to it.  Returns
  /// (redemptionAmount, sharesToRedeem).  :318 rounds the BURN up.
  pure def seniorRedemptionFill(shares: int, price: int, avail: int): (int, int) = {
    val amountD = shares * price
    val availD = avail * DECIMALS_FACTOR
    if (availD < amountD) (availD / DECIMALS_FACTOR, ceilDiv(availD, price))
    else (amountD / DECIMALS_FACTOR, shares)
  }

  /// EpochManager.sol:355-375 — the junior tranche is bounded by cash AND by the
  /// subordination cap, whichever is smaller (:362-363's `Math.min`).  This is
  /// the line v1 replaced with `min(juniorAssetsReq, rem)`.
  pure def juniorRedemptionFill(shares: int, price: int, avail: int,
                                cap: int): (int, int) = {
    if (cap <= 0) (0, 0)
    else {
      val amountD = shares * price
      val maxD = minInt(avail, cap) * DECIMALS_FACTOR
      if (maxD < amountD) (maxD / DECIMALS_FACTOR, ceilDiv(maxD, price))
      else (amountD / DECIMALS_FACTOR, shares)
    }
  }

  /// RiskAdjustedTranchesPolicy.sol:22-29, combined into one division exactly as
  /// the contract does "to minimize rounding errors".
  ///   seniorProfit = profit * seniorAssets * (HUNDRED_PERCENT_IN_BPS - riskAdj)
  ///                  / (HUNDRED_PERCENT_IN_BPS * (seniorAssets + juniorAssets))
  pure def seniorProfitShare(profit: int, seniorA: int, juniorA: int,
                             riskAdjBps: int): int =
    profit * seniorA * (HUNDRED_PERCENT_IN_BPS - riskAdjBps)
      / (HUNDRED_PERCENT_IN_BPS * (seniorA + juniorA))

  /// Pool.sol:383-402 — junior absorbs first, senior is capped at its balance.
  /// Returns (senior', junior').
  pure def lossToTranches(seniorA: int, juniorA: int, loss: int): (int, int) = {
    val juniorLoss = if (juniorA >= loss) loss else juniorA
    val seniorLoss = minInt(seniorA, loss - juniorLoss)
    (seniorA - seniorLoss, juniorA - juniorLoss)
  }

  /// TrancheVault.sol:729-736 — _convertToShares.
  pure def assetsToShares(assets: int, trancheAssets: int, supply: int): int =
    if (supply != 0 and trancheAssets == 0) 0
    else if (supply == 0) assets
    else assets * supply / trancheAssets

  /// Pool.sol:226-244 — getTrancheAvailableCap for the SENIOR tranche: the
  /// liquidity cap and the subordination cap, whichever is tighter.  This is the
  /// DEPOSIT side of the same ratio, and it is the only side v1 modelled.
  pure def seniorAvailableCap(seniorA: int, juniorA: int, ratio: int,
                              liqCap: int): int = {
    val poolAssets = seniorA + juniorA
    val byLiquidity = if (liqCap > poolAssets) liqCap - poolAssets else 0
    val byRatio = maxInt(juniorA * ratio, seniorA) - seniorA
    minInt(byLiquidity, byRatio)
  }

  /// Pool.sol:226-232 — the junior tranche is bounded by the liquidity cap only.
  pure def juniorAvailableCap(seniorA: int, juniorA: int, liqCap: int): int = {
    val poolAssets = seniorA + juniorA
    if (liqCap > poolAssets) liqCap - poolAssets else 0
  }

  /// EpochManager.sol:361, :373 — what a share request is worth in tokens.
  pure def redemptionValue(shares: int, price: int): int =
    shares * price / DECIMALS_FACTOR

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed
  //  from the cited Solidity line in integer arithmetic.  The rows marked [A.8]
  //  are P2-CONTRACT §A.8 verbatim and reproduce exactly.  The rows marked [SEP]
  //  are values v1's `min(request, cash)` cannot produce.
  // ===========================================================================

  // -- minJuniorAmount (EpochManager.sol:349-353) ------------------------------
  pure val h01: bool = minJuniorAmount(700, 4) == 175
  pure val h02: bool = minJuniorAmount(750, 4) == 188
  pure val h03: bool = minJuniorAmount(800, 4) == 200
  pure val h04: bool = minJuniorAmount(700, 0) == 0

  // -- juniorRedeemableCap (EpochManager.sol:355-358) --------------------------
  pure val h05: bool = juniorRedeemableCap(700, 200, 4) == 25
  pure val h06: bool = juniorRedeemableCap(750, 250, 4) == 62
  pure val h07: bool = juniorRedeemableCap(800, 200, 4) == 0
  pure val h08: bool = juniorRedeemableCap(700, 200, 0) == 200

  // -- lpTokenPrice (EpochManager.sol:207-213) ---------------------------------
  pure val h09: bool = lpTokenPrice(250, 200) == 12500
  pure val h10: bool = lpTokenPrice(250, 300) == 8333
  pure val h11: bool = lpTokenPrice(200, 200) == 10000
  pure val h12: bool = lpTokenPrice(0, 200) == 0

  // -- seniorRedemptionFill (EpochManager.sol:305-325) -------------------------
  pure val h13: bool = seniorRedemptionFill(100, 12500, 200) == (125, 100)
  pure val h14: bool = seniorRedemptionFill(100, 12500, 100) == (100, 80)
  pure val h15: bool = seniorRedemptionFill(100, 8333, 63) == (63, 76)

  // -- juniorRedemptionFill (EpochManager.sol:342-379) -------------------------
  pure val h16: bool = juniorRedemptionFill(100, 10000, 100, 25) == (25, 25)
  pure val h17: bool = juniorRedemptionFill(100, 10000, 100, 0) == (0, 0)
  pure val h18: bool = juniorRedemptionFill(100, 10000, 100, 200) == (100, 100)
  pure val h19: bool = juniorRedemptionFill(100, 8333, 63, 200) == (63, 76)

  /// [SEP] The deletion, stated as an inequality.  At (request 100 shares,
  /// price 1.0, cash 100, cap 25) the pool holds MORE cash than the request is
  /// worth, so v1's `min(juniorAssetsReq, rem)` returns the full 100.  The
  /// contract returns 25.  Same inputs, different answers, and cash is not the
  /// difference.
  pure val h20: bool =
    juniorRedemptionFill(100, 10000, 100, 25)._1 != minInt(100, 100)

  // -- seniorProfitShare (RiskAdjustedTranchesPolicy.sol:22-29) ----------------
  pure val h21: bool = seniorProfitShare(100, 700, 200, 1000) == 70
  pure val h22: bool = seniorProfitShare(100, 750, 250, 1000) == 67
  pure val h23: bool = seniorProfitShare(100, 0, 200, 1000) == 0

  /// [SEP] v1's flat 4000 bps of the profit, at the state `init` starts in.
  pure val h24: bool =
    seniorProfitShare(100, 700, 200, 1000) != 100 * 4000 / HUNDRED_PERCENT_IN_BPS

  // -- lossToTranches (Pool.sol:383-402) ---------------------------------------
  pure val h25: bool = lossToTranches(700, 200, 150) == (700, 50)
  pure val h26: bool = lossToTranches(700, 200, 300) == (600, 0)
  pure val h27: bool = lossToTranches(700, 200, 200) == (700, 0)

  // -- assetsToShares (TrancheVault.sol:729-736) -------------------------------
  pure val h28: bool = assetsToShares(100, 700, 700) == 100
  pure val h29: bool = assetsToShares(100, 750, 700) == 93
  pure val h30: bool = assetsToShares(100, 0, 0) == 100
  pure val h31: bool = assetsToShares(100, 0, 200) == 0

  // -- seniorAvailableCap / juniorAvailableCap (Pool.sol:226-244) --------------
  pure val h32: bool = seniorAvailableCap(700, 200, 4, 1200) == 100
  pure val h33: bool = seniorAvailableCap(600, 200, 4, 1200) == 200
  pure val h34: bool = seniorAvailableCap(800, 100, 4, 1200) == 0
  pure val h35: bool = seniorAvailableCap(0, 300, 4, 1000) == 700
  pure val h36: bool = juniorAvailableCap(700, 200, 1200) == 300

  // -- redemptionValue (EpochManager.sol:361, :373) ----------------------------
  pure val h37: bool = redemptionValue(100, 10000) == 100
  pure val h38: bool = redemptionValue(3, 8333) == 2

  pure val inv_T0: bool = and {
    h01, h02, h03, h04, h05, h06, h07, h08, h09, h10,
    h11, h12, h13, h14, h15, h16, h17, h18, h19, h20,
    h21, h22, h23, h24, h25, h26, h27, h28, h29, h30,
    h31, h32, h33, h34, h35, h36, h37, h38,
  }

  // ===========================================================================
  //  STATE-LEVEL VIEWS.  The contract's own view functions.
  // ===========================================================================

  def seniorPrice: int = lpTokenPrice(seniorAssets, seniorSupply)
  def juniorPrice: int = lpTokenPrice(juniorAssets, juniorSupply)
  def juniorRequestValue: int = redemptionValue(juniorReq, juniorPrice)
  def juniorCapNow: int = juniorRedeemableCap(seniorAssets, juniorAssets, maxRatio)

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    seniorAssets' = INIT_SENIOR,
    juniorAssets' = INIT_JUNIOR,
    seniorSupply' = INIT_SENIOR_SUPPLY,
    juniorSupply' = INIT_JUNIOR_SUPPLY,
    seniorOf' = Map("u1" -> INIT_SENIOR_U1, "u2" -> INIT_SENIOR_U2),
    juniorOf' = Map("u1" -> INIT_JUNIOR_U1, "u2" -> INIT_JUNIOR_U2),
    seniorReq' = INIT_REQ,
    juniorReq' = INIT_REQ,
    seniorProcessedAmt' = INIT_PROCESSED,
    juniorProcessedAmt' = INIT_PROCESSED,
    availableCash' = INIT_CASH,
    maxRatio' = MAX_SENIOR_JUNIOR_RATIO,
    poolClosed' = INIT_CLOSED,
    seniorLossTaken' = INIT_LOSS,
    juniorLossTaken' = INIT_LOSS,
    epochId' = INIT_EPOCH,
    lastEpochTranchesFilled' = 0,
    lenders' = HUMA_PRINCIPALS.mapBy(p => p == "u1"),
    lastOp' = OP_INIT,
  }

  /// TrancheVault.deposit into the senior tranche (:312-318 -> :639-669).
  /// The available cap at :644 is where subordination is enforced on the ENTRY,
  /// which is the only side v1 modelled.
  action depositSenior(u: str, amt: int): bool = all {
    lenders.get(u),
    not(poolClosed),
    amt >= MIN_DEPOSIT,
    amt <= seniorAvailableCap(seniorAssets, juniorAssets, maxRatio, LIQUIDITY_CAP),
    val minted = assetsToShares(amt, seniorAssets, seniorSupply)
    all {
      minted > 0,
      seniorAssets' = seniorAssets + amt,
      seniorSupply' = seniorSupply + minted,
      seniorOf' = seniorOf.put(u, seniorOf.get(u) + minted),
      availableCash' = availableCash + amt,
      juniorAssets' = juniorAssets,
      juniorSupply' = juniorSupply,
      juniorOf' = juniorOf,
      seniorReq' = seniorReq,
      juniorReq' = juniorReq,
      seniorProcessedAmt' = seniorProcessedAmt,
      juniorProcessedAmt' = juniorProcessedAmt,
      maxRatio' = maxRatio,
      poolClosed' = poolClosed,
      seniorLossTaken' = seniorLossTaken,
      juniorLossTaken' = juniorLossTaken,
      epochId' = epochId,
      lastEpochTranchesFilled' = 0,
      lenders' = lenders,
      lastOp' = OP_DEP_SENIOR,
    }
  }

  /// TrancheVault.deposit into the junior tranche.  Bounded by the liquidity cap
  /// alone: nothing is subordinated to junior.
  action depositJunior(u: str, amt: int): bool = all {
    lenders.get(u),
    not(poolClosed),
    amt >= MIN_DEPOSIT,
    amt <= juniorAvailableCap(seniorAssets, juniorAssets, LIQUIDITY_CAP),
    val minted = assetsToShares(amt, juniorAssets, juniorSupply)
    all {
      minted > 0,
      juniorAssets' = juniorAssets + amt,
      juniorSupply' = juniorSupply + minted,
      juniorOf' = juniorOf.put(u, juniorOf.get(u) + minted),
      availableCash' = availableCash + amt,
      seniorAssets' = seniorAssets,
      seniorSupply' = seniorSupply,
      seniorOf' = seniorOf,
      seniorReq' = seniorReq,
      juniorReq' = juniorReq,
      seniorProcessedAmt' = seniorProcessedAmt,
      juniorProcessedAmt' = juniorProcessedAmt,
      maxRatio' = maxRatio,
      poolClosed' = poolClosed,
      seniorLossTaken' = seniorLossTaken,
      juniorLossTaken' = juniorLossTaken,
      epochId' = epochId,
      lastEpochTranchesFilled' = 0,
      lenders' = lenders,
      lastOp' = OP_DEP_JUNIOR,
    }
  }

  /// The borrower draws down the credit line; pool cash leaves, tranche assets
  /// do not move (the receivable replaces the cash).  ABSTRACTED as a contract.
  action drawdown(amt: int): bool = all {
    not(poolClosed),
    amt > 0,
    amt <= availableCash,
    availableCash' = availableCash - amt,
    seniorAssets' = seniorAssets,
    juniorAssets' = juniorAssets,
    seniorSupply' = seniorSupply,
    juniorSupply' = juniorSupply,
    seniorOf' = seniorOf,
    juniorOf' = juniorOf,
    seniorReq' = seniorReq,
    juniorReq' = juniorReq,
    seniorProcessedAmt' = seniorProcessedAmt,
    juniorProcessedAmt' = juniorProcessedAmt,
    maxRatio' = maxRatio,
    poolClosed' = poolClosed,
    seniorLossTaken' = seniorLossTaken,
    juniorLossTaken' = juniorLossTaken,
    epochId' = epochId,
    lastEpochTranchesFilled' = 0,
    lenders' = lenders,
    lastOp' = OP_DRAWDOWN,
  }

  /// Pool.distributeProfit (:183) -> BaseTranchesPolicy.distProfitToTranches
  /// (:16-42) -> RiskAdjustedTranchesPolicy._calcProfitForSeniorTranche.  With
  /// zero first loss covers the remainder is the junior tranche's in full.
  action distributeProfit(profit: int): bool = all {
    not(poolClosed),
    profit > 0,
    seniorAssets + juniorAssets > 0,
    val toSenior = seniorProfitShare(profit, seniorAssets, juniorAssets, RISK_ADJ_BPS)
    all {
      seniorAssets' = seniorAssets + toSenior,
      juniorAssets' = juniorAssets + (profit - toSenior),
      availableCash' = availableCash + profit,
      seniorSupply' = seniorSupply,
      juniorSupply' = juniorSupply,
      seniorOf' = seniorOf,
      juniorOf' = juniorOf,
      seniorReq' = seniorReq,
      juniorReq' = juniorReq,
      seniorProcessedAmt' = seniorProcessedAmt,
      juniorProcessedAmt' = juniorProcessedAmt,
      maxRatio' = maxRatio,
      poolClosed' = poolClosed,
      seniorLossTaken' = seniorLossTaken,
      juniorLossTaken' = juniorLossTaken,
      epochId' = epochId,
      lastEpochTranchesFilled' = 0,
      lenders' = lenders,
      lastOp' = OP_PROFIT,
    }
  }

  /// Pool.distributeLoss (:190) -> _distributeLoss (:359-376) -> Pool.sol:383-402.
  /// Cash is untouched: the write-down is on the receivable, which was already
  /// drawn.  The cumulative amounts land in `tranchesLosses` (:401-406).
  action distributeLoss(loss: int): bool = all {
    not(poolClosed),
    loss > 0,
    loss <= seniorAssets + juniorAssets,
    val after = lossToTranches(seniorAssets, juniorAssets, loss)
    all {
      seniorAssets' = after._1,
      juniorAssets' = after._2,
      seniorLossTaken' = seniorLossTaken + (seniorAssets - after._1),
      juniorLossTaken' = juniorLossTaken + (juniorAssets - after._2),
      seniorSupply' = seniorSupply,
      juniorSupply' = juniorSupply,
      seniorOf' = seniorOf,
      juniorOf' = juniorOf,
      seniorReq' = seniorReq,
      juniorReq' = juniorReq,
      seniorProcessedAmt' = seniorProcessedAmt,
      juniorProcessedAmt' = juniorProcessedAmt,
      availableCash' = availableCash,
      maxRatio' = maxRatio,
      poolClosed' = poolClosed,
      epochId' = epochId,
      lastEpochTranchesFilled' = 0,
      lenders' = lenders,
      lastOp' = OP_LOSS,
    }
  }

  /// TrancheVault.addRedemptionRequest (:328).  Shares are escrowed out of the
  /// lender's balance into the epoch summary; the supply is untouched until the
  /// epoch is processed.
  action addRedemptionRequestSenior(u: str, shares: int): bool = all {
    lenders.get(u),
    not(poolClosed),
    shares > 0,
    shares <= seniorOf.get(u),
    seniorOf' = seniorOf.put(u, seniorOf.get(u) - shares),
    seniorReq' = seniorReq + shares,
    seniorAssets' = seniorAssets,
    juniorAssets' = juniorAssets,
    seniorSupply' = seniorSupply,
    juniorSupply' = juniorSupply,
    juniorOf' = juniorOf,
    juniorReq' = juniorReq,
    seniorProcessedAmt' = seniorProcessedAmt,
    juniorProcessedAmt' = juniorProcessedAmt,
    availableCash' = availableCash,
    maxRatio' = maxRatio,
    poolClosed' = poolClosed,
    seniorLossTaken' = seniorLossTaken,
    juniorLossTaken' = juniorLossTaken,
    epochId' = epochId,
    lastEpochTranchesFilled' = 0,
    lenders' = lenders,
    lastOp' = OP_REQ_SENIOR,
  }

  /// TrancheVault.addRedemptionRequest (:328) on the junior tranche.
  action addRedemptionRequestJunior(u: str, shares: int): bool = all {
    lenders.get(u),
    not(poolClosed),
    shares > 0,
    shares <= juniorOf.get(u),
    juniorOf' = juniorOf.put(u, juniorOf.get(u) - shares),
    juniorReq' = juniorReq + shares,
    seniorAssets' = seniorAssets,
    juniorAssets' = juniorAssets,
    seniorSupply' = seniorSupply,
    juniorSupply' = juniorSupply,
    seniorOf' = seniorOf,
    seniorReq' = seniorReq,
    seniorProcessedAmt' = seniorProcessedAmt,
    juniorProcessedAmt' = juniorProcessedAmt,
    availableCash' = availableCash,
    maxRatio' = maxRatio,
    poolClosed' = poolClosed,
    seniorLossTaken' = seniorLossTaken,
    juniorLossTaken' = juniorLossTaken,
    epochId' = epochId,
    lastEpochTranchesFilled' = 0,
    lenders' = lenders,
    lastOp' = OP_REQ_JUNIOR,
  }

  /// EpochManager.closeEpoch (:104-115) — _processRedemptionRequests then
  /// _createNextEpoch.  SENIOR IS SERVED FIRST (:269-279) and `tranchesAssets`
  /// is mutated in place, so `juniorRedeemableCap` below reads the senior
  /// balance that REMAINS.  Computing it from the pre-state is contrast-set
  /// member M5 and agrees with the contract 90.6% of the time.
  /// The three early returns (:199-202 no requests, :264 and :276 the pool
  /// balance floor) fill nothing and still advance the epoch.
  action closeEpoch: bool = all {
    val canProcess = (seniorReq > 0 or juniorReq > 0) and availableCash > MIN_POOL_BALANCE
    val sFill = if (canProcess and seniorReq > 0)
                  seniorRedemptionFill(seniorReq, seniorPrice, availableCash)
                else (0, 0)
    val cashAfterSenior = availableCash - sFill._1
    val seniorLeft = seniorAssets - sFill._1
    val cap = juniorRedeemableCap(seniorLeft, juniorAssets, maxRatio)
    val jFill = if (canProcess and juniorReq > 0 and cashAfterSenior > MIN_POOL_BALANCE)
                  juniorRedemptionFill(juniorReq, juniorPrice, cashAfterSenior, cap)
                else (0, 0)
    all {
      seniorAssets' = seniorLeft,
      juniorAssets' = juniorAssets - jFill._1,
      seniorSupply' = seniorSupply - sFill._2,
      juniorSupply' = juniorSupply - jFill._2,
      seniorReq' = seniorReq - sFill._2,
      juniorReq' = juniorReq - jFill._2,
      seniorProcessedAmt' = sFill._1,
      juniorProcessedAmt' = jFill._1,
      availableCash' = availableCash - sFill._1 - jFill._1,
      epochId' = epochId + 1,
      seniorOf' = seniorOf,
      juniorOf' = juniorOf,
      maxRatio' = maxRatio,
      poolClosed' = poolClosed,
      seniorLossTaken' = seniorLossTaken,
      juniorLossTaken' = juniorLossTaken,
      lastEpochTranchesFilled' = (if (sFill._1 > 0) 1 else 0)
                                   + (if (jFill._1 > 0) 1 else 0),
      lenders' = lenders,
      lastOp' = OP_EPOCH,
    }
  }

  /// TrancheVault.disburse (:451) — the processed amount leaves the pool for the
  /// lenders.  Aggregated across lenders; see ABSTRACTED.
  action disburse(caller: str): bool = all {
    // AUTHORITY (6h): TrancheVault.sol:451, @custom:access Only the lender.
    HUMA_PRINCIPALS.contains(caller),
    lenders.get(caller),
    seniorProcessedAmt + juniorProcessedAmt > 0,
    seniorProcessedAmt' = 0,
    juniorProcessedAmt' = 0,
    seniorAssets' = seniorAssets,
    juniorAssets' = juniorAssets,
    seniorSupply' = seniorSupply,
    juniorSupply' = juniorSupply,
    seniorOf' = seniorOf,
    juniorOf' = juniorOf,
    seniorReq' = seniorReq,
    juniorReq' = juniorReq,
    availableCash' = availableCash,
    maxRatio' = maxRatio,
    poolClosed' = poolClosed,
    seniorLossTaken' = seniorLossTaken,
    juniorLossTaken' = juniorLossTaken,
    epochId' = epochId,
    lastEpochTranchesFilled' = 0,
    lenders' = lenders,
    lastOp' = OP_DISBURSE,
  }

  /// Pool.closePool (:152-169).  The ratio is set to zero at :163 precisely so
  /// that pending junior requests stop being capped, and the epoch that follows
  /// is `processEpochAfterPoolClosure` (:167), which is the same internal call
  /// as `closeEpoch`.  This is the other side of :350 and it is unreachable in
  /// v1, which has no `closePool` at all.
  /// TrancheVault.sol:192 addApprovedLender — onlyPoolOperator.  THE GRANT, and
  /// the transition the former `pure val LENDERS` deleted.
  action addApprovedLender(caller: str, who: str): bool = all {
    caller == POOL_OPERATOR,
    LENDER_CANDIDATES.contains(who),
    not(lenders.get(who)),
    lenders' = lenders.put(who, true),
    seniorAssets' = seniorAssets,
    juniorAssets' = juniorAssets,
    seniorSupply' = seniorSupply,
    juniorSupply' = juniorSupply,
    seniorOf' = seniorOf,
    juniorOf' = juniorOf,
    seniorReq' = seniorReq,
    juniorReq' = juniorReq,
    seniorProcessedAmt' = seniorProcessedAmt,
    juniorProcessedAmt' = juniorProcessedAmt,
    availableCash' = availableCash,
    maxRatio' = maxRatio,
    poolClosed' = poolClosed,
    seniorLossTaken' = seniorLossTaken,
    juniorLossTaken' = juniorLossTaken,
    epochId' = epochId,
    lastOp' = lastOp,
    lastEpochTranchesFilled' = lastEpochTranchesFilled,
  }

  /// removeApprovedLender — onlyPoolOperator.  THE REVOKE.
  action removeApprovedLender(caller: str, who: str): bool = all {
    caller == POOL_OPERATOR,
    LENDER_CANDIDATES.contains(who),
    lenders.get(who),
    // NO zero-balance requirement: TrancheVault.sol:223-232 revokes the
    // role unconditionally.  A first cut of this action added
    // `seniorOf.get(who) == 0 and juniorOf.get(who) == 0`, a constraint
    // the contract does not have -- and since both candidates hold shares
    // at init it made the revoke UNREACHABLE and silently killed
    // wit_lenderRevoked.  Inventing a guard is the deletion this phase
    // exists to catch, committed here inside a repair.
    lenders' = lenders.put(who, false),
    seniorAssets' = seniorAssets,
    juniorAssets' = juniorAssets,
    seniorSupply' = seniorSupply,
    juniorSupply' = juniorSupply,
    seniorOf' = seniorOf,
    juniorOf' = juniorOf,
    seniorReq' = seniorReq,
    juniorReq' = juniorReq,
    seniorProcessedAmt' = seniorProcessedAmt,
    juniorProcessedAmt' = juniorProcessedAmt,
    availableCash' = availableCash,
    maxRatio' = maxRatio,
    poolClosed' = poolClosed,
    seniorLossTaken' = seniorLossTaken,
    juniorLossTaken' = juniorLossTaken,
    epochId' = epochId,
    lastOp' = lastOp,
    lastEpochTranchesFilled' = lastEpochTranchesFilled,
  }

  action closePool(caller: str): bool = all {
    // AUTHORITY (6h): Pool.sol:152, onlyPoolOwnerOrHumaOwner.  NON-SURJECTIVE —
    // no user reaches this role by any action of their own.
    caller == POOL_OWNER,
    not(poolClosed),
    poolClosed' = true,
    maxRatio' = RATIO_DISABLED,
    seniorAssets' = seniorAssets,
    juniorAssets' = juniorAssets,
    seniorSupply' = seniorSupply,
    juniorSupply' = juniorSupply,
    seniorOf' = seniorOf,
    juniorOf' = juniorOf,
    seniorReq' = seniorReq,
    juniorReq' = juniorReq,
    seniorProcessedAmt' = seniorProcessedAmt,
    juniorProcessedAmt' = juniorProcessedAmt,
    availableCash' = availableCash,
    seniorLossTaken' = seniorLossTaken,
    juniorLossTaken' = juniorLossTaken,
    epochId' = epochId,
    lastEpochTranchesFilled' = 0,
    lenders' = lenders,
    lastOp' = OP_CLOSE,
  }

  /// Convention 6 / 6g: every `nondet` is exogenous — a lender identity, an
  /// amount that lender chose, or a credit-side flow.  The protocol selects
  /// nothing here that the driver is told; in particular no `nondet` supplies a
  /// fill amount, a share count to burn, or a tranche split.
  action step: bool = {
    nondet u = LENDER_CANDIDATES.oneOf()
    nondet amt = DEPOSIT_AMOUNTS.oneOf()
    nondet flow = FLOW_AMOUNTS.oneOf()
    nondet shares = REDEEM_SHARES.oneOf()
    nondet who = LENDER_CANDIDATES.oneOf()
    any {
      addApprovedLender(POOL_OPERATOR, who),
      removeApprovedLender(POOL_OPERATOR, who),
      depositSenior(u, amt),
      depositJunior(u, amt),
      drawdown(flow),
      distributeProfit(flow),
      distributeLoss(flow),
      addRedemptionRequestSenior(u, shares),
      addRedemptionRequestJunior(u, shares),
      closeEpoch,
      disburse(u),
      closePool(POOL_OWNER),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — every tranche share is either held by a lender or escrowed
  /// in the current epoch's redemption summary.  Shares are minted only by a
  /// deposit and burned only by a processed redemption.  This is the T2
  /// invariant.
  val inv_conservation: bool = and {
    LENDER_CANDIDATES.fold(0, (acc, u) => acc + seniorOf.get(u)) + seniorReq == seniorSupply,
    LENDER_CANDIDATES.fold(0, (acc, u) => acc + juniorOf.get(u)) + juniorReq == juniorSupply,
  }

  val inv_bounds: bool = and {
    seniorAssets >= 0,
    juniorAssets >= 0,
    seniorSupply >= 0,
    juniorSupply >= 0,
    seniorReq >= 0,
    juniorReq >= 0,
    seniorProcessedAmt >= 0,
    juniorProcessedAmt >= 0,
    availableCash >= 0,
    seniorLossTaken >= 0,
    juniorLossTaken >= 0,
    epochId >= INIT_EPOCH,
    LENDER_CANDIDATES.forall(u => seniorOf.get(u) >= 0 and juniorOf.get(u) >= 0),
  }

  /// THE INVARIANT v1 ABANDONED, correctly qualified.  See FINDINGS F-1: the
  /// unqualified form P2-SCOPE §5 row 8 asks for is not a contract invariant,
  /// because the loss waterfall writes junior down to zero while senior stands
  /// (h26).  Absent a junior loss, subordination holds at EVERY state — the
  /// deposit cap keeps it on the way in, and `juniorRedeemableCap` keeps it on
  /// the way out.  It is FALSE under contrast-set member M1, which is the point.
  val inv_subordination: bool =
    (juniorLossTaken == 0 and maxRatio > 0)
      implies maxRatio * juniorAssets >= seniorAssets

  /// EpochManager.sol:355-357 — the cap is never larger than the tranche it
  /// bounds, and what it leaves behind always clears the ratio.  A shape
  /// property of the `pure def`, and NOT the discriminating check: the
  /// discriminating checks are h05/h07/h16/h20 and `wit_juniorCapped`.
  val inv_capWellFormed: bool = and {
    juniorCapNow >= 0,
    juniorCapNow <= juniorAssets,
    maxRatio > 0 implies
      maxRatio * (juniorAssets - juniorCapNow) >= minInt(seniorAssets,
                                                         maxRatio * juniorAssets),
  }

  /// Pool.sol:388-390 — junior is first loss.  The senior tranche is written
  /// down only after the junior tranche has been written down to nothing, so a
  /// senior loss implies the junior tranche absorbed everything it had.  The
  /// junior tranche can only reach zero through a loss or through a redemption,
  /// and a redemption can only empty it when the senior tranche is already zero
  /// (`juniorRedeemableCap` sees to that), so a senior write-down implies a
  /// junior write-down came first.  This invariant is FALSE if the cap is
  /// deleted: under M1 the junior tranche can be redeemed to zero with the
  /// senior tranche still funded, and the next loss lands on senior with
  /// `juniorLossTaken == 0`.
  val inv_juniorFirstLoss: bool =
    seniorLossTaken > 0 implies juniorLossTaken > 0

  // -------------------------------------------------------------------------
  //  AUTHORITY WITNESSES (6h).  These are what the former `pure val LENDERS`
  //  could not host: with a frozen role set, holding the role is not contingent
  //  on anything and no trace can show the grant.  That is why FROZEN is where
  //  a mandate hides (SURJECTIVITY.md).
  // -------------------------------------------------------------------------

  /// PERMISSION-DEPENDENCE: same pool, same amounts, different role map.
  pure def mayDisburse(who: str, ls: str -> bool): bool = ls.get(who)
  pure val t0_lender_permission_dependent: bool = and {
    mayDisburse("u1", Map("u1" -> true, "u2" -> false)),
    not(mayDisburse("u2", Map("u1" -> true, "u2" -> false))),
  }

  /// THE GRANT is reachable — `u2` holds LENDER_ROLE only because the pool
  /// operator approved it (TrancheVault.sol:192).  Must be [violation].
  val wit_lenderGranted: bool = not(lenders.get("u2"))

  /// THE OPERATOR CAN STRAND A CLAIM.  `removeApprovedLender` carries no balance
  /// check, so a lender still holding shares can lose the role and with it the
  /// ability to `disburse`.  A third Perm instance in huma and a sharper one
  /// than `closePool`: discretion over somebody else's claim.
  val wit_strandedClaim: bool = not(and {
    not(lenders.get("u1")),
    seniorOf.get("u1") + juniorOf.get("u1") > 0,
  })

  /// And THE REVOKE — `u1` starts approved and can end unapproved.
  val wit_lenderRevoked: bool = lenders.get("u1")

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_subordination,
    inv_capWellFormed,
    inv_juniorFirstLoss,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (P2-CONTRACT §D, the fifth trap).
  //  Each of these must be VIOLATED by `quint run --invariant=<name>`.
  // ===========================================================================

  /// T0-LIVE.  `maxRedeemable(700, 200) = 25` as a TRANSITION: the junior
  /// tranche stood at 200 against a senior 700, a lender asked for 100 shares
  /// while the pool held 300 in cash, and exactly 25 came out with 75 shares
  /// left queued.  The last three conjuncts are what make it DISCRIMINATING and
  /// not merely live — see `wit_juniorCapped`, which carries the argument.
  val wit_live_juniorRedeemableCap: bool =
    not(and {
      lastOp == OP_EPOCH,
      seniorAssets == T0_LIVE_SENIOR,
      juniorAssets == T0_LIVE_JUNIOR_AFTER,
      juniorProcessedAmt == T0_LIVE_FILL,
      juniorReq > 0,
      availableCash > 0,
    })

  /// THE REDEMPTION THE CONTRACT BLOCKS AND v1 PERMITS.  P2-SCOPE §5 row 8's
  /// `wit_juniorCapped`: an epoch filled the junior tranche PARTIALLY and the
  /// pool still holds cash, so cash is demonstrably not what stopped it.
  ///
  /// WHY THE `lastOp` CONJUNCT IS LOAD-BEARING, and why the obvious form is
  /// not.  The first draft of this witness read "an epoch has closed, junior
  /// shares are queued, and cash exceeds what they are worth".  MEASURED
  /// against mutants/huma_M1.qnt, that predicate is violated by M1 too: the
  /// deletion is a RELAXATION, so every state M0 can reach M1 can also reach,
  /// by making a smaller request.  For a deleted CONSTRAINT the discriminating
  /// direction is the other one — M1 reaches states M0 cannot, which is
  /// `inv_subordination` — and the only positive witness that separates them
  /// is one pinned to the instant of processing.  Quint 0.32's `--invariant` is
  /// single-state (PILOT-NOTES K6), so that instant is named by the trace
  /// label.  Under M1 a partial junior fill happens only when the cash bound
  /// bites, and the cash bound leaves `availableCash == 0`; under M0 it happens
  /// when the subordination cap bites and the cash is untouched.  That is the
  /// whole separation, and `availableCash > 0` is where it lives.
  /// This is a tag-PLUS-value-signature witness, never tag-only: `lastOp` fixes
  /// the instant and `juniorProcessedAmt`, `juniorReq` and `availableCash`
  /// carry the mechanism.  PILOT-NOTES §5 step 3 permits exactly this shape and
  /// forbids the tag-only one.
  val wit_juniorCapped: bool =
    not(and {
      lastOp == OP_EPOCH,
      juniorProcessedAmt > 0,
      juniorReq > 0,
      availableCash > 0,
    })

  /// `juniorRedeemableCap` ran and BOUND: a strictly positive junior fill left
  /// the junior tranche sitting exactly on the floor the senior balance
  /// implies, with demand still outstanding.
  /// LIVENESS ONLY.  Measured against mutants/huma_M1.qnt this witness is
  /// violated there too — M1 can land junior on the floor by coincidence.  It
  /// discharges the fifth trap and it does not discriminate; `wit_juniorCapped`
  /// and `inv_subordination` are what discriminate.
  val wit_used_juniorRedeemableCap: bool =
    not(and {
      maxRatio > 0,
      juniorProcessedAmt > 0,
      juniorReq > 0,
      juniorAssets == minJuniorAmount(seniorAssets, maxRatio),
    })

  /// `seniorRedemptionFill` ran: the senior tranche was served, and it was
  /// served BEFORE the junior tranche in the same epoch.
  val wit_used_seniorRedemptionFill: bool = seniorProcessedAmt == 0

  /// `lpTokenPrice` was applied at a price other than one: assets and supply
  /// have diverged, which only a profit or a loss can do.
  val wit_used_lpTokenPrice: bool =
    juniorSupply == 0 or juniorAssets == juniorSupply

  /// `seniorProfitShare` ran: the senior tranche gained assets without minting
  /// shares.  v1's flat 4000 bps would also do that, so the discriminating
  /// check is h21 against h24, not this witness — this one only proves the
  /// definition is live.
  val wit_used_seniorProfitShare: bool = seniorAssets <= seniorSupply

  /// `lossToTranches` ran and junior absorbed first.
  val wit_used_lossToTranches: bool = juniorLossTaken == 0

  /// The senior side of the same waterfall: junior was wiped out entirely and
  /// the senior tranche was written down.  6f's other side of `junior >= loss`.
  val wit_branch_seniorLoss: bool = seniorLossTaken == 0

  /// `assetsToShares` ran off the 1:1 diagonal: a deposit minted a share count
  /// different from the assets deposited, which needs a price move first.
  val wit_used_assetsToShares: bool =
    seniorSupply <= INIT_SENIOR_SUPPLY or seniorSupply == seniorAssets

  /// `seniorAvailableCap` bound on the ENTRY: a senior deposit took the tranche
  /// exactly to the ratio bound and no further deposit can be made.
  val wit_used_seniorAvailableCap: bool =
    not(and {
      maxRatio > 0,
      seniorSupply > INIT_SENIOR_SUPPLY,
      seniorAssets == maxRatio * juniorAssets,
    })

  /// EpochManager.sol:350's other side, reached through Pool.closePool (:163):
  /// the ratio is disabled and a junior redemption is processed that the live
  /// ratio would have capped.
  val wit_branch_ratioZero: bool =
    not(and { maxRatio == RATIO_DISABLED, juniorProcessedAmt > 0 })

  /// The `maxRedeemableAmount <= 0` early return at :358: the cap is already
  /// breached and the junior tranche cannot redeem at all.
  val wit_branch_capExhausted: bool =
    not(and { maxRatio > 0, juniorAssets > 0, juniorCapNow == 0 })

  /// THE ARITY HALF OF THE WATERFALL.  `wit_juniorCapped` shows that the junior
  /// fill was bounded by subordination rather than by cash; this shows that ONE
  /// epoch served BOTH tranches, senior first, which is what makes the junior
  /// cap read a senior balance that the same transition had already reduced
  /// (FINDINGS F-2).  A mechanism that serves one tranche per epoch reaches the
  /// same balances over two epochs and is invisible to every value-level check;
  /// it is caught here and nowhere else.  Measured: violated here, and [ok]
  /// under mutants/huma_M6_oneTranche.qnt, where every other obligation in this
  /// file — inv_T0, inv_conservation, inv_subordination, inv_capWellFormed,
  /// wit_juniorCapped and wit_live_juniorRedeemableCap — behaves exactly as it
  /// does on the target.
  /// Justification against the contract, which is what makes this a trace label
  /// rather than an invention: `_processRedemptionRequests` calls
  /// `executeRedemptionSummary` once per tranche it served (:226-229) and then
  /// emits ONE `RedemptionRequestsProcessed` carrying BOTH tranches' post
  /// balances and the unprocessed amount (:231-238).  How many tranches one
  /// epoch touched is therefore observable on chain from a single event.
  val wit_arity_bothTranches: bool = lastEpochTranchesFilled != 2

  /// The other side of the same count: an epoch that served exactly one tranche,
  /// which is the ordinary case when only one has outstanding requests.
  val wit_arity_oneTranche: bool = lastEpochTranchesFilled != 1

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_depositSenior: bool = lastOp != OP_DEP_SENIOR
  val wit_fired_depositJunior: bool = lastOp != OP_DEP_JUNIOR
  val wit_fired_drawdown: bool = lastOp != OP_DRAWDOWN
  val wit_fired_distributeProfit: bool = lastOp != OP_PROFIT
  val wit_fired_distributeLoss: bool = lastOp != OP_LOSS
  val wit_fired_addRedemptionRequestSenior: bool = lastOp != OP_REQ_SENIOR
  val wit_fired_addRedemptionRequestJunior: bool = lastOp != OP_REQ_JUNIOR
  val wit_fired_closeEpoch: bool = lastOp != OP_EPOCH
  val wit_fired_disburse: bool = lastOp != OP_DISBURSE
  val wit_fired_closePool: bool = lastOp != OP_CLOSE
}
