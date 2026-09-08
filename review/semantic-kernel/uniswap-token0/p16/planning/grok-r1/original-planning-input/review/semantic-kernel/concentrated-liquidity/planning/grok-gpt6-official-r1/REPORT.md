# Official concentrated-liquidity planning report (Grok 4.6 author)

Native Grok 4.6 froze OpenSpec change `concentrated-liquidity-library` for independent GPT-6 review. Implementation has not started. Gate accepted is false.

## Chosen increment

Approach C: a coherent library chain rather than a TickMath toy or a full `UniswapV3Pool.swap` model.

In scope: `Word`/`Signed` widths, FullMath as floor/ceil of the exact natural product at width 256 (reusing `Arithmetic.Rounding.mulDiv`), TickMath bit-constant conversion, SqrtPriceMath with the 0.7.6 overflow-fallback branch, single-range `computeSwapStep`, TickBitmap floor compression and one-word search, LiquidityMath.addDelta, factory fee/spacing predicates.

Out of scope and named: full tick traversal (`R-FULL-TRAVERSAL`), FullMath assembly identity (`G-FULLMATH-ASSEMBLY`), UnsafeMath zero denominator (`G-UNSAFEMATH-ZERO`), compiler/EVM (`G-NO-SOLC-DIFFERENTIAL`), deployment (`G-NO-DEPLOYMENT`), wrap-as-checked replacements for int256 min and one uint160 downcast.

## Counts

5 capabilities, 18 requirements, 40 scenarios, 24 unchecked tasks, 45 fixtures, 12 characteristic mutants. Global positives F01, F10, F28, F40.

## Source pin

Uniswap v3-core official `v1.0.0` commit `e3589b192d0be27e100cd0daaf6c97204fdb1899`, tree `f024dbf808e50091852f7cc8724d837543a8c7e5`. Capture and failed 404 for `LICENSE` vs `LICENSE_GPL` are preserved and unread as new network. Historical pin, not latest or deployed.

## Arithmetic reuse

Delivered Arithmetic source `ddf1ac0e` / archive `6d73e6dc`, local ten Lean files plus three Lake pins match HEAD. FullMath Lean wrappers are specified to call `Rounding.mulDiv`; that is not an assembly proof.

## Checker

Independent GPT-6 must review this freeze. Author validation is not that review.
