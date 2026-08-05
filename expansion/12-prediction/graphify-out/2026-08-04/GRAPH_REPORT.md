# Graph Report - 12-prediction  (2026-08-04)

## Corpus Check
- 9 files · ~29,372 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 37 nodes · 26 edges · 13 communities (6 shown, 7 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `03b70c9a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Grove Finance
- Steakhouse Financial
- Azuro
- Gnosis Conditional Tokens Framework
- KalshiEX LLC
- MainnetController
- Polymarket US
- Azuro Protocol
- sUSDS
- USDS
- Section brief — Prediction markets & other (uncategorized large protocols)
- Stage 3: the constructions, machine-checked
- SECTION-NOTES.md

## God Nodes (most connected - your core abstractions)
1. `Section brief — Prediction markets & other (uncategorized large protocols)` - 7 edges
2. `Steakhouse Financial` - 4 edges
3. `Grove Finance` - 4 edges
4. `Stage 3: the constructions, machine-checked` - 3 edges
5. `Polymarket Polygon` - 2 edges
6. `UMA CTF Adapter` - 2 edges
7. `Gnosis Conditional Tokens Framework` - 2 edges
8. `Azuro` - 2 edges
9. `The question this category answers` - 1 edges
10. `The corpus decomposition, as of 2026-08-04` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Prediction Market Venues** — 01_research_kalshi_ex, 01_research_polymarket_polygon, 01_research_polymarket_us, 01_research_azuro_protocol [EXTRACTED 1.00]
- **Risk Curator Infrastructure** — 01_research_steakhouse_financial, 01_research_morpho, 01_research_kamino [EXTRACTED 0.80]
- **Onchain Capital Allocator Infrastructure** — 01_research_grove_finance, 01_research_sky, 01_research_almproxy [EXTRACTED 0.80]

## Communities (13 total, 7 thin omitted)

### Community 0 - "Grove Finance"
Cohesion: 0.40
Nodes (5): ALMProxy, Centrifuge, Grove Finance, JAAA (Janus Henderson Anemoy AAA CLO Strategy), Sky (formerly MakerDAO)

### Community 1 - "Steakhouse Financial"
Cohesion: 0.40
Nodes (5): Aragon DAO, Kamino, Morpho, morpho-org/metamorpho, Steakhouse Financial

### Community 2 - "Azuro"
Cohesion: 0.67
Nodes (3): Azuro, AzuroDAO, Data Provider

### Community 3 - "Gnosis Conditional Tokens Framework"
Cohesion: 1.00
Nodes (3): Gnosis Conditional Tokens Framework, Polymarket Polygon, UMA CTF Adapter

### Community 10 - "Section brief — Prediction markets & other (uncategorized large protocols)"
Cohesion: 0.29
Nodes (6): Lane narrative, Section brief — Prediction markets & other (uncategorized large protocols), Sources, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers

### Community 11 - "Stage 3: the constructions, machine-checked"
Cohesion: 0.67
Nodes (3): Residue, verbatim, Stage 3: the constructions, machine-checked, Where the corpus and the construction disagree

## Knowledge Gaps
- **27 isolated node(s):** `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded`, `Where the corpus and the construction disagree`, `Residue, verbatim` (+22 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Section brief — Prediction markets & other (uncategorized large protocols)` connect `Section brief — Prediction markets & other (uncategorized large protocols)` to `Stage 3: the constructions, machine-checked`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Why does `Stage 3: the constructions, machine-checked` connect `Stage 3: the constructions, machine-checked` to `Section brief — Prediction markets & other (uncategorized large protocols)`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **What connects `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded` to the rest of the system?**
  _27 weakly-connected nodes found - possible documentation gaps or missing edges._