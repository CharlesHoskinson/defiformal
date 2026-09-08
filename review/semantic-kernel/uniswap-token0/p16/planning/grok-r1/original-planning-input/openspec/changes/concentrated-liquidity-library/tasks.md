# Concentrated-liquidity library implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL after the planning gate: superpowers:subagent-driven-development or superpowers:executing-plans. Native Grok 4.6 implements; independent GPT-6 checks. No Foreman. Do not start Lean until this change is accepted.

**Goal:** Implement the first concentrated-liquidity increment: checked signed/unsigned widths, mathematical FullMath, TickMath, SqrtPriceMath, single-range computeSwapStep, TickBitmap one-word search, LiquidityMath.addDelta, and factory fee/spacing predicates.

**Architecture:** New `DefiKernel.ConcentratedLiquidity` namespace reuses `Arithmetic.Word` and `Rounding.mulDiv` at width 256. FullMath assembly, Pool.swap traversal, compiler/EVM and deployment stay named gaps.

**Tech Stack:** Lean 4.33.0-rc2 / mathlib `v4.33.0-rc2` rev `51e6992efd06126df61a496bebf8f49482a4e129`, Python 3 fixture oracle already frozen, OpenSpec, native Grok 4.6 / GPT-6.

## Global Constraints

- No `sorry`, custom axioms, or `native_decide` in accepted proofs.
- Do not edit historical Arithmetic/Typed/pinned Solidity/roadmap/corpus/holdout files except the parent-owned root import after acceptance.
- Do not check the roadmap concentrated-liquidity box; remainder `R-FULL-TRAVERSAL` stays open.
- Fixture expected values are the frozen decimal strings in `fixtures.json`, not Lean self-outputs.
- Solidity 0.7.6 wrap is not 0.8 checked arithmetic.

## 1. Gate and bindings

- [ ] 1.1 Re-bind delivered Arithmetic APIs, Lake pins, and pinned v1.0.0 source SHA-256 values at implementation start and verify they still match this plan’s `source-correspondence.json` and `proposed-api.json`.
- [ ] 1.2 Obtain independent GPT-6 review of this identical planning freeze and verify the recorded verdict, model identity, input hashes and that gate accepted remains false until that review.
- [ ] 1.3 After acceptance only, prepare a private Lean cache and run `cd lean && lake build DefiKernel.Arithmetic.Verify` and verify exit 0 with saved argv/cwd/UTC/logs before adding new modules.

## 2. Words and FullMath

- [ ] 2.1 Create `Types.lean` with `Failure`, `Signed`, width aliases, `Q96`, tick/ratio/fee constants and checked constructors, and verify F45 plus constructor refusals match `fixtures.json`.
- [ ] 2.2 Create `FullMath.lean` wrapping `Arithmetic.Rounding.mulDiv` at width 256 with remapped errors, and verify F01–F09 including phantom product F04.
- [ ] 2.3 Prove FullMath success/refusal as the existing floor/ceiling specifications at width 256, and verify the exported theorems do not mention assembly or `native_decide`.

## 3. TickMath

- [ ] 3.1 Implement `getSqrtRatioAtTick` with the captured bit constants and round-up conversion, and verify F10–F15 including min/max constants and 887273 refusal.
- [ ] 3.2 Implement `getTickAtSqrtRatio` as the captured msb/log/choice algorithm, and verify F16–F19 against the independent greatest-tick literals.
- [ ] 3.3 Prove bound refusals, forward monotonicity on `[MIN_TICK, MAX_TICK]`, and the final inverse choice equation, and verify generic statements are not replaced by the five finite round-trips.

## 4. SqrtPriceMath and SwapMath

- [ ] 4.1 Implement amount0/amount1 deltas and next-price functions with the 0.7.6 overflow-fallback branch and UnsafeMath-positive-denominator helper, and verify F20–F27.
- [ ] 4.2 Implement `computeSwapStep` with exact-in remainder-as-fee, exact-out cap, `invalidFee` and `intOverflow` strengthenings, and verify F28–F33.
- [ ] 4.3 Prove branch equations from the actual conditionals and explicit `feePips < 1e6` / representable remaining premises, and verify no theorem assumes fee conservation as a hypothesis.

## 5. Bitmap, liquidity and factory context

- [ ] 5.1 Implement BitMath, floor compression, `position` and `nextInitializedTickWithinOneWord` over a total word map, and verify F34–F39.
- [ ] 5.2 Implement `addDelta` and factory fee/spacing predicates, and verify F40–F44.
- [ ] 5.3 Prove compress-floor, addDelta iff, and one-word search edges used by F38, and verify these proofs do not claim whole-pool traversal or Tick.cross.

## 6. Evidence

- [ ] 6.1 Create Examples/Tests evaluating all 45 fixtures against frozen literals, and verify every comparison is true with unique IDs F01–F45.
- [ ] 6.2 Create RuntimeAudit, ProofAudit and Verify with `#audit_axioms DefiKernel.ConcentratedLiquidity`, and verify nonempty theorem scope and only standard axioms.
- [ ] 6.3 Implement planned mutants M01–M12 with designated false fixtures and global positives F01/F10/F28/F40, and verify compile failures are classified blocked.
- [ ] 6.4 Add runner/evidence CLI controls for empty, missing, drifted and forged outputs, and verify exit 3 on blocked inputs and a passing sibling.
- [ ] 6.5 Reconcile every spec scenario to proof, finite, mutation or assumption evidence, and verify E05/E06 still list L4 out of scope and `R-FULL-TRAVERSAL` open.

## 7. Integration and remainder

- [ ] 7.1 After parent-owned root import, run `cd lean && lake build DefiKernel.ConcentratedLiquidity.Verify` and `lake env lean DefiKernel/ConcentratedLiquidity/Verify.lean`, and verify exit 0 with full logs.
- [ ] 7.2 Preserve original Arithmetic/Typed/pinned-source bytes and the 404 capture attempt, and verify those SHA-256 values are unchanged.
- [ ] 7.3 Submit implementation/evidence to independent GPT-6, record requested/reported model identity, and verify no self-acceptance.
- [ ] 7.4 Leave the roadmap concentrated-liquidity box unchecked and record `R-FULL-TRAVERSAL` plus `G-FULLMATH-ASSEMBLY`, `G-NO-SOLC-DIFFERENTIAL` and the wrap gaps, and verify the delivery text names those remainders.
