from atlas import *

n = 0
for law in PARSED:
    print(f"{law['id']:5s} subj={law['subjects'] if law['subjects'] else '(PROSE)'}  :: {law['rule']}")
    for t in law["terms"]:
        n += 1
        mixed = (not t["external"]) and ("|" in t["prose"]) and len([a for a in t["prose"].split("|") if bare(a) not in SYMS]) > 0
        kind = "EXTERNAL" if t["external"] else ("MIXED" if mixed else "INTERNAL")
        print(f"        [{kind:8s}] alts={t['alts']}  prose={t['prose']!r}")
print("total terms", n)
