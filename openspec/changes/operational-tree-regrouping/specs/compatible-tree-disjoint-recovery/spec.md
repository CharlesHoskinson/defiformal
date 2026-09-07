## Purpose

Establishes schedule independence only for analyzed compatible branches under an explicitly reduced observation.

## ADDED Requirements

### Requirement: R09 Actual pairwise compatibility
The disjoint reference SHALL require actual full-branch analyzed footprints and check roster-ordered pairs with exact existing conflict kind/cell. The development SHALL prove compatible disjoint-subtree footprint unions, including output dependencies and both write/read directions.

#### Scenario: S20 All conflicts material
- **WHEN** valid branches have write/write or either write/read conflict including an output-only dependency
- **THEN** the exact canonical pair/kind/cell is refused

#### Scenario: S21 Shared reads allowed
- **WHEN** two branches read the same cell but neither writes it
- **THEN** compatibility succeeds and no false separation requirement is introduced

### Requirement: R10 Independent isolated tree reference
The reference executor SHALL run each actual branch from the same initial world with its own history, recursively merge unique write owners and retain initial unowned cells/capabilities. It SHALL be independent of the shared/flat dispatcher and prove grouping correspondence.

#### Scenario: S22 Unique owner merge
- **WHEN** disjoint branches affect separate cells while an unowned sentinel starts11
- **THEN** owner results appear once and sentinel remains11, never22

#### Scenario: S23 Refused owner prefix
- **WHEN** one isolated branch succeeds then refuses
- **THEN** its successful prefix and exact local failure survive merge

#### Scenario: S24 Empty subtree unit
- **WHEN** an empty subtree is merged on either side
- **THEN** the reference state/local observation is unchanged

### Requirement: R11 Generic compatible recovery
For actual admission, valid trees, identical genesis world/store, pairwise analyzed compatibility and any complete schedule, the development SHALL prove canonical equality with independently executed isolated branches using actual prefix dependency/refusal simulation; it SHALL cover financial refusals and not assume the desired run equality.

#### Scenario: S25 All successful orders
- **WHEN** the three disjoint two-step branches run in any of90 complete schedules
- **THEN** the generic theorem and independently expected canonical balances/receipts agree

#### Scenario: S26 All refusal orders
- **WHEN** the middle branch requests6 from5 in any complete schedule
- **THEN** the exact retained refusal and peers match the independent isolated reference

### Requirement: R12 Canonical equality and excluded observations
Canonical equality SHALL retain final full world/store, every local consumed and BranchObservation field; it SHALL omit only tree/path shape, complete schedule, raw intermediate worlds and global attempts. Different-schedule equality SHALL require compatibility and SHALL not imply full-trace or monitor equality.

#### Scenario: S27 Projection distinguishes its own fields
- **WHEN** synthetic pairs differ in receipt, failure, consumed or output versus only raw worlds/attempts
- **THEN** canonical comparison rejects the former and accepts the latter exactly

#### Scenario: S28 Unrestricted law is false
- **WHEN** the two competing withdrawals run in opposite complete orders
- **THEN** vault3 versus4 and different refusals refute independence; the compatibility premise is false
