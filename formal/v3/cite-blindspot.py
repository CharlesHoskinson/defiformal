"""The audit reports 403s as "blocked to automation, not dead". That is a claim
about the host, not a verification of the citation: a 403 means the URL was not
checked, and calling it not-dead reads as a pass.

Name the blind spot. Which hosts return 403, and how much of the corpus sits
behind them?
"""
import glob, io, json, re, subprocess
from collections import Counter, OrderedDict
from urllib.parse import urlparse
import os as _os, pathlib as _pl, sys as _sys
# Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
_SELF = _pl.Path(__file__).resolve().parents[2]
_REPO = _pl.Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_pl.Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


urls = OrderedDict()
for f in sorted(glob.glob(str(_REPO / "expansion/*/specs/*.json"))):
    d = json.load(io.open(f, encoding="utf-8"))
    for o in d.get("functionalObligations") or []:
        for u in re.findall(r"https?://[^\s\"'<>\\]+", str(o.get("evidence") or "")):
            urls.setdefault(u.rstrip(".,;)"), 1)

keys = list(urls)
step = max(1, len(keys) // 60)
done = [int(x) for x in
        io.open(str(_REPO / "formal/v3/.cite-audit-offsets")).read().split()]

# hosts overall
hosts = Counter(urlparse(u).netloc for u in keys)
print("distinct evidence URLs: %d over %d hosts" % (len(keys), len(hosts)))
print("largest hosts: %s" % ", ".join("%s %d" % kv for kv in hosts.most_common(6)))

# re-check only the URLs that previously returned 403, by sampling the audited
# strata and keeping the blocked ones
blocked = []
sample = []
for off in done:
    sample += [k for i, k in enumerate(keys) if i % step == off][:60]
print("\nre-checking %d audited URLs for 403 only..." % len(sample))
for i, u in enumerate(sample, 1):
    r = subprocess.run(["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}",
                        "-L", "--max-time", "12",
                        "-A", "Mozilla/5.0 (compatible; citation-check)", u],
                       capture_output=True, text=True)
    if (r.stdout or "").strip() == "403":
        blocked.append(u)
    if i % 100 == 0:
        print("   ... %d/%d" % (i, len(sample)))

bh = Counter(urlparse(u).netloc for u in blocked)
print("\nURLs returning 403 in the audited set: %d of %d (%.1f%%)"
      % (len(blocked), len(sample), 100.0 * len(blocked) / max(len(sample), 1)))
for h, n in bh.most_common():
    print("   %-34s %d  (%d of this host in the corpus)" % (h, n, hosts[h]))

behind = sum(hosts[h] for h in bh)
print("\ncorpus URLs on hosts observed to block: %d of %d (%.1f%%)"
      % (behind, len(keys), 100.0 * behind / len(keys)))
print("\nThese are NOT verified. A 403 says the host refused the request, not")
print("that the page exists. The audit's reach is the non-blocking remainder.")
