## ADDED Requirements

### Requirement: IQ01 Convert with explicit asset scale

Quantity conversion SHALL preserve the named asset and positive scale, and inverse conversion SHALL reject negative, fractional or overflowing values.

#### Scenario: Q01 word7 is converted at scale1/4 and converted back

- **WHEN** word7 is converted at scale1/4 and converted back
- **THEN** amount7/4 and the original word7 are obtained.

#### Scenario: Q02 amount7/8 at scale1/4 is converted to a word

- **WHEN** amount7/8 at scale1/4 is converted to a word
- **THEN** nonIntegralQuantity is returned.

#### Scenario: Q03 nonpositive scale and negative amount occur together

- **WHEN** nonpositive scale and negative amount occur together
- **THEN** nonPositiveScale takes precedence; with positive scale the negative amount returns negativeQuantity.

### Requirement: IQ02 Prove conversion and dimensional boundaries

Same-scale round trips and exact successful conversion SHALL be proved, while cross-asset misuse SHALL remain a separate typing control.

#### Scenario: Q04 an in-range natural multiple of a positive scale is supplied

- **WHEN** an in-range natural multiple of a positive scale is supplied
- **THEN** successful inverse conversion is characterized exactly.

#### Scenario: Q05 a quantity of one asset is supplied where another indexed asset is required

- **WHEN** a quantity of one asset is supplied where another indexed asset is required
- **THEN** the deliberate type mismatch is reported as compiler rejection, not a runtime semantic mutant.

### Requirement: IQ03 Connect quotes to the actual typed executor

A registered quote-derived reference template SHALL use the existing typed executor and retain full state/capability results and exact refusals.

#### Scenario: Q06 a valid downward gross100 fee transfer starts with payer200 and empty recipient/collector

- **WHEN** a valid downward gross100 fee transfer starts with payer200 and empty recipient/collector
- **THEN** the actual executor succeeds with balances100/67/33 and the unchanged capability store.

#### Scenario: Q07 recipient and collector are the same cell

- **WHEN** recipient and collector are the same cell
- **THEN** the actual aggregate credit is100 and accounting remains balanced.

#### Scenario: Q08 balance is99 or invoke authority exists but the required debit is unauthorized

- **WHEN** balance is99 or invoke authority exists but the required debit is unauthorized
- **THEN** the exact insufficientFunds or unauthorizedDebit refusal is observed with the original inputs preserved.

### Requirement: IQ04 Limit the reference correspondence

Reference results SHALL expose quote/template/scale/authority premises and SHALL NOT imply dynamic pricing, arbitrary template correctness, sequential token-debit fidelity or deployment verification.

#### Scenario: Q09 the fee collector credit is dropped from the constructed template

- **WHEN** the fee collector credit is dropped from the constructed template
- **THEN** the actual executor fails the expected successful full-state comparison and a balanced sibling succeeds.

#### Scenario: Q10 a rational conservation proof is presented as a deployed protocol refinement

- **WHEN** a rational conservation proof is presented as a deployed protocol refinement
- **THEN** the claim is rejected as outside the encoded arithmetic/reference evidence.

