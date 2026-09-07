## Purpose

Relates the independently executed participant tree to the flat machine without erasing fixed-schedule execution data.

## ADDED Requirements

### Requirement: R05 Exact full observation
The full observation and executable comparator SHALL retain full ledger/store, all local consumed/nextIndex/history/event/receipt/failure fields and every raw global attempt/outcome; comparator truth SHALL be equivalent to the complete representation relation.

#### Scenario: S11 Every stored field matters
- **WHEN** a synthetic pair differs in one retained full field
- **THEN** full comparison is false without claiming the pair is reachable

#### Scenario: S12 Literal execution observation
- **WHEN** the funded execution is compared with its independent expected full machine
- **THEN** all raw event/attempt worlds and capability records match

### Requirement: R06 Noncircular simulation
The development SHALL prove initialization, shape preservation, one-token simulation in both directions and arbitrary-entry continuation from actual execution equations; flattening SHALL be a representation conversion rather than the production dispatch implementation.

#### Scenario: S13 Populated entry
- **WHEN** tree and flat entries are fully related with histories/failures already present
- **THEN** continuations remain fully related with no resets

#### Scenario: S14 Actual refusal and skip
- **WHEN** a related selected local refuses or is already failed/exhausted
- **THEN** the same actual error/none append behavior and counters are preserved

#### Scenario: S15 Malformed raw fallback excluded
- **WHEN** a raw tree has duplicate or missing identity
- **THEN** documented total fallback is tested but no well-formed simulation theorem is claimed

### Requirement: R07 Fixed schedule behavioral regrouping
For identical static parameters, valid trees, related starts and the same decoded schedule, the system SHALL prove equality of full observations, including association and empty-node units, without requiring disjoint writes or changing token order.

#### Scenario: S16 Overlapping execution
- **WHEN** withdrawals7/6 compete for10 with fixed order b0,b1 across tree shapes
- **THEN** both give vault3 and the same peer refusal/history/attempt data

#### Scenario: S17 Group association and units
- **WHEN** the funded valid tree is reassociated or gains empty internal nodes
- **THEN** full fixed-schedule results are unchanged

### Requirement: R08 Result and initialization correspondence
The development SHALL map exact admitted/refused result constructors and original stable schedules to M3 and SHALL state arbitrary-entry representation premises separately from genesis reachability; accepted S9 sequential administration SHALL retain its separate scope.

#### Scenario: S18 Refused result projection
- **WHEN** base admission fails before execution
- **THEN** projection retains the exact M3 reason, submitted schedule and entry world

#### Scenario: S19 No implicit restart
- **WHEN** a populated entry is continued across chunks and tree boundaries
- **THEN** complete existing cursor data and first failures survive
