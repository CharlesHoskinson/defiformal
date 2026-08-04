# Graph Report - /root/DefiElements/algebra/results  (2026-08-04)

## Corpus Check
- Corpus is ~810 words - fits in a single context window. You may not need a graph.

## Summary
- 32 nodes · 61 edges · 5 communities
- Extraction: 61% EXTRACTED · 38% INFERRED · 2% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.86)
- Token cost: 67,903 input · 0 output

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4

## God Nodes (most connected - your core abstractions)
1. `R05 The definite fragment is a convex geometry [PROVED]` - 11 edges
2. `R01 Clause polarity (dual-Horn / Horn) [PROVED]` - 9 edges
3. `R02 R ∩ W is a complete lattice [PROVED]` - 7 edges
4. `R03 Fix(Γ) is not a Moore family [PROVED]` - 7 edges
5. `R04 Prohibitions are the sole obstruction [PROVED]` - 7 edges
6. `R07 Three frameworks obstructed by one fact [PROVED]` - 7 edges
7. `R09 The structure is real and thin [MEASURED]` - 7 edges
8. `R08 Composition on canonical forms is linear [PROVED]` - 6 edges
9. `R06 Compatibility is trace-determined [PROVED + MEASURED]` - 5 edges
10. `R10 The structure cannot see the 12 categories [MEASURED]` - 4 edges

## Surprising Connections (you probably didn't know these)
- `R01 Clause polarity (dual-Horn / Horn) [PROVED]` --conceptually_related_to--> `R05 The definite fragment is a convex geometry [PROVED]`  [INFERRED]
  R01-polarity.md → R05-convex.md
- `R02 R ∩ W is a complete lattice [PROVED]` --conceptually_related_to--> `R05 The definite fragment is a convex geometry [PROVED]`  [INFERRED]
  R02-lattice.md → R05-convex.md
- `R03 Fix(Γ) is not a Moore family [PROVED]` --conceptually_related_to--> `R04 Prohibitions are the sole obstruction [PROVED]`  [INFERRED]
  R03-no-moore.md → R04-prohibitions-cost.md
- `R03 Fix(Γ) is not a Moore family [PROVED]` --conceptually_related_to--> `R05 The definite fragment is a convex geometry [PROVED]`  [INFERRED]
  R03-no-moore.md → R05-convex.md
- `R07 Three frameworks obstructed by one fact [PROVED]` --conceptually_related_to--> `R03 Fix(Γ) is not a Moore family [PROVED]`  [INFERRED]
  R07-obstruction.md → R03-no-moore.md

## Hyperedges (group relationships)
- **Derivation chain: clause polarity to complete lattice to prohibition obstruction to trace-determined compatibility** — algebra_results_r01_polarity, algebra_results_r02_lattice, algebra_results_r04_prohibitions_cost, algebra_results_r06_trace_reduction [EXTRACTED 1.00]
- **Definite-fragment compositionality: convex geometry enables linear composition, thinness makes it near-union, prohibitions price leaving the fragment** — algebra_results_r05_convex, algebra_results_r08_composition, algebra_results_r09_thinness, algebra_results_r04_prohibitions_cost [EXTRACTED 1.00]
- **Measured empirical layer over the 72-protocol corpus: trace counts, vacuity/thinness, category invisibility** — algebra_results_r06_trace_reduction, algebra_results_r09_thinness, algebra_results_r10_corpus, protocol_corpus_72 [INFERRED 0.85]

## Communities (5 total, 0 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.42
Nodes (9): R04 Prohibitions are the sole obstruction [PROVED], R06 Compatibility is trace-determined [PROVED + MEASURED], R08 Composition on canonical forms is linear [PROVED], R09 The structure is real and thin [MEASURED], R10 The structure cannot see the 12 categories [MEASURED], Canonical form operator ex(·) and ⪯-maximal generators, Compatibility trace H ∩ A and the 9-vertex quotient blow-up, Corpus of 72 real DeFi protocols across 12 categories (+1 more)

### Community 1 - "Community 1"
Cohesion: 0.48
Nodes (7): R01 Clause polarity (dual-Horn / Horn) [PROVED], R02 R ∩ W is a complete lattice [PROVED], Complete lattice with join = union (R ∩ W), Dual-Horn clauses (exactly one negative literal; union-closed models), Pol-Inv Galois connection, Post's lattice of clones, Schaefer dichotomy theorem

### Community 2 - "Community 2"
Cohesion: 0.47
Nodes (6): Admissibility as a diagonal (agreement set of two opposite maps), R07 Three frameworks obstructed by one fact [PROVED], Approximation fixpoint theory (AFT), Avron's representation theorem for interlaced bilattices, Interlaced bilattice, Tarski fixpoint theorem (lattice fixpoint foundation of AFT)

### Community 3 - "Community 3"
Cohesion: 0.40
Nodes (5): R03 Fix(Γ) is not a Moore family [PROVED], Absence of a closure operator for disjunctive requirements, The definite fragment (E, Cn), Horn clauses / prohibitions (purely negative; intersection-closed models), Moore family (intersection-closed system)

### Community 4 - "Community 4"
Cohesion: 0.80
Nodes (5): R05 The definite fragment is a convex geometry [PROVED], Caspard & Monjardet 2004 §3 (singleton premise ⟹ union-stable, iff), Convex geometry / anti-exchange closure, Edelman 1980 Thm 3.3 (meet-distributive ⟺ convex geometry), Edelman & Jamison 1985 Thm 3.2 (downset alignment iff union-closed)

## Ambiguous Edges - Review These
- `R07 Three frameworks obstructed by one fact [PROVED]` → `Tarski fixpoint theorem (lattice fixpoint foundation of AFT)`  [AMBIGUOUS]
  R07-obstruction.md · relation: cites

## Knowledge Gaps
- **2 isolated node(s):** `Admissibility as a diagonal (agreement set of two opposite maps)`, `Compatibility trace H ∩ A and the 9-vertex quotient blow-up`
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `R07 Three frameworks obstructed by one fact [PROVED]` and `Tarski fixpoint theorem (lattice fixpoint foundation of AFT)`?**
  _Edge tagged AMBIGUOUS (relation: cites) - confidence is low._
- **Why does `R05 The definite fragment is a convex geometry [PROVED]` connect `Community 4` to `Community 0`, `Community 1`, `Community 3`?**
  _High betweenness centrality (0.394) - this node is a cross-community bridge._
- **Why does `R01 Clause polarity (dual-Horn / Horn) [PROVED]` connect `Community 1` to `Community 2`, `Community 3`, `Community 4`?**
  _High betweenness centrality (0.323) - this node is a cross-community bridge._
- **Why does `R07 Three frameworks obstructed by one fact [PROVED]` connect `Community 2` to `Community 1`, `Community 3`?**
  _High betweenness centrality (0.297) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `R05 The definite fragment is a convex geometry [PROVED]` (e.g. with `R01 Clause polarity (dual-Horn / Horn) [PROVED]` and `R02 R ∩ W is a complete lattice [PROVED]`) actually correct?**
  _`R05 The definite fragment is a convex geometry [PROVED]` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `R03 Fix(Γ) is not a Moore family [PROVED]` (e.g. with `R04 Prohibitions are the sole obstruction [PROVED]` and `R05 The definite fragment is a convex geometry [PROVED]`) actually correct?**
  _`R03 Fix(Γ) is not a Moore family [PROVED]` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 4 inferred relationships involving `R04 Prohibitions are the sole obstruction [PROVED]` (e.g. with `R03 Fix(Γ) is not a Moore family [PROVED]` and `R06 Compatibility is trace-determined [PROVED + MEASURED]`) actually correct?**
  _`R04 Prohibitions are the sole obstruction [PROVED]` has 4 INFERRED edges - model-reasoned connections that need verification._