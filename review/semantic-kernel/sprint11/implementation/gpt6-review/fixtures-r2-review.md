# Fixture r2 focused independent review

**ACCEPT WITH LIMITATIONS for the F1–F4 corrections and the recorded 288-comparison fixture run.** No new blocking defect was found in this scope. F03's direct comparison against the actual binary executor remains open. This is not acceptance of the complete fixture contract, production mutations, financial proofs, or Sprint11.

GPT-6 acted as nonauthor checker. The native author stream ends with session `01a07ed5-e45f-70e2-85f6-c621d2aef4f9`, stop reason `end_turn`, and actual `modelUsage` key `grok-4.6-build`; the requested model was `grok-4.6`. The worker's own short report says `grok-4.6`; the archived terminal telemetry supplies the more precise actual identity.

## Frozen inputs and independent checks

| Source | SHA256 |
| --- | --- |
| Examples.lean | `1f844aad7c8912148d3a0660a76c670f91b0c262dc1e847c558e3ea964b2b8a4` |
| Tests.lean | `27576cb692b8befe6451910b076f8f06f870d76594d28681f15e44d5fbd0a05d` |
| Audit.lean | `575ebbbfa8f868af557edb1cd3f1c1c284caa28148bc08b5471f53ee749a6d90` |

All three live files equal both recorded source manifests, their preserved fixture-r2 snapshots, and their actual private-cache source files. The read-only checker script `fixtures-r2-check.py` exited 0 at 2026-09-08T03:49:48Z. Its companion `fixtures-r2-inputs.json` records absolute input paths, exact hashes, lengths, mtimes, the complete expected and actual 288-ID inventories, and command. Every captured input retained the same bytes and mtime during this check. Bounded earlier exploratory probe errors are recorded there; they were checker extraction errors and confer no author failure or success.

The source-derived inventory contains 102 fixed IDs, 42 synthetic variants with two IDs each, 96 F10 schedule/prefix IDs, and six generated F18 schedule IDs. It exactly equals the saved Audit output: **288 unique, nonempty comparisons, 288 true, zero false, zero missing or extra IDs**. Each of the sixteen prescribed mutation false labels and its own protected label is present and true on this unchanged candidate. This is baseline oracle availability, not evidence that mutants were executed or killed.

Saved `lake-build-final.status` and `eval-Audit.final.status` are 0, both stderr files are empty, and the build output records successful completion. The separately saved Audit output is the source of the 288 result count. The earlier F07 failure remains preserved with precisely three false IDs: `nary.refusal.peer_continues`, `nary.refusal.attempt`, and `nary.f07.skip-no-attempt`. The third p0 schedule token now has a corresponding branch slot, `[inv10, inv13, inv13]`, and the token is skipped after refusal; no failing check was removed.

This review executed no Lean, Lake, LSP, or mutation process. It verifies saved execution evidence and source semantics. In the private fixture cache, all four core dependencies equal the reviewed core-r3 snapshots. Live Observation already differs because the binary author is adding conversions; the other three live core files still match. Therefore this run binds the preserved pre-addition dependency version, not the later integrated tree. A fresh integrated run remains necessary after binary additions.

## Required correction follow-up

**F1 resolved.** Tests:433 now inspects `(f10Trace [0]).1`, requiring `.ready6` and exactly one received `some` attempt. `observeReserve` at Examples:917 stores the actual `MonitorInput.attempt`; the comparison uses the independent producer attempt, including participant/index/invocation/before/result. It does not read the unchanged base-machine attempt list. Replacing the delivered input with `none` therefore contradicts this prescribed check by inspection. An actual M14 mutation run is still required.

**F2 resolved.** Tests:313 emits separate candidate and independent negative IDs. Neither comparator can hide the other's failure through negation of a conjunction. Equal-pair positives exercise both comparators directly.

**F3 resolved in the requested fixture scope.** Examples:601–641 now contains a populated arbitrary entry with two old events, two prior outputs at indices 0 and 1, active consumed/nextIndex 2, failed peer consumed 3/nextIndex 1, nonempty store and global attempts. The continuation `[0,2]`, split into two nonempty chunks, invokes the existing stream's consumer at index 2 using its prior output, then permits the peer deposit. The literal full result retains the old raw worlds, outputs, failure and attempts and appends the expected new observations. Monitor entry 7 becomes 9 both chunked and unbroken. Tests:317 separates arbitrary-entry from synthetic evidence and compares the complete machines.

The 42 independent synthetic variants at Examples:691–759 cover current balance/store; local consumed, nextIndex, outputs and failure; event index, step and raw before world; result world and outputs; evaluated guard, deltas, supplies, required/declared state/environment reads and writes; all request fields; receipt constructor; local and event output index/port/value; located failure index/step/reason; and attempt participant/index/invocation/raw before/outcome/success world/output/receipt guard. Each changes the named field while retaining the other stored fields in that pair. This is finite field discrimination, not exhaustive enumeration of every value or nested sum-constructor combination; the generic comparator equality theorem remains separate evidence.

**F4 resolved.** A new independent extraction confirms all 48 literal rows exactly match accepted fixtures.json for complete schedule, participant, own index, operation, before/after main balances, output presence, phase and local counters. `prefixRows` selects a complete schedule's rows before taking its prefix. `expectedF10Prefix` uses only those literal rows and constructor assembly. Tests:397 compares actual and expected full machine with both comparators, phase against the literal row, and consumed/nextIndex against literal counters. Tests:420 emits all 12 × 5 prefix checks, including the explicit empty entry. The 12 final, 12 reserve and 12 final-monitor checks remain. Expected values are not obtained by executing the candidate dispatcher.

F05's shared-principal companion also now has a complete independently constructed expected machine (Examples:529–542; Tests:275), in addition to the parameterized producer's distinct own histories with values 6 and 2. F18/F19 retain direct aliases to actual accepted Interface.Examples operations, receipts, configuration and initial state; the six schedule tests and fixed-edge negative remain in the complete inventory. Their runtime totals and binding checks are not substitutes for generic instantiated proofs.

## Open scope

F03 still runs Nary schedules against literal expectations; it does not yet run actual `Interleaving` and compare through complete executable conversions. The binary lane owns that integration and must provide fresh runtime evidence. The generic initialized interference, exact trace/history, causal provenance, funded reserve and independent completion-success obligations remain proof-lane gates. No source or old evidence was edited by this review; only this report, its check script, and its input manifest were written.
