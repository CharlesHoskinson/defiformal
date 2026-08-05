"""Invariant 5: sample the evidence URLs and check they resolve.

Usage: cite-audit.py [offset] [sample-size]

Strata are disjoint by construction: the stride is len(urls)//sample and the
offset selects which residue class. Offset 0 was the first audit, offset 5 the
second. Run a fresh offset each time rather than re-checking the same URLs.

The first audit took every 10th distinct evidence URL (60 of 638) and found one
dead link, Pendle F20, since repaired. One failure in sixty is either a rate or
an accident. This takes a DISJOINT sample -- the same stride, offset by five --
so the two together cover 120 of the 638 without overlap.
"""
import glob, io, json, re, subprocess, sys
from collections import OrderedDict, Counter

import sys as _s
OFFSET = int(_s.argv[1]) if len(_s.argv) > 1 else 5
SAMPLE = int(_s.argv[2]) if len(_s.argv) > 2 else 60

urls = OrderedDict()
for f in sorted(glob.glob("/root/defiformal/expansion/*/specs/*.json")):
    spec = json.load(io.open(f, encoding="utf-8"))
    app = spec.get("app") or f.split("/")[-1]
    for o in spec.get("functionalObligations") or []:
        for u in re.findall(r"https?://[^\s\"'<>\\]+", str(o.get("evidence") or "")):
            urls.setdefault(u.rstrip(".,;)"), (app, o.get("id")))

keys = list(urls)
step = max(1, len(keys) // SAMPLE)
sample = [k for i, k in enumerate(keys) if i % step == OFFSET % step][:SAMPLE]

# Which strata have been audited before? Offsets are residue classes mod step,
# so distinct offsets are disjoint by construction and the union is exact.
LEDGER = "/root/defiformal/formal/v3/.cite-audit-offsets"
try:
    done = {int(x) for x in io.open(LEDGER).read().split() if x.strip()}
except OSError:
    done = set()

# Only the first SAMPLE of a class is fetched, and a class holds 63 or 64, so
# crediting the whole class overcounts by the remainder. Count what was fetched.
covered = set()
for off in done | {OFFSET % step}:
    covered |= set([k for i, k in enumerate(keys) if i % step == off][:SAMPLE])

print("distinct evidence URLs : %d   stride %d" % (len(keys), step))
print("this stratum (offset %d): %d URLs" % (OFFSET % step, len(sample)))
print("strata run before      : %s" % (sorted(done) or "none"))
print("cumulative coverage    : %d of %d  (%.0f%%)\n"
      % (len(covered), len(keys), 100.0 * len(covered) / len(keys)))

status = Counter()
dead = []
for i, u in enumerate(sample, 1):
    r = subprocess.run(
        ["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "-L",
         "--max-time", "20", "--retry", "1",
         "-A", "Mozilla/5.0 (compatible; citation-check)", u],
        capture_output=True, text=True)
    code = (r.stdout or "000").strip()
    status[code] += 1
    if code in ("404", "410", "000"):
        dead.append((code, u, urls[u]))
    if i % 20 == 0:
        print("  ... %d/%d" % (i, len(sample)))

print("\nHTTP status:")
for c, n in sorted(status.items(), key=lambda kv: -kv[1]):
    label = {"200": "ok", "403": "blocked to automation, not dead",
             "404": "DEAD", "410": "DEAD", "000": "no response / TLS / DNS",
             "429": "rate-limited", "202": "accepted"}.get(c, "")
    print("   %-5s %3d   %s" % (c, n, label))

print("\nhard failures: %d of %d sampled" % (len(dead), len(sample)))
for c, u, (app, oid) in dead:
    print("   %-4s %-24s %s" % (c, "%s/%s" % (app, oid), u[:100]))

done.add(OFFSET % step)
io.open(LEDGER, "w").write(" ".join(str(x) for x in sorted(done)) + "\n")
print("\nstrata now audited: %s" % sorted(done))
