#!/bin/bash
# The demonstration that motivates verify-cattable.mjs: the same perturbation put
# to both checkers. claims.mjs recomputes from the corpus and never opens the
# paper, so it cannot see a table cell change.
set -uo pipefail
cd /root/defiformal || exit 9
cp paper/atlas.tex /root/.atlas.ct.bak

python3 - <<'PY'
import io
p = "/root/defiformal/paper/atlas.tex"
s = io.open(p, encoding="utf-8").read()
io.open(p, "w", encoding="utf-8", newline="\n").write(
    s.replace("Bridges & 11 & 89 & 25 & 64 & 3", "Bridges & 11 & 89 & 26 & 64 & 3", 1))
PY

echo "perturbation: bridges discharged 25 -> 26"
a=$(node formal/v3/verify-cattable.mjs 2>&1 | tail -1)
b=$(node formal/v3/claims.mjs 2>&1 | tail -1)
echo "  verify-cattable: $a"
echo "  claims.mjs     : $b"

cp /root/.atlas.ct.bak paper/atlas.tex
rm -f /root/.atlas.ct.bak
c=$(node formal/v3/verify-cattable.mjs 2>&1 | tail -1)
echo "restored: $c"
