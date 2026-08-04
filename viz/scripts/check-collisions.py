import json, glob
P = {}
claims = []
for f in glob.glob("/root/DefiElements/corpus50/lanes/*.json"):
    d = json.load(open(f, encoding="utf-8"))
    for c in d["categories"]:
        for p in c["protocols"]:
            P[p["name"]] = set(p["elements"])
        for grp in c.get("identical_decompositions", []):
            claims.append(grp)

print("=== lanes CLAIMED identical, checked against the actual element arrays ===")
real, fake = 0, 0
for grp in claims:
    names = [g for g in grp if g in P]
    if len(names) < 2:
        print(f"  [unresolvable names] {grp}")
        continue
    sets = [P[n] for n in names]
    if all(s == sets[0] for s in sets):
        real += 1
        print(f"  TRUE  {' = '.join(names)}  ({len(sets[0])} symbols)")
    else:
        fake += 1
        base = sets[0]
        d = "; ".join(f"{n} differs by {sorted(base ^ s)}" for n, s in zip(names[1:], sets[1:]) if s != base)
        print(f"  FALSE {' = '.join(names)} -> {d}")
print(f"\nclaimed-identical groups: {real} true, {fake} false")
