# sequential-preservation Specification

## Purpose
State the proof obligations needed to lift trusted transition properties to
finite workflows without hiding initialization, authority, or frame premises.

## Requirements

### Requirement: Step and trace correspondence
The system SHALL prove that every successful event corresponds to the existing
registered executor or administrative operation at its immediately preceding
world and that accepted invocation receipts contain the actual evaluated effects.
It SHALL prove receipt extraction succeeds whenever delegated execution succeeds.

#### Scenario: Accepted invocation receipt
- **WHEN** an invocation appears in a successful trace prefix
- **THEN** a proof connects its pre-world, evaluated effects, output snapshots, and post-world to the registered execution

#### Scenario: Refused suffix
- **WHEN** a trace ends in refusal
- **THEN** its final world equals the world after exactly its successful prefix

### Requirement: Cumulative accounting and nonnegativity
The system SHALL prove that every final domain/asset total equals its initial total
plus the sum of actual successful invocation supply changes and that every
reachable balance remains nonnegative. Administration and refusal SHALL contribute
zero ledger change.

#### Scenario: Mint then burn
- **WHEN** a valid deposit and withdrawal mint and burn shares within a workflow
- **THEN** cumulative accounting sums both evaluated supplies and applies separately to every domain and asset

#### Scenario: Accounting at refusal
- **WHEN** one supply-changing step succeeds and a later step refuses
- **THEN** accounting includes the successful supply change and excludes the refused step and suffix

### Requirement: Authority at the point of use
The system SHALL prove invocation, debit, and supply authority using each
successful step's pre-store and administrative authorization using the existing
administrative relation. It SHALL NOT require earlier grants to remain live in
the final store.

#### Scenario: Successful use followed by revocation
- **WHEN** a successful authorized operation is followed by valid revocation
- **THEN** the operation's authority witness is proved at its execution point even though the grant is no longer live afterward

### Requirement: Initialized invariant preservation
The system SHALL prove invariant preservation at every reachable prefix from an
explicit initialization proof and applicable local preservation and boundary
assumptions. Missing premises SHALL remain visible in the statement.

#### Scenario: Inductive guarantee
- **WHEN** initialization establishes an invariant and each admitted step preserves it under stated assumptions
- **THEN** the invariant holds at every successful prefix and at the final world of a refused run

### Requirement: Write locality and supported-predicate framing
The system SHALL prove unchanged ledger cells outside the union of successful
checked writes. It SHALL prove preservation of a predicate only given a proof that
the predicate depends solely on protected ledger cells disjoint from that union.
This frame guarantee SHALL be restricted to ledger predicates.

#### Scenario: Protected ledger predicate
- **WHEN** a predicate is supported on protected cells untouched by all successful steps
- **THEN** its truth is equivalent before and after the workflow, including a workflow ending in refusal

#### Scenario: Unsupported predicate counterexample
- **WHEN** a proposed predicate depends on a balance modified by a successful transfer
- **THEN** a concrete counterexample demonstrates why the frame theorem cannot omit its support and disjointness premises

### Requirement: Scoped sequential composition law
The system SHALL prove the finite-list append/continuation law with preserved
history and absolute boundary positions, including failure short-circuiting.
It SHALL describe this result without claiming general network associativity.

#### Scenario: Boundary-sensitive composition
- **WHEN** a suffix uses time or principal inputs dependent on its absolute position
- **THEN** the append theorem compares execution with the same positions and does not reset them at the suffix
