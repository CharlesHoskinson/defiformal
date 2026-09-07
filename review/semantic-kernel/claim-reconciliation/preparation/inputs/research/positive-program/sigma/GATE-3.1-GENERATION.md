# Phase 3.1 — generation (status from honest corpus)

**Claim options (ROADMAP):**  
(A) `P` generates the corpus, or  
(B) the residue names the closure.

**Measured (Gate 2.3, repo-reproducible):** on the ten re-specs,

| | ungenerated defs | rate |
|---|---:|---:|
| v1 | 28 / 168 | **16.7%** |
| v2 | 119 / 716 | **16.6%** |

Source: `sigma/GATE-2.3-TEN.md`, `basis/denominators.py`, Sol APPROVE at `292dc55`.

**Disposition:** (A) is **false** on the measured slice. (B) is the live claim:
residue / ungenerated protocol definitions name the closure gap. Rate is flat
v1→v2 → gap is **coverage / missing generators**, not fixable by the ten
fidelity re-specs alone.

**Gate 3.1 status:** **MEASURED** (inherits 2.3). Do not re-claim generation
without a new corpus slice and re-run.

## What would strengthen 3.1

1. Re-run generation after absorbing 2.2's six new specs (out of historical ten).
2. Name residue families for the ungenerated IR nodes (link `RESIDUE-*.md`).
