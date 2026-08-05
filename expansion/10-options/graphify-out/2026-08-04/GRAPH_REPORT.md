# Graph Report - 10-options  (2026-08-04)

## Corpus Check
- 7 files · ~25,732 words
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
- Derive (formerly Lyra V2)
- Rysk V12
- Hegic
- Aevo (Ribbon Finance lineage)
- Panoptic V2
- Stage 1 research — Options / structured products

## God Nodes (most connected - your core abstractions)
1. `Stage 1 research — Options / structured products` - 7 edges
2. `Derive (formerly Lyra V2)` - 7 edges
3. `Rysk V12` - 7 edges
4. `Hegic` - 7 edges
5. `Aevo (Ribbon Finance lineage)` - 7 edges
6. `Panoptic V2` - 7 edges
7. `1. WHAT IT DOES` - 1 edges
8. `2. DESIGN` - 1 edges
9. `3. REPO` - 1 edges
10. `4. EVIDENCE` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (6 total, 1 thin omitted)

### Community 0 - "Derive (formerly Lyra V2)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA vs the corpus record, Derive (formerly Lyra V2)

### Community 1 - "Rysk V12"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA vs the corpus record — the largest in this category, Rysk V12

### Community 2 - "Hegic"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA vs the corpus record, Hegic

### Community 3 - "Aevo (Ribbon Finance lineage)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA vs the corpus record, Aevo (Ribbon Finance lineage)

### Community 4 - "Panoptic V2"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA vs the corpus record, Panoptic V2

## Knowledge Gaps
- **31 isolated node(s):** `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO`, `4. EVIDENCE`, `5. WHAT LOOKS UNNAMEABLE` (+26 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — Options / structured products` connect `Stage 1 research — Options / structured products` to `Derive (formerly Lyra V2)`, `Rysk V12`, `Hegic`, `Aevo (Ribbon Finance lineage)`, `Panoptic V2`?**
  _High betweenness centrality (0.842) - this node is a cross-community bridge._
- **Why does `Derive (formerly Lyra V2)` connect `Derive (formerly Lyra V2)` to `Stage 1 research — Options / structured products`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **Why does `Rysk V12` connect `Rysk V12` to `Stage 1 research — Options / structured products`?**
  _High betweenness centrality (0.302) - this node is a cross-community bridge._
- **What connects `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO` to the rest of the system?**
  _31 weakly-connected nodes found - possible documentation gaps or missing edges._