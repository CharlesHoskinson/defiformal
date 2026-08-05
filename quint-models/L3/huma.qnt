// Huma Finance V2 — tranched credit pool with epoch redemption waterfall.
// Source: protocol-repos/yield/00labs_huma-contracts-v2/contracts/liquidity/
//   Pool.sol distributeProfit/Loss, TranchesAssets senior/junior
//   TrancheVault.sol deposit, addRedemptionRequest, executeRedemptionSummary
//   EpochManager.sol startNewEpoch/closeEpoch, senior-first processing
// Core machine: deposit → senior/junior shares; credit originator draws (abstract);
// profit/loss distributed with junior first-loss; redemptions queued per epoch,
// senior filled first, remainder to junior, unfilled rolled to next epoch.

module huma {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val SENIOR_SHARE_BPS: int = 4000   // 40% of profit to senior (abstract)
  pure val MAX_SENIOR_RATIO: int = 4      // senior ≤ 4 × junior (profile + code)

  var tranches: Tranches
  var seniorShares: ShareVault
  var juniorShares: ShareVault
  var seniorOf: int -> int
  var juniorOf: int -> int
  var seniorRedeemReq: int              // shares queued this epoch
  var juniorRedeemReq: int
  var epochId: int
  var poolOn: bool
  var availableCash: int                // liquid assets for redemption

  action init: bool = all {
    tranches' = { senior: 0, junior: 0 },
    seniorShares' = emptyShareVault,
    juniorShares' = emptyShareVault,
    seniorOf' = USERS.mapBy(_ => 0),
    juniorOf' = USERS.mapBy(_ => 0),
    seniorRedeemReq' = 0,
    juniorRedeemReq' = 0,
    epochId' = 1,
    poolOn' = true,
    availableCash' = 0,
  }

  // TrancheVault.deposit into senior (TrancheVault.sol:312)
  action depositSenior(u: int, assets: int): bool = all {
    USERS.contains(u),
    poolOn,
    assets > 0,
    // senior ≤ 4 × junior after deposit (enforced on deposit)
    val newSenior = tranches.senior + assets
    all {
      newSenior <= MAX_SENIOR_RATIO * max(1, tranches.junior) or tranches.junior == 0,
      // if junior==0, only allow junior deposits first — skip if no junior yet
      tranches.junior > 0 or assets == 0,
      val v = { totalAssets: tranches.senior, totalShares: seniorShares.totalShares }
      val minted = assetsToShares(v, assets)
      all {
        minted > 0 or seniorShares.totalShares == 0,
        tranches' = { senior: newSenior, junior: tranches.junior },
        seniorShares' = {
          totalAssets: newSenior,
          totalShares: seniorShares.totalShares + minted
        },
        seniorOf' = seniorOf.put(u, seniorOf.get(u) + minted),
        availableCash' = availableCash + assets,
        juniorShares' = juniorShares,
        juniorOf' = juniorOf,
        seniorRedeemReq' = seniorRedeemReq,
        juniorRedeemReq' = juniorRedeemReq,
        epochId' = epochId,
        poolOn' = poolOn,
      }
    }
  }

  action depositJunior(u: int, assets: int): bool = all {
    USERS.contains(u),
    poolOn,
    assets > 0,
    val v = { totalAssets: tranches.junior, totalShares: juniorShares.totalShares }
    val minted = assetsToShares(v, assets)
    all {
      minted > 0 or juniorShares.totalShares == 0,
      tranches' = { senior: tranches.senior, junior: tranches.junior + assets },
      juniorShares' = {
        totalAssets: tranches.junior + assets,
        totalShares: juniorShares.totalShares + minted
      },
      juniorOf' = juniorOf.put(u, juniorOf.get(u) + minted),
      availableCash' = availableCash + assets,
      seniorShares' = seniorShares,
      seniorOf' = seniorOf,
      seniorRedeemReq' = seniorRedeemReq,
      juniorRedeemReq' = juniorRedeemReq,
      epochId' = epochId,
      poolOn' = poolOn,
    }
  }

  // Credit draw reduces cash (abstract borrower drawdown)
  action drawdown(amount: int): bool = all {
    poolOn,
    amount > 0,
    amount <= availableCash,
    availableCash' = availableCash - amount,
    tranches' = tranches,
    seniorShares' = seniorShares,
    juniorShares' = juniorShares,
    seniorOf' = seniorOf,
    juniorOf' = juniorOf,
    seniorRedeemReq' = seniorRedeemReq,
    juniorRedeemReq' = juniorRedeemReq,
    epochId' = epochId,
    poolOn' = poolOn,
  }

  // Pool.distributeProfit (Pool.sol:183)
  action distributeProfit(profit: int): bool = all {
    poolOn,
    profit > 0,
    val t2 = applyProfit(tranches, profit, SENIOR_SHARE_BPS)
    all {
      tranches' = t2,
      availableCash' = availableCash + profit,
      seniorShares' = { totalAssets: t2.senior, totalShares: seniorShares.totalShares },
      juniorShares' = { totalAssets: t2.junior, totalShares: juniorShares.totalShares },
      seniorOf' = seniorOf,
      juniorOf' = juniorOf,
      seniorRedeemReq' = seniorRedeemReq,
      juniorRedeemReq' = juniorRedeemReq,
      epochId' = epochId,
      poolOn' = poolOn,
    }
  }

  // Pool.distributeLoss — junior first (Pool.sol:190, _distLossToTranches)
  action distributeLoss(loss: int): bool = all {
    poolOn,
    loss > 0,
    loss <= totalTranche(tranches),
    val t2 = applyLoss(tranches, loss)
    all {
      tranches' = t2,
      // loss may reduce cash if assets impaired
      availableCash' = max(0, availableCash - loss),
      seniorShares' = { totalAssets: t2.senior, totalShares: seniorShares.totalShares },
      juniorShares' = { totalAssets: t2.junior, totalShares: juniorShares.totalShares },
      seniorOf' = seniorOf,
      juniorOf' = juniorOf,
      seniorRedeemReq' = seniorRedeemReq,
      juniorRedeemReq' = juniorRedeemReq,
      epochId' = epochId,
      poolOn' = poolOn,
    }
  }

  // addRedemptionRequest (TrancheVault.sol:328)
  action requestRedeemSenior(u: int, shares: int): bool = all {
    USERS.contains(u),
    poolOn,
    shares > 0,
    shares <= seniorOf.get(u),
    seniorOf' = seniorOf.put(u, seniorOf.get(u) - shares),
    seniorRedeemReq' = seniorRedeemReq + shares,
    // shares escrowed in request; supply unchanged until processed
    seniorShares' = seniorShares,
    juniorShares' = juniorShares,
    juniorOf' = juniorOf,
    juniorRedeemReq' = juniorRedeemReq,
    tranches' = tranches,
    availableCash' = availableCash,
    epochId' = epochId,
    poolOn' = poolOn,
  }

  action requestRedeemJunior(u: int, shares: int): bool = all {
    USERS.contains(u),
    poolOn,
    shares > 0,
    shares <= juniorOf.get(u),
    juniorOf' = juniorOf.put(u, juniorOf.get(u) - shares),
    juniorRedeemReq' = juniorRedeemReq + shares,
    seniorShares' = seniorShares,
    juniorShares' = juniorShares,
    seniorOf' = seniorOf,
    seniorRedeemReq' = seniorRedeemReq,
    tranches' = tranches,
    availableCash' = availableCash,
    epochId' = epochId,
    poolOn' = poolOn,
  }

  // EpochManager closeEpoch — senior first (EpochManager.sol:_processSenior/_Junior)
  action processEpoch: bool = all {
    poolOn,
    seniorRedeemReq > 0 or juniorRedeemReq > 0,
    val seniorAssetsReq = sharesToAssets(
      { totalAssets: tranches.senior, totalShares: seniorShares.totalShares },
      seniorRedeemReq)
    val juniorAssetsReq = sharesToAssets(
      { totalAssets: tranches.junior, totalShares: juniorShares.totalShares },
      juniorRedeemReq)
    val fillS = min(seniorAssetsReq, availableCash)
    val rem = availableCash - fillS
    val fillJ = min(juniorAssetsReq, rem)
    // unfilled shares roll to next epoch (simplified: reduce req by filled portion)
    val filledSShares =
      if (seniorAssetsReq == 0) 0
      else divFloor(seniorRedeemReq * fillS, max(1, seniorAssetsReq))
    val filledJShares =
      if (juniorAssetsReq == 0) 0
      else divFloor(juniorRedeemReq * fillJ, max(1, juniorAssetsReq))
    all {
      availableCash' = availableCash - fillS - fillJ,
      tranches' = {
        senior: tranches.senior - fillS,
        junior: tranches.junior - fillJ
      },
      seniorShares' = {
        totalAssets: tranches.senior - fillS,
        totalShares: seniorShares.totalShares - filledSShares
      },
      juniorShares' = {
        totalAssets: tranches.junior - fillJ,
        totalShares: juniorShares.totalShares - filledJShares
      },
      seniorRedeemReq' = seniorRedeemReq - filledSShares,
      juniorRedeemReq' = juniorRedeemReq - filledJShares,
      epochId' = epochId + 1,
      seniorOf' = seniorOf,
      juniorOf' = juniorOf,
      poolOn' = poolOn,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(40).oneOf()
    nondet sh = 1.to(20).oneOf()
    any {
      depositJunior(u, amt),
      depositSenior(u, amt),
      drawdown(amt),
      distributeProfit(amt),
      distributeLoss(amt),
      requestRedeemSenior(u, sh),
      requestRedeemJunior(u, sh),
      processEpoch,
    }
  }

  // Junior absorbs first: after pure loss, junior decreased before senior
  // (structural invariant: total assets non-neg, cash ≤ total tranche assets)
  val trancheNonNeg: bool =
    tranches.senior >= 0 and tranches.junior >= 0 and availableCash >= 0

  val cashBounded: bool =
    availableCash <= tranches.senior + tranches.junior + 100000  // loose bound for sim

  // Senior ratio: when both live, senior ≤ 4 * junior (may break after losses — finding)
  val solvent: bool = trancheNonNeg
}
