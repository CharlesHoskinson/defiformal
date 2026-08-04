"""Diagnostics: why does the reference closure predicate reject 42 of 72 real
protocols, and what does the corpus actually say about co-occurrence?"""
import collections, itertools
import atlas as A

R = A.real_protocols()
print("=== reference closure failures on real protocols ===")
fail = collections.Counter()
for r in R:
    v = A.closure_violations(r["syms"])
    for (lid, i, alts) in v:
        fail[(lid, alts)] += 1
for k, n in fail.most_common():
    print(f"  {k[0]:5s} needs {'|'.join(k[1]):22s} missing in {n} real protocols")

print()
print("=== which real protocols fail, and on what ===")
for r in R:
    v = A.closure_violations(r["syms"])
    if v:
        print(f"  {r['name'][:38]:40s} {[ (l, '|'.join(a)) for l,i,a in v ]}")

print()
print("=== armed written hazards on real protocols ===")
hz = collections.Counter()
for r in R:
    for h in A.armed_written_hazards(r["syms"]):
        hz[h] += 1
print(" ", dict(hz))

print()
print("=== proposed derived hazards vs real protocols ===")
for name, pred in [
    ("{Fl,Xm}", lambda S: {"Fl", "Xm"} <= S),
    ("{Fl,Au,Rl}", lambda S: {"Fl", "Au", "Rl"} <= S),
    ("{Au,Gs}", lambda S: {"Au", "Gs"} <= S),
    ("X2 full", lambda S: "Fl" in S and (S & {"Cp", "Cl"}) and (S & {"Pl", "Cd"})),
]:
    hits = [r["name"] for r in R if pred(set(r["syms"]))]
    print(f"  {name:12s} fires on {len(hits)} real: {hits}")

print()
print("=== element frequency over 72 real ===")
f = collections.Counter()
for r in R:
    f.update(r["syms"])
for s in A.SYMS:
    print(f"  {s:3s} {A.GROUP[s]} S{A.STRATUM[s]} {A.STATUS[s][:4]:4s} {f.get(s,0):3d}")
print("  never observed:", sorted(set(A.SYMS) - set(f)))

print()
print("=== size distribution of real ===")
print(sorted(collections.Counter(len(r["syms"]) for r in R).items()))
