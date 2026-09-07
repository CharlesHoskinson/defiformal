## Purpose

Make parallel composition claims reviewable through complete scenario coverage, discriminating source mutations, exact proof scope and independently audited candidates.

## ADDED Requirements

### Requirement: Planning approval before implementation
The OpenSpec candidate SHALL receive independent Fable and GPT-6 audits before implementation begins. Both final verdicts SHALL cover the same committed candidate and be explicit passes with no blocking finding unresolved. Unavailable, timeout, malformed or error responses SHALL NOT count as passes. Advisory limitations SHALL NOT waive a normative requirement.

#### Scenario: Planning candidate passes
- **WHEN** both named reviewers pass the same candidate and all blocking findings are resolved
- **THEN** implementation may begin under the existing user authorization

#### Scenario: Reviewer unavailable or candidate revised
- **WHEN** a required planning reviewer is unavailable or the candidate changes substantively after its verdict
- **THEN** implementation remains gated until the missing or affected candidate audit passes

### Requirement: Complete reference comparisons
The sprint SHALL map every requirement/scenario to named proofs, full finite-world comparisons, compiler controls, or actual acceptance evidence. Financial and isolation negatives SHALL have funded/authorized compatible siblings. Counts SHALL distinguish mathematical proofs from bounded comparisons, counterexamples and measurements.

#### Scenario: Negative targets interference
- **WHEN** a fixture rejects a conflicting branch pair
- **THEN** a funded authorized underlying-executor control and compatible pair show rejection is caused by the intended compatibility condition

#### Scenario: Branch behavior inventory
- **WHEN** the suite runs
- **THEN** it compares complete ledgers/stores and all required canonical observation fields for success, independent refusal, output routing, boundary identity and supply scenarios

### Requirement: Real source mutations and robust controls
Required mutation classes SHALL cover conflict directions, hidden/output/target dependencies, peer cancellation, prefix rollback, lost/doubled merge state, output-history leakage, boundary-index misuse, omitted supplies, stale capability use, and incorrect state-dependent evaluation. Each counted detection SHALL apply a real implementation-source edit, compile and run the full nonempty named inventory, fail designated comparisons, and retain specified unrelated positive controls.

#### Scenario: Semantic detection
- **WHEN** a required mutant compiles and changes observable behavior
- **THEN** saved execution identifies its designated false comparison and surviving positives

#### Scenario: Invalid or vacuous run
- **WHEN** a mutant is missing, unapplied, noncompiling, surviving, or its check inventory is empty/partial/duplicated/malformed
- **THEN** the runner reports failure or blocked execution and never a semantic detection

#### Scenario: Redundant conflict guards
- **WHEN** one guard removal is masked by another required guard
- **THEN** the manifest explicitly uses a justified composite mutation or reports survival; a compile error is not substituted for detection

### Requirement: Integrated proof and regression audit
The sprint SHALL run the full Lean build, new runtime/imported-axiom audit, all existing kernel runtime and imported-axiom drivers, typed/compiler/mutation/runner/axiom controls and corpus regressions. Accepted imported proof code SHALL contain no sorry, custom axiom or native_decide. Original proof and corpus files SHALL remain byte-identical apart from explicitly authorized new import wiring.

#### Scenario: New proof enters import closure
- **WHEN** a new named theorem is counted
- **THEN** its statement and premises appear in the inventory and its declaration is covered by the fresh built imported axiom audit

#### Scenario: Historical regression or drift
- **WHEN** an existing test fails or a preserved file changes
- **THEN** acceptance is blocked until the cause is resolved and affected checks pass

### Requirement: Independent implementation review and delivery
The implemented source/evidence candidate SHALL receive native Grok/Fable review with exact requested/reported model identity and preserved findings. Executed inputs, reviewed bytes, tool versions and Git objects SHALL be bound by verifiable manifests. Delivery SHALL update the roadmap, verify the authorized branch push, archive this accepted OpenSpec change, and validate its synchronized main specs.

#### Scenario: Reviewed source changes
- **WHEN** implementation changes after review or execution began on a dirty predecessor
- **THEN** affected validation/review is refreshed and exact executed/reviewed bytes are compared to committed objects without relabeling original run heads

#### Scenario: Verified branch and archive
- **WHEN** all implementation acceptance checks pass
- **THEN** source/evidence and archive metadata are pushed to the authorized branch with verified remote heads; broader roadmap work stays open
