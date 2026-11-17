# DeFiFormal-toolchain new rational swap model

This evaluation declares only `R2-SWAP` in `rational-1` / `EXACT_RATIONAL`.
Its workload origin is `new_model` and its boundary is `abstract_model`.
All reserve-swap definitions, AMM formulas, guards and invariant proofs were
newly authored for this benchmark. This is not verification of an existing
DeFiFormal AMM library or a deployed swap implementation. The other eight cases
are not established by this evaluation. A separate adapted-library transfer
evaluation has its own coverage and timings; they are not pooled here.

The pinned toolchain is Lean 4.33.0-rc2, mathlib
`51e6992efd06126df61a496bebf8f49482a4e129`, and DeFiFormal revision
`2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda` from
`CharlesHoskinson/defiformal`. `native-lock.json` binds the retained
`Typed/Types.lean` and `Typed/Expr.lean` snapshots, imported compiled modules,
Lean executable and checker. The complete pinned dependency archive is retained;
the two typed modules rebuild offline from its unchanged sources during setup.

## New model and generic arithmetic reuse

`SwapModel.nativeSwap` is a new composition of generic native
`DefiKernel.Typed.BinaryOp.eval` arithmetic. Addition computes `x+d`, scaling
computes `y*d`, division computes `y*d/(x+d)`, and subtraction computes
`y-output`. The division operator checks its denominator against zero. These
arithmetic operations have no preexisting AMM interpretation or constant-product
theorem. Their use does not change the new-model provenance.

`swapExact` and the raw-number wrapper are also new. They reject malformed
encodings first, then nonpositive reserves, then a nonpositive input amount.
Every independent signed rational input is in scope. There is no floating point,
rounding, fixed scale, overflow, denominator cap or finite-value restriction.
This reserve-only model includes no fees, wallet movements, LP accounting or
implementation refinement.

`SwapAssisted.native_correspondence` proves the actual generic-interpreter result
for every nonzero summed reserve. The success theorem derives that condition
from independent positive rational `x`, `y`, and `d`. It proves the exact output
and final reserves, strict output bounds, positive final reserves, and constant
product. The canonical theorem also proves every specified signed-input refusal
and malformed-number priority. It neither assumes the requested invariant nor
conditions the conclusion on implementation success.

## Procedure, checks and attribution

The unchanged automatic procedure is `aesop` with `maxHeartbeats 20000`, selected
on an unrelated proposition before any target proof. Its actual target failure
is retained. The successful case splits, generic-interpreter correspondence and
algebraic tactics are AI-authored assistance. Both stages import the identical
new model and claims. `origin-repair.json` binds the unchanged Lean sources,
witnesses and original automatic-procedure evidence to the earlier candidate.
Only provenance and evaluation scoping were repaired.

Fractional and unbounded witnesses run the actual arithmetic composition, along
with five refusal-priority controls. Rounding the quotient and using the original
reserve as denominator each compile but return incorrect successful outputs and
violate product equality. Modified source and concrete outputs are retained.
These controls supplement the universal theorem; samples alone are not a proof.
Executed parser controls distinguish failed obligations, incomplete output,
missing dependencies, timeout, proof holes and nonstandard axioms. A flagged
cached skip is rejected, and fresh directories demonstrate repeated replay.

Replay compiles only `SwapModel.lean` and the selected automatic or assisted
proof. The clean build compiles `SwapModel.lean` and `SwapAssisted.lean`, including
every new local helper. Separate `leanchecker` commands replay both compiled
modules without source tactics and verify unchanged artifact hashes. This uses
the same Lean kernel implementation, trusting pinned imported modules; `--fresh`
is not used. Logical axioms are restricted to `propext`, `Classical.choice`, and
`Quot.sound`. Per-repetition `.olean` sizes include model/specification/proof
declarations rather than isolated certificate sizes.

`effort.json` preserves the original swap-model adaptation effort and adds its
share of the common origin-splitting repair. Common earlier infrastructure is
charged once across the cases, and no allowance is reset. The superseded
mixed-origin candidate remains historical failed-attempt evidence. This successor
requires fresh acceptance/reconstruction and independent semantic admission
before it can supply its own one-case measurement.
