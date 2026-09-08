# Sprint11 funded-causal-r3

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6` (session system identity: “You are Grok 4.6 released by xAI.”). Checker assigned: `gpt-6-astra` (not executed in this task). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Private build cwd: `/home/charl/.cache/defiformal-sprint11-builds/causal`.
Lean: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`). Lake: `5.0.0-src+d8b1897`.
Actual toolchain binaries: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`.

This round owns only `lean/DefiKernel/Nary/FundedCausal.lean` and this new evidence directory. Independent GPT-6 accepted r2 as a mathematical subset (`ACCEPT WITH LIMITATIONS`); r2 source/evidence bytes are preserved and were not rewritten. The r2 snapshot hash remains `caa1ee638e8289fc90ea66adde4c725c9e9055d75de8188c89bd5fd3f291d563`.

## Owned source

| Module | Path | SHA256 | Bytes |
| --- | --- | --- | --- |
| FundedCausal r2 (before) | `lean/DefiKernel/Nary/FundedCausal.lean` | `caa1ee638e8289fc90ea66adde4c725c9e9055d75de8188c89bd5fd3f291d563` | 57219 |
| FundedCausal r3 (after) | `lean/DefiKernel/Nary/FundedCausal.lean` | `e45b66de644f49a4a3cb831af0b956c6376c3bc5924ece4b32049eed18f4cd9f` | 64739 |

Frozen dependencies, not edited:

| Module | SHA256 |
| --- | --- |
| Causal.lean | `3cd36f6a0f04b4541db5406a90cdb62c3f200f3e55dd83aa05b175179ef01a67` |
| FundedEnabledness.lean | `98eccaec1a755d5758d1b88fcb5e0f18e6a35d327ee990beb1094b22bc90f0b7` |
| FundedCompanions.lean | `5320f958150f01d832333c0833cdab4dd5eee9c4257dd516ad3b303981c59d5c` |
| Nary/Verify.lean | `11a25869542427480778d0e0eff7c011ff01ed745c1ae995ce8032a1b07303ae` |
| DefiKernel.lean | `aa2fdc6bb5fcf225ba947408ae9c95f85d925babd52fd2094dbd13d47abee99f` |

Worktree and private-cache copies of FundedCausal, FundedEnabledness, and Causal are byte-equal after the rsync. Root `Nary.Verify` and `DefiKernel.lean` were not built.

Source scan of the owned file: `sorry=0`, `native_decide=0`, `axiom` declarations `0`, `admit=0`. 98 explicit theorems (94 from r2 plus 4 new). `#print axioms` of the named theorems reports only `propext`, `Classical.choice`, `Quot.sound`.

## GPT-6 r2 open items closed here

1. **Current-K live-selected `executeStep = .ok`.** `f10_live_selected_enabled` takes `FundedK q m`, selected `failure = none`, and the actual current branch lookup. It concludes
   `∃ result, executeStep f10Cfg (f10Bounds b currentIndex) currentIndex ownOutputs (.invoke inv) m.world = .ok result`.
   It does not assume future or whole-run success. Extra helper receipt/output/store/balance facts are kept in `f10_live_selected_enabled_details`.
2. **Donor index-0 empty history** is `f10_reachable_empty_outputs`, by induction on `Reachable` from skip/refuse preservation and selected-accept `nextIndex + 1 ≠ 0`. It is not a new FundedK conjunct.
3. **Initialized prefix corollary** `f10_initialized_prefix_enabled` applies `f10_monitored_initialized (schedule.take n)` then the live-selected bridge.
4. **Stale comments.** `f12_vault_final` and `depositOnlyRely` now say that the generic instance rely is `fundedRely` (post `fundedInv`). `depositOnlyRely` is a separate monotone peer relation used to show the F12 readiness issue; it is not used by the generic funded instance. Companion proofs are not duplicated.

Existing generic obligation proofs, every-prefix reserve, complete 2/1/1 success, and exact store/provenance results are unchanged in statement. `FundedK` was not weakened. Symbolic enabledness was not replaced by finite runtime checks.

## Helper dependency (honest)

`import DefiKernel.Nary.FundedEnabledness` with a qualified `open` of only the four helpers, avoiding the `f10_catalog_valid` name clash. Those helpers were authored by a separate native worker in `funded-enabledness-r2` and were not edited here. They construct `executeStep = .ok` from catalog/prepare/typed execute/extract on an arbitrary pre-world with fixed store and current budget/funding. This module supplies the current index, own history, store, budget and funding from K, `f10_selected_guards`, and Reachable.

Fixed configuration: `f10Cfg`, `f10Bounds`, `f10Branches`, `f10Initial`, `f10Store`. The bridge is not a theorem about arbitrary funded catalogs.

## Builds

Private causal cache only. Sync: `rsync -a --delete --exclude '.lake' --exclude '.git'` from worktree `lean/` to the causal cache, including the final helper. Commands, cwd, UTC, timeout, exit, stdout and stderr are in `logs/`. There were no failing attempts; the first `lake build DefiKernel.Nary.FundedCausal` exited 0 (959 jobs) and `lake env lean` of that file exited 0. `#print axioms` and `#print` probes exited 0.

`lake build all`, the fixture cache, the proof cache, and root `DefiKernel` / `Nary.Verify` were not used.

## Remaining scope (honest)

This is not Sprint11 acceptance, not companion/full-scenario acceptance, and not a result for arbitrary funded configurations or public `runNary` wrappers. Independent GPT-6 review of this package is still required. This report is not self-acceptance.
