#!/usr/bin/env bash
# The reporters must say the right thing about their own failures.
#
# paper/build.sh once printed "a headline total disagrees with the verdicts"
# because totalgate.mjs could not scandir its input. The totals agreed; the gate
# never ran. Line 49 discarded the diagnosis with >/dev/null 2>&1 and mapped
# every nonzero exit onto one editorial sentence. formal/v3/gate.sh carried the
# same fault in a second shape: an unguarded `cd` let it report "FAIL 61 of 72"
# about a corpus it never read.
#
# The existing negtest-*.sh prove the CONTENT checkers catch manuscript errors.
# None of them proved the reporters distinguish a false property from a check
# that could not run, which is why the defect survived to a published clone.
#
# Every outcome is exercised in BOTH polarities. A harness that only ever sees
# one polarity has discriminated nothing.
#
#   exit 0  property holds over a non-empty corpus
#   exit 1  property is false            -> act on the manuscript
#   exit 3  check could not be performed -> act on the environment
#
# Faults are real, not injected: a chmod-induced EACCES from the filesystem at
# the actual syscall, never a throw planted ahead of it. A fault injected before
# the real call tests the handler rather than the subject.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
R=$(pwd)

pass=0; fail=0
FX=/tmp/negtest-reporting

caught () { printf '  CAUGHT  %s\n' "$1"; pass=$((pass+1)); }
missed () { printf '  MISSED  %s\n' "$1"; fail=$((fail+1)); }

# assert an exit code
want_rc () { # label want got
  if [ "$2" = "$3" ]; then caught "$1 (exit $3)"; else missed "$1 (want exit $2, got $3)"; fi
}
# assert text present / absent
want_has () { if printf '%s' "$2" | grep -qF -- "$3"; then caught "$1"; else missed "$1 -- $3 absent"; fi; }
want_not () { if printf '%s' "$2" | grep -qF -- "$3"; then missed "$1 -- $3 present"; else caught "$1"; fi; }

cleanup () { chmod -R u+rwX "$FX" 2>/dev/null; rm -rf "$FX"; }
trap cleanup EXIT

build_fixture () {  # $1 = fixture dir; expansion symlinked, atlas.tex copied
  rm -rf "$1"; mkdir -p "$1/paper"
  ln -s "$R/expansion" "$1/expansion"
  cp "$R/paper/atlas.tex" "$1/paper/atlas.tex"
}

echo "===== 1. totalgate: VIOLATED vs BLOCKED vs VACUOUS ====="

# --- 1a. control: the real corpus agrees ---------------------------------
out=$(node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "control: real corpus agrees" 0 "$rc"
want_has "control: says totals agree" "$out" "all headline totals agree"

# --- 1b. VIOLATED: a headline total really is wrong ----------------------
build_fixture "$FX/violated"
python3 - "$FX/violated/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
old, new = "$1{,}259$", "$1{,}260$"
if old not in s:
    print("PERTURBATION DID NOT APPLY: anchor absent", file=sys.stderr); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(old, new))
PY
if [ $? -ne 0 ]; then missed "perturbation could not be applied"; else
  out=$(DEFIFORMAL_ROOT="$FX/violated" node formal/v3/totalgate.mjs 2>&1); rc=$?
  want_rc  "VIOLATED: wrong obligations total" 1 "$rc"
  want_has "VIOLATED: names the failing total" "$out" "FAIL obligations total"
fi

# --- 1c. BLOCKED: a real EACCES at the real syscall ----------------------
rm -rf "$FX/blocked"; mkdir -p "$FX/blocked/paper" "$FX/blocked/expansion/01-spot-exchange"
cp "$R/paper/atlas.tex" "$FX/blocked/paper/atlas.tex"
chmod 000 "$FX/blocked/expansion"
out=$(DEFIFORMAL_ROOT="$FX/blocked" node formal/v3/totalgate.mjs 2>&1); rc=$?
chmod 755 "$FX/blocked/expansion"
want_rc  "BLOCKED: unreadable expansion root" 3 "$rc"
want_has "BLOCKED: names the cause"  "$out" "BLOCKED"
want_not "BLOCKED: does NOT claim a disagreement" "$out" "out of step with the verdicts"

# --- 1d. VACUOUS: empty corpus must not read as a disagreement -----------
# With tot === 0 the percentages are NaN, every `has` test fails, and the
# unguarded gate would exit 1 -- announcing a disagreement it never measured.
rm -rf "$FX/vacuous"; mkdir -p "$FX/vacuous/paper" "$FX/vacuous/expansion"
cp "$R/paper/atlas.tex" "$FX/vacuous/paper/atlas.tex"
out=$(DEFIFORMAL_ROOT="$FX/vacuous" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "VACUOUS: empty expansion root" 3 "$rc"
want_not "VACUOUS: does NOT report NaN totals as a disagreement" "$out" "out of step"

echo
echo "===== 2. paper/build.sh reports the two failures differently ====="

# --- 2a. BLOCKED through build.sh -- the exact published defect ----------
rm -rf "$FX/b2"; mkdir -p "$FX/b2/paper" "$FX/b2/expansion/01-spot-exchange"
cp "$R/paper/atlas.tex" "$FX/b2/paper/atlas.tex"
chmod 000 "$FX/b2/expansion"
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/b2" ./paper/build.sh 2>&1); rc=$?
out=$(printf '%s' "$out" | sed 's/\x1b\[[0-9;]*m//g')
chmod 755 "$FX/b2/expansion"
want_rc  "build BLOCKED: exit code" 3 "$rc"
want_has "build BLOCKED: says the totals were not checked" "$out" "were NOT checked"
want_not "build BLOCKED: does NOT say a total disagrees"   "$out" "a headline total disagrees"
want_has "build BLOCKED: surfaces the gate diagnosis"      "$out" "EACCES"

# --- 2b. VIOLATED through build.sh --------------------------------------
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/violated" ./paper/build.sh 2>&1); rc=$?
out=$(printf '%s' "$out" | sed 's/\x1b\[[0-9;]*m//g')
want_rc  "build VIOLATED: exit code" 1 "$rc"
want_has "build VIOLATED: says a total disagrees"    "$out" "a headline total disagrees"
want_not "build VIOLATED: does NOT say it was blocked" "$out" "were NOT checked"

# --- 2c. control: the real tree builds clean ----------------------------
out=$(cd "$R" && ./paper/build.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g'); rc=$?
want_rc  "build control: real tree" 0 "$rc"
want_has "build control: reports OK" "$out" "OK  atlas.pdf"

echo
echo "===== 3. gate.sh: a failed cd must stop the script ====="
guard=$(sed -n '3p' formal/v3/gate.sh)
want_has "gate.sh cd is guarded" "$guard" "|| exit"
want_not "gate.sh no longer hardcodes /root" "$guard" "/root/defiformal"
# a resolution that must fail: run a copy from a directory with no repo above it
mkdir -p "$FX/orphan"
cp formal/v3/gate.sh "$FX/orphan/gate.sh"
out=$(cd "$FX/orphan" && bash ./gate.sh 2>&1); rc=$?
want_rc  "gate.sh orphan: exit code" 3 "$rc"
want_has "gate.sh orphan: says BLOCKED"                 "$out" "GATE BLOCKED"
want_not "gate.sh emits no corpus verdict when blocked" "$out" "FAIL 61 of 72"

# a fake tree of correctly-NAMED but empty files must not pass the sentinel
rm -rf "$FX/fake"; mkdir -p "$FX/fake/paper" "$FX/fake/expansion" "$FX/fake/corpus50/lanes" "$FX/fake/formal/v3"
: > "$FX/fake/paper/atlas.tex"
cp formal/v3/gate.sh "$FX/fake/formal/v3/gate.sh"
out=$(cd "$FX/fake/formal/v3" && bash ./gate.sh 2>&1); rc=$?
want_rc  "sentinel: empty look-alike tree is blocked" 3 "$rc"
want_has "sentinel: names it"                         "$out" "not a defiformal tree"

echo
echo "===== 3b. the contract holds INSIDE the corpus walk ====="
# The first version of this change guarded readdir and left every readFileSync /
# JSON.parse unguarded: an EACCES or malformed JSON one directory deeper threw,
# node exited 1, and build.sh called it a totals disagreement. Same lie, next
# syscall. These lock the depth.

mk_real () {   # a fixture holding ONE real slug, so totals are computable
  rm -rf "$1"; mkdir -p "$1/paper"
  cp "$R/paper/atlas.tex" "$1/paper/atlas.tex"
  mkdir -p "$1/expansion"
  cp -r "$R/expansion/01-spot-exchange" "$1/expansion/"
}

# 3b.1 unreadable verdicts.json (real EACCES at the real syscall)
mk_real "$FX/inner1"
chmod 000 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/inner1" node formal/v3/totalgate.mjs 2>&1); rc=$?
chmod 644 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
want_rc  "inner: unreadable verdicts.json" 3 "$rc"
want_not "inner: not called a disagreement" "$out" "out of step with the verdicts"

# 3b.2 malformed spec JSON
mk_real "$FX/inner2"
sp=$(ls "$FX/inner2/expansion/01-spot-exchange/specs/"*.json | head -1)
printf '{ this is not json' > "$sp"
out=$(DEFIFORMAL_ROOT="$FX/inner2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "inner: malformed spec JSON" 3 "$rc"
want_has "inner: names the parse failure" "$out" "cannot parse"

# 3b.3 tot === 0 -- slugs present, no obligations. Unguarded this is NaN and
# every `has` test fails, so the gate would exit 1 and announce a disagreement.
mk_real "$FX/inner3"
printf '[]' > "$FX/inner3/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/inner3" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "inner: zero obligations" 3 "$rc"
want_not "inner: zero obligations is not a disagreement" "$out" "out of step"

# 3b.4 the same, through build.sh -- the caller must not relabel it.
# The fault must be LIVE for this run: with permissions restored the fixture is a
# one-slug corpus and the gate correctly reports a real disagreement, which is
# not what this case is testing.
chmod 000 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/inner1" ./paper/build.sh 2>&1); rc=$?
chmod 644 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
want_rc  "inner through build.sh: exit code" 3 "$rc"
want_not "inner through build.sh: no disagreement claim" "$out" "a headline total disagrees"

# and the control for that control: with the fault CLEARED, the same one-slug
# fixture must report a genuine disagreement, exit 1. Without this, 3b.4 would
# pass against a build.sh that called everything blocked.
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/inner1" ./paper/build.sh 2>&1); rc=$?
want_rc  "inner control: readable one-slug fixture really disagrees" 1 "$rc"

echo
echo "===== 3d. the contract holds at the TYPE, not just the parse ====="
# Round 2 guarded readFileSync and JSON.parse. Valid JSON `null` is neither a
# read failure nor a parse failure, so it slipped through and the next property
# access threw a TypeError -- node exits 1, the "manuscript is wrong" code.

# 3d.1 a spec that is literally null
mk_real "$FX/t1"
sp=$(ls "$FX/t1/expansion/01-spot-exchange/specs/"*.json | head -1)
printf 'null' > "$sp"
out=$(DEFIFORMAL_ROOT="$FX/t1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "type: spec is JSON null" 3 "$rc"
want_not "type: null spec is not a disagreement" "$out" "out of step"

# 3d.2 a null element inside the verdicts array
mk_real "$FX/t2"
printf '[null]' > "$FX/t2/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/t2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "type: null verdict element" 3 "$rc"

# 3d.3 a non-numeric obligation count
mk_real "$FX/t3"
printf '[{"obligationsTotal":"many","obligationsCovered":1,"verdict":"OK"}]' \
  > "$FX/t3/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/t3" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "type: non-numeric obligation count" 3 "$rc"
# The parent `!Number.isFinite(tot)` guard also returns 3 here, so exit code
# alone does not lock the per-element check. Assert its OWN message.
want_has "type: blocked BY the per-verdict check" "$out" "has a non-numeric obligation count"

# 3d.4 an unreadable slug DIRECTORY. existsSync returns false here, so the slug
# used to be silently skipped and its obligations vanished from the totals --
# the short total was then compared and reported as a real disagreement.
# TWO slugs, deliberately. With one, an unreadable slug leaves zero obligations
# and the pre-existing tot===0 guard returns 3 regardless -- the assertion stays
# green against the reverted fix and locks nothing. With two, the readable slug
# still contributes, the short total is compared, and the unfixed code exits 1
# with "out of step": the silent-skip disagreement this fix exists to prevent.
rm -rf "$FX/t4"; mkdir -p "$FX/t4/paper" "$FX/t4/expansion"
cp "$R/paper/atlas.tex" "$FX/t4/paper/atlas.tex"
cp -r "$R/expansion/01-spot-exchange" "$FX/t4/expansion/"
cp -r "$R/expansion/02-lending"       "$FX/t4/expansion/"
chmod 000 "$FX/t4/expansion/02-lending"
out=$(DEFIFORMAL_ROOT="$FX/t4" node formal/v3/totalgate.mjs 2>&1); rc=$?
chmod 755 "$FX/t4/expansion/02-lending"
want_rc  "type: unreadable slug among readable ones" 3 "$rc"
want_has "type: names the slug it could not enter" "$out" "cannot enter slug 02-lending"
want_not "type: unreadable slug is not silently skipped" "$out" "out of step"

# a slug-shaped FILE is not a category and must be skipped, not blocked
rm -rf "$FX/t5"; mkdir -p "$FX/t5/paper" "$FX/t5/expansion"
cp "$R/paper/atlas.tex" "$FX/t5/paper/atlas.tex"
cp -r "$R/expansion/01-spot-exchange" "$FX/t5/expansion/"
: > "$FX/t5/expansion/99-not-a-dir"
out=$(DEFIFORMAL_ROOT="$FX/t5" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_not "type: a slug-shaped file does not block the run" "$out" "cannot enter slug 99-not-a-dir"

echo
echo "===== 3e. loop2gate.sh derives its verdict from the exit code ====="
# The previous round only added a printf here and left the verdict coming from
# `case "$b" in *"OK"*)`. The note is not the fix.
want_has "loop2gate: branches on the exit code" "$(cat formal/v3/loop2gate.sh)" 'case "$brc" in'
want_not "loop2gate: no longer hardcodes /root"  "$(cat formal/v3/loop2gate.sh)" "cd /root/defiformal"
# A source grep is not enough: the first attempt at this fix appended a result
# block AFTER the script's existing `exit`, so the new branch was dead code and
# a grep for it still passed. Assert there is no statement after the terminal
# exit, and assert the BLOCKED path actually reaches stdout.
# The previous version of this check looked for a line beginning `exit `, but
# the terminal block puts `exit` on the same line as its printf, so the pattern
# never matched and the assertion passed against ANY file -- including the dead
# code it was written to catch. Behavioural instead: implant a marker after the
# terminal block in a copy and confirm it never prints.
# The probe needs a tree whose ../.. is a real defiformal root, or the sentinel
# exits 3 first and BOTH the probe and its control pass/fail vacuously.
probe_tree () {   # $1 = dest; symlinks only, nothing written inside the repo
  rm -rf "$1"; mkdir -p "$1/formal/v3"
  for d in paper expansion corpus50 research; do ln -s "$R/$d" "$1/$d"; done
  ln -s "$R/formal/v2" "$1/formal/v2"
  for f in "$R"/formal/v3/*; do
    b=$(basename "$f"); [ "$b" = "loop2gate.sh" ] && continue
    ln -s "$f" "$1/formal/v3/$b"
  done
}
probe_tree "$FX/pdead"
cp formal/v3/loop2gate.sh "$FX/pdead/formal/v3/loop2gate.sh"
printf '\necho DEAD-CODE-MARKER\n' >> "$FX/pdead/formal/v3/loop2gate.sh"
dout=$(bash "$FX/pdead/formal/v3/loop2gate.sh" 2>&1)
want_not "loop2gate: nothing executes after the terminal block" "$dout" "DEAD-CODE-MARKER"
want_not "loop2gate: dead-code probe reached the terminal block" "$dout" "is not a defiformal tree"

# Control: the same marker placed BEFORE the terminal block MUST print. Without
# this, the check above passes against a script that exited long before either
# block -- which is exactly how the previous two versions of it were vacuous.
probe_tree "$FX/plive"
awk '/^if \[ "\$fail" -ne 0 \]; then/ && !d {print "echo DEAD-CODE-MARKER"; d=1} {print}' \
  formal/v3/loop2gate.sh > "$FX/plive/formal/v3/loop2gate.sh"
lout=$(bash "$FX/plive/formal/v3/loop2gate.sh" 2>&1)
want_has "loop2gate: the dead-code probe can fail (control)" "$lout" "DEAD-CODE-MARKER"
mkdir -p "$FX/orphan2"
cp formal/v3/loop2gate.sh "$FX/orphan2/loop2gate.sh"
out=$(cd "$FX/orphan2" && bash ./loop2gate.sh 2>&1); rc=$?
want_rc  "loop2gate orphan: exit code" 3 "$rc"
want_not "loop2gate orphan: emits no build verdict" "$out" "FAIL build did not report OK"

# Behavioural, not a source grep: on this tree many v3 harnesses cannot run, so
# loop2gate must report BLOCKED with fail=0, never content verdicts about a
# corpus nothing read. Before this fix it printed ten of them and exited 1.
l2=$(bash formal/v3/loop2gate.sh 2>&1); l2rc=$?
want_rc  "loop2gate: blocked tree gives exit 3, not 1" 3 "$l2rc"
want_has "loop2gate: says BLOCKED"                  "$l2" "LOOP-2 RESULT: BLOCKED"
want_has "loop2gate: fail flag is zero"             "$l2" "fail=0"
want_not "loop2gate: no stale-brief content verdict" "$l2" "FAIL section briefs are stale"
want_not "loop2gate: no free-set content verdict"    "$l2" "FAIL free-set claim"

# F1: a blocked sibling harness must not mask a measured content failure in a
# healthy one. want() previously judged blocked against the union of all four.
rm -rf "$FX/attrib"; mkdir -p "$FX/attrib"
cat > "$FX/attrib/probe.sh" <<'SNIP'
declare -A HOUT HRC
HOUT[pairs]="pairs: 1830"; HRC[pairs]=0
HOUT[safe]="Error [ERR_MODULE_NOT_FOUND]: Cannot find module"; HRC[safe]=1
fail=0; blkd=0
blocked_out() { printf '%s' "$1" | grep -qE 'ERR_MODULE_NOT_FOUND|Cannot find module'; }
want () {
  local h="$3" out rc
  out="${HOUT[$h]}"; rc="${HRC[$h]:-1}"
  if printf '%s' "$out" | grep -qE "$2"; then echo "ok $1"
  elif [ "${rc:-1}" != "0" ] && blocked_out "$out"; then echo "BLOCKED $1"; blkd=1
  else echo "FAIL $1"; fail=1; fi
}
want "healthy harness, wrong number" 'pairs: 9999' pairs
want "genuinely blocked harness"     'EVERY other' safe
SNIP
aout=$(bash "$FX/attrib/probe.sh" 2>&1)
want_has "attribution: a wrong number in a healthy harness is FAIL" "$aout" "FAIL healthy harness"
want_has "attribution: the blocked harness is BLOCKED"              "$aout" "BLOCKED genuinely blocked"

# F5: loop2gate's sentinel must be as strong as gate.sh's
rm -rf "$FX/fake2"
mkdir -p "$FX/fake2/paper" "$FX/fake2/corpus50/lanes" "$FX/fake2/formal/v3"
echo "hello atlas" > "$FX/fake2/paper/atlas.tex"
echo '{}' > "$FX/fake2/corpus50/lanes/x.json"
cp formal/v3/loop2gate.sh "$FX/fake2/formal/v3/loop2gate.sh"
out=$(cd "$FX/fake2/formal/v3" && bash ./loop2gate.sh 2>&1); rc=$?
want_rc  "loop2gate sentinel: look-alike tree is blocked" 3 "$rc"
want_not "loop2gate sentinel: emits no corpus verdict"    "$out" "FAIL 61 of 72"

echo
echo "===== 3f. the inline blocked_out sites are inverted too ====="
# chk() was inverted last round; the three inline sites were not, and they are
# the only checks actually blocked today.
gs=$(cat formal/v3/gate.sh)
for needle in "109-claim checker" "smoke" "graph claims"; do
  # the expected-string grep must appear BEFORE the blocked_out call in each block
  blk=$(printf '%s' "$gs" | grep -n "BLOCKED $needle" | head -1 | cut -d: -f1)
  okl=$(printf '%s' "$gs" | grep -n "ok   $needle" | head -1 | cut -d: -f1)
  if [ -n "$blk" ] && [ -n "$okl" ] && [ "$okl" -lt "$blk" ]; then
    caught "inline inversion: $needle tests the expected string first"
  else
    missed "inline inversion: $needle still tests blocked_out first"
  fi
done

echo
echo "===== 3g. validate.mjs prints no vacuous result line ====="
rm -rf "$FX/vspecs"; mkdir -p "$FX/vspecs"
vout=$(node formal/v3/validate.mjs "$FX/vspecs" 2>&1); vrc=$?
want_rc  "validate: empty dir exit code" 3 "$vrc"
want_not "validate: no '0 specs, 0 rejected' line" "$vout" "0 specs, 0 rejected"
want_has "validate: says it was blocked"           "$vout" "BLOCKED"

echo
echo "===== 3c. blocked_out must not hide a content failure ====="
# blocked_out is a new lie in the opposite direction if it is over-broad: a
# harness that RAN and got the wrong answer, but whose output also carries a
# traceback, must read FAIL -- not BLOCKED.
. /dev/stdin <<'SNIP'
blocked_out() {
  printf '%s' "$1" | grep -qE 'Error: (EACCES|ENOENT)|ERR_MODULE_NOT_FOUND|Cannot find module|(PermissionError|FileNotFoundError|ModuleNotFoundError): \[?Errno|^totalgate: BLOCKED|GATE BLOCKED'
}
SNIP
if blocked_out "Traceback (most recent call last):
  File x
ValueError: computed 60 of 72"; then
  missed "blocked_out hides a content failure that merely traced back"
else
  caught "blocked_out does not hide a bare traceback"
fi
if blocked_out "PermissionError: [Errno 13] Permission denied: '/root/x'"; then
  caught "blocked_out still recognises a real PermissionError"
else
  missed "blocked_out no longer recognises a real PermissionError"
fi
if blocked_out "pairs: 1830   BLOCKED-looking word in normal output"; then
  missed "blocked_out trips on the bare word BLOCKED in ordinary output"
else
  caught "blocked_out ignores the bare word BLOCKED in ordinary output"
fi

echo
echo "===== 4. vacuity guards on the other gates ====="

rm -rf "$FX/emptyir"; mkdir -p "$FX/emptyir"
python3 research/positive-program/sigma/gate33_cert_check.py >/dev/null 2>&1; rc=$?
want_rc "gate33 control: real IR" 0 "$rc"
GEN_IR="$FX/emptyir" python3 research/positive-program/sigma/gate33_cert_check.py >/dev/null 2>&1; rc=$?
want_rc "gate33 VACUOUS: empty IR" 3 "$rc"
if [ -f "$FX/emptyir/GATE-3.3-CERT-RESULT.json" ]; then
  missed "gate33 wrote a PASS artefact on an empty IR"
else
  caught "gate33 wrote no artefact on an empty IR"
fi

rm -rf "$FX/emptyrepo"; mkdir -p "$FX/emptyrepo/expansion"
timeout 300 python3 research/positive-program/sigma/verify_final.py >/dev/null 2>&1; rc=$?
want_rc "verify_final control: real corpus" 0 "$rc"
DEFIFORMAL_ROOT="$FX/emptyrepo" python3 research/positive-program/sigma/verify_final.py >/dev/null 2>&1; rc=$?
want_rc "verify_final VACUOUS: empty corpus" 3 "$rc"

# validate.mjs is blocked in-tree by formal/v2/tables.mjs, which hardcodes
# /root/DefiElements. That root fix is out of scope for this change, so the
# guard is present but NOT demonstrable here. Recorded, not claimed.
rm -rf "$FX/emptyspecs"; mkdir -p "$FX/emptyspecs"
vout=$(node formal/v3/validate.mjs "$FX/emptyspecs" 2>&1); vrc=$?
if printf '%s' "$vout" | grep -q 'EACCES'; then
  printf '  BLOCKED validate.mjs vacuity guard NOT demonstrated -- blocked by\n'
  printf '          formal/v2/tables.mjs hardcoded root (out of scope here)\n'
else
  want_rc "validate.mjs VACUOUS: empty dir" 3 "$vrc"
fi

echo
printf '\n===== negtest-reporting: %d caught, %d missed =====\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
