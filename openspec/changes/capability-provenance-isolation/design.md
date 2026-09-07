## Context

This is an author draft for a later package, not implementation or planning acceptance. Read the proposal for motivation. Exact source and held-review bindings are in `review/semantic-kernel/capability-provenance/planning/author-draft/protected-before.json`. It includes the 88 Sprint10 R2 inputs and 93 corpus official-r1 inputs; neither plan is silently advanced by this draft.

The implemented basis is:

- `Typed/Authority.lean`: entries are permanent list-position IDs. `issueCapability` checks trusted administrator, registry-derived operation domain, then right-resource domain; it appends a live entry. `revokeCapability` first resolves the ID, checks its stored domain's administrator, then sets only `live := false`. `authorizesId` checks current lookup, live, holder, domain, operation, exact right and resource domain. Rights are nondelegating and have no component-ID field.
- `Composition/Execution.lean`: `executeStep` first validates the catalog and delegates issue/revoke to those actual functions with `pre.capabilities`; invocation uses `Typed.execute` and re-evaluates the receipt at the same pre-world. `StepSound` carries those actual equations. `ReceiptAuthorized` and `StepSound.authorized` already characterize accepted invoke/debit/supply authority in the pre-world.
- `Composition/Sequence.lean`: `run` starts at `startCursor`, records only successful events, and halts on the first failure. `run_trace_sound` supplies the initialized actual prefix. A rejected step preserves world/events/outputs/index, while adding an exact located failure; it is not whole-cursor identity.
- `Composition/Contracts.lean`: existing `Supports` is ledger-only and explicitly excludes capability-store reads. `Interfaces.lean` permits private/export/import reads, restricts writes with writable flags, and allows an owner's output port to snapshot its own private cell. `resolveSource` can pass that published value to a later consumer without a resource import. Direct private-cell exclusion is not confidentiality of output/history.
- `Parallel/Compatibility.lean`: a branch is `List Invocation`. Parallel and interleaving have fixed initial capability stores; `Parallel.trace_invoke_stores` and `Interleaving.runPrefix_store` are relevant existing facts. Atomic execution uses these invocation-only participants. No concurrent administrative allocator or transactional capability store exists.

The existing root graph navigation resolved historical authority-scan nodes rather than these APIs. It supplies no theorem or freshness claim; actual Lean sources govern this design. No external models or graph rebuild are required.

## Goals / Non-Goals

**Goals:** Initialized causal authority provenance for every actual sequential prefix, exact tombstones and current-store witnesses, and explicit supported world-observation frames. Read-only query soundness must connect to real execution. Concrete funded examples and negative companions must make every trust/support premise inspectable.

**Non-goals:** Authentication or truth of the trusted administrator/registry/environment; legitimacy of trusted initial grants; delegation, allowances, consumption, replay protection, key management, process memory isolation, timing/resource side channels, confidentiality of global event worlds or published snapshots, automatic support inference, deployed fidelity or generic solvency. Concurrent issue/revoke, collision-free distributed allocation and atomic administration remain explicit later gaps. This package closes a bounded portion of the composition roadmap, not general operation-wide noninterference.

## Decisions

### 1. Lift actual initialized traces without replacing the executor

Alternatives considered: (A) proof-only lift of actual traces; (B) lift plus small read-only provenance/observation queries; (C) introduce concurrent administrative execution. Choose B: it keeps the trusted execution relation and gives finite observable targets. A leaves little new executable evidence; C requires new concurrency semantics and allocation/rollback rules outside this scope.

New modules are planned under `DefiKernel.CapabilityProvenance`: `Origins`, `Trace`, `Observation`, `Isolation`, `Examples`, `Tests`, `Audit`, `Verify`. Names are proposed API commitments, not existing declarations. `Trace`, `Isolation` proofs may import existing metatheory and operator preservation. Runtime imports must avoid old Tests/Acceptance and proof-only fixtures. Add only a dedicated Verify root import when implementation is accepted.

Use `Composition.TraceSound cfg boundaries initial events final history index` as the induction relation. A step-list theorem instantiates it with `run_trace_sound`; arbitrary-entry continuation theorems require an existing initialized trace witness. An arbitrary caller-supplied `Cursor` is not initialized simply because its fields parse.

Let `TrustedRoot : CapabilityId → Grant P A D → Prop` be an explicitly supplied root policy. Define `RootsAccepted TrustedRoot initialStore` by every successful initial lookup satisfying that policy on its complete grant. Both initially live and initially dead entries need this premise if a conclusion is advertised for all entries. The empty store has a proved trivial instance; a nonempty fixture has an explicit finite proof. Do not define the policy as “everything in the final store is trusted,” assume the final theorem as an invariant premise, or infer initial authenticity from well-formedness.

For every final `lookup id = some cap`, the theorem yields either:

1. `initial.capabilities.lookup id = some rootCap`, `cap.toGrant = rootCap.toGrant`, and `TrustedRoot id rootCap.toGrant`; or
2. a causally preceding actual successful event `.issue grant` with `.issued id`, actual `issueCapability cfg.authority (boundaries event.index).ctx event.before.capabilities grant = .ok (id, issuedStore)`, and `cap.toGrant = grant`.

In case 2 include the successful administrator/domain/right conditions extracted from the actual issue equation. The event's preceding history comes from `TraceSound`, not a freely fabricated event membership hypothesis. Prove `OriginAt` completeness and unique origin/index using fresh append allocation; equality concerns the immutable Grant fields, while live status can change by revocation.

### 2. Prove lifetime facts and current-use provenance together

By induction on `TraceSound.snoc`, use issue freshness/other-entry preservation, revoke tombstone/other-entry preservation, and invocation store preservation. Required generic conclusions:

- final length equals initial length plus the number of successful issue events, counting duplicate equal grants as separate issues;
- initial IDs and all previously allocated IDs remain allocated with their original holder/domain/operation/right;
- successful issue IDs are distinct, never reuse tombstones and equal the actual pre-event length;
- an initially dead entry or an entry successfully revoked at a prefix stays dead through every actual extension;
- an accepted invocation has exact current pre-store authority for invoke, every negative aggregate cell effect and every nonzero supply change, and each witnessing ID has the initialized origin above.

The debit condition is the existing aggregate negative effect, not every individual syntactic delta. Capability use is reusable and duplicate request IDs add no rights. No “one-shot” or gross-debit semantics are introduced. `claimedActor` never replaces the trusted boundary principal. Cross-domain administration fails according to existing precedence; a revoke of an unknown ID reports unknownCapability before an administrator check.

Lift lifetime facts to every successful prefix and each event's actual before/post stores. Rejected administration has no new entry/event/output and does not consume an ID. Only the cursor failure field changes at first rejection; suffixes are inert. Validating a catalog remains prior to even administrative execution.

### 3. Read-only executable origin queries are observations, not certificates

`Origin` has `.initial grant` and `.issued eventIndex grant`. `issuedOrigin events id` recursively scans events in order, accepting only matching `.issue grant` / `.issued issuedId` pairs with `issuedId = id`. `originOf initial events id` first checks the initial lookup, otherwise calls that scan. This total query can be invoked on arbitrary data, but its soundness theorem requires the initialized actual trace; an artificial event list is a negative companion, never accepted evidence.

`currentAuthorityOrigin initial cursor ctx operation right ids` selects the first requested ID for which `Typed.authorizesId cursor.world.capabilities ctx operation right id` is true and pairs it with `originOf initial cursor.events id`. Its result is optional: absence of current authority or an origin yields none. Soundness/completeness on actual initialized cursors relates it to current authority and causal origin. It does not authenticate `ctx`; trusted boundary applicability is a separate invocation theorem.

A public `auditRun` adapter calls `Composition.run` once and returns the actual cursor plus its requested origin/authority readbacks. It must not normalize input stores, replay events against an initial store, replace failures, modify grants or create a second executor. The runtime contract is exact delegation; proofs and full-raw observation fixtures establish this. The mutation suite below targets new readback/query behavior, not historical authority guard implementations. Existing authority mutation evidence remains separate regression evidence.

### 4. Support includes store and allocation observations explicitly

Define `SupportPolicy` with finite ordered lists `cells`, `capabilityIds`, and `observeNextId : Bool`. A protected ID may currently be absent; lookup-none is part of the observation. Repeated list entries are preserved, not silently deduplicated. `WorldAgrees policy pre post` means:

- equal balances at every selected cell;
- exact `Option Capability` lookup equality at every selected ID, including the complete grant and live bit;
- equal `nextId` when `observeNextId = true`.

Define `SupportsObservation policy observer` as a value-valued property: this agreement implies `observer pre = observer post`. The observer is fixed before comparing worlds. Provide concrete supported projections and predicate corollaries. Do not assume support from a denied-write test, inspect arbitrary Lean closures automatically, or reuse ledger-only Supports for a world/store predicate.

The executable `observeWorld` returns all ordered `(cell,balance)` pairs, `(id,lookup)` pairs and `some nextId` or `none` according to the policy. `capEq` separately compares holder, domain, operation, right and live; option and list comparison preserve constructor, ID, order and length. `viewEq` compares the complete selected ledger list, selected-store list and optional allocation value. Prove its iff with exact projected equality and the observation's support property.

For an actual trace, sufficient frame premises are: every selected ledger cell is outside each accepted receipt's writes; every successful issued/revoked ID is outside `policy.capabilityIds`; and, if nextId is observed, no successful issue occurs. These are explicit actual-effect premises, not “the other component seems unrelated.” An issue of a formerly absent selected ID violates the premise. Revocation is ledger-neutral but can change a supported capability observation. Derive the world frame and supported-observer preservation by initialized induction; a concrete finite instance must discharge the premises without assuming the desired final observation equality.

### 5. Component access and disclosure have separate statements

For a validated catalog, two distinct registered components and a cell private to one, prove that the other component's `canRead` and `canWrite` are both false. Use global private-cell uniqueness and export/import exclusions. For an actual accepted invocation of the other component, derive private ledger locality through the selected component's write guarantee. Extend to actual traces whose invocations all select such peer components; administration changes no ledger but requires the separate store frame premises above.

The positive isolation statement is supported-observation invariance under those actual effects. It is not equality of all runtime receipts, failure reasons or histories. A read-only imported shared balance may control a guard, quantity or output while never being written. An owner may explicitly publish an output snapshot of its private balance; a peer can consume that typed historical output. Include both counterexamples. Future confidentiality work needs a separate disclosure/history/environment/termination policy and a relational execution theorem. Store equality, not just ledger support, is also required when observations read authority.

### 6. Operator applicability stays exact

Mixed administration is proved only for sequential `Composition.run` and accepted sequential grouping via `Metatheory.runGroup_eq_continueRun` starting from an initialized cursor. Invocation-only parallel/interleaving corollaries may carry a trusted-root provenance property because stores remain the initial one; they do not manufacture issue-event origins. Any Atomic corollary must be restricted to its existing invocation-only fixed-store semantics and separately state abort/publication behavior; no Atomic extension is required here. Record concurrent allocation, cross-branch issuance visibility, administrative rollback and ID reservation as unsolved later design requirements.

## Finite fixtures and negative companions

All fixture IDs below are required planned cases, not current results. Use a finite world with at least two domains, three principals, two operation IDs and two assets. Successful transfers use positive rational amounts and independently computed complete balances. Build trusted stores through actual issue where testing administration; directly constructed stores occur only in explicitly named trusted-initial or forged/uninitialized cases. Every test compares actual execution to independent expected data. Runtimes are not theorem substitutes.

| ID | Concrete obligation and discriminator |
|---|---|
| F01 | Nonempty trusted initial store, funded transfer and initial-origin query; explicitly prove root policy for every initial entry, including an initial tombstone. |
| F02 | Empty-root issue/use: actual admin issues invoke/debit rights, funded invocation succeeds, every new entry names the actual issue index and full grant. |
| F03 | Issue exact holder/domain/operation/debit and supply rights in two domains; ensure complete scope and authorized nonzero issuance observations. |
| F04 | Mix issue, successful invocation, issue; origin index is absolute successful event index, not issue ordinal. |
| F05 | Revoke then reissue the same grant: old ID remains dead, new ID equals old length, scopes retained and length increases exactly once. |
| F06 | Successful funded prefix followed by unauthorized issue or revoke: exact authority failure, complete prefix retained, no allocation/event/output increment; supplied suffix inert. |
| F07 | Bad catalog, unknown revoke ID, unauthorized administrator, wrong operation domain and wrong resource domain exercise actual rejection precedence with otherwise valid siblings. |
| F08 | Actual issue/use/revoke/use-old-ID run fails at the final use with current tombstone. A separate run from the pre-failure checkpoint reissues and uses the fresh ID successfully; never resume a halted cursor as if live. |
| F09 | Requested IDs contain absent, dead and wrongly scoped entries before a valid one; query returns the first genuinely authorized current ID. Duplicate valid IDs add no authority. |
| F10 | Accepted negative debit and nonzero supply actions have origin witnesses; paired effects with zero aggregate debit use existing net-effect semantics rather than a new consumption rule. |
| F11 | Constructed initial live capability permits a funded call under existing execution without any issue history; this refutes unconditional administrator provenance without a trusted-root premise. |
| F12 | Two funded worlds differ only in a read-only imported balance; no write targets that cell, but guard outcome or emitted snapshot differs. Compare exact outcome/failure and output values. |
| F13 | Nonempty ledger/store policy survives a funded peer transfer and an issue of an unselected ID when allocation length is hidden; actual noninterference premises are independently established. |
| F14 | Empty selected-ID list still sees allocation when observeNextId=true: a real successful issue changes the view. With the flag false and equal selected ledger cells, views match. |
| F15 | Revoke a selected live ID: ledger unchanged but the complete supported store view changes. A revoke of an unselected ID is the positive sibling. |
| F16 | Valid distinct components reject direct peer-private read and write attempts. Separately, owner publication of a private output followed by peer priorOutput use succeeds, showing the disclosure boundary. |
| F17 | Synthetic view pairs differ only in holder/domain/operation/right/live, ledger balance, nextId, absent-vs-present lookup, list ID/order/length. These test the observer, not real unauthorized execution. |
| F18 | Forged event list claims an issue that was not executed; raw origin query can read the claim, but no initialized trace witness is asserted. Exact auditRun output remains actual. |
| F19 | Invocation-only parallel and complete interleaving schedules preserve the trusted initial store and lookup origins; no concurrent administration is injected into those branch types. |
| F20 | Initialized sequential grouping agrees with the flat run for issue/use/revoke and refusal prefixes, retaining raw worlds, events, outputs, nextIndex and exact failure. |

`capability.positive.funded-peer` is a real nonempty transfer with independent full cursor expectation. `capability.positive.initial-origin` is a nonempty unchanged-root origin readback. The first is protected under every query/observer mutant; per-mutant additional siblings exercise the affected query on unaffected inputs. They are supplemental applicability evidence, not a diagonal fault classifier. Do not require both globals for a mutant deliberately deleting initial origins.

## Mutation and control contract

Fourteen required source edits target actual new runtime declarations after source freeze. These planned descriptions do not claim present compile-valid needles. Before implementation evidence, bind exact once-only needles/replacements to the real source; any change to their meaning requires focused plan review. All variants must compile, execute the full unique inventory, make their designated true comparison false and retain the funded-peer positive. Competing false labels must be recorded in full; detection is not unique fault identification.

| Mutant | New production runtime fault | Designated test | Positive sibling |
|---|---|---|---|
| M01 | originOf returns none for a present initial entry | capability.origin.initial (F01) | issued-origin query (F02) |
| M02 | issuedOrigin emits initial-kind origin for an actual issue | capability.origin.issued-kind (F02) | initial-origin query (F01) |
| M03 | issuedOrigin accepts a nonmatching issued ID | capability.origin.exact-id (F02, two distinct issues) | initial-origin query (F01) |
| M04 | issuedOrigin replaces the complete grant right with invoke | capability.origin.exact-right (F03 debit/supply) | initial-origin query (F01) |
| M05 | issuedOrigin reports event index plus one | capability.origin.absolute-index (F04) | initial-origin query (F01) |
| M06 | currentAuthorityOrigin checks the initial store | capability.authority.current-store (F08) | live unchanged-root query (F01) |
| M07 | currentAuthorityOrigin takes the first supplied ID without authorization filtering | capability.authority.valid-id (F09) | singleton valid current ID (F01) |
| M08 | viewEq omits complete selected-ledger comparison | capability.observe.ledger (F17) | independently equal nonempty view |
| M09 | viewEq omits optional nextId comparison | capability.observe.next-id (F14/F17) | independently equal nonempty view |
| M10 | capEq omits holder equality | capability.observe.holder (F17) | independently equal nonempty view |
| M11 | capEq omits domain equality | capability.observe.domain (F17) | independently equal nonempty view |
| M12 | capEq omits operation equality | capability.observe.operation (F17) | independently equal nonempty view |
| M13 | capEq omits right equality | capability.observe.right (F17) | independently equal nonempty view |
| M14 | capEq omits live equality | capability.observe.live (F15/F17) | independently equal nonempty view |

M01–M07 measure provenance/current-use query sensitivity; M08–M14 measure selected-view comparison sensitivity. They do not newly mutate or certify every old Typed authority guard. Rerun the actual existing typed authority and all accepted dependency regression suites against exactly bound inputs. No fixture expectation, theorem premise or protected positive may be weakened to manufacture detection. No new executor exists to mutate.

Adapt the accepted current Metatheory driver/harness through a separately enumerated literal map, with all 65 actual inherited CLI controls and their classifications retained. Preserve the production `#eval main` numeric failure-count protocol and the fixed `lean_log_path` behavior. Run proof-free mutation projections only for the new namespace, capture the entire local import closure, retain runtime declarations and all imported historical proofs, and reject missing/empty/duplicate/incomplete inventory, ambiguous edits, output overlap and source drift. Exit 0 means valid control, 1 explicit semantic false, 3 blocked; compile or transport failure is not detection. Use explicit production timeout 600 seconds, harness default 600 and outer timeout 1500 unless a recorded actual dependency limit requires independently reviewed revision.

The complete financial oracle compares every finite ledger cell, the entire capability store, each event's index/step/raw before world/raw result world/receipt/outputs, cursor output history, nextIndex and exact located failure. Existing Metatheory cursorEq omits past raw event worlds and is insufficient alone. Supported-view tests separately compare exactly the policy projection; equality of that projection is never advertised as full cursor equality. Keep synthetic comparison controls distinct from funded runtime fixtures and generic proofs.

## Risks / Trade-offs

- Trust laundering through a nonempty starting store → require an explicit root policy and retain F11; sound execution is not authentication.
- An origin reconstructed from forged events → theorem requires initialized actual TraceSound; F18 and exact auditRun delegation make the boundary observable.
- Confusing permission/locality with secrecy → prove direct private read exclusion, disclose owner output publication, and retain F12/F16; full confidentiality remains later work.
- Missing store or global length dependencies → support includes exact lookup and optional nextId; F14/F15 refute ledger-only framing.
- Proof-only success or self-referential expected data → separately initialize/discharge concrete premises and compare raw runtime fields to independent finite tables.
- Accidental changes to accepted packages → source manifests, unchanged old inputs, separate namespace, exact before/after Git/SHA checks and fresh output directories.

## Migration Plan

First freeze this draft and source applicability, then obtain independent nonauthor GPT-6 and native Fable 5.1 medium planning acceptance. Request `claude-fable-5-1[1m] --effort medium` and record actual returned identity; unavailable or tool-only responses remain open. Stock GPT-6 implements after the gate. Native Grok and Fable independently review substantive source and final evidence at exact bound candidates. No Foreman.

Implement runtime queries and proof modules additively, then finite fixtures and runner adaptation. Freeze all required source/spec/driver inputs before official runs. Retain failed attempts, full raw logs, exact commands, UTC and actual timing scope. Record theorem/definition inventory over the actual imported closure with zero forbidden dependencies; finite tests, generic proofs, counterexamples, compiler controls, mutations and native advice have separate categories. Capture an immutable original scenario map and later overlays. Only after source/evidence acceptance and verified delivery may tasks or roadmap claims be marked complete. No canonical corpus or historical review artifact is changed by this package.
