"""Gate 1.1, condition 1: does every candidate family have >= 2 corpus witnesses?

ROADMAP 1.1: "every family has >= 2 corpus witnesses and a law that fails for its
neighbours. A family with no law is a name."

The witness counts are not re-derived here. Each INSIGHT-L*.md section 5 already
records, per candidate primitive, an `instantiated by (n)` column naming the
protocols. Scoring recorded evidence avoids inventing fresh syntactic predicates
per family, which is confirmation-prone: whoever writes the predicate knows which
answer they want.

THE LEDGERS DO NOT AGREE ON NOTATION, and a first cut of this script scored 21
singletons by missing that. Three forms are in use:

    L1/L2/L4/L5/L6   "1inch, CoW (2)"                  parenthesised integer
    L3               "ApeX, GMX - n=2"                 trailing n=
    L3               "Yearn, Beefy, Huma x2 - n>=4"    trailing n>= (a bound)
    L2               "all multi-user specs"            prose, no count at all

Reading only the first form scores the third as a singleton and the fourth as a
singleton, both wrongly. Verdicts are therefore three-way: a cell that cannot be
read is reported UNREADABLE, never silently failed.
"""
import glob
import re
import sys
from collections import defaultdict
import os as _os
from pathlib import Path as _Path
# Resolved from this file's own location, the pattern gate33_cert_check.py uses.
# DEFIFORMAL_ROOT overrides and says so.
_SELF = _Path(__file__).resolve().parents[3]
_REPO = _Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    import sys as _sys
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


LEDGERS = sorted(glob.glob(
    str(_REPO / "research/positive-program/insights/INSIGHT-L*.md")))

PAREN_N = re.compile(r"\((\d+)")
TRAIL_N = re.compile(r"\bn\s*(?:=|>=|≥)\s*(\d+)")
BOUNDED = re.compile(r"\bn\s*(?:>=|≥)\s*\d+")
PROSE_ALL = re.compile(r"\ball\b", re.I)
NOISE = re.compile(
    r"\b(profile|coded|distinctive|and|others|etc|via|plus|has|solver|fill)\b",
    re.I)


def parse_section5(path):
    src = open(path, encoding="utf-8", errors="replace").read()
    m = re.search(r"^#+\s*5\..*?$(.*?)(?=^#+\s*6\.)", src, re.M | re.S)
    if not m:
        return []
    rows = []
    for line in m.group(1).splitlines():
        line = line.strip()
        if not line.startswith("|") or line.startswith("|---"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 3 or cells[0].lower().startswith("candidate"):
            continue
        rows.append({
            "lane": re.search(r"(L\d)", path).group(1),
            "name": cells[0].strip("`"),
            "inst": cells[2],
            "why": cells[3] if len(cells) > 3 else "",
        })
    return rows


def witnesses(cell):
    """-> (count, how). count is None when the cell cannot be read."""
    m = TRAIL_N.search(cell)
    if m:
        how = "n>=" if BOUNDED.search(cell) else "n="
        return int(m.group(1)), how
    m = PAREN_N.search(cell)
    if m:
        return int(m.group(1)), "(n)"
    if PROSE_ALL.search(cell):
        return None, "prose"
    head = cell.split("(")[0].split("—")[0]
    parts = [NOISE.sub("", p).strip() for p in head.split(",")]
    parts = [p for p in parts if p]
    if parts:
        return len(parts), "named"
    return None, "prose"


rows = []
for path in LEDGERS:
    rows.extend(parse_section5(path))
print(f"section-5 candidate rows parsed: {len(rows)}"
      f" across {len(LEDGERS)} ledgers\n")
if not rows:
    sys.exit("no rows parsed -- table shape changed")

print(f"{'lane':<4} {'candidate primitive':<34} {'n':>4} {'read':>6}  verdict")
print("-" * 76)
passing, singles, unread = [], [], []
for r in rows:
    n, how = witnesses(r["inst"])
    if n is None:
        verdict, bucket = "UNREADABLE", unread
    elif n >= 2:
        verdict, bucket = "PASS", passing
    else:
        verdict, bucket = "FAIL (singleton)", singles
    bucket.append(r)
    r["n"], r["how"] = n, how
    print(f"{r['lane']:<4} {r['name'][:34]:<34} {n if n else '-':>4} {how:>6}"
          f"  {verdict}")

print("\n" + "=" * 76)
print(f"condition 1 (>=2 witnesses):"
      f"  PASS {len(passing)}   SINGLETON {len(singles)}"
      f"   UNREADABLE {len(unread)}   of {len(rows)}")

print("\n--- SINGLETONS: one witness, so gate 1.1 condition 1 fails ---")
for r in singles:
    print(f"   {r['lane']}  {r['name'][:32]:<32} {r['inst'][:40]}")

print("\n--- UNREADABLE: no count recorded, must be resolved by hand ---")
for r in unread:
    print(f"   {r['lane']}  {r['name'][:32]:<32} {r['inst'][:40]}")

print("\n--- condition 2: a law that fails for its neighbours ---")
print("The ledgers carry a `why it is primitive` column. It is prose, not a law.")
for r in rows[:3]:
    print(f"   {r['name'][:26]:<26} -> {r['why'][:52]}")
stated = [r for r in rows
          if re.search(r"[=<>]\s*\w|\binv_\w+|\bforall\b", r["why"])]
print(f"\n   rows whose rationale contains an equation or an invariant name:"
      f" {len(stated)} of {len(rows)}")
print("   Gate 1.1 needs a law PER FAMILY that FAILS FOR ITS NEIGHBOURS.")
print("   A rationale is not that, so condition 2 is unmet corpus-wide")
print("   independently of condition 1.")

by_lane = defaultdict(lambda: [0, 0, 0])
for r in rows:
    i = 0 if (r["n"] or 0) >= 2 else (2 if r["n"] is None else 1)
    by_lane[r["lane"]][i] += 1
print(f"\n{'lane':<6} {'>=2':>5} {'singleton':>10} {'unreadable':>11}")
for lane in sorted(by_lane):
    p, f, u = by_lane[lane]
    print(f"{lane:<6} {p:>5} {f:>10} {u:>11}")
