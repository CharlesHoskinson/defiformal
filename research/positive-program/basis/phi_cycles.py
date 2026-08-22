"""Which Phi carriers actually cycle?

BASIS.md P4.2 asserts "R_Phi is the acyclic status DAG". P4.3 is conditional --
"WHEN R_X is acyclic the sequence of writes is a chain" -- and P4.4 admits
(x,x) in R_X, which a DAG has no room for. So acyclicity reads as a description of
the status-machine instances the author sampled rather than a law.

This measures it: across the 51 protocol specs, which finite protocol-written
carriers are driven BOTH ways, i.e. cycle, and which only ever advance.

A carrier cycles if the corpus assigns it a value it has previously left -- for
booleans, both `true` and `false`; for a map, `.put(k,true)` and `.put(k,false)`.
Reported with the assignment sites so each can be checked.
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


ROOT = str(_REPO / "quint-models")
TRUE = re.compile(r"\btrue\b")
FALSE = re.compile(r"\bfalse\b")


def rhs_of(text, at):
    tail = text[at:]
    depth = 0
    cut = len(tail)
    for i, ch in enumerate(tail):
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            if depth == 0:
                cut = i
                break
            depth -= 1
        elif ch == "," and depth == 0:
            cut = i
            break
    return tail[:cut].strip()


cyclic, monotone = defaultdict(list), defaultdict(list)
for path in sorted(glob.glob(ROOT + "/L*/*.qnt")):
    spec = os.path.basename(path)[:-4]
    lane = path.split("/")[-2]
    if spec == "common":
        continue
    src = re.sub(r"//[^\n]*", "", open(path, encoding="utf-8", errors="replace").read())
    boolvars = set(re.findall(r"^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*bool", src, re.M))
    boolmaps = set(re.findall(
        r"^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*[A-Za-z_][A-Za-z0-9_]*\s*->\s*bool",
        src, re.M))
    for v in sorted(boolvars | boolmaps):
        t = f = 0
        for m in re.finditer(re.escape(v) + r"'\s*=", src):
            r = rhs_of(src, m.end())
            if r == v:
                continue           # a frame no-op, not a write
            if TRUE.search(r):
                t += 1
            if FALSE.search(r):
                f += 1
        key = f"{lane}/{spec}.{v}"
        if t and f:
            cyclic[key] = (t, f)
        elif t or f:
            monotone[key] = (t, f)

print(f"finite protocol-written boolean carriers driven BOTH ways (CYCLIC): "
      f"{len(cyclic)}")
for k, (t, f) in sorted(cyclic.items()):
    print(f"   {k:<40} true x{t}  false x{f}")
print(f"\ndriven one way only (monotone, consistent with an acyclic R_Phi): "
      f"{len(monotone)}")
for k, (t, f) in sorted(monotone.items())[:14]:
    print(f"   {k:<40} true x{t}  false x{f}")
if len(monotone) > 14:
    print(f"   ... and {len(monotone)-14} more")
print(f"\nspecs containing at least one cyclic Phi carrier: "
      f"{len({k.split('.')[0] for k in cyclic})}")
