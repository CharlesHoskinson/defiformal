## Purpose

Specify source-bound financial libraries: first pinned Uniswap token0 execution, a contrasting vault after actual source readiness, then resource-gated remaining families without inventing missing pins.

## ADDED Requirements

### Requirement: First pinned Uniswap token0 operation

`P16` SHALL execute the pinned Uniswap V3 token0 next-price helper `getNextSqrtPriceFromAmount0RoundingUp` from v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899` (`SqrtPriceMath.sol` lines 28–56) under pinned compiler settings and a declared EVM harness, or justify another actual source-semantics reference. The independent Python transcription MUST remain a diagnostic third implementation. Predeclared nonempty partitions SHALL cover ordinary add/remove, multiplication overflow, the required denominator-sum overflow branch, rounding-fallback, zero-amount identity success, and the actual removal-denominator `require`. That helper has no fee parameter. Zero amount MUST be treated as identity success (`if (amount == 0) return sqrtPX96`), not as a refusal. Rounding proofs MUST state the branch-specific 0.7.6 fallback equation and MUST NOT silently equate it to the exact mathematical rational formula. Standalone function admissibility MUST be distinguished from full-pool reachability. TickMath, SwapMath, token1 next-price, amount0/amount1 deltas, bitmap/liquidity/factory, the original 45-fixture campaign, compiled M09 SwapMath execution, and the original M01–M12 mutation campaign SHALL remain `P21`. `P16` SHALL obtain independent GPT-6 planning review of the exact repaired token0 planning slice, with recorded verdict, requested/reported model identity, and input hashes, and MUST keep gate accepted false until that review; that slice review MUST NOT wait on `P21`. The original unaccepted whole-library freeze is preserved input, not accepted evidence, and this program-plan revision is not original 1.2 acceptance. A `P16` contribution MUST NOT close those original mixed task IDs.

#### Scenario: Sum-overflow mismatch is repaired
- **WHEN** sqrtP is MAX_SQRT_RATIO−1, liquidity is max uint128, amount causes numerator1+product uint256 overflow while the product fits
- **THEN** Lean library and pinned Solidity results agree on that required branch; `P16` MUST NOT exclude the branch to close the sprint, the Uniswap token0 obligation, or the program

#### Scenario: M09 does not protect F28
- **WHEN** the planned M09 mutant flips the direction predicate
- **THEN** `P16` removes or replaces F28 as a protected control because amountIn changes from 2 to 1, names a genuinely unaffected sibling, and preserves the failed original plan; this is diagnostic/control-plan correction, not compiled M09 SwapMath execution

#### Scenario: Zero amount is identity success
- **WHEN** planned inputs `(sqrtPX96=2^96, liquidity=1, amount=0, add=true)` or the same with `add=false` are applied to the token0 helper
- **THEN** the result is `2^96` and the case is a positive control, not a refusal

#### Scenario: Removal denominator require is the actual refusal
- **WHEN** planned inputs `(sqrtPX96=2^96, liquidity=1, amount=1, add=false)` are applied
- **THEN** the helper fails the source `require` that `numerator1 > product` (both equal `2^96`); planned add sibling `(2^96,1,1,true)` succeeds with `2^95`

### Requirement: Contrasting vault after source readiness

`P17` SHALL select a narrow stateful vault deposit or withdrawal with asset/share rounding and transfer refusal. A reviewed executable vault pin is not established at planning time. `P17` MUST verify or acquire an exact source closure from development material before implementation, and MUST record `blocked_missing_source` rather than invent fidelity if none is ready. Arithmetic-only `P16`/`P18` delivery MAY omit a Typed wrapper. The named predicate `P17.platform_reuse` SHALL require one common harness engine that executes both cases, a named shared financial lemma or contract, a named shared executor result, the token0 library-to-kernel bridge, both case adapters checked against that executor result, and a recorded case-two inventory of new definitions, assumptions, interface changes, and effort. A theorem used only by the vault MUST NOT count as that shared executor result. A common wrapper around separate case engines MUST NOT count as one harness. If composition integration is claimed, a meaningful two-operation preservation instance SHALL be required; if the selected operations do not financially compose, the report MUST claim the narrower interface or library reuse rather than invent a workflow. Narrow noncomposing interface or library reuse remains valid. Narrow arithmetic-only reuse MAY be published in `arithmetic_reuse` while `P17.platform_reuse` remains open. This gate MUST NOT depend on `P30`. A financially meaningless sequential workflow MUST NOT be invented.

#### Scenario: No vault pin
- **WHEN** retained development sources lack an adequate vault revision, compiler, and observation closure
- **THEN** `P17` implementation stays blocked, the missing pin is named, and a second AMM formula is not substituted

#### Scenario: Platform reuse needs both adapters
- **WHEN** `P17` claims kernel or platform reuse across token0 and vault
- **THEN** one common harness engine executes both cases, a named shared financial lemma or contract and named shared executor result exist, the token0 library-to-kernel bridge exists, both adapters are checked against that executor result, and case-two additions/assumptions/interfaces/effort are recorded; arithmetic-only reuse without that inventory MUST leave `P17.platform_reuse` open

#### Scenario: Composition instance only if claimed
- **WHEN** token0 next-price and vault deposit have no financially meaningful sequential composition
- **THEN** the reuse report records library and interface reuse only, MUST NOT add a fake two-operation workflow, and MAY still satisfy `P17.platform_reuse` without a composition instance; if composition integration is claimed, a meaningful two-operation preservation instance is required

### Requirement: Resource-gated remaining families

`P21`–`P29` SHALL start only after `P17.platform_reuse`, except independent source-readiness inspection. Arithmetic-only reuse MUST NOT open that gate. Each family MUST have a pinned source, observation/refusal contract, nonempty fixtures, characteristic mutations, and explicit remainders. Missing pins stay blocked.

#### Scenario: Source inspection before reuse gate
- **WHEN** a Curve or Morpho pin can be verified from retained development bytes
- **THEN** readiness records MAY be written before `P18`, and library implementation still waits on the reuse gate

### Requirement: Full concentrated-liquidity traversal

`P21` SHALL own residual concentrated-liquidity work that `P16` does not: original TickMath tasks 3.1–3.3, SwapMath task 4.2, residual original-4.1 token1 next-price and amount0/amount1 deltas, bitmap/liquidity/factory tasks 5.1–5.3, the original 45-fixture campaign, the original M01–M12 mutation campaign including actual compiled M09 SwapMath execution with the repaired per-mutant unaffected-control set (M09 MUST exclude or replace F28; preserve the failed original plan), and tick traversal, including the named remainders `R-FULL-TRAVERSAL`, `G-FULLMATH-ASSEMBLY`, and `G-NO-SOLC-DIFFERENTIAL` from the unaccepted liquidity candidate. `P21` SHALL obtain independent GPT-6 planning review of the exact repaired residual planning slice, with recorded verdict, requested/reported model identity, and input hashes, and MUST keep gate accepted false until that review; that residual-slice review MUST NOT be a `P16` implementation prerequisite. Exact-output capping in pinned `SwapMath.sol` lines 87–89 is a bounded success behavior, not a refusal. A declared pool admission failure for this scope SHALL use the pinned `UniswapV3Pool.swap` `SPL` guard (lines 608–613). Assembly FullMath identity, `Pool.swap` lock/callback/payment, and deployment fidelity MUST stay named gaps until separately discharged. Mixed original IDs SHALL close only when every recorded contribution exists. Original 1.2 SHALL close only after both applicable accepted planning-slice outcomes exist.

#### Scenario: One-word bitmap is not full traversal
- **WHEN** `nextInitializedTickWithinOneWord` proofs pass
- **THEN** R22 and `P21` remain open until actual multi-word tick traversal and declared pool-step observations are independently accepted and delivered; naming a remainder MUST NOT close those obligations

#### Scenario: Exact-output cap is success
- **WHEN** pinned `computeSwapStep` caps `amountOut` to remaining exact-output (`SwapMath.sol` lines 87–89)
- **THEN** the case is bounded success, not an executor refusal; pool admission failure uses the `SPL` guard (`UniswapV3Pool.sol` lines 608–613)

#### Scenario: Token1 and delta residual stay with P21
- **WHEN** `P16` accepts the narrow token0 next-price slice
- **THEN** original-4.1 residual amount0/amount1 deltas and token1 next-price remain `P21` obligations and MUST NOT be marked done or dropped

#### Scenario: Compiled M09 uses the repaired control set
- **WHEN** `P21` executes original 6.3 mutant M09 against compiled SwapMath
- **THEN** the per-mutant unaffected-control set excludes or replaces F28 with the sibling named by the `P16` control-plan correction, the failed original plan is preserved as evidence, and this execution is not a `P16` token0 obligation

### Requirement: Curve iteration and nonconvergence

`P22` SHALL implement Curve-style iterative invariant calculation against a pinned source. Bound-exhaustion SHALL be classified from that source at source-entry as a revert or as a successful residual, not invented in advance. A fabricated convergent output MUST NOT be emitted when the selected source does not converge.

#### Scenario: Bound exhaustion follows the pin
- **WHEN** iteration hits the declared bound without meeting the invariant tolerance
- **THEN** the observation matches the selected source guard or residual and does not emit a fabricated convergent output

### Requirement: Liquity ordered redemption is not the liquidation dispute

`P23` SHALL implement Liquity-style ordered redemption against a pinned source distinct from the `P10` liquidation-source challenge. Redemption order, partial fills, and refusal when no redeemable trove exists MUST be observed.

#### Scenario: Empty redeemable set
- **WHEN** no trove is redeemable under the pinned order
- **THEN** redemption refuses without rewriting the liquidation-source overlay

### Requirement: Morpho bad-debt loss allocation

`P24` SHALL implement Morpho-style bad-debt realization and loss allocation against a pinned source, including a reachable loss and a no-bad-debt control. A no-bad-debt no-op is a successful exceptional or control outcome, not an executor refusal. Actual rejection gates SHALL be selected from the pinned source at source-entry and MUST NOT be invented before that pin exists.

#### Scenario: Loss allocated to the declared party
- **WHEN** a realized bad-debt fixture executes
- **THEN** balances and shares match the pinned allocation rule and an unaffected control market is unchanged

#### Scenario: No-bad-debt is a control success
- **WHEN** a no-bad-debt fixture executes under the later pin
- **THEN** shares remain unchanged as a successful control, not as an executor refusal

### Requirement: Balancer vault, hooks, and transient accounting

`P25` SHALL implement Balancer-style shared vault accounting, hooks, and transient settlement against a pinned source. This family MUST NOT be used as a substitute for the `P17` contrasting vault pin unless that exact pin is the reviewed Balancer source.

#### Scenario: Transient settlement not committed on hook revert
- **WHEN** a hook reverts during a vault operation
- **THEN** transient accounting is not published as committed state

### Requirement: Asynchronous workflows

`P26` SHALL implement message lifecycles, finality, replay protection, timeouts, challenges, and compensation, and SHALL represent oracle, custody, legal, sequencing, and finality assumptions explicitly. Synchronous rollback MUST NOT be assumed.

#### Scenario: Replay after finality
- **WHEN** a finalized message identifier is submitted again
- **THEN** the workflow refuses replay and retains the original final observation

### Requirement: Signed margin, funding, unsettled PnL, liquidation, and bankruptcy

`P27` SHALL implement signed margin, funding, unsettled profit and loss, liquidation, and bankruptcy handling against a pinned source. An allowed liquidation or bankruptcy transition is a successful exceptional outcome, not an executor refusal. Actual rejection gates SHALL be selected from the pinned source at source-entry.

#### Scenario: Unsettled PnL is not cash
- **WHEN** an account has positive unsettled PnL and insufficient margin
- **THEN** an allowed liquidation or bankruptcy path follows the pinned rule as a successful exceptional transition unless that source actually reverts, and unsettled PnL is not treated as withdrawable cash unless the source says so

### Requirement: Conditional insurance and off-chain claims

`P28` SHALL implement external conditional claims, including insurance or tokenized off-chain obligations, with explicit oracle, custody, and legal assumptions. Off-chain truth MUST remain an assumption where unproved.

#### Scenario: Oracle assumption is explicit
- **WHEN** an insurance claim is paid from an oracle attestation
- **THEN** the evidence packet classifies oracle truth as an external assumption, not a proved fact

### Requirement: Complete cross-domain workflow

`P29` SHALL implement one actual complete cross-domain financial workflow with no synchronous-rollback assumption, including the required finality, replay, timeout, challenge, and compensation semantics. A sketch or single-chain stand-in MUST NOT close this obligation.

#### Scenario: Counterparty domain timeout
- **WHEN** the remote domain does not finalize before the declared timeout
- **THEN** compensation or challenge is a successful exceptional workflow outcome, not an executor refusal, and local committed state is not silently rolled back

### Requirement: Named conditional library proofs and source-independent negatives

Each of `P16`, `P17`, and `P21`–`P29` SHALL name a concrete conditional financial property, a proposed module path, an ordinary success class, a successful exceptional or control class where the source has one, an actual executor-refusal class taken from a real source guard, a characteristic mutation target, and a source-independent negative example. For unpinned families, source-entry SHALL select and freeze the actual source guard or revert; it MUST NOT invent a current refusal. Definition and evidence freeze against a later pin SHALL be an entry task and MUST NOT pretend a current API exists. Proofs MUST NOT assume desired postconditions, source truth, unconditional convergence, or solvency. When a family reuses Claims, Async, certificate, or operator exports, that reuse SHALL be an explicit dependency.

#### Scenario: Token0 directed rounding
- **WHEN** `P16` proves the token0 next-price obligation
- **THEN** the theorem states the branch-specific 0.7.6 fallback equation, includes required sum-overflow, treats zero amount as identity success, uses the removal-denominator `require` as the actual refusal, and includes a mutant that flips overflow fallback; it MUST NOT attach a fee parameter or treat zero amount as refusal

#### Scenario: Missing pin is entry freeze not an API
- **WHEN** `P22` has no Curve pin
- **THEN** the entry task records that a later pin must classify bound-exhaustion as revert versus residual success from that source, and MUST NOT export a pretend current Curve API or an invented refusal
