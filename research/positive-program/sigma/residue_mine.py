"""Mine the `residue` fields across all named applications.

The lane JSONs record, per protocol, what the 58-symbol vocabulary could not
name. That was filed as a post-mortem on the vocabulary. Three of this session's
results turned out to be sitting in it verbatim (the curator refuter, the
owner/curator/allocator role split, keeper-liveness), so it is worth reading as a
source of basis candidates and refuters instead.

Output is a data file (`sigma/residue-index.json`) plus counts. Classification is
keyword-based and therefore crude; every bucket assignment is written to the JSON
so it can be checked, and the UNCLASSIFIED bucket is reported rather than hidden.
"""
import glob
import json
import re

ROOT = "/root/DefiElements"

# Buckets. Ordered: first match wins, so put the specific before the general.
BUCKETS = [
    ("authority/discretion", r"\b(curator|discretion|discretionary|mandate|"
                             r"delegat\w+|role|permission\w*|authori[sz]\w+|"
                             r"who may|governance|admin|owner|operator|"
                             r"fiduciar\w+|accountab\w+)\b"),
    ("liveness/keeper", r"\b(keeper|automation|bot|off-chain agent|must call|"
                        r"liveness|alive|stops|drifts|maintain themselves|"
                        r"crank|rebalanc\w+ (?:is )?trigger)\b"),
    ("off-chain/legal", r"\b(off-chain|offchain|legal|bankruptc\w+|obligor|"
                        r"recourse|custod\w+|register of record|enforceab\w+|"
                        r"attestation|auditor|jurisdiction|KYC|transfer agent)\b"),
    ("rate/price-of-credit", r"\b(rate|utilization|utilisation|stability fee|"
                             r"interest curve|price of credit|APR|APY)\b"),
    ("scoping/inheritance", r"\b(scope|scoped|inherit\w*|module|per-pool|"
                            r"per-market|subset|consumes|dependency)\b"),
    ("strategy/policy", r"\b(strateg\w+|policy|allocation policy|target LTV|"
                        r"loop|leverage|rebalanc\w+)\b"),
    ("risk-budget/cap", r"\b(supply cap|risk budget|cap\b|limit|exposure)\b"),
    ("settlement/matching", r"\b(matching|order book|clearing|auction|"
                            r"novation|counterparty|settlement)\b"),
]

rows = []
for path in sorted(glob.glob(f"{ROOT}/corpus50/lanes/*.json")):
    lane = json.load(open(path, encoding="utf-8"))
    lname = lane.get("lane") or path.split("/")[-1]
    for cat in lane.get("categories", []):
        cname = cat.get("category") or "?"
        for p in cat.get("protocols", []) or []:
            if not isinstance(p, dict):
                continue
            nm = p.get("name", "?")
            for r in p.get("residue", []) or []:
                if not isinstance(r, str):
                    continue
                bucket = "UNCLASSIFIED"
                for bname, pat in BUCKETS:
                    if re.search(pat, r, re.I):
                        bucket = bname
                        break
                rows.append({"lane": lname, "category": cname, "protocol": nm,
                             "bucket": bucket, "residue": r})

print(f"residue entries across all applications: {len(rows)}")
print(f"applications contributing at least one : "
      f"{len({r['protocol'] for r in rows})}\n")

counts = {}
for r in rows:
    counts[r["bucket"]] = counts.get(r["bucket"], 0) + 1
print(f"{'bucket':<24} {'n':>4}  {'apps':>5}")
print("-" * 40)
for b, n in sorted(counts.items(), key=lambda x: -x[1]):
    apps = len({r["protocol"] for r in rows if r["bucket"] == b})
    print(f"{b:<24} {n:>4}  {apps:>5}")

top = "authority/discretion"
print(f"\n--- {top}: the bucket the refuter and 6h came from ---")
seen = set()
for r in rows:
    if r["bucket"] != top or r["protocol"] in seen:
        continue
    seen.add(r["protocol"])
    txt = " ".join(r["residue"].split())
    print(f"\n  {r['protocol'][:44]}  [{r['category'][:24]}]")
    print(f"    {txt[:200]}")
    if len(seen) >= 12:
        break

print(f"\n--- liveness/keeper: pair 4's autonomy law ---")
seen = set()
for r in rows:
    if r["bucket"] != "liveness/keeper" or r["protocol"] in seen:
        continue
    seen.add(r["protocol"])
    txt = " ".join(r["residue"].split())
    print(f"  {r['protocol'][:40]:<40} {txt[:110]}")

with open(f"{ROOT}/research/positive-program/sigma/residue-index.json", "w",
          encoding="utf-8") as fh:
    json.dump(rows, fh, indent=1)
print(f"\nwritten: sigma/residue-index.json ({len(rows)} entries)")
