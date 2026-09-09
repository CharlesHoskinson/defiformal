## Purpose

Specify the standalone token0 next-price observation, required wrap fallback, identity and refusal cases, and the Lean API that later implementation must inhabit under delivered Arithmetic and P15 contracts.

## ADDED Requirements

### Requirement: Pure helper has four inputs and no fee

The operation SHALL be `SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp(uint160 sqrtPX96, uint128 liquidity, uint256 amount, bool add)` returning uint160. There is no fee parameter, ledger, tick, or capability field. Standalone helper admissibility is distinct from reachability inside `UniswapV3Pool.swap`.

#### Scenario: No invented ledger history
- **WHEN** a token0 observation is recorded
- **THEN** it contains only the four inputs, the uint160 result or a source revert, and no fabricated post-world

### Requirement: Zero amount is identity success

`if (amount == 0) return sqrtPX96` SHALL be treated as success identity, not a refusal.

#### Scenario: Planned identity vector
- **WHEN** inputs `(2^96, 1, 0, true)` or the same with `add=false` are applied
- **THEN** the result is `2^96`

#### Scenario: Zero-liquidity zero-amount identity
- **WHEN** inputs `(2^96, 0, 0, false)` are applied
- **THEN** the public helper returns `2^96` and MUST NOT be classified as a remove-path require refusal

### Requirement: Ordinary add and the removal require are both required

Planned add `(2^96, 1, 1, true)` SHALL return `2^95`. Planned removal `(2^96, 1, 1, false)` SHALL fail the source `require` that `numerator1 > product`. Nonidentity removal refusal SHALL include the premise `amount ≠ 0`. Ordinary removal success SHALL require product-fit, `numerator1 > product`, FullMath success, and then `SafeCast.toUint160` success, in that order. Add-path success uses the source bare `uint160` cast, which is distinct from SafeCast.

#### Scenario: Planned add sibling
- **WHEN** inputs `(2^96, 1, 1, true)` are applied
- **THEN** product and denominator sum both fit and the result is `2^95`

#### Scenario: Removal denominator require
- **WHEN** inputs `(2^96, 1, 1, false)` are applied
- **THEN** `numerator1` equals product equals `2^96` and the helper refuses via `require`

#### Scenario: Guard-passing SafeCast refusal
- **WHEN** inputs `(2^159, 2^63+1, 1, false)` are applied
- **THEN** the source require passes, FullMath returns `2^222+2^159`, and SafeCast.toUint160 refuses

#### Scenario: Primary-add FullMath zero denominator
- **WHEN** inputs `(0, 0, 1, true)` are applied
- **THEN** identity is not taken and the public helper refuses in FullMath on denominator 0

### Requirement: Public branch equations are ordered Except compositions

A branch theorem SHALL characterize the proposed public `SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp` under exact ordered callee composition, or else list sufficient success premises including `amount ≠ 0` on every nonidentity branch. Unconditional success from a helper-fit guard alone MUST NOT be claimed.

#### Scenario: Remove-path success names FullMath then SafeCast
- **WHEN** a remove-path success theorem is claimed
- **THEN** it includes `amount ≠ 0`, product-fit, `numerator1 > product`, FullMath success, and SafeCast success

### Requirement: Wrapped denominator-sum fallback cannot be excluded

When the product `amount * sqrtPX96` fits uint256 and `numerator1 + product` overflows uint256, Solidity 0.7.6 wraps the sum and takes `UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount))`. Unbounded Lean `Nat` addition and `Operations.add` MUST NOT silently replace that branch. Product-overflow fallback is a separate partition.

#### Scenario: Required wrap branch
- **WHEN** sqrtP is `MAX_SQRT_RATIO-1`, liquidity is max uint128, and amount is the least value that makes the denominator sum overflow while the product still fits
- **THEN** the observation is the wrapped-sum fallback, not the primary FullMath path, and P16 MUST NOT exclude the branch to pass

### Requirement: Branch theorem states the implemented fallback under exact premises

A proved branch equation SHALL characterize the actual implemented fallback of the public helper under its premises (add, amount ≠ 0, product fits, wrapped sum `< numerator1`, LowGasSafeMath.add on the inner sum). Restating an arbitrary helper is not that theorem. UnsafeMath `y==0` remains unspecified in source comments and MUST be kept distinct from helper reachability: fallback with a successful checked inner add has a positive denominator and `sqrtP > 0`. Lean MUST NOT invent `divisionByZero` as if the assembly specified it. Overflow partitions MUST NOT be excluded. Source/assembly refinement remains open.

#### Scenario: Fallback equation is premise-specific
- **WHEN** a wrap-fallback theorem is claimed
- **THEN** it names those premises and the `divRoundingUp` formula, and does not equate the result to unbounded `liquidity * sqrtP / (liquidity + amount * sqrtP)` alone

### Requirement: Typed wrap is optional for arithmetic-only P16/P18

Arithmetic-only delivery MAY return `Except Failure (Word 160)` without a Typed kernel wrapper. `P17.platform_reuse` SHALL still require an actual token0-to-kernel bridge and shared theorem instances in both cases. A P16 arithmetic-only increment MUST NOT be labelled platform reuse.

#### Scenario: Arithmetic-only increment omits Typed wrap
- **WHEN** P16 publishes model proofs and bounded source comparisons without `Typed.execute`
- **THEN** that is valid arithmetic-library scope and MUST NOT be labelled `P17.platform_reuse`
