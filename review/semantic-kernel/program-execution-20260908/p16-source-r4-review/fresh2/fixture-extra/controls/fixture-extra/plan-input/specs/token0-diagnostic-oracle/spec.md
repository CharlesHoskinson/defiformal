## Purpose

Repair a new copy of the Python diagnostic oracle for the Solidity 0.7.6 wrapped denominator sum, keep the defective oracle as a disagreement witness, and require independently computed expected arithmetic on nonempty partitions.

## ADDED Requirements

### Requirement: New oracle copy models wrapped uint256 addition

A new Python copy SHALL compute `wrapped_denom = (numerator1 + product) % 2^256` and take the source fallback when `wrapped_denom < numerator1`. The historical defective oracle SHA-256 `4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd` SHALL be preserved unchanged as a witness. Python is not pinned-source execution.

#### Scenario: Wrap case disagrees with the defective oracle
- **WHEN** the required MAX_SQRT_RATIO−1 wrap vector is evaluated on both copies
- **THEN** the repaired copy matches the independently computed fallback value and the defective copy returns a different unbounded-mulDiv value

### Requirement: Independent expected arithmetic is not the oracle output

Diagnostic expected values SHALL be computed from the source-shaped formulae (identity; ceil of primary mulDiv; ceil of fallback division; require) without reading the repaired oracle's return as the expected value.

#### Scenario: Identity, add, require, and wrap have independent literals
- **WHEN** `(2^96,1,0,*)`, `(2^96,1,1,true)`, `(2^96,1,1,false)`, and the wrap vector are checked
- **THEN** each expected value is produced by those formulae and compared to the repaired oracle, with a nonempty case denominator

### Requirement: Wrap premise is not automatic disagreement

A wrap-premise vector whose unbounded mulDiv coincides with the fallback formula SHALL be recorded as a finding, not used as the discriminating wrap witness.

#### Scenario: Q96 max-liquidity wrap coincides
- **WHEN** `(2^96, max uint128, 2^160-2^128+2, true)` is evaluated
- **THEN** both oracles may agree at `2^64` and that fact is preserved; discrimination uses the MAX_SQRT_RATIO−1 vector instead

### Requirement: Empty diagnostic corpus is blocked

A zero-case run SHALL exit 3, not 0.

#### Scenario: Empty-corpus flag
- **WHEN** the diagnostic runner is invoked with `--empty-corpus`
- **THEN** it prints a blocked empty-denominator message and exits 3

### Requirement: r2 supplement does not rewrite r1 diagnostics

A later planning repair SHALL add new witness and mutant source-shaped arithmetic in a new evidence directory. The r1 `diagnose.py`, repaired oracle, logs, compiler catalog, defective oracle, and extracted original inputs MUST remain byte-identical. Replaying r1 `diagnose.py` SHALL redirect its `logs/diagnose.json` write into the new evidence and disable bytecode writes.

#### Scenario: Empty r2 scoring path is blocked
- **WHEN** the r2 supplement is invoked with `--empty-corpus`
- **THEN** it exits 3 with a nonempty blocked message and denominator 0
