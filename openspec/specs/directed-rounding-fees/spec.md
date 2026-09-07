# directed-rounding-fees Specification

## Purpose

Defines full-product directed rounding and separate fee-from-gross and fee-on-top conventions.

## Requirements

### Requirement: RF01 Specify directed quotient results

For a positive denominator, floor and ceiling SHALL satisfy their independent quotient inequalities; zero denominator SHALL be refused first.

#### Scenario: R01 7*5/3 is rounded in both directions

- **WHEN** 7*5/3 is rounded in both directions
- **THEN** floor returns11 and ceiling12.

#### Scenario: R02 denominator0 is supplied even when the product is large

- **WHEN** denominator0 is supplied even when the product is large
- **THEN** divisionByZero precedes any quotient-overflow decision.

### Requirement: RF02 Handle exactness and final overflow

Ceiling SHALL add one exactly for nonzero remainder and SHALL check the rounded final word bound.

#### Scenario: R03 6*5/3 is rounded upward

- **WHEN** 6*5/3 is rounded upward
- **THEN** 10 is returned without an extra unit.

#### Scenario: R04 254*254/253 is rounded at width8

- **WHEN** 254*254/253 is rounded at width8
- **THEN** floor255 succeeds and ceiling returns quotientOverflow.

### Requirement: RF03 Keep fee conventions explicit

feeFromGross and feeOnTop SHALL validate the rate first and retain their distinct charged/received definitions.

#### Scenario: R05 gross100 at rate1/3 is charged downward and upward

- **WHEN** gross100 at rate1/3 is charged downward and upward
- **THEN** gross charging returns net67/fee33 or net66/fee34 respectively.

#### Scenario: R06 principal100 at rate1/3 is charged on top upward

- **WHEN** principal100 at rate1/3 is charged on top upward
- **THEN** charged134, received100 and fee34 are returned.

#### Scenario: R07 denominator0 or numerator greater than denominator is supplied to a fee API

- **WHEN** denominator0 or numerator greater than denominator is supplied to a fee API
- **THEN** invalidRate is returned before any arithmetic subcall failure.

### Requirement: RF04 Prove fee conservation and qualified representability

Successful quotes SHALL satisfy charged=received+fee; a valid gross-based quote SHALL fit, while an on-top quote MAY refuse addition overflow.

#### Scenario: R08 principal255 and rate1/1 are charged on top at width8

- **WHEN** principal255 and rate1/1 are charged on top at width8
- **THEN** addOverflow is returned.

#### Scenario: R09 gross0 or a valid rate300/600 is used at width8

- **WHEN** gross0 or a valid rate300/600 is used at width8
- **THEN** zero remains zero; the wide natural rate yields fee50/net50 for gross100 without word truncation.

#### Scenario: R10 rounded output is compared with exact rational division

- **WHEN** rounded output is compared with exact rational division
- **THEN** the directed error bound is proved and equality is claimed only under divisibility or the explicitly rounded specification.

