#!/bin/bash
# domain-graph.json is generated from the specs and verdicts, and nothing
# checked that the committed copy matched what the generator produces. It did
# not: after the Pendle citation was repathed, the graph kept the dead URL for
# two commits.
#
# Regenerate and compare canonicalised JSON -- sensitive to content, immune to
# serialiser formatting -- then always restore the committed file, so a check
# that only reports never leaves the tree dirty. See merged-fresh.sh for why
# both of those matter.
set -uo pipefail
# Resolved from this script's own location; see merged-fresh.sh.
cd "$(dirname "$0")/../.." || exit 3
[ -f formal/v3/domain-fresh.sh ] || { echo "DOMAIN GRAPH CHECK BLOCKED: not the repository root"; exit 3; }

G=expansion/graphify-out/domain-graph.json
[ -f "$G" ] || { echo "DOMAIN GRAPH CHECK BLOCKED: $G absent"; exit 3; }
BAK=$(mktemp) || exit 3
trap 'cp "$BAK" "$G" 2>/dev/null; rm -f "$BAK"' EXIT
cp "$G" "$BAK" || exit 3

node formal/v3/domain-graph.mjs > /dev/null 2>&1
rc=$?
if [ $rc -ne 0 ]; then
  echo "DOMAIN GRAPH CHECK BLOCKED: domain-graph.mjs exited $rc (nothing measured)"
  exit 3
fi

python3 - "$BAK" "$G" <<'PY'
import io, json, sys
def canon(p):
    return json.dumps(json.load(io.open(p, encoding="utf-8")),
                      sort_keys=True, separators=(",", ":"))
a = json.load(io.open(sys.argv[1], encoding="utf-8"))
b = json.load(io.open(sys.argv[2], encoding="utf-8"))
if canon(sys.argv[1]) == canon(sys.argv[2]):
    print("DOMAIN GRAPH FRESH (%d nodes / %d links, canonical compare)"
          % (len(a["nodes"]), len(a["links"])))
    sys.exit(0)
print("DOMAIN GRAPH STALE - the committed copy differs from the generator output")
A = {str(n["id"]): n for n in a["nodes"]}
B = {str(n["id"]): n for n in b["nodes"]}
ch = [k for k in A if k in B and A[k] != B[k]]
print("  nodes %d -> %d, links %d -> %d" % (len(a["nodes"]), len(b["nodes"]),
                                            len(a["links"]), len(b["links"])))
print("  nodes with changed fields: %d" % len(ch))
for k in ch[:5]:
    print("    " + k)
sys.exit(1)
PY
exit $?
