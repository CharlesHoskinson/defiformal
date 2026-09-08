## Purpose

Freeze the minimum shared kernel, library, adapter, and evidence contracts needed by the first two source-bound cases and later family reuse.

## ADDED Requirements

### Requirement: Kernel and operator boundary

The shared platform contract SHALL name the delivered kernel and operator version, typed operation boundary, dimensions, roles, effects, supply, access, and exact refusal order actually used by the next cases. The contract MUST use delivered APIs and MUST NOT invent undeclared operator fields.

#### Scenario: Delivered sequential refusal order
- **WHEN** a library adapter wraps sequential composition
- **THEN** successful prefixes are retained and execution stops at the first refusal using the accepted sequential contract

#### Scenario: No invented ledger history
- **WHEN** the selected operation is a pure next-price function
- **THEN** the adapter observation omits fabricated ledger history and records only the declared inputs, outputs, and refusals

### Requirement: Library amount, rounding, and error contract

Shared library arithmetic SHALL make machine width, overflow, wrapping versus checked failure, rounding direction, and fee predicates explicit. Unbounded mathematical addition MUST NOT silently replace a source wrapped-sum fallback when that fallback is in the declared observation.

#### Scenario: Token0 denominator-sum overflow
- **WHEN** token0 next-price inputs overflow the uint256 denominator sum while the product fits
- **THEN** the `P16` library observation matches the pinned Solidity 0.7.6 wrapped-sum fallback on that required branch; the branch MUST be exercised and MUST NOT be excluded to pass

### Requirement: Adapter input and output relation

Each selected operation SHALL publish a pre-state/input to post-state/output relation, including refusal constructors. Protocol-specific adapters and local proofs are permitted. A new global induction, cloned dispatcher, or case-specific checker exemption MUST block an unchanged-interface reuse claim.

#### Scenario: Local adapter is not a reuse failure
- **WHEN** the vault case adds a protocol-specific share-rounding adapter and a local proof
- **THEN** reuse remains eligible if a named shared library lemma or financial contract and an executor or composition theorem are instantiated unchanged

### Requirement: Common evidence packet

Every credited operation SHALL bind exact source, model, and tool identities; supported input/state/observation relation; relevant Lean theorem, premise, and axiom evidence; actual pinned-source and model executions over predeclared nonempty partitions including refusals; actual characteristic mutations with unaffected controls; and an independent verdict with remaining obligations.

#### Scenario: Missing pin identity
- **WHEN** an evidence packet names a Uniswap function without compiler settings, source revision, and observation relation
- **THEN** the packet is incomplete and MUST NOT be scored as source-bound evidence

### Requirement: Obligation classes remain separate

The platform SHALL classify each obligation as model proof, bounded source execution, representation correspondence, source refinement, or authenticity/environment assumption. An increment MAY ship as model-verified with bounded source differential evidence and source refinement open. A later selected refinement sprint MUST still occur before full-program closure.

#### Scenario: Bounded increment with refinement open
- **WHEN** P16 token0 model proofs and bounded Solidity comparisons pass and source refinement is not proved
- **THEN** the increment may publish those two classes and MUST keep source refinement outstanding

#### Scenario: Codec does not close refinement
- **WHEN** certificate encode/decode correspondence is proved for Typed sequential IR
- **THEN** pinned-source refinement over related admissible Solidity states remains a separate open obligation

### Requirement: Two-case substantive reuse gate

Wider financial families SHALL be resource-gated by a measured reuse result from the Uniswap token0 case and one contrasting stateful vault case, not by an arbitrary serial backlog. Arithmetic-only `P16`/`P18` delivery MAY omit a Typed wrapper. The stronger platform resource gate MUST require the token0 library-to-kernel bridge and both case adapters checked against the same named executor result. A theorem used only by the vault MUST NOT discharge that executor result. If the two operations do not financially compose, the report MUST claim the narrower interface or library reuse rather than invent a workflow. Narrow arithmetic-only reuse MAY be published while the stronger gate remains open.

#### Scenario: Second AMM is not the contrasting case
- **WHEN** a nearby AMM formula is available and no vault pin exists
- **THEN** the vault case remains blocked on source readiness and MUST NOT be replaced by a second AMM to keep a pass

#### Scenario: Invented composition is refused
- **WHEN** token0 next-price and vault deposit have no financially meaningful sequential composition
- **THEN** the reuse report records library and interface reuse only and MUST NOT add a fake two-operation workflow

#### Scenario: Arithmetic reuse does not close the platform gate
- **WHEN** only arithmetic lemmas are shared and the token0 kernel bridge is absent
- **THEN** that narrower reuse MAY be published and the `P17`/`P21`–`P29` platform resource gate MUST remain open

### Requirement: No whole-backlog prerequisite

Minimum-contract freeze and first library source-readiness SHALL proceed without requiring the entire review backlog, full M4 completion, or certificate implementation. Certificates, if later delivered, MUST first accept the repaired Typed/sequential grammar; a caller-supplied judgment, source hash, or theorem name is not proof.

#### Scenario: Source readiness during M4 review
- **WHEN** M4 recovery review is open
- **THEN** Uniswap pin verification and overflow-oracle repair MAY start as independent P16 entry work
