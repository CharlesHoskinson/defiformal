## ADDED Requirements

### Requirement: Trusted initialization and actual traces
The implementation SHALL state provenance over initialized Composition.TraceSound traces and an explicit trusted-root policy. Arbitrary cursors, event lists and final-store legitimacy assumptions SHALL NOT replace initialization.

#### Scenario: P01 Nonempty roots
- **GIVEN** a nonempty store and an explicit RootsAccepted proof
- **WHEN** an actual run is observed
- **THEN** provenance includes the exact initial grant scope; the proof does not infer root authenticity.

#### Scenario: P02 Empty initialization
- **GIVEN** an empty store
- **WHEN** an actual successful issue occurs
- **THEN** its origin is the authorized event and the empty-root obligation is discharged.

#### Scenario: P03 Uninitialized counterexample
- **GIVEN** a manually constructed live entry without an accepted root premise
- **WHEN** the existing kernel admits a funded invocation
- **THEN** the example refutes unconditional issue-history provenance and is not labelled an authenticated grant.

### Requirement: Causal origin completeness and scope
The implementation SHALL prove every final entry has a trusted initial or actual authorized issue origin, with unique ID origin and complete immutable scope. Causal witnesses SHALL come from the actual initialized prefix.

#### Scenario: P04 Actual issue witness
- **GIVEN** a final entry absent initially
- **WHEN** provenance is proved
- **THEN** an actual preceding issue equation at its recorded boundary and pre-store witnesses administrator, operation-domain and resource-domain authorization.

#### Scenario: P05 Complete immutable grant
- **GIVEN** an issued entry that is subsequently revoked
- **WHEN** its origin is read
- **THEN** holder, domain, operation and right match the original grant while liveness may be false.

#### Scenario: P06 Absolute issue position
- **GIVEN** issue/invocation/issue interleaving
- **WHEN** an origin index is returned
- **THEN** it is the actual event index and not an issue ordinal.

### Requirement: Fresh allocation and permanent tombstones
The implementation SHALL prove append-only allocation, exact successful-issue length accounting, scope preservation and permanent dead status across actual trace extensions. Revocation SHALL retain IDs and no issued ID SHALL reuse an earlier allocation.

#### Scenario: P07 Equal grants distinct IDs
- **GIVEN** two successful equal grants
- **WHEN** their IDs are compared
- **THEN** each equals its own pre-store length and the IDs differ.

#### Scenario: P08 Revoke and reissue
- **GIVEN** a revoked old ID
- **WHEN** the same grant is issued again
- **THEN** the old entry remains allocated and dead and the new entry uses the next fresh ID.

#### Scenario: P09 Exact count
- **GIVEN** any actual successful prefix
- **WHEN** length is measured
- **THEN** it equals initial length plus successful issue count; invocations and revocations contribute zero.

### Requirement: Current pre-store use and provenance
The implementation SHALL connect existing invocation/debit/supply authority to each actual pre-step store and its causal origins, preserving exact holder/domain/operation/right and trusted actor applicability. Existing net-effect and reusable-capability semantics SHALL remain unchanged.

#### Scenario: P10 Revoked use refused
- **GIVEN** a successful revoke
- **WHEN** the old ID is used at the next actual invocation
- **THEN** current-store authority fails despite its historical issue origin.

#### Scenario: P11 Exact right witnesses
- **GIVEN** an accepted invocation with negative aggregate debit and nonzero supply
- **WHEN** authority is extracted
- **THEN** each exact right has a requested live current-pre-store ID and an initialized origin.

#### Scenario: P12 Duplicate and invalid IDs
- **GIVEN** absent, dead or wrongly scoped IDs preceding a valid one
- **WHEN** currentAuthorityOrigin runs
- **THEN** it returns the first current authorized witness and duplicate IDs add no rights.

### Requirement: Rejected administration retains the prefix
The implementation SHALL prove exact prefix retention and no allocation on rejected administration, with existing failure precedence and permanent halt. It SHALL NOT claim the first rejecting step leaves the whole cursor identical.

#### Scenario: P13 Unauthorized admin
- **GIVEN** a funded successful prefix
- **WHEN** issue or revoke is rejected
- **THEN** ledger, store, events, outputs and nextIndex remain exact while only the located failure is added.

#### Scenario: P14 Rejection precedence
- **GIVEN** competing invalid inputs
- **WHEN** executeStep rejects
- **THEN** catalog validation precedes administration and unknown revoke ID precedes administrator lookup as in existing source.

#### Scenario: P15 Halted suffix
- **GIVEN** an administrative refusal
- **WHEN** any suffix is supplied
- **THEN** the failed cursor is unchanged; successful reissue examples use a separate valid checkpoint/run.

### Requirement: Read-only query correspondence
The implementation SHALL add total read-only origin and current-authority queries with soundness/completeness under initialized actual trace premises. It SHALL delegate execution without changing the old executor, and SHALL distinguish arbitrary-data readback from provenance certification.

#### Scenario: P16 Delegated actual run
- **GIVEN** auditRun inputs
- **WHEN** execution completes or refuses
- **THEN** the returned cursor equals the actual Composition.run result in all raw observable fields.

#### Scenario: P17 Origin query on actual data
- **GIVEN** an initialized actual cursor
- **WHEN** originOf/currentAuthorityOrigin returns a witness
- **THEN** its complete origin/current-authority meaning is proved and converse completeness is stated.

#### Scenario: P18 Forged event readback
- **GIVEN** an artificial issue event
- **WHEN** a raw readback returns an origin
- **THEN** it is explicitly not a certificate without an initialized trace witness; the negative example does not enter production evidence as actual execution.
