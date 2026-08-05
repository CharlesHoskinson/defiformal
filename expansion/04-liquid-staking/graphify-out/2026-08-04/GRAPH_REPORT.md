# Graph Report - 04-liquid-staking  (2026-08-04)

## Corpus Check
- 9 files · ~33,040 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 48 nodes · 25 edges · 24 communities (5 shown, 19 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `03b70c9a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Lido Protocol
- stVaults (Lido V3)
- WBETH Token
- AllocationManager
- Babylon Genesis Chain
- EtherFiRestaker
- LiquidityPool
- NodeOperatorManager
- StrategyManager
- AuctionManager
- Covenant Committee
- EigenPodManager
- RewardsCoordinator
- weETH Token
- AllocationManager
- DelegationManager
- RewardsCoordinator
- OperatorGrid
- PredepositGuarantee
- stETH Token
- wstETH Token
- Section brief — Liquid staking & restaking
- Stage 3: the constructions, machine-checked
- SECTION-NOTES.md

## God Nodes (most connected - your core abstractions)
1. `Section brief — Liquid staking & restaking` - 7 edges
2. `Lido Protocol` - 5 edges
3. `Stage 3: the constructions, machine-checked` - 3 edges
4. `stVaults (Lido V3)` - 2 edges
5. `WBETH Token` - 2 edges
6. `The question this category answers` - 1 edges
7. `The corpus decomposition, as of 2026-08-04` - 1 edges
8. `The category residue the original lane recorded` - 1 edges
9. `Where the corpus and the construction disagree` - 1 edges
10. `Residue, verbatim` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Lido Core Components** — lido_staking_router, lido_dsm, lido_accounting_oracle, lido_vebo, lido_withdrawal_queue [EXTRACTED 1.00]
- **stVaults Architecture** — lido_vault_hub, lido_lazy_oracle, lido_operator_grid, lido_predeposit_guarantee [EXTRACTED 1.00]
- **EigenLayer Core Contracts** — eigen_strategy_manager, eigen_delegation_manager, eigen_allocation_manager, eigen_rewards_coordinator [EXTRACTED 1.00]
- **EtherFi Core Protocol Components** — 01-research_LiquidityPool, 01-research_StakingManager, 01-research_AuctionManager [EXTRACTED 0.90]
- **Cross-Protocol Restaking Dependencies** — 01-research_EtherFiRestaker, 01-research_StrategyManager, 01-research_AllocationManager [INFERRED 0.85]

## Communities (24 total, 19 thin omitted)

### Community 0 - "Lido Protocol"
Cohesion: 0.33
Nodes (6): AccountingOracle, DepositSecurityModule, Lido Protocol, StakingRouter, ValidatorsExitBusOracle, WithdrawalQueueERC721

### Community 1 - "stVaults (Lido V3)"
Cohesion: 0.67
Nodes (3): LazyOracle, stVaults (Lido V3), VaultHub

### Community 2 - "WBETH Token"
Cohesion: 0.67
Nodes (3): WrapTokenV3ETH, ExchangeRateUpdater, WBETH Token

### Community 21 - "Section brief — Liquid staking & restaking"
Cohesion: 0.29
Nodes (6): Lane narrative, Section brief — Liquid staking & restaking, Sources, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers

### Community 22 - "Stage 3: the constructions, machine-checked"
Cohesion: 0.67
Nodes (3): Residue, verbatim, Stage 3: the constructions, machine-checked, Where the corpus and the construction disagree

## Knowledge Gaps
- **41 isolated node(s):** `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded`, `Where the corpus and the construction disagree`, `Residue, verbatim` (+36 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Section brief — Liquid staking & restaking` connect `Section brief — Liquid staking & restaking` to `Stage 3: the constructions, machine-checked`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `Stage 3: the constructions, machine-checked` connect `Stage 3: the constructions, machine-checked` to `Section brief — Liquid staking & restaking`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded` to the rest of the system?**
  _41 weakly-connected nodes found - possible documentation gaps or missing edges._