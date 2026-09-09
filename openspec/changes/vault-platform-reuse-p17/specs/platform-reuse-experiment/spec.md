## Purpose

Make the P17 platform-reuse experiment concrete: one engine, a named shared lemma, a named shared executor theorem instantiated by both adapters, the token0 kernel bridge, and a case-two inventory design, without claiming the gate in this freeze.

## ADDED Requirements

### Requirement: One engine executes token0 and vault

`P17.platform_reuse` SHALL require one common harness engine that actually executes the token0 case and the vault case. A wrapper around separate engines SHALL NOT count. A cloned dispatcher SHALL NOT count. The engine SHALL preserve P16 fail-closed receipt, coverage, and `#eval` truth lessons and SHALL use portable paths/settings.

#### Scenario: Wrapper of two campaigns is not one engine
- **WHEN** a candidate shells out to a token0 campaign and a vault campaign behind a common function name
- **THEN** `P17.platform_reuse` remains false

### Requirement: Shared lemma and execute_ok_iff are instantiated by both adapters

The named shared financial lemma SHALL be `Rounding.divideNat_down_ok_iff` / `divideNat_up_ok_iff` and the directed `mulDiv` rational-error theorems under the no-product-overflow premise, used by token0 FullMath and by vault conversion. The named shared executor theorem SHALL be `DefiKernel.Typed.execute_ok_iff` with real premises, instantiated by both adapters. A vault-only theorem, a vacuous zero-effect token0 wrap, or a circular desired-postcondition premise SHALL NOT count.

#### Scenario: Ordinary token0 add is a nonzero quote-register effect
- **WHEN** the token0 Typed adapter is instantiated on `(2^96, 1, 1, true)`
- **THEN** `execute_ok_iff` is applied to a QuoteSqrtP debit/supply decrease of `2^95` and MUST NOT use an empty-delta template as the reuse witness

#### Scenario: Vault deposit accounting is proved from deltas
- **WHEN** the vault deposit adapter is instantiated on `P17-DEP-D0`
- **THEN** USDS party effects sum to 0 and sUSDS effects equal supply, derived from the template deltas rather than assumed as the post-state hypothesis

### Requirement: Token0 bridge does not invent source ledger history

The token0 library SHALL remain a pure `Except Failure (Word 160)`. Source observations SHALL remain four inputs plus `uint160 | revert`. The kernel bridge SHALL lift the **actual successful library word** through `Quantity.toQuantity` into a labelled quote-register model cell whose **pre-register equals the input sqrtPX96** at scale 1 (raw Q96 units). That cell SHALL NOT be claimed as Uniswap storage, cash settlement, or bounded source execution. Templates MUST be library-derived. Arithmetic-only reuse SHALL NOT open `P17.platform_reuse`.

#### Scenario: Pure helper observation omits ledger fields
- **WHEN** a token0 source observation is recorded
- **THEN** it contains only the four inputs and the uint160 result or revert, even if a separate Typed wrap exists

#### Scenario: Quote-register is model-only
- **WHEN** the token0 Typed wrap is described
- **THEN** `model_only` is true, `pool_storage` is false, `cash_settlement` is false, the pre-register equals input sqrtPX96, and scale 1 means raw Q96 units

### Requirement: Composition is unclaimed; inventory is required

This slice SHALL NOT claim composition integration and SHALL NOT invent a token0-to-vault sequential workflow. Case-two new definitions, assumptions, interface changes, and effort SHALL be recorded at implementation. Missing inventory SHALL leave `P17.platform_reuse` open. If the quote-register embedding cannot be justified, the package SHALL record that design obligation rather than weaken the accepted gate.

#### Scenario: No fabricated sequential workflow
- **WHEN** token0 next-price and vault deposit are reported
- **THEN** the reuse report records library/interface/executor reuse only and does not add a fake two-operation workflow

#### Scenario: Missing inventory keeps the gate open
- **WHEN** adapters exist but case-two additions/assumptions/interfaces/effort are not measured
- **THEN** `P17.platform_reuse` remains false
