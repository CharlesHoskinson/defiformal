## Purpose

Make DeFiFormal's results re-checkable by people outside the project. Reproduction failed for 3 of 13 assessed projects, including the two most active Lean and Rocq peers, and DeFiFormal's repository is blank on CI, release, outside reproduction and known adoption. Serves tasks I.2, I.4, III.1 and III.2.

## ADDED Requirements

### Requirement: The repository SHALL have a release, a contribution guide and a license

The repository SHALL carry a tagged release, a contribution guide and a license file.

#### Scenario: Release and contribution files are available

- **WHEN** the release is published
- **THEN** a tagged release date, a contribution guide and a license file are present

### Requirement: An outside developer SHALL reproduce the P18 package

A developer outside the project SHALL run the sprint P18 token0 package from its README, and the outcome and setup time SHALL be recorded whether it passes or fails.

#### Scenario: Reproduction is on record

- **WHEN** a developer outside the project follows the P18 token0 package README
- **THEN** a record exists with outcome, pass or fail, and setup time

### Requirement: Compiled proof modules SHALL ship as an evidence package

The package SHALL contain the compiled proof modules, checker name and version, the trusted-import list, what each check covers and checksums. The composed example and every later integration SHALL ship with an evidence package, and adoption SHALL be recorded only when corroborated.

#### Scenario: Third party re-checks from the package alone

- **WHEN** a third party receives the package and nothing else
- **THEN** they re-run the `leanchecker` pass and obtain the recorded result

#### Scenario: Integrations carry evidence

- **WHEN** the composed example or a later integration is shipped
- **THEN** it carries its evidence package and every recorded adoption is corroborated
