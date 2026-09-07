# sequential-workflow-execution Specification

## Purpose
Specify observable ordered execution with explicit state, capability changes,
output histories, and preservation of the successful prefix on refusal.

## Requirements

### Requirement: Validated initialization and trusted execution inputs
The system SHALL validate structural configuration before execution and receive
authenticated context, observations, and time separately from workflow requests.
Boundary inputs SHALL be indexed by absolute step position. Malformed
configuration SHALL return the unchanged initial world with no executed events.

#### Scenario: Invalid initial configuration
- **WHEN** a workflow is submitted with invalid component ownership or bindings in its configuration
- **THEN** execution returns a configuration refusal and no step runs

#### Scenario: Caller cannot replace authority context
- **WHEN** a request claims an actor different from the adapter's authenticated principal
- **THEN** the existing actor-consistency refusal is preserved for an otherwise well-formed invocation

### Requirement: Current-world propagation
The system SHALL execute each step against the immediately preceding ledger and
capability store. Invocation success SHALL preserve the store, administrative
success SHALL preserve the ledger, and every refusal SHALL preserve its input world.

#### Scenario: Consecutive funded transfers
- **WHEN** Alice starts with 10 USD and two authorized transfers of 3 USD to Bob execute
- **THEN** Alice ends with 4 USD and Bob gains 6 USD

#### Scenario: Issue use revoke use
- **WHEN** a capability is validly issued, used successfully, revoked, and then requested again
- **THEN** the first use remains committed and the second use refuses under the updated store

### Requirement: Ordered first-refusal execution
The system SHALL execute in submitted order, stop at the first refusal, retain all
earlier successful changes, and execute no suffix. Empty execution SHALL be identity.

#### Scenario: Empty workflow
- **WHEN** an empty workflow runs from a valid configuration
- **THEN** it succeeds with the unchanged world and empty event and output histories

#### Scenario: First step refusal
- **WHEN** the first step refuses
- **THEN** the initial world is returned with failure index zero and no successful events or outputs

#### Scenario: Middle refusal preserves prefix
- **WHEN** a successful transfer is followed by an insufficient-funds deposit and a funded later action
- **THEN** only the transfer remains committed and the funded suffix action does not execute

#### Scenario: Ordering changes observations
- **WHEN** transfer-then-deposit and deposit-then-transfer encounter different intermediate balances
- **THEN** each run reports its own ordered successful prefix, resulting world, and first refusal

### Requirement: Observable receipts and refusal provenance
The system SHALL expose successful step identities, actual evaluated ledger effects
and supply changes, administrative store changes, selected post-state outputs,
and final world. A failure SHALL include its absolute position, step identity, and
reason. Failed steps SHALL produce no successful receipt or output.

#### Scenario: Delegated refusal
- **WHEN** an interface-valid and correctly bound step is refused by the financial executor or capability administrator
- **THEN** its original refusal reason is retained with the workflow position

#### Scenario: Snapshot remains historical
- **WHEN** a later step changes a cell previously emitted as an output
- **THEN** the earlier output remains its original post-step snapshot

### Requirement: Continuation preserves history and boundary position
The system SHALL make execution of an appended list agree with continuation from
its prefix, carrying the world, outputs, next absolute index, and terminal status.

#### Scenario: Successful prefix resumed
- **WHEN** a suffix consumes a prefix output and a position-dependent trusted input
- **THEN** resumed execution equals one-pass execution in final world, events, outputs, and failure

#### Scenario: Failed prefix resumed
- **WHEN** a suffix is appended to a prefix that has already refused
- **THEN** continuation returns the failed prefix unchanged and executes no additional steps
