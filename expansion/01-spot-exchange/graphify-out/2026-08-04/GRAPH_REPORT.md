# Graph Report - 01-spot-exchange  (2026-08-04)

## Corpus Check
- 3 files · ~17,705 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 35 nodes · 20 edges · 15 communities (4 shown, 11 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4717d916`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- PoolManager.sol
- Swiss Stake AG
- PancakeSwap Infinity
- Raydium AMM v4
- Fluid DEX v2
- Raydium CLMM
- BinPoolManager.rel
- Curve Cryptoswap
- Firepit
- Uniswap v2
- Uniswap v3
- V3FeeAdapter
- V4FeeAdapter
- Section brief — Spot DEX / AMM
- SECTION-NOTES.md

## God Nodes (most connected - your core abstractions)
1. `Section brief — Spot DEX / AMM` - 7 edges
2. `PoolManager.sol` - 4 edges
3. `Swiss Stake AG` - 3 edges
4. `Uniswap v4` - 2 edges
5. `PancakeSwap Infinity` - 2 edges
6. `The question this category answers` - 1 edges
7. `The corpus decomposition, as of 2026-08-04` - 1 edges
8. `The category residue the original lane recorded` - 1 edges
9. `Stage 3` - 1 edges
10. `Sources` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Uniswap Protocol Fee Unification** — token_jar, firepit, v3_fee_adapter, v4_fee_adapter [EXTRACTED 0.90]
- **PancakeSwap Infinity Modular Architecture** — vault_sol, cl_pool_manager, bin_pool_manager [EXTRACTED 1.00]
- **Curve Next-Generation Pools** — 01_research_stableswap_ng, 01_research_twocrypto_ng, 01_research_tricrypto_ng [EXTRACTED 1.00]

## Communities (15 total, 11 thin omitted)

### Community 0 - "PoolManager.sol"
Cohesion: 0.33
Nodes (6): Hooks.sol, PoolManager.sol, ProtocolFees, TokenJar, Uniswap v4, V4FeePolicy

### Community 1 - "Swiss Stake AG"
Cohesion: 0.50
Nodes (4): stableswap-ng, Swiss Stake AG, tricrypto-ng, twocrypto-ng

### Community 2 - "PancakeSwap Infinity"
Cohesion: 0.67
Nodes (3): CLPoolManager.sol, PancakeSwap Infinity, Vault.sol

### Community 13 - "Section brief — Spot DEX / AMM"
Cohesion: 0.25
Nodes (7): Lane narrative, Section brief — Spot DEX / AMM, Sources, Stage 3, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers

## Knowledge Gaps
- **28 isolated node(s):** `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded`, `Stage 3`, `Sources` (+23 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded` to the rest of the system?**
  _28 weakly-connected nodes found - possible documentation gaps or missing edges._