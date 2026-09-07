# continuation-observation Specification

## Purpose
Specify exact observable continuation data and substitution laws for a restricted sequential context grammar.

## Requirements

### Requirement: Exact cursor observations

Cursor observation SHALL retain the full current typed ledger, complete capability store, ordered event index/action/receipt/output fields, frozen qualified history, absolute next position and complete optional located failure. Only past raw event worlds and proof terms SHALL be omitted. Production comparison SHALL expose local separable ledger, store, events, history, next-position and failure conjuncts, with a local per-event index/action/receipt/output comparison. Existing world/branch equality SHALL be reused only in correctness proofs, not as delegated runtime comparison.

#### Scenario: Current world sensitivity

- **WHEN** two cursors differ only at a current ledger cell
- **THEN** their observations differ

#### Scenario: Complete store sensitivity

- **WHEN** two cursors have equal ledgers but different store entries or tombstones
- **THEN** their observations differ

#### Scenario: Qualified output sensitivity

- **WHEN** otherwise equal cursors differ in frozen history value, unit, producer position or qualified key
- **THEN** their observations differ and history order remains significant

#### Scenario: Receipt sensitivity

- **WHEN** otherwise equal event observations differ in invoked request, evaluated receipt, issue ID or revoke ID
- **THEN** their cursor observations differ

#### Scenario: Located failure sensitivity

- **WHEN** otherwise equal cursors differ in failure reason, position or optional failed action
- **THEN** their observations differ

#### Scenario: Next position sensitivity

- **WHEN** otherwise equal cursors have different absolute next positions
- **THEN** their observations differ

### Requirement: Observation equivalence laws

The production comparison SHALL decide the declared observation equivalence, and that equivalence SHALL be reflexive, symmetric and transitive. Equality SHALL NOT silently include or exclude different fields in separate consumers.

#### Scenario: Equivalence laws

- **WHEN** arbitrary well-typed cursors, including explicitly synthetic/unreachable observer pairs, are compared
- **THEN** the Boolean comparison corresponds exactly to the stated relation and all three equivalence laws hold

#### Scenario: Omitted past diagnostic worlds

- **WHEN** cursors agree on all observed fields but differ in a past raw event world
- **THEN** the selected observer equates the explicitly synthetic pair while retaining the restriction on raw diagnostic inspection and making no claim of two reachable traces differing only there

### Requirement: Restricted contextual substitution

Sequential substitution SHALL hold for one-hole contexts formed only by fixed groups before or after the hole under the same configuration and boundary function. Group equivalence SHALL quantify over every pair of equivalent input cursors, and execution SHALL preserve all required continuation data.

#### Scenario: Output-consuming suffix

- **WHEN** equivalent groups are followed by a fixed continuation consuming an earlier qualified snapshot
- **THEN** the filled contexts remain observationally equivalent with the same exact history and results

#### Scenario: Fixed prefix and suffix

- **WHEN** a one-hole context has fixed nonempty groups before and after the hole
- **THEN** equivalent replacement groups remain equivalent for every equivalent input cursor

#### Scenario: Failure-bearing replacement

- **WHEN** equivalent replacement results already carry the same first failure
- **THEN** the fixed suffix remains inert and the filled contexts preserve that exact refusal

### Requirement: Necessary continuation premises

The evidence SHALL include actual counterexamples to substitution based only on equal current ledger or one particular initial execution. Restricted contexts SHALL NOT add peers, inspect omitted raw worlds, change trusted boundaries or move an atomic commit boundary.

#### Scenario: Missing history premise

- **WHEN** equal-ledger cursors provide different frozen snapshots to the same consumer
- **THEN** the actual continuation results differ

#### Scenario: Missing index premise

- **WHEN** equal-ledger cursors select different index-dependent trusted boundaries
- **THEN** the actual continuation authorization or output differs

#### Scenario: Missing store premise

- **WHEN** equal-ledger cursors have different existing capability entries before the same authorized issue
- **THEN** the actual fresh issued IDs and complete stores differ

#### Scenario: One-entry agreement is insufficient

- **WHEN** two groups share the same initially refusing action but have different suffixes, and a fixed authorized funding prefix enables that action
- **THEN** equality at the original entry does not imply equal filled-context execution, demonstrating the need for universal input-cursor equivalence
