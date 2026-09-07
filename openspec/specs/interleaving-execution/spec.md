# interleaving-execution Specification

## Purpose
Define replayable shared-state execution with exact local histories, refusal outcomes and explicit schedule validity.

## Requirements

### Requirement: Complete finite schedules

The evaluator SHALL accept finite binary invocation-only branches and a schedule with exactly one token per static invocation slot of each branch. Tokens SHALL select branch-local slots in order. Invalid counts SHALL produce a typed preflight refusal with expected and observed counts for both branches.

#### Scenario: Balanced schedule

- **WHEN** both branches contain two invocations and the schedule is left,right,left,right
- **THEN** preflight accepts the schedule and each branch consumes its two slots in local order

#### Scenario: Missing and excess slots

- **WHEN** a schedule omits a right slot or adds a left slot, including extra tokens for an empty branch
- **THEN** preflight refuses with exact expected/observed counts before any execution

#### Scenario: Empty schedules

- **WHEN** both branches and the schedule are empty
- **THEN** execution returns the initial world, empty attempts and empty branch observations

### Requirement: Structural admission permits shared state

The evaluator SHALL check configuration, the complete left branch, the complete right branch, then schedule counts in that order. It SHALL preserve exact structural failure location and reason, including in unreachable suffixes. Overlapping footprints SHALL NOT itself refuse execution. Every admission refusal SHALL preserve the initial world and emit no attempts or outputs.

#### Scenario: Overlapping funded branches

- **WHEN** two structurally valid funded and authorized branches write the same cell
- **THEN** preflight admits them without requiring disjointness or proof of an invariant

#### Scenario: Unreachable malformed suffix

- **WHEN** an early invocation would financially refuse but its branch has an unknown operation later
- **THEN** the whole-branch structural check refuses at the later local index without executing the prefix

#### Scenario: Preflight precedence

- **WHEN** configuration, structural and schedule errors coexist
- **THEN** the first error in configuration-left-right-schedule order is returned

### Requirement: One evolving shared world

Each active scheduled invocation SHALL execute against the current shared world through the existing trusted single-step semantics. Successful attempts SHALL update that world and emit their actual complete receipts and post-state snapshots. Boundaries SHALL depend only on branch identity and local invocation index. The capability store SHALL remain equal to the initial store.

#### Scenario: Competing liquidity

- **WHEN** left withdraws7 and right withdraws6 from shared USD10 under LR and RL schedules
- **THEN** LR leaves source3/Alice7/Bob0 with right insufficient-funds; RL leaves source4/Alice0/Bob6 with left insufficient-funds, preserving all other cells and the full capability store

#### Scenario: Replenishment order

- **WHEN** one branch funds liquidity before or after a peer withdrawal
- **THEN** the withdrawal observes the balance at its actual attempt and a refused withdrawal is not retried after replenishment

#### Scenario: Local boundary identity

- **WHEN** a multi-step branch is shifted in global schedule position while local trusted inputs are fixed
- **THEN** each attempted step uses its original branch-local principal, environment and time

#### Scenario: Revoked authority

- **WHEN** the initial store differs only in a required grant being live versus revoked
- **THEN** the live funded invocation succeeds and the revoked one refuses for its exact authority reason

### Requirement: Branch-local refusal and history

The first runtime refusal SHALL halt only its own branch, retaining every earlier successful effect, receipt and output. Later tokens of that branch SHALL skip without another attempt. Peer execution SHALL continue. Input resolution SHALL use only the selected branch history with qualified keys and typed units; old snapshots SHALL remain fixed.

#### Scenario: Retained prefix and peer continuation

- **WHEN** a branch succeeds then refuses while its peer has remaining valid invocations
- **THEN** the prefix and peer effects remain, the first exact failure remains stable, and the failed suffix contributes no attempts

#### Scenario: Dual refusal

- **WHEN** both branches refuse at their own local indices
- **THEN** both exact failures remain visible and neither is replaced by the peer failure

#### Scenario: Different snapshots at the same key

- **WHEN** interleaved producers capture different balances at the same fully qualified output key in separate branches
- **THEN** each later local consumer resolves its own value and the stored snapshots do not change after peer writes

#### Scenario: Peer-only history

- **WHEN** only the peer has produced a requested output while an own-history or literal sibling supplies the correct unit and funding
- **THEN** the peer-only reference refuses for the intended missing-history reason and the sibling succeeds

### Requirement: Complete observations and prefix execution

Results SHALL expose the supplied schedule, one final world, consumed slot counts, ordered real success/refusal attempts and both branch observations. Internal finite-prefix execution SHALL be total, explicitly distinguishing skipped and attempted slots. Canonical comparison SHALL retain complete final balances/store, branch labels, ordered requests/receipts/typed outputs, successful indices and exact failures; only global order, consumed skipped slots and raw foreign event worlds SHALL be omitted by the named disjoint projection.

#### Scenario: Attempt continuity

- **WHEN** successes and refusals alternate across branches
- **THEN** every attempt begins at the previous attempt post-world or unchanged refused world and successful branch events are its branch projection

#### Scenario: Observation sensitivity

- **WHEN** two results differ only in one exact refusal, index, request, receipt, output, branch label, final balance or capability entry
- **THEN** canonical comparison distinguishes the changed field; an identical pair remains equal

#### Scenario: Skipped tokens

- **WHEN** a schedule prefix selects an already failed branch or exceeds its static length
- **THEN** internal execution changes only its consumed slot count, emits no attempt, and cannot make an invalid complete schedule publicly admitted
