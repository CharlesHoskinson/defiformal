# Certificates official planning r3

Native Grok 4.6 repaired official r2 **CHANGES_REQUIRED** findings R1–R5. Independent GPT-6 / gpt-6-astra must review this freeze. `STATUS.gate_accepted` is false. No certificate implementation.

Cancelled attempt `01a0827d-aa5e-7b72-bba6-f23b7b809432` (max 40 turns, process exit 1) is **not** this candidate and is **not** acceptance. Its terminal is `p19-planning-author-r3-attempt1-terminal.json`; partial archive SHA-256 `a131784a5656d0cca0f7ceb1f6b29995417daf78d36c43cfdffbf6985e6cb4b2`. This session continued those plan bytes and finished the r3 checker/evidence.

r1 archive `a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed` and r2 archive `122118df438c8c05a09f48e5097fb6f6bfd3c19cedece4dee20aa32757c4bc13` are unchanged. r1/r2 package/evidence bytes were not resealed.

Final r2 review SHA-256 `b4a7558255cd315ea324740ad2e815c6e3edb60a832f0e52ae8f599a570b82c7`; verdict `7d4231316413e0fb1272e95fc12235fa2651741a2cdafe539bbcca7c56b63998`; evidence-manifest `92ddb33a6f4cddd698b7248ffe999a0ca044f1f859a387b188b26ad2538bd040`.

## R1–R5 (planning contracts and stored fixtures)

| ID | Repair |
| --- | --- |
| R1 | Kernel projections (`T-kernel-execute-ok/error`, step, run-cursor) are separate from `T-report-policy-accepted`. F25/F36 share the transfer payload; F36 refuses `observationMismatch.claimedNextState` and retains alice USD 7. Proofs remain P20. |
| R2 | F09/F17/F18/F19/F23/F40/F47 now request live scoped invoke (and debit where required) at store indices 12/13. F18 env unit is amount USD so `envReadFootprint` is reachable. M09/M10 use `JudgmentOutcome.true` / `notApplicable`. M03/M15/M06 remaining-kernel premises are stored. |
| R3 | F49/F24 `accountingCorrect=false` on `insufficientFunds`. Worlds are `|D|×|P|×|A|` (32 only for 2×4×4). Policy refusal retains post-world; kernel refusal retains pre-world. F50/F51 receipts are issued/revoked, not null. |
| R4 | Compact canonical bytes; nested key order including types/source_pin/payloads; `checkIR : DecodedExecution → Report`. |
| R5 | Allowlist `StepSound`, `ReceiptAuthorized`, `TraceSound`, `RefusalSound` after `-- BEGIN PROOFS` at bound Execution/Sequence hashes. |

Reachability diagnostics **consume stored fixture/contract values**. They are planning diagnostics, not kernel, proof, IR-checker, or mutant execution.

## Fresh commands (actual child exits)

| Command/control | Exit | Diagnostic |
| --- | ---: | --- |
| openspec validate --strict | 0 | `Change 'serialized-kernel-certificates' is valid` |
| package.py --prepare | 0 | author consistency only |
| package.py --seal then --check intact | 0 | sealed nonempty package |
| empty fixtures inventory | 3 | `BLOCKED: fixtures: empty (0 of 0)` |
| bound STATUS.json missing | 3 | manifest missing STATUS.json |
| bound STATUS.json changed | 1 | manifest mismatch |
| SF01 identifier changed | 1 | `FAILED: requirement map identity` |
| restored intact sibling | 0 | sealed nonempty package |
| preserved r2 plan --reachability | 1 | F09/F17/F18/F19/F23/F40/F47 missing matching invoke; F18 wrong env unit |

Setup/timeout/compile failure was not used as semantic detection.

## Counts

Historical r2 (frozen, not this candidate): 5 capabilities, 31 requirements, 81 scenarios, 38 tasks, 54 fixtures, 16 mutants, 592 structural fixture checks.

This r3 candidate, independently reconciled: 5 capabilities, 37 requirements, 99 scenarios (S01–S99), 38 unchecked tasks, 54 fixtures, 16 mutants, 636 author planning checks. Those checks are not 636 semantic certificate executions. Lean executions 0; certificate executions 0; mutant detections 0.

## Not claimed

Implementation, Lean proofs, mutation detection, P19 tasks 20.2–20.4, P20 correspondence, qualified certificate delivery, or planning-gate acceptance.

## Remainders

`remainder-obligations.json` L01–L12. L12 is P20 quantified correspondence. Roadmap §5 boxes remain unchecked.
