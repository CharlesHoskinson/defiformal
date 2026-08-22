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

section = """

---

## Gate 2.1b — W1 (`curve`, `apex`) delivered

Both typecheck; all invariants clean; 34 + 42 T0 vectors; 12 + 18 `wit_*` trace
obligations all violated as required; lint 0 on `curve`, 1 justified on `apex`.
Mutants confirm the separation: on both M1s `inv_conservation` still reports
**[ok]** while `inv_T0` is violated — i.e. the conservation invariant alone does
not detect the deleted mechanism.

### Five corrections from W1, all load-bearing

1. **K=8's worst case is 8, not 7.** K=8 is *tight*, not slack; K=7 would
   silently mis-evaluate pairs that need all eight. Verified independently:
   49 of 4900 sampled pairs need exactly 8 at a 10^5 cap.
2. **`get_D` is asymmetric, and the asymmetry is the contract's own.** `D_P` is
   two *sequential* floor divisions, so `(10^5, 1)` is a period-2 limit cycle
   that never converges at any depth, while `(1, 10^5)` converges at exactly 8.
   Verified: `(10^6, 1)` diverges, `(1, 10^6)` converges in 10. A "tidied"
   symmetric rewrite must therefore fail, and `kernelNewtonOk` asserts it does.
3. **The residual bound of 1 is FALSE for the contract.** `get_D`'s break bounds
   the *step* `|D - Dprev| <= 1`, not the *residual* at the returned D. At
   `(100010, 1)` it breaks with residual 3. Shipped with the true bound.
4. **`inv_kMonotone` does not kill apex's fee deletion.** Measured on the mutant:
   with 999/1000 removed entirely, `inv_kMonotone` still reports **[ok]**,
   because integer flooring alone makes k non-decreasing. **A prescribed positive
   check that the deleted mechanism satisfies** — the same shape as the other
   traps. Only T0 separates them. It is also *false as stated* for closes and
   liquidations, where an underwater settlement makes k fall.
5. **`PILOT-NOTES` mis-cites apex's M3 agreement as 7/49; it is 0/49** — the v1
   body has no `MINIMUM_LIQUIDITY` subtraction at all, so it cannot agree even on
   the diagonal.

### NEW — a correction to this roadmap's own curve domain (`evidence/curve_k.py`)

Carry-forward 3 recommended a **10^6** cap for curve. That is wrong for K=8:

| cap | worst converging | K=8 verdict |
|---|---|---|
| 10^4 | 6 iters | sufficient |
| 10^5 | 8 iters | **exactly tight** |
| 10^6 | **12 iters** | **truncates 97 of 4900 converging pairs** |

W1 measured K=8 tight on a grid topping out near 10^5, then the domain shipped
at 10^6. A bound validated on a domain smaller than the one it ships against is
the same failure this whole phase exists to prevent — and this instance is in
the roadmap's own recommendation, not a worker's.

**Resolution:** either cap curve at **10^5** (K=8 exactly tight, divergence
witness still hosted — 10 non-converging in a 4900 sample — and vast i64
headroom), or keep 10^6 and raise **K >= 12**. The 10^5 option is cheaper and
keeps the verified kernel unchanged. **W1's shipped curve domain must be checked
against this before 2.1b closes.**"""

if "## Gate 2.1b — W1" not in t:
    t = t + section
r.write_text(t, encoding="utf-8")
print("ROADMAP updated with W1 result and the curve-domain correction")
