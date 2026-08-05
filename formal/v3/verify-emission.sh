#!/usr/bin/env bash
# The emission invariant: every subsection block in the paper must be byte-equal
# to what emit-tex.mjs produces from the specs and verdicts. A difference means
# the paper has been hand-edited and a figure may no longer match its
# computation. Council pass 2 found one by hand; this finds it mechanically.
set -uo pipefail
cd /root/defiformal
TEX=paper/atlas.tex
fail=0

for slug in $(ls expansion | grep -E '^[0-9]{2}-'); do
  specs="expansion/$slug/specs"; verd="expansion/$slug/verdicts.json"
  [ -d "$specs" ] && [ -f "$verd" ] || continue
  node formal/v3/emit-tex.mjs "$specs" "$verd" > /tmp/emit.tex 2>/dev/null || { echo "FAIL $slug: emitter errored"; fail=1; continue; }

  first=$(grep -m1 -oE '\\subsection\{[^}]*\}\\label\{[^}]*\}' /tmp/emit.tex)
  [ -n "$first" ] || { echo "FAIL $slug: no subsection emitted"; fail=1; continue; }

  # the emitted block runs from its first subsection to the next \section
  python3 - "$slug" "$first" <<'PY'
import io, sys, re
slug, first = sys.argv[1], sys.argv[2]
tex = io.open("/root/defiformal/paper/atlas.tex", encoding="utf-8").read()
emit = io.open("/tmp/emit.tex", encoding="utf-8").read().strip()
i = tex.find(first)
if i < 0:
    print(f"FAIL {slug}: emitted block not present in the paper"); sys.exit(1)
j = tex.find("\\section{", i)
block = tex[i: j if j > 0 else len(tex)].strip()
if block == emit:
    print(f"ok   {slug}: {emit.count(chr(92)+'subsection{')} subsections byte-equal to the emitter")
    sys.exit(0)
# report the first differing line so a defect is locatable
a, b = emit.splitlines(), block.splitlines()
for n, (x, y) in enumerate(zip(a, b), 1):
    if x != y:
        print(f"FAIL {slug}: first difference at emitted line {n}")
        print(f"   emitter: {x[:110]}")
        print(f"   paper:   {y[:110]}")
        break
else:
    print(f"FAIL {slug}: paper block has {len(b)} lines, emitter {len(a)}")
sys.exit(1)
PY
  [ $? -eq 0 ] || fail=1
done

echo
[ $fail -eq 0 ] && echo "EMISSION INVARIANT HOLDS for all twelve categories" || echo "EMISSION INVARIANT VIOLATED"
exit $fail
