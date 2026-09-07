## Purpose

Identify when two finite registered workflows can run independently without hidden ledger interference or changes to their trusted capability context.

## ADDED Requirements

### Requirement: Concrete conservative footprints
The system SHALL derive branch footprints from every concrete registered invocation, fixed party references, and trusted branch-local caller. Reads SHALL include all syntactic guard/delta/supply reads, both expression branches, declared reads, every potential write target, and selected output cells. Writes SHALL include declared writes and every delta target, including zero or cancelling effects.

#### Scenario: Hidden reads
- **WHEN** a branch guard, delta, supply expression, or inactive expression arm reads a peer write cell
- **THEN** admission rejects the conflict even if that expression is not evaluated on this initial state

#### Scenario: Balance and output dependencies
- **WHEN** a branch has a delta target or selected output cell written by its peer without an explicit expression read
- **THEN** admission still includes that dependency and rejects the conflict

#### Scenario: No financial evaluation during admission
- **WHEN** two requests have identical structural references but different numeric arguments or initial balances
- **THEN** their structural footprint analysis is the same; financial success is decided by execution

### Requirement: Symmetric conflict rejection
The system SHALL admit a pair only if both write regions are disjoint and each write region is disjoint from the other read region. It SHALL permit common read-only cells and SHALL analyze the complete submitted branches, including unreachable suffixes.

#### Scenario: Both conflict directions
- **WHEN** only the right write region intersects the left read region, or only the reverse holds
- **THEN** admission rejects either direction

#### Scenario: Compatible common reads
- **WHEN** both branches read one common cell and neither writes it, with otherwise disjoint regions
- **THEN** admission accepts the pair

#### Scenario: Unreachable conflicting suffix
- **WHEN** a later submitted invocation conflicts even though an earlier invocation would refuse
- **THEN** admission rejects before either branch executes

### Requirement: Stable local inputs and fixed capabilities
The parallel operator SHALL accept invocation-only branches, retain their left/right identities across execution orders, bind trusted principal/environment/time by identity and local index, isolate prior-output lookup to each branch, and use the same immutable initial capability store throughout. Capability issuance and revocation SHALL be excluded from this operator.

#### Scenario: Branch-local boundaries
- **WHEN** branches use different callers or time assumptions at the same local index
- **THEN** each invocation receives its own unchanged boundary under both execution orders

#### Scenario: Prior revocation
- **WHEN** a capability is revoked before the fork
- **THEN** a dependent invocation refuses under that store in every order, while an otherwise identical live-store sibling succeeds

#### Scenario: Administrative input excluded
- **WHEN** a caller attempts to include issue or revoke as a parallel branch entry
- **THEN** the public branch type cannot represent that entry

#### Scenario: Reusable shared grant
- **WHEN** both independent branches refer to a live reusable capability allowed by the existing authority API
- **THEN** admission does not reject solely because the capability identifier is shared

### Requirement: Deterministic preflight refusal
The system SHALL validate the global catalog, analyze left then right invocations in local order, and check write/write then left-write/right-read then right-write/left-read conflicts. An admission refusal SHALL preserve the complete initial world and emit no execution receipt or output. Structural failures SHALL carry branch/local position/cause; conflicts SHALL carry conflict class and a deterministic witness cell.

#### Scenario: Malformed local reference
- **WHEN** a registered invocation contains an unresolvable party/cell reference
- **THEN** admission returns its structural cause and location without committing any prefix

#### Scenario: Multiple admission failures
- **WHEN** both branch analysis and conflict checks would fail
- **THEN** the documented preflight ordering selects a deterministic reason

#### Scenario: Financial refusal kept local
- **WHEN** catalog and references are valid but a request has insufficient funds, unavailable prior output, wrong argument unit, or missing authority
- **THEN** admission does not replace the eventual existing branch-runtime refusal with an invented compatibility success
