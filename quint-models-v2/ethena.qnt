// Ethena USDe + sUSDe (partial)
// SOURCE: protocol-repos/cdp/ethena-labs_bbp-public-assets/contracts/contracts/{USDe,EthenaMinting,StakedUSDe}.sol
// AUTHORITY 6h MODELLED: minter-only USDe.mint; MINTER/REDEEMER roles; REWARDER transferInRewards
// ABSTRACTED: signed orders, off-chain hedge, block caps, blacklist/cooldown
// AUTHORITY OMITTED: GATEKEEPER disableMintRedeem (use maxMint admin instead)

module ethena {
  pure val OWNER: str = "owner"
  pure val MINTER: str = "minter_bot"
  pure val REDEEMER: str = "redeemer_bot"
  pure val REWARDER: str = "rewarder"
  pure val USERS: Set[str] = Set("alice", "bob")
  pure val ACTORS: Set[str] = Set("owner", "minter_bot", "redeemer_bot", "rewarder", "alice", "bob", "mallory")
  pure val AMOUNTS: Set[int] = Set(10, 50, 100)

  var usdeBal: str -> int
  var collatBal: str -> int
  var protocolCollat: int
  var minter: str
  var totalUSDe: int
  var sShares: str -> int
  var vaultAssets: int
  var totalShares: int
  var maxMint: int
  var lastActor: str
  var lastAction: str

  pure def sumMap(m: str -> int, ks: Set[str]): int =
    ks.fold(0, (acc, k) => acc + m.get(k))

  pure def sharesOut(assets: int, tA: int, tS: int): int =
    if (tS == 0 or tA == 0) assets else (assets * tS) / tA

  pure def assetsOut(shares: int, tA: int, tS: int): int =
    if (tS == 0) 0 else (shares * tA) / tS

  action init: bool = all {
    usdeBal' = ACTORS.mapBy(_ => 0),
    collatBal' = ACTORS.mapBy(a => if (USERS.contains(a)) 200 else 0),
    protocolCollat' = 0,
    minter' = MINTER,
    totalUSDe' = 0,
    sShares' = ACTORS.mapBy(_ => 0),
    vaultAssets' = 0,
    totalShares' = 0,
    maxMint' = 500,
    lastActor' = "",
    lastAction' = "init",
  }

  action setMinter(caller: str, who: str): bool = all {
    caller == OWNER,
    ACTORS.contains(who),
    minter' = who,
    usdeBal' = usdeBal,
    collatBal' = collatBal,
    protocolCollat' = protocolCollat,
    totalUSDe' = totalUSDe,
    sShares' = sShares,
    vaultAssets' = vaultAssets,
    totalShares' = totalShares,
    maxMint' = maxMint,
    lastActor' = caller,
    lastAction' = "setMinter",
  }

  action mintUSDe(caller: str, beneficiary: str, amt: int): bool = all {
    caller == MINTER,
    minter == MINTER,
    USERS.contains(beneficiary),
    AMOUNTS.contains(amt),
    amt <= maxMint,
    collatBal.get(beneficiary) >= amt,
    collatBal' = collatBal.put(beneficiary, collatBal.get(beneficiary) - amt),
    protocolCollat' = protocolCollat + amt,
    usdeBal' = usdeBal.put(beneficiary, usdeBal.get(beneficiary) + amt),
    totalUSDe' = totalUSDe + amt,
    minter' = minter,
    sShares' = sShares,
    vaultAssets' = vaultAssets,
    totalShares' = totalShares,
    maxMint' = maxMint,
    lastActor' = caller,
    lastAction' = "mintUSDe",
  }

  action redeemUSDe(caller: str, benefactor: str, amt: int): bool = all {
    caller == REDEEMER,
    USERS.contains(benefactor),
    AMOUNTS.contains(amt),
    usdeBal.get(benefactor) >= amt,
    protocolCollat >= amt,
    usdeBal' = usdeBal.put(benefactor, usdeBal.get(benefactor) - amt),
    totalUSDe' = totalUSDe - amt,
    protocolCollat' = protocolCollat - amt,
    collatBal' = collatBal.put(benefactor, collatBal.get(benefactor) + amt),
    minter' = minter,
    sShares' = sShares,
    vaultAssets' = vaultAssets,
    totalShares' = totalShares,
    maxMint' = maxMint,
    lastActor' = caller,
    lastAction' = "redeemUSDe",
  }

  action depositStake(caller: str, amt: int): bool = all {
    USERS.contains(caller),
    AMOUNTS.contains(amt),
    usdeBal.get(caller) >= amt,
    usdeBal' = usdeBal.put(caller, usdeBal.get(caller) - amt),
    vaultAssets' = vaultAssets + amt,
    sShares' = sShares.put(caller, sShares.get(caller) + sharesOut(amt, vaultAssets, totalShares)),
    totalShares' = totalShares + sharesOut(amt, vaultAssets, totalShares),
    collatBal' = collatBal,
    protocolCollat' = protocolCollat,
    minter' = minter,
    totalUSDe' = totalUSDe,
    maxMint' = maxMint,
    lastActor' = caller,
    lastAction' = "depositStake",
  }

  action transferInRewards(caller: str, amt: int): bool = all {
    caller == REWARDER,
    AMOUNTS.contains(amt),
    vaultAssets' = vaultAssets + amt,
    totalUSDe' = totalUSDe + amt,
    usdeBal' = usdeBal,
    collatBal' = collatBal,
    protocolCollat' = protocolCollat,
    minter' = minter,
    sShares' = sShares,
    totalShares' = totalShares,
    maxMint' = maxMint,
    lastActor' = caller,
    lastAction' = "transferInRewards",
  }

  action unstake(caller: str, sh: int): bool = all {
    USERS.contains(caller),
    AMOUNTS.contains(sh),
    sShares.get(caller) >= sh,
    totalShares >= sh,
    vaultAssets >= assetsOut(sh, vaultAssets, totalShares),
    sShares' = sShares.put(caller, sShares.get(caller) - sh),
    totalShares' = totalShares - sh,
    vaultAssets' = vaultAssets - assetsOut(sh, vaultAssets, totalShares),
    usdeBal' = usdeBal.put(caller, usdeBal.get(caller) + assetsOut(sh, vaultAssets, totalShares)),
    collatBal' = collatBal,
    protocolCollat' = protocolCollat,
    minter' = minter,
    totalUSDe' = totalUSDe,
    maxMint' = maxMint,
    lastActor' = caller,
    lastAction' = "unstake",
  }

  val inv_usde_accounting: bool =
    sumMap(usdeBal, ACTORS) + vaultAssets == totalUSDe
  val inv_mint_authority: bool =
    lastAction != "mintUSDe" or lastActor == MINTER
  val inv_reward_authority: bool =
    lastAction != "transferInRewards" or lastActor == REWARDER
  val inv_all: bool =
    inv_usde_accounting and inv_mint_authority and inv_reward_authority

  action step: bool = any {
    nondet c = ACTORS.oneOf(); nondet w = ACTORS.oneOf(); setMinter(c, w),
    nondet c = ACTORS.oneOf(); nondet b = USERS.oneOf(); nondet a = AMOUNTS.oneOf(); mintUSDe(c, b, a),
    nondet c = ACTORS.oneOf(); nondet b = USERS.oneOf(); nondet a = AMOUNTS.oneOf(); redeemUSDe(c, b, a),
    nondet c = USERS.oneOf(); nondet a = AMOUNTS.oneOf(); depositStake(c, a),
    nondet c = ACTORS.oneOf(); nondet a = AMOUNTS.oneOf(); transferInRewards(c, a),
    nondet c = USERS.oneOf(); nondet a = AMOUNTS.oneOf(); unstake(c, a),
  }
}
