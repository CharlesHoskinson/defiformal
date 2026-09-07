## Context

Author draft at `5dc7abbf520ad01ed7a1681d70b492855080a16d`; not a planning acceptance. The input manifest under `review/semantic-kernel/claim-reconciliation/planning/author-draft/` binds the actual files read. `preparation-r2/claims.json` supplies CL01–CL18 and 63 excerpts from 22 files. Its source base and the actual historical-instance run are `4d42600082d4213d34ac5ab4b0dfc3eefde23d5e`, not a newly executed measurement at this draft revision.

The 2026-09-06 migration design preserves historical results while correcting their use. `Defialgebra.ConvexGeometry` already proves intrinsic extreme-point and reachability results. The historical `m5-convex.mjs` defines both saturation and reach locally; `lib.mjs` exports model-class predicates, not the closure called by m5. `formal/v2/f8.mjs` and `viz/src/laws.ts:closureOf` are different objects; the latter is depth-limited, traverses alternatives and excludes the seed. They cannot silently become the bridge target.

## Goals / Non-Goals

The deliverables are a reconciled claim overlay and selected prose, two checked finite unary-rule Lean instances, and an honest executable-evidence wrapper. Completion means these deliverables pass their stated gates, not that every historical statement, financial model or paper argument has been accepted.

No historical Lean file, Quint model, JavaScript generator, Python historical generator, original or normalized corpus, accepted kernel module, sealed review input or old result is modified. No repaired Delta implementation, semantic-minimality theorem, general AFT obstruction, verified JavaScript engine, computational-complexity proof, protocol deployment correspondence, complete manuscript rewrite or new untouched evaluation is included.

## Decisions

### 1. Split delivery without hiding dependencies

Three alternatives were considered. A prose-only correction is inexpensive but leaves CL15's instance obligation untouched. A combined whole-paper rewrite plus full JavaScript refinement would conflate substantially different proof and publication problems. This design chooses separate testable increments within one bounded change: claim ledger/prose; exact Lean graph instances; bounded execution reporting; combined evidence review. Ledger corrections can be reviewed before bridge proofs; the package cannot claim its concrete bridge complete if only the prose lands.

The read-only preparation records are evidence inputs, not completed implementation tasks. All tasks start unchecked. Historical source snapshots and old runs retain their exact identities. New claims cite either a new proof statement with premises or an actual executed record; a plan expectation is never a result.

### 2. Claim overlay and allowed edits

Create `review/semantic-kernel/claim-reconciliation/implementation/claims.json` with exactly one current record for each CL01–CL18 and separate discovered occurrence records. Preserve the original entry verbatim by source path, JSON pointer and hash. Each current record contains `id`, `original`, `sites`, `disposition`, `proposed_text`, `applied_sites`, `retained_sites`, `evidence`, `limits`, `dependencies`, `review_status` and `supersedes`. Stable dispositions are `correct_prose`, `retain_scoped_result`, `withdraw_inference`, `bridge_pending`, `bridge_proved`, and `defer_separate_work`; they do not double as evidence classes. Evidence classes are `source_inspection`, `lean_generic`, `lean_instance`, `bounded_execution`, `historical_measurement`, `counterexample`, and `unchecked_assumption`.

Every site binds path, source Git blob/SHA, exact quoted bytes with line range, semantic claim ID, and successor bytes if edited. The checker validates structural evidence links and explicitly recorded scope judgments; a human/nonauthor review supplies mathematical interpretation. It does not infer truth from keywords or automatically decide arbitrary prose, theorem applicability or the existence of a bijunctive definition. Literal scope-negative controls exercise these declared evidence contracts, not an invented semantic decision procedure. Distinguish a mathematical statement from explanatory prose and literal historical quotation. Unknown/disputed interpretations remain unresolved and cannot be silently finalized. New records append or supersede; retained snapshots are never replaced. Missing links, duplicate current IDs, cycles, dangling supersession and conflicting accepted heads fail validation.

The future prose allowlist is `algebra/MODEL.md`, `algebra/THEOREM-LEDGER.md`, `research/positive-program/basis/{BASIS,REFUTATION,GENERATION}.md`, and `docs/research/semantic-kernel-claim-disposition.md`. Selected non-theorem prose/cross-references in `paper/atlas.tex` can change; all theorem/lemma/proposition/corollary statement and proof environments remain byte-identical. If an environment itself requires correction, record a visibly linked erratum outside it and defer a separately reviewed mathematical revision. Historical verification reports, corrected QSIGMA/Gate3.1 reports and `gen_chunk3.py` are preserved; their stale echoes receive overlay annotations rather than generator changes. Adding downstream paths to the edit allowlist requires a candidate revision and explicit review before edits, not an automatic search-and-replace.

Discovery searches the tracked UTF-8 repository with exact inventory/exclusions and records every hit/context/hash. Exclude dependency/build/vendor data and immutable review copies from the edit list, while recording copied claims as copies. Search family terms, labels, theorem names and known numerical phrases from all 18 entries. Review false positives and unmatched bounded patterns. This establishes coverage of the declared discovery procedure, not completeness over all possible paraphrases, deleted history or rendered TeX. Paper acceptance additionally compiles a private copy and binds PDF plus extracted text; a source token occurring in a comment or hidden macro is not reader-visible correction evidence. No old generators run as part of discovery.

`claim-disposition-map.json` in this change maps each CL item and the ten original disposition-register rows to the planned action and limits. CL06 permits a valid stronger route: prove `adm A`, `adm B`, a purely negative forbidden set `F ⊆ A ∪ B`, and `∀ X, F ⊆ X → ¬ adm X`. Any common upper bound would contain F, so none is admissible. A pair satisfying only requirements/warrants is insufficient; a mixed clause with a repairable positive consequent is insufficient. This package does not require finding such a full-instance witness: absent one, narrow the prose to the established union-closure failure and explicitly leave induced-order nonexistence unestablished. Never infer lattice existence from the failure of an old proof.

CL17 similarly requires full-instance valid assignments for a majority counterexample, or an independently reviewed analytic proof about the full relation; width statistics alone remain syntax. The default corrective route retains the statistics and withdraws their semantic implication. No new exhaustive admissibility or majority search is required here. CL03/04 name one-pass D separately from a stabilized operator; neither an unproved D* nor a repaired operator is introduced.

### 3. Exact finite input artifacts

The instance universe is the actual ordered 58-entry `T.MECH` list imported as `L.E`, captured without renaming. Encode names bijectively as `Fin 58` and prove decoding/encoding round trips and uniqueness. Bind two separate instances, `lstar` and `parsedNew`. Their raw records and extraction decisions retain law IDs, subjects, external flags, alternative arrays, repeated edges and excluded self-implications. In m5 a term contributes only when its retained alternative list has length one; subjects each produce an edge except self-loops. PARSED_NEW first excludes external terms; LSTAR uses its declared table. Record exact parser source and data bytes and reject unknown names or malformed structures.

Future `scripts/historical_convex_evidence.py extract` executes a new read-only extractor in an isolated process over the pinned dependency closure and writes `instance-inputs.json`. A separate checker recomputes the fixed-source inventory and compares every vocabulary item, law term and extraction decision to literal Lean data; a digest or count alone is not an equality witness. Fixed-instance extraction validation does not prove the parser correct on arbitrary future strings. Any source/table change invalidates the instance binding and requires a new candidate.

The current audit records occurrences/distinct edges 13/12 for LSTAR and 16/15 for PARSED_NEW. Those are input expectations for this fixed source, not a new measurement. Preserve multiplicity metadata while the mathematical relation uses distinct pairs. Removing self-loops preserves reflexive-transitive reachability; prove that fact or state/use a relation with loops consistently. A self-loop-zero count after removal is not independent evidence about the original table.

### 4. Universal bridge and trust boundaries

New `lean/DefiHistorical/Convex/Data.lean` holds only fixed data/encodings. `Saturation.lean` defines a finite executable round that adds all immediate consequences of the current set and iterates it 58 times. Generalize its proof over any finite vocabulary of size n. Monotonicity, extensivity and strict-growth/finite-cardinality reasoning prove saturation by n rounds and equality to the least relation-closed superset. Prove, for every `S : Finset (Fin 58)`, `saturate i S = Defialgebra.ConvexGeometry.reachSet (edge i) S`. This is an all-input theorem including empty and full sets; neither enumeration of 2^58 subsets nor assuming that very equality is an acceptable premise.

`Instances.lean` proves each concrete edge relation's reflexive-transitive antisymmetry. Use a literal topological rank checked on every non-self edge and a general strict-rank path argument; do not take a printed SCC count as an axiom. A finite edge-check proof by ordinary kernel reduction is acceptable. Supply a decidability instance for reachability whose soundness/completeness follows from the proved finite saturation, not an oracle.

Instantiate the unchanged generic `reachCl_antiExchange_iff`, `thm_convex`, `unique_minimum_generator`, `ex_reachCl`, `ex_reachCl_union_ex` and `ex_oplus` with this same relation and representation. State every prerequisite, including closed-input premises for `ex_oplus` and finite/decidable instances. Define intrinsic extreme points via deletion and closure; then prove equality with the maximal-element predicate in the paper's reversed specialization orientation. Never define the two sides equal and call that a correspondence proof.

The exported concrete statements concern the encoded unary fragment, not full requirements, warrants, bans or grounding. PARSED_NEW's definite graph and LSTAR stay distinct. Source extraction, mathematical modeling and runtime-language correctness are separate boundaries:

1. Complete fixed input equality binds the Lean instance to captured source data.
2. Universal Lean saturation/reachability theorems establish every subset of that instance.
3. A line-by-line correspondence table maps m5's local Set loop initialization, monotone insertion, loop termination and return to the proved saturation specification. Its in-place traversal order is allowed to differ from synchronous rounds because both compute the least closed superset; demonstrate this invariant argument explicitly.
4. This reviewed algorithm translation is not a formal semantics for Node, Set, the parser or V8. Runtime execution remains bounded evidence. The final paper wording can assert the encoded fixed unary instance theorem and describe this correspondence with its trust boundary; it cannot state that arbitrary JavaScript executions were Lean-verified.

If the intended paper Cn cannot be tied to these exact unary rules, keep `cor:ourconvex`'s broader application open and publish the narrower instance bridge. No silently substituted UI helper or full-admissibility operator closes it. `prop:excost` is separate from the algebraic theorem and receives only a corrected cross-reference in this change.

### 5. Actual bounded execution contract

Keep `formal/v3/m5-convex.mjs` and its historical outputs unchanged. The new wrapper invokes the actual script in a fresh private output location with a clean allowlisted environment, no NODE_OPTIONS/preloads, an absolute Node binary/hash/version, repository revision and exact runtime read closure. Inspect side effects before invoking any changed dependency. Record cwd, argv, environment, UTC bounds, duration, exit status, signal/timeout and raw stdout/stderr; copy artifacts and verify their hashes. Do not mutate or call `f8`/old generators as a shortcut.

For both graph blocks, require exactly one occurrence of all expected counter families. Validate nonempty denominators and semantics, not just headings. The audit's actual expected tuples are:

| Family | LSTAR | PARSED_NEW | Scope |
| --- | --- | --- | --- |
| Equality | 32567, mismatch0 | 32567, mismatch0 | nonempty seeds of size1–3 |
| Union | 30856, failure0 | 30856, failure0 | only singleton/pair split i<j<k |
| Anti-exchange | 1700 states,5169336 tests,0 violations | 1697 states,5142758 tests,0 violations | deduplicated size≤2 closures incl empty; ordered distinct outside points |
| Composition | 1711 indices,1464616 pairs,0 failures | same indices/pairs/failures | i≤j generator indices, duplicates retained, empty omitted |
| Principal closure | 49/58 | 48/58 | singleton equality |

Distinct nonempty generator closures are1699/1696; these are not1711 independent states. Report exact duplicate/index semantics and all observed fields. The wrapper's success requires exact complete source-bound inventories and zero violations, independently of m5's exit0. Preserve actual mismatches as failures; missing, malformed, truncated, duplicate, timed-out, unreadable or source-drifted evidence is blocked. Do not synthesize expected output and label it an actual execution.

### 6. CLI and control contract

Future commands, all from repository root unless stated:

- `python3 scripts/historical_claims.py discover --candidate REV --out OUT`: bounded read-only discovery with exact file/hash inventory, 18 input claims and all selected occurrences; OUT must be new and outside the repository.
- `python3 scripts/historical_claims.py check --package PACKAGE`: offline, read-only schema/source/claim-site validation; preserve bytes and mtimes.
- `python3 scripts/historical_convex_evidence.py extract --candidate REV --out OUT`: exact fixed-source table/algorithm extraction records.
- `python3 scripts/historical_convex_evidence.py run --candidate REV --out OUT`: actual unchanged m5 execution and strict parsed counters.
- `python3 scripts/historical_convex_evidence.py check --package PACKAGE`: offline raw-log, source, table, denominator and artifact validation.
- `python3 scripts/test_historical_reconciliation.py --repo ROOT --out OUT`: actual CLI controls in fresh copied fixtures, never mutations of original sources.
- From `lean/`: `lake build DefiHistorical.Convex.Verify` and `lake env lean DefiHistorical/Convex/Verify.lean`. The initial missing-module failure is development scaffolding, not a mathematical counterexample.

Exit0 means a complete, nonempty package passed its declared checks; exit1 means readable bound content violates a claim/contract; exit3 means blocked/incomplete/unbound execution. A separate `scientific_claim_status` prevents a syntactically valid unresolved ledger or bounded pass from implying all claims proved. For a well-formed complete log, positive violation counters produce exit1; malformed/missing/duplicate blocks produce exit3. Ordinary nonzero tool failures retain their actual exit and cannot be reclassified as semantic counterexamples. Checks never acquire sources online.

The planned named inventory is `control-inventory.json`; all entries remain unexecuted expectations until implementation. Controls have immutable literal inputs and per-control expected exit/diagnostics with a valid sibling. Required negative controls: missing CL18; duplicated CL01; stale quote/hash; invalid supersession; one-pass/stabilized conflation; non-union-closure promoted to no lattice; wide clause promoted to non-majority; semantic-minimality misclassification; zero/truncated/duplicate counter block; nonzero violation with process exit0; generator-index denominator called distinct states; swapped instance labels/one changed edge; reversed reach orientation; missing empty-set domain; two-cycle antisymmetry counterexample; ex defined as max rather than intrinsic; source drift; and exposed-case promotion. Algorithmic mutants must actually execute the mutated candidate or proof obligation in a private copy; data/parser controls are labelled data/parser controls. No source-string-only test counts as semantic mutation evidence. Universal false statements use meaningful finite counterexamples or failed checked obligations with the appropriate successful control, never an arbitrary compiler error.

### 7. Dependency and publication boundaries

S9 operational sequential groups/context equivalence are accepted and are cited accurately under CL11. Sprint10/M2 operational interface binding is pending; M3 finite participants/initialized causal composition and M4 group simulation/schedule independence remain later packages. This historical graph work imports none of those future APIs and neither blocks on nor completes them. Static binding union is never advertised as the operational result.

Corpus-provenance-adjudication owns annotation identities, source adjudication, recovered/reconstructed artifacts and deployment/fidelity boundaries. Its source packets are proposed, not accepted financial facts. Claim correction can proceed independently using preserved source-level evidence; new empirical generalization claims require separately accepted corpus evidence. No 72-row,75-unit or29-dispute measure is silently merged with the historical58-symbol universe.

The twelve proposed evaluation cases all have recorded development exposure. The currently empty untouched selection remains `not_selected` and evaluation readiness remains `blocked_missing_freeze`; this plan selects or unseals no cases. Eager reads of `algebra/blind-test-set.json` by tables.mjs are recorded as input access, with no holdout credit. Any future evaluation needs its own kernel/library/taxonomy/translator/evaluator freeze, independent selection/exposure audit and actual observations. Full paper rewriting, replacing theorem statements, cost analysis, citation/literature renewal, visualizations and claims of broad environmental coverage are separate publication work.

### 8. Review and completion

Before implementation, freeze the plan, complete claim map, source closure and dependency statuses; obtain nonauthor GPT-6 and native Fable5.1 medium on the identical bundle. This draft's author is ineligible for that nonauthor review. Prior authorship of triage/source packets and historical audit must be disclosed; earlier advisory reviews are not this gate. GPT-6 stock harness implements; no Foreman. Final source and evidence require native Grok and Fable (`claude-fable-5-1[1m]`, `--effort medium`), actual returned identities where available, exact input hashes before/after and preserved timeout/unavailable attempts. Review is advisory, not a theorem proof.

The final inventory enumerates imported theorem and supplemental declarations dynamically with full statements, premises, module provenance and transitive axiom checks. No `sorry`, custom axioms or `native_decide` in accepted new proof closure. Separate generic, concrete-instance, counterexample and generated declarations. Bind complete scenario IDs to actual evidence; no fixed theorem-count target. Unresolved bridge prerequisites block bridge acceptance; explicitly deferred whole-paper work does not become completed through package delivery.

## Risks / Trade-offs

- Fixed-source extraction can agree on a shared mistake → bind complete records and inspect parser/translation decisions; limit the theorem to the encoded instance and disclose translation trust.
- Wider claims can hide behind corrected terminology → retain all18 ledger records and downstream review, plus exact rendered paper evidence.
- Historical snapshots can be rewritten accidentally → protect hashes before/after and use fresh output roots; old numerical disagreements stay visible.
- Broad induced-lattice refutations can be overcorrected → preserve the pure-negative no-upper-bound proof route and require full admissibility before strengthening.
- An executable universal theorem can be confused with V8 correctness → state the three separate evidence layers and leave formal runtime-language refinement out of scope.

## Migration Plan

The gate precedes all implementation. Freeze baseline and negative-control expectations, then deliver claim overlay/prose, bound data and universal proofs, wrapper/controls, and integrated reviews in that order. Parent owns commits/push/archive. Failed candidates and old reports remain immutable; rollback means reverting only new candidate edits, not deleting their evidence. This author draft creates no implementation files and records no fresh numerical, Lean or native results.
