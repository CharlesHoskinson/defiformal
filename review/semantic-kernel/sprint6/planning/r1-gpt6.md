# Sprint 6 independent GPT-6 planning review — R1

Verdict: **REQUEST CHANGES**

Candidate: `a3b2dec486de281080a84ae5f7cfc0da39d066a9`.
Bundle SHA-256: `e96a1e761257bfc3b43e845f0a9f48951a66363ae1980574dec3caf94a66a814`.
Requested model: `gpt-6-astra`.
Exposed runtime identity: stock Codex subagent `/root/sprint6_plan_gpt6`; the session identifies the agent as Codex based on GPT-6. No separate provider-reported concrete model/build identifier was exposed to this reviewer. The requested model is not presented as an independently observed runtime build.
Method: independent source/planning analysis and executed byte-identity checks. No Lean implementation, theorem compilation, runtime financial experiment, or mutation execution was performed by this reviewer. No Foreman was used. This report does not adopt or infer another reviewer's verdict.

There is one blocking planning finding. The proposed dependency and serial-correspondence argument is otherwise coherent against the inspected executor, but one mandatory output-history fixture cannot occur under the stated compatibility and catalog rules. This is not a request for implementation evidence before the planning gate.

## Reviewed identity and evidence

I read the R1 bundle and candidate manifest, all eight OpenSpec candidate files, and the relevant Typed/Composition source. I executed SHA-256 checks against `git show <candidate>:<path>` for all 20 entries of `r1-candidate.json`. Every committed hash matched the manifest; the working files also matched at that initial check, when HEAD was the candidate above. I independently computed the bundle digest above. All 20 embedded bundle source payloads matched the committed text after excluding separator newlines. The 24 entries of `source-context.json` matched both its recorded base `c71d61b137014360364c3eeba733df6cada2aff3` and the R1 candidate's Git objects.

The working OpenSpec files changed during review as the orchestrator began a revision. This verdict remains on the frozen R1 bundle and Git objects; the original output scenario and tasks were re-read directly with `git show`. An executed strict OpenSpec validation returned exit 0, but it ran against that changing working tree, so it is **not** claimed here as R1 validation evidence. No result from later planning bytes is an approval of R1.

The existing graph query returned historical material rather than the new Typed/Composition scope. It was not used as evidence for semantic claims. The source definitions are the basis of this review.

## Blocking finding B1: the distinct-value fully qualified collision fixture is impossible

Affected R1 clauses:

- `specs/parallel-workflow-execution/spec.md`, “Colliding local output keys” (lines 40–42): both branches emit the same local step/port key with different values and subsequently consume their own values.
- `design.md` decisions 1 and 7: output keys use `QualifiedPort`; the negative inventory asks for colliding keys, and mutant 10 asks for shared history or collision misrouting.
- `tasks.md` tasks 4.4, 6.4 and 7.4, together with the requirement to give every scenario nonvacuous evidence.

The issue follows directly from existing code:

1. `Composition.QualifiedPort` contains component and port identity (`Composition/Interfaces.lean:16`). `OutputPort` selects a fixed concrete `cell` (`:26`), not a caller-relative cell or an arbitrary expression result.
2. `Component.portIds` collects every output/input/export port ID; `validateCatalog` requires unique component IDs and unique port IDs within each component (`:100`, `:106`). Consequently, in a valid fixed catalog one fully qualified output port selects one fixed cell `c` and one intrinsic amount unit.
3. `snapshots` copies the selected post-state balance at that cell (`:163`). The R1 analysis includes every selected output cell in reads and aggregates regions over the entire branch.
4. If both branches emit the same `(localStep, QualifiedPort)` key, then `c ∈ R_L` and `c ∈ R_R`. Compatibility requires `W_L ∩ R_R = ∅` and `W_R ∩ R_L = ∅`, so neither branch can write `c` anywhere in its submitted workflow.
5. Actual successful invocations frame cells outside their writes. Therefore both snapshots must equal the same initial balance at `c`; their units also agree. Different values cannot occur, including when one tries to change `c` in an earlier local step, since admission uses the complete branch regions.

For a concrete failed attempt, let the shared qualified port select Alice's USD cell with initial balance 10. To obtain snapshots 7 and 10, the left branch must change that cell. The right branch's output read then rejects admission. If the left branch does not change the cell, both values are 10. Additional authority or funding cannot cure this conflict. Using two components with the same numeric port ID can give distinct values, but those are different `QualifiedPort` keys and are not a fully qualified collision.

Treating the scenario as a vacuous implication would violate the required nonvacuous fixture/evidence coverage. Altering the old catalog or snapshot semantics to manufacture the example would exceed this sprint's scope.

Concrete correction:

- Replace the distinct-value collision scenario with two explicit admissible cases: equal local step/numeric port IDs in distinct components selecting different cells retain their distinct **component-qualified** values; identical fully qualified keys selecting a common read-only cell retain equal snapshots as separate **branch-labeled** observations.
- Make the leakage negative explicit: at local index 1, a branch requests a step-0 fully qualified output key which exists only in its peer's history. The original branch must refuse `.interface .unavailableOutput`, even when the peer's value has the right unit and would enable funded, authorized work. Its own step 0 can emit another key or no output. Supply a matching sibling where the requested key is present in its own history, or an equivalent literal enables the work.
- Mutant 10 must have a designated oracle that detects actual peer-history leakage using that peer-only-key negative. A separate loss-of-component-qualification mutation can use the distinct-component/different-value fixture. Equal-value fully qualified collisions alone cannot detect a swapped value source.
- Update design, tasks and coverage consistently, retaining complete expected observations and both serial references. Do not weaken the output-cell read set or change old output semantics.

## Semantic and feasibility assessment of the remaining plan

**Complete dependencies and refused behavior.** The read/write definition covers every syntactic expression arm, declared reads, all declared writes, all delta targets, and snapshots. In the old AST the only ledger access is `Expr.balance`; observation lookups and `now` use fixed boundary inputs. `Template.evaluate` resolves metadata and evaluates guards, deltas and supplies; its complete result is determined by those reads and fixed non-state inputs. `applyEvaluated` has exactly one further ledger dependency: its global sufficient-funds test. The plan correctly requires zero effect outside resolved delta targets before that test and does not assume the later `writesOK` check. Outside the target set, proof-carrying nonnegative balances make the sufficient-funds conjunct true. Inside it, equal balances and equal effects make the conjunct equal. Thus exact `.insufficientFunds`, `.accounting`, `.writeFootprint`, and earlier refusal precedence can be preserved without assuming success. I found no additional ledger dependency in the inspected closed executor.

**Admission versus branch refusal.** `Composition.prepareInvocation` normally resolves inputs before access checking. Preflight deliberately moves structural checks ahead of runtime, including unreachable suffixes. The plan explicitly declares that new admission behavior and limits LR/RL equivalence to admitted input; it does not incorrectly equate admission refusal with the old sequence's first runtime refusal. Numeric/unit/history/capability failures remain local runtime outcomes after structural admission. No initial-state success oracle is used to certify independence.

**Isolated execution and immutable capabilities.** `Composition.run` begins with empty events/output history and index zero; a failed cursor retains its prefix and makes continuation inert. Two calls therefore implement independent refusals as specified. Invocation execution preserves the store, while issue/revoke are excluded by the branch type. `hasAuthority` reads reusable exact rights from the store and does not consume them. Shared capability identifiers can therefore be admitted when their ledger regions satisfy compatibility. Branch/local-index boundaries preserve caller, environment and time under reordered branch execution. This claim remains conditional on those trusted inputs, with no authentication or provenance theorem implied.

**Merge and canonical observation.** Selecting balances within disjoint write regions and the initial balance elsewhere is compatible with existing locality proofs and constructive nonnegativity. Supply is taken from real receipts rather than inferred from the result. Canonical observations retain operation/resolved request data, evaluated receipts, immutable outputs, refusal positions/reasons, both branch identities, full joined ledger and store. Omitting foreign raw event worlds is necessary: a serial second branch has a different foreign pre-world even when it cannot depend on those differences. The plan does not erase meaningful output or refusal fields merely to make equality hold.

**Actual LR/RL correspondence and non-circularity.** Both references run the actual existing executor again from the first branch's final world, reset local history, and still execute the second branch after a refusal. The proposed proof chain is viable: prove single-invocation congruence and frame facts; lift over the runner with equal local histories and dependency-region agreement; use cross-disjointness to establish that agreement after the peer; identify the serial final ledger with the region merge. The planned theorem quantifies over all admitted finite branches and nonnegative states, not only example success paths. Local contract obligations remain only in the optional invariant-preservation layer and cannot substitute for executor dependency proofs.

**Accounting, authority and initialized invariants.** Existing `StepSound`, `TraceSound`, `run_accounting`, and `Supports` provide the intended ingredients. Joined accounting follows from disjoint effects and the two receipt supply sums, or from serial correspondence plus sequential accounting and receipt congruence. Authority can be transported to the initial store because all invocation prefixes preserve it. For two supported initialized ledger predicates, own-branch preservation plus peer-disjoint support transports each predicate from its isolated final state to the join. This does not require circular assume-guarantee premises or generic solvency.

**Scope and evidence tasks.** The 47 planned scenarios cover success, first/middle/dual refusal, empty branches, both conflict directions, hidden reads, boundaries, histories, supply, frames and review/delivery gates. Fourteen mutation classes and full-inventory/positive-control requirements are stated, with compile failures and vacuous inventories excluded from semantic detection. All legacy suites, imported axiom closure, source identities and historical preservation are explicit acceptance obligations. Except for B1, I found no missing class that requires a planning blocker. This is a substantial proof sprint, but the AST is closed, branch composition is binary and finite, and administrative steps/interleavings/associativity are excluded; no contradictory proof scope was found.

## Optional implementation guidance and extensions

These are not additional blockers and do not waive any SHALL.

1. Reuse `Typed.Expr.eval_congr` and `Typed.Expr.eval_congr_of_resolved`. They already prove full evaluation-result congruence by syntax induction. New code should connect accepted footprint membership to their premises rather than duplicate the existing syntax proof. Template/executor and branch lifting remain new obligations.
2. Analyze redundancy for every dependency mutant, not only write/write removal. Omitting syntactic reads can be masked by declared reads on a normally successful template. Use a structurally valid, funded/authorized undeclared-read case whose underlying executor would refuse its read-footprint check, or a justified explicit composite edit. Likewise, declared writes can mask omitted delta targets. Zero/cancelling undeclared targets give an admission-sensitive control without requiring successful unauthorized effects. The plan already requires redundancy analysis; these are concrete ways to fulfill it.
3. Make the final scenario map more precise than broad section ranges by linking individual check names and theorem statements. This is already required by tasks 6.6 and 8.2; the broad planning map is not current execution evidence.
4. An explicit lemma that a shared fully qualified snapshot key has equal values under compatibility would document B1's repaired fixture, but is an optional additional theorem rather than a prerequisite beyond the corrected test obligations.

## Gate result

R1 does not pass the planning gate. Resolve B1 in a committed candidate and obtain the required audits of that candidate before implementation. This report makes no claim about another provider's availability or verdict, and no implementation acceptance claim.
