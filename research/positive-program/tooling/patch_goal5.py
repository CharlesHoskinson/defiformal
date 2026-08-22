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

t = t.replace(
    "> ## STATUS 2026-08-05 (pass 4) — PHASE 2 PRELIMINARIES ALL PASSED",
    "> ## STATUS 2026-08-05 (pass 5) — PLAN REVIEW FAILED; REPAIRS IN PROGRESS")

addition = """>
> **Pass 5 — the plan review failed and gate 2.1 is BLOCKED again.**
> `phase2/P2-REVIEW.md`: the plan's guards cover the ordering class of deletion
> well and the arithmetic and missing-state classes barely at all. Five repairs
> required.
>
> **The fourth trap was inside the plan.** `P2-FIDELITY` F3 (parsimony)
> instructed the worker to collapse any distinction the mutant suite did not
> need and iterate to a fixed point. The worker also authors the mutant suite,
> so a thin suite licensed deleting almost anything — and it made the generation
> measurement circular, the corpus becoming a function of the ten contrast sets.
> Same shape as the other three traps, except mandated. **Repaired**: F3 is now
> reporting-only, and deletion additionally requires the contract-facing
> droppability test.
>
> **The acceptance test was cheatable for eight of ten** — it checks the shape
> of a definition, never its value. Repair: exact conformance vectors read off
> the contract.
>
> **The `nondet` convention catches 3 of 10** and is silent on every arithmetic
> and missing-state deletion.
>
> Repairs 1 and 4 are applied. Repairs 2, 3 and 5 are in flight as the repaired
> execution contract.
>
> **Guard strengthened:** `respec_lint.py` D3 now matches trailing comments, the
> form of the confirmed `apex.qnt:145` defect. D3 findings went 2 -> 7; baseline
> is now **185 findings / 57 specs**.
>
> **apex has six deletions, not three** — all confirmed against source, and it
> was the one protocol nobody had independently checked.
"""

marker = "> **Still unsupported:** `|P| = 4` and the six sorts. Gate 0.1 remains FAILED."
if marker in t and "Pass 5 —" not in t:
    t = t.replace(marker, addition + marker)

g.write_text(t, encoding="utf-8")
print("GOAL.md synced to pass 5")
