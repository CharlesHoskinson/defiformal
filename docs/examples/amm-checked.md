# Checked Word AMM quote and reserve update (2026-11-17)

`DefiKernel.AMM.Checked.swapPool` takes 256-bit unsigned X/Y reserves, X input, and fee numerator/denominator. All values use raw scale 1; X/Y are semantic asset labels, with Typed asset/ledger interfaces remaining separate. The successful domain is exactly positive reserves/input, `feeNumerator < feeDenominator`, and `reserveX + input < 2^256`. The denominator's positivity and output's 256-bit fit are derived, with no successful-output premise.

The actual intermediate values have proved widths: fee difference 256 bits, weighted input and scaled X reserve 512 bits, summed denominator 513 bits, and numerator 768 bits. `wideMul`/`wideAdd` prove these ranges for all their bounded inputs. Native Nat arithmetic retains those full products; this is a mathematical Word model, with no modular EVM256/refinement claim.

```text
weightedInput = input*(feeDenominator-feeNumerator)
numerator     = reserveY*weightedInput
denominator   = reserveX*feeDenominator+weightedInput
output        = floor(numerator/denominator)
postX         = reserveX+input
postY         = reserveY-output
```

The fee is never rounded before the quote, and the full input stays in the pool. Native execution uses checked X addition, division, output conversion and Y subtraction. Refusal priority is zero reserve, zero input, invalid fee pair, then retained-input reserve overflow. `arithmetic_error_iff` proves the only reachable arithmetic failure is `addOverflow` at that last step; division-by-zero, quotient-overflow and subtraction-underflow cannot occur after valid guards. Raw-number parsing, signed inputs outside Word, and `ofNat` input overflow are separate interfaces.

Zero output is explicitly permitted. With `(x,y,input,num,den)=(10,20,1,1,2)`, output is 0 and actual post-reserves are `(11,20)`. Rounding the fee down first would instead change the quote. Reversing that zero output as the next positive-input operation refuses with `badAmount`; its error contains no returned post-pool, so no rollback is inferred.

The [immutable proof module](../../lean/DefiKernel/AMM/Checked.lean) provides constructive `success`, exact `exists_success_iff`, rational execution identity and `rational_floor_interval` against the accepted `Rational.swapPool` quote at the same fee. It proves positive post-reserves, exact X correspondence, and rational Y ≤ Word Y < rational Y + 1. `product_nondecrease` reuses the rational product theorem: output flooring retains extra Y and strengthens that bound. Product equality is not claimed; even zero-fee rounding can increase it (10,20,input2 gives Word post12,17, product204).

[CheckedAudit](../../lean/DefiKernel/AMM/CheckedAudit.lean) contains 15 finite controls, including nonreduced/full-width fees, a product exceeding 512 bits, exact overflow/refusal priority, floor output and zero-output reversal. In a configured checkout with pinned Lean4.33.0-rc2 dependencies, run:

```sh
python3 /absolute/checkout/scripts/replay_amm_checked.py \
  --toolchain /absolute/lean-4.33.0-rc2-darwin_aarch64
```

The CLI first builds current Checked source, then freshly evaluates its source audit and checks the exact 15 labels. Exit0 means the finite gate passed; exit1 means build/proof or comparison failure; exit3 means missing/empty/unreadable source, unavailable prerequisite/tool, timeout, or empty/duplicate evidence. The existing AMM Verify import makes the controls and nonempty combined AMM axiom audit part of the default build.

Mutation programs extract the actual API prefix (including range proofs) and append actual controls without importing intact cached Checked. Early fee-flooring, omitted denominator input and output-ceiling mutants produce actual false observations; full mutants retain unchanged generic proofs and are compiler-rejected. Changed expectations are a separate real-CLI comparison failure; empty/unreadable controls are blocked. The Checked math source remains the exact independently reviewed byte snapshot.

This slice supplies Word pool/domain/floor/product correspondence. A Word two-success round-trip theorem, actual Typed wallet/per-asset conservation with reserves bound to pre-ledger cells, and the full unbounded/signed/malformed R2 library bridge remain separate obligations. No source/deployed equivalence, market-wide no-arbitrage, outside reproduction or adoption is claimed. The original 168 imports and historical report/provenance remain unchanged. [Accounting](../../benchmarks/component-accounting/amm-checked.json) covers only declared new files; shared dependencies and missing historical effort are not silently charged or reconstructed.
