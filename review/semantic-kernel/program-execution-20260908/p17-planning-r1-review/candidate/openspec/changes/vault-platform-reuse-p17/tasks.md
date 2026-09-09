# P17 vault source-entry and reuse implementation tasks (after independent planning review)

All boxes stay unchecked in this planning freeze. Frozen program tasks 18.1–18.7 are not ticked here. Do not start Lean or a production harness until independent GPT-6 accepts this slice. Do not assume the P16 source gate is closed.

## 1. Planning gate and pin re-bind

- [ ] 1.1 Obtain independent GPT-6 review of this exact `vault-platform-reuse-p17` candidate, record verdict, requested/reported model identity, and input hashes, and verify `gate_accepted` remains false until that review.
- [ ] 1.2 Re-hash the captured ten-key closure, main versus L2 `SUsds.sol`, foundry.toml, compiler binary, and compile-smoke receipt, and verify they still match `source-pin.json` and `compiler-harness-plan.json`.
- [ ] 1.3 After acceptance only, run `cd lean && lake build DefiKernel.Arithmetic.Verify` on the repo toolchain pin `leanprover/lean4:v4.33.0-rc2`, and verify exit 0 with saved argv/cwd/UTC/logs before adding Vault modules.

## 2. Shared engine and compiler/EVM

- [ ] 2.1 Extract `scripts/platform_engine/` from delivered `scripts/token0_p16/record_cmd.py` plus compile/prestate/score, with portable path/settings, and verify token0 and vault campaigns call that engine rather than wrapping two campaigns.
- [ ] 2.2 Compile captured `src/SUsds.sol` plus the ten-key closure with solc `0.8.21+commit.d9974bed` SHA-256 `f2857a898be15c69e8de5598dcd3f3e169e94964a0ce9a0bbb1b111f145a81df`, optimizer 200, shanghai, `bytecodeHash none`, without editing captured bytes, and verify bytecode hashes are recorded and are not the IPFS smoke hashes.
- [ ] 2.3 Bind a Shanghai-enabled genesis JSON (not P16 Istanbul), verify `evm run --dump` roundtrip with an unscored smoke, and verify missing/unusable dump is `blocked_missing_evm` exit 3.
- [ ] 2.4 Deploy VatMock, UsdsMock, UsdsJoinMock, SUsds implementation, and ERC1967 proxy; call `initialize`; and verify mocks remain labelled harness assumptions and no address/block/codehash identity is claimed.
- [ ] 2.5 If solc or evm cannot be bound, record `blocked_missing_compiler` or `blocked_missing_evm` with the missing identity, and verify that status is not scored as source agreement.

## 3. Vault library and observations

- [ ] 3.1 Create `lean/DefiKernel/Vault/Types.lean` and `Conversion.lean` using `Rounding.divideNat` / premised `mulDiv` and `Operations.mul` for 0.8.21 product overflow, and verify `_divup` matches source including the zero-numerator clause with `chi > 0`.
- [ ] 3.2 Implement deposit/mint/withdraw/redeem under D0/D1 premises with ordered drip/_mint/_burn, and verify invalid-address runs before transferFrom and that successful transferFrom is not treated as USDS credit without observed balances.
- [ ] 3.3 Evaluate fixtures P17-DEP-D0, P17-MINT-D0, P17-RED-D0, P17-WD-D0, P17-DEP-D1, P17-MINT-D1, P17-RED-D1, P17-WD-D1, P17-DEP-ZERO, P17-DEP-BAD-RECV, P17-DEP-SELF, P17-DEP-TF-BAL, P17-DEP-TF-ALLOW, P17-RED-BAL, P17-RED-ALLOW, and P17-DEP-MUL-OVF against the independent literals in `fixtures.json`, and verify every comparison is true with nonempty unique IDs.
- [ ] 3.4 Prove conversion bounds and authorized supply changes under `proof-obligations.json` using overflow premises rather than the source overflow-comment conclusion, and verify P17-NEG-MINT-NO-CREDIT is rejected.

## 4. Platform reuse (token0 + vault)

- [ ] 4.1 Implement the token0 quote-register Typed wrap via `Quantity.toQuantity` without editing accepted token0 theorem statements and without adding ledger fields to token0 source observations, and verify ordinary add `(2^96,1,1,true)` is a nonzero QuoteSqrtP effect.
- [ ] 4.2 Instantiate `Typed.execute_ok_iff` for the token0 quote-register adapter and the vault deposit adapter with real `e.Valid` premises, and verify neither adapter assumes the desired post-state as a hypothesis.
- [ ] 4.3 Run the common engine on both token0 (preserving accepted P16 observations and fail-closed scoring) and vault fixtures, and verify one engine, not two wrapped campaigns.
- [ ] 4.4 Record measured case-two new definitions, new assumptions, interface changes, and effort, and verify `P17.platform_reuse` stays false without that inventory.
- [ ] 4.5 Leave composition integration unclaimed, and verify no token0-to-vault sequential workflow is added.

## 5. Production mutants and audits

- [ ] 5.1 Implement compiled production mutants V-TF-SKIP and V-DEP-CEIL from `planned-mutations.json` as the named single Solidity edits, and verify V-TF-SKIP designated false is P17-DEP-D0 (shares mint, USDS vault unchanged) while P17-RED-D0 and P17-DEP-BAD-RECV remain unaffected, and V-DEP-CEIL designated false is P17-DEP-D1 while P17-DEP-D0 and P17-RED-D1 remain unaffected.
- [ ] 5.2 Classify compile failures as blocked, not detection, and verify Python-only edits and planning-validation controls are present only as diagnostic non-credit rows.
- [ ] 5.3 Create Vault RuntimeAudit/ProofAudit/Verify with nonempty theorem scope and `#audit_axioms`, and verify no `sorry`, custom axioms, or `native_decide`.

## 6. Review and remainders

- [ ] 6.1 Reconcile every spec scenario to proof, finite, mutation, diagnostic, or assumption evidence, and verify source-execution and mutation denominators are nonzero before complete operation credit.
- [ ] 6.2 Submit the implementation candidate to independent GPT-6, and verify no self-acceptance and that frozen program tasks remain unticked in this planning package.
- [ ] 6.3 Leave accrual/`_rpow`, UUPS, permit/IERC1271, L2 token, deployed identity, P21, and P30 named in `remaining-gates.json`, and verify `P17.platform_reuse` is not set from arithmetic-only reuse.
