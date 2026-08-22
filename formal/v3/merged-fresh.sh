#!/bin/bash
# The merged graph is generated from the twelve lane graphs and its freshness was
# never gated. verify-graphs.py checks that its node and link counts equal the
# sums of the parts, which is exactly the check the domain graph passed while
# carrying a dead URL: content can change without counts changing.
#
# Two defects were only visible once the check could run at all:
#
#   1. It compared bytes. graphify's serialiser formats differently across
#      versions, so a tree with identical content -- 777 nodes, 684 links, zero
#      added, removed or changed -- reported STALE. Compare canonicalised JSON
#      instead: still sensitive to content, immune to whitespace and key order.
#   2. It regenerated INTO PLACE and restored only when the generator failed, so
#      a passing run left the repository dirty and tripped gate.sh's own
#      cleanliness assertion. A read-only check must leave no trace: regenerate
#      into scratch and always put the committed file back.
set -uo pipefail
export PATH="$HOME/.local/bin:$PATH"
# Resolved from this script's own location. A `cd` to a hardcoded root that does
# not exist here is how this check spent its life reporting BLOCKED.
cd "$(dirname "$0")/../.." || exit 3
[ -f formal/v3/merged-fresh.sh ] || { echo "MERGED GRAPH CHECK BLOCKED: not the repository root"; exit 3; }

M=expansion/graphify-out/merged-graph.json
[ -f "$M" ] || { echo "MERGED GRAPH CHECK BLOCKED: $M absent"; exit 3; }
BAK=$(mktemp) || exit 3
# Always restore: this check reports, it does not mutate the tree.
trap 'cp "$BAK" "$M" 2>/dev/null; rm -f "$BAK"' EXIT
cp "$M" "$BAK" || exit 3

graphify merge-graphs \
  expansion/01-spot-exchange/graphify-out/graph.json \
  expansion/02-lending/graphify-out/graph.json \
  expansion/03-cdp-stablecoins/graphify-out/graph.json \
  expansion/04-liquid-staking/graphify-out/graph.json \
  expansion/05-perpetuals/graphify-out/graph.json \
  expansion/06-yield-vaults/graphify-out/graph.json \
  expansion/07-bridges/graphify-out/graph.json \
  expansion/08-intents/graphify-out/graph.json \
  expansion/09-rwa/graphify-out/graph.json \
  expansion/10-options/graphify-out/graph.json \
  expansion/11-fiat-stablecoins/graphify-out/graph.json \
  expansion/12-prediction/graphify-out/graph.json \
  --out "$M" > /dev/null 2>&1
rc=$?
if [ $rc -ne 0 ]; then
  echo "MERGED GRAPH CHECK BLOCKED: merge-graphs exited $rc (nothing measured)"
  exit 3
fi

python3 - "$BAK" "$M" <<'PY'
import io, json, sys
def canon(p):
    return json.dumps(json.load(io.open(p, encoding="utf-8")),
                      sort_keys=True, separators=(",", ":"))
a_raw = json.load(io.open(sys.argv[1], encoding="utf-8"))
b_raw = json.load(io.open(sys.argv[2], encoding="utf-8"))
if canon(sys.argv[1]) == canon(sys.argv[2]):
    print("MERGED GRAPH FRESH (%d nodes / %d links, canonical compare)"
          % (len(a_raw["nodes"]), len(a_raw["links"])))
    sys.exit(0)
print("  committed %d nodes / %d links   fresh %d / %d"
      % (len(a_raw["nodes"]), len(a_raw["links"]), len(b_raw["nodes"]), len(b_raw["links"])))
A = {str(n["id"]): n for n in a_raw["nodes"]}
B = {str(n["id"]): n for n in b_raw["nodes"]}
ch = [k for k in A if k in B and A[k] != B[k]]
print("  added %d, removed %d, changed %d"
      % (len(set(B) - set(A)), len(set(A) - set(B)), len(ch)))
for k in ch[:4]:
    print("    " + k)
print("MERGED GRAPH STALE")
sys.exit(1)
PY
exit $?
