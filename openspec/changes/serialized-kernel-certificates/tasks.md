## 1. Independent planning gate

- [ ] 1.1 Freeze this OpenSpec package and `review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/` with `STATUS.gate_accepted=false`; verify independent GPT-6 reviews the frozen bytes, r1 archive `a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed`, r2 archive `122118df438c8c05a09f48e5097fb6f6bfd3c19cedece4dee20aa32757c4bc13` and r3 archive `e5b6415c6fe74b8654e9633e48dbc528118072b2f1306865b2c56855dab9b6a9` are unchanged, and no Lean/Python certificate implementation exists outside the planning checker.
- [ ] 1.2 Bind used Typed/Composition sources and the three Lean/Lake pins to Git `a12b7cac05a818cc8d35c2ca440b7170a2807e92`; verify each listed path's blob equals D and that original 53 readiness hashes are unchanged.
- [ ] 1.3 Preserve the attempt-1 root-setup failure, r1 synthetic controls, and every later failed planning check; verify those bytes still exist and receive no authorship credit.

## 2. Schema, rationals and decode/encode

- [ ] 2.1 Implement `DefiKernel.Certificates.Schema` from `grammar.json`; verify the module remains unelaborated until a recorded compiler check, then that F01–F07 codec failures match.
- [ ] 2.2 Implement canonical rational decode/encode (`num`/`den`, lowest terms, den>0); verify F03 unreduced, F04 lexical float, F05 zero-denominator and F28 `1/2`.
- [ ] 2.3 Implement identifier, enumeration, duplicate and canonical-key contracts; verify F06 unknown party, F07 negative id, F08 catalog-duplicate-after-decode, and F11 unknown executable field.
- [ ] 2.4 Prove encode_decode_roundtrip for every supported canonical DecodedIR as in correspondence-theorems.json; verify finite F25/F27/F28 tests as bounded evidence that does not discharge universal RC01, and that refused decode returns no kernel object (S39–S40, S78).
- [ ] 2.5 Implement decodeBytes/checkBytes/checkIR entrypoints with no ambient registry/env/config; verify F01 never calls execute and F25 payload carries explicit registry/store/ctx/env.
- [ ] 2.6 Implement lexical scientific/float scan before JSON parse and resource-limit blocked outcomes; verify F04 and that oversized/timeout inputs are blocked not refused.

## 3. Recomputing typed judgments

- [ ] 3.1 Implement typing via actual `Args.check`; verify F15 unit mismatch is `evaluation argumentUnit` and F16 claimed TypeCorrect does not skip Args.check on the intact checker.
- [ ] 3.2 Implement footprint recomputation from delivered template inventories including conservative `ite` reads; verify F17 stateReadFootprint, F18 envReadFootprint and F19 writeFootprint.
- [ ] 3.3 Implement authority via `hasAuthority`/`issueCapability`/`revokeCapability`; verify F20 unauthorizedInvoke, F21 unauthorizedDebit, F22 revoked id and F10 duplicate ids confer no extra debit rights.
- [ ] 3.4 Implement accounting and funds via `Evaluated.accountingOK` and nonnegative post-state; verify F23 unbalanced `accounting`, F24 `insufficientFunds` and F25 alice7/bob3 with full 32-cell frame.
- [ ] 3.5 Implement exact refusal constructors and short-circuit; verify F29 actorMismatch, F30 unknownOperation with typeCorrect not_reached, and F52 constructor identity.

## 4. Sequential composition

- [ ] 4.1 Implement catalog validation through actual `validateCatalog`; verify F08/F26 `configuration` after successful decode and that empty-document F01 never becomes a catalog pass.
- [ ] 4.2 Implement invoke/issue/revoke through actual `executeStep` and receipt extraction against the pre-state; verify F27 success, F32 unavailableOutput, F47 readAccess, F50 id 12 and F51 tombstone.
- [ ] 4.3 Implement sequential `run` correspondence; verify F48 two-event prior-output, F49 inert suffix, and F09 repeated-delta addition.
- [ ] 4.4 Reject unsupported composition and Claims operators; verify F14/F53 treeJoin with valid invoke rest are unsupportedForm, not complete.

## 5. Correspondence, pins and observations

- [ ] 5.1 Prove checkIR_execute_ok / checkIR_executeStep_ok over the supported IR domain; verify F25/F27/F50 as bounded instances with independent literals, not candidate oracles.
- [ ] 5.2 Prove checkIR_execute_error / checkIR_executeStep_error including pre-world preservation; verify F15–F24, F26, F29–F30, F32, F47 as bounded instances.
- [ ] 5.3 Implement source-pin matching against delivered dependency records distinct from untrusted envelope strings; verify F37 stale SHA refuses and F25 pin equals `a12b7cac05a818cc8d35c2ca440b7170a2807e92`.
- [ ] 5.4 Implement full 14-field Report/reportEq; verify F36 claimed next-state ExecutionResult mismatch and that codec/audit results are not Reports.

## 6. Runtime/proof boundary and audit roots

- [ ] 6.1 Classify `ComponentContract` propositions and theorem-name library fields as informational outstanding; verify F33/F38 accepted-with-outstanding, not executable pass.
- [ ] 6.2 Record six trust classes including environment-authenticity; verify F39 classification, F40 `missingObservation` not zero, and F41 missing class incomplete.
- [ ] 6.3 Keep LibraryTheoremsInstantiated and SourceRefinement outstanding without recorded compiler checks; verify F42/F43 and that Arithmetic/Atomic theorems are not new certificate acceptance.
- [ ] 6.4 Run `#audit_axioms` on Certificates, Typed and Composition prefixes including Correspondence/Soundness; verify F44/F45/F46, empty theorem scope blocked, no unimported-universe claim.

## 7. Fixtures, mutations, projection and runner

- [ ] 7.1 Materialize every fixture in `fixtures.json` from `baseline.json` with independent expected fields and unique check ids; verify 32-cell/12-store/fresh-id-12 frame and F47–F54 coverage.
- [ ] 7.2 Implement `Certificates.Audit` with unique nonempty check names that count false checks correctly; verify F25 positives remain true on intact source.
- [ ] 7.3 Adapt `scripts/run_certificate_mutations.py` with Typed/Composition/Certificates proof-tail projection from `mutation-projection.json`; verify field-set equality, outside-repo output, timeout/empty blocked, outer invocation record, and intact projected sibling observations.
- [ ] 7.4 Freeze M01–M16 needles as unique runtime sites (7 future, 9 existing); run each as its own one-mutant SPEC and verify designated false plus protected positive including refusal protections.
- [ ] 7.5 Preserve every compiler failure, timeout, cancellation and malformed output without semantic credit; verify intact sibling F25 still passes after each isolated mutant restore.
- [ ] 7.6 Confirm no runtime declaration is discarded by projection guards on all nine existing targets and listed consumers.

## 8. Integration and evidence

- [ ] 8.1 Add only parent-owned root import after planning acceptance and run fresh Lean plus runtime checks; verify delivered Typed/Composition semantics unchanged.
- [ ] 8.2 Run the three `#audit_axioms` prefix commands with nonempty imported theorems, standard axioms only, no sorry/custom axioms/`native_decide`; verify declared-root coverage and identity records separate from envelope strings.
- [ ] 8.3 Reconcile every requirement, scenario, fixture, mutant and task with actual commands; verify nonempty counts and that roadmap §5 boxes remain unchecked. Counts are not semantic proofs.
- [ ] 8.4 Obtain independent GPT-6 implementation/evidence review on the same frozen candidate, preserve r1 review identity, and keep historical Fable/Opus/GPT reports unrelabelled; verify actual returned model and input hashes.
- [ ] 8.5 Publish accepted source/evidence to `semantic-kernel-pivot` only after that later evidence review; verify no merge to main and that Claims/Tree/Nary/Quint/fidelity remainder stays open.
- [ ] 8.6 Implement author `--check` isolated CLI controls for empty/missing/changed/spec-drift with intact sibling; verify a broken control fails the suite and r1 synthetic records remain historical.
