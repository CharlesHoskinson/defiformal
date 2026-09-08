# Fixtures-r1 draft report

Worker requested `grok-4.6`. Worker reported `grok-4.6` (this Grok Build session). Independent GPT-6 was assigned and was not executed by this worker. No Foreman. No commit, push, archive, or self-acceptance.

## What was drafted

New runtime-only sources:

- `lean/DefiKernel/Nary/Examples.lean` — independent worlds, catalogs, receipts, machines, F10 prefix table, F18/F19 Interface.Examples bindings
- `lean/DefiKernel/Nary/Tests.lean` — unique nonempty `runtimeComparisons`
- `lean/DefiKernel/Nary/Audit.lean` — production `#eval` of `runtimeComparisons`; throws on empty, duplicate, or false

Owned evidence is only under `review/semantic-kernel/sprint11/implementation/fixtures-r1/`. Core modules, root imports, lake config, and sealed planning files were not edited.

## Coverage

All 19 fixture IDs are present with an explicit evidence class.

| ID | Class | Independent expectation in the draft |
|---|---|---|
| F01 | admission/refusal | configuration first; p1 index1 `interface.unknownOperation`; final p2 expected 1 observed 0 |
| F02 | funded execution | literal 10−1=9, 9+1=10, 10+2=12; store/locals/index/guard/no-failure labels |
| F03 | binary instance | BranchId LR vault 3 / RL vault 4; both-count four Nats 1,0,1,0 |
| F04 | typed roster | `Roster.empty` / `Roster.singleton`; valid empty; singleton vault 9; missing token |
| F05 | funded execution | one parameterized producer op 18; outputs 6 then 2; final vault 2 |
| F06 | actual refusal | index1 `kernel.unauthorizedInvoke`; peer index0 success |
| F07 | funded execution | four attempts, one error, p0 consumed 3, final vault 12 |
| F08 | arbitrary prefix | consumed 2, attempts 1, monitor count stays 1 |
| F09 | synthetic observation | continuation plus eight one-field comparator diffs |
| F10 | generic instance | 12 schedules, 48 prefix rows, Ready6/Consumed |
| F11 | funded negative | transfer 7 leaves vault 3 |
| F12 | funded negative | producer, peer 3, consumer 6 leaves vault 1 |
| F13 | funded negative | peer transfer 7 vault→donor1 leaves 3 |
| F14 | funded negative | identity from vault 3 stays 3 |
| F15 | logical only | False→False both ways; facts do not hold |
| F16 | actual refusal | false-guard producer, skip, peer +1, monitor Awaiting |
| F17 | provenance negative | peer producer output 6, monitor stays Awaiting |
| F18 | M2 instance | `op102`/`receipt102`, six schedules, total 10, global edge |
| F19 | M2 negative | `op103`/`receipt103`, `.unequal 0 (name 0) (name 1) 4 5` |

Mutation false labels M01–M16 are all present as exact check IDs. Protected positives `nary.empty.exact`, `nary.no_failure.exact`, `nary.routing.locals`, and `nary.monitor.actual_producer` are present.

F10 Lean rows match `fixtures.json` 48/48. F02 values are written as arithmetic, not as a Nary replay. F05 uses one producer interface. F18/F19 use accepted `Interface.Examples` names and the real `BindingFailure.unequal` constructor. Runtime imports are `Interface.Regions`/`Bindings`/`Examples` plus Nary Schedule/Execution/Observation/CausalRuntime. No `Interface.Tests`/`Fixtures`/`Accounting`/`Preservation` and no Nary proof modules. No `sorry`, `axiom`, or `native_decide`. Shared executable definitions sit before `-- BEGIN PROOFS`.

## Local validation that actually ran

Python compared the F10 table, counted unique check names (103 static, plus 36 F10 and 6 F18 interpolated names), and scanned imports and forbidden keywords. That is structural only.

Repository `lake build` / `lake env lean` was **not** run for these three modules. The task forbade using the repository cache while the core author owns it. These drafts are **pending elaboration**. No passing `#eval` result is claimed.

## Remaining work

- Follow-up compile of `DefiKernel.Nary.Examples`, `Tests`, and `Audit` once the foundation cache is free.
- Adjust literal `Evaluated` read/write lists if `executeStep` order differs.
- Independent GPT-6 check of this draft.
- Mutation SPECs and root integration are other lanes.
