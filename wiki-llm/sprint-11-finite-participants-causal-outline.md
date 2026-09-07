# Provisional Sprint11: finite participants and causal preservation

Planning outline only for increment M3; no OpenSpec freeze, implemented API,
independent review, completed theorem or accepted roadmap claim. This follows the
[metatheory draft](operational-metatheory-planning-draft.md) and provisional
[M2 plan](../openspec/changes/operational-interface-binding-preservation/design.md).
Require accepted and delivered Sprint9/M1 and Sprint10/M2, then refresh their actual
source, APIs, theorem signatures, baseline and runner-control identities before a
complete OpenSpec or independent planning gate. Names below are proposed only.

## Bounded semantic choices

Use a fixed finite participant type B, decidable equality and an explicit ordered
list containing each B exactly once. Its completeness/uniqueness is a parameter
contract, not a new malformed-enumeration runtime API. Empty B is permitted.
Participants identify streams, not authenticated ledger principals; trusted
boundaries still supply the principal at each participant's local absolute index.
Use invocation-only branches B → List Invocation, one fixed configuration, complete
entry world/store, local histories and an explicit finite schedule List B.
Capabilities remain fixed during this operator; issue/revoke and allocation races
are outside this increment. No cross-stream history lookup is added.

Admission validates the catalog, analyzes every full branch in enumeration order,
then checks complete occurrence counts in the same order. Report the first static
participant/index failure before schedule mismatch, including unreachable suffixes.
A mismatch identifies participant, expected branch length and observed token count.
The exact binary-error projection must map this to the existing two-count payload
using the unchanged branches/schedule, not discard diagnostic information.

The proposed machine has one shared world, local state B → LocalState and one
ordered global attempt list. A token consumes one static slot; an active available
invocation calls actual Composition.executeStep with current world and its own
history/index/boundary. Success appends its exact event/outputs and increments the
successful index. Refusal records its first exact located failure and unchanged
world. Failed/exhausted selection consumes a slot but adds no attempt; peers keep
running. An arbitrary-prefix runner permits overlong prefixes; public admission
requires exact full counts. The result retains the supplied schedule.

Proposed new namespace/files: `DefiKernel.Nary` with Schedule, Execution, Soundness,
BinaryCorrespondence, Interference, Causal, Examples, Tests, Audit and Verify.
These are future modules, not imports that currently exist. Keep all computational
declarations before the proof marker; leave historical Defialgebra.Nary unchanged.

## Actual execution and binary correspondence

Prove initialization and one-token soundness with actual success/refusal equations,
then every-prefix soundness. Recover each stream's ordered successful history from
its own actual events; distinguish consumed slots from successful nextIndex.
Derive exact refusal stability, fixed store, nonnegativity, receipt accounting and
supported frames from actual kernel results. No isolated branch replay substitutes
for shared execution; failed calls and skipped tokens contribute no receipt.

For B=existing BranchId and enumeration [left,right], define explicit conversions
of all local fields, world/store, attempts and results. Prove initial and one-token
simulation, then continuation and admitted-run correspondence with existing
Interleaving, including structural errors, complete-count errors and raw diagnostic
worlds. Use an exact data relation plus extensionality for participant functions;
pointwise final balances alone are insufficient. Arbitrary-prefix correspondence
must not require success or complete schedules. This is the runtime-to-Lean bridge:
the executable new dispatcher itself is related to actual existing computation.
Any additional executable IR would require a separate correspondence, not assumed
agreement from printing equal example results.

## Initialized finite rely/guarantee rule

For each i, fix ledger invariant Iᵢ and pre/post-world relations Gᵢ and Rᵢ.
Require all Iᵢ at entry. A local obligation quantifies arbitrary current machine
inputs and actual selected successful invocation, using Iᵢ(pre) to prove Iᵢ(post)
and Gᵢ(pre,post). Require Gᵢ ⊆ Rⱼ for every i≠j and preservation of Iⱼ under Rⱼ.
Induct over actual schedule prefixes to prove every invariant simultaneously.
Refusal and skip cases use world identity, without assuming a guarantee they did
not produce. This generalizes the existing initialized binary rule, not circular
whole-run implications. Lift accepted M2 total/global-binding instances under their
actual local conditions, preserving the entire fixed global binding set.

## Separate causal monitor rule

Add a deterministic monitor of the actual executed prefix, not a new admission or
financial guard. Its update receives the selected participant, current boundary,
pre-machine and actual outcome/skip only. It cannot inspect future schedule tokens
or outcomes. Prove that executable monitor replay equals its inductive trace
relation; fake supplied receipt/monitor tables cannot establish provenance.

Use a joint invariant K(q,m) with four separately discharged obligations:
1. Initialized monitor/machine satisfy K, and K implies every desired Iᵢ.
2. K plus explicitly stated current external facts entails the selected local
   assumption Aᵢ(q,m,boundary); no future successful run supplies that fact.
3. Iᵢ and Aᵢ plus actual StepSound imply local preservation and guarantee Gᵢ.
4. Actual guarantee, peer stability and the concrete monitor update reestablish K;
   refusal and skip updates have their own proof cases.

Trusted observations/authentication remain explicit environment premises. If a
schedule violates a necessary causal assumption, state a current-prefix restriction
or exhibit failure of the theorem's premises; the basic executor is unchanged.
Prove enabledness separately whenever success is claimed. StepSound alone gives
no progress. Keep the basic and causal rules distinct; split the latter into a
later OpenSpec if its monitor scope grows beyond this finite witness.

## Nonvacuous causal witness and negative companions

Protect a home/USD vault reserve4, initially vault10, donor1=2, donor2=3,
recipient0 and a separately framed budget cell6. Participant p0 contains a producer
then consumer; p1 deposits1 and p2 deposits2 into the vault with exact authority.
The producer is an actual accepted zero-effect invocation exporting budget6.
The consumer in the **same stream** reads that exact qualified prior output and
transfers6 vault→recipient. It uses the ordinary sufficient-balance guard.
Own-history semantics prohibit replacing this with cross-stream snapshot routing.

The monitor records only p0's actual successful producer output, its qualified key
and local index. Phase Awaiting becomes Ready6, then Consumed after the one actual
consumer; a stale fact is not reused after consumption. Prove the producer's bound
6≤currentVault−4 from initialization and deposit-only intervening effects, and
preserve it until consumption. Printing a snapshot alone proves no budget bound.
All12 complete schedules of stream lengths2,1,1 are bounded checks; independently
expect final vault7, donors1/1, recipient6 and unchanged budget6, with reserve≥4
at every prefix. A generic proof, not those12 checks, establishes the rule.

Required negatives: authorized transfer7 from vault10 succeeds and leaves3 when
the reserve premise is absent; an intervening authorized withdrawal3 after the
snapshot leaves7, then consuming6 succeeds and leaves1, exposing stale budget
stability; an authorized peer withdrawal7 itself breaks reserve preservation.
Also include entry vault3 with identity actions (missing initialization), both
circular promised facts false, a refused producer emitting no fact, and an actual
successful lookalike producer in another stream that cannot authorize p0's monitor.
Freeze exact full stores, receipts, histories, boundaries and failure payloads in
the eventual OpenSpec. Compiler failures are not these semantic counterexamples.

## Evidence and remaining scope

Require nonempty exact binary-correspondence fixtures, at least three nonempty
streams, empty/singleton participants, malformed static suffixes, count mismatches,
failed-stream continuation, own-history collisions and actual financial negatives.
Plan real compiled source mutations for selected-stream routing, world/store/history
propagation, consumed/index handling, peer-halting errors and monitor provenance/
staleness; freeze their exact independent false oracles and protected positives
only after the executable design is complete. Do not announce a mutant count here.
Retain every accepted predecessor CLI control, full imported proof/private-name
inventory and honest source/tool/regression bindings. No sorry/custom axioms or
native_decide. Stock GPT-6 implementation follows nonauthor GPT-6/native Opus plan
acceptance; native Grok/Opus review results, requesting opus and recording returned
model. No Foreman. M4 routing/group simulation, generic schedule independence,
active extensions, administration provenance and Atomic boundary laws stay open.
