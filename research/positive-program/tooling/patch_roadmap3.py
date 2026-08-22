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
    "| 2.0e plan review | **FAILED** | `phase2/P2-REVIEW.md`: plan not sound as written; five repairs required |\n"
    "| 2.1 re-spec the ten | **BLOCKED** | blocked on 2.0e repairs — do NOT start until all five land |",
    "| 2.0e plan review | **repairs delivered** | R1+R4 applied to `P2-FIDELITY`; R2/R3/R5 in `phase2/P2-CONTRACT.md` |\n"
    "| 2.0f close three carry-forwards | **OPEN** | see below — all three are pre-`2.1` blockers |\n"
    "| 2.1 re-spec the ten | **BLOCKED** | blocked on 2.0f |")

t = t.replace(
    "**Next gate: 2.0e — repair the plan.** Five required changes, ranked by damage\nprevented. Do not write a single re-spec until all five land.",
    """**Next gate: 2.0f — close three carry-forwards.** The five repairs landed, but
delivering them surfaced three items that must be closed before any re-spec is
written.

### Carry-forward 1 — the pilot's own mechanism is unreachable (VERIFIED)

Convention 8 caps ranges at 200. `MINIMUM_LIQUIDITY = 1000` is a **protocol
constant, not a scale**, so on the pilot `uniswap_v2`:

    isqrt(200 * 200) - 1000  =  -800     underflow

The initial-mint lock — the pilot's headline mechanism and one of the twelve
unmatched candidate primitives — cannot occur at all. A cap of at least 2000 is
required for a non-zero first mint. Fix the convention before the pilot is
written, or the pilot certifies a domain in which its own mechanism is absent.

### Carry-forward 2 — one deletion no convention reaches (VERIFIED)

`apex`'s liquidation **trigger**: an endogenous argument was replaced by a
legitimate exogenous one, which convention 6 explicitly *permits*. Conventions
6b-6f do not reach it either. This is a named hole, not an oversight — it needs
a new convention or an explicit per-protocol check.

Related and verified: apex's fee is **invisible at ordinary trade sizes** — at
`(in=200, rIn=1000, rOut=1000)` the 999/1000 form and the zero-fee form both
return 166. A "safe small trade" domain silently re-deletes the fee. This is
exactly the second-order damage path the review predicted for i64.

### Carry-forward 3 — two agents disagree about Curve, and the disagreement IS the lesson

- Expressibility (gate 2.0d): Curve's integer Newton fails to converge on
  **2.8% of a 1372-point grid**, at any depth up to 96 — a period-2 limit cycle.
- Contract (gate 2.0e): swept **all 200x200 pairs at AMP=100, K=8 — zero
  non-converging**, worst case 3 iterations.

These are probably not contradictory; they are different domains. But that is
the point: **the smaller domain is exactly where the pathology is invisible**,
which is the same failure by which Curve's spec reached `bal0 = bal1 = 100` and
lost its discrimination witness. Do not adopt the `<=200` sweep as evidence that
Curve converges. Reconcile the two grids explicitly and record which domain each
claim holds on.

### The fifth trap, found by the contract in its own output

T0 conformance vectors are `pure val`s, hence true in every state **including one
where the pinned `pure def` is never called** — the arithmetic present as a
library and absent as a mechanism. Already live at `apex.qnt:184`. Countered by a
`wit_used_<f>` violation obligation plus one `T0-LIVE:` vector per protocol whose
obligation is a *trace*, not an equality. This is the fifth instance of one
shape: **the check passes because the mechanism never ran.**""")

r.write_text(t, encoding="utf-8")
print("ROADMAP updated: 2.0e delivered, 2.0f opened with three carry-forwards")
