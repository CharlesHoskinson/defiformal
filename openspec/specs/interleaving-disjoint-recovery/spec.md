# interleaving-disjoint-recovery Specification

## Purpose
Relate shared execution to accepted disjoint parallel semantics without equating order-sensitive shared-state outcomes.

## Requirements

### Requirement: Universal disjoint recovery

For every pair admitted by existing disjoint parallel admission and every complete finite schedule, the named canonical projection of shared execution SHALL equal the existing parallel observation, including exact refusals and retained prefixes. The theorem SHALL derive this result from dependency/frame proofs rather than assume commutation or success-only premises.

#### Scenario: All disjoint schedules

- **WHEN** any complete schedule interleaves structurally accepted branches with compatible footprints
- **THEN** the generic theorem identifies its complete canonical observation with the existing parallel and LR/RL reference observations

#### Scenario: Disjoint refusal

- **WHEN** one disjoint branch refuses in the middle while its peer continues
- **THEN** recovery preserves the same local failure, own successful prefix and complete peer outcome

#### Scenario: Six concrete schedules

- **WHEN** two disjoint branches each have two invocations
- **THEN** all six complete schedules also match independent expected worlds and canonical branch observations in bounded execution

### Requirement: Empty and serial specializations

The system SHALL prove empty/one-empty identity laws and full-block LR/RL schedule correspondence under the same admission and canonical-observation boundaries. It SHALL retain concrete counterexamples to arbitrary shared-state schedule equivalence.

#### Scenario: Empty peer

- **WHEN** one branch is empty and the other succeeds or refuses
- **THEN** the shared observation agrees with its existing sequential branch behavior and empty peer observation

#### Scenario: Full-block schedules

- **WHEN** all left tokens precede all right tokens or vice versa for a disjoint pair
- **THEN** the canonical result equals the corresponding existing real serial evaluator

#### Scenario: Order-sensitive shared state

- **WHEN** two withdrawals compete for insufficient combined liquidity
- **THEN** LR and RL have different independently checked successful/refused branches, so unrestricted equivalence is refuted
