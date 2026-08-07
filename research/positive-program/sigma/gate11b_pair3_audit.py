"""Audit of pair 3's two apparent separators, P4 and P5.

Both survived the exact-arithmetic check, so neither is a fixed-point artifact.
That is not enough. The suspicion here is a THIRD artifact class, new to this
pass and not in the pass-one list:

    ASYMMETRIC TEST DESIGN -- the two mechanisms were handed arguments that are
    not each other's counterparts, so the "separation" is a property of the test,
    not of the mechanisms.

P4 varied `collPrice` for isHealthy but ALL prices for maintainsMargin. isHealthy
has two prices playing opposite roles (`collPrice` up is good, `debtPrice` up is
bad); maintainsMargin has ONE price playing both roles at once, since `price`
appears in equity AND in `posSize * price * maintBps`. So the comparison was
rigged unless isHealthy is also tested against its adverse price.

P5 compared isHealthy's BACKING quantity (collateral value, unsigned by
construction) against maintainsMargin's EQUITY (signed). The counterpart of
equity is not collateral value but the HEALTH SURPLUS -- and a surplus is
negative exactly when the predicate is false, in both mechanisms.
"""
from fractions import Fraction


def is_healthy(c, cp, d, dp, ltv, F=int):
    if d <= 0:
        return True
    return (F(c) * cp) * ltv >= (F(d) * dp) * 10000


def maintains_margin(ps, col, en, side, price, maint, F=int):
    if side == "Flat" or ps == 0:
        return True
    pv = F(ps) * price
    pnl = pv - en if side == "Long" else en - pv
    return (F(col) + pnl) * 10000 >= F(ps) * price * maint


HC = [(100, 5), (100, 10), (500, 2), (50, 20)]
HD = [(10, 3), (40, 5), (90, 2)]
LTV = [5000, 7500, 9000]
POS = [(10, 100, 900), (10, 100, 1100), (50, 500, 5000)]
PRICES = [80, 100, 120]
MAINT = [500, 1000, 2000]

print("=" * 74)
print("AUDIT P4 -- monotone in price")
print("=" * 74)

up_coll = all(is_healthy(c, cp, d, dp, l) <= is_healthy(c, cp + 5, d, dp, l)
              for (c, cp) in HC for (d, dp) in HD for l in LTV)
up_debt = all(is_healthy(c, cp, d, dp, l) <= is_healthy(c, cp, d, dp + 5, l)
              for (c, cp) in HC for (d, dp) in HD for l in LTV)
print(f"  isHealthy monotone UP in collPrice : {up_coll}")
print(f"  isHealthy monotone UP in debtPrice : {up_debt}   <- its ADVERSE price")

mm_long = all(maintains_margin(ps, col, en, "Long", p, m)
              <= maintains_margin(ps, col, en, "Long", p + 5, m)
              for (ps, col, en) in POS for p in PRICES for m in MAINT)
mm_short = all(maintains_margin(ps, col, en, "Short", p, m)
               <= maintains_margin(ps, col, en, "Short", p + 5, m)
               for (ps, col, en) in POS for p in PRICES for m in MAINT)
print(f"  maintainsMargin monotone UP, Long  : {mm_long}")
print(f"  maintainsMargin monotone UP, Short : {mm_short}   <- its ADVERSE side")
print()
if (not up_debt) and (not mm_short) and up_coll and mm_long:
    print("  VERDICT: P4 does NOT separate. BOTH predicates are monotone in their")
    print("  favourable price argument and anti-monotone in their adverse one.")
    print("  The pass-one result compared isHealthy's favourable price against")
    print("  maintainsMargin's adverse side. ASYMMETRIC TEST DESIGN -- rejected.")
else:
    print("  VERDICT: the asymmetry does not fully explain P4; inspect above.")

print()
print("=" * 74)
print("AUDIT P5 -- surplus never negative")
print("=" * 74)
print("  Pass one compared NON-CORRESPONDING quantities:")
print("    isHealthy       -> collateral VALUE  c*cp     (unsigned by construction)")
print("    maintainsMargin -> EQUITY  col + pnl          (signed)")
print("  The counterpart of equity is the HEALTH SURPLUS. Recomputed on both:\n")

h_surplus_neg = [(c, cp, d, dp, l) for (c, cp) in HC for (d, dp) in HD
                 for l in LTV if (c * cp) * l - (d * dp) * 10000 < 0]
m_equity_neg = [(ps, col, en, s, p) for (ps, col, en) in POS
                for s in ("Long", "Short") for p in PRICES
                if col + ((ps * p - en) if s == "Long" else (en - ps * p)) < 0]
print(f"  isHealthy       surplus  c*cp*ltv - d*dp*1e4  < 0 in"
      f" {len(h_surplus_neg)} cases")
print(f"  maintainsMargin equity                        < 0 in"
      f" {len(m_equity_neg)} cases")
print()
if h_surplus_neg and m_equity_neg:
    print("  VERDICT: P5 does NOT separate. Both mechanisms have a signed")
    print("  health quantity that goes negative exactly when the predicate")
    print("  fails. Pass one compared isHealthy's BACKING (unsigned by")
    print("  construction) against maintainsMargin's EQUITY (signed).")
    print("  ASYMMETRIC TEST DESIGN again -- rejected.")
else:
    print("  VERDICT: one side never goes negative; P5 may be real.")

print()
print("=" * 74)
print("A caveat that must be recorded rather than resolved here")
print("=" * 74)
print("  Whether maintainsMargin's equity is negative in a REACHABLE state of")
print("  apex/gmx is not established by this script -- the domain above is")
print("  chosen, not explored. Claiming 'equity can go negative in the corpus'")
print("  would be the asserted-not-measured error from pass one. It is stated")
print("  here as UNVERIFIED and left to a reachability check in the specs.")


# ---------------------------------------------------------------------------
# P5 RE-AUDIT under convention 8c (constant-crossing).
#
# The check above reported isHealthy's surplus negative in 0 cases and concluded
# "P5 may be real". That was a DOMAIN artifact: HC/HD/LTV above contain only
# healthy states, so the surplus had no opportunity to go negative. Phase 2's
# own convention 8c requires a domain holding values on both sides of every
# constant in a comparison. The Phase 1 test violated it.
# ---------------------------------------------------------------------------
HC_X = [(100, 5), (100, 10), (500, 2), (50, 20), (10, 1), (1, 1)]
HD_X = [(10, 3), (40, 5), (90, 2), (500, 20), (900, 50)]
neg = [(c, cp, d, dp, l) for (c, cp) in HC_X for (d, dp) in HD_X for l in LTV
       if (c * cp) * l - (d * dp) * 10000 < 0]
tot = len(HC_X) * len(HD_X) * len(LTV)
print()
print("=" * 74)
print("P5 RE-AUDIT -- domain widened to cross the health threshold (conv. 8c)")
print("=" * 74)
print(f"  isHealthy surplus < 0 in {len(neg)} of {tot} cases"
      f"  (narrow domain gave 0 of 36)")
print(f"  e.g. {neg[0][:4]} -> collateral value {neg[0][0]*neg[0][1]},"
      f" debt value {neg[0][2]*neg[0][3]}")
print()
print("  VERDICT: P5 does NOT separate. Both mechanisms carry a signed health")
print("  quantity that goes negative exactly when the predicate fails. The")
print("  pass-one result came from a domain that never crossed the threshold --")
print("  the same failure convention 8c exists to prevent, committed here in a")
print("  Phase 1 test rather than a Phase 2 spec.")
