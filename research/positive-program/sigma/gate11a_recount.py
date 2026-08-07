"""Sub-gate 1.1a: recount candidate-primitive witnesses CORPUS-WIDE.

Gate 1.1 asks for ">= 2 corpus witnesses". The section-5 ledgers answer a
different question -- they count within a lane, and say so ("Maple (1 in lane;
appears in other categories)"). So the recorded 31/19/2 split cannot decide the
gate. This recounts across all 57 specs.

METHOD, and why it is not confirmation-prone

Each section-5 row carries a `quint definition` column naming the ACTUAL Quint
identifiers the candidate primitive is realised by -- `sharesFromAssets`,
`canDeliverOnce`, `RateLimit`/`currentLimit`/`consume`. Those names are the
ledger's own commitment, written before this question was asked. This script
searches the corpus for them. It does not invent a predicate per family, which
would let the author pick the answer.

WHAT COUNTS AS A WITNESS

A protocol spec (any `L*/*.qnt` that is not a `common.qnt`) whose source, with
comments stripped, references at least one of the row's identifiers. Both local
definitions and call sites count -- "instantiated by" covers a protocol that
defines the mechanism itself, as `justlend` does for `exchangeRate`.

`common.qnt` files are excluded from the count. They are shared libraries; a
definition sitting in one is not a protocol instantiating it. They are reported
separately, because a row whose identifiers appear ONLY in common files has no
protocol witness at all.

SENSITIVITY IS REPORTED, NOT CHOSEN

A row naming several identifiers can be scored two ways. ANY (a spec using at
least one) is generous; ALL (a spec using every one) is strict. Both are printed
so the reader can see how much the verdict depends on the choice.
"""
import glob
import os
import re
import sys
from collections import defaultdict

ROOT = "/root/DefiElements"
LEDGERS = sorted(glob.glob(f"{ROOT}/research/positive-program/insights/INSIGHT-L*.md"))
SPECS = sorted(glob.glob(f"{ROOT}/quint-models/L*/*.qnt"))

PAREN_N = re.compile(r"\((\d+)")
TRAIL_N = re.compile(r"\bn\s*(?:=|>=|≥)\s*(\d+)")
TICKED = re.compile(r"`([^`]+)`")
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
# identifiers too generic to be evidence of anything
STOPWORDS = {"common", "qnt", "int", "bool", "str", "Set", "List", "Map",
             "type", "val", "def", "action", "pure", "var", "state", "shape"}

sources = {}
for p in SPECS:
    src = re.sub(r"//[^\n]*", "", open(p, encoding="utf-8", errors="replace").read())
    sources[p] = src
protocols = [p for p in SPECS if os.path.basename(p) != "common.qnt"]
commons = [p for p in SPECS if os.path.basename(p) == "common.qnt"]
print(f"corpus: {len(SPECS)} specs = {len(protocols)} protocol specs"
      f" + {len(commons)} common.qnt\n")


def recorded_n(cell):
    m = TRAIL_N.search(cell) or PAREN_N.search(cell)
    return int(m.group(1)) if m else None


def identifiers(defn_cell):
    """The Quint names the ledger commits this row to."""
    out = []
    for chunk in TICKED.findall(defn_cell):
        for name in IDENT.findall(chunk):
            if name in STOPWORDS or len(name) < 4:
                continue
            if name not in out:
                out.append(name)
    return out


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
        rows.append({"lane": re.search(r"(L\d)", path).group(1),
                     "name": cells[0].strip("`"),
                     "defn": cells[1], "inst": cells[2]})
    return rows


rows = []
for p in LEDGERS:
    rows.extend(parse_section5(p))
if not rows:
    sys.exit("no rows parsed")

for r in rows:
    ids = identifiers(r["defn"])
    r["ids"] = ids
    hits_any, hits_all, dead = set(), set(), []
    per_id = {}
    for name in ids:
        pat = re.compile(r"\b" + re.escape(name) + r"\b")
        found = {p for p in protocols if pat.search(sources[p])}
        found_common = {p for p in commons if pat.search(sources[p])}
        per_id[name] = found
        if not found and not found_common:
            dead.append(name)
        hits_any |= found
    if ids:
        sets = [per_id[n] for n in ids if per_id[n]]
        hits_all = set.intersection(*sets) if sets else set()
    r["any"], r["all"], r["dead"] = len(hits_any), len(hits_all), dead
    r["rec"] = recorded_n(r["inst"])
    r["specs"] = sorted(os.path.basename(p)[:-4] for p in hits_any)

print(f"{'lane':<4} {'candidate primitive':<32} {'rec':>4} {'ANY':>4} {'ALL':>4}  change")
print("-" * 78)
promoted, still_single, unsearchable = [], [], []
for r in rows:
    if not r["ids"]:
        unsearchable.append(r)
        print(f"{r['lane']:<4} {r['name'][:32]:<32} {r['rec'] or '-':>4}"
              f" {'-':>4} {'-':>4}  NO IDENTIFIERS (prose definition)")
        continue
    change = ""
    if r["rec"] == 1 and r["any"] >= 2:
        change = f"SINGLETON -> {r['any']}"
        promoted.append(r)
    elif r["any"] < 2:
        change = "still < 2"
        still_single.append(r)
    print(f"{r['lane']:<4} {r['name'][:32]:<32} {r['rec'] or '-':>4}"
          f" {r['any']:>4} {r['all']:>4}  {change}")

print("\n" + "=" * 78)
searched = [r for r in rows if r["ids"]]
ge2 = [r for r in searched if r["any"] >= 2]
print(f"searchable rows: {len(searched)} of {len(rows)}"
      f"   ({len(unsearchable)} have prose definitions and cannot be searched)")
print(f"corpus-wide >= 2 witnesses (ANY): {len(ge2)} of {len(searched)}")
print(f"corpus-wide >= 2 witnesses (ALL): "
      f"{len([r for r in searched if r['all'] >= 2])} of {len(searched)}")
print(f"recorded as lane-singletons but corpus-wide >= 2: {len(promoted)}")

print("\n--- PROMOTED: lane-local singleton, but >= 2 witnesses corpus-wide ---")
for r in promoted:
    print(f"   {r['lane']} {r['name'][:30]:<30} {r['rec']} -> {r['any']}"
          f"   {', '.join(r['specs'][:5])}")

print("\n--- STILL UNDER 2 corpus-wide: these genuinely fail condition 1 ---")
for r in still_single:
    print(f"   {r['lane']} {r['name'][:30]:<30} ANY={r['any']}"
          f"   ids={','.join(r['ids'][:3])}   {', '.join(r['specs'][:3])}")

dead_rows = [r for r in searched if r["dead"]]
print(f"\n--- ledger identifiers found NOWHERE in the corpus: "
      f"{sum(len(r['dead']) for r in dead_rows)} across {len(dead_rows)} rows ---")
for r in dead_rows:
    print(f"   {r['lane']} {r['name'][:30]:<30} missing: {', '.join(r['dead'][:4])}")

print("\n--- rows with a prose definition, unsearchable by this method ---")
for r in unsearchable:
    print(f"   {r['lane']} {r['name'][:30]:<30} {r['defn'][:44]}")
