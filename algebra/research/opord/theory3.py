import itertools, collections
from atlas import *
import model3 as M
from theory2 import C1, C2, I, meet, Cs, allsub

small = [s for s in Cs if len(s) <= 3]
fails = 0
wit = None
n = 0
for a, b, c in itertools.islice(itertools.product(small, repeat=3), 60000):
    n += 1
    if a <= c and (a | meet(b, c)) != meet(a | b, c):
        fails += 1
        if wit is None:
            wit = (sorted(a), sorted(b), sorted(c))
print(f"modularity: tested {n}, failures {fails}, witness {wit}")

# minimal forbidden faces of I
U = ["Fl", "Xm", "Xf", "Rl", "Of", "Bs", "Sl", "Au", "Gs", "Uc", "Aw", "At", "Cp", "Cl", "Pl", "Cd", "Ix", "Sh", "Ct", "Li"]
bad = [s for s in allsub if not I(s)]
minimal = [s for s in bad if all(I(s - {x}) for x in s)]
print("minimal forbidden faces (within test universe):", sorted([sorted(s) for s in minimal]))

# ---- FCA: attribute reducibility over the 72-protocol context
objs = [(p["name"], frozenset(x for x in p["syms"] if x in SYMS)) for p in lanes]
O = [n for n, _ in objs]
ext = {a: frozenset(n for n, s in objs if a in s) for a in SYMS}
present = {a: e for a, e in ext.items() if e}
red = []
for a, e in present.items():
    others = [f for b, f in present.items() if b != a and f >= e]
    if others:
        inter = frozenset(O)
        for f in others:
            inter &= f
        if inter == e:
            red.append(a)
print(f"\nattributes present: {len(present)}; FCA-reducible (extent = intersection of strictly larger extents): {len(red)}")
print(sorted(red))
irr = sorted(set(present) - set(red))
print(f"attribute-irreducible (a generating set for the concept lattice): {len(irr)}")
print(irr)

# concept count
concepts = set()
for r in range(0, 4):
    for c in itertools.combinations(sorted(present), r):
        e = frozenset(O)
        for a in c:
            e &= present[a]
        i = frozenset(a for a in present if present[a] >= e) if e else frozenset(present)
        concepts.add((e, i))
print("concepts reachable from <=3 attributes:", len(concepts))

# ---- generator/dependent typing vs stratum
dep = set(M.CONSUME)
gen = sorted(SYMS - dep)
print(f"\ntyping: {len(dep)} dependent (warranted) elements, {len(gen)} generators")
print("generators:", gen)
print("dependents:", sorted(dep))
agree = collections.Counter()
for s in SYMS:
    t = 1 if s in dep else 0
    agree[(t, ELEMS[s]["stratum"])] += 1
print("typing x stratum contingency:", dict(sorted(agree.items())))
