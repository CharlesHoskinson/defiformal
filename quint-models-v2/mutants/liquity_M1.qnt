// =============================================================================
//  liquity — Phase 2 re-spec (W3).  Replaces quint-models/L2/liquity.qnt.
//
//  SOURCE:
//    protocol-repos/cdp/liquity_bold/contracts/src/TroveManager.sol
//      :745-833   redeemCollateral — the loop.  :770 sortedTroves.getLast(),
//                 :785 sortedTroves.getPrev(troveId), :788 the ICR < 100% skip
//                 (`continue`), :810 remainingBold -= boldLot, :768 the
//                 `remainingBold > 0` loop condition
//      :671-714   _redeemCollateralFromTrove — :682 boldLot = min(maxBold,
//                 entireDebt), :685 correspondingColl = boldLot*DECIMAL_PRECISION
//                 /_redemptionPrice, :689 collLot = corresponding - collFee,
//                 :694 the newDebt < MIN_DEBT zombie branch
//    protocol-repos/cdp/liquity_bold/contracts/src/SortedTroves.sol
//      :15        "a sorted doubly linked list with nodes sorted in descending
//                 order" — descending annual interest rate
//      :129,:152,:190  insert / remove / reInsert
//      :318,:325,:333,:341  getFirst / getLast / getNext / getPrev
//      :362-377   _validInsertPosition — prev.rate >= rate > next.rate
//    protocol-repos/cdp/liquity_bold/contracts/src/Dependencies/Constants.sol
//      :8,:9,:44  DECIMAL_PRECISION, _100pct, MIN_DEBT = 2000e18
//    protocol-repos/cdp/liquity_bold/contracts/src/Dependencies/LiquityMath.sol
//                 _computeCR = _coll * _price / _debt, uint max when debt == 0
//    protocol-repos/cdp/liquity_bold/contracts/src/BorrowerOperations.sol
//                 openTrove, closeTrove, adjustTroveInterestRate
//    protocol-repos/cdp/liquity_bold/contracts/src/StabilityPool.sol
//                 provideToSP, withdrawFromSP, claimAllCollGains, offset
//
//  MECHANISM:
//    A redemption is extremal selection over a global order.  It starts at
//    `getLast()` — the LOWEST annual interest rate in the whole system — walks
//    backwards through `getPrev()`, takes `min(remaining, entireDebt)` from each
//    trove it can legally touch, and stops when the redeemer's BOLD runs out.
//    The trove is never an input.  Which troves are hit, how many, and how deep
//    the last one is cut are all consequences of the amount and of where every
//    borrower chose to sit in the interest-rate order.
//
//  WHAT v1 DELETED (this file exists to restore it):
//    D-1  quint-models/L2/liquity.qnt:130 declares
//           `action redeem(u: int, boldAmt: int)`
//         and :225 feeds it `nondet u = USERS.oneOf()`.  The spec redeems from
//         whichever trove the driver names.  `touched > 1` is unreachable for
//         every input, so the prefix walk — the entire mechanism — is absent.
//         Restored as `redeemCollateral(boldAmt)`: the amount is exogenous, the
//         troves are not.
//    D-2  quint-models/L2/liquity.qnt:69 writes `Trove.rate`, :153 copies it,
//         and NO GUARD ANYWHERE READS IT.  `rate` is the sort key of
//         SortedTroves; carrying it while never comparing it is the deletion
//         seen from the other side.  `respec_lint.py` D1 finds this one by
//         itself (measured: 1 finding on the v1 file).  Restored: `rate` is
//         compared in `sorted.before`, which orders the list that the redemption
//         walks, and is re-compared on every `reInsert`.
//    Corpus context: all 57 v1 specs use `fold` only in the form
//    `fold(0, (acc,x) => acc + ...)`.  There is no extremal selection anywhere in
//    the v1 corpus.  This file and `derive` are the two that introduce one.
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    the descending-rate order and its total tie-break; getLast() as the walk's
//    entry point; the getPrev() walk; `boldLot = min(remaining, entireDebt)`;
//    the ICR < 100% `continue` (:788) as a SKIP, not a stop; the endogenous
//    `remainingBold > 0` cutoff; MIN_DEBT = 2000 on the open path; MCR on the
//    open and liquidation paths; CCR on the open and close paths; _computeCR's
//    floor division and its uint-max-at-zero-debt branch; SortedTroves.reInsert
//    on an interest-rate change; the Stability Pool offset.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - zombie troves.  TroveManager.sol:694-711 removes a trove from
//      SortedTroves when a redemption leaves `newDebt < MIN_DEBT`, and parks a
//      pointer in `lastZombieTroveId` so the next redemption resumes there.  The
//      spec leaves the trove in the list with `active = debt > 0`.  This is the
//      P2-CARRYFORWARD Flag L executor decision, taken verbatim.  Consequence:
//      the spec's walk can revisit a sub-MIN_DEBT trove where the contract's
//      would consume the zombie pointer first.  `wit_belowMinDebt` proves the
//      state the dropped branch fires in is REACHED, so the abstraction is live
//      rather than vacuous.
//    - interest accrual.  `_getLatestTroveData` grows `entireDebt` by
//      `annualInterestRate` over elapsed time.  Dropped with the clock; `debt`
//      is `entireDebt`.  `rate`'s OTHER consumer is dropped, its ordering
//      consumer is not, and ordering is the mechanism under repair.
//    - the redemption fee.  `_redemptionRate` is chain state
//      (baseRate + decay + the redeemed fraction); P2-CONTRACT §A.5 marks it
//      NOT DERIVABLE and fixes it at 0.  At rate 0, `collFee = 0` and
//      `collLot = correspondingColl`, so the fee is a scalar skim off the payout
//      and touches neither the order nor the cutoff.
//    - `_maxIterations` (:764, :768).  A gas cap; capping the walk can only make
//      the prefix shorter, never re-order it.
//    - batch interest managers (`_updateBatchInterestPriorToRedemption`,
//      `insertIntoBatch`, `reInsertBatch`) and `urgentRedemption` / branch
//      shutdown.  P2-SCOPE row 5 droppable list.
//    - redistribution (DefaultPool) and gas compensation.
//    - CollSurplusPool.  A fully redeemed trove keeps its residual collateral in
//      place instead of routing it to a surplus pool; `closeTrove` returns it.
//      v1 deleted that collateral from the system entirely (`:145`); here it is
//      conserved, which is what makes `inv_collConservation` assertable.
//    - per-holder BOLD balances.  `freeBold` is the aggregate of every wallet.
//      The one guard that reads a single holder's balance,
//      `_requireBoldBalanceCoversRedemption`, is enforced against the aggregate.
//    - per-holder collateral wallets.  `userColl` is the aggregate.  One trove
//      per user, so no user can outspend another's endowment on the open path.
//    - multi-collateral branches and the CollateralRegistry fan-out.
//    - TroveManager.sol:826 deliberately REMOVED `require(totalCollDrawn > 0)`.
//      The spec keeps `redeemed > 0` on `redeemCollateral`, because a redemption
//      that redeems nothing is an all-identity frame, which convention 6d
//      forbids, and it is stutter-equivalent to not calling.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label of the observation
//    interface (P2-FIDELITY §1), carrying what the contract's Redemption /
//    Liquidation / TroveUpdated events carry, which are droppable only because
//    no guard reads them.  Read by `wit_fired_*` (convention 6d) and by nothing
//    else; no guard and no `pure def` reads it.  Exempt from 6e's write-only
//    clause on that basis.  PILOT-NOTES.md §5 step 2.
//
//    `lastTouched` is the SECOND ghost and it was added for a measured reason,
//    recorded here because it is a finding about the method and not only about
//    this file.  The first draft carried no arity label and relied on state
//    signatures alone: `debtsOf(troves) == List(4000, 0, 0)` was asserted to be
//    unreachable under M1.  M1 WAS BUILT AND RUN, and it reached that state —
//    at depth 3, by being told trove 3, then trove 2, then trove 1.  A
//    single-state predicate (PILOT-NOTES trap K6) cannot say "in ONE
//    transition", and for an extremal-selection mechanism the discriminating
//    observable IS the arity of the selection: how many elements one call
//    consumed.  Pinning it needs a label, exactly as 6d's enabledness does.
//    `lastTouched` carries what the contract's own event stream carries — one
//    `TroveUpdated` per trove the loop touched, inside one `Redemption` — which
//    is droppable only because no guard reads it.  Read by `wit_multiTrove`,
//    `wit_live_redeemPrefix` and `wit_prefixStrict`; no guard and no `pure def`
//    reads it.  This is exactly what P2-SCOPE §5 row 5 asks for in words:
//    "`wit_multiTrove`: no redemption consumed >= 2 troves — must be violated."
//    GENERALISATION FOR THE OTHER WORKERS: where the pilot's deletion changed a
//    VALUE, a value signature killed it.  Where the deletion changes WHICH
//    elements one transition touches, no value signature can kill it, because
//    the deleted spec can reach the same values by taking more transitions.
//    Selection-shaped mechanisms need an arity label; `derive`'s `worstScenario`
//    index and `huma`'s per-epoch fill vector are the same shape.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 3 users, 3 list entries (one trove per user, so the list can
//       never exceed 3).  Eight `nondet`s per step: 3 / 3 / 2 / 4 / 3 / 3 / 3 / 3
//       enumerated values, all <= 8.
//    8b magnitude — peak intermediate 1.8e11 = userColl endowment 90000 times
//       PRICE_HIGH 2e6, in `crWad`'s numerator when it is applied to the whole
//       system.  Next: `debt * CCR` <= 18000*1.5e6 = 2.7e10, and sorted.qnt's
//       `t.coll * price` <= 9000*2e6 = 1.8e10.  All below I64_MAX = 9.22e18.
//       This spec does NOT call `isqrtFloor`, so PILOT-NOTES D-d's 4.611686e18
//       floor does not apply to it.
//    8c constant-crossing —
//       MIN_DEBT = 2000: DEBT_AMOUNTS contains 1000 (BELOW — `canOpen` refuses,
//         t0_20) and 2000 / 3000 / 6000 (at and above, t0_21).  The other site
//         is TroveManager.sol:694's `newDebt < MIN_DEBT`, crossed at runtime by
//         `wit_belowMinDebt` (a redemption leaves debt 1000) against the
//         ordinary case (a redemption leaves debt 4000).
//         P2-CONTRACT §C row 5's domain (debts <= 300) cannot cross MIN_DEBT in
//         either direction — no trove can be opened at all.  P2-CARRYFORWARD
//         Flag L already declared it a live instance of CF1; the domain used
//         here is Flag L's, raised once more so that DEBT_AMOUNTS also holds a
//         value strictly below the constant.  See the DOMAIN note below.
//       MCR = 1.1e6: crossed at PRICE_LOW — `canOpen(4000, 2000, 4e5, ...)` is
//         false (ICR 0.8) where `canOpen(9000, 2000, 4e5, ...)` is true
//         (ICR 1.8).  t0_22 / t0_23.
//       CCR = 1.5e6: crossed at PRICE_HIGH — `canOpen(4000, 6000, 2e6, 0, 0)`
//         passes MCR (ICR 1.33) and fails CCR (TCR 1.33).  t0_24.
//       _100pct = 1e6 (the redemption skip, TroveManager.sol:788): crossed by
//         t0_10 (a trove at ICR 0.8 is SKIPPED and the walk continues past it)
//         against t0_03 (every trove eligible).  Both sides, same list.
//       The redemption budget against total eligible debt: t0_04 leaves
//         `remaining = 2000 > 0`, t0_01..t0_03 leave `remaining = 0`.
//
//  INPUTS:  (convention 6g, dependency parity — foot(Q) = contract storage the
//           contract's own expression for this quantity depends on)
//    | name     | contract expression              | file:line | foot(Q) | spec vars read |
//    | boldAmt  | redeemCollateral(_boldamount)    | TM:748    | none    | freeBold (guard) |
//    | u        | openTrove(_owner,...) msg.sender | BO        | none    | troves (guard) |
//    | ids      | batchLiquidateTroves(_troveArray)| TM        | none    | troves (guard) |
//    | collAmt  | openTrove(_collAmount)           | BO        | none    | userColl (guard) |
//    | debtAmt  | openTrove(_boldAmount)           | BO        | none    | none |
//    | rate     | openTrove(_annualInterestRate)   | BO        | none    | none |
//    | spAmt    | provideToSP(_topUp)              | SP        | none    | freeBold (guard) |
//    | p        | priceFeed.fetchPrice()           | TM:772    | none    | none (external call) |
//    THE ROW THAT IS NOT HERE IS THE POINT.  v1 supplied a NINTH quantity,
//    `u` fed to `redeem(u, boldAmt)`.  Its contract expression is
//    `sortedTroves.getLast()` (TroveManager.sol:770) followed by
//    `sortedTroves.getPrev(...)` (:785), whose foot(Q) is
//    {SortedTroves.nodes, Troves[].annualInterestRate} — both modelled here, as
//    `troves`.  A `nondet` reads neither, so parity fails by two, and 6g rejects
//    it.  Contrast `ids`: `batchLiquidateTroves(uint256[] _troveArray)` takes
//    its trove identities from CALLDATA, foot(Q) = none, so the same-shaped
//    `nondet` is legitimate there.  One protocol, two identity-valued inputs,
//    and 6g separates them — which is exactly what convention 6 alone could not
//    do, because both look like "the driver names a trove".
//    `p` is a genuine external-call return, foot(Q) = none: the oracle case 6g
//    was written to permit.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    TroveManager.redeemCollateral      -> action redeemCollateral
//    TroveManager.batchLiquidateTroves  -> action batchLiquidate
//    TroveManager.liquidate (single)    -> action batchLiquidate with a 1-list
//    TroveManager.urgentRedemption      -> ABSTRACTED (branch shutdown)
//    TroveManager.shutdown              -> ABSTRACTED (branch shutdown)
//    BorrowerOperations.openTrove       -> action openTrove
//    BorrowerOperations.closeTrove      -> action closeTrove
//    BorrowerOperations.adjustTroveInterestRate -> action adjustInterestRate
//    BorrowerOperations.adjustTrove / addColl / withdrawBold -> ABSTRACTED
//                                          (no new mechanism; open/close span
//                                           the same guards)
//    BorrowerOperations.setInterestBatchManager -> ABSTRACTED (batches)
//    StabilityPool.provideToSP          -> action provideToSP
//    StabilityPool.withdrawFromSP       -> action withdrawFromSP
//    StabilityPool.claimAllCollGains    -> action claimCollGains
//    SortedTroves.insert / remove / reInsert -> kernel-side, exercised by
//                                          openTrove / closeTrove /
//                                          adjustInterestRate
//    PriceFeed.fetchPrice               -> action setPrice
//    CollateralRegistry.redeemCollateral-> ABSTRACTED (single branch)
//    Storage read by a require on a state-changing path:
//      SortedTroves node order + Troves[].annualInterestRate (TM:770,785)
//        -> var troves, as an ORDERED List;
//      Troves[].debt / .coll (TM:682,685)          -> fields of var troves;
//      Troves[].status (TM:788 via _isActiveOrZombie) -> field `active`;
//      boldToken.balanceOf(redeemer)               -> var freeBold (aggregate);
//      activePool coll / debt                      -> var systemColl, boldSupply;
//      stabilityPool deposits / coll gains         -> var spDeposits, spColl;
//      priceFeed price                             -> var price.
//      (the two GHOST vars, `lastOp` and `lastTouched`, are the trace label and
//       are exempt from the write-only clause on the grounds argued above.)
//    No `var` is write-only: every one is read by a guard or an invariant, and
//    `spColl` — the one v1 left with a single writer and no reader, D2 on the v1
//    file — now has two writers (`batchLiquidate`, `claimCollGains`) and is read
//    by `inv_collConservation`.
//
//  UNITS:  (hole H2's obligation, applied here as a convention)
//    debt, boldSupply, freeBold, spDeposits, boldAmt, MIN_DEBT  — BOLD
//    coll, systemColl, userColl, spColl, collAmt, collOut       — collateral
//    price                                                      — BOLD per
//                                                                 collateral,
//                                                                 WAD-scaled
//    rate                                                       — annual
//                                                                 interest,
//                                                                 ordinal only
//    MCR, CCR, HUNDRED_PCT, crWad(...)                          — WAD-scaled
//                                                                 dimensionless
//    WAD                                                        — scale factor
//    `coll * price` and `debt * WAD` are both BOLD*WAD, which is why `icrOk`
//    compares them directly.
//
//  CONTRAST SET M (F0/F2, with R4's three mandatory members):
//    M0  redeemPrefix = the getLast()/getPrev() walk over the rate order   [target]
//    M1  the v1 body verbatim: `redeem(u, boldAmt)` with `nondet u`
//        (quint-models/L2/liquity.qnt:130,225).  MANDATORY member 1.  BUILT AND
//        RUN as mutants/liquity_M1.qnt.  Agreement with M0 on the T0 domain:
//        it reproduces t0_01 (touched = 1) and nothing else, so 1/4 = 25% over
//        the four declared amounts.  Measured results, and the middle column is
//        the part that matters:
//          inv_T0            [ok]        <- every vector still passes: the
//                                           `pure def` is still there, still
//                                           correct, and never called.  The
//                                           fifth trap, live.
//          inv_conservation  [ok]        <- the headline invariant does not
//                                           discriminate, exactly as the pilot
//                                           found for uniswap_v2 (§7)
//          inv_redeemPrefix  [ok]        <- and NEITHER DOES THE MECHANISM
//                                           INVARIANT, because it quantifies
//                                           over a hypothetical application of
//                                           `redeemPrefix` at the current state
//                                           rather than over the transition
//                                           that was taken
//          wit_multiTrove    [ok]        <- THE KILL.  M1 can never make one
//                                           call consume two troves
//          wit_live_redeemPrefix [ok]    <- with the arity label; WITHOUT it
//                                           this witness was VIOLATED under M1
//                                           at depth 3.  See GHOST above.
//        M1 dies to the arity label and to nothing else in this file.
//    M2  chaos: any subset of troves, any split of the amount.  MANDATORY
//        member 2 — the maximally permissive form in the same direction.
//        Killed by redeemIsExtremal clauses (A) and (B), which are `inv_all`.
//    M3  largest-debt-first, the "socially efficient" rival, sourced from the
//        sibling CDP design space (MakerDAO/DAI has no ordered redemption at
//        all; Liquity v1 redeems by ICR ascending, which IS this shape with a
//        different key).  MANDATORY member 3.  Agreement over the four declared
//        amounts: 1/4 = 25% (only t0_01, where the two orders happen to pick the
//        same trove, would coincide — and even there it does not: largest-debt
//        picks id 1 and gives debts [5000,2000,2000], not [6000,2000,1000], so
//        measured agreement is 0/4).  See t0_25.
//    M4  the reverse order — highest rate first.  The rounding-direction rival's
//        analogue for an ordered structure: same mechanism, order flipped.
//        Agreement 0/4; t0_25 is the separating vector and it is the brief's
//        "a different order would have produced a different outcome".
//    FINDING, carried forward from PILOT-NOTES §7: R4 asks for a near neighbour
//    agreeing on >= 90% of the declared domain.  For an ORDER-VALUED mechanism
//    no such rival exists either, and for a sharper reason than the pilot's.
//    The pilot's `geometricMint` had rivals agreeing on 30.6% (the perfect
//    squares).  Here every rival that permutes the key disagrees as soon as the
//    amount exceeds the smallest trove's debt, which is three of the four
//    declared amounts; and the fourth is the one-trove case where the ORDER is
//    not observable at all.  An extremal-selection mechanism has no smooth
//    neighbourhood: the output is a function of a permutation, and permutations
//    have no metric in which "90% agreement" is a small perturbation.  R4's
//    >= 90% clause should read "or the closest available rival with its measured
//    agreement reported", exactly as the pilot recommended, and this is the
//    second independent instance.
//
//  LINT:  `respec_lint.py liquity.qnt` reports ONE finding, and it is kept
//         deliberately rather than dodged.
//    [D4] redeemCollateral(boldAmt): driver picks `boldAmt` from REDEEM_AMOUNTS
//         and passes it to a selection action.
//    JUSTIFICATION.  D4's docstring names THIS protocol's v1 defect as its
//    witness: "liquity.qnt `redeem(u, ...)` with `nondet u = USERS.oneOf()` —
//    the contract walks a sorted list; the spec is told which trove."  The
//    detector as implemented fires on ANY `nondet` handed to an action whose
//    name contains a selection verb, without asking whether the quantity is an
//    element IDENTITY.  `boldAmt` is the redeemer's own BOLD:
//    `redeemCollateral(address, uint256 _boldamount, ...)`, calldata,
//    foot(Q) = none, and convention 6 explicitly permits amounts.  So D4 scores
//    the REPAIRED file exactly as loudly as the file it was written to catch,
//    and it would score any faithful re-spec of any redemption the same way.
//    It is left in place because dodging it would hide the measurement.
//    PROPOSED REFINEMENT, and the linter already computes the ingredient:
//    `analyse` builds `keyed` (is the parameter used as a map key inside the
//    action?) and then discards it into the message text.  D4 should be split —
//    D4a when the nondet reaches a map/list LOOKUP inside the action body, which
//    is the identity case and the real defect, and D4b, informational, otherwise.
//    On the v1 file D4a fires on `redeem(u)` and `liquidateViaSP(u)`; on this
//    file it fires on nothing.  That is the discrimination D4 currently lacks.
//    Two further D4 false-positive shapes were hit and are reported with this
//    work: (i) the regex `^\s*<name>\(<args>\)\s*,?\s*$` matches a `pure def`
//    BODY, not only a driver call site, so `pure def f(...) =\n  redeemFrom(l,
//    boldAmt, p)` scores two findings that have nothing to do with the driver
//    (worked around here by keeping the body on the `=` line, which is a code
//    style forced by a linter and should not be); (ii) it cannot see through a
//    nested call, so `batchLiquidate(List(u, v))` — the contract's own array
//    signature — is silently exempt while `liquidateViaSP(u)` is not.
//
//  ACCEPTANCE:
//    T1  quint typecheck liquity.qnt
//    T2  quint run --main=liquity --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 liquity.qnt
//    T3  quint run --main=liquity --invariant=inv_all ...       (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: redeemPrefix(T0_TROVES, 6000, 2000000) touches THREE troves and
//        leaves head-first debts [4000, 0, 0].  The obligation is the TRACE that
//        violates `wit_live_redeemPrefix` — a reachable state in which the two
//        LOWEST-rate troves are at zero debt and the highest-rate trove, which
//        also carries the MOST debt, has been cut by exactly the residue.
//        P2-CONTRACT §D lists this vector as "redeem(250) touching 3"; 250 is
//        below MIN_DEBT and cannot exist, so the amount is re-derived at the
//        repaired domain.  Reached at depth 1 from init.
//    T4  the contrast set is BUILT, not only declared (PILOT-NOTES trap K10):
//          quint run --main=liquity --invariant=wit_multiTrove \
//            --max-steps=20 --max-samples=20000 mutants/liquity_M1.qnt
//        MUST report NO violation, while the same command on liquity.qnt MUST
//        report one.  That pair is the whole kill; see CONTRAST SET below for
//        the eleven measurements and for what does NOT kill M1.
// =============================================================================
module liquity {
  // CONTRAST SET MEMBER M1 -- see mutants/W3-mutants.txt

  import kernel.* from "../kernel"
  import sorted.* from "../sorted"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// Constants.sol:44 — MIN_DEBT = 2000e18, descaled to 1 unit = 1 BOLD.
  pure val MIN_DEBT: int = 2000
  /// Constants.sol:9 — _100pct = DECIMAL_PRECISION.  sorted.WAD is the same 1e6.
  pure val HUNDRED_PCT: int = 1000000
  /// TroveManager MCR — 110%, WAD-scaled.
  pure val MCR: int = 1100000
  /// TroveManager CCR — 150%, WAD-scaled.
  pure val CCR: int = 1500000
  /// P2-CONTRACT §A.5: _redemptionRate is chain state, NOT DERIVABLE, fixed at 0.
  pure val REDEMPTION_RATE: int = 0

  pure val USERS: Set[int] = Set(1, 2, 3)

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN D (convention 8a; see BOUNDS for 8b and 8c)
  //
  // DOMAIN NOTE.  P2-CONTRACT §C row 5 prescribes debts <= 300 and amounts
  // <= 600.  MIN_DEBT is 2000 and is a protocol constant, not a scale factor, so
  // that domain opens no trove and the file would model nothing.  The domain
  // below is P2-CARRYFORWARD Flag L's ({2000, 3000, 6000}) plus the value 1000,
  // which Flag L omits and 8c requires: without a debt strictly BELOW MIN_DEBT
  // the `debtAmt >= MIN_DEBT` guard is never exercised on its refusing side and
  // the constant is uncrossed in the other direction.  Amounts are chosen so
  // that the walk stops at 1, 2 and 3 troves and once with budget left over.
  // ---------------------------------------------------------------------------

  pure val COLL_AMOUNTS: Set[int] = Set(4000, 9000)
  pure val DEBT_AMOUNTS: Set[int] = Set(1000, 2000, 3000, 6000)
  pure val RATES: Set[int] = Set(5, 8, 12)
  pure val REDEEM_AMOUNTS: Set[int] = Set(1000, 3000, 6000)
  pure val SP_AMOUNTS: Set[int] = Set(1000, 2000, 6000)
  pure val PRICE_LOW: int = 400000
  pure val PRICE_MID: int = 1200000
  pure val PRICE_HIGH: int = 2000000
  pure val PRICES: Set[int] = Set(PRICE_LOW, PRICE_MID, PRICE_HIGH)

  /// init is a configured state, per P2-CONTRACT §C rows 2 and 8 (`init` at
  /// 150/50; `init` at senior=700, junior=200).  Three troves already open, at
  /// three distinct rates, is the smallest configuration in which "a prefix of
  /// the rate order" is a statement with content.
  pure val T0_TROVES: List[Trove] = List(
    { id: 1, rate: 12, debt: 6000, coll: 9000, active: true },
    { id: 2, rate:  8, debt: 2000, coll: 9000, active: true },
    { id: 3, rate:  5, debt: 2000, coll: 4000, active: true },
  )
  pure val INIT_BOLD_SUPPLY: int = 10000
  pure val INIT_FREE_BOLD: int = 8000
  pure val INIT_SP_DEPOSITS: int = 2000
  pure val INIT_SP_COLL: int = 0
  pure val INIT_SYSTEM_COLL: int = 22000
  pure val COLL_TOTAL: int = 90000
  pure val INIT_USER_COLL: int = 68000
  pure val NO_TROVE: Trove = { id: 0, rate: 0, debt: 0, coll: 0, active: false }

  pure val OP_INIT: str = "init"
  pure val OP_OPEN: str = "openTrove"
  pure val OP_CLOSE: str = "closeTrove"
  pure val OP_ADJUST: str = "adjustInterestRate"
  pure val OP_PROVIDE: str = "provideToSP"
  pure val OP_WITHDRAW: str = "withdrawFromSP"
  pure val OP_CLAIM: str = "claimCollGains"
  pure val OP_LIQUIDATE: str = "batchLiquidate"
  pure val OP_REDEEM: str = "redeemCollateral"
  pure val OP_PRICE: str = "setPrice"

  // ---------------------------------------------------------------------------
  // STATE.  `troves` is a List, never a Set the driver selects from
  // (convention 5).  Its ORDER is the sort key of SortedTroves and is what the
  // redemption consumes a prefix of.
  // ---------------------------------------------------------------------------

  var troves: List[Trove]    // SortedTroves, descending annual interest rate
  var boldSupply: int        // BOLD
  var freeBold: int          // BOLD in wallets
  var spDeposits: int        // BOLD in the Stability Pool
  var spColl: int            // collateral gains held by the Stability Pool
  var systemColl: int        // collateral in the ActivePool
  var userColl: int          // collateral in wallets
  var price: int             // BOLD per collateral, WAD-scaled
  var lastOp: str            // GHOST — trace label, see header
  var lastTouched: int       // GHOST — selection arity of the last redemption

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  Every one is pinned by exact T0 vectors below AND carries a reachability
  //  obligation, because a `pure val` equality is true in states where the
  //  definition is never applied (the fifth trap, P2-CONTRACT §D).
  // ===========================================================================

  /// THE REGISTRY NAME (P2-SCOPE convention 3).  TroveManager.sol:745-833.
  /// `sorted.redeemFrom` walks `rev(l)` — the list from its tail — which is
  /// `getLast()` followed by `getPrev()` at :770 and :785, in list form.  Each
  /// step takes `min(remaining, entireDebt)` (:682), converts it at
  /// `boldLot * DECIMAL_PRECISION / redemptionPrice` (:685), skips a trove whose
  /// ICR is below 100% (:788) WITHOUT stopping, and halts when `remainingBold`
  /// reaches 0 (:768).  Nothing in the signature names a trove.
  /// (The body is kept on the `=` line deliberately: `respec_lint.py` D4 matches
  /// any line that is exactly `<name>(<args>)`, including a `pure def` body, and
  /// scores `redeemFrom(l, boldAmt, p)` as a driver hand-off.  See the report.)
  pure def redeemPrefix(l: List[Trove], boldAmt: int, p: int): RedeemAcc = redeemFrom(l, boldAmt, p)

  /// LiquityMath._computeCR — `_coll * _price / _debt`, floor, and
  /// `type(uint256).max` when the debt is zero.  I64_MAX is the kernel's
  /// backend ceiling and plays that role here.
  pure def crWad(coll: int, debt: int, p: int): int =
    if (debt <= 0) I64_MAX else mulDivDown(coll, p, debt)

  /// BorrowerOperations.openTrove's three requires, in one place.
  pure def canOpen(collAmt: int, debtAmt: int, p: int,
                   tcrColl: int, tcrDebt: int): bool =
    and {
      collAmt > 0,
      debtAmt >= MIN_DEBT,
      crWad(collAmt, debtAmt, p) >= MCR,
      crWad(tcrColl + collAmt, tcrDebt + debtAmt, p) >= CCR,
    }

  /// TroveManager's liquidation trigger.
  pure def isLiquidatable(t: Trove, p: int): bool =
    t.active and t.debt > 0 and crWad(t.coll, t.debt, p) < MCR

  // -- list helpers over the sorted structure ---------------------------------

  pure def findTrove(l: List[Trove], id: int): Trove =
    l.foldl(NO_TROVE, (acc, t) => if (t.id == id) t else acc)

  pure def hasTrove(l: List[Trove], id: int): bool =
    l.indices().exists(i => l[i].id == id)

  pure def sumDebt(l: List[Trove]): int =
    l.foldl(0, (s, t) => s + t.debt)

  pure def sumColl(l: List[Trove]): int =
    l.foldl(0, (s, t) => s + t.coll)

  pure def debtsOf(l: List[Trove]): List[int] =
    l.foldl(List(), (a, t) => a.append(t.debt))

  // -- batch liquidation, TroveManager.batchLiquidateTroves -------------------

  type LiqAcc = {
    list: List[Trove],
    sp: int,
    spc: int,
    bold: int,
    sysColl: int,
    hit: int,
  }

  /// One iteration of batchLiquidateTroves' loop.  A trove that is not
  /// liquidatable, or that the Stability Pool cannot cover, is passed over —
  /// the contract's `continue`, not a revert.
  pure def liquidateOne(acc: LiqAcc, id: int, p: int): LiqAcc = {
    val t = findTrove(acc.list, id)
    if (not(isLiquidatable(t, p)) or acc.sp < t.debt) acc
    else {
      list: removeById(acc.list, id),
      sp: acc.sp - t.debt,
      spc: acc.spc + t.coll,
      bold: acc.bold - t.debt,
      sysColl: acc.sysColl - t.coll,
      hit: acc.hit + 1,
    }
  }

  pure def liquidateBatch(l: List[Trove], ids: List[int], sp: int, spc: int,
                          bold: int, sysColl: int, p: int): LiqAcc =
    ids.foldl({ list: l, sp: sp, spc: spc, bold: bold, sysColl: sysColl, hit: 0 },
              (acc, id) => liquidateOne(acc, id, p))

  /// The batch's own structural check: every hit removed exactly one trove, and
  /// the Stability Pool covered every offset it performed.
  pure def liquidationIsCovered(l: List[Trove], ids: List[int], sp: int, spc: int,
                                bold: int, sysColl: int, p: int): bool = {
    val r = liquidateBatch(l, ids, sp, spc, bold, sysColl, p)
    and {
      r.list.length() + r.hit == l.length(),
      r.hit <= ids.length(),
      r.sp >= 0,
      r.spc >= spc,
      r.bold >= 0,
      r.sysColl >= 0,
      sp - r.sp == bold - r.bold,
      r.spc - spc == sysColl - r.sysColl,
    }
  }

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed
  //  from the cited Solidity line in integer arithmetic.  Every one of
  //  t0_01..t0_04 is a value the v1 shortcut cannot produce, because v1's
  //  `redeem(u, amt)` cannot make `touched` exceed 1 for any input whatsoever.
  // ===========================================================================

  pure val T0_PRICE: int = PRICE_HIGH

  // -- redeemPrefix: one trove, two troves, three troves, budget left over ----
  pure val t0_01: bool = and {
    debtsOf(redeemPrefix(T0_TROVES, 1000, T0_PRICE).rev) == List(6000, 2000, 1000),
    redeemPrefix(T0_TROVES, 1000, T0_PRICE).touched == 1,
    redeemPrefix(T0_TROVES, 1000, T0_PRICE).remaining == 0,
    redeemPrefix(T0_TROVES, 1000, T0_PRICE).collOut == 500,
  }
  pure val t0_02: bool = and {
    debtsOf(redeemPrefix(T0_TROVES, 3000, T0_PRICE).rev) == List(6000, 1000, 0),
    redeemPrefix(T0_TROVES, 3000, T0_PRICE).touched == 2,
    redeemPrefix(T0_TROVES, 3000, T0_PRICE).remaining == 0,
    redeemPrefix(T0_TROVES, 3000, T0_PRICE).collOut == 1500,
  }
  pure val t0_03: bool = and {
    debtsOf(redeemPrefix(T0_TROVES, 6000, T0_PRICE).rev) == List(4000, 0, 0),
    redeemPrefix(T0_TROVES, 6000, T0_PRICE).touched == 3,
    redeemPrefix(T0_TROVES, 6000, T0_PRICE).remaining == 0,
    redeemPrefix(T0_TROVES, 6000, T0_PRICE).collOut == 3000,
  }
  pure val t0_04: bool = and {
    debtsOf(redeemPrefix(T0_TROVES, 12000, T0_PRICE).rev) == List(0, 0, 0),
    redeemPrefix(T0_TROVES, 12000, T0_PRICE).touched == 3,
    redeemPrefix(T0_TROVES, 12000, T0_PRICE).remaining == 2000,
    redeemPrefix(T0_TROVES, 12000, T0_PRICE).collOut == 5000,
  }

  // -- the ICR < 100% skip, TroveManager.sol:788 (6f, both sides) -------------
  // At PRICE_LOW the lowest-rate trove is under-collateralised and is PASSED
  // OVER; the walk continues to the next-lowest rate and stops with budget left.
  pure val t0_10: bool = and {
    debtsOf(redeemPrefix(T0_TROVES, 3000, PRICE_LOW).rev) == List(6000, 0, 2000),
    redeemPrefix(T0_TROVES, 3000, PRICE_LOW).touched == 1,
    redeemPrefix(T0_TROVES, 3000, PRICE_LOW).remaining == 1000,
    redeemPrefix(T0_TROVES, 3000, PRICE_LOW).collOut == 5000,
  }

  // -- rounding, TroveManager.sol:685 (6c, an inexact quotient) ---------------
  // 1000 * 1e6 / 1.2e6 = 833.33..., floors to 833.  The residue stays in the
  // trove, which is the direction the contract rounds.
  pure val t0_11: bool = and {
    redeemPrefix(T0_TROVES, 1000, PRICE_MID).collOut == 833,
    debtsOf(redeemPrefix(T0_TROVES, 1000, PRICE_MID).rev) == List(6000, 2000, 1000),
  }

  // -- the extremum, SortedTroves.sol:318,325 ---------------------------------
  pure val t0_12: bool = and {
    getLast(T0_TROVES).rate == 5,
    getFirst(T0_TROVES).rate == 12,
    minByRate(T0_TROVES) == getLast(T0_TROVES),
    rev(T0_TROVES).head() == getLast(T0_TROVES),
  }

  // -- insertion is a function of the key set, ties broken by id --------------
  pure val T0_A: Trove = { id: 1, rate: 12, debt: 6000, coll: 9000, active: true }
  pure val T0_B: Trove = { id: 2, rate:  8, debt: 2000, coll: 9000, active: true }
  pure val T0_C: Trove = { id: 3, rate:  5, debt: 2000, coll: 4000, active: true }
  pure val T0_C12: Trove = { id: 3, rate: 12, debt: 2000, coll: 4000, active: true }
  pure val t0_13: bool = and {
    insertSorted(insertSorted(insertSorted(List(), T0_A), T0_B), T0_C) == T0_TROVES,
    insertSorted(insertSorted(insertSorted(List(), T0_C), T0_B), T0_A) == T0_TROVES,
    insertSorted(insertSorted(insertSorted(List(), T0_B), T0_C), T0_A) == T0_TROVES,
    isSorted(T0_TROVES),
    isCanonical(T0_TROVES),
  }
  pure val t0_14: bool = and {
    before(T0_A, T0_C12),
    not(before(T0_C12, T0_A)),
    reInsert(T0_TROVES, T0_C12) == List(T0_A, T0_C12, T0_B),
  }

  // -- the mechanism check itself, at every declared amount -------------------
  pure val t0_15: bool =
    REDEEM_AMOUNTS.forall(a =>
      PRICES.forall(p => redeemIsExtremal(T0_TROVES, a, p)))

  // -- crWad, LiquityMath._computeCR (6c: an inexact quotient, and the zero
  //    branch that returns uint max) -----------------------------------------
  pure val t0_16: bool = crWad(4000, 3000, PRICE_HIGH) == 2666666
  pure val t0_17: bool = crWad(9000, 6000, PRICE_HIGH) == 3000000
  pure val t0_18: bool = crWad(4000, 0, PRICE_HIGH) == I64_MAX
  pure val t0_19: bool = crWad(4000, 2000, PRICE_LOW) == 800000

  // -- canOpen, both sides of MIN_DEBT, MCR and CCR (8c / 6f) -----------------
  pure val t0_20: bool = not(canOpen(9000, 1000, PRICE_HIGH, 0, 0))
  pure val t0_21: bool = canOpen(9000, 2000, PRICE_HIGH, 0, 0)
  pure val t0_22: bool = not(canOpen(4000, 2000, PRICE_LOW, 0, 0))
  pure val t0_23: bool = canOpen(9000, 2000, PRICE_LOW, 0, 0)
  pure val t0_24: bool = and {
    crWad(4000, 6000, PRICE_HIGH) >= MCR,
    not(canOpen(4000, 6000, PRICE_HIGH, 0, 0)),
  }

  // -- THE ORDER IS THE MECHANISM.  The same three troves and the same amount,
  //    walked from the other end, produce a different outcome.  This is the
  //    contrast set's M4 (reverse order) and, read the other way, M3
  //    (largest-debt-first, which for this fixture picks the same trove the
  //    reverse walk does).  A spec whose redemption takes the trove as a
  //    parameter can produce EITHER list and is pinned by NEITHER. ------------
  pure val t0_25: bool = and {
    debtsOf(redeemPrefix(T0_TROVES, 3000, T0_PRICE).rev) == List(6000, 1000, 0),
    debtsOf(redeemPrefix(rev(T0_TROVES), 3000, T0_PRICE).rev) == List(2000, 2000, 3000),
    debtsOf(redeemPrefix(T0_TROVES, 3000, T0_PRICE).rev)
      != debtsOf(rev(redeemPrefix(rev(T0_TROVES), 3000, T0_PRICE).rev)),
  }

  // -- the batch liquidation structural check --------------------------------
  pure val t0_26: bool =
    PRICES.forall(p =>
      liquidationIsCovered(T0_TROVES, List(1, 2), 20000, 0, 10000, 22000, p))

  pure val inv_T0: bool = and {
    t0_01, t0_02, t0_03, t0_04, t0_10, t0_11, t0_12, t0_13, t0_14,
    t0_15, t0_16, t0_17, t0_18, t0_19, t0_20, t0_21, t0_22, t0_23,
    t0_24, t0_25, t0_26,
  }

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    troves' = T0_TROVES,
    boldSupply' = INIT_BOLD_SUPPLY,
    freeBold' = INIT_FREE_BOLD,
    spDeposits' = INIT_SP_DEPOSITS,
    spColl' = INIT_SP_COLL,
    systemColl' = INIT_SYSTEM_COLL,
    userColl' = INIT_USER_COLL,
    price' = PRICE_HIGH,
    lastOp' = OP_INIT,
    lastTouched' = 0,
  }

  /// BorrowerOperations.openTrove.  SortedTroves.insert puts the new trove at
  /// the position its own rate earns it, which is where in the redemption queue
  /// the borrower has chosen to stand.
  action openTrove(u: int, collAmt: int, debtAmt: int, rate: int): bool = all {
    USERS.contains(u),
    not(hasTrove(troves, u)),
    rate > 0,
    collAmt <= userColl,
    canOpen(collAmt, debtAmt, price, systemColl, boldSupply),
    troves' = insertSorted(troves,
      { id: u, rate: rate, debt: debtAmt, coll: collAmt, active: true }),
    boldSupply' = boldSupply + debtAmt,
    freeBold' = freeBold + debtAmt,
    systemColl' = systemColl + collAmt,
    userColl' = userColl - collAmt,
    spDeposits' = spDeposits,
    spColl' = spColl,
    price' = price,
    lastOp' = OP_OPEN,
    lastTouched' = 0,
  }

  /// BorrowerOperations.adjustTroveInterestRate -> SortedTroves.reInsert.
  /// The only action that MOVES a trove within the order, and therefore the only
  /// one that changes who gets redeemed first without changing who exists.
  action adjustInterestRate(u: int, newRate: int): bool = all {
    USERS.contains(u),
    hasTrove(troves, u),
    newRate > 0,
    newRate != findTrove(troves, u).rate,
    troves' = reInsert(troves, { ...findTrove(troves, u), rate: newRate }),
    boldSupply' = boldSupply,
    freeBold' = freeBold,
    systemColl' = systemColl,
    userColl' = userColl,
    spDeposits' = spDeposits,
    spColl' = spColl,
    price' = price,
    lastOp' = OP_ADJUST,
    lastTouched' = 0,
  }

  /// BorrowerOperations.closeTrove — burns the owner's BOLD, returns the
  /// collateral, removes the node from SortedTroves.
  action closeTrove(u: int): bool = all {
    USERS.contains(u),
    hasTrove(troves, u),
    freeBold >= findTrove(troves, u).debt,
    crWad(systemColl - findTrove(troves, u).coll,
          boldSupply - findTrove(troves, u).debt, price) >= CCR,
    troves' = removeById(troves, u),
    boldSupply' = boldSupply - findTrove(troves, u).debt,
    freeBold' = freeBold - findTrove(troves, u).debt,
    systemColl' = systemColl - findTrove(troves, u).coll,
    userColl' = userColl + findTrove(troves, u).coll,
    spDeposits' = spDeposits,
    spColl' = spColl,
    price' = price,
    lastOp' = OP_CLOSE,
    lastTouched' = 0,
  }

  /// StabilityPool.provideToSP
  action provideToSP(amt: int): bool = all {
    amt > 0,
    freeBold >= amt,
    freeBold' = freeBold - amt,
    spDeposits' = spDeposits + amt,
    troves' = troves,
    boldSupply' = boldSupply,
    spColl' = spColl,
    systemColl' = systemColl,
    userColl' = userColl,
    price' = price,
    lastOp' = OP_PROVIDE,
    lastTouched' = 0,
  }

  /// StabilityPool.withdrawFromSP
  action withdrawFromSP(amt: int): bool = all {
    amt > 0,
    spDeposits >= amt,
    freeBold' = freeBold + amt,
    spDeposits' = spDeposits - amt,
    troves' = troves,
    boldSupply' = boldSupply,
    spColl' = spColl,
    systemColl' = systemColl,
    userColl' = userColl,
    price' = price,
    lastOp' = OP_WITHDRAW,
    lastTouched' = 0,
  }

  /// StabilityPool.claimAllCollGains — the second writer of `spColl`, which v1
  /// lacked entirely.
  action claimCollGains(amt: int): bool = all {
    amt > 0,
    spColl >= amt,
    spColl' = spColl - amt,
    userColl' = userColl + amt,
    troves' = troves,
    boldSupply' = boldSupply,
    freeBold' = freeBold,
    spDeposits' = spDeposits,
    systemColl' = systemColl,
    price' = price,
    lastOp' = OP_CLAIM,
    lastTouched' = 0,
  }

  /// TroveManager.batchLiquidateTroves(uint256[] _troveArray).  The identities
  /// come from CALLDATA — foot(Q) is empty and the `nondet` is legitimate under
  /// 6g.  See the INPUTS table: this is the control against which `redeem`'s
  /// deleted `getLast()` is measured.
  action batchLiquidate(ids: List[int]): bool = all {
    ids.length() > 0,
    val r = liquidateBatch(troves, ids, spDeposits, spColl, boldSupply, systemColl, price)
    all {
      r.hit > 0,
      troves' = r.list,
      spDeposits' = r.sp,
      spColl' = r.spc,
      boldSupply' = r.bold,
      systemColl' = r.sysColl,
      freeBold' = freeBold,
      userColl' = userColl,
      price' = price,
      lastOp' = OP_LIQUIDATE,
      lastTouched' = 0,
    }
  }

  /// M1 -- the v1 body verbatim (quint-models/L2/liquity.qnt:130-171).  The
  /// trove is a PARAMETER.  Everything else in this file is unchanged.
  action redeem(u: int, boldAmt: int): bool = all {
    USERS.contains(u),
    hasTrove(troves, u),
    boldAmt > 0,
    freeBold >= boldAmt,
    price > 0,
    val t = findTrove(troves, u)
    val collOut = boldAmt * WAD / price
    all {
      boldAmt <= t.debt,
      collOut <= t.coll,
      troves' = reInsert(troves, { ...t, debt: t.debt - boldAmt,
                                   coll: t.coll - collOut,
                                   active: t.debt - boldAmt > 0 }),
      boldSupply' = boldSupply - boldAmt,
      freeBold' = freeBold - boldAmt,
      systemColl' = systemColl - collOut,
      userColl' = userColl + collOut,
      spDeposits' = spDeposits,
      spColl' = spColl,
      price' = price,
      lastOp' = OP_REDEEM,
      lastTouched' = 1,
    }
  }

  /// PriceFeed.fetchPrice — a genuine external-call return, foot(Q) = none.
  action setPrice(p: int): bool = all {
    p > 0,
    p != price,
    price' = p,
    troves' = troves,
    boldSupply' = boldSupply,
    freeBold' = freeBold,
    spDeposits' = spDeposits,
    spColl' = spColl,
    systemColl' = systemColl,
    userColl' = userColl,
    lastOp' = OP_PRICE,
    lastTouched' = 0,
  }

  /// Convention 6: every `nondet` is exogenous — a caller identity for an
  /// action the caller initiates, a token amount, a calldata trove array, or an
  /// oracle price.  Nothing here names a trove that the PROTOCOL selects.
  action step: bool = {
    nondet u = USERS.oneOf()
    nondet v = USERS.oneOf()
    nondet collAmt = COLL_AMOUNTS.oneOf()
    nondet debtAmt = DEBT_AMOUNTS.oneOf()
    nondet rate = RATES.oneOf()
    nondet spAmt = SP_AMOUNTS.oneOf()
    nondet boldAmt = REDEEM_AMOUNTS.oneOf()
    nondet p = PRICES.oneOf()
    any {
      openTrove(u, collAmt, debtAmt, rate),
      adjustInterestRate(u, rate),
      closeTrove(u),
      provideToSP(spAmt),
      withdrawFromSP(spAmt),
      claimCollGains(spAmt),
      batchLiquidate(List(u, v)),
      redeem(u, boldAmt),
      setPrice(p),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — the T2 invariant.  Three separate books balance: trove debt
  /// against BOLD supply, BOLD supply against where the BOLD sits, and every
  /// unit of collateral against the three places it can be.  v1 could assert the
  /// first two and NOT the third, because its `redeem` deleted a fully redeemed
  /// trove's residual collateral from `totalColl` outright (v1 :148).
  val inv_conservation: bool = and {
    sumDebt(troves) == boldSupply,
    freeBold + spDeposits == boldSupply,
    sumColl(troves) == systemColl,
    systemColl + spColl + userColl == COLL_TOTAL,
  }

  val inv_bounds: bool = and {
    boldSupply >= 0,
    freeBold >= 0,
    spDeposits >= 0,
    spColl >= 0,
    systemColl >= 0,
    userColl >= 0,
    price > 0,
    troves.length() <= 3,
    troves.indices().forall(i => troves[i].debt >= 0),
    troves.indices().forall(i => troves[i].coll >= 0),
    troves.indices().forall(i => troves[i].active == (troves[i].debt > 0)),
  }

  /// THE ORDER IS MAINTAINED.  SortedTroves.sol:15 — descending annual interest
  /// rate, and `isCanonical` says the list carries no information the unordered
  /// trove set does not already carry.  That second clause is the machine-checked
  /// form of the state-space-cost claim: adding the order added zero reachable
  /// states, because the order is a FUNCTION of the set (the id tie-break is
  /// what buys it, and it also makes the set injective, since two troves can
  /// never coincide as records).
  val inv_listCanonical: bool = and {
    isSorted(troves),
    isCanonical(troves),
    troves.indices().forall(i => USERS.contains(troves[i].id)),
  }

  /// THE WALK STARTS AT THE EXTREMUM.  TroveManager.sol:770 enters the loop at
  /// `sortedTroves.getLast()`.  `redeemFrom` walks `rev(l)`, whose head is
  /// exactly that trove, and the fold form of the same extremum agrees.  Held
  /// at every reached state, so it covers every list the run actually builds —
  /// including the ones `reInsert` re-orders.
  val inv_walkStartsAtLast: bool =
    troves.length() == 0 or and {
      rev(troves).head() == getLast(troves),
      minByRate(troves) == getLast(troves),
      getFirst(troves).rate >= getLast(troves).rate,
    }

  /// T3 for this protocol (P2-SCOPE §5 row 5).  At EVERY reachable state, and
  /// for EVERY declared redemption amount, the walk respects the rate order,
  /// leaves at most one trove partially redeemed, stops only when the budget is
  /// spent or every eligible trove is drained, conserves debt against BOLD,
  /// counts its own steps, prices the payout to within one rounding unit per
  /// touched trove, and carries one price.  A spec that redeems from a nondet
  /// trove fails the first two clauses.
  val inv_redeemPrefix: bool =
    REDEEM_AMOUNTS.forall(a => redeemIsExtremal(troves, a, price))

  /// The batch offset never overdraws the Stability Pool and never loses a trove.
  val inv_liquidationCovered: bool =
    USERS.forall(a => USERS.forall(b =>
      liquidationIsCovered(troves, List(a, b), spDeposits, spColl,
                           boldSupply, systemColl, price)))

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_listCanonical,
    inv_walkStartsAtLast,
    inv_redeemPrefix,
    inv_liquidationCovered,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (P2-CONTRACT §D, the fifth trap).
  //  Each of these must be VIOLATED by `quint run --invariant=<name>`.  A
  //  violation is a trace; a trace is the proof the definition actually ran on
  //  the declared domain.  A `pure def` cited only by `pure val` equalities is a
  //  deleted mechanism carrying a certificate.
  // ===========================================================================

  /// THE ARITY OF THE SELECTION, which is P2-SCOPE §5 row 5's `wit_multiTrove`
  /// in the words it uses: "no redemption consumed >= 2 troves — must be
  /// violated".  ONE call took debt from at least two different troves.  This
  /// is the clause M1 cannot satisfy at any depth and under any sequence of
  /// driver choices, because its `redeem(u, boldAmt)` touches the one trove it
  /// was named and stops.  Everything else in this file passes under M1.
  val wit_multiTrove: bool = lastTouched < 2

  /// T0-LIVE.  `redeemPrefix(T0_TROVES, 6000, 2e6)` touching THREE troves in
  /// ONE call, as a TRACE.  Head-first debts [4000, 0, 0]: the two LOWEST-rate
  /// troves are at zero and the HIGHEST-rate trove — which also carries three
  /// times the debt of either — has been cut by exactly the 2000 residue.  4000
  /// is not in DEBT_AMOUNTS, so no `openTrove` can produce it.
  /// `lastTouched == 3` is load-bearing and was added after measurement: WITHOUT
  /// it, M1 reaches this exact state at depth 3 by being named trove 3, then
  /// trove 2, then trove 1, and the witness is violated under the deleted
  /// mechanism.  With it, M1 cannot: one call, three troves.  Under M3
  /// (largest-debt-first) and M4 (reverse order) the 6000 lands entirely on
  /// trove 1 and the state is unreachable at any depth with the declared
  /// amounts.  Depth 1 from init.
  val wit_live_redeemPrefix: bool =
    not(and {
      troves.length() == 3,
      debtsOf(troves) == List(4000, 0, 0),
      boldSupply == 4000,
      lastTouched == 3,
    })

  /// THE STRICT PREFIX, which is the brief's explicit obligation.  ONE call
  /// consumed the two lowest-rate troves and STOPPED — trove 1, at the highest
  /// rate and the largest debt, is untouched at 6000 while trove 2 sits at 1000.
  /// Exactly one trove is partially redeemed, and it is the one the budget ran
  /// out inside.  A STRICT prefix: `lastTouched == 2` against a list of 3.
  /// t0_25 is the companion, and it is the second half of the obligation: the
  /// same amount over the same three troves in the reverse order gives
  /// [2000, 2000, 3000] instead of [6000, 1000, 0], so a different order would
  /// have produced a different outcome — the same redeemer, the same 3000, a
  /// different set of counterparties and a different collateral payout.
  val wit_prefixStrict: bool =
    not(and {
      troves.length() == 3,
      debtsOf(troves) == List(6000, 1000, 0),
      troves[0].rate > troves[1].rate,
      troves[1].rate > troves[2].rate,
      lastTouched == 2,
    })

  /// THE SKIP, TroveManager.sol:788.  At PRICE_LOW the lowest-rate trove is
  /// below 100% collateralisation, so the walk steps OVER it — not into it, and
  /// not to a halt — hits the next-lowest rate, and then stops with budget in
  /// hand because everything else is ineligible too.  Head-first [6000, 0, 2000]:
  /// the middle trove is empty and BOTH its neighbours are untouched, which no
  /// "stop at the first ineligible trove" implementation can produce.  This one
  /// is a BRANCH witness (6f) and not an M1 discriminator: M1 reaches the same
  /// state by being named trove 2, and it is `wit_multiTrove` that separates
  /// them.  Recorded rather than papered over.
  val wit_skipBelow100: bool =
    not(and {
      troves.length() == 3,
      debtsOf(troves) == List(6000, 0, 2000),
    })

  /// `redeemPrefix` left a trove below MIN_DEBT — the state TroveManager.sol:694
  /// branches on, and the one this spec's zombie ABSTRACTED line is about.
  /// Reaching it proves the dropped branch is live rather than vacuous.
  val wit_belowMinDebt: bool =
    not(troves.indices().exists(i =>
      troves[i].active and troves[i].debt > 0 and troves[i].debt < MIN_DEBT))

  /// `reInsert` MOVED a trove.  Trove 3 raised its rate to 12, tying trove 1,
  /// and the id tie-break placed it second — so the list is [1, 3, 2] and the
  /// redemption queue now ends at trove 2.  No insert-at-open order can produce
  /// a list whose ids are not rate-then-id sorted from the opening rates, and no
  /// state reachable without `reInsert` has trove 2 last.
  val wit_used_reInsert: bool =
    not(and {
      troves.length() == 3,
      troves[0].id == 1,
      troves[1].id == 3,
      troves[2].id == 2,
      troves[0].rate == troves[1].rate,
    })

  /// `crWad` ran on a live trove and its answer was BELOW MCR — the liquidation
  /// trigger, which is the only reader that can turn a state-independent number
  /// into a state-dependent verdict.
  val wit_used_crWad: bool =
    not(troves.indices().exists(i => isLiquidatable(troves[i], price)))

  /// `liquidateBatch` ran and the Stability Pool absorbed collateral.  Nothing
  /// else writes `spColl` upward.
  val wit_used_liquidateBatch: bool = spColl == 0

  /// `canOpen` ran and admitted a trove: id 3 holding 9000 collateral.  init
  /// gives trove 3 exactly 4000, redemption only ever REDUCES collateral, and
  /// no other action raises it, so this state requires a close followed by an
  /// open that passed all four of `canOpen`'s clauses.
  val wit_used_canOpen: bool =
    not(troves.indices().exists(i => troves[i].id == 3 and troves[i].coll == 9000))

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_openTrove: bool = lastOp != OP_OPEN
  val wit_fired_closeTrove: bool = lastOp != OP_CLOSE
  val wit_fired_adjustInterestRate: bool = lastOp != OP_ADJUST
  val wit_fired_provideToSP: bool = lastOp != OP_PROVIDE
  val wit_fired_withdrawFromSP: bool = lastOp != OP_WITHDRAW
  val wit_fired_claimCollGains: bool = lastOp != OP_CLAIM
  val wit_fired_batchLiquidate: bool = lastOp != OP_LIQUIDATE
  val wit_fired_redeemCollateral: bool = lastOp != OP_REDEEM
  val wit_fired_setPrice: bool = lastOp != OP_PRICE
}
