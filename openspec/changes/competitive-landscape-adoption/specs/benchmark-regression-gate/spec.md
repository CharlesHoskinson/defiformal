## Purpose

Detect build and axiom-audit failures on every commit. Serves task I.1.

## ADDED Requirements

### Requirement: Every commit SHALL run the regression gate

The repository SHALL run, on every commit to the delivery branch, the Lean build and the axiom audit, and SHALL fail the gate on a build error or an audit finding.

#### Scenario: Passing run at the current revision

- **WHEN** the gate runs at the current revision with the pinned toolchain
- **THEN** a passing Lean build and axiom audit are visible for that revision, and the gate exits successfully

#### Scenario: Deliberate break is caught

- **WHEN** one audited theorem is replaced by `sorry` or a build error is deliberately introduced
- **THEN** the gate exits with failure and names the build error or the audit finding
