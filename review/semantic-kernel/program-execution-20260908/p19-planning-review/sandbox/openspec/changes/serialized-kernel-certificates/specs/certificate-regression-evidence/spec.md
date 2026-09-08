## Purpose

Defines independent fixtures, planned mutations, malformed and stale controls, declared audit-root evidence and the mutation-runner protocol for this certificate increment.

## ADDED Requirements

### Requirement: EV01 Independent fixtures and discriminating controls

Every fixture SHALL have independent literal expected fields, a nonempty scenario list and a status of planned-not-executed until implementation. The inventory SHALL include malformed, empty, missing, unsupported, stale and changed-judgment controls plus funded success and exact-constructor refusal siblings. Count-only summaries SHALL NOT substitute for constructor identity.

#### Scenario: S61 Every fixture has literal expected fields

- **WHEN** `fixtures.json` is validated
- **THEN** each fixture has nonempty `id`, `expected` object with constructor or decode-failure identity, and does not store checker-generated oracles.

#### Scenario: S62 Discriminating negative controls exist

- **WHEN** empty, missing-field, unreduced-rational, unsupported-step, stale-SHA and claimed-next-state fixtures are listed
- **THEN** each has a distinct expected failure distinct from an intact sibling's expected success.

### Requirement: EV02 Planned mutations with designated false and protected positives

Each mutant SHALL name the semantic change, a planned source needle or `future_anchor` status, one designated false observation, and at least one unaffected positive. Production execution SHALL use one-mutant SPECs. Future composition-operator coverage remains a named later obligation, not silent closure. Existing arithmetic and Atomic cases SHALL NOT be new certificate mutants.

#### Scenario: S63 Each mutant has change anchor false and protected positive

- **WHEN** `planned-mutations.json` is validated
- **THEN** every mutant has unique id, `actual_source_change` or `future_anchor`, `oracle_fixture`, `required_false` and `expected_protected_check`, with those two check names distinct.

#### Scenario: S64 One-mutant SPEC protocol is required

- **WHEN** production mutations run
- **THEN** each invocation has exactly one mutation and `positive_checks` equal to that mutant's protected check; a unioned multi-mutant SPEC is forbidden.

#### Scenario: S65 Arithmetic and Atomic cases are not certificate acceptance

- **WHEN** mutation and fixture inventories are inspected
- **THEN** no mutant claims Arithmetic word/fee theorems or Atomic settlement as newly accepted certificate coverage.

### Requirement: EV03 Runner protocol mapping and blocked evidence

The certificate mutation driver SHALL reuse the inherited Interface SPEC fields `schema_version`, `modules`, `mutations` and `positive_checks` with literal field-set equality. Timeout, empty output, missing module, parse error and compiler error SHALL be blocked evidence (exit 3), never semantic detection. Output SHALL live outside the repository.

#### Scenario: S66 Inherited SPEC field set is reused

- **WHEN** a production mutant SPEC is written
- **THEN** its JSON keys are exactly `schema_version`, `modules`, `mutations`, `positive_checks` with `schema_version` 1.

#### Scenario: S67 Timeout or empty output is blocked

- **WHEN** a mutant Lean command times out or prints zero checks
- **THEN** the record is blocked, not a detected false observation, and an outer invocation record is required.

### Requirement: EV04 Isolated checker CLI negative controls

Author planning controls SHALL invoke the actual `--check` CLI on isolated intact, empty, missing, changed-bytes and spec-drift copies, record argv/cwd/UTC/duration/stdout/stderr/exits/tool hashes, and fail the suite if a control does not discriminate. Historical r1 synthetic `if not []` records SHALL be preserved and SHALL NOT be relabelled as CLI executions.

#### Scenario: S80 Empty fixture inventory blocks through --check

- **WHEN** an isolated plan copy has `fixtures.json` fixtures array empty
- **THEN** `package.py --check` exits 3 with an empty-selection message and the intact sibling still exits 0.

### Requirement: EV05 Runtime proof projection for existing mutation targets

Existing Typed/Composition mutants SHALL run under the planned projection that strips `-- BEGIN PROOFS` on Typed, Composition and Certificates prefixes in the local import closure, without discarding runtime declarations. Intact projected siblings SHALL still match independent protected observations.

#### Scenario: S81 Projection lists nine existing consumers

- **WHEN** `mutation-projection.json` is inspected
- **THEN** M03/M04/M08/M12 name Transition consumers including Execution/Sequence, and M06 names F47 as designated false with F27 protected.

#### Scenario: S68 Forbidden-read companion refuses readAccess

- **WHEN** F47 invokes vault-guarded transfer on component 0
- **THEN** expected failure is interface.readAccess while F27 transfer 3 remains accepted.

#### Scenario: S69 Producer then prior-output consumer

- **WHEN** F48 runs transfer 3 then transfer of the snapshot amount 7
- **THEN** independent expected world is alice USD 0, bob USD 10, nextIndex 2, two events.

#### Scenario: S70 Successful prefix then refusal is inert

- **WHEN** F49 runs transfer 3, transfer 11, transfer 1
- **THEN** world remains alice 7 bob 3, events length 1, cursorFailure index 1 insufficientFunds, and the third step is absent.

#### Scenario: S71 Admin issue preserves old entries

- **WHEN** F50 issues a bob invoke grant on the 12-entry store under vault admin
- **THEN** issued id is 12, store length 13, and the original 12 entries are unchanged.

#### Scenario: S72 Admin revoke tombstones id 0

- **WHEN** F51 revokes id 0 under vault admin
- **THEN** entry 0 live is false, nextId remains 12, and other entries are unchanged.

#### Scenario: S73 Two present refusal constructors differ

- **WHEN** F52 compares insufficientFunds and unauthorizedDebit reports
- **THEN** reportEq is false and both failures are present Some constructors.

#### Scenario: S74 Unsupported tag with valid invoke rest is malformed

- **WHEN** F53 has tag treeJoin and otherwise F27 invoke fields
- **THEN** codec reports unsupportedForm.treeJoin.

#### Scenario: S75 Fresh id observation is 12 not 0

- **WHEN** F50/F54 issue from store12
- **THEN** receipt id is 12, not 0.
