"""Gate 2.2 work-list: which named applications have no spec?

ROADMAP 2.2 has read "The corpus names 72; only 51 have specs" since it was
written, and the 21 have never been enumerated, so the gate has no work-list.
This produces one from `corpus50/lanes/*.json` against the specs on disk.

MATCHING. A first cut normalised by stripping `\bv\d+\b` before removing
punctuation, so "Aave V3" became "aave" while `aave_v3` became "aavev3" -- the
underscore is a word character, so there is no boundary before `v3` and the
version survived on one side only. That scored 48 unspecced and 28 orphan specs,
i.e. it failed to match almost everything. Punctuation is now removed FIRST and
version suffixes after, and a containment pass catches the rest.

Every match made by containment rather than equality is printed, and so is every
name unmatched on either side. A matcher this fiddly must show its work.
"""
import glob
import json
import os
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


ROOT = str(_REPO)
NOISE = ("protocol", "finance", "financial", "labs", "network", "dao",
         "exchange", "markets", "market", "swap", "bridge", "perps",
         "perpetual", "onchain", "the")


def norm(s):
    s = s.split("(")[0]                      # drop parentheticals
    s = s.lower()
    s = re.sub(r"[^a-z0-9]+", "", s)         # punctuation FIRST
    s = re.sub(r"v\d+$", "", s)              # then a trailing version
    for w in NOISE:
        if s.endswith(w) and len(s) > len(w) + 2:
            s = s[: -len(w)]
    return s


# Hand-confirmed aliases. Four orphan specs were the same protocol under a name
# no normaliser will reach -- a digit-leading name, a product suffix, a rebrand
# and a ticker. Listed explicitly rather than by loosening the matcher, which
# would start making matches nobody checked.
ALIASES = {
    "1inch": "oneinch",
    # "GMX V2 Perps" -> the noise-word pass strips "perps", leaving "gmxv2";
    # the trailing-version pass already ran, so the v2 survives. Key on the
    # post-normalisation form, not on what the name looks like.
    "gmxv2": "gmx",
    "eigencloud": "eigenlayer",
    "paypalusd": "pyusd",
}

named = {}
for path in sorted(glob.glob(f"{ROOT}/corpus50/lanes/*.json")):
    lane = json.load(open(path, encoding="utf-8"))
    for cat in lane.get("categories", []):
        cname = cat.get("category") or cat.get("name") or "?"
        for p in cat.get("protocols", []) or []:
            nm = p.get("name") if isinstance(p, dict) else str(p)
            if nm:
                named.setdefault(norm(nm), (nm, cname))

specs = {}
for p in sorted(glob.glob(f"{ROOT}/quint-models/L*/*.qnt")):
    b = os.path.basename(p)[:-4]
    if b != "common":
        specs.setdefault(norm(b), (b, p.split("/")[-2]))
for p in sorted(glob.glob(f"{ROOT}/quint-models-v2/*.qnt")):
    b = os.path.basename(p)[:-4]
    if b not in ("common", "kernel", "sqrt", "sorted"):
        specs.setdefault(norm(b), (b, "v2"))

# containment pass for the survivors
matched, by_contain = {}, []
for k in list(named):
    if k in ALIASES and ALIASES[k] in specs:
        matched[k] = specs[ALIASES[k]]
        by_contain.append((named[k][0], specs[ALIASES[k]][0] + "  [alias]"))
        continue
    if k in specs:
        matched[k] = specs[k]
        continue
    for sk in specs:
        if len(sk) >= 4 and (sk in k or k in sk):
            matched[k] = specs[sk]
            by_contain.append((named[k][0], specs[sk][0]))
            break

unspecced = {k: v for k, v in named.items() if k not in matched}
used = {v[0] for v in matched.values()}
orphan = {k: v for k, v in specs.items() if v[0] not in used}

print(f"named applications : {len(named)}")
print(f"protocol specs     : {len(specs)}")
print(f"matched            : {len(matched)}"
      f"  ({len(by_contain)} by containment)")
print()
print(f"matched by containment rather than equality:")
for a, b in by_contain:
    print(f"   {a[:34]:<34} -> {b}")

print(f"\n{'='*70}\nNAMED BUT UNSPECCED: {len(unspecced)}\n")
print(f"{'application':<40} category")
print("-" * 70)
for k in sorted(unspecced, key=lambda x: (unspecced[x][1], unspecced[x][0])):
    nm, cat = unspecced[k]
    print(f"{nm[:40]:<40} {cat[:28]}")

print(f"\nSPECCED BUT NOT NAMED: {len(orphan)}")
for k in sorted(orphan):
    print(f"   {orphan[k][0]} ({orphan[k][1]})")

print("\n" + "=" * 70)
print(f"ROADMAP 2.2 says 72 named / 51 specced -> 21 unspecced.")
print(f"Measured: {len(named)} named, {len(specs)} specs,"
      f" {len(unspecced)} unspecced, {len(orphan)} orphan.")
