#!/bin/bash
# Round five, blocker 7: the gates must fail on the manuscript errors they claim
# to detect. claims.mjs asserts 109 category claims and has never been shown to
# fail. Neither had verify-graphs.py, and neither had the emission invariant --
# which was passing while verifying nothing.
#
# Four perturbations of the kind the checker exists to catch, each restored.
set -uo pipefail
cd /root/defiformal || exit 9
cp paper/atlas.tex /root/.atlas.claims.bak

run () { node formal/v3/claims.mjs 2>&1 | tail -1; }
report () {
  case "$2" in
    *", 0 failed"*) echo "  MISSED  $1  -> $2" ;;
    *)              echo "  CAUGHT  $1  -> $2" ;;
  esac
}

echo "baseline: $(run)"
echo

perturb () {  # sed-expression, label
  cp /root/.atlas.claims.bak paper/atlas.tex
  python3 - "$1" <<'PY'
import io, sys, re
p = "/root/defiformal/paper/atlas.tex"
s = io.open(p, encoding="utf-8").read()
old, new = sys.argv[1].split("=>")
if old not in s:
    print("   (anchor %r absent)" % old[:40]); raise SystemExit(3)
io.open(p, "w", encoding="utf-8", newline="\n").write(s.replace(old, new, 1))
PY
  report "$2" "$(run)"
}

# a category table row: bridges 25 discharged -> 26
perturb 'Bridges & 11 & 89 & 25 & 64 & 3=>Bridges & 11 & 89 & 26 & 64 & 3' "bridges discharged 25 -> 26"

# an obligation total
perturb '$1{,}259$=>$1{,}260$' "obligation total 1,259 -> 1,260"

# a coverage percentage
perturb '45.3\%=>45.4\%' "coverage 45.3% -> 45.4%"

# a residue count
perturb '689 residue=>690 residue' "residue 689 -> 690"

cp /root/.atlas.claims.bak paper/atlas.tex
rm -f /root/.atlas.claims.bak
echo
echo "restored: $(run)"
