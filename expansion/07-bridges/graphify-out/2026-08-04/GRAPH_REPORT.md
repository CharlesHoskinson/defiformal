# Graph Report - 07-bridges  (2026-08-04)

## Corpus Check
- 7 files · ~22,192 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 38 nodes · 37 edges · 6 communities (5 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `475ab3ce`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- WBTC
- LayerZero V2
- Coinbase Bridge (cbBTC and other wrapped assets)
- Hyperliquid Bridge
- Binance Bitcoin (BTCB)
- Stage 1 research — Bridges / cross-domain (top five)

## God Nodes (most connected - your core abstractions)
1. `Stage 1 research — Bridges / cross-domain (top five)` - 7 edges
2. `WBTC` - 7 edges
3. `LayerZero V2` - 7 edges
4. `Coinbase Bridge (cbBTC and other wrapped assets)` - 7 edges
5. `Hyperliquid Bridge` - 7 edges
6. `Binance Bitcoin (BTCB)` - 7 edges
7. `1. WHAT IT DOES` - 1 edges
8. `2. DESIGN` - 1 edges
9. `3. REPO` - 1 edges
10. `4. EVIDENCE` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (6 total, 1 thin omitted)

### Community 0 - "WBTC"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, WBTC

### Community 1 - "LayerZero V2"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, LayerZero V2

### Community 2 - "Coinbase Bridge (cbBTC and other wrapped assets)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Coinbase Bridge (cbBTC and other wrapped assets)

### Community 3 - "Hyperliquid Bridge"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Hyperliquid Bridge

### Community 4 - "Binance Bitcoin (BTCB)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Binance Bitcoin (BTCB)

## Knowledge Gaps
- **31 isolated node(s):** `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO`, `4. EVIDENCE`, `5. WHAT LOOKS UNNAMEABLE` (+26 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — Bridges / cross-domain (top five)` connect `Stage 1 research — Bridges / cross-domain (top five)` to `WBTC`, `LayerZero V2`, `Coinbase Bridge (cbBTC and other wrapped assets)`, `Hyperliquid Bridge`, `Binance Bitcoin (BTCB)`?**
  _High betweenness centrality (0.842) - this node is a cross-community bridge._
- **Why does `WBTC` connect `WBTC` to `Stage 1 research — Bridges / cross-domain (top five)`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **Why does `LayerZero V2` connect `LayerZero V2` to `Stage 1 research — Bridges / cross-domain (top five)`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **What connects `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO` to the rest of the system?**
  _31 weakly-connected nodes found - possible documentation gaps or missing edges._