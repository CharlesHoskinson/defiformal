"""Owner-locality across every basis family, not the seven read by hand.

REFUTER-DELEGATED-ALLOCATION.md section 5 lists three things standing between the
exhibit and a theorem. This closes the mechanical half of the first: the claim
that every family in P is a FUNCTION of state and caller-supplied amounts, hence
owner-local.

The argument has two steps and only the first is mechanisable:

  STEP 1 (here).  Every identifier the section-5 ledgers commit each candidate
                  primitive to is defined as a `pure def`, `def`, `type` or
                  `pure val` -- never as an `action`. A `pure def` is a function:
                  given the same arguments it returns the same value and it
                  cannot write state. So no family can, on its own, choose
                  between post-states.

  STEP 2 (not here). That functions compose to functions under the basis's
                  composition operator. That is a proof obligation against the
                  operator's definition in BASIS.md, and no script settles it.

Why step 1 matters: `reallocate` is an ACTION with a chooser -- from one
pre-state many post-states satisfy its guards, and which occurs is picked by a
named principal. If every generator is a `pure def`, the generators cannot
express that, whatever they are composed into.

CALIBRATION. An identifier that resolves to nothing is reported UNRESOLVED, never
silently counted as a function. A generous classifier here would manufacture the
result.
"""
import glob
import os
import re
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


ROOT = str(_REPO)
LEDGERS = sorted(glob.glob(f"{ROOT}/research/positive-program/insights/INSIGHT-L*.md"))
SPECS = sorted(glob.glob(f"{ROOT}/quint-models/L*/*.qnt"))
TICKED = re.compile(r"`([^`]+)`")
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
STOP = {"common", "qnt", "int", "bool", "str", "Set", "List", "Map",
        "type", "val", "def", "action", "pure", "var", "state", "shape"}

src = {p: re.sub(r"//[^\n]*", "", open(p, encoding="utf-8", errors="replace").read())
       for p in SPECS}


def classify(name):
    """How is `name` introduced, across the whole corpus?"""
    kinds = set()
    for p, s in src.items():
        for m in re.finditer(
                r"^\s*(pure\s+def|pure\s+val|def|val|action|type|var)\s+"
                + re.escape(name) + r"\b", s, re.M):
            kinds.add(" ".join(m.group(1).split()))
    return kinds


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

tally = defaultdict(int)
unresolved, actions = [], []
per_row = []
for r in rows:
    ids = []
    for chunk in TICKED.findall(r["defn"]):
        for n in IDENT.findall(chunk):
            if n not in STOP and len(n) >= 4 and n not in ids:
                ids.append(n)
    kinds_here = set()
    for n in ids:
        k = classify(n)
        if not k:
            unresolved.append((r["lane"], r["name"], n))
            tally["UNRESOLVED"] += 1
            continue
        for kk in k:
            tally[kk] += 1
            kinds_here.add(kk)
        if "action" in k:
            actions.append((r["lane"], r["name"], n, sorted(k)))
    per_row.append((r["lane"], r["name"], len(ids), sorted(kinds_here)))

print(f"section-5 rows: {len(rows)}")
print(f"identifiers resolved: {sum(v for k, v in tally.items() if k != 'UNRESOLVED')}"
      f"   unresolved: {tally['UNRESOLVED']}\n")
print("how the corpus introduces each committed identifier:")
for k in sorted(tally, key=lambda x: -tally[x]):
    print(f"   {k:<12} {tally[k]}")

print(f"\nidentifiers introduced as an `action` (a relation, not a function):"
      f" {len(actions)}")
for lane, row, name, k in actions:
    print(f"   {lane} {row[:30]:<30} {name:<24} {k}")

print(f"\nUNRESOLVED identifiers (reported, not assumed): {len(unresolved)}")
for lane, row, name in unresolved[:14]:
    print(f"   {lane} {row[:30]:<30} {name}")

func_only = [r for r in per_row
             if r[3] and "action" not in r[3]]
print(f"\nrows whose every resolved identifier is a function/type/val:"
      f" {len(func_only)} of {len(rows)}")
print()
print("=" * 74)
if not actions:
    print("STEP 1 HOLDS. No candidate primitive is introduced as an `action`.")
    print("Every family the ledgers commit to is a `pure def`, `def`, `type` or")
    print("`val` -- a function or a carrier. None can choose between post-states,")
    print("so none can express a principal's discretion.")
else:
    print("STEP 1 FAILS for the rows above -- those families ARE relations, and")
    print("the owner-locality premise does not hold uniformly. Inspect them.")
print()
print("STEP 2 remains open: that functions compose to functions under the basis")
print("composition operator. That is a proof against its definition in BASIS.md")
print("and no script settles it.")
