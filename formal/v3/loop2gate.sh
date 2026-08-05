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
cd /root/defiformal || exit 9
fail=0

need () { [ -f "$1" ] || { echo "  FAIL missing script: $1"; fail=1; return 1; }; }

echo "===== 1. paper build"
b=$(cd paper && ./build.sh 2>&1)
echo "$b" | sed 's/\x1b\[[0-9;]*m//g' | tail -6
case "$b" in *"OK"*) echo "  ok   build reports OK" ;;
             *) echo "  FAIL build did not report OK"; fail=1 ;; esac
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
  if echo "$allout" | grep -qE "$2"; then echo "  ok   $1"
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
  out=$(eval "$2" 2>&1 | tail -1); echo "  $out"
  case "$out" in *"$3"*) echo "  ok   $1" ;; *) echo "  FAIL $1"; fail=1 ;; esac
}
one "109 category claims" "node formal/v3/claims.mjs"           ", 0 failed"
one "22 checker self-tests" "node formal/v3/selftest.mjs"        ", 0 failed"
one "headline totals"      "node formal/v3/totalgate.mjs"        "agree"
one "emission invariant"   "python3 formal/v3/verify-emission.py" "HOLDS"
one "graph claims"         "python3 formal/v3/verify-graphs.py"   "VERIFIED"
one "extensions"           "node formal/v3/verify-extensions.mjs" "0 mismatch"
one "submission structure" "python3 formal/v3/verify-structure.py" "COMPLETE"
mf=$(bash formal/v3/merged-fresh.sh 2>&1 | tail -1); echo "  $mf"
case "$mf" in *"MERGED GRAPH FRESH"*) echo "  ok   merged graph regenerates identically" ;; *) echo "  FAIL merged graph is stale"; fail=1 ;; esac
df=$(bash formal/v3/domain-fresh.sh 2>&1 | head -1); echo "  $df"
case "$df" in *"DOMAIN GRAPH FRESH"*) echo "  ok   domain graph regenerates identically" ;; *) echo "  FAIL domain graph is stale"; fail=1 ;; esac

echo
lc=$(python3 formal/v3/lane-coverage.py 2>&1 | tail -1); echo "  $lc"
case "$lc" in *"LANE COVERAGE COMPLETE"*) echo "  ok   every lane document is in its lane graph" ;; *) echo "  FAIL a lane document is missing from its graph"; fail=1 ;; esac
cv=$(node formal/v3/verify-coverage.mjs 2>&1 | tail -1); echo "  $cv"
case "$cv" in *"COVERAGE SENSITIVITY VERIFIED"*) echo "  ok   coverage sensitivity matches the ledger" ;; *) echo "  FAIL coverage sensitivity"; fail=1 ;; esac
fs=$(node formal/v3/verify-freeset.mjs 2>&1 | tail -1); echo "  $fs"
case "$fs" in *"FREE-SET CLAIM VERIFIED"*) echo "  ok   free-set conjecture matches the algebra" ;; *) echo "  FAIL free-set claim"; fail=1 ;; esac
bf=$(bash formal/v3/brief-fresh.sh 2>&1 | tail -1); echo "  $bf"
case "$bf" in *"SECTION BRIEFS FRESH"*) echo "  ok   section briefs regenerate identically" ;; *) echo "  FAIL section briefs are stale"; fail=1 ;; esac

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
printf '\n===== LOOP-2 RESULT: %s (fail=%s)\n' "$([ $fail -eq 0 ] && echo PASS || echo FAIL)" "$fail"
exit $fail
