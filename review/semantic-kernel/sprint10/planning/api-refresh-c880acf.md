This is bounded Sprint10 planning preparation against frozen Sprint9 candidate `c880acf62944746ff9a376afc0c0050702f037f7`. It is **not** accepted dependency evidence, an official planning gate, a Lean proof, or implementation authorization. Sprint9 source/evidence acceptance and verified delivery remain prerequisites. No build, elaboration, fixture execution, mutation, native call, source edit or commit was performed.

The current M1 APIs support the proposed design without a semantic redesign. All 17 financial-source bindings in the old provisional context still match their recorded bytes. The companion JSON binds 47 inspected files to exact c880 Git blobs and SHA256 values, with unchanged HEAD and file readbacks. The current draft has **20 fixture contracts, 57 scenarios, 17 requirements, 34 unchecked tasks and 14 planned mutants**. Static inspection of the actual M1 harness finds 65 named controls with their expected exits; this inspection does not claim those controls have completed their current run.

Required refreshes before the official planning freeze:

1. Replace the obsolete inspected-`a52fb...` and “proposed recursive-group names are not existing APIs” context. M1 now supplies `DefiKernel.Metatheory.SeqGroup.empty/step/seq`, `runGroup cfg boundaries cursor group`, and the exact full-cursor theorem below. Keep c880 labelled inspected-only until acceptance; if the accepted dependency changes, compare its actual relevant bytes and refresh the bindings. Record separate source, evidence, archive and remote-delivery identities.

2. Replace future Opus bindings in proposal, design, tasks, `interface-binding-regression-evidence/spec.md`, and the wiki outline. Latest AGENTS requires independent nonauthor GPT-6 plus native Fable5.1 planning acceptance on identical frozen inputs; request `claude-fable-5-1[1m]` with `--effort medium`, recording the actual returned identity. Substantive source/evidence reviews use native Grok plus Fable5.1. Preserve historical Opus reports and their original identities. Stock GPT-6 implementation and no Foreman remain binding.

3. Make the arbitrary-entry continuation proof contract explicit. `Composition.TraceSound.nil` starts with empty events/history and index0. `continueRun_trace_sound` preserves an already supplied TraceSound premise; it does not manufacture that premise for arbitrary entry cursors. F16 deliberately starts at index2 with supplied history. Prove continuation accounting/invariants by induction over actual `advance`/`continueRun`, or introduce a suffix trace indexed by the complete supplied cursor. Sum only newly appended successful events, for example after proving the append decomposition or using `events.drop entry.events.length`. Preserve the entry prefix without claiming a genesis reconstruction. Then transport that theorem through actual `runGroup` equality.

```lean
DefiKernel.Metatheory.runGroup_eq_continueRun
  (cfg : Composition.Config P A D)
  (boundaries : Nat → Composition.Boundary P A D)
  (cursor : Composition.Cursor P A D)
  (group : DefiKernel.Metatheory.SeqGroup P A D) :
  DefiKernel.Metatheory.runGroup cfg boundaries cursor group =
    Composition.continueRun cfg boundaries cursor
      (DefiKernel.Metatheory.flatten group)
```

This theorem uses shared `DecidableEq` and `Fintype` instances for P/A/D, has no success-only or entry-trace premise, and preserves raw before/post event worlds as well as the current ledger/store/history/index/failure. Use this equality for the grouped accounting result. `CursorEquivalent` intentionally omits old raw worlds, so it is not a replacement for the full-cursor bridge.

4. Refresh the immediate runner predecessor to `scripts/check_metatheory_mutations.py`, `scripts/test_metatheory_mutation_runner.py`, `mutations/metatheory.json`, and `DefiKernel.Metatheory.Audit`. The old Atomic bytes remain historical evidence. Freeze the complete Interface rename map, including paths, scoped namespaces, proof-tail/namespace regexes, fixture names, `discovered-metatheory-dependency`, production forms, and exact empty/duplicate/failed-count strings. A chosen new filename `run_interface_mutations.py` is valid but must be mapped explicitly rather than treated as an inherited filename. Retain the 600-second command default, explicit production timeout argument and 1500-second outer harness bound, including the inherited limits on timed-out-command logging. Bind actual final65 control evidence after S9 completes.

5. Preserve the distinction between global and per-mutant positive controls. The inherited schema enforces one global `positive_checks` list; the M2 table names different siblings per variant. Freeze a supplemental per-mutant assertion matrix, as the M1 workflow does, or explicitly design and review a schema change. A nonempty actual transfer with independently checked full world/store/receipt and neutral receipt delta, plus a valid empty binding query, is a plausible global pair; survival still requires real execution. The proposed Region has a `cells` field: the eventual M01 site is a fold over `region.cells.toList` unless an explicit `Region.toList` accessor is added. Do not describe that accessor as an existing API.

The existing bridges remain usable with these exact distinctions:

| Obligation | Current source/API | Required use |
| --- | --- | --- |
| Cell balance type | `Typed.State.balance : Cell P A D → ℚ`; `Cell := D × P × A` | Reuse this ledger. New region sums operate over its cells; no alternate state or supply field. |
| Actual accepted step | `Composition.executeStep_sound` | Convert actual `.ok result` equality into `StepSound`. |
| Exact cell effect | `Atomic.step_receipt_balance` in `Atomic/Settlement.lean` | Its premise is `StepSound`, not an execution equality directly. Compose the preceding bridge; prove the new facade equals `Atomic.receiptEffect`. |
| Effect outside declared writes | `Composition.StepSound.locality` plus exact cell equation | Derive zero actual receipt effect by rational cancellation. Locality alone is a balance equation. |
| Value support | `Composition.AgreeOn : Set Cell → State → State → Prop` | New `ValueSupports` is a value-equality predicate; existing `Supports` only preserves propositions. Coerce finite regions to sets explicitly where needed. |
| Shared prefixes | `Interleaving.runPrefix_reachable`, `Reachable.next`, `AdvanceSound` | Induct on actual selected token transitions. Accepted cases carry exact execution equality; refused, halted and exhausted cases preserve the world. |
| Export identity | `Component.exports`, `ResourcePort`, `ResourceImport.source/cell/writable`, `validateCatalog` | Define new qualified resource resolution. Existing `lookupOperation` resolves invocation interfaces, not resource exports. Catalog validity constrains aliases/access but does not establish balance equality. |

For shared receipt accounting, use the actual ordered `Machine.attempts`, retaining successful outcomes only. Neither concatenated branch receipts nor whole-dimension `Machine.supply` is a substitute for signed region effects. Derive permitted-call membership from the selected invocation and static branch membership. There is no need to assume disjointness, peer success, or a schedule-independent result. Same-configuration M2 preservation does not require turning M1 `ConfigAgreement` into a runtime checker.

The fixture contract remains constructible on this API, subject to later compilation and execution. Keep its fresh five-account/two-asset/two-domain universe: all20 cells, explicit17 live grants, exact per-call IDs and ordered raw evaluated deltas. M1's example aliases have different finite universes and cannot silently supply those identities. F18 appends ID17 and then tombstones exactly that entry; administrative balance identity does not mean store identity. The private-total catalog may contain unused op105 because catalog validation is structural; its access refusal cannot substitute for F06's valid exposed-total catalog and actually accepted authorized total increment.

For F16, the supplied `(index1, component0/port12, USD9)` history is arbitrary continuation data, not a claim that that output was reachable under the same catalog. Actual op100 at index2 creates the balance snapshot `(component0/port10, USD4)`; op107 consumes that snapshot at index3 and divides by2 to return USD2. Its expected request argument is USD4, its final balances are6/4 and its nextIndex is4. “Literal snapshot” should describe independently written expected data, not a production operation that accepts a supplied output. Resource port0, input11 and output10 are distinct; querying an input/output-only name must still fail live-export resolution.

Preserve all peer companions:

| Fixture | Schedule | Required current API behavior |
| --- | --- | --- |
| F17 | L,R,L | Two accepted paired debits reach3/3/4 before left local-index1 refusal. |
| F19 | L,L,R | Reach4/4/2; refusal leaves that world; peer then reaches3/3/4. Left consumed2, right consumed1. |
| F20 | L,L,L,R | Same refusal, then a failed-left suffix skip changes only left consumed; no mint attempt/receipt/supply. Peer reaches3/3/4. Left consumed3, right consumed1. |

F19/F20 have exactly two accepted receipts and one failed attempt in actual global order; both output histories are empty, left failure stays at local index1, both successful next indices are1, and all17 capability entries remain unchanged. These companions close the original refusal-last coverage gap. Keep a distinct exhausted-selection identity proof case; F20 is a failed-suffix witness, not an exhausted-active witness. None of these cases is a finite-participant executor or a reordering law.

A prompt path to the planning freeze is: complete and verify S9 delivery; refresh future context/reviewer/API/runner records while preserving all20/57 commitments; capture the specified fresh accepted-source Lean baseline and honest Python regression identities or relevant-dependency carries; regenerate and strictly validate source/scenario/mutation/control maps; freeze one complete source bundle for separate nonauthor GPT-6 and native Fable5.1-medium review. Only both accepted verdicts and adjudication authorize the missing-feature check and new Interface implementation. No current review or fixture count establishes that gate.
