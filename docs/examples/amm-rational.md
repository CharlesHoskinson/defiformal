# Exact-rational AMM pool foundation (2026-11-17)

`DefiKernel.AMM.Rational.swapPool` is a reusable reserve-only library operation for an exact-input, two-asset constant-product pool. Its independent inputs are rational reserves `x,y`, X input `d`, and scalar input-fee fraction `f`. X/Y are semantic asset labels here; typed asset/unit interfaces remain part of the later settlement work. It accepts exactly `x>0`, `y>0`, `d>0`, and `0≤f<1`; no upper bound, fixed literal, or successful-output premise replaces that domain.

Refusal priority is `badReserve` for either nonpositive reserve, then `badAmount` for nonpositive input, then `badFee` for a negative fee or fee at least one. Typed rational inputs have no malformed-number constructor. The future raw R2 adapter must preserve its separate malformed-any-input priority. Refusals return a reason with no post-state; no observed rollback world is claimed.

The pricing input is `e=d*(1-f)`. The executed output and actual pool reserves are:

```text
outputY = y*e/(x+e)
postX   = x+d
postY   = y-outputY
postX*postY - x*y = x*y*d*f/(x+e)
```

The full X input, including the fee, stays in the pool. `constructive_contract` proves actual successful execution with these fields, positive output strictly below `y`, positive post-reserves, the exact product increment, and product nondecrease. `success_iff` also identifies the exact successful domain and result. The denominator's positivity is derived from the input assumptions.

`roundTrip` calls the same operation twice: the first actual post-pool is flipped, the full Y output becomes the reverse input, and the same fee is used. There is no intervening pool change. `round_trip_contract` constructs both successful calls and proves returned X is at most the original X input; the final pool Y reserve equals the initial Y reserve. The proof applies product nondecrease to both steps and cancels the positive initial Y reserve. This is a precise full-output, same-pool bound in raw X/Y units. Wallet settlement, external valuations, alternate routes, fees paid elsewhere and adversarial scheduling are outside it.

The [source](../../lean/DefiKernel/AMM/Rational.lean) contains 16 explicitly named mathematical/helper theorems. The imported-module axiom audit also inspects generated theorem constants and supplemental definitions; its count is a different unit. [RationalAudit](../../lean/DefiKernel/AMM/RationalAudit.lean) supplies 16 finite controls, including independent fractional inputs, positive/zero fees, exact fee retention, wrong-denominator expectations, signed refusal precedence, and both round-trip examples. For `(x,y,d,f)=(10,20,2,1/2)`, output is `20/11`, actual reserves are `(12,200/11)`, and reversing the full output returns `4/7` X with final reserves `(80/7,20)`.

In an already configured checkout with the pinned Mathlib dependencies, run:

```sh
python3 /absolute/checkout/scripts/replay_amm_rational.py \
  --toolchain /absolute/lean-4.33.0-rc2-darwin_aarch64
```

The CLI builds the current rational library before freshly evaluating the source audit. It requires the exact 16 nonempty assertion labels and records the native Lean version/binary hash and model/audit source hashes. Exit 0 means that finite gate passed; exit 1 means a proof/build or comparison contradiction; exit 3 means unavailable tools/dependency evidence, missing/empty/unreadable source, timeout, or an empty/duplicate assertion inventory. This is a source-development replay, requiring its configured build cache; the existing published ordering archive does not contain this new operation.

Mutation evidence keeps three checks distinct. API-prefix programs extract the actual model definitions and append the actual audit assertions with the self-import removed, so changed models never import an intact cached `Rational.olean`. The intact prefix passes, while omitted-fee reserve accounting and a wrong denominator each produce an actual false fee/denominator comparison. Full source mutants retain the unchanged generic proofs and are compiler-rejected. Separately, changing only an expected value fails the real CLI comparison; empty/unreadable audit controls are blocked. All production-source mutations were restored. The current library is rebuilt on each CLI call, including recovery after a rejected model build.

This dated foundation leaves IV.1 open: Typed wallet execution and per-asset transfer conservation, a checked Word contract with explicit widths/overflow and output-floor correspondence, and the complete fresh R2 library-calling success/signed/malformed contract remain unimplemented. The original imported benchmark/report bytes and `new_model` provenance remain unchanged. No market-wide no-arbitrage, deployed/source equivalence, outside reproduction or corroborated adoption is established.

[Line accounting and attribution](../../benchmarks/component-accounting/amm-rational.json) cover the declared new files, using physical source sections rather than semantic complexity. Shared library dependencies are not silently charged. The prospective implementation interval is agent wall time including tools/waits; active effort and human/person-hours are unknown. Earlier read-only design and missing historical authoring effort are not reconstructed.
