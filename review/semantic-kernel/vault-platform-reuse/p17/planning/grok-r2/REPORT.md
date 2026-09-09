# P17 vault planning repair r2 — Grok 4.6 author

**Status: pending_independent_gpt6_review. Not acceptance.** Native Grok 4.6 repaired the r1 CHANGES_REQUIRED findings R1–R3 in `openspec/changes/vault-platform-reuse-p17/` only. Independent GPT-6 has not reviewed these r2 bytes. `gate_accepted` is false. `P17.platform_reuse` is false. No Foreman, subagents, commit, push, Lean, campaign solc/EVM, or production mutation credit. Frozen program tasks 18.1–18.7 remain unchecked. r1 author evidence is preserved.

- **Requested author:** native Grok 4.6
- **Returned author identity:** Grok 4.6 (this author session)
- **Prior review:** GPT-6 CHANGES_REQUIRED, report SHA-256 `7d91ff18974965f2a2adf8a8595d29773a5f6f5a7b0ee715483886ba7b216978`, r1 archive `000d48b5664a18ac3f4378f48bb150a51cf32427ff63d36d1dcf28e9cf1d72f1`
- **Worktree:** `/home/charl/defiformal-wt-p17-vault-grok-gpt6-20260908`
- **HEAD:** `2ad464397cd207bca647768d77d57abb1f8e575c` branch `work/p17-vault-readiness-grok-gpt6-20260908`
- **Change:** `openspec/changes/vault-platform-reuse-p17/`
- **Evidence:** `review/semantic-kernel/vault-platform-reuse/p17/planning/grok-r2/`
- **Preserved r1:** `review/semantic-kernel/vault-platform-reuse/p17/planning/grok-r1/` manifest `ad4d72ff9bd4bca6850428dfd55bbca4e31c19d48b65e6966a455de512506d1e`

## R1

Lifted `Evaluated.Valid` has parameters `store, ctx, request, state, e` and no `post`. The no-credit negative is now `P17-TH-NEGATIVE` / `P17-NEG-MINT-NO-CREDIT`: honest deposit template, `assets > 0`, `execute_ok_iff` derives `post.USDS.vault = pre.USDS.vault + assets`, candidate `candidate.USDS.vault = pre.USDS.vault` cannot equal that result. `not_predicate` is `Evaluated.Valid`. `executor_refusal` is false. Matching positive `P17-POS-DEPOSIT-CREDIT` uses the same effects and premises. Desired post-state is not a Valid hypothesis.

## R2

`fixtures.json` has a construction contract (defaults, D1 overlay, overrides). Every scored source row stores a complete `pre` that diagnose re-merges. Finite USDS allowance equal to transferred assets replaces `max_or_assets`. D1 mint funds `10^18+1` USDS. D1 `chi=RAY+1` is `storage_seed_chi_after_initialize`, not protocol-reachable. Redeem/withdraw controls are `independent_prestate_not_mutated_deposit`. Diagnose simulates captured source guards against those prestates.

## R3

Success observations bind full EVM logs including `usds.Transfer` and a vault-emitter projection. Unrelated logs are retained, not equated. Finite USDS allowance is in pre/post and consumed on success entry. Refusal retains supplied prestate beside revert and does not claim rollback verification.

## Reuse limits retained

Quote-register is model-only, not pool storage or cash settlement. Templates must be library-derived; token0 pre-register equals input sqrtPX96; scale 1 is raw Q96. Unchanged `execute_ok_iff` instances and an actual common engine remain required. Arithmetic-only reuse cannot open the gate. No token0–vault sequential composition. No new P30 prerequisite.

## Checks

| Command | Exit |
| --- | --- |
| intact diagnose.py | 0 (199/199) |
| `--wrong-literal` | 1 (`independent_P17-DEP-D1`, `sim_shares_P17-DEP-D1`) |
| `--empty-corpus` | 3 |
| `--unavailable` | 3 (`evaluated_valid_lift`) |
| `openspec validate --strict` | 0 |

23 requirements, 34 scenarios, 23 unchecked tasks, 16 scored source fixtures plus two model observations, two planned mutants. Production mutation credit 0.

## Not done

Independent GPT-6 r2 review, Lean, campaign compile, scored EVM, compiled mutants, P16 source-gate close, commit, push.
