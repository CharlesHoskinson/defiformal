import collections
from atlas import *
from rules import R, N, unwarranted, has, ST, G, real_ids
from search import viol, CONS, isreal, law_unmet, extra

SEL = ['L1', 'L2', 'L3', 'L4', 'L19', 'L20', 'L21', 'warrant', 'ground', 'X2', 'FlX', 'armed', 'Uc', 'X18', 'L5']
rej = [False] * len(blind)
for c in SEL:
    for i, v in enumerate(viol[c]):
        if v:
            rej[i] = True

print("=== SURVIVING NON-LANE CASES (false accepts) ===")
for i, c in enumerate(blind):
    if not rej[i] and not isreal[i]:
        X = sorted(c["elements"], key=lambda s: (ST.get(s, 9), G.get(s, "")))
        print(f"{c['id']} n={len(X):2d} groups={len({G.get(s,'?') for s in X}):2d} {[(s, G.get(s,'?'), ST.get(s,'?')) for s in X]}")

print()
print("=== REJECTED LANE CASES (false rejects) ===")
for i, c in enumerate(blind):
    if rej[i] and isreal[i]:
        which = [k for k in SEL if viol[k][i]]
        print(f"{c['id']} {LANESETS[frozenset(c['elements'])]}  by {which}")
