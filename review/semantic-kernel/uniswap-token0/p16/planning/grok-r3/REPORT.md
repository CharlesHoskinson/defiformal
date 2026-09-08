# P16 token0 planning r3 — Grok 4.6 author repair (R4)

**Status: pending_independent_gpt6_review. Not acceptance.** Native Grok 4.6 applied the single remaining GPT-6 r2 repair (R4) from `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-r2-planning-review/REVIEW.md` (SHA-256 `ebdf78e2d83921ffedcbbf0aa2e722d4a529a3c3dd8f4bd9fe60d73f8504ccc5`). `gate_accepted` remains false. No Foreman, commit, push, Lean, solc/EVM install, compiled mutants, or r1/r2 evidence rewrite.

- **Prior review:** CHANGES_REQUIRED R4 only; candidate archive SHA-256 `baaf21f02b8d2e78293763d1c2c41e8b65d3f1e1bbeb56f14d06d276da57aae5`; base `de0e03ed45c1073c6d01f7213303530aafcb9e4f`
- **Worktree HEAD:** `de0e03ed45c1073c6d01f7213303530aafcb9e4f`
- **Allowed source edits:** two stored `wrapped_denominator` literals in `openspec/changes/uniswap-token0-p16/{fixtures,planned-mutations}.json`
- **New evidence:** `review/semantic-kernel/uniswap-token0/p16/planning/grok-r3/`
- **Preserved:** all 65 grok-r1 files and all 24 grok-r2 files byte-for-byte, including the old failed 2^256 literals in r2 logs/reports. Other 16 plan files unchanged.

Counts after repair: 5 capabilities, 24 requirements, 30 scenarios, 20 unchecked implementation tasks. `openspec validate uniswap-token0-p16 --strict` exits 0.

## R4 — stored strict-underflow denominator

Both stored fields previously held decimal **2^256**. For frozen inputs `(2^96,1,2,false)`, wrapped subtraction is `(2^96-2^97) mod 2^256 = 2^256-2^96`. Replaced both with:

`115792089237316195423570985008687907853269984665561335876943319670319585689600`

Public mutant result **1** and symbolic prose were already correct. Equality P16-REQ remains a refusal baseline; P16-ADD remains the unaffected positive.

## Stored-field diagnostic

`bind_strict_underflow.py` SHA-256 `986489354b0fde72bbf457bcae5043159e2bad2110b781ad5ecf07a3d08a630f` reads caller `--fixtures`/`--mutations` bytes, hashes them, parses stored P16-REQ-STRICT inputs, recomputes wrapped denominator and ceil result from those inputs, and compares **both** stored denominator fields plus stored public `1`, designated false, equality, and add control. Planning diagnostic credit only.

| Child | Actual exit | Recorded as |
| --- | --- | --- |
| repaired live JSON | 0 | 15/15 |
| preserved r2 archive JSON | **1** | 13/15; failed both stored denominator fields; bytes still `3bd3b3c5…` / `473e5b4e…` |
| `--empty-corpus` | **3** | BLOCKED, DENOMINATOR 0 |
| in-memory corrupt fixtures denom | **1** | only fixtures field failed |
| in-memory corrupt mutations denom | **1** | only mutations field failed |
| malformed `{` | **1** | JSON decode failure |

Parent `suite_r3.py` expects those negative exits but does not relabel child `returncode`. No r1/r2 campaign replay.

## Remaining gates

Independent GPT-6 targeted re-review. Lean/Arithmetic baseline, solc 0.7.6 acquisition, EVM identity, compiled mutants with unaffected controls, branch proofs. Original 1.2 whole-task still open. P21 residual remains P21.
