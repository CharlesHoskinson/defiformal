// Ondo USDY — RWAHub async subscription / redemption at admin-set price IDs.
// Sources:
//   ondoprotocol_usdy/contracts/RWAHub.sol
//     requestSubscription (L141), claimMint (L193), _claimMint (L207)
//     requestRedemption (L239), claimRedemption (L262)
//     setPriceIdForDeposits (L355), setPriceIdForRedemptions (L380)
//     _getMintAmountForPrice (L689): rwa = deposit * 1e18 / price
//     _getRedemptionAmountForRwa (L705): collateral = rwa * price / 1e18
//   USDY.sol mint/burn (role-gated)
// Scope: one collateral, one rwa supply, discrete price IDs, two-phase mint/redeem.
// NOT covered: allowlist/blocklist/sanctions, instant mints, off-chain redemptions,
//   multi-product (OMMF, tokenised equities), fee recipient paths beyond net amounts.

module ondo {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2)
  pure val REQ_IDS: Set[int] = Set(0, 1, 2)
  pure val AMOUNTS: Set[int] = Set(10, 20, 50)
  pure val PRICES: Set[int] = Set(100, 110, 90)  // scale = 100 means par
  pure val SCALE: int = 100
  pure val MIN_DEPOSIT: int = 10
  pure val MIN_REDEEM: int = 10

  var rwaSupply: int
  var deposits: int -> AsyncRequest
  var redemptions: int -> AsyncRequest
  var nextDepId: int
  var nextRedId: int
  // Collateral held by hub/assetRecipient for open deposit claims not yet minted.
  // Redemption payout comes from assetSender (off-model inventory).
  var collateralEscrow: int
  // Off-model assetSender inventory used to pay redemptions.
  var assetSenderBal: int

  action init: bool = all {
    rwaSupply' = 0,
    deposits' = REQ_IDS.mapBy(_ => emptyAsyncReq),
    redemptions' = REQ_IDS.mapBy(_ => emptyAsyncReq),
    nextDepId' = 0,
    nextRedId' = 0,
    collateralEscrow' = 0,
    assetSenderBal' = 1000,
  }

  /// RWAHub.requestSubscription — transfer collateral in, open Pending deposit.
  action requestSubscription(u: int, amt: int): bool = all {
    USERS.contains(u),
    AMOUNTS.contains(amt),
    amt >= MIN_DEPOSIT,
    canRequest(amt),
    nextDepId < 3,
    deposits' = deposits.put(nextDepId, applyRequest(u, amt)),
    nextDepId' = nextDepId + 1,
    collateralEscrow' = collateralEscrow + amt,
    rwaSupply' = rwaSupply,
    redemptions' = redemptions,
    nextRedId' = nextRedId,
    assetSenderBal' = assetSenderBal,
  }

  /// RWAHub.setPriceIdForDeposits — PRICE_ID_SETTER_ROLE attaches a price.
  action setDepositPrice(id: int, price: int): bool = {
    val r = deposits.get(id)
    all {
      REQ_IDS.contains(id),
      PRICES.contains(price),
      id < nextDepId,
      canPrice(r, price),
      deposits' = deposits.put(id, applyPrice(r, price)),
      rwaSupply' = rwaSupply,
      redemptions' = redemptions,
      nextDepId' = nextDepId,
      nextRedId' = nextRedId,
      collateralEscrow' = collateralEscrow,
      assetSenderBal' = assetSenderBal,
    }
  }

  /// RWAHub._claimMint — mint rwa = deposit * scale / price; clear request.
  action claimMint(id: int): bool = {
    val r = deposits.get(id)
    val minted = sharesFromNav(r.amount, r.price, SCALE)
    all {
      REQ_IDS.contains(id),
      id < nextDepId,
      canClaim(r),
      minted > 0,
      deposits' = deposits.put(id, applyClaim(r)),
      rwaSupply' = applyMintSupply(rwaSupply, minted),
      collateralEscrow' = collateralEscrow, // stays with assetRecipient (off-chain fund)
      redemptions' = redemptions,
      nextDepId' = nextDepId,
      nextRedId' = nextRedId,
      assetSenderBal' = assetSenderBal,
    }
  }

  /// RWAHub.requestRedemption — burn rwa immediately; open Pending redemption.
  action requestRedemption(u: int, shares: int): bool = all {
    USERS.contains(u),
    AMOUNTS.contains(shares),
    shares >= MIN_REDEEM,
    canBurnSupply(rwaSupply, shares),
    nextRedId < 3,
    redemptions' = redemptions.put(nextRedId, applyRequest(u, shares)),
    rwaSupply' = applyBurnSupply(rwaSupply, shares),
    nextRedId' = nextRedId + 1,
    deposits' = deposits,
    nextDepId' = nextDepId,
    collateralEscrow' = collateralEscrow,
    assetSenderBal' = assetSenderBal,
  }

  /// RWAHub.setPriceIdForRedemptions
  action setRedeemPrice(id: int, price: int): bool = {
    val r = redemptions.get(id)
    all {
      REQ_IDS.contains(id),
      PRICES.contains(price),
      id < nextRedId,
      canPrice(r, price),
      redemptions' = redemptions.put(id, applyPrice(r, price)),
      rwaSupply' = rwaSupply,
      deposits' = deposits,
      nextDepId' = nextDepId,
      nextRedId' = nextRedId,
      collateralEscrow' = collateralEscrow,
      assetSenderBal' = assetSenderBal,
    }
  }

  /// RWAHub.claimRedemption — pay collateral = shares * price / scale from assetSender.
  action claimRedemption(id: int): bool = {
    val r = redemptions.get(id)
    val due = assetsFromNav(r.amount, r.price, SCALE)
    all {
      REQ_IDS.contains(id),
      id < nextRedId,
      canClaim(r),
      due > 0,
      assetSenderBal >= due,
      redemptions' = redemptions.put(id, applyClaim(r)),
      assetSenderBal' = assetSenderBal - due,
      rwaSupply' = rwaSupply,
      deposits' = deposits,
      nextDepId' = nextDepId,
      nextRedId' = nextRedId,
      collateralEscrow' = collateralEscrow,
    }
  }

  action step: bool = any {
    nondet u = USERS.oneOf()
    nondet a = AMOUNTS.oneOf()
    requestSubscription(u, a),
    nondet i = REQ_IDS.oneOf()
    nondet p = PRICES.oneOf()
    setDepositPrice(i, p),
    nondet j = REQ_IDS.oneOf()
    claimMint(j),
    nondet u2 = USERS.oneOf()
    nondet s = AMOUNTS.oneOf()
    requestRedemption(u2, s),
    nondet k = REQ_IDS.oneOf()
    nondet p2 = PRICES.oneOf()
    setRedeemPrice(k, p2),
    nondet m = REQ_IDS.oneOf()
    claimRedemption(m),
  }

  /// Supply non-negative; escrow and sender inventory non-negative.
  val balancesNonNeg: bool =
    rwaSupply >= 0 and collateralEscrow >= 0 and assetSenderBal >= 0

  /// Every claimed mint contributed exactly sharesFromNav(amount, price, SCALE).
  /// Open (Pending/Priced) deposits have not yet minted.
  val mintAccounting: bool = {
    val claimedMinted = REQ_IDS.fold(0, (acc, id) => {
      val r = deposits.get(id)
      if (r.phase == Claimed)
        acc + sharesFromNav(r.amount, r.price, SCALE)
      else acc
    })
    val burnedOpen = REQ_IDS.fold(0, (acc, id) => {
      val r = redemptions.get(id)
      // burn happens at request: Pending, Priced, Claimed all burned
      if (r.phase == Pending or r.phase == Priced or r.phase == Claimed)
        acc + r.amount
      else acc
    })
    rwaSupply == claimedMinted - burnedOpen
  }
}
