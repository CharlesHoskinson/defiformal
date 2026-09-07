## Context

See proposal.md for motivation. This is increment M1 of
`wiki-llm/operational-metatheory-planning-draft.md`. The inspected source context is
Sprint8 candidate `a52fb748272fdc08f07d4ad8d2e2a06805b92dd6`. Its final accepted,
archived and delivered source/evidence revision must replace this provisional
binding when the Sprint9 planning bundle freezes. Sprint8 delivery, fresh baseline,
and independent GPT-6/native Opus acceptance of that same frozen plan are required
before implementation. This author draft is not either planning audit.

`Composition.Cursor` stores the whole world, raw events, frozen outputs, absolute
nextIndex and first located failure. `Composition.advance` executes invocation,
issue and revoke; a failed cursor is inert. `continueRun` is a list fold, whereas
this change needs a genuinely recursive group interpreter and its simulation.
`Parallel.observeBranch` retains event index/step/receipt/output, history, nextIndex
and failure, but omits raw event before/after worlds. Existing Parallel,
Interleaving and Atomic operators are invocation-only and keep distinct admission,
execution and public observation contracts.

`Composition.executeStep` first validates the entire catalog. Invocation uses the
complete lookupOperation pair, registry template, actual boundary/history/world,
and receipt extraction. Issue consults the registry-derived operation domain at
`Grant.operation`; the source has no field named grant.scope. Revoke looks up a
capability in the current store and consults its domain's trusted administrator.
These paths determine the configuration hypotheses, including failures.

## Goals / Non-Goals

Goals are recursive sequential cursor simulation and associativity, exact
continuation observations with a restricted context theorem, and configuration
agreement lifted through actual existing operators. All laws retain exact refusal
reasons, requests, evaluated receipts, qualified ordered snapshots, absolute
positions and complete capability stores where those fields are observed.

M2 port/binding algebra, finite-participant execution, parallel tree regrouping,
causal monitors, active new peers, identity-universe extension, arbitrary shared
commutation, dynamic capability provenance and movement of atomic commit
boundaries remain separate changes. No new configuration certificate checker or
runtime program-admission checker is introduced. Supported-program membership and
configuration agreement are explicit propositions used by proofs. They do not
turn program names into certificates or classify malformed configurations by a
new invented runtime label.

## Decisions

### 1. Recursive groups continue the actual cursor

Create `lean/DefiKernel/Metatheory/SequentialGroups.lean` with this interface:

```lean
inductive SeqGroup (P A D : Type)
  | empty
  | step (action : Composition.Step P A D)
  | seq (first second : SeqGroup P A D)

flatten : SeqGroup P A D → List (Composition.Step P A D)
runGroup (cfg : Composition.Config P A D) (boundaries : Nat → Composition.Boundary P A D)
  (cursor : Composition.Cursor P A D) : SeqGroup P A D → Composition.Cursor P A D
```

The empty case returns cursor. A leaf calls Composition.advance once. A sequence
recursively evaluates first, binds the resulting entire cursor, then recursively
evaluates second with that cursor. It does not call Composition.run/startCursor,
flatten, or the list executor in its runtime body. Flatten is a separately
recursive enumeration used by the proof and reference correspondence.

Prove for arbitrary cfg, boundary, cursor and group, with the existing finite typed
instances:

```text
runGroup cfg boundary cursor group
  = Composition.continueRun cfg boundary cursor (flatten group).
```

Induct on the actual group constructors, using the actual first-child result in
the sequence case and the existing list continuation append theorem. This proves
full cursor equality, including raw event worlds, not only ledger equivalence.
Derive both empty identities, refusal absorption and associativity of three actual
groups. A supplied cursor may have a nonzero index, earlier events/history,
administrative store changes, or an existing failure. No success premise or
initial-cursor restriction is allowed in this simulation.

This scope admits nested administrative steps. It does not claim child groups are
transactions; the existing sequential successful prefix remains after refusal.
An alternative definition that simply invokes the old executor on flatten would
make the desired simulation definitional and leave recursive propagation untested,
so it is excluded from the production interpreter.

### 2. Observation contains the full continuation interface

Create `Metatheory/Observation.lean`. `CursorObservation` contains the current
whole world and an exact `Parallel.BranchObservation`. `observeCursor` records
these fields. Its production Boolean comparison explicitly compares pointwise
all typed ledger cells, the complete capability store, ordered event indices and
steps, invoked/admin receipts, event outputs, the full frozen output history,
absolute nextIndex and the complete optional located failure. Reuse existing
world/branch equality lemmas where useful; keep observation field comparisons in
this module so all six planned omission mutations alter actual production
comparison code. Do not replace them with test-only selector flags.

Define `CursorEquivalent c d` as pointwise full current ledger equality, complete
store equality and equality of the exact branch observation. Prove comparison
iff that proposition and reflexivity, symmetry and transitivity. World extensional
identity and proof irrelevance justify passing the same computational state into
advance. Observed event records retain exact requests, evaluated deltas/supply,
outputs and issue/revoke IDs. Only past raw event before/after worlds and proof
terms are omitted. The observer does not permit direct inspection of those
omitted diagnostic worlds. This intentionally differs from the stronger full
cursor equality established by group simulation.

Create `Metatheory/Contexts.lean` with `SeqContext.hole`, `before fixed context`
and `after context fixed`. Filling replaces one group hole; fixed nodes are the
same SeqGroup on both sides. Contexts cannot inspect a cursor, reset it, switch
configuration/boundary, add a peer or introduce an atomic commit boundary.

First prove advance and runGroup preserve CursorEquivalent for the same step or
group. Then define `GroupEquivalent cfg boundary g h` by quantifying over EVERY
pair of CursorEquivalent input cursors and requiring equivalent returned cursors.
Prove the equivalence laws and `GroupEquivalent g h → GroupEquivalent (fill C g)
(fill C h)` for this grammar. The universal input premise is needed for fixed
prefix contexts; equality from one particular entry is insufficient. A weaker
same-entry endpoint statement must not be renamed contextual equivalence. For its
negative witness, use groups with the same initially refusing first action and
different suffixes. At the original entry both observations agree; a fixed
authorized funding prefix enables that first action and exposes the different
suffix behavior. All calls use the same boundary function with sufficient exact
authority for the funding movement. Frozen
outputs, store, nextIndex and first failure are used in the advance proof rather
than reconstructed from the current ledger.

### 3. Configuration agreement is an explicit sufficient premise

Create `Metatheory/Configuration.lean` and `ConfigurationGroups.lean`. A reference
set has `calls : Set (ComponentId × OperationId)` and `operations : Set OperationId`.
SupportedStep requires both the invocation pair and invocation operation for an
invoke; requires Grant.operation for issue; revoke has no static operation
reference. SupportedGroup/List/Branch quantify over all submitted leaves, including
unreachable suffixes. Define unions and prove their support laws; none is a new
checker or runtime certificate.

`ConfigAgreement old new refs : Prop` requires:

- identical fixed types P, A and D and the same corresponding instances;
- validateCatalog old.registry old.catalog = true and the same for new;
- old.registry op = new.registry op for every op in refs.operations;
- lookupOperation old.catalog component op = lookupOperation new.catalog component op
  for every (component,op) in refs.calls, preserving the complete component/interface
  pair, including access declarations and None results;
- old.domainAdmin d = new.domainAdmin d for EVERY d.

The final premise is deliberately stronger than agreement only on issue targets:
an arbitrary starting cursor can revoke a capability whose domain comes from its
current store. Both configurations use the same complete initial world/store,
boundary function, history and indices. Full registry-template equality on issue
references is also stronger than the minimal operation-domain equality, but gives
one small sufficient relation for this increment. Both stronger choices remain
explicit in theorem statements and negative examples.

Prove actual `Composition.executeStep old boundary index history step world =
Composition.executeStep new boundary index history step world` from
ConfigAgreement and SupportedStep. Follow actual computation in order: global
validation, prepareInvocation/access/input resolution, registry evaluation,
receipt extraction and snapshots; handle every error branch. For issue, derive
equality of registryAuthorityConfig.operationDomain at grant.operation. For
revoke, use equal store lookup and domainAdmin agreement. Do not use an assumed
executeStep equality, equal successful receipts, or a whole-run equivalence as an
agreement field. Reflexivity is conditional on catalog validity; symmetry and
transitivity are agreement laws, not evidence that arbitrary additions are safe.

Induct advance/continueRun over supported lists, then use actual recursive group
simulation for group congruence. This yields exact cursor equality, including
admin receipts, next fresh IDs, tombstones and refusals. Both-valid catalogs also
make the two actual startCursor results equal.

### 4. Lift through the existing operators without changing their semantics

Create `Metatheory/OperatorLifting.lean`. On supported invocation-only left/right
branches, prove analyzeInvocation/analyzeBranch equality, hence exact Parallel,
Interleaving and Atomic admission equality with their original error precedence.
All static branch positions are covered even if execution would refuse earlier.
Compatibility, schedule counts and Atomic policy are the same on both sides;
Atomic policy lanes/participants and event label are immutable parameters.

Lift actual executeStep equality through isolated Parallel branch execution,
shared Interleaving tokens and Atomic token/attempt/receipt updates. Prove exact
existing Result equality where the runtime data permits structural equality;
otherwise use an explicit full data relation with a separate extensionality proof
that yields equality. Do not weaken to final balances or just committed outcomes.
The Atomic theorem includes admission refusal, kernel abort, lane-supply abort,
unsettled residuals and commit, preserving the supplied schedule and all diagnostic
fields. No operator gets a new admission rule or certificate wrapper.

A direct induction over existing operator machines is bounded and preserves their
contracts. Translating all operators into a new general syntax would add another
semantics and an unnecessary correspondence obligation, so it is excluded.

### 5. Independent examples and negative companions

Create `Metatheory/Examples.lean`, `Tests.lean`, `Audit.lean` and `Verify.lean`.
Reuse existing typed financial templates as inputs but construct expected worlds,
complete stores, requests/receipts, snapshots and failures independently. Tests
must not compute expected values by calling runGroup, flatten/continueRun, or the
new comparator. Generic simulation comparisons are useful additional checks, not
the only financial oracle.

The main sequential fixture starts Alice USD10/Bob0/Carol0. Its first nonempty
leaf transfers7 from Alice to Bob and exports Alice's post-balance3. The second
uses that exact qualified prior output to transfer3 from Alice to Carol, leaving
Alice0/Bob7/Carol3. The third transfers1 from Bob to Alice, leaving
Alice1/Bob6/Carol3. The trusted boundary selects Alice at absolute positions0/1
and Bob at2; the fixture supplies exact valid rights. Independently construct all
three intermediate and final worlds and ordered receipts/snapshots. Include a
separate transfer7 followed by refused transfer6 retaining Alice3/Bob7; its funded
suffix would otherwise move funds. An administrative fixture
issues a capability in one group, invokes it in the next, revokes it in another,
then observes exact denied use and an inert suffix. Start another fixture with
existing store entries and nextIndex nonzero to test fresh-ID/index continuation.
Index-dependent boundaries vary actor and time at known absolute slots; expected
results bind those exact slots.

Configuration positive: a fresh operation/component outside the finite support is
added, both catalogs validate, old component/interface/registry values and admins
remain equal, and a nonempty old program including issue/invoke/revoke has identical
actual execution. Invocation-only Parallel, Interleaving and Atomic siblings use
fixed identical boundaries/schedule/policy and include success and actual refusal
or abort. Empty programs alone do not satisfy this evidence obligation.

Named negative companions establish omitted premises independently: changed old
registry behavior; changed old component access/output declaration; newly invalid
or duplicate catalog entry causing exact configuration refusal; grant-only
operation domain changed while invoked-operation lookups agree; changed trusted
admin changing issue/revoke authorization; an extra initial capability changing
issued ID despite equal ledger. These are actual old/new execution differences,
not an expected compilation failure or a fake agreement-checker status. Witness
both validity results where the omitted premise is not catalog validity.

Observation counterexamples use equal-ledger cursors with different frozen outputs,
indices or stores and a continuation that produces an actual different result.
Also compare a pair differing only in a past raw event world: the selected observer
intentionally equates them, and the restricted continuation remains equivalent.
A swap of shared withdrawals7 and 6 from USD10 and an explicit one-transaction vs
two-boundary rollback example delimit associativity's scope; no general atomic or
parallel reassociation claim is inferred.

### 6. Fourteen actual mutations and 65 defensive controls

Use `scripts/check_metatheory_mutations.py`,
`scripts/test_metatheory_mutation_runner.py` and `mutations/metatheory.json`, adapting
the accepted Atomic runner's explicit recursive local source discovery and strict
runtime/proof boundary parser. Production mutation targets are ONLY the new
SequentialGroups/Observation runtime definitions. Imported kernel source stays
byte-identical. Every mutation must compile, change exactly one intended source
site, make its designated independent comparison false, and preserve declared
nonempty positive comparisons. A compiler error earns no financial detection.

| ID | Actual mutation | Designated independent oracle | Protected positive |
| --- | --- | --- | --- |
| M01 | At seq, pass entry world to second child | `metatheory.group.world-chain`: transfer7 then funded continuation retains exact intermediate world | single nonempty leaf |
| M02 | At seq, restore entry capability store | `metatheory.group.store-chain`: issued grant remains usable with exact fresh ID | store-independent nonempty transfer |
| M03 | At seq, reset frozen output history | `metatheory.group.history-chain`: consumer uses first child's exact snapshot | literal-input nonempty sequence |
| M04 | At seq, reset nextIndex to entry index | `metatheory.group.index-chain`: nonzero absolute indices and qualified previous output | single nonempty leaf |
| M05 | At seq, clear first failure | `metatheory.group.refusal-absorption`: funded suffix stays inert after exact middle refusal | successful nonempty sequence |
| M06 | Skip the second child | `metatheory.group.child-executed`: second funded movement appears with exact receipt/world | single nonempty leaf |
| M07 | Reverse child order | `metatheory.group.ordered`: asymmetric movements/producer-consumer result | single nonempty leaf |
| M08 | Leaf always uses boundary position0 | `metatheory.group.boundary-index`: distinct absolute actor/time yields exact authorization | nonempty index-insensitive boundary sibling |
| M09 | Omit current ledger from cursor comparison | `metatheory.observe.world-diff`: same other fields, changed protected cell must differ | equal nonempty cursor |
| M10 | Omit complete store from comparison | `metatheory.observe.store-diff`: ledger same, tombstone/entry differs | equal nonempty cursor |
| M11 | Omit frozen history comparison | `metatheory.observe.output-diff`: same events, differing qualified history | equal nonempty cursor |
| M12 | Omit failure comparison | `metatheory.observe.failure-diff`: exact reason/location/step differs | equal nonempty cursor |
| M13 | Omit event receipt comparison | `metatheory.observe.receipt-diff`: same remaining fields, evaluated receipt differs | equal nonempty cursor |
| M14 | Omit nextIndex comparison | `metatheory.observe.next-index-diff`: same other fields, absolute position differs | equal nonempty cursor |

M09–M14 are production observation sensitivity checks; classify them separately
from the eight executor-routing mutations. Include changed/equal pairs for every
subfield beyond the single required mutant site, including event outputs, step,
receipt request/evaluated values and failure step=None versus Some.

The required 65 controls are the actual `cases()` inventory in the updated
`test_atomic_mutation_runner.py`, inspected as 65 after its two production audit
output controls were added. This current working-source inspection is not yet a
claim of final Sprint8 acceptance. Adapt module roots, fixtures and labels to
Metatheory, including renaming the discovered Atomic dependency control. Retain
all 11 proof-tail parser controls and both production `#eval`/`IO.userError` forms.
Capture the exact name map/count and accepted source hash at implementation
freeze; do not silently drop a control. Expected classifications remain valid/violated/blocked,
with exit0/1/3 at the underlying runner. Malformed/partial/empty inventories,
compiler-only failures, dirty/staged/drifting inputs, symlinks and runtime code
hidden after the proof marker remain blocked. Mutant compiler failures and these
runner-defense tests are separate from financial detections.

### 7. Evidence and integration

Every new executable declaration, syntax/macro/initialization block precedes its
file's `-- BEGIN PROOFS` marker. Proof-only definitions that are executable must
also precede it; the projection cannot quietly discard supporting runtime code.
Root `lean/DefiKernel.lean` gains the new Verify import after targeted checks.
No historical namespace or theorem is rewritten. No dependency upgrade is planned.

Use LSP first and pinned Lake from `lean/`; literal installed Lean4 skill runtime,
no sorry/custom axioms/native_decide. Fresh full Lean and prior Python regressions,
14 real mutations and 65 controls need nonempty inventories and exact source/tool/
Git/log/artifact bindings. Scan imported Metatheory theorems and supplemental
declarations mechanically, preserve full pp.proofs statements/private helpers,
and classify generic proofs, concrete instances, counterexamples, generated
constants, runtime observations and compiler controls separately.

## Risks / Trade-offs

- [Ledger-only equivalence loses continuation inputs] → Include full store, ordered
  histories, nextIndex and first failure; prove actual advance preservation.
- [Raw event world omission mistaken for full abstraction] → Restrict the observer
  and context grammar explicitly; group associativity separately proves full cursor equality.
- [Static support misses issue-only registry dependencies] → Collect Grant.operation;
  use a real grant-only operation-domain counterexample.
- [Global validation changes unrelated old execution] → Require both catalogs valid;
  preserve a named invalid-extension refusal witness.
- [Administrative result IDs depend on initial store] → Require the whole same world;
  demonstrate equal-ledger/different-store issue-ID failure.
- [Scope grows into later metatheory] → Only binary sequential syntax and existing
  operator configuration lifting; no new peers, participant types or commit boundaries.
- [Mutation projection or expected values mask an error] → Freeze actual source sites,
  independent full financial expectations, positive siblings and all defensive controls.

## Migration Plan

1. Finish accepted Sprint8 delivery, refresh source context, freeze this complete
   plan and obtain independent GPT-6/native Opus planning verdicts on identical bytes.
2. Capture a fresh baseline and protected source/tool manifest; implement only new
   Metatheory modules, with targeted proof/runtime checks before root integration.
3. Freeze implementation/spec/runner source, execute complete new and prior evidence,
   obtain native Grok/Opus substantive-result and evidence reviews, and address
   concrete blockers through targeted revisions until resolved.
4. Archive OpenSpec only after acceptance, reconcile source/evidence manifests and
   push the user-authorized branch with remote verification. No merge to main.
   Rollback before delivery removes only the new import/modules in a reviewed
   revision; retain failed review/mutation artifacts and historical accepted bytes.

Reviewer binding follows the 2026-09-07 user override in `AGENTS.md`: future
planning uses nonauthor GPT-6 plus native Opus; substantive source/evidence
reviews use native Grok plus native Opus. Request `opus`, record the actual
returned model identity, and keep unavailable reviews open. Historical Fable
reports and accepted historical plan bytes retain their original identity.
