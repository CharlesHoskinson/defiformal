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

t = t.replace(
    "| 2.1 re-spec the ten | **IN FLIGHT (pilot)** | 2.0f closed; three per-protocol collisions to decide first (liquity MIN_DEBT, morpho MAX_LIF, apex ranges) |",
    "| 2.1a pilot (`uniswap_v2`) | **PASSED** | lint 0, typecheck clean, `inv_conservation` ok, 13 `wit_*` all violated as required; 22 T0 vectors |\n"
    "| 2.1b the remaining nine | **IN FLIGHT** | four workers by technique, against pilot conventions |")

addendum = """

---

## Gate 2.1a — pilot result and what it changed

**Passed on every check, independently verified.** Lint 0 findings; `kernel.qnt`,
`uniswap_v2.qnt` and a mutant all typecheck; `inv_conservation` clean over
20 steps x 2000 samples in 91 ms; all 13 `wit_*` obligations report `[violation]`
as required. Conformance vectors, recomputed here:

| input | `isqrtFloor(a0*a1) - 1000` | v1 `min` shortcut |
|---|---|---|
| (4000, 9000) | **5000** | 3000 |
| (2000, 8000) | **3000** | 1000 |
| (1000, 2000) | **414** | 0 (refused) |

All off-diagonal, which is the point: `min` is correct exactly on the diagonal,
where every rival agrees.

### The pilot invalidated its own headline, correctly

It reported that **the v1 spec of the same protocol also scores 0** on the
linter. Confirmed. All five detectors were blind to both of `uniswap_v2`'s
deletions, so the baseline contained nothing from the protocol that motivated
Phase 2. "0 findings" was therefore not evidence of improvement.

**Fixed by adding detector D6** — state with substantive writes and zero reads.
It catches v1's `kLast` (3 writes, read by nothing, because its only consumer
`_mintFee` was absent) and does not fire on the pilot. The comparison is now
meaningful. D6 finds **19 instances corpus-wide**: `funding` twice, `queue`,
`feesOwed`, `feeGrowth`, `protocolFees0`, `loanBorrower`, `permitted`. New v1
baseline **204 findings / 57 specs**, up from 185.

**Also fixed — pilot trap K5, a bug in the guard itself:** `respec_lint.py` was
skipping any file named `kernel.qnt`, leaving the most load-bearing file in the
tree unchecked. Exemption removed; the kernel lints clean.

### Two corrections that bind the remaining nine

1. **Peak intermediate is 4.61e18, not 4e8.** It lives inside `isqrtFloor`'s fold
   (`(2^31-1)^2`), so every spec calling it inherits that floor — **2.00x i64
   headroom, not 1e10x**. Verified. Far tighter than `P2-CONTRACT` assumed.
2. **R4's "near neighbour agreeing on >=90%" is unsatisfiable for
   `geometricMint`.** Exhaustive enumeration over all 49 domain pairs gives a
   best of 30.6% (ceil-sqrt), because the geometric mean is extremal — every
   rival separates off the diagonal. Reported with the measured figure rather
   than faked.

### Known state of `quint-models-v2/`

`kernel.qnt` imports `sqrt.qnt` rather than folding it, and `sorted.qnt` is
deliberately **not** wrapped because it exports a type, which Quint cannot
republish through a wrapper. `sorted.qnt` carries **3 D1 findings**
(`collOut`, `price`, `touched` — fields carried but never read in a guard).
These are gate-2.0d demonstration scaffolding. **The ordered-structures worker
must not inherit them uncritically.**

Ten traps for the nine are documented in `quint-models-v2/PILOT-NOTES.md` (K1-K10),
including three further linter defects: D2 misreads a wrapped assignment (K3),
D3 fires on ordinary commentary (K4), and `--invariant` is a single-state
predicate with no two-state form (K6)."""

if "## Gate 2.1a — pilot result" not in t:
    t = t + addendum

r.write_text(t, encoding="utf-8")
print("ROADMAP updated")
