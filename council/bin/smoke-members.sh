#!/usr/bin/env bash
# Each CLI must return, through foreman-launch, from an empty sandbox with
# stdin nulled, stdout that contains a balanced JSON object with a
# "verdict" key -- extracted via council/bin/extract-json.py rather than
# requiring bare stdout to already be valid JSON on its own, since a
# member can narrate its next tool call inline with its final answer (see
# members.sh's empirical/grok case) without that being a dispatch failure.
# Extraction papering over a member that returned no JSON at all is not
# acceptable either: extract-json.py fails closed when no balanced object
# exists, so that case still fails this check.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
[ -f council/bin/members.sh ] || { echo "members.sh absent"; exit 3; }
. council/bin/members.sh

pass=0; fail=0
for lens in empirical formal significance reproducer; do
  SB=$(mktemp -d)
  cp council/bin/smoke-fixture.md "$SB/bundle.md"
  cat > "$SB/brief.md" <<'BRIEF'
Read ./bundle.md. Decide whether the claim under review is sound.
Output ONLY a single JSON object, no prose, no markdown fences:
{"lens":"smoke","verdict":"approved","summary":"<=20 words"}
BRIEF
  out="$SB/out.json"; log="$SB/out.log"
  run_member "$lens" "$SB" "$SB/brief.md" "$out" "$log"; rc=$?
  extract_log="$SB/extract.log"
  if python3 council/bin/extract-json.py --require-key verdict "$out" >/dev/null 2>"$extract_log"; then
    note=$(tail -n1 "$extract_log")
    echo "  ok   $lens (exit $rc) [$note]"; pass=$((pass+1))
  else
    echo "  FAIL $lens (exit $rc): $(head -c 120 "$log" 2>/dev/null)"; fail=$((fail+1))
  fi
  rm -rf "$SB"
done
echo "members smoke: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
