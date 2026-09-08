set -uo pipefail
pass=0; fail=0
caught () { printf '  CAUGHT  %s\n' "$1"; pass=$((pass+1)); }
missed () { printf '  MISSED  %s\n' "$1"; fail=$((fail+1)); }
want_not () { if printf '%s' "$2" | grep -qF -- "$3"; then missed "$1 -- $3 present"; else caught "$1"; fi; }
want_has () { if printf '%s' "$2" | grep -qF -- "$3"; then caught "$1"; else missed "$1 -- $3 absent"; fi; }
FX="/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p13-review/targeted/intact-assertions"
if [ ! -s "$FX/attrib/fns.sh" ]; then
  missed "want() rc=0 lock: attrib/fns.sh missing; want() was not invoked"
else
  cat > "$FX/w_rc.sh" <<SNIP
declare -A HOUT HRC
HOUT[pairs]="pairs: 1830"; HRC[pairs]=7
fail=0; blkd=0
. "$FX/attrib/fns.sh"
want "died but printed the needle" 'pairs: 1830' pairs
SNIP
  wout=$(bash "$FX/w_rc.sh" 2>&1)
  want_not "want() rc=0 lock did not collapse to a missing lift" "$wout" "No such file or directory"
  want_not "want() rc=0 lock did not collapse to command-not-found" "$wout" "command not found"
  want_not "want(): a dead harness is not ok on a stray needle" "$wout" "  ok   died but printed"
  want_has "want(): a dead harness with a stray needle is FAIL" "$wout" "  FAIL died but printed"
fi


[ "$fail" -eq 0 ]
