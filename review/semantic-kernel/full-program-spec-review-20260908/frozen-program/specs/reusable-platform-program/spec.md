## Purpose

Define the remaining FormalDeFi program as a reusable verification platform: sprint gates, evidence classes, independent acceptance, honest blocked work, and delivery limits.

## ADDED Requirements

### Requirement: Whole-program definition of done

Full-program completion (`P37` successful exit) SHALL require every required sprint outcome independently accepted and delivered. Named blocked, rejected, or repair dispositions SHALL be honest reporting and MUST NOT be an alternative completion path. Supported-domain interim releases MAY publish accepted subsets with remaining required work still open.

#### Scenario: Blocked adapter is not completion
- **WHEN** Moriarty, Compact, ZKIR, or proof-carrying-transaction source or interface evidence is unavailable
- **THEN** the corresponding implementation task records `blocked_unavailable` with the missing artifact identity, that required outcome stays undelivered, and full-program completion remains open

#### Scenario: Supported-domain interim release
- **WHEN** a delivery report claims a bounded platform increment
- **THEN** it names the accepted library operations, composition theorems, source pins, obligation classes, and remaining required gaps, and MUST NOT mark `P37` complete

#### Scenario: Partial paper is not P37
- **WHEN** an honest paper draft describes accepted `P16` results while Curve or evaluation remain open
- **THEN** that draft is a partial publication artifact and MUST NOT close `P37`

### Requirement: Sprint unit contract

Every program sprint `P01`–`P37` SHALL declare dependencies, proposed and existing output paths, an interface or claim boundary, concrete tasks, nonempty success and refusal inventories, independent acceptance, a delivery gate, and stop or repair conditions. Sprint identifiers MUST be the stable `Pnn` series and MUST remain distinct from historical `Sprint12/M4`, `Sprint13/M5`, and `Sprint14/M6` labels, which stay discoverable as legacy mappings.

#### Scenario: Historical labels stay linked
- **WHEN** a reader follows M4 tree-regrouping work
- **THEN** `P01` and `P02` cite `openspec/changes/operational-tree-regrouping/` and original task IDs `1.1`–`7.5` with an explicit carried-acceptance, required-rebind, or remaining-work disposition, without renaming those tasks delivered

#### Scenario: Missing inventories block acceptance
- **WHEN** a candidate reports success with an empty positive or empty negative inventory
- **THEN** the check is blocked (exit 3), not a passing property

### Requirement: Evidence class separation

Accepted evidence SHALL distinguish model proof, bounded source execution, measurement, representation correspondence, source refinement, and explicit external assumptions. A codec-to-Lean theorem MUST NOT discharge source refinement. Compiler, runtime, authenticity, oracle, custody, legal, and environment-truth assumptions MUST remain explicit where unproved.

#### Scenario: Certificate success is not source fidelity
- **WHEN** a serialized checker agrees with `Composition.executeStep` on a supported IR
- **THEN** source-refinement and authenticity obligations remain outstanding unless separately discharged

#### Scenario: Python transcription is not pinned execution
- **WHEN** a Uniswap token0 comparison uses only an in-memory Python oracle
- **THEN** the result is diagnostic third-implementation evidence and MUST NOT receive production source-execution credit

### Requirement: Independent acceptance versus author exit

Author completion SHALL NOT constitute independent acceptance. Initial execution SHALL use one native Grok 4.6 author and one independent GPT-6 checker. One review plus one targeted rereview is the default; further rounds MUST require a concrete unresolved finding. Exact frozen input, model, and tool identities MUST be recorded, including requested versus reported model identity.

#### Scenario: Author exit without checker
- **WHEN** a native author session ends with `end_turn` and a source archive
- **THEN** the candidate remains unaccepted until independent GPT-6 review of those exact bytes records a verdict

#### Scenario: Unavailable checker
- **WHEN** the independent checker is unavailable or returns a tool-only failure
- **THEN** the planning or evidence gate stays open and is not an approval

### Requirement: Applicable evidence, not blanket expensive gates

Evidence obligations SHALL match the sprint class. Semantic, proof, or behavior changes SHALL supply the relevant proof, execution, or mutation evidence. Scoped candidate review MAY reuse exact-bound inventories. Record-only, freeze, documentation, and publication edits SHALL require integrity, link, and claim checks rather than a new full Lean or mutation campaign. When mutations apply they MUST exercise actual production code, with compilation for compiled languages and real execution for interpreted scripts. Bounded `P01` recovery review MUST NOT inherit the full M4 eighteen-mutant fixture campaign.

#### Scenario: P01 does not run P02 mutants
- **WHEN** `P01` reviews generic recovery theorems with meaningful success and refusal witnesses
- **THEN** exhaustive F01–F20, ninety-schedule, and eighteen-mutant campaigns remain `P02` and are not required for `P01` successful exit

### Requirement: Mutation and gate honesty

Where mutations apply, production mutation credit SHALL require an actual production mutant, a designated changed observation, and a separately verified unaffected control. Timeouts, setup failures, and compile errors MUST be classified blocked, not detected mutations. Gate exit codes MUST be `0` holds over a nonempty corpus, `1` property false, and `3` check could not run.

#### Scenario: Compile failure is blocked
- **WHEN** a planned mutant fails to compile
- **THEN** the record is blocked and MUST NOT increment detected-mutation counts

#### Scenario: Affected control invalidates the mutant
- **WHEN** M09 flips a direction predicate and protected F28 amountIn changes from 2 to 1
- **THEN** F28 is not an unaffected control and the mutation plan MUST be repaired before scoring

### Requirement: Proof inventory completeness

Accepted kernel proofs SHALL include complete statements, premises, and transitive axiom inventories, with no `sorry`, custom axioms, or `native_decide`. Changed modules plus affected consumers MUST be checked; exact unchanged-dependency reuse is allowed. Historical theorem statements MUST NOT be edited to make a new claim pass.

#### Scenario: Forbidden proof dependency
- **WHEN** an imported audit finds `sorry`, a custom axiom, or `native_decide` in accepted new proofs
- **THEN** the proof gate fails and the candidate is not accepted

### Requirement: Delivery boundary

Accepted work SHALL integrate only through parent-owned commit, push, and readback to `semantic-kernel-pivot`. Delivery MUST NOT merge to `main`. This planning change MUST NOT execute sprints or lift the strategy-audit dispatch hold.

#### Scenario: Planning files do not dispatch
- **WHEN** this OpenSpec change exists and validates
- **THEN** no implementation worktree is started and CURRENT.json dispatch hold remains a root-owned routing fact

### Requirement: Evidence-based cleanup

Cleanup SHALL require exact consumer, root, build, or CLI evidence and MUST be reversible. Graph isolation or a suggestive filename MUST NOT justify deletion. Historical proofs, negative results, partials, unique unintegrated candidates, and dirty worktrees SHALL be preserved.

#### Scenario: Graph orphan is not dead code
- **WHEN** a standalone Lean root has no incoming graph edges
- **THEN** the file is retained unless a consumer, build, or CLI check proves it unused

### Requirement: Successful exit is not terminal disposition

Every sprint SHALL distinguish `successful_exit` (required outcomes independently accepted and delivered), `partial_delivery` (a coherent accepted subset with named remainder still open), and `terminal_disposition` (rejected, repair-required, or blocked attempt). Rejection or a recorded repair MUST NOT by itself deliver the required outcome. A rejected candidate MAY be replaced; the sprint stays open until successful exit or the required outcome is otherwise delivered.

#### Scenario: Rejected reporting candidate
- **WHEN** independent review rejects the `P13` 210/0 archive
- **THEN** that archive is a terminal attempt disposition, R43 and R44 remain open under `P13`, and no other sprint is assigned those items

### Requirement: Historical baseline is not redone

Accepted Sprints 1–11 and checked integer arithmetic SHALL remain the completed baseline. This program MUST NOT reopen those accepted theorem statements as new work except to reuse their exact delivered APIs.

#### Scenario: Sprint 11 reuse
- **WHEN** M4 recovery review needs finite-participant APIs
- **THEN** it binds delivered Sprint 11 source `94f70e502c75132656bd0902a17be60ca45ab1c2` rather than reimplementing finite Nary
