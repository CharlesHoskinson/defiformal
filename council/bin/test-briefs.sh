#!/usr/bin/env bash
# Every brief must carry the three rules the post-mortem made non-negotiable,
# and must be self-contained: a member reads its brief and the bundle, nothing
# else.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
pass=0; fail=0
has () { if grep -qi "$2" "$1"; then echo "  ok   $(basename "$1"): $3"; pass=$((pass+1));
         else echo "  FAIL $(basename "$1"): $3"; fail=$((fail+1)); fi; }

for b in council/sprint1/BRIEF-empirical.md council/sprint1/BRIEF-formal.md \
         council/sprint1/BRIEF-significance.md council/sprint1/BRIEF-reproducer.md; do
  [ -f "$b" ] || { echo "  FAIL $b absent"; fail=$((fail+1)); continue; }
  has "$b" "accidental drift"        "states the threat model"
  has "$b" "falsifier"               "requires a falsifier per finding"
  has "$b" "insufficient_evidence"   "allows insufficient_evidence"
  has "$b" "single JSON object"      "states the output contract"
  has "$b" "do not read any other"   "sandbox instruction"
  # self-contained: no cross-references to sibling briefs
  if grep -qi "BRIEF-" "$b"; then echo "  FAIL $(basename "$b"): references a sibling brief"; fail=$((fail+1));
  else echo "  ok   $(basename "$b"): self-contained"; pass=$((pass+1)); fi
done

# Check that the Standards bullet about candidates is present and byte-identical in all four briefs
if python3 council/bin/check-standards-identity.py >/dev/null 2>&1; then
  echo "  ok   Standards bullet identity: all four briefs have byte-identical sentence"
  pass=$((pass+1))
else
  echo "  FAIL Standards bullet identity check"
  python3 council/bin/check-standards-identity.py
  fail=$((fail+1))
fi

echo "briefs: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
