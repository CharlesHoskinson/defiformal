# interface-total-preservation Specification

## Purpose
Establish initialized interface-total invariants from actual write confinement, shared-flow neutrality and explicit support for declared observations.

## Requirements

### Requirement: Conditional port-confined conservation

The system SHALL prove unchanged region sum from actual successful receipt writes confined to a declared shared set and zero summed effect over the region intersection with that set. Actual write locality MUST justify the complementary frame; catalog validity or whole-asset supply neutrality alone MUST NOT imply region neutrality.

#### Scenario: IT01 Nonvacuous shared cancellation
- **WHEN** Alice−2/Bob+2 are actual nonzero effects inside the region and shared set
- **THEN** the neutral intersection sum and actual confinement establish unchanged total10

#### Scenario: IT02 Supply neutrality is insufficient
- **WHEN** actual transfer2 leaves the singleton Alice region with whole-asset supply0
- **THEN** the region total drops by2 and the missing region-neutrality premise is explicit

#### Scenario: IT03 Complement framed
- **WHEN** an actual accepted receipt writes only inside Q
- **THEN** every region cell outside Q is unchanged by actual locality

### Requirement: Supported declared total

The system SHALL distinguish a fixed initialized ghost quantity from a state-dependent declared total. For the latter it MUST require value-valued support, actual writes excluding that support and neutral region flow, and MUST prove preservation of the initialized equality.

#### Scenario: IT04 Fixed declared quantity
- **WHEN** initial region sum is10 and each actual permitted step has neutral confined region flow
- **THEN** the fixed declared quantity10 remains equal to the region sum at every prefix

#### Scenario: IT05 Private total support
- **WHEN** a private home/USD total cell10 supports the declared quantity and actual transfer2 avoids it
- **THEN** both declared quantity and region sum remain10

#### Scenario: IT06 Missing initialization
- **WHEN** a constant declared quantity11 is compared to entry region sum10 under only neutral later actions
- **THEN** preservation does not establish equality at entry or later; initialization remains required

### Requirement: Actual writable-total counterexample

The system SHALL provide a separately valid catalog and an authorized successful transition that changes a writable declared-total observation while leaving the region sum unchanged. A denied access attempt MUST NOT stand in for this counterexample.

#### Scenario: IT07 Exposed total changes
- **WHEN** the separately exported writable total cell10 receives authorized +1 outside region Alice/Bob
- **THEN** execution succeeds, region stays10, declared total becomes11 and the equality is false

#### Scenario: IT08 Exact missing premise
- **WHEN** the same accepted write is within shared Q and has zero region flow
- **THEN** the violated support-exclusion premise is identified; the example does not refute the theorem with all premises

### Requirement: Initialized operational total lifting

The system SHALL lift local actual-step total obligations through every sequential prefix, accepted recursive sequential-group simulation and existing binary shared prefixes. Local obligations MUST quantify over arbitrary current execution inputs and permitted successful steps, without assuming the desired completed run. The arbitrary-entry group result MUST follow actual advance/continueRun induction or an entry-indexed suffix trace and then actual Metatheory.runGroup_eq_continueRun; it MUST NOT require a genesis trace for F16.

#### Scenario: IT09 Nonzero-index group
- **WHEN** a group starts at index2 with retained history and executes transfer2 followed by the specified snapshot-driven return2
- **THEN** the total stays10 through actual steps at indices2 and3, with nextIndex4 and retained old history

#### Scenario: IT10 Shared total invariant
- **WHEN** initialized Alice/Bob/Carol region total10 is preserved by each actually selected paired debit and peer refusal
- **THEN** every shared prefix retains total10, including F19 peer continuation after retained4/4/2 refusal and F20 failed-suffix skip before final3/3/4

#### Scenario: IT11 Absorbed failure
- **WHEN** a sequential cursor has already refused or a selected shared stream is failed or exhausted
- **THEN** the identity transition preserves the reached total without a fabricated successful receipt
