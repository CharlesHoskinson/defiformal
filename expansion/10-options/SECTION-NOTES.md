## Lane narrative

**What the section introduction should say.** One symbol carries the whole of options, while five symbols distinguish five algebraic variants of one scalar function on a two-asset pool. That resolution mismatch is the category's headline, and the requirement tables reject four of the five venues — the worst rate of the twelve. Stage 3 resolved *why*, and the answer splits in two.

**The finding: two of the four rejections are artefacts, and two are a defect in the language.**

- **Artefacts.** One venue's collateral test is an order-gating engine and its auto-deleveraging has its own documentation page; the corpus carried neither. Another's collateral test is a 2,401-line audited risk engine, and the price source the corpus carried *none* of is an on-chain time-weighted price — "oracle-free" meant no external feed, not no price. Restore what was demoted and both rejections vanish.
- **A defect in the language.** The two that survive are exactly the two that **escrow maximum payoff at trade time**. Their threshold, liquidator and backstop obligations are closed *by construction*: the obligation cannot arise. The requirement language admits only one way to discharge a term — name a satisfying element — so it reads a closed obligation as an unspecified one. The rejection is correct about the tables and wrong about the protocols.

This is the sharpest formalism finding of the run, it is now evidenced obligation by obligation, and it is a change to the **constraint language** rather than to the vocabulary.

**Corrections.** The staked-backstop element is wrong for one venue — its security module is an owner-funded treasury with no stake and no slashing — and two venues the corpus called identical differ in index, loss-absorption topology and auto-deleveraging.

**Six axes the single options symbol collapses**, and each that no element names is residue: exercise style; cash or physical settlement; peer-to-peer, peer-to-pool or AMM-derived underwriting; upfront or streamed premium; isolated, portfolio or scenario margin; model-priced with a volatility surface against book-priced.
