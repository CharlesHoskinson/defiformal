# Graph Report - .  (2026-08-04)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 13 nodes · 8 edges · 6 communities (2 shown, 4 thin omitted)
- Extraction: 88% EXTRACTED · 12% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.9)
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

## God Nodes (most connected - your core abstractions)
1. `Sky Lending` - 3 edges
2. `DSS Architecture` - 3 edges
3. `MCD_VAT` - 1 edges
4. `MCD_DOG` - 1 edges
5. `MCD_CLIPPER` - 1 edges
6. `USDS` - 1 edges
7. `Ethena` - 1 edges
8. `USDe` - 1 edges
9. `USDD` - 1 edges
10. `Lista CDP` - 1 edges

## Surprising Connections (you probably didn't know these)
- `Sky Lending` --implements--> `DSS Architecture`  [INFERRED]
  01-research.md → 01-research.md  _Bridges community 1 → community 0_

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Shared DSS Liquidation Engine Implementation** — mcd_vat, mcd_dog, mcd_clipper [EXTRACTED 1.00]

## Communities (6 total, 4 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.67
Nodes (3): DSS Architecture, Lista CDP, USDD

### Community 1 - "Community 1"
Cohesion: 0.67
Nodes (3): MCD_VAT, Sky Lending, USDS

## Knowledge Gaps
- **11 isolated node(s):** `MCD_VAT`, `MCD_DOG`, `MCD_CLIPPER`, `USDS`, `Ethena` (+6 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sky Lending` connect `Community 1` to `Community 0`?**
  _High betweenness centrality (0.106) - this node is a cross-community bridge._
- **Why does `DSS Architecture` connect `Community 0` to `Community 1`?**
  _High betweenness centrality (0.106) - this node is a cross-community bridge._
- **What connects `MCD_VAT`, `MCD_DOG`, `MCD_CLIPPER` to the rest of the system?**
  _11 weakly-connected nodes found - possible documentation gaps or missing edges._