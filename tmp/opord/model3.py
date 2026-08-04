"""OP-ORD v3 — final. gamma (forward closure) + rho (residual warrant)
   + polarity-corrected hazard laws + stratum ideal."""
import collections, json, itertools
from atlas import *

avail = collections.Counter({k: len(v) for k, v in LANESETS.items()})
real_ids = set()
for c in blind:
    fs = frozenset(c["elements"])
    if avail.get(fs, 0) > 0:
        avail[fs] -= 1
        real_ids.add(c["id"])

ST = {s: ELEMS[s]["stratum"] for s in ELEMS}
GRP = {s: ELEMS[s]["group"] for s in ELEMS}
RISKG = {"G05", "G06", "G07", "G13", "G16"}

norm = lambda X: set(x for x in X if x in SYMS)
has = lambda S, *ss: any(s in S for s in ss)

PRICE = ["Ex", "Tp", "At", "Oa", "Sv", "Cl", "Cp", "St", "Wg"]
INDEX = ["Ex", "Tp", "Oa", "At"]
LOSS = ["Li", "Ad", "Sl", "Bs"]
TERMINAL = ["Sl", "Ad", "Bs", "Tr", "Cv", "Wq", "Rd", "Ps", "Sv", "Im", "Of"]

LSTAR = [
    ("L1a", ["Pl", "Im", "Cd", "Pf", "Op"], [PRICE]),
    ("L1c", ["Pl", "Im", "Cd", "Pf"], [["Ct"]]),
    ("L1d", ["Pl", "Im", "Cd", "Pf"], [LOSS]),
    ("L2", ["Pl"], [["Sh", "Ix", "Rb"], TERMINAL]),
    ("L3", ["Uc"], [["Aw"], ["At"], ["Bs", "Tr", "Sv", "Ft", "Ct"], ["Sv", "Ft", "Fz", "Ep", "Tr"]]),
    ("L4", ["Pf"], [INDEX, ["Ct"], ["Li", "Ad", "Sl", "Bs"]]),
    ("L5", ["Py"], [["Sh", "Ix", "Rb"], ["Ep"], ["Rd"]]),
    ("L7", ["Cd"], [["Rd", "Ps", "Li", "Ad", "Sl", "Bs"]]),
    ("L19", ["Of"], [["Xm"], ["Xf"], ["Bs", "Sl"]]),
    ("L20", ["Rl"], [["Au"]]),
    ("L21", ["Gs"], [["Au"]]),
]

CONSUME = {
    "Ct": ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Dp", "Tr", "Cv", "Rs", "Vl", "Pm", "Ob", "Fl", "Rd"],
    "Li": ["Ct"],
    "Ad": ["Ct", "Pf", "Ob"],
    "Sl": ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Tr", "Cv", "Rs", "Vl", "Ob", "Dp", "Bs", "Ct", "Xf", "Xm"],
    "Bs": ["Pl", "Im", "Cd", "Uc", "Pf", "Op", "Rs", "Vl", "In", "Of", "Xm", "Xf", "Cv", "Tr", "Ob", "Ct", "Sl", "Rl", "Ba", "Ft", "Wq"],
    "Tp": ["Cp", "Cl", "St", "Wg", "Pm", "Ob"],
    "Ex": ["Ct", "Li", "Ad", "Pf", "Op", "Pm", "Cd", "Pl", "Im", "Uc", "Ft", "As", "Ps", "Rd", "Tr", "Cv",
           "Sl", "Bs", "Vl", "Dp", "Py", "Sv", "Rl", "Oa", "Rs", "Sr", "Cl", "St", "Wg", "Cp", "Ob", "Of", "In"],
    "Xm": ["Xf", "Rs", "In", "Of", "Rl", "Vl", "Ob", "Sb", "Up", "Tg", "Gp"],
    "Sv": ["Tr", "Pl", "Im", "Uc", "Ft", "Cv", "Op", "Cd", "Rl", "Sh", "Ep", "Wq"],
    "Ps": ["At", "Cd", "Rd", "Xf", "Fz", "Aw", "Ix", "Sr"],
    "As": ["Ex", "Tp", "Oa", "At"],
    "Fl": ["Cp", "Cl", "St", "Wg", "Pm", "Pl", "Im", "Cd", "Ob", "Ag", "Sh", "Ix"],
    "Of": ["Xf", "In", "Rl", "Xm"],
    "Pf": ["Ct", "Ob", "Pm", "Ex"],
    "Op": ["Ct", "Ob", "Ex", "Sh", "Rf", "Pm", "Cl"],
    "Py": ["Ix", "Sh", "Rb", "Ft"],
    "Tr": ["Pl", "Im", "Uc", "Ft", "Cd", "Cv", "Rs", "Vl", "Sh", "Ix", "Sv", "Dp"],
    "Cv": ["Pl", "Im", "Cd", "Uc", "Bs", "Sh"],
    "Rl": ["In", "Xf", "Xm", "Of", "Au", "Ob", "Rf"],
    "Gs": ["Au", "Ob", "In", "Rl", "Aw"],
    "Vl": ["Rs", "Bs", "Sl", "Sh", "Wq", "Ep", "Rb", "Ix", "Xf", "Ob"],
    "Ft": ["Sh", "Ix", "Rb", "Py", "Ep", "At", "Sv", "Uc", "Tr"],
    "Rb": ["Sh", "Ix", "Vl", "Pl", "Im", "Cd", "Ps", "Rd"],
    "Pl": ["Sh", "Ix", "Rb"],
    "Im": ["Sh", "Ix", "Rb", "Ct"],
    "Uc": ["Sh", "Ix", "Rb", "Ft"],
    "Cd": ["Sh", "Ix", "Rb", "Rd", "Ps", "As"],
}


def forward_open(X):
    S = norm(X)
    return [(lid, "|".join(t)) for lid, subs, terms in LSTAR
            if any(s in S for s in subs) for t in terms if not has(S, *t)]


def unwarranted(X):
    S = norm(X)
    return [e for e in sorted(S) if e in CONSUME and not has(S, *CONSUME[e])]


def hazard_viol(X):
    S = norm(X)
    out = []
    if "Uc" in S and not (has(S, "Aw") and has(S, "At")):
        out.append("X11a*")
    if has(S, "Aw") and has(S, "Xf") and not has(S, "At", "Fz", "Xm"):
        out.append("X19*")
    if has(S, "Fl") and has(S, "Cp", "Cl") and has(S, "Pl", "Cd", "Im"):
        out.append("X2")
    if has(S, "Oa") and has(S, "Li") and not has(S, "Ex", "Tp"):
        out.append("X18")
    if "Fl" in S and has(S, "Xf", "Rl", "Of"):
        out.append("X21")
    out += armed_ref(X)
    return out


def ungrounded(X):
    S = norm(X)
    return any(GRP[e] in RISKG for e in S) and not any(ST[e] <= 2 for e in S)


def admissible(X, parts=False):
    f, w, h, g = forward_open(X), unwarranted(X), hazard_viol(X), ungrounded(X)
    ok = not (f or w or h or g)
    return (ok, dict(closure=f, warrant=w, hazard=h, ground=g)) if parts else ok


R = [c for c in blind if c["id"] in real_ids]
N = [c for c in blind if c["id"] not in real_ids]

if __name__ == "__main__":
    a = sum(1 for c in R if admissible(c["elements"]))
    b = sum(1 for c in N if admissible(c["elements"]))
    print(f"REAL {a}/72={a/72:.3f}  OTHER {b}/84={b/84:.3f}  RATIO {(a/72)/(b/84):.2f}")
    print("\n--- false rejects ---")
    for c in R:
        ok, p = admissible(c["elements"], parts=True)
        if not ok:
            print("  FR", c["id"], LANESETS[frozenset(c["elements"])], {k: v for k, v in p.items() if v})
    print("\n--- survivors among non-lane ---")
    for c in N:
        if admissible(c["elements"]):
            print("  FA", c["id"], sorted(c["elements"]))

    # ablation: contribution of each block
    blocks = {"closure": lambda X: forward_open(X), "warrant": unwarranted,
              "hazard": hazard_viol, "ground": lambda X: ungrounded(X)}
    print("\n--- ablation (drop one block) ---")
    for drop in blocks:
        def adm(X, drop=drop):
            return not any(bool(f(X)) for k, f in blocks.items() if k != drop)
        a2 = sum(1 for c in R if adm(c["elements"]))
        b2 = sum(1 for c in N if adm(c["elements"]))
        print(f"  without {drop:8s}: real {a2}/72={a2/72:.3f} other {b2}/84={b2/84:.3f} ratio {(a2/72)/(b2/84):.2f}")
    print("\n--- each block alone ---")
    for k, f in blocks.items():
        a2 = sum(1 for c in R if not f(c["elements"]))
        b2 = sum(1 for c in N if not f(c["elements"]))
        print(f"  only {k:8s}: real {a2}/72={a2/72:.3f} other {b2}/84={b2/84:.3f} ratio {(a2/72)/(b2/84):.2f}")
