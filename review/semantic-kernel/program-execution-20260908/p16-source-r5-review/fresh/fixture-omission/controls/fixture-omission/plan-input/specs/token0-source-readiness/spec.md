## Purpose

Bind the pinned Uniswap v3-core token0 helper, its import closure, declared compiler settings, and the missing compiler/EVM harness as a future readiness obligation.

## ADDED Requirements

### Requirement: Pin closure is compared, not self-asserted

P16 SHALL verify Uniswap v3-core commit `e3589b192d0be27e100cd0daaf6c97204fdb1899`, tree `f024dbf808e50091852f7cc8724d837543a8c7e5`, and compare the historical liquidity planning archive SHA-256 to CURRENT.json `lanes[id=liquidity].candidate.sha256` (`e1cd08f9f8a843355f1b249a013c9de0d29e7e1ebf1d5a3e8716d6d7621baf77`). The unaccepted whole-library freeze is preserved input, not accepted evidence.

#### Scenario: Archive hash matches CURRENT.json
- **WHEN** the retained archive `p15-retained-inputs/liquidity-official-planning-r1-stage.tar.gz` is hashed
- **THEN** the digest equals CURRENT.json `liquidity.sha256` and the planning package records that comparison rather than restating the constant alone

### Requirement: Token0 helper import closure matches captured bytes

The helper `getNextSqrtPriceFromAmount0RoundingUp` SHALL be bound to captured `SqrtPriceMath.sol` lines 28–56 and the transitive static imports FullMath, UnsafeMath, LowGasSafeMath, SafeCast, and FixedPoint96. Each file SHALL match retained SHA-256 and git-blob identities. No source bytes are modified.

#### Scenario: Six-file closure plus hardhat settings
- **WHEN** captured source bytes are hashed and git-blob SHA-1 values are recomputed
- **THEN** they match the retained tree/blob identities for those six libraries and `hardhat.config.ts`, and SqrtPriceMath imports exactly those five libraries

### Requirement: Compiler settings are declared; the binary is not claimed installed

Declared settings SHALL be Solidity 0.7.6, optimizer enabled, 800 runs, `metadata.bytecodeHash none`. Missing compiler binary and EVM harness identity SHALL be an explicit future readiness obligation. This planning pass MUST NOT claim the binary is installed or that source was executed.

#### Scenario: Host has no solc
- **WHEN** `command -v solc` is empty on the author host
- **THEN** the package records `not_established` for the compiler binary, freezes the official linux-amd64 0.7.6 identity from binaries.soliditylang.org, and does not treat Python diagnostics as compilation

### Requirement: Harness plan is concrete and reproducible

P16 SHALL freeze a standard-json compile of a public probe contract over the captured libraries, optimizer 800, bytecodeHash none, evmVersion istanbul, and an EVM `eth_call`/run observation. Success is ABI uint160. Refusal is EVM revert with recorded returndata. Model Failure names MUST NOT be equated with revert payloads by assumption.

#### Scenario: Missing binary blocks execution, not the planning record
- **WHEN** the official solc 0.7.6 binary has not been downloaded
- **THEN** source-execution partitions remain unexecuted and MUST NOT be scored as agreement; the acquisition URL and expected binary SHA-256 remain the plan
