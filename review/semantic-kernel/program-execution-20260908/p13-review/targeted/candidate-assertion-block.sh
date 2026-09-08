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

