# parallel-workflow-execution Specification

## Purpose
Execute independent branch workflows with their own histories and refusal results, and join their permitted ledger changes without losing either branch.

## Requirements

### Requirement: Independent prefix execution
For an admitted pair the system SHALL execute each branch using the existing sequential invocation semantics from the common initial world. Each branch SHALL stop at its first refusal and retain its successful prefix; refusal in one branch SHALL NOT cancel execution of its peer.

#### Scenario: One branch refuses immediately
- **WHEN** left refuses before any accepted invocation and right contains funded authorized work
- **THEN** right completes and its changes appear in the join

#### Scenario: Middle and dual refusal
- **WHEN** one or both branches refuse after successful invocations
- **THEN** each successful prefix is retained with its own exact reason and local refusal index

#### Scenario: Empty branch identity
- **WHEN** one or both branches are empty
- **THEN** the nonempty branch retains its sequential result; two empty branches preserve the complete initial world

### Requirement: Exact region merge
The system SHALL select each branch final balance only inside its admitted write region and preserve the initial balance elsewhere. The joined capability store SHALL equal the initial store. Actual successful effects SHALL be proved confined to the corresponding admitted region.

#### Scenario: Two funded disjoint branches
- **WHEN** left transfers 3 USD from Alice starting at 10 to Bob starting at 0, and right transfers 4 shares from vault starting at 20 to Alice starting at 0
- **THEN** the join has Alice USD7, Bob USD3, vault shares16, Alice shares4, unchanged other cells, and unchanged capability store

#### Scenario: Common initial balance
- **WHEN** an untouched cell has a nonzero initial balance
- **THEN** its joined balance equals that initial balance once, without duplication

#### Scenario: Refused branch prefix
- **WHEN** a branch writes a cell successfully before a later invocation refuses
- **THEN** merge retains that final prefix balance rather than reverting the branch to initial state

### Requirement: Qualified outputs and receipts
The system SHALL retain exact successful invocation receipt data and immutable typed snapshots, keyed externally by branch identity, local position and qualified port. Each branch SHALL resolve only its own earlier successful outputs, preserving its local ordering and refusal semantics.

#### Scenario: Qualified output identities
- **WHEN** branches emit the same local step and numeric port ID from distinct components selecting different cells, or emit the same fully qualified local key for a common read-only cell
- **THEN** the first case preserves distinct component-qualified values and the second preserves equal snapshots as two branch-labeled observations; neither case conflates the branch histories

#### Scenario: Snapshot after later writes
- **WHEN** a branch writes a previously selected cell again
- **THEN** the earlier snapshot value remains unchanged

#### Scenario: Unavailable or foreign output
- **WHEN** an invocation attempts to consume an earlier key present only in its peer history, or another output not available in its own earlier successful history
- **THEN** that branch refuses without consuming its peer history or altering its prefix

### Requirement: Financially complete canonical observations
The system SHALL expose a canonical observation containing the full joined ledger and capability store plus both branch outcomes, accepted local positions and operation/request identity, actual evaluated receipt data, typed outputs, final local indices, and exact refusal reasons/indices. Equivalence SHALL ignore only global completion order and raw event full-world context; raw isolated branch cursors SHALL remain available as separate evidence.

#### Scenario: Swapped completion order
- **WHEN** an admitted pair is evaluated right first instead of left first
- **THEN** canonical observations retain fixed left/right labels and every required financial field

#### Scenario: Distinct refusal evidence
- **WHEN** two candidate results differ only in refusal reason, local index, output value, supply receipt or final ledger cell
- **THEN** they are not equivalent

#### Scenario: Raw trace context
- **WHEN** a serial second branch sees first-branch changes in cells it cannot depend on
- **THEN** canonical equivalence may hold while raw full pre-worlds differ, and the result does not claim a single shared raw trace
