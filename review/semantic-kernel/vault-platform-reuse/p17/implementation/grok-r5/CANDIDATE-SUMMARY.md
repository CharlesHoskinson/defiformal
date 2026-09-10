# DeFiFormal P17 candidate: Grok R5 repair round

**Candidate**: `review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5/`  
**Execution**: `attempt-1/`  
**Worktree**: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`  
**Author**: native Grok 4.6. AGY r1–r4 developed the frozen R4 candidate while Grok was unavailable; those bytes and authorship are preserved.  
**Reviewer**: pending native Opus repair review of this candidate. Opus R4 review (`claude-opus-5`, session `a1e40b81-7427-45e5-8b00-b2492cd46156`) remains CHANGES_REQUIRED historical evidence.  
**Date**: 2026-09-09  

This author reports the repair candidate ready for root freeze and independent review. The author does **not** accept `P17.platform_reuse`, source execution, or implementation. Root alone can accept.

## 1. What this round closed

R-1 through R-9 and ROOT-RR4, ROOT-T2.2, ROOT-T2.3, ROOT-T2.5, ROOT-FULL-COVERAGE, in one authorized repair round.

- **R-1**: `Token0Bridge` `preQ`/`postQ` are `Quantity.toQuantity` of the library input and successful ordinary-add word. `preRegister` binds that input. `execute_ok_iff_quote` consumes it. Nonzero ordinary-add, `e.Valid` without desired-post, model-only raw-Q96 scale1, and old P16 statements are unchanged.
- **R-2**: measured new definitions, new vs inherited assumptions, interface changes, and native receipt effort. Adapter is deposit-only. Every engine module is listed.
- **R-3**: well-formed model success vs source refusal is fail/1. Missing/malformed/unmapped remains blocked/3. c1–c7 reproduced; c6 consumer exit 1; c7 exit 1.
- **R-4**: token0 detection is disagreement with the intact expected observation. All six compiled detections remain real. Non-distinguishing planned==intact is blocked without detection credit.
- **R-5**: prose corrected: Valid holds; no-credit violates `execute_ok_iff` observation/post equality. Lean theorem unchanged.
- **R-6**: 34 scenarios mapped; 4 inherited_planning; implementation citations point at grok-r5 evidence. Planning gate not rerun.
- **R-7**: `remaining-gates.json` supersedes named frozen statuses without rewriting frozen bytes. accrual/`_rpow`, UUPS, permit/IERC1271, L2 token, deployment identity, P21, P30 remain open/not claimed. Execution is not acceptance.
- **R-8**: candidate-local harnesses against the current engine, with portable paths. Old primary R3 commands remain frozen historical tests.
- **R-9**: `vault_emitter_projection` recorded and checked. On actual `P17-DEP-D0`, USDS Transfer is in full logs and absent from the vault projection. Emitter/order/content falsifiers kept.
- **ROOT-RR4**: metadata diagnostics for merge, finite allowance, D1 seed, funding label, negative-theorem predicate, each with intact and named failure.
- **ROOT-T2.2**: creation/runtime SHA256 bound to source/settings/compilation; hex-text vs raw-bytes vs historical IPFS smoke identified.
- **ROOT-T2.3**: unscored `evm --dump` roundtrip plus missing-dump `blocked_missing_evm`/exit 3.
- **ROOT-T2.5**: `blocked_missing_compiler` / `blocked_missing_evm` with `missing_identity` on real missing tools; intact controls pass.
- **ROOT-FULL-COVERAGE**: default vault campaign scores the canonical 17 IDs independently of a filtered list.

## 2. Preservation

agy-r1, agy-r2, agy-r3, agy-r4, grok-r1, frozen planning, primary root diagnostics, and the Opus sandbox are not overwritten. Failed grok-r5 attempts are kept (`token0bridge-r1-lift`, `rr4-r5`). Atlas stays parked. No commits, pushes, main merge, or Foreman.

## 3. Reproduction (cwd = worktree root)

```bash
export DEFIFORMAL_EVIDENCE_DIR="$PWD/review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5"
export DEFIFORMAL_RUN_DIR=attempt-1   # use a new attempt-* to rerun; refuse_nonempty_dir will not reuse

# Lean 4.33.0-rc2 via the worktree Elan pin
python3 -B scripts/token0_p16/record_cmd.py --name lean-version --cwd "$PWD/lean" \
  --out /tmp/lean-version/receipt.json --stdout-path /tmp/lean-version/stdout.bin \
  --stderr-path /tmp/lean-version/stderr.bin -- lake env lean --version
python3 -B scripts/token0_p16/record_cmd.py --name lean-verify --cwd "$PWD/lean" \
  --out /tmp/lean-verify/receipt.json --stdout-path /tmp/lean-verify/stdout.bin \
  --stderr-path /tmp/lean-verify/stderr.bin --timeout 900 -- lake build DefiKernel.Vault.Verify

PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/setup_controls.py
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/rr4_metadata_diagnostics.py
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/token0_detector_controls.py
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/vault_campaign.py
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/vault_mutants.py
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/token0_campaign.py
PYTHONPATH=scripts/platform_engine python3 scripts/platform_engine/dump_smoke.py
python3 review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5/harnesses/replay_parser.py
python3 review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5/harnesses/replay_logs_and_projection.py
python3 review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5/harnesses/replay_discrimination.py
python3 review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5/harnesses/replay_model_consumer.py
```

Do not rerun the frozen primary R3 commands as a test of this engine.

## 4. Scope limits

No mainnet, accrual/`_rpow`, UUPS, permit/IERC1271, L2 token, pool-storage/cash-settlement for token0, sequential token0-vault composition, P21, or P30. D1 chi is a storage seed without a reachability claim; non-reachability is not proved. Nineteen-cell poststate comparison covers the ten successful vault rows. The seven refusals retain supplied prestate plus the actual refusal. Author freeze is not self-acceptance.
