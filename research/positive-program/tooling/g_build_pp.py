import json
import glob
from pathlib import Path
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


from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json

ROOT = Path(str(_REPO / "research/positive-program"))
GO = ROOT / "graphify-out"
INPUT = str(ROOT)

chunks = sorted(glob.glob(str(GO / ".graphify_chunk_*.json")))
nodes, edges, hyper = [], [], []
for c in chunks:
    d = json.loads(Path(c).read_text(encoding="utf-8"))
    nodes += d.get("nodes", [])
    edges += d.get("edges", [])
    hyper += d.get("hyperedges", [])

seen = set()
dedup = []
for n in nodes:
    if n["id"] not in seen:
        seen.add(n["id"])
        dedup.append(n)

ids = {n["id"] for n in dedup}
kept = [e for e in edges if e["source"] in ids and e["target"] in ids]
print("chunks:", len(chunks))
print("nodes:", len(nodes), "-> dedup", len(dedup))
print("edges:", len(edges), "-> kept", len(kept), "(dropped", len(edges) - len(kept), "dangling)")

# cross-chunk join quality: how many edges span two different source files
extraction = {"nodes": dedup, "edges": kept, "hyperedges": hyper,
              "input_tokens": 0, "output_tokens": 0}
(GO / ".graphify_extract.json").write_text(
    json.dumps(extraction, indent=2, ensure_ascii=False), encoding="utf-8")

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

wrote = to_json(G, communities, str(GO / "graph.json"))
print("graph.json written:", wrote)

report = generate(G, communities, cohesion, labels, gods, surprises,
                  detection, {"input": 0, "output": 0}, INPUT,
                  suggested_questions=questions)
(GO / "GRAPH_REPORT.md").write_text(report, encoding="utf-8")

print("Graph:", G.number_of_nodes(), "nodes,", G.number_of_edges(),
      "edges,", len(communities), "communities")
print("--- top god nodes ---")
for g in gods[:12]:
    print("  ", g)
