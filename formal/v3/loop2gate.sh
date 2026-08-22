#!/bin/bash
# LOOP-2 integrity gate.
#
# Two failure modes this script has already produced and must not repeat:
#   - matching against `tail -n` when the summary line sits above the tail, so a
#     reproducing harness reads as drift (cried wolf, 2026-08-05);
#   - invoking a script by a remembered name that does not exist, and reporting
#     the crash as a citation finding.
# Both are why every check below greps the WHOLE output and why the harness
# names are asserted to exist before they are run.
cd "$(dirname "$0")/../.." || exit 3
if [ ! -s paper/atlas.tex ] || ! ls corpus50/lanes/*.json >/dev/null 2>&1; then
  printf 'LOOP2 BLOCKED: %s is not a defiformal tree; nothing was measured\n' "$PWD" >&2
  exit 3
fi
fail=0
blkd=0

need () { [ -f "$1" ] || { echo "  FAIL missing script: $1"; fail=1; return 1; }; }

# Signatures of a harness that could not RUN, deliberately narrow -- a bare
# "Traceback" also appears when a harness ran and failed on content, and
# classifying that as blocked would hide a real defect behind a reassuring word.
blocked_out() {
  printf '%s' "$1" | grep -qE 'Error: (EACCES|ENOENT)|ERR_MODULE_NOT_FOUND|Cannot find module|(PermissionError|FileNotFoundError|ModuleNotFoundError): \[?Errno|Permission denied|^totalgate: BLOCKED|GATE BLOCKED|LOOP2 BLOCKED'
}

echo "===== 1. paper build"
b=$(cd paper && ./build.sh 2>&1); brc=$?
echo "$b" | sed 's/\x1b\[[0-9;]*m//g' | tail -6
# The VERDICT must come from the exit code, not from grepping stdout for "OK".
# An earlier revision only printed a note here and still derived its verdict
# from the grep, so a blocked build was still reported as a build failure.
case "$brc" in
  0) case "$b" in *"OK"*) echo "  ok   build reports OK" ;;
                  *) echo "  FAIL build exited 0 without the OK line"; fail=1 ;; esac ;;
  3) echo "  BLOCKED build - a build check could not run; nothing was measured"; blkd=1 ;;
  *) echo "  FAIL build did not report OK (exit $brc)"; fail=1 ;;
esac
echo "  undefined-reference lines: $(echo "$b" | grep -ciE 'undefined (reference|citation)')"

echo
echo "===== 2. the four harnesses (whole output searched, not the tail)"
allout=""
for h in pairs canonical safe antiexchange; do
  need "formal/v2/$h.mjs" || continue
  allout="$allout
$(node formal/v2/$h.mjs 2>&1)"
done
want () { # label regex
  # expected string wins first; only then may the blocked classifier speak.
  if echo "$allout" | grep -qE "$2"; then echo "  ok   $1"
  elif blocked_out "$allout"; then echo "  BLOCKED $1 (harness could not run; nothing measured)"; blkd=1
  else echo "  FAIL $1 (/$2/ not in harness output)"; fail=1; fi
}
want "61 of 72 protocols satisfy laws+warrants" 'laws\+warrants: 61/72'
want "1830 pairs"                               'pairs: 1830'
want "185 failures"                             'fail: 185'
want "20 of 61 universally composable"          'EVERY other in the corpus: 20/61'
want "15 definite arcs"                         'arcs 15'
want "0 anti-exchange violations"               'NON-unique: 0'

echo
echo "===== 3. every numeric claim recomputed from a committed script"
one () { # label script-cmd needle
  # capture the WHOLE output before judging it -- truncating to the last line
  # first discards the very evidence that marks a blocked run.
  full=$(eval "$2" 2>&1); orc=$?
  printf '  %s\n' "$(printf '%s' "$full" | tail -1)"
  # The EXIT CODE is the verdict; the needle only confirms a zero exit said what
  # it claims. Grepping the whole output for a substring is not safe on its own:
  # totalgate's provenance NOTE echoes a filesystem path into the output, so a
  # path containing the needle turned a real FAIL into ok (found at
  # /tmp/agree-check against the needle "agree"). Contract: 0 holds, 3 blocked.
  case "$orc" in
    0) case "$full" in
         *"$3"*) echo "  ok   $1" ;;
         *) echo "  FAIL $1 (exited 0 without '$3')"; fail=1 ;;
       esac ;;
    3) echo "  BLOCKED $1 (could not run; nothing measured)"; blkd=1 ;;
    *) if blocked_out "$full"; then echo "  BLOCKED $1 (could not run; nothing measured)"; blkd=1
       else echo "  FAIL $1 (exit $orc)"; fail=1; fi ;;
  esac
}
one "109 category claims" "node formal/v3/claims.mjs"           ", 0 failed"
one "22 checker self-tests" "node formal/v3/selftest.mjs"        ", 0 failed"
one "headline totals"      "node formal/v3/totalgate.mjs"        "all headline totals agree with the verdicts"
one "emission invariant"   "python3 formal/v3/verify-emission.py" "HOLDS"
one "graph claims"         "python3 formal/v3/verify-graphs.py"   "VERIFIED"
one "extensions"           "node formal/v3/verify-extensions.mjs" "0 mismatch"
one "submission structure" "python3 formal/v3/verify-structure.py" "COMPLETE"
one "merged graph regenerates identically" "bash formal/v3/merged-fresh.sh" "MERGED GRAPH FRESH"
one "domain graph regenerates identically" "bash formal/v3/domain-fresh.sh" "DOMAIN GRAPH FRESH"

echo
one "every lane document is in its lane graph" "python3 formal/v3/lane-coverage.py" "LANE COVERAGE COMPLETE"
one "composition table matches the corpus" "node formal/v3/verify-composition.mjs" "COMPOSITION TABLE VERIFIED"
one "footprints table matches the corpus" "node formal/v3/verify-footprints.mjs" "FOOTPRINTS TABLE VERIFIED"
one "category table matches the corpus cell by cell" "node formal/v3/verify-cattable.mjs" "CATEGORY TABLE VERIFIED"
one "every set-membership claim holds in the algebra" "node formal/v3/verify-setclaims.mjs" "SET CLAIMS VERIFIED"
one "coverage sensitivity matches the ledger" "node formal/v3/verify-coverage.mjs" "COVERAGE SENSITIVITY VERIFIED"
one "free-set conjecture matches the algebra" "node formal/v3/verify-freeset.mjs" "FREE-SET CLAIM VERIFIED"
one "section briefs regenerate identically" "bash formal/v3/brief-fresh.sh" "SECTION BRIEFS FRESH"

echo "===== 4. citations: every protocol design claim carries a URL and a date"
need formal/v3/evidence.mjs && node formal/v3/evidence.mjs 2>&1 | tail -2
need formal/v3/cites.mjs && node formal/v3/cites.mjs 2>&1 | grep -iE 'without|missing|no url|no date|aggregator' | head -4

echo
echo "===== 5. paper shape"
echo "  measurements $(grep -c 'begin{measurement}' paper/atlas.tex) | proved $(grep -cE 'begin\{(theorem|proposition|corollary|lemma)\}' paper/atlas.tex) | conjectures $(grep -c 'begin{conjecture}' paper/atlas.tex) | article $(pdfinfo paper/atlas.pdf 2>/dev/null | awk '/^Pages/{print $2}')pp | supplement $(pdfinfo paper/supplement.pdf 2>/dev/null | awk '/^Pages/{print $2}')pp"

echo
echo "===== 6. git"
git status --short | head
echo "  HEAD: $(git log --oneline -1)"
if [ "$fail" -ne 0 ]; then
  printf '\n===== LOOP-2 RESULT: FAIL (fail=%s blocked=%s)\n' "$fail" "${blkd:-0}"; exit 1
elif [ "${blkd:-0}" -ne 0 ]; then
  printf '\n===== LOOP-2 RESULT: BLOCKED - one or more checks could not run (fail=%s blocked=%s)\n' "$fail" "${blkd:-0}"; exit 3
else
  printf '\n===== LOOP-2 RESULT: PASS\n'; exit 0
fi
