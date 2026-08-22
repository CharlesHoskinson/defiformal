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


g = pathlib.Path(str(_REPO / "research/positive-program/GOAL.md"))
t = g.read_text(encoding="utf-8")

old_head = "> ## STATUS 2026-08-05 (pass 3) — PHASE 2 IN PROGRESS"
new_head = "> ## STATUS 2026-08-05 (pass 4) — PHASE 2 PRELIMINARIES ALL PASSED"
t = t.replace(old_head, new_head)

addition = """>
> **Pass 4 update — every Phase 2 preliminary is green; gate 2.1 is unblocked.**
> The kernel is built and independently verified: `phase2/kernel/` 9/9 typecheck.
> The inexpressibility claim ("unrolled for quint purity without loops") is
> **false on all three counts**. Extremal selection is not merely expressible
> but *cheaper*: zero extra reachable states (machine-checked by a
> `listIsCanonical` invariant), ~1.6x wall clock, flat from 3 to 24 troves,
> branching drops, and Apalache proved the 7-part mechanism invariant to depth 3.
> `isqrt` is exact on `0 <= n < 2^62`. Fixed-depth Newton was measured and
> rejected.
>
> Five hard constraints now bind every re-spec (see ROADMAP gate 2.0d): i64
> backend overflow; Newton needs a `done` flag or it silently deletes the
> contract's break, at depth K=8; convergence obligations must not sit in a
> precondition; history-based regression guards are unsound; and Curve's integer
> Newton genuinely fails to converge on 2.8% of a 1372-point grid.
>
> **Still unsupported:** `|P| = 4` and the six sorts. Gate 0.1 remains FAILED.
"""

marker = "> **Fidelity is a quotient, not a refinement.**"
if marker in t and "Pass 4 update" not in t:
    idx = t.index(marker)
    end = t.index("\n\n", t.index("(`phase2/P2-FIDELITY.md`).", idx))
    t = t[:end] + "\n" + addition + t[end:]

g.write_text(t, encoding="utf-8")
print("GOAL.md synced to pass 4")
