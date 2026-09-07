# Source graph scope and limits

This is a worktree source snapshot, not an accepted release or proof-status graph. Tracked source plus current untracked DefiKernel Lean modules and the two Metatheory runners are included. Review artifacts, documents, generated/vendor/build/dependency trees and symlinks are excluded. The original root graph is unchanged.

Graphify AST extraction is deterministic and uses no model/API. Only EXTRACTED cross-file AST relationships with both endpoints in the selected source set are aggregated. These are extractor-reported static relationships, not validated runtime calls. Lean uses nested-comment/string-masked literal import extraction; it has no Lean AST, call or theorem edges. Quint and other unsupported source files remain inventory-only nodes. All selected files have nodes even without imports. Community labels use dominant source families; cohesion values are structural, not semantic quality scores. Generated questions/connections are navigation suggestions, not independently established semantic claims.

Extraction model tokens: **0 input / 0 output**. No token-reduction benchmark or external-model comparison was run. The interactive HTML loads pinned vis-network 9.1.6 from unpkg.com and needs browser network access.

Full detection flagged these 10 fixture symlinks; none was followed:

- `/home/charl/defiformal/review/semantic-kernel/sprint6/regressions/composition-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint7/regressions/composition-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint7/regressions/parallel-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint8/regressions/composition-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint8/regressions/interleaving-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint8/regressions/parallel-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint9/planning/baseline/python/atomic-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint9/planning/baseline/python/composition-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint9/planning/baseline/python/interleaving-runner-controls/runs/output-symlink [symlink target outside scan root]`
- `/home/charl/defiformal/review/semantic-kernel/sprint9/planning/baseline/python/parallel-runner-controls/runs/output-symlink [symlink target outside scan root]`

---

# Graph Report - defiformal  (2026-09-07)

## Corpus Check
- 492 files · ~547,024 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 492 nodes · 307 edges · 319 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness

This graph includes uncommitted worktree source. Git HEAD alone does not establish freshness. From the repository root, compare the current scoped source-file set and each byte hash with `source-manifest.json`:

```bash
/home/charl/.local/share/uv/tools/graphifyy/bin/python3 graphify-out/codebase/build-source-graph.py --check-freshness
```

Rebuild the scoped AST plus Lean-import graph with:

```bash
/home/charl/.local/share/uv/tools/graphifyy/bin/python3 graphify-out/codebase/build-source-graph.py
```

The generic `graphify update .` command does not reproduce this scope or the Lean import extractor.

## God Nodes (graphify heuristic)

No qualifying symbol hubs were selected in this file-only graph. Measured file dependency hubs are listed below.

## Surprising Connections (you probably didn't know these)
- The algorithm selected no surprising connections. All 307 retained edges are cross-file dependencies; absence of a selected surprise does not imply absence of such connections.

## Import Cycles
- None detected.

## Communities

319 structural communities: 16 with multiple files and 303 singleton communities. Unsupported-source inventory nodes and standalone scripts can be isolated; this is not evidence of semantic independence.

| Community | Dominant source family | Files | Raw cohesion | Family composition |
|---|---|---:|---:|---|
| 0 | formal/v2 | 36 | 0.05555555555555555 | formal/v2: 23, formal/v3: 13 |
| 1 | lean/DefiKernel/Parallel | 22 | 0.1645021645021645 | lean/DefiKernel/Parallel: 15, lean/DefiKernel/Interleaving: 6, lean/DefiKernel/Composition: 1 |
| 2 | lean/DefiKernel/Typed | 18 | 0.16339869281045752 | lean/DefiKernel/Typed: 10, lean/DefiKernel/Composition: 7, lean/DefiKernel/Parallel: 1 |
| 3 | lean/DefiKernel/Atomic | 15 | 0.2761904761904762 | lean/DefiKernel/Atomic: 15 |
| 4 | lean/Defialgebra | 14 | 0.15384615384615385 | lean/Defialgebra: 11, lean: 2, algebra/stage4: 1 |
| 5 | formal/v3 | 14 | 0.14285714285714285 | formal/v3: 14 |
| 6 | lean/DefiKernel/Metatheory | 14 | 0.26373626373626374 | lean/DefiKernel/Metatheory: 12, lean/DefiKernel/Composition: 2 |
| 7 | lean/DefiKernel | 13 | 0.20512820512820512 | lean/DefiKernel: 10, lean: 1, lean/DefiKernel/Composition: 1, lean/DefiKernel/Typed: 1 |
| 8 | lean/DefiKernel/Interleaving | 12 | 0.2878787878787879 | lean/DefiKernel/Interleaving: 12 |
| 9 | formal/v3 | 10 | 0.2 | formal/v3: 10 |
| 10 | viz/src | 8 | 0.42857142857142855 | viz/src: 5, algebra: 3 |
| 11 | formal | 4 | 0.5 | formal: 4 |
| 12 | algebra/solvers | 3 | 0.6666666666666666 | algebra/solvers: 3 |
| 13 | algebra | 2 | 1.0 | algebra: 2 |
| 14 | algebra/research | 2 | 1.0 | algebra/research: 2 |
| 15 | audit/arity | 2 | 1.0 | audit/arity: 2 |

All community assignments and scores are retained in `graph.json` and `analysis.json`.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Should `formal/v2` be split into smaller, more focused modules?**
  _Cohesion score 0.05555555555555555 - nodes in this community are weakly interconnected._
- **Should `formal/v3` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._
## File dependency hubs

Graphify god-node scoring returns no qualifying symbol nodes for this file-only graph. The following are measured file in-degrees, not semantic importance scores.

- `formal/v2/tables.mjs`: 53 incoming, 0 outgoing edges.
- `formal/v3/lib.mjs`: 14 incoming, 1 outgoing edges.
- `formal/v3/construct.mjs`: 8 incoming, 2 outgoing edges.
- `lean/DefiKernel/AxiomAudit.lean`: 7 incoming, 0 outgoing edges.
- `lean/DefiKernel/Interleaving/Execution.lean`: 6 incoming, 3 outgoing edges.
- `lean/DefiKernel/Parallel/Execution.lean`: 6 incoming, 2 outgoing edges.
- `lean/DefiKernel/Interleaving/LocalOrder.lean`: 5 incoming, 1 outgoing edges.
- `lean/DefiKernel/Typed/Examples.lean`: 5 incoming, 1 outgoing edges.
- `lean/DefiKernel/Atomic/Execution.lean`: 4 incoming, 2 outgoing edges.
- `lean/DefiKernel/Composition/Examples.lean`: 4 incoming, 2 outgoing edges.
- `lean/DefiKernel/Composition/Sequence.lean`: 4 incoming, 1 outgoing edges.
- `lean/DefiKernel/Interleaving/Soundness.lean`: 4 incoming, 1 outgoing edges.
