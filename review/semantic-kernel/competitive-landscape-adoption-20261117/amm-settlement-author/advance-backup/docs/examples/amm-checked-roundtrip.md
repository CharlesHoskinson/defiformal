# Checked Word same-pool reversal (2026-11-17)

[CheckedRoundTrip](../../lean/DefiKernel/AMM/CheckedRoundTrip.lean) calls the accepted
`Checked.swapPool` twice at the same fee: the second pool is the **actual first
post-pool with X/Y flipped**, and its input is the entire first output. All quantities
are integer raw units at scale1. The fee numerator/denominator and reserves/input
are 256-bit words; the accepted widened arithmetic and final output floor apply.
No new financial formula or executor replaces the checked operation.

`reverse_domain` proves that an admissible first swap with positive output admits
the reverse swap: both reserves are positive, the same fee remains valid, and the
reverse retained-input sum is `(originalY−output)+output=originalY`, which already
fits256 bits. `constructive_two_success` then proves both actual calls succeed,
without assuming the reverse result or additional headroom.

`two_success_no_profit` quantifies over arbitrary words and actual successful
forward/reverse results. It proves that the reverse post-X equals originalY and
the returned original-X amount is at most the initial input. It derives the bound
from both accepted product-nondecrease theorems and positive originalY. The
reverse axes are flipped; economically the final pool holds originalY and at
least originalX. This is a same-pool, full-output, same-fee theorem, not a claim
about external prices, other pools, partial reversals or general arbitrage.

A positive first input can floor to zero output. `zero_output_reverse_refusal`
proves the actual combined operation then returns `error badAmount`. The first
swap did succeed mathematically; the error carries no post-world/pool. No wallet
rollback, transaction atomicity or Typed settlement is inferred. If the first
output is positive but the reverse output floors to zero, both calls can succeed.

[The finite audit](../../lean/DefiKernel/AMM/CheckedRoundTripAudit.lean) checks nine
complete result/refusal comparisons: fee/no-fee loss, exact equality, originalY
at the maximum word, first-zero/refused reversal, and all four forward refusals.
With installed pinned Lean4.33.0-rc2 and its dependencies:

```sh
python3 scripts/replay_amm_checked_roundtrip.py --toolchain /absolute/lean-4.33.0-rc2
```

The CLI builds current proof source, freshly evaluates the source audit and
requires exactly9 nonempty unique labels and the exact completion record.
Intact execution exits0; a wrong expected return value exits1 after an actual
false comparison. Missing, empty, unreadable controls and an empty inventory
exit3. These are real CLI subprocess controls. Mutation probes execute copied
actual API prefixes with intact Checked imported, without importing cached
CheckedRoundTrip: omitted reserve flipping and the wrong reverse input both
produce false runtime observations. Separately, their unchanged full proofs
fail compilation. No cached intact module stands in for altered source.

The focused math axiom audit checks5 theorem constants and2 supplemental
declarations with forbidden dependencies0; named disclosures use only standard
Lean axioms. Default kernel replay checks the exact CheckedRoundTrip module with
the same kernel and trusts imports. [Accounting](../../benchmarks/component-accounting/amm-checked-roundtrip.json)
uses explicit physical ranges and records a shared prospective wall interval,
not active effort or human/person-hours. Historical per-component authoring
costs remain unavailable. Actual Typed wallet conservation, source/EVM refinement
and outside reproduction/adoption remain separate obligations.
