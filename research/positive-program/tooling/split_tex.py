import re
from pathlib import Path

SRC = Path("/root/DefiElements/paper")
OUT = SRC / "kg-corpus"
OUT.mkdir(exist_ok=True)
for f in OUT.glob("*.md"):
    f.unlink()

BS = chr(92)          # backslash
TEXCMD = BS + r"[a-zA-Z]+"


def slug(s):
    s = re.sub(BS + r"[a-zA-Z]+\{([^}]*)\}", r"\1", s)
    s = re.sub(r"[^a-zA-Z0-9 ]+", "", s).strip().lower()
    s = re.sub(r"\s+", "-", s)
    return s[:60] or "untitled"


def clean_title(s):
    s = re.sub(BS + r"[a-zA-Z]+\{([^}]*)\}", r"\1", s)
    s = re.sub(TEXCMD, "", s)
    return s.replace("{", "").replace("}", "").strip()


total = 0
for src_name, prefix in (("atlas.tex", "atlas"),
                         ("supplement.tex", "supp"),
                         ("formal-data.tex", "formal")):
    p = SRC / src_name
    if not p.exists():
        continue
    text = p.read_text(encoding="utf-8", errors="replace")
    parts = re.split(r"(?m)^" + BS + BS + r"section\*?\{", text)

    head = parts[0]
    (OUT / (prefix + "-00-preamble.md")).write_text(
        "# " + prefix + " preamble\n\nSource: " + src_name + "\n\n" + head,
        encoding="utf-8")
    total += 1

    for i, part in enumerate(parts[1:], 1):
        m = re.match(r"([^}]*)\}", part)
        title = m.group(1) if m else ("section-" + str(i))
        body = part[m.end():] if m else part
        name = prefix + "-" + str(i).zfill(2) + "-" + slug(title) + ".md"
        (OUT / name).write_text(
            "# " + clean_title(title) + "\n\nSource: " + src_name +
            ", section " + str(i) + "\n\n" + body,
            encoding="utf-8")
        total += 1

print("wrote", total, "files to", OUT)
