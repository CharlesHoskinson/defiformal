// Sky — sDAI / savings share + USDS join surface (partial CDP category witness).
// Sources:
//   sky-ecosystem_sdai/src/SavingsDai.sol
//     chi/rho/drip via pot, convertToShares (278), deposit (298), redeem (355)
//   sky-ecosystem_usds/src/DaiUsds.sol  — 1:1 daiToUsds / usdsToDai
//   sky-ecosystem_usds/src/UsdsJoin.sol — join/exit against vat
// Scope: ERC-4626-style share vault over accumulating chi; 1:1 stablecoin conversion.
//        vat/CDP core (urns, ilk, clip) is NOT in these repos.
// NOT covered: full Maker/Sky vat, clipper auctions, dog liquidations, DSR governance.

module sky {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val SCALE: int = RAY

  var shares: int -> int
  var totalShares: int
  var chi: int
  var usdsSupply: int
  var potDai: int
  var freeDai: int

  pure def toShares(assets: int, chiNow: int): int =
    sharesFromIndex(assets, chiNow, SCALE)

  pure def toAssets(sh: int, chiNow: int): int =
    assetsFromIndex(sh, chiNow, SCALE)

  pure def totalAssetsOf(ts: int, chiNow: int): int =
    toAssets(ts, chiNow)

  action init: bool = all {
    shares' = USERS.mapBy(_ => 0),
    totalShares' = 0,
    chi' = SCALE,
    usdsSupply' = 0,
    potDai' = 0,
    freeDai' = 1000,
  }

  action drip(delta: int): bool = all {
    delta > 0,
    delta <= SCALE / 10,
    chi' = chi + delta,
    shares' = shares,
    totalShares' = totalShares,
    usdsSupply' = usdsSupply,
    potDai' = potDai,
    freeDai' = freeDai,
  }

  /// deposit — SavingsDai.sol:298
  action deposit(u: int, assets: int): bool = {
    val sh = toShares(assets, chi)
    all {
      USERS.contains(u),
      assets > 0,
      freeDai >= assets,
      sh > 0,
      shares' = shares.put(u, shares.get(u) + sh),
      totalShares' = totalShares + sh,
      potDai' = potDai + assets,
      freeDai' = freeDai - assets,
      chi' = chi,
      usdsSupply' = usdsSupply,
    }
  }

  /// redeem — SavingsDai.sol:355
  action redeem(u: int, sh: int): bool = {
    val assets = toAssets(sh, chi)
    all {
      USERS.contains(u),
      sh > 0,
      shares.get(u) >= sh,
      potDai >= assets,
      shares' = shares.put(u, shares.get(u) - sh),
      totalShares' = totalShares - sh,
      potDai' = potDai - assets,
      freeDai' = freeDai + assets,
      chi' = chi,
      usdsSupply' = usdsSupply,
    }
  }

  /// daiToUsds — DaiUsds.sol:71
  action daiToUsds(u: int, wad: int): bool = all {
    USERS.contains(u),
    wad > 0,
    freeDai >= wad,
    freeDai' = freeDai - wad,
    usdsSupply' = usdsSupply + wad,
    shares' = shares,
    totalShares' = totalShares,
    chi' = chi,
    potDai' = potDai,
  }

  /// usdsToDai — DaiUsds.sol:78
  action usdsToDai(u: int, wad: int): bool = all {
    USERS.contains(u),
    wad > 0,
    usdsSupply >= wad,
    usdsSupply' = usdsSupply - wad,
    freeDai' = freeDai + wad,
    shares' = shares,
    totalShares' = totalShares,
    chi' = chi,
    potDai' = potDai,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet assets = 1.to(50).oneOf()
    nondet sh = 1.to(50).oneOf()
    nondet wad = 1.to(30).oneOf()
    nondet delta = 1.to(1000).oneOf()
    any {
      deposit(u, assets),
      redeem(u, sh),
      drip(delta),
      daiToUsds(u, wad),
      usdsToDai(u, wad),
    }
  }

  val shareConservation: bool =
    mapSum(shares, USERS) == totalShares

  val nonNegative: bool = and {
    totalShares >= 0,
    chi > 0,
    usdsSupply >= 0,
    potDai >= 0,
    freeDai >= 0,
    nonNegMap(shares, USERS),
  }

  /// Hidden assumption: broader Sky balance sheet funds chi growth after drip.
  val potNonNeg: bool = potDai >= 0

  val parWhenNoAccrual: bool =
    chi != SCALE or potDai == totalAssetsOf(totalShares, chi)

  val safety: bool = and {
    shareConservation,
    nonNegative,
    potNonNeg,
  }
}
