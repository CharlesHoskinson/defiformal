# Sprint11 funded-companions-r1

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6`. Checker assigned: independent GPT-6 (not executed here). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Build cwd: `/home/charl/defiformal-wt-sprint11-grok-gpt6-20260907/lean` (worktree `.lake`; root-released isolated cache).
Lean: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`).
Lake: `5.0.0-src+d8b1897`.

Owned file: `lean/DefiKernel/Nary/FundedCompanions.lean`  
SHA-256 `5320f958150f01d832333c0833cdab4dd5eee9c4257dd516ad3b303981c59d5c` (49329 bytes).  
Namespace: `DefiKernel.Nary.FundedCompanions`. Does not import `FundedCausal`. Does not edit Examples/Tests/runtime/plans. InterfaceInstances r2 remains `e1c37f5c1ab0339f85daba12d3fba4c000ae11cc84a8882d8c34566e1ee267aa`.

## Compile

| Command | Exit |
| --- | --- |
| `lake build DefiKernel.Nary.FundedCompanions` 00 | **1** (preserved) |
| same 01 | **1** (preserved) |
| same 02 | **0**, 958 jobs, Built 4.7s |
| same 03 (final source) | **0**, 958 jobs, Built 7.3s |
| `lake env lean DefiKernel/Nary/FundedCompanions.lean` | **0**, empty stdout/stderr |

`lake build all` was not run. Private fixture/proof/causal caches were not used as lake cwd. Other workers rsynced worktree sources into those caches independently; this task did not lake-build there.

Source scan of the owned file: no `sorry`, `native_decide`, or `axiom`. 120 theorems, 16 defs. Not an imported axiom inventory.

## F12 stale authorized withdrawal

Schedule `[0,1,0]` is complete (counts 2/1/0). `admit` is `.isOk`; `runNary` is `.executed f12Schedule f12Expected`.

Actual `executeStep` successes:

- producer `inv200` at vault 10 → `rec200`, `[budgetOut 0]`, world `f12AfterProd`
- peer `inv16` at `f12AfterProd` → `rec16s`, world `f12AfterPeer` (vault 7)
- consumer `inv201` at index 1 with history `[budgetOut 0]` → `rec201`, world `f12AfterCons`

Final fields from the independent expected machine: vault 1, budget 6, recipient 6, donor1 3, store `f12Store`, p0 outputs `[budgetOut 0]`, nextIndex 2/1.

Named invariant failure: `readyBudgetBound` (`6 ≤ vault - 4`). After producer, vault 10 gives `6 ≤ 6`. After the authorized withdrawal 3, vault 7 gives `¬(6 ≤ 3)`. Ordinary `vaultReserve4` still holds at vault 7 (`4 ≤ 7`).

Named premise failure: `depositOnlyRely` of the actual 10→7 step, and `Stable readyInv` of **any** rely that covers that step (`f12_not_stable_if_rely_covers`). Also `¬ CrossInclusion f12WithdrawalGuarantee depositOnlyRely`.

`Stable readyInv depositOnlyRely` remains true. This is not a claim that the safe deposit-only rely is itself unstable.

Remaining premises retained: catalog validity, `prepareInvocation`/`checkAccess` for all three calls, ordinary consumer guard (`nonnegative ∧ amount ≤ vault`, no reserve conjunct), consumer funds `6 ≤ 7`, producer output provenance still current.

Receipt delta of the peer step: vault −3, budget cell unchanged.

## F16 refused producer

Schedule `[0,0,1]` is complete. `admit` is `.isOk`; `runNary` is `.executed f16Schedule f16Expected`.

Catalog is valid. `hasAuthority` for cap 0 / op 210 / vault principal is true. `prepareInvocation` succeeds. `falseProducer.guard = .lit false`. Actual `executeStep` is `.error (.kernel .guard)`, so there is no successful budget output or Ready fact.

Dispatcher: refuse producer, skip the consumer token (no extra attempt), accept peer deposit 1. p0 outputs `[]`, events `[]`, consumed 2, nextIndex 0, failure `f16Fail`, attempts length 2, vault 11, store `f16Store`.

`continueMonitored` erases to `runPrefix` (`continueMonitored_erase`). The first monitor input is the actual refused producer attempt from the dispatcher, not a synthetic `MonitorInput`. `isReadyProducer` of that error is false, so phase stays `.awaiting`. Final `continueMonitored` phase is `.awaiting`.

## F17 peer lookalike

Accepted fixture schedule is `[1]`, not a complete 2/1/0 token list. `admit` is `.error (.schedule ⟨0, 2, 0⟩)`; `runNary` is refused. The lookalike is the actual `runPrefix` / `continueMonitored`.

p1 successfully executes the same zero-effect producer: same output key `name 0 7`, same step 0, same value 6, same `rec200`. p0 remains silent (`outputs = []`, `nextIndex = 0`). World/store stay `f10Initial`/`f10Store`.

`isReadyProducer` of the peer attempt is false because participant is 1, not 0. The same key/index/value with participant 0 would be Ready (`f17_own_producer_is_ready`). No impersonation premise: the peer call is a real success under vault authority. Monitor consumes that actual attempt and stays `.awaiting`.

## F10 standalone deposit Ready-bound witness

Independent of `FundedCausal`'s generic whole-run K. Conditional on actual `executeStep = .ok`, not future enabledness.

`inv202` deltas: donor1 −1, vault +1. `inv203`: donor2 −2, vault +2. Budget cell unchanged in both. Any successful such step preserves `readyBudgetBound`.

Concrete successes at the actual post-producer world (`runPrefix [0]`, still vault 10, budget 6, p0 outputs `[budgetOut 0]`):

- deposit1 → vault 11, bound holds, budget 6
- deposit2 → vault 12, bound holds, budget 6

This is a peer-stability witness for GPT-6 to use alongside FundedCausal's own K update. It does not replace or weaken that generic proof.

## Frozen / other-worker files

| File | Role | SHA-256 |
| --- | --- | --- |
| InterfaceInstances.lean | frozen r2 | `e1c37f5c…` unchanged |
| Examples.lean / Tests.lean | not edited | `1f844aad…` / `d029f586…` |
| FundedCausal.lean | other worker | `a0e49fae…` → `caa1ee63…` during this pass |
| FundedEnabledness.lean | other worker, appeared | `3e84627e…` |

## Remaining outside this lane

Independent GPT-6 review of this package. FundedCausal generic whole-run K, enabledness, all twelve F10 complete schedules, imported axiom inventory, `lake build all`, 16 production mutants, Sprint11 acceptance. F17 is intentionally a prefix companion, not a complete-schedule `runNary` success.

This report is not self-acceptance.
