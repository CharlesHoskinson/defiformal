// Azuro v2 — liquidity pool bookmaker vs discrete conditions.
// Sources:
//   Azuro-protocol_Azuro-v2-public/contracts/LP.sol
//     addLiquidity / withdrawLiquidity / bet / withdrawPayout
//     lockedLiquidity, free liquidity
//   CoreBase.sol / PrematchCore.sol
//     createCondition (reinforcement, odds, fund)
//     putBet, resolveCondition, resolvePayout
// Model: one LP pot, one binary condition, multiple bettors.

module azuro {
  import common.* from "./common"

  pure val USERS: Set[str] = Set("lp", "alice", "bob")
  pure val LP_USER: str = "lp"

  type CondState = Created | Resolved | Canceled

  var freeLiquidity: int       // LP free funds (not locked by conditions)
  var lockedLiquidity: int     // reserved by open conditions (LP.sol L36)
  var lpShares: str -> int     // simplified deposit shares (NFT→fungible here)
  var totalShares: int
  var userCash: str -> int     // off-pool wallet balances

  // Single condition
  var condState: CondState
  var reinforcement: int       // max liquidity reserved for condition
  var oddsYes: int             // fixed odds for YES outcome (ODDS_BASE scale)
  var oddsNo: int
  var fund: int                // condition fund (starts = reinforcement)
  var yesStake: int            // total staked on YES
  var noStake: int
  var yesPayoutLiability: int  // sum of promised payouts on YES
  var noPayoutLiability: int
  var winnerIsYes: bool        // set on resolve
  var betYes: str -> int       // per-user outstanding YES stake
  var betNo: str -> int
  var betPayoutYes: str -> int // promised payout per user if YES wins
  var betPayoutNo: str -> int
  var claimed: str -> bool

  action init: bool = all {
    freeLiquidity' = 0,
    lockedLiquidity' = 0,
    lpShares' = USERS.mapBy(_ => 0),
    totalShares' = 0,
    userCash' = USERS.mapBy(u => if (u == LP_USER) 500 else 100),
    condState' = Created,
    reinforcement' = 0,
    oddsYes' = 20000,  // 2.0x
    oddsNo' = 20000,
    fund' = 0,
    yesStake' = 0,
    noStake' = 0,
    yesPayoutLiability' = 0,
    noPayoutLiability' = 0,
    winnerIsYes' = false,
    betYes' = USERS.mapBy(_ => 0),
    betNo' = USERS.mapBy(_ => 0),
    betPayoutYes' = USERS.mapBy(_ => 0),
    betPayoutNo' = USERS.mapBy(_ => 0),
    claimed' = USERS.mapBy(_ => false),
  }

  /// addLiquidity (LP.sol L255)
  action addLiquidity(user: str, amount: int): bool = all {
    USERS.contains(user),
    amount > 0,
    userCash.get(user) >= amount,
    val shares = if (totalShares == 0) amount
                 else mulDivDown(amount, totalShares, freeLiquidity + lockedLiquidity)
    all {
      shares > 0,
      userCash' = userCash.setBy(user, c => c - amount),
      freeLiquidity' = freeLiquidity + amount,
      lockedLiquidity' = lockedLiquidity,
      lpShares' = lpShares.setBy(user, s => s + shares),
      totalShares' = totalShares + shares,
      condState' = condState,
      reinforcement' = reinforcement,
      oddsYes' = oddsYes,
      oddsNo' = oddsNo,
      fund' = fund,
      yesStake' = yesStake,
      noStake' = noStake,
      yesPayoutLiability' = yesPayoutLiability,
      noPayoutLiability' = noPayoutLiability,
      winnerIsYes' = winnerIsYes,
      betYes' = betYes,
      betNo' = betNo,
      betPayoutYes' = betPayoutYes,
      betPayoutNo' = betPayoutNo,
      claimed' = claimed,
    }
  }

  /// createCondition: lock reinforcement from free liquidity (CoreBase L343+)
  action createCondition(reinf: int): bool = all {
    condState == Created,
    reinforcement == 0,
    reinf > 0,
    freeLiquidity >= reinf,
    freeLiquidity' = freeLiquidity - reinf,
    lockedLiquidity' = lockedLiquidity + reinf,
    lpShares' = lpShares,
    totalShares' = totalShares,
    userCash' = userCash,
    condState' = Created,
    reinforcement' = reinf,
    oddsYes' = oddsYes,
    oddsNo' = oddsNo,
    fund' = reinf,
    yesStake' = 0,
    noStake' = 0,
    yesPayoutLiability' = 0,
    noPayoutLiability' = 0,
    winnerIsYes' = winnerIsYes,
    betYes' = betYes,
    betNo' = betNo,
    betPayoutYes' = betPayoutYes,
    betPayoutNo' = betPayoutNo,
    claimed' = claimed,
  }

  /// putBet on YES (PrematchCore.putBet) — simplified odds fixed
  action betYesAction(user: str, amount: int): bool = all {
    condState == Created,
    reinforcement > 0,
    USERS.contains(user),
    user != LP_USER,
    amount > 0,
    userCash.get(user) >= amount,
    val payout = betPayout(amount, oddsYes)
    // exposure: new YES liability must fit in fund + opposing stakes pattern
    // Azuro locks max(0, maxPayout - (fund - reinforcement contribution))
    // Simplified: free locked headroom covers net exposure increase
    val newYesLiab = yesPayoutLiability + payout
    val exposure = if (newYesLiab > fund + noStake) newYesLiab - fund - noStake else 0
    all {
      lockedLiquidity + freeLiquidity >= exposure, // pool can cover
      payout > amount,
      userCash' = userCash.setBy(user, c => c - amount),
      // stake enters condition fund
      fund' = fund + amount,
      yesStake' = yesStake + amount,
      yesPayoutLiability' = newYesLiab,
      betYes' = betYes.setBy(user, b => b + amount),
      betPayoutYes' = betPayoutYes.setBy(user, p => p + payout),
      freeLiquidity' = freeLiquidity,
      lockedLiquidity' = lockedLiquidity,
      lpShares' = lpShares,
      totalShares' = totalShares,
      condState' = condState,
      reinforcement' = reinforcement,
      oddsYes' = oddsYes,
      oddsNo' = oddsNo,
      noStake' = noStake,
      noPayoutLiability' = noPayoutLiability,
      winnerIsYes' = winnerIsYes,
      betNo' = betNo,
      betPayoutNo' = betPayoutNo,
      claimed' = claimed,
    }
  }

  action betNoAction(user: str, amount: int): bool = all {
    condState == Created,
    reinforcement > 0,
    USERS.contains(user),
    user != LP_USER,
    amount > 0,
    userCash.get(user) >= amount,
    val payout = betPayout(amount, oddsNo)
    val newNoLiab = noPayoutLiability + payout
    val exposure = if (newNoLiab > fund + yesStake) newNoLiab - fund - yesStake else 0
    all {
      lockedLiquidity + freeLiquidity >= exposure,
      payout > amount,
      userCash' = userCash.setBy(user, c => c - amount),
      fund' = fund + amount,
      noStake' = noStake + amount,
      noPayoutLiability' = newNoLiab,
      betNo' = betNo.setBy(user, b => b + amount),
      betPayoutNo' = betPayoutNo.setBy(user, p => p + payout),
      freeLiquidity' = freeLiquidity,
      lockedLiquidity' = lockedLiquidity,
      lpShares' = lpShares,
      totalShares' = totalShares,
      condState' = condState,
      reinforcement' = reinforcement,
      oddsYes' = oddsYes,
      oddsNo' = oddsNo,
      yesStake' = yesStake,
      yesPayoutLiability' = yesPayoutLiability,
      winnerIsYes' = winnerIsYes,
      betYes' = betYes,
      betPayoutYes' = betPayoutYes,
      claimed' = claimed,
    }
  }

  /// resolveCondition: oracle sets winner (PrematchCore.resolveCondition)
  /// Accounting: fund already includes reinforcement (also mirrored in
  /// lockedLiquidity — a view, not extra cash). True assets = free + fund.
  /// free' = free + fund keeps winner liability in the pool for claim();
  /// locked' = 0. Guard: free + fund >= winLiab (pool can pay winners).
  action resolve(yesWins: bool): bool = all {
    condState == Created,
    reinforcement > 0,
    val winLiab = if (yesWins) yesPayoutLiability else noPayoutLiability
    val freeNext = freeLiquidity + fund
    all {
      freeNext >= winLiab,
      freeLiquidity' = freeNext,
      lockedLiquidity' = 0,
      lpShares' = lpShares,
      totalShares' = totalShares,
      userCash' = userCash,
      condState' = Resolved,
      reinforcement' = reinforcement,
      oddsYes' = oddsYes,
      oddsNo' = oddsNo,
      fund' = 0,
      yesStake' = yesStake,
      noStake' = noStake,
      yesPayoutLiability' = yesPayoutLiability,
      noPayoutLiability' = noPayoutLiability,
      winnerIsYes' = yesWins,
      betYes' = betYes,
      betNo' = betNo,
      betPayoutYes' = betPayoutYes,
      betPayoutNo' = betPayoutNo,
      claimed' = claimed,
    }
  }

  /// withdrawPayout for a winning bet (LP.withdrawPayout → resolvePayout)
  action claim(user: str): bool = all {
    condState == Resolved,
    USERS.contains(user),
    not(claimed.get(user)),
    val pay = if (winnerIsYes) betPayoutYes.get(user) else betPayoutNo.get(user)
    all {
      pay > 0,
      // payout already reserved in freeLiquidity at resolve
      freeLiquidity >= pay,
      freeLiquidity' = freeLiquidity - pay,
      lockedLiquidity' = lockedLiquidity,
      lpShares' = lpShares,
      totalShares' = totalShares,
      userCash' = userCash.setBy(user, c => c + pay),
      condState' = condState,
      reinforcement' = reinforcement,
      oddsYes' = oddsYes,
      oddsNo' = oddsNo,
      fund' = fund,
      yesStake' = yesStake,
      noStake' = noStake,
      yesPayoutLiability' = yesPayoutLiability,
      noPayoutLiability' = noPayoutLiability,
      winnerIsYes' = winnerIsYes,
      betYes' = betYes,
      betNo' = betNo,
      betPayoutYes' = betPayoutYes,
      betPayoutNo' = betPayoutNo,
      claimed' = claimed.put(user, true),
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(40).oneOf()
    nondet reinf = 20.to(80).oneOf()
    any {
      addLiquidity(u, amt),
      createCondition(reinf),
      betYesAction(u, amt),
      betNoAction(u, amt),
      resolve(true),
      resolve(false),
      claim(u),
    }
  }

  /// Global conservation.
  /// Open condition: fund holds reinforcement (= locked) + stakes; stakes left
  /// userCash, so free + fund + userCash == 700 (locked is a view of fund.reinf).
  /// Resolved: free holds pool + reserved unclaimed payouts; fund cleared.
  val unclaimedPayouts: int =
    USERS.fold(0, (acc, u) =>
      acc +
        if (claimed.get(u)) 0
        else if (winnerIsYes) betPayoutYes.get(u)
        else betPayoutNo.get(u)
    )

  val inv_global_cash: bool =
    if (condState == Created and reinforcement > 0)
      freeLiquidity + fund + sumMap(userCash, USERS) == 700
    else if (condState == Resolved)
      freeLiquidity + sumMap(userCash, USERS) == 700
    else
      freeLiquidity + lockedLiquidity + sumMap(userCash, USERS) == 700

  val inv_nonneg: bool =
    freeLiquidity >= 0 and lockedLiquidity >= 0 and
    USERS.forall(u => userCash.get(u) >= 0 and lpShares.get(u) >= 0)

  /// After resolve, free must cover remaining unclaimed winner payouts.
  val inv_claims_covered: bool =
    condState != Resolved or freeLiquidity >= unclaimedPayouts
}
