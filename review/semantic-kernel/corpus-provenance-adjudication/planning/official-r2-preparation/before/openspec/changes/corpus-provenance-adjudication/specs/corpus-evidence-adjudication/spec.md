## Purpose

Add auditable source-backed judgments over immutable annotation observations while preserving all unresolved disagreement and challenge evidence.

## ADDED Requirements

### Requirement: Exact independent observation inventory

The system SHALL preserve raw A/B answers and mechanical agreement records and maintain all 29 facet disagreements plus the separately identified Liquity V1 liquidation challenge.

#### Scenario: ADJ-01 Full initial disagreement set

- **WHEN** the frozen A/B inputs are compared
- **THEN** exactly the 29 inventoried unit/facet records across 24 units are queued, with all 32 symmetric-difference label instances; existing research drafts may supply bound evidence inputs but do not count as accepted decisions

#### Scenario: ADJ-02 Separate agreed-label challenge

- **WHEN** the Liquity V1 liquidation challenge is queued
- **THEN** liquidation remains present in both raw label sets, the actual mechanisms facet remains INTERSECTION_UNRESOLVED because redemption differs, and the historical challenge wording is retained without inventing another facet disagreement

### Requirement: Reusable scoped label predicates

The system MUST apply a frozen explicit inclusion predicate, product/version/time scope and direct-service/no-inheritance rules to every adjudicated label.

#### Scenario: ADJ-03 All disputed labels have rules

- **WHEN** the 29 records and separate liquidation challenge are expanded to label claims
- **THEN** all 17 distinct disputed labels plus liquidation reference explicit auditable predicates and no protocol-specific exception

#### Scenario: ADJ-04 Dependency or parent inheritance

- **WHEN** only an underlying product or unscoped parent text exhibits the proposed label
- **THEN** that evidence cannot establish the child direct-service claim and unsupported promotion is rejected

#### Scenario: ADJ-05 Unknown label predicate

- **WHEN** an evidence decision proposes a label without a declared rule version and predicate
- **THEN** the decision is rejected without inventing a default predicate

### Requirement: Truthful evidence dispositions

The system SHALL distinguish supported, refuted, not_evidenced, conflicting and not_applicable dispositions from review process status.

#### Scenario: ADJ-06 Silence and empty agreement

- **WHEN** sources omit a mechanism or both annotations are empty
- **THEN** absence is not inferred and the claim remains not_evidenced unless positive scoped evidence supports another disposition

#### Scenario: ADJ-07 Applicable evidence conflict

- **WHEN** two applicable sources conflict and version/time scoping cannot resolve them
- **THEN** both are retained with a conflicting disposition rather than selected by reviewer majority

#### Scenario: ADJ-08 Partial facet resolution

- **WHEN** one disputed label is supported but another remains conflicting or not evidenced
- **THEN** the facet remains semantically unresolved despite accepted review of the individual records

### Requirement: Versioned evidence adjudication and effective view

The system SHALL append accepted judgments and superseding records without editing prior judgments or observations, and derive effective facets with explicit reasons.

#### Scenario: ADJ-09 Version-specific Liquity evidence

- **WHEN** validated existing or newly captured V1-specific code/docs address liquidation and redemption conditions and receive independent review
- **THEN** separate scoped decisions can update the effective view without changing old A/B answers, relabelling an imported research packet as a collector run, requiring redundant acquisition of valid bytes, or claiming historical/deployment fidelity

#### Scenario: ADJ-10 Superseded decision

- **WHEN** new evidence reverses a previously accepted disposition
- **THEN** a new linked record explains the effective facet change while all prior decision and observation bytes remain available

#### Scenario: ADJ-11 Reviewed unresolved closure

- **WHEN** every queue item has reviewed records but some dispositions remain not_evidenced or conflicting
- **THEN** work accounting is complete while the report and roadmap retain the exact unresolved semantic count
