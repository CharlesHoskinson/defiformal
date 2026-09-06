# DeFi formal developments

Run from this directory:

```sh
lake build                  # historical algebra and new kernel pilot
lake build DefiKernel       # pilot, including its acceptance declarations
lake env lean DefiKernel/Acceptance.lean
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
implement capability issuance/revocation. Oracle feed and timestamp fields are
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
