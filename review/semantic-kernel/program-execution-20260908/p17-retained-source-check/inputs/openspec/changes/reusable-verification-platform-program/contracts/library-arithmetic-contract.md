# Library amount, rounding, and error contract (P15 task 16.2)

**Status:** author freeze, pending independent GPT-6 review  
**Delivered library:** `DefiKernel.Arithmetic` at HEAD `01490b539b3d30bb992e0d6cfc603022d7be99a9`  
**Accepted historical package:** checked integer financial arithmetic, source candidate
`ddf1ac0e50f2e032385664a0965bab59eef91ea3`, archive delivery
`6d73e6dcf7b99c2b6cd1114985562a9f4081f4c4`  
(`review/semantic-kernel/integer-arithmetic/delivery.json`, SHA-256
`917a177bcabf9f560a33f7d39ba4130ffe0800a867ed9c1a8da095e624a69f01`)

This contract states what the delivered Arithmetic APIs actually do, and
separately states the P16 Solidity 0.7.6 wrapping obligation that those APIs
do **not** implement.

## 1. Machine width

`Word w` (`lean/DefiKernel/Arithmetic/Word.lean` 6–9, SHA-256
`5c0f467384bc3fe320ab363b7124f1c94b9ea688293c61cac7c5e08af8cb879b`):

- `value : Nat`
- `bound : value < 2^w`

Width is a type parameter. Width 0 contains only zero (`Word.width_zero`,
lines 69–72). Width 0 is a mathematical boundary. It is not a hardware claim
(OpenSpec `checked-unsigned-arithmetic` scenario W02).

`ofNat w n` / `Word.checked .inputOverflow n` (22–26) succeed iff `n < 2^w`.
Otherwise `inputOverflow`. There is no modular truncation in the delivered
constructor.

Typical EVM unsigned widths used later by P16 are 256, 160, and 128. Those
widths are representable as `Word 256`, `Word 160`, `Word 128`. Representability
is not a proof that Solidity 0.7.6 addition equals `Operations.add`.

## 2. Checked failures actually exported

`inductive Failure` (Word.lean 11–15):

| Constructor | Produced by | Meaning |
| --- | --- | --- |
| `inputOverflow` | `ofNat`, `Quantity.fromRat` last | value does not fit `2^w` |
| `addOverflow` | `Operations.add` | `a.value + b.value ≥ 2^w` |
| `subUnderflow` | `Operations.sub` | `a.value < b.value` |
| `mulOverflow` | `Operations.mul` | `a.value * b.value ≥ 2^w` |
| `divisionByZero` | `Rounding.divideNat` / `mulDiv` | denominator `= 0` |
| `quotientOverflow` | `mulDiv`, fee rounding | rounded quotient `≥ 2^w` |
| `invalidRate` | `Fees.validatedRate` | `den = 0` or `num > den` |
| `nonPositiveScale` | `Quantity.fromRat` first | `scale ≤ 0` |
| `negativeQuantity` | `fromRat` second | `scale > 0` and `amount < 0` |
| `nonIntegralQuantity` | `fromRat` third | not an exact natural multiple of scale |

`Operations.add/sub/mul` (`Operations.lean` 8–16, SHA-256
`081c4d29809a33b6377ab1746ae93f2f2a429f5fa307983331c4cb5fbc460485`)
header comment: “Checked addition, subtraction and multiplication without
modular wraparound.”

Exact characterizations:

- `add_error_iff`: `2^w ≤ a.value + b.value ∧ failure = addOverflow`
- `sub_error_iff`: `a.value < b.value ∧ failure = subUnderflow`
- `mul_error_iff`: `2^w ≤ a.value * b.value ∧ failure = mulOverflow`

Natural addition in Lean is unbounded. Overflow is a **checked refusal**,
not wrap.

Fixture F04 (`Arithmetic/Examples.lean` 120–122, 219): width 8, `255 + 1`
expects `.error .addOverflow`. Production mutant `wrap-add` replaced
`a.value + b.value` with `(a.value + b.value) % (2^w)` and made F04 false
(`mutations-r1/mutation-spec.json` needle/replacement, run exit 1,
`results.json` label `wrap-add`). That mutant is evidence that wrapping is
**not** accepted Arithmetic behavior.

## 3. Rounding direction

`inductive Rounding | down | up` (Word.lean 17).

`Rounding.divideNat` (`Rounding.lean` 12–16, SHA-256
`0bd0c65af77bc809f4ff3b8cb5d98ab7eca5be0e0e7216e9e88263e4e02649f0`):

1. `denominator = 0` → `divisionByZero` first
2. `down` → `numerator / denominator` (floor)
3. `up` → floor plus one iff remainder ≠ 0 (ceiling)

`mulDiv` (18–21) uses the **unbounded** natural product `a.value * b.value`,
then `divideNat`, then `Word.checked .quotientOverflow`. Intermediate product
need not fit in `Word w`. That is distinct from `Operations.mul`, which
refuses `mulOverflow` before any division (OpenSpec scenarios W05 vs W06).

Zero denominator precedes quotient overflow (`mulDiv_error_iff`,
`mulDiv_divisionByZero_iff`).

Directed error bounds versus exact `ℚ` division are proved
(`mulDiv_down_rational_error`, `mulDiv_up_rational_error`). Equality of
floor and ceiling holds iff the denominator divides the product
(`mulDiv_equal_iff_dvd`). Rounding proofs must use these directed
specifications. They must not silently equate a rounded word to the exact
rational formula.

## 4. Fees and quantity conversion

`Fees.validatedRate` (`Fees.lean` 15–16) refuses `invalidRate` before any
rounding subcall when `den = 0` or `num > den`. Rate numerators/denominators
are `Nat`, not truncated to `Word w`.

`feeFromGross` (18–24): fee from `gross * rate / den`, `charged = gross`,
`received = gross - fee`.  
`feeOnTop` (26–32): fee from `principal * rate / den`, `received = principal`,
`charged = principal + fee` (may `addOverflow`).

Successful quotes satisfy `charged = received + fee`
(`feeFromGross_conservation`, `feeOnTop_conservation`).

`Quantity.fromRat` error precedence (`Quantity.lean` 83–101, SHA-256
`df223e39db3d3de1070deba403075331bb801805cd95f02ccb8eeafed0ae569e`):

1. `nonPositiveScale`
2. `negativeQuantity`
3. `nonIntegralQuantity`
4. `inputOverflow`

`toQuantity` uses a positive scale and never truncates. Inverse conversion
refuses fractions rather than rounding them.

## 5. What delivered Arithmetic does not provide

These are **not** delivered APIs:

- modular wrap on add/mul
- signed `int24` / `int128` / `int256` with Solidity overflow rules
- shifts, bitmaps, Q64.96 constructors beyond using `Word` at those widths
- assembly `mulmod` / 512-bit `FullMath`
- `UnsafeMath` unspecified division-by-zero
- Uniswap token0 next-price

`Arithmetic.Rounding.mulDiv` and Solidity `FullMath.mulDiv` share a
mathematical intention (full product then quotient). That intention is not a
source correspondence proof. Source-readiness review
`/home/charl/defiformal/review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-review.md`
states this gap explicitly.

## 6. Pinned Solidity 0.7.6 wrapping (P16 obligation, not yet proved)

P16 must observe `getNextSqrtPriceFromAmount0RoundingUp` from Uniswap v3-core
`e3589b192d0be27e100cd0daaf6c97204fdb1899`,
`SqrtPriceMath.sol` lines 28–56.

Captured bytes (retained evidence, not copied into this freeze):

| File | SHA-256 | Bytes |
| --- | --- | --- |
| `SqrtPriceMath.sol` | `ddd62e3a94346248677f30f1ab009ef015e71e4b8696dcca890eeabc9dc6c149` | 10774 |
| `FullMath.sol` | `54087aee268a6938a85a408d7b14481b5c2c956c21508d5583f1bf48ec6d69ba` | 5118 |
| `UnsafeMath.sol` | `4d02353eb503e3111e25bd50104ac9b279f99e88d848e455262a3fbeb55c50e7` | 660 |
| `LowGasSafeMath.sol` | `394107ff2dbbaded5612452af5e77b4af9d0871b096c1514b0ea659b862fc46f` | 1696 |
| `SafeCast.sol` | `9aed494b56d3dd16b7d6535583ded2cdfb03dc80aaa919347b13d35fd597e8bf` | 1048 |
| `FixedPoint96.sol` | `219deb88ffbcdefa482be35051db586378e8523062bee592dd2c5fa7fb47ebd6` | 380 |
| `hardhat.config.ts` | `85cc32497cbb67a78cabc0716881891c258b7a3d42c1c9fe599c9279d60e8af2` | 1241 |

Declared compiler settings (`hardhat.config.ts` 32–45): Solidity **0.7.6**,
optimizer enabled, 800 runs, `metadata.bytecodeHash = 'none'`. No compiler
binary, install, or bytecode was verified in this freeze
(`captured_not_executed`).

### 6.1 Native 0.7.6 wrap versus checked Lean add

In Solidity 0.7.6, `uint256` `+` and `*` wrap modulo `2^256`.

Token0 add path (SqrtPriceMath.sol 38–47):

1. `product = amount * sqrtPX96` (wraps). Overflow test:
   `(product = amount * sqrtPX96) / amount == sqrtPX96`.
2. If the product fits: `denominator = numerator1 + product` (**native wrap**),
   then `if (denominator >= numerator1)` use
   `FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator)`.
3. If the product overflows **or** the wrapped sum is below `numerator1`,
   fall back to
   `UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount))`.

The `.add` on the fallback denominator is `LowGasSafeMath.add`
(LowGasSafeMath.sol 11–13): `require((z = x + y) >= x)` — **revert on
overflow**, not silent wrap.

Remove path (48–55): no wrap fallback. `require` that the product fits and
`numerator1 > product`, else revert. Difference uses native `-` after that
require. Return uses `SafeCast.toUint160` (SafeCast.sol 10–12). The add-path
success returns use a bare `uint160(...)` cast (lines 44 and 47).

`UnsafeMath.divRoundingUp` (UnsafeMath.sol 12–16) leaves division by zero
unspecified.

`FixedPoint96.RESOLUTION = 96`. `numerator1 = uint256(liquidity) << 96`.

### 6.2 Required P16 denominator-sum overflow branch

When the product fits in uint256 **and** `numerator1 + product` overflows
uint256, Solidity takes the wrapped-sum fallback. P16 must exercise that
branch. Unbounded Lean `Nat` addition and `Operations.add` (checked
`addOverflow`) both **miss** that branch if used as a silent substitute.

This freeze does **not** prove the fallback equation and does not execute
solc. The branch is `required_future` for P16. It cannot be excluded to pass.

Planned identity/refusal vectors from the program spec, not executed here:

| Inputs `(sqrtPX96, liquidity, amount, add)` | Declared observation | Status |
| --- | --- | --- |
| `(2^96, 1, 0, true)` or `add=false` | return `2^96` (identity success, not a refusal) | required_future |
| `(2^96, 1, 1, true)` | return `2^95` | required_future |
| `(2^96, 1, 1, false)` | `require` fails: `numerator1 > product` is false | required_future |
| product fits, `numerator1 + product` wraps | wrapped-sum fallback, not unbounded add | required_future |

The helper has **no fee parameter**. Token1, deltas, TickMath, SwapMath,
bitmap, factory, and compiled M09 SwapMath execution remain P21.

### 6.3 Existing Python oracle is not source execution

File:
`/home/charl/defiformal-wt-liquidity-grok-gpt6-20260908/review/semantic-kernel/concentrated-liquidity/planning/grok-gpt6-official-r1/cl_oracle.py`  
SHA-256 `4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd`,
13073 bytes.

Header (lines 9–10) models uint256 wrap **only** for wrapping multiplication
as an overflow test. The add path (178–185) then does:

```
denom = numerator1 + product   # Python unbounded int
if denom >= numerator1:        # true whenever product >= 0
    return mul_div_rounding_up(...)
```

That unbounded sum does not wrap. When Solidity would wrap the denominator
sum, this oracle stays on the primary FullMath path. That is the recorded
planning defect. P16 task 17.2 must repair the diagnostic oracle. Even after
repair, Python remains a **third implementation**, not pinned-source
execution, and not accepted source behavior.

A Python-only mutation earns no production mutation credit.

## 7. How P16 must use this contract

1. Use delivered `Word`, `ofNat`, `Operations` checked failures, and
   `Rounding.down`/`up` for any Lean word arithmetic that is claimed to be
   the accepted library.
2. Do not encode the token0 denominator sum as `Operations.add` if the
   observation is Solidity native wrap-plus-fallback.
3. State the branch-specific 0.7.6 fallback equation. Do not equate it to
   exact rational `liquidity * sqrtP / (liquidity ± amount * sqrtP)` alone.
4. Keep Python diagnostic and solc/EVM execution in separate obligation
   classes.
5. Typed wrap remains optional for arithmetic-only P16/P18. Kernel-platform
   evidence requires the library-to-Typed bridge named in the adapter
   contract.
