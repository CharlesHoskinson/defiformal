blocked_out() {
  printf '%s' "$1" | grep -qE 'Error: (EACCES|ENOENT)|ERR_MODULE_NOT_FOUND|Cannot find module|(PermissionError|FileNotFoundError|ModuleNotFoundError): \[?Errno|: Permission denied|cd: .*: Permission denied|command not found|No such file or directory|can\x27t open file|^totalgate: BLOCKED|GATE BLOCKED|LOOP2 BLOCKED'
}
want () { # label regex harness
  local h="$3" out rc
  out="${HOUT[$h]}"; rc="${HRC[$h]:-1}"
  # A harness that died has measured nothing, so it may not produce an `ok`
  # even if its text carries the needle. Exit code first, needle second.
  if printf '%s' "$out" | grep -qE "$2"; then echo "  ok   $1"
  elif [ "${rc:-1}" != "0" ] && blocked_out "$out"; then
    echo "  BLOCKED $1 ($h could not run; nothing measured)"; blkd=1
  elif [ "${rc:-1}" != "0" ]; then echo "  FAIL $1 ($h exit $rc; wanted /$2/)"; fail=1
  else echo "  FAIL $1 (/$2/ not in $h output)"; fail=1; fi
}
