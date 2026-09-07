# Independent GPT-6 Sprint 7 planning review

Verdict: **ACCEPT WITH LIMITATIONS**. No blocking planning finding or required
planning correction. The candidate is sufficiently precise and implementable to
pass this review's portion of the planning gate. The separate native Fable review
and current baseline remain independent gate conditions. This verdict establishes
neither implementation correctness nor that the planned proofs already exist.

## Identity and independence

- Reviewed candidate: `bf3fb509b211d7cd92eb68410fb49dc5f4e20e7d`.
- Base: `850d785d41dc311785dc33cdb3f65c368756434c`.
- Bundle: `review/semantic-kernel/sprint7/planning/r1-bundle.md`.
- Bundle SHA-256: `b8bd48445352214c3e2f09004c5cbe29928bf388adf256d01759b307fc952997`.
- Bundle size: 362852 bytes; identity manifest: `r1-candidate.json`.
- Requested reviewer: GPT-6 through the stock Codex harness. This report was
  produced by the independently dispatched Codex reviewer under that request and
  the harness role identifying GPT-6. Independent provider/build telemetry is
  unavailable to this reviewer; no separately verified backend build ID is claimed.
- Review date: 2026-09-07. Initial planning review, within the initial-plus-one-
  targeted-revision budget. No Foreman or substitute provider was used.
- I did not read the native Fable report, parent audit findings, or author
  self-review. Seeing their filenames in Git status/diff summaries was not used
  as review evidence. No specs, implementation, or historical sources were edited.

## Actual checks and scope

I read the approved migration design, progress ledger including Sprint 6,
`AGENTS.md`, the verification-footguns skill and gate register. I reviewed the
proposal, complete design, all four specifications, all 37 tasks, the 43-scenario
mapping, source-context manifest, and wiki/roadmap scope. I inspected existing
Composition execution, observations, sequential cursors and preservation helpers;
Parallel admission, dependency adapter, commutation and execution; and the
existing production mutation runner pattern.

Read-only checks performed:

1. `git rev-parse HEAD` returned the candidate above. Python SHA-256 and Git-object
   comparisons verified all 39 manifest entries against working files and candidate
   objects, including byte lengths. All 39 embedded bundle sections match their
   listed file bytes (allowing the bundle delimiter's terminal newline convention).
   The bundle's full length and SHA-256 match exactly. There were zero mismatches.
2. All 26 entries of `source-context.json` also match their Git objects at the base.
   `lean/DefiKernel/Interleaving/` does not exist. The base-to-candidate diff contains
   planning/documentation/evidence changes, with no Lean implementation change.
3. Independently parsed all four specs: 15 requirements and 43 scenarios. The map
   contains exactly those 43 unique `(spec, scenario)` pairs, with no omitted or
   extra row. All linked task IDs exist and every row has a nonempty task list.
   There are exactly 37 unique task checkboxes; only planning task 1.1 is checked.
4. `openspec validate shared-state-interleaving --strict --json --no-interactive`
   exited 0: one item passed, zero failed, no issues. Installed OpenSpec reports
   `1.10.0`. `openspec status --change shared-state-interleaving --json` reports
   complete planning artifacts; its `isComplete` is not evidence of completed
   implementation tasks.
5. `git diff --check 850d785d41dc311785dc33cdb3f65c368756434c
   bf3fb509b211d7cd92eb68410fb49dc5f4e20e7d` exited 0.
6. The graphify query returned historical graph nodes rather than relevant new
   kernel context. No semantic conclusion relies on that graph; candidate source
   and the frozen bundle supplied the relevant evidence.

I did not independently run a Lean build, execute an Interleaving fixture, compile
a mutant, or verify a new theorem. There is no Interleaving implementation to test.
The parent is responsible for its separately recorded current baseline. Existing
historical pass counts in the ledger are context, not freshly reproduced evidence
in this review. Concurrent untracked parent baseline/review artifacts are outside
the frozen source identity.

## Semantic assessment

The schedule contract is coherent. A token consumes the next static branch slot;
exact left/right counts make the public schedule complete regardless of refusals.
Consumed counts advance on failed suffix and out-of-range internal tokens, while
the canonical successful index stops at the first failure. Before a refusal these
indices agree, which makes the selected invocation, local boundary, output key and
failure index consistent. After refusal only consumption advances. No retry or
peer cancellation is implied. Count validation and whole-branch admission occur
before execution, so malformed unreachable suffixes cannot be masked by a
financial refusal. Configuration-left-right-schedule precedence is explicit.

The distinction between mutable ledger values and immutable local output snapshots
is also implementable. Existing `Composition.executeStep` accepts an explicit
history, local index, boundary and world; the new machine can supply its own
history with the current shared world. Different values at identical qualified
keys are possible when both branches produce at the same local index and an
interleaved write changes the captured cell. This no longer requires the
impossible disjoint collision used as a concern in the previous sprint.

The full attempt log and canonical observation have appropriate separate roles.
Attempt records retain actual pre-worlds and exact failed calls; the final world
may later differ from a failure's pre-world because the peer continues. The plan
does not reuse the sequential final-world refusal witness for that different
claim. The recovery projection removes foreign raw event worlds and schedule
order while retaining exact requests, receipts, typed outputs, branch assignment,
successful indices, located failures and full final ledger/store. This agrees
with the existing `Parallel.BranchObservation` boundary. It does not assert
equality of full interleaved traces.

The preservation plan has the necessary causal connection: machine reachability
must be derived from the actual runner and carry real success/refusal execution
equations. Accounting telescopes actual successful receipts, authority uses each
actual pre-world/local boundary, and invocation-only steps preserve the capability
store. Refusal/skip identity cases need no arbitrary rely or guarantee witness.
Supported frame predicates and proof-carrying nonnegativity are correctly scoped.

The proposed rely/guarantee rule is noncircular. At a left success, the induction
hypothesis supplies the left invariant; its independently quantified local
obligation supplies the left invariant afterward and `G_left`. Inclusion into
`R_right` and right stability preserve the right invariant. The symmetric case
is identical, and initialization establishes the base. No peer invariant is
smuggled into the local obligation. A no-supply transfer template makes the total
USD10 instance feasible even with arbitrary histories and invariant-satisfying
worlds: only successful calls must satisfy the local conclusion. This is a useful
conservation instance on overlapping support, not a solvency or invariant-
inference result.

Generic disjoint recovery has a credible source-backed proof path. Existing
`Parallel.executeStep_congr` in `Dependency/Adapter.lean` retains exact errors,
receipts, outputs, regional ledger agreement and capability equality.
`executeStep_target_frame` frames each admitted invocation's writes.
`analyzed_dependencies` includes writes in reads, and `analyzed_outputs` includes
the cells needed for snapshots. Existing `CursorAgrees` and `continueRun_congr`
show the required branch observation structure. A new induction can track isolated
cursors at consumed branch prefixes, agreement of the shared world on each
branch's analyzed dependency region, and unchanged cells outside both write sets.
Successful peer steps preserve the other region by compatibility. Exact refusal
congruence aligns the failure cases; remaining failed tokens are inert for the
isolated cursor even though the machine consumed count increases. At completion,
write-region agreement plus the outside frame yields the existing merged world,
and existing serial correspondence gives LR/RL observations. This needs a new
proof, but I found no missing premise that would require arbitrary shared-state
commutation or an all-success hypothesis.

## Fourteen mutation feasibility checks

These are feasible oracle recipes, not measured detections. Each must ultimately
edit actual retained production computation, compile, execute the full inventory,
produce its designated false comparison and preserve a successful control.

| Mutation | Concrete discriminating observation and useful protected control |
| --- | --- |
| 1. Schedule-count bypass | Structurally valid missing/excess schedule must return exact count refusal and no attempts; a valid complete schedule still succeeds. |
| 2. Reintroduced overlap rejection | Funded shared writes must be admitted; a disjoint funded pair remains accepted. |
| 3. Stale initial-world evaluation | Peer replenishment or state-dependent effects must change the later receipt/outcome; a first isolated invocation is unaffected. |
| 4. Isolated-world replacement | A later branch success must retain a prior peer balance change in the full final world; a one-branch success remains correct. |
| 5. Global cancellation | A funded peer attempt after an immediate opposite refusal must occur and succeed; an ordinary successful branch remains correct. |
| 6. Prefix rollback | A branch success followed by refusal retains its concrete balances/outputs; a success without a later refusal remains correct. |
| 7. Halted retry | An initially refusing withdrawal, intervening peer replenishment, and a funded valid suffix make a resumed branch produce an extra attempt/effect; the peer success remains present. |
| 8. Peer-history leakage | A missing own producer must refuse despite a usable peer producer, alongside a funded literal/own-history success; distinct colliding snapshots provide additional sensitivity. |
| 9. Snapshot recomputation | A producer captures a value, a peer changes its cell, and a later own consumer must retain the captured argument/output; a literal or unchanged-cell sibling remains correct. |
| 10. Global boundary index | Shift a branch globally while local principal/time vary across indices; verify exact local request or refusal and preserve an unshifted success. |
| 11. Wrong local invocation | Two differently parameterized operations at distinct local positions yield distinct expected requests/receipts; a singleton control cannot exhibit the selection error. |
| 12. Dropped peer supply | Both branches emit nonzero supplies: independently expected total and actual receipt aggregation differ if one contribution disappears; a single supplying branch remains correct. |
| 13. Revoked-grant resurrection | Otherwise identical funded live/revoked calls separate exact authority refusal from success; the live sibling remains successful. |
| 14. Omitted exact failure observation | Change only the failure in a compared observation and require inequality through the actual public recovery comparison; an identical observation pair must remain equal. |

Stale-world and isolated-world errors can share failing fixtures; cancellation,
rollback and retry can also overlap. Distinct designated labels and reporting
this dependence are adequate; fourteen mutations need not represent fourteen
independent logical dimensions. A compile failure is not sensitivity credit.
The established runner's source projection and complete-log checks provide a
reasonable starting point, while the new source-drift/Git-object obligations
still require their own implementation and live controls.

## Nonblocking implementation watchpoints and acceptance limits

1. Keep the two index invariants explicit in soundness and recovery. Reusing a
   sequential cursor's `nextIndex` as consumed slots after failure would break
   completion; using consumed slots as canonical `nextIndex` would break recovery.
   The candidate already specifies the correct distinction in design sections
   1–3 and tasks 3.1, 3.3, 4.2, 5.3–5.4. No plan amendment is needed.
2. Keep source mutants 9, 12 and 14 on production paths. Snapshot recomputation
   must change history/output handling actually consumed by the runner; dropped
   supply must change the actual aggregation; failure omission must change the
   comparison/projection used by recovery checks. Editing only expected fixture
   values, a private comparator, or stripped proof text would not discharge
   tasks 7.3 and 7.5. In particular positive recovery equality alone cannot detect
   dropped failure fields; the specified unequal observation pair is necessary.
3. Implement the disjoint prefix simulation early, as the design requests. It is
   the largest proof obligation and cannot be waived in favor of six schedules
   or a theorem assuming its own observation equality. This is effort risk,
   not evidence that the stated theorem is false.
4. The coverage JSON uses a generic evidence-kind description, but each linked
   task presently specifies the required proof/runtime/administrative evidence.
   At delivery task 6.3 must replace planned coverage with actual artifacts and
   explicit kinds. The current 43-row map is planning coverage only.

No additional review round is requested by this report. Acceptance is limited to
the specified finite binary invocation model, fixed capabilities, trusted
boundaries/catalog/observations, and exact arithmetic. It neither expands Sprint
6's historical claims nor closes atomic settlement, changing-capability races,
liveness, general associativity, environment truth, or deployed fidelity.
