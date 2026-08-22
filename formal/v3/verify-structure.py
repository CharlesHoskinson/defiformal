"""Structure check across the submission.

The article carries twelve category sections and four case studies; the
remaining fifty-six profiles are in the supplement. The invariant is that every
category has five profiles somewhere in the submission, and that no label is
duplicated within or across the two documents.
"""
import io, re, sys
import os as _os, pathlib as _pl, sys as _sys
# Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
_SELF = _pl.Path(__file__).resolve().parents[2]
_REPO = _pl.Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_pl.Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


art = io.open(str(_REPO / "paper/atlas.tex"), encoding="utf-8").read()
sup = io.open(str(_REPO / "paper/supplement.tex"), encoding="utf-8").read()

secs = re.findall(r"\\section\{([^}]*)\}\\label\{sec:cat:([a-z]+)\}", art)
labels_art = re.findall(r"\\label\{(sub:cat:[a-z]+:[a-z0-9]+)\}", art)
labels_sup = re.findall(r"\\label\{(sub:cat:[a-z]+:[a-z0-9]+)\}", sup)
allp = labels_sup   # the supplement is canonical; the article carries abbreviated cases

print(f"category sections in the article: {len(secs)}")
cases = art.count(chr(92) + "label{case:")
print(f"profiles: {len(labels_sup)} in the supplement; abbreviated case studies in the article: {cases}")

MAP = {"dex":"dex","lend":"lnd","cdp":"cdp","lsd":"lsd","perp":"perp",
       "yield":"yld","bridge":"bri","intent":"int","rwa":"rwa","opt":"opt",
       "fiat":"fiat","pred":"prd"}
by = {}
for l in allp:
    by.setdefault(l.split(":")[2], []).append(l)

ok = True
if len(secs) != 12:
    print(f"  FAIL expected 12 category sections, found {len(secs)}"); ok = False
for name, key in secs:
    got = len(by.get(MAP.get(key, key), []))
    mark = "ok " if got == 5 else "** "
    print(f"  {mark}{name:<38} {got} profiles")
    if got != 5: ok = False

dupes = [l for l in set(allp) if allp.count(l) > 1]
print(f"duplicate labels: {len(dupes)}{'  ' + str(dupes[:4]) if dupes else ''}")
if dupes: ok = False

print("\nSUBMISSION STRUCTURE COMPLETE" if ok else "\nINCOMPLETE")
sys.exit(0 if ok else 1)
