## Purpose

Turn the single fixed-value correspondence into per-operation contracts over the full domain, and state the relation between the Lean library and the pinned deployed code. Serves tasks II.2 and II.3.

## ADDED Requirements

### Requirement: Deposit correspondence SHALL hold over the full domain

The deposit operation SHALL have a theorem relating its Word-arithmetic executable and its exact-rational transition for all admissible asset amounts and rates, including rounding, fee and refusal behaviour, in the form of the native-correspondence helper used by the benchmark adapter.

#### Scenario: No literal remains

- **WHEN** the correspondence theorem is inspected
- **THEN** its statement quantifies over assets and rates and the fixed WAD instance is a corollary, not the theorem

### Requirement: Source correspondence SHALL be stated as three artifacts

The repository SHALL state the relation between the pinned token0 Solidity campaign and the Lean library as three separate artifacts: a model theorem, a differential observation record and a written refinement obligation.

#### Scenario: Token0 campaign is related to the library

- **WHEN** the pinned token0 Solidity campaign is compared with the Lean library
- **THEN** the repository holds a model theorem, a differential observation record and a written refinement obligation naming what remains unproved
