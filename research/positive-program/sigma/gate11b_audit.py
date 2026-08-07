"""1.1b, second pass: audit the three "separating" laws from gate11b_laws.py.

The first pass reported 3 of 8 candidate laws separating PRO_RATA_SHARES from
INDEX_ACCRUAL. A table with three YES rows looks like a result. Each is audited
here before any of it is believed.

  L1 ratio-pair scale invariance   -- is it a law, or a signature difference?
  L5 operation preserves its ratio -- does it survive exact arithmetic, or is the
                                      separation an integer-flooring artifact?
  L8 conversion writes a ratio component -- this one was HARDCODED in pass one,
                                      not measured. Measure it against the corpus.
"""
import glob
import os
import re
from fractions import Fraction

INDEX_BASE = 1_000_000
ROOT = "/root/DefiElements"


def mul_div_down(a, b, d):
    return 0 if d <= 0 else (a * b) // d


def shares_from_assets(assets, A, S):
    if assets <= 0:
        return 0
    if S == 0 or A == 0:
        return assets
    return mul_div_down(assets, S, A)


print("=" * 74)
print("AUDIT L5 -- is the separation real, or integer flooring?")
print("=" * 74)
PAIRS = [(A, S) for A in (100, 1000, 7777, 100_000)
         for S in (100, 999, 5000, 100_000)]
XS = [1, 7, 100, 999, 10_000]

floor_pres = exact_pres = total = 0
for (A, S) in PAIRS:
    for a in XS:
        total += 1
        s = shares_from_assets(a, A, S)
        if (A + a) * S == A * (S + s):
            floor_pres += 1
        s_exact = Fraction(a * S, A)
        if Fraction(A + a) * S == Fraction(A) * (S + s_exact):
            exact_pres += 1
print(f"  integer arithmetic : ratio preserved in {floor_pres}/{total} cases")
print(f"  exact  arithmetic  : ratio preserved in {exact_pres}/{total} cases")
print()
if exact_pres == total and floor_pres < total:
    print("  VERDICT: L5 does NOT separate. In exact arithmetic pro-rata deposit")
    print("  preserves A/S identically -- (A+a)/(S + aS/A) = A/S. The reported")
    print("  separation is entirely an artifact of `mulDivDown` flooring, which")
    print("  is a property of the fixed-point encoding, not of the mechanism.")
else:
    print("  VERDICT: L5 survives exact arithmetic.")

print()
print("=" * 74)
print("AUDIT L1 -- law, or signature difference?")
print("=" * 74)
print("  assetsFromShares(x, A, S)   : ratio pair is (A, S), BOTH parameters")
print("  presentFromScaled(x, index) : ratio pair is (index, INDEX_BASE),")
print("                                the denominator is a module constant")
print()
print("  Scaling BOTH components of the index pair preserves the value:")
for i, k in ((1_500_000, 3), (2_000_000, 10)):
    lhs = mul_div_down(999, k * i, k * INDEX_BASE)
    rhs = mul_div_down(999, i, INDEX_BASE)
    print(f"    mulDivDown(999, {k}*{i}, {k}*BASE) = {lhs}"
          f"   vs  unscaled {rhs}   equal={lhs == rhs}")
print()
print("  VERDICT: L1 does NOT separate the MECHANISMS. It separates their")
print("  SIGNATURES -- one takes its denominator as an argument, the other")
print("  fixes it as a constant. Scale-invariance holds for both when both")
print("  components are scaled. A signature difference is not a law.")

print()
print("=" * 74)
print("AUDIT L8 -- measured against the corpus, not asserted")
print("=" * 74)
SPECS = sorted(glob.glob(f"{ROOT}/quint-models/L*/*.qnt"))
HEAD = re.compile(r"^\s*(?:pure\s+)?(action|def)\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
CONV = {"pro-rata": ("sharesFromAssets", "assetsFromShares", "assetsToShares"),
        "index": ("presentFromScaled", "scaledFromPresent")}
RATIO_VARS = {"pro-rata": ("totalAssets", "totalShares", "totalSupply",
                           "totalSupplyAssets", "totalSupplyShares"),
              "index": ("index", "Index")}

rows = []
for p in SPECS:
    if os.path.basename(p) == "common.qnt":
        continue
    src = re.sub(r"//[^\n]*", "", open(p, encoding="utf-8", errors="replace").read())
    heads = list(HEAD.finditer(src))
    for n, h in enumerate(heads):
        if h.group(1) != "action":
            continue
        body = src[h.end(): heads[n + 1].start() if n + 1 < len(heads) else len(src)]
        writes = set(re.findall(r"([A-Za-z_][A-Za-z0-9_]*)'\s*=", body))
        for fam, fns in CONV.items():
            if not any(re.search(r"\b" + f + r"\b", body) for f in fns):
                continue
            hit = sorted(w for w in writes
                         if any(t.lower() in w.lower() for t in RATIO_VARS[fam]))
            rows.append((fam, os.path.basename(p)[:-4], h.group(2), hit))

for fam in ("pro-rata", "index"):
    sub = [r for r in rows if r[0] == fam]
    withw = [r for r in sub if r[3]]
    print(f"\n  {fam}: {len(sub)} actions call the conversion;"
          f" {len(withw)} also write a ratio component")
    for _, spec, act, hit in sub[:9]:
        print(f"     {spec:<14} {act:<22} writes {hit if hit else '-- none --'}")

pr = [r for r in rows if r[0] == "pro-rata"]
ix = [r for r in rows if r[0] == "index"]
pr_rate = sum(1 for r in pr if r[3]) / len(pr) if pr else 0
ix_rate = sum(1 for r in ix if r[3]) / len(ix) if ix else 0
print(f"\n  measured: pro-rata {pr_rate:.0%} of call sites write a ratio"
      f" component;  index {ix_rate:.0%}")
print("  VERDICT: L8 separates only if these rates are far apart AND the index")
print("  rate is near zero. Read the numbers above before claiming it.")
