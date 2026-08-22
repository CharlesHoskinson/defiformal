"""Corrected test of the Q/Sigma invariant from BASIS.md.

First operationalisation (qsigma.py) was wrong: it flagged
`totalSupply' = totalSupply + amount` as exogenous because `amount` is a
parameter. But that is an *arithmetic update* — the claim allows it.

The distinction BASIS.md actually draws is REPLACEMENT vs UPDATE:

  REPLACEMENT : x' = e   where x does NOT occur in e   (prior value discarded)
  UPDATE      : x' = e   where x DOES occur in e       (prior value participates)

  Q     := state vars that are NEVER replaced (every assignment is an update,
           or a structural re-put of the same map)
  Sigma := state vars replaced at least once

Claim under test: the Q/Sigma partition is non-trivial AND balances/supplies
land in Q while prices/rates/phases land in Sigma.
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
# assignments that are structurally "same container, one entry changed"
CONTAINER = re.compile(r"\.(put|set|append|tail|head|replaceAt)\s*\(")

rows = []
for path in SPECS:
    lane, spec = path.split("/")[-2], path.split("/")[-1]
    src = open(path, encoding="utf-8", errors="replace").read()
    src = re.sub(r"//[^\n]*", "", src)
    varnames = set(re.findall(r"^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)", src, re.M))
    if not varnames:
        continue
    for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)'\s*=", src):
        v = m.group(1)
        if v not in varnames:
            continue
        rhs = src[m.end():]
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
        rhs = rhs[:cut].strip()
        mentions_self = v in set(IDENT.findall(rhs))
        container = bool(CONTAINER.search(rhs))
        rows.append({"lane": lane, "spec": spec, "var": v,
                     "replacement": not mentions_self and not container,
                     "rhs": rhs[:70]})

by_var = defaultdict(lambda: {"n": 0, "repl": 0, "ex": []})
for r in rows:
    k = (r["lane"], r["spec"], r["var"])
    by_var[k]["n"] += 1
    if r["replacement"]:
        by_var[k]["repl"] += 1
        if len(by_var[k]["ex"]) < 2:
            by_var[k]["ex"].append(r["rhs"])

Q = {k for k, v in by_var.items() if v["repl"] == 0}
S = {k for k, v in by_var.items() if v["repl"] > 0}
print(f"assignments analysed: {len(rows)}")
print(f"distinct state variables: {len(by_var)}")
print(f"  Q     (never replaced): {len(Q)}")
print(f"  Sigma (replaced >=1):   {len(S)}")
print(f"  partition non-trivial:  {0 < len(S) < len(by_var)}"
      f"   Sigma fraction {len(S)/len(by_var):.3f}")

def bucket(name):
    n = name.lower()
    if any(w in n for w in ("price", "rate", "index", "oracle", "nav", "amp",
                            "time", "epoch", "block", "phase", "paused",
                            "frozen", "mode", "status", "enabled", "active")):
        return "price/rate/phase"
    if any(w in n for w in ("bal", "supply", "total", "coll", "debt", "share",
                            "reserve", "deposit", "liquid", "pool", "fund",
                            "asset", "locked", "staked")):
        return "balance/supply"
    return "other"

tab = defaultdict(lambda: [0, 0])
for k, v in by_var.items():
    tab[bucket(k[2])][0 if v["repl"] == 0 else 1] += 1
print(f"\n{'category':<20} {'Q':>5} {'Sigma':>7}  {'% in Q':>7}")
for cat in ("balance/supply", "price/rate/phase", "other"):
    q, s = tab[cat]
    pct = 100 * q / (q + s) if (q + s) else 0
    print(f"{cat:<20} {q:>5} {s:>7}  {pct:>6.1f}%")

viol = sorted((k, v) for k, v in by_var.items()
              if v["repl"] > 0 and bucket(k[2]) == "balance/supply")
print(f"\n--- balance/supply variables that ARE replaced: {len(viol)} ---")
for k, v in viol[:12]:
    print(f"   {k[0]}/{k[1]}:{k[2]}  {v['repl']}/{v['n']}   e.g. {v['ex'][0][:56]}")

json.dump({"Q": sorted(list(k) for k in Q), "Sigma": sorted(list(k) for k in S)},
          open(str(_REPO / "research/positive-program/sigma/qsigma3.json"), "w"),
          indent=2)
print("\nwritten: sigma/qsigma3.json")
