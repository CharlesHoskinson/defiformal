import json, glob, itertools, os
from collections import defaultdict
import os as _os
from pathlib import Path as _Path
# Resolved from this file's own location, the pattern gate33_cert_check.py uses.
# DEFIFORMAL_ROOT overrides and says so.
_SELF = _Path(__file__).resolve().parents[3]
_REPO = _Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    import sys as _sys
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


specs = sorted(glob.glob(str(_REPO / "expansion/*/specs/*.json")))
P = {}
cat = {}
for f in specs:
    d = json.load(open(f))
    name = d.get('app') or os.path.basename(f)
    P[name] = set(d.get('construction', []))
    cat[name] = d.get('category','?')
names = sorted(P)
print("protocols:", len(names))
E = sorted(set().union(*P.values()))
print("elements used:", len(E))

# prohibitions, element-set semantics
def arms_X21(X): return 'Fl' in X and bool(X & {'Xf','Rl','Of'})
def arms_X2(X):  return 'Fl' in X and bool(X & {'Cp','Cl'}) and bool(X & {'Pl','Cd'})
def bad(X): return arms_X21(X) or arms_X2(X)

self_bad = [n for n in names if bad(P[n])]
print("self-arming protocols:", len(self_bad), self_bad)
seeds = [n for n in names if not bad(P[n])]
print("clean seeds:", len(seeds))

fail = []
for a,b in itertools.combinations(seeds,2):
    U = P[a]|P[b]
    if bad(U): fail.append((a,b,'X21' if arms_X21(U) else '', 'X2' if arms_X2(U) else ''))
tot = len(seeds)*(len(seeds)-1)//2
print("pairs:", tot, "failing:", len(fail), "edge density: %.4f" % (1-len(fail)/tot))

endpoints = defaultdict(int)
for a,b,_,_ in fail:
    endpoints[a]+=1; endpoints[b]+=1
print("failure endpoints:", len(endpoints))
for n,c in sorted(endpoints.items(), key=lambda x:-x[1]):
    print("   %-24s deg=%3d  Fl=%s  elts=%s" % (n,c,'Fl' in P[n], sorted(P[n]&{'Fl','Xf','Rl','Of','Cp','Cl','Pl','Cd'})))

# vertex cover of failure graph = greedy/exact over Fl carriers
Fl_carriers = [n for n in seeds if 'Fl' in P[n]]
print("Fl carriers among seeds:", len(Fl_carriers), Fl_carriers)
covered = all((a in Fl_carriers) or (b in Fl_carriers) for a,b,_,_ in fail)
print("every failing pair has an Fl endpoint:", covered)

# max clique in compatibility graph = max independent set in failure graph
cover = set(endpoints)   # exact: failure graph lives on these vertices only
free = [n for n in seeds if n not in cover]
best = None
covL = sorted(cover)
failset = set()
for a,b,_,_ in fail: failset.add(frozenset((a,b)))
for r in range(len(covL),-1,-1):
    found=False
    for S in itertools.combinations(covL,r):
        ok=True
        for x,y in itertools.combinations(S,2):
            if frozenset((x,y)) in failset: ok=False;break
        if ok:
            best=set(S); found=True; break
    if found: break
print("max clique size = %d (free %d + %d of the %d failure vertices) : %s" %
      (len(free)+len(best), len(free), len(best), len(covL), sorted(best)))
print("checks needed: 2^%d = %d" % (len(covL), 2**len(covL)))

# ---- nerve of the element cover -------------------------------------------
# contexts = protocols, variables = elements. nerve simplices = families with
# common element.  Compute per-element star sizes.
star = {e: [n for n in seeds if e in P[n]] for e in E}
print("\n--- nerve of the cover (contexts=protocols, variables=elements) ---")
for e in sorted(E, key=lambda e:-len(star[e]))[:8]:
    print("   %-3s carried by %d protocols" % (e, len(star[e])))
print("   Fl star:", len(star.get('Fl',[])), "Xf:", len(star.get('Xf',[])),
      "Rl:", len(star.get('Rl',[])), "Of:", len(star.get('Of',[])))

# ---- scope sheaf: cellular cochain computation over the failure graph ------
# Vertices: the failure-graph protocols. Stalk over v: F(v) = R^{S(v)} where
# S(v) = P[v] cap Trig, Trig = elements named by a prohibition.
Trig = ['Fl','Xf','Rl','Of','Cp','Cl','Pl','Cd']
V = sorted(set(endpoints))
Edges = [(a,b) for a,b,_,_ in fail]
def stalkV(v): return [e for e in Trig if e in P[v]]
def stalkE(a,b): return [e for e in Trig if e in P[a] and e in P[b]]
d0v = sum(len(stalkV(v)) for v in V)
d0e = sum(len(stalkE(a,b)) for a,b in Edges)
print("\n--- cellular scope sheaf on the failure graph ---")
print("vertices %d edges %d ; dim C0 = %d, dim C1 = %d" % (len(V),len(Edges),d0v,d0e))

# rank of delta0 for the constant-restriction (identity) sheaf: this is the
# incidence structure of the "element-wise" graph -- per element e, the
# subgraph of edges whose both endpoints carry e.
import fractions
h0=h1=0
for e in Trig:
    Ve=[v for v in V if e in P[v]]
    Ee=[(a,b) for a,b in Edges if e in P[a] and e in P[b]]
    # connected components of (Ve,Ee)
    par={v:v for v in Ve}
    def find(x):
        while par[x]!=x: par[x]=par[par[x]]; x=par[x]
        return x
    for a,b in Ee:
        ra,rb=find(a),find(b)
        if ra!=rb: par[ra]=rb
    comps=len({find(v) for v in Ve})
    b1 = len(Ee)-len(Ve)+comps if Ve else 0
    h0+=comps; h1+=b1
    print("   element %-3s: |V_e|=%2d |E_e|=%3d  b0=%d  b1=%d" % (e,len(Ve),len(Ee),comps,b1))
print("constant-sheaf H0 dim = %d, H1 dim = %d" % (h0,h1))
json.dump({n:sorted(P[n]) for n in names}, open(str(_REPO / "tmp/sheaf_corpus.json"),'w'), indent=0)
