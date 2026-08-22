#!/usr/bin/env python3
r"""Every "<Kind>~\ref{label}" must name the environment its label sits in.

A defect this catches and no LaTeX pass can: atlas.tex called conj:frag a
Measurement at two cross-references. Both halves are well formed, so
`undefined references: 0` is reported either way -- the kind is wrong, and
nothing in the toolchain has an opinion about the kind.

Referee A raised the class once, as corpus computations labelled Proposition,
and it was actioned at the definition sites only. The references were never
checked.

Exit codes follow the convention the rest of formal/v3 uses:
  0  every cross-reference names its target's environment
  1  at least one does not -- act on the manuscript
  3  the check could not run -- act on the environment
"""
import os
import pathlib
import re
import sys

_SELF = pathlib.Path(__file__).resolve().parents[2]
_REPO = pathlib.Path(os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    print("xref-kinds.py: NOTE - reading %s (DEFIFORMAL_ROOT), not %s" % (_REPO, _SELF),
          file=sys.stderr)

KIND = {"measurement": "Measurement", "conjecture": "Conjecture",
        "proposition": "Proposition", "theorem": "Theorem", "lemma": "Lemma",
        "corollary": "Corollary", "definition": "Definition", "remark": "Remark",
        "example": "Example"}
NAMES = set(KIND.values())

TARGETS = ["paper/atlas.tex", "paper/supplement.tex"]

bad, checked, refs = [], 0, 0
ran = False
for rel in TARGETS:
    p = _REPO / rel
    if not p.exists():
        continue
    ran = True
    tex = p.read_text(encoding="utf-8")

    # label -> the environment open when it was declared
    env_of, stack = {}, []
    for m in re.finditer(r"\\(begin|end)\{([a-z]+)\}|\\label\{([^}]+)\}", tex):
        if m.group(1) == "begin":
            stack.append(m.group(2))
        elif m.group(1) == "end":
            if stack:
                stack.pop()
        elif m.group(3) and stack:
            env_of.setdefault(m.group(3), stack[-1])
    checked += len(env_of)

    for m in re.finditer(r"([A-Z][a-z]+)~\\ref\{([^}]+)\}", tex):
        said, lab = m.group(1), m.group(2)
        if said not in NAMES:
            continue
        refs += 1
        want = KIND.get(env_of.get(lab, ""))
        if want and said != want:
            bad.append((rel, tex[:m.start()].count("\n") + 1, said, lab, want))

if not ran:
    print("xref-kinds: BLOCKED - no manuscript found under %s" % _REPO, file=sys.stderr)
    raise SystemExit(3)
if checked == 0:
    print("xref-kinds: BLOCKED - no labelled environments parsed; nothing was checked",
          file=sys.stderr)
    raise SystemExit(3)

for rel, line, said, lab, want in bad:
    print("  FAIL %s:%d says %s where %s is a %s" % (rel, line, said, lab, want))

print("xref-kinds: %d labelled environments, %d typed cross-references, %d mismatched"
      % (checked, refs, len(bad)))
raise SystemExit(1 if bad else 0)
