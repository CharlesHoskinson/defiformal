"""Denominators: how many PROTOCOL definitions does each version actually have?

28 -> 119 ungenerated is an absolute count. The v2 re-specs decompose more finely
and carry apparatus v1 never had, so a rate needs the matching denominator or the
increase is inflated.

Counts, per version, the definitions that are neither apparatus (t0_/wit_/inv_/h\\d\\d)
nor kernel (isqrt/newton/mulDiv/ceilDiv/geometricMintExact/check*).
"""
import json
import os
import re

APPARATUS = re.compile(
    r"^(t0_|T0_|wit_|inv_|check[A-Z]|h\d\d$|sqrtOk$|kernel[A-Z]|kernelOk$)")
KERNEL = re.compile(
    r"^(isqrt|newton|geometricMintExact|mulDivDown$|mulDivUp$|ceilDiv$|"
    r"checkBoundary$|checkDecades$|checkSmall$|checkSquares$)")


def protocol_defs(d):
    n = 0
    for m in d["modules"]:
        if m["name"] == "common":
            continue
        for de in m["declarations"]:
            if de["kind"] != "def":
                continue
            nm = de.get("name", "")
            if APPARATUS.match(nm) or KERNEL.match(nm):
                continue
            n += 1
    return n


print(f"{'spec':<18} {'v1 protocol defs':>17} {'v2 protocol defs':>17}")
print("-" * 56)
t1 = t2 = 0
for fn in sorted(os.listdir("/root/gen-ir-v1ten")):
    spec = fn[:-5]
    a = protocol_defs(json.load(open(f"/root/gen-ir-v1ten/{fn}")))
    b = protocol_defs(json.load(open(f"/root/gen-ir-v2ten/{fn}")))
    t1 += a
    t2 += b
    print(f"{spec.replace('__','/'):<18} {a:>17} {b:>17}")
print("-" * 56)
print(f"{'TOTAL':<18} {t1:>17} {t2:>17}")
print()
u1, u2 = 28, 119
print(f"ungenerated protocol defs   v1 {u1:>4} / {t1:<4} = {100*u1/t1:5.1f}%")
print(f"                            v2 {u2:>4} / {t2:<4} = {100*u2/t2:5.1f}%")
print()
print("The v1 corpus-wide headline was 743/820 generated = 90.6%, i.e. 9.4%")
print("ungenerated. Compare the v2 rate above, on the same ten protocols and the")
print("same basis, with the deleted mechanisms restored.")
