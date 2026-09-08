## Context

See proposal.md for motivation. Inspected APIs are the delivered Arithmetic at source `ddf1ac0e50f2e032385664a0965bab59eef91ea3` / archive `6d73e6dcf7b99c2b6cd1114985562a9f4081f4c4`, currently byte-identical to HEAD `a12b7cac05a818cc8d35c2ca440b7170a2807e92` for the ten Lean files plus three Lake pins. Pinned Uniswap v3-core is official tag `v1.0.0`, commit `e3589b192d0be27e100cd0daaf6c97204fdb1899`, Git tree `f024dbf808e50091852f7cc8724d837543a8c7e5`, captured under `review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/` with verified raw/Git-blob closure. Historical pin, not latest or deployed. Solidity 0.7.6 from `hardhat.config.ts` is configuration evidence only; this worktree has no `solc` binary.

Existing `Word w` is unsigned with `value < 2^w`. `Rounding.mulDiv` uses the unbounded natural product then checks the final word. `Fees` is gross/on-top, not SwapMath. Typed balances are exact rationals. None of those is a Uniswap implementation correspondence.

M4 and Claims are not prerequisites. This package must not invent their future exports.

## Goals / Non-Goals

**Goals:**

- One coherent first increment: concentrated-liquidity *arithmetic* plus the *tick-index and one-word navigation* primitives that tick traversal uses.
- Executable Lean functions with independent mathematical specifications, exact named refusals, and `#eval` fixtures whose expected values are independent decimal literals.
- Reuse `Arithmetic.Rounding.mulDiv` / `divideNat` at width 256 for the documented FullMath floor/ceil specification.
- Record four claim levels and the full remaining `UniswapV3Pool.swap` obligation by name.

**Non-Goals:**

- Full pool swap loop, Tick.cross/update, Position, Oracle, TransferHelper, callback payment, lock, protocol-fee split, or in-range tick recomputation after a multi-step walk.
- Proof that FullMath assembly/`mulmod`/modular inverse equals unbounded natural division.
- Solidity 0.8 checked-arithmetic semantics, EVM opcode fidelity, gas, compiler acceptance, bytecode, or any deployed address.
- Replacing UnsafeMath zero-denominator with checked division under a claim of unchanged behavior.
- Curve, redemption, vault, margin, claims, workflows, corpus/holdout evaluation, or certificates/adapters.

## Decisions

### 1. First increment versus remainder

Three approaches were considered:

- A. TickMath-only toy. Too small: it does not give a usable swap-step or fee/rounding surface.
- B. Full `UniswapV3Pool.swap` including oracle, callback, and lock. Not constructible as a first increment: token/callback assumptions, storage, termination of an unbounded loop, and compiler/runtime semantics are not available here.
- C. Chosen: a dependency chain `signed words → FullMath math spec → TickMath → SqrtPriceMath → SwapMath.computeSwapStep → TickBitmap/BitMath → LiquidityMath.addDelta → factory fee/spacing predicates`.

Approach C is a real module/proof chain. It is *not* full tick traversal. Named remainder `R-FULL-TRAVERSAL` retains:

1. Price-limit versus next-tick target selection in the pool loop.
2. Repeated `computeSwapStep` until remaining is zero or the limit is reached.
3. Bitmap lookup, MIN/MAX tick clamp, `getSqrtRatioAtTick` of `tickNext`.
4. Initialized crossing, direction-dependent `liquidityNet` negation, `tickNext - 1` when `zeroForOne`.
5. Protocol/LP fee growth, oracle observe/write, final slot0/liquidity writes.
6. Output transfer, swap callback, incoming-balance check (`IIA`), event, unlock, `AS`/`LOK`/`SPL` entry refusals.

`computeSwapStep` ≠ that loop. Completing this increment must not check the roadmap box.

### 2. Four claim levels

| Level | This increment |
| --- | --- |
| L1 Pure mathematical library | In scope. Lean functions and theorems over `Nat`/`Int`/`Word`/`Signed`. |
| L2 Executable FormalDeFi model | In scope as pure functions plus `SwapStep` records. Not a Typed pool transition and not Composition/Atomic embedding. |
| L3 Pinned-source correspondence | Partial: documented FullMath floor/ceil; TickMath/SqrtPriceMath/SwapMath/TickBitmap/LiquidityMath as integer algorithms with named gaps. Not assembly identity. |
| L4 Deployed fidelity | Out of scope. No chain, address, block, periphery, or bytecode. |

### 3. Namespace, failures, and reuse

Create `DefiKernel.ConcentratedLiquidity`. Do not extend historical `Arithmetic.Failure`. New constructors:

`divisionByZero`, `quotientOverflow`, `tickOutOfBounds`, `ratioOutOfBounds`, `priceZero`, `liquidityZero`, `uint256Overflow`, `uint160Overflow`, `addOverflow`, `subUnderflow`, `liquidityUnderflow`, `liquidityOverflow`, `intOverflow`, `invalidFee`, `invalidSpacing`, `zeroDenominatorUnsafe`, `bitMathZero`.

Map `Arithmetic.Rounding.mulDiv` errors into `divisionByZero` / `quotientOverflow` only. Unsigned words reuse `Arithmetic.Word`. Signed words are new:

```lean
structure Signed (w : Nat) where
  value : Int
  bound_lo : -(2^(w-1) : Int) ≤ value
  bound_hi : value < (2^(w-1) : Int)
```

Require `w ≥ 1` at the public aliases `I24 := Signed 24`, `I128 := Signed 128`, `I256 := Signed 256`. `U24/U128/U160/U256` abbreviate `Word`. Q64.96 prices are `Word 160` with scale `Q96 = 2^96`. Fee pips are `Word 24` or `Nat` with explicit `< 10^6` check at SwapMath/factory predicates.

No silent modular construction. `ofNat`/`ofInt` refuse out-of-range inputs.

### 4. FullMath: mathematical specification, assembly gap

Documented source spec: `floor(a×b÷d)` and `ceil(a×b÷d)` as uint256, refuse `d=0` or quotient `≥ 2^256`. Intermediate 512-bit products are allowed.

Lean:

```lean
def mulDiv (a b d : Word 256) : Except Failure (Word 256)
def mulDivRoundingUp (a b d : Word 256) : Except Failure (Word 256)
```

Implementation calls `Rounding.mulDiv .down` / `.up` and remaps errors. Theorems are the existing floor inequalities / ceiling leastness at `w=256`. This is L1 and the *documented* L3 spec. It is **not** a proof of the assembly `mulmod`/CRT/modular-inverse path. Named gap `G-FULLMATH-ASSEMBLY`.

Denominator width: source denominators are uint256. `Rounding.mulDiv` already accepts a `Nat` denominator; public CL wrappers take `Word 256` so a zero word is `divisionByZero` and a nonzero word is a positive `Nat`.

### 5. Solidity 0.7.6 wrapping versus checked Lean

Pinned sources compile as 0.7.6. There is no implicit 0.8 overflow revert. SqrtPriceMath detects uint256 multiply overflow by wrap-then-divide: `(product = amount * sqrtPX96) / amount == sqrtPX96`. Lean models that test as `amount * sqrtPX96 < 2^256` (unbounded). On failure of the add-token0 first formula, the source uses the fallback `UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount))`. The two expressions are distinct branches, not an identity.

One add-token0 success path downcasts with `uint160(...)` without `SafeCast` (0.7.6 truncation). Lean refuses `≥ 2^160` as `uint160Overflow`. Fixtures use in-range results. Named gap `G-UINT160-UNCHECKED-DOWNCAST`.

`amountRemaining = type(int256).min` on the exact-output path: source negation wraps; Lean returns `intOverflow`. Named gap `G-INT256-MIN-NEGATION`.

`feePips ≥ 10^6`: source `1e6 - feePips` wraps; Lean returns `invalidFee`. Factory `enableFeeAmount` requires `fee < 1000000`. Named strengthening `G-FEE-PIPS-FACTORY-CONTEXT`.

Do not treat wrap as checked-div equivalence.

### 6. UnsafeMath

`UnsafeMath.divRoundingUp` leaves `y=0` unspecified. Lean internal helper refuses `zeroDenominatorUnsafe`. Public SqrtPriceMath paths only call it after `sqrtPX96>0` or other established positive denominators. This is a model strengthening, not a drop-in replacement. Named gap `G-UNSAFEMATH-ZERO`.

### 7. TickMath

Constants (source and Lean):

- `MIN_TICK = -887272`, `MAX_TICK = 887272`
- `MIN_SQRT_RATIO = 4295128739` (inclusive inverse input)
- `MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342` (exclusive inverse input)

`getSqrtRatioAtTick` implements the source bit-constant loop, optional `type(uint256).max / ratio` for `tick>0`, and the Q128.128 → Q64.96 round-up `((ratio >> 32) + (ratio % 2^32 == 0 ? 0 : 1))`. Refuse `|tick| > MAX_TICK` as `tickOutOfBounds` before the loop. Independent oracle confirms the named min/max ratios equal the algorithm at `±887272`, and tick 0 equals `2^96`.

In-range bit multiplications are `Nat` products with a proved or checked `product < 2^256` obligation so wrapping vs unbounded coincide.

`getTickAtSqrtRatio` Lean implementation follows the source msb/log/tickLow/tickHi/final-choice algorithm. The *independent specification* used by fixtures is: greatest tick `t` with `getSqrtRatioAtTick t ≤ sqrtPriceX96`. Proof plan: refuse outside `[MIN_SQRT_RATIO, MAX_SQRT_RATIO)`; prove the final choice equation; prove forward monotonicity on `[MIN_TICK, MAX_TICK]`; finite-check the greatest-tick property on F16–F19 and the selected forward ticks. A generic inverse-correctness theorem is desired if constructible without `sorry`; it is not a silent substitute for the finite checks if it is not proved.

### 8. SqrtPriceMath and SwapMath

Widths: price `uint160`, liquidity `uint128`, amounts `uint256`, signed overloads `int128` liquidity / `int256` amounts. Directional rounding matches source comments: amount0 next-price rounds up; amount1 next-price rounds down; amount deltas take an explicit `roundUp` flag; signed helpers round against the caller when liquidity is negative.

`getNextSqrtPriceFromInput/Output` refuse `sqrtPX96=0` or `liquidity=0`.

`computeSwapStep(current, target, liquidity, amountRemaining, feePips)`:

- `zeroForOne := current ≥ target`
- `exactIn := amountRemaining ≥ 0`
- exact-in: `amountRemainingLessFee = mulDiv(remaining, 1e6-feePips, 1e6)`; compare to target amount-in (round up); either snap to target or `getNextSqrtPriceFromInput`
- exact-out: compare `|remaining|` to target amount-out (round down); either snap or `getNextSqrtPriceFromOutput`
- recompute in/out unless the max+exact shortcut applies
- cap exact-out `amountOut` to `|remaining|`
- if exact-in and next ≠ target: `feeAmount = remaining - amountIn`; else `mulDivRoundingUp(amountIn, feePips, 1e6-feePips)`

Invariants must be derived from these branches and explicit input validity (`feePips < 1e6`, nonzero liquidity/price where required, representable signed remaining). Do not assume “fees conserve” as a premise.

### 9. TickBitmap and LiquidityMath

`compress(tick, spacing)` is floor division: Solidity truncates toward zero, then `if tick < 0 && tick % spacing != 0 { compressed-- }`. Lean may implement `Int.fdiv` with a proof of equality to that adjustment.

`position(compressed)`: `wordPos = compressed >> 8` (arithmetic), `bitPos = uint8(compressed % 256)` which for negatives is Euclidean bit 255 of word `-1` at compressed `-1`.

`nextInitializedTickWithinOneWord` is a total function on a finite word map `Int → Word 256` defaulting to 0. It is not whole-pool traversal. `lte=true` includes the current bit; `lte=false` starts at `compressed+1`. Empty masked word returns the word edge (`compressed - bitPos` or `compressed+1+(255-bitPos)`) with `initialized=false`.

`addDelta(x: U128, y: I128)`: negative `y` refuses when `z ≥ x` (`LS` → `liquidityUnderflow`); nonnegative refuses when `z < x` or `z ≥ 2^128` (`LA` → `liquidityOverflow`).

Factory predicates, not the factory contract: builtin pairs `(500,10)`, `(3000,60)`, `(10000,200)`; `fee < 1_000_000`; `0 < spacing < 16384`. SwapMath does not itself enforce these; the predicates are explicit input context.

### 10. Modules, proofs, evidence

New files, runtime definitions before `-- BEGIN PROOFS`:

`lean/DefiKernel/ConcentratedLiquidity/{Types,FullMath,TickMath,BitMath,SqrtPriceMath,SwapMath,TickBitmap,LiquidityMath,FactoryContext,Examples,Tests,RuntimeAudit,ProofAudit,Verify}.lean`

No `sorry`, custom axioms, or `native_decide` in accepted proofs. Axiom audit uses existing `#audit_axioms DefiKernel.ConcentratedLiquidity` with the standard `{propext, Classical.choice, Quot.sound}` allowlist. Empty theorem scope is blocked.

Proof roles:

- Generic: FullMath iff, addDelta iff, compress floor, TickMath bounds/monotonicity/refusal, SwapStep branch equations under the actual `if` conditions.
- Finite: 45 named fixtures via `#eval`.
- Source correspondence: per-function kind in `source-correspondence.json`.
- Later differential vs `solc 0.7.6`: planned only; `solc`/`yarn` are absent. Gap `G-NO-SOLC-DIFFERENTIAL`.

Scripts after acceptance: `scripts/check_concentrated_liquidity_mutations.py`, `scripts/test_concentrated_liquidity_runner.py`, `scripts/check_concentrated_liquidity_evidence.py`. Reuse accepted integer-arithmetic runner patterns after reading their *then-current* source. Exit 0 nonempty complete evidence; 1 well-formed semantic miss; 3 blocked. A compile failure is blocked, not detection.

### 11. Observations and fixtures

Success is `Except.ok` with every numeric field compared as decimal strings. Refusal is `Except.error` with the named constructor; no fabricated post-state. Source revert strings (`T`,`R`,`LS`,`LA`,`AS`,`LOK`,`SPL`,`IIA`) are labels, not EVM identity.

Fixtures F01–F45 live in `fixtures.json` with independently computed literals from `cl_oracle.py` (Python int). They are not Lean outputs. Characteristic cases include phantom 2^256 product, TickMath 0/±1/min/max, min-ratio inclusive / max exclusive, amount0/1 rounding, overflow fallback, remainder-as-fee, exact-output cap, negative floor compression, uninitialized word edge, LS/LA, and the two named model strengthenings.

Mutants M01–M12 each change one production runtime expression, compile under the frozen projection, falsify a designated fixture, keep global positives F01/F10/F28/F40 and a sibling positive. Count is characteristic, not a quota.

## Risks / Trade-offs

- [Risk] Treating FullMath math spec as assembly proof → Mitigation: `G-FULLMATH-ASSEMBLY` remains open; theorems cite `Rounding.mulDiv`.
- [Risk] Silent wrap→checked replacement → Mitigation: explicit 0.7.6 wrap tests; named gaps for int256 min, uint160 downcast, fee pips.
- [Risk] Claiming full traversal from one swap step → Mitigation: remainder list R-FULL-TRAVERSAL; roadmap box stays open.
- [Risk] Tautological “fees conserve” theorems → Mitigation: derive equalities from the actual remainder versus `mulDivRoundingUp` branches.
- [Risk] Inverse TickMath generic proof too large → Mitigation: finite greatest-tick fixtures plus choice/monotonicity; generic inverse is extra, not a fake close.
- [Risk] solc assumed present → Mitigation: no L3 compiler claim; differential plan is not constructible in this worktree.

## Migration Plan

1. Independent GPT-6 planning review of this freeze. Gate accepted stays false until that review.
2. After acceptance: private Lean cache, implement Types/FullMath/TickMath, then SqrtPriceMath/SwapMath, then bitmap/liquidity, then evidence.
3. Parent-owned root import, native Grok implementation, independent GPT-6 evidence review, deliver to `semantic-kernel-pivot`, archive OpenSpec. No merge to main.
4. Remainder R-FULL-TRAVERSAL is a later package. Curve/redemption/vault/margin/claims stay separate agenda items.

## Open Questions

None that change this increment’s specs, APIs, fixtures, or remainder boundary. solc 0.7.6 acquisition is a later constructibility question for L3 compiler differentials, not for this plan.
