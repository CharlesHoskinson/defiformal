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

## Current increment

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

## Full migration backlog

1. Finish claim-site reconciliation across the old paper and working ledgers;
   preserve original statements and attach scoped corrections. Audit the
   instance bridge behind structural/exhaustive claims.
2. Generalize the pilot's finite identity fixtures and complete dimensioned
   expression typing. Bind capabilities to permitted transition behavior;
   today's supplied policy accepts vault drain, unbacked issuance and debt
   erasure, now preserved as executable counterexamples. Complete the typed IR
   and operational semantics, including distinct composition operators,
   observations/refusals, assumptions, and certificates.
3. Normalize the corpus with source/deployment identity, recover or reconstruct
   the missing crosswalk/schema, and perform independent annotation and rule
   adjudication. Restore retrievable references from the source plan.
4. Build a real serialized certificate path and source-bound fidelity checks.
   Automate axiom-list coverage and replace format-sensitive mutation extraction
   as the language grows. Current disclosure and mutation coverage are bound to
   this snapshot; mutations do not yet cover execution or sequence functions.
5. Extend the initial proofs to operational composition, authority,
   noninterference, assume-guarantee discharge, claims and conservative extension.
6. Port adversarial financial libraries with pinned contract implementations,
   differential execution, mutation tests and selected refinement proofs.
7. Freeze the kernel and evaluation split, test untouched cases, report separate
   metrics, then update publication and ontology visualization.

Completing the pilot does not close these work packages. It does not establish
deployed protocol fidelity, general solvency, or a complete DeFi calculus.
