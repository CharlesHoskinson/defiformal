"""Classify all 156 blind cases and write algebra/verdicts/OP-LOG.json.

The classifier is the validity predicate and nothing else. There is no lookup
against the census, no size heuristic, and no appeal to blind-test-KEY.json or
negative-corpus.json, neither of which was read.
"""
import json, collections, os
import atlas as A, theory as T

OUT = "/root/DefiElements/algebra/verdicts/OP-LOG.json"

cases = A.blind_cases()
assert len(cases) == 156, len(cases)

verdicts, detail = [], []
for c in cases:
    v = T.violations(c["elements"])
    verdicts.append({"id": c["id"],
                     "verdict": "INADMISSIBLE" if v else "ADMISSIBLE"})
    detail.append({"id": c["id"], "n": len(c["elements"]),
                   "sort": "Q" if T.is_mandate(c["elements"]) else "M",
                   "violated": v})

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w", encoding="utf8") as f:
    json.dump({"verdicts": verdicts}, f, indent=1)

n_adm = sum(1 for v in verdicts if v["verdict"] == "ADMISSIBLE")
print(f"wrote {OUT}: {len(verdicts)} verdicts, "
      f"{n_adm} ADMISSIBLE, {len(verdicts)-n_adm} INADMISSIBLE")

print("\nviolated-clause frequency across the blind set:")
cnt = collections.Counter()
for d in detail:
    cnt.update(d["violated"])
for k, n in cnt.most_common():
    print(f"   {k:5s} {n:3d}")

print("\nadmissible rate by size:")
bysz = collections.defaultdict(lambda: [0, 0])
for d, v in zip(detail, verdicts):
    b = bysz[d["n"]]
    b[1] += 1
    if v["verdict"] == "ADMISSIBLE":
        b[0] += 1
print("  ", {k: f"{v[0]}/{v[1]}" for k, v in sorted(bysz.items())})

print("\nmandate-sort cases:", [d["id"] for d in detail if d["sort"] == "Q"])

# sanity: the 72 census sets, wherever they sit in the blind file, must be
# classified the way the theory classifies them directly.
real = {frozenset(s for s in r["syms"] if s in A.SYMSET): r["name"]
        for r in A.real_protocols()}
hit = miss = 0
for c, v in zip(cases, verdicts):
    k = frozenset(s for s in c["elements"] if s in A.SYMSET)
    if k in real:
        if v["verdict"] == "ADMISSIBLE":
            hit += 1
        else:
            miss += 1
            print(f"   census set rejected: {c['id']} {real[k]} {T.violations(c['elements'])}")
print(f"\ncensus sets present in the blind file: {hit+miss}, accepted {hit}, rejected {miss}")
