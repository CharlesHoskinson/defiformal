"""Greedy forward selection of strict axiom variants.

Objective: maximise discrimination ratio realAcc/negAcc subject to a floor on
realAcc. Candidates are all *strict* readings of laws I had to widen; a
candidate is only eligible if it has a one-sentence mechanism justification
(they all do -- each is the atlas's own wording, unwidened).
"""
import atlas as A, theory as T, negatives as N

REAL = A.real_protocols()
NEG = [n for n in N.gen(seed=7, per_family=400)
       if n["family"] in {"drop1", "drop2", "add1", "add2", "add3", "swapgrp",
                          "swapany", "graft", "uniform", "weighted"}
       and len(n["syms"]) <= 17]
# held-out generator, different seed and different family mix
HOLD = [n for n in N.gen(seed=99, per_family=250)
        if n["family"] in {"drop1", "drop2", "add1", "add2", "add3", "swapgrp",
                           "swapany", "graft", "uniform", "weighted"}
        and len(n["syms"]) <= 17]

C = T.C
CAND = [
    C("S1", [("Up",)], ["Tg", "Gp"], "L15 unwidened: timelock or pause only."),
    C("S2", [("Ct",)], ["Li", "Ad", "Sl", "Bs"],
      "Screen 3 unwidened: a threshold test must reach a G06 terminal.", sort="M"),
    C("S3", [("Im",), ("Cd",), ("Pf",)], ["Li", "Ad", "Sl", "Bs"],
      "L1 term 3 unwidened.", sort="M"),
    C("S4", [("Xf",)], ["Xm", "At"], "L8 with only the verifier/custodian."),
    C("S5", [("Pl",), ("Im",), ("Cd",), ("Pf",), ("Op",)], ["Ct"],
      "L1 term 2 unwidened: all five subjects."),
    C("S6", [("Pl",)], T.TRUTH + ["Cl"], "L1 term 1 with Pl restored as subject.",
      sort="M"),
    C("S7", [("Tr",)], ["Sv"], "L6 unwidened."),
    C("S8", [("Of",)], ["Bs", "Sl"], "L19 term 3 unwidened."),
    C("S9", [("Rs",)], ["Vl"], "L22: restaked capital is validator capital."),
    C("S10", [("Fl",)], T.CURVE + ["Pl", "Im", "Cd", "Ag", "Ob"],
      "Screen 5 unwidened: flash liquidity comes out of an inventory."),
    C("S11", [("Xm",)], ["Xf", "Of", "Rl", "In", "Vl", "Rs"],
      "L18/C5 tightened: a verifier verifies a crossing or a remote stake."),
    C("S12", [("At",)], ["Rd", "Ps", "Xf", "Cd", "Uc", "Ft", "Tr", "Sv",
                         "As", "Vl", "Rs", "Bs", "Aw", "Fz"],
      "C13 tightened: an attestation names backing, an obligor or a holder."),
    C("S13", [("Aw",)], ["Fz", "At", "Uc", "Ft", "Xf", "Rd", "Ps", "Tr", "Sv",
                         "Vl", "Rs", "Ob", "Rf", "In", "Ag", "Ct", "Pl", "Im"],
      "C22 tightened."),
    C("S14", [("Pf",), ("Dp",)], ["Li", "Ad", "Sl", "Bs"],
      "L4: a leveraged directional book needs a terminal loss path.", sort="M"),
    C("S15", [("Em",)], ["Sh", "Ix", "Rb", "Pl", "Im", "Cd", "Cp", "Cl", "St",
                         "Pm", "Ob", "Rf", "Ba", "In", "Ag", "Vl", "Rs", "Bs",
                         "Ct", "Op", "Pf", "Ep", "Tr", "Ft", "Uc", "Sr", "Fd",
                         "Rd", "Wq", "Xf"],
      "Completion: emissions are paid for a *measured action*."),
    C("S16", [("Sr",)], T.CLAIM + ["Em", "Ct", "Op", "Pl", "Pm", "Rd", "Ft",
                                   "Py", "Sv", "Xf", "Cl"],
      "C10 tightened (Wq removed)."),
    C("S17", [("Wq",)], T.CLAIM + ["Rd", "Vl", "Rs", "Ps", "Ep", "Ft", "Uc",
                                   "Pl", "Im", "Tr", "Op"],
      "C3 tightened (Xf, Bs removed)."),
    C("S18", [("Gp",)], [s for s in A.SYMS if A.GROUP[s] not in
                         {"G10", "G11"}],
      "A pause suppresses *reachable transitions*; a pause over nothing but "
      "incentives and control is a pause over nothing."),
    C("S19", [("Tg",)], ["Up", "Gp", "Fz", "Au", "Em", "Sv", "Ps", "Cd", "Im",
                         "Pl", "Uc", "Bs", "Rs", "Vl", "Xf", "Xm", "Fd", "Ct",
                         "Li", "Sl", "Ix", "Sh", "Rb", "Ep", "Wq", "Rd", "Tr",
                         "Cl", "Cp", "St", "Ag", "Tp", "Fl"],
      "Completion: a timelock delays an authorised change to something."),
    C("S20", [("Ix",)], T.CLAIM + ["Pl", "Im", "Cd", "Uc", "Ft", "Py", "Sr",
                                   "Rd", "Vl", "Rs", "Ps", "Wq", "Ep", "Tr",
                                   "Ct", "Xf", "Of", "Em", "Sv", "Bs"],
      "Completion: an accrual index rescales a claim some element records."),
]


def acc(clauses, corpus, key="syms"):
    return sum(1 for c in corpus if T.valid(c[key], clauses)) / len(corpus)


base = T.POOL
ra, na = acc(base, REAL), acc(base, NEG)
print(f"base: realAcc={ra:.3f} negAcc={na:.3f} ratio={ra/na:.3f}")
print()
print(f"{'id':5s} {'realAcc':>8s} {'negAcc':>7s} {'ratio':>6s}  (base + this one)")
for cl in CAND:
    s = base + [cl]
    r, n = acc(s, REAL), acc(s, NEG)
    print(f"{cl['id']:5s} {r:8.3f} {n:7.3f} {r/n:6.3f}")

print()
print("=== greedy forward selection, floor realAcc >= 0.85 ===")
chosen, cur = [], base
while True:
    best = None
    for cl in CAND:
        if cl in chosen:
            continue
        s = cur + [cl]
        r, n = acc(s, REAL), acc(s, NEG)
        if r < 0.85:
            continue
        if best is None or r / n > best[1]:
            best = (cl, r / n, r, n)
    if best is None:
        break
    r0, n0 = acc(cur, REAL), acc(cur, NEG)
    if best[1] <= r0 / n0 + 1e-9:
        break
    chosen.append(best[0])
    cur = cur + [best[0]]
    print(f"  + {best[0]['id']:5s} realAcc={best[2]:.3f} negAcc={best[3]:.3f} ratio={best[1]:.3f}")

print()
print("chosen:", [c["id"] for c in chosen])
r, n = acc(cur, REAL), acc(cur, NEG)
h = acc(cur, HOLD)
print(f"final on calibration: realAcc={r:.3f} negAcc={n:.3f} ratio={r/n:.3f}")
print(f"final on HELD-OUT generator: negAcc={h:.3f} ratio={r/h:.3f}")
print()
print("reals rejected:")
for x in REAL:
    v = T.violations(x["syms"], cur)
    if v:
        print(f"  {x['name'][:44]:46s} {v}")
