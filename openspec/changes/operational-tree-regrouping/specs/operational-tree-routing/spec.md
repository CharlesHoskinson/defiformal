## Purpose

Preserves stable participant identities while routing actual shared-state execution through a finite tree.

## ADDED Requirements

### Requirement: R01 Stable roster and shape
The system SHALL use the same fixed complete/nodup M3 roster and SHALL require exactly one leaf per participant, allowing explicit empty nodes without changing identity or creating a private world.

#### Scenario: S01 Empty universe
- **WHEN** the participant universe and schedule are empty
- **THEN** the empty tree preserves the entire entry world/store and creates no attempts

#### Scenario: S02 Regrouped identities
- **WHEN** a complete three-leaf tree is reassociated or wrapped with empty nodes
- **THEN** every original identity remains present exactly once

### Requirement: R02 Ordered admission and refusal identity
The admitted runner SHALL first return the exact actual M3 admission error when present, then the roster-first tree multiplicity error; every admission refusal SHALL retain full entry world/store and create no machine or attempts.

#### Scenario: S03 Duplicate and missing leaf
- **WHEN** base admission succeeds for duplicate/missing trees
- **THEN** the exact participant/expected1/observed count follows roster order

#### Scenario: S04 Base precedence
- **WHEN** a malformed tree coexists with configuration, full-suffix structural or count error
- **THEN** the actual base error wins with its complete payload

#### Scenario: S05 Unreachable malformed suffix
- **WHEN** a financially failing branch has a structurally invalid later invocation
- **THEN** full base analysis still refuses before tree checking

### Requirement: R03 Actual recursive routing
The dispatcher SHALL independently descend the tree and execute the selected invocation at most once using actual executeStep, consumed for selection and own nextIndex/history for preparation; it SHALL preserve all unselected locals and apply exact success/refusal/skip updates.

#### Scenario: S06 Disjoint funded leaves
- **WHEN** all six invocations are selected in any of the90 complete schedules
- **THEN** literal expected full machines and unchanged peer locals are obtained

#### Scenario: S07 Refusal does not cancel peers
- **WHEN** a branch has refused and further tokens select it and peers
- **THEN** only its consumed counter advances on skips while peers execute and first refusal remains

#### Scenario: S08 Own absolute boundary
- **WHEN** the selected successful position is1 with distinct boundary identity/time
- **THEN** index1 boundary and own history are used exactly

### Requirement: R04 Path schedules preserve stable names
The system SHALL decode paths in order with exact first invalid token/path, validate all submitted paths before runTreePaths admission, and prove re-encoding across well-formed trees preserves the decoded name schedule and append offsets.

#### Scenario: S09 Re-encode after regrouping
- **WHEN** the same stable schedule is encoded for two valid shapes
- **THEN** each decodes to the identical token list, while copying old paths is not presumed equivalent

#### Scenario: S10 Invalid full suffix
- **WHEN** an invalid path follows two valid paths, even after an eventual financial failure
- **THEN** the wrapper returns invalidPath at token2 before financial execution
