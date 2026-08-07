// Yearn Vault V3 — multi-strategy share vault with debt accounting.
// Source: protocol-repos/yield/yearn_yearn-vaults-v3/contracts/VaultV3.vy
//   total_idle, total_debt, strategies HashMap, deposit/redeem,
//   _convert_to_shares/assets, withdraw pulls from strategy queue.
// Core machine: deposit mints shares against total_assets = idle + debt;
// allocate debt to strategies; report profit/loss; redeem burns shares,
// pulling from idle then strategies.

module yearn {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val STRATS: Set[int] = Set(10, 11)   // strategy ids
  pure val MAX_DEBT_BPS: int = 10000

  var vault: ShareVault
  var idle: int
  var debt: int -> int              // per-strategy current_debt
  var sharesOf: int -> int
  var maxDebt: int -> int           // per-strategy debt limit

  pure def totalDebt(d: int -> int): int =
    STRATS.fold(0, (acc, s) => acc + d.get(s))

  pure def totalAssets(idle_: int, d: int -> int): int =
    idle_ + totalDebt(d)

  action init: bool = all {
    vault' = emptyShareVault,
    idle' = 0,
    debt' = STRATS.mapBy(_ => 0),
    sharesOf' = USERS.mapBy(_ => 0),
    maxDebt' = STRATS.mapBy(_ => 5000),
  }

  // deposit (VaultV3.vy:49) — assets stay idle initially
  action deposit(u: int, assets: int): bool = all {
    USERS.contains(u),
    canDeposit(vault, assets),
    val newV = applyDeposit(vault, assets)
    val minted = newV.totalShares - vault.totalShares
    all {
      vault' = { totalAssets: totalAssets(idle + assets, debt), totalShares: newV.totalShares },
      idle' = idle + assets,
      sharesOf' = sharesOf.put(u, sharesOf.get(u) + minted),
      debt' = debt,
      maxDebt' = maxDebt,
    }
  }

  // DEBT_MANAGER: update_debt — move idle → strategy (VaultV3 debt management)
  action allocate(s: int, amount: int): bool = all {
    STRATS.contains(s),
    amount > 0,
    amount <= idle,
    debt.get(s) + amount <= maxDebt.get(s),
    idle' = idle - amount,
    debt' = debt.put(s, debt.get(s) + amount),
    vault' = { totalAssets: totalAssets(idle - amount, debt.put(s, debt.get(s) + amount)),
               totalShares: vault.totalShares },
    sharesOf' = sharesOf,
    maxDebt' = maxDebt,
  }

  // strategy report profit (REPORTING_MANAGER path)
  action reportProfit(s: int, profit: int): bool = all {
    STRATS.contains(s),
    profit > 0,
    debt.get(s) > 0,
    val newDebt = debt.put(s, debt.get(s) + profit)
    all {
      debt' = newDebt,
      vault' = { totalAssets: totalAssets(idle, newDebt), totalShares: vault.totalShares },
      idle' = idle,
      sharesOf' = sharesOf,
      maxDebt' = maxDebt,
    }
  }

  // strategy report loss
  action reportLoss(s: int, loss: int): bool = all {
    STRATS.contains(s),
    loss > 0,
    loss <= debt.get(s),
    val newDebt = debt.put(s, debt.get(s) - loss)
    all {
      debt' = newDebt,
      vault' = { totalAssets: totalAssets(idle, newDebt), totalShares: vault.totalShares },
      idle' = idle,
      sharesOf' = sharesOf,
      maxDebt' = maxDebt,
    }
  }

  // redeem (VaultV3.vy:51) — pull from idle first, then strategies
  action redeem(u: int, shares: int): bool = all {
    USERS.contains(u),
    shares > 0,
    shares <= sharesOf.get(u),
    canRedeem(vault, shares),
    val assets = sharesToAssets(vault, shares)
    all {
      assets <= totalAssets(idle, debt),
      // prefer idle; if short, pull from first strategy with debt
      val fromIdle = min(idle, assets)
      val need = assets - fromIdle
      // abstract: pull need from strategies pro-rata simplified — take from any
      val pullOk = need == 0 or STRATS.exists(s => debt.get(s) >= need)
      all {
        pullOk,
        val sPick = if (need == 0) 10 else 10  // simplified single pull
        val newDebt =
          if (need == 0) debt
          else debt.put(sPick, debt.get(sPick) - need)
        all {
          idle' = idle - fromIdle,  // need was added to idle then paid; net idle -= fromIdle
          // actually: strategy withdraw adds to idle then we pay assets; net idle' = idle - fromIdle
          // and debt reduced by need. After payout idle decreases by assets from the combined pot.
          // Correct: idle becomes idle - fromIdle (need comes from strategy directly to user)
          debt' = newDebt,
          vault' = {
            totalAssets: totalAssets(idle - fromIdle, newDebt),
            totalShares: vault.totalShares - shares
          },
          sharesOf' = sharesOf.put(u, sharesOf.get(u) - shares),
          maxDebt' = maxDebt,
        }
      }
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet s = STRATS.oneOf()
    nondet amt = 1.to(100).oneOf()
    nondet sh = 1.to(50).oneOf()
    any {
      deposit(u, amt),
      allocate(s, amt),
      reportProfit(s, amt),
      reportLoss(s, amt),
      redeem(u, sh),
    }
  }

  // total_assets = idle + sum(debt); vault.totalAssets tracks it
  val assetsMatch: bool =
    vault.totalAssets == idle + totalDebt(debt) and
    vault.totalAssets >= 0 and vault.totalShares >= 0

  // shares outstanding match user balances
  val sharesMatch: bool =
    USERS.fold(0, (acc, u) => acc + sharesOf.get(u)) == vault.totalShares

  // share solvency from common
  val solvent: bool = shareSolvency(vault) and assetsMatch and sharesMatch
}
