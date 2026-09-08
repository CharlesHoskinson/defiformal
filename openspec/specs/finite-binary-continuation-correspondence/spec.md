# finite-binary-continuation-correspondence Specification

## Purpose
Specify finite binary continuation correspondence for actual finite shared-state execution with explicit assumptions and reproducible evidence.

## Requirements

### Requirement: Exact binary specialization

Specialization to ordered left and right participants SHALL simulate the existing binary shared executor on every stored field and result, including raw event worlds, consumed counts, evaluated receipts, located failures, attempt ordering and retained schedules.

#### Scenario: Arbitrary binary prefix
- **WHEN** the schedule includes successful, refused and exhausted selections without a completeness premise
- **THEN** the converted new machine equals the existing binary machine exactly

#### Scenario: Binary two-count refusal payload
- **WHEN** both left and right counts mismatch
- **THEN** the error projection reconstructs both expected and observed counts from the original inputs

#### Scenario: Binary malformed suffix
- **WHEN** an unreachable structural suffix and schedule error coexist
- **THEN** both operators return the same participant and local structural failure before schedule checking

### Requirement: Arbitrary-entry continuation chunking

Continuing an arbitrary machine over concatenated schedules SHALL equal successive continuation over the chunks, retaining all entry data; the three-chunk associativity law SHALL preserve the identical token sequence and SHALL not claim participant-tree or schedule-order equivalence.

#### Scenario: Populated arbitrary entry
- **WHEN** entry has prior events and outputs, nonzero positions and a failed peer
- **THEN** one concatenated continuation and successive chunks retain the same full machine including old raw event worlds

#### Scenario: Three chunks with refusal
- **WHEN** a refusal occurs in the middle chunk and a peer runs in the last
- **THEN** both chunk parenthesizations produce the same full machine and peer result

#### Scenario: Conflicting schedules remain distinct
- **WHEN** two authorized streams attempt withdrawals7 and6 from vault10 in opposite orders
- **THEN** the appropriate first withdrawal succeeds and the second refuses; no equality across schedules is claimed

### Requirement: Complete executable observation relation

The finite observation query SHALL compare full world/store, every roster local field and every event/attempt field, including raw worlds and evaluated receipts, and SHALL have a theorem relating true to exact machine equality.

#### Scenario: Independent full machine expectation
- **WHEN** a funded three-stream execution is compared with literal expected states, receipts, histories and attempts
- **THEN** the complete query returns true without generating expectations through the candidate executor

#### Scenario: Single-field arbitrary pair separation
- **WHEN** two explicitly synthetic machines differ only in one stored field or one historical raw world
- **THEN** the query returns false for every such field, with these cases labeled as synthetic rather than reachable executions
