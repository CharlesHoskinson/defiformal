"""Do the 16 G-groups behave like feature-model or-groups with a cardinality
cap? Measure the census maximum per group and what a cap would cost/buy."""
import collections
import atlas as A, negatives as N

REAL = A.real_protocols()
NEG = [n for n in N.gen(seed=11, per_family=400)
       if n["family"] in {"drop1", "drop2", "add1", "add2", "add3", "swapgrp",
                          "swapany", "graft", "uniform", "weighted"}
       and len(n["syms"]) <= 17]

GROUPS = sorted({A.GROUP[s] for s in A.SYMS})


def prof(S):
    c = collections.Counter(A.GROUP[s] for s in S if s in A.SYMSET)
    return c


print(f"{'grp':5s} {'|grp|':>5s} {'realMax':>7s} {'negMax':>6s}  cost/buy at cap=realMax")
for g in GROUPS:
    n = sum(1 for s in A.SYMS if A.GROUP[s] == g)
    rm = max(prof(r["syms"]).get(g, 0) for r in REAL)
    nm = max(prof(x["syms"]).get(g, 0) for x in NEG)
    over = sum(1 for x in NEG if prof(x["syms"]).get(g, 0) > rm)
    print(f"{g:5s} {n:5d} {rm:7d} {nm:6d}  buys {100*over/len(NEG):5.2f}% of negatives")

print()
print("=== joint cap: any group over its census max ===")
caps = {g: max(prof(r["syms"]).get(g, 0) for r in REAL) for g in GROUPS}
bad = sum(1 for x in NEG if any(prof(x["syms"]).get(g, 0) > caps[g] for g in GROUPS))
print(f"caps={caps}")
print(f"rejects {100*bad/len(NEG):.2f}% of negatives, 0% of reals by construction")

print()
print("=== cap+1 (a genuinely conservative cap) ===")
bad = sum(1 for x in NEG if any(prof(x["syms"]).get(g, 0) > caps[g] + 1 for g in GROUPS))
print(f"rejects {100*bad/len(NEG):.2f}% of negatives")

print()
print("=== total size cap ===")
print("real max size", max(len(r["syms"]) for r in REAL))
for k in (14, 15, 16, 17, 18):
    print(f"  size>{k}: {100*sum(1 for x in NEG if len(x['syms'])>k)/len(NEG):.2f}% of negatives")

print()
print("=== candidate exclusions: pairs never co-occurring in the census, by group pair ===")
seen = set()
for r in REAL:
    for a in r["syms"]:
        for b in r["syms"]:
            if a < b:
                seen.add((a, b))
cand = []
for i, a in enumerate(A.SYMS):
    for b in A.SYMS[i + 1:]:
        x, y = (a, b) if a < b else (b, a)
        if (x, y) not in seen:
            cand.append((x, y))
print(f"{len(cand)} unobserved pairs of {len(A.SYMS)*(len(A.SYMS)-1)//2}")
hit = sum(1 for x in NEG if any(p[0] in set(x["syms"]) and p[1] in set(x["syms"]) for p in cand))
print(f"banning all of them would reject {100*hit/len(NEG):.1f}% of negatives and 0% of reals")
print("  (NOT USED: this is memorisation, not an algebra -- see report)")
