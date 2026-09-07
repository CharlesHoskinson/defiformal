## Context

This is the M2 planning candidate, awaiting independent planning acceptance before implementation. Sprint9 is accepted and delivered: Lean source `eec499d613688137a341f3556cd80ca461dd2ee9`, source/evidence commit `ec9ed80457d7a9c4064d26ab193591579027abae`, and archive/verified remote commit `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff` on `semantic-kernel-pivot` (no main merge). Exact records are `review/semantic-kernel/sprint9/archive-delivery.json` and `acceptance/final-acceptance.json`; the accepted API/baseline binding is `review/semantic-kernel/sprint10/planning/r2-preparation/dependency-baseline.json`. Relevant source bytes remain equal through delivery. The accepted M1 source supplies `DefiKernel.Metatheory.SeqGroup.empty/step/seq`, `flatten`, `runGroup cfg boundaries cursor group` and `runGroup_eq_continueRun`. S10 implementation remains gated on same-candidate nonauthor GPT-6/native Fable5.1 medium planning acceptance. Material dependency changes require rechecking the bindings and revising the plan before that gate.

The current kernel has exact rational typed balances, actual evaluated receipts, permanent capability IDs, global catalog validation and binary shared execution. `Composition.executeStep_sound` converts an actual successful executeStep equality into `StepSound`; `Atomic.step_receipt_balance` consumes that soundness premise to give the exact cell-effect equation. `Composition.validateCatalog` forbids duplicate exported cells globally and validates imports against the exact exported cell. A live balance resource and a frozen invocation output are different objects. No historical Interface/Nary file changes are permitted.

## Goals / Non-Goals

**Goals:** finite typed receipt accounting; conditional initialized interface totals; exact executable global binding queries; actual-step and every-prefix preservation; algebraic constraint transport; independent nonzero financial witnesses and source mutation evidence.

**Non-Goals:** a new financial transition or storage alias model; inferred semantic certificates; solvency, liveness or machine arithmetic; finite-participant execution, causal monitor rules, routing trees, active extension, capability provenance or Atomic boundary regrouping. Three qualified names are a constraint example, not a three-party executor. No unconditional preservation from equal entry balances or from asset-supply neutrality.

## Decisions

### 1. Modules and stable mathematical interfaces

New namespace `DefiKernel.Interface`, files `Regions.lean`, `Accounting.lean`, `Bindings.lean`, `Preservation.lean`, `Examples.lean`, `Tests.lean`, `Audit.lean`, `Verify.lean`. Proof helpers may split into adjacent new modules without changing contracts. Runtime declarations, including executable predicates and private helpers, precede `-- BEGIN PROOFS`. Root integration is `lean/DefiKernel.lean`; there is no `DefiKernel.Verify` target. All Lake commands run with working directory `lean/` and its pinned toolchain.

Use existing type parameters P/A/D, decidable equality, and the finite instances required by actual execution. Define:

```text
Region P A D := { domain : D, asset : A, cells : Finset (Cell P A D) }
Region.WellFormed L := ∀ c ∈ L.cells, c.1 = L.domain ∧ c.2.2 = L.asset
balanceSum L s := sum over L.cells of s.balance c
receiptCellEffect receipt c :=
  invoked _ e => (e.deltas.map (fun d => if d.1 = c then d.2 else 0)).sum
  issued _ | revoked _ => 0
receiptDelta L receipt := sum over L.cells of receiptCellEffect receipt c
ValueSupports S f := ∀ s t, AgreeOn S s t → f s = f t
```

The inspected `State.balance` accessor has exactly this cell-to-rational type. Its accepted M1 source binding is captured in the dependency manifest; do not introduce a second ledger. Use direct executable `Finset.sum` for balanceSum and receiptDelta. Pinned `Finset.toList` uses noncomputable choice and MUST NOT appear in runtime aggregation or accepted runtime mutation paths; mathematical list/sum equivalence does not make that conversion executable. Region declarations use set semantics. WellFormed is an explicit proof premise, not an additional admission checker. Exact sum accounting holds even for mixed regions, but dimensioned interface contracts require WellFormed. The empty sum is zero. Repeated receipt targets are all summed. Define and prove `receiptCellEffect = Atomic.receiptEffect` before reusing the existing exact-cell bridge. This small computational facade supplies auditable query code, not an alternative executor.

Alternative rejected: whole-asset supply as region delta. It loses transfers across the region boundary. Another rejected alternative is a caller-supplied effect table in the accounting theorem.

### 2. Actual receipt accounting and noncircular total preservation

For arbitrary cfg, boundary, index, history, step, pre and r, prove:

```text
executeStep cfg boundary index history step pre = .ok r
  → balanceSum L r.world.state = balanceSum L pre.state + receiptDelta L r.receipt
```

Apply `Composition.executeStep_sound` to the actual success equality, then `Atomic.step_receipt_balance` to its `StepSound` witness, the new receipt-effect facade equality, and a finite-sum identity. Invocation, issue and revoke are covered; administration preserves balances while stores change. The receipt fold over newly appended actual successful events telescopes from the supplied entry state to every sequential prefix. For continuation from an existing cursor, exclude its preexisting event prefix from that fold and retain its old events/outputs unchanged; no claim reconstructs an arbitrary supplied cursor from genesis. For an arbitrary supplied cursor, prove the continuation result directly by induction over actual `Composition.advance`/`Composition.continueRun`, or define a suffix trace indexed by the complete entry cursor. Prove the old-event append decomposition before summing the new suffix (equivalently `result.events.drop entry.events.length`). `Composition.TraceSound.nil` starts at empty events/history and index0, and `continueRun_trace_sound` only preserves an existing TraceSound premise; neither supplies one for F16. No premise may require the arbitrary entry cursor to be genesis-reachable. Actual refusals append no successful receipt and retain the reached state. Shared-run folds use the actual global accepted attempts, not isolated branch re-execution or duplicate receipt collection.

For a shared finite cell set `Q : Finset (Cell P A D)` and support `S : Set (Cell P A D)`, define `WritesWithin Q receipt := ∀ c ∈ receipt.writes, c ∈ Q` and `NeutralOn L Q receipt := sum c ∈ L.cells ∩ Q of receiptCellEffect receipt c = 0`. Prove actual write locality makes effects outside Q zero. These premises yield unchanged region total even when shared effects are individually nonzero.

For `balanceSum L s = f s`, assume initialization, ValueSupports S f and disjointness of every actual receipt write from S, together with confinement and neutrality. State a generic local obligation over **every** current pre-world, history, absolute index, boundary and permitted step, with actual success equality. Lift by actual trace induction. Concretely, for `Allowed : Step P A D → Prop`, local preservation has shape `∀ boundary index history step pre r, Allowed step → I pre.state → executeStep cfg boundary index history step pre = .ok r → I r.world.state`. The prefix theorem assumes initialization of I and static membership of every program step in Allowed; binary invocation branches use Allowed (.invoke inv). This is an explicit conditional theorem, not automatic inference of Allowed. Do not premise the final invariant, an already successful completed run, or equality of the desired post-total. The fixed ghost q specialization uses constant f and empty support. A private support cell is one sufficient instance; arbitrary state-dependent f requires its explicit value support proof.

### 3. Exact binding query and failure precedence

Define `Binding := QualifiedPort × QualifiedPort` and use an ordered `List Binding` for query input. Repetition is permitted and logically idempotent. Define `resolveExport catalog name : Except EndpointFailure Cell`; lookup first the exact component ID, then the exact resource-export port ID. `EndpointFailure` distinguishes `missingComponent(name)` and `missingPort(name)`. Input/output port IDs and import source names are not independently declared resource exports. Catalog validation is not a proof of balance equality.

Define the production API `checkBindings cfg edges state : Except BindingFailure PUnit` and `bindingsHold cfg edges state : Bool` as its success projection. Failures are:

```text
configuration
endpoint(edgeIndex : Nat, side : left | right, reason : EndpointFailure)
domainMismatch(edgeIndex, leftCell, rightCell)
assetMismatch(edgeIndex, leftCell, rightCell)
unequal(edgeIndex, leftName, rightName, leftAmount : ℚ, rightAmount : ℚ)
```

First call existing `validateCatalog cfg.registry cfg.catalog`, including when edges is empty. On failure return configuration. Then traverse edges in original list order with zero-based positions. For each edge resolve left, resolve right, compare domain, compare asset, compare balances, in that exact order. Return its first failure or continue. Success is `.ok ()`. Earlier inequality wins over later missing endpoint; left missing endpoint wins over right; domain mismatch wins over asset mismatch. Never sort or deduplicate the query list before diagnostics. No input world/store mutation occurs.

`Agrees catalog edges s` is the proposition that each listed edge resolves both endpoints and their domain, asset and current balances agree. Prove:

```text
checkBindings cfg edges s = .ok ()
  ↔ validateCatalog cfg.registry cfg.catalog = true ∧ Agrees cfg.catalog edges s
bindingsHold cfg edges s = true ↔ the same conjunction
```

Also expose exact first-failure characterization and resolution uniqueness under valid catalogs. This is a concrete query, not a complete equivalence checker. Valid duplicate-free catalog lookup is fixed throughout a preservation theorem. Invalid catalogs still have deterministic query failure, with no financial inference from rejection.

Existing imports reference an export's exact cell. Prove this from catalog validity and instantiate after a real write. A self-binding `(p,p)` is automatically balance-equal when p resolves. Two distinct exported names in a valid catalog cannot alias one cell; equality of their balances needs a separate invariant.

### 4. Initialized binding preservation and constraint algebra

A sufficient local condition for a resolved edge (c,d) is equality of **actual** receipt effects at c and d. Initial balance equality plus the exact-cell bridge establishes post equality. Frame and self-edge cases are corollaries. For every permitted actual successful step require this paired-effect condition for each global edge; alternatively allow a separately proved local invariant-preservation obligation. Quantification includes arbitrary current history/index/boundary and pre-world, and may use the current invariant as an inductive antecedent. It must not assume the desired entire run or future peer result.

Prove initialization plus these local obligations entails Agrees at every actual sequential prefix and existing binary Interleaving prefix. Explicitly handle failed/absorbed cursors and failed/exhausted branch skips by actual world identity. Administrative steps have zero balance effects, without claiming store identity. Lift the sequential theorem through accepted M1 recursive-group full-cursor simulation, including a nonzero starting index and arbitrary supplied history. Use exactly:

```lean
DefiKernel.Metatheory.runGroup_eq_continueRun cfg boundaries cursor group :
  DefiKernel.Metatheory.runGroup cfg boundaries cursor group =
    Composition.continueRun cfg boundaries cursor (DefiKernel.Metatheory.flatten group)
```

The theorem shares P/A/D DecidableEq and Fintype binders and has no success-only or entry-trace premise. `CursorEquivalent` omits old raw worlds and is not a replacement for this full-cursor equality. A checked correspondence to actual execution is required; defining the group theorem to run a newly flattened list is insufficient.

Use list append as conjunction: `Agrees (E ++ F) ↔ Agrees E ∧ Agrees F`. Prove reversal of every edge, duplicate idempotence, append associativity and permutation invariance at the proposition/success level. Transfer initialization and step obligations across these laws to get prefix corollaries. Exact diagnostic payloads need not be equal after reordering or reversal.

Let `symClosure E` be the finite set of listed ordered pairs and their reverses. Equal symmetric closures imply equivalent Agrees predicates, including resolution/dimension constraints. This criterion is sufficient, not necessary. With a valid catalog of three same-dimension exported cells, E=[A=B,B=C] and F=E++[A=C] have equal predicates for every state, by transitivity, but unequal symmetric closures. Do not generalize to a complete semantic-equivalence decision. Preserve all global edges; no binary cut is an argument to the query and no cut-local query mode is added.

### 5. Independent fixture contract

Use a fresh finite fixture universe P={alice,bob,carol,total,admin}, A={usd,eur}, D={home,away}; every unspecified cell balance is exactly zero. Compare the entire 20-cell ledger and full store, with independent literal expected data. No expected balance, receipt or failure may be obtained by calling a production Interface query or executor. Helpers constructing literal expected records are permitted. Capabilities are an explicit fixed live-entry list, holder alice, domain home, exact operation IDs and exact debit/changeSupply rights as needed; no blanket authorization. The initial store is exactly17 live entries ordered as follows (holder alice, domain home throughout): ID0=(op100,invoke),1=(op100,debit Alice),2=(op101,invoke),3=(op101,changeSupply home/usd),4=(op102,invoke),5=(op102,debit Alice),6=(op102,debit Bob),7=(op103,invoke),8=(op103,debit Alice),9=(op104,invoke),10=(op104,debit Alice),11=(op105,invoke),12=(op105,changeSupply home/usd),13=(op106,invoke),14=(op106,debit Alice),15=(op107,invoke),16=(op107,debit Bob). Every invocation supplies exactly its listed IDs in that order. All debit cells above mean home/USD at that party. Each request has parties=[] and claimedActor=none; arguments=[] except the F16 op107 USD4 argument. F18 issues a new op100 invoke grant to Bob at ID17, then revokes17; its final appended entry alone is tombstoned. The refused admin companion uses principal alice against trusted admin. Administration uses authenticated admin. All environments are empty, time0, and no claimedActor unless specified.

Freeze these operations: ID100 transfer2 (alice −2,bob +2); ID101 mint3 (bob +3,supply home/usd +3); ID102 paired debit (alice −1,bob −1,carol +2); ID103 one-sided debit (alice −1,carol +1); ID104 repeated targets (alice −1,alice −2,bob +3); ID105 total increment (total +1,supply home/usd +1); ID106 transfer7 (alice −7,carol +7). Each template has no arguments/parties, literal true guard, exactly the ordered deltas above, exactly the indicated supply list (otherwise []), no state/environment reads and a duplicate-free declared write list in first-target order. Reads, guard, supplied IDs, request, writes and repeated delta list are compared explicitly, not only net results. Output-free core fixtures emit []; a separate grouped fixture emits an actual post-balance USD snapshot and consumes it as described below; its expected snapshot is independently written literal data. The canonical valid catalog has C0 export A=Alice, C1 export B=Bob, C2 export C=Carol, C3 export U=Alice/home/EUR, C4 export V=Alice/away/USD and C5 export W=Alice/away/EUR, all local resource port0 and writable. C0 contains the unique interfaces for op100–107 and imports B/C; the exposed-total variant adds C6's writable home/total/USD export port0 and C0's matching import, while the private-total variant has C6 own that cell privately and no import. C7 imports A for F14. All unmentioned private cells/imports/outputs are empty. Interface op107 alone has input port11 of USD amount; core interfaces emit no outputs. F16's separate valid interface variant adds to op100 output port10 at Alice/home/USD, with no other interface change. Every interface/template signature matches and all catalogs are checked by actual validation. Private-total and deliberately exposed-total variants are separate valid catalogs.

| Fixture ID | Actual execution or query | Independently required observation |
|---|---|---|
| F01 | Region home/usd {alice,bob}, balances6,4; op100 | Final4,6; region10→10; delta0; effects −2,+2; unchanged full store; exact invoked receipt |
| F02 | Same actual op100, singleton {alice} | 6→4; delta−2; whole home/usd supply0 |
| F03 | Same entry6,4; op101 | 6,7; region10→13; delta+3; supplies[(home,usd),+3] |
| F04 | Entry6,4; op104 | Final3,7; singleton delta−3; ordered repeated receipt targets retained |
| F05 | F01 plus private total cell10, f reads it | Region10 and f10 after transfer; support {home,total,usd} framed |
| F06 | Entry Alice6/Bob4/total10; separate valid catalog exposes total as writable; op105 | Accepted total10→11, region remains10, region flow0, whole supply+1; total relation false |
| F07 | Entry alice=bob=5,carol0; op102, plus a recursive M1 seq of two op102 leaves | Original one-receipt case stays4/4/2; grouped companion has independent full expected cursors5/5/0 →4/4/2 →3/3/4 and A=B query success at both actual prefixes |
| F08 | Same entry; op103 | Accepted4,5,1; binding A=B false with exact unequal payload |
| F09 | Three names A,B,C; global edge A=C and cut {A,C}|{B} | Query on balances4,5,5 rejects A=C; the explicitly constructed empty cut-extracted edge list accepts; no participant execution claim |
| F10 | Catalog A=(component0,port0) alice/home/usd; B=(component1,port0) bob/home/usd; C=(component2,port0) carol/home/usd; E=(A,B),(B,C) | Equal5,5,5 succeeds; E vs E+(A,C) equivalent with unequal symmetric closures; independent edge (A,B) fails at4,5,5 |
| F11 | Entry A=U=V=W=5, all other cells0; additional valid exports U=(component3,port0) alice/home/eur; V=(component4,port0) alice/away/usd; W=(component5,port0) alice/away/eur; each balance5 | A=U assetMismatch; A=V domainMismatch; A=W domainMismatch takes precedence, all printed amounts5 |
| F12 | Entry Alice4/Bob5/Carol5; unknown X=(component99,port0), Y=(component0,port99) | Exact endpoint missingComponent vs missingPort with original edge index and side; all combinations and earlier inequality/later missing covered |
| F13 | Zero ledger; invalid catalog repeats C0, including empty edges; valid catalog empty edges and self-edge | Invalid configuration error; valid empty/self success; input state/store unchanged |
| F14 | Entry Alice6/Bob4; import source A in a distinct component, exact cell A, writable authorization preserved | After op100, import and canonical export observe Alice4; no second export of the same cell |
| F15 | Region home/USD {Alice,Bob,Carol}; F07 followed by actual op106 insufficientFunds and a skipped op101 suffix | World4,4,2, one successful receipt; failure kernel.insufficientFunds at absolute index1; no mint/suffix history; binding retained |
| F16 | Entry Alice6/Bob4, region {Alice,Bob}; accepted M1 group, entry index2 and one independently initialized prior output (index1,component0/port12,USD9); leaves op100 and snapshot-driven return2 Bob→Alice | First emits Alice4 at absolute index2; second reads that exact output and divides by literal2 to move2; final6,4, indices2/3 and nextIndex4, old history preserved, region10; capabilities include exact return-operation rights |
| F17 | Region home/USD {Alice,Bob,Carol}; binary admitted schedule [left,right,left], left=[op102,op106], right=[op102], initial alice=bob=5 | Complete actual run: left paired→4,4,2; right paired→3,3,4; left op106 refuses; actual attempt fold has two receipts; binding A=B and total10 persist |
| F18 | Entry Alice6/Bob4, region singleton Alice; authorized issue then revoke starting from explicit store length n=17 | Receipts issued n/revoked n; appended capability then tombstone; balances unchanged and region delta0; include rejected non-admin case with unchanged store |
| F19 | F17 entry/region/branches, schedule [left,left,right] | Left paired→4/4/2, left op106 refuses at local index1 leaving4/4/2, then right paired→3/3/4; left refusal retained, two successful receipts and one failed attempt in actual global order |
| F20 | F19 with left=[op102,op106,op101], right=[op102], schedule [left,left,left,right] | Third token skips the failed left mint suffix, preserving4/4/2 without an attempt/receipt/supply; peer then reaches3/3/4; exact left refusal and store retained |

F19 and F20 are bounded companions added after the provisional constructibility
check; original F17 remains required. Their independent global attempt sequence
is left/index0/op102 at5/5/0 → ok4/4/2, left/index1/op106 at4/4/2 →
error(kernel.insufficientFunds), right/index0/op102 at4/4/2 → ok3/3/4.
The full17-entry store remains unchanged. Left has one successful event at index0,
nextIndex1 and failure(index1,Some invoke op106,kernel.insufficientFunds); right
has one successful event at index0, nextIndex1 and no failure. Both output
histories are[], and each raw event retains the just-specified before/result world.
Left consumed is2 for F19 and3 for F20; right consumed is1 in both. F20's skipped
third left token changes only consumed and adds no global attempt. All20 ledger
cells are checked; region Alice/Bob/Carol totals10 at every prefix and A=B changes
5→4→3. These schedules directly exercise peer continuation after refusal, which
F17's refusal-last order does not. Failed and exhausted selection remain separate
identity cases in the generic prefix proofs; F20 is the explicit failed-suffix
runtime witness. These M2 fixtures remain unexecuted; their required behavior is stated against the inspected M1 API, with accepted Sprint9 delivery bound separately from these unexecuted M2 cases.

F12 uses query [(A,Y)] for the right missingPort oracle, [(X,A)] for left missingComponent, [(A,X)] for right missingComponent, [(X,Y)] for left-before-right precedence, and [(A,B),(A,X)] for earlier inequality0 versus missing endpoint1. F11 queries exactly [(A,U)], [(A,V)] and [(A,W)]. Also query valid C0 input-only port11 and, in the F16 catalog, output-only port10: each is missingPort for live resource resolution.

F07 retains its original one-step witness and adds a companion within the same fixture
ID. From a valid-catalog start cursor at index0, empty events/output history and
the fixed 17-entry store, execute actual
`Metatheory.SeqGroup.seq (.step (.invoke op102)) (.step (.invoke op102))` using `runGroup`; here
`op102` denotes the fully specified invocation with IDs[4,5,6], empty arguments
and parties, principal Alice and no claimed actor. The first-leaf cursor and the
whole-group cursor are each compared to separately constructed expected records,
not to a flattened execution or a production Interface result. Their complete
20-cell ledgers are respectively4/4/2 and3/3/4 at home/USD Alice/Bob/Carol, all
other balances0. Both retain the exact initial17-entry store, outputs=[], and
failure=none; nextIndex is1 then2. The first event is at index0 with literal
pre-world5/5/0 and post-world4/4/2; the second is at index1 with literal
pre-world4/4/2 and post-world3/3/4. Expected receipts retain the full invoked
request/evaluated template, ordered effects[Alice−1,Bob−1,Carol+2], supply=[],
declared writes[Alice,Bob,Carol], empty reads and output list, and literal true
guard. Compare events=[first] then[first,second], with the exact result worlds.
The actual global query on[(A,B)] must return success at entry and at both
actual prefixes. This is a concrete initialized group-binding witness; its
nonzero equal endpoint effects discharge the generic local premise. The generic
group-binding theorem still covers arbitrary groups and supplied initialized
cursors under its stated obligations.

F16 starts and ends at Alice6/Bob4, so it is a total/history/full-cursor group
fixture, **not an initialized A=B witness**. No binding-equality premise is
inferred for it or added to its arbitrary continuation data.

F16's supplied old output at index1/component0/port12 is arbitrary continuation data, not a claim of prior reachability in this catalog. No prior event is fabricated to justify that entry. F16's snapshot/return template uses a new operation ID107, literal divisor2, input USD amount4, Bob−2/Alice+2; independent expected request arguments=[USD4]. It needs no causal preservation claim beyond these actual fixture checks. The finite fixture comparison count is discovered from actual tests, never inferred from this table. Additional access/admin controls are allowed but cannot replace a listed case.

### 6. Fourteen actual production mutations and protected expectations

Implement `scripts/run_interface_mutations.py` and `scripts/test_interface_mutation_runner.py` from the final accepted predecessor harness. Each variant changes one new runtime definition before the proof marker in a copied actual source closure, removes proof suffixes only under the established verified procedure, compiles the complete mutated runtime dependency closure, executes the real Audit entry point and records explicit false comparisons. Compilation alone is never financial detection. Every named designated comparison below must be true for control, false for its compiled mutant; its protected sibling remains true. Bind the actual replacement bytes, source path, counts, closure and independent expected data before production execution.

| ID | Real new runtime mutation | Designated comparison | Protected sibling |
|---|---|---|---|
| M01 | Replace balanceSum’s `region.cells.sum state.balance` with executable `region.cells.fold max 0 state.balance` | F01 sum10 becomes max6 at Alice6/Bob4 | Empty region sum0 remains0 |
| M02 | Negate receiptDelta's final signed sum | F02 delta−2 | F01 neutral delta0 |
| M03 | receiptCellEffect uses first matching target instead of sum | F04 singleton delta−3 | F02 one-target delta−2 |
| M04 | receiptDelta returns0 if receipt has nonzero supply for region dimension | F03 delta+3 | F01 delta0 |
| M05 | receiptDelta returns whole dimension supply | F02 delta−2 | F03 delta+3 |
| M06 | checkBindings drops final edge before traversal | F08 one-edge unequal result | F07 equal edge success |
| M07 | Query compares left balance with itself | F08 exact unequal result | F07 equal edge success |
| M08 | Query omits asset comparison | F11 A=U assetMismatch | F07 same-asset equality |
| M09 | Query omits domain comparison | F11 A=V domainMismatch | F07 same-domain equality |
| M10 | resolveExport searches port ID globally, ignoring component | F08 resolves B to Bob5 and rejects | F13 self-edge success |
| M11 | Missing port lookup falls back to first export of selected component | F12 missingPort at component0/port99 | F10 existing-port success |
| M12 | Traverse tail before checking current edge, preserving original indices | F12 first unequal index0 before missing index1 | F10 all valid equal edges |
| M13 | checkBindings bypasses catalog validation | F13 invalid-catalog empty-edge configuration | F13 valid empty success |
| M14 | receiptCellEffect for issued receipt returns1 rather than0 | F18 issued delta0 for singleton region | F01 invoked neutral delta0 |

M01 changes aggregation from sum to maximum using a commutative associative executable fold, with no arbitrary enumeration. For the designated nonempty region it returns6 instead of10; the empty region stays0. The pinned existing-library probe records10/6/0/0, demonstrating this replacement's constructibility only, not any new Interface mutation execution. M10 deliberately uses colliding local port IDs in distinct valid components. M12 targets deterministic diagnostics rather than a financial theorem. M08/M09 target typed binding validation; M11/M13 target structural validation; distinguish these categories from M01–M07/M14 accounting/balance checks. Cut omission, writable total and false symmetric-closure completeness are actual semantic counterexamples, not invented runtime mutation flags or theorem-premise edits.

The immediate accepted predecessor is `scripts/check_metatheory_mutations.py`, `scripts/test_metatheory_mutation_runner.py`, `mutations/metatheory.json` and `DefiKernel.Metatheory.Audit` at eec499d. It exposes65 named real-CLI control contracts: 52 inherited cases (including the base proof-boundary case), 11 additional proof-tail/parser cases, and 2 production `#eval`/`IO.userError` forms. `review/semantic-kernel/sprint10/planning/r2-preparation/runner-adaptation.json` freezes every old/new control name, complete fixture payload, expected exit/message, namespace, root, proof regex and production-error string. The adaptation contract itself does not execute new Interface controls. The bound predecessor Metatheory control run completed65/65 at eec499d; its summary and source identities are recorded in runner-adaptation.json, with accepted source/evidence/delivery status recorded in dependency-baseline.json. Retain every accepted control and recheck the binding if those inputs change. Historical Atomic runner inputs remain historical evidence.

The exact driver rename is `scripts/check_metatheory_mutations.py` → `scripts/run_interface_mutations.py`; the harness is `scripts/test_metatheory_mutation_runner.py` → `scripts/test_interface_mutation_runner.py`; manifest `mutations/metatheory.json` → `mutations/interface.json`; namespace/path `DefiKernel.Metatheory`/`lean/DefiKernel/Metatheory` → `DefiKernel.Interface`/`lean/DefiKernel/Interface`; Audit and RunnerInput/SplitComputation roots follow that same map. Rename `discovered-metatheory-dependency` → `discovered-interface-dependency`. Preserve the imported `DefiKernel.Interleaving.RunnerDependency` fixture and its theorem untouched: it remains an imported dependency whose proof tail must survive. The scoped-module regex and exact end-namespace regex substitute only Metatheory→Interface; the forbidden proof-tail token regex and proof marker remain byte-identical. Map exact `Metatheory runtime comparisons empty`, `Metatheory runtime comparison names are duplicated`, and `Metatheory runtime comparisons failed: {count}` to their Interface counterparts, preserving numeric failure counts in both run_cmd and actual production #eval forms. Control helper functions `runnerAllows`, `runnerIncludeSensitivity`, `runner_positive` and `runner_sensitivity` stay unchanged. Runtime financial imports include only the required new runtime modules and existing execution/example definitions; do not import prior Tests/Audit or new proof-only fixture helpers into production mutation roots.

Keep schema_version1 and its one global `positive_checks` list. Freeze two global checks: `interface.positive.transfer` checks an actual F01 transfer's independent entire world/store/request/receipt and neutral actual region receipt delta, without calling balanceSum or checkBindings; `interface.positive.empty-query` checks valid F13 empty-edge acceptance. Both must survive all14 mutants. Each table row's additional protected sibling is enforced by a separate source-bound per-mutant assertion matrix over actual saved Audit output, following the M1 pattern; these row-specific requirements are not silently inserted into or claimed enforced by the global schema. Missing/false required observations reject that mutant. All actual financial comparisons execute in control; a compiler refusal earns no detection credit.

Preserve the runner's explicit `--timeout-seconds 600` default and pass that argument in each production invocation. The outer harness bounds each runner process at1500 seconds. Record UTC and measured wall time, requested bounds, partial stdout/stderr and accepted/failed/blocked result; a timed-out command is blocked, not detected, and no successful-completion timing is invented. Preserve the inherited limitation that a subprocess timeout can prevent the inner runner from emitting its normal per-command record; the outer recorder must retain the timeout classification and partial output. Empty/missing inputs, source drift, malformed evidence, failed required positives, invalid proof trimming and missing/false production observations use the actual exit contract (0 accepted,1 detection/expectation failure,3 blocked).

### 7. Proof and acceptance evidence

Discover the actual imported Interface environment, full elaborated statements and axiom dependencies, including unused axioms, generated declarations and private helper name mappings. Classify explicit generic results, concrete reference instances, counterexamples and generated constants separately. No predetermined theorem count, forbidden custom axiom, sorry or native_decide. Runtime evidence includes exact full expected observations; mutation/control evidence has actual commands, UTC, exit status, stdout/stderr, source/tool/executable hashes, before/after byte bindings and artifact manifests. Preserve any nested Git metadata as archives, not embedded repositories.

The initial missing-feature check honestly precedes implementation after the gate. Then targeted LSP, pinned builds, fresh Audit/Verify, full integrated Lean build and all accepted Python regressions. Regression carries require exact relevant source/tool dependency equivalence and honest original run identity; do not relabel an older run as fresh. Run all new14 production mutants and the complete inherited control catalog at the frozen candidate. Native Grok and Fable5.1 medium review both source and final evidence; planning review is nonauthor GPT-6 plus native Fable5.1 medium, request `claude-fable-5-1[1m]` with `--effort medium`, record the actual returned model. Unavailable/cancelled reviewers remain open. Correct material findings without an inferred revision-count cap. Review opinions and finite fixtures are not Lean proofs.

## Risks / Trade-offs

- [Dependency evidence drifts] → Recheck exact accepted source/API and delivery bindings before review or implementation; acceptance of a different source does not transfer automatically.
- [A local condition merely assumes the desired run] → Quantify actual-step obligations over arbitrary current inputs and use initialization plus trace induction; prove nonzero paired-effect/support instances.
- [Logical constraint equivalence hides changed diagnostics] → State query-success equivalence separately from exact first-error behavior; retain original indices.
- [A mutation only fails elaboration] → No detection credit; require compiled runtime, named false oracle and protected true sibling; revise a nondiscriminating site before freeze.
- [Total observations are secretly writable] → Prove ValueSupports and write exclusion, plus an actually accepted violating counterexample with a separate valid exposed-total catalog.
- [New proofs get mistaken for historical/general n-ary closure] → Preserve historical files and explicitly leave M3–M6 execution obligations open.

## Migration Plan

1. Finalize these planning inputs, accepted dependency/baseline bindings, coverage map and strict OpenSpec validation. No M2 implementation or planning acceptance is inferred.
2. Freeze this complete planning bundle with exact source/API/control closure and actual baseline run identities or verified source-equivalent carries. Obtain nonauthor GPT-6/native Fable5.1 medium verdicts on the same bytes. Resolve blockers before implementation; rerun affected baseline checks if relevant inputs change.
3. Implement the new namespace and isolated tests with stock GPT-6/LSP-first checks; preserve old source/corpus identities and existing semantic behavior.
4. Freeze a source candidate, execute all required evidence, correct findings and obtain native Grok/Fable5.1-medium source/evidence acceptance on exact bytes.
5. Archive only when every task/evidence obligation is complete and verify authorized branch delivery. No merge to main. Reversible integration rollback removes only new imports/modules and leaves historical evidence intact.
