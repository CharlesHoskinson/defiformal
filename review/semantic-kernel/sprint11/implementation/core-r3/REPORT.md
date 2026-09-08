# Sprint11 core-r3: schedule length and take-prefix monitor equality

Requested worker: `grok-4.6`. Reported worker: Grok 4.6.
Assigned checker: `gpt-6-astra`. This worker did not run that check.
Baseline HEAD: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Evidence directory: `review/semantic-kernel/sprint11/implementation/core-r3/`.
Prior attempts `core-r1/` and `core-r2-aborted-source/` were not rewritten.

R2 aborted (exit 134) with no compile telemetry. Current Schedule/CausalRuntime already contained the r2 drafts. Those drafts did **not** compile: `sum_count_cons` left unsolved Nat goals because `simp [List.count_cons]` rewrote counts inside the inductive tail. This round rewrote that induction and then compiled.

## Fixes

**Schedule (task 2.2).** Restored generic theorems, no participant-type split, no `Fintype B`:

- `count_sum_length`: `(roster.order.map schedule.count).sum = schedule.length`
- `Complete.length`: complete schedule length equals the sum of branch lengths over the roster

Proof uses `List.nodup_cons`, `List.count_cons` on the outer cons only, explicit `roster.complete`, and induction on the roster/schedule lists. `Multiset.sum_count_eq_card` was verified locally in mathlib (`Finset/Basic.lean:1088`) as an alternative; it was not required once the induction closed.

**CausalRuntime.** Kept `continueMonitored_common_prefix` as the two-append helper. Added:

- `continueMonitored_take_eq`: `(preTokens ++ suffix).take preTokens.length` elaborates to `preTokens` by `List.take_append`
- `continueMonitored_take_prefix`: monitored states after `preTokens.length` tokens of `preTokens ++ suffix₁` and `preTokens ++ suffix₂` are equal, for fixed cfg/boundaries/branches/update/entry

The equality does not claim that `update` has no captured constants. Full replay/inductive-trace remains a later Causal deliverable.

Executable admission/control flow was not changed. The M11 two-space `let` needle is unchanged.

## Builds (cwd `lean/`)

| Command | Exit |
|---|---|
| `lake build DefiKernel.Nary.Schedule` | 0 |
| `lake build DefiKernel.Nary.Execution` | 0 |
| `lake build DefiKernel.Nary.Observation` | 0 |
| `lake build DefiKernel.Nary.CausalRuntime` | 0 |
| `lake env lean` on each of the four files | 0 |

Sorry-analyzer: 0 on each owned file. All 16 planned needles unique in the runtime prefix, including M11; no changed anchors; sealed planning JSON not edited.

## Outstanding

Independent GPT-6 check of this follow-up is not done. Fixtures, binary correspondence, interference, funded causal witness, mutation production runs, and root integration remain outside this foundation follow-up. `implementation_accepted` remains false.
