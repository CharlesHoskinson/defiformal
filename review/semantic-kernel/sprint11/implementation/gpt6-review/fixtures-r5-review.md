# Fixtures r5 independent GPT-6 review

**ACCEPT WITH LIMITATIONS: runtime label repair only.** No required fix found. This accepts the exact source change and retained/replayed bounded evidence; it does not accept complete Sprint11 integration or award production mutation detections.

Reviewer: independent GPT-6 / gpt-6-astra. Author: native Grok. Directly parsed final native end record at line 1690 reports session `01a07ed5-e45f-70e2-85f6-c621d2aef4f9`, with actual modelUsage key `grok-4.6-build`. Root process record has exit0; compressed stream decompresses to its recorded raw SHA256. No usage values/signatures are reproduced.

## Exact source and semantic preservation

Candidate `94f70e502c75132656bd0902a17be60ca45ab1c2` contains the reviewed Tests blob, SHA256 `b63713488d3997a0ce4c68198a2792caf389a6265c040e3072e72f219bd1d8ca`. Comparing its Lean/scripts tree against prior candidate `bc002dd49fd531ab0aac757613c3051cd94a9bb6` finds only `lean/DefiKernel/Nary/Tests.lean` changed. Accepted r4 Tests SHA256 is `d029f586694a96ed3cdc8accd4bddd90162e36ca6e028dd0ad628da851666512`. Audit and Examples match both r4 snapshots and the private cache.

I inspected the complete diff, independently extracted old/new synth label and mutant-argument pairs, required every mutant argument and its order to match, and verified each new literal is exactly the snake_case transformation. Removing the one exact `emitSchedTag` helper, reversing its five use sites in emitted names, and restoring only the synth string literals reproduces the complete old file byte-for-byte. The retained independent diff, before/after/restored sources and executable checker make this stronger than comparing all-true outputs. There are 39 changed synth label strings, generating 78 F09 rows; schedule emission adds 96 F10 and six F18 renamed rows. The helper leaves `schedTag` and schedule data untouched. No comparison expression, Boolean argument, branch call, receipt, fixture input, mutant value, execution order or financial expectation changes. Thus all prior semantics, including the ten F03 binary checks and twelve F07 three-chunk checks, are preserved.

## Names, parser and SPEC controls

Independently parsing r4/r5 raw outputs gives an order-preserving 310-to-310 bijection: 180 changed names and 130 unchanged. Every previously valid name is unchanged; all 180 old invalid names are repaired, with no collision, dropped row or extra row. The transform prefixes digit-initial schedule segments with `s` and changes camelCase segments to snake_case. All outcomes remain true. A separately generated full name inventory from source literal names, synth pairs and finite schedules agrees exactly with the 310 emitted names.

The frozen runner itself remains SHA256 `4528dde870fdb3e4c408e4646f70dcc5f8d31a84623e488103eee528a2e020be`. The independent checker extracts its actual CHECK_NAME assignment and applies its observation/candidate line regex logic: all 310 new candidate lines parse as 310 unique observations. The preserved r4 output yields only 130 matching observations, explaining the old malformed-observation gate without treating that transport failure as a false runtime property. This is a focused parser control, not a new production runner invocation or a mutation detection.

All 16 actual M01–M16 SPEC files equal their committed pre-repair bytes. Every required-false name and protected-positive name is present, true in the control, and unchanged by the bijection. Every specified mutation needle still occurs exactly once in its actual source module. This preserves readiness to run the individual SPECs; it does not establish mutant sensitivity.

## Evidence and independent execution

All 50 author final-manifest entries match, and the manifest covers all regular files except itself. All 54 regular files in native archive `fixtures-r5-stage.tar.gz` match live bytes. Archive SHA256 is `36658f456df736cf16fe1668bf711c35a0ddac55cfb007b9960c102de40c6811`. Author fresh Tests build, Audit build and direct Audit elaboration/evaluation each record exit0 and empty stderr.

The independent replay ran `lake env lean --stdin` in the exclusively released fixture cache, importing Audit then evaluating its main. It exited0 with empty stderr in 2.320 seconds. All 310 lines are true and byte-identical to the author's output, SHA256 `4bf0c4ca9a8d15a421bfea40e1520e93ce037e271faba937188e33b39658f8f4`. All 25 local runtime import sources match worktree/private bytes. The retained inputs bind 125 local compiled artifacts, config pins, actual Lean/Lake binaries, runner, SPECs, source and evidence before replay; all remain unchanged afterward. This reviewer did not rebuild or modify source/cache artifacts. No main, causal, or proof cache was used. External packages are configuration-pinned; this report does not claim a complete external cache inventory.

The old r4 source and emitted-ID evidence retain their identities. The new mapping is an intentional transport correction, not a retroactive rewrite of old checks. Reconciliation and future runner executions must bind the r5 names/output and exact new candidate. Kernel proof acceptance, integrated inventory and each actual mutation execution remain separate parent gates.

Evidence: `fixtures-r5-evidence/check.py`, `result.json`, independent source inverse/diff/bijection, candidate/build checks, and replay source/stdout/stderr. There were no failed independent runtime probes. One discovery command referenced nonexistent `tools/` before locating the actual runner under `scripts/`; this had no effect on checks or source.
