"""1.1a, second pass: shared-library reuse vs independent re-implementation.

The first pass counted protocol specs referencing each row's ledger identifiers.
`layerzero` refuted the method: it implements once-only delivery with its own
`PacketStatus = Sent | Verified | Delivered` machine keyed by nonce, never
touching `common.canDeliverOnce`/`markUsed`, so identifier search scores it 0
while the ledger correctly counts it as the second witness.

That failure is structural, and it runs the wrong way:

  * identifiers DEFINED IN a lane's `common.qnt` and called by k protocols are
    ONE implementation invoked k times -- WEAK evidence for a primitive;
  * a second protocol re-implementing the mechanism under its own names is the
    STRONGEST evidence a primitive is real, and search cannot see it.

So the method counts the weak evidence and misses the strong. This pass measures
how much of the corpus-wide >= 2 count is shared-library reuse, which is the part
the first pass CAN answer soundly, and which bears directly on how gate 1.1's
condition 1 should be stated.
"""
import glob
import os
import re

ROOT = "/root/DefiElements"
LEDGERS = sorted(glob.glob(f"{ROOT}/research/positive-program/insights/INSIGHT-L*.md"))
SPECS = sorted(glob.glob(f"{ROOT}/quint-models/L*/*.qnt"))
TICKED = re.compile(r"`([^`]+)`")
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
STOPWORDS = {"common", "qnt", "int", "bool", "str", "Set", "List", "Map",
             "type", "val", "def", "action", "pure", "var", "state", "shape"}

src = {p: re.sub(r"//[^\n]*", "", open(p, encoding="utf-8", errors="replace").read())
       for p in SPECS}
protocols = [p for p in SPECS if os.path.basename(p) != "common.qnt"]
commons = [p for p in SPECS if os.path.basename(p) == "common.qnt"]


def defines(path, name):
    return re.search(r"\b(?:pure\s+)?(?:def|val|action|type|var)\s+" +
                     re.escape(name) + r"\b", src[path]) is not None


def parse(path):
    s = open(path, encoding="utf-8", errors="replace").read()
    m = re.search(r"^#+\s*5\..*?$(.*?)(?=^#+\s*6\.)", s, re.M | re.S)
    rows = []
    for line in (m.group(1).splitlines() if m else []):
        line = line.strip()
        if not line.startswith("|") or line.startswith("|---"):
            continue
        c = [x.strip() for x in line.strip("|").split("|")]
        if len(c) < 3 or c[0].lower().startswith("candidate"):
            continue
        rows.append({"lane": re.search(r"(L\d)", path).group(1),
                     "name": c[0].strip("`"), "defn": c[1]})
    return rows


rows = []
for p in LEDGERS:
    rows.extend(parse(p))

print(f"{'lane':<4} {'candidate primitive':<31} {'wit':>4} {'shared':>7} {'indep':>6}  class")
print("-" * 76)
tally = {"shared-only": 0, "independent": 0, "mixed": 0, "under2": 0, "prose": 0}
detail = {"shared-only": [], "independent": [], "mixed": []}
for r in rows:
    ids = []
    for chunk in TICKED.findall(r["defn"]):
        for n in IDENT.findall(chunk):
            if n not in STOPWORDS and len(n) >= 4 and n not in ids:
                ids.append(n)
    if not ids:
        tally["prose"] += 1
        continue
    users, shared_ids, indep_defs = set(), 0, set()
    for n in ids:
        pat = re.compile(r"\b" + re.escape(n) + r"\b")
        hits = {p for p in protocols if pat.search(src[p])}
        users |= hits
        if any(defines(c, n) for c in commons):
            shared_ids += 1
        for p in hits:
            if defines(p, n):
                indep_defs.add(p)
    if len(users) < 2:
        tally["under2"] += 1
        continue
    if shared_ids and not indep_defs:
        cls = "shared-only"
    elif indep_defs and not shared_ids:
        cls = "independent"
    else:
        cls = "mixed"
    tally[cls] += 1
    detail[cls].append((r, len(users), len(indep_defs)))
    print(f"{r['lane']:<4} {r['name'][:31]:<31} {len(users):>4} {shared_ids:>7}"
          f" {len(indep_defs):>6}  {cls}")

print("\n" + "=" * 76)
print("Of the rows reaching >= 2 witnesses by identifier search:")
print(f"  shared-only  {tally['shared-only']:>3}   every identifier lives in a"
      f" lane common.qnt -- ONE implementation, called k times")
print(f"  mixed        {tally['mixed']:>3}")
print(f"  independent  {tally['independent']:>3}   at least one protocol defines"
      f" the mechanism itself")
print(f"  (under 2 witnesses {tally['under2']}, prose definitions {tally['prose']})")

print("\n--- SHARED-ONLY: >= 2 only because a common.qnt definition is reused ---")
for r, u, i in detail["shared-only"]:
    print(f"   {r['lane']} {r['name'][:34]:<34} {u} callers, 0 independent defs")
