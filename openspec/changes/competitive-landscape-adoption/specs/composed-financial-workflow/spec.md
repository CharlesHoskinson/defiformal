## Purpose

Produce the first composed financial example: two real components under one composition contract with one shared lemma, so that unit consistency and interface compatibility become demonstrated rather than available. Serves tasks I.3 and II.1.

Draft amendment (2026-11-18): effort availability belongs to delivery accounting;
prospective separate-effort measurement belongs to the linked
`competitive-landscape-validation` change. Original reviewed scenario bytes and
their 2026-11-17 acceptance remain historical evidence until this amendment is accepted.

## ADDED Requirements

### Requirement: Two financial components SHALL compose under one contract

Composition of the sUSDS deposit and the token0 quote register SHALL require an explicit, financially meaningful input/output relation and one `ComponentContract` instance whose preservation theorem invokes one named financial lemma shared by both components. Without that relation, only narrower library/interface reuse MAY be claimed and composition MUST remain open.

#### Scenario: Composition is checked

- **WHEN** the composed workflow module is built
- **THEN** exactly one `ComponentContract` instance covers both components, initialization and preservation of a named financial invariant are proved for the actual composed execution with each step's local guarantees discharged, one named lemma is invoked by both, dimension and refusal obligations are discharged, and the axiom audit reports no new trusted declaration

#### Scenario: Component counts are reported

- **WHEN** the second component is registered
- **THEN** the record reports its scoped model, specification and guidance line counts and attribution separately from the first, identifies shared/unallocated source, and states effort availability without inferring development cost or savings

### Requirement: Component accounting SHALL report scope and effort availability

The accounting record SHALL identify the selected vault-deposit and token0
quote-register adapter source revisions/hashes, exhaustive line categories,
attribution provenance and supporting-source exclusions. It MUST distinguish
adapter/workflow counts from complete-component costs. Each effort field SHALL
carry a measurement and method or an explicit unavailable value (`null`) with
reason and provenance. Shared elapsed intervals, command runtimes and missing
records MUST NOT be promoted to separate authoring time, human person-hours,
zero effort or productivity evidence. A new reconciliation SHALL identify the
amended criterion and preserve legacy accounting verdicts.

#### Scenario: Accounting records unavailable historical effort honestly

- **WHEN** selected component accounting is reconciled and historical or separately allocated effort cannot be recovered
- **THEN** counts, attribution, exact scope and exclusions remain checkable, missing effort stays null with reasons and evidence sources, the original unmet measurement criterion is preserved, and prospective measurement is explicitly assigned to validation tasks 2.1/2.2 without claiming cost savings
