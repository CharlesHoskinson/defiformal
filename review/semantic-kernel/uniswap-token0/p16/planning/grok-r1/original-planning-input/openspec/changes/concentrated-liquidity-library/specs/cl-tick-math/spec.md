## Purpose

Specify Uniswap v3-core v1.0.0 tick-to-price and price-to-tick conversion as an integer bit-constant algorithm with explicit inclusive and exclusive bounds.

## ADDED Requirements

### Requirement: CLT01 Forward conversion uses the source bit constants

`getSqrtRatioAtTick` SHALL implement the captured TickMath bit-selection, 128-bit right shift, optional `2^256-1 / ratio` inversion for positive ticks, and the final Q128.128 to Q64.96 round-up. Tick 0 SHALL be `2^96`. The algorithm at `±887272` SHALL equal the named min and max ratio constants.

#### Scenario: T01 ticks 0, 1 and -1 have independent forward prices

- **WHEN** `getSqrtRatioAtTick` is evaluated at 0, 1 and -1
- **THEN** the results are `79228162514264337593543950336`, `79232123823359799118286999568` and `79224201403219477170569942574` respectively.

#### Scenario: T02 min and max ticks match the named ratio constants

- **WHEN** `getSqrtRatioAtTick` is evaluated at `-887272` and `887272`
- **THEN** the results are `4295128739` and `1461446703485210103287273052203988822378723970342`.

#### Scenario: T06 selected forward prices round-trip under the greatest-tick spec

- **WHEN** the independent greatest-tick inverse is applied to the forward prices of ticks 0, 1, -1, min and max
- **THEN** each recovered tick equals the original.

### Requirement: CLT02 Ticks outside ±887272 are refused

`getSqrtRatioAtTick` SHALL return `tickOutOfBounds` when `|tick| > 887272` and SHALL NOT run the bit loop on that input.

#### Scenario: T03 tick 887273 is refused

- **WHEN** `getSqrtRatioAtTick` is evaluated at 887273
- **THEN** the error is `tickOutOfBounds`.

### Requirement: CLT03 Inverse accepts the minimum ratio and excludes the maximum

`getTickAtSqrtRatio` SHALL refuse `sqrtPriceX96 < MIN_SQRT_RATIO` and `sqrtPriceX96 ≥ MAX_SQRT_RATIO` with `ratioOutOfBounds`. On success it SHALL equal the greatest tick whose forward price is `≤` the input. The Lean body SHALL follow the captured msb/log/final-choice algorithm; fixtures compare against the independent greatest-tick specification, not against Lean’s own output.

#### Scenario: T04 inverse of 2^96 is tick 0 and inverse of MIN_SQRT_RATIO is MIN_TICK

- **WHEN** `getTickAtSqrtRatio` is evaluated at `2^96` and at `4295128739`
- **THEN** the results are 0 and `-887272`.

#### Scenario: T05 MAX_SQRT_RATIO and MIN_SQRT_RATIO-1 are refused

- **WHEN** `getTickAtSqrtRatio` is evaluated at `1461446703485210103287273052203988822378723970342` and at `4295128738`
- **THEN** both return `ratioOutOfBounds`.
