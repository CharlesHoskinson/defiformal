"""Count subsections per category section BY POSITION.

The first attempt matched subsection labels against the section's label key -
sec:cat:lend against sub:cat:lnd:*, sec:cat:yield against sub:cat:yld:* - and
reported five categories at zero because the prefixes were chosen
independently. Position is the thing that actually determines which section a
subsection renders under, so count that.
"""
import io, re

s = io.open("/root/defiformal/paper/atlas.tex", encoding="utf-8").read()

secs = [(m.start(), m.group(1), m.group(2))
        for m in re.finditer(r"\\section\{([^}]*)\}\\label\{(sec:cat:[a-z]+)\}", s)]
# every \section, so we know where each category section ends
allsec = [m.start() for m in re.finditer(r"\\section\*?\{", s)]
subs = [(m.start(), m.group(1), m.group(2))
        for m in re.finditer(r"\\subsection\{([^}]*)\}\\label\{(sub:[^}]*)\}", s)]

print(f"category sections: {len(secs)}   application subsections: {len(subs)}")
ok = True
for pos, name, lab in secs:
    end = min([p for p in allsec if p > pos], default=len(s))
    mine = [t for t in subs if pos < t[0] < end]
    flag = "ok " if len(mine) == 5 else "** "
    if len(mine) != 5:
        ok = False
    print(f"  {flag}{name:<42} {len(mine)}  [{lab}]")
    for _, t, l in mine:
        print(f"        {t:<34} {l}")

print()
print("ALL TWELVE CATEGORIES CARRY FIVE SUBSECTIONS" if ok else "INCOMPLETE")

dups = [l for _, _, l in subs]
print(f"duplicate subsection labels: {len(dups) - len(set(dups))}")
