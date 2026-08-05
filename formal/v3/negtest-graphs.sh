#!/bin/bash
# verify-graphs.py runs 40 checks and has never been shown to fail. Two checks
# have passed vacuously on this run already, so "it prints VERIFIED" is not
# evidence that it verifies anything.
#
# Three independent perturbations, each restored.
set -uo pipefail
cd /root/defiformal || exit 9

G=expansion/12-prediction/graphify-out/graph.json
M=expansion/graphify-out/GRAPHS.md
D=expansion/graphify-out/domain-graph.json
cp "$G" /root/.neg.g; cp "$M" /root/.neg.m; cp "$D" /root/.neg.d

run () { python3 formal/v3/verify-graphs.py 2>&1 | tail -1; }
report () { case "$2" in *VIOLATED*|*Traceback*|*Error*) echo "  CAUGHT  $1";; *) echo "  MISSED  $1  -> $2";; esac; }

echo "baseline: $(run)"
echo

# 1. drop a node from a lane graph: the sum-of-parts check must notice
python3 - <<'PY'
import io, json
p = "/root/defiformal/expansion/12-prediction/graphify-out/graph.json"
g = json.load(io.open(p, encoding="utf-8"))
g["nodes"] = g["nodes"][:-1]
io.open(p, "w", encoding="utf-8", newline="\n").write(json.dumps(g))
PY
report "a node removed from 12-prediction" "$(run)"
cp /root/.neg.g "$G"

# 2. alter a figure in GRAPHS.md: the document must stop matching the graphs
python3 - <<'PY'
import io
p = "/root/defiformal/expansion/graphify-out/GRAPHS.md"
s = io.open(p, encoding="utf-8").read().replace("777 nodes", "778 nodes", 1)
io.open(p, "w", encoding="utf-8", newline="\n").write(s)
PY
report "merged node count changed in GRAPHS.md" "$(run)"
cp /root/.neg.m "$M"

# 3. break a domain-graph relation: the element-span checks must notice
python3 - <<'PY'
import io, json
p = "/root/defiformal/expansion/graphify-out/domain-graph.json"
g = json.load(io.open(p, encoding="utf-8"))
n = 0
for l in g["links"]:
    if l.get("relation") == "carries" and n < 40:
        l["relation"] = "noop"; n += 1
io.open(p, "w", encoding="utf-8", newline="\n").write(json.dumps(g))
PY
report "40 carries-relations disabled in the domain graph" "$(run)"
cp /root/.neg.d "$D"

echo
echo "restored: $(run)"
rm -f /root/.neg.g /root/.neg.m /root/.neg.d
