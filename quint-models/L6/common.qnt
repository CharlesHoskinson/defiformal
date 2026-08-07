// L6 shared primitives — empirical recurrences across reserve-backed stablecoins
// (fiat) and prediction markets (pred). Instantiated by protocol modules in this lane.
//
// Source traces:
//   FiatTokenV1 mint/burn/blacklist  — circlefin_stablecoin-evm/contracts/v1/FiatTokenV1.sol
//   TetherToken issue/redeem/destroy — tethercoin_USDT/TetherToken.sol
//   PaxosTokenV2 freeze/wipe + SupplyControl rate limit
//     — paxosglobal_paxos-token-contracts/contracts/PaxosTokenV2.sol
//     — .../contracts/lib/RateLimit.sol
//   Grove RateLimits linear refill  — grove-labs_grove-alm-controller/src/RateLimits.sol
//   Polymarket CTF split/merge/redeem — Polymarket_ctf-exchange-v2 adapters + UMA payouts
//   Azuro LP + condition reinforcement — Azuro-v2-public contracts/LP.sol, CoreBase.sol

module common {

  // ---------------------------------------------------------------------------
  // Arithmetic helpers
  // ---------------------------------------------------------------------------

  pure def min(a: int, b: int): int = if (a < b) a else b
  pure def max(a: int, b: int): int = if (a > b) a else b

  pure def mulDivDown(a: int, b: int, d: int): int =
    if (d <= 0) 0 else (a * b) / d

  pure def sumMap(m: str -> int, addrs: Set[str]): int =
    addrs.fold(0, (acc, k) => acc + m.get(k))

  // ---------------------------------------------------------------------------
  // Candidate primitive: BALANCE_LEDGER (fungible token accounting)
  // ERC20 balances + totalSupply; transfer conserves totalSupply.
  // Instantiated by: USDT, USDC, USDG, PYUSD, Polymarket collateral, Azuro LP asset.
  // ---------------------------------------------------------------------------

  pure def canTransfer(
    balances: str -> int, src: str, dst: str, amount: int
  ): bool =
    amount > 0 and src != dst and balances.get(src) >= amount

  pure def applyTransfer(
    balances: str -> int, src: str, dst: str, amount: int
  ): str -> int =
    balances
      .setBy(src, b => b - amount)
      .setBy(dst, b => b + amount)

  pure def canMintTo(balances: str -> int, dst: str, amount: int): bool =
    amount > 0

  pure def applyMint(
    balances: str -> int, totalSupply: int, dst: str, amount: int
  ): (str -> int, int) =
    (balances.setBy(dst, b => b + amount), totalSupply + amount)

  pure def canBurnFrom(balances: str -> int, src: str, amount: int): bool =
    amount > 0 and balances.get(src) >= amount

  pure def applyBurn(
    balances: str -> int, totalSupply: int, src: str, amount: int
  ): (str -> int, int) =
    (balances.setBy(src, b => b - amount), totalSupply - amount)

  /// Conservation: sum of balances equals totalSupply (no fee drain).
  pure def supplyConserved(
    balances: str -> int, addrs: Set[str], totalSupply: int
  ): bool =
    sumMap(balances, addrs) == totalSupply

  // ---------------------------------------------------------------------------
  // Candidate primitive: RESTRICTED_ADDRESS (Fz / Aw interaction)
  // Blacklist (USDC, USDT) or freeze (Paxos USDG/PYUSD): blocks transfer.
  // Distinct wipe semantics live in protocol modules.
  // ---------------------------------------------------------------------------

  pure def isRestricted(restricted: str -> bool, addr: str): bool =
    restricted.get(addr)

  pure def eitherRestricted(
    restricted: str -> bool, a: str, b: str
  ): bool =
    restricted.get(a) or restricted.get(b)

  pure def setRestricted(
    restricted: str -> bool, addr: str, flag: bool
  ): str -> bool =
    restricted.put(addr, flag)

  // ---------------------------------------------------------------------------
  // Candidate primitive: MINTER_ALLOWANCE (delegated quantity mint)
  // USDC: masterMinter configures minterAllowed[minter]; mint consumes allowance.
  // FiatTokenV1.sol L121–145, L329–338.
  // ---------------------------------------------------------------------------

  pure def canMintWithAllowance(
    isMinter: str -> bool, allowance: str -> int,
    minter: str, amount: int
  ): bool =
    isMinter.get(minter) and amount > 0 and allowance.get(minter) >= amount

  pure def consumeAllowance(
    allowance: str -> int, minter: str, amount: int
  ): str -> int =
    allowance.setBy(minter, a => a - amount)

  // ---------------------------------------------------------------------------
  // Candidate primitive: LINEAR_REFILL_RATE_LIMIT (flow limiter)
  // Paxos RateLimit.sol (refillPerSecond, remainingAmount, limitCapacity)
  // Grove RateLimits.sol (slope * dt + lastAmount, capped at maxAmount)
  // Same math: current = min(capacity, remaining + slope * elapsed).
  // ---------------------------------------------------------------------------

  type RateLimit = {
    capacity: int,     // max remaining
    remaining: int,    // current remaining budget
    slope: int,        // units refilled per time step
    lastTime: int,     // last update timestamp
  }

  pure def currentLimit(rl: RateLimit, t: int): int = {
    if (rl.capacity <= 0) 0
    else if (rl.slope <= 0) rl.remaining
    else {
      val elapsed = if (t >= rl.lastTime) t - rl.lastTime else 0
      min(rl.capacity, rl.remaining + rl.slope * elapsed)
    }
  }

  pure def canConsume(rl: RateLimit, t: int, amount: int): bool =
    amount > 0 and currentLimit(rl, t) >= amount

  pure def consumeLimit(rl: RateLimit, t: int, amount: int): RateLimit = {
    val cur = currentLimit(rl, t)
    { ...rl, remaining: cur - amount, lastTime: t }
  }

  pure def refundLimit(rl: RateLimit, t: int, amount: int): RateLimit = {
    val cur = currentLimit(rl, t)
    { ...rl, remaining: min(rl.capacity, cur + amount), lastTime: t }
  }

  // ---------------------------------------------------------------------------
  // Candidate primitive: COMPLEMENTARY_OUTCOME_SPLIT (prediction CTF)
  // Polymarket / Gnosis CTF: collateral → equal YES + NO position tokens.
  // merge reverses; redeem after resolution pays payout[i] * amount.
  // CtfCollateralAdapter.splitPosition / mergePositions / redeemPositions.
  // UMA PayoutHelperLib: valid binary payouts [1,0], [0,1], or [1,1] (void).
  // ---------------------------------------------------------------------------

  type BinaryPayout = {
    yes: int,   // 0 or 1
    no: int,    // 0 or 1
  }

  pure def validBinaryPayout(p: BinaryPayout): bool =
    (p.yes == 1 and (p.no == 0 or p.no == 1)) or
    (p.yes == 0 and p.no == 1)

  /// Split: lock `amount` collateral, mint `amount` of each outcome.
  pure def canSplit(collateral: int, amount: int): bool =
    amount > 0 and collateral >= amount

  /// Merge: burn equal YES+NO, release collateral.
  pure def canMerge(yesBal: int, noBal: int, amount: int): bool =
    amount > 0 and yesBal >= amount and noBal >= amount

  /// Redeem after resolve: receive amount * payout for held outcomes.
  pure def redeemPayout(yesBal: int, noBal: int, p: BinaryPayout): int =
    yesBal * p.yes + noBal * p.no

  // ---------------------------------------------------------------------------
  // Candidate primitive: BOOKMAKER_POOL_BET (Azuro-style)
  // LP holds free liquidity; condition locks reinforcement; bet locks exposure.
  // payout = amount * odds / ODDS_BASE; resolve settles winner against pool.
  // ---------------------------------------------------------------------------

  pure val ODDS_BASE: int = 10000  // fixed-point odds scale (abstracted)

  pure def betPayout(amount: int, odds: int): int =
    mulDivDown(amount, odds, ODDS_BASE)

  /// Can book if free liquidity covers the marginal exposure increase.
  pure def canBook(
    freeLiquidity: int, amount: int, odds: int, lockedByCondition: int
  ): bool = {
    val payout = betPayout(amount, odds)
    amount > 0 and odds > ODDS_BASE and freeLiquidity + amount >= payout
  }

  // ---------------------------------------------------------------------------
  // Candidate primitive: OFFCHAIN_RESERVE_CLAIM (category essence)
  // On-chain totalSupply is a liability; reserve assets live off-chain.
  // Modelled as an external integer the issuer may update, not enforced by code.
  // Invariant of interest: reserve >= totalSupply (1:1 backing claim).
  // ---------------------------------------------------------------------------

  pure def reserveCovers(reserve: int, totalSupply: int): bool =
    reserve >= totalSupply and reserve >= 0 and totalSupply >= 0
}
