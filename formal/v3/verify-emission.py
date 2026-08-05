"""The emission invariant.

The supplement is the canonical emitted artefact: all sixty profiles must appear
there byte-equal to what the emitter produces. The article carries four
abbreviated cases; for those the invariant is weaker but still binding — the
construction measurement, which holds every figure, must be byte-equal, and only
the enumerated residue may be elided.
"""
import io, os, re, subprocess, sys

ROOT = "/root/defiformal/expansion"
V3 = "/root/defiformal/formal/v3"
art = io.open("/root/defiformal/paper/atlas.tex", encoding="utf-8").read()
sup = io.open("/root/defiformal/paper/supplement.tex", encoding="utf-8").read()

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

cases = [l for l in emitted if l in art]
for lab in cases:
    m = re.search(r"\\begin\{measurement\}\\label\{meas:" + re.escape(lab[4:]) + r"\}.*?\\end\{measurement\}",
                  emitted[lab], re.S)
    if not m:
        bad.append(f"{lab}: emitted block has no construction measurement"); continue
    if m.group(0) not in art:
        bad.append(f"{lab}: the article's construction measurement differs from the emitter")

print(f"emitted profiles: {len(emitted)}   byte-equal in the supplement: {len(emitted) - len([b for b in bad if 'supplement' in b])}")
print(f"abbreviated cases in the article: {len(cases)}   their measurements verified: "
      f"{len(cases) - len([b for b in bad if 'article' in b or 'no construction' in b])}")
for b in bad[:10]:
    print("  FAIL", b)
print("\nEMISSION INVARIANT HOLDS" if not bad else "\nEMISSION INVARIANT VIOLATED")
sys.exit(1 if bad else 0)
