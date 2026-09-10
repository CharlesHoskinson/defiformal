# P18 grok-r2 repair — native Grok 4.6

**Status: ready for independent Opus review. Not acceptance. Not self-accepted.**

Root verification (not Opus) required P18-R1..R5 before review. Requested author `grok-4.6` high. Requested reviewer `opus`, reported reviewer null. No Foreman, commit, or push. grok-r1 logs and generator were not overwritten. R1 candidate archive SHA-256 `2cdbb76c422d968745dbd3973e6029a87b7c41c608014e5df364503db602ae18` remains historical.

## Root causes

The R1 validator globbed whatever `*.packet.json` existed. Control packets alone could pass. It did not resolve source/model log hashes to bound files, did not derive `actually_run` from those records, treated empty Tests.lean stdout as an executed model run, and mapped empty required evidence to exit 1.

## Repairs

| Id | Repair |
| --- | --- |
| P18-R1 | `required-inventory.json` lists `p18.token0.next-price.packet.json` independently of the glob. Missing required packet is blocked 3. |
| P18-R2 | `run_release_controls.py` perturbs the current substantive packet. Empty required evidence is 3; contradictory claims are 1; intact is 0. |
| P18-R3 | `evidence-binding-index.json` maps each run id to a versioned log path. Claimed hash is compared to that file, not to hash membership. |
| P18-R4 | Denominators are derived from executed nonempty runtime records, partitions, theorems, and bound mutant summaries. |
| P18-R5 | Tests.lean compile receipt stays in `compilation_bindings`. It is not a `model_runs` runtime witness. `actually_run` is 16 = 12 source + 4 model runtime invocations. |

## Actual current consumer results

| Case | Expected | Actual |
| --- | --- | --- |
| intact | 0 | 0 |
| missing-required-main-packet | 3 | 3 |
| zero-main-execution-denominator | 3 | 3 |
| missing-main-source | 3 | 3 |
| changed-actual-source-log-binding | 1 | 1 |
| invented-execution-denominator | 1 | 1 |
| missing-production-mutations-and-controls | 3 | 3 |
| empty-stdout-presented-as-model-runtime | 1 | 1 |

Driver matched 8/8 and exits 0 only when every case matches.

Public Lean example and wrapper remain 12/12. RuntimeAudit remains 22 true. Missing binding remains 3. Actual binder ran `bind-environment.py` (not a cat/echo of a previous receipt). Tests.lean compile exit 0 with 0-byte stdout, recorded as compilation.

Accepted P16 Lean modules, 12 EVM rows, and six compiled mutants were not rerun and were not edited.
