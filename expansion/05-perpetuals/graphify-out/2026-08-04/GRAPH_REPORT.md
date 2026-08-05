# Graph Report - 05-perpetuals  (2026-08-04)

## Corpus Check
- 9 files · ~30,813 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 49 nodes · 46 edges · 7 communities (6 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e48b7729`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- ApeX Protocol (ApeX Omni)
- Aster
- Hyperliquid
- Lighter
- edgeX
- Stage 1 research — Perpetuals / derivatives (05-perpetuals)
- SECTION-NOTES.md

## God Nodes (most connected - your core abstractions)
1. `Hyperliquid` - 7 edges
2. `ApeX Protocol (ApeX Omni)` - 7 edges
3. `Aster` - 7 edges
4. `Lighter` - 7 edges
5. `edgeX` - 7 edges
6. `Section brief — Perpetuals / derivatives` - 7 edges
7. `Stage 1 research — Perpetuals / derivatives (05-perpetuals)` - 6 edges
8. `Stage 3: the constructions, machine-checked` - 3 edges
9. `WHAT IT DOES` - 1 edges
10. `DESIGN` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (7 total, 1 thin omitted)

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
Cohesion: 0.22
Nodes (8): DELTA, DESIGN, EVIDENCE, Lighter, REPO, Stage 1 research — Perpetuals / derivatives (05-perpetuals), WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 4 - "edgeX"
Cohesion: 0.29
Nodes (7): DELTA, DESIGN, edgeX, EVIDENCE, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 5 - "Stage 1 research — Perpetuals / derivatives (05-perpetuals)"
Cohesion: 0.20
Nodes (9): Lane narrative, Residue, verbatim, Section brief — Perpetuals / derivatives, Sources, Stage 3: the constructions, machine-checked, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers (+1 more)

## Knowledge Gaps
- **38 isolated node(s):** `WHAT IT DOES`, `DESIGN`, `REPO`, `EVIDENCE`, `WHAT LOOKS UNNAMEABLE` (+33 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — Perpetuals / derivatives (05-perpetuals)` connect `Lighter` to `ApeX Protocol (ApeX Omni)`, `Aster`, `Hyperliquid`, `edgeX`?**
  _High betweenness centrality (0.465) - this node is a cross-community bridge._
- **Why does `Hyperliquid` connect `Hyperliquid` to `Lighter`?**
  _High betweenness centrality (0.173) - this node is a cross-community bridge._
- **Why does `ApeX Protocol (ApeX Omni)` connect `ApeX Protocol (ApeX Omni)` to `Lighter`?**
  _High betweenness centrality (0.173) - this node is a cross-community bridge._
- **What connects `WHAT IT DOES`, `DESIGN`, `REPO` to the rest of the system?**
  _38 weakly-connected nodes found - possible documentation gaps or missing edges._