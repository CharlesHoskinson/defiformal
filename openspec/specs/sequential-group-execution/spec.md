# sequential-group-execution Specification

## Purpose
Specify finite recursive sequential groups that preserve actual cursor continuation, administrative effects and exact refusal behavior.

## Requirements

### Requirement: Recursive ordered execution

A finite sequential group SHALL execute its ordered children recursively, passing the complete returned continuation cursor to the next child. Empty groups SHALL be identity and each action SHALL execute through the existing single-step semantics, including issue and revoke.

#### Scenario: Nested producer and consumer

- **WHEN** a snapshot-producing movement, a prior-output consumer and a third movement occur in nested nonempty groups
- **THEN** the consumer uses the exact frozen qualified snapshot and all three actions have the independently expected worlds, receipts and absolute positions

#### Scenario: Empty group identities

- **WHEN** an empty group appears before or after a nonempty group from any existing cursor
- **THEN** the complete result equals execution of that nonempty group alone

#### Scenario: Administrative cross-group continuation

- **WHEN** one child issues a capability and later children invoke and revoke that issued ID
- **THEN** the complete updated store and exact administrative receipts reach every later child

### Requirement: Refusal and absolute continuation

The first located refusal SHALL retain the successful cursor prefix and make every remaining child inert. Child boundaries SHALL use the actual absolute next position; history, events and capability state SHALL NOT be reset.

#### Scenario: Middle refusal absorbs suffix

- **WHEN** transfer7 succeeds from USD10, transfer6 refuses, and a funded suffix would otherwise succeed
- **THEN** Alice remains3 and Bob7, the exact middle failure is retained and the suffix emits no movement, receipt or snapshot

#### Scenario: Previously failed cursor

- **WHEN** a recursive group starts from an already failed nonempty cursor
- **THEN** the complete cursor is unchanged

#### Scenario: Nonzero boundary position

- **WHEN** an existing cursor starts at a nonzero position and trusted actor or time differs by absolute slot
- **THEN** every action uses its actual continuation position and preserves the resulting exact success or refusal; the M08 sensitivity variant changes only the new leaf boundary argument to a constant position0 function, leaving imported single-step semantics unchanged

### Requirement: Actual flattening correspondence

Recursive group execution SHALL equal the existing flat sequential continuation on the same leaf list for every supplied cursor, without a successful-run premise. This correspondence SHALL include full raw events and their worlds, current world/store, outputs, position and failure.

#### Scenario: Successful recursive simulation

- **WHEN** a nonempty nested group succeeds with cross-child output dependencies
- **THEN** its entire cursor equals the actual flat continuation and independently expected financial fields

#### Scenario: Administrative refusal simulation

- **WHEN** a revoke in one group makes a later use refuse
- **THEN** recursive and flat execution retain the same tombstone, denied invocation, local index and successful prefix

#### Scenario: Arbitrary continuation simulation

- **WHEN** the starting cursor contains existing events, outputs, store entries and a nonzero position
- **THEN** the simulation preserves that entire prefix rather than creating a fresh initial cursor

### Requirement: Sequential associativity scope

The two parenthesizations of three sequential groups SHALL return equal complete cursors, derived from actual recursive execution correspondence. This law SHALL preserve leaf order and the existing sequential boundary.

#### Scenario: Three-group associativity

- **WHEN** three nonempty groups are parenthesized left or right, including a failure-bearing case
- **THEN** both executions return the same complete cursor

#### Scenario: Reordering is a distinct behavior

- **WHEN** shared withdrawals7 and6 compete for USD10 in opposite leaf orders
- **THEN** the differing accepted movement and refusal demonstrate that associativity does not permit swapping leaves
