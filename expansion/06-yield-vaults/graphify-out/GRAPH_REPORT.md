# Graph Report - 06-yield-vaults  (2026-08-04)

## Corpus Check
- 7 files · ~25,779 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 37 nodes · 36 edges · 6 communities (5 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `95cf949f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- CIAN Yield Layer
- Convex Finance
- Pendle
- Spark Savings (sUSDS / Sky Savings Rate)
- Huma Finance V2
- Stage 1 research — category 06, Yield / vaults / aggregators

## God Nodes (most connected - your core abstractions)
1. `Pendle` - 7 edges
2. `Spark Savings (sUSDS / Sky Savings Rate)` - 7 edges
3. `Convex Finance` - 7 edges
4. `CIAN Yield Layer` - 7 edges
5. `Huma Finance V2` - 7 edges
6. `Stage 1 research — category 06, Yield / vaults / aggregators` - 6 edges
7. `WHAT IT DOES` - 1 edges
8. `DESIGN` - 1 edges
9. `REPO` - 1 edges
10. `EVIDENCE` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (6 total, 1 thin omitted)

### Community 0 - "CIAN Yield Layer"
Cohesion: 0.29
Nodes (7): CIAN Yield Layer, DELTA, DESIGN, EVIDENCE, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 1 - "Convex Finance"
Cohesion: 0.29
Nodes (7): Convex Finance, DELTA, DESIGN, EVIDENCE, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 2 - "Pendle"
Cohesion: 0.29
Nodes (7): DELTA, DESIGN, EVIDENCE, Pendle, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 3 - "Spark Savings (sUSDS / Sky Savings Rate)"
Cohesion: 0.29
Nodes (7): DELTA, DESIGN, EVIDENCE, REPO, Spark Savings (sUSDS / Sky Savings Rate), WHAT IT DOES, WHAT LOOKS UNNAMEABLE

### Community 4 - "Huma Finance V2"
Cohesion: 0.29
Nodes (7): DELTA, DESIGN, EVIDENCE, Huma Finance V2, REPO, WHAT IT DOES, WHAT LOOKS UNNAMEABLE

## Knowledge Gaps
- **30 isolated node(s):** `WHAT IT DOES`, `DESIGN`, `REPO`, `EVIDENCE`, `WHAT LOOKS UNNAMEABLE` (+25 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — category 06, Yield / vaults / aggregators` connect `Stage 1 research — category 06, Yield / vaults / aggregators` to `CIAN Yield Layer`, `Convex Finance`, `Pendle`, `Spark Savings (sUSDS / Sky Savings Rate)`, `Huma Finance V2`?**
  _High betweenness centrality (0.833) - this node is a cross-community bridge._
- **Why does `Pendle` connect `Pendle` to `Stage 1 research — category 06, Yield / vaults / aggregators`?**
  _High betweenness centrality (0.310) - this node is a cross-community bridge._
- **Why does `Spark Savings (sUSDS / Sky Savings Rate)` connect `Spark Savings (sUSDS / Sky Savings Rate)` to `Stage 1 research — category 06, Yield / vaults / aggregators`?**
  _High betweenness centrality (0.310) - this node is a cross-community bridge._
- **What connects `WHAT IT DOES`, `DESIGN`, `REPO` to the rest of the system?**
  _30 weakly-connected nodes found - possible documentation gaps or missing edges._