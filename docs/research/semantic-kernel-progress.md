# Semantic kernel migration progress

Branch: `semantic-kernel-pivot`. Starting commit: `8ae0bbf`.
Authorization: user approved saving and executing the assessed plan on 2026-09-06.
Implementation: GPT-6 / stock Codex harness. Review: native Grok and Fable CLIs.
Foreman is not used.

## Source identity

`2026-09-06-defi-source-plan.md` is a byte-for-byte copy of the user-supplied
Desktop `defi.md`, SHA-256
`c458c6c9e32675afe6a6aa44e6f1a6767d3963accb6d291ec24e6212ecac9975`.
Its unresolved external citation tokens and two sandbox attachment links do
not constitute retrieved source evidence.

## First increment

| Deliverable | State | Evidence |
| --- | --- | --- |
| Migration design and execution plan | Saved | `../superpowers/specs/2026-09-06-semantic-kernel-design.md`; `../superpowers/plans/2026-09-06-semantic-kernel-pivot.md` |
| Existing Lean baseline | Passed at starting revision | `cd lean && lake build`, exit 0, 979 jobs; existing linter warnings |
| Research mandate and entry-point supersession | Delivered | Commit `43c2b1b`; README and AGENTS.md; historical claim notices |
| Generic Lean pilot and three reference examples | First increment complete; revised and reviewed | Source candidate `9e9a2bfe6a3c85785fd3fb845bba6c7765481e22` |
| Full Lean build | Passed at revised candidate | Parent command `cd lean && lake build`, exit 0, 988 jobs; `../../review/semantic-kernel/2026-09-06/r2-full-build.log` |
| Executable pilot checks | 33/33 passed | Fresh `lake env lean DefiKernel/Audit.lean`; `../../review/semantic-kernel/2026-09-06/r2-pilot-audit.log` |
| Named theorem axiom audit | 51/51 disclosures, standard axioms only | Exact set equality of source theorem names, disclosure list, and observed output; `../../review/semantic-kernel/2026-09-06/r2-axiom-coverage.json` |
| Source mutation sensitivity | Seven mutations discriminated | Unchanged control: 22 true comparisons, exit 0. Six checker-branch mutations and an isolated price-conjunct mutation: explicit false comparisons and exit 1. Clean input-source binding in `../../review/semantic-kernel/2026-09-06/r2-mutation-results.json` |
| Grok review | R1 passed; targeted R2 retry passed after full-bundle timeout | Requested `grok-4.6`, native usage `grok-4.6-build`; saved native response |
| Fable review | R2 passed after R1 fixes | Native main response `claude-fable-5-1`; saved native response and adjudication |

The baseline is a measurement at the starting revision, not a claim that future
changes build. Candidate evidence and exact reviewed sources are recorded under
`review/semantic-kernel/2026-09-06/`.
See [the review adjudication](../../review/semantic-kernel/2026-09-06/ADJUDICATION.md)
for findings, fixes, the timed-out invocation, successful retry, and exact
review scope. The final evidence commit changes records only; reviewed source
bytes match candidate `9e9a2bf`.

## Sprint 2: operation contracts and automatic axiom coverage

User authorized pushing the branch and starting the next sprint on 2026-09-06.
Remote `origin/semantic-kernel-pivot` was created and read back at
`4c25efc41c4c2b6d6ad3c9fd68d081e71043f387`. The sprint continues on that branch.
The [sprint design](../superpowers/specs/2026-09-06-operation-contracts-design.md)
and [execution plan](../superpowers/plans/2026-09-06-operation-contracts.md)
are saved in commit `95c1360`.

| Deliverable | State | Evidence |
| --- | --- | --- |
| Starting Lean baseline | Passed | `lake build`, exit 0; unchanged first-increment sources |
| Trusted operation-contract wrapper and examples | Complete; reviewed | Revised candidate `8a75bf7bfc468958f673f4842395129cdfe78e19`; 43/43 new runtime checks |
| Automatic elaborated theorem/axiom audit | Complete; strengthened after review | 278/278 imported theorem constants plus 234/234 supplemental declarations; no forbidden axioms |
| Integrated build | Passed | Full build: 994 jobs, exit 0; original runtime 33/33; new runtime 43/43; fresh automatic audit exit 0 |
| Contract mutation sensitivity | Discriminates both tested mutations | Control: 43/43 true. Contract bypass: 15 explicit false comparisons. Borrow-condition bypass: six explicit false comparisons. Positive controls remain true; all 43 comparisons execute per variant |
| Axiom audit negative tests | Passed at revised candidate | 99 replay assertions: automatic addition, module provenance, transitive custom/sorry dependencies, unused axioms, sorry definitions/opaques, clean controls, empty/missing scopes, and source identity checks |
| Native Grok and Fable review | Passed at revised candidate | Fable focused follow-up passed; all three Grok retry scopes passed. Original Grok timeout remains no verdict; manifests and invocation records preserved |

Contracts bind a trusted operation selection and parameters to complete effects;
borrow requirements are checked independently of the proposal's own guard.
The broad-policy counterexamples remain valid for the original executor.
Automatic audit discovers theorems from the loaded Lean environment; scope is
imported pilot modules, not every unimported file in the repository.
Automatic counts include generated theorem constants, so 278 is not a count of
278 separately stated financial results. The test recipes ran against committed
inputs at `b1167bf` and `8a75bf7`, with clean input paths, recorded hashes, and unchanged input
bytes after execution. Other working-tree paths held the pending review records.
The supplemental audit closes a confirmed R1 gap: theorem-only dependency
inspection missed unused custom axioms and sorry-dependent definitions.
The final audit includes the helper module itself, with no exemption.
See the [sprint review adjudication](../../review/semantic-kernel/sprint2/ADJUDICATION.md)
for actual model identities, findings, fixes and deferred advisory items.
Financial source bytes are unchanged between the two sprint review candidates;
the revision strengthens audit coverage and the mutation output-directory guard.

## Sprint 3: corpus normalization and provenance

User authorized this sprint with “begin”. Base:
`1d26fd863f9bf9ecb8361982f43e212a4c94eec7`; branch `semantic-kernel-pivot`.
The [sprint design](../superpowers/specs/2026-09-06-corpus-provenance-design.md)
and [execution plan](../superpowers/plans/2026-09-06-corpus-provenance.md)
are saved with neutral source/identity inputs in `81f48aa`.

| Deliverable | State | Evidence |
| --- | --- | --- |
| Frozen historical source inventory | Saved | Three lane files, 72 complete source rows, byte hashes and JSON pointers |
| Provisional candidate identity map | Saved | 75 units; Liquity V1/V2 and Ondo USDY/OUSG/Global Markets splits; deployment identities unresolved |
| Independent model annotations | Complete, provisional | 75 units each; 279 nonempty agreements, 67 empty agreements and 29 unresolved differences; separate raw annotations |
| Schema, builder and read-only validation | Verified | 20 tests / 76 real CLI runs; actual corpus rebuild byte-identical; check preserves bytes and timestamps |
| Limited primary-source provenance | Captured | Current official-document excerpts and response fingerprints; distinct from historical source claims |
| Native Grok/Fable review | Accepted with recorded limitations | Both focused reviews on `7df773478df6408ac75abeca64ef04d76320c6fe`; [adjudication](../../review/semantic-kernel/sprint3/ADJUDICATION.md) |

This is a reconstruction of the missing crosswalk/schema, not a recovered copy.
Agreement is provisional; differing labels remain explicitly unresolved under
the conservative adjudication rule. All candidates are development cases.
The separate Liquity V1 liquidation source challenge remains open. Three real
adjudication mutants are discriminated by the strengthened tests; five coherent
split-payload corruptions that previously passed are now rejected.
Exact final commands, file hashes and actual corpus reproduction results are in
[final verification](../../review/semantic-kernel/sprint3/final-verification.json).

## Sprint 4: typed transition IR and capability authority

Source candidate `76c99e44689fcdd3422d998f4b82cf2f8e794c57`, based on
`77462b61f5f537eb29b2cf162ead6567e7151ace`. GPT-6 implementation used the stock
Codex harness; no Foreman. The user authorized the autonomous completion loop.

| Deliverable | Current result |
| --- | --- |
| Reusable typed identities and closed dimensioned expression AST | Implemented; exact rational arithmetic, checked arguments/observations, explicit division refusals |
| Registered execution and capability lifecycle | Implemented; authenticated context, exact scoped rights, fresh IDs/tombstones, issue/use/revoke/retry |
| Reference financial libraries | Transfer, fixed-rate deposit/withdrawal and oracle borrow; complete32-cell posts and independent price/freshness/collateral checks |
| Named proof inventory | 52 named theorems across8 modules; scoped generic and concrete claims recorded separately |
| Full build and runtime | 1005-job full build;189/189 typed comparisons; legacy33+43 comparisons pass |
| Imported axiom audit | Typed524 theorem+978 supplemental declarations; legacy278+234; forbidden0 |
| Discriminating evidence | 24/24 real source mutants detected,189 comparisons each;3 positive controls preserved;17 real runner CLI controls;99 existing axiom-audit assertions |
| Compiler typing refusals | One executed positive and3 separately compiled negative fixtures; expected Type mismatch, not financial counterexamples |
| Native review | All five scoped reviews accepted with limitations by native Grok/Fable; no blocking findings |
| Delivery | Complete source/evidence pushed at `6ca2f65`; remote head matched local and worktree was clean |

The exact [design](../superpowers/specs/2026-09-06-typed-kernel-design.md),
[implementation checklist](../superpowers/plans/2026-09-06-typed-kernel.md),
[proof inventory](../../review/semantic-kernel/sprint4/proof-inventory.json),
[build evidence](../../review/semantic-kernel/sprint4/build-verification.json), and
[mutation outcomes](../../review/semantic-kernel/sprint4/mutations/summary.json)
and [native review adjudication](../../review/semantic-kernel/sprint4/ADJUDICATION.md)
are saved. All original tracked proof/corpus files remain unchanged. The only
modified preexisting files are the kernel import root and this progress ledger.

Trust boundaries remain explicit: registry/admin/store/context authenticity and
observation truth are assumed. Debit authority is an administrator's exact-cell
grant to the invoker, with no separate owner-consent condition. Effects are net
rational changes, not ordered debits or consumable allowances. Footprints and
domain conditions characterize successful execution; refused evaluation can have
already read inputs. General success theorems do not prove a full refusal taxonomy.
Composition, claims lifecycle, replay protection, machine arithmetic and deployed
protocol fidelity remain future work. All references are development examples.

Sprint 4 is complete. [Delivery verification](../../review/semantic-kernel/sprint4/delivery.json)
records the source/evidence push; a subsequent documentation commit saves that
verification. The stock harness also checks the final documentation commit head.

## Sprint 5: typed interfaces and sequential composition

The approved [OpenSpec proposal](../../openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/proposal.md),
[design](../../openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/design.md),
and [47 tasks](../../openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/tasks.md)
are implemented at source candidate `28ba18c446f72084ff11b4d125dccf93bf8f4162`.
GPT-6 used the stock Codex harness, with native Grok/Fable review and no Foreman.

| Deliverable | Accepted evidence |
| --- | --- |
| Typed interfaces and adapter | Validated private/shared access, typed historical outputs, trusted boundary inputs, same-prestate receipt extraction |
| Sequential execution | Current ledger/store propagation, successful prefix retained, first refusal stops execution, absolute continuation positions |
| Named proofs | 70 named theorems: 58 generic and 12 reference fixtures; accounting, authorization, locality, conditional invariants, supported ledger frames, continuation |
| Full build/runtime | 1016-job build; 93/93 composition comparisons; existing typed 189 and legacy 33+43 pass |
| Imported axiom audit | Composition 328 theorem + 583 supplemental declarations; typed 524+978 and legacy 278+234; forbidden 0 |
| Mutation evidence | 12/12 compiled composition mutants detected with 93 checks each and six protected positives; 24/24 existing typed mutants detected |
| Controls/regressions | 36 composition and 17 legacy runner CLI controls; 99 axiom-control assertions; positive and three negative typing fixtures; 20 corpus tests |
| Preservation/integrity | 165 original proof/corpus files byte-identical; 990 artifact-integrity assertions with zero failures |
| Native review | Both required final Grok/Fable reviews accept with limitations; initial findings, fixes, model identities and dissent retained |

[Coverage](../../review/semantic-kernel/sprint5/coverage.md) maps all 19 requirements
and 42 scenarios. The [proof inventory](../../review/semantic-kernel/sprint5/proof-inventory.json),
[build evidence](../../review/semantic-kernel/sprint5/build-verification.json),
[mutation results](../../review/semantic-kernel/sprint5/mutations/summary.json), and
[adjudication](../../review/semantic-kernel/sprint5/ADJUDICATION.md) distinguish
proof, bounded execution, measurements, and assumptions. Execution began on a
dirty predecessor; original records are preserved. A
[direct Git-object comparison](../../review/semantic-kernel/sprint5/commit-source-verification.json)
binds all 27 input files to the reviewed source commit without relabeling those
historical execution heads. No source changed after final review.

Ledger frames require explicit support/write-disjointness. Component locality
ends at denied `canWrite`; foreign-private identification is demonstrated in
configured workflows, not a general private-state noninterference theorem.
Contract preservation retains local/boundary assumptions. Nonnegativity is a
proof-carrying-state fact. Environment truth, catalog authorship and capability
provenance remain assumptions. Structural catalog checks have negative examples
but no individual source mutants. An optional Fable documentation-only follow-up
was unavailable due to credits; both required final reviews completed beforehand.
[Delivery verification](../../review/semantic-kernel/sprint5/delivery.json) records
the source/evidence push at `5fb0929`, with matching remote head and clean worktree.
OpenSpec archived the change as `2026-09-06-typed-interfaces-sequential-composition`
and synchronized all 19 requirements to four main specifications.
[Archive validation](../../review/semantic-kernel/sprint5/archive-validation.json)
records strict specification and local-link checks. A subsequent metadata commit
saves these records, with its remote head checked separately by the stock harness.

## Sprint 6: disjoint parallel composition acceptance

The approved OpenSpec change implements binary disjoint parallel composition.
Planning passed on `c0f6f0b`; Lean source froze at `7cb4807` and the new mutation
runner/spec at `fae07ca`. Both native Grok and Fable reviews accepted the Lean
implementation and final evidence with limitations. Exact identities, source
hashes, findings and responses are recorded in the
[adjudication](../../review/semantic-kernel/sprint6/implementation/ADJUDICATION.md).

The operator conservatively analyzes every branch suffix, executes independent
prefixes with isolated histories and fixed capabilities, retains exact refusals,
and merges disjoint write regions. Generic proofs establish correspondence to
both real admission-gated serial orders, actual receipt accounting, point-of-use
authority, locality, supported frames and conditional initialized invariants.
Proof-carrying nonnegativity is distinguished from discovered invariants.

All ten integrated Lean commands pass: 131 Parallel runtime comparisons and
388 theorem/419 supplemental axiom checks, with zero forbidden dependencies.
There are 126 explicit theorems: 88 generic, 35 reference instances and three
counterexamples, plus 262 generated theorem declarations. All 14 source mutants
are detected with complete inventories and protected positives; all 45 Parallel
CLI controls pass. All seven historical Python suites pass. A clean root-package
build and frozen issue/revoke type-error controls also pass.
[Coverage](../../review/semantic-kernel/sprint6/coverage.md) maps all 47 scenarios;
[the proof inventory](../../review/semantic-kernel/sprint6/proof-inventory.json)
records exact elaborated statements and premises. Original 165 corpus/proof paths,
32 protected kernel sources and 435 historical Lean files are unchanged; the root
import only adds the Parallel verification module.

Accepted source/evidence commit `26bb17d` is verified on `semantic-kernel-pivot`.
The approved change is archived as `2026-09-07-disjoint-parallel-composition`;
all 17 requirements synchronized to four main specifications.
[Delivery](../../review/semantic-kernel/sprint6/delivery.json) and
[archive records](../../review/semantic-kernel/sprint6/archive-action.json) identify
the actions. Shared
state interleaving, atomic synchronization, broader associativity, claims and
provenance, environment truth and deployed fidelity remain open. The reference
cases are development fixtures, not untouched holdouts or deployed protocol
proofs.

## Sprint 7: shared-state interleaving acceptance

Final proof source `bea105ec` implements one evolving shared world, finite complete
binary schedules, own histories and permanent local refusal with peer continuation.
Actual trace/order/accounting/authority/frame proofs and initialized noncircular
interference composition are generic. Universal disjoint recovery includes exact
refusals and all complete schedules. Three final corollaries explicitly expose
admission identity and complete exhausted-or-refused behavior.

Both native Grok/Fable source and final evidence reviews accepted with limitations.
[Adjudication](../../review/semantic-kernel/sprint7/implementation/ADJUDICATION.md)
records identities and findings. Runtime116/116, production mutations 14/14,
runner controls 52/52, nine historical Python suites and12 final Lean commands pass.
Imported audit has262theorems/271 supplemental with zero forbidden dependencies.
127 explicit theorems comprise107generic,15 instances,3 counterexample constructions
and2counterexample corollaries;135 others are generated. Original execution revision
`6de24fe` is retained, with25+3 exact runtime input bindings to the proof supplement.
Historical1117paths remain unchanged and the root only adds the new verification
import. [Coverage](../../review/semantic-kernel/sprint7/coverage-final.md) maps43
scenarios. The source/evidence push `b0f9bbf` is verified and OpenSpec archived15 requirements into four main specs; archive metadata `55d1ce3` is also pushed and remotely verified; all 37 tasks are complete.

Atomic synchronization is the next proposed increment. Trusted initial store and
boundaries, finite schedules, exact arithmetic and explicit frame/interference
premises remain limits; no deployed fidelity or general behavioral associativity
is claimed. The stock Codex goal loop now covers the full remaining roadmap while
the user is AFK, with the same OpenSpec planning and native acceptance gates.

## Full migration backlog

1. Finish claim-site reconciliation across the old paper and working ledgers;
   preserve original statements and attach scoped corrections. Audit the
   instance bridge behind structural/exhaustive claims.
2. Extend the typed IR with distinct operational composition operators, claims
   lifecycle, assumptions and certificates. Sprint 4 implements reusable finite
   identities, dimensioned expression typing, trusted registry selection and
   capability issuance/use/revocation. Preserve the original negative results
   and current wrapper/typed reference semantics as these operators grow.
3. Complete deployment/source identity beyond the saved 72-row/75-candidate
   provisional reconstruction. Resolve 29 facet differences and the separate
   Liquity V1 liquidation source challenge; recover remaining bundled products
   and retrievable references. All 75 units remain development cases.
4. Build a real serialized certificate path and source-bound fidelity checks.
   Extend automatic imported-module axiom coverage to explicit future package
   manifests and replace format-sensitive extraction as the language grows.
   Current mutations cover original checker branches, wrapper contract/borrow
   checks and24 typed authority/registry/footprint/accounting/oracle mutations.
   Sprint 5 adds12 sequential, Sprint 6 adds14 disjoint-parallel, and Sprint 7 adds14 shared-interleaving mutants. Broader effect application, structural catalog checks, and later composition operators remain open. Audit coverage is bound to the actual import closure.
   Review follow-ups include explicit inductive audit roots, a current-module
   exclusion fixture, script-output hygiene across multiple checkouts, and
   mutations that weaken individual actor/effect/supply comparisons.
5. Extend the accepted sequential and binary disjoint-parallel results through shared-state
   interleaving to synchronized composition, operation-wide noninterference, assume-guarantee discharge,
   claims and conservative extension.
6. Port adversarial financial libraries with pinned contract implementations,
   differential execution, mutation tests and selected refinement proofs.
   Extend the reference operations with repayment and trusted-effect locality
   results; the current debt-erasure test is rejection as a borrowing proposal.
7. Freeze the kernel and evaluation split, test untouched cases, report separate
   metrics, then update publication and ontology visualization.

Completing the pilot does not close these work packages. It does not establish
deployed protocol fidelity, general solvency, or a complete DeFi calculus.

## Sprint8 atomic synchronization acceptance (2026-09-07)

Source `99e2e2c` and evidence are accepted with limitations by native Grok and
Opus and pushed at `2c038094`. Four atomic OpenSpec capabilities (16 requirements,
49 scenarios) are archived. Archive-metadata delivery `9501f0a4` is verified; all40 tasks and49 scenarios are complete.
Actual kernel/proof/18-production-mutant runs retain a52 identity; final65 runner
controls execute at a52 with harness bytes committed unchanged at99. All135
runtime comparisons and14 Lean commands pass;357 imported theorems comprise106
explicit and251 generated, with496 supplemental axiom-audited declarations and
zero forbidden dependencies. Eleven legacy suites retain88aa identity with
explicit relevant-input equivalence.

The model adds first-failure atomic rollback and signed receipt-derived typed
settlement, not deployed Balancer fidelity or a generic order-independence law.
Initial store/boundary trust, rational arithmetic, fixed stores, supported frames
and initialized invariant premises remain explicit. See the
[Sprint8 adjudication](../../review/semantic-kernel/sprint8/final-review/ADJUDICATION.md).
Future native reviews use Grok and Opus under the user's reviewer update.

## Sprint 9: sequential congruence and configuration preservation

Native Grok and Fable5.1 medium accepted source `eec499d613688137a341f3556cd80ca461dd2ee9`
and final execution evidence with recorded limitations. Recursive sequential
groups, full-cursor simulation/associativity, selected observation equivalence,
fixed-prefix/suffix substitution and sufficient configuration preservation for
all existing operators are implemented.

Fresh16 Lean commands and148 new runtime comparisons pass. The imported inventory
contains109 explicit theorems (74 generic,35 instances),128 generated theorem
constants and342 supplemental declarations, with zero forbidden dependencies.
All14 actual mutations and65 CLI controls pass their required classifications.
Thirteen legacy suites retain c880 execution identity through exact relevant
source/tool equivalence. Source-r1 aliases were corrected with distinct complete
financial expectations; original evidence and the context-limited Fable attempt
remain preserved. [Adjudication](../../review/semantic-kernel/sprint9/ADJUDICATION.md)
and [evidence](../../review/semantic-kernel/sprint9/EVIDENCE.md) give precise scope.
Source/evidence delivery is verified at `ec9ed804`; OpenSpec is archived with35
checked tasks,17 requirements and55 scenarios preserved. The archive push is
recorded separately.

## Sprint 10: operational interfaces and binding preservation

Source `b165bc586080d668f689fbc18dfa09eb8739d688` and completed evidence passed
native Grok (`grok-4.6-build`) and Fable (`claude-fable-5-1`) medium review on
one identical bundle. GPT-6 used the stock harness. Region queries and actual
receipt accounting now support initialized total and global binding preservation
through sequential execution, recursive groups and existing binary interleavings.

All 18 integration commands, 99 runtime labels, 14 compiling query mutations and
65 CLI controls pass. The dynamic proof inventory contains 310 theorem constants:
144 explicit (110 generic,32 reference,2 counterexample-classified) and166
generated, plus356 supplemental declarations; forbidden axioms0. The build is
incremental, one catalog check is an intentional alias, and mutation overlap does
not establish unique fault identification. Thirteen older suites and Sprint9's
14/65 runs retain their original execution revisions through exact relevant
input/tool equivalence. Final record corrections preserve original reviews.

Source/evidence delivery `1db00deb` and archive delivery `ec8f163c` are verified.
All34 tasks and57 scenarios are complete; four main specifications contain the
same17 normative requirements. [Evidence](../../review/semantic-kernel/sprint10/EVIDENCE.md)
and [adjudication](../../review/semantic-kernel/sprint10/ADJUDICATION.md) state the
remaining initialization, confinement, neutrality, support and authority trust
premises. Finite participants and other M3–M6 obligations remain open.

Checked integer arithmetic and corpus provenance tooling have separate accepted
planning gates and ongoing implementation. Neither is an accepted result yet.
