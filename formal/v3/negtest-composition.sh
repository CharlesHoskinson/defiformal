#!/bin/bash
# Negative control for verify-composition.mjs, asserting the perturbation landed
# before believing the verdict: a control that silently fails to apply is
# indistinguishable from a checker that cannot fail.
set -uo pipefail
cd /root/defiformal || exit 9
cp paper/atlas.tex /root/.comp.bak

python3 - <<'PY'
import io, sys
p = "/root/defiformal/paper/atlas.tex"
s = io.open(p, encoding="utf-8").read()
old, new = "Intents & 8/8 & 0--23 & 6 & 0", "Intents & 8/8 & 0--23 & 5 & 0"
if old not in s:
    print("PERTURBATION DID NOT APPLY: anchor absent"); sys.exit(3)
io.open(p, "w", encoding="utf-8", newline="\n").write(s.replace(old, new, 1))
print("perturbation applied: intents universal 6 -> 5")
PY

out=$(node formal/v3/verify-composition.mjs 2>&1)
echo "$out" | grep -E 'Intents|VIOLATED|VERIFIED'
case "$out" in
  *VIOLATED*) echo "NEGATIVE CONTROL PASSED" ;;
  *)          echo "NEGATIVE CONTROL FAILED: the checker did not notice" ;;
esac

cp /root/.comp.bak paper/atlas.tex
rm -f /root/.comp.bak
echo "restored: $(node formal/v3/verify-composition.mjs 2>&1 | tail -1)"
