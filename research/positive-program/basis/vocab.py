#!/usr/bin/env python3
"""Enumerate every applied opcode across the corpus IR, split by whether it is
a locally-declared name or an unresolved (builtin) symbol."""
import json, os, collections
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


IR = _os.environ.get("GEN_IR", str(_REPO / "research/positive-program/basis/gen-ir"))
files = sorted(os.listdir(IR))

def walk(e, out):
    if not isinstance(e, dict):
        return
    k = e.get("kind")
    if k == "app":
        out.append(e["opcode"])
        for a in e.get("args", []):
            walk(a, out)
    elif k == "lambda":
        walk(e.get("expr"), out)
    elif k == "let":
        d = e.get("opdef")
        if d: walk(d.get("expr"), out)
        walk(e.get("expr"), out)
    elif k in ("name", "int", "bool", "str"):
        pass
    else:
        for v in e.values():
            if isinstance(v, dict): walk(v, out)
            elif isinstance(v, list):
                for x in v:
                    if isinstance(x, dict): walk(x, out)

declared = collections.defaultdict(set)   # lane -> names declared in common
allops = collections.Counter()
localnames = collections.defaultdict(set) # lane__spec -> declared def names

# pass 1: gather declared names per module file
mods = {}
for fn in files:
    d = json.load(open(os.path.join(IR, fn)))
    key = fn[:-5]
    lane, spec = key.split("__")
    mods[key] = d
    for m in d["modules"]:
        for de in m["declarations"]:
            if de["kind"] in ("def", "var", "const", "assume", "typedef"):
                n = de.get("name")
                if n:
                    if m["name"] == "common":
                        declared[lane].add(n)
                    if m["name"] != "common":
                        localnames[key].add(n)

for lane in sorted(declared):
    print(lane, "common decls:", len(declared[lane]))

# pass 2: opcodes
for key, d in mods.items():
    lane, spec = key.split("__")
    if spec == "common": continue
    for m in d["modules"]:
        if m["name"] == "common": continue
        for de in m["declarations"]:
            if de["kind"] != "def": continue
            ops = []
            walk(de.get("expr"), ops)
            for o in ops:
                allops[o] += 1

known = set()
for lane in declared: known |= declared[lane]
for k in localnames: known |= localnames[k]

print("\n--- opcodes NOT declared anywhere (candidate builtins) ---")
builtins = {o: c for o, c in allops.items() if o not in known}
for o, c in sorted(builtins.items(), key=lambda x: -x[1]):
    print(f"{c:6d}  {o}")
print("\ntotal distinct opcodes:", len(allops), " builtin-ish:", len(builtins))
