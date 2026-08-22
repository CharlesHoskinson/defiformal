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
    "| 2.0f close three carry-forwards | **1 of 3 closed** | CF3 resolved by computation; CF1 (pilot range cap) and CF2 (apex trigger, uncovered) open |",
    "| 2.0f close three carry-forwards | **CLOSED** | CF1 closed (constant-crossing rule); CF2 closed as convention 6g, half-lintable; CF3 resolved then **corrected** |")
t = t.replace(
    "| 2.1 re-spec the ten | **BLOCKED** | blocked on 2.0f |",
    "| 2.1 re-spec the ten | **READY** | 2.0f closed; three per-protocol collisions to decide first (liquity MIN_DEBT, morpho MAX_LIF, apex ranges) |")

old = "**Resolution for the re-spec:** Curve's declared domain must reach past 10^4 to\nhost the non-convergence witness, and 10^5..10^7 does so while staying inside\ni64 (10^7 * 10^7 = 10^14, well under 9.2 * 10^18). Adopt that range and assert\nthe witness explicitly."

new = """**Resolution for the re-spec — CORRECTED at gate 2.0f.**

The first resolution here said `10^5..10^7` was safe because
`10^7 * 10^7 = 10^14`. **That checked the wrong quantity** — the product of the
two balances, not the peak intermediate inside the Newton step. At extreme
imbalance `D_P` is *cubic* in `D`, so the numerator
`(Ann*S + D_P*N) * D` grows far faster than `x*y`. Verified
(`evidence/curve_peak.py`):

| point | peak intermediate | x*y | fits i64 |
|---|---|---|---|
| (10^4, 1) | 520,204,015,200 | 10,000 | yes |
| (10^6, 1) | 500,202,000,401,500,200 | 1,000,000 | yes |
| (10^7, 1) | **500,020,200,004,015,000,200** | 10,000,000 | **NO** |

Largest `x` at `y = 1` whose peak fits i64 is **2,642,111**. The corrected cap is
**10^6**: peak `5.0 * 10^17`, about 18x headroom, and the witness is still
hosted — 250 of 381 sampled points non-converging at K=8. Adopt `<= 10^6`, not
`10^7`, and assert the divergence witness explicitly.

This correction is itself an instance of the Phase 2 lesson: a domain bound was
justified against a plausible-looking quantity that was not the binding one."""

t = t.replace(old, new)

t = t.replace(
    "### Carry-forward 1 — the pilot's own mechanism is unreachable (VERIFIED)",
    """### Carry-forward 1 — CLOSED (`phase2/P2-CARRYFORWARD.md`)

Diagnosis: convention 8's `<= 200` conflated **value magnitude** with
**branching factor**. Only branching costs runtime. Replaced by 8a (branching:
at most 8 enumerated values per `nondet`), 8b (magnitude: declare the peak,
`< 9.22e18`), and 8c **constant-crossing** — the domain must contain values on
both sides of every protocol constant appearing in a comparison, subtraction or
min/max.

Applying 8c retroactively to the old `<= 200` cap: **six of the ten protocols
were dead, not merely degraded** — `uniswap_v2` and `apex` (both underflow
`MINIMUM_LIQUIDITY = 1000`), `gmx` (`d <= 200 < FLOAT_PRECISION`, so impact is
identically 0), `liquity` (`MIN_DEBT = 2000`), `morpho_blue`
(`VIRTUAL_SHARES = 10^6`, so a share balance is not even representable), and
`derive` (spot `10^4`). Two degraded, two survived.

Pilot domain: mint amounts `{1000..20000}`. `(1000, 1000)` yields 0 and hosts the
`INSUFFICIENT_LIQUIDITY_MINTED` revert branch; `(4000, 9000)` yields minter LP
**5000 > 0** with 1000 permanently locked.

**Three collisions carried into 2.1 as decisions:** liquity's `MIN_DEBT = 2000`
is a live second instance of CF1 that survives even the repaired contract
domain (debts there are `<= 300`); morpho's `MAX_LIF` branch is unreachable
without varying `LLTV`, which needs a scope amendment since multi-market was
dropped; and apex's two declared ranges are mutually unreachable once the sqrt
bootstrap runs.

### Carry-forward 2 — CLOSED as a convention, OPEN as a linter

New convention **6g, dependency parity**: for each `nondet`-supplied or
literal-substituted quantity, the spec must read every contract-storage variable
the contract's expression depends on, restricted to variables the spec models.
It measures *storage dependence*, not "outside-ness" — an oracle's storage
footprint is empty in the contract too, so parity holds and oracles are not
banned. In apex it permits the oracle price and forbids `markPrice`, whose
footprint is `{reserveBase, reserveQuote, position size}` via `getMarkPriceAcc`.

Ten-way test: uniquely catches the apex trigger (the target), independently
re-catches compound_v3, liquity, huma and derive — which were each already
caught by a *different* convention, evidence that 6g is the right
generalisation — is silent on five, and produces **zero false positives**.

Lintable in half: D5a (undeclared `nondet`, or a non-empty declared footprint on
a `nondet`) and D5b (declared footprint minus identifiers actually read) are pure
syntax. The classification itself is not mechanisable — every declaration-free
heuristic fires on compound_v3, morpho and gmx, all genuine oracle reads. A
three-question reviewer checklist covers that half.

### Original CF1 statement (superseded, retained for the record)""")

r.write_text(t, encoding="utf-8")
print("ROADMAP updated: 2.0f CLOSED, CF3 corrected, 2.1 READY")
