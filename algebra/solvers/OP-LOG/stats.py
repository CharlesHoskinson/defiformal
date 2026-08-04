import json
import theory as T, atlas as A, algebra as G

print("axioms", len(T.POOL), {"R": len(T.R), "C": len(T.COMPLETION),
                              "W": len(T.W), "X": len(T.X), "V": len(T.V)})
cnf = sum(len(c["trigger"]) for c in T.POOL)
lits = sum(len(t) + len(c["head"]) for c in T.POOL for t in c["trigger"])
print("CNF clauses", cnf, "total literals", lits)
print("sort-M guarded:", [c["id"] for c in T.POOL if c["sort"] == "M"])
print("free generators", len(G.FREE), "derived", G.HEADS)

used = set()
trig = set()
for c in T.POOL:
    for t in c["trigger"]:
        used |= set(t)
        trig |= set(t)
    used |= set(c["head"])
print("atoms named by no axiom:", sorted(set(A.SYMS) - used))
print("atoms constrained as a trigger:", len(trig))
print("atoms never a trigger:", sorted(set(A.SYMS) - trig))

d = json.load(open("/root/DefiElements/algebra/verdicts/OP-LOG.json"))
print("verdicts", len(d["verdicts"]), "unique ids", len({v["id"] for v in d["verdicts"]}),
      set(v["verdict"] for v in d["verdicts"]))

# non-injectivity fibres in the census
from collections import defaultdict
fib = defaultdict(list)
for r in A.real_protocols():
    fib[frozenset(s for s in r["syms"] if s in A.SYMSET)].append(r["name"])
print("\ncollision fibres:")
for k, v in fib.items():
    if len(v) > 1:
        print("  ", sorted(k), "->", v)
sub = 0
ks = list(fib)
for i, a in enumerate(ks):
    for b in ks:
        if a != b and a < b:
            sub += 1
print("strict-subset pairs among distinct census sets:", sub)
