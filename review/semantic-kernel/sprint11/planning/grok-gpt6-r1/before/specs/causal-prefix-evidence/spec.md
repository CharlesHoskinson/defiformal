## Purpose

Specify causal prefix evidence for actual finite shared-state execution with explicit assumptions and reproducible evidence.

## ADDED Requirements

### Requirement: Actual-prefix monitor correspondence

For identical fixed update function, initial monitor/machine and configuration/branches/boundaries, a deterministic monitor SHALL consume actual prefix dispatcher data, including the exact newly appended attempt or none for skip, SHALL not affect financial execution, and SHALL have executable erasure, replay/inductive-trace correspondence and a common-prefix theorem. This contract SHALL NOT infer an unconditional absence of future knowledge from a callback signature that permits captured constants.

#### Scenario: Producer then consumer monitor
- **WHEN** the actual p0 producer and consumer succeed in that order
- **THEN** the monitor changes Awaiting to Ready6 to Consumed with the actual qualified identity, while erasure equals base execution

#### Scenario: Refusal and overscheduling input
- **WHEN** a call refuses and then a failed or exhausted token is selected
- **THEN** the monitor receives the actual error once and none on skip, with no replayed prior receipt

#### Scenario: Arbitrary monitor entry and chunks
- **WHEN** a continuation starts with a populated monitor and machine
- **THEN** chunked replay retains the entry monitor and equals the unchunked deterministic fold

#### Scenario: Fixed-parameter common prefix
- **WHEN** two monitored runs use identical initial monitor/machine, update and static parameters, share a token prefix and differ only in later suffixes
- **THEN** their monitored states after that prefix are equal, without a claim about changed callbacks or externally prescient initial data

### Requirement: Noncircular causal induction

The causal rule SHALL expose initialized joint invariant, current assumption derivation, selected actual-success local guarantee, peer stability and actual monitor-update preservation separately, with explicit refusal/skip cases and present external premises; the concrete instance SHALL discharge them independently.

#### Scenario: Initialized budget derivation
- **WHEN** entry vault10 and framed budget6 establish reserve4 and the actual producer exports6
- **THEN** the Ready budget inequality follows from initialization and receipt provenance without assuming final reserve

#### Scenario: Peer-stable bound before consumption
- **WHEN** only authorized deposits1 and2 intervene between producer and consumer
- **THEN** the budget bound remains true and the consumer preserves reserve under actual execution

#### Scenario: Stale bound after interfering withdrawal
- **WHEN** an authorized peer withdraws3 after the producer and before consumer6
- **THEN** both calls succeed and final vault is1; the required stability assumption is explicitly false

### Requirement: Funded three-stream reserve and success

The concrete witness SHALL prove reserve at every prefix and actual success for every complete schedule of stream lengths2,1,1 using literal initial funds and guards; bounded schedule checks SHALL supplement, not replace, the generic and instantiated proofs.

#### Scenario: All twelve complete schedules
- **WHEN** the funded producer/consumer and two deposit streams run under each complete schedule
- **THEN** all streams succeed with final vault7, donors1 and1, recipient6 and budget6, exact fixed store and schedule-specific diagnostics

#### Scenario: Reserve at partial schedules
- **WHEN** any prefix of a complete witness schedule is selected
- **THEN** vault is at least4 and the monitor phase is justified by that actual prefix

#### Scenario: Independent receipt accounting
- **WHEN** the witness completes
- **THEN** the three transfers have exact signed effects and the producer has zero effect; receipts conserve the full ledger total

### Requirement: Qualified monitor provenance negatives

The witness monitor SHALL require the designated stream, operation, local index and qualified actual successful output before establishing its fact, and SHALL not reuse a consumed or absent fact.

#### Scenario: Refused producer has no fact
- **WHEN** p0 producer has a false financial guard
- **THEN** its actual refusal emits no output and the monitor remains Awaiting

#### Scenario: Other stream lookalike
- **WHEN** p1 successfully emits the same value and qualified output key while p0 has not produced
- **THEN** the p0 monitor remains Awaiting despite that actual successful peer output

#### Scenario: Consumed fact is not recreated by skip
- **WHEN** p0 producer and consumer finish and p0 is selected again
- **THEN** the monitor stays Consumed and the extra token supplies no attempt
