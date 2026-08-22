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
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/b2" ./paper/build.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g'); rc=${PIPESTATUS[0]}
chmod 755 "$FX/b2/expansion"
want_has "build BLOCKED: says the totals were not checked" "$out" "were NOT checked"
want_not "build BLOCKED: does NOT say a total disagrees"   "$out" "a headline total disagrees"
want_has "build BLOCKED: surfaces the gate diagnosis"      "$out" "EACCES"

# --- 2b. VIOLATED through build.sh --------------------------------------
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/violated" ./paper/build.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
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
out=$(cd "$FX/orphan" && bash ./gate.sh 2>&1 | head -20); rc=$?
want_not "gate.sh emits no corpus verdict when blocked" "$out" "FAIL 61 of 72"

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
