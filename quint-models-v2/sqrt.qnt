// Exact integer square root for Quint. Restoring (binary digit-by-digit) sqrt.
module sqrt {
  /// Exact floor(sqrt(n)) for 0 <= n < 4^bits.
  /// `bits` fold steps; each step is one multiply and one compare.
  /// Largest intermediate is (2^bits)^2 = 4^bits, so pick `bits` so that
  /// 4^bits fits the backend integer width (Rust backend: bits <= 31).
  pure def isqrtBits(n: int, bits: int): int =
    if (n <= 0) 0
    else range(0, bits).foldl(0, (res, i) => {
      val cand = res + 2^(bits - 1 - i)
      if (cand * cand <= n) cand else res
    })

  /// Rust backend (i64): exact on 0 <= n < 2^62 = 4611686018427387904.
  pure def isqrt(n: int): int = isqrtBits(n, 31)

  /// TypeScript backend (BigInt): exact on 0 <= n < 2^128.
  pure def isqrtWide(n: int): int = isqrtBits(n, 64)

  /// Defining property of floor(sqrt).
  pure def isqrtCorrect(n: int): bool = {
    val r = isqrt(n)
    and { r >= 0, r * r <= n, (r + 1) * (r + 1) > n }
  }

  // --- Uniswap V2 UniswapV2Pair.mint, first-deposit branch ---
  // liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY
  pure val MINIMUM_LIQUIDITY: int = 1000

  pure def geometricMintExact(a0: int, a1: int): int =
    if (a0 <= 0 or a1 <= 0) 0 else isqrt(a0 * a1) - MINIMUM_LIQUIDITY

  // --- exhaustive / spot checks, evaluated as an invariant ---
  pure val checkSmall: bool = 0.to(4095).forall(n => isqrtCorrect(n))
  pure val checkSquares: bool =
    1.to(3000).forall(k => and {
      isqrt(k * k) == k,
      isqrt(k * k - 1) == k - 1,
      isqrt(k * k + k) == k,
    })
  pure val checkDecades: bool =
    0.to(18).forall(e => 0.to(40).forall(d => isqrtCorrect(10^e + d)))
  pure val checkBoundary: bool = and {
    isqrtCorrect(2^62 - 1),
    isqrt(2^62 - 1) == 2^31 - 1,
    isqrt(0) == 0, isqrt(1) == 1, isqrt(2) == 1, isqrt(3) == 1, isqrt(4) == 2,
  }
  pure val sqrtOk: bool = and { checkSmall, checkSquares, checkDecades, checkBoundary }
}

