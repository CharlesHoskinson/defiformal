# Kernel and operator contract (P15 task 16.1)

**Status:** author freeze, pending independent GPT-6 review  
**Kernel identity:** DefiKernel at git `01490b539b3d30bb992e0d6cfc603022d7be99a9`  
**Toolchain:** `leanprover/lean4:v4.33.0-rc2` (`lean/lean-toolchain`, SHA-256 `0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6`)  
**mathlib:** inputRev `v4.33.0-rc2`, pinned rev `51e6992efd06126df61a496bebf8f49482a4e129` (`lean/lake-manifest.json`, SHA-256 `8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002`)

This contract names the delivered Typed operation and sequential composition
APIs that P16/P17 may wrap. It does not add fields. It does not change kernel
semantics. Exact hashes are in `source-bindings.json`.

## 1. Which operator this contract binds

The reusable operator is **registered first-order Typed execution**:

- Template selection from a trusted `Registry`
- Request ingress and capability checks
- Exact-rational expression evaluation
- Aggregate net effects and supply
- `Except Refusal ExecutionResult`

Entry point: `DefiKernel.Typed.execute` in
`lean/DefiKernel/Typed/Transition.lean` lines 171–187.
SHA-256 `73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2`.

Sequential wrapping, when used, is `DefiKernel.Composition.run` /
`advance` in `lean/DefiKernel/Composition/Sequence.lean` lines 33–51.
SHA-256 `32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729`.

Pure financial arithmetic is **not** this operator. It lives in
`DefiKernel.Arithmetic` and returns `Except Arithmetic.Failure (Word w)`
without a ledger. See `library-arithmetic-contract.md`.

## 2. Historical APIs that are not this operator

`lean/DefiKernel/Core.lean` (`DefiKernel.Transition`, SHA-256
`767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d`) is the
Sprint-1 pilot. Its fields are `actor`, `effect`, `supplyChange`, `writes`,
`guard`. Its refusals are `guard`, `unauthorizedDebit`, `unauthorizedSupply`,
`insufficientFunds`, `accounting`, `footprint` (lines 49–57). P15 does not
treat that record as the reusable operator.

`lean/DefiKernel/Contracts.lean` is the Sprint-2 trusted-wrapper layer over
the pilot. It is not the Typed operator.

Nary/Tree, Parallel, Atomic, Metatheory, and Interface modules exist at this
HEAD. P15 does not freeze them as required by token0 or the vault case.
`lean/DefiKernel.lean` currently imports `DefiKernel.Nary.Tree.Recovery`
because P01 was delivered. That import does not add operator fields to Typed
execution.

## 3. Identities

Declared in `lean/DefiKernel/Typed/Types.lean`, SHA-256
`5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82`.

| Identity | Lines | Fields actually declared |
| --- | --- | --- |
| `ClaimId` | 9–11 | `value : Nat` |
| `CapabilityId` | 13–15 | `value : Nat` |
| `OperationId` | 17–19 | `value : Nat` |
| `ObservationId` | 21–23 | `value : Nat` |
| `Cell` | 25 | `Domain × Party × Asset` |
| `Quantity` | 28–30 | `amount : ℚ`, `nonneg` |
| `State` | 32–34 | `balance : Cell → ℚ`, `nonneg` |
| `InvocationContext` | 131–134 | `principal`, `domain` |

`InvocationContext` is adapter-supplied identity. The source comment at
Types.lean line 130 states that constructing this value is not signature
verification.

No nonce, expiration, chain-id, or owner-consent field is declared.

## 4. Dimensions and roles

**Dimensions** (`Unit`, Types.lean 41–46):

- `amount asset`
- `price base quote` (quote units per one base unit, line 40)
- `scalar`
- `bool`

`NumericUnit` (49–53) excludes `bool`. `Value` (60–62) is `Bool` or `ℚ`.
Typed expression arithmetic is exact `ℚ` (`Expr.lean` line 3). Machine-width
words are a separate Arithmetic API.

**Authority roles** (`Right`, `lean/DefiKernel/Typed/Authority.lean` 8–12,
SHA-256 `dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb`):

- `invoke`
- `debit cell`
- `changeSupply domain asset`

`Grant` (21–26): `holder`, `domain`, `operation`, `right`.  
`Capability` (28–30): Grant plus `live`.  
List positions are permanent IDs. Revoked entries remain tombstones
(Authority.lean lines 3–4, 76).

`hasAuthority` (98–101) is existential over supplied IDs. Duplicate IDs confer
no extra rights (comment line 97).

Debit authority is an administrator grant of an exact cell to the invoker.
There is no separate owner-consent constructor.

## 5. Template, request, effects, supply, access

`Template` (`Transition.lean` 19–28):

- `signature : List (Unit Asset)`
- `domain`
- `partyArity`
- `guard : Expr … .bool`
- `deltas : List CellDelta`
- `supplyDeltas : List SupplyDelta`
- `stateReads`, `envReads`, `writes`

`Request` (37–42): `operation`, `parties`, `arguments`, `capabilityIds`,
optional `claimedActor`. The request does not carry a template, guard body,
or validity certificate (`execute_ok_iff` comment, lines 217–218).

**Effects:** `Evaluated.effect` (111–113) sums every matching `CellDelta`,
including repeats. Effects are net `ℚ` changes, not ordered debits or
consumable allowances (`Transition.lean` lines 5–6).

**Supply:** `Evaluated.supply` (115–117) sums matching `SupplyDelta`s.
`accountingOK` (145–146) requires, for every domain and asset,
`∑ party, effect (domain, party, asset) = supply domain asset`.

**Access / footprints:**

- `stateReadsOK` / `envReadsOK`: required reads ⊆ declared reads
- `domainOK`: required state reads and nonzero net movement stay in the
  invocation domain. Environment keys may name other domains. Their truth is
  adapter-supplied (127–131)
- `debitsOK`: every negative net effect has a live `debit` right
- `suppliesOK`: every nonzero supply change has a live `changeSupply` right
- `writesOK`: undeclared cells have zero net effect

Composition access is separate: `Component.canRead` / `canWrite` and
`checkAccess` in `lean/DefiKernel/Composition/Interfaces.lean` 81–140,
SHA-256 `4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe`.
Catalog validation is structural. It does not discharge kernel authority
(Interfaces.lean lines 3–4).

**Outputs of a successful Typed execute:** `ExecutionResult` (73–75) is
`state` plus `capabilities`. Successful invoke preserves the capability store
(`applyEvaluated` line 165). Administrative issue/revoke change the store and
preserve the ledger (`Composition.Execution.executeStep` 98–105).

Composition snapshots copy declared output-cell balances after commitment
(`snapshots`, Interfaces.lean 162–167). They are not a general ledger history
type.

## 6. Exact Typed.execute refusal order

The order below is the order of the computational branches in
`execute` (171–187) then `applyEvaluated` (152–166). Constructor declaration
order in `inductive Refusal` (44–60) is not the runtime order.

### 6.1 Ingress (`execute`)

1. `unknownOperation` — registry has no template (175–177)
2. `actorMismatch` — `claimedActor` is `some` and differs from
   `ctx.principal` (178–179)
3. `domainMismatch` — `ctx.domain ≠ template.domain` (180)
4. `partyArity` — `request.parties.length ≠ template.partyArity` (181)
5. `evaluation` from `Args.check` (182)
6. `unauthorizedInvoke` — no live `invoke` right (183–184)
7. `evaluation` from `template.evaluate` (185–186)
8. `applyEvaluated` refusals (187)

`Args.check` (`Expr.lean` 23–32):

- Both lists empty: success
- Heads present and units differ: `argumentUnit` (even if lengths also differ)
- Length mismatch after matching prefix, or one list empty: `argumentCount`

### 6.2 Evaluation (`Template.evaluate`, 93–108)

First error from this sequence wins, all as `Refusal.evaluation`:

1. Resolve `requiredStateReads`
2. Resolve declared `stateReads`
3. Resolve `writes`
4. Evaluate `guard`
5. For each delta: resolve target, then evaluate amount
6. For each supply delta: evaluate amount

`EvalFailure` constructors actually declared (Types.lean 80–86):
`argumentCount`, `argumentUnit`, `partyArgument`, `missingObservation`,
`observationUnit`, `divisionByZero`.

`BinaryOp.eval` (`Expr.lean` 58–76) is total for add/sub/scale/convert.
Division, ratio, and unconvert refuse `divisionByZero` when the denominator
is zero. Boolean `and`/`or` evaluate both operands. Only `ite` is lazy
(comment lines 126–127).

### 6.3 Apply (`applyEvaluated`, 152–166)

1. `guard`
2. `stateReadFootprint`
3. `envReadFootprint`
4. `crossDomain`
5. `unauthorizedDebit`
6. `unauthorizedSupply`
7. `insufficientFunds` if `¬ ∀ c, 0 ≤ balance c + effect c`.
   In that branch, `accounting` and `writeFootprint` are **not** checked
   (dependent `if hn : …`, lines 162–166)
8. `accounting` (only if nonnegativity holds)
9. `writeFootprint` (only if nonnegativity and accounting hold)
10. success: new state `balance + effect` with the nonnegativity witness,
    unchanged capability store

Successful read/domain checks are not refused-path confidentiality guarantees
(comment lines 168–170).

## 7. Composition step and sequential first-refusal

`DefiKernel.Composition.Failure` (`Execution.lean` 32–37):
`configuration`, `interface reason`, `kernel reason`, `authority reason`,
`internalReceipt`.

### 7.1 `executeStep` order (87–105)

1. `configuration` if `validateCatalog` is false
2. On `.invoke`:
   1. `prepareInvocation` (65–76)
   2. `Typed.execute` mapped to `Failure.kernel`
   3. `extractReceipt` mapped to `internalReceipt`
3. On `.issue`: `issueCapability` mapped to `Failure.authority`
4. On `.revoke`: `revokeCapability` mapped to `Failure.authority`

`prepareInvocation` order:

1. Catalog `lookupOperation` missing → `interface unknownOperation`
2. `resolveInputs` (`Interfaces.lean` 154–160):
   1. `inputCount` if source arity differs
   2. `unavailableOutput` if a `priorOutput` index is not strictly less than
      the current step or is absent from history
   3. `inputUnit` if packed units differ from declared input ports
3. Registry missing → `kernel unknownOperation`
4. `checkAccess` (131–140):
   1. `resolution` (EvalFailure while resolving conservative read/write refs)
   2. `readAccess`
   3. `writeAccess`

`AuthorityFailure` for issue (65–74): `unauthorizedAdmin`, then
`operationDomain`, then `resourceDomain`.  
For revoke (77–85): `unknownCapability`, then `unauthorizedAdmin`.

Receipts are re-evaluated against the **same pre-state** after successful
execute (`Execution.lean` lines 3–5, 78–85). They are not a fabricated
post-hoc ledger.

### 7.2 Sequential `advance` / `run` (Sequence.lean 29–51)

- Invalid catalog at start: `LocatedFailure` at index 0, step `none`,
  reason `configuration`, no events
- If `cursor.failure` is already `some`, `advance` is identity (inert suffix)
- First step error records `LocatedFailure` at `nextIndex` and does not
  append an event or output
- Success appends the event, concatenates outputs, increments `nextIndex`

This is the delivered “successful prefixes retained, first refusal stops
execution” contract required by
`specs/minimum-reusable-contracts/spec.md` scenario
“Delivered sequential refusal order”.

## 8. Pure arithmetic versus a Typed wrapped operation

| Surface | Returned type | State | Authority | Use for P16 token0 |
| --- | --- | --- | --- | --- |
| `Arithmetic.Operations.add/sub/mul`, `Rounding.mulDiv`, `Fees.*` | `Except Failure (Word w)` or `FeeQuote` | none | none | Allowed. Arithmetic-only P16/P18 may omit a Typed wrapper |
| `Quantity.toQuantity` | `Typed.Quantity asset` directly | none | none | Scale conversion into a typed quantity. Not an `Except` |
| `Quantity.fromRat` | `Except Failure (Word w)` | none | none | Inverse conversion. Checked failure, not a direct quantity |
| `Arithmetic.Reference.observeExecution` | `((State × Store) × Except Refusal ExecutionResult)` | yes | yes | Pattern for a quote-derived Typed wrap. Not token0 |
| `Typed.execute` | `Except Refusal ExecutionResult` | yes | yes | Required only if token0 is used as kernel-platform evidence |
| `Composition.executeStep` / `run` | `Except Failure StepResult` / `Cursor` | yes, plus output history | yes | Required for sequential composition claims, not for pure token0 |

`Reference.observeExecution` (`Arithmetic/Reference.lean` 67–71) keeps the
supplied pre-state beside the `Except` result because a refusal has no
post-world. That observation shape is the Typed wrap. It is not a field of
`Word`.

P17.platform_reuse later requires a token0 library-to-Typed bridge and both
case adapters against a named shared executor result. That bridge is
`required_future`. This freeze does not implement it.

## 9. Fields that must not be invented

The following are **not** declared on `Template`, `Request`, `Right`,
`ExecutionResult`, or `Word`, and P16/P17 adapters must not add them as if
they were kernel fields:

- wrapping/`mod 2^w` constructors on `Operations.add`
- fee, tick, or pool-state fields on the Typed operator
- owner consent, allowances, replay nonces
- ordered debit traces
- fabricated ledger history on a pure function
- certificate tags treated as `execute` success
- a selected vault pin

## 10. Trust boundaries already stated in the delivered sources

These remain assumptions, not proved kernel theorems:

- registry/admin/store/context authenticity
- observation truth and price positivity, unless a guard checks them
- finite Party/Asset/Domain universe
- input `State.nonneg` as a proof-carrying fact
- no machine overflow in Typed `ℚ` arithmetic
- no deployed-contract fidelity
