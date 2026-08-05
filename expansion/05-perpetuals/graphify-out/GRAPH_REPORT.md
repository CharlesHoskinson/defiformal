# Graph Report - 05-perpetuals  (2026-08-04)

## Corpus Check
- 10 files · ~41,373 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 84 nodes · 80 edges · 11 communities (10 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e74ec6e8`
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
- Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals)
- Aster
- edgeX
- Hyperliquid

## God Nodes (most connected - your core abstractions)
1. `Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals)` - 9 edges
2. `Aster` - 9 edges
3. `edgeX` - 7 edges
4. `Hyperliquid` - 7 edges
5. `ApeX Protocol (ApeX Omni)` - 7 edges
6. `Aster` - 7 edges
7. `Lighter` - 7 edges
8. `edgeX` - 7 edges
9. `Section brief — Perpetuals / derivatives` - 7 edges
10. `Hyperliquid` - 6 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (11 total, 1 thin omitted)

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

### Community 7 - "Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals)"
Cohesion: 0.15
Nodes (12): ApeX Protocol (ApeX Omni), CORRECTS ROUND ONE, CORRECTS ROUND ONE, Funding, Funding — and ApeX is the exception, Lighter, Measured, Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals) (+4 more)

### Community 8 - "Aster"
Cohesion: 0.22
Nodes (9): Aster, Audits — the chain, the clearinghouse, the engine and the bridge are all uncovered, Confirmed verbatim at the primary source, CORRECTS ROUND ONE, Funding — three venues, three different objects, "Onchain" is currently unfalsifiable from outside, The admission rule is published and contradicted, The escape hatch: none — a confirmed negative over the complete corpus (+1 more)

### Community 9 - "edgeX"
Cohesion: 0.29
Nodes (7): Audits — scope named, and one live contract outside it, CORRECTS ROUND ONE — the live custody stack is StarkEx, not the Arbitrum rollup, CORRECTS ROUND ONE — the loss-absorption layer is not absent, it is undocumented-but-observable, CORRECTS ROUND ONE — the proof regime of the current stack is *worse* than V1's, edgeX, Funding, One anomaly I could not resolve

### Community 10 - "Hyperliquid"
Cohesion: 0.33
Nodes (6): Funding — stated exactly, Hyperliquid, Measured, New material round one did not carry, The absence census, on a provenance-checked corpus, Who may halt a market — the delisting vote

## Knowledge Gaps
- **66 isolated node(s):** `Funding — stated exactly`, `Who may halt a market — the delisting vote`, `The absence census, on a provenance-checked corpus`, `New material round one did not carry`, `Measured` (+61 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Stage 1 research — Perpetuals / derivatives (05-perpetuals)` connect `Lighter` to `ApeX Protocol (ApeX Omni)`, `Aster`, `Hyperliquid`, `edgeX`?**
  _High betweenness centrality (0.154) - this node is a cross-community bridge._
- **Why does `Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals)` connect `Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals)` to `Aster`, `edgeX`, `Hyperliquid`?**
  _High betweenness centrality (0.140) - this node is a cross-community bridge._
- **Why does `Aster` connect `Aster` to `Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals)`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **What connects `Funding — stated exactly`, `Who may halt a market — the delisting vote`, `The absence census, on a provenance-checked corpus` to the rest of the system?**
  _66 weakly-connected nodes found - possible documentation gaps or missing edges._