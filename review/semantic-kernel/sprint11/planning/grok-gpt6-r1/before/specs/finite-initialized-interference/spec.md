## Purpose

Specify finite initialized interference for actual finite shared-state execution with explicit assumptions and reproducible evidence.

## ADDED Requirements

### Requirement: Initialized simultaneous finite preservation

A generic theorem SHALL establish all participant invariants at every actual prefix from all entry invariants, selected actual-success local preservation/guarantees, cross-participant inclusion and peer stability; refusal and skip cases SHALL use unchanged state.

#### Scenario: Three independently discharged obligations
- **WHEN** three funded streams satisfy initialization, local guarantees and pairwise cross-inclusion/stability
- **THEN** all three invariants hold at every prefix for arbitrary schedules under those hypotheses

#### Scenario: No initialization
- **WHEN** identity actions start with reserve3 against required reserve4
- **THEN** execution stays at3 and no initialized preservation conclusion is attributed to the otherwise vacuous step obligations

#### Scenario: False circular promises
- **WHEN** two assumptions and their promised conclusions are all false
- **THEN** their circular implications alone are true but do not establish either invariant at entry or any reserve guarantee

### Requirement: Actual local obligations and supported financial instances

Financial instances SHALL use actual successful invocation equations and the accepted M2 TypedTotalContract/Agrees predicates and actual local support, neutrality or paired-effect premises quoted in accepted-api.json; they SHALL retain the entire fixed global binding set and SHALL not infer preservation from authorization alone.

#### Scenario: Finite global equality and total instance
- **WHEN** three streams preserve an initialized shared declared total and every fixed global edge under accepted M2 premises
- **THEN** the finite executor preserves those predicates at every actual prefix

#### Scenario: Global edge omitted by local view
- **WHEN** a funded step leaves a local or empty edge subset satisfied but violates an initialized edge in the global set
- **THEN** the full global binding query fails with the independently expected values

#### Scenario: Authorized unsafe withdrawal
- **WHEN** transfer7 from vault10 has valid authority and ordinary sufficient-balance guards
- **THEN** it succeeds and leaves3, showing reserve preservation needs its extra local premise

### Requirement: No hidden progress or commutation premise

The generic finite rule SHALL be conditional on actual accepted steps and SHALL neither assert enabledness from soundness nor assume shared-write commutation or every peer postcondition as a local premise.

#### Scenario: Refusal is a real outcome
- **WHEN** a guarded producer refuses with a valid catalog and authority
- **THEN** the theorem handles world identity and does not claim a successful output or monitor fact

#### Scenario: Unsafe peer relation
- **WHEN** an authorized peer withdrawal7 changes vault10 to3
- **THEN** the reserve-stability premise fails and the unsafe peer is not covered by the funded deposit-only theorem
