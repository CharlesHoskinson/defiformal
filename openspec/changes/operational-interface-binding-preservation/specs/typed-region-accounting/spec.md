## Purpose

Connect finite typed balance regions to the exact signed effects of actual accepted execution receipts, including boundary transfers and issuance.

## ADDED Requirements

### Requirement: Finite typed region observations

The system SHALL expose finite region sums with set membership, exact domain/asset well-formedness and zero for an empty region. Repeated region declarations MUST NOT duplicate balances; typed interface results MUST state region well-formedness.

#### Scenario: RA01 Empty region
- **WHEN** an empty region is observed in any state
- **THEN** the balance sum and receipt delta are both zero

#### Scenario: RA02 Duplicate declarations
- **WHEN** the same home/USD Alice cell is inserted twice into a region with Alice6 and Bob4
- **THEN** the region sum is10, not16, and membership remains set-valued

#### Scenario: RA03 Typed membership
- **WHEN** a region declared home/USD contains an away or EUR cell
- **THEN** the region well-formedness proposition is false; dimensioned preservation cannot omit that premise

### Requirement: Exact signed actual receipt accounting

For every actual successful invocation or administrative step, the system SHALL prove post-region sum equals pre-region sum plus the complete signed effect of that actual result receipt. The theorem MUST NOT assume this equation or accept a replacement receipt as its premise.

#### Scenario: RA04 Neutral nonzero transfer
- **WHEN** actual authorized transfer2 moves Alice6/Bob4 to4/6
- **THEN** the two-cell sum remains10 with effects −2,+2 and net region delta0

#### Scenario: RA05 Boundary-crossing transfer
- **WHEN** the same actual transfer is observed in singleton Alice region
- **THEN** the sum changes6 to4 and delta is−2 even though whole home/USD supply is0

#### Scenario: RA06 Nonzero issuance
- **WHEN** actual authorized mint3 credits Bob from4 to7 in the two-cell region
- **THEN** the sum changes10 to13 and receipt delta is+3; no neutral-flow conclusion is inferred

#### Scenario: RA07 Repeated targets
- **WHEN** the actual receipt contains Alice−1,Alice−2,Bob+3 in that order
- **THEN** the singleton Alice delta is−3, final Alice3/Bob7, and all original receipt entries are retained

### Requirement: Administrative balance identity

The system SHALL derive zero region effect for successful issue/revoke receipts and unchanged balances on actual administrative refusal, while retaining exact capability-store changes and refusal reasons.

#### Scenario: RA08 Issue and revoke
- **WHEN** an authenticated administrator issues a capability at fresh ID n then revokes n
- **THEN** all balances stay unchanged, both region deltas are0, and the store appends then tombstones that exact entry

#### Scenario: RA09 Refused administration
- **WHEN** a non-administrator attempts the same issue
- **THEN** the actual authority refusal retains the input world/store and produces no successful receipt

### Requirement: Actual successful prefix accounting

The system SHALL prove telescoping region accounting over actual successful sequential events and global shared-run attempts at every prefix. Refused, skipped and unreachable suffix actions MUST NOT contribute a receipt.

#### Scenario: RA10 Successful prefix followed by refusal
- **WHEN** paired debit succeeds from5/5/0 then transfer7 refuses and mint3 is a stopped suffix
- **THEN** the reached ledger is4/4/2, exactly one successful receipt is summed, and failure occurs at absolute index1

#### Scenario: RA11 Shared global receipt fold
- **WHEN** complete schedule left,right,left executes two paired debits then a left insufficient-funds refusal in region Alice/Bob/Carol
- **THEN** the reached ledger is3/3/4 and exactly the two actual global successful receipts contribute

#### Scenario: RA12 Peer continues after refusal
- **WHEN** the same F17 branches run under left,left,right from5/5/0
- **THEN** the first paired debit reaches4/4/2, left refusal at local index1 retains4/4/2, then the peer reaches3/3/4 with two actual successful receipts, exact retained left failure and unchanged full store

#### Scenario: RA13 Failed suffix skip before peer
- **WHEN** left=[op102,op106,op101] and right=[op102] run under left,left,left,right
- **THEN** the failed left mint suffix adds no attempt, receipt or supply; left consumed becomes3 with nextIndex1, and the right peer still reaches3/3/4 with the exact earlier failure retained
