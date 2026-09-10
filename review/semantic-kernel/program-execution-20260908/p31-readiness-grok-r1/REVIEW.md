# P31 source-readiness independent review

**Decision: the four readiness drafts are usable source preparation. They are not accepted readiness, not adapter implementation, and not P31.**

This is a fresh native Grok 4.6 high audit of frozen sandbox `/home/charl/.cache/defiformal-program/program-execution-20260908/p31-readiness-grok-r1-sandbox` only. Live AGY P19 R12 work was not read. Frozen inputs were not modified. No network, subagents, Foreman, source edits, branches, commits, or pushes. No Compact, K, lake, or Lean build was run. Compiler versions in the pin are source-declared, not fresh tool observations.

Root captures the actual returned model as Grok 4.6 (`requested_model` in dispatch is `grok-4.6`) and independently adjudicates. cameronfreer lean4-skills was not invoked because no Lean code or proof is in this pin.

## Identities

Source pin: `7307349d0275af6fcb4144e1661d8b59d6b2663a`.

`inputs.json` declares 20 files. All 20 SHA-256 values match frozen sandbox bytes. Manifest `source_files` (13) match SHA-256, byte length, and Git blob SHA-1 recomputed as `sha1("blob " + len + NUL + bytes)` from those frozen bytes. Manifest record hashes match `moriarty.json`, `compact.json`, `zkir.json`, `pct.json`, `commands.json`, and `README.md`. Live `git show` against `/home/charl/Moriarty` was not repeated. The sandbox capture commands recorded that `git show` of this pin. This audit checks the captured bytes, not a second live-repo read.

No extra sandbox files were found. `LICENSE` is Apache License 2.0. Manifest `acceptance` is false. Brief SHA-256 matches dispatch: `993d15dc7903780cb4f4227e1454f9b77f6f6c977830d10eb44ff2258ba3ffe1`.

| Path | SHA-256 | Git blob |
| --- | --- | --- |
| `moriarty.json` | `a13c187102034022222b06da06686a6f2fd1c6acda6dcaba2f5a98f3934bea84` | (record) |
| `compact.json` | `017454cb410180ee26117730ef4f508d1596c99ba0c750e1b147cbcaf7f384d6` | (record) |
| `zkir.json` | `58e54486bb3605a4c9079040372a6f644477d3fa26fb80776b663b0e3b8bdff2` | (record) |
| `pct.json` | `0dde3610bb31dd84ba4db76f446d8c0055cef26bfbc659e70246f1c4bf5619aa` | (record) |
| `source/LICENSE` | `564375305a412a292d2e12024b657786ced6b4688b7b7c4b0bdb218f650a4367` | `71fe98a3f5dd6ad99733ca2c24af28b3716eb9ba` |
| `src/types.ts` | `5cc7356e9a38a74f1a202c7c6c8d7ac6d1ef6eac8fe0d8013beb242e3de604d0` | `558fc0f05a1b3efbdf3e53101cf00b3fd211429b` |
| `src/runtime-types.ts` | `f6ba49cff1900109ac9c8d2e3fdf3e69b8037dd2a6ce5c539dac2b9a081ae7e0` | `9eb79101327e4ef3a08179916b854561927dd217` |
| `src/evaluate.ts` | `395041bfedcb30d03bb525df2492c99e9c5f72dcf1784d58db0b9c605efc03f9` | `13e806c08b06596baf743a3e67686a8583f3a1ca` |
| `src/codec.ts` | `8575d98e630fed5b6e68b23c574aec450fc2bbce1b83b057ce6154e43610b7e8` | `09d59cad2a00f743e788b1ee23ede606820746d9` |
| `src/lower-compact.ts` | `6d99da9126627ee7f0990bc4361824ad13fffb1c787352fc9ce23edfd3ce3997` | `9f4878aa616ca763ecdbcfe095a26653ef489fbe` |
| `src/successor/core.ts` | `51376b05dc210093db1080ec22d4264f7b6daaafc6c42af97e429f0e2872b2f7` | `a444ee7f0c78c6a16a9344e12371254659357863` |
| `src/successor/repayment.ts` | `e1be96f067ddb2c5166342012388e0f612871705cd6aa74279a45ef9b288c808` | `140ace6d35046715efda9cadfb3c582cbd644109` |
| `compact/MAPPING.md` | `3732353f1ed5162c1bff7820bca38c639c268637e138ae317e2dee5eb1464eb5` | `429fe4ef620fb0b287fed72b37bbb36a15c3c28b` |
| `compact/arithmetic.compact` | `b2969d0bc346fa93d88546578c9f9d29f1b74d7bc3f88f2e04709fa0932d9415` | `b8a5b4d56e83d6b51a96a8229569bd8eed6f3496` |
| `compact/verify-mapping.py` | `7145639c3b19f45e8e280fabe72b06cb87c8038e3b219baf76ebba1c92e78960` | `a6d0cf66bbbde53fa20b720e7d12b20ce12121b7` |
| `formal/k/moriarty.k` | `306332cec1895862cefb7061d6f9e40c92c3d88240c9da471053b10add3bec11` | `25619251f4f2e54841670e20b24e98dbea03d6a3` |
| `spec/numeric-profile.json` | `6d88f694bf8af8c5b7dd75fce76f58fe0d14fc68c2782dd0d3fb885ca4a7eb15` | `205d2268f1ec4b2df26a0dba66a1669da1398f8a` |

## Task boundary

P31 tasks 32.1–32.4 ask for readiness records that name a verified interface/source or `blocked_unavailable`. Tasks 32.5–32.8 require actual verified adapters under proposed `lean/DefiKernel/Adapters/`. Task 32.9 reviews those adapter results.

These drafts keep `readiness_accepted`, `adapter_implemented`, `P31_accepted`, and `whole_program_complete` false. None marks an implementation task complete by deferral. None uses `blocked_unavailable`. That is the right status: named interfaces exist in the pin, and adapters are not implemented here.

Missing Lean implementation is the known next phase. It is not a fabricated test failure. Absence of a verified DeFiKernel adapter contract in this sandbox is not proof that no implementation exists anywhere outside this pin.

## Moriarty (32.1)

Named APIs exist in the pin.

- `BoundProgram` and Core types in `src/types.ts` with profile `moriarty-bounded-atomic/1`
- `EvaluationInput`, `Simulation`, `Complete`, `Rejected` in `src/runtime-types.ts`
- `createSimulator` and `evaluate` in `src/evaluate.ts`
- `FundedCore` in `src/successor/core.ts` with `moriarty-funded-source/0`
- `prepareRepayment` in `src/successor/repayment.ts` with `moriarty-funded-repayment/0`

Profile separation is real. Bounded-atomic programs, funded-source Core types, and the funded-repayment kernel are three distinct schemas. `FundedCore` is documented as not an execution input. `prepareRepayment` is the transition kernel. An adapter must choose and declare one profile.

`canonicalEncode` admits records, arrays, strings, and booleans and rejects `null` and numeric primitives (`NON_CANONICAL_VALUE`). Callers still need a closed schema (`decodeCanonicalRecord`). Extra codec rules (sparse arrays, accessors, non-`Object` prototypes, symbol keys, non-ASCII keys, cycles, depth 256, lone surrogates) do not contradict the record. `evaluate.ts` uses `canonicalEncode` for structural equality.

Funded repayment checks transfer-in-step (`step.get(transferId)`), payer/creditor/settlement-asset match, unused `allocationId`, `convertNominal`, nonzero settlement, and remaining unallocated funding. A transfer seeds `remaining = amount`. Each repay subtracts `settlement.value`. Distinct allocation IDs may consume one transfer. A one-allocation-per-transfer rule would narrow source.

`evaluate` uses `checkedUInt128` after JavaScript `BigInt` add/mul/sub. A product that does not fit UInt128 is rejected even if a later quotient would fit.

No DeFiKernel correspondence is in these files or in retained `moriarty.k`.

`evaluate.ts` and `lower-compact.ts` import unpinned `frontend.ts`. `evaluate.ts` also imports unpinned `registered-bounds.ts`. The named public APIs are in the pin. A closed runnable compile/bounds pin is not. That is a capture gap, not proof that compile does not exist at the pin.

Funded repayment admits compact `JSON.parse`/`JSON.stringify` equality, not `canonicalEncode`. Applying the bounded-atomic codec to repayment inputs would narrow that kernel.

## Compact (32.2)

`lowerCompact` and `CompactMapping` exist. `arithmetic.compact` exports `checkedAdd`, `checkedSub`, `checkedMul`, `checkedDiv`. The mapper rejects persistent Text, observation Text, `And`/`Or`, and unguarded Text arguments. It states it omits obligation-ledger, authority, proof, settlement, and acceptance. `checkedMul` requires the UInt128 product to fit via 64-bit limbs (`UINT_OVERFLOW_HIGH` / `UINT_OVERFLOW_MIDDLE`).

The source evaluator still has And/Or short-circuit and Text state. The mapper is a restricted Core mapping, not full source. Treating it as full Core would narrow Moriarty.

`checkedAdd` is `(a + b) as Uint<128>` with no explicit overflow assert in this pin. Compact add wrap-versus-reject is compiler semantics and was not observed. Do not equate that cast with `evaluate.ts` `checkedUInt128` without a compiler-semantics pin. The Compact record's UInt128-intermediate claim is about multiplication, which `checkedMul` does enforce.

Hardcoded metadata `compiler: '0.31.1'`, `language: '0.23.0'`, `runtime: '0.16.0'` are source-declared stamps, not tool observations.

## ZKIR (32.3)

`verify-mapping.py` asserts compiler `0.31.1`, language `0.23.0`, runtime `0.16.0`, compiles with `--skip-zk`, and asserts no `.prover` or `.verifier` files. `compactSnapshotHarness` is labeled test-only and stores `disclose(kernel)` without moving assets. Receipt fields `keysGenerated` and `proofsGenerated` are false.

These versions are source-declared. This audit did not run `compact`. No general ZKIR schema is in the thirteen files. The record status `generated_test_wrapper_route_identified_verified_ZKIR_contract_missing` is accurate. That is a missing verified adapter contract, not a claim that no ZKIR compiler exists.

## PCT (32.4)

`TrustedAcceptanceBackend` is a deployment-owned interface (`authenticate`, `verifyAndCommit`) extending `SourceBinding`. The package comment says this package supplies neither cryptographic claim verification nor durable atomic state-and-nonce consumption, and that a boolean callback is not an implementation.

`evaluate` returns `PROOF_INVALID` when backend methods are absent, discards client `checks`, reconstructs them via `authenticate`, and requires `Committed` hashes (`traceHash`, `proofContextHash`, `afterStateHash`). It recompiles `backend.source` / `backend.bounds`. `Simulation` is internal and unaccepted. It is not public proof-carrying acceptance.

Certificate consumption waiting on accepted P20 is stated. Cryptographic, semantic, oracle, custody, legal, and durable state/nonce classes are kept separate. The record does not wait on P19 checker existence.

## What the records do not do

They do not invent Moriarty/Compact/ZKIR/PCT semantics beyond the pinned files. They do not claim DeFiKernel adapters. They do not treat `--skip-zk` snapshots as proofs. They do not freeze `numeric-profile.json` (`proposed-not-frozen`). They do not treat retained K as full funded repayment. They do not mark 32.5–32.8 complete.

Unsupported claims in the four records: none found. Accidental narrowing inside the records: none found. Narrowing would occur later if an adapter substituted wire-format equality for canonicalEncode, a one-allocation-per-transfer rule, Compact subset for full Core, K projection for `prepareRepayment`, or skip-zk artifacts for keys/proofs.

## Precise remaining gaps

1. Capture `frontend.ts` and `registered-bounds.ts` (and their compile closure) if implementation needs a closed runnable pin.
2. Choose one adapter profile: bounded-atomic `evaluate`, `FundedCore` types, or `prepareRepayment`.
3. Do not apply bounded-atomic `canonicalEncode` to funded-repayment compact JSON.
4. Do not treat `moriarty.k` as full funded repayment. It is a two-balance, one-transfer, optional-one-repay projection. Its unallocated check is `CASH <= T`.
5. Capture the exact ZKIR artifact format before task 32.7.
6. Pin Compact add overflow semantics if Compact arithmetic is reused.
7. Treat `numeric-profile.json` as proposed, not frozen.
8. Implement and verify adapters 32.5–32.8 against this pin. Missing Lean is the next phase.
9. Complete accepted P20 before PCT certificate consumption.
10. Task 32.9 reviews actual adapter modules. None are in this sandbox.

P31 and whole-program acceptance remain false.
