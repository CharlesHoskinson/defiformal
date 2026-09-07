## Purpose

Defines the bounded fixed-claim lifecycle contract described in design.md.

## ADDED Requirements

### Requirement: CP01 Fund creation with actual registered execution

Loan creation SHALL append a liability only after actual Composition execution transfers the exact principal from creditor to debtor with zero supply and no other effects.

#### Scenario: P01 A debtor borrows10 from a funded creditor

- **WHEN** a debtor borrows10 from a funded creditor
- **THEN** one command publishes cash movement and exactly one face10 claim.

#### Scenario: P02 Funding is missing or has the wrong amount or source

- **WHEN** funding is missing or has the wrong amount or source
- **THEN** the candidate receipt fails exact shape and neither funds nor a claim are published.

### Requirement: CP02 Repay the current creditor with actual cash

Repayment SHALL require 0<amount≤remaining and actual debtor-to-current-creditor movement before atomically updating paid and remaining.

#### Scenario: P03 10 outstanding is repaid4 then6

- **WHEN** 10 outstanding is repaid4 then6
- **THEN** the first leaves remaining6/paid4 and the second yields terminal paid with paid10 and actual cash restored.

#### Scenario: P04 The creditor changed before repayment

- **WHEN** the creditor changed before repayment
- **THEN** cash reaches the current creditor; historical payments retain their own event creditor.

#### Scenario: P05 Repayment is zero, negative or exceeds remaining

- **WHEN** repayment is zero, negative or exceeds remaining
- **THEN** the ordered amount refusal preserves ledger and liability.

### Requirement: CP03 Reject substituted effects and supply

Payment validation SHALL compare the actual invoked receipt at every cell and every domain/asset supply entry, preserving kernel failure distinctions.

#### Scenario: P06 A successful inner invocation pays from another party, to another creditor, or in another asset

- **WHEN** a successful inner invocation pays from another party, to another creditor, or in another asset
- **THEN** paymentMismatch retains the tentative diagnostic and publishes no state change.

#### Scenario: P07 A successful inner invocation adds supply or an extra balanced transfer

- **WHEN** a successful inner invocation adds supply or an extra balanced transfer
- **THEN** exact all-cell/supply checks reject it despite a plausible headline payment.

#### Scenario: P08 The registered invocation refuses for authority or insufficient funds

- **WHEN** the registered invocation refuses for authority or insufficient funds
- **THEN** the exact underlying Composition failure is retained without a claim mutation.

### Requirement: CP04 Publish cash and claims together

An accepted lifecycle money command SHALL publish its actual result and claim mutation once; every refusal SHALL retain entry public state and successful history.

#### Scenario: P09 Execution succeeds but subsequent payment validation fails

- **WHEN** execution succeeds but subsequent payment validation fails
- **THEN** public world, claims, outputs and events remain at entry while the failure records the actual tentative result.

#### Scenario: P10 Cash or claim publication is individually omitted

- **WHEN** cash or claim publication is individually omitted
- **THEN** the independently expected full-state oracle rejects the incomplete result.
