# Deposit minted sUSDS, then quote it as hypothetical token0

This fixed illustrative workflow deposits **one raw USDS unit** at `chi = RAY`,
mints **one raw sUSDS unit**, and routes the actual minted-share output into a
hypothetical sUSDS-as-token0 quote. The native quote starts at `sqrtP = 2^96`,
liquidity `1`, and yields `sqrtP = 2^95`. Neither raw amount is WAD-normalized.
The quote register stores raw Q96 integers at scale 1; it is not a market-price
observation, pool storage, cash settlement or a spend of the minted shares.

[VaultQuoteWorkflow.lean](../../lean/DefiKernel/Composition/VaultQuoteWorkflow.lean)
uses one common finite universe, two registered templates and typed output
routing. The deposit exports `.amount susds`; the quote consumes that exact
`.priorOutput` and refuses a wrong asset, unavailable output or amount other than
this fixed native witness. The final ledger holds one USDS in the vault, one
unspent sUSDS at the recipient, and the native result in a distinct synthetic
`quoteSqrtP` asset. No price/USDS amount conversion is asserted.

The [native bridge](../../lean/DefiKernel/Composition/ShareQuote.lean) proves that
`Vault.convertToShares` returns the actual Word supplied to the native token0
library. `deposit_evaluates`, `deposit_effect_projection`,
`deposit_supply_projection` and `accepted_deposit_specialization` relate the new
concrete deposit to the accepted adapter at assets=shares=1. This is a model
specialization/projection and conversion witness, not full state/source or
bytecode refinement. `actual_financial_io` connects the resolved input and the
actual committed register balance to that same native computation.

One `ComponentContract` states unit-rate backing:

```text
total raw sUSDS shares ≤ vault USDS reserves
```

`matched_backing_change` proves that equal changes to reserves and issued shares
preserve backing. Both component preservation proofs invoke it: deposit changes
both by 1; quote changes both by 0. The quote's synthetic register delta is
excluded from financial backing. Initialization, concrete local guarantees,
two successful actual steps and every actual prefix are proved. There is no
undischarged universal `localGuarantee` premise or claim of general scheduling
preservation.

From `lean/`, using the pinned toolchain:

```sh
lake build DefiKernel.Composition.VaultQuoteWorkflow
lake env lean DefiKernel/Composition/VaultQuoteWorkflow.lean
```

The module checks ten nonempty, distinct runtime labels and fails on any false
result. Four refusal controls assert the exact reason, index, successful-prefix
length, complete ledger and capability store: wrong unit, unavailable output,
wrong share amount, and unfunded deposit. The successful prefix remains committed
when the quote refuses. A copied-source quote-guard bypass is rejected by the
wrong-amount control; an empty check inventory is blocked. These are two focused
controls, not a complete adversary campaign. Scoped axiom audit and `leanchecker`
replay check the new module; imported dependencies remain trusted and the checker
uses the same Lean kernel.

## New source accounting and limits

The [hash-bound count record](../../benchmarks/component-accounting/vault-quote-workflow.json)
covers all 279 physical lines of this new workflow file with explicit ranges:

| Attribution within this file | Model | Specification | Guidance | Excluded | Blank |
| --- | ---: | ---: | ---: | ---: | ---: |
| Deposit-specific | 28 | 13 | 8 | 4 | 6 |
| Quote-specific | 21 | 6 | 5 | 8 | 3 |
| Shared universe/routing/contract | 33 | 31 | 32 | 19 | 25 |
| Runtime verification | 0 | 0 | 0 | 35 | 2 |

These are manually reviewed primary-role source counts, not full-component costs
or a measured reuse ratio. Inline proof terms retain the line's primary role.
Inherited native libraries, the accepted adapters, `ShareQuote`, and the entrypoint
import are outside this file's counts. Shared source is reported separately.
The [earlier adapter baseline](../../benchmarks/component-accounting/README.md)
retains its own scope and original attribution.

The new code was authored through Codex. The count record captures a prospective
implementation-phase wall interval starting at 2026-11-17 10:04:49 UTC, excluding
earlier read-only investigation and including tools/waits. It is not active
authoring time or human/person-hours. Separate per-component time was not timed
and remains unknown; it is not split arbitrarily. AI authorship is not a copyright
ownership assertion.

II.1 remains open for its separate-effort reuse-measurement scenario: per-component
authoring effort is unknown, and the shared interval does not satisfy it.
Historical I.3 effort and outside reproduction I.4 remain open. This example does
not establish the full-domain correspondence in II.2, deployed equivalence,
market solvency or a distributable proof package. Source/proof behavior and the
unmet effort/reproduction evidence retain separate acceptance status.
