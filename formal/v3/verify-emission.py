"""The emission invariant, across both documents.

Every emitted subsection must appear byte-equal in the article or in the
supplement. Four are retained in the article as case studies; the rest are in
the supplement. A subsection present in neither, or present but altered, means
a figure may no longer match the computation behind it.
"""
import io, os, re, subprocess, sys

ROOT = "/root/defiformal/expansion"
V3 = "/root/defiformal/formal/v3"
art = io.open("/root/defiformal/paper/atlas.tex", encoding="utf-8").read()
sup = io.open("/root/defiformal/paper/supplement.tex", encoding="utf-8").read()

total = ok = 0
bad = []
for slug in sorted(d for d in os.listdir(ROOT) if re.match(r"^\d\d-", d)):
    specs, verd = f"{ROOT}/{slug}/specs", f"{ROOT}/{slug}/verdicts.json"
    if not (os.path.isdir(specs) and os.path.exists(verd)):
        continue
    r = subprocess.run(["node", f"{V3}/emit-tex.mjs", specs, verd],
                       capture_output=True, text=True)
    if r.returncode != 0:
        bad.append(f"{slug}: emitter failed"); continue
    # split the emitted text into its subsections
    parts = re.split(r"(?=\\subsection\{)", r.stdout.strip())
    for p in parts:
        if not p.strip().startswith("\\subsection{"):
            continue
        total += 1
        lab = re.search(r"\\label\{(sub:cat:[^}]*)\}", p)
        body = p.strip()
        if body in art or body in sup:
            ok += 1
        else:
            where = "article" if (lab and lab.group(1) in art) else \
                    ("supplement" if (lab and lab.group(1) in sup) else "neither")
            bad.append(f"{slug} {lab.group(1) if lab else '?'}: present in {where} but not byte-equal")

print(f"emitted subsections: {total}   byte-equal in the article or supplement: {ok}")
for b in bad[:12]:
    print("  FAIL", b)
print("\nEMISSION INVARIANT HOLDS" if not bad else "\nEMISSION INVARIANT VIOLATED")
sys.exit(1 if bad else 0)
