#!/usr/bin/env bash
# Discriminating probe for loop2gate want() rc=0 guard.
# Runs OUTSIDE the private candidate. Does not edit candidate source.
# Intact lift: dead harness + stray needle must be FAIL (not ok).
# Mutated lift (rc=0 guard removed): same fixture is wrongly ok.
set -uo pipefail
CAND=/home/charl/.cache/defiformal-program/honest-gate-clean-r2/candidate
HERE=/home/charl/.cache/defiformal-program/honest-gate-clean-r2/execution/want-rc0-mutant
rm -rf "$HERE/work"
mkdir -p "$HERE/work"
cd "$HERE/work"

lift () { # $1 = file, $2 = function name, $3 = dest  — same guards as the harness
  awk -v fn="$2" 'index($0, fn "()")==1 || index($0, fn " ()")==1 {inside=1}
                  inside {print}
                  inside && /^\}/ {exit}' "$1" > "$3"
  [ -s "$3" ] || return 1
  [ "$(tail -1 "$3")" = "}" ] || return 1
  [ "$(grep -cE '^[A-Za-z_][A-Za-z0-9_]* *\(\) *\{' "$3")" = "1" ] || return 1
  grep -qE '^(echo|one |want "|chk "|===== |[a-z]+=\$\()' "$3" && return 1
  return 0
}

cp "$CAND/formal/v3/loop2gate.sh" intact-loop2gate.sh
# Mutant: drop the rc=0 conjunct so a dead harness that printed the needle is ok.
python3 - <<'PY'
from pathlib import Path
p = Path("intact-loop2gate.sh")
s = p.read_text()
old = '''if [ "${rc:-1}" = "0" ] && printf '%s' "$out" | grep -qE "$2"; then echo "  ok   $1"'''
new = '''if printf '%s' "$out" | grep -qE "$2"; then echo "  ok   $1"'''
if old not in s:
    raise SystemExit("PERTURBATION DID NOT APPLY: rc=0 conjunct absent")
Path("mutated-loop2gate.sh").write_text(s.replace(old, new, 1))
PY

: > intact-fns.sh
: > mutated-fns.sh
for fn in blocked_out want; do
  lift intact-loop2gate.sh "$fn" one.sh || { echo "LIFT_FAIL intact $fn"; exit 2; }
  cat one.sh >> intact-fns.sh
  lift mutated-loop2gate.sh "$fn" one.sh || { echo "LIFT_FAIL mutated $fn"; exit 2; }
  cat one.sh >> mutated-fns.sh
done

# Same fixture as the repaired harness (i) probe.
write_probe () {
  local fns="$1" dest="$2"
  cat > "$dest" <<SNIP
declare -A HOUT HRC
HOUT[pairs]="pairs: 1830"; HRC[pairs]=7
fail=0; blkd=0
. "$PWD/$fns"
want "died but printed the needle" 'pairs: 1830' pairs
SNIP
}

write_probe intact-fns.sh intact-probe.sh
write_probe mutated-fns.sh mutated-probe.sh

intact_out=$(bash ./intact-probe.sh 2>&1); intact_rc=$?
mut_out=$(bash ./mutated-probe.sh 2>&1); mut_rc=$?

printf 'INTACT_BEGIN\n%s\nINTACT_END\nINTACT_RC=%s\n' "$intact_out" "$intact_rc"
printf 'MUTATED_BEGIN\n%s\nMUTATED_END\nMUTATED_RC=%s\n' "$mut_out" "$mut_rc"

judge () {
  local name="$1" out="$2"
  local has_ok=no has_fail=no missing=no cnf=no
  printf '%s' "$out" | grep -qF -- "  ok   died but printed" && has_ok=yes
  printf '%s' "$out" | grep -qF -- "  FAIL died but printed" && has_fail=yes
  printf '%s' "$out" | grep -qF -- "No such file or directory" && missing=yes
  printf '%s' "$out" | grep -qF -- "command not found" && cnf=yes
  printf '%s_HAS_OK=%s\n%s_HAS_FAIL=%s\n%s_MISSING_FILE=%s\n%s_COMMAND_NOT_FOUND=%s\n' \
    "$name" "$has_ok" "$name" "$has_fail" "$name" "$missing" "$name" "$cnf"
}

judge INTACT "$intact_out"
judge MUTATED "$mut_out"

# Designated repaired checks:
# intact: want_not ok AND want_has FAIL  → sibling/control passes
# mutated: want_not ok would MISSED (ok present); want_has FAIL would MISSED
if printf '%s' "$intact_out" | grep -qF -- "  FAIL died but printed" \
   && ! printf '%s' "$intact_out" | grep -qF -- "  ok   died but printed" \
   && ! printf '%s' "$intact_out" | grep -qF -- "command not found"; then
  echo INTACT_DESIGNATED=PASS
else
  echo INTACT_DESIGNATED=FAIL
fi
if printf '%s' "$mut_out" | grep -qF -- "  ok   died but printed" \
   && ! printf '%s' "$mut_out" | grep -qF -- "  FAIL died but printed" \
   && ! printf '%s' "$mut_out" | grep -qF -- "command not found"; then
  echo MUTATED_DESIGNATED=FAILS_AS_REQUIRED
else
  echo MUTATED_DESIGNATED=DID_NOT_EXHIBIT_DEFECT
fi

# Save function bodies for the evidence record
cp intact-fns.sh "$HERE/intact-fns.sh"
cp mutated-fns.sh "$HERE/mutated-fns.sh"
cp intact-probe.sh "$HERE/intact-probe.sh"
cp mutated-probe.sh "$HERE/mutated-probe.sh"
diff -u intact-loop2gate.sh mutated-loop2gate.sh > "$HERE/want-rc0-removal.diff" || true
