// =============================================================================
//  polymarket — Phase 2 re-spec (W3).  Replaces quint-models/L6/polymarket.qnt.
//
//  SOURCE:  (hole H4 — the coverage table must name BOTH contracts)
//    protocol-repos/pred/Polymarket_ctf-exchange-v2/src/exchange/mixins/Trading.sol
//      :277-296   _matchOrders — _isAllComplementary early path, then the
//                 BUY-taker and SELL-taker paths
//      :390-444   _settleMakerOrders — Phase 1 walks the maker array IN ORDER
//                 deriving a MatchType per position and accumulating
//                 totalMintAmount / totalMergeAmount; Phase 2 executes AT MOST
//                 ONE _mint and AT MOST ONE _merge; Phase 3 distributes
//      :405       matchType = _deriveMatchType(takerOrder, makerOrders[i])
//      :409-418   totalMintAmount += takingAmount  /  totalMergeAmount += makingAmount
//      :425-426   if (totalMintAmount > 0) _mint(...);  if (totalMergeAmount > 0) _merge(...)
//      :446-475   _prepareMakerOrder — the maker gives `fillAmount` of its maker
//                 asset and is owed `taking` of its taker asset
//      :548-570   _performOrderChecks -> _calculateTakingAndValidateFee
//      :577-590   _deriveMatchType — the assembly
//                   matchType := mul(add(takerSide,1), eq(takerSide,makerSide))
//                 Side.BUY = 0, Side.SELL = 1, so BUY/BUY = 1 = MINT,
//                 SELL/SELL = 2 = MERGE, disagreement = 0 = COMPLEMENTARY
//      :592-611   _isAllComplementary
//      :613-626   _deriveAssetIds — buy: (0, tokenId); sell: (tokenId, 0)
//      :640-676   _validateOrdersMatch — the three crossing conditions, verbatim
//      :330-335   require(balanceAfter >= taking + balanceBefore)  —
//                 TooLittleTokensReceived, the taker's own price honoured by the
//                 AGGREGATE of the maker prefix
//      :678-700   _updateOrderStatus — orderStatus[hash].remaining, real storage
//    .../src/exchange/libraries/CalculatorHelper.sol:5-11
//                 calculateTakingAmount = making * takerAmount / makerAmount
//    .../src/exchange/mixins/AssetOperations.sol:40-52
//                 _mint  -> ConditionalTokens.splitPosition(partition [1,2])
//                 _merge -> ConditionalTokens.mergePositions(partition [1,2])
//    protocol-repos/pred/Polymarket_uma-ctf-adapter/src/UmaCtfAdapter.sol
//                 initialize / resolve / getExpectedPayouts; payouts [1,0],
//                 [0,1], [1,1] with payoutDenominator = sum of numerators
//
//  MECHANISM:
//    A price is not an input.  A taker order carries (makerAmount, takerAmount)
//    and so does every maker order; the exchange walks the maker list IN ORDER,
//    derives MINT / MERGE / COMPLEMENTARY from whether the two sides AGREE,
//    computes each fill's `taking` from that maker's own ratio, accumulates the
//    same-side crossings into ONE totalMintAmount and ONE totalMergeAmount, and
//    settles them with a SINGLE CTF split or merge.  Same-side crossings are
//    therefore the settlement of a trade: two people who both want to BUY
//    opposite outcomes are matched by CREATING the pair out of their combined
//    collateral, not by transferring anything between them.  The taker's budget
//    is consumed across the maker prefix and cuts the walk off endogenously.
//
//  WHAT v1 DELETED (this file exists to restore it):
//    D-1  quint-models/L6/polymarket.qnt:75-97 `tradeYes(seller, buyer, yesAmt,
//         price)` — ONE counterparty, a bilateral transfer, and the price is
//         `:143 nondet price = 1.to(3).oneOf()`.  The whole of
//         _settleMakerOrders is gone: no maker list, no order, no match type, no
//         batching.  Restored as `matchOrders(taker)` over `var book`.
//    D-2  quint-models/L6/polymarket.qnt:40-67 `split` and `merge` exist, and
//         are ONLY ever standalone user actions.  They are never the settlement
//         of a trade, so the identity that connects the order book to the CTF —
//         "a BUY crossed against a BUY is a mint" — is severed even though both
//         halves are present.  Restored: `matchOrders` performs the split and
//         the merge, and `wit_mintSettlement` is a state that the standalone
//         `split` cannot produce.
//    D-3  The price being exogenous is NOT a 6g violation and it is worth
//         saying so.  P2-CARRYFORWARD's ten-way table, row 10: the order's
//         (makerAmount, takerAmount) is CALLDATA, so foot(Q) is empty and a
//         `nondet` price has matching parity.  6g is silent here.  The defect is
//         structural — the quantity is legitimately exogenous and the STRUCTURE
//         that turns two exogenous orders into one price is missing.  This is
//         the protocol in the ten where 6g and 6b both pass and the spec is
//         still wrong, which is why convention 6's "if the contract computes
//         WHICH, the spec computes WHICH" has to be about structure and not
//         only about identity.
//
//  PRESERVED (each is a guard or a value-flow observable in the contract):
//    the maker list as an ORDER, walked head-first; _deriveMatchType's exact
//    arithmetic including its Side encoding; all three _validateOrdersMatch
//    crossing conditions in cross-multiplied integer form; calculateTakingAmount
//    and its floor; the MINT accumulator taking `takingAmount` while the MERGE
//    accumulator takes `makingAmount` (they are not the same quantity);
//    at-most-one _mint and at-most-one _merge per match; orderStatus.remaining
//    as `filled`; the TooLittleTokensReceived guard on the aggregate; the CTF
//    binary partition [1,2]; UMA's three payout vectors and payoutDenominator.
//
//  ABSTRACTED (anything simplified and not listed here is a defect — conv. 9):
//    - the maker ARRAY is calldata in `_matchOrders`; the spec derives it as the
//      crossing sub-list of a resting book, walked head-first.  This is a
//      STRENGTHENING, not a relaxation: the contract accepts any crossing subset
//      in any order and the spec commits to one canonical choice (book order,
//      greedy under the taker's budget).  Every maker the spec includes is one
//      the contract's own `_validateOrdersMatch` would admit, because that guard
//      is applied per maker inside the walk, and every maker the spec skips is
//      one the operator would simply omit.  The cost is that outcomes the
//      contract permits under a different operator choice are unreachable here;
//      the benefit is that the price and the participant set are both endogenous,
//      which is the deletion under repair.
//    - `postOrder` is NOT an on-chain function.  Polymarket's CLOB is off-chain
//      and orders are signed messages; only `orderStatus` is storage.  The action
//      is the environment resting a signed order, exactly as `setPrice` is the
//      environment moving an oracle.  It is listed as an environment action in
//      COVERAGE, not as a contract function.
//    - EIP-712 hashing, signature validation, nonces, `UserPausable`, operator
//      roles and `cancelOrder`.  No state-changing guard in `_settleMakerOrders`
//      reads them except through `_validateOrder`, which is a pure admission
//      test on calldata the driver supplies anyway.
//    - fees.  `makerFeeAmounts` / `takerFeeAmount` are operator inputs, the fee
//      receiver is outside the conservation boundary, and every fee path in
//      Trading.sol is a subtraction applied AFTER the match type and the taking
//      amount are fixed.  Setting them to zero cannot move the order, the match
//      type or the batch totals.  (Contrast the pilot, where the 997/1000 IS the
//      mechanism; here it is not.)
//    - the taker order's own `orderStatus` is not persisted: a taker order is a
//      fresh calldata order at each match, and only the resting makers carry
//      `filled`.
//    - multi-outcome conditions.  The CTF partition is [1,2], one binary market.
//    - the UMA dispute window, bonds, `flagged` / `paused` questions and
//      `emergencyResolve`.  `resolveMarket` is the resolution event; the path to
//      it carries no arithmetic the matching mechanism reads.
//    - `_transfer`'s ERC20/ERC1155 reverts are folded into one solvency guard on
//      the post-walk balances.
//
//  GHOST:
//    `lastOp` is not contract state.  It is the trace label of the observation
//    interface (P2-FIDELITY §1), carrying what OrderFilled / OrdersMatched /
//    PositionSplit / PositionsMerge carry, which are droppable only because no
//    guard reads them.  In `matchOrders` it additionally records WHICH of the
//    three MatchType settlements the batch performed, so convention 6f's branch
//    coverage is witnessed at the level the contract branches at.  Read by
//    `wit_fired_*` / `wit_branch_*` and by nothing else; no guard and no
//    `pure def` reads it.  Exempt from 6e's write-only clause on that basis.
//
//  BOUNDS:  (convention 8a / 8b / 8c)
//    8a branching — 3 users; the book holds at most 5 orders (4 resting at init,
//       one postable).  Five `nondet`s per step: 3 / 3 / 3 / 2 / 3 enumerated
//       values, all <= 8.
//    8b magnitude — peak intermediate 1.5e4: `_validateOrdersMatch` multiplies
//       two order amounts, both <= 100 in the declared catalogue, and
//       `fillCap`'s numerator is `remaining * makerAmount` <= 60*50 = 3000.
//       P2-CONTRACT §C row 10 declares 4.0e4; the spec is inside it.  Far below
//       I64_MAX = 9.22e18.  This spec does not call `isqrtFloor`, so
//       PILOT-NOTES D-d's 4.611686e18 floor does not apply.
//    8c constant-crossing —
//       Side.BUY = 0 / Side.SELL = 1 and the three MatchType values: all three
//       are crossed at RUNTIME, not merely in vectors — `wit_branch_mint`,
//       `wit_branch_merge`, `wit_branch_complementary`.
//       The crossing conditions of `_validateOrdersMatch` are crossed on both
//       sides: t0_30 (a maker at 0.6 crosses a 0.6 taker, at equality) against
//       t0_31 (a maker at 0.8 does not), same book, same taker.
//       The taker budget against the makers' available size: the forward walk of
//       t0_10 stops with `remaining = 1` INSIDE maker 3, whose fill is 11 of 30;
//       the reversed walk of t0_11 stops with `remaining = 0`.
//       `payoutDenominator`: PAYOUTS holds [1,0] and [0,1] (denominator 1) and
//       [1,1] (denominator 2), so both sides of the divisor are in the domain.
//       Order exhaustion: `filled == makerAmount` (skip) against
//       `filled < makerAmount` (fill), both in the t0_13 / t0_14 walks.
//
//  INPUTS:  (convention 6g, dependency parity)
//    | name    | contract expression            | file:line | foot(Q) | spec vars read |
//    | taker   | matchOrders(Order takerOrder)  | Trading   | none    | book, cash, posYes, posNo (all four, in the walk) |
//    | o       | the signed maker order         | off-chain | none    | book (guard) |
//    | u       | msg.sender                     | CTF       | none    | cash / posYes / posNo (guard) |
//    | amount  | splitPosition(uint amount)     | CTF       | none    | cash (guard) |
//    | k       | UmaCtfAdapter payouts          | UMA       | none    | none (oracle) |
//    THE ROW THAT IS NOT HERE IS THE POINT.  v1 supplied a sixth quantity,
//    `price`, at :143.  Its contract expression is
//    `CalculatorHelper.calculateTakingAmount(making, order.makerAmount,
//    order.takerAmount)`, whose foot(Q) is EMPTY — the amounts are calldata.  So
//    6g does NOT reject it, and P2-CARRYFORWARD row 10 records that.  What
//    rejects it is convention 6 read structurally: the contract derives the
//    execution price from the ORDERS IT IS CROSSING, and a driver-supplied price
//    is not that derivation whatever its footprint.  `k` is a genuine
//    external-call return (UMA), foot(Q) = none: the oracle case 6g permits.
//
//  COVERAGE:  (convention 6e — every external state-changing function of BOTH
//              contracts; H4's obligation)
//    CTFExchange.matchOrders -> Trading._matchOrders  -> action matchOrders
//    Trading._settleMakerOrders / _prepareMakerOrder / _settleTakerOrder
//                                                    -> inside matchOrders
//    Trading._settleComplementary (the all-complementary early path)
//                                                    -> the MATCH_COMPLEMENTARY
//                                                       arm of the same walk
//    CTFExchange.cancelOrder / cancelOrders          -> ABSTRACTED (signatures)
//    CTFExchange.registerToken / pauseTrading / admin -> ABSTRACTED (roles)
//    AssetOperations._mint  -> CTF splitPosition     -> inside matchOrders
//    AssetOperations._merge -> CTF mergePositions    -> inside matchOrders
//    ConditionalTokens.splitPosition (direct)        -> action split
//    ConditionalTokens.mergePositions (direct)       -> action merge
//    ConditionalTokens.redeemPositions               -> action redeemPositions
//    UmaCtfAdapter.initialize                        -> ABSTRACTED (one market)
//    UmaCtfAdapter.resolve                           -> action resolveMarket
//    UmaCtfAdapter.dispute / flag / emergencyResolve -> ABSTRACTED (window)
//    (environment, not a contract function)          -> action postOrder
//    Storage read by a require on a state-changing path:
//      Trading.orderStatus[hash].remaining (:678-700) -> Order.filled in var book;
//      Trading.orderStatus[hash].filled               -> filled == makerAmount;
//      ERC20 collateral balances                      -> var cash;
//      ERC1155 outcome balances (:330-335)            -> var posYes, posNo;
//      CTF locked collateral                          -> var lockedCollateral;
//      UmaCtfAdapter question state / payouts         -> var phase, var payout.
//    No `var` is write-only: `book` is written by `postOrder` and `matchOrders`
//    and read by every walk; `payout` is read by `redeemPositions`.
//
//  UNITS:  (hole H2's obligation, applied here as a convention)
//    cash, lockedCollateral, CASH_TOTAL                     — collateral (USDC)
//    posYes, posNo                                          — outcome tokens
//    Order.makerAmount   — collateral if side == BUY, outcome tokens if SELL
//    Order.takerAmount   — outcome tokens if side == BUY, collateral if SELL
//    Order.filled        — same unit as that order's makerAmount
//    MatchAcc.remaining  — the TAKER's makerAmount unit
//    MatchAcc.mintTotal / mergeTotal — collateral, and simultaneously outcome
//                          tokens of BOTH ids: that identity is what a CTF
//                          split/merge IS, and it is why the two accumulators
//                          can be settled by one call each
//    MatchAcc.takerOut   — the TAKER's takerAmount unit
//    payout.yes / payout.no — dimensionless numerators over payoutDen
//
//  CONTRAST SET M (F0/F2, with R4's three mandatory members):
//    M0  matchTakerAgainstMakers — the ordered walk above            [target]
//    M1  the v1 body verbatim: `tradeYes(seller, buyer, yesAmt, price)` with
//        `nondet price = 1.to(3).oneOf()` (polymarket.qnt:75-97,143).
//        MANDATORY member 1.  Agreement with M0 over the declared taker
//        catalogue: 0/3.  M1 has no match type, so `totalMintAmount` is
//        identically 0 and `lockedCollateral` never moves during a trade; t0_10
//        and t0_13 both separate it, and `wit_mintSettlement` /
//        `wit_mergeSettlement` are unreachable under it.
//    M2  chaos: any transfer of tokens for collateral at any price that leaves
//        both parties non-negative.  MANDATORY member 2 — maximally permissive
//        in the same direction.  Killed by `inv_matchConserves`, whose
//        batchTotals-agreement clause pins the settlement to the accumulators.
//    M3  bilateral matching WITH a derived price but no batching: settle each
//        maker separately, one CTF call per same-side maker.  MANDATORY member 3
//        — the nearest neighbour, and the one that a careless re-spec would
//        actually write.  Agreement with M0 on final BALANCES: 3/3, because a
//        split of 40 followed by a split of 60 leaves the same balances as one
//        split of 100.  Agreement on the OBSERVABLE the contract commits to —
//        the number of CTF calls and the amount of each — 0/3.  Reported per the
//        pilot's R4 amendment.  This is the sharpest member of the set: it is
//        the one that no balance-level invariant can separate, and it is
//        separated by t0_10's `mintTotal == 100` read as "one call, of 100".
//    M4  a match type derived from TOKEN agreement rather than SIDE agreement —
//        the plausible misreading of `_deriveMatchType`, since the assembly
//        compares `takerOrderSide` to `makerOrderSide` in a function whose other
//        guard compares token ids.  Agreement 1/3 (it coincides on the
//        merge-only taker).  Killed by t0_18's four matchType vectors.
//    FINDING: R4's >= 90% clause is satisfiable here, and by M3 — but only if
//    "agreement" is measured on BALANCES.  Measured on the contract's own
//    committed observable it is 0%.  The clause needs to name the observable,
//    not only the percentage.  Third independent instance of the same defect in
//    R4 (PILOT-NOTES §7 is the first; liquity.qnt's header is the second).
//
//  LINT:  `respec_lint.py polymarket.qnt` reports ONE finding.
//    [D4] redeemPositions(u): driver picks `u` from USERS and passes it to a
//         selection action; used as a map key.
//    JUSTIFICATION.  `ConditionalTokens.redeemPositions` is called by a holder
//    for its OWN balances: `msg.sender` is the redeemer and the only storage the
//    identity reaches is that holder's own ERC1155 balance, which the spec reads.
//    Convention 6 permits "user identity for deposits" and this is its exact
//    mirror.  foot(Q) = none.  The v1 file scores the SAME finding on the SAME
//    line (measured: `respec_lint.py quint-models/L6/polymarket.qnt` -> 1
//    finding, [D4] redeem(u)), and v1's actual deletion — the exogenous price
//    and the missing match type — is invisible to all six detectors.  So on this
//    protocol the linter's only finding is a false positive and its only true
//    finding is absent.  See liquity.qnt's LINT block for the proposed D4a/D4b
//    split; note that the `used as a map key` clause fires here, on the
//    legitimate case, which is why the split must ALSO ask whether the action is
//    one the caller initiates for itself.
//    NOTE on what did NOT fire: `matchOrders(TAKERS[ti])` escapes D4 only
//    because the regex `\(([^)]*)\)` cannot see through the nested subscript.
//    The taker order is genuinely calldata and genuinely exogenous, so the
//    verdict is right, but it is right by accident.
//
//  ACCEPTANCE:
//    T1  quint typecheck polymarket.qnt
//    T2  quint run --main=polymarket --invariant=inv_conservation \
//          --max-steps=20 --max-samples=2000 polymarket.qnt
//    T3  quint run --main=polymarket --invariant=inv_all ...     (no violation)
//        and, for each W in the wit_* block, the same command with
//          --invariant=W  MUST report a violation.
//    T0-LIVE: ONE match, THREE makers, two of them same-side, settled by
//        EXACTLY ONE mint of 100.  The obligation is the TRACE that violates
//        `wit_mintSettlement`: a reachable state with lockedCollateral 150 and
//        the taker holding 111 YES against 0 NO — a holding no `split` can
//        produce, because `split` mints the pair.  Depth 1 from init.
//        P2-CONTRACT §D lists "totalMintAmount = 32" for this protocol; §A.10's
//        batch row is reproduced exactly as t0_20, but it cannot be a REACHABLE
//        state — see the note above t0_20.
// =============================================================================
module polymarket {
  import kernel.* from "./kernel"

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4 — every value in `init` is a named pure val)
  // ---------------------------------------------------------------------------

  /// Structs.sol Side — the encoding _deriveMatchType's assembly depends on.
  pure val SIDE_BUY: int = 0
  pure val SIDE_SELL: int = 1
  /// Structs.sol MatchType, and the values the assembly produces.
  pure val MATCH_COMPLEMENTARY: int = 0
  pure val MATCH_MINT: int = 1
  pure val MATCH_MERGE: int = 2
  /// AssetOperations._getPartition — the binary partition [1, 2].
  pure val TOKEN_YES: int = 1
  pure val TOKEN_NO: int = 2

  pure val USERS: Set[str] = Set("alice", "bob", "carol")
  pure val MAX_BOOK: int = 5

  pure val PHASE_OPEN: int = 0
  pure val PHASE_RESOLVED: int = 1

  type Order = {
    id: int,
    maker: str,
    side: int,
    tokenId: int,
    makerAmount: int,   // what the maker gives
    takerAmount: int,   // what the maker wants
    filled: int,        // orderStatus[hash].remaining, complemented
  }

  type Payout = { yes: int, no: int }

  // ---------------------------------------------------------------------------
  // DECLARED DOMAIN D (convention 8a; see BOUNDS for 8b and 8c)
  //
  // Prices are read off the ratios and all lie strictly inside (0, 1), which is
  // what a prediction-market outcome token can be worth: a BUY offers less
  // collateral than the tokens it asks for, a SELL asks less collateral than the
  // tokens it offers.  `orderWellFormed` states exactly that and it is an
  // invariant, not a comment.
  //   ORD_A  bob   BUY  NO  20 for 40   (0.50)
  //   ORD_B  carol BUY  NO  27 for 60   (0.45)
  //   ORD_C  bob   SELL YES 30 for 18   (0.60)
  //   ORD_D  carol SELL NO  50 for 20   (0.40)
  //   ORD_E  bob   BUY  YES  5 for 10   (0.50)   postable
  //   ORD_F  carol SELL NO  10 for  5   (0.50)   postable
  //   TAK_1  alice BUY  YES 60 for 100  (0.60)
  //   TAK_2  alice SELL YES 30 for 12   (0.40)
  //   TAK_3  alice BUY  YES  6 for 10   (0.60)
  // ---------------------------------------------------------------------------

  pure val ORD_A: Order = { id: 1, maker: "bob",   side: SIDE_BUY,  tokenId: TOKEN_NO,  makerAmount: 20, takerAmount: 40, filled: 0 }
  pure val ORD_B: Order = { id: 2, maker: "carol", side: SIDE_BUY,  tokenId: TOKEN_NO,  makerAmount: 27, takerAmount: 60, filled: 0 }
  pure val ORD_C: Order = { id: 3, maker: "bob",   side: SIDE_SELL, tokenId: TOKEN_YES, makerAmount: 30, takerAmount: 18, filled: 0 }
  pure val ORD_D: Order = { id: 4, maker: "carol", side: SIDE_SELL, tokenId: TOKEN_NO,  makerAmount: 50, takerAmount: 20, filled: 0 }
  pure val ORD_E: Order = { id: 5, maker: "bob",   side: SIDE_BUY,  tokenId: TOKEN_YES, makerAmount:  5, takerAmount: 10, filled: 0 }
  pure val ORD_F: Order = { id: 6, maker: "carol", side: SIDE_SELL, tokenId: TOKEN_NO,  makerAmount: 10, takerAmount:  5, filled: 0 }

  pure val TAK_1: Order = { id: 101, maker: "alice", side: SIDE_BUY,  tokenId: TOKEN_YES, makerAmount: 60, takerAmount: 100, filled: 0 }
  pure val TAK_2: Order = { id: 102, maker: "alice", side: SIDE_SELL, tokenId: TOKEN_YES, makerAmount: 30, takerAmount:  12, filled: 0 }
  pure val TAK_3: Order = { id: 103, maker: "alice", side: SIDE_BUY,  tokenId: TOKEN_YES, makerAmount:  6, takerAmount:  10, filled: 0 }

  /// The rival maker of t0_31: the same shape as ORD_C at a price that does NOT
  /// cross TAK_1, so `_validateOrdersMatch` has a witness on each side.
  pure val ORD_NC: Order = { id: 7, maker: "bob", side: SIDE_SELL, tokenId: TOKEN_YES, makerAmount: 30, takerAmount: 24, filled: 0 }

  pure val INIT_BOOK: List[Order] = List(ORD_A, ORD_B, ORD_C, ORD_D)
  pure val POSTABLE: List[Order] = List(ORD_E, ORD_F)
  pure val TAKERS: List[Order] = List(TAK_1, TAK_2, TAK_3)
  pure val TAKER_IDX: Set[int] = Set(0, 1, 2)
  pure val POST_IDX: Set[int] = Set(0, 1)

  pure val PAYOUTS: List[Payout] = List({ yes: 1, no: 0 }, { yes: 0, no: 1 }, { yes: 1, no: 1 })
  pure val PAYOUT_IDX: Set[int] = Set(0, 1, 2)
  pure val NO_PAYOUT: Payout = { yes: 0, no: 0 }

  pure val SPLIT_AMOUNTS: Set[int] = Set(10, 20, 50)

  /// init is a configured state, per P2-CONTRACT §C rows 2 and 8.  Bob holds 50
  /// YES against carol's 50 NO, so 50 collateral is already locked in the CTF —
  /// the state a market that has traded at all is in, and the state a SELL order
  /// needs to be fillable from.
  pure val INIT_CASH: int = 200
  pure val INIT_BOB_YES: int = 50
  pure val INIT_CAROL_NO: int = 50
  pure val INIT_LOCKED: int = 50
  pure val CASH_TOTAL: int = 650

  pure val OP_INIT: str = "init"
  pure val OP_SPLIT: str = "split"
  pure val OP_MERGE: str = "merge"
  pure val OP_POST: str = "postOrder"
  pure val OP_MATCH_MINT: str = "matchOrders/MINT"
  pure val OP_MATCH_MERGE: str = "matchOrders/MERGE"
  pure val OP_MATCH_COMP: str = "matchOrders/COMPLEMENTARY"
  pure val OP_RESOLVE: str = "resolveMarket"
  pure val OP_REDEEM: str = "redeemPositions"

  // ---------------------------------------------------------------------------
  // STATE.  `book` is a List, never a Set the driver selects from
  // (convention 5).  Its ORDER is the maker-array order of _settleMakerOrders
  // and is what the taker's budget consumes a prefix of.
  // ---------------------------------------------------------------------------

  var book: List[Order]         // resting maker orders, ascending id
  var cash: str -> int          // collateral (USDC)
  var posYes: str -> int        // ERC1155 outcome balances, tokenId 1
  var posNo: str -> int         // ERC1155 outcome balances, tokenId 2
  var lockedCollateral: int     // collateral held by the CTF for this condition
  var phase: int
  var payout: Payout
  var lastOp: str               // GHOST — trace label, see header

  // ===========================================================================
  //  THE MECHANISM, as named `pure def`s (convention 3 / 6b).
  // ===========================================================================

  /// CalculatorHelper.sol:5-11 — `(makingAmount * takerAmount) / makerAmount`.
  /// Floors: the residue stays with the order, never with the counterparty.
  /// THIS is the price.  It is a ratio off the order being crossed, and there is
  /// no other price anywhere in this file.
  pure def takingAmount(making: int, mkAmount: int, tkAmount: int): int =
    mulDivDown(making, tkAmount, mkAmount)

  /// Trading.sol:577-590 — `mul(add(takerSide, 1), eq(takerSide, makerSide))`.
  /// Sides AGREE  => the two orders want the same direction on OPPOSITE tokens,
  /// which cannot be a transfer and must be a CTF mint (both buying) or a CTF
  /// merge (both selling).  Sides DISAGREE => an ordinary transfer.
  pure def matchType(takerSide: int, makerSide: int): int =
    if (takerSide == makerSide) takerSide + 1 else 0

  /// Trading.sol:640-676, verbatim, in the same cross-multiplied integer form
  /// the contract uses (which is why there is no division and no rounding here).
  pure def ordersMatch(taker: Order, o: Order, mt: int): bool =
    if (mt == MATCH_COMPLEMENTARY)
      taker.tokenId == o.tokenId and
        taker.makerAmount * o.makerAmount >= taker.takerAmount * o.takerAmount
    else if (mt == MATCH_MINT)
      taker.tokenId != o.tokenId and
        taker.takerAmount * o.makerAmount + o.takerAmount * taker.makerAmount
          >= taker.takerAmount * o.takerAmount
    else
      taker.tokenId != o.tokenId and
        taker.takerAmount * o.makerAmount + o.takerAmount * taker.makerAmount
          <= taker.makerAmount * o.makerAmount

  /// (0, 1) pricing.  A BUY offers less collateral than the tokens it asks for;
  /// a SELL asks less collateral than the tokens it offers.  Asserted as
  /// `inv_bookWellFormed`, and the MINT branch of `fillCap` divides by
  /// `takerAmount - makerAmount`, which this is what keeps non-zero.
  pure def orderWellFormed(o: Order): bool =
    and {
      o.makerAmount > 0,
      o.takerAmount > 0,
      o.filled >= 0,
      o.filled <= o.makerAmount,
      if (o.side == SIDE_BUY) o.takerAmount > o.makerAmount
      else o.takerAmount < o.makerAmount,
    }

  /// How much of THIS maker's making amount the taker's remaining budget can
  /// absorb.  The three arms are the three units the taker pays in:
  ///   MERGE  — the taker supplies the complementary tokens one-for-one;
  ///   MINT   — the taker supplies only the SHORTFALL, `taking - fill`, because
  ///            the maker's own collateral funds the rest of the split;
  ///   COMPL. — the taker pays the maker's `taking` outright.
  /// Each is the exact inverse of `takerConsumes` below, floored so that the
  /// consumption can never exceed the budget.
  pure def fillCap(o: Order, mt: int, remaining: int): int =
    if (mt == MATCH_MERGE) remaining
    else if (mt == MATCH_MINT)
      mulDivDown(remaining, o.makerAmount, o.takerAmount - o.makerAmount)
    else mulDivDown(remaining, o.makerAmount, o.takerAmount)

  pure def takerConsumes(mt: int, fill: int, taking: int): int =
    if (mt == MATCH_MINT) taking - fill
    else if (mt == MATCH_MERGE) fill
    else taking

  pure def takerReceives(mt: int, fill: int, taking: int): int =
    if (mt == MATCH_MINT) taking
    else if (mt == MATCH_MERGE) fill - taking
    else fill

  type MatchAcc = {
    rest: List[Order],
    remaining: int,
    mintTotal: int,
    mergeTotal: int,
    takerOut: int,
    touched: int,
    cash: str -> int,
    posYes: str -> int,
    posNo: str -> int,
  }

  /// One position of the Phase-1 loop, Trading.sol:405-421 fused with
  /// _prepareMakerOrder (:446-475) and the Phase-3 distribution (:428-443).
  /// A maker that does not cross, or that has nothing left, is passed over —
  /// which is the operator declining to include it in `makerOrders`.
  /// Uniform settlement, and it is uniform in the CONTRACT too: the maker gives
  /// `fill` of its maker asset and receives `taking` of its taker asset,
  /// whatever the match type.  `_deriveAssetIds` is what makes it uniform:
  /// buy => (collateral, tokenId); sell => (tokenId, collateral).
  pure def matchOne(acc: MatchAcc, taker: Order, o: Order): MatchAcc = {
    val mt = matchType(taker.side, o.side)
    if (acc.remaining <= 0 or not(ordersMatch(taker, o, mt)))
      { ...acc, rest: acc.rest.append(o) }
    else {
      val avail = o.makerAmount - o.filled
      val fill = minInt(avail, fillCap(o, mt, acc.remaining))
      if (fill <= 0) { ...acc, rest: acc.rest.append(o) }
      else {
        val taking = takingAmount(fill, o.makerAmount, o.takerAmount)
        val buys = o.side == SIDE_BUY
        val isYes = o.tokenId == TOKEN_YES
        { rest: acc.rest.append({ ...o, filled: o.filled + fill }),
          remaining: acc.remaining - takerConsumes(mt, fill, taking),
          mintTotal: acc.mintTotal + (if (mt == MATCH_MINT) taking else 0),
          mergeTotal: acc.mergeTotal + (if (mt == MATCH_MERGE) fill else 0),
          takerOut: acc.takerOut + takerReceives(mt, fill, taking),
          touched: acc.touched + 1,
          cash: if (buys) acc.cash.setBy(o.maker, c => c - fill)
                else acc.cash.setBy(o.maker, c => c + taking),
          posYes: if (not(isYes)) acc.posYes
                  else if (buys) acc.posYes.setBy(o.maker, x => x + taking)
                  else acc.posYes.setBy(o.maker, x => x - fill),
          posNo: if (isYes) acc.posNo
                 else if (buys) acc.posNo.setBy(o.maker, x => x + taking)
                 else acc.posNo.setBy(o.maker, x => x - fill) }
      }
    }
  }

  /// THE REGISTRY NAME (P2-SCOPE convention 3).  Trading.sol:390-444.
  /// Walks the maker list IN ORDER.  Nothing in the signature is a price and
  /// nothing in the signature names the makers to use: the walk decides.
  pure def matchTakerAgainstMakers(makers: List[Order], taker: Order,
                                   cash0: str -> int, yes0: str -> int,
                                   no0: str -> int): MatchAcc =
    makers.foldl({ rest: List(), remaining: taker.makerAmount - taker.filled,
                   mintTotal: 0, mergeTotal: 0, takerOut: 0, touched: 0,
                   cash: cash0, posYes: yes0, posNo: no0 },
                 (acc, o) => matchOne(acc, taker, o))

  // -- local primitives over the ordered book (P2-SCOPE §3) -------------------

  // LOCAL PRIMITIVE: list reversal for Order, for the order-dependence vector.
  pure def revOrders(l: List[Order]): List[Order] =
    l.foldl(List(), (acc, e) => List(e).concat(acc))

  // LOCAL PRIMITIVE: id lookup over the book.
  pure def bookHasId(l: List[Order], oid: int): bool =
    l.indices().exists(i => l[i].id == oid)

  // LOCAL PRIMITIVE: the per-position fill vector a walk produced.
  pure def fillsOf(before: List[Order], after: List[Order]): List[int] =
    range(0, before.length()).foldl(List(), (a, i) => a.append(after[i].filled - before[i].filled))

  /// Trading.sol:405-421 Phase 1, transcribed DIRECTLY against an explicit
  /// operator fill vector, with no walk and no budget.  Its only purpose is to
  /// be a second, independent statement of the accumulation rule that the walk
  /// must agree with — see `inv_matchConserves`.  It is also what reproduces
  /// P2-CONTRACT §A.10's batch row exactly (t0_20).
  pure def batchTotals(takerSide: int, makers: List[Order],
                       fills: List[int]): { mint: int, merge: int } =
    makers.indices().fold({ mint: 0, merge: 0 }, (acc, i) => {
      val mt = matchType(takerSide, makers[i].side)
      if (mt == MATCH_MINT)
        { mint: acc.mint + takingAmount(fills[i], makers[i].makerAmount, makers[i].takerAmount),
          merge: acc.merge }
      else if (mt == MATCH_MERGE) { mint: acc.mint, merge: acc.merge + fills[i] }
      else acc
    })

  pure def sumOver(m: str -> int): int = USERS.fold(0, (s, u) => s + m.get(u))

  pure def payoutDen(p: Payout): int = p.yes + p.no

  /// ConditionalTokens.redeemPositions — numerators over payoutDenominator.
  pure def redeemPayout(y: int, n: int, p: Payout): int =
    (y * p.yes + n * p.no) / payoutDen(p)

  pure def validPayout(p: Payout): bool =
    and {
      p.yes == 0 or p.yes == 1,
      p.no == 0 or p.no == 1,
      p.yes + p.no > 0,
    }

  /// THE MECHANISM CHECK.  Every clause is a property of the walk that a
  /// bilateral transfer at an exogenous price cannot satisfy, and it holds at
  /// EVERY reachable state for EVERY taker in the catalogue.
  pure def matchIsOrdered(makers: List[Order], taker: Order, cash0: str -> int,
                          yes0: str -> int, no0: str -> int): bool = {
    val r = matchTakerAgainstMakers(makers, taker, cash0, yes0, no0)
    and {
      // the taker's budget is consumed monotonically and never overrun
      r.remaining >= 0,
      r.remaining <= taker.makerAmount - taker.filled,
      r.takerOut >= 0,
      // the maker list keeps its length and its order; fills only grow, and
      // never past the resting size
      r.rest.length() == makers.length(),
      makers.indices().forall(i => r.rest[i].id == makers[i].id),
      makers.indices().forall(i => r.rest[i].filled >= makers[i].filled),
      makers.indices().forall(i => r.rest[i].filled <= makers[i].makerAmount),
      // `touched` counts exactly the positions that were filled
      r.touched == makers.indices().filter(i => r.rest[i].filled > makers[i].filled).size(),
      r.touched <= makers.length(),
      // AT MOST ONE CTF CALL OF EACH KIND, and never both: MINT needs the taker
      // buying and MERGE needs it selling, so one match is one settlement.
      r.mintTotal >= 0,
      r.mergeTotal >= 0,
      r.mintTotal == 0 or r.mergeTotal == 0,
      // the walk's accumulators agree with the direct Phase-1 transcription
      // applied to the fills the walk chose
      batchTotals(taker.side, makers, fillsOf(makers, r.rest))
        == { mint: r.mintTotal, merge: r.mergeTotal },
    }
  }

  // ===========================================================================
  //  T0 CONFORMANCE VECTORS (repair 2).
  // ===========================================================================

  pure val T0_ACC1: MatchAcc =
    matchTakerAgainstMakers(INIT_BOOK, TAK_1, USERS.mapBy(_ => INIT_CASH),
                            USERS.mapBy(u => if (u == "bob") INIT_BOB_YES else 0),
                            USERS.mapBy(u => if (u == "carol") INIT_CAROL_NO else 0))
  pure val T0_ACC1R: MatchAcc =
    matchTakerAgainstMakers(revOrders(INIT_BOOK), TAK_1, USERS.mapBy(_ => INIT_CASH),
                            USERS.mapBy(u => if (u == "bob") INIT_BOB_YES else 0),
                            USERS.mapBy(u => if (u == "carol") INIT_CAROL_NO else 0))
  pure val T0_ACC2: MatchAcc =
    matchTakerAgainstMakers(T0_ACC1.rest, TAK_2, T0_ACC1.cash, T0_ACC1.posYes, T0_ACC1.posNo)
  pure val T0_ACC3: MatchAcc =
    matchTakerAgainstMakers(T0_ACC1.rest, TAK_3, T0_ACC1.cash, T0_ACC1.posYes, T0_ACC1.posNo)

  // -- THE HEADLINE WALK.  One taker, four resting orders, three of them
  //    crossed: two same-side BUYs settled by ONE mint of 100, one opposite-side
  //    SELL settled by transfer, and one order skipped because its token is
  //    wrong.  The budget of 60 runs out INSIDE the third maker, which is filled
  //    11 of its 30.  That partial fill is the endogenous cutoff. -------------
  pure val t0_10: bool = and {
    T0_ACC1.mintTotal == 100,
    T0_ACC1.mergeTotal == 0,
    T0_ACC1.remaining == 1,
    T0_ACC1.takerOut == 111,
    T0_ACC1.touched == 3,
    fillsOf(INIT_BOOK, T0_ACC1.rest) == List(20, 27, 11, 0),
  }

  // -- THE ORDER IS THE MECHANISM.  Same taker, same four orders, walked from
  //    the other end.  A different set of fills, a different mint, a different
  //    payout.  A spec that crosses one named counterparty at a driver's price
  //    can produce either and is pinned by neither. --------------------------
  pure val t0_11: bool = and {
    T0_ACC1R.mintTotal == 78,
    T0_ACC1R.remaining == 0,
    T0_ACC1R.takerOut == 108,
    fillsOf(revOrders(INIT_BOOK), T0_ACC1R.rest) == List(0, 30, 27, 9),
    T0_ACC1R.mintTotal != T0_ACC1.mintTotal,
  }

  // -- MERGE.  A SELL taker crossed against a SELL maker on the other token:
  //    settled by ONE merge of 30, which is `makingAmount` and NOT
  //    `takingAmount` — Trading.sol:414 and :409 accumulate different
  //    quantities, and a spec that used one for both would fail here. --------
  pure val t0_13: bool = and {
    T0_ACC2.mergeTotal == 30,
    T0_ACC2.mintTotal == 0,
    T0_ACC2.remaining == 0,
    T0_ACC2.takerOut == 18,
    T0_ACC2.touched == 1,
    fillsOf(T0_ACC1.rest, T0_ACC2.rest) == List(0, 0, 0, 30),
  }

  // -- COMPLEMENTARY ONLY.  Trading.sol:290's `_isAllComplementary` early path:
  //    no CTF call at all, and the two exhausted orders are skipped rather than
  //    reverting the match. ---------------------------------------------------
  pure val t0_14: bool = and {
    T0_ACC3.mintTotal == 0,
    T0_ACC3.mergeTotal == 0,
    T0_ACC3.touched == 1,
    T0_ACC3.takerOut == 10,
    fillsOf(T0_ACC1.rest, T0_ACC3.rest) == List(0, 0, 10, 0),
  }

  // -- the walk agrees with the direct Phase-1 transcription ------------------
  pure val t0_15: bool = and {
    matchIsOrdered(INIT_BOOK, TAK_1, USERS.mapBy(_ => INIT_CASH),
                   USERS.mapBy(u => if (u == "bob") INIT_BOB_YES else 0),
                   USERS.mapBy(u => if (u == "carol") INIT_CAROL_NO else 0)),
    matchIsOrdered(T0_ACC1.rest, TAK_2, T0_ACC1.cash, T0_ACC1.posYes, T0_ACC1.posNo),
    matchIsOrdered(T0_ACC1.rest, TAK_3, T0_ACC1.cash, T0_ACC1.posYes, T0_ACC1.posNo),
  }

  // -- _deriveMatchType, all four cases (P2-CONTRACT §A.10 rows 1-3) ----------
  pure val t0_18: bool = and {
    matchType(SIDE_BUY, SIDE_BUY) == MATCH_MINT,
    matchType(SIDE_SELL, SIDE_SELL) == MATCH_MERGE,
    matchType(SIDE_BUY, SIDE_SELL) == MATCH_COMPLEMENTARY,
    matchType(SIDE_SELL, SIDE_BUY) == MATCH_COMPLEMENTARY,
  }

  // -- calculateTakingAmount (P2-CONTRACT §A.10 rows 4-6), plus one inexact
  //    quotient for 6c: 30*65/100 = 19.5 floors to 19 -------------------------
  pure val t0_19: bool = and {
    takingAmount(50, 100, 40) == 20,
    takingAmount(30, 100, 40) == 12,
    takingAmount(20, 100, 65) == 13,
    takingAmount(30, 100, 65) == 19,
    takingAmount(11, 30, 18) == 6,
  }

  // -- P2-CONTRACT §A.10's batch row, reproduced EXACTLY.
  //    NOTE, and it is a finding reported with this file: these three orders
  //    cannot be a reachable state.  A BUY with makerAmount 100 and takerAmount
  //    40 pays 2.5 collateral per outcome token, and an outcome token is worth
  //    at most 1.  Under a MINT settlement the taker's share of the split would
  //    be `taking - fill` = 20 - 50 = -30, i.e. the taker is PAID to receive
  //    tokens.  The arithmetic of the accumulation is nonetheless exactly what
  //    the contract computes, and it is pinned here as arithmetic.  The
  //    reachable analogue is t0_10.
  pure val A10_MAKERS: List[Order] = List(
    { id: 91, maker: "bob",   side: SIDE_BUY,  tokenId: TOKEN_NO,  makerAmount: 100, takerAmount: 40, filled: 0 },
    { id: 92, maker: "carol", side: SIDE_BUY,  tokenId: TOKEN_NO,  makerAmount: 100, takerAmount: 40, filled: 0 },
    { id: 93, maker: "bob",   side: SIDE_SELL, tokenId: TOKEN_YES, makerAmount: 100, takerAmount: 65, filled: 0 },
  )
  pure val t0_20: bool =
    batchTotals(SIDE_BUY, A10_MAKERS, List(50, 30, 20)) == { mint: 32, merge: 0 }

  // -- the taker's own price, honoured by the AGGREGATE of the maker prefix
  //    (Trading.sol:330-335) ------------------------------------------------
  pure val t0_21: bool = and {
    takingAmount(59, 60, 100) == 98,
    T0_ACC1.takerOut >= takingAmount(60 - T0_ACC1.remaining, 60, 100),
  }

  // -- _validateOrdersMatch, both sides of every crossing condition (6f) ------
  pure val t0_30: bool = and {
    ordersMatch(TAK_1, ORD_C, MATCH_COMPLEMENTARY),          // 0.60 vs 0.60, at equality
    ordersMatch(TAK_1, ORD_A, MATCH_MINT),                   // 0.60 + 0.50 >= 1
    ordersMatch(TAK_2, ORD_D, MATCH_MERGE),                  // 0.40 + 0.40 <= 1
  }
  pure val t0_31: bool = and {
    not(ordersMatch(TAK_1, ORD_NC, MATCH_COMPLEMENTARY)),    // 0.60 vs 0.80
    not(ordersMatch(TAK_3, ORD_D, MATCH_COMPLEMENTARY)),     // token mismatch
    not(ordersMatch(TAK_2, ORD_C, MATCH_MERGE)),             // token mismatch
  }

  // -- the (0,1) pricing envelope, both sides -------------------------------
  pure val t0_32: bool = and {
    INIT_BOOK.indices().forall(i => orderWellFormed(INIT_BOOK[i])),
    TAKERS.indices().forall(i => orderWellFormed(TAKERS[i])),
    orderWellFormed(ORD_E),
    orderWellFormed(ORD_F),
    not(orderWellFormed(A10_MAKERS[0])),
  }

  // -- UMA payouts and payoutDenominator, both sides of the divisor ----------
  pure val t0_33: bool = and {
    redeemPayout(111, 0, PAYOUTS[0]) == 111,
    redeemPayout(111, 0, PAYOUTS[1]) == 0,
    redeemPayout(111, 0, PAYOUTS[2]) == 55,
    payoutDen(PAYOUTS[0]) == 1,
    payoutDen(PAYOUTS[2]) == 2,
    PAYOUT_IDX.forall(k => validPayout(PAYOUTS[k])),
  }

  pure val inv_T0: bool = and {
    t0_10, t0_11, t0_13, t0_14, t0_15, t0_18, t0_19, t0_20, t0_21,
    t0_30, t0_31, t0_32, t0_33,
  }

  // ===========================================================================
  //  ACTIONS
  // ===========================================================================

  action init: bool = all {
    book' = INIT_BOOK,
    cash' = USERS.mapBy(_ => INIT_CASH),
    posYes' = USERS.mapBy(u => if (u == "bob") INIT_BOB_YES else 0),
    posNo' = USERS.mapBy(u => if (u == "carol") INIT_CAROL_NO else 0),
    lockedCollateral' = INIT_LOCKED,
    phase' = PHASE_OPEN,
    payout' = NO_PAYOUT,
    lastOp' = OP_INIT,
  }

  /// ConditionalTokens.splitPosition called directly by a holder.
  action split(user: str, amount: int): bool = all {
    phase == PHASE_OPEN,
    USERS.contains(user),
    amount > 0,
    cash.get(user) >= amount,
    cash' = cash.setBy(user, c => c - amount),
    posYes' = posYes.setBy(user, y => y + amount),
    posNo' = posNo.setBy(user, n => n + amount),
    lockedCollateral' = lockedCollateral + amount,
    book' = book,
    phase' = phase,
    payout' = payout,
    lastOp' = OP_SPLIT,
  }

  /// ConditionalTokens.mergePositions called directly by a holder.
  action merge(user: str, amount: int): bool = all {
    phase == PHASE_OPEN,
    USERS.contains(user),
    amount > 0,
    posYes.get(user) >= amount,
    posNo.get(user) >= amount,
    lockedCollateral >= amount,
    cash' = cash.setBy(user, c => c + amount),
    posYes' = posYes.setBy(user, y => y - amount),
    posNo' = posNo.setBy(user, n => n - amount),
    lockedCollateral' = lockedCollateral - amount,
    book' = book,
    phase' = phase,
    payout' = payout,
    lastOp' = OP_MERGE,
  }

  /// ENVIRONMENT action: a maker signs an order and rests it.  Not an on-chain
  /// function; see ABSTRACTED.  Ids increase, which is what keeps the book a
  /// function of the set of resting orders.
  action postOrder(o: Order): bool = all {
    phase == PHASE_OPEN,
    book.length() < MAX_BOOK,
    not(bookHasId(book, o.id)),
    orderWellFormed(o),
    book.length() == 0 or o.id > book[book.length() - 1].id,
    book' = book.append(o),
    cash' = cash,
    posYes' = posYes,
    posNo' = posNo,
    lockedCollateral' = lockedCollateral,
    phase' = phase,
    payout' = payout,
    lastOp' = OP_POST,
  }

  /// CTFExchange.matchOrders -> Trading._matchOrders.  THE SIGNATURE IS THE
  /// REPAIR: one taker order, and no price, no counterparty and no amount of
  /// anyone else's.  Every maker crossed, every fill, the execution price and
  /// the size of the single CTF call are computed from the book.
  action matchOrders(taker: Order): bool = all {
    phase == PHASE_OPEN,
    USERS.contains(taker.maker),
    orderWellFormed(taker),
    book.length() > 0,
    val r = matchTakerAgainstMakers(book, taker, cash, posYes, posNo)
    val spent = taker.makerAmount - taker.filled - r.remaining
    val buys = taker.side == SIDE_BUY
    val yesT = if (taker.tokenId == TOKEN_YES) 1 else 0
    val cashN = if (buys) r.cash.setBy(taker.maker, c => c - spent)
                else r.cash.setBy(taker.maker, c => c + r.takerOut)
    val yesN = if (yesT == 0) r.posYes
               else if (buys) r.posYes.setBy(taker.maker, y => y + r.takerOut)
               else r.posYes.setBy(taker.maker, y => y - spent)
    val noN = if (yesT == 1) r.posNo
              else if (buys) r.posNo.setBy(taker.maker, n => n + r.takerOut)
              else r.posNo.setBy(taker.maker, n => n - spent)
    all {
      r.touched > 0,
      spent > 0,
      r.takerOut >= takingAmount(spent, taker.makerAmount, taker.takerAmount),
      // Phase 1: every maker funded the transfer _prepareMakerOrder pulled.
      book.indices().forall(i => r.cash.get(book[i].maker) >= 0),
      USERS.forall(u => r.posYes.get(u) >= 0 and r.posNo.get(u) >= 0),
      // Phases 2 and 3: the taker funded its own leg.  Trading.sol:314 pulls
      // `takerFillAmount` of the taker's MAKER asset before any maker is
      // settled, so a taker that cannot cover its own fill reverts the match.
      USERS.forall(u => cashN.get(u) >= 0 and yesN.get(u) >= 0 and noN.get(u) >= 0),
      lockedCollateral + r.mintTotal - r.mergeTotal >= 0,
      book' = r.rest,
      cash' = cashN,
      posYes' = yesN,
      posNo' = noN,
      lockedCollateral' = lockedCollateral + r.mintTotal - r.mergeTotal,
      phase' = phase,
      payout' = payout,
      lastOp' = if (r.mintTotal > 0) OP_MATCH_MINT
                else if (r.mergeTotal > 0) OP_MATCH_MERGE
                else OP_MATCH_COMP,
    }
  }

  /// UmaCtfAdapter.resolve — a genuine external oracle report, foot(Q) = none.
  action resolveMarket(k: int): bool = all {
    phase == PHASE_OPEN,
    PAYOUT_IDX.contains(k),
    val pOut = PAYOUTS[k]
    all {
      validPayout(pOut),
      payout' = pOut,
      phase' = PHASE_RESOLVED,
      book' = book,
      cash' = cash,
      posYes' = posYes,
      posNo' = posNo,
      lockedCollateral' = lockedCollateral,
      lastOp' = OP_RESOLVE,
    }
  }

  /// ConditionalTokens.redeemPositions.  The caller redeems its OWN balances.
  action redeemPositions(user: str): bool = all {
    phase == PHASE_RESOLVED,
    USERS.contains(user),
    posYes.get(user) + posNo.get(user) > 0,
    val pay = redeemPayout(posYes.get(user), posNo.get(user), payout)
    all {
      lockedCollateral >= pay,
      cash' = cash.setBy(user, c => c + pay),
      posYes' = posYes.put(user, 0),
      posNo' = posNo.put(user, 0),
      lockedCollateral' = lockedCollateral - pay,
      book' = book,
      phase' = phase,
      payout' = payout,
      lastOp' = OP_REDEEM,
    }
  }

  /// Convention 6: every `nondet` is exogenous — a caller identity, a calldata
  /// order, a token amount, or an oracle report.  Nothing here supplies a price
  /// and nothing here names the makers a taker crosses.
  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amount = SPLIT_AMOUNTS.oneOf()
    nondet ti = TAKER_IDX.oneOf()
    nondet pi = POST_IDX.oneOf()
    nondet k = PAYOUT_IDX.oneOf()
    any {
      split(u, amount),
      merge(u, amount),
      postOrder(POSTABLE[pi]),
      matchOrders(TAKERS[ti]),
      resolveMarket(k),
      redeemPositions(u),
    }
  }

  // ===========================================================================
  //  INVARIANTS (convention 7).
  // ===========================================================================

  /// CONSERVATION — the T2 invariant.  Every unit of collateral is either in a
  /// wallet or locked in the CTF, at every state, through every match, split,
  /// merge and redemption.  v1's `inv_collateral_conserved` asserted the same
  /// sum, but its trade action could not move `lockedCollateral` at all, so the
  /// invariant was never stressed by the mechanism it exists to constrain.
  val inv_conservation: bool =
    sumOver(cash) + lockedCollateral == CASH_TOTAL

  val inv_bounds: bool = and {
    lockedCollateral >= 0,
    book.length() <= MAX_BOOK,
    USERS.forall(u => cash.get(u) >= 0),
    USERS.forall(u => posYes.get(u) >= 0),
    USERS.forall(u => posNo.get(u) >= 0),
    phase == PHASE_OPEN or phase == PHASE_RESOLVED,
  }

  /// THE CTF IDENTITY.  While the market is open, the collateral locked in the
  /// condition is exactly the outstanding YES supply and exactly the outstanding
  /// NO supply.  A match that minted without locking, or transferred tokens that
  /// were never minted, breaks it.
  val inv_ctfBalanced: bool =
    phase == PHASE_RESOLVED or
      (lockedCollateral == sumOver(posYes) and sumOver(posYes) == sumOver(posNo))

  /// After resolution the lock still covers every outstanding claim, in
  /// numerator units, so no holder can be left unpayable by an earlier
  /// redemption's rounding.
  val inv_claimsCovered: bool =
    phase == PHASE_OPEN or
      lockedCollateral * payoutDen(payout)
        >= sumOver(posYes) * payout.yes + sumOver(posNo) * payout.no

  /// THE BOOK IS AN ORDER.  Ascending ids, no duplicates, every resting order
  /// inside the (0,1) pricing envelope, and no order filled past its size.
  val inv_bookWellFormed: bool = and {
    book.indices().forall(i => orderWellFormed(book[i])),
    book.indices().forall(i => i + 1 >= book.length() or book[i].id < book[i + 1].id),
    book.indices().forall(i => USERS.contains(book[i].maker)),
  }

  /// T3 for this protocol (P2-SCOPE §5 row 10).  At EVERY reachable state and
  /// for EVERY taker in the catalogue, the walk keeps the maker order, consumes
  /// the taker's budget monotonically without overrunning it, counts its own
  /// fills, settles by at most one mint and at most one merge and never both,
  /// and agrees with the contract's Phase-1 accumulation rule stated
  /// independently.
  val inv_matchConserves: bool =
    TAKER_IDX.forall(i => matchIsOrdered(book, TAKERS[i], cash, posYes, posNo))

  val inv_all: bool = and {
    inv_T0,
    inv_conservation,
    inv_bounds,
    inv_ctfBalanced,
    inv_claimsCovered,
    inv_bookWellFormed,
    inv_matchConserves,
  }

  // ===========================================================================
  //  T0-LIVE AND USE WITNESSES (P2-CONTRACT §D, the fifth trap).
  //  Each must be VIOLATED by `quint run --invariant=<name>`.
  // ===========================================================================

  /// T0-LIVE.  One match, three makers, TWO of them on the taker's own side,
  /// settled by EXACTLY ONE mint of 100 — as a TRACE.  The signature is a
  /// holding no other action can produce: alice holds 111 YES and 0 NO while the
  /// lock stands at 150.  `split` mints the PAIR, so any YES that reached her
  /// that way would be matched by an equal NO; a transfer from a maker cannot
  /// raise the lock at all.  Under M1 (v1's bilateral `tradeYes` at a nondet
  /// price) `lockedCollateral` never moves during a trade and this state is
  /// unreachable.  Under M3 (per-maker settlement) the balances coincide but the
  /// lock arrives in two CTF calls of 40 and 60, which t0_10's `mintTotal == 100`
  /// rejects.  Depth 1 from init.
  val wit_mintSettlement: bool =
    not(and {
      lockedCollateral == 150,
      posYes.get("alice") == 111,
      posNo.get("alice") == 0,
      cash.get("alice") == 141,
    })

  /// The MERGE settlement, and the mirror argument: alice's YES fell by 30 and
  /// the lock fell by 30, while she holds no NO at all.  The standalone `merge`
  /// action requires an equal NO balance, so it cannot have produced this.
  val wit_mergeSettlement: bool =
    not(and {
      lockedCollateral == 120,
      posYes.get("alice") == 81,
      posNo.get("alice") == 0,
    })

  /// The endogenous cutoff, as a state.  Maker 3 is filled 11 of its 30 —
  /// a partial fill nobody asked for, produced only because the taker's budget
  /// ran out inside it.  Filling an order to 11 requires the walk to have spent
  /// 49 of 60 on the two makers ahead of it in the book.
  val wit_partialPrefix: bool =
    not(and {
      book.length() >= 4,
      book[0].filled == 20,
      book[1].filled == 27,
      book[2].filled == 11,
      book[3].filled == 0,
    })

  /// `takingAmount` ran and its FLOOR was load-bearing: maker 3 delivered 11
  /// tokens for 6 collateral, where the exact ratio is 6.6.
  val wit_used_takingAmount: bool =
    not(and {
      book.length() >= 3,
      book[2].filled == 11,
      cash.get("bob") == 186,
    })

  /// `postOrder` extended the book, so the maker list the walk consumes is not a
  /// constant.
  val wit_used_postOrder: bool = book.length() <= 4

  /// `redeemPayout` ran on the tie payout, where payoutDenominator is 2 and the
  /// division is the one that leaves a residue in the CTF.
  val wit_used_tiePayout: bool =
    not(and { phase == PHASE_RESOLVED, payout.yes == 1, payout.no == 1 })

  // -- convention 6d / 6f: enabledness and every MatchType branch --------------

  val wit_fired_split: bool = lastOp != OP_SPLIT
  val wit_fired_merge: bool = lastOp != OP_MERGE
  val wit_fired_postOrder: bool = lastOp != OP_POST
  val wit_fired_resolveMarket: bool = lastOp != OP_RESOLVE
  val wit_fired_redeemPositions: bool = lastOp != OP_REDEEM
  val wit_branch_mint: bool = lastOp != OP_MATCH_MINT
  val wit_branch_merge: bool = lastOp != OP_MATCH_MERGE
  val wit_branch_complementary: bool = lastOp != OP_MATCH_COMP
}
