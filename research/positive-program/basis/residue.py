#!/usr/bin/env python3
"""Classify each of the 46 maximal violating subterms as
   INLINE  -- the lane basis already contains an operator with this content;
              the spec wrote it out by hand.  Basis is fine; spec is sloppy.
   MISSING -- no operator of the lane basis, and no family of P, has this
              content.  The basis must grow.
and, for MISSING, name the family that must be added."""
import json, collections
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


r = json.load(open(_os.environ.get("GEN_RESULT", str(_REPO / "research/positive-program/basis/RESULT.json"))))
V = r["violations"]

# key: (spec, defn, term) -> (verdict, family/covered-by)
TAG = {
 # --- scale x by a ratio: F1's mulDiv kernel, present in every lane common ---
 "((field(d, sats) * SLASH_FRACTION_BPS) / BPS)": ("INLINE","F1 assetsFromIndex"),
 "((debt * (WAD - LIQ_DISCOUNT)) / WAD)": ("INLINE","F1 assetsFromIndex"),
 "((sh * (bal + BALANCE_OFFSET)) / (ts + SHARES_OFFSET))": ("INLINE","F1 assetsToShares"),
 "((maxM * proportion) / WAD)": ("INLINE","F1 assetsFromIndex"),
 "((delegatedShares * slashMag) / maxM)": ("INLINE","F1 assetsFromIndex"),
 "((get(userShares, u) * slashMag) / maxM)": ("INLINE","F1 assetsFromIndex"),
 "((amount * (priorShares + SHARES_OFFSET)) / (priorBal + BALANCE_OFFSET))": ("INLINE","F1 assetsToShares"),
 "((tpe * MAX_REBASE_BPS) / BPS)": ("INLINE","F1 assetsFromIndex"),
 "((gemAmt * tout) / WAD)": ("INLINE","F1 assetsFromIndex"),
 "((gemAmt * tin) / WAD)": ("INLINE","F1 assetsFromIndex"),
 "(amountIn / 1000)": ("INLINE","F1 mulDivDown (0.1% fee)"),
 "(collat / 2)": ("INLINE","F1 mulDivDown (50% haircut)"),
 "(amountIn * 2)": ("INLINE","F1 mulDivDown (2x factor)"),
 "(rate / 2)": ("INLINE","F1 mulDivDown (reserve factor)"),
 "(SCALE / 10)": ("INLINE","closed constant"),
 "(seniorRedeemReq * fillS)": ("INLINE","F1 pro-rata epoch fill"),
 "(juniorRedeemReq * fillJ)": ("INLINE","F1 pro-rata epoch fill"),
 "(pool * shares)": ("INLINE","F1 sharesToAssets"),
 "(baseIn * lpShares)": ("INLINE","F1 assetsToShares"),
 # --- index accrual / scaled balances: F7, present in L1+L2+L3 commons ---
 "((totalBorrows * rateBpsPerBlock) * blocks)": ("INLINE","F7 accrueIndex"),
 "((outstandingPrincipal * loanRateBps) * dt)": ("INLINE","F7 accrueIndex"),
 "(principal * globalIdx)": ("INLINE","F7 presentFromScaled"),
 "(((cash + borrows) - reserves) * INDEX_BASE)": ("INLINE","F7 scaledFromPresent"),
 "(seizeUnderlying * INDEX_BASE)": ("INLINE","F7 scaledFromPresent"),
 "(amount * INDEX_BASE)": ("INLINE","F7 scaledFromPresent"),
 "(cTokens * rate)": ("INLINE","F7 presentFromScaled"),
 "(stakedU * (ix - paid))": ("INLINE","F7 streamIndex + F1 (reward debt)"),
 # --- valuation APPLICATION: no family in P does (A,P) -> V ---
 "(col * collPrice)": ("MISSING","N2 mark-to-market"),
 "((seizedCol * collPrice) * 10000)": ("MISSING","N2 mark-to-market"),
 "(seizedCol * collPrice)": ("MISSING","N2 mark-to-market"),
 "(poolAmount * markPrice)": ("MISSING","N2 mark-to-market"),
 "(impactPool * markPrice)": ("MISSING","N2 mark-to-market"),
 "(yesAmt * price)": ("MISSING","N2 mark-to-market"),
 "((boldAmt * WAD) / price)": ("MISSING","N2 mark-to-market (inverse)"),
 "(qty * MAINT_PER_SHORT)": ("MISSING","N2 mark-to-market (margin per unit)"),
 # --- trading function / bonding curve: no family in P ---
 "((reserve0 + a0) * (reserve1 + a1))": ("MISSING","N1 trading function"),
 "((reserve0 - a0) * (reserve1 - a1))": ("MISSING","N1 trading function"),
 "(y * dx)": ("MISSING","N1 trading function"),
 "(baseIn * reserveQuote)": ("MISSING","N1 trading function"),
 "(2 * min(x, y))": ("MISSING","N1 trading function (StableSwap D)"),
 "(amp * 2)": ("MISSING","N1 trading function (StableSwap D)"),
 "(((ann * S) + prodTerm) / (ann + 1))": ("MISSING","N1 trading function (StableSwap D)"),
 # --- tranche subordination: no family in P ---
 "(MAX_SENIOR_RATIO * max(1, field(tranches, junior)))": ("MISSING","N4 tranche subordination"),
}

miss = [v for v in V if TAG.get(v["term"], ("?",))[0] == "?"]
if miss:
    print("UNTAGGED:", [m["term"] for m in miss]); raise SystemExit(1)

cnt = collections.Counter(TAG[v["term"]][0] for v in V)
print("maximal violating subterms :", len(V))
print("  INLINE  (basis covers it) :", cnt["INLINE"])
print("  MISSING (basis lacks it)  :", cnt["MISSING"])
print("\n--- MISSING, grouped by the family that must be added ---")
fams = collections.Counter(TAG[v["term"]][1] for v in V if TAG[v["term"]][0] == "MISSING")
for f, c in fams.most_common(): print(f"   {c:3d}  {f}")

# per-spec verdict
spec_kind = collections.defaultdict(set)
for v in V: spec_kind[(v["lane"], v["spec"])].add(TAG[v["term"]][0])
inline_only = [s for s, k in spec_kind.items() if k == {"INLINE"}]
has_missing = [s for s, k in spec_kind.items() if "MISSING" in k]
clean = 51 - len(spec_kind)
print(f"\nSPEC VERDICTS over 51 formalised protocols")
print(f"  generated outright                    : {clean}")
print(f"  generated after re-folding inlined ops: {len(inline_only)}")
print(f"  NOT generated (needs a new family)    : {len(has_missing)}")
for l, s in sorted(has_missing):
    fs = sorted({TAG[v['term']][1] for v in V
                 if (v['lane'], v['spec']) == (l, s) and TAG[v['term']][0] == 'MISSING'})
    print(f"      {l}/{s}: {', '.join(fs)}")
print(f"\n  TOTAL GENERATED (modulo inlining)     : {clean + len(inline_only)} / 51")
print("\n--- specs generated only after re-folding ---")
for l, s in sorted(inline_only): print(f"      {l}/{s}")
