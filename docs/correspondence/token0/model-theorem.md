# Token0 model theorem and observation relation

This package separates a proved Lean model property, reused finite source observations, and an unproved source refinement obligation. Its baseline is `0694a5c36fc12e95ca0085a4ebae4ac418b7aefa`. It adds no Lean theorem and changes no historical source or evidence.

The model artifact is `DefiKernel.ConcentratedLiquidity.SqrtPriceMath.add_result_le`, in module `DefiKernel.ConcentratedLiquidity.Token0Proofs` ([source](../../../lean/DefiKernel/ConcentratedLiquidity/Token0Proofs.lean), SHA-256 `fd2e1ffadf85649f20b8b61280dc00282eee7bc02bdc1d828f7ef6094eabc3f9`). For every typed `sqrtP : U160`, `L : U128`, `amount : U256`, and `q : U160`, it proves:

```text
getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount true = .ok q
    implies q.value ≤ sqrtP.value.
```

This is a global successful-add property of the word model, including its checked arithmetic and fallback branches. It has no additional positivity premise. The same module contains `primary_add`, `wrap_fallback`, `prod_fallback`, `remove_require`, `remove_primary`, and `identity`; this package does not upgrade their model conclusions to EVM theorems. The namespace is `SqrtPriceMath`; the owning proof module is `Token0Proofs`.

The input relation fixes the pure `probe(uint160,uint128,uint256,bool)` wrapper and selector `6c84a8a2`. For integers `(p,L,a,b)` require `0 ≤ p < 2^160`, `0 ≤ L < 2^128`, `0 ≤ a < 2^256`, and `b ∈ {0,1}`. Source calldata is exactly 132 bytes: the four selector bytes followed by four canonical 32-byte big-endian words encoding those values. The Lean inputs are the corresponding bounded words and Boolean `b = 1`. Prices use the existing Q96 representation; token amounts and liquidity remain raw integers. This relation does not rescale them into token balances.

For an invocation with these inputs, define the observation relation as follows:

- A semantic source success relates to Lean `.ok q` exactly when returndata is exactly 32 bytes, its big-endian integer is below `2^160` (the high 96 bits are zero), and that integer equals `q.value`.
- A semantic EVM revert relates to Lean `.error e` only as a coarse refusal. Retain the source's raw returndata and the separately observed Lean error label. In particular, empty `0x` does not identify `e`, and this relation proves no one-to-one error correspondence.
- Missing evidence, malformed calldata or return data, timeout, cancellation, infrastructure failure, out-of-gas, and other execution errors receive no related observation. A CLI exit code of zero alone establishes neither semantic success nor semantic revert.

Thus, for a successful add observation that satisfies this relation, the *model theorem together with the observed equality* yields an output no greater than the input Q96 price. The theorem proves the model property; the finite records establish the equality only for their recorded inputs. There is no theorem that all source invocations satisfy the relation.

[The observation manifest](differential-observations.json) binds the 12 original archived P16 author invocations, their calldata, raw outputs, receipts, compiler inputs and context. It records 8 successes and 4 semantic reverts, all four with empty returndata. The four additional P18-counted model invocations are listed separately: **12 source + 4 model invocations**, not 16 source cases. Original author dates and identities remain intact. The later independent GPT-6 replay is corroboration with its own acceptance record; its records neither replace the archived author records nor add a denominator. Frozen P18 files with pending-review fields are historical bytes; the separately pinned P16 and P18 acceptance records establish current acceptance.

From the repository root, run `python3 docs/correspondence/token0/verify.py`. This checks pinned bytes and record consistency; it performs no Solidity/EVM execution and does not prove refinement. Exit 0 means a nonempty consistent record, exit 3 means required evidence or a denominator is missing or empty, and exit 1 means contradictory or changed evidence. `--manifest PATH` selects an alternate manifest for inspection; it does not change the repository root used to resolve pinned files. The existing P18 validator remains the release-evidence validator. A fresh focused check of the unchanged model uses `lake build DefiKernel.ConcentratedLiquidity.Token0Proofs`, a Lean file importing that module and printing axioms for `add_result_le`, and `lake env leanchecker -v DefiKernel.ConcentratedLiquidity.Token0Proofs` from `lean/` with the pinned toolchain. [The remaining obligation](refinement-obligation.md) is explicitly open.
