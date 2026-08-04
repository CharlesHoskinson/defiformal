import collections, itertools, json
from atlas import *
from rules import R, N, close2, unwarranted, WARRANT, PROMOTE, PT, has, ST, G, real_ids

ALLX = [c["elements"] for c in blind]


def law_unmet(X, lawid):
    S = set(x for x in X if x in SYMS)
    law = next(l for l in PARSED if l["id"] == lawid)
    if not any(s in S for s in law["subjects"]):
        return False
    for kind, t in PT[lawid]:
        if kind != "INT":
            continue
        if not any(a in S for a in t["alts"]):
            return True
    return False


LAWIDS = [l["id"] for l in PARSED if l["subjects"] and any(k == "INT" for k, _ in PT[l["id"]])]
print("laws with internal terms and element subjects:", LAWIDS)


def extra(X, name):
    S = set(x for x in X if x in SYMS)
    if name == "warrant":
        return bool(unwarranted(X))
    if name == "ground":
        return any(ST[e] >= 3 for e in S) and not any(ST[e] <= 2 for e in S)
    if name == "Uc":
        return "Uc" in S and not (has(S, "Aw") and has(S, "At"))
    if name == "X2":
        return has(S, "Fl") and has(S, "Cp", "Cl") and has(S, "Pl", "Cd", "Im")
    if name == "X18":
        return has(S, "Oa") and has(S, "Li") and not has(S, "Ex", "Tp")
    if name == "FlX":
        return has(S, "Fl") and has(S, "Xm", "Xf", "Rl", "Of")
    if name == "armed":
        return bool(armed_ref(X))
    raise KeyError(name)


EXTRAS = ["warrant", "ground", "Uc", "X2", "X18", "FlX", "armed"]

# precompute violation bitmaps
CONS = LAWIDS + EXTRAS
viol = {}
for cname in CONS:
    if cname in LAWIDS:
        viol[cname] = [law_unmet(X, cname) for X in ALLX]
    else:
        viol[cname] = [extra(X, cname) for X in ALLX]

isreal = [c["id"] in real_ids for c in blind]
NR = sum(isreal)
NN = len(blind) - NR

for cname in CONS:
    rr = sum(1 for i, v in enumerate(viol[cname]) if v and isreal[i])
    nr = sum(1 for i, v in enumerate(viol[cname]) if v and not isreal[i])
    print(f"{cname:8s} realRej {rr:3d}  otherRej {nr:3d}")


def score(sel):
    rej = [False] * len(blind)
    for c in sel:
        for i, v in enumerate(viol[c]):
            if v:
                rej[i] = True
    a = sum(1 for i in range(len(blind)) if not rej[i] and isreal[i])
    b = sum(1 for i in range(len(blind)) if not rej[i] and not isreal[i])
    ar, br = a / NR, b / NN
    return a, b, ar, br, (ar / br if br else float("inf"))


# greedy forward selection maximising ratio subject to real acceptance floor
best = []
cur = []
print("\n--- greedy (floor: real acceptance >= 0.55) ---")
while True:
    cands = []
    for c in CONS:
        if c in cur:
            continue
        a, b, ar, br, rt = score(cur + [c])
        if ar >= 0.55:
            cands.append((rt, a, b, c))
    if not cands:
        break
    cands.sort(reverse=True)
    rt, a, b, c = cands[0]
    a0, b0, ar0, br0, rt0 = score(cur)
    if rt <= rt0 + 1e-9:
        break
    cur.append(c)
    print(f"  + {c:8s} -> real {a}/{NR}={a/NR:.3f} other {b}/{NN}={b/NN:.3f} ratio {rt:.2f}")

print("\ngreedy selection:", cur)

# exhaustive over all subsets of CONS (|CONS| small enough?)
print("\n--- exhaustive best by ratio, real acceptance floor varied ---")
allsets = []
n = len(CONS)
print("n constraints", n)
for r in range(0, min(n, 9) + 1):
    for sel in itertools.combinations(CONS, r):
        a, b, ar, br, rt = score(list(sel))
        allsets.append((rt, ar, br, a, b, sel))
for floor in [0.5, 0.6, 0.7, 0.75, 0.8]:
    f = [x for x in allsets if x[1] >= floor]
    f.sort(key=lambda t: (-t[0], -t[1], len(t[5])))
    print(f"floor {floor}: ratio {f[0][0]:.2f} real {f[0][3]}/{NR} other {f[0][4]}/{NN} sel {f[0][5]}")
