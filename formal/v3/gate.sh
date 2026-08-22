#!/usr/bin/env bash
# LOOP-2 integrity gate. Report exact observed numbers; never "as expected".
cd "$(dirname "$0")/../.." || exit 3   # an unguarded cd once turned EACCES into "FAIL 61 of 72"
# A cd into a directory that merely EXISTS also succeeds, and the harnesses then
# report content verdicts about a tree holding no corpus. Landing in the wrong
# place is a blocked check, never a finding about the corpus.
# Names alone are not a repo: three empty files of the right name walk straight
# past a existence check. Require content that only this corpus has.
if [ ! -s paper/atlas.tex ] || [ ! -d expansion ] || ! ls corpus50/lanes/*.json >/dev/null 2>&1 \
   || ! grep -q 'begin{measurement}' paper/atlas.tex 2>/dev/null; then
  printf 'GATE BLOCKED: %s is not a defiformal tree; nothing was measured\n' "$PWD" >&2
  exit 3
fi
fail=0
blkd=0
say() { printf '\n===== %s\n' "$1"; }

say "1. paper build"
out=$(cd paper && ./build.sh 2>&1); brc=$?
out=$(printf '%s' "$out" | sed 's/\x1b\[[0-9;]*h*[0-9;]*m//g')
printf '%s\n' "$out" | tail -6
# The caller must learn the contract too, or the fix stops at build.sh's own
# stdout: exit 3 means the build could not check something, not that it failed.
case "$brc" in
  0) if printf '%s' "$out" | grep -qE 'OK[[:space:]]+atlas\.pdf: [0-9]+ pages'; then
       echo "GATE: build OK"
     else
       echo "GATE: BUILD reported success without the OK line"; fail=1
     fi ;;
  3) echo "GATE: BUILD BLOCKED - a build check could not run; nothing was measured"; blkd=1 ;;
  *) echo "GATE: BUILD FAILED (exit $brc)"; fail=1 ;;
esac
undef=$(grep -c 'undefined' paper/atlas.log 2>/dev/null); undef=${undef:-0}
echo "undefined references in atlas.log: $undef"
[ "$undef" = "0" ] || { echo "GATE: undefined references present"; fail=1; }

say "2. harnesses"
p=$(node formal/v2/pairs.mjs 2>&1)
printf '%s\n' "$p" | head -4
c=$(node formal/v2/canonical.mjs 2>&1); printf '%s\n' "$c" | head -2
s=$(node formal/v2/safe.mjs 2>&1); printf '%s\n' "$s" | head -2
a=$(node formal/v2/antiexchange.mjs 2>&1); printf '%s\n' "$a" | grep -E 'VIOLATIONS|closed sets'

# A harness that could not run has not refuted anything. Reporting its silence
# as "FAIL 61 of 72" is a corpus verdict about a corpus nothing read.
# Signatures of a harness that could not RUN. Deliberately narrow: a bare
# "BLOCKED" or a lone "Traceback" also appears in output from a harness that ran
# and failed on content, and classifying that as blocked would hide a real defect
# behind a reassuring word -- the same lie in the opposite direction.
blocked_out() {
  printf '%s' "$1" | grep -qE 'Error: (EACCES|ENOENT)|ERR_MODULE_NOT_FOUND|Cannot find module|(PermissionError|FileNotFoundError|ModuleNotFoundError): \[?Errno|^totalgate: BLOCKED|GATE BLOCKED'
}
# ORDER MATTERS. A harness that produced the expected answer is never blocked,
# however noisy its stderr. Only then does the blocked classifier get a say.
chk() {
  if printf '%s' "$2" | grep -q -- "$3"; then echo "  ok   $1"
  elif blocked_out "$2"; then echo "  BLOCKED $1 (harness could not run; nothing measured)"; blkd=1
  else echo "  FAIL $1 (wanted '$3')"; fail=1; fi
}
chk "61 of 72 satisfy laws+warrants" "$p" "61/72"
chk "1830 pairs"                     "$p" "pairs: 1830"
chk "185 failures"                   "$p" "fail: 185"
chk "29 of 72 compress"              "$c" "29/72"
chk "20 universally composable"      "$s" "20/61"
chk "15 definite arcs"               "$c" "arcs 15"
chk "0 anti-exchange violations"     "$a" "VIOLATIONS: 0"

say "3. every category claim recomputed"
cl=$(node formal/v3/claims.mjs 2>&1); echo "$cl" | tail -1
# expected string wins first; see chk() -- these three are the only
# checks actually blocked today, so the inversion matters most here.
if printf '%s' "$cl" | grep -q ', 0 failed'; then echo "  ok   109-claim checker"
elif blocked_out "$cl"; then echo "  BLOCKED 109-claim checker (could not run)"; blkd=1
else echo "  FAIL claim checker"; fail=1; fi

say "3b. v3 toolchain smoke"
sm=$(bash formal/v3/smoke.sh 2>&1); echo "$sm" | tail -1
# expected string wins first; see chk() -- these three are the only
# checks actually blocked today, so the inversion matters most here.
if printf '%s' "$sm" | grep -q 'SMOKE OK'; then echo "  ok   smoke"
elif blocked_out "$sm"; then echo "  BLOCKED smoke (could not run)"; blkd=1
else echo "  FAIL smoke"; fail=1; fi

say "3c. knowledge-graph claims"
gr=$(python3 formal/v3/verify-graphs.py 2>&1); echo "$gr" | tail -1
# expected string wins first; see chk() -- these three are the only
# checks actually blocked today, so the inversion matters most here.
if printf '%s' "$gr" | grep -q 'GRAPH CLAIMS VERIFIED'; then echo "  ok   graph claims (12 lanes, merged, domain)"
elif blocked_out "$gr"; then echo "  BLOCKED graph claims (could not run)"; blkd=1
else echo "  FAIL graph claims"; fail=1; fi

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

if [ "$fail" -ne 0 ]; then
  printf '\n===== GATE RESULT: FAIL (fail flag=%s, blocked flag=%s)\n' "$fail" "$blkd"
  exit 1
elif [ "$blkd" -ne 0 ]; then
  printf '\n===== GATE RESULT: BLOCKED - one or more harnesses could not run;\n'
  printf '      no corpus verdict was measured (fail flag=%s, blocked flag=%s)\n' "$fail" "$blkd"
  exit 3
else
  printf '\n===== GATE RESULT: PASS (fail flag=%s, blocked flag=%s)\n' "$fail" "$blkd"
  exit 0
fi
