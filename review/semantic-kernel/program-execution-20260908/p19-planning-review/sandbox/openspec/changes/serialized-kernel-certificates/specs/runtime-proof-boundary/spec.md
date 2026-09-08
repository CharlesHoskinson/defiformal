## Purpose

Separates executable certificate judgments from registry, context, observation and environment trust and from Lean proof obligations that require actual object and statement identity.

## ADDED Requirements

### Requirement: PB01 Arbitrary propositions are not executable certificates

`ComponentContract` fields `initial`, `assumes`, `invariant` and `guarantees` SHALL remain proof-level `Prop`. Serializing them as strings, JSON, or tags SHALL NOT make them decidable or accepted. `ContractObligations` SHALL require an actual Lean proof term of that structure.

#### Scenario: S49 Contract propositions do not pass the checker

- **WHEN** a module copies `Composition.Examples.collateralContract` as `"invariant": "10 ≤ collateral"`
- **THEN** the checker classifies the field as an outstanding proof obligation and the executable certificate is not complete by that field.

#### Scenario: S50 Contract obligations need a Lean proof object

- **WHEN** a certificate names `"ContractObligations collateralContract"` without a recorded theorem identity in an imported module
- **THEN** the obligation remains outstanding; the string does not discharge it.

### Requirement: PB02 Registry context observation and environment trust

Registry contents, domain-admin lookup, invocation-context authenticity, observation truth and replay prevention SHALL be declared trust or assumptions, not proved by this increment. Missing or wrong-unit observations SHALL still be executable `missingObservation` / `observationUnit` refusals. Treating missing observations as zero SHALL be forbidden.

#### Scenario: S51 Registry authenticity is an assumption

- **WHEN** a complete increment certificate is reported
- **THEN** `AssumptionsDeclared` includes registry-trust and does not claim the registry was authenticated.

#### Scenario: S52 Observation truth is adapter-supplied

- **WHEN** an environment maps price key 7 to USD 3 at timestamp 10
- **THEN** the checker uses that value if present and records observation-truth as an assumption, not a proved market fact.

#### Scenario: S53 Missing observation is executable refusal

- **WHEN** borrow-style code observes a key absent from the environment
- **THEN** the checker reports `evaluation missingObservation` and does not substitute 0.

### Requirement: PB03 Assumptions are classified not discharged

AssumptionsDeclared SHALL mean every required assumption class is present and labelled. The six classes are registry-trust, administrator-trust, context-authenticity, observation-truth, environment-authenticity and replay-prevention-outside-model. Environment-authenticity is a named class, not subsumed by observation-truth. Presence SHALL NOT imply truth. Omitting a required class SHALL make the certificate incomplete.

#### Scenario: S54 Listed assumptions are classified

- **WHEN** F25 includes the six trust classes
- **THEN** AssumptionsDeclared is recorded as classified, not as proved.

#### Scenario: S55 Missing assumption class is incomplete

- **WHEN** F41 omits environment-authenticity
- **THEN** the certificate is incomplete for the increment, not accepted.

### Requirement: PB04 Library theorems and source maps do not auto-pass

LibraryTheoremsInstantiated SHALL require the actual Lean theorem name, module, statement identity and a recorded compiler check. SourceRefinementObligations SHALL record `source_map` pins and remain outstanding for deployed or Quint fidelity. Existing Arithmetic and Atomic theorems SHALL NOT be reused as new certificate acceptance.

#### Scenario: S56 Library field without compiler check is outstanding

- **WHEN** `"libraries": [{"theorem": "applyEvaluated_accounting", "module": "DefiKernel.Typed.Transition"}]` has no recorded Lean check in this increment's evidence
- **THEN** the obligation is outstanding even though that theorem exists in delivered source.

#### Scenario: S57 Source map is not deployed fidelity

- **WHEN** `source_map` points at `Typed/Examples.lean` transfer
- **THEN** the checker records a development correspondence pin and does not claim ERC-20 or deployed-contract refinement.

### Requirement: PB05 Declared audit roots only

Axiom audit SHALL run `#audit_axioms` on each declaring-module prefix `DefiKernel.Certificates`, `DefiKernel.Typed` and `DefiKernel.Composition`. Transitive import of Typed from Certificates SHALL NOT substitute for the Typed prefix command. Correspondence and Soundness proof modules SHALL be in the Certificates prefix. Unimported Arithmetic, Atomic, Nary, Claims, Tree and repository-wide modules SHALL NOT be claimed covered. Empty imported theorem scope SHALL be blocked.

#### Scenario: S58 Declared prefixes are audited separately

- **WHEN** implementation later runs the three `#audit_axioms` commands
- **THEN** each prefix reports a nonempty imported theorem inventory or is blocked, and Certificates includes Correspondence/Soundness/Verify.

#### Scenario: S59 Unimported modules are not claimed covered

- **WHEN** this increment's audit-root list is inspected
- **THEN** it names Typed Types/Expr/Authority/Transition and Composition Interfaces/Execution/Contracts/Sequence plus proposed Certificates modules, and does not include unimported Nary/Claims/Arithmetic as covered certificate roots.

#### Scenario: S60 Empty imported theorem scope is blocked

- **WHEN** an audit command would observe zero imported theorems
- **THEN** the result is blocked, never `0 of 0` pass.
