# Sprint11 funded-causal-r2

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6` (session system identity: “You are Grok 4.6 released by xAI.”). Checker assigned: `gpt-6-astra` (not executed in this task). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Private build cwd: `/home/charl/.cache/defiformal-sprint11-builds/causal`.
Lean: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`). Lake: `5.0.0-src+d8b1897`.

r1 was root-interrupted (SIGINT exit 2). This r2 directory is new evidence. causal-generic-r1 was not modified.

## Owned source

| Module | Path | SHA256 |
| --- | --- | --- |
| FundedCausal | `lean/DefiKernel/Nary/FundedCausal.lean` | `caa1ee638e8289fc90ea66adde4c725c9e9055d75de8188c89bd5fd3f291d563` |

Frozen Causal.lean remains `3cd36f6a0f04b4541db5406a90cdb62c3f200f3e55dd83aa05b175179ef01a67`. Worktree and private-cache copies of both files are byte-equal.

Source scan of the owned file found no `sorry`, `native_decide`, `axiom`, or `admit` token (`source-scan.txt`). `#print axioms` on the named theorems reports only `propext`, `Classical.choice`, `Quot.sound`.

## GPT-6 structural fixes applied

- `fundedBalances` donor2 is `3 - 2 * n2`. inv203 transfers 2 and increments nextIndex once; after p2 success donor2 = 1.
- `fundedAssumption` gates p1 `1 ≤ donor1` and p2 `2 ≤ donor2` on `nextIndex = 0`. AssumptionDerivation is `∀ b` whenever `K` holds, so an exhausted stream must not require another transfer. The old `donor2 = 3 - n2` arithmetic had masked that.

## Generic instance

`f10_monitored_initialized` instantiates `continueMonitored_start_initialized` with independently discharged:

| Obligation | Theorem |
| --- | --- |
| initialized | `f10_start_K` |
| InvariantDerivation | `f10_inv_derivation` |
| AssumptionDerivation | `f10_assumption_derivation` |
| PresentExternal | `f10_present_external` (`True`) |
| SelectedSuccessGuarantee | `f10_selected_success` |
| GuaranteeInclusion | `f10_cross` |
| RelyStable | `f10_stable` |
| SkipUpdate | `f10_skip_update` |
| RefusalUpdate | `f10_refusal_update` |
| SuccessUpdate | `f10_success_update` |

`FundedK` is the counted invariant: Reachable, store `f10Store`, nextIndex bounds 2/1/1, exact balances from successful positions, phase = `phaseOf n0`, own-output history `[]` or `[budgetOut 0]`. Failure is not a `K` conjunct, so refusal/skip keep `K`.

`fundedGuarantee` includes post-state `fundedInv`. Peer rely is post-invariant. Deposit-only vault-nondecreasing is **not** the instance rely; F12 falsifies it.

## Safety

`f10_every_prefix_reserve`: for every schedule and every `n`, vault ≥ 4 after `continueMonitored` of `schedule.take n`. This is the initialized every-prefix reserve, from `K` plus `fundedInv`.

Also named: budget = 6, store = `f10Store`, own-output provenance.

## Progress (separate from K)

Soundness does not imply progress. `f10_selected_guards` states the live-token financial guards from current `K` (producer identity at index 0 with empty history; consumer at index 1 with `[budgetOut 0]` and `6 ≤ vault`; p1/p2 funding only at `nextIndex = 0`). It does **not** claim a generic `executeStep = .ok` on arbitrary symbolic worlds (catalog/authority/accounting sit outside those guards).

`f10_complete_success`: every schedule with counts 2,1,1 is one of the twelve permutations (`f10_complete_mem`). Each is identified with the independent `expectedF10` machine via `machineEq_iff` and kernel-reduced `decide +kernel`. Finals: vault 7, donor1 1, donor2 1, recipient 6, budget 6, nextIndex 2/1/1, failures `none`. The twelve Boolean runtime checks are not a substitute for the generic `K` instance.

## Companions

- F12: `runPrefix` vault = 1 after producer, authorized withdrawal 3, consume 6. `depositOnlyRely` is false (10 ≰ 7). No artificial reserve guard.
- F16: catalog valid, producer invoke authority holds, false-guard producer leaves monitor `.awaiting` and p0 outputs `[]`.
- F17: successful peer lookalike leaves p0 monitor `.awaiting`, outputs `[]`, nextIndex 0.

## Builds

Private cache only. Sync: `rsync -a --delete --exclude '.lake' --exclude '.git'` from worktree `lean/` to the causal cache. Commands and exits are in `compile-status.json` and `logs/`. Failed attempts 01–04 and 06–12 are preserved. Final `lake build DefiKernel.Nary.FundedCausal` and `lake env lean` of that file both exit 0 (log 13).

## Remaining scope (honest)

No theorem `executeStep = .ok` for an arbitrary `FundedK` world and live selected invocation, proved by unfolding `Typed.execute`/`applyEvaluated` on symbolic state. Guards are proved; complete 2/1/1 success is the exhaustive expected-machine identification. That is a remaining premise for a fully symbolic progress lemma, not a hole in the generic `K` instance or the every-prefix reserve.
