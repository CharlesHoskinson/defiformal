# Graph Report - 02-lending  (2026-08-04)

## Corpus Check
- 3 files · ~1,880 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 49 nodes · 46 edges · 8 communities (7 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e48b7729`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Section brief — Lending
- 1 · Aave V3
- 2 · Morpho
- 3 · SparkLend
- 4 · JustLend V1
- 5 · Maple
- 02 · Lending — stage-1 research
- SECTION-NOTES.md

## God Nodes (most connected - your core abstractions)
1. `1 · Aave V3` - 7 edges
2. `2 · Morpho` - 7 edges
3. `3 · SparkLend` - 7 edges
4. `4 · JustLend V1` - 7 edges
5. `5 · Maple` - 7 edges
6. `Section brief — Lending` - 7 edges
7. `02 · Lending — stage-1 research` - 6 edges
8. `1.1 WHAT IT DOES` - 1 edges
9. `1.2 DESIGN` - 1 edges
10. `1.3 REPO` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (8 total, 1 thin omitted)

### Community 0 - "Section brief — Lending"
Cohesion: 0.25
Nodes (7): Lane narrative, Section brief — Lending, Sources, Stage 3, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers

### Community 1 - "1 · Aave V3"
Cohesion: 0.29
Nodes (7): 1.1 WHAT IT DOES, 1.2 DESIGN, 1.3 REPO, 1.4 EVIDENCE, 1.5 WHAT LOOKS UNNAMEABLE, 1.6 DELTA, 1 · Aave V3

### Community 2 - "2 · Morpho"
Cohesion: 0.29
Nodes (7): 2.1 WHAT IT DOES, 2.2 DESIGN, 2.3 REPO, 2.4 EVIDENCE, 2.5 WHAT LOOKS UNNAMEABLE, 2.6 DELTA, 2 · Morpho

### Community 3 - "3 · SparkLend"
Cohesion: 0.29
Nodes (7): 3.1 WHAT IT DOES, 3.2 DESIGN, 3.3 REPO, 3.4 EVIDENCE, 3.5 WHAT LOOKS UNNAMEABLE, 3.6 DELTA, 3 · SparkLend

### Community 4 - "4 · JustLend V1"
Cohesion: 0.29
Nodes (7): 4.1 WHAT IT DOES, 4.2 DESIGN, 4.3 REPO, 4.4 EVIDENCE, 4.5 WHAT LOOKS UNNAMEABLE, 4.6 DELTA, 4 · JustLend V1

### Community 5 - "5 · Maple"
Cohesion: 0.29
Nodes (7): 5.1 WHAT IT DOES, 5.2 DESIGN, 5.3 REPO, 5.4 EVIDENCE, 5.5 WHAT LOOKS UNNAMEABLE, 5.6 DELTA, 5 · Maple

### Community 6 - "02 · Lending — stage-1 research"
Cohesion: 0.50
Nodes (3): 02 · Lending — stage-1 research, FINDING 1 — THE PRICE OF CREDIT, FINDING 2 — THE DELEGATED ALLOCATION MANDATE

## Knowledge Gaps
- **39 isolated node(s):** `1.1 WHAT IT DOES`, `1.2 DESIGN`, `1.3 REPO`, `1.4 EVIDENCE`, `1.5 WHAT LOOKS UNNAMEABLE` (+34 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `02 · Lending — stage-1 research` connect `02 · Lending — stage-1 research` to `1 · Aave V3`, `2 · Morpho`, `3 · SparkLend`, `4 · JustLend V1`, `5 · Maple`?**
  _High betweenness centrality (0.527) - this node is a cross-community bridge._
- **Why does `1 · Aave V3` connect `1 · Aave V3` to `02 · Lending — stage-1 research`?**
  _High betweenness centrality (0.184) - this node is a cross-community bridge._
- **Why does `2 · Morpho` connect `2 · Morpho` to `02 · Lending — stage-1 research`?**
  _High betweenness centrality (0.184) - this node is a cross-community bridge._
- **What connects `1.1 WHAT IT DOES`, `1.2 DESIGN`, `1.3 REPO` to the rest of the system?**
  _39 weakly-connected nodes found - possible documentation gaps or missing edges._