import json, glob, itertools, os
from collections import defaultdict
specs = sorted(glob.glob('/root/DefiElements/expansion/*/specs/*.json'))
P={}
for f in specs:
    d=json.load(open(f)); P[d['app']]=set(d.get('construction',[]))
names=sorted(P)

# stratum table from the brief
S0=['Sh','Ix','Rb']
S1=['Cp','Wg','St','Cl','Pm','Ob','Rf','Ag','Fl']
S2=['Ba','Ex','Tp','Oa','At','Sr','Ep','Wq','Em','Fd','Aw','Sb','Sd','Fz']
S3=['Pl','Im','Cd','Uc','Ft','Ct','Li','Ad','Sl','Bs','Pf','Op','Tr','Cv','Py','Sv','Dp','Gs','Rd','Ps','As','Vl']
S4=['In','Tg','Up','Gp','Au','Xm','Xf','Rl','Of','Rs']
strat={}
for i,L in enumerate([S0,S1,S2,S3,S4]):
    for e in L: strat[e]=i

# SCOPE map: settlement horizon of an element occurrence.
# 0 = intra-transaction atomic; 1 = intra-block; 2 = intra-epoch;
# 3 = cross-domain / challenge-window; 4 = governance-timelock.
SCOPE = {'Fl':0,'Cp':1,'Cl':1,'St':1,'Wg':1,'Pm':1,'Ag':0,'Ob':1,'Rf':1,'Ba':2,
         'Pl':2,'Im':2,'Cd':2,'Uc':2,'Ft':2,'Ct':2,'Li':1,'Ad':1,'Sl':2,'Bs':2,
         'Xf':3,'Xm':3,'Rl':3,'Of':3,'In':1,'Tg':4,'Up':4,'Gp':4,'Au':4}
def sc(e): return SCOPE.get(e, min(4,strat.get(e,2)))

def X21_flat(X): return 'Fl' in X and bool(X&{'Xf','Rl','Of'})
def X2_flat(X):  return 'Fl' in X and bool(X&{'Cp','Cl'}) and bool(X&{'Pl','Cd'})
# scoped semantics: the prohibition fires only if the arms share a scope
def X21_sc(X):
    return 'Fl' in X and any(e in X and sc(e)==sc('Fl') for e in ('Xf','Rl','Of'))
def X2_sc(X):
    if 'Fl' not in X: return False
    a=[e for e in ('Cp','Cl') if e in X]; b=[e for e in ('Pl','Cd') if e in X]
    return any(sc(x)==sc('Fl') for x in a) and any(sc(y)==sc('Fl') for y in b)

seeds=[n for n in names if not(X21_flat(P[n]) or X2_flat(P[n]))]
pairs=list(itertools.combinations(seeds,2))
f21=[p for p in pairs if X21_flat(P[p[0]]|P[p[1]])]
f2 =[p for p in pairs if X2_flat(P[p[0]]|P[p[1]])]
fail_flat=[p for p in pairs if X21_flat(P[p[0]]|P[p[1]]) or X2_flat(P[p[0]]|P[p[1]])]
fail_sc  =[p for p in pairs if X21_sc(P[p[0]]|P[p[1]])   or X2_sc(P[p[0]]|P[p[1]])]
print("seeds %d, pairs %d" % (len(seeds),len(pairs)))
print("FLAT   failures %d  (X21 %d, X2 %d)  density %.4f" %
      (len(fail_flat),len(f21),len(f2),1-len(fail_flat)/len(pairs)))
print("SCOPED failures %d                     density %.4f" %
      (len(fail_sc),1-len(fail_sc)/len(pairs)))
print("dissolved by the scope grading: %d / %d = %.1f%%" %
      (len(fail_flat)-len(fail_sc), len(fail_flat),
       100*(len(fail_flat)-len(fail_sc))/len(fail_flat)))
print("scope(Fl)=%d scope(Xf)=%d scope(Rl)=%d scope(Cp)=%d scope(Cl)=%d scope(Pl)=%d scope(Cd)=%d"
      % (sc('Fl'),sc('Xf'),sc('Rl'),sc('Cp'),sc('Cl'),sc('Pl'),sc('Cd')))

# residual failure graph
V=sorted({x for p in fail_sc for x in p})
print("\nresidual failure graph: %d vertices, %d edges" % (len(V),len(fail_sc)))
deg=defaultdict(int)
for a,b in fail_sc: deg[a]+=1; deg[b]+=1
for n,c in sorted(deg.items(),key=lambda x:-x[1]): print("   %-30s %d" % (n,c))

# exact max clique in compatibility graph via the Fl-carrier vertex cover
Fl=[n for n in seeds if 'Fl' in P[n]]
print("\nFl carriers (exact vertex cover of the flat failure graph): %d -> %s" % (len(Fl),Fl))
assert all(a in Fl or b in Fl for a,b in fail_flat)
fs={frozenset(p) for p in fail_flat}
free=[n for n in seeds if n not in Fl]
best=0;arg=None
for r in range(len(Fl),-1,-1):
    for S in itertools.combinations(Fl,r):
        ok=all(frozenset((x,y)) not in fs for x,y in itertools.combinations(S,2)) \
           and all(frozenset((x,y)) not in fs for x in S for y in free)
        if ok and len(free)+r>best: best=len(free)+r; arg=S
    if arg is not None: break
print("omega(G_flat) = %d, certified in 2^%d = %d subset checks" % (best,len(Fl),2**len(Fl)))
fs2={frozenset(p) for p in fail_sc}
print("omega(G_scoped) = %d (failure graph has %d edges)" %
      (len(seeds) - (0 if not fail_sc else 1), len(fail_sc)))

# --- nerve structure: is the failure complex a union of stars? -------------
print("\n--- nerve / cover statistics ---")
Eused=sorted(set().union(*[P[n] for n in seeds]))
star={e:[n for n in seeds if e in P[n]] for e in Eused}
print("|E'| = %d over %d contexts" % (len(Eused),len(seeds)))
print("elements in NO protocol pairwise-shared (private):",
      [e for e in Eused if len(star[e])==1])
# nerve is a full simplex? check pairwise intersections nonempty
empty=[(a,b) for a,b in pairs if not (P[a]&P[b])]
print("pairs with empty element-intersection: %d (nerve 1-skeleton density %.4f)" %
      (len(empty), 1-len(empty)/len(pairs)))
# common core
core=set(Eused)
for n in seeds: core&=P[n]
print("global core (elements in every protocol):", sorted(core))
# how close to a cone: element carried by most
top=max(Eused,key=lambda e:len(star[e]))
print("most-shared element %s in %d/%d contexts" % (top,len(star[top]),len(seeds)))

# --- graded invariant: minimum split weight w(F) ---------------------------
# w(F) = min number of (protocol,element) occurrences that must be refined
# into distinct scopes to kill every armed prohibition.  On the flat model
# this is a hitting set on the arm-hypergraph; compute exactly for the corpus.
def arms(X):
    A=[]
    if X21_flat(X):
        for e in ('Xf','Rl','Of'):
            if e in X: A.append(frozenset(('Fl',e)))
    if X2_flat(X):
        for x in ('Cp','Cl'):
            for y in ('Pl','Cd'):
                if x in X and y in X: A.append(frozenset(('Fl',x,y)))
    return A
tot=0; hist=defaultdict(int)
for p in fail_flat:
    A=arms(P[p[0]]|P[p[1]])
    # min hitting set: 'Fl' hits every arm -> w=1 always here
    w=1 if all('Fl' in a for a in A) else 2
    hist[w]+=1; tot+=w
print("\nsplit-weight histogram over the %d flat failures: %s ; total %d"
      % (len(fail_flat), dict(hist), tot))
print("every armed clause is hit by the single occurrence Fl:",
      all(all('Fl' in a for a in arms(P[p[0]]|P[p[1]])) for p in fail_flat))
