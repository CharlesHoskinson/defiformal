## Purpose

Preserves actual old prefix behavior under explicit initial, configuration, boundary, store and one-way write-isolation premises.

## ADDED Requirements

### Requirement: XS01 Explicit configuration and initialization premises

The theorem SHALL require valid old/new catalogs, supported old lookups/templates, all-domain administrator equality, equal old boundaries, equal full stores and initial agreement on S.

#### Scenario: S01 Only unreferenced well-formed declarations are added

- **WHEN** only unreferenced well-formed declarations are added
- **THEN** old configuration dependencies agree and the added peers can execute under the extended configuration.

#### Scenario: S02 An added declaration or unreachable branch suffix is malformed

- **WHEN** an added declaration or unreachable branch suffix is malformed
- **THEN** actual extended admission refuses in the inherited order; the old-admission theorem is not applied.

#### Scenario: S03 Initial protected funds, an old boundary or a required template differs

- **WHEN** initial protected funds, an old boundary or a required template differs
- **THEN** the missing premise is exposed with a matching positive sibling and actual differing behavior where claimed.

### Requirement: XS02 One-way complete support

Isolation SHALL cover all old analyzed reads, writes and snapshot cells and exclude all new writes from S, without requiring new reads to avoid old writes.

#### Scenario: S04 A new peer reads a protected balance and changes only an unprotected cell

- **WHEN** a new peer reads a protected balance and changes only an unprotected cell
- **THEN** old preservation holds although symmetric read/write compatibility fails.

#### Scenario: S05 A snapshot-only cell is omitted from S or a peer writes it

- **WHEN** a snapshot-only cell is omitted from S or a peer writes it
- **THEN** the isolation/coverage obligation fails and the actual snapshot-sensitive negative distinguishes the old outputs.

#### Scenario: S06 Multiple overlapping violations exist

- **WHEN** multiple overlapping violations exist
- **THEN** the finite isolation checker returns the first violation in the documented roster/analyzer order.

### Requirement: XS03 Actual prefix and continuation simulation

The proof SHALL follow actual old success/refusal/skip and new success/refusal/skip transitions, yielding equal old projections after every restricted prefix without assuming the desired whole-run equality.

#### Scenario: S07 An old token executes successfully or refuses

- **WHEN** an old token executes successfully or refuses
- **THEN** the matching old-only token has exact receipt/outputs or exact located refusal and identical protected before/post observations.

#### Scenario: S08 A new peer refuses with later static slots remaining

- **WHEN** a new peer refuses with later static slots remaining
- **THEN** old streams continue, the failed peer suffix skips and only the projection stutters.

#### Scenario: S09 A related populated entry includes nonzero positions, history and a failed old stream

- **WHEN** a related populated entry includes nonzero positions, history and a failed old stream
- **THEN** continuation preserves the projection under explicit slot alignment, including arbitrary extra skipped tokens.

### Requirement: XS04 Supported invariant and tree transport

The extension SHALL transport only predicates supported on S with separately established old preservation, and tree claims SHALL use actual accepted fixed-schedule simulation.

#### Scenario: S10 The old invariant is initialized, preserved and supported on S

- **WHEN** the old invariant is initialized, preserved and supported on S
- **THEN** it holds on every extended prefix under the projection theorem.

#### Scenario: S11 A purported invariant reads an omitted cell or a global total changed by peer mint

- **WHEN** a purported invariant reads an omitted cell or a global total changed by peer mint
- **THEN** protected equality alone does not establish it and a concrete differing predicate is retained.

#### Scenario: S12 A valid accepted M4 tree represents the same roster, world and fixed schedule

- **WHEN** a valid accepted M4 tree represents the same roster, world and fixed schedule
- **THEN** the active projection follows through the actual tree simulation, without assuming raw equality across different schedules.
