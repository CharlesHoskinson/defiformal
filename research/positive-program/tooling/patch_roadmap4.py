import pathlib
import os as _os
from pathlib import Path as _Path
# Resolved from this file's own location, the pattern gate33_cert_check.py uses.
# DEFIFORMAL_ROOT overrides and says so.
_SELF = _Path(__file__).resolve().parents[3]
_REPO = _Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    import sys as _sys
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


r = pathlib.Path(str(_REPO / "research/positive-program/ROADMAP.md"))
t = r.read_text(encoding="utf-8")

old = "### Carry-forward 3 — two agents disagree about Curve, and the disagreement IS the lesson"
new = "### Carry-forward 3 — RESOLVED by direct computation (`evidence/curve_reconcile.py`)"
t = t.replace(old, new)

marker = "Reconcile the two grids explicitly and record which domain each\nclaim holds on."
resolution = """Reconciled. Faithful integer `get_D` (StableSwap n=2) swept directly:

| domain | amp | K | points | non-converging | rate | worst iters |
|---|---|---|---|---|---|---|
| 1..200 | 100 | 8 | 40000 | 0 | 0.00% | 3 |
| 1..200 | 100 | 96 | 40000 | 0 | 0.00% | 3 |
| 1..2000 | 100 | 8 | 23716 | 0 | 0.00% | 5 |
| 1..10^5 | 100 | 8 | 20449 | 18 | 0.09% | 8 |
| 1..10^7 | 100 | 8 | 20449 | 280 | 1.37% | 8 |
| 1..10^7 | 100 | 96 | 20449 | 75 | 0.37% | 17 |

**Both agents were right on their own domain, and that is the finding.** The
pathology is real and lives *exactly outside* the `<=200` domain. Threshold is
between 10^4 (converges, 6 iterations) and 10^5 (does not converge at any depth
up to 96). Every non-converging point sits at extreme imbalance — the first
five all have `y = 1`. Raising depth from K=8 to K=96 reduces the rate
(1.37% -> 0.37%) but never eliminates it, which is consistent with the
period-2 limit cycle reported at gate 2.0d.

**Consequence, and it is the whole lesson of Phase 2 in one instance:** adopting
the `<=200` sweep as evidence that Curve converges would repeat, exactly, the
failure by which Curve's v1 spec reached `bal0 = bal1 = 100` and lost its
discrimination witness. A small domain does not prove convergence; it hides
divergence.

**Resolution for the re-spec:** Curve's declared domain must reach past 10^4 to
host the non-convergence witness, and 10^5..10^7 does so while staying inside
i64 (10^7 * 10^7 = 10^14, well under 9.2 * 10^18). Adopt that range and assert
the witness explicitly."""

t = t.replace(marker, resolution)

t = t.replace(
    "| 2.0f close three carry-forwards | **OPEN** | see below — all three are pre-`2.1` blockers |",
    "| 2.0f close three carry-forwards | **1 of 3 closed** | CF3 resolved by computation; CF1 (pilot range cap) and CF2 (apex trigger, uncovered) open |")

r.write_text(t, encoding="utf-8")
print("ROADMAP updated: carry-forward 3 resolved")
