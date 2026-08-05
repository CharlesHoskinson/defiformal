import json
from pathlib import Path

GO = Path("/root/DefiElements/research/positive-program/graphify-out")
p = GO / ".graphify_extract.json"
d = json.loads(p.read_text(encoding="utf-8"))

# canonical id -> list of duplicate ids to fold in
MERGES = {
    "consolidated_consolidated_requirements_horizon_sort": [
        "requirements_req_sheaf_theory_horizon_sort",
    ],
}

alias = {}
for canon, dups in MERGES.items():
    for dsrc in dups:
        alias[dsrc] = canon

present = {n["id"] for n in d["nodes"]}
alias = {k: v for k, v in alias.items() if k in present and v in present}
print("merging:", alias)

# fold rationale text from duplicate into canonical
by_id = {n["id"]: n for n in d["nodes"]}
for dsrc, canon in alias.items():
    src_r = by_id[dsrc].get("rationale")
    if src_r:
        cur = by_id[canon].get("rationale") or ""
        by_id[canon]["rationale"] = (cur + " || " + src_r).strip(" |")

d["nodes"] = [n for n in d["nodes"] if n["id"] not in alias]

seen_edge = set()
new_edges = []
for e in d["edges"]:
    e["source"] = alias.get(e["source"], e["source"])
    e["target"] = alias.get(e["target"], e["target"])
    if e["source"] == e["target"]:
        continue
    key = (e["source"], e["target"], e.get("relation"))
    if key in seen_edge:
        continue
    seen_edge.add(key)
    new_edges.append(e)
d["edges"] = new_edges

for h in d.get("hyperedges", []):
    h["nodes"] = sorted({alias.get(n, n) for n in h.get("nodes", [])})

p.write_text(json.dumps(d, indent=2, ensure_ascii=False), encoding="utf-8")
print("after merge:", len(d["nodes"]), "nodes,", len(d["edges"]), "edges")
