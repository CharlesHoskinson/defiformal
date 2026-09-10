# Token0 increment API (P18 v0.1.0)

## Library

| Item | Value |
| --- | --- |
| Function | `DefiKernel.ConcentratedLiquidity.SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp` |
| Module | `lean/DefiKernel/ConcentratedLiquidity/SqrtPriceMath.lean` |
| Observation helper | `DefiKernel.ConcentratedLiquidity.Examples.observeToken0` |
| Kind | pure function |
| Widths | `Word 160`, `Word 128`, `Word 256` |
| Result | `Except Failure U160` |

`Failure` constructors used by this helper:

- `subUnderflow` — removal `require` (product overflow or `numerator1 ≤ product`)
- `uint160Overflow` — remove-path `toUint160`
- `divisionByZero` — FullMath zero denominator
- `quotientOverflow` — FullMath quotient overflow
- `addOverflow` — checked fallback add (not wrapping Arithmetic.add)

Zero amount is identity success, not a refusal. Add-path overflow uses the
Solidity 0.7.6 wrapped-sum fallback; Lean `Operations.add` remains checked.

## Source pin (accepted P16)

- Upstream: Uniswap v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899`
- Helper span: `SqrtPriceMath.sol` lines 28–56
- Capture in this checkout: `review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/SqrtPriceMath.sol`
- SHA-256: `ddd62e3a94346248677f30f1ab009ef015e71e4b8696dcca890eeabc9dc6c149`
- Compiler settings: Solidity 0.7.6, optimizer on, 800 runs, `bytecodeHash: none`
- Versioned source-campaign archive: `review/semantic-kernel/program-execution-20260908/p16-source-candidate-r6.tar.gz` SHA-256 `8a8a9400e04a63ade06976959faca2a575e8158fa92f31d29e612cdc049ff981`

Do not substitute a private worktree path for that archive.

## Observation relation

`token0.pure.next-price`

- Inputs: `sqrtPX96`, `liquidity`, `amount`, `add`
- Pre-state: none
- Success: `uint160`
- Refusals: removal require, FullMath zero/overflow, fallback checked add, remove-path uint160 overflow
- Ledger history: false
- Not observed: pool swap, fees, vault shares, capabilities, sequential composition

## Supported example matrix

Twelve nonempty rows. Counts come from the accepted P16 campaign evidence, not
from directory names.

| Id | Behaviour |
| --- | --- |
| P16-I-ADD | identity add |
| P16-I-REM | identity remove |
| P16-I-ZERO-LIQ | identity with zero liquidity |
| P16-ADD | ordinary add `(2^96,1,1,true)=2^95` |
| P16-ADD-ROUND | ordinary add rounding |
| P16-REQ | removal require `(2^96,1,1,false)` |
| P16-REQ-STRICT | stricter removal require |
| P16-REM | ordinary remove success |
| P16-SAFECAST | remove-path uint160 overflow |
| P16-ADD-DEN0 | add zero denominator |
| P16-PROD | product-overflow fallback |
| P16-WRAP | denominator-sum overflow fallback |

Exact literals are in `expected/token0-observations.json` and in
`lean/DefiKernel/ConcentratedLiquidity/Examples.lean`.

## Invocation

1. Bind tools with `bind-environment.py` (records lake and verifies 4.33.0-rc2).
2. Run `run-token0-example.py --binding <receipt>`.
3. Optionally run `lake env lean DefiKernel/ConcentratedLiquidity/RuntimeAudit.lean` from `lean/`.

Do not replay the six compiled Solidity mutants from this example. Those
production mutants and unaffected ADD controls are reused by hash from the
accepted P16 source archive.

## Credit boundary

This API may be used as a model-verified arithmetic increment with bounded
source evidence. It does not close P30, P17, P21, P37, or independent P18
acceptance. Packet schema validity is not proof.
