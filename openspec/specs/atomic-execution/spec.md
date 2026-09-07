# atomic-execution Specification

## Purpose
Define finite atomic transaction behavior with exact admission, fail-fast speculative execution and one committed public event.

## Requirements

### Requirement: Ordered complete admission

The system SHALL validate the catalog, entire left branch, entire right branch, lane uniqueness, participant uniqueness, complete participant coverage and exact schedule counts in that order. Shared footprints SHALL be permitted. Every admission refusal SHALL retain the event label, supplied schedule, exact typed reason and complete initial world without attempts or committed data.

#### Scenario: Shared funded admission

- **WHEN** both valid branches write a funded shared cell under a complete schedule
- **THEN** the request is admitted despite overlapping footprints

#### Scenario: Malformed unreachable suffix

- **WHEN** an unreachable invocation is structurally invalid and policy or schedule is also invalid
- **THEN** the entire branch structural error is reported before policy/schedule and the initial world is unchanged

#### Scenario: Policy and count precedence

- **WHEN** duplicate lane, duplicate participant, uncovered principal and count errors compete
- **THEN** the first error in the specified preflight order is returned with its typed identity and position

#### Scenario: Empty and malformed schedules

- **WHEN** empty branches have an empty schedule, or nonempty branches have missing/excess tokens
- **THEN** the empty case can commit identity and malformed counts refuse before speculation

### Requirement: One speculative world and local histories

Every scheduled active invocation SHALL execute once against the current speculative world using its own captured output history and trusted branch-local boundary. Successful attempts SHALL preserve their exact receipts and snapshots diagnostically. Public execution SHALL never recompute financial effects from a stale initial world or leak peer history.

#### Scenario: Live state after peer movement

- **WHEN** a peer changes a balance before a later live-read operation
- **THEN** the later receipt reflects the changed speculative balance

#### Scenario: Captured local snapshots

- **WHEN** two branches capture distinct values at the same qualified output key and then consume their own snapshots
- **THEN** each consumer uses its own captured value despite subsequent shared-world changes

#### Scenario: Peer-only output refusal

- **WHEN** an invocation references an output produced only by the peer beside an independently funded own-history sibling
- **THEN** the peer-only case refuses with the exact history error and the own-history sibling succeeds

#### Scenario: Local principal and time

- **WHEN** the global schedule position differs from the invocation local index
- **THEN** the actual call uses the fixed local principal/time, including live/revoked and authorized/unauthorized siblings

### Requirement: First failure aborts the whole event

The first attempted kernel refusal or successful-step settlement-policy violation SHALL stop all remaining own and peer invocations. The public abort SHALL restore the entire initial ledger and capability store and preserve label, schedule, branch, invocation, local index, zero-based global index and exact reason. Policy failure SHALL be distinguishable from a kernel refusal.

#### Scenario: Immediate failure stops peer

- **WHEN** the first attempted invocation refuses while later peer work would be valid
- **THEN** no peer or suffix attempt occurs and the public world is exactly the entry world

#### Scenario: Middle failure restores prefix

- **WHEN** a successful prefix is followed by a kernel refusal
- **THEN** all speculative prefix changes roll back publicly and the exact first refusal is retained

#### Scenario: Policy failure diagnostics

- **WHEN** an actual successful kernel step violates lane supply policy
- **THEN** diagnostics retain its real movement and updated obligations, the event aborts at that position, and no public effect commits

### Requirement: Committed publication and exact observations

The public result SHALL distinguish admission refusal, abort and commit. Only commit SHALL publish one named event containing ordered successful financial receipts, typed outputs, local identities and actual committed supply. Abort SHALL publish no committed inner receipt, output or supply. Public comparison SHALL preserve label, schedule, kind, full ledger/store, exact reasons/residuals and all committed financial fields; aborted diagnostic traces alone may be omitted.

#### Scenario: Committed event

- **WHEN** a nonempty event executes and settles successfully
- **THEN** one atomic event contains independently expected complete world/store/receipt/output data

#### Scenario: Aborted mint and history

- **WHEN** a nonlane asset is speculatively minted before a later refusal
- **THEN** the public mint supply is zero, the initial balances return and no tentative output can serve as later committed history

#### Scenario: Observation field sensitivity

- **WHEN** one preserved public field changes beside an equal-value control
- **THEN** the production comparison distinguishes every changed field and accepts the equal control

#### Scenario: Order-sensitive outcome

- **WHEN** identical invocations run under two valid orders with different funding availability
- **THEN** the exact commit/abort outcomes differ without any claim of atomic order independence
