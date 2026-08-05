#!/bin/bash
# Negative control for verify-measurements.mjs, asserting each perturbation
# landed before believing the verdict.
set -uo pipefail
cd /root/defiformal || exit 9
cp paper/atlas.tex /root/.meas.bak

try () {
  cp /root/.meas.bak paper/atlas.tex
  python3 - "$1" <<'PY'
import io, sys
p = "/root/defiformal/paper/atlas.tex"
s = io.open(p, encoding="utf-8").read()
old, new = sys.argv[1].split("=>")
if old not in s:
    print("  PERTURBATION DID NOT APPLY: %r absent" % old); sys.exit(3)
io.open(p, "w", encoding="utf-8", newline="\n").write(s.replace(old, new, 1))
PY
  out=$(node formal/v3/verify-measurements.mjs 2>&1)
  case "$out" in
    *VIOLATED*) echo "  CAUGHT  $2" ;;
    *)          echo "  MISSED  $2" ;;
  esac
}

echo "baseline: $(node formal/v3/verify-measurements.mjs 2>&1 | tail -1)"
echo
try '$147$ arm=>$148$ arm'                     "X21 failures 147 -> 148"
try '$1{,}645$ compose=>$1{,}646$ compose'      "composing pairs 1,645 -> 1,646"
try 'Twenty of the=>Nineteen of the'            "universal twenty -> nineteen (word form)"

cp /root/.meas.bak paper/atlas.tex
rm -f /root/.meas.bak
echo
echo "restored: $(node formal/v3/verify-measurements.mjs 2>&1 | tail -1)"
