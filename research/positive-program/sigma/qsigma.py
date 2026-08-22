"""Test the Q/Sigma invariant claimed by BASIS.md:

  "no Q-sorted state variable is ever assigned a value that isn't an arithmetic
   term over prior Qs"

The claim is circular if Q is defined by it, so we make it testable:

  EXOGENOUS assignment := the right-hand side of  x' = ...  mentions a formal
  parameter of the enclosing action (a value entering from outside the machine).
  ENDOGENOUS assignment := RHS is built only from state vars, consts and literals.

  Sigma := state vars with >=1 exogenous assignment
  Q     := state vars with 0 exogenous assignments

Then report whether the partition is non-trivial and whether it lines up with the
semantic reading (balances/supplies are Q; prices/rates/flags are Sigma).
"""
import glob
import re
import json
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


SPECS = sorted(glob.glob(str(_REPO / "quint-models/L*/*.qnt")))
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")

rows = []
for path in SPECS:
    lane, spec = path.split("/")[-2], path.split("/")[-1]
    src = open(path, encoding="utf-8", errors="replace").read()
    src = re.sub(r"//[^\n]*", "", src)          # strip comments

    varnames = set(re.findall(r"^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)", src, re.M))
    if not varnames:
        continue

    # action/def headers with their formal parameters, and their source span
    heads = list(re.finditer(
        r"^\s*(?:pure\s+)?(action|def)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(\(([^)]*)\))?",
        src, re.M))
    spans = []
    for i, h in enumerate(heads):
        start = h.end()
        end = heads[i + 1].start() if i + 1 < len(heads) else len(src)
        params = set()
        if h.group(4):
            for p in h.group(4).split(","):
                nm = p.split(":")[0].strip()
                if nm:
                    params.add(nm)
        spans.append((start, end, h.group(2), params))

    # nondet-bound names inside a body are also exogenous entries
    for start, end, aname, params in spans:
        body = src[start:end]
        params = params | set(re.findall(r"nondet\s+([A-Za-z_][A-Za-z0-9_]*)", body))
        for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)'\s*=", body):
            v = m.group(1)
            if v not in varnames:
                continue
            rhs = body[m.end():]
            depth = 0
            cut = len(rhs)
            for i, ch in enumerate(rhs):
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
            rhs = rhs[:cut]
            ids = set(IDENT.findall(rhs))
            exo = sorted(ids & params)
            rows.append({"lane": lane, "spec": spec, "action": aname,
                         "var": v, "exogenous": bool(exo), "via": exo})

by_var = defaultdict(lambda: {"n": 0, "exo": 0, "params": set()})
for r in rows:
    k = (r["lane"], r["spec"], r["var"])
    by_var[k]["n"] += 1
    if r["exogenous"]:
        by_var[k]["exo"] += 1
        by_var[k]["params"].update(r["via"])

Q = [k for k, v in by_var.items() if v["exo"] == 0]
S = [k for k, v in by_var.items() if v["exo"] > 0]

print(f"specs with state: {len({(r['lane'], r['spec']) for r in rows})}")
print(f"assignments analysed: {len(rows)}")
print(f"distinct state variables assigned: {len(by_var)}")
print(f"  Q  (never exogenously assigned): {len(Q)}")
print(f"  Sigma (exogenously assigned >=1): {len(S)}")
frac = len(S) / len(by_var) if by_var else 0
print(f"  partition non-trivial: {0 < len(S) < len(by_var)}   Sigma fraction {frac:.3f}")

def bucket(name):
    n = name.lower()
    if any(w in n for w in ("price", "rate", "index", "oracle", "nav", "amp", "time",
                            "epoch", "block", "phase", "paused", "frozen", "mode")):
        return "price/rate/phase"
    if any(w in n for w in ("bal", "supply", "total", "coll", "debt", "share",
                            "reserve", "deposit", "liquid", "pool", "fund")):
        return "balance/supply"
    return "other"

print("\n--- does the split match the semantic reading? ---")
tab = defaultdict(lambda: [0, 0])
for k, v in by_var.items():
    tab[bucket(k[2])][0 if v["exo"] == 0 else 1] += 1
print(f"{'category':<20} {'Q':>5} {'Sigma':>7}")
for cat in ("balance/supply", "price/rate/phase", "other"):
    q, s = tab[cat]
    print(f"{cat:<20} {q:>5} {s:>7}")

print("\n--- counterexamples: balance/supply vars assigned exogenously ---")
bad = [(k, v) for k, v in by_var.items()
       if v["exo"] > 0 and bucket(k[2]) == "balance/supply"]
for k, v in sorted(bad)[:15]:
    print(f"   {k[0]}/{k[1]}:{k[2]}  exo={v['exo']}/{v['n']} via {sorted(v['params'])[:4]}")
print(f"   total: {len(bad)}")

json.dump({"rows": rows,
           "Q": [list(k) for k in Q],
           "Sigma": [list(k) for k in S]},
          open(str(_REPO / "research/positive-program/sigma/qsigma.json"), "w"),
          indent=2)
print("\nwritten: sigma/qsigma.json")
