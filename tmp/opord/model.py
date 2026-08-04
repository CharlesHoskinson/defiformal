"""OP-ORD model: closure operator + residual (Galois adjoint) + corrected hazard laws."""
import collections, json, itertools
from atlas import *

# ---------------------------------------------------------------- corpora
avail = collections.Counter({k: len(v) for k, v in LANESETS.items()})
real_ids = set()
for c in blind:
    fs = frozenset(c["elements"])
    if avail.get(fs, 0) > 0:
        avail[fs] -= 1
        real_ids.add(c["id"])

ST = {s: ELEMS[s]["stratum"] for s in ELEMS}
GRP = {s: ELEMS[s]["group"] for s in ELEMS}


def norm(X):
    return set(x for x in X if x in SYMS)


def has(S, *ss):
    return any(s in S for s in ss)


# --------------------------------------------------- (1) forward closure  gamma
# mixed terms (element alternative beside a prose alternative) are NOT decidable
# from membership -> external. Promotions listed explicitly.
PROMOTE = {
    "liquidation capacity": ["Li", "Ad", "Sl", "Bs"],
    "obligor": ["Sv", "Ft", "Fz", "Ep", "Tr"],
}
MIXED = {"L6", "L7", "L8", "L14", "L15"}


def term_kind(t):
    if t["external"]:
        return "EXT"
    parts = [bare(a) for a in t["prose"].split("|")]
    return "MIX" if any(p not in SYMS for p in parts) else "INT"


TERMS = {l["id"]: [(term_kind(t), t) for t in l["terms"]] for l in PARSED}


def forward_open(X):
    S = norm(X)
    bad = []
    for law in PARSED:
        if not any(s in S for s in law["subjects"]):
            continue
        for kind, t in TERMS[law["id"]]:
            if kind == "INT":
                ok = has(S, *t["alts"])
            elif kind == "MIX":
                ok = True
                for p in t["prose"].split("|"):
                    w = PROMOTE.get(p.strip())
                    if w is not None:
                        ok = has(S, *t["alts"]) or has(S, *w)
            else:
                w = PROMOTE.get(t["prose"].strip())
                ok = True if w is None else has(S, *w)
            if not ok:
                bad.append((law["id"], t["prose"]))
    return bad


# --------------------------------------------- (2) residual / consumer warrant
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
}


def unwarranted(X):
    S = norm(X)
    return [e for e in sorted(S) if e in CONSUME and not has(S, *CONSUME[e])]


# ------------------------------------- (3) hazard rows restated as laws / bans
def hazard_viol(X):
    S = norm(X)
    out = []
    # X11a, polarity restored (FINDINGS option b)
    if "Uc" in S and not (has(S, "Aw") and has(S, "At")):
        out.append("X11a")
    # X19, polarity restored: a restricted claim crossing a domain needs
    # destination-side enforcement or a named attester
    if has(S, "Aw") and has(S, "Xf") and not has(S, "At", "Fz", "Xm"):
        out.append("X19")
    # X2 as a ban (economic magnitude, kept prohibitive)
    if has(S, "Fl") and has(S, "Cp", "Cl") and has(S, "Pl", "Cd", "Im"):
        out.append("X2")
    # X18
    if has(S, "Oa") and has(S, "Li") and not has(S, "Ex", "Tp"):
        out.append("X18")
    # computed hazard from FINDINGS 12.1 - Fl is async-impossible
    if "Fl" in S and has(S, "Xm", "Xf", "Rl", "Of"):
        out.append("X21")
    # membership-evaluable written rows
    for h in armed_ref(X):
        out.append(h)
    return out


# ------------------------------------------------- (4) grounding / stratum ideal
def ungrounded(X):
    S = norm(X)
    return bool(S) and any(ST[e] >= 3 for e in S) and not any(ST[e] <= 2 for e in S)


# ------------------------------------------------------------- the predicate
def admissible(X, parts=False):
    f = forward_open(X)
    w = unwarranted(X)
    h = hazard_viol(X)
    g = ungrounded(X)
    ok = not (f or w or h or g)
    if parts:
        return ok, dict(closure=f, warrant=w, hazard=h, ground=g)
    return ok


if __name__ == "__main__":
    R = [c for c in blind if c["id"] in real_ids]
    N = [c for c in blind if c["id"] not in real_ids]
    a = sum(1 for c in R if admissible(c["elements"]))
    b = sum(1 for c in N if admissible(c["elements"]))
    ar, br = a / len(R), b / len(N)
    print(f"REAL  {a}/{len(R)} = {ar:.3f}")
    print(f"OTHER {b}/{len(N)} = {br:.3f}")
    print(f"RATIO {ar/br:.2f}")
    print()
    print("--- false rejects (lane protocols judged INADMISSIBLE) ---")
    for c in R:
        ok, p = admissible(c["elements"], parts=True)
        if not ok:
            print(" ", c["id"], LANESETS[frozenset(c["elements"])], {k: v for k, v in p.items() if v})
    print()
    print("--- surviving non-lane cases ---")
    for c in N:
        if admissible(c["elements"]):
            print(" ", c["id"], sorted(c["elements"]))
