"""The emission invariant.

The supplement is the canonical emitted artefact: all sixty profiles must appear
there byte-equal to what the emitter produces. The article carries four
abbreviated cases; for those the invariant is weaker but still binding — the
construction measurement, which holds every figure, must be byte-equal, and only
the enumerated residue may be elided.
"""
import io, os, re, subprocess, sys
import os as _os, pathlib as _pl, sys as _sys
# Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
_SELF = _pl.Path(__file__).resolve().parents[2]
_REPO = _pl.Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_pl.Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


ROOT = str(_REPO / "expansion")
V3 = str(_REPO / "formal/v3")
art = io.open(str(_REPO / "paper/atlas.tex"), encoding="utf-8").read()
sup = io.open(str(_REPO / "paper/supplement.tex"), encoding="utf-8").read()

emitted = {}
for slug in sorted(d for d in os.listdir(ROOT) if re.match(r"^\d\d-", d)):
    specs, verd = f"{ROOT}/{slug}/specs", f"{ROOT}/{slug}/verdicts.json"
    if not (os.path.isdir(specs) and os.path.exists(verd)):
        continue
    r = subprocess.run(["node", f"{V3}/emit-tex.mjs", specs, verd],
                       capture_output=True, text=True)
    assert r.returncode == 0, f"{slug}: emitter failed"
    for p in re.split(r"(?=\\subsection\{)", r.stdout.strip()):
        if not p.strip().startswith("\\subsection{"):
            continue
        lab = re.search(r"\\label\{(sub:cat:[^}]*)\}", p).group(1)
        emitted[lab] = p.strip()

bad = []
for lab, body in emitted.items():
    if body not in sup:
        bad.append(f"{lab}: not byte-equal in the supplement")

# The article carries four abbreviated cases under case:* labels; the emitter
# names them sub:cat:*. Map explicitly and require all four -- an empty list
# here once meant "nothing to check" and passed.
CASES = {
    "sub:cat:dex:uniswap": "case:dex:uniswap",
    "sub:cat:lsd:lido":    "case:lsd:lido",
    "sub:cat:bri:wbtc":    "case:bri:wbtc",
    "sub:cat:opt:rysk":    "case:opt:rysk",
}
cases = [l for l in CASES if f"\\label{{{CASES[l]}}}" in art]
if len(cases) != len(CASES):
    missing = [CASES[l] for l in CASES if l not in cases]
    bad.append(f"article is missing case labels: {missing}")
for lab in cases:
    m = re.search(r"\\begin\{measurement\}\\label\{meas:" + re.escape(lab[4:]) + r"\}.*?\\end\{measurement\}",
                  emitted[lab], re.S)
    if not m:
        bad.append(f"{lab}: emitted block has no construction measurement"); continue
    body = m.group(0)
    # the article renamed the measurement label with the case; compare the
    # body from the first line after \label to \end{measurement}
    inner = body.split("}", 2)[-1] if "\\label{" in body else body
    if inner.strip() not in art:
        bad.append(f"{lab}: the article's construction measurement differs from the emitter")

print(f"emitted profiles: {len(emitted)}   byte-equal in the supplement: {len(emitted) - len([b for b in bad if 'supplement' in b])}")
print(f"abbreviated cases in the article: {len(cases)}   their measurements verified: "
      f"{len(cases) - len([b for b in bad if 'article' in b or 'no construction' in b])}")
for b in bad[:10]:
    print("  FAIL", b)
print("\nEMISSION INVARIANT HOLDS" if not bad else "\nEMISSION INVARIANT VIOLATED")
sys.exit(1 if bad else 0)
