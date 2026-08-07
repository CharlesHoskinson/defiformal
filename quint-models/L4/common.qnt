// L4 shared primitives — empirical recurrences across bridges + intents/aggregation.
// Source-traced from WBTC Factory mint/burn request flow, Circle CCTP burn-mint,
// Across deposit/fill/refund, LayerZero send/verify/lzReceive, CoW/1inch signed-order
// remaining fill, Kyber delegated-intent status. Instantiated by protocol modules.

module common {

  // ---------------------------------------------------------------------------
  // Arithmetic helpers
  // ---------------------------------------------------------------------------

  pure def min(a: int, b: int): int = if (a < b) a else b
  pure def max(a: int, b: int): int = if (a > b) a else b

  pure def mulDivDown(a: int, b: int, d: int): int =
    if (d <= 0) 0 else (a * b) / d

  // ---------------------------------------------------------------------------
  // Candidate primitive: CUSTODIAL_WRAPPED_SUPPLY (Rd / Xf / Aw partial)
  // WBTC: Factory.confirmMintRequest → Controller.mint → totalSupply++
  // Coinbase: MintForwarder.mint rate-limited against FiatToken totalSupply
  // BTCB profile: onlyOwner mint with no on-chain reserve binding
  // Invariant candidate: totalSupply is the only on-chain claim on off-chain reserve.
  // ---------------------------------------------------------------------------

  type WrapSupply = {
    totalSupply: int,
    paused: bool,
  }

  pure def emptyWrap: WrapSupply = { totalSupply: 0, paused: false }

  pure def canMintWrap(s: WrapSupply, amt: int): bool =
    amt > 0 and not(s.paused)

  pure def applyMintWrap(s: WrapSupply, amt: int): WrapSupply =
    { ...s, totalSupply: s.totalSupply + amt }

  pure def canBurnWrap(s: WrapSupply, amt: int): bool =
    amt > 0 and not(s.paused) and s.totalSupply >= amt

  pure def applyBurnWrap(s: WrapSupply, amt: int): WrapSupply =
    { ...s, totalSupply: s.totalSupply - amt }

  // ---------------------------------------------------------------------------
  // Candidate primitive: TWO_PHASE_CUSTODIAN_REQUEST
  // WBTC Factory: merchant addMintRequest → custodian confirmMintRequest
  //               merchant burn → custodian confirmBurnRequest
  // Status: PENDING | APPROVED | REJECTED | CANCELED
  // ---------------------------------------------------------------------------

  type ReqStatus = Pending | Approved | Rejected | Canceled

  type CustodianRequest = {
    requester: int,
    amount: int,
    status: ReqStatus,
  }

  pure def canConfirmMint(r: CustodianRequest): bool =
    r.status == Pending and r.amount > 0

  pure def applyApprove(r: CustodianRequest): CustodianRequest =
    { ...r, status: Approved }

  pure def applyReject(r: CustodianRequest): CustodianRequest =
    { ...r, status: Rejected }

  pure def applyCancel(r: CustodianRequest): CustodianRequest =
    { ...r, status: Canceled }

  // ---------------------------------------------------------------------------
  // Candidate primitive: BURN_MINT_BRIDGE (Xf + Xm with 1:1 conservation)
  // Circle CCTP: TokenMessenger.depositForBurn → MessageTransmitter.receiveMessage
  //              → TokenMinter.mint  (TokenMessenger.sol:169, MessageTransmitter.sol:250)
  // LayerZero OFT default path: _debit burns, _credit mints (OFT.sol:56-86)
  // Global conservation: sum of domain supplies is constant under pure bridge moves
  // when no external mint/burn outside the bridge.
  // ---------------------------------------------------------------------------

  pure def canBurnMintSend(srcSupply: int, amount: int): bool =
    amount > 0 and srcSupply >= amount

  pure def applyBurnOnSrc(srcSupply: int, amount: int): int = srcSupply - amount

  pure def applyMintOnDst(dstSupply: int, amount: int): int = dstSupply + amount

  /// Conservation after a completed burn-mint of `amount`.
  pure def burnMintConserved(
    srcBefore: int, dstBefore: int, srcAfter: int, dstAfter: int, amount: int
  ): bool =
    and {
      srcAfter == srcBefore - amount,
      dstAfter == dstBefore + amount,
      srcBefore + dstBefore == srcAfter + dstAfter,
    }

  // ---------------------------------------------------------------------------
  // Candidate primitive: ATTESTED_MESSAGE_ONCE
  // CCTP MessageTransmitter: usedNonces[nonce] prevents double receive
  // LayerZero EndpointV2: inbound payload cleared before lzReceive
  // Once-only delivery is the safety hinge of cross-domain messaging.
  // ---------------------------------------------------------------------------

  pure def canDeliverOnce(used: Set[int], nonce: int): bool =
    not(used.contains(nonce))

  pure def markUsed(used: Set[int], nonce: int): Set[int] =
    used.union(Set(nonce))

  // ---------------------------------------------------------------------------
  // Candidate primitive: OPTIMISTIC_FILL (Of)
  // Across SpokePool: deposit locks input on origin; relayer fills output on dest
  // from own inventory; later refunded via root bundle (SpokePool.sol:583,958)
  // Distinct from burn-mint: liquidity is *pre-positioned* and reimbursed.
  // ---------------------------------------------------------------------------

  type FillStatus = Unfilled | Filled | SlowRequested

  type DepositOrder = {
    depositor: int,
    recipient: int,
    inputAmount: int,
    outputAmount: int,
    originPool: int,     // token units locked on origin
    status: FillStatus,
  }

  pure def canDeposit(amount: int): bool = amount > 0

  pure def canFill(d: DepositOrder): bool =
    d.status == Unfilled and d.outputAmount > 0

  pure def applyFill(d: DepositOrder): DepositOrder =
    { ...d, status: Filled }

  // ---------------------------------------------------------------------------
  // Candidate primitive: SIGNED_ORDER_REMAINING (In partial / Ob partial)
  // 1inch OrderMixin: remainingInvalidator tracks unfilled making amount
  // CoW GPv2Settlement: filledAmount[orderUid] accumulates executed amount
  // Partial fills: remaining decreases; cancel sets remaining to 0 / max sentinel.
  // ---------------------------------------------------------------------------

  type SignedOrder = {
    maker: int,
    makingAmount: int,   // maker sells
    takingAmount: int,   // maker wants
    remaining: int,      // remaining making amount
    cancelled: bool,
  }

  pure def emptyOrder(maker: int, making: int, taking: int): SignedOrder = {
    maker: maker,
    makingAmount: making,
    takingAmount: taking,
    remaining: making,
    cancelled: false,
  }

  pure def canFillOrder(o: SignedOrder, fillMaking: int): bool =
    and {
      not(o.cancelled),
      fillMaking > 0,
      fillMaking <= o.remaining,
    }

  /// Pro-rata taking for a partial fill of `fillMaking` of makingAmount.
  pure def takingForFill(o: SignedOrder, fillMaking: int): int =
    if (o.makingAmount <= 0) 0
    else mulDivDown(fillMaking, o.takingAmount, o.makingAmount)

  pure def applyFillOrder(o: SignedOrder, fillMaking: int): SignedOrder =
    { ...o, remaining: o.remaining - fillMaking }

  pure def applyCancelOrder(o: SignedOrder): SignedOrder =
    { ...o, remaining: 0, cancelled: true }

  /// Filled amount never exceeds original making amount.
  pure def remainingBounded(o: SignedOrder): bool =
    o.remaining >= 0 and o.remaining <= o.makingAmount

  // ---------------------------------------------------------------------------
  // Candidate primitive: BATCH_CLEARING (Ba)
  // CoW settle: uniform clearing prices; each trade must not lose vs limit.
  // sellAmount * buyPrice >= buyAmount * sellPrice  (limit price check)
  // ---------------------------------------------------------------------------

  /// Limit-price check at clearing prices (sellToken price, buyToken price).
  /// Maker sells `sellAmt` of sell-token, buys at least `buyAmt` of buy-token.
  pure def clearsAtLimit(
    sellAmt: int, buyAmt: int, sellPrice: int, buyPrice: int
  ): bool =
    and {
      sellAmt > 0,
      buyAmt > 0,
      sellPrice > 0,
      buyPrice > 0,
      // executed: sellAmt * buyPrice / sellPrice >= buyAmt  (rearranged)
      sellAmt * buyPrice >= buyAmt * sellPrice,
    }

  // ---------------------------------------------------------------------------
  // Candidate primitive: DELEGATED_INTENT_STATUS
  // Kyber KSSmartIntentRouter: NOT_DELEGATED → DELEGATED → EXECUTED / REVOKED
  // Intent hash is one-shot; nonce unordered invalidation on execute.
  // ---------------------------------------------------------------------------

  type IntentStatus = NotDelegated | Delegated | Executed | Revoked

  pure def canDelegate(st: IntentStatus): bool = st == NotDelegated
  pure def canExecute(st: IntentStatus): bool = st == Delegated
  pure def canRevoke(st: IntentStatus): bool =
    st == NotDelegated or st == Delegated

  pure def applyDelegate(st: IntentStatus): IntentStatus = Delegated
  pure def applyExecute(st: IntentStatus): IntentStatus = Executed
  pure def applyRevoke(st: IntentStatus): IntentStatus = Revoked

  // ---------------------------------------------------------------------------
  // Candidate primitive: RATE_LIMITED_MINT
  // Coinbase MintForwarder + RateLimit: allowance replenishes over interval.
  // allowances[caller] decreases on mint; _replenishAllowance tops up.
  // ---------------------------------------------------------------------------

  type RateLimitState = {
    allowance: int,
    maxAllowance: int,
  }

  pure def canRateLimitedMint(rl: RateLimitState, amt: int): bool =
    amt > 0 and amt <= rl.allowance

  pure def applyRateLimitedMint(rl: RateLimitState, amt: int): RateLimitState =
    { ...rl, allowance: rl.allowance - amt }

  pure def replenish(rl: RateLimitState): RateLimitState =
    { ...rl, allowance: rl.maxAllowance }

  // ---------------------------------------------------------------------------
  // Candidate primitive: ESCROW_BALANCE (Hyperliquid / Across origin pool)
  // Contract holds token balance; deposits increase escrow, withdrawals decrease.
  // No mint: destination credit is ledger/balance, not a new token.
  // ---------------------------------------------------------------------------

  pure def canEscrowDeposit(amt: int): bool = amt > 0

  pure def applyEscrowDeposit(escrow: int, amt: int): int = escrow + amt

  pure def canEscrowWithdraw(escrow: int, amt: int): bool =
    amt > 0 and escrow >= amt

  pure def applyEscrowWithdraw(escrow: int, amt: int): int = escrow - amt
}
