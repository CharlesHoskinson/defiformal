## Lane narrative

**What the section introduction should say.** This is the best-documented category in DeFi and the one the vocabulary resolves most finely — five symbols for five algebraic variants of one scalar function on a two-asset pool. The lane's question is whether that resolution is earned. Four of five ship core contracts on GitHub under a named licence; the AMM repositories of one are **all-rights-reserved, not open source**, which constrains what the paper may reproduce.

**Findings that are judgement, not arithmetic.**

- **An artefact can be ambiguous at its own version string.** Two live implementations of the same protocol both report `version = "v2.1.0"` and implement mathematically *different* repegging predicates — the deployed one linear in accumulated profit, the repository's quadratic, the first being the first-order expansion of the second. They agree near unit profit and diverge as profit compounds. Any citation of that version without a bytecode hash is citing an ambiguous artefact. This is a *methodological* finding about decomposing deployed systems, and it belongs in the paper.
- **The corpus record for Fluid describes v1; v2 is deployed**, with tick spacing, a current tick and a per-pool controller. The concentrated-liquidity marker the corpus forced is wrong as recorded.
- **Raydium does not burn its token** — it buys and holds. The three-way buyback grouping in the corpus is invalid, and the value-return channel needs three distinct obligations: distribution to a claim class, supply destruction, accumulation.
- **Three of five carry the hook residue, with three different permission-binding conventions.** Nothing in the 58 names third-party code executing inside the settlement path, which is what the whole category now differentiates on.

**Unresolved.** Deployed-bytecode-to-repository correspondence is asserted rather than proved for every protocol here except where an explorer-verified address is given.
