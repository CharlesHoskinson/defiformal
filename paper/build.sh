#!/usr/bin/env bash
# Build the paper. Fails LOUDLY: a silent compile failure once let two whole
# sections sit unrendered while a stale PDF kept being exported.
set -uo pipefail
cd "$(dirname "$0")"

die() { printf '\n\033[1;31mBUILD FAILED\033[0m: %s\n' "$1" >&2; exit 1; }

run_tex() {
  local pass="$1" log
  log=$(pdflatex -interaction=nonstopmode -halt-on-error atlas.tex 2>&1) || {
    printf '\n\033[1;31m=== pdflatex pass %s FAILED ===\033[0m\n' "$pass" >&2
    printf '%s\n' "$log" | grep -E '^(!|l\.[0-9]+)' | head -20 >&2
    die "pdflatex pass $pass"
  }
}

before=$(stat -c %Y atlas.pdf 2>/dev/null || echo 0)

run_tex 1
bibtex atlas >/dev/null 2>&1 || printf '\033[1;33mwarning\033[0m: bibtex reported a problem\n' >&2
run_tex 2
run_tex 3

[ -f atlas.pdf ] || die "no atlas.pdf produced"
after=$(stat -c %Y atlas.pdf)
[ "$after" -gt "$before" ] || die "atlas.pdf was not rewritten (stale artefact)"

# unresolved references are silent poison in a paper that cross-references heavily
undef=$(grep -c 'undefined' atlas.log 2>/dev/null || true)
[ "${undef:-0}" -eq 0 ] || {
  printf '\n\033[1;31m=== %s UNDEFINED REFERENCE(S) ===\033[0m\n' "$undef" >&2
  grep 'undefined' atlas.log | head -12 >&2
  die "undefined references"
}

pages=$(pdfinfo atlas.pdf 2>/dev/null | awk '/^Pages/{print $2}')
printf '\033[1;32mOK\033[0m  atlas.pdf: %s pages, %s bytes\n' "${pages:-?}" "$(stat -c%s atlas.pdf)"
printf 'proved items:      %s\n' "$(grep -c '\\begin{theorem}\|\\begin{proposition}\|\\begin{corollary}\|\\begin{lemma}' atlas.tex)"
printf 'measurements:      %s\n' "$(grep -c '\\begin{measurement}' atlas.tex)"
printf 'open conjectures:  %s\n' "$(grep -c '\\begin{conjecture}' atlas.tex)"

# the standing instruction: the paper is a result, not a changelog
leak=$(grep -cE 'earlier version|retract|CORRECTED|previously claimed|withdrawn' atlas.tex || true)
[ "${leak:-0}" -eq 0 ] || die "$leak changelog phrase(s) in atlas.tex - the paper is a result, not a changelog"
