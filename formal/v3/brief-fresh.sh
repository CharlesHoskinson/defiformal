#!/bin/bash
# SECTION-BRIEF.md is the stated input for writing a paper section, and nothing
# checked that the committed briefs still match their generator. Three of twelve
# did not: 07-bridges still showed At discharging BTCB, Coinbase and WBTC after
# council finding 5 withdrew it, which would have reintroduced retracted claims
# into any section regenerated from it.
#
# Regenerate all twelve and require equality, then put the committed briefs back:
# the generator writes into the tree, so without the restore a stale brief left
# the repository dirty and tripped gate.sh's cleanliness assertion.
set -uo pipefail
# Resolved from this script's own location; see merged-fresh.sh.
cd "$(dirname "$0")/../.." || exit 3
[ -f formal/v3/brief-fresh.sh ] || { echo "SECTION BRIEFS BLOCKED: not the repository root"; exit 3; }
ROOT=$(pwd)

B=$(mktemp -d) || exit 3
restore () {
  for f in "$B"/*.md; do
    [ -e "$f" ] || continue
    s=$(basename "$f" .md)
    cp "$f" "$ROOT/expansion/$s/SECTION-BRIEF.md" 2>/dev/null
  done
  rm -rf "$B"
}
trap restore EXIT

for d in expansion/*/; do
  s=$(basename "$d")
  [ -f "$d/SECTION-BRIEF.md" ] && cp "$d/SECTION-BRIEF.md" "$B/$s.md"
done
n=$(ls "$B" | wc -l)
[ "$n" -gt 0 ] || { echo "SECTION BRIEFS BLOCKED: no briefs found"; exit 3; }

node formal/v3/section-brief.mjs "$ROOT/expansion" > /dev/null 2>&1 || {
  echo "SECTION BRIEFS BLOCKED: generator failed (nothing measured)"; exit 3; }

stale=0
for f in "$B"/*.md; do
  s=$(basename "$f" .md)
  if ! cmp -s "$f" "expansion/$s/SECTION-BRIEF.md"; then
    echo "  stale: $s"
    stale=$((stale + 1))
  fi
done

if [ "$stale" -eq 0 ]; then
  echo "SECTION BRIEFS FRESH ($n of $n regenerate identically)"
  exit 0
fi
echo "SECTION BRIEFS STALE: $stale of $n differ from the generator"
exit 1
