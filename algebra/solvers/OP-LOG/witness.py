"""Targeted search for the closure witnesses that pin down where Valid sits
inside the composition lattice."""
import itertools, random
import atlas as A, theory as T, algebra as G

rng = random.Random(11)
REAL = [frozenset(G.Cn(r["syms"])) for r in A.real_protocols()]
pool = set(REAL)
for _ in range(200000):
    s = G.Cn(rng.sample(A.SYMS, rng.randint(1, 7)))
    pool.add(s)
pool = list(pool)
VAL = [s for s in pool if T.valid(s)]
INV = [s for s in pool if not T.valid(s)]
print(f"pool={len(pool)} valid={len(VAL)} invalid={len(INV)}")

print()
print("1. Valid is NOT closed under join  (two valid protocols, invalid union)")
found = 0
for a, b in itertools.islice(itertools.product(VAL, repeat=2), 3000000):
    if a == b:
        continue
    j = G.join(a, b)
    v = T.violations(j)
    if v:
        print(f"   A={sorted(a)}")
        print(f"   B={sorted(b)}")
        print(f"   A+B={sorted(j)}  violates {v}")
        found += 1
        if found == 3:
            break

print()
print("2. Valid is NOT closed under meet  (two valid, invalid intersection)")
found = 0
for a, b in itertools.islice(itertools.product(VAL, repeat=2), 3000000):
    if a == b:
        continue
    m = G.meet(a, b)
    if not m:
        continue
    v = T.violations(m)
    if v:
        print(f"   A={sorted(a)}  B={sorted(b)}")
        print(f"   A^B={sorted(m)}  violates {v}")
        found += 1
        if found == 2:
            break

print()
print("3. Valid is NOT upward closed  (valid, one atom added, invalid)")
found = 0
for a in VAL:
    for e in A.SYMS:
        if e in a:
            continue
        b = G.Cn(set(a) | {e})
        v = T.violations(b)
        if v and not any(x in ("V1",) for x in v):
            print(f"   S={sorted(a)}  +{e}  violates {v}")
            found += 1
            break
    if found == 3:
        break

print()
print("4. Valid is NOT downward closed  (valid, one atom removed, invalid)")
found = 0
for a in VAL:
    for e in sorted(a):
        b = frozenset(set(a) - {e})
        if not b:
            continue
        v = T.violations(b)
        if v:
            print(f"   S={sorted(a)}  -{e}  violates {v}")
            found += 1
            break
    if found == 3:
        break

print()
print("5. The sort flip: a valid MANDATE that becomes an invalid MECHANISM")
found = 0
for a in VAL:
    if not T.is_mandate(a):
        continue
    for e in ("Li", "Ad", "Sl", "Bs"):
        if e in a:
            continue
        b = G.Cn(set(a) | {e})
        if T.is_mandate(b):
            continue
        v = T.violations(b)
        if v:
            print(f"   mandate S={sorted(a)}  +{e} -> mechanism, violates {v}")
            found += 1
            break
    if found == 3:
        break
print("   (mandate witnesses in the census:",
      [r["name"] for r in A.real_protocols() if T.is_mandate(r["syms"])], ")")

print()
print("6. Repair menu: is completion NP-hard? measure branching")
import collections
cnt = collections.Counter()
for s in rng.sample(INV, min(400, len(INV))):
    cnt[len(T.violations(s))] += 1
print("   #violated clauses per invalid set:", dict(sorted(cnt.items())))
