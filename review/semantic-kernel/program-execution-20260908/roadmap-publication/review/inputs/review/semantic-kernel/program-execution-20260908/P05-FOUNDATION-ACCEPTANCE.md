# P05 foundation acceptance

ACCEPT_WITH_LIMITATIONS for program task 6.1 only. The four exact native Grok
foundation modules are integrated with an import of CapabilityProvenance.Trace
in the kernel entry point. Independent GPT-6 accepted initialized sequential
origin, allocation, tombstone, current-authority, prefix-retention, and selected
observation results. The scope does not include whole P05 acceptance.

The candidate archive SHA-256 is
`7fc31431a2b5d6f0198f8a182fcd31a35b90d323c076c1c0bc000c9a3b30c52a`.
The independent review manifest SHA-256 is
`97aa32bc405e1608b0b52138409dd03c8e41486d6297b5e90225c598797915ea`.
See `p05-review/REVIEW.md`, `verdict.json`, and
`accepted-evidence-manifest.json` for exact statements, dependencies, limits,
tool identities, and retained historical evidence.

The mandatory correction overlay is part of this acceptance. Actual counts are
23 original checks plus seven additions, for 30 passing candidate checks. The
author's historical 22/29 counts are incorrect and remain unchanged as evidence.
The old `foundation.revoke.keeps.id` row checks a peer ID; it does not demonstrate
revocation of the target ID. The old `foundation.current.skips.dead` row has an
incompatible right and does not isolate liveness. Neither gets that credit.
The r2 same-grant issue/revoke/issue rows and the retained eight-comparison
`p05-review/RevocationAudit.lean` supply actual revoked-ID discrimination, a live
sibling, and a stale-store negative. The audit and successful raw log are required
delivery evidence. `p05-review/check-inventory.json` records all labels.

Fresh primary verification passed the kernel build, 30 candidate comparisons,
and eight reviewer comparisons. The initial root log parser expected the wrong
reviewer-label prefix and exited 1 after all Lean subprocesses had exited 0.
`p05-primary-validation/log-reconciliation.json` preserves that bookkeeping
failure and the corrected tally from unchanged raw logs. No Lean rerun was
claimed for this correction. All 25 candidate archive members and 173 preexisting
Lean/configuration files, apart from the separately recorded root import, remain
unchanged through integration.

Independent inventory covers 2,495 imported project declarations, including
939 theorem declarations. The candidate contributes 158 explicit declarations
and 91 explicit theorems; generated declarations use a separate denominator.
All 71 prior theorem headers are preserved. The transitive axiom inventory has
no forbidden dependencies. These are mathematical model results under initialized
trace and trusted-root premises, not deployed authentication or confidentiality.

Original r1/r2 archives and native receipts are retained in `p05-retained-inputs/`;
`p05-integration.json` maps historical absolute paths to their exact published
copies. Native author terminals report `grok-4.6-build` and normal completion.
The independent reviewer was requested as `gpt-6-astra`; no separate returned
provider model identity is available. No Foreman was used.

Tasks 6.2–6.5 remain open for package-wide evidence, Isolation, full F01–F20
fixtures, fourteen compiled production mutants, inherited-control adaptation,
and final review/delivery. No whole-sprint or whole-program completion is granted.
