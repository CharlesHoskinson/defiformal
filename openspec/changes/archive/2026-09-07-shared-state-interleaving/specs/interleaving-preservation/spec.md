## Purpose

Establish actual-trace preservation and initialized interference rules for every finite shared-state schedule prefix.

## ADDED Requirements

### Requirement: Actual trace soundness

Every evaluated prefix SHALL have an inductive witness connecting its actual initial and final machines. Each success SHALL carry real single-step execution and soundness witnesses; each refusal SHALL carry its real exact failed execution. Local order, history isolation, refusal stability and immutable capabilities SHALL be proved from the runner.

#### Scenario: Prefix soundness

- **WHEN** any finite token prefix executes, including first or middle refusals
- **THEN** the proof connects actual worlds, attempts and local histories without assuming the target runner result

#### Scenario: Complete slot consumption

- **WHEN** an admitted full schedule executes despite failed suffixes
- **THEN** both consumed counts equal their static branch lengths and each branch has exhausted its invocations or retains its first refusal

### Requirement: Accounting authority and nonnegativity

For every finite prefix, total final balance in each domain/asset SHALL equal initial total plus actual successful receipt supplies. Each success SHALL be authorized at its actual pre-world and trusted branch-local boundary under the fixed initial capability store. All reached balances SHALL be nonnegative with the proof-carrying state premise stated.

#### Scenario: Supply and refusal

- **WHEN** both branches emit nonzero supply changes and one later refuses
- **THEN** the equation includes each actual successful supply exactly once and contributes zero for refusals/skips

#### Scenario: Authority at execution

- **WHEN** a funded unauthorized attempt is interleaved with an authorized peer
- **THEN** the unauthorized attempt refuses and every accepted receipt has point-of-use authority evidence

#### Scenario: Reached worlds

- **WHEN** any schedule prefix reaches a success or refusal
- **THEN** initial, intermediate and final nonnegativity are established through the state witnesses

### Requirement: Locality and supported frames

Execution SHALL preserve cells outside actual successful write footprints and outside the union of admitted analyzed branch writes. A ledger predicate SHALL be framed only with explicit support on a protected region disjoint from the relevant writes. Refused and skipped attempts SHALL preserve the whole ledger.

#### Scenario: Protected collateral

- **WHEN** overlapping USD transfers leave a separately supported collateral region untouched
- **THEN** the concrete collateral predicate and every protected balance remain unchanged

#### Scenario: Missing support counterexample

- **WHEN** a purported protected predicate depends on a cell that a valid branch changes
- **THEN** a concrete counterexample shows that the predicate cannot be framed from the stated smaller region

### Requirement: Initialized interference composition

The system SHALL prove both branch invariants at every prefix from initialization, independently proved own-step invariant/guarantee obligations, each guarantee included in the peer rely relation, and stability of each invariant under its rely relation. Own-step obligations SHALL quantify over all own-invariant worlds, histories and applicable branch positions with the fixed local boundaries. They SHALL NOT assume the peer invariant, the final result, or the desired whole-run preservation theorem.

#### Scenario: Overlapping invariant instance

- **WHEN** two competing shared-source transfer branches start at total USD10 and each guarantees unchanged USD total
- **THEN** explicit equality-of-total rely relations, local guarantees and initialization instantiate preservation of total USD10 under every schedule prefix, even when one branch refuses

#### Scenario: Initialization is necessary

- **WHEN** a preserved total predicate is false in the initial ledger
- **THEN** a concrete counterexample prevents concluding that it becomes true merely from step preservation

#### Scenario: Peer stability is necessary

- **WHEN** a locally preserved predicate is changed by an otherwise valid peer invocation
- **THEN** a concrete counterexample shows why own preservation alone cannot discharge the interference theorem
