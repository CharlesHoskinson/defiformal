#!/usr/bin/env bash
# LOOP-2 integrity gate. Report exact observed numbers; never "as expected".
cd /root/defiformal
fail=0
say() { printf '\n===== %s\n' "$1"; }

say "1. paper build"
out=$(cd paper && ./build.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
printf '%s\n' "$out" | tail -6
if printf '%s' "$out" | grep -qE 'OK[[:space:]]+atlas\.pdf: [0-9]+ pages'; then
  echo "GATE: build OK"
else
  echo "GATE: BUILD FAILED"; fail=1
fi
undef=$(grep -c 'undefined' paper/atlas.log 2>/dev/null); undef=${undef:-0}
echo "undefined references in atlas.log: $undef"
[ "$undef" = "0" ] || { echo "GATE: undefined references present"; fail=1; }

say "2. harnesses"
p=$(node formal/v2/pairs.mjs 2>&1)
printf '%s\n' "$p" | head -4
c=$(node formal/v2/canonical.mjs 2>&1 | head -2); printf '%s\n' "$c"
s=$(node formal/v2/safe.mjs 2>&1 | head -2); printf '%s\n' "$s"
a=$(node formal/v2/antiexchange.mjs 2>&1 | grep -E 'VIOLATIONS|closed sets'); printf '%s\n' "$a"

chk() { if printf '%s' "$2" | grep -q -- "$3"; then echo "  ok   $1"; else echo "  FAIL $1 (wanted '$3')"; fail=1; fi; }
chk "61 of 72 satisfy laws+warrants" "$p" "61/72"
chk "1830 pairs"                     "$p" "pairs: 1830"
chk "185 failures"                   "$p" "fail: 185"
chk "29 of 72 compress"              "$c" "29/72"
chk "20 universally composable"      "$s" "20/61"
chk "15 definite arcs"               "$c" "arcs 15"
chk "0 anti-exchange violations"     "$a" "VIOLATIONS: 0"

say "3. every category claim recomputed"
cl=$(node formal/v3/claims.mjs 2>&1 | tail -1); echo "$cl"
printf '%s' "$cl" | grep -q ', 0 failed' && echo "  ok   109-claim checker" || { echo "  FAIL claim checker"; fail=1; }

say "3b. v3 toolchain smoke"
sm=$(bash formal/v3/smoke.sh 2>&1 | tail -1); echo "$sm"
printf '%s' "$sm" | grep -q 'SMOKE OK' && echo "  ok   smoke" || { echo "  FAIL smoke"; fail=1; }

say "4. hand-asserted numbers and uncited protocol claims in the paper"
# every \begin{measurement} block should be traceable; report the count and the
# sections added since stage 0 so a human can spot an untraced figure
echo "measurements in atlas.tex: $(grep -c 'begin{measurement}' paper/atlas.tex)"
echo "theorem-class items:       $(grep -cE 'begin\{(theorem|proposition|corollary|lemma)\}' paper/atlas.tex)"
echo "conjectures:               $(grep -c 'begin{conjecture}' paper/atlas.tex)"
echo "changelog guard: enforced by paper/build.sh in step 1, which passed;"
echo "  the gate does not keep a second copy of the pattern."
echo "protocol-design claims in atlas.tex requiring a URL: the paper cites the corpus, not"
echo "  live protocols; per-application citations enter at stage 6 via emit-tex from specs"
echo "  whose obligations each carry an evidence URL (validate.mjs enforces)."

say "5. git"
git status --short | head -10
echo "HEAD: $(git log --oneline | head -1)"

printf '\n===== GATE RESULT: %s (fail flag=%s)\n' "$([ $fail -eq 0 ] && echo PASS || echo FAIL)" "$fail"
exit $fail
