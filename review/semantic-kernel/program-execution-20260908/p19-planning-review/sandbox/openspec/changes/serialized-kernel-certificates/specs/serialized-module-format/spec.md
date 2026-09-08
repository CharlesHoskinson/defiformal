## Purpose

Defines the bounded JSON Module/Transition envelope, exact rationals, identifiers, enumerations, catalogs and sequential steps that this certificate increment serializes.

## ADDED Requirements

### Requirement: SF01 Canonical exact rationals

Every numeric amount, price, scalar, delta, supply, balance and timestamp-as-scalar SHALL be encoded as a JSON object `{"num": integer, "den": positive-integer}` in lowest terms with positive denominator and sign only on `num`. Floats, scientific notation, strings, unreduced pairs, zero or negative denominators, NaN and infinities SHALL be decode refusals.

#### Scenario: S01 Unreduced two-over-four is refused

- **WHEN** a certificate encodes amount `{"num": 2, "den": 4}`
- **THEN** decode refuses with exact noncanonical-rational failure and does not invoke kernel execution.

#### Scenario: S02 Canonical one-over-two is accepted for decode

- **WHEN** a certificate encodes amount `{"num": 1, "den": 2}`
- **THEN** decode yields Lean rational `1/2` and kernel evaluation may proceed.

#### Scenario: S03 Zero denominator is refused

- **WHEN** a certificate encodes amount `{"num": 1, "den": 0}`
- **THEN** decode refuses with exact zero-denominator failure before any kernel call.

#### Scenario: S04 JSON float amount is refused

- **WHEN** a certificate encodes amount `0.5` or `"1/2"`
- **THEN** decode refuses with exact wrong-json-type failure.

### Requirement: SF02 Identifiers and finite enumerations

Party, asset and domain names SHALL be members of the module's declared finite enumerations. `OperationId`, `CapabilityId`, `ObservationId`, `ComponentId` and `PortId` SHALL be JSON integers equal to the corresponding Lean `Nat` `.value`, rejecting negatives, floats and strings. Capability store IDs SHALL be list indices; a grant SHALL NOT choose its ID.

#### Scenario: S05 Unknown party name is refused

- **WHEN** a request names party `"carol"` and the module enumerates only `alice|bob|vault|pool`
- **THEN** decode refuses unknown-identifier and does not invent a party.

#### Scenario: S06 Negative operation id is refused

- **WHEN** an operation id is `-1`
- **THEN** decode refuses identifier-domain failure.

#### Scenario: S07 Issued capability id is the pre-store length

- **WHEN** a live store has `n` entries and issue succeeds
- **THEN** the issued id value equals `n` and the new entry is appended, never overwritten.

### Requirement: SF03 Duplicates and significant order

Catalog component ids, catalog-wide operation ids, private cells, export cells and per-component port ids SHALL be duplicate-free as `validateCatalog` requires. Repeated cell or supply deltas SHALL add. Request capability-id list order is existential; duplicates SHALL confer no extra rights. History and step lists are order-significant.

#### Scenario: S08 Duplicate component ids fail catalog

- **WHEN** two catalog components share `id.value = 0`
- **THEN** `validateCatalog` is false and sequential execution reports `configuration`.

#### Scenario: S09 Repeated deltas add

- **WHEN** two identical debit-3 entries target the same cell
- **THEN** net effect is `-6`, not a set-union of `-3`.

#### Scenario: S10 Duplicate request capability ids confer no extra rights

- **WHEN** the same invoke id is listed twice and no debit id is present
- **THEN** invoke may succeed while unauthorized debit still refuses.

### Requirement: SF04 Canonical JSON and schema version

Certificates SHALL use schema version `1`. Canonical hashing SHALL use the frozen key order in `schema.json`. Unknown fields that would be treated as executable SHALL be refused. Schema-version mismatch SHALL be refused before kernel execution.

#### Scenario: S11 Unknown executable field is refused

- **WHEN** a transition object contains `"silentPass": true`
- **THEN** decode refuses unknown-field and does not accept the module.

#### Scenario: S12 Schema version mismatch is refused

- **WHEN** `schema_version` is `0` or `2` or missing
- **THEN** decode refuses schema-version failure.

#### Scenario: S13 Canonical key order is required for identity hashes

- **WHEN** two documents differ only by JSON object key order
- **THEN** their canonical encodings are equal and their raw UTF-8 hashes may differ.

### Requirement: SF05 Full module envelope

A module SHALL serialize the envelope keys in `grammar.json` (`schema_version`, `mode`, `source_pin`, `audit_roots`, `types`, `assumptions`, `invariants`, `libraries`, `source_map`, `payload`). Empty arrays are allowed for later families. Omitting a required envelope field or supplying an empty document SHALL be refused.

#### Scenario: S14 Envelope keys are present

- **WHEN** F13's compact baseline document is decoded
- **THEN** those envelope keys exist as JSON fields and the codec result is ok.

#### Scenario: S15 Empty document is refused

- **WHEN** the certificate bytes are empty
- **THEN** decodeBytes reports malformed emptyDocument and Typed.execute is not called.

#### Scenario: S16 Missing payload field is refused

- **WHEN** the module object omits `payload`
- **THEN** decode refuses missing-field.payload.

### Requirement: SF06 Sequential composition steps only

Supported steps SHALL be `invoke`, `issue` and `revoke` as in delivered `Composition.Step`. Tree, n-ary, parallel, interleaving and atomic constructors, Claims obligation create/discharge operators, and Quint modules SHALL be explicit unsupported-form refusals, not quiet accepts.

#### Scenario: S17 Invoke issue and revoke encode

- **WHEN** a sequential workflow lists invoke, issue and revoke
- **THEN** decode yields the three delivered constructors.

#### Scenario: S18 Tree or n-ary step constructor is refused

- **WHEN** a step has `"ctor": "treeJoin"` or `"ctor": "naryAdvance"`
- **THEN** the checker reports unsupported-form and does not treat the document as a complete increment certificate.

### Requirement: SF07 Source-mapped constructible grammar

The serialized language SHALL construct every supported delivered Typed Expr/Template/State/Capability and sequential Composition catalog/step/run object named in `grammar.json`, including units, packed values, party refs, cells, observation refs, registry list entries, complete state tables, interfaces, ports, input sources, boundaries, history and steps. A bounded constructor subset is allowed only if omitted constructors are listed as unsupported. Registry, environment and configuration SHALL appear in the payload signature, never as ambient globals.

#### Scenario: S76 Full transfer template roundtrips constructors

- **WHEN** F25's payload registry entry 0 is decoded
- **THEN** guard/deltas/writes match Typed.Examples.transfer constructors (lit, arg, unary neg, binary le, caller/argument party refs).

### Requirement: SF08 Raw bytes JSON and decoded IR entrypoints

`decodeBytes` SHALL consume raw UTF-8, apply lexical scientific/float rejection, duplicate-key rejection, then schema decode. `checkBytes` SHALL call `decodeBytes` first. `checkIR` SHALL not accept malformed bytes. Resource-limit and timeout outcomes SHALL be blocked, not semantic refusal.

#### Scenario: S77 Float token is lexical before JSON value typing

- **WHEN** F04's raw document contains `0.5` as a JSON number
- **THEN** decodeBytes reports lexicalScientificOrFloat and does not depend on Lean.Data.Json retaining that token.
