import json
import glob
from itertools import combinations
from fractions import Fraction

specs = {}
for f in sorted(glob.glob("/root/DefiElements/expansion/*/specs/*.json")):
    d = json.load(open(f))
    specs[d.get("app", f)] = frozenset(d.get("construction", []))

print("spec files:", len(specs))
distinct = set(specs.values())
print("distinct construction sets:", len(distinct))
print("C(distinct,2) =", len(distinct) * (len(distinct) - 1) // 2)

# which apps share a support
from collections import defaultdict
by_set = defaultdict(list)
for a, c in specs.items():
    by_set[c].append(a)
for c, apps in by_set.items():
    if len(apps) > 1:
        print("  DUPLICATE support:", apps)

# --- attribute each X21-armed pair to the element pair that arms it
apps = sorted(specs)
pairs = list(combinations(apps, 2))
attrib = defaultdict(int)
armed = 0
for a, b in pairs:
    u = specs[a] | specs[b]
    if "Fl" not in u:
        continue
    hit = False
    for partner in ("Xf", "Rl", "Of"):
        if partner in u:
            attrib[("Fl", partner)] += 1
            hit = True
    if hit:
        armed += 1
print(f"\nX21-armed pairs (60-app basis): {armed} of {len(pairs)}")
for k, v in sorted(attrib.items(), key=lambda kv: -kv[1]):
    print(f"   {k}: {v}")

print("\nprotocols carrying Fl:", sorted(a for a, c in specs.items() if "Fl" in c))

# --- the null, computed exactly
chain = [0, 1, 2, 3, 4]
subs = []
for m in range(1, 1 << 5):
    subs.append(frozenset(i for i in chain if m >> i & 1))
disj = sum(1 for x in subs for y in subs if not (x & y))
print(f"\nnon-empty subsets of 5-chain: {len(subs)}  pairs: {len(subs)**2}")
print(f"P(disjoint | arbitrary non-empty subsets) = {disj}/{len(subs)**2}"
      f" = {Fraction(disj, len(subs)**2)} = {disj/len(subs)**2:.4f}")

ivals = [frozenset(range(lo, hi + 1)) for lo in chain for hi in chain if hi >= lo]
dj = sum(1 for x in ivals for y in ivals if not (x & y))
print(f"intervals: {len(ivals)}  pairs: {len(ivals)**2}")
print(f"P(disjoint | intervals) = {dj}/{len(ivals)**2}"
      f" = {Fraction(dj, len(ivals)**2)} = {dj/len(ivals)**2:.4f}")

# up-closed / down-closed families
up = [frozenset(range(lo, 5)) for lo in chain]
dn = [frozenset(range(0, hi + 1)) for hi in chain]
for name, fam in (("up-closed", up), ("down-closed", dn)):
    d2 = sum(1 for x in fam for y in fam if not (x & y))
    print(f"P(disjoint | {name}) = {d2}/{len(fam)**2} = {d2/len(fam)**2:.4f}")
