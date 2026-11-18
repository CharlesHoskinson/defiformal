# Full-domain deposit correspondence implementation plan

Baseline: `95352f1b386cbedd831ed03d7906f36c160ea8b2`. Destination: `semantic-kernel-pivot`. Preserve historical theorem statements and source evidence. Use Codex author / independent Astra medium review and isolated cached source/build state.

- [ ] Add `Vault.ConversionDomain`: admissible Word256 assets and Word192 chi satisfy positive chi and a bounded checked product with RAY. Derive the floor quotient Word bound; prove native `convertToShares` returns it without assuming a successful result. Prove natural floor inequalities and the raw-scale rational interval. Preserve overflow-before-zero-rate refusal ordering and show quotient overflow impossible on the admissible domain.
- [ ] Freeze, verify, review and integrate this indispensable arithmetic obligation before extending it.
- [ ] Add `Vault.ComputedDeposit`: native conversion feeds its actual returned Word into the existing typed deposit adapter. Separate native arithmetic failures from typed refusals. Prove generic `execute_ok_iff` over all admissible assets/rates with pointwise ledger effects and explicit zero fee; recover the fixed-WAD case as a corollary.
- [ ] Exercise zero assets, nonunit rates, inexact floor rounding, overflow and zero-rate refusals, with a meaningful negative control. Run pinned build, nonempty fresh axiom audit and kernel replay; independently review the frozen candidate and integrate accepted source.

Exact quantities use raw scale 1. Rounded shares are bounded against the rational quotient, not equated to an unrounded value. This extends arithmetic-to-typed-model correspondence; it does not claim full native Ledger, Solidity or bytecode refinement. Record prospective implementation intervals separately from unavailable historical effort. Keep incomplete criteria open.
