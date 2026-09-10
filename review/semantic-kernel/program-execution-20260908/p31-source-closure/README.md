# P31 runnable source preparation

The source pin remains Moriarty commit 7307349d0275af6fcb4144e1661d8b59d6b2663a. The original13 files are unchanged. TypeScript AST inspection adds frontend.ts, registered-bounds.ts, parser.ts, checker.ts, validate.ts, diagnostics.ts, and exact spec/bounds.json:20 files and40 dependency edges, with no unresolved edge in the inspected forms. Node fs, crypto and util remain host dependencies.

The captured upstream simulate.mjs and its loan.mori and swap.mori inputs ran unchanged under Node24.18.1. All four actions produced Simulation; their adverse controls refused with EXACT_PLAN_MISMATCH (loan accrue/settle), GUARD_FAILED (swap), and PRINCIPAL_BINDING (close). All four evaluate calls without a backend refused with PROOF_INVALID. Loan settlement closes the episode while the agreement remains Outstanding, exactly as the captured output records. This is local simulation, not ledger settlement or accepted proof consumption.

manifest.json binds the static import/export, literal dynamic import/require and new URL closure. example-inputs.json separately binds the exact upstream example and its two explicitly enumerated dynamic paths. simulation-receipt.json binds the command, source manifests, Node binary and raw outputs. root-observations.json records the checks root actually inspected. The capture does not prove all possible runtime filesystem access is closed.

The initial scanner setup failed before scanning because installed TypeScript7 does not expose the old5.x AST API path. attempt1 preserves its original scripts and partial source bytes. The successful scanner uses isolated TypeScript5.9.3, installed without lifecycle scripts; scanner-package-lock.json pins the package integrity. The global compiler was not changed. No scanner failure receives proof or execution credit.

This resolves the missing frontend/bounds capture for these examples. DeFiKernel adapters, Lean correspondence, ZKIR format, Compact compiler arithmetic semantics, and accepted P20 certificate consumption remain open. Independent Grok review of this supplemental preparation is pending; the prior source-readiness review covered the earlier13 files only.
