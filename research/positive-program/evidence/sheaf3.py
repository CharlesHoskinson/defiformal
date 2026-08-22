import json, glob, itertools
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

P={}
for f in sorted(glob.glob(str(_REPO / "expansion/*/specs/*.json"))):
    d=json.load(open(f)); P[d['app']]=set(d.get('construction',[]))
names=sorted(P)
# scope = the set of settlement horizons at which the mechanism's state is
# mutable.  0=intra-transaction 1=intra-block 2=intra-epoch 3=cross-domain
# challenge window 4=governance timelock.  A prohibition fires only if all its
# arms are simultaneously live at some common horizon.
H=range(5)
LIVE={'Fl':{0},                       # atomic by definition: open+close in one tx
      'Cp':set(H),'Cl':set(H),'St':set(H),'Wg':set(H),'Pm':set(H),
      'Pl':set(H),'Cd':set(H),'Im':set(H),'Uc':set(H),
      'Xf':{3,4},'Xm':{3,4},'Rl':{3,4},'Of':{3,4},   # cannot complete in one tx
      'Ep':{2,3,4},'Wq':{2,3,4},'Tg':{4},'Up':{4},'Gp':{4}}
def live(e): return LIVE.get(e,set(H))
def fires(X,arms):
    """arms: list of alternatives-sets; fires iff some choice is co-live."""
    picks=[]
    for alt in arms:
        cand=[e for e in alt if e in X]
        if not cand: return False,None
        picks.append(cand)
    for combo in itertools.product(*picks):
        common=set(H)
        for e in combo: common&=live(e)
        if common: return True,(combo,sorted(common))
    return False,None
X21=[['Fl'],['Xf','Rl','Of']]
X2 =[['Fl'],['Cp','Cl'],['Pl','Cd']]
def flat(X,arms): return all(any(e in X for e in alt) for alt in arms)
def bad_flat(X): return flat(X,X21) or flat(X,X2)
def bad_sc(X):   return fires(X,X21)[0] or fires(X,X2)[0]

seeds=[n for n in names if not bad_flat(P[n])]
pairs=list(itertools.combinations(seeds,2))
ff=[p for p in pairs if bad_flat(P[p[0]]|P[p[1]])]
f21=[p for p in pairs if flat(P[p[0]]|P[p[1]],X21)]
f2 =[p for p in pairs if flat(P[p[0]]|P[p[1]],X2)]
fs=[p for p in pairs if bad_sc(P[p[0]]|P[p[1]])]
print("seeds %d pairs %d"%(len(seeds),len(pairs)))
print("FLAT   failures %3d (X21 %d, X2 %d)  compat density %.4f"%(len(ff),len(f21),len(f2),1-len(ff)/len(pairs)))
print("SCOPED failures %3d                   compat density %.4f"%(len(fs),1-len(fs)/len(pairs)))
print("dissolved %d/%d = %.1f%%"%(len(ff)-len(fs),len(ff),100*(len(ff)-len(fs))/len(ff)))
print("X21 under scope semantics: live(Fl) & live(Xf) =",live('Fl')&live('Xf'),"-> never fires")
print("X2  under scope semantics: live(Fl)&live(Cp)&live(Pl) =",live('Fl')&live('Cp')&live('Pl'),"-> fires at horizon 0")

V=sorted({x for p in fs for x in p}); deg=defaultdict(int)
for a,b in fs: deg[a]+=1; deg[b]+=1
print("\nRESIDUAL obstruction: %d contexts, %d 1-simplices"%(len(V),len(fs)))
for n,c in sorted(deg.items(),key=lambda x:-x[1]):
    print("   %-32s deg %2d  arms %s"%(n,c,sorted(P[n]&{'Fl','Cp','Cl','Pl','Cd'})))
cov=[n for n in V if 'Fl' in P[n]]
print("residual vertex cover (Fl carriers): %d -> %s"%(len(cov),cov))
print("every residual edge has an Fl endpoint:",all(a in cov or b in cov for a,b in fs))
S={frozenset(p) for p in fs}
free=[n for n in seeds if n not in cov]
best=0
for r in range(len(cov),-1,-1):
    for T in itertools.combinations(cov,r):
        if all(frozenset((x,y)) not in S for x,y in itertools.combinations(T,2)) and \
           all(frozenset((x,y)) not in S for x in T for y in free):
            best=max(best,len(free)+r)
    if best: break
print("omega(G_scoped) = %d  (vs omega(G_flat) below)"%best)
covf=[n for n in seeds if 'Fl' in P[n]]; Sf={frozenset(p) for p in ff}
freef=[n for n in seeds if n not in covf]; bf=0
for r in range(len(covf),-1,-1):
    for T in itertools.combinations(covf,r):
        if all(frozenset((x,y)) not in Sf for x,y in itertools.combinations(T,2)) and \
           all(frozenset((x,y)) not in Sf for x in T for y in freef): bf=max(bf,len(freef)+r)
    if bf: break
print("omega(G_flat)   = %d   certified by 2^%d = %d checks"%(bf,len(covf),2**len(covf)))

# residual cellular sheaf: constant sheaf on the residual 1-complex
par={v:v for v in V}
def find(x):
    while par[x]!=x: par[x]=par[par[x]]; x=par[x]
    return x
for a,b in fs:
    ra,rb=find(a),find(b)
    if ra!=rb: par[ra]=rb
comps=len({find(v) for v in V}) if V else 0
b1=len(fs)-len(V)+comps if V else 0
print("\nresidual complex: b0=%d b1=%d  (H^1 rank of the constant sheaf = %d)"%(comps,b1,b1))
print("is the residual complex a union of %d stars? %s"%(len(cov),
      all(a in cov or b in cov for a,b in fs)))
# cone test on the largest component
print("cone apexes (vertices adjacent to all others in their component):",
      [v for v in V if deg[v]==len(V)-1])
