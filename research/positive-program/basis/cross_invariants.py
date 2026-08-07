"""Which invariants does the corpus hand-write that composition should have supplied?

BASIS.md P1 gives Led one law -- ||bal|| = sup -- and claims the closure preserves it
by induction. The diagnosed defect is that a coupling k may glue a Led's declared
total to an unrelated Q, so the law does not survive composition.

If that defect is real rather than theoretical, the corpus should show the scar:
specs writing their OWN cross-carrier conservation invariants, because the algebra
did not give them one. BASIS.md section 4 already names several -- `reserveCovers`,
`shareSolvency`, `pyBackingHolds`, `shareConservation` -- and says they occur "only on
the right of an invariant declaration", never as a guard.

This counts them: `val inv_*` / `val *Holds` / `val *Covers` bodies that relate TWO OR
MORE distinct state variables. Those are the obligations the theory left to the spec
author, and they are the test set any interface discipline has to satisfy.
"""
import glob
import os
import re
from collections import defaultdict

ROOT = "/root/DefiElements/quint-models"
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


def body_of(src, at):
    tail = src[at:]
    nxt = re.search(r"\n\s{0,2}(?:pure\s+)?(?:val|def|action|var|type)\s", tail)
    return tail[: nxt.start()] if nxt else tail[:600]


rows = []
per_spec = defaultdict(int)
for path in sorted(glob.glob(ROOT + "/L*/*.qnt")):
    spec = os.path.basename(path)[:-4]
    lane = path.split("/")[-2]
    src = re.sub(r"//[^\n]*", "", open(path, encoding="utf-8", errors="replace").read())
    varnames = set(re.findall(r"^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)", src, re.M))
    if not varnames:
        continue
    for m in re.finditer(
            r"^\s*val\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*bool\s*=", src, re.M):
        name = m.group(1)
        if not re.match(r"(inv_|.*(Holds|Covers|Conserv|Solven|Backing|Bounded))",
                        name):
            continue
        body = body_of(src, m.end())
        used = {w for w in IDENT.findall(body) if w in varnames}
        if len(used) >= 2:
            rows.append((lane, spec, name, sorted(used)))
            per_spec[f"{lane}/{spec}"] += 1

print(f"invariants relating 2+ state variables: {len(rows)}"
      f"  across {len(per_spec)} specs\n")
print(f"{'lane':<4} {'spec':<14} {'invariant':<26} vars related")
print("-" * 88)
for lane, spec, name, used in rows:
    print(f"{lane:<4} {spec:<14} {name[:26]:<26} {', '.join(used[:5])}"
          + (f" (+{len(used)-5})" if len(used) > 5 else ""))

print(f"\n{'spec':<20} count")
for s, n in sorted(per_spec.items(), key=lambda x: -x[1])[:12]:
    print(f"  {s:<20} {n}")
print(f"\nBASIS.md P1 supplies exactly ONE law for Led: ||bal|| = sup.")
print(f"The corpus hand-writes {len(rows)} further cross-carrier invariants.")
print("Each is an obligation the composition operator did not discharge, and each")
print("is a test case for any interface discipline proposed to replace it.")
