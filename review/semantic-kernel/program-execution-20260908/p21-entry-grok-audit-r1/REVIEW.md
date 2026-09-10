# P21 source-entry and planning-repair audit

**Disposition: `PLAN_REPAIR_REQUIRED`.** This is not P21 acceptance. This is not acceptance of a repaired residual plan. This is not implementation authorization. This audit does not close program task 22.1.

Auditor: fresh native Grok4.6 high. Requested model `grok-4.6`. Independent of the future AGY Gemini3.8 Flash High planning author. Older GPT/Grok/Opus role text in frozen files is historical. No Foreman. No Lean. No rewritten full plan. No commits.

Read-only sandbox: `/home/charl/.cache/defiformal-program/program-execution-20260908/p21-entry-grok-audit-sandbox`. New evidence is only under this directory.

## Hash verification

`inputs.json` SHA-256 is `f07308e490939cd278643bdb38881203bf8d9b78e1d886b18d3bfb0b7a796d45`. All **114/114** listed sandbox files match. All **41/41** original archive members match preparation hashes for archive `e1cd08f9f8a843355f1b249a013c9de0d29e7e1ebf1d5a3e8716d6d7621baf77`. All **11/11** pinned source files in the preparation record match. P16 source, P16 proof, P17 root-adjudication, PLAN-ACCEPTANCE, sprint-index, and program tasks hashes match the preparation bindings.

The tar.gz archive itself is not in this sandbox. Only extracted members were hashed here.

Upstream remains historical Uniswap v3-core v1.0.0 commit `e3589b192d0be27e100cd0daaf6c97204fdb1899`, tree `f024dbf808e50091852f7cc8724d837543a8c7e5`. No new source was acquired. No current deployment behavior is inferred.

## What the future author must reconcile

The preserved original `concentrated-liquidity-library` freeze is a coherent first increment that **excludes** `UniswapV3Pool.swap` traversal. The accepted program P21 `successful_exit` **requires** residual TickMath, SwapMath, token1/delta, bitmap/liquidity/factory, all 45 fixtures, M01–M12 with repaired M09 controls, **and** declared multi-word/two-tick traversal with liquidity and amount/fee accounting.

Naming remainder `R-FULL-TRAVERSAL` cannot close R22, P21, or the program. Source readiness is not proof or implementation. P16 token0 source evidence and P17 platform reuse open their dependencies. They do not discharge P21.

Preserve the original failed scope and the original M09/F28 control record as evidence. Do not present them as the repaired slice.

## Residual ownership

### TickMath 3.1–3.3, including quantified monotonicity and inverse choice

Original 3.1–3.2 and F10–F19 are present and still P21-owned. Original 3.3 already requires bound refusals, forward monotonicity on `[MIN_TICK, MAX_TICK]`, and the final inverse choice equation. Spec scenarios T01–T06 are finite. T06 is five round-trips. Those finite checks are necessary. They are not a substitute for 3.3.

Pinned `TickMath.sol:203` is the choice equation:

`tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow`

The repaired plan must keep that equation and quantified forward monotonicity as generic proof obligations. The original proof-strategy already forbids a silent generic inverse-equals-greatest-tick claim.

### SwapMath 4.2 and residual 4.1 token1/delta

F28–F33 cover single-range `computeSwapStep`, including remainder-as-fee F29 and exact-output cap F30. Keep F30 as bounded success.

F20–F23 cover amount1/amount0 deltas. F24/F27 cover token0 next-price, which P16 already owns as a contribution. **No original fixture calls `getNextSqrtPriceFromAmount1RoundingDown`.** Program 22.3 still requires that helper. Add residual token1 next-price observations. Do not drop 4.1 because P16 is narrow.

Pinned token1 helper `SqrtPriceMath.sol:68-97`:

- add uses `LowGasSafeMath.add` then `toUint160()` (`:84`)
- remove uses `UnsafeMath.divRoundingUp` when `amount <= uint160.max` (`:89`), `require(sqrtPX96 > quotient)` (`:93`), then unchecked `uint160(sqrtPX96 - quotient)` (`:95`)
- the direct helper does not `require` liquidity or price, unlike `getNextSqrtPriceFromInput/Output`

### Bitmap/liquidity/factory 5.1–5.3

F34–F44 and task 5.3 already exist. They must stay, and they must **not** be described as whole-pool traversal. One-word search is `TickBitmap.sol:42-77`. Factory predicates are `UniswapV3Factory.sol:26-31` and `:61-67`, not a factory contract.

### 45 fixtures, 12 mutants, residual proof/runtime/audit/review

All 45 fixtures F01–F45 exist with `execution: not_run`. All 12 mutants exist as `PLANNED_NOT_IMPLEMENTED_OR_COMPILED`. P21 still owes the full campaign plus residual 6.2/6.4/6.5 and 7.1–7.3 as split contributions. Mixed original IDs close only after P16 contributions also exist.

P16 dropped unused Signed from the token0 slice. P21 still owns original 2.1 residual `Signed`/`I24`/`I128`/`I256` and F45.

## Traversal admission and observation boundary

Pinned `UniswapV3Pool.swap` distinguishes these observations:

| Class | Source | P21 status |
| --- | --- | --- |
| Pool admission refusal | `UniswapV3Pool.sol:608-613` `SPL` | **Declared refusal for this scope** |
| Bounded exact-output cap success | `SwapMath.sol:87-89` | **Success, already F30** |
| Limited traversal success | loop `:641-730`, two initialized crosses, amount/fee remaining `:673-679`, signed `liquidityNet` `:718-722` | **Required, missing from original plan** |
| Multi-word continuation | repeat one-word search after a word-edge miss (`TickBitmap.sol:57-75` uninitialized edge) | **Required, missing** |
| Source-independent negative | liquidity delta without a corresponding initialized cross | **Required, missing** |
| AS / LOK / lock / callback / IIA / payment / oracle write / protocol-fee split / deployed pool | `:603`, `:607`, `:615`, `:771-787`, `:698-707`, `:681-686` | **Named remainder unless later pinned and observed** |

`observation-contracts.json` currently labels `SPL` as out of scope. That is the failed original record. The repaired plan must reclassify `SPL` as the declared admission refusal and must **not** silently claim callbacks, payment, lock, or deployed-pool security.

Dependencies needed to state a meaningful limited traversal contract:

1. `nextInitializedTickWithinOneWord` plus MIN/MAX clamp (`:646-657`)
2. `TickMath.getSqrtRatioAtTick(tickNext)` (`:660`)
3. target versus `sqrtPriceLimitX96` selection (`:665-667`)
4. `SwapMath.computeSwapStep` (`:663-671`) including the exact-output cap
5. remaining/calculated amount updates (`:673-679`)
6. initialized `Tick.cross` liquidityNet (`Tick.sol:166-182`, used at `:709-717`)
7. direction sign `if (zeroForOne) liquidityNet = -liquidityNet` (`:718-720`)
8. `LiquidityMath.addDelta` (`:722`)
9. `tickNext - 1` when `zeroForOne` (`:725`)
10. otherwise `getTickAtSqrtRatio` when price moved (`:726-728`)

`Tick.cross` also writes fee/seconds outside fields. Binding text requires liquidity and amount/fee accounting. It does not require oracle identity. Name whether those outside writes are in or out.

`Pool.sol:719` comments that `liquidityNet` cannot be `int128.min`. That is a source comment. This audit did not prove it.

Required records the repaired plan must declare for this already-required scope:

- source correspondence for the slice above, with `UniswapV3Pool.swap` no longer wholesale `out_of_scope`
- two-initialized-tick success fixture with independent amount, fee, and liquidity literals
- multi-word continuation observation (two ticks in one word do not discharge “multi-word”)
- `SPL` refusal fixture
- skip-initialized-cross mutant (matrix characteristic). M07 remainder-fee is a different mutant
- source-independent liquidity-delta-without-cross negative
- theorems for signed liquidityNet application and step amount/fee accumulation

## M09 false/unaffected discrimination

Original M09 flips `zeroForOne` to `current < target`. Designated false is F31. Unaffected positive is F28. Pinned source predicate is `SwapMath.sol:37`: `bool zeroForOne = sqrtRatioCurrentX96 >= sqrtRatioTargetX96`.

Independent diagnostic on a **copy** of `cl_oracle.compute_swap_step`, changing only that assignment:

| Fixture | Baseline | After direction flip | Role |
| --- | --- | --- | --- |
| F28 | amountIn 2, amountOut 1, fee 1, zeroForOne true | amountIn **1**, amountOut 1, fee 1, zeroForOne false | Original unaffected control. **Affected.** |
| F31 | amountIn 1, amountOut 0, fee 1, zeroForOne false | amountIn 1, amountOut **1**, fee 1, zeroForOne true | Designated false. Detection is amountOut and/or zeroForOne, **not** amountIn. |
| F29 | 0/0/1 numeric, zeroForOne true | numerics same, zeroForOne false | Numeric-stable, direction-unstable. Frozen F29 has no zeroForOne field. |
| F30 | amountIn 3, next `2^96-1` | amountIn 2, next `2^96+1` | Affected. Cap remains success. |
| F32 | `invalidFee` | `invalidFee` | Unchanged **because the oracle refuses feePips≥1e6 before direction**. |
| F33 | `intOverflow` | `intOverflow` | Unchanged **because the oracle refuses int256 min before direction**. |

This is a diagnostic calculation. It is not a compiled mutant. Frozen literals were not changed. P16’s control-plan correction is not compiled SwapMath M09 evidence.

Concrete interference: F28 uses `current = 2^96 > target = 2^96-1`. The flip treats the step as one-for-zero and replaces amount0-in with amount1-in. amountIn 2 becomes 1. F28 cannot be an unaffected control.

Defensible replacement-control constraints from **existing** fixtures:

- Preserve the failed original M09/F28 record.
- Exclude F28 from compiled M09 unaffected controls.
- Repair CLE02/E03, which currently requires F28 true for every mutant including M09.
- **F32** is a defensible sibling only if production SwapMath refuses `feePips ≥ 1e6` before the direction predicate. That matches the original Lean/oracle plan and `observation-contracts.json` precedence. Pinned `SwapMath.sol` has no such guard. F32 is not a Solidity M09 sibling.
- **F33** has the same Lean-only constraint for `amountRemaining = -2^255`.
- **F29** may be used only if the published observation excludes direction and that limitation is named.
- **F01/F10/F40** do not call `computeSwapStep`. They are not same-function siblings.
- No existing success SwapMath fixture is fully observation-invariant when direction is observed.
- Freeze whether compiled M09 is Lean production, pinned Solidity, or both. Sibling validity depends on that choice.

## Source-width and refusal assumptions

Keep these named. Do not treat wrap as checked-div equivalence.

- Solidity 0.7.6 wrapping versus Lean checked strengthenings (`hardhat.config.ts` 0.7.6, F32/F33)
- `feePips < 1e6`: factory `enableFeeAmount` requires it (`UniswapV3Factory.sol:63`). SwapMath does not
- signed min negation: source wraps `uint256(-amountRemaining)`, Lean `intOverflow`
- token1 downcast: SafeCast on add (`:84`) versus unchecked `uint160` on remove (`:95`)
- UnsafeMath denominator: `y=0` unspecified (`UnsafeMath.sol:8-15`). Token1 remove-small and amount0 round-up call it
- one-word bitmap versus multi-word traversal
- FullMath assembly `mulmod`/CRT remainder (`FullMath.sol:26-54`) remains `G-FULLMATH-ASSEMBLY`
- source-differential remainder remains `G-NO-SOLC-DIFFERENTIAL` until a P21 campaign exists

P16 accepted twelve token0 source cases and six token0 mutants. P17 accepted scoped vault platform reuse. Neither is TickMath, SwapMath, token1, bitmap, traversal, or compiled M09.

## What this audit does not do

- It does not close 22.1. Root adjudicates and queues the AGY author after the current P19 batch.
- It does not accept P21 or original 1.2.
- It does not add acceptance bars beyond the binding program and source contracts.
- It does not implement Lean, compile mutants, or run solc/EVM.
- It does not touch AGY’s P19 worktree.

Unknowns are listed in `findings.json`. Commands that were inspection or diagnostic, versus compilation, are in `commands.json`. The mapping from 22.1–22.8 and original split IDs to needed planning artifacts is in `repair-checklist.json`.
