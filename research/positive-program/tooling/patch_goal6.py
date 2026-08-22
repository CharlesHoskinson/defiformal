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

addition = """>
> **Pass 6 — all Phase 2 preliminaries closed; writing has started.**
> Gate 2.0f CLOSED. The pilot re-spec of `uniswap_v2` is in flight into
> `quint-models-v2/`, seeded with the verified `sqrt.qnt` and `sorted.qnt`.
>
> Two corrections landed, one of them to my own work. The Curve domain
> recommendation of `10^5..10^7` was justified against the **product of the
> balances**; the binding quantity is the peak Newton intermediate, which is
> cubic at extreme imbalance and reaches `5.0e20` at `(10^7, 1)` — overflowing
> i64. Corrected cap `10^6` (peak `5.0e17`, 18x headroom, witness still hosted).
>
> And the old range cap of 200 did not merely degrade the corpus. Applying the
> new constant-crossing rule retroactively, **six of the ten protocols were dead
> under it** — `uniswap_v2` and `apex` (`MINIMUM_LIQUIDITY = 1000`), `gmx`
> (`FLOAT_PRECISION`), `liquity` (`MIN_DEBT = 2000`), `morpho_blue`
> (`VIRTUAL_SHARES = 10^6`), `derive` (spot `10^4`).
>
> Convention 6g (dependency parity) closed the last uncovered deletion and
> independently re-caught four already covered by different rules — evidence it
> is the right generalisation rather than another patch.
>
"""

marker = "> **Still unsupported:**"
if marker in t and "Pass 6 —" not in t:
    t = t.replace(marker, addition + marker, 1)
    g.write_text(t, encoding="utf-8")
    print("GOAL.md pass-6 body applied")
else:
    print("already present or marker missing")
