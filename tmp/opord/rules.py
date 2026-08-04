import collections, json
from atlas import *

avail = collections.Counter({k: len(v) for k, v in LANESETS.items()})
real_ids = set()
for c in blind:
    fs = frozenset(c["elements"])
    if avail.get(fs, 0) > 0:
        avail[fs] -= 1
        real_ids.add(c["id"])
R = [c["elements"] for c in blind if c["id"] in real_ids]
N = [c["elements"] for c in blind if c["id"] not in real_ids]

G = {s: ELEMS[s]["group"] for s in ELEMS}
ST = {s: ELEMS[s]["stratum"] for s in ELEMS}


def has(X, *ss):
    return any(s in X for s in ss)


# ---------------- closure with mixed terms treated as external (C1)
MIXED_LAWS = {"L6", "L7", "L8", "L14", "L15"}


def mixed_terms(law):
    out = []
    for t in law["terms"]:
        if t["external"]:
            out.append(("EXT", t))
            continue
        proseparts = [bare(a) for a in t["prose"].split("|")]
        if any(p not in SYMS for p in proseparts):
            out.append(("MIX", t))
        else:
            out.append(("INT", t))
    return out


PT = {law["id"]: mixed_terms(law) for law in PARSED}

# promoted prose witnesses: obligation -> element witnesses
PROMOTE = {
    "liquidation capacity": ["Li", "Ad", "Sl", "Bs"],
    "named custodian, plus a global claim ledger": ["At", "Aw", "Fz", "Rd", "Ps"],
    "bounded emergency process": ["Gp", "Fz"],
    "mechanical trigger": ["Ct", "Ex", "Oa", "Ep", "At"],
    "bounded liquidity reserve": ["Bs", "Ps", "Rd"],
    "obligor": ["At", "Aw", "Sv", "Fz"],
    "exit-liquidity": ["Wq", "Rd", "Ps", "Cp", "Cl", "St", "Wg", "Pm", "Ob", "Ag", "Fl", "Sr", "Xf", "Ep", "Rf"],
    "settlement verifier": ["Xm", "Ob", "Ba", "Oa", "Rl", "Bs"],
    "(solver|fallback)": ["Bs", "Rf", "Ag", "Ob", "Ba", "Rl", "Of"],
    "proof verifier": ["Sd", "Xm", "Oa"],
    "nullifier set": ["Sb"],
    "credential source": ["Aw", "At"],
    "revocation": ["Aw", "Gp", "Fz", "Au"],
    "attributed slash condition": ["Sl", "Bs"],
    "loss waterfall": ["Sl", "Tr", "Bs", "Ad"],
    "non-reflexive capital": ["Vl", "Bs", "Sh"],
}


def close2(X, use_promotion=True, mixed_external=True):
    """returns list of (lawid, prose) unmet"""
    S = set(X)
    bad = []
    for law in PARSED:
        if not any(s in S for s in law["subjects"]):
            continue
        for kind, t in PT[law["id"]]:
            if kind == "INT":
                ok = any(a in S for a in t["alts"])
            elif kind == "MIX":
                if mixed_external:
                    ok = True
                else:
                    ok = any(a in S for a in t["alts"])
                if use_promotion and not ok:
                    for p in t["prose"].split("|"):
                        w = PROMOTE.get(p.strip())
                        if w and has(S, *w):
                            ok = True
            else:  # EXT
                ok = True
                if use_promotion:
                    w = PROMOTE.get(t["prose"].strip())
                    if w is not None:
                        ok = has(S, *w)
            if not ok:
                bad.append((law["id"], t["prose"]))
    return bad


# ---------------- warrant (residual) sets
WARRANT = {
    "Ct": ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Dp", "Rs", "Tr", "Cv", "Pm", "Ob", "Fl", "Vl"],
    "Li": ["Ct"],
    "Ad": ["Ct", "Pf", "Ob"],
    "Sl": ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Tr", "Cv", "Rs", "Vl", "Ob", "Dp", "Bs", "Ct", "Xf"],
    "Bs": ["Pl", "Im", "Cd", "Uc", "Pf", "Op", "Rs", "Vl", "In", "Of", "Xm", "Xf", "Cv", "Tr", "Ob", "Ct", "Sl", "Rl", "Ba"],
    "Tp": ["Cp", "Cl", "St", "Wg", "Pm", "Ob"],
    "Xm": ["Xf", "Rs", "In", "Of", "Rl", "Vl", "Ob", "Sb"],
    "Sv": ["Tr", "Pl", "Im", "Uc", "Ft", "Cv", "Op", "Cd", "Rl", "Sh", "Ep", "Wq"],
    "Ps": ["At", "Rd", "Cd", "Xf", "Sh", "Ix", "Sr"],
    "As": ["Rd", "Ps", "At", "Bs", "Ex", "Cd", "Cl"],
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
}


def unwarranted(X):
    S = set(X)
    return [e for e in S if e in WARRANT and not has(S, *WARRANT[e])]


# ---------------- rule bank
def rules(X):
    S = set(x for x in X if x in SYMS)
    v = {}
    v["closure_ref"] = bool(closes_ref(X))
    v["closure_C1"] = bool(close2(X, use_promotion=False))
    v["closure_C1P"] = bool(close2(X, use_promotion=True))
    v["armed_ref"] = bool(armed_ref(X))
    v["warrant"] = bool(unwarranted(X))
    v["Uc_bare"] = "Uc" in S and not (has(S, "Aw") and has(S, "At"))
    v["X2"] = has(S, "Fl") and has(S, "Cp", "Cl") and has(S, "Pl", "Cd", "Im")
    v["X18"] = has(S, "Oa") and has(S, "Li") and not has(S, "Ex", "Tp")
    v["FlXm"] = has(S, "Fl") and has(S, "Xm", "Xf", "Rl", "Of")
    v["ground_any"] = len(S) >= 3 and all(ST[e] >= 3 for e in S)
    v["ground_s3"] = any(ST[e] >= 3 for e in S) and not any(ST[e] <= 2 for e in S)
    v["ground_s4"] = any(ST[e] == 4 for e in S) and not any(ST[e] <= 2 for e in S)
    # anchor: at least one "product" element
    PRODUCT = {"G01", "G02", "G03", "G04", "G05", "G07", "G13", "G15", "G16"}
    v["no_anchor"] = not any(G[e] in PRODUCT for e in S)
    v["ngroups"] = len({G[e] for e in S})
    return v


keys = ["closure_ref", "closure_C1", "closure_C1P", "armed_ref", "warrant", "Uc_bare", "X2", "X18", "FlXm", "ground_any", "ground_s3", "ground_s4", "no_anchor"]
print(f"{'rule':14s} {'realRej':>8s} {'otherRej':>9s}")
for k in keys:
    rr = sum(1 for X in R if rules(X)[k])
    nr = sum(1 for X in N if rules(X)[k])
    print(f"{k:14s} {rr:8d} {nr:9d}")

print()
print("ngroups/|X| ratio real:", sorted(collections.Counter(round(rules(X)['ngroups'] / len(X), 1) for X in R).items()))
print("ngroups/|X| ratio other:", sorted(collections.Counter(round(rules(X)['ngroups'] / len(X), 1) for X in N).items()))

print()
print("--- unwarranted detail on REAL rejections ---")
for c in blind:
    if c["id"] in real_ids:
        u = unwarranted(c["elements"])
        if u:
            print(c["id"], LANESETS[frozenset(c["elements"])], u)
print()
print("--- closure_C1P detail on REAL rejections ---")
for c in blind:
    if c["id"] in real_ids:
        u = close2(c["elements"])
        if u:
            print(c["id"], LANESETS[frozenset(c["elements"])], u)
