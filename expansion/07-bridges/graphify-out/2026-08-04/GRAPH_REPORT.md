# Graph Report - 07-bridges  (2026-08-04)

## Corpus Check
- 9 files · ~25,530 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 50 nodes · 47 edges · 8 communities (6 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a3bfdf17`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- WBTC
- LayerZero V2
- Coinbase Bridge (cbBTC and other wrapped assets)
- Hyperliquid Bridge
- Binance Bitcoin (BTCB)
- Stage 1 research — Bridges / cross-domain (top five)
- Section brief — Bridges / cross-domain
- SECTION-NOTES.md

## God Nodes (most connected - your core abstractions)
1. `Stage 1 research — Bridges / cross-domain (top five)` - 7 edges
2. `WBTC` - 7 edges
3. `LayerZero V2` - 7 edges
4. `Coinbase Bridge (cbBTC and other wrapped assets)` - 7 edges
5. `Hyperliquid Bridge` - 7 edges
6. `Binance Bitcoin (BTCB)` - 7 edges
7. `Section brief — Bridges / cross-domain` - 7 edges
8. `Stage 3: the constructions, machine-checked` - 3 edges
9. `1. WHAT IT DOES` - 1 edges
10. `2. DESIGN` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (8 total, 2 thin omitted)

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

### Community 6 - "Section brief — Bridges / cross-domain"
Cohesion: 0.20
Nodes (9): Lane narrative, Residue, verbatim, Section brief — Bridges / cross-domain, Sources, Stage 3: the constructions, machine-checked, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers (+1 more)

## Knowledge Gaps
- **39 isolated node(s):** `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO`, `4. EVIDENCE`, `5. WHAT LOOKS UNNAMEABLE` (+34 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — Bridges / cross-domain (top five)` connect `Stage 1 research — Bridges / cross-domain (top five)` to `WBTC`, `LayerZero V2`, `Coinbase Bridge (cbBTC and other wrapped assets)`, `Hyperliquid Bridge`, `Binance Bitcoin (BTCB)`?**
  _High betweenness centrality (0.477) - this node is a cross-community bridge._
- **Why does `WBTC` connect `WBTC` to `Stage 1 research — Bridges / cross-domain (top five)`?**
  _High betweenness centrality (0.171) - this node is a cross-community bridge._
- **Why does `LayerZero V2` connect `LayerZero V2` to `Stage 1 research — Bridges / cross-domain (top five)`?**
  _High betweenness centrality (0.171) - this node is a cross-community bridge._
- **What connects `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO` to the rest of the system?**
  _39 weakly-connected nodes found - possible documentation gaps or missing edges._