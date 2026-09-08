# Fixtures-r2 report

Worker requested `grok-4.6`. Worker reported `grok-4.6`. GPT-6 findings from `gpt6-review/fixture-preliminary.md` were applied. r1 hashes and logs were left in `fixtures-r1/`. No Foreman, no commit, no mutation runner.

Private compile cwd: `/home/charl/.cache/defiformal-sprint11-builds/fixture`. Repository `.lake` was not used. Worktree and private hashes matched.

## Review fixes

1. **M14 `nary.monitor.success_input`.** The check now uses `observeReserve`, which records `MonitorInput.attempt`. It requires phase `Ready6` and a delivered `some` producer attempt equal to the independent `expectedProducerAttempt`. It does not read the base machine attempt list.
2. **Extra skip.** `nary.f10.extra-skip-consumed` still uses `prefix3`. `nary.f10.overschedule.refused` confirms `runNary` refuses `[0,0,1,2,0]` with schedule mismatch expected 2 observed 3. Both true at runtime.
3. **Synthetic negatives.** Each one-field pair is two IDs: `nary.f09.candidate.*` (`!machineEq`) and `nary.f09.independent.*` (`!fullMachineEq`). Equal-pair positives exist for both comparators.
4. **F09.** Populated entry has nonempty prior outputs, nextIndex/consumed 2, failed p1 consumed 3, nonempty store. Continuation `[0] ++ [2]` consumes producer history then a peer deposit. Monitor entry starts at 7 and ends at 9. Classification splits `arbitraryEntry` vs `syntheticObservation`. One-field diffs cover world, store, local consumed/nextIndex/outputs/failure, event index/step/before, result world/outputs, evaluated guard/deltas/supplies/reads/env/writes, request fields, receipt constructor, local and event output step/port/value, failure index/step/reason, and attempt participant/index/invocation/before/outcome/ok-world/ok-outputs/ok-guard.
5. **F10 prefixes.** All 12 schedules × prefix lengths 0–4 (60 checks) compare actual machine, monitor phase, and `localsNC` to the first N literal rows. Final Consumed and reserve checks remain.

F18/F19 aliases were preserved. F05 shared-principal now has a full expected machine.

## Runtime evidence (bounded, not a proof)

```
cd /home/charl/.cache/defiformal-sprint11-builds/fixture
lake build DefiKernel.Nary.Examples DefiKernel.Nary.Tests DefiKernel.Nary.Audit   # exit 0
lake env lean DefiKernel/Nary/Audit.lean                                         # exit 0
```

`#eval main`: **288 true, 0 false**, 288 unique IDs. All 16 mutation false labels and protected positives are true.

Preserved failure: first Audit run after compile was **285 true / 3 false** (`eval-Audit.attempt1.stdout`). F07 `runNary` refused because p0 branch length 2 ≠ schedule count 3. The third p0 token is a post-failure skip, so the branch is now `[inv10, inv13, inv13]`. Checks were not deleted.

## Not claimed

These 288 results are bounded executable comparisons. They are not kernel proofs of initialized interference, causal obligations, or binary correspondence. Mutation SPECs were not run. Root integrated `lake build` was not run.
