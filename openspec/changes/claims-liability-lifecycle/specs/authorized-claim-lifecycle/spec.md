## Purpose

Defines the bounded fixed-claim lifecycle contract described in design.md.

## ADDED Requirements

### Requirement: CL01 Bind ownership and authenticated actors

Lifecycle authorization SHALL use the trusted boundary principal/domain and current row ownership, with separate unchanged kernel capabilities for cash movement.

#### Scenario: L01 A debtor invokes funded creation or repayment with valid cash authority

- **WHEN** a debtor invokes funded creation or repayment with valid cash authority
- **THEN** the debtor role and actual invoke/debit permissions are both checked.

#### Scenario: L02 A nondebtor pays or a noncreditor transfers, extends, defaults or forgives

- **WHEN** a nondebtor pays or a noncreditor transfers, extends, defaults or forgives
- **THEN** the exact role refusal preserves public state even if the actor has broad ledger/admin permissions.

### Requirement: CL02 Transfer and extend without inventing liability

Transfer SHALL change only creditor/revision and extension SHALL change only an active claim due/revision under the declared forbearance rules.

#### Scenario: L03 The current creditor transfers an active or defaulted claim

- **WHEN** the current creditor transfers an active or defaulted claim
- **THEN** the debtor, face, amounts, due, condition and default history remain unchanged.

#### Scenario: L04 The creditor extends an active due date

- **WHEN** the creditor extends an active due date
- **THEN** newDue is strictly later and at least now; principal and cash remain exact.

#### Scenario: L05 A defaulted claim is extended or a transfer names the debtor

- **WHEN** a defaulted claim is extended or a transfer names the debtor
- **THEN** the action refuses; no cure, self-payment claim or debtor novation occurs.

### Requirement: CL03 Distinguish forgiveness from paid discharge

Discharge by a creditor SHALL explicitly forgive the entire remaining amount, recording waived rather than paid and publishing no cash movement.

#### Scenario: L06 The creditor forgives an active or defaulted remainder

- **WHEN** the creditor forgives an active or defaulted remainder
- **THEN** remaining becomes0, waived increases by the old remainder, paid is unchanged and status is terminal forgiven.

#### Scenario: L07 Forgiveness is reported as repayment

- **WHEN** forgiveness is reported as repayment
- **THEN** the full status/paid/waived/receipt oracle rejects that report.

### Requirement: CL04 Record default without debt disappearance

Default SHALL require the current creditor, active status and now strictly greater than due; it SHALL preserve every monetary amount and retain immutable default history.

#### Scenario: L08 Default is requested exactly at due and one tick later

- **WHEN** default is requested exactly at due and one tick later
- **THEN** the first refuses and the second records default without erasing debt.

#### Scenario: L09 A defaulted claim receives partial or complete late repayment

- **WHEN** a defaulted claim receives partial or complete late repayment
- **THEN** payment remains allowed and defaultAt survives partial/defaulted or terminal/paid status.

### Requirement: CL05 Enforce revisions time and ordered refusal

Existing-row commands SHALL check expectedRevision and explicit ordered admission; lifecycle time SHALL be nondecreasing without strengthening legacy time semantics.

#### Scenario: L10 A stale row revision and unauthorized actor occur together

- **WHEN** a stale row revision and unauthorized actor occur together
- **THEN** revision refusal wins under the declared precedence.

#### Scenario: L11 A lifecycle boundary time decreases

- **WHEN** a lifecycle boundary time decreases
- **THEN** clock refusal precedes lookup; legacy execution retains its old timestamp behavior.
