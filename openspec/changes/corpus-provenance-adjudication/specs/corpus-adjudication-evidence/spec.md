## Purpose

Verify complete source-bound corpus records with deterministic actual CLI behavior and independently reviewable evidence that separates failure from inability to check.

## ADDED Requirements

### Requirement: Deterministic offline build and read-only check

The system SHALL build canonical outputs from complete bound inputs and check existing outputs without network access, repair or mutation under a hash-bound OS-enforced namespace/seccomp wrapper covering subprocesses, with an actual socket-denial and local-file positive self-test; unavailable enforcement is blocked, never silently bypassed.

#### Scenario: CHK-01 Repeatable real build

- **WHEN** the same frozen complete production inputs are built into two fresh output directories
- **THEN** canonical output bytes match and check exits zero for the record contract while disclosing unresolved facts

#### Scenario: CHK-02 Read-only malformed output check

- **WHEN** an existing generated projection is changed to a wrong readable value
- **THEN** check exits one with the violated item and leaves input/output bytes and modification times unchanged

#### Scenario: CHK-11 Actual offline denial

- **WHEN** build/check and a child-process socket probe run under the bound namespace/seccomp policy
- **THEN** the probe is actually denied while a local-file positive and valid offline projection succeed, with exact launcher/policy identities and no asserted-only network guarantee

#### Scenario: CHK-12 Offline enforcement unavailable

- **WHEN** the required launcher, namespace/seccomp support or denial self-test is unavailable
- **THEN** offline verification exits three with offline_isolation_unavailable and cannot claim a passed no-network check

### Requirement: Complete input and output identity safeguards

The system MUST reject incomplete/duplicate inventories, block unverifiable inputs and drift, and prevent output paths from overwriting protected inputs.

#### Scenario: CHK-03 Partial or duplicate queue

- **WHEN** a readable frozen work inventory omits or duplicates one item while actual bound INTERSECTION_UNRESOLVED records and raw symmetric differences still supply the complete independent denominator
- **THEN** validation reports a specific contract violation rather than treating the shortened population as complete

#### Scenario: CHK-04 Empty missing or malformed input

- **WHEN** a required input is absent, empty, unreadable or malformed
- **THEN** the command exits three and reports the precise inability to check, never a zero-item pass

#### Scenario: CHK-05 Source or driver drift

- **WHEN** relevant source/rule/schema/driver bytes or Git-object bindings change between initial binding and completion
- **THEN** the actual command exits three and invalidates run integrity; unrelated HEAD movement is recorded at both ends without relabeling or rejecting identical relevant inputs

#### Scenario: CHK-06 Unsafe output destination

- **WHEN** output exists or overlaps a repository/input/evidence root or traverses a symlink
- **THEN** the command blocks before mutation and preserves valid sources and siblings

#### Scenario: CHK-13 Closed work dispositions

- **WHEN** the full queue includes not_attempted, review_pending, attempted_unavailable, budget_exhausted, reviewed_unresolved and reviewed_resolved items
- **THEN** every enum value is counted; open first-two states block complete-work exit zero, the four documented terminal states may pass bookkeeping with required reasons/evidence, and unknown values violate the schema without implying factual closure

#### Scenario: CHK-14 Literal authoritative rules

- **WHEN** one displayed design predicate differs from the authoritative rules.json row or a decision binds another rule payload
- **THEN** validation rejects the drift while a literally equal rule/table and exact decision binding pass

#### Scenario: CHK-15 Refreshed official inventory

- **WHEN** a revised plan is frozen for review or implementation
- **THEN** current artifact/context/scenario/task/control manifests are regenerated and hash-bound, earlier copies remain historical, and a stale map cannot silently be used as the current inventory

### Requirement: Actual discriminating controls

The evidence SHALL exercise the real entry points on both defeating content and valid siblings and distinguish source fixtures from production primary evidence.

#### Scenario: CHK-07 Contradiction versus missing evidence

- **WHEN** a supported claim is mechanically invalid in one fixture and a claimed retained body is missing in another
- **THEN** actual CLI observations distinguish exit one violation from exit three blocked with named reasons and a passing sibling

#### Scenario: CHK-08 Local collection fixture

- **WHEN** a local HTTP fixture exercises redirects, unavailable bodies or size limits
- **THEN** the report identifies it as a harness control and never counts it as a real protocol primary source

### Requirement: Exact accepted evidence and honest delivery

The package SHALL bind final inventories, actual logs and independent reviews to exact source/tool/model identities and preserve unresolved obligations when updating delivery status.

#### Scenario: CHK-09 Final independent reconciliation

- **WHEN** frozen production runs and native Grok/Fable 5.1 reviews are collected with Fable requested as `claude-fable-5-1[1m]` at `--effort medium`
- **THEN** each counted item and artifact hash reconciles to the exact candidate, unavailable review stays open and advisory acceptance is not financial proof

#### Scenario: CHK-10 Accepted limited package

- **WHEN** record tooling is accepted while original bytes, deployments or semantic disputes remain unresolved
- **THEN** delivery and roadmap updates distinguish accepted tooling from unresolved factual obligations and preserve independent accepted kernel sprint deliveries, including Sprint 9 archive 9908d9b56be2d5ed2b58a16fa8d28b23f33733ff
