## Context

See proposal.md for motivation. Inputs are accepted P15 contracts at delivery `66ec8833186ca24066dbc5427c399c165a995cee`, delivered Arithmetic (`Word`, `Operations` checked add/mul, `Rounding.mulDiv`), captured v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899`, and the unaccepted liquidity planning archive SHA-256 `e1cd08f9f8a843355f1b249a013c9de0d29e7e1ebf1d5a3e8716d6d7621baf77` compared to CURRENT.json. PLAN-ACCEPTANCE editorial interpretation E2: P16 does not wait for P21 planning or implementation. This design does not implement Lean.

Host observation, not the Lean pin: this author environment's `lean` is 4.33.1. Implementation SHALL use the repository `lean/lean-toolchain` pin `leanprover/lean4:v4.33.0-rc2` and mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.

## Goals / Non-Goals

**Goals:**

- Exact P16 planning/source-readiness slice plus diagnostic oracle and M09/F28 control-plan repair.
- Concrete API, branch premises, fixture literals, production-mutant edit sites, compiler/EVM acquisition, and review criteria for later implementation.
- Preserve original failures: defective oracle, accidental wrap-agreement vector, failed original M09/F28 plan.

**Non-Goals:**

- Lean modules, lake build, `#eval`, or proofs in this increment.
- solc install, EVM run, or compiled mutants in this increment.
- TickMath, SwapMath implementation, token1/delta, bitmap, factory, 45-fixture campaign, compiled M09.
- Typed kernel wrapper (optional later). P17 platform reuse.
- Ticking frozen program tasks 17.1–17.6 or self-accepting the gate.

## Decisions

### 1. Namespace and files (proposed, not created)

`DefiKernel.ConcentratedLiquidity` under `lean/DefiKernel/ConcentratedLiquidity/`.

| Module | P16 content |
| --- | --- |
| `Types.lean` | `Failure` constructors needed by token0/FullMath, width aliases `U128/U160/U256`, `Q96 = 2^96`. Do **not** declare `Signed`. Original mixed 2.1 signed/tick/fee/F45 residual stays P21. |
| `FullMath.lean` | `mulDiv` / `mulDivRoundingUp` wrapping `Arithmetic.Rounding.mulDiv` at width 256 (original 2.2–2.3). |
| `SqrtPriceMath.lean` | Only `getNextSqrtPriceFromAmount0RoundingUp`. |
| `Examples.lean` / `Tests.lean` | P16 fixtures, not F10–F45. |
| `RuntimeAudit.lean` / `ProofAudit.lean` / `Verify.lean` | Nonempty theorem inventory, `#audit_axioms`, no `sorry` / custom axioms / `native_decide`. |

Do not add token1, deltas, SwapMath, TickMath, or bitmap modules in P16.

### 2. Failure labels versus source reverts

Model constructors used by token0:

| Label | When the model uses it | Source mechanism |
| --- | --- | --- |
| identity success | `amount = 0` | `return sqrtPX96` |
| (none; ok) | primary / fallback success | uint160 value |
| `subUnderflow` or a dedicated `requireFailed` | remove path `numerator1 ≤ product` or product overflow | `require(...)` empty payload in 0.7.6 |
| `addOverflow` | fallback `(numerator1 / sqrtPX96).add(amount)` overflows | LowGasSafeMath `require((z=x+y)>=x)` |
| `divisionByZero` / `quotientOverflow` | FullMath | `require` on zero denominator / quotient overflow |
| `uint160Overflow` | remove-path SafeCast when FullMath word `≥ 2^160` | add path: source bare `uint160` truncates; no observed reachable add-truncation mismatch. Future local bound: successful add result ≤ input sqrt. Do not invent a source add-path refusal. |
| `zeroDenominatorUnsafe` | not a public-helper observation under planned fallback reachability | Source comment leaves UnsafeMath `y==0` unspecified. Distinct from helper reachability: wrap/product-overflow fallback with successful inner add has `sqrtP>0` and a positive denominator. |

Correspondence is a planned relation. Do not assume Lean constructor names equal returndata.

### 3. Branch premises (add path)

`numerator1 = uint256(liquidity) << 96`.

1. `amount = 0` → return `sqrtPX96` (identity).
2. Else `product = amount * sqrtPX96` (native wrap). Product fits iff `(product / amount == sqrtPX96)` when `amount ≠ 0`, modelled as `amount * sqrtPX96 < 2^256`.
3. If product fits: `wrapped = (numerator1 + product) mod 2^256`. If `wrapped ≥ numerator1` (equivalently the unbounded sum fits), return `uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, wrapped))`.
4. Else (product overflow **or** wrapped sum `< numerator1`): return `uint160(UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount)))`. Inner `.add` is checked; it reverts rather than wrapping.

Required wrap theorem premises: add, `amount ≠ 0`, product fits, `numerator1 + product ≥ 2^256`, inner add fits. Conclusion on the **public** helper: source bare uint160 of `ceil(numerator1 / ((numerator1 / sqrtPX96) + amount))`. Future local bound: that inner denominator is positive and `sqrtPX96 > 0`.

Remove path, `amount ≠ 0`: require product fits **and** `numerator1 > product`; then FullMath; then `SafeCast.toUint160`. Success needs both callees. Identity (`amount = 0`) precedes this path, including `(2^96,0,0,false)`.

Primary-add FullMath denominator 0 is a public refusal: `(0,0,1,true)`.

### 4. Admissibility and local model bounds

Standalone input domain: any representable `(uint160, uint128, uint256, bool)`. Overflow partitions stay in scope. Pool-reachable subset is a P21 remainder. Do not exclude overflow to pass.

Named **local model bounds / reachability** (future proof obligations, not proved here):

1. A successful add result is ≤ the input sqrt price. This may justify representing the source bare uint160 as `Word 160` without inventing a source truncation refusal.
2. Reaching fallback with a successful checked inner add gives a positive denominator; fallback selection with product fitting excludes `sqrtP = 0`.

Keep the source UnsafeMath `y==0` comment limitation distinct from that helper reachability. Universal source/assembly refinement stays open (P30).

### 5. FullMath substrate

Call `Rounding.mulDiv .down/.up` then remap `divisionByZero` / `quotientOverflow`. Theorems are the existing floor/ceil specifications at `w=256`. This is not assembly identity (`G-FULLMATH-ASSEMBLY`). Fixtures F01–F09 from the unaccepted plan are substrate, not the original 45-fixture campaign.

### 6. Python oracles

| Copy | SHA-256 | Role |
| --- | --- | --- |
| retained / witness `cl_oracle_defective.py` | `4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd` | unbounded sum; wrap disagreement witness |
| `cl_oracle_repaired.py` | `d4ff08d0ebdee3818c24e13ac8abd2f6095f414282289930cacc740d88016279` | wrapped denom; diagnostic only |

Expected values in diagnostics are independent formulae, not the repaired function's output.

### 7. Compiler / EVM harness (proposed, not run)

Official identity from `https://binaries.soliditylang.org/linux-amd64/list.json` (list SHA-256 `78b63682e0e994bfbdf432b5eb1837b6d5190a21256e5e22971673bdc41bb0ce`):

- path `solc-linux-amd64-v0.7.6+commit.7338295f`
- sha256 `bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb`
- keccak256 `995f7d67d87a936dca9922389e6bdbfd2febb3aabe52beed5a43f73fb45a5146`
- URL `https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.7.6+commit.7338295f`

Do **not** use yarn.lock `solc@0.7.3`. Do not install in this planning pass.

Compile with standard-json, optimizer enabled 800 runs, `metadata.bytecodeHash = none`, `evmVersion = istanbul` (0.7.6 default, frozen so a later default cannot sneak in). Probe contract (new harness file, not a pin edit):

```solidity
pragma solidity =0.7.6;
import "./FullMath.sol";
import "./UnsafeMath.sol";
import "./LowGasSafeMath.sol";
import "./SafeCast.sol";
import "./FixedPoint96.sol";
import "./SqrtPriceMath.sol";
contract Token0Probe {
    function probe(uint160 sqrtPX96, uint128 liquidity, uint256 amount, bool add)
        external pure returns (uint160)
    {
        return SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amount, add);
    }
}
```

Captured tree also contains `contracts/test/SqrtPriceMathTest.sol` (git blob `41fec2f54ed7ec9b0c6a5700a08df314a14dac4d`) but that file was **not** in the 41-file capture. Either acquire that exact blob from the same commit or use Token0Probe. Do not edit captured library bytes.

EVM: not frozen in this planning pass. Before any source scoring, select and record the exact EVM executable/version/hash and execution fork, compile/bytecode identity, and ABI observation adapter. Missing `evm` is `blocked_missing_evm`, not a pass, and is not a source-execution failure.

Runtime observation: `{tool, compiler_sha256, bytecode_sha256, calldata, status: success|revert, returndata}`. Compare numeric success to Lean `Word 160`. Compare revert to model error **without** assuming payload equality.

### 8. M09 / F28

Original plan: M09 flips `zeroForOne := current ≥ target` to `current < target`, designated false F31, sibling/global positive F28.

Diagnosed on the repaired oracle (not compiled):

| Fixture | Original | M09 | Use |
| --- | --- | --- | --- |
| F28 | amountIn 2, zeroForOne true | amountIn 1, zeroForOne false | **exclude** as protected |
| F31 | oneForZero success | changes | designated false, unchanged |
| F32 | invalidFee | invalidFee | **named model-side sibling** for planned Lean SwapMath with `invalidFee`/`intOverflow` preguards. Captured Solidity `computeSwapStep` has no such preguard, so F32 is not automatically a pinned Solidity control. |
| F33 | intOverflow | intOverflow | additional model-side control |
| F29 | numeric 0/0/1 | numeric 0/0/1 but zeroForOne flips | **not** named |

Compiled M09 remains P21. M09 itself stays the original future Lean SwapMath direction mutation.

### 9. Production token0 mutants (planned, not compiled)

Each mutant has **one actual Solidity edit** in `SqrtPriceMath.sol` lines 28–56. No Solidity-or-Lean alternative, no unbounded-or-wrapped alternative. Designated false witnesses must change the public observation. Python-only edits and model-label changes earn no production credit. Compile/tool-setup failure is blocked, not detection, and is not a source-execution failure. Actual EVM exceptional outcomes are recorded at implementation.

T0-REQ-SKIP designated false is P16-REQ-STRICT `(2^96,1,2,false)`: original require refuses; after deleting only `numerator1 > product` the wrapped subtraction denominator is `2^256-2^96` and the mutant returns 1. Equality P16-REQ remains a required baseline/control (still publicly refuses via FullMath denominator 0). P16-ADD remains the unaffected positive.

T0-ID-SKIP deletes the Solidity identity return and reaches high-level division by `amount` at amount 0. Deleting a Python/Lean identity that treats amount 0 as product-fit is not that mutant.

### 10. Proof obligations

See `proof-obligations.json`. Axiom audit: only standard Lean/mathlib axioms on the P16 theorem set. Inventory MUST be nonempty. Branch theorems MUST mention the wrap premises. Typed wrapper optional.

### 11. Alternatives considered

- Wait for P21 planning: rejected (E2).
- Treat Python as source: rejected (P15 §6.3).
- Exclude wrap because Q96 max-liquidity wrap agrees with unbounded mulDiv: rejected; that vector is a finding, the MAX_SQRT_RATIO−1 vector discriminates.
- Invent UnsafeMath `divisionByZero` as source: rejected; comment says unspecified. Helper reachability is a separate future bound.
- Use F29 as M09 sibling because amounts stay 0: rejected; `zeroForOne` still flips.
- Declare unused `Signed` to satisfy original 2.1: rejected (R3). Residual stays P21.
- Designate T0-REQ-SKIP on equality P16-REQ: rejected (R1); still publicly refuses.

## Risks / Trade-offs

- [Missing solc/evm] → Frozen official identities; execution stays blocked, not green.
- [Host Lean 4.33.1 ≠ pin 4.33.0-rc2] → Implementation uses repo toolchain, not this host default.
- [Bare uint160 truncation vs Word 160] → No observed reachable add-truncation mismatch. Future local add-result bound; do not invent a source refusal.
- [FullMath assembly ≠ Rounding.mulDiv] → Named gap; token0 proofs use the documented floor/ceil spec.
- [Author diagnostics mistaken for GPT-6 review] → `gate_accepted` false; result.json pending.

## Migration Plan

No runtime migration. If independent GPT-6 accepts this slice, root copies these bytes onto `semantic-kernel-pivot` and implementation may start in a later increment. Rollback is leaving the change unintegrated. Do not merge to main.

## Open Questions

None that change this slice. Vault pin, P17 reuse, and P21 residual planning remain later sprints.
