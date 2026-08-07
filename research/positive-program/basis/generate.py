#!/usr/bin/env python3
"""THE GENERATION CHECK.

Criterion (reading (c), strengthened):
  A definition d of protocol spec S in lane L is P-GENERATED iff every applied
  operator in body(d) lies in
        Pi  (economically inert plumbing builtins)
      U B_L (operators declared in L/common.qnt   = the lane's basis reduct)
      U G(S)(definitions of S already shown generated; well-founded)
  and NO operator of Pi_hard = {imul, idiv, imod, ipow} occurs anywhere in
  body(d) outside a B_L call.

  Pi_hard is what makes the reading non-degenerate: multiplicative and
  divisive arithmetic on state-derived magnitudes IS the content of the
  families (pro-rata F1, index F7, health F5, payoff F8).  Admitting it as
  free plumbing would make every spec trivially generated.
"""
import json, os, collections, sys

IR = os.environ.get("GEN_IR", "/root/gen-ir")
HARD = {"imul", "idiv", "imod", "ipow"}

# ---------------------------------------------------------------- IR walking
def subexprs(e):
    """Yield every expression node, depth-first."""
    if not isinstance(e, dict): return
    k = e.get("kind")
    yield e
    if k == "app":
        for a in e.get("args", []): yield from subexprs(a)
    elif k == "lambda":
        yield from subexprs(e.get("expr"))
    elif k == "let":
        d = e.get("opdef")
        if d: yield from subexprs(d.get("expr"))
        yield from subexprs(e.get("expr"))

def pp(e, depth=0):
    """Pretty-print an IR expression back to quint-ish source."""
    if not isinstance(e, dict): return "?"
    k = e.get("kind")
    if k == "name": return e["name"]
    if k in ("int", "bool", "str"): return str(e["value"])
    if k == "lambda":
        ps = ", ".join(p["name"] for p in e.get("params", []))
        return f"({ps}) => {pp(e['expr'], depth+1)}"
    if k == "let":
        d = e.get("opdef", {})
        return f"let {d.get('name')} = {pp(d.get('expr'), depth+1)} in {pp(e['expr'], depth+1)}"
    if k == "app":
        op = e["opcode"]
        a = [pp(x, depth+1) for x in e.get("args", [])]
        inf = {"iadd": "+", "isub": "-", "imul": "*", "idiv": "/", "imod": "%",
               "igt": ">", "ige": ">=", "igte": ">=", "ilt": "<", "ilte": "<=",
               "eq": "==", "neq": "!=", "and": " and ", "or": " or "}
        if op in inf and len(a) == 2:
            s = inf[op]
            if s.strip() in ("and", "or"): return "(" + s.join(a) + ")"
            return f"({a[0]} {s} {a[1]})"
        if op == "assign" and len(a) == 2: return f"{a[0]}' = {a[1]}"
        return f"{op}({', '.join(a)})"
    return f"<{k}>"

# --------------------------------------------------- second-order matching
def match(pat, term, binding, metas):
    """Match basis-body pattern `pat` (params in `metas` are metavariables)
    against `term`.  Returns True/False."""
    if not isinstance(pat, dict) or not isinstance(term, dict): return False
    if pat.get("kind") == "name" and pat["name"] in metas:
        m = pat["name"]
        if m in binding:
            return canon(binding[m]) == canon(term)
        binding[m] = term
        return True
    if pat.get("kind") != term.get("kind"): return False
    k = pat["kind"]
    if k == "name": return pat["name"] == term["name"]
    if k in ("int", "bool", "str"): return pat["value"] == term["value"]
    if k == "app":
        if pat["opcode"] != term["opcode"]: return False
        pa, ta = pat.get("args", []), term.get("args", [])
        if len(pa) != len(ta): return False
        return all(match(p, t, binding, metas) for p, t in zip(pa, ta))
    return False

def canon(e):
    if not isinstance(e, dict): return None
    k = e.get("kind")
    if k == "name": return ("n", e["name"])
    if k in ("int", "bool", "str"): return ("l", e["value"])
    if k == "app": return ("a", e["opcode"], tuple(canon(x) for x in e.get("args", [])))
    return ("?", k)

# ---------------------------------------------------------------- load IR
files = sorted(f for f in os.listdir(IR) if f.endswith(".json") and "__" in f)
basis = {}        # lane -> {name: body-expr or None}
basis_pats = collections.defaultdict(list)   # lane -> [(name, bodyexpr, metas)]
specs = {}        # (lane, spec) -> [decl]

for fn in files:
    lane, spec = fn[:-5].split("__")
    d = json.load(open(os.path.join(IR, fn)))
    for m in d["modules"]:
        if m["name"] == "common":
            if lane in basis: continue
            basis[lane] = {}
            for de in m["declarations"]:
                if de["kind"] == "def":
                    body = de.get("expr", {})
                    metas = set()
                    if body.get("kind") == "lambda":
                        metas = {p["name"] for p in body.get("params", [])}
                        body = body["expr"]
                    basis[lane][de["name"]] = body
                    basis_pats[lane].append((de["name"], body, metas))
                elif de["kind"] in ("var", "const", "typedef"):
                    basis[lane][de.get("name")] = None
        else:
            if spec == "common": continue
            specs[(lane, spec)] = m["declarations"]

# ---- NON-DEGENERACY FILTER ON THE PATTERN SET -----------------------------
# A basis operator may serve as a matching template only if it is SUBSTANTIVE:
# its body must not be a single builtin application whose arguments are all
# distinct bare metavariables.  `collValue(a,p) = a*p` is exactly imul(X,Y) --
# a rebadged builtin, a universal pattern that would match every product in the
# corpus and make the classification vacuous.  Such ops are recorded and
# excluded from the templates.
def is_trivial(body, metas):
    if not isinstance(body, dict) or body.get("kind") != "app": return False
    args = body.get("args", [])
    names = [a.get("name") for a in args if isinstance(a, dict) and a.get("kind") == "name"]
    return (len(names) == len(args) and len(args) > 0
            and all(n in metas for n in names) and len(set(names)) == len(names))

TRIVIAL = collections.defaultdict(list)
sub_pats = collections.defaultdict(list)
for lane, pats in basis_pats.items():
    for nm, body, metas in pats:
        if is_trivial(body, metas):
            TRIVIAL[lane].append((nm, pp(body)))
        else:
            sub_pats[lane].append((nm, body, metas))

print("=== NON-SUBSTANTIVE basis operators (bare builtin aliases, excluded as templates) ===")
for lane in sorted(TRIVIAL):
    for nm, b in TRIVIAL[lane]: print(f"   {lane}/common.{nm}  ==  {b}")
print()

basis_pats = sub_pats
# widen basis patterns with hard-op-bearing subterms of substantive basis bodies
basis_cores = collections.defaultdict(list)
for lane, pats in basis_pats.items():
    for nm, body, metas in pats:
        for s in subexprs(body):
            if s.get("kind") == "app" and s["opcode"] in HARD and not is_trivial(s, metas):
                basis_cores[lane].append((nm, s, metas))

# ---------------------------------------------------------------- the check
results = {}
all_violations = []
CONST = {}

for (lane, spec), decls in sorted(specs.items()):
    B = set(basis.get(lane, {}))
    local_defs = {de["name"]: de for de in decls if de["kind"] == "def"}
    local_vars = {de["name"] for de in decls if de["kind"] == "var"}
    # dependency + own-violation pass
    own_bad = {}      # name -> [violating subterm]
    deps = {}
    for nm, de in local_defs.items():
        body = de.get("expr", {})
        metas = set()
        if body.get("kind") == "lambda":
            metas = {p["name"] for p in body.get("params", [])}
            body = body["expr"]
        bad, dep, const_folds = [], set(), []

        # CLOSEDNESS: a hard op whose every leaf is a literal or a closed 0-ary
        # pureval is constant folding -- it computes a number, not a mechanism.
        # `BASE_BPS / 2` and `100 * 100` are not economic content; `collat / 2`
        # (collat is state) is.
        closed_vals = set()
        cand = dict(local_defs)
        for bn, bbody in basis.get(lane, {}).items():
            if bbody is not None: cand.setdefault(bn, {"expr": bbody})
        for cn, cd in cand.items():
            ce = cd.get("expr", {})
            if ce.get("kind") != "lambda":
                if all(s.get("kind") in ("int", "bool", "str")
                       or (s.get("kind") == "app" and s["opcode"] in
                           ("iadd", "isub", "imul", "idiv", "imod", "iuminus"))
                       for s in subexprs(ce)):
                    closed_vals.add(cn)
        def is_closed(e):
            for s in subexprs(e):
                k = s.get("kind")
                if k == "name":
                    if s["name"] not in closed_vals: return False
                elif k == "app":
                    if s["opcode"] not in ("iadd","isub","imul","idiv","imod","iuminus"):
                        return False
                elif k not in ("int","bool","str"): return False
            return True

        # Report only MAXIMAL violating subterms.  On hitting a hard op outside
        # a basis call, record that whole node; do not report hard ops nested
        # inside it (they are part of the same violation) -- but do resume
        # reporting inside any basis call appearing beneath it.
        def scan(e, under_hard):
            if not isinstance(e, dict): return
            k = e.get("kind")
            if k == "app":
                op = e["opcode"]
                if op in B:
                    dep.add(("B", op))
                    for a in e.get("args", []): scan(a, False)
                    return
                if op in local_defs: dep.add(("L", op))
                if op in HARD and not under_hard:
                    if is_closed(e): const_folds.append(e)
                    else:            bad.append(e)
                    for a in e.get("args", []): scan(a, True)
                    return
                for a in e.get("args", []): scan(a, under_hard)
                return
            if k == "name":
                n = e["name"]
                if n in B: dep.add(("B", n))
                elif n in local_defs: dep.add(("L", n))
                return
            if k == "lambda": scan(e.get("expr"), under_hard); return
            if k == "let":
                d = e.get("opdef")
                if d: scan(d.get("expr"), under_hard)
                scan(e.get("expr"), under_hard); return
        scan(body, False)
        own_bad[nm] = bad
        CONST[(lane, spec, nm)] = const_folds
        deps[nm] = dep

    # transitive closure: a def is generated iff it and all local deps are clean
    gen = {nm: (len(own_bad[nm]) == 0) for nm in local_defs}
    changed = True
    while changed:
        changed = False
        for nm in local_defs:
            if not gen[nm]: continue
            for kind, dn in deps[nm]:
                if kind == "L" and dn in gen and not gen[dn]:
                    gen[nm] = False; changed = True
    results[(lane, spec)] = (gen, own_bad, local_defs, deps)

    for nm, bads in own_bad.items():
        for b in bads:
            # classify
            cls, via = "B-novel", None
            for bn, pat, metas in basis_pats[lane]:
                if match(pat, b, {}, metas): cls, via = "A1-inlined-basis-body", bn; break
            if cls == "B-novel":
                for bn, pat, metas in basis_cores[lane]:
                    if match(pat, b, {}, metas): cls, via = "A2-inlined-basis-core", bn; break
            all_violations.append(dict(lane=lane, spec=spec, defn=nm,
                                       qual=local_defs[nm].get("qualifier"),
                                       term=pp(b), cls=cls, via=via))

# ---------------------------------------------------------------- report
tot_defs = sum(len(r[2]) for r in results.values())
tot_gen = sum(sum(1 for v in r[0].values() if v) for r in results.values())
print(f"protocol specs           : {len(results)}")
print(f"definitions tested       : {tot_defs}")
print(f"definitions P-generated  : {tot_gen}")
print(f"definitions NOT generated: {tot_defs - tot_gen}")

clean_specs = [k for k, r in results.items() if all(r[0].values())]
dirty_specs = [k for k, r in results.items() if not all(r[0].values())]
print(f"\nSPECS FULLY GENERATED    : {len(clean_specs)}")
print(f"SPECS WITH RESIDUE       : {len(dirty_specs)}")
print("\n-- clean --")
for l, s in sorted(clean_specs): print(f"   {l}/{s}")
print("\n-- residue --")
for l, s in sorted(dirty_specs):
    gen, own_bad, ld, _ = results[(l, s)]
    ng = [n for n in ld if not gen[n]]
    print(f"   {l}/{s}: {len(ng)} ungenerated def(s): {', '.join(sorted(ng))}")

nconst = sum(len(v) for v in CONST.values())
print(f"\nconstant-folding hard ops excluded (economically inert): {nconst}")
for k, v in sorted(CONST.items()):
    for e in v: print(f"   {k[0]}/{k[1]} {k[2]}: {pp(e)}")

print("\n================ EVERY VIOLATING SUBTERM (maximal) ================")
byc = collections.Counter(v["cls"] for v in all_violations)
print("classification counts:", dict(byc), " total:", len(all_violations))
for v in sorted(all_violations, key=lambda x: (x["cls"], x["lane"], x["spec"], x["defn"])):
    print(f"[{v['cls']:24s}] {v['lane']}/{v['spec']:16s} {v['qual']:8s} {v['defn']}")
    print(f"      term : {v['term']}")
    if v["via"]: print(f"      matches basis op: {v['via']}")

json.dump(dict(results={f"{k[0]}/{k[1]}": {"gen": r[0]} for k, r in results.items()},
               violations=all_violations),
          open(os.environ.get("GEN_RESULT", "/root/RESULT.json"), "w"), indent=1)
