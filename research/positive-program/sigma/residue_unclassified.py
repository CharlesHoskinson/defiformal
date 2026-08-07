"""What is actually in the 131 UNCLASSIFIED residue entries?

The first classifier used buckets I invented before reading the data, and left
131 entries across 59 applications unclassified -- more than any bucket it found.
Guessing a second set of keywords would repeat the mistake, so this reads the
data first: term frequency over the unclassified subset only, plus a sample.
"""
import json
import re
from collections import Counter

P = "/root/DefiElements/research/positive-program/sigma/residue-index.json"
rows = json.load(open(P, encoding="utf-8"))
unc = [r for r in rows if r["bucket"] == "UNCLASSIFIED"]
print(f"unclassified: {len(unc)} entries, "
      f"{len({r['protocol'] for r in unc})} applications\n")

STOP = set("""the a an and or of for to in is are that this it its no not with
as on by be if but from at any all which what when where how than then so such
there here their they them we i my me you your has have had was were been being
can could would should may might will shall do does did done more most other
only same each per into out up down over under about after before between both
another one two three element elements name names named naming vocabulary
symbol symbols record records recorded residue protocol protocols defi
lane category categories""".split())


def terms(s):
    return [w for w in re.findall(r"[a-z][a-z-]{3,}", s.lower())
            if w not in STOP]


c = Counter()
for r in unc:
    c.update(set(terms(r["residue"])))

print("terms appearing in >= 8 unclassified entries:")
print(f"{'term':<22} {'entries':>8}")
print("-" * 32)
for w, n in c.most_common(60):
    if n >= 8:
        print(f"{w:<22} {n:>8}")

print("\n" + "=" * 74)
print("SAMPLE — 14 unclassified entries, first sentence each")
print("=" * 74)
seen = set()
shown = 0
for r in unc:
    if r["protocol"] in seen:
        continue
    seen.add(r["protocol"])
    t = " ".join(r["residue"].split())
    first = re.split(r"(?<=[.;])\s", t)[0]
    print(f"\n  {r['protocol'][:38]}  [{r['category'][:22]}]")
    print(f"    {first[:190]}")
    shown += 1
    if shown >= 14:
        break
