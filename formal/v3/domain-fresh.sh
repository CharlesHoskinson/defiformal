#!/bin/bash
# domain-graph.json is generated from the specs and verdicts, and nothing
# checked that the committed copy matched what the generator produces. It did
# not: after the Pendle citation was repathed, the graph kept the dead URL for
# two commits.
#
# Regenerate into a scratch copy and require byte-equality. A generated artefact
# that is not regenerated is a stale artefact, whatever its node count says.
set -uo pipefail
cd /root/defiformal || exit 9

G=expansion/graphify-out/domain-graph.json
cp "$G" /root/.domain-check.bak || exit 9

node formal/v3/domain-graph.mjs > /dev/null 2>&1
rc=$?
if [ $rc -ne 0 ]; then
  cp /root/.domain-check.bak "$G"
  echo "FAIL domain-graph.mjs exited $rc"
  exit 1
fi

if cmp -s /root/.domain-check.bak "$G"; then
  echo "DOMAIN GRAPH FRESH"
  rm -f /root/.domain-check.bak
  exit 0
fi

echo "DOMAIN GRAPH STALE - the committed copy differs from the generator output"
python3 - <<'PY'
import io, json
a = json.load(io.open("/root/.domain-check.bak", encoding="utf-8"))
b = json.load(io.open("/root/defiformal/expansion/graphify-out/domain-graph.json", encoding="utf-8"))
A = {str(n["id"]): n for n in a["nodes"]}
B = {str(n["id"]): n for n in b["nodes"]}
ch = [k for k in A if k in B and A[k] != B[k]]
print("  nodes %d -> %d, links %d -> %d" % (len(a["nodes"]), len(b["nodes"]),
                                            len(a["links"]), len(b["links"])))
print("  nodes with changed fields: %d" % len(ch))
for k in ch[:5]:
    print("    " + k)
PY
rm -f /root/.domain-check.bak
exit 1
