# Gate 1.2 — corpus non-definability witnesses (draft)

**Status:** OPEN — witnesses collected; not yet a closed independence proof.

For each primitive P_i, one corpus action that is impossible if P_i is deleted
from the term language (BASIS §2 style, made gate-explicit).

## P1 Led — stored quantity change

| witness | location | why Led |
|---|---|---|
| ERC-20 transfer / mint / burn | L6/common ledger ops; `usdt`, `usdc`, `usd1.qnt` mint | changes stored `Q` balances and totalSupply together |
| MetaMorpho `reallocate` | `metamorpho.qnt` | moves vault `Q` across markets; conservation of total assets |

Without Led, these actions have no legal state update on `Q`.

## P2 Prop — floored proportion

| witness | location | why Prop |
|---|---|---|
| share mint/redeem | L1/common `sharesFromAssets` / Morpho / Yearn | `⌊a·S/A⌋` not a sum of prior Q |
| Aave index conversion | `aave_v3.qnt` `mulDivDown` on liquidityIndex | scaled ↔ present needs multiplicative floor |

Without Prop, reachable Q stays in the ℕ-span of initials.

## P3 Cmp — guards / boolean outcomes

| witness | location | why Cmp |
|---|---|---|
| Morpho health | `morpho_blue.qnt` `isHealthy(...)` before borrow/withdraw | guard is sort B |
| Lista `safe` CR | `lista.qnt` borrow/withdraw | CR ≥ MIN_CR is Cmp |

Without Cmp, every guard collapses to true and partial debit becomes total.

## P4 Post — exogenous Σ / Φ write

| witness | location | why Post |
|---|---|---|
| `shockPrice` | `morpho_blue.qnt`, `aave_v3.qnt`, `justlend.qnt` | oracle price not a term over prior Q |
| `applyPostPrice` | L5/common; `centrifuge.qnt` | NAV/price write |
| WBTC `confirmMint` status | `wbtc.qnt` Φ Pending→Approved by custodian | phase write not forced by Q arithmetic |

Without Post, prices and many status machines are constant forever.

## Pairwise check (informal)

No witness for P_i is rewriteable using only the other three without smuggling
the same primitive under another name (e.g. encoding Cmp as a Q-sentinel fails
locality/no-forgery discipline). Formalization path: Lean term language or
deletion experiments on IR.

## Next to close 1.2

1. IR-level deletion: remove all P_i-tagged ops from gen-ir, re-run generation —
   if corpus coverage collapses specifically where P_i was used, strengthen.
2. Or Lean non-definability for a toy algebra matching BASIS signatures.
