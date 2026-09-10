# P17 Case-Two Platform Reuse Inventory

**Worktree**: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`  
**Author**: AGY Gemini (`gemini-3.8-flash-high`, `--effort high`)  
**Reviewer**: Claude Opus (native `opus` model alias)  
**Date**: 2026-09-09  

---

## 1. Executive Summary

This inventory records all new definitions, assumptions, interface bindings, and effort metrics introduced by the Case Two (ERC-4626 / Sky sUSDS Vault) verification relative to the accepted Token0 arithmetic slice.

### Core Metrics

| Metric | Measured Value | Requirement / Target | Status |
| :--- | :--- | :--- | :--- |
| **New Lean Files** | 10 files | `lean/DefiKernel/Vault/*.lean`, `Token0Bridge.lean` | Complete |
| **New Lean LOC** | 1,779 lines | All files $\le$ 100 char/line | Complete |
| **Lean Theorems Proven** | 73 theorems | 0 `sorry`, 0 custom axioms, forbidden=0 | Complete |
| **Lean Axiom Audit** | 73 theorems, 62 decls | `AxiomAudit.lean` clean pass | Complete |
| **Runtime Test Suite** | 20 named checks | 20/20 true, nodup names | Complete |
| **Platform Engine Modules** | 12 modules | `scripts/platform_engine/` | Complete |
| **Platform Engine LOC** | 2,154 lines | Common compile, EVM run, scoring | Complete |
| **EVM Fixtures Executed** | 17 fixtures | 16 original + RR-5 `P17-RED-DELEGATED` | Complete |
| **EVM Fixture Score** | 17/17 ok (100%) | All 19 cells evaluated + full logs | Complete |
| **Production Mutants** | 2/2 detected | `V-TF-SKIP`, `V-DEP-CEIL` with all controls | Complete |
| **Token0 Platform Reuse** | Compile & Execute | Solc 0.7.6 Istanbul + EVM probe = $2^{95}$ | Complete |

---

## 2. New Definitions

### Lean 4 Kernel Modules

1. **`DefiKernel.Vault.Types`** (100 lines):
   - Fundamental constants: `RAY = 10^27`, `WAD = 10^18`.
   - Word types: `Word 256`, `Word 160`, checked arithmetic bounds.
   - Domain enumerations: `Party` (`vault`, `sender`, `receiver`, `owner`, `spender`), `Asset` (`usds`, `susds`), `Domain` (`vault`).
   - Kernel state types: `Cell = Domain × Party × Asset`, `State`, `Evaluated`, `Template`.
   - Error types: `Failure` (`insufficientBalance`, `insufficientAllowance`, `invalidAddress`, `mulOverflow`, `divZero`, etc.).

2. **`DefiKernel.Vault.Conversion`** (180 lines):
   - Directed conversion functions: `convertToShares_floor`, `convertToAssets_floor`, `convertToShares_ceil`, `convertToAssets_ceil`.
   - Checked ceiling division: `_divup`.
   - Mathematical correspondence proofs between conversion operations and underlying arithmetic lemmas.

3. **`DefiKernel.Vault.Operations`** (549 lines):
   - Core functional operations: `deposit`, `mint`, `withdraw`, `redeem`.
   - Guarded sub-operations: `mintAfterGuard`, `burnShares`.
   - Formal proofs:
     - `burnShares_insufficientBalance`
     - `burnShares_insufficientAllowance`
     - `redeem_burn_error`
     - `withdraw_burn_error`
     - `burnShares_success_self`
     - `burnShares_success_delegated`
     - `redeem_success_assets`
     - `withdraw_success_shares`
     - `redeem_floor_assets`
     - `withdraw_ceil_shares`
     - `mintShares_success`
     - `mintAfterGuard_success`
     - `mintAfterGuard_transfer_error`
     - `deposit_transfer_error`

4. **`DefiKernel.Vault.Adapter`** (394 lines):
   - Typed transition adapters: `depositTemplate`, `redeemTemplate`.
   - Capability store, invocation context, and evaluation bindings.
   - Exact equivalence theorems: `deposit_execute_ok_iff`, `redeem_execute_ok_iff`.
   - Discrimination soundness: `no_credit_mismatch` proving that perturbations fail `Evaluated.Valid`.

5. **`DefiKernel.ConcentratedLiquidity.Token0Bridge`** (335 lines):
   - Quote-register Typed wrap of delivered Token0 library.
   - Uses `Quantity.toQuantity` with `scale1 = 1` raw Q96 units.
   - Proven non-vacuous effect: `ordinary_add_nonzero_debit` proves `postQ - preQ != 0` ($2^{95} - 2^{96} = -2^{95}$).
   - Fully audited with 0 sorry and 0 custom axioms.

6. **Supplemental Test & Audit Modules**:
   - `Examples.lean` (172 lines): 20 runtime checks.
   - `Tests.lean` (12 lines): Named check list with uniqueness proof `runtimeChecks_named`.
   - `RuntimeAudit.lean` (20 lines): Executable `#eval` verification.
   - `ProofAudit.lean` (14 lines): `#audit_axioms` for `DefiKernel.Vault` and `Token0Bridge`.
   - `Verify.lean` (3 lines): Top-level verification aggregator.

### Shared Platform Engine Modules

- `common.py`: Shared tool pins, SHA256 verification, fail-closed classification.
- `compile.py`: Parameterized Solc wrapper (supports Solc 0.8.21 Shanghai & Solc 0.7.6 Istanbul).
- `evm.py`: Parameterized Geth EVM runner with prestate execution, trace parsing, and dump-to-alloc conversion.
- `abi.py`: ABI word encoding, calldata generation, revert payload decoder.
- `keccak.py`: Pure-Python Keccak-256 implementation.
- `prestate.py`: Shanghai and Istanbul genesis templates with dynamic alloc binding.
- `score.py`: Fail-closed campaign scoring.
- `vault_exec.py`: Fixture runner evaluating all 19 cells, returndata, and full logs across 17 fixtures.
- `vault_campaign.py`: Complete vault test campaign entrypoint.
- `vault_mutants.py`: Production Solidity mutant compilation and discrimination testing.
- `token0_campaign.py`: Shared platform compilation and execution for Token0 probe.

---

## 3. New Assumptions

1. **`A-MOCK-INFRASTRUCTURE`**: External dependencies (`UsdsMock.sol`, `VatMock.sol`, `JoinMock.sol`) stand in for Maker/Sky multi-contract infrastructure. ERC20 operations mutate storage balances directly without fee-on-transfer, hooks, or external reentrancy.
2. **`A-INITIALIZATION-PROXY`**: `SUsds` is deployed behind an ERC1967 transparent proxy and initialized with fixed parameters.
3. **`A-STABLE-TIME-DOMAIN`**: Scored fixtures execute under stable-time domain D0 (`rho = 0`, `timestamp = 0`, `chi = RAY`) and D1 (`rho = 0`, `timestamp = 0`, `chi = RAY + 1` storage seed); rate accrual (`rpow`, `drip()`) is held constant within individual transactions.
4. **`A-OBSERVED-STATE-MOVEMENT`**: External call success is insufficient to prove asset movement; all 19 state cells are explicitly observed and verified.
5. **`A-LOCAL-SYNTHETIC-ADDRESSES`**: Contracts and accounts utilize deterministic local addresses (`0x20...02` vault, `0x20...01` usds), not mainnet addresses.

---

## 4. Interface Changes

1. **Stateful Observation Domain**:
   - P16 Token0 evaluated 4 pure arithmetic inputs to `uint160 | revert`.
   - P17 Vault evaluates 19 state cells spanning assets, shares, allowances, and total supplies across 5 actors and 2 tokens.
2. **Shanghai EVM Execution Fork**:
   - P16 used Istanbul genesis.
   - P17 introduces Shanghai genesis prestate (`shanghaiTime = 0`), compiling with Solc 0.8.21 and testing `PUSH0` opcode behavior.
3. **Multi-Asset Kernel Templates**:
   - Kernel transition templates extended to track two distinct asset types simultaneously (`usds` and `susds`).
4. **Token0 Quote-Register Typed Wrap**:
   - `Token0Bridge` bridges the pure next-price helper into the Typed kernel framework via a synthetic model-only QuoteSqrtP register with verified nonzero debit/supply effect.

---

## 5. Effort Metrics

- **Total Lean Implementation**: 1,779 LOC across 10 files.
- **Total Engine Implementation**: 2,154 LOC across 12 modules.
- **Theorems Proven**: 73 theorems, 0 sorry, 0 custom axioms.
- **Fixtures Executed**: 17 fixtures, 17/17 passed (100%).
- **Mutants Verified**: 2 production mutants, both detected on designated false fixtures with all controls passing.
- **Cross-Platform Verification**: Both Token0 and Vault execute successfully through the same parameterized platform engine.
