# Case Two Inventory: P17 Vault Platform Reuse

**Worktree**: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`  
**Author Provenance**: AGY Gemini (`gemini-3.8-flash-high`, `--effort high`)  
**Independent Reviewer**: Claude Opus (native `opus` model alias)  
**Execution Candidate**: `agy-r3` (execution path: `attempt-1/`)  
**Date**: 2026-09-09  

---

## 1. Executive Summary & Verification Metrics

This candidate delivers the complete, unabridged implementation of **P17 Vault Platform Reuse**, expanding the semantic kernel from the pure arithmetic foundation of P16 (Uniswap v3 `Token0`) to stateful, multi-asset ERC-4626 vault dynamics (Maker/Sky `SUsds`), while preserving and re-verifying the full P16 source campaign through a single, shared execution and scoring engine.

### Verification Scorecard

| Category | Metric | Measured Value | Standard / Requirement |
| :--- | :--- | :--- | :--- |
| **Lean 4 Proofs** | `lake build DefiKernel.Vault.Verify` | **995 / 995 jobs clean** | 0 `sorry`, 0 custom axioms |
| **Vault Axiom Audit** | `DefiKernel.Vault` theorems | **175 / 175 proven** | Forbidden axioms = 0 |
| **Vault Axiom Audit** | `DefiKernel.Vault` decls | **184 / 184 audited** | Forbidden axioms = 0 |
| **Token0Bridge Audit** | `Token0Bridge` theorems | **73 / 73 proven** | Forbidden axioms = 0 |
| **Token0Bridge Audit** | `Token0Bridge` decls | **62 / 62 audited** | Forbidden axioms = 0 |
| **Vault EVM Campaign** | `vault_campaign.py` fixtures | **17 / 17 ok (exit 0)** | All 19 cells & full logs match |
| **Token0 EVM Campaign** | `token0_campaign.py` fixtures | **12 / 12 ok (exit 0)** | All 12 baseline fixtures match |
| **Token0 Theorem Probe** | Ordinary add probe `2^95` | **Match verified** | `Token0Bridge.ordinary_effect_nonzero` |
| **Vault Mutants** | `V-TF-SKIP`, `V-DEP-CEIL` | **2 / 2 detected** | Controls preserved |
| **Token0 Mutants** | `T0-ID-SKIP` through `T0-CHECKED-ADD` | **6 / 6 detected** | Controls `P16-ADD`, `P16-REQ` preserved |
| **Lean Model Binding** | Model vs EVM comparison | **100% agreement** | Mathematical model correspondence |
| **Protocol Controls** | Replay parser test suite | **30 / 30 passed** | 0 regressions |
| **Extended Log Falsifiers** | Replay extended log falsifiers suite | **6 / 6 passed** | 0 regressions |

---

## 2. Reconciled Deployment & State Parameters

In compliance with root directive **SC4**, all prestate values, timestamps, actor labels, and contract deployment configurations are reconciled against the physical runtime artifacts:

### 2.1 Time Domain & Accrual
- **Genesis Block Timestamp**: `1700000000` (`TS = 1700000000`).
- **Initial Rate Timestamp**: `rho = 1700000000`.
- **Accrual Behavior**: In `SUsds.sol`, `drip()` evaluates `block.timestamp - rho`. Because block timestamp matches `rho` in both D0 (`chi = RAY`) and D1 (`chi = RAY + 1`), `drip()` leaves `chi` unchanged during the single-block transaction, ensuring deterministic verification.

### 2.2 Actor Addresses
- `S` (Sender / Depositor): `0x1111111111111111111111111111111111110001` (funded with 1000 USDS in genesis).
- `R` (Receiver): `0x1111111111111111111111111111111111110002`.
- `O` (Owner / Shares Holder): `0x1111111111111111111111111111111111110003`.
- `P` (Spender / Operator): `0x1111111111111111111111111111111111110004`.
- `VOW` (Maker Protocol Vow): `0x1111111111111111111111111111111111110005`.

### 2.3 Contract Deployment Architecture
1. `VatMock.sol:VatMock`: Created from genesis alloc by sender `S`.
2. `UsdsMock.sol:UsdsMock`: Created from genesis alloc by sender `S`.
3. `UsdsJoinMock.sol:UsdsJoinMock`: Created with constructor arguments `(vat, usds)`.
4. `SUsds.sol:SUsds` (Implementation): Created with constructor arguments `(join, vow)`.
5. `ERC1967Proxy.sol:ERC1967Proxy` (Vault Entry): Created with constructor arguments `(impl, data)` where `data` is the 4-byte selector `0x8129fc1c` (`initialize()`), setting `chi = RAY` and `rho = 1700000000`.
6. **Execution Target**: All fixture operations target the `ERC1967Proxy` address. The proxy executes `DELEGATECALL` to the SUsds implementation, preserving `address(this) = vault`.

---

## 3. Scope & Substantive Reuse

### 3.1 Shared Platform Engine
Both cases (`Token0` and `Vault`) execute through the shared platform engine in `scripts/platform_engine/`:
- `evm.py`: Common EVM runner (`geth --exec evm`), genesis configuration, prestate generation, and fail-closed parser.
- `compile.py`: Parameterized Solc compiler supporting both Solc 0.7.6 Istanbul (`Token0`) and Solc 0.8.21 Shanghai (`Vault`).
- `score.py`: Unified fail-closed scoring grammar (0 = all pass, 1 = semantic failure, 3 = setup/tool blocked).
- `abi.py`: Standard ABI encoding/decoding.

### 3.2 Dual-Domain Mutation Campaigns
- **Vault Mutants**:
  - `V-TF-SKIP`: Omits underlying token debit. Fails `P17-DEP-D0` on asset transfer and balance checks; unaffected controls pass.
  - `V-DEP-CEIL`: Mutates share calculation to `_divup`. Fails `P17-DEP-D1` on share quantity; unaffected controls pass.
- **Token0 Mutants**:
  - `T0-ID-SKIP`, `T0-WRAP-SKIP`, `T0-PROD-SKIP`, `T0-REQ-SKIP`, `T0-FLOOR`, `T0-CHECKED-ADD` all compile, detect designated false witnesses, and preserve independent controls (`P16-ADD`, `P16-REQ`).
