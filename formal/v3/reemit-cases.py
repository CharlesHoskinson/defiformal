"""Re-emit the four retained case studies in the article, and any stale profile
in the supplement, from the current verdicts."""
import io, os, re, subprocess

ROOT = "/root/defiformal/expansion"
V3 = "/root/defiformal/formal/v3"

emitted = {}
for slug in sorted(d for d in os.listdir(ROOT) if re.match(r"^\d\d-", d)):
    specs, verd = f"{ROOT}/{slug}/specs", f"{ROOT}/{slug}/verdicts.json"
    if not (os.path.isdir(specs) and os.path.exists(verd)):
        continue
    r = subprocess.run(["node", f"{V3}/emit-tex.mjs", specs, verd],
                       capture_output=True, text=True)
    assert r.returncode == 0, f"{slug}: {r.stderr[:300]}"
    for p in re.split(r"(?=\\subsection\{)", r.stdout.strip()):
        if not p.strip().startswith("\\subsection{"):
            continue
        lab = re.search(r"\\label\{(sub:cat:[^}]*)\}", p)
        emitted[lab.group(1)] = p.strip()

for path in ["/root/defiformal/paper/atlas.tex", "/root/defiformal/paper/supplement.tex"]:
    s = io.open(path, encoding="utf-8").read()
    fixed = 0
    for lab, body in emitted.items():
        m = re.search(r"\\subsection\{[^}]*\}\\label\{" + re.escape(lab) + r"\}", s)
        if not m:
            continue
        nxt = re.search(r"\\subsection\{|\\section\{|\\end\{document\}", s[m.end():])
        end = m.end() + (nxt.start() if nxt else len(s) - m.end())
        cur = s[m.start():end].rstrip()
        if cur == body:
            continue
        s = s[:m.start()] + body + "\n\n" + s[end:]
        fixed += 1
    io.open(path, "w", encoding="utf-8", newline="\n").write(s)
    print(f"{os.path.basename(path)}: {fixed} profile(s) re-emitted")
