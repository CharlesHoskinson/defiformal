# P16 token0 planning r2 — Grok 4.6 author repair

**Status: pending_independent_gpt6_review. Not acceptance.** Native Grok 4.6 repaired the P16 planning slice against independent GPT-6 `CHANGES_REQUIRED` (R1–R3) in `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-planning-review/REVIEW.md`. `gate_accepted` remains false. No Foreman, commit, push, Lean, solc/EVM install, or compiled mutants. Every grok-r1 evidence byte is unchanged.

- **Prior review:** CHANGES_REQUIRED; required R1, R2, R3; candidate archive SHA-256 `60b770e6fd89467e76682bc15bea95570e833f71fb7a9ad80def69796f941a45`
- **Worktree HEAD:** `de0e03ed45c1073c6d01f7213303530aafcb9e4f`
- **Allowed edits:** `openspec/changes/uniswap-token0-p16/**`
- **New evidence:** `review/semantic-kernel/uniswap-token0/p16/planning/grok-r2/`

Counts after repair: 5 capabilities, 24 requirements, 30 scenarios, 20 unchecked implementation tasks. `openspec validate uniswap-token0-p16 --strict` exits 0.

## R1 — production mutants and T0-REQ-SKIP

T0-REQ-SKIP no longer designates equality P16-REQ. Designated false is **P16-REQ-STRICT** `(2^96,1,2,false)`: original require refuses; after deleting only `numerator1 > product`, wrapped subtraction denominator is `2^256-2^96` and the mutant returns **1**. Equality `(2^96,1,1,false)` remains a required baseline/control (still publicly refuses via FullMath denominator 0). P16-ADD remains the unaffected positive.

Each token0 production mutant now has **one actual Solidity edit**:

| ID | Edit | Designated false public change |
| --- | --- | --- |
| T0-WRAP-SKIP | keep wrapped `numerator1 + product`; replace `if (denominator >= numerator1)` with `if (true)` | P16-WRAP → truncated FullMath `1430089493431239948923811608424801982436782118539` |
| T0-PROD-SKIP | keep `product = amount * sqrtPX96`; skip the fit test | P16-PROD → `2^96` |
| T0-ID-SKIP | delete Solidity `if (amount == 0) return sqrtPX96` | reaches high-level `/ amount` at amount 0; Python/Lean identity deletion is not this mutant; EVM classification at implementation |
| T0-CHECKED-ADD | `numerator1.add(product)` (LowGasSafeMath), not Operations.add | P16-WRAP reverts on the wrapping sum; actual payload bound later |
| T0-FLOOR | `mulDiv` instead of `mulDivRoundingUp` on line 44 | P16-ADD-ROUND 26409387504754779197847983446 → 26409387504754779197847983445 |

M09 stays the future Lean SwapMath direction mutation with model `invalidFee`/`intOverflow` preguards. F32 is a supported **model-side** sibling, not automatically a pinned Solidity control.

## R2 — public branch equations

Nonidentity removal refusal now requires `amount ≠ 0`. New diagnostics:

- P16-I-ZERO-LIQ `(2^96,0,0,false)` → `2^96`
- P16-SAFECAST `(2^159, 2^63+1, 1, false)`: require passes, FullMath `2^222+2^159`, SafeCast refuses
- P16-ADD-DEN0 `(0,0,1,true)`: FullMath denominator 0

Branch theorems are about the public helper with ordered Except composition (identity; FullMath then SafeCast on remove; FullMath then bare uint160 on add). Future local bounds, not proofs now: successful add result ≤ input sqrt; fallback with successful inner add has positive denominator and `sqrtP > 0`. UnsafeMath comment limitation stays distinct. Overflow partitions are not excluded. No source/assembly refinement claim.

## R3 — Signed

`Types.lean` plans only unsigned aliases, Q96, and token0/FullMath failures. Signed is not declared. Original mixed 2.1 signed/tick/fee/F45 residual is named in P21 `remaining-gates.json`. Historical tasks were not ticked or edited.

## Diagnostics

r2 supplement `diagnose_r2.py` SHA-256 `3a67fa580e11db0937b4028cc10041598fcee5b7f27d551bcb11775f143044ba`: **37/37** checks, 4 new witnesses, exit 0. `--empty-corpus` exit **3**.

r1 `diagnose.py` replayed from exact bytes `ad14dc08c1d3ea01eeaf5baf3b79d1ca3c460c47190c833f08a201aae8f2c20f` with write redirect: 44 checks, 8 cases, exit 0. Original `grok-r1/logs/diagnose.json` remains `174b14e1fdc4c4865bbd915bd3de9375bee65cd47c6960bedbdd02816ec7ad13`. Repaired oracle `d4ff08d0ebdee3818c24e13ac8abd2f6095f414282289930cacc740d88016279` unchanged. 65 r1 files match the pre-repair snapshot. No production mutation credit.

## Remaining gates

Lean/Arithmetic baseline, solc 0.7.6 acquisition, EVM identity at acquisition (not frozen here), compiled mutants with unaffected controls, branch proofs, independent re-review. Original 1.2 whole-task still open.
