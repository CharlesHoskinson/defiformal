# checked-unsigned-arithmetic Specification

## Purpose

Defines exact unsigned word bounds, checked operations and explicit arithmetic refusals.

## Requirements

### Requirement: UW01 Bound words without silent coercion

Construction SHALL return the exact natural value below2^w or inputOverflow, with no modular truncation.

#### Scenario: W01 255 and256 are constructed at width8

- **WHEN** 255 and256 are constructed at width8
- **THEN** 255 succeeds unchanged and256 returns inputOverflow.

#### Scenario: W02 width0 is used as a mathematical boundary case

- **WHEN** width0 is used as a mathematical boundary case
- **THEN** only0 is representable; no hardware-width claim follows.

### Requirement: UW02 Check addition and subtraction

Addition and subtraction SHALL characterize overflow and underflow before returning bounded words.

#### Scenario: W03 254+1 and255+1 are evaluated at width8

- **WHEN** 254+1 and255+1 are evaluated at width8
- **THEN** the first returns255 and the second addOverflow.

#### Scenario: W04 0-1 is evaluated

- **WHEN** 0-1 is evaluated
- **THEN** subUnderflow is returned rather than zero or a wrapped value.

### Requirement: UW03 Distinguish checked multiplication from full-product division

Checked multiplication SHALL reject an out-of-range product, while mulDiv SHALL preserve the exact intermediate natural product.

#### Scenario: W05 16*16 is checked at width8

- **WHEN** 16*16 is checked at width8
- **THEN** mulOverflow is returned.

#### Scenario: W06 200*2/2 is evaluated by full-product mulDiv at width8

- **WHEN** 200*2/2 is evaluated by full-product mulDiv at width8
- **THEN** 200 is returned although the intermediate product exceeds255.

### Requirement: UW04 Prove exact success and refusal contracts

Every exported arithmetic operation SHALL have a universal specification with exact result bounds and error conditions, independent of sampled tests.

#### Scenario: W07 an arbitrary valid pair of words is evaluated

- **WHEN** an arbitrary valid pair of words is evaluated
- **THEN** success iff the mathematical result fits and the correct operation-specific refusal otherwise is proved.

#### Scenario: W08 a four-bit exhaustive comparison passes

- **WHEN** a four-bit exhaustive comparison passes
- **THEN** it remains bounded execution and does not replace the generic Lean theorem.

