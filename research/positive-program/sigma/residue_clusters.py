"""Are the two biggest terms in the unclassified residue real clusters?

Term frequency over the 131 unclassified entries has no dominant term -- the top
is "price" at 12 of 131 (9%). That is consistent with a long tail of
protocol-specific mechanisms rather than a missed structural class. Before
concluding that, the two largest candidates are read in full: price/oracle (20
entries between them) and claim (11).

A cluster is only real if the entries name the SAME mechanism. Entries that
merely share a word are a long tail wearing a shared vocabulary.
"""
import json
import re
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


P = str(_REPO / "research/positive-program/sigma/residue-index.json")
rows = [r for r in json.load(open(P, encoding="utf-8"))
        if r["bucket"] == "UNCLASSIFIED"]


def show(label, pat):
    hit = [r for r in rows if re.search(pat, r["residue"], re.I)]
    print("=" * 74)
    print(f"{label}: {len(hit)} entries, "
          f"{len({r['protocol'] for r in hit})} applications")
    print("=" * 74)
    for r in hit:
        t = " ".join(r["residue"].split())
        first = re.split(r"(?<=[.;:])\s", t)[0]
        print(f"  {r['protocol'][:26]:<26} {first[:132]}")
    print()


show("PRICE / ORACLE", r"\b(price|oracle)\b")
show("CLAIM", r"\bclaim\b")
