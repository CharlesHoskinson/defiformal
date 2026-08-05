# defiformal

An algebra of mechanism composition for decentralised finance.

A vocabulary of 58 recurring on-chain financial mechanisms, extracted from 72
deployed protocols across 12 categories, together with the constraints saying
which mechanisms require which others and which combinations are forbidden — and
an investigation of what, if anything, composition preserves.

**The paper is `paper/atlas.tex`.** Build it with `./paper/build.sh`.

## What is established

- **Polarity.** Requirements and warrants are dual-Horn, prohibitions Horn. So the
  protocols satisfying requirements and warrants form a complete lattice under
  union, which admissibility does not inherit. This is an instance of the
  Pol–Inv characterisation, not a new result.
- **The deterministic fragment is a convex geometry.** A union-stable closure is
  anti-exchange iff its specialization digraph is acyclic; ours is. Verified
  exhaustively over all 1.44 × 10¹⁶ closed sets, and formalised in Lean 4.
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
