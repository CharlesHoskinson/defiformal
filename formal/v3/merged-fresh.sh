#!/bin/bash
# The merged graph is generated from the twelve lane graphs and its freshness was
# never gated. verify-graphs.py checks that its node and link counts equal the
# sums of the parts, which is exactly the check the domain graph passed while
# carrying a dead URL: content can change without counts changing.
#
# Regenerate into place and require byte-equality, restoring on failure so the
# check never leaves the tree worse than it found it.
set -uo pipefail
export PATH=/root/.local/bin:$PATH
cd /root/defiformal || exit 9

M=expansion/graphify-out/merged-graph.json
cp "$M" /root/.merged-check.bak || exit 9

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
  cp /root/.merged-check.bak "$M"
  rm -f /root/.merged-check.bak
  echo "MERGED GRAPH CHECK FAILED: merge-graphs exited $rc"
  exit 1
fi

if cmp -s /root/.merged-check.bak "$M"; then
  rm -f /root/.merged-check.bak
  echo "MERGED GRAPH FRESH"
  exit 0
fi

python3 - <<'PY'
import io, json
a = json.load(io.open("/root/.merged-check.bak", encoding="utf-8"))
b = json.load(io.open("/root/defiformal/expansion/graphify-out/merged-graph.json",
                      encoding="utf-8"))
print("  committed %d nodes / %d links   fresh %d / %d"
      % (len(a["nodes"]), len(a["links"]), len(b["nodes"]), len(b["links"])))
A = {str(n["id"]): n for n in a["nodes"]}
B = {str(n["id"]): n for n in b["nodes"]}
ch = [k for k in A if k in B and A[k] != B[k]]
print("  added %d, removed %d, changed %d"
      % (len(set(B) - set(A)), len(set(A) - set(B)), len(ch)))
for k in ch[:4]:
    print("    " + k)
PY
rm -f /root/.merged-check.bak
echo "MERGED GRAPH STALE"
exit 1
