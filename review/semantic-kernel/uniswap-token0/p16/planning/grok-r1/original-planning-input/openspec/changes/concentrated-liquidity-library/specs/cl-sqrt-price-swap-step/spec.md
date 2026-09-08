## Purpose

Specify Q64.96 next-price and token-amount deltas with directional rounding and the 0.7.6 overflow-fallback branch, and specify single-range computeSwapStep including remainder-as-fee and output-cap behaviour.

## ADDED Requirements

### Requirement: CLS01 Amount deltas follow directed rounding on explicit inputs

`getAmount1Delta` SHALL compute `round(liquidity · |sqrtB-sqrtA| / 2^96)` with the caller’s `roundUp` flag. `getAmount0Delta` SHALL compute the corresponding `liquidity · |sqrtB-sqrtA| / (sqrtA·sqrtB)` directed quotient after swapping inputs so `sqrtA ≤ sqrtB`, and SHALL refuse `sqrtA=0` as `priceZero`. Exact products SHALL yield the same floor and ceiling.

#### Scenario: S01 liquidity 2^96 between 2^96 and 2^96+1 yields amount1 1

- **WHEN** `getAmount1Delta` is evaluated with those inputs in both rounding modes
- **THEN** both modes return 1.

#### Scenario: S02 liquidity 1 between 2^96 and 2^96+1 rounds amount1 and amount0 down to 0 and up to 1

- **WHEN** both amount deltas are evaluated with liquidity 1 and those prices
- **THEN** floor results are 0 and ceiling results are 1.

#### Scenario: S08 swap-step fees and amounts come from the actual functions

- **WHEN** a successful `computeSwapStep` result is examined
- **THEN** `amountIn`, `amountOut` and `feeAmount` equal the values of the documented branch formulas on those inputs, not a separately assumed conservation identity.

### Requirement: CLS02 Next-price guards, zero-amount short-circuit and overflow fallback

`getNextSqrtPriceFromInput` and `getNextSqrtPriceFromOutput` SHALL refuse `sqrtPX96=0` as `priceZero` and `liquidity=0` as `liquidityZero`. A zero token0 amount SHALL return the input price. When adding token0, if `amount · sqrtPX96 ≥ 2^256` or the first-formula denominator overflows uint256, the function SHALL take the captured fallback expression rather than claiming algebraic equality with the non-overflow formula.

#### Scenario: S03 zero token0 amount returns the starting price

- **WHEN** `getNextSqrtPriceFromAmount0RoundingUp` is evaluated at price `2^96`, liquidity `2^96`, amount 0, add true
- **THEN** the result equals the starting price.

#### Scenario: S04 zero price and zero liquidity are refused

- **WHEN** `getNextSqrtPriceFromInput` is evaluated with price 0 or liquidity 0
- **THEN** the errors are `priceZero` and `liquidityZero` respectively.

#### Scenario: S05 amount 2^160 at price 2^96 uses the overflow fallback

- **WHEN** `getNextSqrtPriceFromAmount0RoundingUp` is evaluated with amount `2^160`, price `2^96`, liquidity `2^96`, add true
- **THEN** the result is `4294967296`, which is the fallback expression, not the first-formula result.

### Requirement: CLS03 Single-range computeSwapStep has target, remainder-fee, cap and direction branches

`computeSwapStep` SHALL set `zeroForOne` from `current ≥ target` and `exactIn` from `amountRemaining ≥ 0`. Exact input SHALL discount by `mulDiv(remaining, 1e6-feePips, 1e6)` and either snap to the target or move by `getNextSqrtPriceFromInput`. When exact input does not reach the target, `feeAmount` SHALL be `remaining - amountIn`. Exact output SHALL cap `amountOut` to `|remaining|`. This function SHALL NOT be described as full pool traversal.

#### Scenario: S06 exact input of 1000 at fee 3000 reaches the adjacent lower price

- **WHEN** `computeSwapStep` is evaluated at current `2^96`, target `2^96-1`, liquidity `2^96`, remaining 1000, fee 3000
- **THEN** next price is `2^96-1`, amountIn is 2, amountOut is 1 and feeAmount is 1.

#### Scenario: S07 exact input of 1 does not reach the target and becomes remainder fee

- **WHEN** `computeSwapStep` is evaluated with remaining 1 and the same prices, liquidity and fee
- **THEN** next price stays `2^96`, amountIn is 0, amountOut is 0 and feeAmount is 1.

#### Scenario: S09 exact output of 1 is capped when the unrounded amountOut is 2

- **WHEN** `computeSwapStep` is evaluated at current `2^96`, target `2^96-100`, liquidity `2^97`, remaining -1, fee 3000
- **THEN** amountOut is 1, amountIn is 3, feeAmount is 1 and next price is `2^96-1`.

#### Scenario: S10 current below target is one-for-zero

- **WHEN** `computeSwapStep` is evaluated at current `2^96`, target `2^96+1`, liquidity `2^96`, remaining 1000, fee 3000
- **THEN** `zeroForOne` is false, next price is `2^96+1`, amountIn is 1, amountOut is 0 and feeAmount is 1.

### Requirement: CLS04 Fee-pip and int256-min strengthenings are named refusals

`computeSwapStep` SHALL return `invalidFee` when `feePips ≥ 10^6`. It SHALL return `intOverflow` when `amountRemaining = -2^255`. These refusals are model strengthenings relative to Solidity 0.7.6 wrap behaviour and SHALL be recorded as gaps, not as 0.8 semantics.

#### Scenario: S11 feePips 1000000 is invalidFee

- **WHEN** `computeSwapStep` is evaluated with feePips 1000000
- **THEN** the error is `invalidFee`.

#### Scenario: S12 int256 minimum remaining is intOverflow

- **WHEN** `computeSwapStep` is evaluated with `amountRemaining = -2^255`
- **THEN** the error is `intOverflow`.
