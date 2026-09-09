## Why

The accepted program allocates a narrow Uniswap v3 token0 next-price slice to P16, including the Solidity 0.7.6 wrapped denominator-sum fallback that the unaccepted whole-library plan missed. That slice needs an exact repaired planning package, a diagnostic oracle that actually takes the wrap branch, and an M09/F28 control-plan correction before Lean or compiled source work.

## What Changes

- Add a P16-only OpenSpec planning slice for `SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp` (v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899`, lines 28–56), FullMath substrate required by that helper, pinned compiler/EVM readiness, and nonempty fixture/mutation/proof inventories.
- Repair a **new copy** of the Python diagnostic oracle so uint256 denominator addition wraps and takes the source fallback. Keep the historical defective oracle as a source-independent disagreement witness. Python remains a third implementation.
- Diagnose original M09/F28: the SwapMath direction flip changes protected F28 `amountIn` 2→1. Exclude F28 as protected and name F32 as the model-side unaffected sibling for the planned Lean SwapMath with invalidFee/intOverflow preguards. This is control-plan correction, not compiled M09 execution. F32 is not automatically a pinned Solidity control.
- Freeze a concrete solc 0.7.6 / EVM acquisition and observation plan. The compiler binary is not installed or executed in this planning pass.
- Keep `gate_accepted` false until independent GPT-6 review of these exact bytes. Original mixed task 1.2 is only a P16 planning contribution here. P21 residuals stay open.

## Capabilities

### New Capabilities

- `token0-source-readiness`: pin closure, import closure, compiler settings, and the proposed compiler/EVM harness with an explicit missing-binary obligation.
- `token0-next-price-observation`: standalone helper relation, branch premises, required wrap fallback, refusal/identity distinction, and Lean API under delivered Arithmetic and P15 contracts.
- `token0-diagnostic-oracle`: repaired wrapped-sum oracle, independent expected arithmetic, defective-oracle disagreement, and nonempty diagnostic partitions.
- `token0-mutation-control-plan`: M09/F28 diagnosis, named unaffected sibling, and planned compiled production token0 mutants with designated witnesses/controls.
- `token0-planning-evidence`: review-gate rules, original-ID contribution limits, remaining gates, and inventory/axiom/review criteria.

### Modified Capabilities

None. Accepted P15 contracts and the frozen 37-sprint program remain unchanged inputs. This change does not edit `openspec/specs/` main specs.

## Impact

New files live under `openspec/changes/uniswap-token0-p16/`. Author r1 evidence is `review/semantic-kernel/uniswap-token0/p16/planning/grok-r1/` (immutable). Bounded r2 repair evidence is `review/semantic-kernel/uniswap-token0/p16/planning/grok-r2/`. Proposed later implementation paths are `lean/DefiKernel/ConcentratedLiquidity/` (not created here). No Lean, no Solidity compile, no mutation campaign, no source-tree edit, and no frozen-program checkbox is in this increment. Delivery, if later accepted, is parent-owned onto `semantic-kernel-pivot` only.
