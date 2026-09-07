## Why

The kernel uses exact rational quantities. Protocol implementations usually use bounded integers, integer division and explicitly directed rounding. A rational conservation theorem does not establish that an overflowing or rounded implementation produces the same result. The financial libraries need a checked arithmetic layer and a precise connection to dimensioned kernel quantities.

## What Changes

- Add an unsigned bounded-word library with checked construction, addition, subtraction, multiplication and full-product multiply/divide.
- Define floor and ceiling results and fee conventions explicitly, with exact refusal behavior.
- Prove arithmetic bounds, success/refusal characterizations, rounding error bounds and same-asset quantity conversion.
- Exercise a fee-bearing reference transfer through the existing typed executor, including insufficient funds, unauthorized debit and coincident recipient/collector cells.
- Add independently calculated examples, real runtime mutations and an imported proof/axiom audit.

## Capabilities

### New Capabilities

- `checked-unsigned-arithmetic`: bounded unsigned words and exact failures.
- `directed-rounding-fees`: full-product division, rounding and fee conventions.
- `integer-quantity-correspondence`: quantity conversion and reference fee accounting.
- `integer-arithmetic-evidence`: substantive runtime, mutation, proof and review evidence.

### Modified Capabilities

None. The rational kernel and historical results retain their existing semantics.

## Impact

New files live under `lean/DefiKernel/Arithmetic/`, with a separate verification root and dedicated scripts. This is a mathematical word-arithmetic library, not an EVM interpreter, deployed Uniswap refinement, gas model, signed funding library or serialized certificate checker. Later protocol libraries must bind their exact widths, scales, fee conventions and failure paths to these results.

This is an author draft. Every implementation task remains unchecked and needs the same-candidate nonauthor GPT-6/native Fable planning gate.
