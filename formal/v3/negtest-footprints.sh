#!/bin/bash
# Negative control for verify-footprints.mjs. An earlier attempt did not apply
# its perturbation and reported VERIFIED, which is indistinguishable from a
# checker that cannot fail. Assert the edit landed before believing the result.
set -uo pipefail
cd /root/defiformal || exit 9
cp paper/atlas.tex /root/.foot.bak

echo "the row as written:"
grep -n 'Bridges & 17' paper/atlas.tex | head -2

python3 - <<'PY'
import io, sys
p = "/root/defiformal/paper/atlas.tex"
s = io.open(p, encoding="utf-8").read()
before = s.count("Bridges & 17")
if before == 0:
    print("PERTURBATION DID NOT APPLY: anchor absent"); sys.exit(3)
s = s.replace("Bridges & 17", "Bridges & 18", 1)
io.open(p, "w", encoding="utf-8", newline="\n").write(s)
after = io.open(p, encoding="utf-8").read().count("Bridges & 18")
print(f"perturbation applied: {before} occurrence(s) of 'Bridges & 17' -> 'Bridges & 18' now {after}")
PY

out=$(node formal/v3/verify-footprints.mjs 2>&1)
echo "$out" | grep -E 'Bridges|VIOLATED|VERIFIED'
case "$out" in
  *VIOLATED*) echo "NEGATIVE CONTROL PASSED" ;;
  *)          echo "NEGATIVE CONTROL FAILED: the checker did not notice" ;;
esac

cp /root/.foot.bak paper/atlas.tex
rm -f /root/.foot.bak
echo "restored: $(node formal/v3/verify-footprints.mjs 2>&1 | tail -1)"
