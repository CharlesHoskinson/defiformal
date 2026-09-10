# P17 implementation partial state (author, not acceptance)

Worktree: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`
Author: native Grok 4.6. Independent Opus reviews the eventual full frozen candidate.
Source execution: **false**. Platform reuse: **false**. Not candidate-ready.

## Lean (this continuation)

- Adapter cell-equality, `Finset.sum_ite_eq` party accounting, `True` after `cases`, `req.operation` vs `depositOp`: `adapter-diag4` exit 0, `adapter-lake-build` exit 0. Source SHA `783502a0d6d5dbbe08a6a8608bcd4086428e7b6d485f042594a715e024283521`.
- Token0Bridge symbolic ordinary-add + singleton-cell proofs: `token0bridge-diag3` exit 0, lake build exit 0. Source SHA `bbf0b2a73d55f3e38fee1fbe226e3fa1ce54613cd9d819e8374a0a526858f2eb`.
- Operations mint now returns previewMint assets (D1 check). RuntimeAudit: all 20 named checks true (`runtimeaudit-diag2` exit 0).
- `lake build DefiKernel.Vault.RuntimeAudit DefiKernel.Vault.ProofAudit DefiKernel.Vault.Verify` exit 0, 9.3s. Nonempty axiom audit for `DefiKernel.Vault` and `DefiKernel.ConcentratedLiquidity.Token0Bridge`. No forbidden axioms. Conversion/Operations prior exit-0 receipts preserved.
- Carry-forward: generic `bind_ok`/`bind_error`; no `simp [bind, Except.bind]` over unevaluated convert/preview/Word.checked. `@[irreducible]` is not the kernel fix.

## Engine (started, incomplete)

- `scripts/platform_engine/` shared compile/score/prestate. Fail-closed: empty rows exit 3.
- Vault compile with pinned solc 0.8.21 sha `f2857a…`, shanghai, bytecodeHash none: `vault-compile3` wrapper exit 0, 8 contracts, captured `src/SUsds.sol` sha `9fe0c713…`, mocks labelled separately. `vault-compile2` wrapper exit 3 is a Python `0 or 3` bug on an otherwise successful solc receipt; do not relabel it as success.
- Token0 compile through the same engine (`token0-compile1` exit 0, 7 contracts, istanbul/0.7.6). Frozen Token0Probe sha `cc120019…` unchanged.
- Fail-closed `score_rows([])` exit 3, one-fail row exit 1.
- Not done: Shanghai genesis/state-dump roundtrip, initialized proxy, 16+RR-5 fixtures with 19 cells/full logs, V-TF-SKIP/V-DEP-CEIL compiled mutants, RR-1..RR-5 errata, case-two inventory.

## Do not

Overwrite failed receipts. Restart package discovery. Merge to main. Atlas. Foreman. Self-accept `P17.platform_reuse`.
