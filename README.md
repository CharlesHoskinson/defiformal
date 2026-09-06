# defiformal

A semantic and verification foundation for decentralised finance.

**Active direction (2026-09-06):** typed open financial state transitions, with
explicit assets, authority, claims, interfaces, effects, and environment
assumptions. The research objective is conditional preservation under
composition. Financial mechanisms become libraries; the atlas remains an
empirical ontology. The four-primitive basis is withdrawn.

Start with the [approved migration design](docs/superpowers/specs/2026-09-06-semantic-kernel-design.md),
[execution plan](docs/superpowers/plans/2026-09-06-semantic-kernel-pivot.md), and
[progress ledger](docs/research/semantic-kernel-progress.md).
The [supplied proposal](docs/research/2026-09-06-defi-source-plan.md) is preserved
as source material; its citation placeholders and attachments remain unresolved.

## Retained research

A vocabulary of 58 recurring on-chain financial mechanisms, extracted from 72
deployed protocols across 12 categories, together with the constraints saying
which mechanisms require which others and which combinations are forbidden — and
an investigation of what, if anything, composition preserves.

**The existing paper is `paper/atlas.tex`.** It records the earlier research
program and has not yet been rewritten for the semantic kernel. Build it with
`./paper/build.sh`.

## Earlier results and their scope

- **Polarity.** Requirements and warrants are dual-Horn, prohibitions Horn. So the
  protocols satisfying requirements and warrants form a complete lattice under
  union. Adding admissibility constraints need not preserve set union or set
  intersection; that alone does not decide whether the induced poset is a
  lattice. The clause classification is an instance of the Pol–Inv
  characterisation, not a new result.
- **The deterministic fragment is a convex geometry.** A union-stable closure is
  anti-exchange iff its specialization digraph is acyclic; ours is. Verified
  through a structural reduction formalised in Lean 4. The separate bounded
  executions and instance measurements must retain their own stated scope.
- **Composition on canonical forms is linear.** Every protocol has a unique
  minimal generator, and the generator of a composite is computable from the
  generators of its parts without consulting the rest of the vocabulary.
- **The positive theory does not bind.** Its 79 clauses exclude no element across
  any of the 72 protocols. The vocabulary rejects; it does not predict.

## What is not

The order structure of the admissible sets is unknown. Composition failure comes
from constraints that are neither Horn nor dual-Horn, and so lie outside the
classification that explains the structure. And the vocabulary is not complete:
not one of the 72 protocols is fully expressible, with coverage degrading as more
of a protocol lives off-chain — which is inversely correlated with capital held.

## Layout

| | |
|---|---|
| `paper/` | the paper, its bibliography, and a build script that fails loudly |
| `lean/` | Lean 4 + mathlib formalisation (`lake exe cache get` then `lake build`) |
| `formal/` | Quint models and the verification harnesses |
| `corpus50/` | the 72 protocol decompositions, from three independent blind lanes |
| `algebra/` | requirements, the theorem ledger, results as graph nodes, research |
| `review/` | referee reports and the record of what was actioned |
| `viz/` | the element data, the law engine, and the visualisation backlog |
| `papers/` | inventories of the literature (PDFs are gitignored) |

## Method

Claims carry their epistemic status in their environment: **theorem** means
proved, **measurement** means established computationally with the instance and
bound stated, **conjecture** means believed with the evidence named. Measurements
are marked *exhaustive* or *sampled*. The paper states results; the working
record of what was refuted along the way lives in `algebra/THEOREM-LEDGER.md`
and `review/ACTIONS.md`.

Every substantive claim was attacked before it was kept. Three referee reports
returned major revision; the findings and their resolutions are in `review/`.

## Reproducing

```bash
./paper/build.sh                              # the paper
cd lean && lake exe cache get && lake build   # the formalisation
node formal/v2/pairs.mjs                      # which protocols compose
node formal/v2/canonical.mjs                  # canonical forms of the corpus
node formal/v2/antiexchange.mjs               # the convex-geometry check
```
