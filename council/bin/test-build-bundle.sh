#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
pass=0; fail=0
want () { if [ "$2" = "$3" ]; then echo "  ok   $1"; pass=$((pass+1));
          else echo "  FAIL $1 (want $3, got $2)"; fail=$((fail+1)); fi; }

python3 council/bin/build-bundle.py >/dev/null 2>&1
# A stale committed bundle stays on disk if the builder fails (e.g. a
# manuscript edit detaches an anchor and the builder exits 3 without
# writing). Every assertion below would then validate that stale file and
# report green -- the exact vacuous-check failure this repo has been
# eliminating elsewhere. Check the builder's own exit status, not just the
# artifact it may or may not have written.
want "builder exit 0 (initial run)" "$?" "0"
B=council/sprint1/BUNDLE-blinded.md

want "bundle exists"          "$([ -s "$B" ] && echo y || echo n)" "y"
want "candidate A present"    "$(grep -c 'CANDIDATE A' "$B")" "1"
want "candidate B present"    "$(grep -c 'CANDIDATE B' "$B")" "1"
want "candidate C present"    "$(grep -c 'CANDIDATE C' "$B")" "1"
want "residue figure 689"     "$(grep -c '689' "$B")" "1"
# CANDIDATE C used to restate 1830/1645/185 in a hand-written paragraph
# duplicating the extracted one; that paragraph is gone (see build-bundle.py),
# so the only surviving form of this figure is the extracted text's own
# "1,830" (strip_tex turns the manuscript's "1{,}830" into "1,830", comma
# kept). Check that form directly -- the bare digits "1830" no longer
# appear anywhere in the bundle, by design.
want "pairs figure 1,830"     "$(grep -c '1,830' "$B")" "1"
# The bundle is plain prose for a language model: any surviving backslash is
# a LaTeX-stripping defect by definition (escaped braces, \%, \$, \&, \_, ...),
# whatever construct produced it. This guards the whole class, not just the
# \{...\} case first observed in CANDIDATE A.
want "no stray backslashes"   "$(grep -c '\\' "$B")" "0"
# \begin{measurement}[Title] carries an internal title the bundle doesn't
# need (each candidate already has its own ## heading), and on a document
# whose cover page says author identity is sealed, a bracketed phrase
# standing alone on its own line reads as a redaction marker, not a title.
# It lands on both CANDIDATE A and CANDIDATE C -- the two candidates
# extracted from LaTeX (meas:perps and meas:pairs each carry one) -- so
# this is not a one-off, it's a structural asymmetry against the two
# LaTeX-sourced arms versus the hand-written B. Guard the class: no line
# may be nothing but a [...] label.
want "no bare bracketed lines" "$(grep -c '^\[.*\]$' "$B")" "0"
# Third instance of the same underlying class as the previous two guards:
# something mechanical from LaTeX extraction survives untranslated and
# marks exactly the LaTeX-sourced arms (A, C) as machine-produced, against
# this document's own "do not speculate about what produced this"
# instruction. Guard LaTeX residue generally rather than one construct at a
# time: a literal "---" (the em-dash convention -- extracted prose is
# normalised to a real em dash, and the frame's own section dividers use
# "***" instead, so this check has no legitimate match to exclude), a
# leftover "[ref]" placeholder, or a stray "~" tie are all things that would
# not appear in ordinary hand-written prose.
want "no LaTeX residue"       "$(grep -c -E -- '---|\[ref\]|~' "$B")" "0"
python3 council/bin/leak-check.py "$B" >/dev/null 2>&1
want "bundle passes leak check" "$?" "0"
want "sha recorded"           "$([ -s council/sprint1/BUNDLE.sha256 ] && echo y || echo n)" "y"
want "sha matches bundle"     "$(sha256sum "$B" | cut -d' ' -f1)" "$(cut -d' ' -f1 < council/sprint1/BUNDLE.sha256)"

# The bundle must be REGENERATED identically, or its hash means nothing.
h1=$(sha256sum "$B" | cut -d' ' -f1)
python3 council/bin/build-bundle.py >/dev/null 2>&1
want "builder exit 0 (regen run)" "$?" "0"
want "regenerates identically" "$(sha256sum "$B" | cut -d' ' -f1)" "$h1"

echo "build-bundle: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
