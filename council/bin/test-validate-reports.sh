#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
V=council/bin/validate-reports.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
want () { if [ "$2" = "$3" ]; then echo "  ok   $1"; pass=$((pass+1));
          else echo "  FAIL $1 (want $3, got $2)"; fail=$((fail+1)); fi; }

good='{"lens":"empirical","ranking":["B","C","A"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[{"id":"F1","candidate":"A","severity":"high","claim":"c","problem":"p","falsifier":"run x","fix":"f","status":"verified"}],"strongest_candidate_argument":"a","dissent_note":"d"}'

printf '%s' "$good" > "$T/R1-empirical-grok.json"
python3 "$V" "$T" >/dev/null 2>&1; want "CONTROL: a valid report passes" "$?" "0"

printf '```json\n%s\n```' "$good" > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "markdown fences rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf 'Here is my review:\n%s' "$good" > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "prose preamble rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","verdict":"approved","summary":"s"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "missing ranking rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":["A","B","C"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[{"id":"F1","candidate":"A","severity":"high","claim":"c","problem":"p","fix":"f","status":"verified"}],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "finding without falsifier rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":["A","B","C"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "changes_requested with no finding rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":[],"ranking_reason":"r","verdict":"insufficient_evidence","summary":"s","findings":[],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "insufficient_evidence with empty ranking passes" "$?" "0"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":["A","B","C"],"ranking_reason":"r","verdict":"insufficient_evidence","summary":"s","findings":[],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "insufficient_evidence with full ranking rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":[],"ranking_reason":"r","verdict":"approved","summary":"s","findings":[],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "approved with empty ranking rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":["A","B","C"],"ranking_reason":"r","verdict":"approved","summary":"s","findings":[{"id":"F1","candidate":"D","severity":"critical","claim":"c","problem":"p","falsifier":"run x","fix":"f","status":"confirmed"}],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "finding with invalid enum values rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"empirical","ranking":["A","B","C"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[{"id":"F1","candidate":"A","severity":"high","claim":"c","problem":"the bundle wraps its output in ```python fences here","falsifier":"run x","fix":"f","status":"verified"}],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "finding text quoting a code fence still passes" "$?" "0"
rm "$T/R1-formal-claude.json"

printf '%s' "$good" > "$T/unreadable.json"
chmod 000 "$T/unreadable.json"
python3 "$V" "$T" >/dev/null 2>&1; want "unreadable report is could-not-run, not invalid" "$?" "3"
rm -f "$T/unreadable.json"

rm -f "$T"/*.json
python3 "$V" "$T" >/dev/null 2>&1; want "empty dir is BLOCKED not clean" "$?" "3"

# Regression: council/sprint1/reports/R1-empirical-grok.json's round-1 attempt
# 1 (2026-08-23, 4,915 bytes, since overwritten on disk by the retry) put a
# truncated, self-interrupted JSON fragment directly ahead of a complete,
# well-formed object -- {"lens":"emp{"lens":"empirical","ranking":[...],...} --
# so brace-counting from the *first* '{' consumed the real object's own
# braces and never returned to zero. Before extract-json.py's multi-'{'
# fallback this was unrecoverable: "no single balanced, parseable JSON
# object found" (extraction impossible, not just a contract violation).
# The report is still correctly invalid after the fix -- the recovered
# object is still preceded by discarded bytes, so "no prose outside the
# object" still (correctly) rejects it -- but for the true reason: the
# object is found, and it's the surrounding prose that fails the contract.
orphan='{"lens":"emp{"lens":"empirical","ranking":["C","B","A"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[{"id":"F1","candidate":"C","severity":"high","claim":"c","problem":"p","falsifier":"run x","fix":"f","status":"verified"}],"strongest_candidate_argument":"a","dissent_note":"d"}'
printf '%s' "$orphan" > "$T/R1-empirical-grok.json"
out=$(python3 "$V" "$T" 2>&1); rc=$?
want "orphaned truncated fragment: still invalid (real cause: prose outside object)" "$rc" "1"
case "$out" in
  *"no single balanced, parseable JSON object found"*)
    echo "  FAIL orphaned fragment: extractor still cannot find the object at all"
    fail=$((fail+1)) ;;
  *"output is not exactly one JSON object"*)
    echo "  ok   orphaned fragment: object now recovered past the truncated first '{'"
    pass=$((pass+1)) ;;
  *)
    echo "  FAIL orphaned fragment: unexpected validator output: $out"
    fail=$((fail+1)) ;;
esac
rm -f "$T/R1-empirical-grok.json"

echo "validate-reports: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
