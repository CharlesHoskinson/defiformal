"""Which residue entries name a DELEGATED MANDATE over other people's assets?

The authority/discretion bucket is 69 entries, but it mixes governance knobs
(emission splits, pool factories) with the specific thing the refuter is about: a
named party exercising discretion over assets it does not own. This narrows to
the latter, because gate 1.1 condition 1 asks for >= 2 independent witnesses and
the answer decides whether the refuter is a singleton.
"""
import json
import re

P = "/root/DefiElements/research/positive-program/sigma/residue-index.json"
rows = json.load(open(P, encoding="utf-8"))

# Must name a PARTY exercising discretion AND assets belonging to others.
PARTY = re.compile(r"\b(curator|manager|delegate\w*|operator|agent|"
                   r"third[- ]party|batch manager|servicer|allocator|firm)\b", re.I)
OTHERS = re.compile(r"\b(other people|depositor\w*|borrower\w*|on behalf|"
                    r"their behalf|another address|other[s']* (?:money|funds|"
                    r"assets|capital)|mandate)\b", re.I)
DISCRETION = re.compile(r"\b(discretion\w*|chooses|choose|decides|sets|"
                        r"allocat\w+|curat\w+|rebalanc\w+|at will)\b", re.I)

hits = []
for r in rows:
    t = " ".join(r["residue"].split())
    if PARTY.search(t) and DISCRETION.search(t) and OTHERS.search(t):
        hits.append((r["protocol"], r["category"], t))

seen, out = set(), []
for proto, cat, t in hits:
    if proto in seen:
        continue
    seen.add(proto)
    out.append((proto, cat, t))

print(f"residue entries naming a delegated mandate over others' assets:"
      f" {len(hits)}")
print(f"distinct protocols                                            :"
      f" {len(out)}\n")
for proto, cat, t in out:
    print(f"  {proto[:40]}   [{cat[:28]}]")
    print(f"    {t[:230]}\n")

cats = sorted({c for _, c, _ in out})
print(f"categories spanned: {len(cats)}")
for c in cats:
    print(f"   {c}")
