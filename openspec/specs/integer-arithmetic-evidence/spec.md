# integer-arithmetic-evidence Specification

## Purpose

Defines proof, runtime, mutation, compiler and source-bound evidence requirements for checked arithmetic.

## Requirements

### Requirement: IE01 Freeze a complete executable evidence contract

Before implementation the candidate SHALL bind all runtime fixtures, literal mutants, runner controls, dependency inputs and proof/audit roots and pass both required planning reviews.

#### Scenario: E01 only author OpenSpec validation has passed

- **WHEN** only author OpenSpec validation has passed
- **THEN** implementation and scientific acceptance remain pending.

#### Scenario: E02 a helper or audit root is absent from the package manifest

- **WHEN** a helper or audit root is absent from the package manifest
- **THEN** official freeze or evidence acceptance is blocked rather than inferred from directory names.

### Requirement: IE02 Require actual mutation sensitivity

Every semantic mutant SHALL compile, change production behavior, fail its designated independent observation and preserve global and separate sibling positives.

#### Scenario: E03 a source edit compiles but all observations still pass

- **WHEN** a source edit compiles but all observations still pass
- **THEN** the mutation is not counted as detected.

#### Scenario: E04 a mutant cannot compile or its positive controls fail

- **WHEN** a mutant cannot compile or its positive controls fail
- **THEN** the attempt is classified separately and cannot certify mutation sensitivity.

### Requirement: IE03 Audit proof closure and nonempty observations

Acceptance SHALL dynamically audit imported theorem/supplemental declarations and bind nonempty actual runtime, compiler and runner results to exact source/tool identities.

#### Scenario: E05 a forbidden axiom, unbound source, forged summary or zero-check report is supplied

- **WHEN** a forbidden axiom, unbound source, forged summary or zero-check report is supplied
- **THEN** acceptance fails or blocks at the appropriate declared evidence boundary.

#### Scenario: E06 a bounded independent arithmetic oracle agrees

- **WHEN** a bounded independent arithmetic oracle agrees
- **THEN** its precise finite domain and interpreter are retained and no chain-fidelity claim follows.

### Requirement: IE04 Deliver only the independently reviewed scope

Final native Grok/Fable reviews, scenario reconciliation and branch delivery SHALL precede scoped completion, while later signed/protocol/runtime work remains explicit.

#### Scenario: E07 a native reviewer is unavailable or returns no substantive verdict

- **WHEN** a native reviewer is unavailable or returns no substantive verdict
- **THEN** the review remains open and the response is preserved.

#### Scenario: E08 unsigned arithmetic and reference results pass

- **WHEN** unsigned arithmetic and reference results pass
- **THEN** only their scope is archived; signed funding, protocol libraries and deployed adapters remain separate obligations.

