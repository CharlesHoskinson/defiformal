# DeFiFormal P17 Candidate Summary: Vault Platform Reuse

**Candidate Directory**: `review/semantic-kernel/vault-platform-reuse/p17/implementation/agy-r2/`  
**Worktree**: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`  
**Author**: AGY Gemini (`gemini-3.8-flash-high`, `--effort high`)  
**Independent Reviewer**: Claude Opus (native `opus` model alias)  
**Date**: 2026-09-09  

---

## 1. Executive Summary

This frozen candidate `agy-r2` represents the complete, verified, and unbifurcated implementation of **DeFiFormal Sprint P17: Vault Platform Reuse**. It resolves all reviewer requests (RR-1 through RR-5) and fulfills all root directives (SC1 through SC5), delivering:

1. **SC1 (Shared Engine & Token0 Campaign)**:
   - Full execution of the 12-case P16 source campaign on Istanbul genesis prestate via the shared platform engine.
   - 6 compiled production mutants (`T0-ID-SKIP`, `T0-WRAP-SKIP`, `T0-PROD-SKIP`, `T0-REQ-SKIP`, `T0-FLOOR`, `T0-CHECKED-ADD`) all compiled, detected on designated false fixtures, and verified against unaffected positive controls (`P16-ADD`) and equality controls (`P16-REQ`).
   - Ordinary add probe `probe(2^96, 1, 1, true)` returns $2^{95}$, matching `Token0Bridge.ordinary_effect_nonzero`.
   - Unified fail-closed scoring: `denominator: 12, ok: 12, exit: 0`.

2. **SC2 (Mathematical Model-to-Source Binding)**:
   - Both Vault and Token0 EVM returndata are verified not merely against Python literals, but directly against compiled Lean kernel model exports (`P17VaultBindings.lean` and `P16SourceBindings.lean` executed under `record_cmd`).
   - Every fixture step records `lean_model: ...` and `lean_model_match: true`.

3. **SC3 (Strict Full Ordered Emitter-Bound Logs)**:
   - Emitter identification derived from true EVM call-frame stack tracking across `CALL`, `STATICCALL`, `CALLCODE`, and `DELEGATECALL`.
   - ERC1967 transparent proxy context correctly maps executing code to `address(this) = vault`.
   - Memory bounds strictly enforced without zero-padding; truncated memory raises exceptions and fails verification.
   - Full event sequences (`LOG0` through `LOG4`) strictly checked; extra or unknown records fail closed.

4. **SC4 (Truthful Case-Two Inventory & Reconciled Deployment)**:
   - Scope-specific axiom audits separately reported:
     - `DefiKernel.Vault`: 175 proven theorems, 184 audited declarations (forbidden = 0).
     - `DefiKernel.ConcentratedLiquidity.Token0Bridge`: 73 proven theorems, 62 supplemental declarations (forbidden = 0).
   - Reconciled deployment parameters: block timestamp 1700000000 matching `rho = 1700000000`; synthetic actors `S`, `R`, `O`, `P`, `VOW` at `0x1111...0001` through `0x1111...0005`; ERC1967 proxy with `initialize()` selector `0x8129fc1c`.

5. **SC5 (Parser Regressions & Write-Once Immutability)**:
   - `classify_evm_stdout` in `evm.py` repaired: non-empty payloads accompanying `ERROR_INVALID` are rejected as `unknown_output` (`blocked`). All 30 tests in `replay.py` pass (30/30).
   - Absolute write-once enforcement via `refuse_nonempty_dir()`.
   - Explicit historical erratum in `RR-COMPLIANCE.md` detailing the Grok r2 overwritten intact run, the 5 intermediate `agy-r1` campaign attempts, and parser/log protocol findings.

---

## 2. Directory Structure of Candidate `agy-r2/`

```
review/semantic-kernel/vault-platform-reuse/p17/implementation/agy-r2/
├── CANDIDATE-SUMMARY.md
├── CASE-TWO-INVENTORY.md
├── case-two-inventory.json
├── RR-COMPLIANCE.md
├── scenario-map.json
├── evidence-manifest.json
└── run-1/
    ├── evm/
    │   ├── compile/
    │   │   ├── compile.json
    │   │   └── result.json
    │   ├── execute/
    │   │   ├── deploy/
    │   │   │   ├── addresses.json
    │   │   │   └── genesis0.json
    │   │   └── fixtures/
    │   │       ├── P17-DEP-D0/ ... P17-RED-DELEGATED/
    │   │       ├── rows.json
    │   │       └── score.json
    │   ├── token0-compile/
    │   │   ├── compile.json
    │   │   └── result.json
    │   ├── token0-execute/
    │   │   ├── P16-I-ADD/ ... P16-WRAP/
    │   │   ├── ordinary-add-summary.json
    │   │   ├── rows.json
    │   │   ├── score.json
    │   │   └── summary.json
    │   └── token0-mutants/
    │       ├── T0-ID-SKIP/ ... T0-CHECKED-ADD/
    │       └── summary.json
    ├── lean/
    │   ├── token0/
    │   │   ├── P16SourceBindings.lean
    │   │   ├── bindings/
    │   │   └── bindings-summary.json
    │   └── vault/
    │       ├── P17VaultBindings.lean
    │       ├── bindings/
    │       └── bindings-summary.json
    └── mutants/
        ├── V-TF-SKIP/
        ├── V-DEP-CEIL/
        └── summary.json
```

---

## 3. Verification Commands for Reviewer

All evidence is fully reproducible with clean commands:

```bash
# 1. Verify Lean 4 proofs and audit counts
lake --dir lean build DefiKernel.Vault.Verify

# 2. Verify platform engine parser protocol replay (30/30)
python3 review/semantic-kernel/program-execution-20260908/p17-agy-parser-precheck-r1/replay.py

# 3. Verify log protocol falsifiers replay (3/3)
python3 review/semantic-kernel/program-execution-20260908/p17-agy-scope-precheck-r1/replay_logs.py

# 4. Re-run Vault campaign into fresh test directory
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/vault_campaign.py

# 5. Re-run Vault mutants campaign
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/vault_mutants.py

# 6. Re-run Token0 campaign into fresh test directory
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/token0_campaign.py
```
