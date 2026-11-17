# Checked conversion drives a computed vault deposit

[ComputedDeposit.lean](../../lean/DefiKernel/Vault/ComputedDeposit.lean) generalizes
the fixed-WAD adapter over arbitrary `Word 256` asset amounts and `Word 192`
rates. The caller, receiver, registry/request pattern and asset identities remain
those of the accepted vault adapter. Capability stores and Typed prestates are
parameters; actual execution checks are retained.

[ConversionDomain.lean](../../lean/DefiKernel/Vault/ConversionDomain.lean) proves
that native conversion succeeds exactly when:

```text
0 < chi.value
assets.value * RAY < 2^256
```

The second condition is the native checked multiplication bound. The output
Word is constructed from `assets.value * RAY / chi.value`; its bound is derived
from division being at most the bounded product. There is no supplied successful
output or quotient-bound premise. Amounts are lifted at raw scale 1, without WAD
normalization. For computed raw shares `q`, the rational contract is:

```text
q ≤ assets * RAY / chi < q + 1
```

`word_rational_correspondence` combines native computed success, this interval
and equality of the executable wrapper to the exact-rational Typed transition.
`execute_ok_iff_computed` exposes invoke authority, all evaluated validity checks,
capability preservation and every balance update. `funded_success` constructs
actual successful execution for every admissible amount/rate with the supplied
funded prestate and real grants. It is not merely conditional on execution
succeeding. `fixed_wad_corollary` recovers the historical adapter from the generic
result; the original theorem statements are unchanged.

The wrapper charges **zero fees**. `zero_fee_effects` proves that a successful
call debits the sender's full asset amount, credits that same amount to the vault,
and credits the computed floor shares to the receiver. The floor interval keeps
rounding dust explicit; unrounded equality is not claimed.

## Refusals and scope

`run` returns `Except (Vault.Failure ⊕ Typed.Refusal) ...`:

- `.inl .mulOverflow` occurs when the checked product does not fit, including
  when the rate is also zero. Multiplication has precedence.
- `.inl .divisionByZero` occurs for a bounded product and zero rate. A floor
  quotient overflow is proved impossible; the arithmetic-error classification
  is exhaustive for this converter.
- `.inr reason` preserves the actual Typed execution refusal after arithmetic
  succeeds, including missing authority or insufficient funds.

A refusal carries no post-world. The supplied prestate is not promoted into an
observed rollback result. The rate is an explicit input. This correspondence is
for checked conversion plus the existing Typed deposit model; it does not prove
the full native `Vault.Ledger` operation, its allowance/address/accrual or stored
word-overflow behavior, or pinned Solidity/bytecode refinement. Those require
separate state relations and proofs.

## Run the checks

From `lean/` with the pinned toolchain:

```sh
lake build DefiKernel.Vault.ComputedDepositAudit
lake env lean DefiKernel/Vault/ComputedDepositAudit.lean
```

[ComputedDepositAudit.lean](../../lean/DefiKernel/Vault/ComputedDepositAudit.lean)
runs twelve nonempty, distinct controls and fails on a false result. Successful
cases compare the complete Typed ledger and capability store against an
independent expected table. Cases cover zero assets, unit and nonunit rates,
inexact floor rounding, a zero-share floor result, WAD specialization, zero rates,
checked multiplication overflow and its precedence, and exact native/Typed error
constructors. The module also runs nonempty axiom audits of the quantified
conversion and wrapper proofs.

A focused mutation changes the actual wrapper model body from native floor
conversion to native ceiling conversion: raw assets 3 at rate `2 * RAY` mint 2
instead of 1. Both model prefixes compile; the explicit floor control changes
from true to false. The full mutated wrapper is separately rejected by its
existing generic proof. The prefix extraction is explicitly bounded before the
proof section, not represented as an accepted full mutant proof module. This
focused control is not a broad adversary or source-refinement campaign.

The scoped audits and `leanchecker` replay use the same pinned Lean kernel and
trust imported dependencies. Counts include generated declarations. The new
implementation interval starts at 2026-11-17 10:29:11 UTC, excludes preceding
read-only investigation, and includes tools/waits. Command timings and that wall
interval are not active authoring time, human/person-hours or reconstructed
historical effort. Historical I.3 and the II.1 separate-effort measurement scenario,
I.4 outside reproduction, and Phase III distributable evidence remain separate.
