import json, collections
from atlas import *
import model3 as M

out = {"verdicts": [{"id": c["id"], "verdict": "ADMISSIBLE" if M.admissible(c["elements"]) else "INADMISSIBLE"}
                    for c in blind]}
p = "/root/DefiElements/algebra/verdicts/OP-ORD.json"
with open(p, "w") as f:
    json.dump(out, f, indent=1)
print("wrote", p, len(out["verdicts"]))
print(collections.Counter(v["verdict"] for v in out["verdicts"]))

# summary numbers for the report
a = sum(1 for c in M.R if M.admissible(c["elements"]))
b = sum(1 for c in M.N if M.admissible(c["elements"]))
print(f"REAL {a}/72={a/72:.4f} OTHER {b}/84={b/84:.4f} RATIO {(a/72)/(b/84):.3f}")

# which block rejects what, over the 84 non-lane cases
cnt = collections.Counter()
for c in M.N:
    ok, p2 = M.admissible(c["elements"], parts=True)
    if not ok:
        for k, v in p2.items():
            if v:
                cnt[k] += 1
print("non-lane rejections by block (overlapping):", dict(cnt))
cnt2 = collections.Counter()
for c in M.R:
    ok, p2 = M.admissible(c["elements"], parts=True)
    if not ok:
        for k, v in p2.items():
            if v:
                cnt2[k] += 1
print("lane rejections by block:", dict(cnt2))
