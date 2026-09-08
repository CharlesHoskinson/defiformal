## Why

Roadmap §6 still requires Uniswap-style concentrated-liquidity arithmetic and tick traversal. Delivered Arithmetic supplies checked unsigned words and unbounded-product floor/ceiling division; it does not implement Q64.96 prices, signed ticks, directed swap-step fees, bitmap compression, or the pinned v3-core v1.0.0 sources. A rational conservation theorem cannot stand in for those functions.

## What Changes

- Add a new `DefiKernel.ConcentratedLiquidity` namespace with signed/unsigned widths used by the pinned libraries, mathematical FullMath, TickMath, SqrtPriceMath, SwapMath.computeSwapStep, TickBitmap next-initialized-within-one-word, LiquidityMath.addDelta, and factory fee/spacing predicates.
- Freeze exact refusal/observation contracts, independent literal fixtures, characteristic mutants, and a four-level claim map.
- Keep full `UniswapV3Pool.swap` traversal, Tick.cross/Position/Oracle, callback/payment/lock, assembly FullMath identity, compiler/EVM/deployment fidelity, and later differential tests as a named remainder. Do not silently close the whole roadmap item.
- Do not modify historical Arithmetic, Typed, Nary, corpus, holdout, assessment, or pinned Solidity bytes. Root import/build registration happens only after an accepted plan.

## Capabilities

### New Capabilities

- `cl-checked-words-fullmath`: signed int24/128/256 and unsigned 24/128/160/256 words; FullMath as floor/ceil of the exact natural product with zero-denominator and uint256 quotient refusals.
- `cl-tick-math`: `getSqrtRatioAtTick` / `getTickAtSqrtRatio` with bounds ±887272, min ratio inclusive, max ratio exclusive, and the integer bit-constant algorithm.
- `cl-sqrt-price-swap-step`: Q64.96 next-price and amount deltas with directional rounding and the 0.7.6 overflow-fallback branch; single-range `computeSwapStep` including exact-input remainder-as-fee and exact-output cap.
- `cl-tick-bitmap-liquidity`: floor compression of negative ticks, inclusive/exclusive one-word search, uninitialized word edges, signed liquidity deltas, and factory fee/spacing input predicates.
- `cl-library-evidence`: independent fixtures, characteristic mutants, proof/execution/assumption boundaries, and honest four-level claims.

### Modified Capabilities

None. Existing `checked-unsigned-arithmetic`, `directed-rounding-fees`, typed transitions, and historical theorems retain their statements.

## Impact

New Lean modules under `lean/DefiKernel/ConcentratedLiquidity/`, dedicated Verify/audit roots, and new scripts under `scripts/`. Evidence under `review/semantic-kernel/concentrated-liquidity/`. Parent-owned `lean/DefiKernel.lean` import after acceptance only.

This is official planning. It is not implementation, not a Lean proof, not compiler/EVM acceptance, and not a deployed Uniswap claim. Gate accepted remains false until independent GPT-6 review of this freeze.
