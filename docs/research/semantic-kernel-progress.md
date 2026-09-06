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

## Full migration backlog

1. Finish claim-site reconciliation across the old paper and working ledgers;
   preserve original statements and attach scoped corrections. Audit the
   instance bridge behind structural/exhaustive claims.
2. Generalize the pilot's finite identity fixtures and complete dimensioned
   expression typing. Extend trusted operation contracts to capability issuance,
   revocation and authenticated selection. The original supplied policy accepts
   vault drain, unbacked issuance and debt erasure; the new wrapper rejects
   those proposals under the selected reference contracts. Complete the typed IR
   and operational semantics, including distinct composition operators,
   observations/refusals, assumptions, and certificates.
3. Normalize the corpus with source/deployment identity, recover or reconstruct
   the missing crosswalk/schema, and perform independent annotation and rule
   adjudication. Restore retrievable references from the source plan.
4. Build a real serialized certificate path and source-bound fidelity checks.
   Extend automatic imported-module axiom coverage to explicit future package
   manifests and replace format-sensitive extraction as the language grows.
   Current mutations cover original checker branches and the new wrapper's
   contract/borrow checks; general effect application and sequence mutations
   remain open. Audit coverage is bound to the actual import closure.
   Review follow-ups include explicit inductive audit roots, a current-module
   exclusion fixture, script-output hygiene across multiple checkouts, and
   mutations that weaken individual actor/effect/supply comparisons.
5. Extend the initial proofs to operational composition, authority,
   noninterference, assume-guarantee discharge, claims and conservative extension.
6. Port adversarial financial libraries with pinned contract implementations,
   differential execution, mutation tests and selected refinement proofs.
   Extend the reference operations with repayment and trusted-effect locality
   results; the current debt-erasure test is rejection as a borrowing proposal.
7. Freeze the kernel and evaluation split, test untouched cases, report separate
   metrics, then update publication and ontology visualization.

Completing the pilot does not close these work packages. It does not establish
deployed protocol fidelity, general solvency, or a complete DeFi calculus.
