# Adapter observation contract (P15 task 16.3)

**Status:** author freeze, pending independent GPT-6 review  
**P16 operation:** pure `getNextSqrtPriceFromAmount0RoundingUp`  
**P17 operation:** stateful vault deposit/withdrawal, pin `not_established`

This contract states the input/pre-state → output/post-state/refusal relation
for the two cases. Protocol-specific adapters and local proofs are permitted.
A new global induction, cloned dispatcher, or case-specific checker exemption
blocks an unchanged-interface reuse claim.

## 1. Common observation rules

1. Record only observations the selected operation actually has.
2. A pure function must not invent ledger, capability, or history fields.
3. A refusal has no post-state. Keep the supplied input beside the `Except`
   / revert result. Do not fill a fake post-world.
4. Bind exact source, model, compiler/harness, and observation identifiers
   before scoring source-bound evidence.
5. Distinguish standalone function admissibility from reachability inside a
   larger protocol (pool swap, vault callback, token transfer).
6. Protocol-specific adapters are expected. They are not reuse failure if a
   named shared library lemma or financial contract and a named delivered
   executor or composition theorem, with its premises, are instantiated
   unchanged for both cases when `P17.platform_reuse` is claimed. Sharing
   only an executable entrypoint is not that theorem.

The Typed wrap observation already delivered for fee quotes is
`Arithmetic.Reference.observeExecution`
(`lean/DefiKernel/Arithmetic/Reference.lean` 66–71):
`((pre-state, pre-store), Except Refusal ExecutionResult)`.
Use that shape when wrapping through `Typed.execute`. Do not use it for
pure token0 unless P16 actually builds the kernel bridge.

## 2. P16 token0: pure function relation

### 2.1 Function identity

- Name: `SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp`
- Pin: Uniswap v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899`
- Span: `SqrtPriceMath.sol` lines 28–56
- Kind: `internal pure`
- Capture: retained under
  `/home/charl/defiformal/review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/SqrtPriceMath.sol`
  SHA-256 `ddd62e3a94346248677f30f1ab009ef015e71e4b8696dcca890eeabc9dc6c149`
- Compiler settings declared: Solidity 0.7.6, optimizer on, 800 runs,
  `bytecodeHash: none` (`hardhat.config.ts` 32–45)
- Compiler binary / EVM harness: `not_established` (P16 must declare and run
  one, or justify another actual source-semantics reference)
- Python oracle: `diagnostic_only` (see library contract §6.3)

### 2.2 Inputs (no pre-state)

| Name | Source type | Model width if using Arithmetic |
| --- | --- | --- |
| `sqrtPX96` | `uint160` | `Word 160` |
| `liquidity` | `uint128` | `Word 128` |
| `amount` | `uint256` | `Word 256` |
| `add` | `bool` | `Bool` |

There is no fee argument. There is no pool storage, tick, ledger, or
capability input. Do not add them.

### 2.3 Outputs and refusals

**Success:** `uint160` next sqrt price.

**Source refusals actually in this helper and its callees:**

| Condition | Source mechanism | Notes |
| --- | --- | --- |
| `amount == 0` | `return sqrtPX96` | **Success identity**, not a refusal (line 35) |
| remove, product overflow or `numerator1 ≤ product` | `require(...)` (line 52) | actual refusal. Planned `(2^96,1,1,false)` hits `numerator1 > product` false |
| `FullMath.mulDiv` / `mulDivRoundingUp` | `require` on zero denominator or quotient overflow | callee |
| fallback `LowGasSafeMath.add` overflow | `require((z = x + y) >= x)` | revert, not wrap |
| fallback `UnsafeMath.divRoundingUp` with `y == 0` | unspecified in source | bind at P16. Do not invent Lean `divisionByZero` as if the assembly specified it |
| remove-path `toUint160` overflow | `SafeCast.toUint160` require | add-path uses bare `uint160` casts |

**Not observations of this function:**

- ledger balances, supply, capabilities
- sequential `Cursor` history
- pool `swap` lock, callback, or `SPL` guard (those are P21 if selected)
- fee pips

### 2.4 Predeclared partitions (required nonempty, not executed here)

P16 must declare nonempty partitions before scoring. This freeze names the
required families. It does not populate results.

1. Ordinary add, product and denominator sum both fit
2. Ordinary remove, `numerator1 > product`
3. Multiplication overflow on add (`amount * sqrtPX96` wraps, fallback)
4. **Denominator-sum overflow** on add (product fits, `numerator1 + product`
   wraps, fallback). Required. Must not be excluded
5. Rounding-fallback / `UnsafeMath.divRoundingUp` path
6. Zero-amount identity success for both `add` values
7. Removal-denominator `require` failure
8. Applicable callee refusals that P16 includes in its matrix

Standalone helper admissibility ≠ reachable from `UniswapV3Pool.swap`.
Full-pool reachability stays open.

### 2.5 Model side

If P16 is arithmetic-only:

- Model observation is `Except Arithmetic.Failure (Word 160)` or an explicit
  source-shaped refusal tag that is **not** a Typed `Refusal`
- Do not emit `ExecutionResult` or output-history lists

If P16 claims kernel-platform evidence:

- Build a Typed template whose expressions compute the same next price
- Observe via `Typed.execute` / `observeExecution`
- Pure arithmetic success alone establishes arithmetic-library scope only

## 3. P17 vault: stateful relation (pin not established)

No reviewed executable vault pin exists at this freeze. CURRENT.json lane
`remaining_libraries` is `future_open`. Sprint-index P17 path
`source_pin: not established`.

This contract **permits** a future pin. It does not select one. A second AMM
formula must not replace the vault case.

### 3.1 Required observation shape once a pin exists

| Item | Requirement |
| --- | --- |
| Kind | Stateful deposit and/or withdrawal |
| Pre-state | At least the balances/shares/supply the selected source actually reads |
| Input | Amounts and actor/authorization data the source takes |
| Success post-state | Those same cells/supply after the source update |
| Ordinary success | One successful conversion with rounding direction from the pin |
| Reachable refusal | The pin's **actual** transfer or authorization guard, frozen before scoring |
| Negative | Source-independent share mint without asset credit |
| Assumptions | Token behavior, callbacks, and environment assumptions stated before scoring |

Do not invent a current refusal. Do not exclude a discovered mismatch only
to keep a pass. If retained development sources lack an adequate revision,
compiler, and observation closure, record `blocked_missing_source` in
`terminal_disposition`. That is not `successful_exit`.

### 3.2 Supported future source choices (honest, not selected)

Allowed search space at P17 entry:

- Exact vault source closure already retained in development material
- A later acquired pin with compiler settings and observation relation
- ERC-4626-like share/asset vaults **if and only if** that exact source is
  pinned and reviewed. ERC-4626 is a class name, not a pin

Not allowed:

- Uniswap token1 or another AMM formula as the contrasting case
- A fabricated ledger for a source that has none
- Treating this P15 contract as establishing a pin

Unknown until P17: compiler, file hash, function names, rounding direction,
exact revert strings, callback/token assumptions.

## 4. P17 common harness / executor reuse (required later, not implemented)

`P17.platform_reuse` is a named predicate. This freeze does not implement
P17. Arithmetic-only reuse may later be published in `arithmetic_reuse`
without closing the platform gate.

To claim `P17.platform_reuse`, all of the following must hold:

1. **One harness engine** actually executes the token0 case and the vault
   case. A wrapper around two separate engines does not count.
2. A **named shared financial lemma or contract** from these P15 contracts
   or delivered Arithmetic, instantiated in both cases.
3. Distinguish the **common executable entrypoint** from the **shared
   proved result**. Routing both adapters through one function is not
   enough.
   - Entrypoint examples, not selected now: `Typed.execute` returning
     `Except Refusal ExecutionResult`, and `Composition.executeStep`
     returning `Except Failure StepResult`.
   - Shared proved result: a **named delivered executor or composition
     theorem**, its explicit premises, and checked unchanged instantiations
     for **both** the token0 case and the vault case. Examples of actual
     delivered theorem names that may later be considered, not selected or
     instantiated in this freeze: `DefiKernel.Typed.execute_ok_iff`
     (`lean/DefiKernel/Typed/Transition.lean` line 219) and
     `DefiKernel.Composition.executeStep_sound`
     (`lean/DefiKernel/Composition/Execution.lean` line 201). A theorem
     used only by the vault does not count.
4. The **token0 library-to-Typed kernel bridge** exists and is checked.
5. **Both adapters** are checked against that named theorem and against
   the common executable entrypoint.
6. A **case-two inventory** records new definitions, new assumptions,
   interface changes, and effort for the vault case relative to token0.

Composition integration, if claimed, needs a meaningful two-operation
preservation instance. If token0 next-price and vault deposit do not
financially compose, report narrower interface/library reuse. Do not invent
a sequential workflow. Narrow noncomposing reuse remains valid.

This gate does not depend on P30 source refinement. Certificates are not a
prerequisite.

## 5. Adapter I/O summary

```
token0_pure:
  in  = {sqrtPX96, liquidity, amount, add}
  pre = {}
  out = uint160 | source_revert
  post = {}
  history = omitted

token0_typed_wrap:          # optional, required only for kernel-platform evidence
  in  = Request / Invocation derived from the four inputs
  pre = State × CapabilityStore × Boundary
  out = Except Refusal ExecutionResult  (or Composition Failure)
  post = ExecutionResult on success, pre retained on refusal
  history = Composition outputs only if sequential composition is actually used

vault_stateful:             # pin not_established
  in  = pin-defined
  pre = pin-defined balances/supply/authorization
  out = success conversion | pin-defined refusal
  post = pin-defined
  history = only if the selected source/workflow actually has one
```
