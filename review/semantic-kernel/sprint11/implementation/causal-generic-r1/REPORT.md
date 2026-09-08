# Sprint11 causal-generic-r1

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6` (session system identity: “You are Grok 4.6 released by xAI.”). No `grok-4.6-build` runtime telemetry was visible in this process. Checker assigned: `gpt-6-astra` (not executed in this task). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Private build cwd: `/home/charl/.cache/defiformal-sprint11-builds/causal`.
Lean: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`). Lake: `5.0.0-src+d8b1897`.

## Owned source

New proof-only module:

| Module | Path | SHA256 |
| --- | --- | --- |
| Causal | `lean/DefiKernel/Nary/Causal.lean` | `3cd36f6a0f04b4541db5406a90cdb62c3f200f3e55dd83aa05b175179ef01a67` |

One `-- BEGIN PROOFS` marker. Source scan of the owned file found no `sorry`, `native_decide`, or `axiom` token (`source-scan.txt`). That scan is not a Lean axiom audit.

Core/runtime/other proofs/fixtures/root config were not edited. Private cache sources were not copied back over other owners.

Import is `DefiKernel.Nary.CausalRuntime` only. Arbitrary participant `B` has `DecidableEq B` and no `Fintype B`. Monitor state `Q` is an arbitrary `Type`. `Fintype P/A/D` is inherited from `executeStep`.

## What the layer proves

### Replay / inductive-trace correspondence

`Replay` constructors require an actual `AdvanceSound` base transition and the exact appended attempt:

- skip: `none`
- refuse: `some` error attempt at the current world
- accept: `some` successful attempt with the actual result

Theorems:

- `continueMonitored_replay`: the executable fold is a `Replay`
- `Replay.eq_continueMonitored`: any such trace equals `continueMonitored`
- `Replay.erase`: the machine component equals `continueRun`

### Appended-attempt provenance

`AdvanceSound.appended_option` classifies skip (`none`, attempts unchanged), refusal (actual `executeStep = .error`), and success (actual `executeStep = .ok`). Helpers `advanceMonitored_skip` / `_refuse` / `_accept` match those payloads to the monitor input.

### Erasure and fixed-parameter shared prefix

Reuses core `continueMonitored_erase`, `continueMonitored_take_eq`, and `continueMonitored_take_prefix`.

- `continueMonitored_erase_start`: monitored start erases to `runPrefix`
- `continueMonitored_fixed_parameter_shared_prefix`: after `preTokens.length` tokens of `preTokens ++ suffixᵢ`, both suffixes equal the continuation of `preTokens` alone, for fixed cfg/boundaries/branches/update/entry

The shared-prefix equality does not claim that `update` has no captured constants, and does not cover a changed callback or an externally prescient initial monitor.

### Generic initialized finite-prefix rule

Main theorem: `continueMonitored_initialized`.

Named premises, separately:

| Premise | Meaning |
| --- | --- |
| `initialized` | `K` at the supplied entry pair |
| `InvariantDerivation` | current `K` implies every participant ledger invariant |
| `AssumptionDerivation` | current `K` plus a named present external premise yields the selected assumption |
| `PresentExternal` | that external premise is present whenever `K` holds (instance may use `True`) |
| `SelectedSuccessGuarantee` | own invariant and guarantee from current invariant, assumption, and actual `executeStep = .ok` |
| `GuaranteeInclusion` | selected guarantee is included in each peer rely |
| `RelyStable` | peer invariants are stable under rely |
| `SkipUpdateObligation` | skip/halted/exhausted preserves `K` under the actual `none` monitor update |
| `RefusalUpdateObligation` | refusal preserves `K` under the actual error-attempt update; world identity, no invented success |
| `SuccessUpdateObligation` | after actual success, the monitor update reestablishes `K` from assumption, guarantee, and post-invariants |

Conclusion: `K` at the monitored pair after the schedule, and every participant invariant at that world.

`continueMonitored_every_prefix` instantiates that rule on `schedule.take length`. `continueMonitored_start_initialized` is the genesis-entry specialization.

`derived_monitor_step_preserves` is a one-step `K` corollary. It is not the causal result; the named obligations are.

The rule does not assume future success, a whole-run conclusion, or enabledness/progress. An arbitrary `update` need not satisfy the obligations. A funded witness is expected to discharge each premise independently.

## Builds (private cache only)

Worktree lean sources/config excluding `.lake` were synced into the private cache before compile. Post-sync and final source-hash files matched (`hashes/worktree-lean-sources.final.sha256` equals `hashes/private-lean-sources.final.sha256`). Repository-cache `lake` was not run.

| Command | Exit |
| --- | --- |
| pre-edit `lake build DefiKernel.Nary.CausalRuntime` (933 jobs) | 0 |
| `lake build DefiKernel.Nary.Causal` attempts 01–04 | 1, 1, 1, 1 |
| `lake build DefiKernel.Nary.Causal` attempt 05 (934 jobs) | 0 |
| `lake env lean DefiKernel/Nary/Causal.lean` | 0 |
| `lake env lean --stdin` `#check` / `#print axioms` of named theorems | 0 |

Failed attempts are kept under `logs/01`–`logs/04`.

Focused `#print axioms` on the named correspondence and initialized-rule theorems printed only `propext`, `Classical.choice`, and `Quot.sound`. No `sorryAx`, custom axiom, or `native_decide` dependency appeared in that checked set. That is not the required full imported-declaration inventory.

## Limits / remaining work

- No concrete funded F10 proof, Ready-budget arithmetic, or twelve-schedule success theorem. A separate FundedCausal module is supposed to follow actual fixture compile.
- No enabledness/progress theorem.
- Captured callback constants and externally supplied initial monitor facts are outside the shared-prefix contract.
- Independent GPT-6 check of this layer is assigned and was not executed here.
- Full imported explicit/generated/private/supplemental axiom inventory of the module is not done.
- Binary correspondence, InterfaceInstances, runtime fixtures, production mutants, and root integration remain other lanes.

`implementation_accepted` remains false.
