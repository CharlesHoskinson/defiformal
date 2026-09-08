## Purpose

Define signed and unsigned machine widths used by concentrated-liquidity math, and FullMath as floor or ceiling of an exact natural product with explicit zero-denominator and quotient-width refusals.

## ADDED Requirements

### Requirement: CLW01 Bound signed and unsigned words without wrap

Public constructors SHALL return the exact integer when it lies in the declared range and SHALL refuse otherwise. Unsigned width `w` is `0 ≤ value < 2^w`. Signed width `w≥1` is `-2^(w-1) ≤ value < 2^(w-1)`. `toInt256` SHALL refuse `n ≥ 2^255`. No constructor SHALL reduce modulo the word size.

#### Scenario: W09 2^255-1 is in range for int256 and 2^255 is not

- **WHEN** `toInt256` is applied to `2^255-1` and to `2^255`
- **THEN** the first succeeds with that integer and the second returns `intOverflow`.

### Requirement: CLW02 Floor of the exact product at width 256

`mulDiv(a,b,d)` SHALL equal `floor(a·b/d)` as a `Word 256` when `d>0` and that quotient is `< 2^256`. The intermediate product SHALL be the unbounded natural product. A product at or above `2^256` that still yields a fitting quotient SHALL succeed.

#### Scenario: W01 10 times 20 divided by 3 floors to 66

- **WHEN** `mulDiv` is evaluated on 10, 20 and 3
- **THEN** the result is 66.

#### Scenario: W04 2^128 times 2^128 divided by 2^128 is 2^128

- **WHEN** `mulDiv` is evaluated on three copies of `2^128`
- **THEN** the result is `2^128` even though the exact product is `2^256`.

#### Scenario: W08 a zero numerator yields zero for a positive denominator

- **WHEN** `mulDiv` is evaluated on 0, `2^255` and 7
- **THEN** the result is 0.

#### Scenario: W07 the mathematical specification is Rounding.mulDiv not assembly

- **WHEN** a successful `mulDiv` result is compared with `Arithmetic.Rounding.mulDiv .down` at width 256 on the same values
- **THEN** the numeric results agree, and no theorem asserts that FullMath assembly, `mulmod`, or the modular inverse path was executed.

### Requirement: CLW03 Ceiling of the exact product

`mulDivRoundingUp(a,b,d)` SHALL equal `ceil(a·b/d)` as a `Word 256` when `d>0` and that quotient is `< 2^256`. Exact division SHALL match the floor result. A needed increment that would reach `2^256` SHALL return `quotientOverflow`.

#### Scenario: W02 10 times 20 divided by 3 ceils to 67

- **WHEN** `mulDivRoundingUp` is evaluated on 10, 20 and 3
- **THEN** the result is 67.

#### Scenario: W03 10 times 20 divided by 5 is 40 in both rounding modes

- **WHEN** both FullMath operations are evaluated on 10, 20 and 5
- **THEN** both return 40.

### Requirement: CLW04 Zero denominator precedes quotient overflow

A zero denominator SHALL return `divisionByZero` and SHALL NOT compute a quotient. A positive denominator whose directed quotient is `≥ 2^256` SHALL return `quotientOverflow`.

#### Scenario: W05 1 times 1 divided by 0 is divisionByZero

- **WHEN** `mulDiv` is evaluated on 1, 1 and 0
- **THEN** the error is `divisionByZero`.

#### Scenario: W06 (2^256-1) times 2 divided by 1 is quotientOverflow

- **WHEN** `mulDiv` is evaluated on `2^256-1`, 2 and 1
- **THEN** the error is `quotientOverflow`.
