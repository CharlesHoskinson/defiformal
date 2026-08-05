// Beefy Vault V6 — single-strategy share vault.
// Source: protocol-repos/yield/beefyfinance_beefy-contracts/contracts/archive/vaults/BeefyVaultV6.sol
//   balance() = want in vault + strategy.balanceOf()
//   deposit mints shares = amount * totalSupply / pool
//   withdraw burns shares, strategy.withdraw if needed
//   proposeStrat / upgradeStrat for strategy switch
// Differs from Yearn: exactly one active strategy; no multi-debt map; harvest is strategy-side.

module beefy {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)

  var vault: ShareVault
  var wantInVault: int          // want().balanceOf(vault)
  var wantInStrategy: int       // strategy.balanceOf()
  var sharesOf: int -> int
  var stratCandidate: int       // 0 = none; else proposed strategy id
  var activeStrat: int

  pure def poolBal(v: int, s: int): int = v + s

  action init: bool = all {
    vault' = emptyShareVault,
    wantInVault' = 0,
    wantInStrategy' = 0,
    sharesOf' = USERS.mapBy(_ => 0),
    stratCandidate' = 0,
    activeStrat' = 1,
  }

  // deposit (BeefyVaultV6.sol:102)
  action deposit(u: int, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val pool = poolBal(wantInVault, wantInStrategy)
    val v = { totalAssets: pool, totalShares: vault.totalShares }
    val minted = assetsToShares(v, amount)
    all {
      minted > 0 or vault.totalShares == 0,
      wantInVault' = wantInVault + amount,
      vault' = {
        totalAssets: pool + amount,
        totalShares: vault.totalShares + minted
      },
      sharesOf' = sharesOf.put(u, sharesOf.get(u) + minted),
      wantInStrategy' = wantInStrategy,
      stratCandidate' = stratCandidate,
      activeStrat' = activeStrat,
    }
  }

  // earn — send idle want to strategy (BeefyVaultV6.sol:123)
  action earn: bool = all {
    wantInVault > 0,
    wantInStrategy' = wantInStrategy + wantInVault,
    wantInVault' = 0,
    vault' = vault,
    sharesOf' = sharesOf,
    stratCandidate' = stratCandidate,
    activeStrat' = activeStrat,
  }

  // strategy harvest: compounds want — only meaningful with shareholders
  // (shareSolvency: totalShares==0 ⇒ totalAssets==0; empty vault cannot accrue)
  action harvest(profit: int): bool = all {
    profit > 0,
    vault.totalShares > 0,
    wantInStrategy' = wantInStrategy + profit,
    vault' = {
      totalAssets: poolBal(wantInVault, wantInStrategy + profit),
      totalShares: vault.totalShares
    },
    wantInVault' = wantInVault,
    sharesOf' = sharesOf,
    stratCandidate' = stratCandidate,
    activeStrat' = activeStrat,
  }

  // withdraw (BeefyVaultV6.sol:141)
  action withdraw(u: int, shares: int): bool = all {
    USERS.contains(u),
    shares > 0,
    shares <= sharesOf.get(u),
    shares <= vault.totalShares,
    val pool = poolBal(wantInVault, wantInStrategy)
    val r = divFloor(pool * shares, vault.totalShares)
    all {
      r > 0,
      // if vault balance insufficient, pull from strategy
      val fromVault = min(wantInVault, r)
      val fromStrat = r - fromVault
      all {
        fromStrat <= wantInStrategy,
        wantInVault' = wantInVault - fromVault,
        wantInStrategy' = wantInStrategy - fromStrat,
        vault' = {
          totalAssets: pool - r,
          totalShares: vault.totalShares - shares
        },
        sharesOf' = sharesOf.put(u, sharesOf.get(u) - shares),
        stratCandidate' = stratCandidate,
        activeStrat' = activeStrat,
      }
    }
  }

  // proposeStrat (BeefyVaultV6.sol:163)
  action proposeStrat(id: int): bool = all {
    id > 0,
    id != activeStrat,
    stratCandidate' = id,
    vault' = vault,
    wantInVault' = wantInVault,
    wantInStrategy' = wantInStrategy,
    sharesOf' = sharesOf,
    activeStrat' = activeStrat,
  }

  // upgradeStrat — switch (abstract: no balance move)
  action upgradeStrat: bool = all {
    stratCandidate > 0,
    activeStrat' = stratCandidate,
    stratCandidate' = 0,
    vault' = vault,
    wantInVault' = wantInVault,
    wantInStrategy' = wantInStrategy,
    sharesOf' = sharesOf,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(50).oneOf()
    nondet sh = 1.to(30).oneOf()
    nondet id = Set(2, 3, 4).oneOf()
    any {
      deposit(u, amt),
      earn,
      harvest(amt),
      withdraw(u, sh),
      proposeStrat(id),
      upgradeStrat,
    }
  }

  val balanceMatches: bool =
    vault.totalAssets == poolBal(wantInVault, wantInStrategy) and
    vault.totalAssets >= 0

  val sharesMatch: bool =
    USERS.fold(0, (acc, u) => acc + sharesOf.get(u)) == vault.totalShares

  val solvent: bool = shareSolvency(vault) and balanceMatches and sharesMatch
}
