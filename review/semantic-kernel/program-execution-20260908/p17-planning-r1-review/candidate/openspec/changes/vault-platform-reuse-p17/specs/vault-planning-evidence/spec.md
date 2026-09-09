## Purpose

Record the P17 planning-review gate, nonempty structural controls, P16 preservation, and remaining obligations so this slice cannot be mistaken for reuse acceptance or production mutation credit.

## ADDED Requirements

### Requirement: Gate accepted stays false until independent GPT-6 review

This author package SHALL keep `gate_accepted=false`, `independent_acceptance=false`, and `P17.platform_reuse=false`. Independent GPT-6 MUST record verdict, requested/reported model identity, and input hashes on these exact bytes. Author diagnostics are not that review. Frozen program tasks 18.1–18.7 SHALL NOT be ticked here.

#### Scenario: Author freeze is not self-acceptance
- **WHEN** this planning package is completed
- **THEN** result.json status is `pending_independent_gpt6_review` and no frozen program task checkbox is ticked

### Requirement: P16 observations and fail-closed behavior are preserved

Future implementation SHALL preserve P16's accepted semantic observations and repaired fail-closed gate behavior. This slice SHALL NOT assume the P16 source gate is closed. Semantic success SHALL require child 0, wrapper 0, classification `ok`, complete protocol, and actual Lean comparison truth. Missing/malformed receipts SHALL be setup-blocked. Compiler failure with partial rows and malformed extra protocol rows SHALL be blocked, not success. Child 1/timeout/crash alone SHALL NOT be mutation detection.

#### Scenario: P16 source gate remains independent
- **WHEN** this P17 planning slice is accepted
- **THEN** P16 source-consumer R1/R2 repairs remain their own gate and P17.platform_reuse stays false until the reuse experiment is implemented and independently accepted

### Requirement: Inventories are nonempty and class-separated

Fixture, mutation, proof, and remaining-gate inventories SHALL name nonempty partitions, designated witnesses, independent unaffected controls, a source-independent mint-without-asset-credit negative, and obligation classes. Planning validation and OpenSpec structural controls SHALL NOT be scored as production mutation credit. Empty fixture or mutation inventories SHALL be blocked (exit 3).

#### Scenario: Empty fixture inventory is blocked
- **WHEN** diagnose.py is run with `--empty-corpus`
- **THEN** the process exits 3 and production_mutation_credit remains 0

#### Scenario: Characteristic mutant has an unaffected control
- **WHEN** mutant V-TF-SKIP is planned
- **THEN** designated false is P17-DEP-D0 and P17-RED-D0 plus P17-DEP-BAD-RECV remain independent unaffected controls

### Requirement: P21 and P30 stay closed for this increment

This slice SHALL NOT start P21 residual liquidity work, SHALL NOT access held/untouched payloads, and SHALL NOT claim P30 source refinement. Arithmetic-only reuse MAY later be published without opening wider-family spending.

#### Scenario: Wider families remain gated
- **WHEN** this planning package is frozen
- **THEN** remaining-gates.json records P21 resource-gated by unimplemented `P17.platform_reuse` and P30 source refinement open
