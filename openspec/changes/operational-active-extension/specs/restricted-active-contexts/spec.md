## Purpose

Defines a restricted contextual substitution law whose observers and operational constructors preserve the stated protected execution interface.

## ADDED Requirements

### Requirement: XC01 Universal related-entry sequential contexts

Sequential context congruence SHALL quantify over arbitrary related input cursors and use actual invocation-only execution with supported fixed prefixes/suffixes and exact absolute boundaries.

#### Scenario: C01 A supported invocation prefix or suffix surrounds equivalent groups

- **WHEN** a supported invocation prefix or suffix surrounds equivalent groups
- **THEN** the resulting protected cursors remain equivalent without resetting failure/history/index.

#### Scenario: C02 Two groups agree only at one funded entry

- **WHEN** two groups agree only at one funded entry
- **THEN** that equality is insufficient for general contextual substitution and a distinguishing entry is retained.

### Requirement: XC02 Prefix-sensitive active peer contexts

Insertion of active peers SHALL require matching old token-prefix behavior and slot counts plus the extension premises, not endpoint group equality alone.

#### Scenario: C03 New peer slots are inserted before, between and after matching old prefixes

- **WHEN** new peer slots are inserted before, between and after matching old prefixes
- **THEN** the actual extended executions preserve the old projected correspondence.

#### Scenario: C04 Only old endpoints agree while intermediate protected observations differ

- **WHEN** only endpoint balances agree, or equal sequential cursors have different skipped-slot structure
- **THEN** the stronger interleaving substitution premise is not satisfied; the counterexample is not hidden by endpoint equality.

### Requirement: XC03 Excluded observation and administrative constructors

The context grammar SHALL exclude arbitrary inspection of omitted raw data, merged peer history, store modification and transaction-wide abort, with separate negative companions.

#### Scenario: C05 A continuation reads an omitted ledger cell or changes old capability liveness

- **WHEN** a continuation reads an omitted ledger cell or changes old capability liveness
- **THEN** the claimed unrestricted law fails under actual execution and the context is outside the theorem.

#### Scenario: C06 An unrelated grant entry is added before an administrative issue

- **WHEN** an unrelated grant entry is added before an administrative issue
- **THEN** fresh capability ID/receipt/store can differ despite equal balances; no allocation-renaming theorem is inferred.

#### Scenario: C07 A disjoint added peer refuses inside Atomic

- **WHEN** a disjoint added peer refuses inside Atomic
- **THEN** the actual batch aborts/rolls back and ordinary interleaving extension is not promoted to atomic extension.
