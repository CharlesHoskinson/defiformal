// Coinbase wrapped tokens (cbBTC-class) — rate-limited mint + pause + freeze.
// Sources:
//   coinbase_wrapped-tokens-os/contracts/wrapped-tokens/MintForwarder.sol
//     mint (L86) rate-limited via RateLimit._replenishAllowance
//   RateLimit.sol: allowances, maxAllowances, intervals (L33-62)
//   FiatTokenProxy — upgradeable centre-tokens duplicate (profile)
// Scope: one minter with rate limit; aggregate supply; blacklist flag on holder.
// Off-chain reserve is NOT in the contract. Pause + freeze are on-chain.
// NOT covered: multi-asset wrappers, jurisdiction gates, proxy admin.

module coinbase {
  import common.* from "./common"

  pure val HOLDERS: Set[int] = Set(1, 2, 3)
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)
  pure val MAX_ALLOWANCE: int = 10

  var wrap: WrapSupply
  var rl: RateLimitState
  var balances: int -> int
  var blacklisted: int -> bool

  action init: bool = all {
    wrap' = emptyWrap,
    rl' = { allowance: MAX_ALLOWANCE, maxAllowance: MAX_ALLOWANCE },
    balances' = HOLDERS.mapBy(_ => 0),
    blacklisted' = HOLDERS.mapBy(_ => false),
  }

  /// MintForwarder.mint — onlyCallers, rate-limited, increases supply + balance.
  action mint(dst: int, amt: int): bool = all {
    HOLDERS.contains(dst),
    AMOUNTS.contains(amt),
    not(blacklisted.get(dst)),
    canMintWrap(wrap, amt),
    canRateLimitedMint(rl, amt),
    wrap' = applyMintWrap(wrap, amt),
    rl' = applyRateLimitedMint(rl, amt),
    balances' = balances.put(dst, balances.get(dst) + amt),
    blacklisted' = blacklisted,
  }

  /// Burn by holder (unwrap path: send back to Coinbase account — abstracted).
  action burn(from: int, amt: int): bool = all {
    HOLDERS.contains(from),
    AMOUNTS.contains(amt),
    not(blacklisted.get(from)),
    balances.get(from) >= amt,
    canBurnWrap(wrap, amt),
    wrap' = applyBurnWrap(wrap, amt),
    balances' = balances.put(from, balances.get(from) - amt),
    rl' = rl,
    blacklisted' = blacklisted,
  }

  /// RateLimit replenish — models interval top-up of minter allowance.
  action replenishAllowance: bool = all {
    rl' = replenish(rl),
    wrap' = wrap,
    balances' = balances,
    blacklisted' = blacklisted,
  }

  /// Pause (Gp) — guardian.
  action setPaused(p: bool): bool = all {
    wrap' = { ...wrap, paused: p },
    rl' = rl,
    balances' = balances,
    blacklisted' = blacklisted,
  }

  /// Freeze / blacklist (Fz) — blocks mint-to and burn-from.
  action setBlacklist(u: int, flagged: bool): bool = all {
    HOLDERS.contains(u),
    blacklisted' = blacklisted.put(u, flagged),
    wrap' = wrap,
    rl' = rl,
    balances' = balances,
  }

  action step: bool = any {
    nondet t = HOLDERS.oneOf()
    nondet a = AMOUNTS.oneOf()
    mint(t, a),
    nondet f = HOLDERS.oneOf()
    nondet b = AMOUNTS.oneOf()
    burn(f, b),
    replenishAllowance,
    setPaused(true),
    setPaused(false),
    nondet u = HOLDERS.oneOf()
    setBlacklist(u, true),
    nondet v = HOLDERS.oneOf()
    setBlacklist(v, false),
  }

  /// Conservation: sum of balances equals total supply.
  val supplyEqualsBalances: bool =
    HOLDERS.fold(0, (acc, u) => acc + balances.get(u)) == wrap.totalSupply

  /// Rate limit: allowance never exceeds max and never negative.
  val allowanceBounded: bool =
    rl.allowance >= 0 and rl.allowance <= rl.maxAllowance
}
