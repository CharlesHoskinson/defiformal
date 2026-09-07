# Proposed Sprint 10: operational interface and binding preservation

Wiki-only outline for increment M2, prepared while Sprint8 acceptance and Sprint9
planning are still open. This is not an OpenSpec change, independent review,
implementation, completed theorem or accepted roadmap item. The inspected source
context is `a52fb748272fdc08f07d4ad8d2e2a06805b92dd6`; freeze against accepted source
only after the preceding dependency gates complete. Sprint9's author cannot serve
as its independent GPT-6 planning reviewer. This M2 outline needs its own complete
OpenSpec and independent planning gate before implementation.

Read together with the [remaining roadmap](../roadmap.md), the
[operational metatheory increments](operational-metatheory-planning-draft.md), and
[the Sprint9 draft](sprint-9-operational-continuation-congruence.md). The next bounded
change should be named `operational-interface-binding-preservation`. It would close
specific operational bridges for historical Interface and Nary results, while
leaving finite participant execution, causal assume-guarantee, parallel tree
simulation, active-peer extension and capability provenance open.

## Scope and dependency decision

Use the existing typed world, actual evaluated receipts, static component resource
ports, and existing sequential/shared execution. Do not add a storage model, alias
rewriter, new financial primitive, participant scheduler or transaction operator.
Historical `Defialgebra.Interface` and `Defialgebra.Nary` files remain unchanged.
Their integer functions and binding algebra are motivation and comparison points;
the new theorems must concern actual typed execution.

M2's region accounting and global constraint algebra can be reasoned about without
M1. For the next sequential implementation sprint, require accepted Sprint9 delivery
and use its proved recursive-group simulation to lift the new invariants through
actual sequential groups. This makes the planned dependency explicit instead of
silently importing a draft API. Sequential traces and existing binary Interleaving
prefixes are sufficient for this increment. Three globally named ports do not
constitute a new three-participant executor.

## Four proposed capability contracts

1. `typed-region-accounting`: exact finite same-domain/asset balance sums and their
   change under actual accepted receipts, with signed nonzero supply permitted.
2. `interface-total-preservation`: conditional preservation of a declared region
   total using explicit port confinement, shared-flow neutrality and support for
   any state-dependent declared quantity.
3. `global-binding-preservation`: globally named, typed balance-port equality
   constraints, initialization and actual-step preservation, with union and
   reorientation laws lifted to actual prefixes.
4. `interface-binding-regression-evidence`: independent funded examples, negative
   companions, actual production query mutations and inherited defensive controls,
   complete imported proof evidence and independent native acceptance.

These are proposed capabilities, not counted finalized requirements/scenarios/tasks.
The formal OpenSpec must enumerate those from its final text and map each to an
actual planned proof, runtime example or gate.

## Proposed modules and computational interfaces

Place new code in `lean/DefiKernel/Interface/`, keeping the historical namespace
separate. Proposed files:

- `Regions.lean`: a region with domain, asset and a Finset of exact typed cells;
  well-formedness states every member has that domain/asset. Define `balanceSum`
  and `receiptDelta` as finite sums over every region cell. Region membership uses
  set semantics, so repeated declarations do not duplicate a balance; repeated
  targets inside an actual receipt are fully summed before region aggregation.
- `Accounting.lean`: the generic exact-cell-to-region receipt bridge, neutral-flow
  and supported declared-total results. Use the accepted actual receipt effect
  bridge; do not premise the desired sum equation or a caller-supplied amount.
- `Bindings.lean`: resolve globally qualified resource exports from the real
  component catalog; define finite named binding edges, typed resolution and
  `Agrees`. Expose a production Boolean agreement query for concrete states with
  exact missing-endpoint/type-mismatch/inequality behavior fixed in the eventual
  design. It reports this concrete binding query only, not a general certificate,
  authority judgment or complete semantic equivalence decision.
- `Preservation.lean`: initialization and actual accepted-step obligations imply
  region/total/binding properties at every reached prefix. Derive sequential group
  corollaries through the accepted M1 simulation and existing binary shared-prefix
  corollaries through actual Interleaving reachability. Refusal and skip identity
  cases remain explicit.
- `Examples.lean`, `Tests.lean`, `Audit.lean`, `Verify.lean`: independent expected
  typed data, checked positive/negative instances, nonempty runtime observations
  and automatic theorem/supplemental discovery. Root integration is the actual
  `lean/DefiKernel.lean` import and `lake build DefiKernel.Interface.Verify DefiKernel`
  from `lean/`, after targeted checks.

All computational declarations, including predicates with executable decision
procedures, precede `-- BEGIN PROOFS`. Final names/API are frozen by the eventual
OpenSpec design after inspecting accepted M1 source; this outline is not a demand
to implement these speculative filenames before its planning gate.

## Exact accounting and declared-total proof obligations

For any well-formed finite region L and actual successful invocation result r:

```text
executeStep cfg boundary index history (.invoke inv) pre = .ok r
  ⇒ balanceSum L r.world.state
       = balanceSum L pre.state + receiptDelta L r.receipt.
```

The receipt comes from the actual successful result. First sum the exact pointwise
balance-change theorem over the Finset. This permits negative, zero and positive
region deltas and does not equate region flow with whole-asset supply. A transfer
across the region boundary changes the region sum with zero whole-asset supply.
An authorized mint inside the region has a nonzero signed receipt contribution.
Issue/revoke receipts have zero balance delta, giving separate administrative
corollaries without asserting that their stores are unchanged.

The operational counterpart of historical port confinement uses an explicit set Q
of writable shared cells. Require actual receipt writes confined to Q and neutrality
of receipt effects over `L.cells ∩ Q`. Existing actual write locality frames the
other cells; the shared-region sum is unchanged by the neutrality premise. Neither
typing nor interface validity implies neutrality. Include a nonzero transfer whose
negative and positive shared deltas cancel as the nonvacuous positive instance.

For the invariant `balanceSum L state = declaredTotal state`, there are two distinct
specializations:

- A fixed ghost quantity q: initialize `balanceSum L initial = q`, then preserve it
  under the actual neutral-flow obligations. No new on-ledger supply field exists.
- A state-dependent quantity: require explicit `Supports totalSupport declaredTotal`
  in the appropriate value-valued sense, or a proved pointwise agreement implication,
  and prove every actual write avoids totalSupport. Combined with neutral region
  flow, this preserves the equality. The exact support interface must be stated;
  reusing the predicate-only Supports API without a value-equality bridge is not
  enough. A concrete total read from a private collateral cell may instantiate it.

The typed State has no historical independent `sup` field. Do not add a shareable
bookkeeping cell and infer it is protected. The writable-total negative must use
an actual authorized transition that changes the chosen declaredTotal observation
while leaving the region sum unchanged. A denied access attempt is not such a
witness. The no-net-flow law is conditional, not a solvency theorem.

## Binding meanings and preservation

Each edge uses two stable `QualifiedPort` names. Resolve them through the real
catalog and require matching domain and asset; restrict this increment to scalar
balance resource ports. Frozen invocation output histories are a different interface
and are not silently treated as live resource aliases.

There are two distinct statements:

- Existing runtime imports identify the exact same exported cell. Catalog validity
  checks the imported/exported cell identity and access conditions. Aliasing in
  this sense is already part of the current resource model.
- A binding edge between two distinct resolved cells demands equality of their
  current balances. It is an invariant, not a new storage identity. A one-sided
  accepted write can break it; initializing equal numbers does not prevent this.

Define `Agrees catalog E state` over the complete finite global edge set E. Keep the
same catalog/resolution and edge set throughout an execution. Prove initialization
plus the actual step obligation

```text
Agrees catalog E pre.state ∧ actualStepSound pre result
  ⇒ Agrees catalog E result.world.state
```

for every selected operation entails agreement at every actual prefix. The local
obligation is quantified over current pre-state/history/boundary and permitted
operations, not merely postulated for the already desired completed run. For a
useful sufficient condition, prove equal net receipt effects at both endpoints
preserve an initialized equality. Exact-cell alias edges satisfy this directly;
distinct endpoints require explicit paired effects or a frame. Refusal/skip steps
preserve agreement by actual identity. Administrative steps preserve balances
while their authority/store changes remain governed by the existing executor.

Prove `Agrees (E ∪ F) ↔ Agrees E ∧ Agrees F`, orientation reversal, idempotence and
union associativity at predicate level. Transfer initialization and step obligations
through these equivalences, then state the resulting prefix theorem. These laws
do not regroup runtime participants or change their schedules.

Equal symmetric closures of edge sets give a sufficient equivalence criterion.
They are not necessary: E={A=B,B=C} and F=E∪{A=C} have the same equality predicate
although their symmetric closures differ. Preserve this exact counterexample;
no complete semantic equivalence checker based only on symmetric closure is in scope.

## Minimum independent financial and binding examples

Freeze exact asset/domain/cell lists and all world/store/receipt expectations in
the future OpenSpec. The following cases define the intended nontrivial content:

1. USD region {Alice,Bob}, initial (6,4), actual authorized transfer2 Alice→Bob:
   region sum10, net receipt delta0, final (4,6), with both shared effects nonzero.
2. Region {Alice} under the same transfer: sum6→4 and delta−2 while whole-asset
   supply remains0. This defeats conflating region neutrality with supply neutrality.
3. Authorized USD mint3 to Bob in the two-cell region: sum10→13, receipt delta+3.
   Exact accounting succeeds and the neutrality specialization does not apply.
4. A nonempty private declared-total/support cell has value10, region sum10;
   the shared transfer2 preserves both. A negative fixture erroneously exposes its declared-total cell as a writable
   shared export. A separately authorized write of+1 to that cell, outside the
   region and inside the permitted shared-write set, breaks equality while region
   flow stays0. The missing premise is exclusion of totalSupport from those writes. This is the operational writable-total counterexample.
5. Distinct resolved USD cells A=B=5 with an actual one-sided authorized debit1
   to a funded peer: final4 versus5 breaks Agrees. A single accepted receipt with debits1 at both A/B and credit2 at a third cell
   leaves A=B=4 and provides a nonzero preservation sibling. Two separate unequal
   intermediate updates would not establish an every-prefix binding invariant.
6. Three global port names A,B,C with A=C retained in E across the cut {A,C}|{B};
   actual steps with equal A/C effects preserve it. A cut-local edge extraction
   omits A=C and wrongly accepts a state with A≠C. This is binding-scope evidence,
   not execution by three participants.
7. Same printed amount under different asset/domain identities must not satisfy a
   well-typed edge. Missing and wrong qualified endpoint names have distinct exact
   query outcomes. A same-cell import/export alias remains valid after a real write.
8. Two edge sets with unequal symmetric closures but equal predicates because of
   transitivity, alongside a genuinely omitted independent edge that changes query
   results. Do not use the sufficient criterion as a completeness claim.
9. Accepted prefix followed by actual refusal: reached-state sums/bindings retain
   the exact successful prefix and no suffix receipt is counted. Add a nonzero-index
   M1 grouped execution instance and an ordinary binary shared-prefix instance.

## Mutation and acceptance outline

The eventual design should freeze actual source mutations of new executable
region/binding queries, not edits to imported Lean financial semantics or to proof
premises. Candidate mutation sites are: omit the last region cell, wrong receipt
sign, use only the first repeated delta, erase a nonzero mint contribution, replace
region flow with whole-asset supply, omit a binding edge, compare the wrong endpoint,
ignore asset/domain, and use a cut-local edge subset. A separate actual check must
establish that each candidate compiles and flips its independent designated oracle;
if a site cannot discriminate, revise the plan before freezing its final inventory.
Do not announce a passing or fixed mutant count from this outline.

Every neutral-transfer witness uses nonzero movement, and every broken-preservation
witness uses an actual accepted transition with the offending hypothesis absent.
Keep compiler refusals, mathematical counterexamples, financial runtime detections
and generated theorem constants separate. Adapt the final established defensive
runner control catalog with an exact old/new name map; its count and source hash
must come from accepted preceding evidence, not from a future hardcoded assumption.

Complete the bounded OpenSpec, freeze its source/API/plan bundle, obtain independent
GPT-6/native Fable planning acceptance, then use stock GPT-6 implementation with
LSP-first Lean checks and saved source/tool identities. Require full existing
regressions, all actual finalized mutations/controls, complete imported proof
statements/private-name mappings and native Grok/Fable source/evidence acceptance.
Continue targeted correction until material blockers are resolved; there is no
inferred revision-count budget that terminates the user-authorized full goal.
Only then archive and verify authorized branch delivery. No Foreman or merge to main.

## What remains after M2

M3 still needs a real finite-participant shared executor, exact binary correspondence
and initialized causal/inductive assumptions. M4 needs tree routing simulation and
compatible schedule independence. M5/M6 cover active additions and the stronger
Atomic transaction conditions. Claims/liabilities/asynchrony, capability provenance,
serialized certificate checking, corpus identities and untouched holdouts, machine
arithmetic/financial libraries, deployed differential fidelity and publication
remain the separate roadmap packages. Region/binding proofs do not discharge them.
