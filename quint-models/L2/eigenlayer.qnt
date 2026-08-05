// EigenLayer — deposit shares, operator allocation magnitude budget, slashing.
// Sources:
//   Layr-Labs_eigenlayer-contracts/src/contracts/strategies/StrategyBase.sol
//     deposit (98), withdraw (137), totalShares, virtual offsets
//   .../core/AllocationManager.sol
//     slashOperator (61), magnitude accounting, INITIAL_TOTAL_MAGNITUDE
//   .../core/DelegationManager.sol — delegateTo (liability only)
// Scope: single strategy, deposit/withdraw shares, operator maxMagnitude budget,
//        allocate, slash reduces maxMagnitude + shares.
// NOT covered: EigenPod proofs, multichain, rewards, AVS registration, deallocation delays.

module eigenlayer {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val OPERATORS: Set[int] = Set(10, 11)
  pure val INITIAL_MAGNITUDE: int = 1000
  pure val SHARES_OFFSET: int = 1
  pure val BALANCE_OFFSET: int = 1

  var underlying: int
  var totalShares: int
  var userShares: int -> int
  var delegatedTo: int -> int
  var maxMagnitude: int -> int
  var encumbered: int -> int
  var queuedShares: int
  var burnedShares: int

  pure def underlyingToShares(amount: int, priorShares: int, priorBal: int): int =
    (amount * (priorShares + SHARES_OFFSET)) / (priorBal + BALANCE_OFFSET)

  pure def sharesToUnderlying(sh: int, ts: int, bal: int): int =
    if (ts + SHARES_OFFSET == 0) 0
    else (sh * (bal + BALANCE_OFFSET)) / (ts + SHARES_OFFSET)

  action init: bool = all {
    underlying' = 0,
    totalShares' = 0,
    userShares' = USERS.mapBy(_ => 0),
    delegatedTo' = USERS.mapBy(_ => 0),
    maxMagnitude' = OPERATORS.mapBy(_ => INITIAL_MAGNITUDE),
    encumbered' = OPERATORS.mapBy(_ => 0),
    queuedShares' = 0,
    burnedShares' = 0,
  }

  action deposit(u: int, amount: int): bool = {
    val newSh = underlyingToShares(amount, totalShares, underlying)
    all {
      USERS.contains(u),
      amount > 0,
      newSh > 0,
      underlying' = underlying + amount,
      totalShares' = totalShares + newSh,
      userShares' = userShares.put(u, userShares.get(u) + newSh),
      delegatedTo' = delegatedTo,
      maxMagnitude' = maxMagnitude,
      encumbered' = encumbered,
      queuedShares' = queuedShares,
      burnedShares' = burnedShares,
    }
  }

  /// delegateTo — transfers slashing liability, not custody
  action delegate(u: int, op: int): bool = all {
    USERS.contains(u),
    OPERATORS.contains(op),
    userShares.get(u) > 0,
    delegatedTo' = delegatedTo.put(u, op),
    underlying' = underlying,
    totalShares' = totalShares,
    userShares' = userShares,
    maxMagnitude' = maxMagnitude,
    encumbered' = encumbered,
    queuedShares' = queuedShares,
    burnedShares' = burnedShares,
  }

  action allocate(op: int, mag: int): bool = all {
    OPERATORS.contains(op),
    mag > 0,
    encumbered.get(op) + mag <= maxMagnitude.get(op),
    encumbered' = encumbered.put(op, encumbered.get(op) + mag),
    underlying' = underlying,
    totalShares' = totalShares,
    userShares' = userShares,
    delegatedTo' = delegatedTo,
    maxMagnitude' = maxMagnitude,
    queuedShares' = queuedShares,
    burnedShares' = burnedShares,
  }

  /// slashOperator — AllocationManager._slashOperator
  action slash(op: int, proportion: int): bool = {
    val maxM = maxMagnitude.get(op)
    val slashMag = (maxM * proportion) / WAD
    val delegatedShares = USERS.fold(0, (acc, u) =>
      if (delegatedTo.get(u) == op) acc + userShares.get(u) else acc)
    val burn = if (maxM == 0) 0 else (delegatedShares * slashMag) / maxM
    val assetOut = sharesToUnderlying(burn, totalShares, underlying)
    val newEnc = if (encumbered.get(op) >= slashMag) encumbered.get(op) - slashMag else 0
    all {
      OPERATORS.contains(op),
      proportion > 0,
      proportion <= WAD,
      slashMag > 0,
      maxM >= slashMag,
      maxMagnitude' = maxMagnitude.put(op, maxM - slashMag),
      encumbered' = encumbered.put(op, newEnc),
      userShares' = USERS.mapBy(u =>
        if (delegatedTo.get(u) == op and delegatedShares > 0)
          userShares.get(u) - (userShares.get(u) * slashMag) / maxM
        else userShares.get(u)),
      totalShares' = totalShares - burn,
      underlying' = if (underlying >= assetOut) underlying - assetOut else 0,
      burnedShares' = burnedShares + burn,
      delegatedTo' = delegatedTo,
      queuedShares' = queuedShares,
    }
  }

  action queueWithdraw(u: int, sh: int): bool = {
    val assetOut = sharesToUnderlying(sh, totalShares, underlying)
    all {
      USERS.contains(u),
      sh > 0,
      userShares.get(u) >= sh,
      userShares' = userShares.put(u, userShares.get(u) - sh),
      queuedShares' = queuedShares + sh,
      totalShares' = totalShares - sh,
      underlying' = if (underlying >= assetOut) underlying - assetOut else 0,
      delegatedTo' = delegatedTo,
      maxMagnitude' = maxMagnitude,
      encumbered' = encumbered,
      burnedShares' = burnedShares,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet op = OPERATORS.oneOf()
    nondet amount = 1.to(40).oneOf()
    nondet mag = 1.to(200).oneOf()
    nondet prop = 1.to(WAD).oneOf()
    nondet sh = 1.to(20).oneOf()
    any {
      deposit(u, amount),
      delegate(u, op),
      allocate(op, mag),
      slash(op, prop),
      queueWithdraw(u, sh),
    }
  }

  val magnitudeBudget: bool =
    OPERATORS.forall(op => encumbered.get(op) <= maxMagnitude.get(op))

  val magnitudeBounded: bool =
    OPERATORS.forall(op =>
      maxMagnitude.get(op) >= 0 and maxMagnitude.get(op) <= INITIAL_MAGNITUDE)

  val nonNegative: bool = and {
    underlying >= 0,
    totalShares >= 0,
    queuedShares >= 0,
    burnedShares >= 0,
    nonNegMap(userShares, USERS),
    OPERATORS.forall(op => encumbered.get(op) >= 0),
  }

  val safety: bool = and {
    magnitudeBudget,
    magnitudeBounded,
    nonNegative,
  }
}
