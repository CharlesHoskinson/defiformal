import json
import glob
from pathlib import Path

from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json

ROOT = Path("/root/DefiElements/paper")
GO = ROOT / "graphify-out"
INPUT = str(ROOT / "kg-corpus")

# --- merge chunks -> semantic
chunks = sorted(glob.glob(str(GO / ".graphify_chunk_*.json")))
nodes, edges, hyper = [], [], []
tin = tout = 0
for c in chunks:
    d = json.loads(Path(c).read_text(encoding="utf-8"))
    nodes += d.get("nodes", [])
    edges += d.get("edges", [])
    hyper += d.get("hyperedges", [])
    tin += d.get("input_tokens", 0)
    tout += d.get("output_tokens", 0)

seen = set()
dedup = []
for n in nodes:
    if n["id"] not in seen:
        seen.add(n["id"])
        dedup.append(n)

# drop edges whose endpoints do not resolve (cross-chunk id drift)
ids = {n["id"] for n in dedup}
kept = [e for e in edges if e["source"] in ids and e["target"] in ids]
dropped = len(edges) - len(kept)

extraction = {"nodes": dedup, "edges": kept, "hyperedges": hyper,
              "input_tokens": tin, "output_tokens": tout}
(GO / ".graphify_extract.json").write_text(
    json.dumps(extraction, indent=2, ensure_ascii=False), encoding="utf-8")
print("merged:", len(dedup), "nodes,", len(kept), "edges (dropped", dropped, "dangling)")

detection = json.loads((GO / ".graphify_detect.json").read_text(encoding="utf-8"))

G = build_from_json(extraction, root=INPUT, directed=False)
if G.number_of_nodes() == 0:
    raise SystemExit("ERROR: empty graph")

communities = cluster(G)
cohesion = score_all(G, communities)
gods = god_nodes(G)
surprises = surprising_connections(G, communities)
labels = {cid: "Community " + str(cid) for cid in communities}
questions = suggest_questions(G, communities, labels)
tokens = {"input": tin, "output": tout}

wrote = to_json(G, communities, str(GO / "graph.json"))
print("graph.json written:", wrote)

report = generate(G, communities, cohesion, labels, gods, surprises,
                  detection, tokens, INPUT, suggested_questions=questions)
(GO / "GRAPH_REPORT.md").write_text(report, encoding="utf-8")

analysis = {
    "communities": {str(k): v for k, v in communities.items()},
    "cohesion": {str(k): v for k, v in cohesion.items()},
    "gods": gods,
    "surprises": surprises,
    "questions": questions,
}
(GO / ".graphify_analysis.json").write_text(
    json.dumps(analysis, indent=2, ensure_ascii=False), encoding="utf-8")

print("Graph:", G.number_of_nodes(), "nodes,", G.number_of_edges(),
      "edges,", len(communities), "communities")
print("--- communities (size) ---")
for cid, members in sorted(communities.items(), key=lambda kv: -len(kv[1])):
    print(cid, len(members), [m.split("_")[-1] for m in members[:8]])
