"""Compare generation on the SAME ten protocols: v1 specs vs v2 re-specs.

RAW TOTALS WOULD LIE. v1 ten: 144/172 generated. v2 ten: 924/1605. That looks like
a collapse, and most of it is an artifact: the v2 re-specs carry T0 conformance
vectors, wit_* reachability obligations, inv_* invariants and the restored kernel,
none of which exist in v1. Those are VERIFICATION APPARATUS, not protocol mechanism,
and counting them as ungenerated definitions inflates the failure.

So this restricts both sides to PROTOCOL definitions -- the actions and the pure
defs they call -- and reports that. The apparatus counts are kept and reported
separately rather than hidden, because "the apparatus is not P-generated" is itself
true and worth stating: a basis of economic primitives was never going to generate a
conformance vector.
"""
import re
import subprocess
import sys

APPARATUS = re.compile(
    r"^(t0_|T0_|wit_|inv_|check[A-Z]|h\d\d$|sqrtOk$|kernel[A-Z]|kernelOk$)")
KERNEL = re.compile(
    r"^(isqrt|newton|geometricMintExact|mulDivDown$|mulDivUp$|ceilDiv$|"
    r"checkBoundary$|checkDecades$|checkSmall$|checkSquares$)")


def run(path):
    out = subprocess.run([sys.executable, path], capture_output=True, text=True,
                         cwd="/root/DefiElements/research/positive-program").stdout
    tested = gen = notgen = None
    per = {}
    for line in out.splitlines():
        m = re.search(r"definitions tested\s*:\s*(\d+)", line)
        if m:
            tested = int(m.group(1))
        m = re.search(r"definitions P-generated\s*:\s*(\d+)", line)
        if m:
            gen = int(m.group(1))
        m = re.search(r"definitions NOT generated\s*:\s*(\d+)", line)
        if m:
            notgen = int(m.group(1))
        m = re.match(r"\s+(L\d/\w+): \d+ ungenerated def\(s\): (.+)$", line)
        if m:
            per[m.group(1)] = [x.strip() for x in m.group(2).split(",")]
    return tested, gen, notgen, per


def classify(names):
    prot, app, kern = [], [], []
    for n in names:
        if KERNEL.match(n):
            kern.append(n)
        elif APPARATUS.match(n):
            app.append(n)
        else:
            prot.append(n)
    return prot, app, kern


t1, g1, n1, p1 = run("/tmp/gen_v1ten.py")
t2, g2, n2, p2 = run("/tmp/gen_v2ten.py")

print("RAW (not comparable -- v2 carries apparatus v1 never had)")
print(f"  v1 ten  tested {t1 or (g1 or 0)+(n1 or 0):>5}   generated {g1:>5}"
      f"   ungenerated {n1:>5}")
print(f"  v2 ten  tested {t2:>5}   generated {g2:>5}   ungenerated {n2:>5}\n")

print("UNGENERATED, split by what the definition IS")
print(f"{'spec':<18} {'v1 protocol':>12} {'v2 protocol':>12}   "
      f"{'v2 apparatus':>13} {'v2 kernel':>10}")
print("-" * 74)
tot = [0, 0, 0, 0]
rows = []
for spec in sorted(set(p1) | set(p2)):
    a1, _, _ = classify(p1.get(spec, []))
    a2, ap2, k2 = classify(p2.get(spec, []))
    rows.append((spec, len(a1), len(a2), len(ap2), len(k2), a1, a2))
    tot[0] += len(a1); tot[1] += len(a2); tot[2] += len(ap2); tot[3] += len(k2)
    print(f"{spec:<18} {len(a1):>12} {len(a2):>12}   {len(ap2):>13} {len(k2):>10}")
print("-" * 74)
print(f"{'TOTAL':<18} {tot[0]:>12} {tot[1]:>12}   {tot[2]:>13} {tot[3]:>10}")

print("\nPROTOCOL definitions that are ungenerated in v2 but NOT in v1")
print("(these are the mechanisms the re-spec RESTORED and the basis cannot reach)")
for spec, _, _, _, _, a1, a2 in rows:
    new = sorted(set(a2) - set(a1))
    if new:
        print(f"  {spec:<18} {', '.join(new[:9])}"
              + (f"  (+{len(new)-9} more)" if len(new) > 9 else ""))

print("\nPROTOCOL definitions ungenerated in v1 but generated in v2")
for spec, _, _, _, _, a1, a2 in rows:
    gone = sorted(set(a1) - set(a2))
    if gone:
        print(f"  {spec:<18} {', '.join(gone)}")
