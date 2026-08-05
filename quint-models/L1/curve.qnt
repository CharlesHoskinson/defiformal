// Curve Stableswap (2-coin abstraction of StableSwap3Pool).
// Source: protocol-repos/dex/curvefi_curve-contract/contracts/pools/3pool/StableSwap3Pool.vy
//   balances (L94), A amplification (initial_A), get_D (L195-217),
//   fee/admin_fee, add_liquidity / exchange / remove_liquidity.
// Model: D-invariant hybrid; amp A concentrates near peg; fee on imbalance.

module curve {
  import common.* from "./common"

  pure val FEE_BPS: int = 4        // 0.04% typical stableswap fee scale (abstract)
  pure val ADMIN_BPS: int = 50     // half of fee to admin (of fee), abstract
  pure val A: int = 100            // amplification coefficient (const for this model)
  pure val USERS: Set[str] = Set("alice", "bob")

  var bal0: int
  var bal1: int
  var lpSupply: int
  var lpBal: str -> int
  var adminFees0: int
  var adminFees1: int

  /// Simplified D for 2 coins: Newton's method collapsed to one stable step.
  /// Exact Curve: D = (Ann*S + D_P*n)*D / ((Ann-1)*D + (n+1)*D_P).
  /// We use D ≈ S when balanced, and D < S when imbalanced (concavity).
  pure def approxD(x: int, y: int, amp: int): int = {
    val S = x + y
    if (S == 0) 0
    else if (x == 0 or y == 0) 0
    else {
      // Weighted blend: high A → D closer to S; low A → D closer to 2*sqrt(xy)
      val prodTerm = 2 * min(x, y)  // stand-in for geometric contribution
      val ann = amp * 2
      // D ≈ (ann*S + prodTerm*2) related blend
      (ann * S + prodTerm) / (ann + 1)
    }
  }

  action init: bool = all {
    bal0' = 100,
    bal1' = 100,
    lpSupply' = 200,  // D-like at peg
    lpBal' = USERS.mapBy(u => if (u == "alice") 200 else 0),
    adminFees0' = 0,
    adminFees1' = 0,
  }

  /// add_liquidity balanced or single-sided
  action addLiquidity(u: str, a0: int, a1: int): bool = all {
    USERS.contains(u),
    a0 >= 0, a1 >= 0, (a0 > 0 or a1 > 0),
    val d0 = approxD(bal0, bal1, A)
    val d1 = approxD(bal0 + a0, bal1 + a1, A)
    val mint = if (lpSupply == 0) d1 else mulDivDown(d1 - d0, lpSupply, d0)
    all {
      mint > 0,
      d1 >= d0,
      bal0' = bal0 + a0,
      bal1' = bal1 + a1,
      lpSupply' = lpSupply + mint,
      lpBal' = lpBal.put(u, lpBal.get(u) + mint),
      adminFees0' = adminFees0,
      adminFees1' = adminFees1,
    }
  }

  /// exchange i→j: stableswap out with fee
  action exchange0for1(dx: int): bool = all {
    dx > 0,
    bal0 > 0, bal1 > 0,
    // Ideal constant-sum out at peg, reduced by product term when imbalanced
    val ideal = dx  // near peg 1:1
    val fee = mulDivDown(ideal, FEE_BPS, 10000)
    val admin = mulDivDown(fee, ADMIN_BPS, 100)
    val dy = ideal - fee
    all {
      dy > 0,
      dy < bal1,
      bal0' = bal0 + dx,
      bal1' = bal1 - dy - admin,  // admin fee leaves pool (Curve admin_fee)
      adminFees1' = adminFees1 + admin,
      adminFees0' = adminFees0,
      lpSupply' = lpSupply,
      lpBal' = lpBal,
    }
  }

  action removeLiquidity(u: str, shares: int): bool = all {
    USERS.contains(u),
    shares > 0,
    lpBal.get(u) >= shares,
    lpSupply > shares,
    val a0 = mulDivDown(shares, bal0, lpSupply)
    val a1 = mulDivDown(shares, bal1, lpSupply)
    all {
      bal0' = bal0 - a0,
      bal1' = bal1 - a1,
      lpSupply' = lpSupply - shares,
      lpBal' = lpBal.put(u, lpBal.get(u) - shares),
      adminFees0' = adminFees0,
      adminFees1' = adminFees1,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet a0 = 0.to(20).oneOf()
    nondet a1 = 0.to(20).oneOf()
    nondet sh = 1.to(20).oneOf()
    nondet dx = 1.to(15).oneOf()
    any {
      addLiquidity(u, a0, a1),
      exchange0for1(dx),
      removeLiquidity(u, sh),
    }
  }

  val lpConservation: bool =
    USERS.fold(0, (acc, u) => acc + lpBal.get(u)) == lpSupply

  val balancesNonNeg: bool = bal0 >= 0 and bal1 >= 0 and lpSupply >= 0

  /// D non-increase is NOT required on exchange (fees leave); on add, D grows.
  val adminFeesNonNeg: bool = adminFees0 >= 0 and adminFees1 >= 0
}
