#!/usr/bin/env bash
# Build the paper. Twice, so cross-references and the theorem numbering settle.
set -euo pipefail
cd "$(dirname "$0")"
for i in 1 2; do
  pdflatex -interaction=nonstopmode -halt-on-error atlas.tex >/dev/null
done
echo "atlas.pdf: $(pdfinfo atlas.pdf 2>/dev/null | awk '/^Pages/{print $2}') pages, $(stat -c%s atlas.pdf) bytes"
grep -c '\\begin{theorem}\|\\begin{proposition}\|\\begin{corollary}' atlas.tex \
  | xargs printf 'proved items:      %s\n'
grep -c '\\begin{measurement}' atlas.tex | xargs printf 'measurements:      %s\n'
grep -c '\\begin{conjecture}'  atlas.tex | xargs printf 'open conjectures:  %s\n'
