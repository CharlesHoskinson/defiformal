# Certificates official planning r4

Native Grok 4.6 repaired remaining official r3 **CHANGES_REQUIRED** findings R1 and R3 only. Independent GPT-6 / gpt-6-astra must review this freeze. `STATUS.gate_accepted` is false. No certificate implementation. R2, R4 and substantive R5 were not reopened. No new fixture campaign.

Official r3 review SHA-256 `19e74032fdde1d1502a6211f928a7761b6a5f98fc28fcbe07585ebf3a57a70f1`. Candidate archive SHA-256 `e5b6415c6fe74b8654e9633e48dbc528118072b2f1306865b2c56855dab9b6a9` is unchanged as historical input. r1/r2/r3 package and evidence bytes were not resealed.

## R1

`rawExecute : DecodedExecution → RawObservation` is the quantified kernel target and is not a Report. Theorems that project `checkIR` now require the supported decoded execution domain/mode and `source_identity`. F25/F36/F37/F41 may share one kernel payload: F37 staleSource keeps pre-world, null receipt and execution not reached; F36 claimed-world refusal retains post-world. `T-report-policy-accepted` requires explicit `requested_discharge_ok` for `require_library_discharge` / `require_invariant_discharge` and recorded compiler/evidence predicates. Proofs remain P20.

## R3

Guard is a prior class, not `accountingCorrect`. Guard-before-footprint order is unchanged. F17/F18 keep `accountingCorrect=not_reached`. F24/F49 keep `accountingCorrect=false` on `insufficientFunds`, including after F49's successful prefix. Unreached accounting predicates are not evaluated to fill an outcome.

## Fresh commands (actual child exits)

| Command/control | Exit | Diagnostic |
| --- | ---: | --- |
| openspec validate --strict | 0 | `Change 'serialized-kernel-certificates' is valid` |
| package.py --prepare | 0 | author consistency only |
| package.py --seal then --check intact | 0 | sealed nonempty package |
| empty fixtures | 3 | `BLOCKED: fixtures: empty (0 of 0)` |
| missing STATUS.json | 3 | manifest missing |
| changed STATUS.json | 1 | manifest mismatch |
| SF01 identifier changed | 1 | `FAILED: requirement map identity` |
| restored intact sibling | 0 | sealed nonempty package |
| preserved r2 --reachability | 1 | missing matching invoke on F09/F17/F18/F19/F23/F40 |
| preserved r3 --reachability | 1 | missing `rawExecute`; guard still `accountingCorrect`; missing T-raw/T-checkIR |

One restored-intact attempt failed after a 68-file reseal that included live control-run files being rewritten. That failure is retained as a process receipt; the discriminating 43-file seal plus the eight controls above are the frozen evidence. Setup/timeout/compile failure was not used as semantic detection.

## Counts

Historical r3: 5 capabilities, 37 requirements, 99 scenarios, 38 tasks, 54 fixtures, 16 mutants, 636 author checks.

This r4 candidate: 5 capabilities, 37 requirements, 99 scenarios, 38 unchecked tasks, 54 fixtures, 16 mutants, **640** author planning checks. Lean executions 0; certificate executions 0; mutant detections 0.

## Not claimed / remainders

Implementation, Lean proofs, mutation detection, P19 tasks 20.2–20.4, P20 correspondence, qualified certificate delivery, or planning-gate acceptance. `remainder-obligations.json` L01–L12. Roadmap §5 boxes remain unchecked.
