# Graph Report - 08-intents  (2026-08-04)

## Corpus Check
- 7 files · ~25,599 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 38 nodes · 37 edges · 6 communities (5 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5eec2a17`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- LiquidMesh
- Binance Wallet
- OKX DEX
- Jupiter
- KyberSwap
- Stage 1 research — Category 08: Intents / aggregation / order flow

## God Nodes (most connected - your core abstractions)
1. `Stage 1 research — Category 08: Intents / aggregation / order flow` - 7 edges
2. `LiquidMesh` - 7 edges
3. `Binance Wallet` - 7 edges
4. `OKX DEX` - 7 edges
5. `Jupiter` - 7 edges
6. `KyberSwap` - 7 edges
7. `1. WHAT IT DOES` - 1 edges
8. `2. DESIGN` - 1 edges
9. `3. REPO` - 1 edges
10. `4. EVIDENCE` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (6 total, 1 thin omitted)

### Community 0 - "LiquidMesh"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, LiquidMesh

### Community 1 - "Binance Wallet"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Binance Wallet

### Community 2 - "OKX DEX"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, OKX DEX

### Community 3 - "Jupiter"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Jupiter

### Community 4 - "KyberSwap"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, KyberSwap

## Knowledge Gaps
- **31 isolated node(s):** `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO`, `4. EVIDENCE`, `5. WHAT LOOKS UNNAMEABLE` (+26 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — Category 08: Intents / aggregation / order flow` connect `Stage 1 research — Category 08: Intents / aggregation / order flow` to `LiquidMesh`, `Binance Wallet`, `OKX DEX`, `Jupiter`, `KyberSwap`?**
  _High betweenness centrality (0.842) - this node is a cross-community bridge._
- **Why does `LiquidMesh` connect `LiquidMesh` to `Stage 1 research — Category 08: Intents / aggregation / order flow`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **Why does `Binance Wallet` connect `Binance Wallet` to `Stage 1 research — Category 08: Intents / aggregation / order flow`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **What connects `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO` to the rest of the system?**
  _31 weakly-connected nodes found - possible documentation gaps or missing edges._