# Graph Report - 11-fiat-stablecoins  (2026-08-04)

## Corpus Check
- 1 files · ~12,022 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 38 nodes · 37 edges · 6 communities (5 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6c07d92e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Tether USDT
- Circle USDC
- World Liberty Financial USD1
- Global Dollar USDG (Paxos)
- PayPal USD (PYUSD)
- Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research

## God Nodes (most connected - your core abstractions)
1. `Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research` - 7 edges
2. `Tether USDT` - 7 edges
3. `Circle USDC` - 7 edges
4. `World Liberty Financial USD1` - 7 edges
5. `Global Dollar USDG (Paxos)` - 7 edges
6. `PayPal USD (PYUSD)` - 7 edges
7. `1. WHAT IT DOES` - 1 edges
8. `2. DESIGN` - 1 edges
9. `3. REPO` - 1 edges
10. `4. EVIDENCE` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (6 total, 1 thin omitted)

### Community 0 - "Tether USDT"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Tether USDT

### Community 1 - "Circle USDC"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Circle USDC

### Community 2 - "World Liberty Financial USD1"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, World Liberty Financial USD1

### Community 3 - "Global Dollar USDG (Paxos)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Global Dollar USDG (Paxos)

### Community 4 - "PayPal USD (PYUSD)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, PayPal USD (PYUSD)

## Knowledge Gaps
- **31 isolated node(s):** `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO`, `4. EVIDENCE`, `5. WHAT LOOKS UNNAMEABLE` (+26 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research` connect `Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research` to `Tether USDT`, `Circle USDC`, `World Liberty Financial USD1`, `Global Dollar USDG (Paxos)`, `PayPal USD (PYUSD)`?**
  _High betweenness centrality (0.842) - this node is a cross-community bridge._
- **Why does `Tether USDT` connect `Tether USDT` to `Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **Why does `Circle USDC` connect `Circle USDC` to `Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **What connects `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO` to the rest of the system?**
  _31 weakly-connected nodes found - possible documentation gaps or missing edges._