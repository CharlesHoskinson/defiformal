"""OP-LOG's own negative corpus.

I did not read `algebra/blind-test-KEY.json` and I did not read
`algebra/negative-corpus.json` (which `blind.mjs` shows is the generator's
source of corruptions, i.e. the key by another name). To calibrate I build my
own adversarial corpus from the 72 lane decompositions, using corruption
families that a reasonable generator would use.

Families:
  drop1/drop2   : delete 1 or 2 elements from a real protocol
  add1/add2/add3: inject 1-3 elements drawn from the vocabulary
  swapgrp       : replace an element with another from the same G-group
  swapany       : replace k elements with uniformly drawn ones
  graft         : union of a prefix of one protocol and a suffix of another
  chimera       : union of two whole protocols from different categories
  uniform       : uniform random subset, size drawn from the real size profile
  weighted      : random subset, elements drawn with corpus frequency weights
"""
import random, itertools
import atlas as A

REAL = A.real_protocols()
# `Ve` (vote-escrow) is on the contested register, not in ELEMENTS; two census
# decompositions use it. It is out of signature, so it is dropped here and
# ignored by every axiom rather than being treated as evidence either way.
for _r in REAL:
    _r["syms"] = [s for s in _r["syms"] if s in A.SYMSET]
REAL_SETS = [frozenset(r["syms"]) for r in REAL]
REAL_INDEX = set(REAL_SETS)
SIZES = [len(s) for s in REAL_SETS]

import collections
FREQ = collections.Counter()
for s in REAL_SETS:
    FREQ.update(s)
WEIGHTS = [FREQ.get(s, 0) + 0.5 for s in A.SYMS]

BY_GROUP = collections.defaultdict(list)
for s in A.SYMS:
    BY_GROUP[A.GROUP[s]].append(s)


def gen(seed=7, per_family=400):
    rng = random.Random(seed)
    out = []

    def emit(fam, syms, frm=None):
        f = frozenset(syms)
        if len(f) < 1:
            return
        if f in REAL_INDEX:      # accidentally reconstructed a real protocol
            return
        out.append({"family": fam, "syms": sorted(f), "from": frm})

    for _ in range(per_family):
        r = rng.choice(REAL)
        s = set(r["syms"])
        if len(s) > 2:
            emit("drop1", s - {rng.choice(sorted(s))}, r["name"])
        if len(s) > 3:
            emit("drop2", s - set(rng.sample(sorted(s), 2)), r["name"])
        emit("add1", s | {rng.choice(A.SYMS)}, r["name"])
        emit("add2", s | set(rng.sample(A.SYMS, 2)), r["name"])
        emit("add3", s | set(rng.sample(A.SYMS, 3)), r["name"])
        # same-group substitution
        v = rng.choice(sorted(s))
        cands = [c for c in BY_GROUP[A.GROUP[v]] if c != v]
        if cands:
            emit("swapgrp", (s - {v}) | {rng.choice(cands)}, r["name"])
        k = max(1, len(s) // 4)
        drop = set(rng.sample(sorted(s), min(k, len(s))))
        emit("swapany", (s - drop) | set(rng.sample(A.SYMS, len(drop))), r["name"])
        r2 = rng.choice(REAL)
        a, b = sorted(s), sorted(set(r2["syms"]))
        emit("graft", set(a[: len(a) // 2]) | set(b[len(b) // 2:]),
             f"{r['name']}|{r2['name']}")
        if r["category"] != r2["category"]:
            emit("chimera", s | set(b), f"{r['name']}+{r2['name']}")
        n = rng.choice(SIZES)
        emit("uniform", rng.sample(A.SYMS, n))
        n = rng.choice(SIZES)
        picked = set()
        while len(picked) < n:
            picked.add(rng.choices(A.SYMS, weights=WEIGHTS)[0])
        emit("weighted", picked)
    return out


if __name__ == "__main__":
    N = gen()
    c = collections.Counter(x["family"] for x in N)
    print(len(N), dict(c))
    print("mean size", sum(len(x["syms"]) for x in N) / len(N))
