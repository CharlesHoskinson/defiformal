## Purpose

Deliver DeFiFormal's results as identified, published and technically replayable
evidence. The original assessment found gaps in CI, release and outside
reproduction. This delivery milestone serves tasks I.2, III.1 and III.2;
actual outside reproduction remains required by the linked validation change.

Draft amendment (2026-11-18): the original outside P18 scenario transfers to
validation task 3.1; the original outside package-only scenario transfers to task
4.1. The actual-person, outcome and timing requirements remain pending there.
This changes milestone allocation, not the recorded absence of outside runs.

## ADDED Requirements

### Requirement: The repository SHALL have a release, a contribution guide and a license

The repository SHALL carry a tagged release, a contribution guide and a license file.

#### Scenario: Release and contribution files are available

- **WHEN** the release is published
- **THEN** a tagged release date, a contribution guide and a license file are present

### Requirement: Compiled proof modules SHALL ship as an evidence package

The package SHALL contain the compiled proof modules, checker name and version, the trusted-import list, what each check covers and checksums. The composed example and every later integration SHALL ship with an evidence package, and adoption SHALL be recorded only when corroborated.

Engineering verification SHALL replay the exact selected modules from a fresh
archive extraction using its identified bundled runtime. The record SHALL bind
archive/source/tool identities and actual command outcomes. Missing, empty or
unreadable required evidence MUST block; altered bytes MUST fail. Engineering
replay SHALL remain distinct from the pending outside-person reproduction in
`competitive-landscape-validation`.

#### Scenario: Published package passes engineering replay

- **WHEN** the exact published archive is extracted into an unrelated working directory for engineering verification
- **THEN** the bundled checker/runtime replays the nonempty selected-module inventory with recorded results and trust scope, missing/empty/unreadable evidence blocks, altered bytes fail, and no outside-person reproduction is inferred

#### Scenario: Integrations carry evidence

- **WHEN** the composed example or a later integration is shipped
- **THEN** it carries its evidence package and every recorded adoption is corroborated
