"""The composition operation and machine-checked proofs of its laws.

DEFINITE FRAGMENT.  H = the clauses of theory.POOL whose trigger is a single
conjunct and whose head is a single atom, restricted to sort "*" (unguarded).
These are definite Horn rules  b1 & ... & bk -> h.

    Cn(S) = least superset of S closed under H.

    S (+) T = Cn(S u T)          join
    S (*) T = S n T              meet

CARRIER = the image of Cn, i.e. the Cn-closed subsets of the 58 atoms.
"""
import itertools, random
import atlas as A, theory as T

# ------------------------------------------------------- the definite fragment
DEFINITE = [(cl["id"], cl["trigger"][0], cl["head"][0])
            for cl in T.POOL
            if cl["sort"] == "*" and len(cl["trigger"]) == 1 and len(cl["head"]) == 1]


def Cn(S):
    S = set(S)
    changed = True
    while changed:
        changed = False
        for _, body, h in DEFINITE:
            if h not in S and all(b in S for b in body):
                S.add(h)
                changed = True
    return frozenset(S)


def join(S, T_):
    return Cn(set(S) | set(T_))


def meet(S, T_):
    return frozenset(set(S) & set(T_))


HEADS = sorted({h for _, _, h in DEFINITE})
FREE = [s for s in A.SYMS if s not in HEADS]

if __name__ == "__main__":
    print("definite Horn rules extracted from the theory:")
    for cid, body, h in DEFINITE:
        print(f"   {cid:5s}  {' & '.join(body):12s} -> {h}")
    print(f"\nderived atoms (rule heads): {HEADS}")
    print(f"free generators: {len(FREE)} of 58")

    rng = random.Random(3)
    UNIV = A.SYMS
    sample = [frozenset(rng.sample(UNIV, rng.randint(0, 8))) for _ in range(4000)]
    closed = [Cn(s) for s in sample]
    closed = list({c for c in closed})
    print(f"\nsampled {len(closed)} distinct Cn-closed sets")

    def check(name, fn, xs, n=3):
        bad = None
        for t in itertools.islice(itertools.product(xs, repeat=n), 200000):
            r = fn(*t)
            if r is not True:
                bad = (t, r)
                break
        print(f"  {name:38s} {'HOLDS' if bad is None else 'FAILS ' + str(bad)}")
        return bad is None

    xs = closed[:60]
    print("\n=== laws of (+) on Cn-closed sets ===")
    check("commutative   A+B = B+A", lambda a, b: join(a, b) == join(b, a), xs, 2)
    check("associative   (A+B)+C = A+(B+C)",
          lambda a, b, c: join(join(a, b), c) == join(a, join(b, c)), xs, 3)
    check("idempotent    A+A = A", lambda a: join(a, a) == a, xs, 1)
    check("identity      A+0 = A", lambda a: join(a, frozenset()) == a, xs, 1)
    check("meet closed   A^B is Cn-closed", lambda a, b: Cn(meet(a, b)) == meet(a, b), xs, 2)
    check("absorption    A^(A+B) = A", lambda a, b: meet(a, join(a, b)) == a, xs, 2)
    check("absorption    A+(A^B) = A", lambda a, b: join(a, meet(a, b)) == a, xs, 2)
    check("Cn extensive  A <= Cn(A)", lambda a: set(a) <= set(Cn(a)), xs, 1)
    check("Cn idempotent Cn(Cn A) = Cn A", lambda a: Cn(Cn(a)) == Cn(a), xs, 1)
    check("Cn monotone   A<=B => CnA<=CnB",
          lambda a, b: not (set(a) <= set(b)) or set(Cn(a)) <= set(Cn(b)), xs, 2)

    print("\n=== distributivity (expected to FAIL) ===")
    ok = check("A+(B^C) = (A+B)^(A+C)",
               lambda a, b, c: join(a, meet(b, c)) == meet(join(a, b), join(a, c)), xs, 3)
    if ok:
        print("    ... searching harder")

    print("\n=== modularity ===")
    check("A<=C => A+(B^C) = (A+B)^C",
          lambda a, b, c: not (set(a) <= set(c)) or
          join(a, meet(b, c)) == meet(join(a, b), c), xs, 3)

    print("\n=== validity under (+) : the non-monotonicity result ===")
    wit = None
    for a, b in itertools.islice(itertools.product(xs, repeat=2), 40000):
        if T.valid(a) and T.valid(b) and not T.valid(join(a, b)):
            wit = (sorted(a), sorted(b), sorted(join(a, b)), T.violations(join(a, b)))
            break
    print("  join of two valid terms invalid:", wit)

    wit = None
    for a in xs:
        if not T.valid(a):
            continue
        for e in A.SYMS:
            if e in a:
                continue
            b = Cn(set(a) | {e})
            if not T.valid(b):
                wit = (sorted(a), e, T.violations(b))
                break
        if wit:
            break
    print("  valid term made invalid by ONE added atom:", wit)

    wit = None
    for a in xs:
        if T.valid(a):
            continue
        for e in A.SYMS:
            if e in a:
                continue
            b = Cn(set(a) | {e})
            if T.valid(b):
                wit = (sorted(a), e)
                break
        if wit:
            break
    print("  invalid term made valid by ONE added atom:", wit)

    print("\n=== is the requirement stratum union-closed? ===")
    REQ = [cl for cl in T.POOL if cl["sort"] == "*" and cl["head"]]
    bad = None
    for a, b in itertools.islice(itertools.product(xs, repeat=2), 40000):
        if T.valid(a, REQ) and T.valid(b, REQ) and not T.valid(join(a, b), REQ):
            bad = (sorted(a), sorted(b), T.violations(join(a, b), REQ))
            break
    print("  unguarded, non-exclusion clauses union-closed:", bad is None, bad or "")

    print("\n=== the sort guard is what breaks monotonicity ===")
    bad = None
    for a in xs:
        for e in A.SYMS:
            if e in a:
                continue
            b = Cn(set(a) | {e})
            if T.is_mandate(a) and not T.is_mandate(b) and T.valid(a) and not T.valid(b):
                bad = (sorted(a), e, T.violations(b))
                break
        if bad:
            break
    print("  mandate -> mechanism sort flip witness:", bad)
