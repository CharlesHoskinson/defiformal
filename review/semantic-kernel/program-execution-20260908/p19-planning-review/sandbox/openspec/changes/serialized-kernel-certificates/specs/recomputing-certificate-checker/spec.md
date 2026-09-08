## Purpose

Defines the recomputing certificate checker that derives typing, footprint, authority, accounting and sequential composition judgments from delivered kernel entrypoints rather than from supplied labels.

## ADDED Requirements

### Requirement: CC01 Recompute typing

TypeCorrect SHALL be the result of actual `Args.check` against the selected template signature and packed values. A supplied `TypeCorrect` tag, theorem name or caller assertion SHALL NOT discharge typing.

#### Scenario: S19 Argument unit mismatch is evaluation refusal

- **WHEN** a transfer template expects amount USD and the request supplies amount share
- **THEN** the checker reports kernel `evaluation argumentUnit` and TypeCorrect is false.

#### Scenario: S20 Claimed TypeCorrect tag is not a pass

- **WHEN** a certificate claims `"judgments": ["TypeCorrect"]` with a unit-mismatched request
- **THEN** the checker still refuses and does not accept the tag as evidence.

### Requirement: CC02 Recompute footprints

FootprintCorrect SHALL recompute required state and environment reads from guard, delta and supply expressions, plus declared writes, using the delivered template inventories. Conservative `ite` reads include both branches. Success SHALL require required reads ⊆ declared reads and actual net movement ⊆ declared writes.

#### Scenario: S21 Undeclared state read is stateReadFootprint

- **WHEN** a guard reads a balance cell that is absent from `stateReads`
- **THEN** the checker reports kernel `stateReadFootprint`.

#### Scenario: S22 Undeclared environment read is envReadFootprint

- **WHEN** a delta observes a key absent from `envReads`
- **THEN** the checker reports kernel `envReadFootprint`.

#### Scenario: S23 Undeclared write is writeFootprint

- **WHEN** a nonzero effect targets a cell absent from `writes`
- **THEN** the checker reports kernel `writeFootprint`.

### Requirement: CC03 Recompute authority

AuthorityCorrect SHALL use delivered `hasAuthority` / `authorizesId` on the live capability store, invocation context and operation. Invoke, debit and supply rights SHALL be checked separately. Revoked tombstones SHALL remain unusable. Issue and revoke SHALL go through `issueCapability` and `revokeCapability`.

#### Scenario: S24 Missing invoke grant is unauthorizedInvoke

- **WHEN** the request lists no live invoke capability for the caller, domain and operation
- **THEN** the checker reports kernel `unauthorizedInvoke`.

#### Scenario: S25 Debit without grant is unauthorizedDebit

- **WHEN** net effect on a cell is negative and no live debit right for that cell is authorized
- **THEN** the checker reports kernel `unauthorizedDebit`.

#### Scenario: S26 Revoked identifier cannot authorize

- **WHEN** a previously live invoke id is revoked and then used
- **THEN** `authorizesId` is false and execution reports `unauthorizedInvoke`.

### Requirement: CC04 Recompute accounting and funds

AccountingCorrect SHALL use delivered `Evaluated.accountingOK` (party-sum of effects equals supply per domain/asset) and the nonnegative post-balance check. The checker SHALL NOT skip either test because a tag or theorem name is present.

#### Scenario: S27 Unbalanced deltas are accounting refusal

- **WHEN** a transfer debits 3 and credits 4 with zero supply
- **THEN** the checker reports kernel `accounting`.

#### Scenario: S28 Overdraft is insufficientFunds

- **WHEN** alice USD 10 is debited 11 under otherwise valid grants
- **THEN** the checker reports kernel `insufficientFunds`.

#### Scenario: S29 Successful transfer three yields alice seven bob three

- **WHEN** alice USD 10 transfers 3 to bob under valid grants, catalog and writes
- **THEN** the checker reports accepted with alice USD 7, bob USD 3, vault USD 20, and unchanged capability store.

### Requirement: CC05 Recompute sequential composition

CompositionCompatible in this increment SHALL mean delivered `validateCatalog` plus `executeStep` / `Sequence.run` over invoke/issue/revoke. Catalog access, history-dependent inputs and receipt extraction against the pre-state SHALL be the actual Composition functions.

#### Scenario: S30 Invalid catalog is configuration

- **WHEN** `validateCatalog` is false
- **THEN** `executeStep` and `startCursor` report `configuration` and the checker matches that constructor.

#### Scenario: S31 Sequential invoke uses actual kernel execute

- **WHEN** a catalog-valid invoke step runs
- **THEN** the checker result equals `executeStep` including extracted receipt from the pre-state and post-state snapshots.

#### Scenario: S32 Future priorOutput is unavailableOutput

- **WHEN** an input source is `priorOutput` at step ≥ current index
- **THEN** the checker reports interface `unavailableOutput`.

### Requirement: CC06 Exact refusal constructors and precedence

Refusals SHALL retain the exact delivered constructor (`Typed.Refusal`, `InterfaceFailure`, `AuthorityFailure`, `Composition.Failure`). A boolean `failed: true` without constructor identity SHALL NOT pass. Decode failures precede kernel checks. Kernel `execute` SHALL keep the documented order: unknownOperation, actorMismatch, domainMismatch, partyArity, Args.check evaluation, unauthorizedInvoke, template evaluation, then applyEvaluated order guard, stateReadFootprint, envReadFootprint, crossDomain, unauthorizedDebit, unauthorizedSupply, insufficientFunds, accounting, writeFootprint.

#### Scenario: S33 Actor mismatch precedes unauthorized invoke

- **WHEN** `claimedActor` disagrees with the context principal and invoke authority is also missing
- **THEN** the reported refusal is `actorMismatch`.

#### Scenario: S34 Unknown operation precedes other kernel checks

- **WHEN** the registry has no template and the request is otherwise malformed
- **THEN** the reported refusal is `unknownOperation`.

#### Scenario: S35 Boolean failed without constructor is not a pass

- **WHEN** F31 is raw `{"ok":false}`
- **THEN** decodeBytes is malformed, and M11 instead compares F52's two complete Reports with different present constructors.

### Requirement: CC07 Reject non-evidence

A theorem name, string, keyword tag, `gate33` OTHER/Led/Prop/Cmp/Post label, or caller-supplied `Evaluated` record SHALL NOT discharge any required judgment. `Typed.execute` SHALL continue to ignore caller-supplied validity certificates.

#### Scenario: S36 Theorem name does not instantiate a library

- **WHEN** a certificate lists `"theorem": "asset_delta_balance"` with no recorded Lean object identity and compiler check
- **THEN** LibraryTheoremsInstantiated is outstanding or refused, never accepted.

#### Scenario: S37 Keyword tag is not a certificate

- **WHEN** a payload contains gate33-style `"tag": "TypeCorrect"` or `"tag": "OTHER"`
- **THEN** the checker treats the tag as a non-evidence field and still recomputes or refuses.

#### Scenario: S38 Caller-supplied evaluated record is ignored

- **WHEN** a request includes a precomputed `Evaluated` object
- **THEN** decode refuses unknown-field or the kernel path still calls `template.evaluate` on the pre-state and ignores the supplied record.
