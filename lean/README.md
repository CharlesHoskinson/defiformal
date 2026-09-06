# DeFi formal developments

Run from this directory:

```sh
lake build                  # historical algebra and new kernel pilot
lake build DefiKernel       # pilot, including its acceptance declarations
lake env lean DefiKernel/Audit.lean  # fresh runtime output and axiom disclosure
lake env lean DefiKernel/ContractAudit.lean  # trusted operation-contract runtime checks
lake env lean DefiKernel/VerifyAxioms.lean   # automatic imported-module axiom audit
```

Use the versions pinned in `lean-toolchain` and `lake-manifest.json`.
For a fresh dependency checkout, `lake exe cache get` obtains the mathlib cache.

`Defialgebra/` retains the historical mathematical results and counterexamples.
`DefiKernel/` is the first executable increment of the
[approved migration](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md).
The [progress ledger](../docs/research/semantic-kernel-progress.md) records the
observed verification and independent review status.

## Pilot scope

- Four account identities and four asset identities; exact rational quantities.
- A generic checker for guards, net-debit and supply authority, nonnegative
  balances, asset-wise accounting, and write footprints.
- Transfer, a vault with a fixed exchange rate, and collateralized borrowing
  using a declared oracle observation, all through the same transition type.
- Lean proofs relating successful execution to its checks, accounting and
  locality, plus a frame lemma with an explicit predicate-dependency premise.
- Concrete accepted/refused examples and deliberately broken transitions.

The supplied policy is a trust assumption. It does not authenticate callers or
implement capability issuance/revocation. In particular, the fixture grants
permissions without binding them to transition shape: it accepts a vault drain
without share burn, share issuance without a deposit, and debt erasure without
repayment. Accepted counterexamples make this boundary explicit. The generic
accounting and policy-relative authority theorems still hold for those effects;
the fixture is not a safe policy for a financial application.

The operation-contract layer adds a separate execution boundary. Trusted
application code selects an operation contract and its parameters; an untrusted
proposal supplies the transition to check. Library contracts compare the actor,
complete asset/account effects and supply changes against those parameters.
Borrow contracts independently check the declared oracle and collateral rules,
so replacing a proposal's own guard with `true` cannot remove those rules.
Contract refusal and original kernel refusal remain distinguishable.

This boundary is conditional on trusted contract selection. The original broad
policy and its accepted counterexamples remain unchanged. The new layer does
not authenticate a caller, issue or revoke capabilities, or guarantee safety
when untrusted code can choose its own contract or trusted parameters.

Oracle feed and timestamp fields are
declared inputs; checking them does not establish provenance or market truth.
Debt is represented as a distinct nonnegative obligation token in the reference
example. This is not a general party/claim lifecycle model.

The pilot accepts Lean functions for guards and effects. It is not yet a closed,
serialized IR or a checker for untrusted external proof packages. It does not
prove general operational composition, intermediate-effect authority,
machine-width arithmetic refinement, deployed-contract correspondence,
economic solvency, or asynchronous liveness. These remain migration obligations.

Lean proof terms are the current evidence format. Concrete acceptance theorems
check their stated examples; they do not establish corpus-wide adequacy.
`Audit.lean` retains the first increment's manual disclosure list.
`VerifyAxioms.lean` runs an automatic audit of elaborated theorem constants in
imported modules under the `DefiKernel` module prefix. It reports theorem names,
origin modules and transitive axiom dependencies, and rejects an empty theorem
scope or dependencies outside `propext`, `Classical.choice`, and `Quot.sound`.
It also inspects imported definitions, opaque declarations and unused axiom
declarations in that scope, so an unused custom axiom or a definition containing
`sorry` cannot hide behind the theorem-only dependency check.
Discovery does not depend on source-text formatting or a manual theorem list.
It covers the import closure, including generated theorem constants; unimported
files and declarations in the audit command's current module are outside scope.
