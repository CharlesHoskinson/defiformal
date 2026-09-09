# P16 source repair r4 independent review

**CHANGES_REQUIRED: R1 and R2 are substantially repaired but remain incomplete.** The remaining repairs are confined to execution-success checks and complete protocol parsing. No accepted Lean/proof source repair, wider P17/P21 prerequisite, portability engine or P30 refinement proof is requested.

Exact archive: `p16-source-candidate-r4.tar.gz`, SHA-256 `b5a344f2db9f73dfe4d6a0aa17e46985cdb49cc431740a6312274561c82c6221`. Root manifest binds 3,927 files. Native Grok session `01a08488-e6a2-7a50-841d-3700e2c340b7` ended normally after 52 turns, process 0, reported actual model `grok-4.6-build`. Independent reviewer: GPT-6; no separate provider attestation is invented.

## Retained positives and fresh validation

The fresh intact campaign exits 0 in 5.882 seconds with 12/12 source observations, six compiled production mutants, complete RuntimeAudit rows and twelve checked Lean bindings. It uses the reviewer-private Lean cache; only the campaign's execution-root binding is redirected to the private sandbox. Frozen modules are imported unchanged from the worktree, and generated evidence stays in this review directory. No worktree `.lake` is used.

Independent checks match all seven baseline/mutant compiler identities, creation/runtime bytecode hashes, exact single source edits, selector, twelve ABI encodings and twelve Lean input/result/truth bindings. The original r3 positives and accepted r2 proof/model/recorder review remain valid. The pinned solc, EVM, Istanbul genesis and retained runner identities match prior review; baseline runtime is `07f36245480430411ce6a9afe829520f63ffd9a9af7fd7cac52f133d75c6f580`, creation is `74306c39f38934e603ee0beb9e4989025c08dd17b8383a209231c3d287f52182`, selector `6c84a8a2`. Strict removal yields mutant public 1, equality still refuses, all ordinary ADD controls remain unchanged, and identity-skip produces the actual INVALID opcode exception.

Fresh CLI controls return mismatch 1, empty selection 3, missing compiler 3, malformed fixtures 3, fixture omission/type error/extra ID 3, Lean text control suite 0, and recorder control suite 0. The recorder suite exercises child 0/1/3 and timeout descendant cleanup with an unaffected outside process. Selected author fault controls were replayed against unchanged production consumers, with output destinations and Lean cache redirected: missing receipt, crash partial output and timeout now block 3; the genuine generated Lean false-comparison control returns 1. Wrong argv, cwd, receipt exit type and output hash each block 3 in additional actual full-campaign relay controls. A real pinned-solc invocation with a tiny timeout returns `blocked_compile_timeout`; its outside process remains alive. These are fixes that should be retained.

All 3,330 author manifest rows verify. Before/after candidate checks match all 3,927 files, all 197 accepted r2 files, 591 unchanged r3 files, 144 planning files and 179 prior tracked Lean-tree files. Tracked worktree status is clean. Four modules changed from r3; `p16_mutants.py` is unchanged despite the author's shorthand “five modules.” Current r4 scores and commands are new evidence; the historical failed r3 score/binding attempt remains historical. No old reviews or author evidence were rewritten.

## R1 remaining — successful execution and recognized EVM syntax

Exact locations: `scripts/token0_p16/source_campaign.py:719` (`score_lean_execution`), `p16_common.py:472` (`invocation_is_complete`, completion versus success), `p16_common.py:354` (`validate_receipt` status consistency), and `p16_evm.py:102` (`classify_evm_stdout`, especially the final generic exception branch).

The decisive reproduction needs no forged receipt, substituted tool, or transport tampering. In `faults2/compiler-nonzero`, the reviewer changes only the generated ephemeral binding file by appending:

```lean
#check P16ReviewNonexistentDeclaration
```

The actual pinned Lean process prints its earlier valid rows, reports the unknown declaration, and exits **1**. The unchanged recorder records **child 1 / wrapper 1**. The campaign nevertheless reports Lean status `ok`, score exit 0 and overall exit **0**. `invocation_is_complete` permits an ordinary nonzero completed process, and `score_lean_execution` returns the successful parsed rows without requiring successful execution. This remains the original R1 obligation: compilation failure is blocked, not semantic success.

Additional full-campaign diagnostic relay controls distinguish receipt structure from semantic parsing. Each relay first invokes the genuine recorder/EVM; its precise post-record corruption is retained in `probes/receipt_fault_relay.py`:

- `receipt-faults/wrong-status` changes only the receipt classification to `failure` while child/wrapper remain 0. It still scores overall 0 with six mutants credited. Ordinary classification and exit consistency are not enforced.
- `receipt-faults/unknown-error-output` substitutes `error: unrecognized diagnostic failure` and updates the receipt's byte count/hash consistently. It still scores overall 0 and six mutants because any line containing `error:` falls through to `evm_exception`, with an invented empty payload if none was present.

The latter tests parser behavior on receipt-bound malformed output; it is not a claim that the pinned EVM naturally emitted that text, nor a demand for cryptographic authenticity against malicious local tools. The same relay demonstrates that wrong argv/cwd/types/hashes now block correctly.

Required R1 repair: preserve valid failure receipts, but require child **0**, wrapper **0**, classification **ok**, and no timeout/cancellation/crash for source/model semantic scoring. Enforce classification/exit consistency at receipt validation or the scoring boundary. Keep a well-formed semantic comparison false as exit 1; a compiler failure with partial rows must return blocked 3. Parse the complete documented pinned EVM output grammar; unknown error text, missing payload where required, ambiguous/duplicate result lines or extra protocol output must block, not become generic exceptions. Preserve exact recognized `execution reverted` and `invalid opcode: INVALID` behavior and the separate STOP smoke rule. Add the actual Lean-error-after-rows control and consistent-metadata unknown-output/status controls to the repaired runner's focused controls.

## R2 remaining — do not silently discard malformed protocol rows

Exact locations: `scripts/token0_p16/source_campaign.py:583` (`parse_lean_bindings`, row filtering at line 588) and `:536` (`parse_runtime_audit`, suffix search rather than a complete defined protocol).

`faults2/malformed-extra` changes only the generated ephemeral Lean file by appending:

```lean
#eval IO.println "P16-ADD malformed extra protocol row"
```

The real pinned Lean process emits the complete normal twelve rows plus this malformed extra P16 row and exits 0. The campaign still exits **0**. The parser only checks lines beginning `P16-` that also contain ` sqrtP=`; this malformed protocol line is silently ignored. Existing author replacement-row controls block because an ID then disappears, but they do not demonstrate rejection of malformed extra rows alongside a complete set.

Required R2 repair: define and validate the whole RuntimeAudit/binding protocol, while explicitly allowing documented Lake/compiler log wrappers outside that protocol. Reject every malformed, duplicate, unknown or conflicting protocol row and inconsistent summary/result metadata rather than selecting a passing subset. Keep exact expected IDs, stored inputs, result syntax, truth and denominators, including the now-working fixture validation and generated bindings. Add the genuine extra-row emission control alongside existing false/missing/duplicate/malformed replacement controls. A malformed protocol blocks 3; a complete, consistent, well-formed false comparison fails 1.

## Remaining P16 scope and evidence use

The only required repairs from this review are the remaining parts of R1/R2 above, followed by one fresh authoritative intact score and focused failing/blocked controls. The accepted planning/proof scope and preserved positive source evidence do not need another whole proof audit. The remaining original token0 tasks 4.1–4.4, 5.1/5.2/5.4 and 6.1–6.3, and corresponding program 17.5–17.6 contribution, cannot receive final source/operation acceptance until those consumer defects are independently closed. This is not an additional demand for P17 Typed reuse, the P21 mixed 45-fixture/M09 remainder, or P30 universal source refinement. Those remain separate work as planned. P18 packet/example publication follows accepted P16 and is not made a prerequisite here.

M09 handoff and scenario/remainder mapping retain the correct model/source distinction: F28 excluded, F31 designated, F32 only model-side under earlier invalidFee checks. Source failure labels remain distinct from Lean constructors. No deployment, full original mixed-liquidity task acceptance or universal assembly/source-refinement claim is made. Hardcoded W16/tool/evidence paths remain the previously documented replay limitation, not a new blocking portability gate.

Reviewer setup failures are preserved in `logs/reviewer-setup-failures.json`: initial private sandbox source-closure omission (setup blocked), a runner assuming a score after that block, an incorrect CLI mode spelling, and an adapted receipt-key mismatch. Corrected runs use new destinations and independently verified copied closure bytes; none is counted as a candidate semantic failure.

The rejected overlay and nonrecursive evidence manifests bind exact candidate/reviewer bytes. No source was edited. All reviewer execution has ended; checker and private cache are released.
