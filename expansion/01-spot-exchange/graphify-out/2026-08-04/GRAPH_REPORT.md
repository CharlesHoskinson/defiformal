# Graph Report - .  (2026-08-04)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 25 nodes · 22 edges · 5 communities
- Extraction: 59% EXTRACTED · 41% INFERRED · 0% AMBIGUOUS · INFERRED: 9 edges (avg confidence: 0.96)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d6658fc1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4

## God Nodes (most connected - your core abstractions)
1. `Liquidity Layer` - 5 edges
2. `Fluid` - 4 edges
3. `Uniswap Protocol` - 3 edges
4. `PancakeSwap Infinity` - 3 edges
5. `Raydium Protocol` - 3 edges
6. `Raydium` - 3 edges
7. `Uniswap v4` - 2 edges
8. `AMM v4` - 2 edges
9. `DEX v2` - 2 edges
10. `Vaults` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Uniswap Protocol Versions** — 01-research_uniswap_v2, 01-research_uniswap_v3, 01-research_uniswap_v4 [EXTRACTED 1.00]
- **PancakeSwap Infinity Modular Architecture** — 01-research_pancakeswap_vault, 01-research_pancakeswap_pool_managers [EXTRACTED 1.00]
- **Raydium AMM Products** — 01-research_amm_v4, 01-research_clmm, 01-research_cpmm [EXTRACTED 1.00]
- **Fluid Protocol Products** — 01-research_dex_v1, 01-research_dex_v2, 01-research_vaults [EXTRACTED 1.00]
- **Fluid Smart Primitives** — 01-research_smart_collateral, 01-research_smart_debt [EXTRACTED 0.90]

## Communities (5 total, 0 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.38
Nodes (7): DEX v1, DEX v2, Fluid, Liquidity Layer, Smart Collateral, Smart Debt, Vaults

### Community 1 - "Community 1"
Cohesion: 0.40
Nodes (5): AMM v4, CLMM, CPMM, OpenBook, Raydium

### Community 2 - "Community 2"
Cohesion: 0.40
Nodes (5): Uniswap Protocol, Uniswap Protocol Fees System, Uniswap v2, Uniswap v3, Uniswap v4

### Community 3 - "Community 3"
Cohesion: 0.50
Nodes (4): PancakeSwap Infinity, PancakeSwap Infinity Pool Managers, PancakeSwap Protocol, PancakeSwap Infinity Vault

### Community 4 - "Community 4"
Cohesion: 0.50
Nodes (4): Raydium AMM v4, Raydium CLMM, Raydium CPMM, Raydium Protocol

## Knowledge Gaps
- **15 isolated node(s):** `Uniswap v2`, `Uniswap v3`, `Uniswap Protocol Fees System`, `PancakeSwap Protocol`, `PancakeSwap Infinity Vault` (+10 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Are the 2 inferred relationships involving `Liquidity Layer` (e.g. with `Smart Collateral` and `Smart Debt`) actually correct?**
  _`Liquidity Layer` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `Uniswap Protocol` (e.g. with `Uniswap v2` and `Uniswap v3`) actually correct?**
  _`Uniswap Protocol` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `Raydium Protocol` (e.g. with `Raydium AMM v4` and `Raydium CLMM`) actually correct?**
  _`Raydium Protocol` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Uniswap v2`, `Uniswap v3`, `Uniswap Protocol Fees System` to the rest of the system?**
  _15 weakly-connected nodes found - possible documentation gaps or missing edges._