# Graph Report - 03-cdp-stablecoins  (2026-08-04)

## Corpus Check
- 9 files · ~32,212 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 25 nodes · 18 edges · 8 communities (3 shown, 5 thin omitted)
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `03b70c9a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- DSS Architecture
- Section brief — CDP / collateral-backed stablecoins
- BOLD
- Ethena
- MCD_CLIPPER
- lisUSD
- SECTION-NOTES.md
- Stage 3: the constructions, machine-checked

## God Nodes (most connected - your core abstractions)
1. `Section brief — CDP / collateral-backed stablecoins` - 7 edges
2. `Stage 3: the constructions, machine-checked` - 3 edges
3. `Sky Lending` - 3 edges
4. `DSS Architecture` - 3 edges
5. `The question this category answers` - 1 edges
6. `The corpus decomposition, as of 2026-08-04` - 1 edges
7. `The category residue the original lane recorded` - 1 edges
8. `Where the corpus and the construction disagree` - 1 edges
9. `Residue, verbatim` - 1 edges
10. `Sources` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Shared DSS Liquidation Engine Implementation** — mcd_vat, mcd_dog, mcd_clipper [EXTRACTED 1.00]

## Communities (8 total, 5 thin omitted)

### Community 0 - "DSS Architecture"
Cohesion: 0.33
Nodes (6): DSS Architecture, Lista CDP, MCD_VAT, Sky Lending, USDD, USDS

### Community 1 - "Section brief — CDP / collateral-backed stablecoins"
Cohesion: 0.29
Nodes (6): Lane narrative, Section brief — CDP / collateral-backed stablecoins, Sources, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers

### Community 7 - "Stage 3: the constructions, machine-checked"
Cohesion: 0.67
Nodes (3): Residue, verbatim, Stage 3: the constructions, machine-checked, Where the corpus and the construction disagree

## Knowledge Gaps
- **19 isolated node(s):** `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded`, `Where the corpus and the construction disagree`, `Residue, verbatim` (+14 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Section brief — CDP / collateral-backed stablecoins` connect `Section brief — CDP / collateral-backed stablecoins` to `Stage 3: the constructions, machine-checked`?**
  _High betweenness centrality (0.120) - this node is a cross-community bridge._
- **Why does `Stage 3: the constructions, machine-checked` connect `Stage 3: the constructions, machine-checked` to `Section brief — CDP / collateral-backed stablecoins`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **What connects `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded` to the rest of the system?**
  _19 weakly-connected nodes found - possible documentation gaps or missing edges._