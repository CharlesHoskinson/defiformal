# P16 token0 implementation tasks (after independent planning review)

All boxes stay unchecked in this planning freeze. Frozen program tasks 17.1–17.6 are not ticked here. Do not start Lean until independent GPT-6 accepts this slice.

## 1. Planning gate and pin re-bind

- [ ] 1.1 Obtain independent GPT-6 review of this exact `uniswap-token0-p16` candidate, record verdict, requested/reported model identity, and input hashes, and verify `gate_accepted` remains false until that review.
- [ ] 1.2 Re-hash the captured token0 closure, archive versus CURRENT.json `liquidity.sha256`, defective oracle, and compiler-identity file, and verify they still match `source-pin.json` and `compiler-harness-plan.json`.
- [ ] 1.3 After acceptance only, run `cd lean && lake build DefiKernel.Arithmetic.Verify` on the repo toolchain pin `leanprover/lean4:v4.33.0-rc2` (not a host default 4.33.1), and verify exit 0 with saved argv/cwd/UTC/logs (original 1.3).

## 2. FullMath substrate (original 2.2–2.3)

- [ ] 2.1 Create `Types.lean` with token0 `Failure` constructors, `U128/U160/U256`, and `Q96` only, and verify `Signed` is absent and original 2.1 signed/tick/fee/F45 residual remains P21.
- [ ] 2.2 Create `FullMath.lean` wrapping `Arithmetic.Rounding.mulDiv` at width 256, and verify original F01–F09 literals including phantom product F04, zero denominator F05, and quotient overflow F06/F08.
- [ ] 2.3 Prove FullMath success/refusal as the existing floor/ceiling specifications at width 256, and verify exported theorems mention neither assembly nor `native_decide`.

## 3. Token0 next-price library

- [ ] 3.1 Implement `getNextSqrtPriceFromAmount0RoundingUp` with identity, product-fit test, wrapped denominator sum, LowGasSafeMath fallback add, bare uint160 on add success, and SafeCast on remove, and verify it does not call `Operations.add` for the wrap sum.
- [ ] 3.2 Evaluate fixtures P16-I-ADD, P16-I-REM, P16-I-ZERO-LIQ, P16-ADD, P16-ADD-ROUND, P16-ADD-DEN0, P16-REQ, P16-REQ-STRICT, P16-REM, P16-SAFECAST, P16-PROD, and P16-WRAP against the independent literals in `fixtures.json`, and verify every comparison is true with nonempty unique IDs.
- [ ] 3.3 Prove public-helper branch equations under `proof-obligations.json` ordered Except composition (identity, amount ≠ 0 on nonidentity branches, FullMath then SafeCast on remove, wrap-fallback premises, future add-result and fallback-positivity bounds), and verify no statement is a restatement of an arbitrary helper.

## 4. Pinned compiler and EVM

- [ ] 4.1 Acquire official `solc-linux-amd64-v0.7.6+commit.7338295f` and verify its SHA-256 is `bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb` and `solc --version` reports `0.7.6+commit.7338295f`.
- [ ] 4.2 Compile `Token0Probe` with standard-json optimizer 800, `bytecodeHash none`, `evmVersion istanbul` over the captured six libraries without editing those bytes, and verify bytecode is produced and its hash is recorded.
- [ ] 4.3 Execute the probe on every P16 fixture partition including wrap, identity, add `2^95`, removal require, ordinary remove, and product overflow, and verify success/revert observations match Lean without assuming Failure names equal returndata.
- [ ] 4.4 If solc or evm cannot be acquired, record `blocked_missing_compiler` or `blocked_missing_evm` with the missing identity, and verify that status is not scored as source agreement.

## 5. Production mutants and audits

- [ ] 5.1 Implement compiled production mutants T0-ID-SKIP, T0-WRAP-SKIP, T0-PROD-SKIP, T0-REQ-SKIP, T0-FLOOR, and T0-CHECKED-ADD from `planned-mutations.json` as the named single Solidity edits, and verify T0-REQ-SKIP designated false is P16-REQ-STRICT (mutant public 1) while P16-REQ remains a refusing baseline/control and P16-ADD remains unaffected.
- [ ] 5.2 Classify compile failures as blocked, not detection, and verify Python-only edits are present only as diagnostic non-credit rows.
- [ ] 5.3 Create RuntimeAudit/ProofAudit/Verify with nonempty theorem scope and `#audit_axioms`, and verify no `sorry`, custom axioms, or `native_decide`.
- [ ] 5.4 Apply the repaired M09 control plan (F28 excluded, F32 named model-side sibling for Lean SwapMath with invalidFee/intOverflow preguards, F31 still designated false) in the P21 handoff record, and verify this increment does not compile or run M09 and does not treat F32 as a pinned Solidity control.

## 6. Review and remainders

- [ ] 6.1 Reconcile every spec scenario to proof, finite, mutation, diagnostic, or assumption evidence, and verify source-execution and mutation denominators are nonzero before complete operation credit.
- [ ] 6.2 Submit the implementation candidate to independent GPT-6, and verify no self-acceptance and that original mixed IDs remain open.
- [ ] 6.3 Leave TickMath, SwapMath, token1/delta, bitmap/liquidity/factory, original 2.1 signed/tick/fee/F45 residual, the 45-fixture campaign, compiled M01–M12, full traversal, and P30 refinement named in `remaining-gates.json`, and verify original 1.2 is not marked whole-task done.
