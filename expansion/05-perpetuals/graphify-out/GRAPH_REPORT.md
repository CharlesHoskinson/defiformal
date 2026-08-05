# Graph Report - 05-perpetuals  (2026-08-04)

## Corpus Check
- 1 files · ~13,804 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 37 nodes · 36 edges · 6 communities (5 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d6658fc1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- ApeX Protocol (ApeX Omni)
- Aster
- Hyperliquid
- Lighter
- edgeX
- Stage 1 research — Perpetuals / derivatives (05-perpetuals)

## God Nodes (most connected - your core abstractions)
1. `Hyperliquid` - 7 edges
2. `ApeX Protocol (ApeX Omni)` - 7 edges
3. `Aster` - 7 edges
4. `Lighter` - 7 edges
5. `edgeX` - 7 edges
6. `Stage 1 research — Perpetuals / derivatives (05-perpetuals)` - 6 edges
7. `WHAT IT DOES` - 1 edges
8. `DESIGN` - 1 edges
9. `REPO` - 1 edges
10. `EVIDENCE` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (6 total, 1 thin omitted)

### Community 0 - "ApeX Protocol (ApeX Omni)"
Cohesion: 0.29
Nodes (7): ApeX Protocol (ApeX Omni), DELTA, DESIGN, EVIDENCE, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 1 - "Aster"
Cohesion: 0.29
Nodes (7): Aster, DELTA, DESIGN, EVIDENCE, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 2 - "Hyperliquid"
Cohesion: 0.29
Nodes (7): DELTA, DESIGN, EVIDENCE, Hyperliquid, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 3 - "Lighter"
Cohesion: 0.29
Nodes (7): DELTA, DESIGN, EVIDENCE, Lighter, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 4 - "edgeX"
Cohesion: 0.29
Nodes (7): DELTA, DESIGN, edgeX, EVIDENCE, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

## Knowledge Gaps
- **30 isolated node(s):** `WHAT IT DOES`, `DESIGN`, `REPO`, `EVIDENCE`, `WHAT LOOKS UNNAMEABLE` (+25 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — Perpetuals / derivatives (05-perpetuals)` connect `Stage 1 research — Perpetuals / derivatives (05-perpetuals)` to `ApeX Protocol (ApeX Omni)`, `Aster`, `Hyperliquid`, `Lighter`, `edgeX`?**
  _High betweenness centrality (0.833) - this node is a cross-community bridge._
- **Why does `Hyperliquid` connect `Hyperliquid` to `Stage 1 research — Perpetuals / derivatives (05-perpetuals)`?**
  _High betweenness centrality (0.310) - this node is a cross-community bridge._
- **Why does `ApeX Protocol (ApeX Omni)` connect `ApeX Protocol (ApeX Omni)` to `Stage 1 research — Perpetuals / derivatives (05-perpetuals)`?**
  _High betweenness centrality (0.310) - this node is a cross-community bridge._
- **What connects `WHAT IT DOES`, `DESIGN`, `REPO` to the rest of the system?**
  _30 weakly-connected nodes found - possible documentation gaps or missing edges._