import itertools, collections
from atlas import *
import model3 as M

norm, has = M.norm, M.has


def C1(X):  # single-atom-subject laws only: forward closure + warrant + ground + Uc + Oa
    S = norm(X)
    if M.forward_open(S) or M.unwarranted(S) or M.ungrounded(S):
        return False
    if "Uc" in S and not (has(S, "Aw") and has(S, "At")):
        return False
    if has(S, "Oa") and has(S, "Li") and not has(S, "Ex", "Tp"):
        return False
    return True


def C2(X):  # conjunctive-subject law (X19*)
    S = norm(X)
    return not (has(S, "Aw") and has(S, "Xf") and not has(S, "At", "Fz", "Xm"))


def I(X):
    S = norm(X)
    if has(S, "Fl") and has(S, "Cp", "Cl") and has(S, "Pl", "Cd", "Im"):
        return False
    if "Fl" in S and has(S, "Xf", "Rl", "Of"):
        return False
    if armed_ref(S):
        return False
    return True


U = ["Fl", "Xm", "Xf", "Rl", "Of", "Bs", "Sl", "Au", "Gs", "Uc", "Aw", "At", "Cp", "Cl", "Pl", "Cd", "Ix", "Sh", "Ct", "Li"]
allsub = [frozenset(c) for r in range(0, 6) for c in itertools.combinations(U, r)]
Cs = [s for s in allsub if C1(s)]
Cset = set(Cs)
bad = [(sorted(a), sorted(b)) for a in Cs for b in Cs if len(a | b) <= 5 and (a | b) not in Cset]
print(f"|C1| = {len(Cs)}  union-closed: {not bad}", bad[:2])
print("empty closed:", C1(frozenset()), " top closed:", C1(frozenset(SYMS)))
badint = [(sorted(a), sorted(b), sorted(a & b)) for a in Cs for b in Cs if (a & b) not in Cset]
print("intersection-closed:", not badint, "witness:", badint[0] if badint else None)


def meet(a, b):
    inter = a & b
    subs = [frozenset(c) for r in range(len(inter) + 1) for c in itertools.combinations(sorted(inter), r)]
    cl = [s for s in subs if C1(s)]
    return frozenset().union(*cl) if cl else frozenset()


# lattice laws for (C1, join=union, meet)
small = [s for s in Cs if len(s) <= 3]
print("\nlattice law checks on", len(small), "closed sets of size<=3")
fails = collections.Counter()
wit = {}
n = 0
for a, b, c in itertools.islice(itertools.product(small, repeat=3), 60000):
    n += 1
    if (a | b) | c != a | (b | c):
        fails["assoc-join"] += 1
    if meet(meet(a, b), c) != meet(a, meet(b, c)):
        fails["assoc-meet"] += 1
        wit.setdefault("assoc-meet", (sorted(a), sorted(b), sorted(c)))
    if a | b != b | a or meet(a, b) != meet(b, a):
        fails["comm"] += 1
    if a | a != a or meet(a, a) != a:
        fails["idem"] += 1
    if a | frozenset() != a:
        fails["identity"] += 1
    if a | meet(a, b) != a or meet(a, a | b) != a:
        fails["absorb"] += 1
        wit.setdefault("absorb", (sorted(a), sorted(b)))
    if a | meet(b, c) != meet(a | b, a | c):
        fails["distrib"] += 1
        wit.setdefault("distrib", (sorted(a), sorted(b), sorted(c), sorted(a | meet(b, c)), sorted(meet(a | b, a | c))))
print("triples tested", n, "failures:", dict(fails))
for k, v in wit.items():
    print("  witness", k, v)

# Adm = C1 n C2 n I
A = [s for s in allsub if C1(s) and C2(s) and I(s)]
Aset = set(A)
bu = [(sorted(a), sorted(b), sorted(a | b)) for a in A for b in A if len(a | b) <= 5 and (a | b) not in Aset]
print(f"\n|Adm| = {len(A)}  union-closed: {not bu}")
print("  join witnesses (first 3):", bu[:3])
bi = [(sorted(a), sorted(b), sorted(a & b)) for a in A for b in A if (a & b) not in Aset]
print("  intersection-closed:", not bi, "witness:", bi[0] if bi else None)
