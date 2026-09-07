# interleaving-regression-evidence Specification

## Purpose
Bind shared-state proof and runtime claims to nonempty discriminating evidence, exact source revisions and independent reviews.

## Requirements

### Requirement: Independent financial evidence

Reference workflows SHALL check independent complete expected worlds/stores, receipts, outputs and exact failures. Evidence SHALL cover competing liquidity, replenishment, live reads versus snapshots, qualified local history, boundary identity, prefix refusal, supply, protected state, unauthorized/revoked capabilities and disjoint schedules. Development examples SHALL remain labeled as such.

#### Scenario: Full financial oracle

- **WHEN** all required example families run against the frozen source
- **THEN** every named comparison executes, full worlds/stores and intended errors match independent expected values, and the nonempty unique inventory is saved

#### Scenario: Live versus frozen values

- **WHEN** a peer changes shared state between a producer and a consumer
- **THEN** independent expected values distinguish current-ledger evaluation from own prior snapshots

### Requirement: Production mutation sensitivity

Fourteen semantic source mutations specified in the design SHALL compile and execute through the real production runner and complete named runtime inventory. Each SHALL cause its designated false comparison while protected positives remain true. Empty, partial, malformed, duplicate or unknown inventories, compile-only failures, no-op edits and survivors SHALL fail or block explicitly without being counted as detections.

#### Scenario: Semantic mutation

- **WHEN** each required production mutation is run in a fresh isolated projection
- **THEN** its actual edit, compile/run logs, designated failure and protected positives are saved with exact source and artifact hashes

#### Scenario: Runner controls

- **WHEN** actual runner CLI calls encounter empty/partial/duplicate/unknown results, missing/nonunique/no-op edits, compile failures, survivors, failed positives or unsafe output locations
- **THEN** each rejects for its intended diagnostic beside a valid accepted control

#### Scenario: Source drift

- **WHEN** an input differs from the frozen candidate or changes during execution
- **THEN** evidence blocks instead of attributing results to the wrong revision

### Requirement: Proof inventory and regression integrity

The sprint SHALL retain automatic imported theorem and supplemental declaration axiom audits, allowing no sorry, custom axioms or native_decide in accepted kernel proofs. Named inventories SHALL distinguish generic proofs, concrete instances, counterexamples, generated declarations and runtime checks. Existing kernel, corpus, compiler, mutation and runner regressions SHALL pass on the accepted source with historical bytes preserved.

#### Scenario: Imported proof coverage

- **WHEN** the full build and new verification root run
- **THEN** every in-scope imported declaration is inventoried with zero forbidden dependencies and named theorem premises are recorded

#### Scenario: Legacy preservation

- **WHEN** the current source is compared with the base and full legacy checks run
- **THEN** historical source/corpus bytes are unchanged apart from the declared import-root/documentation updates, and fresh command exits/logs are retained

### Requirement: Planning implementation and delivery gates

Implementation SHALL begin only after independent GPT-6 and native Fable planning reviews pass on the same frozen candidate and a current baseline passes. Substantive results SHALL receive native Grok and Fable reviews with exact requested/reported models, source identity, findings and fixes. An unavailable or incomplete review SHALL remain open. Stock Codex SHALL implement using GPT-6 without Foreman. Wiki notes SHALL record decision summaries and links without presenting plans as proved results. Archive SHALL require all tasks and acceptance gates complete.

#### Scenario: Planning gate

- **WHEN** candidate specs, design and tasks are frozen and both required reviewers pass
- **THEN** the recorded gate authorizes the already approved implementation; schema completeness alone does not authorize it

#### Scenario: Unavailable reviewer

- **WHEN** a native provider returns no substantive verdict or reports unavailable credits
- **THEN** the review remains open and dependent implementation or final acceptance does not proceed

#### Scenario: Accepted delivery

- **WHEN** proofs, execution, mutations, full regressions and native implementation audits pass with findings resolved
- **THEN** roadmap/wiki and task states reflect actual evidence, the branch is pushed and verified, and only this completed OpenSpec change is archived
