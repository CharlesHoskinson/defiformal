# P16 token0 planning slice — Grok 4.6 author r1

**Status: pending_independent_gpt6_review. Not acceptance.** Native Grok 4.6 authored the exact repaired P16 token0 planning/source-readiness slice plus diagnostic oracle and M09/F28 control-plan repair. Independent GPT-6 has not reviewed these bytes. `gate_accepted` is false. No Foreman. No commit or push. No Lean implementation. No solc/EVM execution. No mutation campaign. Frozen program tasks 17.1–17.6 were not ticked. Original 1.2 is only a P16 planning contribution.

- **Requested author:** native Grok 4.6
- **Returned author telemetry:** not separately recorded in this harness; role is native Grok 4.6 author
- **Independent checker:** required next; not run
- **Worktree:** `/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908`
- **HEAD:** `de0e03ed45c1073c6d01f7213303530aafcb9e4f` branch `work/p16-token0-grok-gpt6-20260908`
- **Change:** `openspec/changes/uniswap-token0-p16/`
- **Evidence:** `review/semantic-kernel/uniswap-token0/p16/planning/grok-r1/`

## What this slice is

A P16-only OpenSpec planning package for `SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp` (v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899`, lines 28–56), FullMath substrate required by that helper (original 1.3 and 2.2–2.3), a repaired diagnostic oracle, an M09/F28 control-plan correction, and a concrete compiler/EVM acquisition plan. E2: P16 does not wait on P21.

Counts: 5 capabilities, 21 requirements, 23 scenarios, 20 unchecked implementation tasks. `openspec validate uniswap-token0-p16 --strict` exits 0 after one preserved warning failure.

## Pin closure (compared, not self-asserted)

| Item | Digest |
| --- | --- |
| CURRENT.json `lanes[id=liquidity].candidate.sha256` | `e1cd08f9f8a843355f1b249a013c9de0d29e7e1ebf1d5a3e8716d6d7621baf77` |
| Retained archive | same, match true |
| Defective oracle retained + witness | `4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd` (13073 bytes) |
| Repaired oracle | `d4ff08d0ebdee3818c24e13ac8abd2f6095f414282289930cacc740d88016279` (13525 bytes) |
| Pin commit / tree | `e3589b192d0be27e100cd0daaf6c97204fdb1899` / `f024dbf808e50091852f7cc8724d837543a8c7e5` |

Token0 import closure from actual source bytes: FullMath, UnsafeMath, LowGasSafeMath, SafeCast, FixedPoint96. SHA-256 and git-blob identities match the retained tree for those six libraries plus `hardhat.config.ts`. Compiler source settings: Solidity 0.7.6, optimizer 800, `bytecodeHash none`. Add-path success uses bare `uint160` casts; remove uses `SafeCast.toUint160`. UnsafeMath assembly is `add(div(x,y), gt(mod(x,y),0))` with a comment that division by zero is unspecified.

`contracts/test/SqrtPriceMathTest.sol` exists in the pinned tree (blob `41fec2f54ed7ec9b0c6a5700a08df314a14dac4d`) but was not in the 41-file capture. The harness plan uses a new `Token0Probe` over captured libraries, or that exact blob later. Captured library bytes were not edited.

The unaccepted whole-library plan was extracted read-only under `original-planning-input/`. The historical tar was not overwritten.

## Compiler / EVM (not installed, not executed)

`command -v solc` and `command -v evm` are empty on this host. Official linux-amd64 0.7.6 identity was retrieved from `https://binaries.soliditylang.org/linux-amd64/list.json` (SHA-256 `78b63682e0e994bfbdf432b5eb1837b6d5190a21256e5e22971673bdc41bb0ce`):

- binary `solc-linux-amd64-v0.7.6+commit.7338295f`
- sha256 `bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb`

The binary was **not** downloaded. Yarn.lock `solc@0.7.3` is not the pin. Standard-json compile with optimizer 800, `bytecodeHash none`, `evmVersion istanbul` is the plan. Runtime observation is ABI uint160 or EVM revert; Lean Failure names are not assumed equal to returndata. Missing binary remains `not_established`.

Host Lean is 4.33.1. The repo pin is `leanprover/lean4:v4.33.0-rc2`. Implementation must use the repo pin.

## Diagnostic oracle

The defective copy models uint256 wrap only for the product-fit test, then adds `numerator1 + product` in unbounded Python, so `denom >= numerator1` never fails and the wrap fallback is skipped.

The new copy wraps that sum modulo `2^256`. Python is a third implementation.

Independent expected arithmetic (not oracle self-output):

| ID | Inputs | Expected | Branch |
| --- | --- | --- | --- |
| P16-I-ADD | (2^96,1,0,true) | 2^96 | identity |
| P16-I-REM | (2^96,1,0,false) | 2^96 | identity |
| P16-ADD | (2^96,1,1,true) | 2^95 | primary |
| P16-ADD-ROUND | (2^96,1,2,true) | ceil(2^96/3)=26409387504754779197847983446 | primary remainder |
| P16-REQ | (2^96,1,1,false) | require | numerator1==product |
| P16-REM | (2^96,2,1,false) | 2^97 | remove primary + SafeCast |
| P16-PROD | (2^96,2^96,2^160,true) | 2^32 | product-overflow fallback |
| P16-WRAP | MAX_SQRT_RATIO−1, max uint128, amount 79231140577496994670249413376, add | 340269576638287423012608907232989748562 | wrapped-sum fallback |

Defective unbounded mulDiv on P16-WRAP is `340269576638287423012608907228695104132`. They disagree. Ordinary identity/add still agree, so the defective oracle is not globally wrong.

**Finding preserved:** `(2^96, max uint128, 2^160−2^128+2, true)` is a wrap-premise vector where both oracles return `2^64`. Wrap premise alone does not discriminate. P16-WRAP does.

`diagnose.py`: 44 checks, 8 cases, 0 failures, exit 0. `--empty-corpus` exits 3 with denominator 0. Python 3.14.4 `/usr/bin/python3`. Script SHA-256 `ad14dc08c1d3ea01eeaf5baf3b79d1ca3c460c47190c833f08a201aae8f2c20f`.

## M09 / F28

Original plan protects F28 under M09 (direction flip `current ≥ target` → `current < target`). Diagnosed, not compiled:

- F28 original `amountIn=2`; M09 `amountIn=1`. F28 is excluded as protected.
- F31 still designated false (it changes).
- **Named unaffected sibling: F32** (`feePips=1e6` → `invalidFee` before the predicate). Both polarities refuse `invalidFee`.
- F33 `intOverflow` is an additional same-module control.
- F29 numeric fields can stay 0/0/1 but `zeroForOne` flips; not named.

Compiled M09 SwapMath execution is P21. The failed original `planned-mutations.json` is preserved in the extract.

## Production mutants (planned)

T0-ID-SKIP, T0-WRAP-SKIP, T0-PROD-SKIP, T0-REQ-SKIP, T0-FLOOR, T0-CHECKED-ADD. Each has a designated false P16 fixture and P16-ADD as the ordinary unaffected control except where noted. T0-FLOOR uses P16-ADD-ROUND as designated false because P16-ADD is exact. None compiled. Python-only edits earn no production credit.

## Proof / remainders

Wrap-fallback theorem premises: add, amount ≠ 0, product fits, unbounded sum ≥ 2^256, inner LowGasSafeMath.add fits. Conclusion is `ceil(numerator1 / ((numerator1 / sqrtPX96) + amount))`, not unbounded rational rearrangement. Typed wrap optional for P16/P18. P17 platform reuse still needs a token0-to-kernel bridge. P21 residuals keep original IDs 3.x, 4.1 remainder, 4.2, 5.x, 6.1 remainder, compiled 6.3/M09, 7.4.

## Failures preserved

1. OpenSpec `--strict` attempt 1: two RFC 2119 warnings, exit 1 (`logs/openspec-strict-attempt1.stderr`). Fixed by adding SHALL/MUST. Success is a later command.
2. Defective oracle wrap disagreement (planning defect, not silently repaired in place).
3. Accidental Q96 wrap agreement.
4. Original M09/F28 control-plan failure.
5. Missing solc/evm on this host.
6. Host Lean 4.33.1 ≠ repo pin 4.33.0-rc2.

## What was not done

Independent GPT-6 review. Lean. solc download/compile. EVM run. Production mutants. Ticking frozen 17.1–17.6. Whole original 1.2 acceptance. P21 planning. Commit/push.
