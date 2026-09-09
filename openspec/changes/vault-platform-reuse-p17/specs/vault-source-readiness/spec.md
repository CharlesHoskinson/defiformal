## Purpose

Bind the Sky/Spark sUSDS vault pin, reject the L2 token as the contrasting case, and freeze compiler identity versus administrative smoke and the planned EVM prestate method.

## ADDED Requirements

### Requirement: Main SUsds is the vault pin, not L2

P17 SHALL pin `src/SUsds.sol` at sdai commit `dfc7f41cb7599afcb0f0eb1ddaadbf9dd4015dce`, SHA-256 `9fe0c713751142e75a1da60ad6c0127d5ad01cb6d24289183ac48b202f3c5d69`. The moving `susds` branch SHALL remain locator-only. `src/l2/SUsds.sol` SHALL NOT be the selected vault operation. A second AMM formula SHALL NOT be substituted. If the pin, compiler identity, and observation closure were inadequate, P17 SHALL record `blocked_missing_source` rather than invent fidelity.

#### Scenario: L2 file is a different contract
- **WHEN** captured `src/SUsds.sol` and `src/l2/SUsds.sol` are hashed
- **THEN** the digests differ, L2 lacks `deposit`/`chi`/`drip`, and the selected pin is the main file

#### Scenario: Locator branch is not the pin
- **WHEN** the package records the Git identity
- **THEN** the commit is `dfc7f41cb7599afcb0f0eb1ddaadbf9dd4015dce` and `refs/heads/susds` is labelled locator-only

### Requirement: Ten-key import closure matches captured bytes

The selected file plus the explicit additional `ERC1967Proxy.sol` root SHALL resolve to the ten captured compiler-source keys with recorded SHA-256, byte length, and git blob. Closure SHALL NOT discharge `VatLike`, `UsdsJoinLike`, `UsdsLike`, or `IERC1271`. Proxy source SHALL NOT be a deployed-proxy identity.

#### Scenario: Closure count is ten
- **WHEN** captured compiler-source keys are re-hashed
- **THEN** they match `source-pin.json` and `compile-source-closure.json` for exactly those ten keys

### Requirement: Campaign compiler settings are distinct from smoke artifacts

Declared campaign settings SHALL be Solidity 0.8.21, optimizer enabled, 200 runs, `evmVersion shanghai`, `metadata.bytecodeHash none`. The official binary SHA-256 SHALL be `f2857a898be15c69e8de5598dcd3f3e169e94964a0ce9a0bbb1b111f145a81df`. Root smoke Shanghai/IPFS artifacts SHALL NOT be campaign bytecode identities.

#### Scenario: Smoke hashes are not campaign identities
- **WHEN** compile-smoke.json records IPFS metadata bytecode
- **THEN** the planning package records those hashes as administrative feasibility only and freezes campaign `bytecodeHash none`

### Requirement: Vault EVM fork is pinned separately from token0

The common engine MAY reuse the P16 geth `evm` 1.15.11-stable binary. Vault execution SHALL use a Shanghai-enabled prestate, not the token0 Istanbul genesis. Chained `evm run --dump` MUST be verified as a legal next prestate before scoring, or the run is `blocked_missing_evm`.

#### Scenario: Istanbul genesis is not the vault fork
- **WHEN** a vault source score is planned
- **THEN** the package names a separate Shanghai prestate and does not reuse P16 Istanbul genesis as vault state
