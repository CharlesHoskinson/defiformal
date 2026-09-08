## Purpose

Specify certificates, representation correspondence, source refinement, runtime adapters, environment evaluation, untouched holdouts, Atlas residuals, and the final paper and developer package.

## ADDED Requirements

### Requirement: Typed sequential certificates recompute judgments

`P19` SHALL implement a serialized module and transition format and a checker that recomputes typing, footprints, authority, accounting, and sequential composition by invoking actual delivered Lean entrypoints. Claimed judgment tags, theorem names, and envelope hashes MUST NOT be treated as proof. `P19` MAY be independently reviewed as an implementation candidate. It MUST NOT be labelled an accepted semantic certificate checker, and MUST NOT receive qualified certificate delivery, until `P20` proves quantified representation-to-Lean correspondence for that supported domain. The unaccepted candidate at `/home/charl/defiformal-wt-certificates-grok-gpt6-20260908/openspec/changes/serialized-kernel-certificates/` is a planning input, not an accepted gate.

#### Scenario: Tag does not skip Args.check
- **WHEN** a payload claims `TypeCorrect` and units mismatch
- **THEN** the checker still runs `Args.check` and reports the evaluation error

#### Scenario: Unsupported form is rejected
- **WHEN** a document contains a tree-join or Claims operator with a valid invoke rest
- **THEN** the result is `unsupportedForm`, not a complete certificate

#### Scenario: P19 is not qualified certificate delivery
- **WHEN** the `P19` checker implementation is independently reviewed
- **THEN** qualified certificate delivery and the accepted-semantic-checker label remain open until `P20` correspondence succeeds

### Requirement: Quantified representation correspondence, compatibility, and library instantiation

`P20` SHALL prove a quantified representation-to-Lean correspondence for the supported Typed/sequential certificate domain before qualified certificate delivery. `P20` SHALL check a declared nontrivial composition-compatibility operator by invoking delivered `DefiKernel.Parallel.admit` on the decoded catalog and branches, which recomputes footprints, or `checkCompatibility` on those recomputed footprints, and SHALL connect the result through `checkCompatibility_ok_iff`. `Parallel.Compatible` is a proof-level `Prop` after the proof marker in `lean/DefiKernel/Parallel/Compatibility.lean` and MUST NOT be treated as the executable checker. Caller-supplied footprint labels MUST NOT be accepted. The `Prop` MAY appear in a stated proof obligation once the executable check is connected. `P20` SHALL instantiate a real accepted library theorem through the checker with an actual Lean check rather than a supplied tag. Arbitrary undecidable `ComponentContract` propositions MUST remain unsupported and MUST NOT be counted as executable checks. Wider operator extensions MAY follow with a new correspondence result each. Quint abstractions, if introduced, MUST have the same correspondence obligation. Codec correctness MUST NOT close source refinement. R18 MUST NOT close on a checker that only labels compatibility and library instantiation unsupported.

#### Scenario: Bounded fixture is not universal correspondence
- **WHEN** finite fixtures F25/F27/F28 round-trip
- **THEN** they are bounded evidence and do not discharge the universal correspondence theorem

#### Scenario: Compatibility is actually checked
- **WHEN** a certificate payload claims two-branch compatibility
- **THEN** the checker invokes `Parallel.admit` or `checkCompatibility` on footprints it recomputed from the decoded catalog and branches, reports that `Except` result, and may use `checkCompatibility_ok_iff` in the proof; it MUST NOT treat `Parallel.Compatible` as an executable checker or accept caller-supplied footprint labels

#### Scenario: Library proof is Lean-checked
- **WHEN** a certificate names an accepted Arithmetic or later accepted token0 library theorem
- **THEN** the checker records an actual Lean instantiation check of that theorem and MUST NOT accept a theorem-name tag as LibraryTheoremsInstantiated

### Requirement: Reusable differential execution and selected source refinement

`P30` SHALL run identical generated sequences against pinned implementations and models for successful and refused behavior, detect characteristic mutations, and prove selected concrete implementation-to-model refinements. This sprint MUST remain required before full-program closure even if an earlier increment shipped with refinement open.

#### Scenario: Refinement still required
- **WHEN** P16 and P18 published model-verified bounded comparisons with refinement outstanding
- **THEN** `P30` remains unchecked and the program is not complete

### Requirement: Runtime adapters with readiness gates

`P31` SHALL add chain and runtime adapters only through verified interfaces. Moriarty, Compact, ZKIR, and proof-carrying-transaction integration MUST each have a named readiness task and a distinct named implementation-and-verification task with separate pin/interface and correspondence/real-execution gates. If a verified interface or source is unavailable, that adapter's implementation task SHALL stay `blocked_unavailable` and MUST NOT be marked complete by deferral. Proof-carrying-transaction work that consumes certificates SHALL depend on accepted `P20` correspondence. Unavailable adapters MUST stay off the early `P18` release and evaluation critical path. The 2026-09-06 source plan lines 1140–1142 are agenda input: no invented semantics.

#### Scenario: Missing Moriarty interface
- **WHEN** no verified Moriarty interface or source is supplied
- **THEN** Moriarty readiness records the gap, Moriarty implementation is blocked, kernel modules do not import imagined Moriarty APIs, and Compact, ZKIR, and PCT tasks keep their own independent status

#### Scenario: PCT after verified interface and correspondence
- **WHEN** a verified proof-carrying-transaction interface exists and is pinned and `P20` correspondence is accepted
- **THEN** PCT implementation may bind kernel certificates as a referenced obligation class without collapsing cryptographic, semantic, oracle, and legal evidence

#### Scenario: PCT without correspondence
- **WHEN** PCT is attempted before accepted `P20` correspondence
- **THEN** PCT implementation remains blocked on that correspondence and MUST NOT treat `P19` checker existence as sufficient

### Requirement: Environment pins and evaluations

`P32` SHALL pin implementations, versions, deployments, and relevant execution environments, covering EVM, Solana, Cosmos, Move/Sui, sovereign cross-chain, and payment-channel environments named in the 2026-09-06 source plan line 1116. Each environment MUST have a readiness record. `P34` SHALL run actual nonempty success and refusal execution per required environment against the frozen evaluated APIs. Unavailable toolchains or sources SHALL be blocked and MUST keep full evaluation open. EVM token0 evidence MUST NOT score other environments.

#### Scenario: EVM pin for token0
- **WHEN** Uniswap v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899` executes under a declared solc and EVM harness
- **THEN** that record counts as EVM environment evidence for the declared function, not as Solana, Cosmos, Move, sovereign, or payment-channel coverage

#### Scenario: Missing Move toolchain
- **WHEN** no pinned Move/Sui source and toolchain are available
- **THEN** Move/Sui evaluation is `blocked_unavailable`, MUST NOT inherit EVM scores, and `P34` successful exit remains open

#### Scenario: Per-environment execution
- **WHEN** a required environment has a pin and toolchain
- **THEN** `P34` records at least one nonempty success and one nonempty refusal execution in that environment against the frozen APIs

### Requirement: Kernel freeze and twelve-case replacement policy

`P33` SHALL freeze the actual declared evaluated kernel, schema, and library versions before untouched evaluation. The freeze set MUST be the APIs and libraries declared for that evaluation, not an unrelated whole backlog. The existing 75 candidates MUST remain development. Prior twelve REPORT labels are exposure records with original IDs unknown; they MUST NOT yield an untouched score. Replacement of contaminated cases SHALL follow an exposure-audited policy. Held assessment payloads MUST NOT be read during this program’s planning or during `P33` policy freeze. If a frozen evaluated kernel, schema, or library version later changes, prior untouched labels SHALL be invalidated for reuse; earlier runs MAY remain as separately labelled interim evidence bound to their original versions.

#### Scenario: Development case is not a holdout
- **WHEN** a candidate was used to design the kernel or appears on the prior-exposure ledger
- **THEN** it stays development and is ineligible as an untouched evaluation case

#### Scenario: Version change invalidates untouched reuse
- **WHEN** an evaluated library hash in the freeze set changes after `P34` scoring
- **THEN** those untouched labels MUST NOT be reused; the prior run remains interim evidence under its original freeze identity

### Requirement: Independent untouched evaluation and separated metrics

`P34` SHALL evaluate independently selected untouched cases after the freeze and SHALL report schema coverage, behavioral coverage, library reuse, new kernel concepts, new library templates, external assumptions, and verification effort as separate metrics. A new library function is not a kernel failure; a new state, effect, or composition concept required to encode a holdout is. Full evaluation remains open while any required environment lacks actual success/refusal execution.

#### Scenario: Separated metrics
- **WHEN** evaluation results are published
- **THEN** each metric has its own denominator and no single percentage is advertised as whole-program completion

### Requirement: Atlas candidate and residual interaction

`P35` SHALL independently review the Atlas accessibility candidate archive whose SHA-256 equals CURRENT.json lane `atlas.sha256` (`56c3a1d532669f229e9c67f7e25f3253bedabd9baad5ae4942f306ef9c487db6`). Historical checked boxes in `design-atlas-visualization/tasks.md` SHALL remain historical checkbox bytes and MUST NOT be treated as current acceptance. `P35` SHALL rebind actual DOM reading-order behavior (original 2.2), actual reduced-motion behavior (original 7.5), all nine accessible-name fields on rendered tiles (original 7.6), and per-element source/document sync, and SHALL complete residual keyboard traversal, search-list, badges, zoom, print, find-in-page, 200-percent zoom, reduced motion, readability, screenshot, README, and open-question obligations (7.4, 8.2, 8.3, 8.4 plus CURRENT residuals). Current layout MUST preserve the later authorized Flat/3D and depth/family views; the original 3D ban and 16×5 matrix MUST NOT be revived as the current contract.

#### Scenario: Author 238 checks
- **WHEN** the Atlas candidate reports 238 author checks
- **THEN** independent review of the exact candidate is still required and new scientific features stay parked until schema stability

#### Scenario: Historical Atlas checkboxes are not current acceptance
- **WHEN** original tasks 2.2, 7.5, or 7.6 are historically checked
- **THEN** `P35` still requires actual DOM reading-order, executed reduced-motion, and nine-field accessible-name evidence on the current Flat/3D depth/family layouts

#### Scenario: Authorized 3D is preserved
- **WHEN** current `viz/` imports Scene3D under the recorded client directive
- **THEN** `P35` preserves Flat/3D and depth/family layouts and MUST NOT restore the original 3D ban or 16×5 matrix as the current contract

### Requirement: Scientific Atlas and graph after stable schema

`P36` SHALL update the ontology visualization and repository graph after the accepted schema stabilizes, without implying periodic-law predictive power. `P36` MUST depend on accepted residual Atlas work and on a stable schema from accepted platform results.

#### Scenario: Mapping statement remains visible
- **WHEN** the scientific refresh ships
- **THEN** every layout header retains the mapping statement and missing-denominator mark for incomplete evidence

### Requirement: Paper and external developer package

`P37` successful exit SHALL require every required program outcome independently accepted and delivered, including selected source refinement (`P30`). An honest partial paper MAY exist earlier and MUST NOT close `P37`. Remaining blocked or rejected work SHALL be listed and SHALL keep full-program completion open. Delivery SHALL be to `semantic-kernel-pivot` only and MUST NOT merge to `main`.

#### Scenario: Developer package instantiates an accepted library
- **WHEN** an external-developer package is published
- **THEN** it instantiates an accepted financial library and executor interface, states a meaningful financial predicate, binds a pinned implementation, and shows proved, measured, and assumed obligations exactly

#### Scenario: Partial paper does not close P37
- **WHEN** a paper describes accepted `P16` results while required families, evaluation, or refinement remain undelivered
- **THEN** that paper is a partial artifact and `P37` remains open
