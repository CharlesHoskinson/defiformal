# Provisional Sprint10 peer-continuation correction

The bounded constructibility finding is addressed in the provisional draft.
Original F17 remains required. F19 uses the same branches under left,left,right:
paired debit reaches4/4/2, left refusal retains4/4/2, and the right peer then reaches
3/3/4. F20 adds a failed left mint suffix under left,left,left,right: the skipped
token advances only consumed, adds no attempt/receipt/supply, and the peer still
executes. Both bind exact failure, histories, local indices, full store and actual
attempt order independently in the design. No fixture was executed by this task.

Strict validation passes:4 capabilities,17 requirements,57 scenarios,34 unchecked
tasks,20 fixture contracts,14 planned mutants and65 inspected controls. RA12/RA13
are new scenarios; related total/binding requirements and tasks explicitly cover
the companions. Failed and exhausted identities remain separate generic proof
cases. Author coverage and all exact source/tool bindings were regenerated.

The prior draft/author evidence is preserved under
`before-peer-continuation-companion/` with a verified snapshot manifest.
The independent `provisional-constructibility-gpt6.md` report is retained unchanged;
it was a bounded reading, not official planning acceptance. No native review,
Lean implementation or proof, mutation/control run, provider call or commit was
performed. Accepted/delivered Sprint9, real M1 API/source refresh and the official
independent planning gate remain required; no current M1 API existence is claimed.

Sprint10 wiki was deliberately left unchanged because Sprint9 author evidence
binds its hash. Reconcile its historical outline after the active Sprint9 review
window. This task wrote no Sprint9 files. The final frozen-input readback is in
`peer-continuation-resolution.json`; concurrent root-owned Sprint9 revisions, if
present, are listed rather than misreported as unchanged source. All Sprint10
files written by this task are now stable.
