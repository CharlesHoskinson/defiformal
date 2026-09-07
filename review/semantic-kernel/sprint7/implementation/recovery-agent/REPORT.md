# Generic disjoint recovery implementation handoff

The universal disjoint recovery proof is implemented and passes a targeted Lean
build. It covers every complete schedule admitted by the existing Parallel
checker, including exact runtime refusals and retained prefixes. No all-success,
desired-equality, or arbitrary shared-state commutation premise was added.

Owned sources are `Interleaving/Recovery.lean`, its three new helper modules
`Recovery/Reference.lean`, `Recovery/Step.lean`, `Recovery/Simulation.lean`, and
`Interleaving/LocalOrder.lean`, which the parent expressly requested during this
subtask. No historical source, root import, tasks, or unrelated implementation
was edited. No commit was made. Implementation used the stock GPT-6 harness and
Lean4 LSP workflow; no Foreman was used. This is an implementation handoff, not an
independent implementation review or native-provider approval.

## Proof structure and API

`Reachable.active_index h b active` proves that an active branch's successful
index is `min consumed branch.length`. `Reachable.attempt_index h b active inv
selected` then proves successful index equals consumed slots at every actual
invocation. The minimum is necessary because internal execution permits excess
tokens: those consume slots after exhaustion while leaving the successful index
unchanged. The proof is a direct induction over actual reachability, independent
of recovery; the parent can import `LocalOrder.lean` for interference and analyzed
footprint preservation.

`Recovery.isolated` is the existing sequential runner applied to `branch.take n`.
The reference lemmas prove its next-invocation recurrence and exhausted-token
identity. `Recovery.Simulates` relates each shared local state, viewed as a cursor
over the current shared world, to that branch's independently executed prefix.
The relation is the existing `Parallel.CursorAgrees`: regional ledger agreement,
complete capability equality, exact canonical events, outputs, successful index,
and located failure. It does not equate raw foreign event worlds.

For the selected branch, `advance_own_cursor` connects actual shared advancement
to `Composition.advance`. Existing dependency congruence, instantiated through
`continueRun_congr`, preserves both success and refusal outcomes. For the peer,
the shared step frames the peer's analyzed read region using actual invocation
analysis and checked compatibility. `runPrefix_simulates` proves this invariant
for every finite token list, including internally overlong lists. It uses actual
reachability to align local selection and trusted boundary indices.

The final complete-schedule proof uses exact consumed counts to turn both
isolated prefixes into complete existing `runBranch` results. Regional agreement
covers each admitted write region, because analyzed writes are also reads.
`continue_outside` preserves everything outside the two write sets. These three
cases establish pointwise equality with the existing merge, and actual
reachability supplies full capability-store equality.

Public declarations in `DefiKernel.Interleaving`:

- `runPrefix_parallel cfg boundaries initial left right lf rf hp schedule complete`:
  `ProjectedEquivalent` between the actual shared prefix result and the joined
  independent branch results with `mergeWorld`.
- `runInterleaving_recovers` with the same arguments: an existential joined
  result, the actual Parallel execution equation, the actual public shared
  execution equation, and the canonical relation.
- `runInterleaving_matchesParallel`: the actual public comparison returns true.
- `runInterleaving_matchesSerialLR` and `runInterleaving_matchesSerialRL`: every
  such complete schedule also matches the existing actual serial references.
- `complete_blockLR/RL` and `runInterleaving_blockLR/RL`: full-block schedule
  specializations, with no new commutation assumption.
- `runInterleaving_empty_left/right`: exact canonical sequential branch behavior
  beside an empty peer, including a refusing nonempty branch. As in the existing
  empty-peer lemmas, the admission premise names the empty footprint explicitly.
- `runInterleaving_empty`: with valid configuration, two empty branches and the
  empty schedule return exactly the initial machine as an executed public result.

The serial transport helper requires an already proved existing observational
equivalence; the generic shared-to-parallel theorem is proved before using that
helper. Thus the old serial theorem is a corollary dependency, not a premise that
assumes the new interleaved result.

## Actual verification and identity

[verification.json](verification.json) contains exact commands, full driver text,
25 input/dependency/tool-manifest hashes, owned-source hashes, UTC times and log
hashes. All four commands exit zero:

1. `lake build DefiKernel.Interleaving.Recovery`: successful, 939 jobs. All five
   owned sources compile; warnings replayed from preexisting dependencies are
   distinguished from the new sources. Final LSP diagnostics for the new Recovery,
   Reference, Step, Simulation and LocalOrder files report no errors; the final
   root and helper cleanup checks have no warnings either.
2. A temporary Lean driver runs `#print axioms` for all 35 named theorems across
   the five owned files. The observed declaration set equals the source name set
   exactly. Only `propext`, `Classical.choice`, and `Quot.sound` occur. This is a
   named theorem audit, not a replacement for the parent's automatic imported
   theorem and supplemental-declaration audit.
3. A temporary Lean driver executes all six 2+2 disjoint schedules in both a
   successful case and a refused-prefix case: 12/12 unique checks true. Each check
   compares the full ledger and capability store and exact branch observations
   with independent expectations, then also calls the public Parallel comparison.
   Successful case: left transfers 3 then 2 USD, right transfers 4 then 3 shares;
   expected balances are Alice USD5, Bob USD5, vault shares13, Alice shares7.
   Refused case: left transfers 3 then attempts 8; it retains the first transfer
   and exact index-1 insufficient-funds refusal while right completes. Expected
   balances are Alice USD7, Bob USD3, vault shares13, Alice shares7. All other cells
   and the entire initial store are checked through the independent balance table.
4. Tool identity: Lean `4.33.0-rc2`, commit
   `d8b18978322de05a8f3dba51ef03cf5461676c17`, release build.

All 25 captured input files remained byte-identical during these checks. A source
scan found no `sorry`, `axiom`, or `native_decide` in the five owned files. The
exact axiom audit provides stronger named-proof evidence than that text scan.
No source mutation was executed in this subtask. The concrete executions
supplement the universal Lean proof; they do not establish its quantification.

Development failures were ordinary proof/elaboration checks, not counted as
mutation detection: a bound proof needed an independent copy because a dependent
list-index equality retained the original type, and case analysis on
`AdvanceSound` required generalizing the computed post-state before elimination.
LSP goal inspection guided both fixes. All final proofs elaborate without holes.

## Remaining parent integration

The generic obligations of tasks 5.3 and 5.4 are supplied. Task 5.5's generic
empty/block laws and twelve concrete spot checks are supplied; the parent still
owns the combined production test inventory and the shared-source counterexample
to unrestricted equivalence. The temporary runtime driver is saved verbatim in
the manifest so those cases are reviewable and reproducible, but its labels are
not automatically part of the eventual production Audit inventory.

The parent must include these modules in the verification root, generate the
automatic imported axiom/proof inventory, run full regressions and production
mutation sensitivity, and obtain the required native Grok/Fable implementation
reviews on the final frozen candidate. This subtask does not authorize omitting
those acceptance gates or broaden the theorem beyond checked disjoint admission.
