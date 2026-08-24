#!/usr/bin/env bash
# Each CLI must return ONE JSON object with a "verdict" key, through
# foreman-launch, from an empty sandbox, with stdin nulled.
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
  if python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if 'verdict' in d else 1)" "$out" 2>/dev/null; then
    echo "  ok   $lens (exit $rc)"; pass=$((pass+1))
  else
    echo "  FAIL $lens (exit $rc): $(head -c 120 "$log" 2>/dev/null)"; fail=$((fail+1))
  fi
  rm -rf "$SB"
done
echo "members smoke: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
