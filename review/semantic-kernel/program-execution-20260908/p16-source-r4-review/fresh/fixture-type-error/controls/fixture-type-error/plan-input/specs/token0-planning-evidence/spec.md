## Purpose

Record the P16 planning-review gate, original-ID contribution limits, inventory/axiom checks, and remaining obligations so this slice cannot be mistaken for whole-library acceptance.

## ADDED Requirements

### Requirement: Gate accepted stays false until independent GPT-6 review

This author package SHALL keep `gate_accepted=false` and `independent_acceptance=false`. Independent GPT-6 MUST record verdict, requested/reported model identity, and input hashes on these exact bytes. Author diagnostics are not that review.

#### Scenario: Author freeze is not self-acceptance
- **WHEN** this planning package is completed
- **THEN** result.json status is `pending_independent_gpt6_review` and no frozen program task checkbox is ticked

### Requirement: Original 1.2 is only a P16 planning contribution

Independent review of this repaired token0 slice is the P16 contribution to original 1.2. Whole original 1.2 stays open until the P21 residual-slice planning review is also independently accepted. P16 implementation MUST NOT wait on P21.

#### Scenario: Mixed original IDs remain open
- **WHEN** this P16 planning slice is accepted
- **THEN** original TickMath 3.x, SwapMath 4.2, token1/delta residual 4.1, bitmap/liquidity/factory 5.x, original 2.1 signed/tick/fee/F45 residual, the 45-fixture campaign, compiled M01–M12 including M09 execution, and full traversal remain P21 and MUST NOT be marked done

### Requirement: Original 2.1 signed residual stays P21

P16 Types SHALL include only unsigned aliases, Q96, and failures needed by token0/FullMath. Signed, tick, fee, and F45 constructors from original mixed task 2.1 SHALL remain a P21 residual. Historical original tasks MUST NOT be ticked or edited to appear complete.

#### Scenario: Unused Signed is not a P16 API
- **WHEN** P16 Types are planned
- **THEN** Signed is not declared and the original 2.1 signed/tick/fee/F45 portion is named as P21 remaining work

### Requirement: Inventories are nonempty and class-separated

Fixture, mutation, proof, and remaining-gate inventories SHALL name nonempty partitions, designated witnesses, axiom/inventory checks, and obligation classes (model proof, bounded source execution, representation correspondence, source refinement, authenticity/environment). Gaps MUST NOT be hidden behind the Python oracle or a meta-validator.

#### Scenario: Unexecuted solc path is incomplete, not a pass
- **WHEN** compiler/EVM identities are frozen but not run
- **THEN** bounded-source-execution denominators stay at zero actual runs and credit_eligible remains false

### Requirement: FullMath substrate is in P16; assembly identity is not

Original 1.3 (pin/Arithmetic re-bind) and 2.2–2.3 (FullMath wrap of `Rounding.mulDiv` at width 256 with success/refusal proofs) SHALL be P16 substrate required by token0. Assembly FullMath identity remains named gap `G-FULLMATH-ASSEMBLY` / P21 remainder.

#### Scenario: FullMath fixtures F01–F09 are substrate, not the 45-fixture campaign
- **WHEN** P16 implements FullMath
- **THEN** F01–F09 are evaluated as token0 substrate and original 6.1's remaining fixtures stay P21
