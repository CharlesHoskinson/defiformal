// Centrifuge — async vault share class: request → issuer fulfill → claim.
// Sources:
//   centrifuge_protocol/src/vaults/AsyncRequestManager.sol
//     requestDeposit (L84), requestRedeem (L112)
//     fulfillDepositRequest (L281), fulfillRedeemRequest (L313)
//     deposit (L361), redeem (L414)
//   AsyncInvestmentState: pendingDepositRequest, maxMint, depositPrice,
//     pendingRedeemRequest, maxWithdraw, redeemPrice
//   Spoke.pricePoolPerShare / hub-posted NAV (admin price)
// Scope: one vault, one share class, one asset; async deposit+redeem cycle.
// NOT covered: cross-chain messaging, multi-share-class seniority, transfer hooks,
//   sync deposit path, subsidy/gas refunds, balance-sheet reserve accounting detail.

module centrifuge {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2)
  pure val REQ_IDS: Set[int] = Set(0, 1, 2)
  pure val AMOUNTS: Set[int] = Set(10, 20, 40)
  pure val PRICES: Set[int] = Set(100, 120, 80)
  pure val SCALE: int = 100

  var shareSupply: int
  // Aggregate escrow of assets reserved for pending deposits (simplified).
  var assetEscrow: int
  // Issuer-posted share price (pool per share).
  var nav: PostedPrice
  // Per-user async state collapsed to single open deposit / redeem request each.
  var depReq: int -> AsyncRequest
  var redReq: int -> AsyncRequest
  // Claimable after fulfill: maxMint shares / maxWithdraw assets.
  var maxMint: int -> int
  var maxWithdraw: int -> int
  var depositPrice: int -> int
  var redeemPrice: int -> int
  var nextDepId: int
  var nextRedId: int
  // User share balances (simplified single vault).
  var shares: int -> int

  action init: bool = all {
    shareSupply' = 0,
    assetEscrow' = 0,
    nav' = { value: 100, updatedAt: 0 },
    depReq' = REQ_IDS.mapBy(_ => emptyAsyncReq),
    redReq' = REQ_IDS.mapBy(_ => emptyAsyncReq),
    maxMint' = USERS.mapBy(_ => 0),
    maxWithdraw' = USERS.mapBy(_ => 0),
    depositPrice' = USERS.mapBy(_ => 0),
    redeemPrice' = USERS.mapBy(_ => 0),
    nextDepId' = 0,
    nextRedId' = 0,
    shares' = USERS.mapBy(_ => 0),
  }

  /// Hub / manager posts a new share NAV.
  action postNav(price: int, t: int): bool = all {
    PRICES.contains(price),
    canPostPrice(price),
    nav' = applyPostPrice(nav, price, t),
    shareSupply' = shareSupply,
    assetEscrow' = assetEscrow,
    depReq' = depReq,
    redReq' = redReq,
    maxMint' = maxMint,
    maxWithdraw' = maxWithdraw,
    depositPrice' = depositPrice,
    redeemPrice' = redeemPrice,
    nextDepId' = nextDepId,
    nextRedId' = nextRedId,
    shares' = shares,
  }

  /// AsyncRequestManager.requestDeposit — escrow assets, pending += assets.
  action requestDeposit(u: int, assets: int): bool = all {
    USERS.contains(u),
    AMOUNTS.contains(assets),
    canRequest(assets),
    nextDepId < 3,
    // one open pending deposit request slot per id
    depReq.get(nextDepId).phase == Empty,
    depReq' = depReq.put(nextDepId, applyRequest(u, assets)),
    assetEscrow' = assetEscrow + assets,
    nextDepId' = nextDepId + 1,
    shareSupply' = shareSupply,
    nav' = nav,
    redReq' = redReq,
    maxMint' = maxMint,
    maxWithdraw' = maxWithdraw,
    depositPrice' = depositPrice,
    redeemPrice' = redeemPrice,
    nextRedId' = nextRedId,
    shares' = shares,
  }

  /// fulfillDepositRequest — issuer approves; sets claimable shares at execution price.
  /// Execution price may differ from published nav (issuer discretion — profile residue).
  action fulfillDeposit(id: int, execPrice: int): bool = {
    val r = depReq.get(id)
    val sh = sharesFromNav(r.amount, execPrice, SCALE)
    all {
      REQ_IDS.contains(id),
      id < nextDepId,
      r.phase == Pending,
      PRICES.contains(execPrice),
      sh > 0,
      depReq' = depReq.put(id, applyPrice(r, execPrice)),
      maxMint' = maxMint.put(r.owner, maxMint.get(r.owner) + sh),
      depositPrice' = depositPrice.put(r.owner, execPrice),
      shareSupply' = shareSupply,
      assetEscrow' = assetEscrow,
      nav' = nav,
      redReq' = redReq,
      maxWithdraw' = maxWithdraw,
      redeemPrice' = redeemPrice,
      nextDepId' = nextDepId,
      nextRedId' = nextRedId,
      shares' = shares,
    }
  }

  /// deposit/mint claim — user takes up to maxMint shares.
  action claimDeposit(u: int, sh: int): bool = all {
    USERS.contains(u),
    AMOUNTS.contains(sh),
    sh > 0,
    maxMint.get(u) >= sh,
    maxMint' = maxMint.put(u, maxMint.get(u) - sh),
    shares' = shares.put(u, shares.get(u) + sh),
    shareSupply' = applyMintSupply(shareSupply, sh),
    assetEscrow' = assetEscrow, // assets stay in pool balance sheet
    nav' = nav,
    depReq' = depReq,
    redReq' = redReq,
    maxWithdraw' = maxWithdraw,
    depositPrice' = depositPrice,
    redeemPrice' = redeemPrice,
    nextDepId' = nextDepId,
    nextRedId' = nextRedId,
  }

  /// requestRedeem — lock shares into escrow (pending redeem).
  action requestRedeem(u: int, sh: int): bool = all {
    USERS.contains(u),
    AMOUNTS.contains(sh),
    sh > 0,
    shares.get(u) >= sh,
    nextRedId < 3,
    redReq.get(nextRedId).phase == Empty,
    redReq' = redReq.put(nextRedId, applyRequest(u, sh)),
    shares' = shares.put(u, shares.get(u) - sh),
    nextRedId' = nextRedId + 1,
    shareSupply' = shareSupply, // burned at fulfill/revoke in real code; hold until fulfill
    assetEscrow' = assetEscrow,
    nav' = nav,
    depReq' = depReq,
    maxMint' = maxMint,
    maxWithdraw' = maxWithdraw,
    depositPrice' = depositPrice,
    redeemPrice' = redeemPrice,
    nextDepId' = nextDepId,
  }

  /// fulfillRedeemRequest — issuer sets assets claimable; burns shares.
  action fulfillRedeem(id: int, execPrice: int): bool = {
    val r = redReq.get(id)
    val assets = assetsFromNav(r.amount, execPrice, SCALE)
    all {
      REQ_IDS.contains(id),
      id < nextRedId,
      r.phase == Pending,
      PRICES.contains(execPrice),
      assets > 0,
      canBurnSupply(shareSupply, r.amount),
      redReq' = redReq.put(id, applyPrice(r, execPrice)),
      maxWithdraw' = maxWithdraw.put(r.owner, maxWithdraw.get(r.owner) + assets),
      redeemPrice' = redeemPrice.put(r.owner, execPrice),
      shareSupply' = applyBurnSupply(shareSupply, r.amount),
      assetEscrow' = assetEscrow,
      nav' = nav,
      depReq' = depReq,
      maxMint' = maxMint,
      depositPrice' = depositPrice,
      nextDepId' = nextDepId,
      nextRedId' = nextRedId,
      shares' = shares,
    }
  }

  /// redeem claim — user withdraws assets up to maxWithdraw.
  action claimRedeem(u: int, assets: int): bool = all {
    USERS.contains(u),
    AMOUNTS.contains(assets),
    assets > 0,
    maxWithdraw.get(u) >= assets,
    assetEscrow >= assets,
    maxWithdraw' = maxWithdraw.put(u, maxWithdraw.get(u) - assets),
    assetEscrow' = assetEscrow - assets,
    shareSupply' = shareSupply,
    nav' = nav,
    depReq' = depReq,
    redReq' = redReq,
    maxMint' = maxMint,
    depositPrice' = depositPrice,
    redeemPrice' = redeemPrice,
    nextDepId' = nextDepId,
    nextRedId' = nextRedId,
    shares' = shares,
  }

  action step: bool = any {
    nondet p = PRICES.oneOf()
    postNav(p, 1),
    nondet u = USERS.oneOf()
    nondet a = AMOUNTS.oneOf()
    requestDeposit(u, a),
    nondet i = REQ_IDS.oneOf()
    nondet ep = PRICES.oneOf()
    fulfillDeposit(i, ep),
    nondet u2 = USERS.oneOf()
    nondet s = AMOUNTS.oneOf()
    claimDeposit(u2, s),
    nondet u3 = USERS.oneOf()
    nondet s2 = AMOUNTS.oneOf()
    requestRedeem(u3, s2),
    nondet j = REQ_IDS.oneOf()
    nondet ep2 = PRICES.oneOf()
    fulfillRedeem(j, ep2),
    nondet u4 = USERS.oneOf()
    nondet a2 = AMOUNTS.oneOf()
    claimRedeem(u4, a2),
  }

  /// Share supply equals sum of user balances + shares locked in pending redeem
  /// that are not yet fulfilled (still in redReq Pending).
  val shareConservation: bool = {
    val userSum = mapSum(shares, USERS)
    val pendingRed = REQ_IDS.fold(0, (acc, id) => {
      val r = redReq.get(id)
      if (r.phase == Pending) acc + r.amount else acc
    })
    shareSupply == userSum + pendingRed
      and shareSupply >= 0
      and assetEscrow >= 0
      and nonNegMap(shares, USERS)
      and nonNegMap(maxMint, USERS)
      and nonNegMap(maxWithdraw, USERS)
  }

  /// Claimable mint never negative; nav posted positive after init.
  val navPositive: bool = nav.value > 0
}
