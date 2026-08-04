"""Structural results: lattice checks, distributivity, FCA audit, derived grading."""
import itertools, random, collections
from atlas import *
import model3 as M

norm, has = M.norm, M.has

# ---------------------------------------------------------------- 1. closure C
def closedC(X):
    """the union-closed part: forward closure + warrant + ground + conditional hazards"""
    S = norm(X)
    if M.forward_open(S) or M.unwarranted(S) or M.ungrounded(S):
        return False
    if "Uc" in S and not (has(S, "Aw") and has(S, "At")):
        return False
    if has(S, "Aw") and has(S, "Xf") and not has(S, "At", "Fz", "Xm"):
        return False
    if has(S, "Oa") and has(S, "Li") and not has(S, "Ex", "Tp"):
        return False
    return True


def banI(X):
    """the downward-closed part: pure prohibitions"""
    S = norm(X)
    if has(S, "Fl") and has(S, "Cp", "Cl") and has(S, "Pl", "Cd", "Im"):
        return False
    if "Fl" in S and has(S, "Xf", "Rl", "Of"):
        return False
    if armed_ref(S):
        return False
    return True


U = ["Fl", "Xm", "Xf", "Rl", "Of", "Bs", "Sl", "Au", "Gs", "Uc", "Aw", "At", "Cp", "Cl", "Pl", "Cd", "Ix", "Sh", "Ct", "Li"]
subsets = []
for r in range(len(U) + 1):
    pass
allsub = [frozenset(c) for r in range(0, 6) for c in itertools.combinations(U, r)]
print("universe", len(U), "subsets tested (size<=5)", len(allsub))

C = [s for s in allsub if closedC(s)]
I = [s for s in allsub if banI(s)]
A = [s for s in allsub if closedC(s) and banI(s)]
print(f"C (union-closed part): {len(C)}   I (ban part): {len(I)}   Adm = C n I: {len(A)}")

Cset = set(C)
# union-closure of C  (only test pairs whose union has size <= 5 so it is in range)
bad = [(a, b) for a in C for b in C if len(a | b) <= 5 and (a | b) not in Cset]
print("C union-closed:", not bad, "" if not bad else bad[:3])
# I downward closed
badI = [(a, x) for a in I for x in a if (a - {x}) not in set(I)]
print("I downward-closed:", not badI)
# Adm union-closed?
Aset = set(A)
badA = [(a, b) for a in A for b in A if len(a | b) <= 5 and (a | b) not in Aset]
print("Adm union-closed:", not badA, "witness:", (sorted(badA[0][0]), sorted(badA[0][1]), sorted(badA[0][0] | badA[0][1])) if badA else None)
# Adm intersection closed?
badA2 = [(a, b) for a in A for b in A if (a & b) not in Aset]
print("Adm intersection-closed:", not badA2, "witness:", (sorted(badA2[0][0]), sorted(badA2[0][1]), sorted(badA2[0][0] & badA2[0][1])) if badA2 else None)


def meet(a, b):
    """largest C-closed subset of a & b"""
    inter = a & b
    best = frozenset()
    for r in range(len(inter), -1, -1):
        cands = [frozenset(c) for c in itertools.combinations(sorted(inter), r) if closedC(frozenset(c))]
        if cands:
            # union of all closed subsets is closed (C union-closed)
            best = frozenset().union(*cands)
            break
    return best


# distributivity of (C, u, meet)
random.seed(7)
Csmall = [s for s in C if len(s) <= 4]
viol = None
tested = 0
for a, b, c in itertools.islice(itertools.product(Csmall, repeat=3), 0, 400000):
    tested += 1
    if tested > 40000:
        break
    lhs = a | meet(b, c)
    rhs = meet(a | b, a | c)
    if lhs != rhs:
        viol = (sorted(a), sorted(b), sorted(c), sorted(lhs), sorted(rhs))
        break
print(f"distributivity tested {tested} triples: ", "HOLDS (no counterexample found)" if not viol else f"FAILS {viol}")

# modularity
viol2 = None
tested = 0
for a, b, c in itertools.product(Csmall, repeat=3):
    tested += 1
    if tested > 40000:
        break
    if a <= c:
        lhs = a | meet(b, c)
        rhs = meet(a | b, c)
        if lhs != rhs:
            viol2 = (sorted(a), sorted(b), sorted(c), sorted(lhs), sorted(rhs))
            break
print("modularity:", "HOLDS on sample" if not viol2 else f"FAILS {viol2}")

# ---------------------------------------------------------------- 2. FCA audit
objs = [(p["name"], frozenset(x for x in p["syms"] if x in SYMS)) for p in lanes]
ext = collections.defaultdict(set)
for n, s in objs:
    for a in s:
        ext[a].add(n)
print("\n--- FCA over the 72 lane protocols ---")
never = sorted(s for s in SYMS if not ext[s])
print("elements with EMPTY extent (never used):", never)
byext = collections.defaultdict(list)
for a, e in ext.items():
    if e:
        byext[frozenset(e)].append(a)
dupes = {tuple(sorted(v)): len(k) for k, v in byext.items() if len(v) > 1}
print("attribute-equivalent element groups (identical extent):", dupes)
# object collisions
byint = collections.defaultdict(list)
for n, s in objs:
    byint[s].append(n)
print("object collisions (identical intent):", [v for v in byint.values() if len(v) > 1])

# implication redundancy in L*
print("\n--- entailment among L* rows ---")
for lid, subs, terms in M.LSTAR:
    for t in terms:
        # is this term implied by another row with same-or-broader subjects and narrower term?
        for lid2, subs2, terms2 in M.LSTAR:
            if lid2 == lid:
                continue
            if set(subs) <= set(subs2):
                for t2 in terms2:
                    if set(t2) <= set(t):
                        print(f"  {lid}:{'|'.join(t)} entailed by {lid2}:{'|'.join(t2)}")

# ---------------------------------------------------------- 3. derived grading
req = collections.defaultdict(set)
for lid, subs, terms in M.LSTAR:
    for s in subs:
        for t in terms:
            for a in t:
                if a != s:
                    req[s].add(a)
for e, cs in M.CONSUME.items():
    pass  # consumers are the residual direction, not depth

depth = {}


def d(x, seen=()):
    if x in depth:
        return depth[x]
    if x in seen:
        return 0
    v = 0
    for y in req.get(x, ()):
        v = max(v, 1 + d(y, seen + (x,)))
    depth[x] = v
    return v


for s in SYMS:
    d(s)
agree = sum(1 for s in SYMS if depth[s] == ELEMS[s]["stratum"])
print(f"\nderived depth vs hand stratum: agree on {agree}/{len(SYMS)}; depth range {min(depth.values())}-{max(depth.values())}")
print("nonzero depths:", {k: (v, ELEMS[k]['stratum']) for k, v in sorted(depth.items()) if v})
