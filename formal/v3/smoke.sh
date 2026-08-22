#!/usr/bin/env bash
# Every entry point, every run. The library passing is not evidence the CLI works:
# a field rename once broke the CLI while all 22 library assertions stayed green.
#
# Note: these tools exit non-zero BY DESIGN when they reject input, so output is
# captured and then matched. Piping into grep under `pipefail` would report the
# tool's intentional failure as a smoke failure.
set -uo pipefail
cd "$(dirname "$0")"
fail=0
step() { printf '\n--- %s\n' "$1"; }
ok()   { printf 'ok   %s\n' "$1"; }
bad()  { printf 'FAIL %s\n' "$1"; fail=1; }
has()  { printf '%s' "$1" | grep -q -- "$2"; }

step "selftest: the checker reproduces the paper's published numbers"
out=$(node selftest.mjs 2>&1)
if has "$out" ' 0 failed'; then ok "selftest"; else bad "selftest"; printf '%s\n' "$out" | tail -5; fi

step "validate: a well-formed spec is accepted"
out=$(node validate.mjs fixtures 2>&1)
if has "$out" '^ok ' && ! has "$out" 'FAIL'; then ok "validate accepts"; else bad "validate accepts"; printf '%s\n' "$out"; fi

tmp=$(mktemp -d)
cat > "$tmp/broken.json" <<'JSON'
{"app":"broken","category":"test","construction":["Pl","Rate"],
 "functionalObligations":[{"id":"F1","text":"short","elements":["Rate"]}]}
JSON

step "validate: a malformed spec is rejected"
out=$(node validate.mjs "$tmp" 2>&1)
if has "$out" 'not elements of the 58'; then ok "validate rejects"; else bad "validate rejects"; printf '%s\n' "$out"; fi

step "construct: the CLI produces a verdict"
out=$(node construct.mjs fixtures --json "$tmp/verdicts.json" 2>&1)
if has "$out" 'PARTIAL'; then ok "construct CLI"; else bad "construct CLI"; printf '%s\n' "$out"; fi

step "construct: the CLI refuses a malformed spec instead of scoring it"
out=$(node construct.mjs "$tmp" 2>&1)
if has "$out" 'REJECTED'; then ok "construct CLI rejects"; else bad "construct CLI rejects"; printf '%s\n' "$out"; fi

step "emit-tex: the CLI produces a subsection from the verdict"
out=$(node emit-tex.mjs fixtures "$tmp/verdicts.json" 2>&1)
if has "$out" 'begin{measurement}' && has "$out" 'mathrm{ex}'; then ok "emit-tex CLI"; else bad "emit-tex CLI"; printf '%s\n' "$out"; fi

step "emit-tex: a spec with no verdict fails loudly rather than emitting a gap"
cp "$tmp/broken.json" fixtures/zz-tmp-broken.json
out=$(node emit-tex.mjs fixtures "$tmp/verdicts.json" 2>&1 >/dev/null)
if has "$out" 'NO VERDICT'; then ok "emit-tex fails loud"; else bad "emit-tex fails loud"; printf '%s\n' "$out"; fi
rm -f fixtures/zz-tmp-broken.json
rm -rf "$tmp"

step "negtest-reporting: the reporters distinguish a false property from a blocked check"
out=$(bash negtest-reporting.sh 2>&1 | tail -1)
if has "$out" '0 missed'; then ok "reporting polarities"; else bad "reporting polarities"; printf '%s\n' "$out"; fi

printf '\n%s\n' "$([ $fail -eq 0 ] && echo 'SMOKE OK' || echo 'SMOKE FAILED')"
exit $fail
