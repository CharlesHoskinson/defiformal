#!/bin/bash
# SECTION-BRIEF.md is the stated input for writing a paper section, and nothing
# checked that the committed briefs still match their generator. Three of twelve
# did not: 07-bridges still showed At discharging BTCB, Coinbase and WBTC after
# council finding 5 withdrew it, which would have reintroduced retracted claims
# into any section regenerated from it.
#
# Regenerate all twelve and require byte-equality.
set -uo pipefail
cd /root/defiformal || exit 9

B=/root/.brief-check
rm -rf "$B"; mkdir -p "$B"
for d in expansion/*/; do
  s=$(basename "$d")
  [ -f "$d/SECTION-BRIEF.md" ] && cp "$d/SECTION-BRIEF.md" "$B/$s.md"
done
n=$(ls "$B" | wc -l)

node formal/v3/section-brief.mjs /root/defiformal/expansion > /dev/null 2>&1 || {
  echo "SECTION BRIEFS: generator failed"; exit 1; }

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
  rm -rf "$B"
  exit 0
fi
echo "SECTION BRIEFS STALE: $stale of $n differ from the generator"
rm -rf "$B"
exit 1
