## Purpose

Produce the first composed financial example: two real components under one composition contract with one shared lemma, so that unit consistency and interface compatibility become demonstrated rather than available. Serves tasks I.3 and II.1.

## ADDED Requirements

### Requirement: Two financial components SHALL compose under one contract

Composition of the sUSDS deposit and the token0 quote register SHALL require an explicit, financially meaningful input/output relation and one `ComponentContract` instance whose preservation theorem invokes one named financial lemma shared by both components. Without that relation, only narrower library/interface reuse MAY be claimed and composition MUST remain open.

#### Scenario: Composition is checked

- **WHEN** the composed workflow module is built
- **THEN** exactly one `ComponentContract` instance covers both components, initialization and preservation of a named financial invariant are proved for the actual composed execution with each step's local guarantees discharged, one named lemma is invoked by both, dimension and refusal obligations are discharged, and the axiom audit reports no new trusted declaration

#### Scenario: Reuse is measured

- **WHEN** the second component is registered
- **THEN** the record reports its model, specification and guidance line counts, authoring effort and attribution, separately from the first
