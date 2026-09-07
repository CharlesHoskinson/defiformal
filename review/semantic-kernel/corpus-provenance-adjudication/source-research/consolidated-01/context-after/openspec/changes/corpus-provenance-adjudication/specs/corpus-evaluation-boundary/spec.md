## Purpose

Protect the distinction between permanent development exposure and genuinely reserved evaluation material through explicit manifests and freezes.

## ADDED Requirements

### Requirement: Permanent development membership

The system MUST keep all existing 75 candidates, design-inspected derivatives and the twelve proposed cases found development-exposed by the retained exposure audit in development, with exposure evidence and no relabeling as untouched. The twelve are exposure records, not twelve newly added normalized candidates.

#### Scenario: EV-01 Original and derived development cases

- **WHEN** a normalized candidate gains a source-backed child identity
- **THEN** both original and child remain development with their ancestry and exposure reasons

#### Scenario: EV-02 False untouched promotion

- **WHEN** a current development case or its derivative is marked reserved or untouched
- **THEN** validation rejects the promotion even if the name or version ID changed, including every case in the existing twelve-proposal exposure audit

### Requirement: Separate honest empty evaluation manifest

The system SHALL emit a separate not-selected evaluation manifest and SHALL NOT report zero cases as a passed evaluation.

#### Scenario: EV-03 No selected holdouts

- **WHEN** the current package has not selected new evaluation cases
- **THEN** the manifest records not_selected with zero cases and evaluation evidence is blocked or not run

#### Scenario: EV-04 Missing evaluation freeze

- **WHEN** required kernel/library/rule/translator/evaluator/development bindings are incomplete
- **THEN** readiness remains blocked_missing_freeze and no semantic case acquisition is permitted

### Requirement: Frozen selection and exposure lifecycle

The system MUST bind later selection to explicit frozen inputs and access/overlap records and preserve the original run when subsequent adaptation occurs.

#### Scenario: EV-05 Later complete reservation

- **WHEN** a later independent curator records a new case after a complete freeze and exposure audit
- **THEN** reserved status binds the exact freeze, selection time and declared overlap limits without claiming an executed result

#### Scenario: EV-06 Exposure or later adaptation

- **WHEN** builders inspect a reserved case before evaluation or adapt after its first frozen result
- **THEN** early exposure makes it development and later adaptation retains the original result with a separate post-freeze status
