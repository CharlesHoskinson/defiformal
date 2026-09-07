# atomic-preservation Specification

## Purpose
Establish generic proofs about actual atomic executions, committed preservation, exact rollback and receipt-linked transient cash conservation.

## Requirements

### Requirement: Actual trace and stop soundness

The implementation SHALL prove that every diagnostic machine arises from an actual prefix of the supplied existing interleaving execution with exact appended invocation outcomes, local histories and boundary indices. After first abort its diagnostic state SHALL remain inert. A complete un-aborted event SHALL exhaust every static invocation.

#### Scenario: Actual-prefix witness

- **WHEN** any finite atomic diagnostic prefix is reached
- **THEN** the proof relates that machine to a real interleaving prefix rather than an unrelated supplied trace

#### Scenario: Global stop theorem

- **WHEN** an abort is followed by any remaining schedule suffix
- **THEN** the entire diagnostic state remains unchanged

#### Scenario: Complete exhaustion

- **WHEN** a complete request reaches final settlement without an earlier abort
- **THEN** all branch invocations were successfully exhausted

### Requirement: Cash and obligations conserve

For every reached diagnostic prefix and configured lane, the implementation SHALL prove that current vault cash plus the sum of participant obligations equals entry vault cash, including a successful step causing policy abort. Full clearance SHALL be equivalent to pointwise zero over the complete table and SHALL imply restoration of each clearing vault cash cell on commit.

#### Scenario: Generic cash correspondence

- **WHEN** a nonempty actual speculative prefix changes a lane vault
- **THEN** the exact cash-plus-obligation equality follows from accepted receipt effect application

#### Scenario: Commit restores clearing cash

- **WHEN** a request commits after full clearance
- **THEN** every configured vault cash cell equals its entry value

#### Scenario: Scalar netting counterexample

- **WHEN** a lane has nonzero offsetting principal obligations
- **THEN** a concrete checked counterexample refutes replacing pointwise clearance by global-sum zero

### Requirement: Public financial preservation

The implementation SHALL prove exact entry-world/store identity and zero committed supply/outputs for every admission refusal or abort. On commit it SHALL prove per-domain/asset accounting from actual committed receipts, authority at actual speculative pre-worlds and local boundaries, fixed capability store, proof-carrying nonnegativity, actual/analyzed write locality and supported-predicate frames, with trust and initialization premises explicit.

#### Scenario: Generic rollback

- **WHEN** any public noncommit result is produced
- **THEN** the whole ledger/store equal the entry world and committed supply/history are empty

#### Scenario: Committed accounting and authority

- **WHEN** an event commits with nonzero authorized supply
- **THEN** accounting uses its actual receipts and authority is established at each real pre-world

#### Scenario: Protected collateral and support necessity

- **WHEN** a predicate depends only on untouched collateral or incorrectly claims empty support for a changed cell
- **THEN** the supported predicate is framed and a concrete counterexample exposes the unsupported claim

### Requirement: Conditional correspondence and invariant lifting

Every commit SHALL agree with actual successful interleaving under the supplied schedule. The converse SHALL require actual underlying success, per-step policy acceptance and complete final clearance. An initialized public invariant rule SHALL derive commit preservation from independently quantified actual-prefix obligations and abort preservation from rollback, without circular whole-result assumptions.

#### Scenario: Successful correspondence

- **WHEN** a request commits or an actual successful interleaving passes every policy/clearance check
- **THEN** the two actual committed financial observations agree in the stated direction

#### Scenario: Settlement premise is necessary

- **WHEN** underlying interleaving succeeds while a lane obligation remains nonzero
- **THEN** a concrete example aborts atomically and refutes dropping final clearance

#### Scenario: Initialized macro invariant

- **WHEN** initial invariants and the explicit local/peer-stability premises hold
- **THEN** public commit and abort both preserve the invariant, without requiring zero obligations at every internal step
