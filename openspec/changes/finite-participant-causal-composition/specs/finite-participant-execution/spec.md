## Purpose

Specify finite participant execution for actual finite shared-state execution with explicit assumptions and reproducible evidence.

## ADDED Requirements

### Requirement: Ordered complete participant contract

The operator SHALL accept an explicit finite ordered roster containing every participant exactly once as a typed parameter contract, keep stream identity distinct from trusted principal identity, and require no new malformed-roster runtime checker.

#### Scenario: Empty participant universe
- **WHEN** the participant type is empty and the catalog is valid
- **THEN** the only schedule is empty and execution retains the exact entry world with no locals or attempts

#### Scenario: Singleton and principal sharing
- **WHEN** a singleton roster executes, or two distinct streams authenticate the same principal
- **THEN** each stream retains its own local state and the roster neither invents nor merges streams

### Requirement: Static admission and complete counts

Admission SHALL validate configuration, analyze every complete branch in roster order, and only then check exact schedule counts in that order; overlap SHALL be admitted and the first mismatch SHALL identify participant, expected length and observed count.

#### Scenario: Invalid catalog precedes all other errors
- **WHEN** catalog, an early branch and schedule are invalid
- **THEN** configuration refusal preserves the entry world and supplied schedule

#### Scenario: Malformed refused suffix precedes counts
- **WHEN** a branch has a financially refusing prefix and a structurally invalid suffix while counts also mismatch
- **THEN** admission reports that participant and the exact suffix local failure before any count error

#### Scenario: Last participant mismatch
- **WHEN** only the final roster participant has an incorrect occurrence count
- **THEN** the exact final participant expected and observed counts are reported

#### Scenario: Shared writes are legal
- **WHEN** structurally valid branches write a common vault and counts match
- **THEN** static admission succeeds without asserting commutativity

### Requirement: Selected actual invocation and isolated histories

Each active available token SHALL call the actual invocation executor with the selected stream history, current world and trusted boundary at its successful absolute index, and SHALL publish its exact successful result while leaving every unselected local state unchanged.

#### Scenario: Three nonempty shared streams
- **WHEN** one withdrawal and two deposits execute in a complete schedule
- **THEN** the exact shared balances, all three independent histories and ordered actual attempts match independent expectations

#### Scenario: Same qualified keys in distinct histories
- **WHEN** two streams produce different values with the same qualified key and index using one catalog-valid parameterized producer (component port IDs are unique, so two producer interfaces cannot share one output port)
- **THEN** each consumer reads its own producer value only

#### Scenario: Position-sensitive trusted boundary
- **WHEN** a stream reaches index1 with a boundary different from index0
- **THEN** actual authority and receipt behavior uses index1 rather than a constant boundary

### Requirement: Refusal and skipped tokens retain exact observations

An actual refusal SHALL retain the first located reason and append its error attempt without changing financial world or successful history; failed and exhausted tokens SHALL consume a slot without an attempt, and SHALL permit peers to continue.

#### Scenario: Refused stream suffix and peer continuation
- **WHEN** a stream succeeds then refuses and is selected again before a funded peer
- **THEN** its successful prefix and failure remain, the extra token only increments consumed, and the peer executes

#### Scenario: Exhausted arbitrary prefix
- **WHEN** a singleton branch is selected after its final success in a prefix runner
- **THEN** consumed increases while nextIndex, world, events, outputs and attempts remain unchanged

#### Scenario: No financial publication on admission refusal
- **WHEN** static admission refuses a nonempty scheduled program
- **THEN** the full entry ledger/store and schedule are retained without executing a prefix

### Requirement: Reachable actual trace and accounting

The formal development SHALL connect every executed prefix to actual calls, derive exact successful history and attempt order, complete consumed counts, fixed capability store, full signed receipt accounting and analyzed frames, and SHALL distinguish genesis reachability from arbitrary-entry assumptions.

#### Scenario: Complete active stream is exhausted
- **WHEN** an admitted complete schedule finishes with an active stream
- **THEN** its consumed and nextIndex equal branch length and no invocation remains

#### Scenario: Error contributes no successful receipt
- **WHEN** a successful prefix is followed by a refused call and a skip
- **THEN** only actual successful receipts contribute signed balance changes, and all store cells remain exact

#### Scenario: Framed domain and asset
- **WHEN** successful shared execution never writes a sentinel in another domain or asset
- **THEN** the sentinel and all other unanalyzed cells retain their entry values
