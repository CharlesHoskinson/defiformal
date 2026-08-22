import json, glob, itertools
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
def gyo(edges):
    """GYO reduction: alpha(Vorob'ev)-acyclicity test. Returns (acyclic, residue)."""
    E=[set(e) for e in edges]
    changed=True
    while changed:
        changed=False
        # remove ears: edges contained in another edge
        for i in range(len(E)-1,-1,-1):
            if any(i!=j and E[i]<=E[j] for j in range(len(E))):
                E.pop(i); changed=True; break
        if changed: continue
        # remove vertices appearing in exactly one edge
        cnt={}
        for e in E:
            for v in e: cnt[v]=cnt.get(v,0)+1
        for i,e in enumerate(E):
            drop={v for v in e if cnt[v]==1}
            if drop:
                E[i]=e-drop; changed=True; break
        if changed: continue
        E=[e for e in E if e]
    return (len(E)==0), E
edges=[P[n] for n in sorted(P)]
ac,res=gyo(edges)
print("full corpus cover (%d edges over %d vertices): alpha-acyclic = %s"%(len(edges),len(set().union(*edges)),ac))
print("GYO residue: %d edges, %d vertices"%(len(res), len(set().union(*res)) if res else 0))
if res:
    core=set().union(*res)
    print("residue vertex set (the cyclic core):", sorted(core))
# now: restrict each protocol to the prohibition-relevant sub-vocabulary
Trig={'Fl','Xf','Rl','Of','Cp','Cl','Pl','Cd'}
sub=[P[n]&Trig for n in sorted(P) if P[n]&Trig]
sub=[s for s in sub]
ac2,res2=gyo(sub)
print("\nrestricted to the 8 prohibition-relevant elements: alpha-acyclic = %s"%ac2)
print("  residue:",[sorted(r) for r in res2])
# and after refining Fl by scope (Fl0 atomic) -- Fl no longer co-occurs with Xf/Rl/Of
sub3=[]
for n in sorted(P):
    s=P[n]&Trig
    if not s: continue
    if 'Fl' in s: s=(s-{'Fl','Xf','Rl','Of'})|{'Fl@0'}
    sub3.append(s)
ac3,res3=gyo(sub3)
print("\nafter scope refinement of Fl: alpha-acyclic = %s ; residue %s"%(ac3,[sorted(r) for r in res3]))
# distinct trigger-profiles (contexts of the empirical model)
from collections import Counter
c=Counter(frozenset(P[n]&Trig) for n in P)
print("\ndistinct trigger contexts: %d over %d protocols"%(len(c),len(P)))
for k,v in sorted(c.items(),key=lambda x:-x[1])[:12]: print("   %-28s x%d"%(sorted(k),v))
print("\nCSP size: 8 variables x 5 scopes = 5^8 = %d joint assignments (brute force)"%(5**8))
