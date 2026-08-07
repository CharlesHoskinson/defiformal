"""Sub-gate 1.1b, first pair: does any law separate PRO_RATA_SHARES from
INDEX_ACCRUAL?

Gate 1.1 condition 2: "a law that fails for its neighbours. A family with no law
is a name." These two are the hardest pair in the corpus -- both reduce to
`mulDivDown(a,b,c)`, and BASIS.md already merges their parents (F1/F6 -> Prop +
Post) on exactly that ground. If no law separates them they are one family, and
that is a result; if one does, it is the first real law in the programme.

Definitions transcribed verbatim from quint-models/L1/common.qnt:14-105.

METHOD. State candidate laws BEFORE testing, test each against BOTH mechanisms
over the same domain, and report the full matrix including the laws that fail to
separate. A law that holds for both, or fails for both, is reported as such --
selecting only the separating ones afterwards is how you manufacture a basis.
"""
import itertools

INDEX_BASE = 1_000_000


def mul_div_down(a, b, d):
    return 0 if d <= 0 else (a * b) // d


# ---- PRO_RATA_SHARES -------------------------------------------------------
def shares_from_assets(assets, A, S):
    if assets <= 0:
        return 0
    if S == 0 or A == 0:
        return assets
    return mul_div_down(assets, S, A)


def assets_from_shares(shares, A, S):
    if shares <= 0 or S <= 0:
        return 0
    return mul_div_down(shares, A, S)


def prorata_deposit(A, S, a):
    """The operation that USES the ratio also WRITES both its components."""
    s = shares_from_assets(a, A, S)
    return A + a, S + s


# ---- INDEX_ACCRUAL ---------------------------------------------------------
def present_from_scaled(scaled, index):
    return mul_div_down(scaled, index, INDEX_BASE)


def scaled_from_present(present, index):
    return 0 if index <= 0 else mul_div_down(present, INDEX_BASE, index)


def accrue_index(index, rate_bps, dt):
    if dt <= 0 or rate_bps < 0:
        return index
    return mul_div_down(index, INDEX_BASE + rate_bps * dt, INDEX_BASE)


def index_deposit(index, scaled, a):
    """The operation that USES the ratio writes NEITHER component."""
    return index, scaled + scaled_from_present(a, index)


# ---- domain ----------------------------------------------------------------
XS = [1, 7, 100, 999, 10_000]
PAIRS = [(A, S) for A in (100, 1000, 7777, 100_000)
         for S in (100, 999, 5000, 100_000)]
IDXS = [INDEX_BASE, 1_500_000, 2_000_000, 3_333_333]
KS = [2, 3, 10]
RATES = [1, 50, 500]
DTS = [1, 5, 20]

results = {}


def record(law, family, ok, note=""):
    results.setdefault(law, {})[family] = (ok, note)


# L1 -- scale invariance of the ratio pair: f(x, k*p, k*q) == f(x, p, q)
ok = all(assets_from_shares(x, k * A, k * S) == assets_from_shares(x, A, S)
         for x in XS for (A, S) in PAIRS for k in KS)
record("L1 ratio-pair scale invariance", "pro-rata", ok)
ok = all(present_from_scaled(x, k * i) == present_from_scaled(x, i)
         for x in XS for i in IDXS for k in KS)
record("L1 ratio-pair scale invariance", "index", ok,
       "denominator is the CONSTANT INDEX_BASE, so only the numerator scales")

# L2 -- round-trip contraction: converting out and back never gains
ok = all(assets_from_shares(shares_from_assets(x, A, S), A, S) <= x
         for x in XS for (A, S) in PAIRS)
record("L2 round-trip contraction", "pro-rata", ok)
ok = all(present_from_scaled(scaled_from_present(x, i), i) <= x
         for x in XS for i in IDXS)
record("L2 round-trip contraction", "index", ok)

# L3 -- zero preservation
ok = all(assets_from_shares(0, A, S) == 0 for (A, S) in PAIRS)
record("L3 zero preservation", "pro-rata", ok)
ok = all(present_from_scaled(0, i) == 0 for i in IDXS)
record("L3 zero preservation", "index", ok)

# L4 -- superadditivity under flooring: f(x)+f(y) <= f(x+y)
ok = all(assets_from_shares(x, A, S) + assets_from_shares(y, A, S)
         <= assets_from_shares(x + y, A, S)
         for x, y in itertools.combinations(XS, 2) for (A, S) in PAIRS)
record("L4 superadditivity", "pro-rata", ok)
ok = all(present_from_scaled(x, i) + present_from_scaled(y, i)
         <= present_from_scaled(x + y, i)
         for x, y in itertools.combinations(XS, 2) for i in IDXS)
record("L4 superadditivity", "index", ok)

# L5 -- THE OPERATION PRESERVES ITS OWN RATIO (exactly, cross-multiplied)
ok = all(
    (lambda A2S2: A2S2[0] * S == A * A2S2[1])(prorata_deposit(A, S, a))
    for (A, S) in PAIRS if S > 0 for a in XS)
record("L5 operation preserves its ratio", "pro-rata", ok,
       "flooring makes the ratio drift in favour of existing holders")
ok = all(index_deposit(i, 0, a)[0] == i for i in IDXS for a in XS)
record("L5 operation preserves its ratio", "index", ok,
       "deposit never writes the index")

# L6 -- THE RATIO IS NON-DECREASING UNDER THE OPERATION (cross-multiplied)
ok = all(
    (lambda p: p[0] * S >= A * p[1])(prorata_deposit(A, S, a))
    for (A, S) in PAIRS if S > 0 for a in XS)
record("L6 ratio non-decreasing", "pro-rata", ok)
ok = all(accrue_index(i, r, dt) >= i for i in IDXS for r in RATES for dt in DTS)
record("L6 ratio non-decreasing", "index", ok)

# L7 -- THE RATIO IS STRICTLY INCREASED BY SOME REACHABLE OPERATION
strict_pr = any(
    (lambda p: p[0] * S > A * p[1])(prorata_deposit(A, S, a))
    for (A, S) in PAIRS if S > 0 for a in XS)
record("L7 some operation strictly increases the ratio", "pro-rata", strict_pr)
strict_ix = any(accrue_index(i, r, dt) > i
                for i in IDXS for r in RATES for dt in DTS)
record("L7 some operation strictly increases the ratio", "index", strict_ix)

# L8 -- CLOSURE: the operation using the ratio writes a component of the ratio
record("L8 conversion writes a ratio component", "pro-rata", True,
       "deposit writes BOTH totalAssets and totalShares")
record("L8 conversion writes a ratio component", "index", False,
       "deposit writes scaled only; index moves solely under accrueIndex")

# ---- report ---------------------------------------------------------------
print(__doc__)
print("=" * 74)
print(f"{'candidate law':<44} {'pro-rata':>9} {'index':>7}  separates?")
print("-" * 74)
separating = []
for law, r in results.items():
    p = r["pro-rata"][0]
    i = r["index"][0]
    sep = p != i
    if sep:
        separating.append(law)
    print(f"{law:<44} {str(p):>9} {str(i):>7}  {'YES' if sep else 'no'}")

print("\n" + "=" * 74)
print(f"separating laws: {len(separating)} of {len(results)}")
for law in separating:
    print(f"   * {law}")
    for fam in ("pro-rata", "index"):
        ok, note = results[law][fam]
        if note:
            print(f"       {fam:<9} {ok} -- {note}")

print("\nNON-separating laws (held or failed for both):")
for law, r in results.items():
    if law not in separating:
        print(f"   - {law}: both {r['pro-rata'][0]}")
