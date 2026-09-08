## Purpose

Correct the original M09/F28 control plan by diagnosis, and define compiled production token0 mutants with designated witnesses and unaffected controls. Compiled M09 SwapMath execution remains P21.

## ADDED Requirements

### Requirement: M09 must not treat F28 as a protected control

Original mutant M09 flips `zeroForOne` from `current >= target` to `current < target`. On original F28 that change moves `amountIn` from 2 to 1. P16 SHALL exclude F28 as protected, preserve the failed original plan, and MUST NOT claim compiled M09 execution.

#### Scenario: F28 amountIn 2 becomes 1
- **WHEN** original F28 `(Q96, Q96-1, Q96, 1000, 3000)` is evaluated under the flipped predicate
- **THEN** `amountIn` changes from 2 to 1 and F28 is removed from M09's protected/sibling set

### Requirement: Named unaffected sibling is actually diagnosed

M09 SHALL remain the future Lean `SwapMath` direction-predicate mutation with model `invalidFee`/`intOverflow` preguards. The repaired unaffected sibling SHALL be original F32 (`feePips = 1e6` → `invalidFee`) as a **model-side** control for that planned Lean helper. F32 is not automatically a pinned Solidity control: captured `computeSwapStep` has no such pre-predicate guard. F33 is an additional model-side control. F29 MUST NOT be named, even if some numeric fields stay put, because `zeroForOne` still flips.

#### Scenario: F32 invalidFee is unchanged under M09
- **WHEN** F32 is evaluated with the original and flipped predicates on the diagnostic Lean/model SwapMath
- **THEN** both refuse `invalidFee` and F32 is the named model-side sibling; compiled Solidity M09 remains P21

### Requirement: Production token0 mutants have designated false witnesses and controls

P16 production mutants SHALL each freeze one actual Solidity edit of the pinned helper, compile with the pinned compiler when source mutants are scored, and carry an individually verified unaffected control. Python-only edits and model-label changes earn no production credit. Compile or tool-setup failure is blocked, not detection, and MUST NOT be scored as source-execution failure. Actual EVM exceptional outcomes SHALL be recorded at implementation.

#### Scenario: Skip wrap-fallback mutant
- **WHEN** mutant T0-WRAP-SKIP replaces `if (denominator >= numerator1)` with `if (true)` while keeping wrapped native addition
- **THEN** P16-WRAP is designated false, the planned public mutant value is the truncated FullMath word, and P16-ADD remains an unaffected control

#### Scenario: Skip identity short-circuit mutant
- **WHEN** mutant T0-ID-SKIP deletes the Solidity `if (amount == 0) return sqrtPX96`
- **THEN** P16-I-ADD is designated false because the source reaches high-level division by amount at amount 0; deleting a Python/Lean identity that treats amount 0 as product-fit MUST NOT be scored as that mutant

#### Scenario: Strict-underflow require-skip mutant
- **WHEN** mutant T0-REQ-SKIP deletes only `numerator1 > product`
- **THEN** designated false is P16-REQ-STRICT `(2^96,1,2,false)` whose public result becomes 1, equality P16-REQ remains a refusing baseline/control, and P16-ADD remains the unaffected positive
