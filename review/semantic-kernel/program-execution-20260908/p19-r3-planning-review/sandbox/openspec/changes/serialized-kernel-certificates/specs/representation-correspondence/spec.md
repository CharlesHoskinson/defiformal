## Purpose

Defines faithful correspondence between the serialized certificate representation and delivered Typed and sequential Composition entrypoints for both accepted and refused behavior.

## ADDED Requirements

### Requirement: RC01 Encode and decode roundtrip

For every supported module in this increment, decode of the canonical encoding SHALL recover the Lean IR, and encode of that IR SHALL equal the canonical bytes. Decode refusal SHALL NOT construct a kernel object.

#### Scenario: S39 Supported module roundtrips

- **WHEN** the F25 transfer-three module is canonically encoded then decoded
- **THEN** the recovered enumerations, templates, catalog, store, request and state equal the independent Lean literals.

#### Scenario: S40 Refused decode yields no kernel object

- **WHEN** decode fails on malformed JSON
- **THEN** no `Registry`, `Catalog` or `Request` value is returned and no `execute` call occurs.

### Requirement: RC02 Accepted-path correspondence

When Report.status is accepted, the observation SHALL equal the actual `Typed.execute` or `Composition.executeStep`/`run` success value: post-state balances, capability store, extracted receipt fields, snapshots and event prefix. The checker SHALL call those entrypoints rather than reimplementing them. Kernel success alone SHALL NOT imply Report.accepted; see RC07.

#### Scenario: S41 Checker success equals Typed.execute

- **WHEN** F25's transfer-three request is accepted
- **THEN** checker post-balances and store equal `Typed.execute` on the same registry, store, context, environment, now, request and state.

#### Scenario: S42 Sequential events equal Composition.run

- **WHEN** F27's sequential invoke step is accepted
- **THEN** checker events, outputs, nextIndex and world equal `Composition.run` on the same config, boundaries, world and steps.

### Requirement: RC03 Refused-path correspondence

A refused observation SHALL equal the actual entrypoint error constructor and SHALL NOT be a generic failed bit. Prefix preservation for sequential refusal SHALL match `Sequence.advance` (no new event, inert continuation).

#### Scenario: S43 Checker refusal equals execute error

- **WHEN** F24 overdrafts alice USD
- **THEN** checker and `Typed.execute` both report `insufficientFunds`.

#### Scenario: S44 Configuration refusal equals executeStep

- **WHEN** F08's duplicate-component catalog is submitted as a step
- **THEN** checker and `executeStep` both report `Failure.configuration`.

### Requirement: RC04 Independent expected observations

Fixture expected fields SHALL be independent literals. Tests SHALL NOT generate expected results by calling the candidate checker or the compared Lean runner. A claimed `next_state` or claimed judgment that disagrees with recomputation SHALL fail.

#### Scenario: S45 Fixture expected fields are independent literals

- **WHEN** F25 is checked
- **THEN** expected alice USD 7, bob USD 3, vault USD 20, alice collateral 10, alice debt 2, pool USD 100 and alice share 4 are stored as fixture literals covering all 32 cells, not copied from checker output.

#### Scenario: S46 Claimed next state disagreement fails

- **WHEN** a certificate claims alice USD 10 after transfer 3
- **THEN** the checker reports changed-judgment / observation mismatch against recomputed 7.

### Requirement: RC05 Source pin and delivery identity

A complete increment certificate SHALL bind Git commit `a12b7cac05a818cc8d35c2ca440b7170a2807e92` for used Typed/Composition sources and the three Lean/Lake pins. A stale or missing pin SHALL be stale refusal, not a pass.

#### Scenario: S47 Bound source SHA equals delivery D

- **WHEN** a complete certificate is checked in this increment
- **THEN** its `source_pin.git` equals `a12b7cac05a818cc8d35c2ca440b7170a2807e92`.

#### Scenario: S48 Stale source SHA is refused

- **WHEN** a certificate pins any other Git id
- **THEN** the checker reports stale-source and does not accept the module.

### Requirement: RC06 Quantified supported-IR correspondence

Encode/decode roundtrip and accepted/refused entrypoint correspondence SHALL be stated for every supported canonical DecodedIR, with extensional finite-world equality, as in `correspondence-theorems.json`. Finite fixture equality SHALL remain independent evidence and SHALL NOT discharge this universal requirement. If a correspondence is only computationally checked, it SHALL be labelled bounded.

#### Scenario: S78 Roundtrip is quantified over supported IR

- **WHEN** Correspondence.encode_decode_roundtrip is proved or explicitly labelled bounded
- **THEN** the statement quantifies over supported canonical DecodedIR, not only F25.

#### Scenario: S79 Refused execute correspondence preserves pre-world

- **WHEN** Typed.execute returns an error constructor
- **THEN** the kernel projection failure path equals that constructor and world equals the pre-state.

### Requirement: RC07 Kernel correspondence is separate from report policy

Quantified kernel/decoded-execution correspondence SHALL be stated for Typed success, Typed error, step success, step error and run-cursor projections without assuming Report.status. Report.accepted SHALL require kernel success plus source-identity, six-class presence and optional claimed-world agreement, in that precedence. F25 and F36 MAY share an identical kernel payload; F36's false claimed_next_state SHALL refuse observationMismatch.claimedNextState and retain the recomputed post-world. Proofs remain P20; finite fixtures SHALL NOT discharge them.

#### Scenario: S82 Kernel success is not Report.accepted

- **WHEN** F25's transfer-three request has Typed.execute = ok post
- **THEN** the kernel projection world equals post, and Report.accepted holds only because source identity, six assumption classes and null claimed_next_state also hold.

#### Scenario: S83 Identical kernel payload with false claimed state refuses observationMismatch

- **WHEN** F36 uses the same registry/store/ctx/env/now/request/state as F25 and claims the pre-world as next state
- **THEN** the checker reports observationMismatch.claimedNextState, retains alice USD 7 / bob USD 3, and does not accept the module.

#### Scenario: S84 Policy premises have defined precedence

- **WHEN** F37 pins a stale git id, or F41 omits environment-authenticity after a successful execute
- **THEN** F37 is staleSource with pre-world and no kernel invoke, and F41 is incompleteObligation retaining the recomputed post-world.

#### Scenario: S85 Step projections are not report-only fields

- **WHEN** a composition-step succeeds or fails
- **THEN** world, receipt and outputs equal executeStep, while status, judgments, assumptions, outstanding, source_pin, audit_roots and unsupported remain report-only policy fields.

#### Scenario: S86 Run cursor is distinct from report policy

- **WHEN** F48 or F49 is checked
- **THEN** world, events, outputs, nextIndex and cursorFailure equal Composition.run, and Report.status is not a cursor field. Quantified proof remains P20.
