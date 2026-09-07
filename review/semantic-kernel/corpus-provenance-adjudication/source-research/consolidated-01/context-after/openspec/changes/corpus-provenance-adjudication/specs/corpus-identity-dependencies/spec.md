## Purpose

Maintain traceable product and deployment identities, source pins, dependencies and residues without overstating deployed financial fidelity.

## ADDED Requirements

### Requirement: Complete candidate identity accounting

The system SHALL account for all 75 original candidates and preserve the distinction between organization labels, products, version names, source revisions and deployment identities.

#### Scenario: ID-01 Initial identity baseline

- **WHEN** the preserved normalization is loaded
- **THEN** 75 development candidates, 11 version labels, 64 unresolved versions and zero verified deployments remain the initial measured inventory

#### Scenario: ID-02 Brand is not deployment

- **WHEN** a brand, ranking, source version label or official URL is offered without a chain/code binding
- **THEN** deployment verification is refused while supported weaker identity fields remain available

### Requirement: Evidence-supported splits and residue

The system SHALL retain all original IDs and source-row content while adding only evidence-scoped product/version children and explicit unresolved bundle/residue records.

#### Scenario: ID-03 Additional supported product split

- **WHEN** a development source explicitly distinguishes further products or versions
- **THEN** new stable child IDs link to the original candidate and row while original counts and bytes remain unchanged

#### Scenario: ID-04 Ambiguous bundle

- **WHEN** the inspected source does not establish which child owns a mechanism or historical residue
- **THEN** the bundle and child attribution remain unresolved rather than inheriting the parent content

### Requirement: Typed scoped dependency relationships

The system SHALL record evidence, endpoints, relation and version/time scope for every asserted dependency and an explicit assessment for every candidate.

#### Scenario: ID-05 Supported dependency with cycle

- **WHEN** source evidence supports typed dependency edges including a cycle
- **THEN** all edges and scoped endpoint identities are retained without deleting cycles or transferring facet labels transitively

#### Scenario: ID-06 No dependency evidence

- **WHEN** a candidate assessment finds no adequate dependency evidence
- **THEN** not_evidenced is recorded and the empty edge set is not reported as independence

### Requirement: Reproducible source and deployment pins

The system MUST distinguish an immutable source pin from a verified deployment and require environment, observation block, actual code and build correspondence for verification.

#### Scenario: ID-07 Source pin only

- **WHEN** an exact official code revision and file digests are retained without deployment correspondence
- **THEN** code_pinned is reported while deployment remains unresolved or candidate

#### Scenario: ID-08 Verified direct deployment

- **WHEN** retained environment, address, block/code and reproducible source/build correspondence all agree
- **THEN** only that scoped deployment is verified with its method and evidence recorded

#### Scenario: ID-09 Proxy or code mismatch

- **WHEN** a proxy implementation at the observation block is omitted or actual code differs from the claimed build
- **THEN** verification is blocked for missing evidence or rejected for demonstrated mismatch, with distinct reasons

### Requirement: Independent fidelity classification

The system SHALL keep source inspection, deployment verification, bounded implementation-model comparison and checked refinement as separate evidence claims.

#### Scenario: ID-10 Deployment does not imply fidelity

- **WHEN** a deployment is verified but no implementation-model comparison or refinement exists
- **THEN** fidelity is at most source_inspected and stronger fidelity counts remain zero for this work

#### Scenario: ID-11 Off-chain scope

- **WHEN** positive scope evidence establishes an off-chain-only product with no applicable deployment
- **THEN** not_applicable names its reason and does not count as a verified deployment or erase external obligations
