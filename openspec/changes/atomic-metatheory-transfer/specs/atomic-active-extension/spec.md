## Purpose

Preserves old Atomic observations only under explicit new-step success, protected-write and settlement-safety premises.

## ADDED Requirements

### Requirement: FX01 Fixed-policy settlement-neutral extension

Active extension SHALL retain the same complete ordered policy, store, old dependencies and boundaries, protect every policy lane cell and require actual new steps to succeed with zero lane effects and accepted supply checks.

#### Scenario: X01 Funded new EUR peers execute outside protected USD lane cells

- **WHEN** funded new EUR peers execute outside protected USD lane cells
- **THEN** their independently proved success and neutrality preserve old draw/return commit for every admitted schedule.

#### Scenario: X02 A disjoint new peer refuses or mints a lane asset into an unprotected cell

- **WHEN** a disjoint new peer refuses or mints a lane asset into an unprotected cell
- **THEN** the added kernel/supply abort prevents the theorem; write isolation alone is insufficient.

#### Scenario: X03 Policy/principal table, grant store or lane effects change

- **WHEN** policy/principal table, grant store or lane effects change
- **THEN** the missing premise remains explicit and no desired commit equality supplies it.

### Requirement: FX02 Honest projected old observations

The old projection SHALL retain label, restricted schedule, protected public world/full store, exact old receipts/outputs/supply and outcome; foreign failures SHALL remain failures.

#### Scenario: X04 An old failure occurs after inserted new tokens

- **WHEN** an old failure occurs after inserted new tokens
- **THEN** its old global position is the restricted length of the actual preceding token prefix, with reason/local index/invocation unchanged.

#### Scenario: X05 An added peer aborts or admission rejects it

- **WHEN** an added peer aborts or admission rejects it
- **THEN** the observer retains an explicit foreign failure instead of erasing it or reporting commit.

#### Scenario: X06 A new non-lane mint commits

- **WHEN** a new non-lane mint commits
- **THEN** extended supply may differ, but old projected supply is derived only from old committed receipts.

### Requirement: FX03 Noncircular atomic prefix and finish proof

Preservation SHALL follow actual prefix transitions and the unchanged owed table, then derive commit or exact unsettled/old-abort correspondence at the same finish boundary.

#### Scenario: X07 New enabledness and safety are established from current reachable state and actual receipt equations

- **WHEN** new enabledness and safety are established from current reachable state and actual receipt equations
- **THEN** token induction proves the projected result without assuming atomic commit or whole-run equality.

#### Scenario: X08 Old settlement leaves a residual or an old failure aborts

- **WHEN** old settlement leaves a residual or an old failure aborts
- **THEN** the extension has the same ordered residuals or projected old abort and exact protected rollback; later new tokens do not execute.
