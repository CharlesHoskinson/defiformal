#!/bin/bash
# Would verify-setclaims.mjs have caught the false H witness that five review
# rounds and thirteen checkers missed? Put it back and see.
set -uo pipefail
cd /root/defiformal || exit 9
cp paper/atlas.tex /root/.atlas.bak

echo "baseline: $(node formal/v3/verify-setclaims.mjs 2>&1 | tail -1)"
echo

python3 - <<'PY'
import io
p = "/root/defiformal/paper/atlas.tex"
s = io.open(p, encoding="utf-8").read()
good = """$\\{Fl,Cp\\}$ and $\\{Pl\\}$ both lie in $\\mathcal{H}$, arming no
prohibition, while their union $\\{Cp,Fl,Pl\\}$ arms $X2$."""
bad = """$\\{Cd,Cp,Fl,Im,Pl,St,Uc,Wg\\}$ and $\\{Bs,Cd,Cl,Sl,Uc,Wg\\}$ lie in $\\mathcal{H}$
while their union covers $X2$."""
assert good in s, "current witness not found"
io.open(p, "w", encoding="utf-8", newline="\n").write(s.replace(good, bad, 1))
print("restored the false witness the review found")
PY

out=$(node formal/v3/verify-setclaims.mjs 2>&1)
echo "$out" | tail -4
case "$out" in
  *VIOLATED*) echo "NEGATIVE CONTROL PASSED: the false witness is caught" ;;
  *)          echo "NEGATIVE CONTROL FAILED: it would still have slipped through" ;;
esac

cp /root/.atlas.bak paper/atlas.tex
rm -f /root/.atlas.bak
echo
echo "restored: $(node formal/v3/verify-setclaims.mjs 2>&1 | tail -1)"
