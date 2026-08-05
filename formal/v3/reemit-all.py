"""Re-emit every category block in place after an emitter fix.

Finds each emitted block by its first subsection, replaces it up to the next
\\section, and leaves the authored lead-in paragraphs untouched.
"""
import io, os, re, subprocess

TEX = "/root/defiformal/paper/atlas.tex"
ROOT = "/root/defiformal/expansion"
V3 = "/root/defiformal/formal/v3"

s = io.open(TEX, encoding="utf-8").read()
changed = 0

for slug in sorted(d for d in os.listdir(ROOT) if re.match(r"^\d\d-", d)):
    specs, verd = f"{ROOT}/{slug}/specs", f"{ROOT}/{slug}/verdicts.json"
    if not (os.path.isdir(specs) and os.path.exists(verd)):
        continue
    r = subprocess.run(["node", f"{V3}/emit-tex.mjs", specs, verd],
                       capture_output=True, text=True)
    assert r.returncode == 0, f"{slug}: emitter failed\n{r.stderr[:400]}"
    emit = r.stdout.strip()

    first = re.search(r"\\subsection\{[^}]*\}\\label\{[^}]*\}", emit).group(0)
    i = s.find(first)
    assert i >= 0, f"{slug}: emitted block not found in the paper"
    j = s.find("\\section{", i)
    old = s[i: j if j > 0 else len(s)].rstrip()
    if old == emit:
        print(f"  {slug}: unchanged")
        continue
    s = s[:i] + emit + "\n\n" + (s[j:] if j > 0 else "")
    changed += 1
    print(f"  {slug}: re-emitted")

io.open(TEX, "w", encoding="utf-8", newline="\n").write(s)
print(f"{changed} category block(s) re-emitted")
