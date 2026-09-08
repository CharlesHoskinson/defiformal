# Independent GPT-6 mathematical review: FundedCausal r2

Verdict: **ACCEPT WITH LIMITATIONS for the frozen initialized F10 instance, every-prefix reserve, and actual success of every complete count-2/1/1 schedule.** No mathematical blocker was found in these claims. The separate arbitrary-current-world enabledness helper integration remains open. This is not full Sprint11 acceptance, acceptance of all companion scenarios, or acceptance of future source edits.

Reviewed source: `lean/DefiKernel/Nary/FundedCausal.lean`, 57,219 bytes, SHA-256 `caa1ee638e8289fc90ea66adde4c725c9e9055d75de8188c89bd5fd3f291d563`. Frozen generic Causal dependency remains `3cd36f6a0f04b4541db5406a90cdb62c3f200f3e55dd83aa05b175179ef01a67`. Both source snapshots are retained beside the review logs. The root archive's owned source has the same hash.

Reviewer: independent GPT-6, assigned gpt-6-astra, stock Codex task `/root/causal_check`. Native author provenance was checked directly: the last end event in the compressed funded-causal-r2 native stream is line 4620, session `01a07f17-ae3c-7b62-9b32-de4f9e9dca35`, with `modelUsage` object key `grok-4.6-build`. Usage values and signatures are omitted. The root archive records native exit 0. The review does not rely solely on the author's self-description.

## Premise and induction audit

`FundedK` contains actual past reachability, the fixed capability store, successful-index bounds 2/1/1, exact tracked balances, phase determined by p0's successful index, and p0's own accumulated output history. Reachable is constructed from initialization and actual past AdvanceSound transitions; it is not a premise about future executions. No conjunct assumes a future successful call or the desired whole-run reserve. The initialized theorem quantifies every finite schedule, including partial and overlong schedules, with no completeness or no-failure hypothesis.

For successful indices n0/n1/n2, the ledger relation is:

| Cell | Counted value |
| --- | --- |
| vault | `10 - 6*consumedFlag n0 + n1 + 2*n2` |
| donor1 | `2 - n1` |
| donor2 | `3 - 2*n2` |
| recipient | `6*consumedFlag n0` |
| budget | `6` |
| sentinel | `11` |

Here consumedFlag is one exactly at n0=2. The corrected donor2 equation matches inv203's two-unit transfer. Since n1/n2 are at most one, donors remain nonnegative and the vault remains at least four. At p0 index one, consumedFlag is zero, so vault is at least ten and `6 ≤ vault - 4` follows without assuming the eventual final state.

Assumption derivation is quantified over every participant whenever K holds. Donor funding is correctly conditional on its own index being zero: exhausted donor2 can have balance one without violating the assumption family. The current order fact comes from Reachable.active_index when that participant has no recorded failure. At p0 index one, the assumption contains the actual Ready6 phase, own singleton `[budgetOut 0]`, and the present reserve-compatible spending bound. At other p0 indices that consumption condition is inactive. `fundedExternal` is True; there is no hidden external future-success requirement.

`f10_selected_success` has the actual generic obligation signature: selected participant and invocation, no current local failure, actual `executeStep = .ok result`, selected participant's current invariant, and current assumption imply that participant's post-invariant and transition guarantee. It does **not** take K, every peer's invariant, a post-K assertion, or future success as an input. Although all three invariant functions happen to denote the same funded ledger property, only the named current invariant is supplied. The four selected cases are derived from the actual branch lookup/order fact, rather than assumed as a schedule oracle.

The guarantee includes the post funded invariant and explicit cell effects. The actual rely is the post funded invariant. Cross-inclusion and rely stability are projections, but the substantive premise is independently proved by `f10_selected_success`: producer identity effects frame the ledger; consumer effects are -6/+6 and the current assumption leaves at least four; donor effects are -1/+1 or -2/+2 and conditional funding leaves nonnegative donor balances. This is logically noncircular. It must not be described as a deposit-only transition rely.

Initialization, invariant derivation, assumption derivation, present external premise, selected actual-success guarantee, guarantee inclusion, stability, skip, refusal, and success-update obligations are all supplied separately to the accepted `continueMonitored_start_initialized`. `f10_every_prefix_reserve` applies that theorem to `schedule.take n`; it does not use the twelve complete-schedule computations.

## Actual effects, history, and monitor updates

Receipt facts follow from `executeStep_sound`, concrete preparation/evaluation facts, and successful accounting application. They are facts about the actual successful result, not arbitrary receipt-shaped inputs.

- Producer receipt is exactly rec200 and has zero effect at every cell. Producer exports are exactly the qualified index-zero budget output, obtained from the actual post-state snapshot and the current framed budget value six.
- Consumer preparation uses index one and p0's own singleton output history. Its actual evaluated deltas debit vault six and credit recipient six. The full receipt equality to rec201 uses the successful application guard fact, retaining the request and evaluated metadata rather than proving only a balance approximation. It emits no additional outputs.
- Donor calls derive their actual two-cell effects from evaluation of their fixed transfer templates. The general cell equations also frame every other cell. Invoke capability-store preservation is separately obtained from the actual StepSound invocation case.

Success-update reconstructs K using these facts and the actual accepted transition. Producer success increments p0 from zero to one, preserves balances, appends its sole output, and moves Awaiting to Ready6 using exact receipt/output identity. Consumer success increments one to two, applies -6/+6, preserves its singleton history, and moves Ready6 to Consumed using the exact consumer receipt. Peer success updates only its own successful index/balances, preserves p0's history, and cannot trigger the p0 monitor predicates. The post-invariant/guarantee parameters allowed by the generic success-update interface are not used as a substitute for this reconstruction.

Refusal carries the actual error attempt. It preserves world, successful indices, outputs, and phase, while extending actual reachability. Skip covers both failed and exhausted tokens, supplies no attempt, and preserves the same K fields. K deliberately does not require every local failure field to be none, so these proof obligations are meaningful and compatible with the generic failure semantics.

## Complete-schedule success is a theorem

`fin3_count_sum` proves the three participant counts sum to schedule length. With counts 2/1/1, `f10_complete_length` gives length four. `f10_complete_mem` destructs that finite list and exhausts the Fin3 values, proving that **every** such schedule belongs to the twelve literal schedules. This is an exhaustive kernel-checked coverage proof, not an assumption that the examples are complete.

For every member, `f10_member_machineEq` proves the actual runPrefix machine equals the independent expected machine via the Boolean comparator and its proved `machineEq_iff` equivalence. The expectation is constructed from literal per-schedule rows and a separate expected-event/attempt constructor; it does not call runPrefix, runNary, continueRun, or the candidate dispatcher to generate its oracle. Full machine equality covers the complete world/store, all local fields, raw event worlds, and complete attempts. Different schedules retain different diagnostic orderings.

`f10_complete_success` composes coverage, exact expected-machine identification, expected final values, and monitored erasure. Its only schedule premises are the three counts. It concludes vault7, donor1=1, donor2=1, recipient6, budget6, successful indices2/1/1, and failures none for all three participants. Kernel reduction with `decide +kernel` is a legitimate proof method for these finite cases; there is no native-decide trust axiom in the audited dependencies. The result neither assumes successful execution nor infers it from StepSound. The generic K proof remains separate and is not replaced by this finite proof.

The theorem is specific to the fixed F10 configuration, bounds, initial world, and branches. It is not a result for arbitrary funded configurations, arbitrary stream lengths, arbitrary initial K worlds, liveness, or general economic solvency. It is stated over monitored execution/runPrefix; public runNary admission wrappers remain an integration matter.

## Open scope and source wording

1. **Arbitrary K-world enabledness integration remains open.** `f10_selected_guards` supplies the actual selected case, own producer/consumer history, and current financial guards. It does not prove `∃ result, executeStep ... = .ok result` for an arbitrary supplied K world. The author reports this accurately. Root has assigned four current-world success lemmas to FundedEnabledness. Once independently reviewed, combine those with the current store/history/selected-case facts in a separately named helper if that stronger progress interface is claimed. This open helper does not invalidate the complete-schedule theorem already proved here.
2. **Two source comments remain inaccurate.** At lines 1202–1216, the F12/depositOnlyRely comments call depositOnlyRely the rely “used by” or “of” the funded instance. The definition at line87 is instead post fundedInv, and the author REPORT correctly says so. Correct those comments in an attributed native followup. This is a documentation finding, not a false-theorem finding. The opening comment about twelve Boolean checks should be read as referring to the generic instantiated proof; the separate complete-success theorem explicitly uses kernel finite-case proofs.
3. **Companion and full-scenario acceptance stays separate.** Actual deposit preservation of the Ready bound and detailed F12/F16/F17 behavior are being reviewed in FundedCompanions. The weaker overlapping tail theorems here do not replace those obligations. This review verifies the actual pointwise receipt effects and full expected-machine identity; it does not claim a separately exported full-ledger-total theorem, final mutation acceptance, official inventory acceptance, or delivery completion.

## Independent verification and evidence limits

With root's explicit cache release, the reviewer ran two read-only `lake env lean --stdin` probes in `/home/charl/.cache/defiformal-sprint11-builds/causal`. Both exited 0. The first independently enumerated imported theorem constants whose actual module is FundedCausal, retaining complete types, outer-expanded obligation types, and transitive axioms. It found 206 theorem constants, including all 94 explicit source theorems; no explicit theorem was missing. No retained statement contains ellipsis. The axiom union is only `propext`, `Classical.choice`, `Quot.sound`. The second used literal `#print axioms` on fourteen principal facts and confirmed the same allowed scope. Generated constants are distinguished from the 94 explicit claims; 206 is not a count of independent mathematical claims.

All 35 traced local imported source files matched the worktree/private-cache copies before inspection. Their source and retained compiled-artifact hashes were unchanged afterward. Configuration pins and observed compiler tool hashes are retained. This is read-only introspection of the author's compiled modules, not a reviewer rebuild of the full dependency closure. External Lean/Mathlib packages remain pinned-environment trust. The author retains failed build attempts separately; no reviewer probe failed in this review. The full untruncated outputs and probe bytes remain in `funded-causal-r2-logs/`.

All 62 entries of the author's final-artifact manifest match their bytes. Native source/archive and report hashes, specifications, generic dependency, worktree/private bindings, complete statements, commands/exits, and reviewer report are bound in the companion input manifest. No feature source or build cache was modified. The causal cache was released back to root after the probes.
