## Purpose

Defines the bounded fixed-claim lifecycle contract described in design.md.

## ADDED Requirements

### Requirement: CS01 Represent fixed dimensioned obligations

Claims SHALL retain debtor, current creditor, domain, asset, fixed positive face, remaining/paid/waived quantities, due, unconditional condition, status, default history and revision with executable finite validation.

#### Scenario: S01 A valid fixed loan is created

- **WHEN** a valid fixed loan is created
- **THEN** the fresh row has positive face=remaining, paid=waived=0, an explicit unconditional condition and active status.

#### Scenario: S02 An imported row violates decomposition or status/clock consistency

- **WHEN** an imported row violates decomposition or status/clock consistency
- **THEN** initial admission identifies the first invalid row and ordered reason without running a command.

### Requirement: CS02 Retain permanent identities and tombstones

Claims SHALL use append-only positional ClaimIds and preserve every existing row identity, including terminal entries.

#### Scenario: S03 A paid or forgiven row is followed by a new loan

- **WHEN** a paid or forgiven row is followed by a new loan
- **THEN** the new ID is the previous list length and the old tombstone remains exact.

#### Scenario: S04 A command targets a terminal or nonexistent row

- **WHEN** a command targets a terminal or nonexistent row
- **THEN** it refuses without deleting, reusing or reactivating an ID.

### Requirement: CS03 Bound the instrument and initial assumptions

Claims SHALL distinguish validated imported obligations from funded-origin traces and SHALL exclude unsupported conditional, indexed, interest and asynchronous behavior.

#### Scenario: S05 A valid imported nonempty store is admitted

- **WHEN** a valid imported nonempty store is admitted
- **THEN** validity is not described as proof of historical funding.

#### Scenario: S06 Conditional payoff, legal default or external truth is discussed

- **WHEN** conditional payoff, legal default or external truth is discussed
- **THEN** it remains an explicit separate obligation; an arbitrary Boolean does not certify it.
