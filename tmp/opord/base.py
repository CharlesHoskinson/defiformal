import atlas, json, collections
from atlas import *

# identify which blind cases coincide with a lane decomposition (REAL)
avail = collections.Counter({k: len(v) for k, v in LANESETS.items()})
real_ids = set()
for c in blind:
    fs = frozenset(c["elements"])
    if avail.get(fs, 0) > 0:
        avail[fs] -= 1
        real_ids.add(c["id"])
print("blind cases:", len(blind), " matched to lane sets (REAL):", len(real_ids))
print("unmatched leftover lane sets:", {k: v for k, v in avail.items() if v > 0})

R = [c for c in blind if c["id"] in real_ids]
N = [c for c in blind if c["id"] not in real_ids]
print("REAL", len(R), "OTHER", len(N))
print("size dist REAL", sorted(collections.Counter(len(c["elements"]) for c in R).items()))
print("size dist OTHER", sorted(collections.Counter(len(c["elements"]) for c in N).items()))


def ratio(pred, label):
    """pred(X) -> True means ADMISSIBLE"""
    a = sum(1 for c in R if pred(c["elements"]))
    b = sum(1 for c in N if pred(c["elements"]))
    ar, br = a / len(R), b / len(N)
    print(f"{label:38s} real {a:3d}/{len(R)} = {ar:.3f}   other {b:3d}/{len(N)} = {br:.3f}   ratio {(ar/br if br else float('inf')):.2f}")
    return ar, br


ratio(lambda X: True, "accept everything")
ratio(lambda X: not closes_ref(X), "reference closure (25 laws)")
ratio(lambda X: not closes_ref(X) and not armed_ref(X), "reference closure + armed hazards")

# which laws fire / fail how often
fc = collections.Counter()
for c in blind:
    for lid, pr in closes_ref(c["elements"]):
        fc[lid] += 1
print("failing laws over all 156:", fc.most_common())

fcR = collections.Counter()
for c in R:
    for lid, pr in closes_ref(c["elements"]):
        fcR[lid] += 1
print("failing laws over REAL:", fcR.most_common())
fcN = collections.Counter()
for c in N:
    for lid, pr in closes_ref(c["elements"]):
        fcN[lid] += 1
print("failing laws over OTHER:", fcN.most_common())
