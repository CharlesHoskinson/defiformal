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
| Research mandate and entry-point supersession | In progress | README and AGENTS.md |
| Generic Lean pilot and three reference examples | In progress | GPT-6 native implementation agent |
| Grok review | Pending candidate | Requested model `grok-4.6`; `grok models` advertises it |
| Fable review | Pending candidate | Requested model `claude-fable-5-1` |

The baseline is a measurement at the starting revision, not a claim that future
changes build. Final evidence and exact reviewed sources will be recorded under
`review/semantic-kernel/2026-09-06/`.

## Full migration backlog

1. Finish claim-site reconciliation across the old paper and working ledgers;
   preserve original statements and attach scoped corrections. Audit the
   instance bridge behind structural/exhaustive claims.
2. Complete the typed IR and operational semantics, including the distinct
   composition operators, observations/refusals, assumptions, and certificates.
3. Normalize the corpus with source/deployment identity, recover or reconstruct
   the missing crosswalk/schema, and perform independent annotation and rule
   adjudication. Restore retrievable references from the source plan.
4. Build a real serialized certificate path and source-bound fidelity checks.
5. Extend the initial proofs to operational composition, authority,
   noninterference, assume-guarantee discharge, claims and conservative extension.
6. Port adversarial financial libraries with pinned contract implementations,
   differential execution, mutation tests and selected refinement proofs.
7. Freeze the kernel and evaluation split, test untouched cases, report separate
   metrics, then update publication and ontology visualization.

Completing the pilot does not close these work packages. It does not establish
deployed protocol fidelity, general solvency, or a complete DeFi calculus.
