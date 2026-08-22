import json
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

extraction = json.loads((GO / ".graphify_extract.json").read_text(encoding="utf-8"))
detection = json.loads((GO / ".graphify_detect.json").read_text(encoding="utf-8"))

G = build_from_json(extraction, root=INPUT, directed=False)
communities = cluster(G)
cohesion = score_all(G, communities)
gods = god_nodes(G)
surprises = surprising_connections(G, communities)
labels = {cid: "Community " + str(cid) for cid in communities}
questions = suggest_questions(G, communities, labels)

# force-overwrite: merge legitimately shrinks the graph by 1 node
to_json(G, communities, str(GO / "graph.json.new"))
Path(GO / "graph.json.new").replace(GO / "graph.json")

report = generate(G, communities, cohesion, labels, gods, surprises,
                  detection, {"input": 0, "output": 0}, INPUT,
                  suggested_questions=questions)
(GO / "GRAPH_REPORT.md").write_text(report, encoding="utf-8")

print("Graph:", G.number_of_nodes(), "nodes,", G.number_of_edges(),
      "edges,", len(communities), "communities")
print()
print("--- top god nodes ---")
for g in gods[:10]:
    print("  {:<3} {}".format(g["degree"], g["label"]))
print()
print("--- communities (size, sample) ---")
for cid, members in sorted(communities.items(), key=lambda kv: -len(kv[1]))[:12]:
    lbls = []
    for m in members[:5]:
        for n in extraction["nodes"]:
            if n["id"] == m:
                lbls.append(n["label"][:38])
                break
    print("  c{:<3} n={:<4} {}".format(cid, len(members), " | ".join(lbls)))
