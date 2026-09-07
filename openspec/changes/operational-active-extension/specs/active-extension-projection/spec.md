## Purpose

Defines exactly which old execution fields remain observable after extra participants and their schedule slots are added.

## ADDED Requirements

### Requirement: XP01 Stable participant and schedule restriction

The extension SHALL retain a fixed ledger universe and a stable inclusion of old participant identities, with order-preserving schedule restriction and exact old token counts.

#### Scenario: P01 An extended schedule contains interspersed new IDs

- **WHEN** an extended schedule contains interspersed new IDs
- **THEN** restriction deletes only those IDs and preserves old identity/order/multiplicity.

#### Scenario: P02 An extended schedule is complete

- **WHEN** an extended schedule is complete
- **THEN** the restricted schedule is complete for all old streams, including skipped suffix slots.

#### Scenario: P03 The old set is empty or contains every participant

- **WHEN** the old set is empty or contains every participant
- **THEN** restriction and observation have their exact limiting behavior, without replacing the required nonempty financial positives.

### Requirement: XP02 Complete protected observations

The projection SHALL retain balances on S, the entire store, old consumed/index/failure/history/events and chronologically filtered old attempts with every embedded world projected onto S.

#### Scenario: P04 A new peer changes an unprotected balance

- **WHEN** a new peer changes an unprotected balance
- **THEN** the projected old world is unchanged by that step while the full extended world can differ.

#### Scenario: P05 An old receipt, output, failure or local counter differs

- **WHEN** an old receipt, output, failure or local counter differs
- **THEN** the production comparator reports inequality with all other projected fields equal.

#### Scenario: P06 Old events and attempts contain differing protected before or result balances

- **WHEN** old events and attempts contain differing protected before or result balances
- **THEN** the production comparator detects the difference even if current endpoint balances agree.

### Requirement: XP03 Do not publish omitted peer data as old evidence

The projection SHALL remove only new participant observations and SHALL derive old supply from actual retained old receipts, not the extended aggregate.

#### Scenario: P07 An added peer publishes a matching qualified output

- **WHEN** an added peer publishes a matching qualified output
- **THEN** the old own-history list remains exact and cannot consume the peer output.

#### Scenario: P08 A new peer mints outside S in an asset also used by old streams

- **WHEN** a new peer mints outside S in an asset also used by old streams
- **THEN** its supply is omitted from old supply while every old receipt asset/domain amount remains exact.

#### Scenario: P09 A new token refuses or skips

- **WHEN** a new token refuses or skips
- **THEN** no old attempt is invented, and the old relative attempt order remains unchanged.
