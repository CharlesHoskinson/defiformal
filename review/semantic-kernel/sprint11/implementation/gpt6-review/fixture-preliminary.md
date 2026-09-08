# Fixture draft semantic review

Status: PRELIMINARY; NO IMPLEMENTATION VERDICT. Native Grok is writing these modules. GPT-6 inspected source and accepted fixture/API contracts read-only, with no Lean/Lake/LSP/build or fixture execution. Findings apply to the recorded draft bytes. This report is the sole file written by this review.

Initially inspected Examples.lean SHA256 `e42a4caedcde54d01e7f749d53851b75ef80fc0c8bacbf4910651fe0bc65af47` (1026 lines), Tests.lean `681acf69c43fbbf05a329bdc9daf3bdf2f2641ae8dcd08ced4f856e0adfd9ad2` (488 lines); Audit was absent. Tests changed while the review ran. The relevant findings were reread against `6be66e90e22353f8982d585a9de0545ac3c4c450bac0d70ab770bd1e2b3cba35`. Examples remained unchanged. Audit appeared at `575ebbbfa8f868af557edb1cd3f1c1c284caa28148bc08b5471f53ee749a6d90` and was read in full. Final reread hashes appear below; future edits need focused checking.

## Required semantic corrections / coverage work

### F1. M14's prescribed oracle observes the wrong channel

Tests `f10CoreChecks`, label `nary.monitor.success_input` (initial line354), reads `(f10Mon [0]).2.attempts.head?` and calls `isReadyProducer` on it. The second projection is the base machine, which the accepted M14 mutation does not change: M14 replaces `attempt := appended` with `attempt := none` only in the monitor input. The current prescribed oracle therefore stays true under M14, even though the monitor misses the producer.

Make this exact required label inspect the received monitor input or an independently expected consequence of receiving it, not the unchanged base attempt list. A small observation monitor that retains actual received attempts can compare the producer input with independently constructed expected identity/result fields. An additional exact Ready6 check can support the consequence. Preserve the accepted M14 target/needle/required_false and own protected positive. Do not treat another false label as satisfying this prescribed oracle. This defect remains in the reread Tests hash.

### F2. Synthetic negatives mask a broken candidate comparator

Tests `cmpMachine` (line61) is `machineEq roster x y && fullMachineEq roster x y`. F09's eight negative checks negate this conjunction. If candidate machineEq incorrectly returns true while the independent fullMachineEq returns false, the negative test still passes. Thus these checks cannot demonstrate the specified candidate query's single-field discrimination.

Require `!machineEq ...` directly for each synthetic negative. If the independent comparator is also checked, combine the two negative assertions with AND, or retain distinct IDs. Add an equal-pair positive for the candidate itself. This is a source-level Boolean defect, not a proposed adversarial change to fixtures. It remains in the reread Tests hash.

### F3. F09 does not yet cover the promised arbitrary-entry and all-field variants

Examples lines593–651 and Tests `f09Run`/`f09Chunked`/`f09Checks` contain eight coarse differences. They cover world, store, local consumed, one receipt replacement, local outputs, local failure insertion, attempt participant and event-before world. They omit independent differences for local nextIndex; event index/step/result world/output; attempt index/invocation/before/outcome, including successful result fields; and fine-grained receipt/output/failure observations required by the complete stored-field contract. Replacing an entire receipt also changes several receipt fields at once, so it cannot demonstrate each individual field's discrimination.

Add explicitly synthetic pairs changing one declared field at a time, retaining all other fields, with a coverage table against the actual Machine/LocalState/Event/Attempt/StepResult/receipt/output/failure structures. Include both historical before and after worlds and the evaluated receipt fields, rather than only current balance and a whole receipt replacement. The scope is the accepted full-observation scenario, not an arbitrary expansion of financial cases.

The populated entry has prior events/nonzero positions/failed p1 but `outputs := []`; the only suffix is `[2]`, selecting a fresh peer. `f09Chunked` executes an empty chunk followed by that singleton. It does not exercise a subsequent history-consuming invocation in an already populated stream, a meaningful split around refusal and peer continuation, or arbitrary populated monitor entry/chunking. Add the accepted fixture variants with literal prior outputs, valid later invocation, nonempty chunks and independently expected full machine/monitor values. These obligations are explicit in fixtures.json F09 and binary/causal arbitrary-entry scenarios. Current F09 classification also needs to distinguish its arbitrary-entry run from its synthetic pairs; a single synthetic classification label is not evidence for both classes.

### F4. F10's literal per-prefix monitor expectations are not yet checked

Examples has all48 literal rows across12 schedules, including `monitor` and `localsNC`. A bounded Python extraction compared every row's schedule/participant/index/op/before/after/output-present/phase/counters with accepted fixtures.json: 48 extracted, 48 required, zero differences. The table is good independent source material.

However, `expectedF10` assembles only the final machine, `f10PrefixReserve` checks only vault reserve and sentinel, and `f10MonitorChecks` tests only final Consumed. `row.monitor` is used only in an otherwise unused `expectedF10Phase`; `localsNC` is not used to check prefix counters. The two short spot checks do not validate each schedule's complete monitored prefix trace.

For each complete schedule and each prefix length, assemble the expected machine from the corresponding first literal rows and compare actual full machine plus phase against that row (entry has explicit initial machine/Awaiting). Compare literal consumed/nextIndex counters as well. Do not call `expectedF10` with a partial schedule without adapting row selection: rowsFor currently filters by exact complete schedule, so it returns empty for a proper prefix. This closes the accepted per-prefix provenance/observation contract without obtaining expected values from the candidate dispatcher.

## Resolved during this draft review

**F5 — overlong schedule sent through admission.** Initial Tests `nary.f10.extra-skip-consumed` called f10Run/runNary on `[0,0,1,2,0]`. Exact schedule checking must refuse p0 expected2/observed3, making the intact check false. The reread source changed this to prefix3, preserving the separate monitor call. The source-level defect is resolved at the reread hash. No runtime pass is claimed yet.

## Positive source findings, with limits

**F05 catalog and history construction.** One parameterized op18 has partyArity2 and amount input20, a single output port7 snapshotting fixed budget, and one consumer op19 with input8. Catalog component resource/input/output port IDs are distinct. Calls use donor0→budget6 and budget→donor1=4, appropriate actual invoke/debit capability IDs, and index-dependent producer boundaries donor0/budget followed by vault consumer boundaries. Expected snapshots are qualified same key/index0 values6/2. Expected final balances are vault2, budget2, donor0=0, donor1=4, recipients6/2, with separate histories/events and literal actual receipts. No two producer interfaces share one output port. Catalog validation and actual execution still await compilation/runtime evidence.

The equal-principal companion currently checks consumed counts and event indices only. Before claiming the full fixture variant, add its independent complete expected machine/history/attempt observations; the primary collision fixture already has those full literals.

**F10 oracle independence and provenance.** The48 row values are independent accepted literals. expectAccept is a local assembler of supplied row worlds/operations/receipts/outputs; it does not call candidate Machine.accept/advance/executeStep or a compared binary runner. Likewise explicit world/receipt helpers merely assemble stated values. Sharing data constructors is not using candidate execution to manufacture an oracle. Source inspection found no such call in expectedF10 or expectedF18.

The producer monitor predicate requires participant0, successful index0, operation200, qualified output `(index0,component0,port7,6)` and exact receipt200. Consumer recognition requires participant0/index1/op201/success/exact receipt201; Consumed cannot recreate a fact. Refused producer and actual successful peer-lookalike variants exist. The ready6 constructor encodes fixed amount/identity by the transition predicate rather than storing them as dynamic fields; concrete proofs must expose the provenance invariant that this representation carries. Current type and runtime checks alone do not discharge initialized budget/stability/success theorems.

**F18/F19 actual M2 bindings.** f18Cfg/initial/op/receipt/store alias accepted Interface.Examples cfg/initial55/op102/receipt102/initialStore; the region and nonempty global edge are fresh Nary literals. The six schedules are explicitly distinct. Expected worlds are literal accepted 5/5/0,4/4/2,3/3/4 and fresh2/2/6, with expected local index0, actual receipt102 and exact store. Inspected Interface.Examples shows these world helpers are independent balance constructors and the receipts use their own literal lists. All six accepted-api source file hashes match the accepted API contract. No Interface.Tests or preservation proof import was introduced in these fixtures.

F19 uses actual op103/receipt103, explicit4/5/1 world, exact fixed store, total10, empty-subset pass and the exact full-edge `.unequal 0 (name0) (name1) 4 5` failure. These are correctly scoped runtime queries. Generic finite TypedTotalContract/Agrees proofs and independently discharged actual receipt/support/neutrality/paired-effect obligations remain required in the proof lane; runtime balanceSum/bindingsHold checks do not replace them.

**Audit.** The newly read Audit uses nonempty/unique ID checks, emits all comparisons, filters/counts false values and throws the prescribed Nary error. No executed audit result is inferred from that source.

## Integration reminders, not extra draft verdicts

F03's current checks are Nary executions against independent literals; direct comparison/conversion against the actual binary executor and mismatch projection still need integration from the binary lane. Preserve their runtime/proof separation. No claim that missing draft additions have been compiled or tested is made here.

This review intentionally omits transient elaboration errors, generic world-constructor proof repair and incomplete file-writing issues. Those are author compile work. After freeze, verify source hashes, all prescribed mutation oracles and the substantive corrections above on the actual compiled inputs.

Examples and Tests changed again after the substantive reads. Those new bodies were not reviewed in this pass; the findings above apply to the explicitly inspected hashes and must be reconciled with subsequent author changes. Audit retained its inspected hash.

Final read-only source hash capture:

```json
{
  "Examples": "9ba064d85734ea29ace135f1b767e1b0271a2e5a54fdfc3abeeb32665128af6a",
  "Tests": "1a5b1cbaf912347f2c4b4f1aad708527eca1740b444fc9d756fe648b85f33ddc",
  "Audit": "575ebbbfa8f868af557edb1cd3f1c1c284caa28148bc08b5471f53ee749a6d90"
}
```
