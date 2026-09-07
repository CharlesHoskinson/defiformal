## ADDED Requirements

### Requirement: Explicit world-observation support
The implementation SHALL define support over ledger cells, exact selected capability lookups and optional nextId. Value-valued observers and predicates SHALL have explicit support proofs; ledger-only Supports SHALL NOT be reused for store-sensitive observers.

#### Scenario: I01 Ledger and capability projection
- **GIVEN** a finite policy
- **WHEN** observeWorld executes
- **THEN** every ordered ledger cell and exact optional capability entry is returned, preserving IDs, list shape and all grant/live fields.

#### Scenario: I02 Allocation metadata opt-in
- **GIVEN** identical selected cells/lookups but differing length
- **WHEN** observeNextId is true
- **THEN** views differ; when false this metadata is absent.

#### Scenario: I03 Supported value proof
- **GIVEN** a fixed observer and a proved SupportsObservation premise
- **WHEN** WorldAgrees holds
- **THEN** the complete selected observer value is equal without inferring support automatically.

### Requirement: Actual ledger and administration frames
The implementation SHALL derive frames from actual receipt writes and successful administrative IDs, with no successful issue when allocation length is observed. It SHALL separately discharge concrete premises rather than assume the final observation equality.

#### Scenario: I04 Unselected administration
- **GIVEN** actual writes outside the selected ledger region and issued/revoked IDs outside selected IDs, with length hidden
- **WHEN** a prefix executes
- **THEN** the supported world view is preserved.

#### Scenario: I05 Absent selected ID
- **GIVEN** a selected currently absent ID equal to the next allocated ID
- **WHEN** issuance occurs
- **THEN** the store frame premise fails and the view can change.

#### Scenario: I06 Selected revoke or visible allocation
- **GIVEN** a selected live ID or visible nextId
- **WHEN** a revoke or issue affects that observation
- **THEN** a ledger-only equality is insufficient and the negative companion exhibits the changed value.

### Requirement: Validated direct private access isolation
The implementation SHALL prove direct peer-private read/write exclusion using actual catalog validation and component selection, then lift accepted peer write locality to prefixes. Authority grants SHALL NOT be described as carrying a component identity absent from their actual type.

#### Scenario: I07 Distinct peer direct read
- **GIVEN** a validated catalog and distinct registered components
- **WHEN** one attempts to resolve a direct read of the other private cell
- **THEN** canRead is false and execution refuses the access.

#### Scenario: I08 Distinct peer direct write
- **GIVEN** the same validated ownership setup
- **WHEN** the peer attempts a direct write
- **THEN** canWrite is false and accepted peer execution preserves that private ledger cell.

#### Scenario: I09 Owner access positive
- **GIVEN** the owning component and an otherwise valid funded call
- **WHEN** it accesses its own private cell
- **THEN** the positive case succeeds; private isolation is not an always-reject claim.

### Requirement: Observation disclosure and missing-premise companions
The implementation SHALL include real negative companions separating denied writes, direct private reads, published outputs and capability-store observation. It SHALL NOT claim confidentiality or equality of global event/history observations from the supported world frame.

#### Scenario: I10 Read-only information flow
- **GIVEN** a readable nonwritable shared balance in two worlds
- **WHEN** it controls a guard or output
- **THEN** no writes to that balance coexist with distinct exact outcomes/observations.

#### Scenario: I11 Private output publication
- **GIVEN** an owner output port on its private cell
- **WHEN** the owner publishes and a peer consumes the typed priorOutput
- **THEN** the successful disclosure is retained and confidentiality is not inferred from direct-read exclusion.

#### Scenario: I12 Store-sensitive property
- **GIVEN** a property depending on a selected live capability
- **WHEN** that ID is revoked with ledger unchanged
- **THEN** the property can change and its store support is necessary.

### Requirement: Operator applicability and remaining gaps
The implementation SHALL limit mixed administration to actual sequential semantics and initialized grouping. Existing fixed-store operator corollaries SHALL remain conditional; concurrent allocation and atomic administration SHALL remain explicitly unresolved.

#### Scenario: I13 Initialized sequential groups
- **GIVEN** an initialized cursor and a sequential group with administration
- **WHEN** flattened and executed
- **THEN** the accepted M1 simulation transfers the provenance/frame claims and exact refusal prefix.

#### Scenario: I14 Fixed-store invocation operators
- **GIVEN** existing parallel/interleaving invocation-only branches
- **WHEN** their store corollaries are used
- **THEN** provenance remains trusted-initial-store provenance without invented administrative events.

#### Scenario: I15 Unsupported administrative concurrency
- **GIVEN** a proposed concurrent issue/revoke or atomic administration claim
- **WHEN** scope is checked
- **THEN** it remains a later gap requiring new allocator, visibility and rollback semantics and is not marked complete here.
