## Purpose

Prove independence and financial preservation for the registered executor, including refused outcomes and explicitly scoped observations of disjoint workflows.

## ADDED Requirements

### Requirement: Closed expression and executor dependency
The system SHALL prove that the existing closed expression language and registered invocation executor depend on ledger state only through the analyzed reads and potential effect targets, under identical trusted config, caller, parties, arguments, environment, time and capability store. The proof SHALL cover exact evaluation and execution refusals as well as success; it SHALL NOT assume commutation or evaluator framing as an unchecked premise.

#### Scenario: Expression failure framing
- **WHEN** two nonnegative states agree on analyzed dependencies and evaluation divides by zero or returns another expression error
- **THEN** the exact error is the same

#### Scenario: Implicit balance dependency
- **WHEN** the executor compares sufficient funds over all cells before its write-footprint check
- **THEN** the proof derives zero effect outside resolved delta targets and justifies refusal invariance without assuming the later write check succeeds

#### Scenario: Foreign state changes
- **WHEN** two input states differ only outside a branch dependency region
- **THEN** success/refusal, receipts and outputs match canonically, while each successful result retains its own outside-region balances

### Requirement: Actual serial-order correspondence
For every admitted branch pair and initial world the system SHALL prove equivalence of the parallel observation to actual left-then-right and right-then-left branch re-execution. Each serial reference SHALL execute its second branch on the first branch final world with a fresh local history and the original branch-local boundaries, even after first-branch refusal.

#### Scenario: State-dependent re-execution
- **WHEN** a branch contains guard or effect expressions dependent on its own balances
- **THEN** both serial references re-evaluate the real executor and produce the parallel canonical observation

#### Scenario: Refused first branch
- **WHEN** the first serial branch refuses after a prefix
- **THEN** the second still executes on that prefix world and the theorem retains both exact outcomes

#### Scenario: Independent single steps commute
- **WHEN** each branch contains one invocation
- **THEN** the correspondence theorem yields equal final ledgers/stores and branch-qualified success/refusal/receipt/output observations in either order

### Requirement: Cumulative financial preservation
The system SHALL prove joined accounting for each domain/asset from the sum of both actual successful receipt supplies, invocation/debit/supply authority at each point of use in the fixed initial store, and nonnegativity of branch prefixes and the joined state. It SHALL distinguish proof-carrying nonnegativity from discovered invariants.

#### Scenario: Supply-changing peers
- **WHEN** independent branches mint or burn within authorized disjoint cells
- **THEN** the joined total equals initial total plus both explicit receipt supply sums

#### Scenario: Successful use with refused suffix
- **WHEN** a branch successfully uses authority before a later refusal
- **THEN** the accepted invocation retains its point-of-use authority evidence and accounting contribution

### Requirement: Supported ledger frames and initialized invariants
The system SHALL prove unchanged balances outside the union of branch write regions and frame ledger predicates with explicit support disjoint from that union. It SHALL prove composition of initialized branch ledger invariants from individual preservation obligations and peer-disjoint supports, retaining all local contract and trusted-environment assumptions.

#### Scenario: Protected collateral predicate
- **WHEN** an initialized predicate depends only on untouched collateral cells
- **THEN** it is preserved at the join with its support/disjointness premises discharged for a concrete reference

#### Scenario: Necessary frame premises
- **WHEN** support is omitted or the protected region intersects a branch write
- **THEN** concrete counterexamples show why unconditional framing is false

#### Scenario: Two local invariants
- **WHEN** two initialized supported predicates have individual preservation evidence and the peer cannot write either predicate support
- **THEN** the joined state satisfies both without circular assume-guarantee premises
