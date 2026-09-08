# DeFiFormal source graph — strategic audit

Captured 2026-09-08T14:40:22.661489+00:00. Primary HEAD `a12b7cac05a818cc8d35c2ca440b7170a2807e92`.

638 source-file nodes, 568 directed edges, 347 communities. Graphify AST: 2754 symbol nodes / 5957 edges before file aggregation. Model extraction tokens: 0 input / 0 output. No token-reduction benchmark was run.

## Scope and limits

- Lean imports only; no Lean AST/theorem/call extraction
- Quint/TLA/Solidity unsupported by installed AST remain file inventory
- Static AST resolution is incomplete especially dynamic CLI and shell calls
- Candidate->primary import fallback is architectural navigation, not candidate dependency equality verification
- Disconnected files are not proven dead
- Metadata counts and community cohesion are not proof or progress scores

Primary and candidate layers are separate. No candidate is accepted by appearing in this graph. Existing root/codebase graphs remain preserved as historical snapshots. HTML uses Graphify’s CDN visualization dependency.

## Layer inventory

- primary: 577 files
- sprint12: 10 files
- lifecycle: 4 files
- claims: 9 files
- corpus: 12 files
- historical: 13 files
- atlas: 12 files
- honest-gate: 1 files

## God nodes: measured file dependency hubs

- `primary/formal/v2/tables.mjs`: 53 incoming / 0 outgoing
- `primary/formal/v3/lib.mjs`: 14 incoming / 1 outgoing
- `primary/lean/DefiKernel/AxiomAudit.lean`: 11 incoming / 0 outgoing
- `historical/scripts/historical_reconciliation/common.py`: 9 incoming / 1 outgoing
- `primary/lean/DefiKernel/Interleaving/Execution.lean`: 9 incoming / 3 outgoing
- `primary/scripts/historical_reconciliation/common.py`: 9 incoming / 0 outgoing
- `primary/formal/v3/construct.mjs`: 8 incoming / 2 outgoing
- `corpus/scripts/corpus_adjudication/common.py`: 7 incoming / 0 outgoing
- `primary/lean/DefiKernel/Nary/Execution.lean`: 7 incoming / 2 outgoing
- `primary/lean/DefiKernel/Nary/Observation.lean`: 7 incoming / 1 outgoing
- `primary/lean/DefiKernel/Parallel/Execution.lean`: 7 incoming / 2 outgoing
- `primary/scripts/corpus_adjudication/common.py`: 7 incoming / 0 outgoing
- `primary/lean/DefiKernel/Composition/Sequence.lean`: 6 incoming / 1 outgoing
- `primary/lean/DefiKernel/Interface/Accounting.lean`: 6 incoming / 2 outgoing
- `primary/lean/DefiKernel/Interleaving/Soundness.lean`: 6 incoming / 1 outgoing
- `primary/lean/DefiKernel/Nary/Examples.lean`: 6 incoming / 6 outgoing
- `primary/lean/DefiKernel/Nary/LocalOrder.lean`: 6 incoming / 1 outgoing
- `primary/lean/DefiKernel/Typed/Examples.lean`: 6 incoming / 1 outgoing
- `primary/lean/DefiKernel/Typed/Transition.lean`: 6 incoming / 2 outgoing
- `historical/scripts/historical_reconciliation/access.py`: 5 incoming / 0 outgoing

## Surprising connections and audit implications

The legacy `formal/v2/tables.mjs` remains a dependency of reporting/visualization tools. It is not safely removable merely because the proof program pivoted. New candidate proof modules are often standalone roots and must not be deleted based on the delivered umbrella root alone. See actual paths in graph.json.

## Communities

| ID | Dominant file family | Files | Raw cohesion |
|---|---|---:|---:|
| 0 | primary/lean/DefiKernel/Parallel | 37 | 0.08858858858858859 |
| 1 | primary/formal/v2 | 36 | 0.05555555555555555 |
| 2 | primary/lean/DefiKernel/Nary | 32 | 0.15120967741935484 |
| 3 | primary/lean/DefiKernel/Atomic | 26 | 0.15384615384615385 |
| 4 | primary/lean/DefiKernel/Arithmetic | 22 | 0.15151515151515152 |
| 5 | primary/lean/DefiHistorical | 19 | 0.11695906432748537 |
| 6 | primary/formal/v3 | 14 | 0.14285714285714285 |
| 7 | primary/lean/DefiKernel/Metatheory | 14 | 0.25274725274725274 |
| 8 | primary/lean/Defialgebra | 13 | 0.16666666666666666 |
| 9 | primary/lean/DefiKernel/Interface | 12 | 0.3333333333333333 |
| 10 | corpus/scripts/corpus_adjudication | 11 | 0.32727272727272727 |
| 11 | historical/scripts/historical_reconciliation | 11 | 0.45454545454545453 |
| 12 | primary/scripts/corpus_adjudication | 11 | 0.32727272727272727 |
| 13 | primary/formal/v3 | 10 | 0.2 |
| 14 | primary/scripts/historical_reconciliation | 10 | 0.4444444444444444 |
| 15 | claims/lean/DefiKernel/Claims | 9 | 0.25 |
| 16 | primary/viz/src | 8 | 0.42857142857142855 |
| 17 | atlas/viz/src | 5 | 0.4 |
| 18 | primary/formal/analyze.mjs | 4 | 0.5 |
| 19 | primary/algebra/solvers | 3 | 0.6666666666666666 |
| 20 | atlas/viz/test | 2 | 1.0 |
| 21 | primary/algebra/gpcat-predicate.mjs | 2 | 1.0 |
| 22 | primary/algebra/research | 2 | 1.0 |
| 23 | primary/audit/arity | 2 | 1.0 |

## Suggested questions

- Which historical tools remain on the current reporting and Atlas dependency paths?
- Which candidate modules are absent from delivered verification roots?
- Which apparent orphan files are externally invoked CLI or evidence roots?

## Integrity

Source drift: 0. Dangling edges: 0. Unparsed Lean import tokens: 0. Extraction failures are recorded in analysis.json. No inference of semantic soundness follows from graph integrity.
