"""Per-clause and whole-theory scoring against the 72 real decompositions and
OP-LOG's own adversarial corpus."""
import collections
import atlas as A, theory as T, negatives as N

REAL = A.real_protocols()
NEG = N.gen(seed=7, per_family=400)

# The blind set's negative half is small: its size profile (mean 6.4, max 14
# among cases that are not one of the 72 census sets) rules out whole-protocol
# chimeras. Weight the calibration corpus accordingly.
PLAUSIBLE = {"drop1", "drop2", "add1", "add2", "add3", "swapgrp", "swapany",
             "graft", "uniform", "weighted"}
NEGP = [n for n in NEG if n["family"] in PLAUSIBLE and len(n["syms"]) <= 17]

print(f"reals={len(REAL)}  negatives={len(NEG)}  plausible={len(NEGP)}")
print()
print(f"{'id':6s} {'realRej':>7s} {'negRej%':>7s}   which reals")
print("-" * 100)
for cl in T.POOL:
    rr = [r["name"] for r in REAL if T.violations(r["syms"], [cl])]
    nr = sum(1 for n in NEGP if T.violations(n["syms"], [cl]))
    pct = 100.0 * nr / len(NEGP)
    print(f"{cl['id']:6s} {len(rr):7d} {pct:7.2f}   {', '.join(x[:24] for x in rr[:4])}")

print()
print("=== whole-theory ===")


def report(name, clauses, pred=None):
    f = pred or (lambda S: T.valid(S, clauses))
    ra = sum(1 for r in REAL if f(r["syms"])) / len(REAL)
    na = sum(1 for n in NEGP if f(n["syms"])) / len(NEGP)
    byfam = collections.defaultdict(lambda: [0, 0])
    for n in NEGP:
        b = byfam[n["family"]]
        b[1] += 1
        if f(n["syms"]):
            b[0] += 1
    print(f"{name:26s} realAcc={ra:6.1%} negAcc={na:6.1%} ratio={ra/max(na,1e-9):5.2f}x")
    print("   ", {k: f"{v[0]/v[1]:.0%}" for k, v in sorted(byfam.items())})
    return ra, na


report("reference closure", None, pred=lambda S: A.closes(S))
report("R", T.R)
report("R+C", T.R + T.COMPLETION)
report("R+C+W", T.R + T.COMPLETION + T.W)
report("R+C+W+X", T.R + T.COMPLETION + T.W + T.X)
report("R+C+W+X+V (full)", T.POOL)

print()
print("=== reals rejected by the full theory ===")
for r in REAL:
    v = T.violations(r["syms"])
    if v:
        print(f"  {r['name'][:44]:46s} {v}")
