# Graph Report - 03-cdp-stablecoins  (2026-08-04)

## Corpus Check
- 3 files · ~13,305 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 23 nodes · 16 edges · 7 communities (2 shown, 5 thin omitted)
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4717d916`
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

## God Nodes (most connected - your core abstractions)
1. `Section brief — CDP / collateral-backed stablecoins` - 7 edges
2. `Sky Lending` - 3 edges
3. `DSS Architecture` - 3 edges
4. `The question this category answers` - 1 edges
5. `The corpus decomposition, as of 2026-08-04` - 1 edges
6. `The category residue the original lane recorded` - 1 edges
7. `Stage 3` - 1 edges
8. `Sources` - 1 edges
9. `Lane narrative` - 1 edges
10. `Lane narrative` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Shared DSS Liquidation Engine Implementation** — mcd_vat, mcd_dog, mcd_clipper [EXTRACTED 1.00]

## Communities (7 total, 5 thin omitted)

### Community 0 - "DSS Architecture"
Cohesion: 0.33
Nodes (6): DSS Architecture, Lista CDP, MCD_VAT, Sky Lending, USDD, USDS

### Community 1 - "Section brief — CDP / collateral-backed stablecoins"
Cohesion: 0.25
Nodes (7): Lane narrative, Section brief — CDP / collateral-backed stablecoins, Sources, Stage 3, The category residue the original lane recorded, The corpus decomposition, as of 2026-08-04, The question this category answers

## Knowledge Gaps
- **18 isolated node(s):** `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded`, `Stage 3`, `Sources` (+13 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `The question this category answers`, `The corpus decomposition, as of 2026-08-04`, `The category residue the original lane recorded` to the rest of the system?**
  _18 weakly-connected nodes found - possible documentation gaps or missing edges._