"""OP-ORD model v2: closure operator gamma, residual rho (Galois adjoint),
hazard rows restated as laws, stratum ideal."""
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


def norm(X):
    return set(x for x in X if x in SYMS)


def has(S, *ss):
    return any(s in S for s in ss)


PRICE = ["Ex", "Tp", "At", "Oa", "Pm", "Cl", "Cp", "St", "Wg", "Ob", "Sv"]
LOSS = ["Li", "Ad", "Sl", "Bs"]

# ---- revised law system L* (element-expressible fragment only)
# each law: (id, subjects, [terms]) ; a term is a list of element alternatives
LSTAR = [
    ("L1a", ["Pl", "Im", "Cd", "Pf"], [PRICE]),
    ("L1b", ["Op"], [PRICE]),
    ("L1c", ["Pl", "Im", "Cd", "Pf"], [["Ct"]]),
    ("L1d", ["Pl", "Im", "Cd", "Pf"], [LOSS]),
    ("L2", ["Pl"], [["Sh", "Ix", "Rb"]]),
    ("L3", ["Uc"], [["Aw"], ["At"], ["Bs", "Tr", "Sv", "Ft", "Ct"], ["Sv", "Ft", "Fz", "Ep", "Tr"]]),
    ("L4", ["Pf"], [["Ex", "Tp", "Oa", "Pm", "At"], ["Ct"], ["Li", "Ad", "Sl", "Bs"]]),
    ("L5", ["Py"], [["Sh", "Ix", "Rb"], ["Ep"], ["Rd"]]),
    ("L7", ["Cd"], [["Rd", "Ps", "Li", "Ad", "Sl", "Bs"]]),
    ("L19", ["Of"], [["Xm"], ["Xf"], ["Bs", "Sl"]]),
    ("L20", ["Rl"], [["Au"]]),
    ("L21", ["Gs"], [["Au"]]),
]


def forward_open(X, drop=()):
    S = norm(X)
    bad = []
    for lid, subs, terms in LSTAR:
        if lid in drop:
            continue
        if not any(s in S for s in subs):
            continue
        for t in terms:
            if not has(S, *t):
                bad.append((lid, "|".join(t)))
    return bad


# ---- residual / consumer warrants
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
CONSUME_OPT = {
    "PlLoss": ("Pl", ["Sl", "Bs", "Ad", "Wq", "Tr", "Sv", "Im", "Rd", "Ps", "Of", "Cv"]),
}


def unwarranted(X, opt=()):
    S = norm(X)
    bad = [e for e in sorted(S) if e in CONSUME and not has(S, *CONSUME[e])]
    for k in opt:
        e, cs = CONSUME_OPT[k]
        if e in S and not has(S, *cs):
            bad.append(e + "!" + k)
    return bad


def hazard_viol(X, x21=True):
    S = norm(X)
    out = []
    if "Uc" in S and not (has(S, "Aw") and has(S, "At")):
        out.append("X11a")
    if has(S, "Aw") and has(S, "Xf") and not has(S, "At", "Fz", "Xm"):
        out.append("X19")
    if has(S, "Fl") and has(S, "Cp", "Cl") and has(S, "Pl", "Cd", "Im"):
        out.append("X2")
    if has(S, "Oa") and has(S, "Li") and not has(S, "Ex", "Tp"):
        out.append("X18")
    if x21 and "Fl" in S and has(S, "Xf", "Rl", "Of"):
        out.append("X21")
    out += armed_ref(X)
    return out


def ungrounded(X):
    S = norm(X)
    return any(GRP[e] in RISKG for e in S) and not any(ST[e] <= 2 for e in S)


def admissible(X, parts=False, opt=(), drop=(), x21=True):
    f = forward_open(X, drop)
    w = unwarranted(X, opt)
    h = hazard_viol(X, x21)
    g = ungrounded(X)
    ok = not (f or w or h or g)
    if parts:
        return ok, dict(closure=f, warrant=w, hazard=h, ground=g)
    return ok


R = [c for c in blind if c["id"] in real_ids]
N = [c for c in blind if c["id"] not in real_ids]


def report(**kw):
    a = sum(1 for c in R if admissible(c["elements"], **kw))
    b = sum(1 for c in N if admissible(c["elements"], **kw))
    ar, br = a / len(R), b / len(N)
    return a, b, ar, br, (ar / br if br else float("inf"))


if __name__ == "__main__":
    for opt in [(), ("PlLoss",)]:
        for x21 in [True, False]:
            a, b, ar, br, rt = report(opt=opt, x21=x21)
            print(f"opt={opt} x21={x21}: real {a}/72={ar:.3f} other {b}/84={br:.3f} ratio {rt:.2f}")
    print()
    print("--- chosen: opt=(), x21=False ---")
    for c in R:
        ok, p = admissible(c["elements"], parts=True, x21=False)
        if not ok:
            print("  FR", c["id"], LANESETS[frozenset(c["elements"])], {k: v for k, v in p.items() if v})
    print()
    for c in N:
        if admissible(c["elements"], x21=False):
            print("  FA", c["id"], sorted(c["elements"]))
