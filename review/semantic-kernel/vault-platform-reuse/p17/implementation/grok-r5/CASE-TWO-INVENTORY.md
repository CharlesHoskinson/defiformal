# Case Two Inventory: P17 Vault Platform Reuse (Grok R5)

**Worktree**: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`  
**Author**: native Grok 4.6 R5 repairs. AGY r1–r4 authorship of the prior candidate is preserved and not overwritten.  
**Independent reviewer**: pending native Opus repair review. Root has not accepted implementation.  
**Execution candidate**: `grok-r5` (`attempt-1/`)  
**Date**: 2026-09-09  
**Baseline**: `agy-r4/case-two-inventory.json` (definitions only; R-2 required assumptions, interfaces, effort)

This inventory is measured, not independently accepted. `P17.platform_reuse` remains false.

## 1. Verification scorecard (this candidate)

| Category | Metric | Measured value | Evidence |
|---|---|---|---|
| Lean | `lake env lean --version` | 4.33.0-rc2 | `logs/lean/version-r5` |
| Lean | `lake build DefiKernel.Vault.Verify` | **995 / 995** jobs, exit 0 | `logs/lean/verify-r5` |
| Vault axiom audit | theorems / decls | **175 / 175**, **184 / 184**, forbidden=0 | verify-r5 stdout |
| Token0Bridge axiom audit | theorems / decls | **78 / 78**, **62 / 62**, forbidden=0 | verify-r5 stdout; R-1 added theorems |
| Runtime comparisons | `#eval` denominator | **20** | RuntimeAudit in verify-r5 |
| Vault source campaign | canonical 17 IDs | **17 / 17 ok, exit 0** | `attempt-1/evm/execute/fixtures/score.json` |
| Token0 source campaign | canonical 12 IDs | **12 / 12 ok, exit 0** | `attempt-1/evm/token0-execute/score.json` |
| Ordinary add | `2^95` | match | `ordinary-add-summary.json` |
| Vault mutants | V-TF-SKIP, V-DEP-CEIL | **2 / 2 detected**, controls ok | `attempt-1/mutants/summary.json` |
| Token0 mutants | six compiled production | **6 / 6 detected** vs intact expectation | `attempt-1/evm/token0-mutants/summary.json` |
| Token0 detector controls | intact / falsify / non-distinguishing / blocked | **4 / 4** | `attempt-1/token0-detector-controls/result.json` |
| Dump smoke | intact + missing dump | intact ok; missing `blocked_missing_evm` exit 3 | `attempt-1/dump-smoke/result.json` |
| Setup controls | missing compiler/evm | **5 / 5** | `attempt-1/setup-controls/result.json` |
| RR-4 metadata | intact + five falsifiers | **10 / 10** after preserved failed r5 | `attempt-1/rr4-metadata-diagnostics-2/result.json` |
| Discrimination | c1–c7 | **7 / 7**; c6 consumer exit 1 | `attempt-1/harness-discrimination/results.json` |
| Model consumer | 10 checks | **10 / 10** | `attempt-1/harness-model-consumer/results.json` |
| Parser | 7 refusals + 23 grammar | **30 / 30** | `attempt-1/harness-parser/result.json` |
| Logs + R-9 projection | 6 falsifiers + 4 projection | **10 / 10** | `attempt-1/harness-logs-projection/result.json` |

Failed attempts preserved: `logs/lean/token0bridge-r1-lift` (exit 1), `logs/engine/rr4-r5` (exit 1), `attempt-1/rr4-metadata-diagnostics`.

## 2. New definitions (case two)

Lean modules: Types, Conversion, Operations, Adapter (deposit template only; no redeem template), Examples, Tests, RuntimeAudit, ProofAudit, Verify, Token0Bridge.

Engine modules: `__init__.py`, `common.py`, `compile.py`, `prestate.py`, `score.py`, `evm.py`, `abi.py`, `keccak.py`, `vault_exec.py`, `vault_campaign.py`, `vault_mutants.py`, `token0_campaign.py`, `dump_smoke.py`, `setup_controls.py`, `rr4_metadata_diagnostics.py`, `token0_detector_controls.py`, `manifest.py`.

## 3. New versus inherited assumptions

**New (case two):** UsdsMock/VatMock/UsdsJoinMock are harness, not captured SUsds identity; D1 chi is a storage seed with no protocol-reachability evidence and no non-reachability proof; timestamp == rho (no `_rpow`); G-UNCHECKED-SUPPLY-WRAP; G-MULDIV-UNBOUNDED-PRODUCT; no deployment identity.

**Inherited:** `Typed.execute_ok_iff` statement unchanged; P16 token0 library; frozen 67-file planning package.

## 4. Interface changes

`compile_sources` (solc/evmVersion/optimizer/bytecodeHash/`bytecode_sha256`); `run_fixtures` (subset vs canonical 17); `validate_model_receipt`; 19-cell success observation; `VAULT_ERROR_CONTEXT_MAP`; P16 r6 `classify_evm_stdout`; `vault_emitter_projection`; token0 detection by disagreement with intact expectation.

## 5. Effort

Units: native `record_cmd` UTC intervals. Not person-hours. AGY r1–r4 and prior Grok cumulative usage are not added into this row. Receipts are listed in `case-two-inventory.json`.

## 6. Erratum

agy-r4 described Adapter as containing deposit and redeem templates. Only a deposit template exists.

## 7. Still open (not this sprint)

accrual/`_rpow`, UUPS, permit/IERC1271, L2 token, deployment identity, P21, P30. Successful execution is not independent acceptance. Root alone can accept.
