# Operational tree regrouping — provisional M4 plan

Author planning only. The draft is
[`operational-tree-regrouping`](../openspec/changes/operational-tree-regrouping/proposal.md).
It supplies no kernel code or accepted proof. Accepted S10/M2 and M3 delivery,
actual API/baseline/control refresh and independent planning review are required
before official freeze or implementation.

The accepted S9 result `Metatheory.runGroup_assoc` concerns one sequential cursor:
it preserves all state, capability administration, events, stored outputs, indices
and failures when the same sequential steps are grouped differently. M3 proposes
a finite shared-state machine and causal monitor; its continuation append law
does not implement a participant tree. M4 supplies that separate machine.

The chosen tree has explicit empty, named-leaf and fork constructors. Every global
roster identity occurs once. One complete world/store and global attempt list sit
at the root; leaves contain their own complete local state. Internal nodes hold
neither private worlds nor admission policies. Configuration, boundaries, roster
and global interface edges stay fixed through regrouping.

The runtime recursively routes a named token and calls actual executeStep at its
leaf. It never executes by first flattening the tree. A failed leaf retains its
first refusal, while selected peers still run. Branch selection uses consumed;
boundary/history preparation uses the own successful index. Tree-path schedules
are decoded to stable names; reparenting requires re-encoding paths, not copying
the old path words.

Two proof contracts are deliberately separate:

1. **Same decoded schedule:** relate complete tree and flat machines, prove actual
   single-step simulation, then arbitrary-entry continuation and full observable
   equality across well-formed tree shapes. Shared writes are allowed because the
   token order does not change. Raw worlds, capability records, local histories,
   failure locations and global attempts remain visible.
2. **Different complete schedules:** require actual admitted pairwise-compatible
   footprints, including output reads and both write/read directions. Independently
   run each real branch from the same entry world and merge only its owned write
   cells. Prove recursive merge correspondence and canonical recovery, including
   financially refused prefixes. Canonical equality retains final full world/store,
   local consumed and BranchObservation fields, but excludes raw intermediate
   worlds and global attempt order.

Two authorized withdrawals7/6 from USD10 give USD3 or USD4 under opposite schedules.
They show why the first theorem does not imply the second without compatibility.
A callback recording token order likewise distinguishes schedules even when the
base financial results commute. Causal monitor equality is restricted to the same
update, initial monitor, static parameters and fixed prefix; its function type
does not exclude constants supplied from outside the model.

M2/M3 invariants transport only with initialization and their actual local/peer
obligations. Global edges are not rebuilt at a binary cut. The negative fixture
A=B=C=5 followed by C paying1 makes A=B still true while the full binding fails.
The positive paired-debit fixture preserves A=B and region total10 from5/5/0
through4/4/2,3/3/4 and2/2/6. Neither follows from admission alone.

The draft has five capabilities, twenty requirements, forty-six scenarios,
thirty-four unchecked tasks, twenty fixture contracts and eighteen planned
source mutations. A disjoint three-stream/two-step family covers all90 complete
schedules, with independent literal state/receipt/history expectations and a
financial-refusal sibling. A separate inherited M3 causal family has12 schedules.
Synthetic comparator pairs are explicitly distinguished from reachable execution.

Runtime/proposition definitions precede the proof marker; proof-only fixture
helpers stay outside the runtime closure. Mutants need successful compilation and
the intended false semantic check. Empty output, type/compiler failures, timeout
and cancellation remain blocked execution. Explicit timeouts are600s per runner
and1500s per harness. Final accepted predecessor control bytes/counts need a
literal adaptation map; historical S9's65 controls are not a new M3/M4 result.

Read-only graph traversal returned historical algebra nodes, so current API
claims rely on direct source inspection. Planning requires nonauthor stock GPT-6
and native Fable5.1 medium on the same frozen bundle; substantive result review
requires native Grok and Fable. Request `claude-fable-5-1[1m] --effort medium`,
record the actual returned model, and keep missing/non-substantive verdicts open.
No Foreman, kernel execution or provider invocation occurred in this author draft.
