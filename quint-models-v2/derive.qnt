// =============================================================================
//  derive (Lyra v2) — Phase 2 re-spec.  Replaces quint-models/L5/derive.qnt.
//
//  SOURCE:
//    protocol-repos/opt/derivexyz_v2-core/src/risk-managers/PMRMLib.sol
//      :92-127    getMarginAndMarkToMarket — THE ARGMIN
//      :99        int minSPAN = portfolio.basisContingency;      (fold seed)
//      :100       worstScenario = scenarios.length;              (index sentinel)
//      :102-111   the loop:  if (scenarioMTM < minSPAN) { minSPAN = ...;
//                            worstScenario = i; }
//      :113       minSPAN -= portfolio.staticContingency
//      :115-125   the isInitial branch: minSPAN *= imFactor; -= confidenceCont.
//      :127       return (minSPAN + totalMtM + cash, totalMtM + cash, worst)
//      :130-166   getScenarioMtM (:162-163 the base and perp legs, :165 the sum)
//      :212-218   _getShockedPerpValue      (:213-214 the position == 0 return)
//      :220-226   _getBaseValue             (:221-222 the position == 0 return)
//      :233-240   addPrecomputes — baseValue, totalMtM, staticContingency
//      :376-381   getBasisContingencyScenarios — the 3-scenario list, in order
//    protocol-repos/opt/derivexyz_v2-core/src/risk-managers/PMRM.sol
//      :137-156   setScenarios — marginScenarios is an ORDERED storage array
//      :172-213   handleAdjustment (:183-198 riskAdding, :210-212 the early exit)
//      :182       _checkIfLiveAuction — transfers blocked under liquidation
//      :186-188   _settlePerpRealizedPNL on any perp delta
//      :220-234   _assessRisk — trusted => MM over the 3 basis scenarios,
//                 untrusted => IM over all marginScenarios; revert if < 0
//      :458-462   getMargin(accountId, isInitial)
//      :467-478   getMarginAndMarkToMarket(accountId, isInitial, scenarioId)
//                 — the SINGLE-scenario form the auction uses
//    protocol-repos/opt/derivexyz_v2-core/src/assets/PerpAsset.sol
//      :446-450   _getUnrealizedPnl = (perpPrice - lastMarkPrice) * size
//      :296-303   settlement writes lastMarkPrice = perpPrice
//    protocol-repos/opt/derivexyz_v2-core/src/liquidation/DutchAuction.sol
//      :148-183   startAuction (:163 the margin read, :166 the MM < 0 guard)
//      :208-222   _startInsolventAuction — cachedMM = -maintenanceMargin
//      :232-240   updateScenarioId — "anyone can supply a scenarioId that will
//                 make the IM worse"; guarded by newMargin < currentMargin
//    protocol-repos/opt/derivexyz_v2-core/src/assets/CashAsset.sol :155, :203
//
//  MECHANISM:
//    Portfolio margin is an ARGMIN over an ordered array of price scenarios:
//    the fold seeds at the basis contingency with the index sentinel
//    `scenarios.length`, keeps the strictly-smaller scenario MtM and the index
//    that produced it, and the surviving index — `worstScenario` — is returned
//    to the caller and stored by the auction.  Which scenario is worst depends
//    on the SIGN of the portfolio's net delta, so two portfolios of identical
//    notional have different worst scenarios.
//
//  WHAT v1 DELETED (this file exists to restore it):
//    D-1  quint-models/L5/derive.qnt:22
//           pure val MAINT_PER_SHORT: int = 15   // abstract maintenance per short unit
//         applied at :86 as `qty * MAINT_PER_SHORT`.  The whole search over
//         PMRMLib.sol:99-111 is replaced by one multiplication.  The spec's own
//         header (:12) admits it: "NOT covered: full PMRM scenario matrix".
//         Restored as `worstScenarioMargin` over `scenarioSpan`.
//    D-2  v1 already declares `pure val SPOTS: Set[int] = Set(80, 100, 120)`
//         (:19) and uses it ONLY as a driver domain for `updateMark` and
//         `expire`.  The scenario set is present in the file and is never folded
//         over — the same shape as liquity carrying a sort key it never sorts
//         by.  Restored as the ordered `SPOT_SHOCKS` list that `scenarioSpan`
//         walks.  A `Set` cannot host `worstScenario` at all, because the
//         contract returns an ARRAY INDEX; `SPOT_SHOCKS` is a `List` for that
//         reason and for no other.
//    D-3  v1's `maintenance` is charged only to shorts (`if (isLong) 0 else
//         qty * 15`) and is blind to the base leg, to the perp price, to the
//         spot price and to the sign of the net delta.  6g: foot(minSPAN) =
//         {basePosition, perpPosition, spotPrice, perpPrice, stablePrice} and
//         `qty * 15` reads exactly one of the five.
//
//  PRESERVED (each is a guard, an index, or a value-flow observable):
//    the fold seed `basisContingency` and the index sentinel `scenarios.length`;
//    the STRICT `<` (first minimum wins, so the array order is load-bearing);
//    the returned index `worstScenario`; both scenario arrays and their orders;
//    the isInitial branch and its imFactor; `staticContingency` as a subtraction;
//    the `position == 0` early returns in both leg valuations; the truncation
//    direction of every division (Solidity `int /` truncates TOWARD ZERO and so
//    does Quint's `/` — verified, see UNITS); the risk check on every
//    risk-adding adjustment and the early exit when nothing is risk-adding;
//    the auction's MM < 0 trigger, its stored scenario index and cachedMM, and
//    `updateScenarioId`'s "strictly worse" guard.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - OPTION LEGS.  `portfolio.expiries`, `_getExpiryShockedMTM` (:169-202) and
//      `Black76.prices` are NOT DERIVABLE by reading: they need on-chain vol,
//      forward and discount parameters.  Flagged at gate 2.0e and carried by
//      P2-CONTRACT §A.9 as a NOT DERIVABLE row.  The substitute is the
//      contract's own EMPTY-`expiries` path — a real path, not a relaxation of
//      the formula: with zero expiries the loop at :131-149 contributes nothing
//      and `scenarioMtM` reduces EXACTLY to `_getBaseValue + _getShockedPerpValue
//      - baseValue` (:161-165).  No Black76 number is invented anywhere here.
//      Consequence, recorded rather than hidden: on this path `scenarioMtM` is
//      affine in the spot shock, so the endpoints of the shock array determine
//      the minimum.  See CONTRAST SET member M5.
//    - `volShock`.  `IPMRM.Scenario.volShock` is read by `_getExpiryShockedMTM`
//      and by NOTHING else (:171-179).  With zero expiries no expression reads
//      it, so it is droppable by the droppability rule rather than by choice.
//      Scenarios are therefore spot shocks alone.
//    - CONTINGENCIES.  `staticContingency` is kept as a `pure def` with the
//      owner parameters as arguments and pinned on both sides (t0_18/t0_19), but
//      the modelled deployment sets `otherContParams.perpPercent = basePercent
//      = 0`, which is what P2-CONTRACT §A.9's vectors assume; nothing in
//      `setMarginParams`/`setVolShockParams` forbids 0.  `confidenceContingency`
//      is 0 for the same reason (it is an option-leg quantity, :260).
//      `basisContingency` is 0 by DERIVATION, not by choice: :299-306 accumulates
//      it over `portfolio.expiries`, which is empty.
//    - the stable de-peg branch (:116-121).  `otherContParams.pegLossFactor` is
//      an owner parameter and is not derivable by reading, so `stablePrice` is
//      held at the peg (`STABLE_PRICE == UNIT`), on which branch the adjustment
//      is identically zero and `mFactor == imFactor` everywhere in 𝒟.  Neither
//      `pegLossThreshold` nor `pegLossFactor` is named as a spec constant, so
//      8c has nothing to cross here.
//    - perp FUNDING.  `getUnsettledAndUnrealizedCash` (:243-251) is
//      `unrealizedFunding + unrealizedPnl + position.funding + position.pnl`;
//      the funding terms need the on-chain funding-rate state and are dropped.
//      `perpValue` is the unrealised PnL alone (:446-450), which is exact.
//    - the AUCTION PRICE PATH (bids, `_getDiscountPercentage`, the solvent /
//      insolvent split, `totalInsolventMM`, `terminateAuction`, the security
//      module).  Dropped by P2-SCOPE row 9.  `cachedMM` is therefore written
//      unconditionally with the insolvent-branch formula `-maintenanceMargin`
//      (:210-211); no guard reads the split once bids are gone.  An account
//      under auction is terminal in this model, because the only exits are a bid
//      and `terminateAuction`.  `inv_auctionUnderwater` is stated on the stored
//      `cachedMM` for exactly that reason, and not on a recomputed margin.
//    - subaccount NFTs, `SubAccounts.submitTransfer` plumbing, OI fees,
//      `settleInterest`, and the option asset's European cash settlement.  The
//      last is a v1-scope reduction and is recorded as deviation D-c below: an
//      account holding an option would have to price it through Black76 inside
//      `scenarioMtM`, and inventing that number is the one thing this re-spec
//      may not do.
//    - `maxAccountSize` / `PMRM_TooManyAssets` (:200-207): three assets, one
//      account, never binding.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label of the observation
//    interface (P2-FIDELITY §1) and carries exactly what the contract's own
//    events carry.  It is read by `wit_fired_*` (convention 6d) and by nothing
//    else; no guard and no `pure def` reads it.  Exempt from 6e's write-only
//    clause on that basis, per PILOT-NOTES.md §5 step 2.
//    `lastArgminArity` and `lastArgminIndex` are the ARITY GHOST: how many
//    scenarios the most recent margin read compared, and which index it
//    returned.  Justification against the contract, which is what makes them a
//    trace label rather than an invention: both are on-chain observables.  The
//    count is `scenarios.length` — `marginScenarios.length` for an ordinary
//    caller, 3 for a trusted risk assessor (PMRM.sol:224-232), 1 for the auction
//    (PMRM.sol:473-477) — and `PMRMLib.sol:97` reverts when it is 0, so the
//    contract itself reads it.  The index is the THIRD RETURN VALUE of
//    `getMarginAndMarkToMarket` (:95, :127) and is written to storage by
//    `DutchAuction` as `auctions[].scenarioId` (:191-193, :213), where
//    `updateScenarioId` then compares against it.  They are read by
//    `wit_arity_*` and by nothing else; no guard, no invariant and no `pure def`
//    reads them.  They exist because a value signature cannot express "chosen
//    by comparing against the whole set in one evaluation" — see the
//    `wit_arity_fullScan` note.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 3 subaccounts (two account `nondet`s); cash amounts 3, base
//       amounts 3, perp quantities 3, feed prices 4, scenario ids 5, a bool.
//       Eight `nondet`s per step, each <= 5 values.  Ordered state is one
//       5-element `List` and one 3-element `List`, both constant.
//    8b magnitude — peak intermediate 4.32e6 (`baseValue`'s inner
//       `position*spot*shock` chain at base 300, spot 12000, shock 120, then
//       `* UNIT` for the `divideDecimal`), measured by exhaustive scan over the
//       declared domain.  `< 9.22e18` with 12 orders of magnitude to spare.
//       This spec does NOT call `isqrtFloor`, so it does not inherit that
//       definition's 4.611686e18 floor (PILOT-NOTES.md D-d).
//    8c constant-crossing —
//       UNIT = 100 is crossed by the shock array on BOTH sides (80, 90 below;
//         110, 120 above; 100 exactly), so `spotShock - UNIT` takes both signs
//         and zero — t0_05 / t0_06 / t0_07.
//       the fold seed `basisContingency = 0` is crossed by `scenarioMtM`: a
//         short portfolio drives it negative (t0_25, index 4), a long-base
//         portfolio drives it negative at the other end (t0_26, index 0), and a
//         delta-neutral portfolio never crosses it at all, leaving the SENTINEL
//         (t0_28, t0_29, index == length).  All three are reachable.
//       the `position == 0` early returns are crossed both ways: base 0 vs base
//         > 0 (t0_03), perp 0 vs perp != 0 (t0_08).
//       `isInitial` is crossed by the trusted-risk-assessor switch, which is a
//         modelled `var` and an owner action, not a driver `nondet`.
//       the auction's `maintenanceMargin < 0` is crossed: a 300-lot at 8000
//         cash is admissible at open (IM +200) and liquidatable after the feed
//         moves to 12000 (MM -3200) — t0_34 and t0_36 are the two sides.
//       `worstScenario` itself crosses its sentinel: 0, 4 and 5 are all reached.
//    NOTE on the old cap.  Convention 8's original "integer ranges <= 200" made
//    this protocol DEAD, not degraded: `spot = 10^4` is unrepresentable, so
//    every `multiplyDecimal(position, spot)` truncates to 0 and every scenario
//    MtM is identically 0.  P2-CARRYFORWARD CF1 row 9.  The spot domain here is
//    8000..12000 and the shock domain is 80..120 for that reason.
//
//  INPUTS:  (convention 6g — foot(Q) = contract storage Q's value depends on)
//    | name      | contract expression                  | file:line | foot(Q) | spec vars read |
//    | u, v      | msg.sender / accountId               | PMRM:172  | none    | none (calldata) |
//    | amt       | CashAsset.deposit(amount)            | Cash:155  | none    | none (calldata) |
//    | baseAmt   | WrappedERC20Asset.deposit(amount)    | Wrapped   | none    | none (calldata) |
//    | qty       | AssetDelta.delta on the perp         | PMRM:186  | none    | none (calldata) |
//    | px        | ISpotFeed.getSpot() / perp mark      | PMRM:459  | none    | none (external call) |
//    | sid       | DutchAuction.startAuction(_, sid)    | DA:148    | none    | none (calldata) |
//    | flag      | setTrustedRiskAssessor(_, bool)      | PMRM      | none    | none (calldata) |
//    NOTHING that the protocol itself computes is supplied by the driver.  In
//    particular `worstScenario`, `minSPAN`, `perpValue` and `baseValue` are all
//    computed from `var`s, and the two quantities v1 supplied by literal —
//    `MAINT_PER_SHORT` and the unused `SPOTS` — are now
//    `foot(minSPAN) = {basePosition, perpPosition, spotPrice, perpPrice,
//    stablePrice}` and are read in full by `scenarioSpan`.  6g's own ten-way
//    table (P2-CARRYFORWARD CF2 row 9) names this protocol as one it catches;
//    it is re-checked explicitly here and the footprint is now complete.
//    `px` is a genuine external-call return, exactly the oracle case 6g permits;
//    `sid` is calldata by construction — `startAuction` is `external` with no
//    access control, so the LIQUIDATOR picks the scenario and the contract only
//    verifies it (DA:166, DA:236-240).  See DEVIATIONS D-d for the lint
//    consequence.
//
//  COVERAGE:  (convention 6e — every external state-changing function)
//    PMRM.handleAdjustment            -> the risk gate inside every action below
//    PMRM.setTrustedRiskAssessor      -> action setTrustedRiskAssessor
//    PMRM.setScenarios                -> ABSTRACTED (one fixed scenario array;
//                                        modelled as SPOT_SHOCKS, and the owner
//                                        cannot change it without a redeploy)
//    PMRM.setMarginParams / setVolShockParams / setOtherContingencyParams
//                                     -> ABSTRACTED (owner parameters, fixed)
//    PMRM.mergeAccounts / settleInterest / settlePerpsWithIndex
//                                     -> ABSTRACTED (plumbing; no guard reads)
//    CashAsset.deposit                -> action depositCash
//    CashAsset.withdraw               -> action withdrawCash
//    WrappedERC20Asset.deposit        -> action depositBase
//    WrappedERC20Asset.withdraw       -> action withdrawBase
//    PerpAsset (transfer + settle)    -> action tradePerp
//    spot / perp feeds                -> actions updateSpot / updatePerpPrice
//    DutchAuction.startAuction        -> action startAuction
//    DutchAuction.updateScenarioId    -> action updateScenarioId
//    DutchAuction.bid / continueInsolventAuction / terminateAuction
//                                     -> ABSTRACTED (auction price path)
//    OptionAsset.*                    -> ABSTRACTED (see D-c)
//    Storage read by a require on a state-changing path:
//      cash balance (Cash:203)              -> var cashOf
//      base balance                          -> var baseOf
//      perp position (PMRM:370)              -> var perpOf
//      positions[].lastMarkPrice (Perp:447)  -> var lastMarkOf
//      spot feed / perp feed (PMRM:459)      -> var spotPrice, var perpPrice
//      trustedRiskAssessor (PMRM:224)        -> var trustedOf
//      auctions[].ongoing (DA:168, DA:233)   -> var auctionOngoing
//      auctions[].scenarioId (DA:240)        -> var auctionScenario
//      auctions[].cachedMM (DA:214)          -> var auctionCachedMM
//      CashAsset.totalSupply                 -> var cashSupply
//      WrappedERC20Asset.totalSupply         -> var baseSupply
//    No `var` is write-only.  `auctionCachedMM` is read by `inv_auctionUnderwater`
//    and by `wit_used_worstScenarioMargin`; `auctionScenario` is read by
//    `updateScenarioId`'s own guard; `baseSupply` and `cashSupply` by
//    `inv_conservation` and `inv_baseConservation`.
//
//  UNITS:  (hole H2's obligation)
//    UNIT = 100 is the decimal one.  DecimalMath.multiplyDecimal(a,b) = a*b/UNIT
//    and divideDecimal(a,b) = a*UNIT/b.
//    basePosition, baseAmt, baseSupply        — base-asset contracts * UNIT
//    perpPosition, qty                        — perp contracts * UNIT, SIGNED
//    spotPrice, perpPrice, stablePrice, px    — quote per contract * UNIT
//    spotShock                                — dimensionless * UNIT (100 = 1.0)
//    imFactor                                 — dimensionless * UNIT
//    cash, cashSupply, scenarioMtM, minSPAN, margin, markToMarket, cachedMM
//                                             — quote units * UNIT
//    worstScenario, scenarioId                — an ARRAY INDEX, not a quantity
//    Solidity `int` division truncates toward zero, and Quint's `/` does the
//    same — verified: (-7)/2 == -3 and (-201)/100 == -2, not -4 and -3.  So
//    `multiplyDecimal` below is exact against the contract on negative operands,
//    which is where a floor-based helper would silently diverge.  t0_10 and
//    t0_24 pin that direction.
//
//  CONTRAST SET 𝔐 (F0/F2, with R4's three mandatory members):
//    M0  scenarioSpan = the fold of PMRMLib.sol:99-111 over SPOT_SHOCKS  [target]
//    M1  the v1 body verbatim: maintenance = (if isLong then 0 else qty*15),
//        margin = cash + mtm - maintenance (derive.qnt:22, :86).  MANDATORY
//        member 1.  It has no scenario array and therefore NO INDEX AT ALL, so
//        every vector on `scenarioSpan._2` is unsatisfiable by construction.
//    M1' the review's decoration: MAINT_PER_SHORT carried through a per-scenario
//        factor, i.e. scenarioMtM'(p, s) = -(|base|+|perp|) * 15 * |s-UNIT| / UNIT.
//        This is the cheat this file is written against.  It satisfies
//        `inv_marginIsMin` (any fold-min does) — MEASURED, see MUTANT RESULTS.
//        Agreement with M0, measured exhaustively over the 448-cell declared
//        grid (4 base x 7 perp x 4 spot x 4 perpPrice): span VALUE 18/448 =
//        4.0%, span INDEX 321/448 = 71.7%, both 17/448 = 3.8%.  It is killed
//        three times over:
//          (a) it is symmetric in `s - UNIT`, so its minimum is attained at both
//              ends and first-wins pins `worstScenario == 0` for EVERY
//              portfolio; t0_25 and t0_27 both require 4;
//          (b) it does not read the base/perp split, so it cannot produce
//              t0_25's [2000,1000,0,-1000,-2000] and t0_26's
//              [-4000,-2000,0,2000,4000] from the same |exposure|;
//          (c) `wit_splitSensitiveArgmin` is a REACHABLE STATE in which two
//              accounts of equal |base|+|perp| and equal margin have different
//              `worstScenario`.  M1' makes that state unreachable.
//    M2  chaos: margin = any value <= cash + mtm.  MANDATORY member 2, the
//        maximally permissive form in the same relaxation direction.  Killed by
//        every T0 equality and by `inv_marginIsMin`'s `exists` clause.
//    M3  the sibling in the corpus: apex's exogenous scalar `markPrice`
//        valuation (quint-models/L3/apex.qnt:138-153) applied here as
//        minSPAN = -|perp| * spot / UNIT with the index pinned at 0.  MANDATORY
//        member 3.  Agreement, same 448-cell grid: value 16/448 = 3.6%, index
//        305/448 = 68.1%, both 0/448 = 0.0%.  Killed by t0_25 and by 6g
//        (foot = {perpPosition, spotPrice} only — no base leg, no perp price).
//    M4  the sign-blind rival: the correct MAGNITUDE with the index thrown away
//        (minSPAN identical to M0, `worstScenario` hard-wired to 0).  Agreement:
//        value 448/448 = 100.0%, index 305/448 = 68.1%, both 305/448 = 68.1%;
//        on the 418 non-sentinel cells the index agrees 305/418 = 73.0%.  This
//        is R4's mandatory near neighbour and it clears the >= 90% clause on the
//        value column outright.  Killed ONLY by the index — t0_25 (4) against
//        t0_26 (0) — and by `wit_splitSensitiveArgmin`.  M4 is the member that
//        makes the case for keeping `worstScenario`: NOTHING in the value column
//        separates it from M0, anywhere on the declared domain.
//    M5  the endpoint shortcut: scan only indices 0 and length-1 of the same
//        array, keeping the real indices.  Agreement 448/448 = 100.0% on the
//        value AND on the index.  RECORDED FINDING, not a defect this file can
//        close: on the empty-`expiries` path `scenarioMtM` is affine in the
//        shock, so the interior scenarios are provably redundant.  Separating M0
//        from M5 requires a convex leg, and the only convex leg in this contract
//        is the option leg, whose value is NOT DERIVABLE by reading (see
//        ABSTRACTED).  This is the honest cost of the gate-2.0e substitution and
//        it is reported rather than papered over.  It does not weaken the case
//        against M1/M1'/M3/M4, which are the members that carry the deletion.
//    Consistent with PILOT-NOTES.md §7's finding, R4's ">= 90% agreement" clause
//    IS satisfiable here (M4 and M5 both hit 100% on the value) precisely
//    BECAUSE the substituted path is affine; the pilot found no such rival for
//    an extremal algebraic identity.  Both observations point the same way: the
//    agreement percentage is a property of the substituted path, not of the
//    mechanism.  A third observation is new here — M4 and M5 agree with M0 on
//    100% of the VALUES and are separated only by the INDEX, so for this
//    protocol the R4 percentage must be reported per RETURNED COMPONENT, not per
//    function.  A contrast set scored on the value column alone would report
//    "no rival separates" and would be wrong.
//
//  MUTANT RESULTS (PILOT-NOTES K10 — a contrast set that is only declared is
//  the fourth trap).  `mutants/derive_M1prime.qnt` is one substitution at the
//  single definition site of `scenarioMtM`, replacing it with the review's
//  decorated constant
//      scenarioMtM'(p, s) = -(|base| + |perp|) * MAINT_PER_SHORT * |s - UNIT| / UNIT
//  plus the `../kernel` import path.  MEASURED:
//    inv_T0                        [violation]  <- killed by t0_11..t0_17, t0_25..t0_33
//    inv_conservation              [ok]         <- CONSERVATION DOES NOT DISCRIMINATE
//    inv_marginIsMin               [ok]         <- THE CHEAT PASSES IT, exactly as
//                                                  the plan review predicted: it is
//                                                  a tautology about any fold-min
//    inv_worstIsFirst              [ok]         <- also a shape property; also passes
//    wit_splitSensitiveArgmin      [ok]         <- THE KILL.  The T0-LIVE state is
//                                                  UNREACHABLE under the decoration,
//                                                  because a per-unit charge is
//                                                  sign-blind and returns the same
//                                                  index for both legs of a trade
//    wit_nonTrivialArgmin          [ok]         <- ditto; worstScenario is 0 always
//    wit_arity_fullScan            [ok]         <- the ARITY half also kills it: a
//                                                  sign-blind per-unit charge is
//                                                  minimised at BOTH ends, so
//                                                  first-wins pins the index at 0
//                                                  and a five-wide scan can never
//                                                  return index 4
//    wit_arity_basisScan           [ok]         <- ditto on the 3-wide array
//    wit_arity_singleScenario      [violation]  <- NOT DISCRIMINATING (arity 1 is
//                                                  the auction path, which the
//                                                  mutant also takes)
//    wit_used_worstScenarioMargin  [violation]  <- NOT DISCRIMINATING, and this is
//                                                  worth stating: a use-witness
//                                                  proves the definition is live,
//                                                  never that it is right.  The
//                                                  mutant still writes `cachedMM`
//  Two lines carry the whole case.  `inv_marginIsMin` is the P2-SCOPE §5 row 9
//  check, and it PASSES under the cheat — a re-spec that shipped only the three
//  named acceptance criteria would have signed the deletion off.  What kills it
//  is the T0 vectors on the INDEX and the reachability of a state in which two
//  equal-notional portfolios disagree about which scenario is worst.
//
//  DEVIATIONS, each with its reason:
//    D-a  Registry extended from 1 name to 7.  P2-SCOPE §3 lists
//         `worstScenarioMargin`; convention 6b requires every arithmetic
//         mechanism to be a registry-named `pure def`, and there are seven here
//         (`shockedBaseValue`, `shockedPerpValue`, `scenarioMtM`,
//         `staticContingency`, `perpUnrealizedPnl`, `scenarioSpan`,
//         `worstScenarioMargin`).  `scenarioSpan` is split out of
//         `worstScenarioMargin` because P2-CONTRACT §A.9's `margin` column IS
//         the span (the minimum of the scenario vector), not the returned
//         margin, and the vectors must be pinned against the column as written.
//    D-b  T0 set enlarged from 3 rows to 42 vectors.  §A.9 gives three; 6c
//         wants an inexact quotient per `pure def` and 6f wants both sides of
//         every branch, of which this contract has nine (two `position == 0`
//         returns, the strict `<`, the sentinel, `isInitial`, the trusted arm,
//         the auction trigger, `shock - UNIT`'s sign, and the contingency
//         parameters).
//    D-c  v1's option instrument and its European cash settlement are NOT
//         carried over.  This is a scope REDUCTION against v1 and it is the
//         direct consequence of the gate-2.0e NOT-DERIVABLE flag: an account
//         holding an option would have to price it inside `scenarioMtM` through
//         `Black76.prices`, and P2-CONTRACT §A.9's own substitute is the
//         empty-`options` path.  Modelling settlement while excluding the same
//         option from the risk model would be incoherent, and inventing a
//         Black76 number is the one thing forbidden.  Recorded, not hidden.
//    D-d  `respec_lint.py` reports two D4a findings, both on
//         `startAuction(u, sid)`, and BOTH ARE FALSE POSITIVES.  D4's rule is
//         "the driver picks an element identity that the protocol itself
//         selects".  `DutchAuction.startAuction` (:148) is `external` with no
//         access control: the LIQUIDATOR picks the account and the scenario
//         index, and the contract's only job is to verify the claim (:166,
//         :236-240).  This is the same shape as the exemption the detector
//         already grants to `close` in its own comment — a caller acting on a
//         target of their choosing — and the fix is to treat `auction` the way
//         `close` is treated, or to exempt a selection action whose target is
//         re-verified by a guard inside the same action.  Recommendation to the
//         linter owner: D4 should not fire when the action body contains a guard
//         that re-derives the selection criterion from `var`s, which is exactly
//         `marginOf(singleScenarioMargin(target, sid)) < 0`.
//         SECOND, SEPARATE LINTER FINDING in the same two lines.  `keyed` is
//         computed once PER ACTION — the loop breaks on the first parameter that
//         keys state — and is then attributed PER ARGUMENT.  `sid` is an integer
//         index that never keys a map here, yet it is reported as D4a rather
//         than D4b because `target` keys one.  The D4a/D4b split was added
//         precisely so the linter could tell a defect from its own repair, and
//         this attribution bug collapses the two again for every action with
//         more than one driver-supplied argument.  Fix: compute `keyed` for the
//         argument being reported, not for the action.
//    D-e  `INIT_CASH = 8000` rather than 0.  The margin gate is a guard, so a
//         zero-cash `init` makes every risk-adding action disabled and the
//         mechanism unreachable at depth 1; the T0-LIVE state needs one trade
//         from `init`.  8000 is the smallest CASH_AMOUNTS value that admits the
//         largest declared perp quantity under IM (t0_39: margin +200), so the
//         constant is crossed rather than cleared — a 300-lot at 7000 is refused
//         (t0_40).  Domain choice, recorded per the standing directive.
//
//  ACCEPTANCE:
//    T1  quint typecheck derive.qnt
//    T2  quint run --main=derive --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 derive.qnt
//    T3  quint run --main=derive --invariant=inv_all \
//          --max-steps=20 --max-samples=2000 derive.qnt            (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: `worstScenario = 4` then `= 0` (P2-CONTRACT §D part 2).  The
//        obligation is the TRACE that violates `wit_splitSensitiveArgmin`: a
//        reachable state holding TWO accounts with equal |base| + |perp|, equal
//        `margin`, and `worstScenario` 4 and 0 respectively.  One `tradePerp`
//        from `init` produces it, because the two legs of one trade are equal
//        and opposite.  No per-unit constant, decorated or not, can reach it.
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
//    setTrustedRiskAssessor  MODELLED        src/risk-managers/BaseManager.sol:171  onlyOwner
//    withdrawBase            MODELLED        src/SecurityModule.sol:73  onlyOwner
//    withdrawCash            MODELLED        src/SecurityModule.sol:73  onlyOwner
//    depositBase             PERMISSIONLESS  src/assets/WLWrappedERC20Asset.sol:57  no caller che
//    depositCash             PERMISSIONLESS  src/assets/WLWrappedERC20Asset.sol:57  no caller che
//    startAuction            PERMISSIONLESS  src/liquidation/DutchAuction.sol:148  no caller chec
//    updateScenarioId        PERMISSIONLESS  src/liquidation/DutchAuction.sol:233  no caller chec
//    tradePerp               UNRESOLVED      no contract function matched by name
//    updatePerpPrice         UNRESOLVED      no contract function matched by name
//    updateSpot              UNRESOLVED      no contract function matched by name
// --------------------------------------------------------------------------
module derive {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// DecimalMath.UNIT, descaled from 1e18.  P2-CONTRACT §C row 9.
  pure val UNIT: int = 100

  /// PMRM.setScenarios (:137-156).  An ORDERED array in storage; `worstScenario`
  /// is an index into it, so this is a List and not a Set.  Five spot shocks
  /// straddling UNIT, per P2-CARRYFORWARD row 9.
  pure val SPOT_SHOCKS: List[int] = [80, 90, 100, 110, 120]

  /// PMRMLib.getBasisContingencyScenarios (:376-381), IN THE CONTRACT'S ORDER:
  /// [scenarioSpotUp, scenarioSpotDown, UNIT].  Note it is NOT ascending.
  pure val BASIS_SHOCKS: List[int] = [120, 80, 100]

  /// marginParams.imFactor (:115-116); setMarginParams validates it into
  /// [1e18, 4e18], i.e. [UNIT, 4*UNIT] descaled.  1.3x.
  pure val IM_FACTOR: int = 130

  /// portfolio.basisContingency — the fold SEED (:99).  Zero by derivation, not
  /// by choice: :299-306 accumulates it over `portfolio.expiries`, which is
  /// empty on the modelled path.
  pure val BASIS_CONTINGENCY: int = 0
  /// portfolio.confidenceContingency (:124) — an option-leg quantity (:260).
  pure val CONFIDENCE_CONTINGENCY: int = 0
  /// otherContParams.perpPercent / basePercent (:239-240).  See ABSTRACTED.
  pure val PERP_PERCENT: int = 0
  pure val BASE_PERCENT: int = 0

  /// The stable feed, at the peg.  See ABSTRACTED for the de-peg branch.
  pure val STABLE_PRICE: int = 100

  pure val ACCOUNTS: Set[str] = Set("alice", "bob", "carol")

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN 𝒟 (convention 8a; see BOUNDS for 8b and 8c)
  // ---------------------------------------------------------------------------

  pure val CASH_AMOUNTS: Set[int] = Set(2000, 8000, 10000)
  pure val BASE_AMOUNTS: Set[int] = Set(100, 200, 300)
  pure val PERP_QTYS: Set[int] = Set(100, 200, 300)
  /// 11500 is present so that a settled PnL is NOT a multiple of the deposit
  /// granularity; `wit_used_perpUnrealizedPnl` depends on that separation.
  pure val FEED_PRICES: Set[int] = Set(8000, 10000, 11500, 12000)
  /// Every cash amount and INIT_CASH is a multiple of this; no PnL at 11500 is.
  pure val CASH_GRANULARITY: int = 2000
  pure val SCENARIO_IDS: Set[int] = Set(0, 1, 2, 3, 4)
  pure val TRUST_FLAGS: Set[bool] = Set(true, false)

  pure val INIT_CASH: int = 8000
  pure val INIT_BASE: int = 0
  pure val INIT_PERP: int = 0
  pure val INIT_SPOT: int = 10000
  pure val INIT_PERP_PRICE: int = 10000
  pure val INIT_CASH_SUPPLY: int = 24000
  pure val INIT_BASE_SUPPLY: int = 0
  pure val INIT_TRUSTED: bool = false
  pure val INIT_AUCTION: bool = false
  pure val INIT_SCENARIO: int = 0
  pure val INIT_CACHED_MM: int = 0
  pure val INIT_ARITY: int = 0
  pure val INIT_ARGMIN_INDEX: int = 0

  pure val OP_INIT: str = "init"
  pure val OP_DEP_CASH: str = "depositCash"
  pure val OP_WD_CASH: str = "withdrawCash"
  pure val OP_DEP_BASE: str = "depositBase"
  pure val OP_WD_BASE: str = "withdrawBase"
  pure val OP_TRADE_PERP: str = "tradePerp"
  pure val OP_SPOT: str = "updateSpot"
  pure val OP_PERP_PX: str = "updatePerpPrice"
  pure val OP_TRUST: str = "setTrustedRiskAssessor"
  pure val OP_AUCTION: str = "startAuction"
  pure val OP_RESCEN: str = "updateScenarioId"

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  var cashOf: str -> int          // quote * UNIT
  var baseOf: str -> int          // base contracts * UNIT, >= 0
  var perpOf: str -> int          // perp contracts * UNIT, signed
  var lastMarkOf: str -> int      // PerpAsset positions[].lastMarkPrice
  var spotPrice: int
  var perpPrice: int
  var cashSupply: int             // CashAsset.totalSupply
  var baseSupply: int             // WrappedERC20Asset.totalSupply
  var trustedOf: str -> bool      // PMRM.trustedRiskAssessor
  var auctionOngoing: str -> bool // DutchAuction auctions[].ongoing
  var auctionScenario: str -> int // DutchAuction auctions[].scenarioId
  var auctionCachedMM: str -> int // DutchAuction auctions[].cachedMM
  var lastOp: str                 // GHOST — trace label, see header
  var lastArgminArity: int        // GHOST — scenarios compared by the last margin read
  var lastArgminIndex: int        // GHOST — the index that read returned

  // ===========================================================================
  //  LOCAL PRIMITIVES (P2-SCOPE §3 marker; candidates for kernel promotion).
  //  DecimalMath / SignedDecimalMath.  Quint's `/` truncates toward zero, which
  //  is Solidity's `int` division exactly; the kernel's `mulDivDown` is a floor
  //  only on non-negative operands, and this protocol is signed throughout, so
  //  the direction is named here rather than assumed.
  // ===========================================================================

  /// LOCAL PRIMITIVE: DecimalMath.multiplyDecimal / SignedDecimalMath.multiplyDecimal
  pure def multiplyDecimal(a: int, b: int): int = a * b / UNIT

  /// LOCAL PRIMITIVE: DecimalMath.divideDecimal
  pure def divideDecimal(a: int, b: int): int = a * UNIT / b

  // `absInt` comes from the kernel (SignedMath.abs), appended there by W1.

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  //  `worstScenarioMargin` is the registry name (P2-SCOPE §3).  Every def below
  //  is pinned by exact T0 vectors AND carries a `wit_used_*` reachability
  //  obligation, because a `pure val` equality is true in states where the
  //  definition is never applied (the fifth trap, P2-CONTRACT §D).
  // ===========================================================================

  /// PMRMLib.sol:220-226 — _getBaseValue.
  ///   position.multiplyDecimal(spot).multiplyDecimal(spotShock)
  ///           .divideDecimal(stablePrice)
  /// The `position == 0` early return at :221-222 is a branch, not an
  /// optimisation: it is the only reason a flat account has an all-zero vector.
  pure def shockedBaseValue(position: int, spot: int, stable: int, shock: int): int =
    if (position == 0) 0
    else divideDecimal(multiplyDecimal(multiplyDecimal(position, spot), shock), stable)

  /// PMRMLib.sol:212-218 — _getShockedPerpValue.
  ///   (spotShock - UNIT).multiplyDecimal(perpPrice) then .multiplyDecimal(position)
  /// SIGNED on both factors.  This is the leg that makes `worstScenario` depend
  /// on the direction of the position rather than on its size.
  pure def shockedPerpValue(position: int, perpPriceIn: int, shock: int): int =
    if (position == 0) 0
    else multiplyDecimal(position, multiplyDecimal(shock - UNIT, perpPriceIn))

  /// PMRMLib.sol:130-166 — getScenarioMtM on the EMPTY-`expiries` path.
  /// With zero expiries the loop at :131-149 adds nothing and :161-165 is the
  /// whole function:  shockedBase + shockedPerp - portfolio.baseValue.
  pure def scenarioMtM(base: int, perp: int, spot: int, perpPriceIn: int,
                       stable: int, shock: int): int =
    shockedBaseValue(base, spot, stable, shock)
      + shockedPerpValue(perp, perpPriceIn, shock)
      - shockedBaseValue(base, spot, stable, UNIT)

  /// PMRMLib.sol:239-240 — the static contingency, kept as a subtraction with
  /// its owner parameters exposed so both sides of them can be pinned.
  pure def staticContingency(base: int, perp: int, spot: int,
                             perpPct: int, basePct: int): int =
    multiplyDecimal(multiplyDecimal(absInt(perp), perpPct)
                      + multiplyDecimal(base, basePct), spot)

  /// PerpAsset.sol:446-450 — _getUnrealizedPnl.
  ///   (perpPrice - lastMarkPrice).multiplyDecimal(size)
  pure def perpUnrealizedPnl(position: int, perpPriceIn: int, lastMark: int): int =
    multiplyDecimal(perpPriceIn - lastMark, position)

  /// THE ARGMIN — PMRMLib.sol:99-111, transcribed line for line.
  ///   int minSPAN = portfolio.basisContingency;   <- the seed, NOT +infinity
  ///   worstScenario = scenarios.length;           <- the index SENTINEL
  ///   for (i = 0; i < scenarios.length; ++i)
  ///     if (scenarioMTM < minSPAN) { minSPAN = scenarioMTM; worstScenario = i; }
  /// The comparison is STRICT, so the FIRST minimum wins and the array order is
  /// load-bearing; that is why `shocks` is a `List`.  Returned as
  /// (minSPAN, worstScenario).  The accumulator carries the running index, in
  /// the same way gate 2.0d's `newtonD` accumulator has to carry its `done`
  /// flag: a bare fold over the values alone silently deletes the index, which
  /// is the half of this mechanism that no value-level check can see.
  pure def scenarioSpan(base: int, perp: int, spot: int, perpPriceIn: int,
                        stable: int, shocks: List[int]): (int, int) = {
    val seeded = (BASIS_CONTINGENCY, shocks.length(), 0)
    val scanned = shocks.foldl(seeded, (acc, sh) => {
      val m = scenarioMtM(base, perp, spot, perpPriceIn, stable, sh)
      if (m < acc._1) (m, acc._3, acc._3 + 1) else (acc._1, acc._2, acc._3 + 1)
    })
    (scanned._1, scanned._2)
  }

  /// REGISTRY NAME (P2-SCOPE §3) — PMRMLib.getMarginAndMarkToMarket, :92-127.
  /// Returns (margin, markToMarket, worstScenario), the contract's own triple.
  ///   :113  minSPAN -= staticContingency
  ///   :115-125  if (isInitial) { minSPAN *= imFactor; minSPAN -= confidence }
  ///   :127  return (minSPAN + totalMtM + cash, totalMtM + cash, worstScenario)
  /// `totalMtM` is :234-237's baseValue + perpValue, with no expiry terms.
  pure def worstScenarioMargin(base: int, perp: int, spot: int, perpPriceIn: int,
                               stable: int, perpValueIn: int, cash: int,
                               isInitial: bool, shocks: List[int]): (int, int, int) = {
    val span = scenarioSpan(base, perp, spot, perpPriceIn, stable, shocks)
    val afterStatic = span._1 - staticContingency(base, perp, spot, PERP_PERCENT, BASE_PERCENT)
    val adjusted =
      if (isInitial) multiplyDecimal(afterStatic, IM_FACTOR) - CONFIDENCE_CONTINGENCY
      else afterStatic
    val totalMtM = shockedBaseValue(base, spot, stable, UNIT) + perpValueIn
    (adjusted + totalMtM + cash, totalMtM + cash, span._2)
  }

  pure def marginOf(r: (int, int, int)): int = r._1
  pure def mtmOf(r: (int, int, int)): int = r._2
  pure def worstOf(r: (int, int, int)): int = r._3

  /// PMRM._assessRisk, :220-234.  A trusted risk assessor is checked on MM over
  /// the three basis-contingency scenarios; everyone else on IM over the full
  /// array.  Both arms are the same fold over different ordered lists, so the
  /// returned index differs between them for the same portfolio — t0_27 against
  /// t0_30.
  pure def assessRisk(base: int, perp: int, spot: int, perpPriceIn: int,
                      perpValueIn: int, cash: int, trusted: bool): bool =
    if (trusted)
      marginOf(worstScenarioMargin(base, perp, spot, perpPriceIn, STABLE_PRICE,
                                   perpValueIn, cash, false, BASIS_SHOCKS)) >= 0
    else
      marginOf(worstScenarioMargin(base, perp, spot, perpPriceIn, STABLE_PRICE,
                                   perpValueIn, cash, true, SPOT_SHOCKS)) >= 0

  /// THE ARITY HALF of the argmin, exposed so the ghost can record it.
  /// `_assessRisk` folds `marginScenarios` (5) for an ordinary caller and
  /// `getBasisContingencyScenarios()` (3) for a trusted one; the auction folds a
  /// one-element array (PMRM.sol:473-477).  The count is on-chain: it is
  /// `marginScenarios.length`, which `setScenarios` writes and :97 requires to
  /// be non-zero, selected by `trustedRiskAssessor[caller]`, which is storage.
  pure def riskArity(trusted: bool): int =
    if (trusted) BASIS_SHOCKS.length() else SPOT_SHOCKS.length()

  /// The index that same read returned — the contract's third return value,
  /// which `DutchAuction` stores as `auctions[].scenarioId`.
  pure def riskIndex(base: int, perp: int, spot: int, perpPriceIn: int,
                     perpValueIn: int, cash: int, trusted: bool): int =
    if (trusted)
      worstOf(worstScenarioMargin(base, perp, spot, perpPriceIn, STABLE_PRICE,
                                  perpValueIn, cash, false, BASIS_SHOCKS))
    else
      worstOf(worstScenarioMargin(base, perp, spot, perpPriceIn, STABLE_PRICE,
                                  perpValueIn, cash, true, SPOT_SHOCKS))

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).  Exact (input, output) pairs replayed
  //  from the cited Solidity line in integer arithmetic.  The rows marked [A.9]
  //  are P2-CONTRACT §A.9 verbatim and reproduce exactly.  The rows marked [IDX]
  //  are the ones no per-unit constant can satisfy, decorated or not.
  // ===========================================================================

  // -- _getBaseValue (PMRMLib.sol:220-226) ------------------------------------
  pure val t0_01: bool = shockedBaseValue(200, 10000, 100, 100) == 20000
  pure val t0_02: bool = shockedBaseValue(200, 10000, 100, 80) == 16000
  pure val t0_03: bool = shockedBaseValue(0, 10000, 100, 80) == 0
  pure val t0_04: bool = shockedBaseValue(100, 10000, 99, 100) == 10101

  // -- _getShockedPerpValue (PMRMLib.sol:212-218) -----------------------------
  pure val t0_05: bool = shockedPerpValue(-300, 10000, 80) == 6000
  pure val t0_06: bool = shockedPerpValue(-300, 10000, 120) == -6000
  pure val t0_07: bool = shockedPerpValue(-300, 10000, 100) == 0
  pure val t0_08: bool = shockedPerpValue(0, 10000, 80) == 0
  pure val t0_09: bool = shockedPerpValue(150, 9999, 110) == 1498
  pure val t0_10: bool = shockedPerpValue(-150, 9999, 110) == -1498

  // -- getScenarioMtM (PMRMLib.sol:130-166), the §A.9 vectors ------------------
  pure val t0_11: bool = scenarioMtM(200, -300, 10000, 10000, 100, 80) == 2000
  pure val t0_12: bool = scenarioMtM(200, -300, 10000, 10000, 100, 90) == 1000
  pure val t0_13: bool = scenarioMtM(200, -300, 10000, 10000, 100, 100) == 0
  pure val t0_14: bool = scenarioMtM(200, -300, 10000, 10000, 100, 110) == -1000
  pure val t0_15: bool = scenarioMtM(200, -300, 10000, 10000, 100, 120) == -2000
  pure val t0_16: bool = scenarioMtM(200, 0, 10000, 10000, 100, 80) == -4000
  pure val t0_17: bool = scenarioMtM(0, -300, 10000, 10000, 100, 80) == 6000

  // -- staticContingency (PMRMLib.sol:239-240), both sides of its parameters ---
  pure val t0_18: bool = staticContingency(200, -300, 10000, 0, 0) == 0
  pure val t0_19: bool = staticContingency(200, -300, 10000, 5, 10) == 3500

  // -- _getUnrealizedPnl (PerpAsset.sol:446-450) ------------------------------
  pure val t0_20: bool = perpUnrealizedPnl(-300, 12000, 10000) == -6000
  pure val t0_21: bool = perpUnrealizedPnl(-300, 8000, 10000) == 6000
  pure val t0_22: bool = perpUnrealizedPnl(0, 12000, 10000) == 0
  pure val t0_23: bool = perpUnrealizedPnl(150, 10001, 10000) == 1
  pure val t0_24: bool = perpUnrealizedPnl(-150, 10001, 10000) == -1

  // -- scenarioSpan (PMRMLib.sol:99-111) — THE ARGMIN -------------------------
  pure val t0_25: bool =
    scenarioSpan(200, -300, 10000, 10000, 100, SPOT_SHOCKS) == (-2000, 4)
  pure val t0_26: bool =
    scenarioSpan(200, 0, 10000, 10000, 100, SPOT_SHOCKS) == (-4000, 0)
  pure val t0_27: bool =
    scenarioSpan(0, -300, 10000, 10000, 100, SPOT_SHOCKS) == (-6000, 4)
  pure val t0_28: bool =
    scenarioSpan(0, 0, 10000, 10000, 100, SPOT_SHOCKS) == (0, 5)
  pure val t0_29: bool =
    scenarioSpan(100, -100, 10000, 10000, 100, SPOT_SHOCKS) == (0, 5)
  pure val t0_30: bool =
    scenarioSpan(0, -300, 10000, 10000, 100, BASIS_SHOCKS) == (-6000, 0)
  pure val t0_31: bool =
    scenarioSpan(0, 300, 10000, 10000, 100, BASIS_SHOCKS) == (-6000, 1)
  pure val t0_32: bool =
    scenarioSpan(0, 300, 10000, 10000, 100, SPOT_SHOCKS) == (-6000, 0)

  /// [IDX] The separation, stated as an equality and a disequality at once:
  /// two portfolios with the SAME total exposure and the SAME span, whose worst
  /// scenarios are 4 and 0.  Every per-unit constant — decorated with a
  /// per-scenario factor or not — reads only |base| + |perp| and therefore
  /// returns the same pair twice.  This single vector is the deletion.
  pure val t0_33: bool = and {
    scenarioSpan(0, -300, 10000, 10000, 100, SPOT_SHOCKS)._1
      == scenarioSpan(0, 300, 10000, 10000, 100, SPOT_SHOCKS)._1,
    scenarioSpan(0, -300, 10000, 10000, 100, SPOT_SHOCKS)._2
      != scenarioSpan(0, 300, 10000, 10000, 100, SPOT_SHOCKS)._2,
  }

  // -- worstScenarioMargin (PMRMLib.sol:92-127) -------------------------------
  pure val t0_34: bool =
    worstScenarioMargin(0, -300, 10000, 10000, 100, 0, 10000, false, SPOT_SHOCKS)
      == (4000, 10000, 4)
  pure val t0_35: bool =
    worstScenarioMargin(0, -300, 10000, 10000, 100, 0, 10000, true, SPOT_SHOCKS)
      == (2200, 10000, 4)
  pure val t0_36: bool =
    worstScenarioMargin(0, -300, 10000, 12000, 100, -6000, 10000, false, SPOT_SHOCKS)
      == (-3200, 4000, 4)
  pure val t0_37: bool =
    worstScenarioMargin(0, -300, 10000, 12000, 100, -6000, 10000, false, [120])
      == (-3200, 4000, 0)
  pure val t0_38: bool =
    worstScenarioMargin(0, -300, 10000, 12000, 100, -6000, 10000, false, [80])
      == (4000, 4000, 1)

  // -- _assessRisk (PMRM.sol:220-234), both arms ------------------------------
  // t0_40 and t0_41 are the SAME portfolio at the SAME cash: the untrusted arm
  // refuses it and the trusted arm admits it, because the first applies the IM
  // factor over five scenarios and the second applies none over three.
  pure val t0_39: bool = assessRisk(0, -300, 10000, 10000, 0, 8000, false)
  pure val t0_40: bool = not(assessRisk(0, -300, 10000, 10000, 0, 7000, false))
  pure val t0_41: bool = assessRisk(0, -300, 10000, 10000, 0, 7000, true)
  pure val t0_42: bool = not(assessRisk(0, -300, 10000, 10000, 0, 5000, true))

  pure val inv_T0: bool = and {
    t0_01, t0_02, t0_03, t0_04, t0_05, t0_06, t0_07, t0_08, t0_09, t0_10,
    t0_11, t0_12, t0_13, t0_14, t0_15, t0_16, t0_17, t0_18, t0_19, t0_20,
    t0_21, t0_22, t0_23, t0_24, t0_25, t0_26, t0_27, t0_28, t0_29, t0_30,
    t0_31, t0_32, t0_33, t0_34, t0_35, t0_36, t0_37, t0_38, t0_39, t0_40,
    t0_41, t0_42,
  }

  // ===========================================================================
  //  STATE-LEVEL VIEWS.  These are the contract's own view functions; they read
  //  `var`s and are used by the guards, the invariants and the witnesses.
  // ===========================================================================

  /// PerpAsset.getUnsettledAndUnrealizedCash (:243-251), funding dropped.
  def perpValueOf(u: str): int =
    perpUnrealizedPnl(perpOf.get(u), perpPrice, lastMarkOf.get(u))

  /// PMRM.getMarginAndMarkToMarket(accountId, isInitial, marginScenarios).
  def marginResultOf(u: str, isInitial: bool): (int, int, int) =
    worstScenarioMargin(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                        STABLE_PRICE, perpValueOf(u), cashOf.get(u),
                        isInitial, SPOT_SHOCKS)

  /// PMRM.getMarginAndMarkToMarket(accountId, isInitial, scenarioId), :467-478 —
  /// the SINGLE-scenario form, which is what the auction reads.
  def singleScenarioMargin(u: str, sid: int): (int, int, int) =
    worstScenarioMargin(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                        STABLE_PRICE, perpValueOf(u), cashOf.get(u),
                        false, [SPOT_SHOCKS.nth(sid)])

  def exposureOf(u: str): int = absInt(baseOf.get(u)) + absInt(perpOf.get(u))

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    cashOf' = ACCOUNTS.mapBy(_ => INIT_CASH),
    baseOf' = ACCOUNTS.mapBy(_ => INIT_BASE),
    perpOf' = ACCOUNTS.mapBy(_ => INIT_PERP),
    lastMarkOf' = ACCOUNTS.mapBy(_ => INIT_PERP_PRICE),
    spotPrice' = INIT_SPOT,
    perpPrice' = INIT_PERP_PRICE,
    cashSupply' = INIT_CASH_SUPPLY,
    baseSupply' = INIT_BASE_SUPPLY,
    trustedOf' = ACCOUNTS.mapBy(_ => INIT_TRUSTED),
    auctionOngoing' = ACCOUNTS.mapBy(_ => INIT_AUCTION),
    auctionScenario' = ACCOUNTS.mapBy(_ => INIT_SCENARIO),
    auctionCachedMM' = ACCOUNTS.mapBy(_ => INIT_CACHED_MM),
    lastArgminArity' = INIT_ARITY,
    lastArgminIndex' = INIT_ARGMIN_INDEX,
    lastOp' = OP_INIT,
  }

  /// CashAsset.deposit (:155).  Every asset delta is positive, so `riskAdding`
  /// stays false and `handleAdjustment` returns at :210-212 without calling
  /// `_assessRisk`.  That early exit is why an underwater account can still be
  /// topped up; it is a branch, and t0_40 is its other side.
  action depositCash(u: str, amt: int): bool = all {
    ACCOUNTS.contains(u),
    amt > 0,
    not(auctionOngoing.get(u)),
    cashOf' = cashOf.put(u, cashOf.get(u) + amt),
    cashSupply' = cashSupply + amt,
    baseOf' = baseOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    perpPrice' = perpPrice,
    baseSupply' = baseSupply,
    trustedOf' = trustedOf,
    auctionOngoing' = auctionOngoing,
    auctionScenario' = auctionScenario,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = 0,
    lastArgminIndex' = 0,
    lastOp' = OP_DEP_CASH,
  }

  /// CashAsset.withdraw (:203).  A negative cash delta is risk-adding
  /// (PMRM.sol:195-197), so the argmin runs and the withdrawal is refused unless
  /// the worst scenario still leaves the account solvent.
  action withdrawCash(u: str, amt: int): bool = all {
    ACCOUNTS.contains(u),
    amt > 0,
    cashOf.get(u) >= amt,
    not(auctionOngoing.get(u)),
    assessRisk(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
               perpValueOf(u), cashOf.get(u) - amt, trustedOf.get(u)),
    cashOf' = cashOf.put(u, cashOf.get(u) - amt),
    cashSupply' = cashSupply - amt,
    baseOf' = baseOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    perpPrice' = perpPrice,
    baseSupply' = baseSupply,
    trustedOf' = trustedOf,
    auctionOngoing' = auctionOngoing,
    auctionScenario' = auctionScenario,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = riskArity(trustedOf.get(u)),
    lastArgminIndex' = riskIndex(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                                 perpValueOf(u), cashOf.get(u) - amt,
                                 trustedOf.get(u)),
    lastOp' = OP_WD_CASH,
  }

  /// WrappedERC20Asset.deposit.  Positive delta, so no risk check (:210-212).
  action depositBase(u: str, amt: int): bool = all {
    ACCOUNTS.contains(u),
    amt > 0,
    not(auctionOngoing.get(u)),
    baseOf' = baseOf.put(u, baseOf.get(u) + amt),
    baseSupply' = baseSupply + amt,
    cashOf' = cashOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    perpPrice' = perpPrice,
    cashSupply' = cashSupply,
    trustedOf' = trustedOf,
    auctionOngoing' = auctionOngoing,
    auctionScenario' = auctionScenario,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = 0,
    lastArgminIndex' = 0,
    lastOp' = OP_DEP_BASE,
  }

  /// WrappedERC20Asset.withdraw.  Negative delta, so the argmin runs.
  action withdrawBase(u: str, amt: int): bool = all {
    ACCOUNTS.contains(u),
    amt > 0,
    baseOf.get(u) >= amt,
    not(auctionOngoing.get(u)),
    assessRisk(baseOf.get(u) - amt, perpOf.get(u), spotPrice, perpPrice,
               perpValueOf(u), cashOf.get(u), trustedOf.get(u)),
    baseOf' = baseOf.put(u, baseOf.get(u) - amt),
    baseSupply' = baseSupply - amt,
    cashOf' = cashOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    perpPrice' = perpPrice,
    cashSupply' = cashSupply,
    trustedOf' = trustedOf,
    auctionOngoing' = auctionOngoing,
    auctionScenario' = auctionScenario,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = riskArity(trustedOf.get(u)),
    lastArgminIndex' = riskIndex(baseOf.get(u) - amt, perpOf.get(u), spotPrice, perpPrice,
                                 perpValueOf(u), cashOf.get(u),
                                 trustedOf.get(u)),
    lastOp' = OP_WD_BASE,
  }

  /// A perp transfer between two subaccounts.  PMRM.sol:186-188 settles the
  /// realised PnL of BOTH sides into cash first and stamps `lastMarkPrice`
  /// (PerpAsset.sol:296-303), then the risk gate runs on both post-trade
  /// portfolios.  The two legs are equal and opposite, which is what makes the
  /// T0-LIVE state reachable in ONE step.
  action tradePerp(buyer: str, seller: str, qty: int): bool = all {
    ACCOUNTS.contains(buyer),
    ACCOUNTS.contains(seller),
    buyer != seller,
    qty > 0,
    not(auctionOngoing.get(buyer)),
    not(auctionOngoing.get(seller)),
    val pnlB = perpValueOf(buyer)
    val pnlS = perpValueOf(seller)
    val cashB = cashOf.get(buyer) + pnlB
    val cashS = cashOf.get(seller) + pnlS
    val posB = perpOf.get(buyer) + qty
    val posS = perpOf.get(seller) - qty
    all {
      assessRisk(baseOf.get(buyer), posB, spotPrice, perpPrice, 0, cashB,
                 trustedOf.get(buyer)),
      assessRisk(baseOf.get(seller), posS, spotPrice, perpPrice, 0, cashS,
                 trustedOf.get(seller)),
      cashOf' = cashOf.put(buyer, cashB).put(seller, cashS),
      perpOf' = perpOf.put(buyer, posB).put(seller, posS),
      lastMarkOf' = lastMarkOf.put(buyer, perpPrice).put(seller, perpPrice),
      cashSupply' = cashSupply + pnlB + pnlS,
      baseOf' = baseOf,
      spotPrice' = spotPrice,
      perpPrice' = perpPrice,
      baseSupply' = baseSupply,
      trustedOf' = trustedOf,
      auctionOngoing' = auctionOngoing,
      auctionScenario' = auctionScenario,
      auctionCachedMM' = auctionCachedMM,
      lastArgminArity' = riskArity(trustedOf.get(seller)),
      lastArgminIndex' = riskIndex(baseOf.get(seller), posS, spotPrice, perpPrice,
                                   0, cashS, trustedOf.get(seller)),
      lastOp' = OP_TRADE_PERP,
    }
  }

  /// The spot feed (PMRM.sol:459-463).  An external-call return; foot(Q) is
  /// empty, exactly the oracle case 6g permits.
  action updateSpot(px: int): bool = all {
    px > 0,
    px != spotPrice,
    spotPrice' = px,
    cashOf' = cashOf,
    baseOf' = baseOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    perpPrice' = perpPrice,
    cashSupply' = cashSupply,
    baseSupply' = baseSupply,
    trustedOf' = trustedOf,
    auctionOngoing' = auctionOngoing,
    auctionScenario' = auctionScenario,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = 0,
    lastArgminIndex' = 0,
    lastOp' = OP_SPOT,
  }

  /// The perp mark feed.  Moves every open position's unrealised PnL and every
  /// scenario's perp leg at once, which is what turns a solvent account into a
  /// liquidatable one without anybody trading.
  action updatePerpPrice(px: int): bool = all {
    px > 0,
    px != perpPrice,
    perpPrice' = px,
    cashOf' = cashOf,
    baseOf' = baseOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    cashSupply' = cashSupply,
    baseSupply' = baseSupply,
    trustedOf' = trustedOf,
    auctionOngoing' = auctionOngoing,
    auctionScenario' = auctionScenario,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = 0,
    lastArgminIndex' = 0,
    lastOp' = OP_PERP_PX,
  }

  /// PMRM.setTrustedRiskAssessor — the owner switch that selects which arm of
  /// `_assessRisk` (:224-232) a caller gets, hence which scenario array the
  /// argmin folds and whether the IM factor is applied at all.
  action setTrustedRiskAssessor(u: str, flag: bool): bool = all {
    ACCOUNTS.contains(u),
    flag != trustedOf.get(u),
    trustedOf' = trustedOf.put(u, flag),
    cashOf' = cashOf,
    baseOf' = baseOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    perpPrice' = perpPrice,
    cashSupply' = cashSupply,
    baseSupply' = baseSupply,
    auctionOngoing' = auctionOngoing,
    auctionScenario' = auctionScenario,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = 0,
    lastArgminIndex' = 0,
    lastOp' = OP_TRUST,
  }

  /// DutchAuction.startAuction (:148-183).  `external`, no access control: any
  /// caller flags any account and supplies the scenario index they claim makes
  /// it insolvent; the contract verifies with its own margin read at :163 and
  /// refuses at :166 unless MM < 0.  The verified result is STORED — this is
  /// the write that makes the argmin's output an observable rather than a view.
  action startAuction(target: str, sid: int): bool = all {
    ACCOUNTS.contains(target),
    SCENARIO_IDS.contains(sid),
    not(auctionOngoing.get(target)),
    marginOf(singleScenarioMargin(target, sid)) < 0,
    auctionOngoing' = auctionOngoing.put(target, true),
    auctionScenario' = auctionScenario.put(target, sid),
    auctionCachedMM' = auctionCachedMM.put(target, -marginOf(singleScenarioMargin(target, sid))),
    cashOf' = cashOf,
    baseOf' = baseOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    perpPrice' = perpPrice,
    cashSupply' = cashSupply,
    baseSupply' = baseSupply,
    trustedOf' = trustedOf,
    lastArgminArity' = 1,
    lastArgminIndex' = worstOf(singleScenarioMargin(target, sid)),
    lastOp' = OP_AUCTION,
  }

  /// DutchAuction.updateScenarioId (:232-240) — the argmin run by the market.
  /// "anyone can come in during the auction to supply a scenarioId that will
  /// make the IM worse", and the contract accepts it only if it is STRICTLY
  /// worse than the one already stored.  The stored index therefore descends
  /// toward `worstScenario` under the same `<` the fold uses.
  action updateScenarioId(target: str, sid: int): bool = all {
    ACCOUNTS.contains(target),
    SCENARIO_IDS.contains(sid),
    auctionOngoing.get(target),
    marginOf(singleScenarioMargin(target, sid))
      < marginOf(singleScenarioMargin(target, auctionScenario.get(target))),
    auctionScenario' = auctionScenario.put(target, sid),
    cashOf' = cashOf,
    baseOf' = baseOf,
    perpOf' = perpOf,
    lastMarkOf' = lastMarkOf,
    spotPrice' = spotPrice,
    perpPrice' = perpPrice,
    cashSupply' = cashSupply,
    baseSupply' = baseSupply,
    trustedOf' = trustedOf,
    auctionOngoing' = auctionOngoing,
    auctionCachedMM' = auctionCachedMM,
    lastArgminArity' = 1,
    lastArgminIndex' = worstOf(singleScenarioMargin(target, sid)),
    lastOp' = OP_RESCEN,
  }

  /// Convention 6 / 6g: every `nondet` is exogenous — a caller identity, an
  /// amount the caller chose, an oracle return, or a scenario index a liquidator
  /// supplies and the contract then verifies.  The protocol selects nothing here
  /// that the driver is told; in particular `worstScenario` is never drawn.
  action step: bool = {
    nondet u = ACCOUNTS.oneOf()
    nondet v = ACCOUNTS.oneOf()
    nondet amt = CASH_AMOUNTS.oneOf()
    nondet baseAmt = BASE_AMOUNTS.oneOf()
    nondet qty = PERP_QTYS.oneOf()
    nondet px = FEED_PRICES.oneOf()
    nondet sid = SCENARIO_IDS.oneOf()
    nondet flag = TRUST_FLAGS.oneOf()
    any {
      depositCash(u, amt),
      withdrawCash(u, amt),
      depositBase(u, baseAmt),
      withdrawBase(u, baseAmt),
      tradePerp(u, v, qty),
      updateSpot(px),
      updatePerpPrice(px),
      setTrustedRiskAssessor(u, flag),
      startAuction(u, sid),
      updateScenarioId(u, sid),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).  All must hold at every reachable state.
  // ===========================================================================

  /// CONSERVATION — CashAsset.totalSupply is the sum of the subaccount cash
  /// balances.  Deposits and withdrawals mint and burn it; perp settlement moves
  /// it between accounts and against the PnL pool.  This is the T2 invariant.
  val inv_conservation: bool =
    ACCOUNTS.fold(0, (acc, u) => acc + cashOf.get(u)) == cashSupply

  val inv_baseConservation: bool =
    ACCOUNTS.fold(0, (acc, u) => acc + baseOf.get(u)) == baseSupply

  /// Perps are zero sum: every contract has a long and a short.  Nothing in the
  /// modelled actions can break it, which is exactly why it is worth asserting —
  /// it is the structural fact `tradePerp` must not violate.
  val inv_perpZeroSum: bool =
    ACCOUNTS.fold(0, (acc, u) => acc + perpOf.get(u)) == 0

  val inv_bounds: bool = and {
    spotPrice > 0,
    perpPrice > 0,
    baseSupply >= 0,
    ACCOUNTS.forall(u => baseOf.get(u) >= 0),
    ACCOUNTS.forall(u => lastMarkOf.get(u) > 0),
    ACCOUNTS.forall(u => auctionCachedMM.get(u) >= 0),
    ACCOUNTS.forall(u => SCENARIO_IDS.contains(auctionScenario.get(u))),
  }

  /// T3 for this protocol (P2-SCOPE §5 row 9), stated exactly as specified:
  /// every scenario's MtM is at least the span, and some scenario attains it —
  /// unless the seed won, in which case the index is the sentinel and the span
  /// is `basisContingency`.
  /// HONEST NOTE, and it is the whole reason this file also ships T0 and the
  /// witnesses: this is a SHAPE property.  Any fold-min satisfies it, including
  /// the decorated constant M1'.  It is necessary and it is nowhere near
  /// sufficient.  The discriminating checks are t0_25/t0_27/t0_33 and
  /// `wit_splitSensitiveArgmin`.
  val inv_marginIsMin: bool =
    ACCOUNTS.forall(u => {
      val span = scenarioSpan(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                              STABLE_PRICE, SPOT_SHOCKS)
      and {
        SPOT_SHOCKS.indices().forall(i =>
          scenarioMtM(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                      STABLE_PRICE, SPOT_SHOCKS.nth(i)) >= span._1),
        if (span._2 == SPOT_SHOCKS.length())
          span._1 == BASIS_CONTINGENCY
        else and {
          scenarioMtM(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                      STABLE_PRICE, SPOT_SHOCKS.nth(span._2)) == span._1,
          span._1 < BASIS_CONTINGENCY,
        },
      }
    })

  /// The index the fold returns is the FIRST attaining position, because the
  /// comparison at :107 is strict.  False for any fold that keeps the last
  /// minimum, and unstatable at all for a mechanism with no index.
  /// Conditioned on the index having moved: when the SEED wins, `worstScenario`
  /// is `scenarios.length` and every earlier scenario merely ties the seed
  /// rather than exceeding it, which `inv_marginIsMin` covers instead.
  val inv_worstIsFirst: bool =
    ACCOUNTS.forall(u => {
      val span = scenarioSpan(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                              STABLE_PRICE, SPOT_SHOCKS)
      (span._2 < SPOT_SHOCKS.length()) implies
        SPOT_SHOCKS.indices().forall(i =>
          (i < span._2) implies
            scenarioMtM(baseOf.get(u), perpOf.get(u), spotPrice, perpPrice,
                        STABLE_PRICE, SPOT_SHOCKS.nth(i)) > span._1)
    })

  /// DutchAuction.sol:166 and :210-211 — an ongoing auction carries the
  /// magnitude of the strictly negative maintenance margin that started it.
  /// This is the invariant that reads the argmin's output back out of storage.
  /// It is stated on `cachedMM` and NOT as "the account is still underwater",
  /// because `terminateAuction` is ABSTRACTED: in the contract an auction also
  /// survives a recovery until somebody terminates it, so the recomputed margin
  /// at the stored scenario may legitimately be non-negative later.
  val inv_auctionUnderwater: bool =
    ACCOUNTS.forall(u => auctionOngoing.get(u) implies auctionCachedMM.get(u) > 0)

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_baseConservation,
    inv_perpZeroSum,
    inv_bounds,
    inv_marginIsMin,
    inv_worstIsFirst,
    inv_auctionUnderwater,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (P2-CONTRACT §D, the fifth trap).
  //  Each of these must be VIOLATED by `quint run --invariant=<name>`.  A
  //  violation is a trace; the trace is the proof the definition ran on the
  //  declared domain.  A `pure def` cited only by `pure val` equalities is a
  //  deleted mechanism carrying a certificate.
  // ===========================================================================

  /// T0-LIVE.  Two accounts, equal total exposure, equal margin, DIFFERENT
  /// worst scenario.  Reached in one `tradePerp` from `init`, because the legs
  /// of a trade are equal and opposite.  Under M1 there is no index to differ;
  /// under M1', M3 and M4 the index is a function of |exposure| alone and the
  /// two accounts return the same one, so this state is unreachable.  This is
  /// the vector P2-CONTRACT §D calls `worstScenario = 4` then `= 0`, collapsed
  /// into a single state so that one trace carries both halves.
  val wit_splitSensitiveArgmin: bool =
    not(ACCOUNTS.exists(u => ACCOUNTS.exists(v => and {
      exposureOf(u) > 0,
      exposureOf(u) == exposureOf(v),
      marginOf(marginResultOf(u, false)) == marginOf(marginResultOf(v, false)),
      worstOf(marginResultOf(u, false)) != worstOf(marginResultOf(v, false)),
    })))

  /// P2-SCOPE §5 row 9's own witness: `worstScenario` is always index 0.
  /// Restricted to accounts that actually hold risk, so that the sentinel on a
  /// flat account cannot discharge it for free at `init`.
  val wit_nonTrivialArgmin: bool =
    ACCOUNTS.forall(u =>
      exposureOf(u) == 0 or worstOf(marginResultOf(u, false)) == 0)

  /// `worstScenarioMargin` ran and its result was WRITTEN INTO A VAR: the
  /// auction stores the magnitude of the maintenance margin it computed.  No
  /// other writer of `auctionCachedMM` exists.
  /// LIVENESS ONLY.  Measured against mutants/derive_M1prime.qnt this witness
  /// is violated there too — the decorated constant also produces a negative
  /// margin and also gets stored.  It discharges the fifth trap and it does not
  /// discriminate; `wit_splitSensitiveArgmin` is what discriminates.
  val wit_used_worstScenarioMargin: bool =
    ACCOUNTS.forall(u => auctionCachedMM.get(u) == 0)

  /// `scenarioSpan`'s SEED branch — the sentinel survives, so the fold never
  /// took its `if`.  6f's other side of `m < basisContingency`.
  val wit_branch_sentinel: bool =
    ACCOUNTS.forall(u => worstOf(marginResultOf(u, false)) != SPOT_SHOCKS.length())

  /// `shockedPerpValue` ran on a non-zero position AND the truncation was
  /// load-bearing: an account whose perp leg is short and whose worst scenario
  /// is therefore the last, not the first.
  val wit_used_shockedPerpValue: bool =
    not(ACCOUNTS.exists(u => and {
      perpOf.get(u) < 0,
      worstOf(marginResultOf(u, false)) == SPOT_SHOCKS.length() - 1,
    }))

  /// `shockedBaseValue` ran on a non-zero position: base is held and it moves
  /// the mark-to-market away from cash.
  val wit_used_shockedBaseValue: bool =
    not(ACCOUNTS.exists(u => and {
      baseOf.get(u) > 0,
      mtmOf(marginResultOf(u, false)) != cashOf.get(u),
    }))

  /// `perpUnrealizedPnl` ran and was SETTLED INTO CASH: the total cash supply
  /// has moved without a deposit or a withdrawal being able to explain it,
  /// which only PerpAsset settlement can do.
  val wit_used_perpUnrealizedPnl: bool =
    ACCOUNTS.forall(u => cashOf.get(u) % CASH_GRANULARITY == 0)

  /// `assessRisk` refused something: an account sits at a margin its own next
  /// withdrawal could not clear.  The IM arm is strictly tighter than the MM
  /// arm, so a state where IM < 0 <= MM is one the trusted arm would have
  /// allowed and the untrusted arm would not.
  val wit_used_assessRisk: bool =
    not(ACCOUNTS.exists(u => and {
      marginOf(marginResultOf(u, true)) < 0,
      marginOf(marginResultOf(u, false)) >= 0,
    }))

  /// The trusted arm of `_assessRisk` (:224-227) actually ran: some account is
  /// flagged and holds risk.
  val wit_branch_trusted: bool =
    not(ACCOUNTS.exists(u => trustedOf.get(u) and perpOf.get(u) != 0))

  /// THE ARITY HALF OF THE ARGMIN.  `wit_splitSensitiveArgmin` shows that the
  /// WINNER depends on the portfolio; this shows that the winner was chosen by
  /// comparing against the WHOLE array in ONE evaluation.  A margin read that
  /// folded five scenarios and returned the LAST index cannot be reproduced by
  /// any mechanism that scores one scenario at a time, and it cannot be
  /// reproduced by a sign-blind per-unit charge, whose minimum is attained at
  /// both ends and whose first-wins index is therefore always 0.
  /// This is the obligation the liquity/polymarket lane's mid-flight finding
  /// asks for: for a selection-shaped deletion the discriminating observable is
  /// the ARITY of the selection, not the resulting value.  Measured: violated
  /// here, [ok] under mutants/derive_M1prime.qnt.
  val wit_arity_fullScan: bool =
    not(and {
      lastArgminArity == SPOT_SHOCKS.length(),
      lastArgminIndex == SPOT_SHOCKS.length() - 1,
    })

  /// The trusted arm's arity, and the fact that the BASIS array's ORDER is
  /// load-bearing: index 1 is `scenarioSpotDown`, which is second in
  /// `getBasisContingencyScenarios` (:378-380) and would be first in any
  /// ascending list.  Three scenarios compared, the second one chosen.
  val wit_arity_basisScan: bool =
    not(and { lastArgminArity == BASIS_SHOCKS.length(), lastArgminIndex == 1 })

  /// The auction's single-scenario arity (PMRM.sol:473-477) — a one-element
  /// array, which is the other end of the same `scenarios.length` range and the
  /// reason `worstScenario` can legitimately be 0 with nothing compared.
  val wit_arity_singleScenario: bool = lastArgminArity != 1

  // -- convention 6d: enabledness of every action is witnessed, never assumed --

  val wit_fired_depositCash: bool = lastOp != OP_DEP_CASH
  val wit_fired_withdrawCash: bool = lastOp != OP_WD_CASH
  val wit_fired_depositBase: bool = lastOp != OP_DEP_BASE
  val wit_fired_withdrawBase: bool = lastOp != OP_WD_BASE
  val wit_fired_tradePerp: bool = lastOp != OP_TRADE_PERP
  val wit_fired_updateSpot: bool = lastOp != OP_SPOT
  val wit_fired_updatePerpPrice: bool = lastOp != OP_PERP_PX
  val wit_fired_setTrusted: bool = lastOp != OP_TRUST
  val wit_fired_startAuction: bool = lastOp != OP_AUCTION
  val wit_fired_updateScenarioId: bool = lastOp != OP_RESCEN
}
