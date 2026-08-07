// Grove ALM Controller — rate-limited allocator of Sky-minted USDS.
// Source: protocol-repos/pred/grove-labs_grove-alm-controller/
//   MainnetController.sol mintUSDS / burnUSDS / transferAsset (L283–332)
//   RateLimits.sol linear refill (getCurrentRateLimit, triggerRateLimitDecrease)
//   ALMProxy.sol stateless proxy holding assets
// Category note: shipped under prediction-markets corpus, but the on-chain
// machine is an ALM / credit-line allocator, not a prediction market.

module grove {
  import common.* from "./common"

  pure val ASSETS: Set[str] = Set("USDS", "USDC", "sUSDS")
  pure val DESTINATIONS: Set[str] = Set("vaultA", "vaultB", "buffer")

  var proxyBal: str -> int
  var usdsDebt: int
  var mintLimit: RateLimit
  var transferLimit: RateLimit
  var clock: int
  var relayerFrozen: bool

  action init: bool = all {
    proxyBal' = ASSETS.mapBy(a => if (a == "USDS") 0 else if (a == "USDC") 100 else 0),
    usdsDebt' = 0,
    mintLimit' = { capacity: 100, remaining: 100, slope: 5, lastTime: 0 },
    transferLimit' = { capacity: 50, remaining: 50, slope: 5, lastTime: 0 },
    clock' = 0,
    relayerFrozen' = false,
  }

  /// mintUSDS: draw from Sky vault into proxy (MainnetController L283–297)
  action mintUSDS(amount: int): bool = all {
    not(relayerFrozen),
    canConsume(mintLimit, clock, amount),
    proxyBal' = proxyBal.setBy("USDS", b => b + amount),
    usdsDebt' = usdsDebt + amount,
    mintLimit' = consumeLimit(mintLimit, clock, amount),
    transferLimit' = transferLimit,
    clock' = clock,
    relayerFrozen' = relayerFrozen,
  }

  /// burnUSDS: return USDS to vault, cancel mint rate limit (L300–314)
  action burnUSDS(amount: int): bool = all {
    not(relayerFrozen),
    amount > 0,
    proxyBal.get("USDS") >= amount,
    usdsDebt >= amount,
    proxyBal' = proxyBal.setBy("USDS", b => b - amount),
    usdsDebt' = usdsDebt - amount,
    mintLimit' = refundLimit(mintLimit, clock, amount),
    transferLimit' = transferLimit,
    clock' = clock,
    relayerFrozen' = relayerFrozen,
  }

  /// transferAsset under per-destination rate limit (L318–332)
  action transferAsset(asset: str, dest: str, amount: int): bool = all {
    not(relayerFrozen),
    ASSETS.contains(asset),
    DESTINATIONS.contains(dest),
    amount > 0,
    proxyBal.get(asset) >= amount,
    canConsume(transferLimit, clock, amount),
    proxyBal' = proxyBal.setBy(asset, b => b - amount),
    usdsDebt' = usdsDebt,
    mintLimit' = mintLimit,
    transferLimit' = consumeLimit(transferLimit, clock, amount),
    clock' = clock,
    relayerFrozen' = relayerFrozen,
  }

  /// depositERC4626 simplified: USDC → sUSDS shares 1:1 abstract (L332+)
  action depositERC4626(amount: int): bool = all {
    not(relayerFrozen),
    amount > 0,
    proxyBal.get("USDC") >= amount,
    canConsume(transferLimit, clock, amount),
    proxyBal' = proxyBal
      .setBy("USDC", b => b - amount)
      .setBy("sUSDS", b => b + amount),
    usdsDebt' = usdsDebt,
    mintLimit' = mintLimit,
    transferLimit' = consumeLimit(transferLimit, clock, amount),
    clock' = clock,
    relayerFrozen' = relayerFrozen,
  }

  action freezeRelayer: bool = all {
    proxyBal' = proxyBal,
    usdsDebt' = usdsDebt,
    mintLimit' = mintLimit,
    transferLimit' = transferLimit,
    clock' = clock,
    relayerFrozen' = true,
  }

  action unfreezeRelayer: bool = all {
    proxyBal' = proxyBal,
    usdsDebt' = usdsDebt,
    mintLimit' = mintLimit,
    transferLimit' = transferLimit,
    clock' = clock,
    relayerFrozen' = false,
  }

  action tick: bool = all {
    proxyBal' = proxyBal,
    usdsDebt' = usdsDebt,
    mintLimit' = mintLimit,
    transferLimit' = transferLimit,
    clock' = clock + 1,
    relayerFrozen' = relayerFrozen,
  }

  action step: bool = {
    nondet amt = 1.to(25).oneOf()
    nondet asset = ASSETS.oneOf()
    nondet dest = DESTINATIONS.oneOf()
    any {
      mintUSDS(amt),
      burnUSDS(amt),
      transferAsset(asset, dest, amt),
      depositERC4626(amt),
      freezeRelayer,
      unfreezeRelayer,
      tick,
    }
  }

  /// USDS on proxy cannot exceed debt (all USDS came from mint).
  val inv_usds_debt_covers_proxy: bool =
    proxyBal.get("USDS") <= usdsDebt

  val inv_nonneg: bool =
    usdsDebt >= 0 and ASSETS.forall(a => proxyBal.get(a) >= 0)

  val inv_rate_limits_bounded: bool =
    mintLimit.remaining >= 0 and mintLimit.remaining <= mintLimit.capacity and
    transferLimit.remaining >= 0 and transferLimit.remaining <= transferLimit.capacity
}
