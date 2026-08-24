#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
pass=0; fail=0
want () { if [ "$2" = "$3" ]; then echo "  ok   $1"; pass=$((pass+1));
          else echo "  FAIL $1 (want $3, got $2)"; fail=$((fail+1)); fi; }

python3 council/bin/build-bundle.py >/dev/null 2>&1
B=council/sprint1/BUNDLE-blinded.md

want "bundle exists"          "$([ -s "$B" ] && echo y || echo n)" "y"
want "candidate A present"    "$(grep -c 'CANDIDATE A' "$B")" "1"
want "candidate B present"    "$(grep -c 'CANDIDATE B' "$B")" "1"
want "candidate C present"    "$(grep -c 'CANDIDATE C' "$B")" "1"
# strip_tex turns the manuscript's "1{,}830" into "1,830" (comma kept), so it
# never collides with the bare "1830" written into the bundle frame below —
# if strip_tex is ever changed to also strip commas, this assertion will
# start failing for a reason that is invisible without this comment.
want "residue figure 689"     "$(grep -c '689' "$B")" "1"
want "pairs figure 1830"      "$(grep -c '1830' "$B")" "1"
# The bundle is plain prose for a language model: any surviving backslash is
# a LaTeX-stripping defect by definition (escaped braces, \%, \$, \&, \_, ...),
# whatever construct produced it. This guards the whole class, not just the
# \{...\} case first observed in CANDIDATE A.
want "no stray backslashes"   "$(grep -c '\\' "$B")" "0"
python3 council/bin/leak-check.py "$B" >/dev/null 2>&1
want "bundle passes leak check" "$?" "0"
want "sha recorded"           "$([ -s council/sprint1/BUNDLE.sha256 ] && echo y || echo n)" "y"
want "sha matches bundle"     "$(sha256sum "$B" | cut -d' ' -f1)" "$(cut -d' ' -f1 < council/sprint1/BUNDLE.sha256)"

# The bundle must be REGENERATED identically, or its hash means nothing.
h1=$(sha256sum "$B" | cut -d' ' -f1)
python3 council/bin/build-bundle.py >/dev/null 2>&1
want "regenerates identically" "$(sha256sum "$B" | cut -d' ' -f1)" "$h1"

echo "build-bundle: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
