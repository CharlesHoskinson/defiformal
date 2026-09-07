## Context

This is a provisional M3 author draft, with no implementation or independent planning verdict. The accepted M1 source is `eec499d613688137a341f3556cd80ca461dd2ee9`; the S10/M2 candidate is planning-only `4d42600082d4213d34ac5ab4b0dfc3eefde23d5e`. Accepted and delivered M2 is a prerequisite to freezing this change. Its exact future declarations are not asserted to exist.

Current reusable computation is `Parallel.analyzeBranch`, `Composition.executeStep`, and `Interleaving.LocalState`, `advance`, `continueRun`, and `runPrefix`. Existing proof templates are `Interleaving.AdvanceSound`, `Reachable`, local-order lemmas and initialized `runPrefix_two_invariants`. `Metatheory.runGroup_eq_continueRun` establishes sequential group execution; it does not implement a participant tree. Historical `Defialgebra.Nary` is algebraic evidence, not this operational theorem.

A read-only graph query `nary interface composition invariant` returned historical positive-program nodes, including binding union associativity. Those edges do not establish current kernel dependencies. Source inspection and the M3/M4 split in `wiki-llm/operational-metatheory-planning-draft.md` govern this design.

## Goals / Non-Goals

**Goals:** One actual finite shared-state dispatcher, precise correspondence with the binary operator, initialized simultaneous preservation, and a causal monitor whose facts come from actual prefix execution. Prove continuation chunking on the full machine, including raw event worlds and global attempt order.

**Non-Goals:** Participant-tree routing and regrouping, equality across distinct schedules, active roster extension, mutable configuration, dynamic capability issue/revoke, allocation races, Atomic rollback/settlement generalization, recursive groups of participants and deployment fidelity. These are not consequences of list append associativity. M4 must supply an independent tree dispatcher and its own simulation; compatible-schedule results may project away order-dependent intermediate worlds, unlike the exact fixed-schedule correspondence here.

## Decisions

### D1. Explicit finite roster and deterministic full admission

Proposed `Roster B` contains `order : List B`, a `Nodup` proof and `∀ b, b ∈ order`. Require `DecidableEq B`; runtime never enumerates a Finset through noncomputable `toList`. The roster is a typed parameter contract, not a new malformed-roster checker. An empty roster is constructible only for an empty participant type. Participant identity identifies an invocation stream, not the authenticated ledger principal. The same type universes and equality/finite instances are shared across all compared executions.

Proposed `Branches B P A D := B → Parallel.Branch P A D`, `Boundaries := B → Nat → Boundary P A D`, and `Schedule B := List B`. Boundaries use each selected stream's absolute successful index. Configuration, branches, roster and boundary function are fixed during a run.

`checkSchedule` traverses `roster.order`, reports the first participant with a differing occurrence count, and returns its expected branch length and observed token count. `Complete` is `∀ b, schedule.count b = (branches b).length`. Admission checks catalog validity first, analyzes **all full branches** in roster order with `Parallel.analyzeBranch cfg (boundaries b)`, then checks counts. Its errors are configuration, structural participant plus existing `LocalFailure`, or count mismatch. Its successful value is the ordered list of participant/footprint pairs; no arbitrary default footprint is needed. No compatibility check rejects overlapping reads or writes. An unreachable malformed suffix still precedes a schedule error.

### D2. Actual shared execution, no replay substitute

Proposed `Machine` holds one `Composition.World`, `locals : B → Interleaving.LocalState`, and a list of new participant-indexed attempts with exactly the existing attempt fields. `start` has empty locals and attempts. `advance cfg boundaries branches m b` reads the selected local state:

1. Existing failure or unavailable `branches b[consumed]?` consumes one slot; it changes neither world, events, outputs, nextIndex, failure nor global attempts.
2. Otherwise call actual `Composition.executeStep cfg (boundaries b nextIndex) nextIndex outputs (.invoke inv) m.world` exactly once.
3. Error consumes one slot, retains first exact located failure and appends an actual error attempt at the current world. It changes no balances, store, successful events, outputs or nextIndex.
4. Success consumes one slot, appends the exact event and outputs, increments nextIndex, publishes exactly the returned world and appends the successful attempt. Every unselected local state is unchanged.

`continueRun` is the fold of this dispatcher from an arbitrary supplied machine. `runPrefix` starts empty local histories at the supplied world, without admission; it accepts arbitrary prefixes, including overlong schedules. `runNary` performs admission and retains the supplied schedule in both result constructors. Admission refusal retains the entire entry world and creates no machine or attempt. Public successful admission implies counts complete; financial refusals remain inside the executed machine and do not stop peers.

`AdvanceSound` carries actual selection and actual execution equations in all four cases. `Reachable` starts at `start` and is closed under that dispatcher. Derive own-stream event/history provenance, successful indices, consumed counts, first-failure retention, actual attempt order, fixed capability store, nonnegative balances, exact signed receipt accounting and analyzed write frames from those equations. A theorem about an arbitrary entry machine uses an explicit entry invariant/history premise; genesis-only trace soundness is not silently reused.

### D3. Exact binary and continuation laws

Specialize B to the existing `Parallel.BranchId`, ordered `[left,right]`. Define explicit conversions of machines, attempts and results; all locals, consumed counters, raw event before/after worlds, evaluated receipts, outputs, located failures, global attempts and schedule are retained. For schedule errors the binary projection recomputes **both** expected/observed counts from the original branches and schedule; the n-ary first mismatch alone lacks that information. Prove static admission correspondence in the same order, then start/advance/arbitrary-machine continuation/runPrefix/runNary correspondence. Runtime equality on examples is not the general proof.

Prove `continueRun m (s ++ t) = continueRun (continueRun m s) t` and the induced three-chunk associativity, with no success, disjointness or completeness assumption. A populated arbitrary-entry fixture must include an existing history, nonzero consumed/nextIndex and an already failed peer. This does not reorder tokens, reset histories, or prove participant-group associativity.

A new complete finite observation checker is for evidence only: pointwise full world balances plus exact capability store; for every roster participant, consumed, nextIndex, failure, outputs and all event fields including raw worlds; and every global attempt's participant, index, invocation, before world and full error/success outcome. Successful outcomes include world, evaluated receipt and outputs. Require equivalence to exact machine equality using function extensionality/proof irrelevance. Reusing the old canonical branch comparator alone would omit raw worlds and consumed counts. Finite P/A/D instances are needed by this Boolean checker, not by roster uniqueness itself.

### D4. Initialized finite interference

For each participant i, fix ledger predicate Iᵢ and ledger relations Gᵢ and Rᵢ. Require every Iᵢ at entry. The local obligation quantifies selected branch invocation/index, arbitrary own history/current world and an **actual executeStep = .ok result equation**; Iᵢ(pre) implies Iᵢ(post) and Gᵢ(pre,post). The selection condition is at the own successful index justified by reachable active local order. For all i≠j require Gᵢ ⊆ Rⱼ, and require stability of Iⱼ under Rⱼ. Prove all invariants simultaneously by actual prefix induction. Refusal and skip cases use unchanged state and do not invent successful guarantees. No participant's promised whole-run conclusion is an input premise.

Instantiate the rule for the accepted M2 initialized interface-total/global-binding predicates, retaining **the complete fixed global edge set**. The exact M2 names and local support/neutrality/paired-effect signatures must be resolved from accepted source at the dependency refresh. They remain theorem premises, not a new runtime certificate checker. Generic finite proof is independent of the selected concrete M2 fixture. Neither access authorization nor a catalog check alone establishes a financial invariant.

### D5. Separate executable causal monitor

Proposed `MonitorInput B P A D` contains selected participant, its current boundary, the pre-machine, actual post-machine and `attempt : Option Attempt`. `advanceMonitored update (q,m) b` calls the base `advance` once and obtains the attempted outcome from `post.attempts[pre.attempts.length]?`. It passes that exact input to deterministic `update : Q → MonitorInput → Q`; skip supplies none. `continueMonitored` folds this step. Monitor state never controls admission, executeStep, scheduling or financial publication. The callback receives only current/past execution data; future schedules, supplied fake receipts and future outcomes are not arguments. A Lean callback can nevertheless close over arbitrary constants, so argument shape alone is not an unconditional information-flow or future-knowledge prohibition. Causality is relative to the fixed update function, initial monitor/machine and static configuration/branches/boundaries. Prove a common-prefix theorem: with these parameters identical, executions of prefix ++ suffix1 and prefix ++ suffix2 have the same monitored state after exactly prefix.length tokens. Changing a callback or supplying an externally prescient initial monitor changes the premises and is not covered. This is provenance relative to the supplied initial world and trusted boundaries, not external authentication.

Prove erasure to the base continuation for arbitrary entry, and that the executable fold equals an inductive trace whose constructors require exactly those base transitions and appended-attempt inputs. Establish a joint K(q,m) with separate obligations: initialized K and K⇒∀i Iᵢ; current K plus explicitly named present external premise establishes selected Aᵢ; Iᵢ plus Aᵢ plus actual successful execution establishes own preservation and Gᵢ; peer stability plus that guarantee and the actual update reestablish K. Refusal and skip each require preservation of K under their actual monitor updates. A present external premise required at every prefix must be stated as such; it cannot be inferred from a desired successful future. Enabledness/progress is a separate theorem when claimed. An arbitrary callback need not satisfy these obligations.

The generic rule must expose the initialization, derivation of assumptions, local-step, cross-inclusion/stability and monitor preservation obligations separately. A single opaque premise saying “every transition preserves the desired K” is insufficient as the only causal result. The concrete witness discharges each obligation from execution and arithmetic, rather than supplying the desired final result.

### D6. Funded causal witness and independent observations

Use three streams p0,p1,p2 and distinct principals vault, donor1, donor2, recipient and budget; fixed home/USD cells, an additional framed domain/asset cell, and a nonempty exact capability store. Initial balances are vault10, donor1=2, donor2=3, recipient0, budget6; all unspecified cells are zero except the explicitly framed sentinel. Stream p0 executes an actual zero-effect producer exporting budget6, then a consumer with own-history qualified prior-output input at producer index0. It transfers that input vault→recipient with ordinary sufficient-balance guards. p1 transfers1 donor1→vault; p2 transfers2 donor2→vault. Use existing typed templates/catalog, literal grants, distinct operation identities and authorized boundary positions. No cross-stream history lookup or non-executable abstract oracle is added.

Monitor phases are Awaiting, Ready(amount, producer identity/key/index), Consumed. Only p0's actual successful index0 producer with the declared qualified output can enter Ready6. Only its actual successful index1 consumer consumes the fact. Refusal, skip and other-stream lookalikes establish no new budget fact. Independently prove 6≤vault−4 when Ready, stability under the two deposit-only peers, and reserve≥4 at every actual prefix. From the literal balances/guards prove all three streams succeed for every complete schedule; do not infer success from StepSound. All twelve schedules of lengths2,1,1 are executable checks with final vault7, donor1=1, donor2=1, recipient6, budget6. Their exact event/attempt ordering is schedule-dependent and must be expected separately.

Negative programs share valid catalogs, sufficient authority and independently specified expected outputs: an authorized literal transfer7 from vault10 leaves3; producer then peer withdrawal3 then consumer6 leaves1; a peer withdrawal7 alone leaves3; entry vault3 with identity actions stays3; two false circular promises satisfy their implications but establish no initial reserve; a refused producer supplies no fact; a successful matching output from another stream supplies no p0 fact. Those last two are monitor provenance checks, not claims that every rejected assumption causes a financial runtime refusal.

Freeze nineteen fixture IDs F01–F19 in author evidence. Full expected machines are built from literal expected states, receipts, outputs, positions, stores and failures, never by calling the candidate dispatcher or binary runner to manufacture the oracle. Binary runtime comparison is supplementary to those independent expectations. Synthetic arbitrary/unreachable machine pairs are explicitly labeled comparator tests and cannot count as funded execution.

### D7. Runtime/proof and evidence boundaries

Proposed runtime roots: Nary.Schedule, Execution, Observation, CausalRuntime, Examples, Tests, Audit. Proof roots: Soundness, BinaryCorrespondence, Interference, Causal, InterfaceInstances, and Verify. Names are proposed. All executable and shared proposition declarations precede `-- BEGIN PROOFS`; proof-only fixture helpers are outside runtime imports. Historical proof suffixes remain unchanged. An Audit executable must list nonempty unique check IDs and count false checks correctly.

Sixteen source mutations M01–M16 are defined in `author-draft/planned-mutations.json` with actual replacement sites, independent expected false checks and protected positives. Each production mutation must compile the real runtime closure after proof-tail stripping and fail its intended semantic oracle. Timeout, malformed output, parser/type/compiler error, missing module or empty checks is blocked evidence, never financial detection. Use explicit runner timeout600s and harness timeout1500s, record measured duration, and retain partial/cancelled attempts.

Adapt all final accepted S10 defensive CLI controls by a literal old/new root, namespace, proof-marker/regex, error-text, fixture and command mapping. The currently established S9 catalog has65 controls; S10's final accepted count and bytes remain a mandatory dependency refresh, not an invented new execution. Carry each established control, adding controls only for genuinely new driver behavior with separate labels. No change in this draft executes a mutant or claims a new runner pass.

## Risks / Trade-offs

- A finite function hides unselected corruption → prove update-at/away laws and compare every roster local state in independent fixtures.
- Successful-index and consumed-slot drift can use the wrong history or boundary → actual prefix local-order proof and separate success, refusal and overscheduling oracles.
- A monitor can merely rename the desired invariant → expose separate causal obligations and prove funded initialization, assumption provenance, peer stability and enabledness concretely; retain negative companions.
- M2 dependencies do not yet exist as accepted source → gate on accepted delivery and refresh exact symbols/instances, baseline and all inherited controls before independent planning review. Any material contract change requires a revised plan.
- A list fold theorem can be overstated as operational regrouping → label only fixed-order continuation chunking; retain M4 as unproved here.
- Large full observations increase runtime cost → finite small fixture universes and measured bounded timeouts; do not omit stored fields to force success.

## Migration Plan

Prepare this draft and strict author consistency evidence only. After accepted M2 delivery, bind actual dependency bytes and signatures, complete the literal driver-control mapping, freeze a deterministic planning bundle and obtain nonauthor GPT-6/native Fable5.1 medium verdicts. No review has been performed for this draft. Then implement in the new namespace, obtain actual Lean/runtime/mutation/regression evidence, inventory every imported theorem/axiom and obtain native Grok/Fable5.1 medium review of the same candidate and evidence. Preserve all failed attempts and historical sources. No deployment guarantee is included.

## Dependency refresh required before freeze

Accepted M2 source/evidence/archive identities; actual total/global-binding theorem signatures and concrete instance data; final S10 runtime/driver/control closure and counts; full accepted Lean and legacy baseline identities; literal Nary driver adaptation table. These are declared blocking prerequisites to official planning freeze, not missing choices delegated to implementation. Roster, admission, execution, monitor and proof obligations above are the proposed semantic contract for later review.
