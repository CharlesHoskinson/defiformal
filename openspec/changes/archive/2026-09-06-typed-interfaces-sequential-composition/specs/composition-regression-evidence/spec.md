## Purpose

Require reproducible composed examples, discriminating mutations, and independent
review evidence with claims tied to the source and checks actually performed.

## ADDED Requirements

### Requirement: Composed reference workflow coverage
The system SHALL provide named, independently expected comparisons for order,
first and middle refusal, state propagation, typed output routing, resource
isolation, administration, revocation, and protected-state framing. Comparisons
SHALL check complete finite worlds and observable histories where applicable.

#### Scenario: Positive and negative siblings
- **WHEN** foreign-private access, revoked use, or incompatible output binding is tested
- **THEN** a corresponding permitted, live, or correctly typed sibling succeeds so unrelated refusal does not explain the negative result

#### Scenario: Composed financial reference
- **WHEN** transfer, deposit, and withdrawal are composed from the documented initialized reference world
- **THEN** final balances, actual supply receipts, outputs, and event order match independently specified expectations

### Requirement: Discriminating source mutations
The system SHALL compile and execute actual altered workflow code to detect
ordering changes, continuation after refusal, stale ledger/store use, omitted
revocation propagation, interface bypass, incorrect output routing, omitted
supply receipts, and reset continuation positions. Each required mutant SHALL
be killed by a relevant executed comparison.

#### Scenario: Executable mutant
- **WHEN** a mutant compiles but changes a targeted workflow behavior
- **THEN** a named comparison fails and the evidence records the mutation, source identities, command, and outcome

#### Scenario: Invalid or vacuous mutation run
- **WHEN** a required mutant does not apply, fails to compile, has an empty comparison inventory, or survives
- **THEN** acceptance is blocked and the result is not reported as a detected semantic mutation

### Requirement: Honest verification and proof scope
The system SHALL preserve legacy regressions, audit the imported composition
proof closure, and record theorem premises separately from bounded execution and
measurements. Accepted proofs SHALL contain no admitted proof holes, custom
axioms, or native decision axioms.

#### Scenario: New imported proof
- **WHEN** a composition proof enters the accepted import closure
- **THEN** the axiom audit covers its dependencies and the proof inventory states its scope and premises

#### Scenario: Existing regression failure
- **WHEN** a previously passing required regression fails after composition changes
- **THEN** Sprint 5 acceptance is blocked until the failure is resolved and relevant checks pass

### Requirement: Independent review and source-bound delivery
The system SHALL retain GPT-6 implementation through the stock harness and native
Grok and Fable review of the actual candidate, with findings, fixes, limitations,
and exact source/tool identities saved. It SHALL NOT use Foreman. Planning
completion SHALL be distinguished from implementation acceptance.

#### Scenario: Candidate changes after review
- **WHEN** a source fix changes the candidate after independent review
- **THEN** affected verification and review evidence is refreshed against the new candidate before acceptance

#### Scenario: Delivery record
- **WHEN** Sprint 5 is marked implemented
- **THEN** all required tasks, verification, adjudicated review, and branch delivery evidence are complete and the remote branch head is verified
