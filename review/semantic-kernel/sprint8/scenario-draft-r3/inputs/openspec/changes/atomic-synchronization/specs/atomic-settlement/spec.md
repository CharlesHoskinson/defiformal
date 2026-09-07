## Purpose

Specify typed receipt-derived transient obligations and a deterministic full settlement check before an atomic event may commit.

## ADDED Requirements

### Requirement: Complete typed policy

Clearing lanes SHALL have unique domain/asset pairs with an explicit vault cell, and participants SHALL be duplicate-free and cover every authenticated static invocation principal. Final enumeration SHALL include every lane/participant key in declared lane then participant order, retaining typed identities. Empty lanes SHALL be an explicit ordinary batch mode and SHALL NOT count as evidence of transient settlement.

#### Scenario: Ambiguous lane rejection

- **WHEN** two lanes repeat a domain/asset, with either equal or different vaults
- **THEN** policy admission refuses the exact duplicate pair

#### Scenario: Participant completeness

- **WHEN** a participant is duplicated or a later static invocation principal is absent
- **THEN** admission reports the corresponding distinct policy error before execution

#### Scenario: Nonempty settlement evidence

- **WHEN** a fixture is counted as a transient-settlement success or negative
- **THEN** it contains a real configured lane and a nonzero intermediate obligation

### Requirement: Actual receipt origin

Outstanding entries SHALL initialize to zero and update only by subtracting the actual accepted receipt net effect at each exact lane vault cell from the authenticated invoker entry. Other participant entries SHALL remain unchanged. Repeated receipt deltas SHALL be fully summed. No-op effects SHALL NOT erase debt.

#### Scenario: Draw and return

- **WHEN** one authenticated principal draws7 from vault10 and returns7
- **THEN** the intermediate obligation is7 and the final obligation is0 with vault cash10

#### Scenario: Repeated deltas and no-op

- **WHEN** a receipt contains repeated deltas at the lane cell or a later operation has zero lane effect
- **THEN** the full net delta is used and the no-op preserves any existing obligation

#### Scenario: Intermediate credit

- **WHEN** an independently funded principal returns extra before a later authorized draw of that credit
- **THEN** the signed negative intermediate entry can return to zero and settle

### Requirement: Qualified final clearance

Commit SHALL require every outstanding lane/participant entry to equal exact zero. Any nonzero table SHALL abort with the complete canonical nonzero residual table and the entry world. Principal, domain and asset qualifications SHALL NOT be collapsed or netted against other keys.

#### Scenario: Under and over return

- **WHEN** draw7 is followed by return6 or independently funded return8 with no further movement
- **THEN** the results abort with residual+1 or−1 respectively and restore vault10

#### Scenario: Cross-principal cancellation

- **WHEN** one principal owes7 while a peer has credit−7 in the same lane
- **THEN** global sum zero does not settle and both exact residual entries are returned

#### Scenario: Cross-asset and domain separation

- **WHEN** equal numeric debts and credits occur in distinct configured assets or domains
- **THEN** every qualified nonzero entry remains and settlement refuses

#### Scenario: Last lane or participant residual

- **WHEN** only a later lane or later participant has a nonzero obligation
- **THEN** final clearance detects that exact residual rather than checking only a prefix

### Requirement: Lane supply policy

Every successful receipt SHALL have zero signed supply for every configured lane domain/asset across that asset, including supply at a nonvault principal. The first violating lane in policy order SHALL cause a located policy abort with lane and exact amount. Authorized supply of unconfigured assets SHALL remain permitted.

#### Scenario: Nonvault lane mint

- **WHEN** a receipt mints the lane asset into a cell different from the clearing vault
- **THEN** the event aborts for lane supply with the exact amount even if vault cash is unchanged

#### Scenario: Nonlane supply success

- **WHEN** an independently authorized unconfigured-asset mint accompanies a fully cleared nonempty lane
- **THEN** the event commits with its exact nonzero supply summary
