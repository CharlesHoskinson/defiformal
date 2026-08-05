# Graph Report - .  (2026-08-04)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 36 nodes · 15 edges · 21 communities (3 shown, 18 thin omitted)
- Extraction: 87% EXTRACTED · 13% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.78)
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
- Community 5
- Community 6
- Community 7
- Community 8
- Community 9
- Community 10
- Community 11
- Community 12
- Community 13
- Community 14
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20

## God Nodes (most connected - your core abstractions)
1. `Lido Protocol` - 5 edges
2. `stVaults (Lido V3)` - 2 edges
3. `WBETH Token` - 2 edges
4. `StakingRouter` - 1 edges
5. `DepositSecurityModule` - 1 edges
6. `AccountingOracle` - 1 edges
7. `ValidatorsExitBusOracle` - 1 edges
8. `WithdrawalQueueERC721` - 1 edges
9. `VaultHub` - 1 edges
10. `LazyOracle` - 1 edges

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

## Communities (21 total, 18 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.33
Nodes (6): AccountingOracle, DepositSecurityModule, Lido Protocol, StakingRouter, ValidatorsExitBusOracle, WithdrawalQueueERC721

### Community 1 - "Community 1"
Cohesion: 0.67
Nodes (3): LazyOracle, stVaults (Lido V3), VaultHub

### Community 2 - "Community 2"
Cohesion: 0.67
Nodes (3): WrapTokenV3ETH, ExchangeRateUpdater, WBETH Token

## Knowledge Gaps
- **33 isolated node(s):** `stETH Token`, `wstETH Token`, `StakingRouter`, `DepositSecurityModule`, `AccountingOracle` (+28 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `stETH Token`, `wstETH Token`, `StakingRouter` to the rest of the system?**
  _33 weakly-connected nodes found - possible documentation gaps or missing edges._