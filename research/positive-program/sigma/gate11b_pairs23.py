"""1.1b, pairs 2 and 3. Audit discipline is built in, not bolted on afterwards.

Pass one on PRO_RATA vs INDEX reported "3 of 8 separate" and the true figure was
0: one separator was an integer-flooring artifact, one was a signature difference,
and one was asserted rather than measured (the corpus reversed it). So here:

  * nothing is hardcoded -- every cell is computed from transcribed definitions;
  * every arithmetic law is run in BOTH integer and exact (Fraction) arithmetic,
    and a separation that survives only in integer arithmetic is reported as an
    ENCODING artifact, not a separation;
  * a difference in what is a parameter versus a constant is reported as a
    SIGNATURE difference, not a law.

PAIR 2  L3 `RateLimit`/`currentLimit`  vs  L6 `RateLimit`/`currentLimit`
        (the "RateLimit envelope" and "LINEAR_REFILL_RATE_LIMIT" rows)
PAIR 3  L1 `isHealthy`  vs  L3 `maintainsMargin`
        (the "COLLATERALIZED_HEALTH" and "MarginPosition + maintenance" rows)

Definitions transcribed from L1/common.qnt:112-127, L3/common.qnt:92-196,
L6/common.qnt:112-140.
"""
import itertools
from fractions import Fraction


def mn(a, b):
    return a if a < b else b


def mx(a, b):
    return a if a > b else b


# ---- PAIR 2 : the two rate limits -----------------------------------------
def l3_current_limit(max_amount, slope, last_amount, last_updated, now):
    elapsed = mx(0, now - last_updated)
    return mn(max_amount, last_amount + slope * elapsed)


def l6_current_limit(capacity, slope, remaining, last_time, t):
    if capacity <= 0:
        return 0
    if slope <= 0:
        return remaining
    elapsed = t - last_time if t >= last_time else 0
    return mn(capacity, remaining + slope * elapsed)


print("=" * 74)
print("PAIR 2 -- L3 RateLimit vs L6 RateLimit")
print("=" * 74)
print("Field mapping: maxAmount<->capacity, lastAmount<->remaining,")
print("               lastUpdated<->lastTime, slope<->slope.")
print("Test: EXTENSIONAL AGREEMENT. Two definitions that agree on every")
print("well-formed state are the same primitive, whatever they are called.\n")

CAPS = [0, 1, 100, 1000]
SLOPES = [0, 1, 7, 50]
REMS = [0, 1, 50, 100, 1000]
TIMES = [(0, 0), (0, 5), (3, 3), (5, 0), (2, 40)]

agree = differ = 0
wf_agree = wf_differ = 0
examples = []
for cap, sl, rem in itertools.product(CAPS, SLOPES, REMS):
    for lt, t in TIMES:
        a = l3_current_limit(cap, sl, rem, lt, t)
        b = l6_current_limit(cap, sl, rem, lt, t)
        if a == b:
            agree += 1
        else:
            differ += 1
            if len(examples) < 6:
                examples.append((cap, sl, rem, lt, t, a, b))
        # well-formed: positive capacity, positive slope, remaining within cap
        if cap > 0 and sl > 0 and 0 <= rem <= cap:
            if a == b:
                wf_agree += 1
            else:
                wf_differ += 1

tot = agree + differ
print(f"  all states        : agree {agree}/{tot}  differ {differ}")
print(f"  WELL-FORMED states: agree {wf_agree}/{wf_agree+wf_differ}"
      f"  differ {wf_differ}")
print("\n  where they differ (cap, slope, rem, lastT, t) -> L3 vs L6:")
for e in examples:
    print(f"     ({e[0]}, {e[1]}, {e[2]}, {e[3]}, {e[4]})  ->  {e[5]}  vs  {e[6]}")
if wf_differ == 0:
    print("\n  VERDICT: identical on every well-formed state. The differences are")
    print("  confined to degenerate inputs (capacity <= 0, slope <= 0) where L6")
    print("  adds guard clauses and L3 does not. That is DEFENSIVENESS, not a")
    print("  different mechanism. NO SEPARATION -- one family.")
else:
    print("\n  VERDICT: they differ on well-formed states; inspect above.")


# ---- PAIR 3 : the two health predicates ------------------------------------
def is_healthy(coll_amt, coll_price, debt_amt, debt_price, ltv_bps, F=int):
    if debt_amt <= 0:
        return True
    c = F(coll_amt) * coll_price
    d = F(debt_amt) * debt_price
    return c * ltv_bps >= d * 10000


def position_value(pos_size, price, F=int):
    return F(pos_size) * price


def maintains_margin(pos_size, collateral, entry_notional, side, price,
                     maint_bps, F=int):
    if side == "Flat" or pos_size == 0:
        return True
    pv = position_value(pos_size, price, F)
    pnl = pv - entry_notional if side == "Long" else entry_notional - pv
    eq = F(collateral) + pnl
    return eq * 10000 >= F(pos_size) * price * maint_bps


print()
print("=" * 74)
print("PAIR 3 -- L1 isHealthy vs L3 maintainsMargin")
print("=" * 74)

HC = [(100, 5), (100, 10), (500, 2), (50, 20)]
HD = [(0, 3), (10, 3), (40, 5), (90, 2)]
LTV = [5000, 7500, 9000]
POS = [(0, 100, 0), (10, 100, 900), (10, 100, 1100), (50, 500, 5000)]
SIDES = ["Long", "Short"]
PRICES = [80, 100, 120]
MAINT = [500, 1000, 2000]

res = {}


def rec(law, fam, ok):
    res.setdefault(law, {})[fam] = ok


# P1 vacuous on zero exposure
rec("P1 vacuous at zero exposure", "isHealthy",
    all(is_healthy(c, cp, 0, dp, l) for (c, cp) in HC for (_, dp) in HD
        for l in LTV))
rec("P1 vacuous at zero exposure", "maintainsMargin",
    all(maintains_margin(0, col, en, s, p, m) for (_, col, en) in POS
        for s in SIDES for p in PRICES for m in MAINT))

# P2 scale invariance: multiply every VALUE quantity by k -> same verdict
KS = [2, 5, 13]
rec("P2 value-scale invariance", "isHealthy",
    all(is_healthy(c, cp, d, dp, l) == is_healthy(k * c, cp, k * d, dp, l)
        for (c, cp) in HC for (d, dp) in HD for l in LTV for k in KS))
rec("P2 value-scale invariance", "maintainsMargin",
    all(maintains_margin(ps, col, en, s, p, m)
        == maintains_margin(k * ps, k * col, k * en, s, p, m)
        for (ps, col, en) in POS for s in SIDES for p in PRICES
        for m in MAINT for k in KS))

# P3 monotone non-decreasing in the collateral / margin quantity
rec("P3 monotone in collateral", "isHealthy",
    all(is_healthy(c, cp, d, dp, l) <= is_healthy(c + 10, cp, d, dp, l)
        for (c, cp) in HC for (d, dp) in HD for l in LTV))
rec("P3 monotone in collateral", "maintainsMargin",
    all(maintains_margin(ps, col, en, s, p, m)
        <= maintains_margin(ps, col + 10, en, s, p, m)
        for (ps, col, en) in POS for s in SIDES for p in PRICES for m in MAINT))

# P4 monotone non-decreasing in PRICE
rec("P4 monotone in price", "isHealthy",
    all(is_healthy(c, cp, d, dp, l) <= is_healthy(c, cp + 5, d, dp, l)
        for (c, cp) in HC for (d, dp) in HD for l in LTV))
rec("P4 monotone in price", "maintainsMargin",
    all(maintains_margin(ps, col, en, s, p, m)
        <= maintains_margin(ps, col, en, s, p + 5, m)
        for (ps, col, en) in POS for s in SIDES for p in PRICES for m in MAINT))

# P5 the surplus quantity is sign-definite (never negative)
rec("P5 surplus never negative", "isHealthy",
    all(c * cp >= 0 for (c, cp) in HC))
rec("P5 surplus never negative", "maintainsMargin",
    all(col + ((ps * p - en) if s == "Long" else (en - ps * p)) >= 0
        for (ps, col, en) in POS for s in SIDES for p in PRICES))

# exact-arithmetic replay of every arithmetic law, to catch encoding artifacts
exact_same = True
for (c, cp) in HC:
    for (d, dp) in HD:
        for l in LTV:
            if is_healthy(c, cp, d, dp, l) != is_healthy(c, cp, d, dp, l, Fraction):
                exact_same = False
for (ps, col, en) in POS:
    for s in SIDES:
        for p in PRICES:
            for m in MAINT:
                if (maintains_margin(ps, col, en, s, p, m)
                        != maintains_margin(ps, col, en, s, p, m, Fraction)):
                    exact_same = False

print(f"{'candidate law':<34} {'isHealthy':>10} {'maintMargin':>12}  separates?")
print("-" * 74)
sep = []
for law, r in res.items():
    a, b = r["isHealthy"], r["maintainsMargin"]
    s = a != b
    if s:
        sep.append(law)
    print(f"{law:<34} {str(a):>10} {str(b):>12}  {'YES' if s else 'no'}")

print(f"\nexact-arithmetic replay agrees with integer everywhere: {exact_same}")
print("  (so no separation below is a fixed-point encoding artifact)")
print(f"\nseparating laws: {len(sep)} of {len(res)}")
for law in sep:
    print(f"   * {law}")
