import re, json, glob, itertools, random
import networkx as nx
raw = open("/root/DefiElements/paper/formal-data.tex").read()
ELEM = {m.group(1): (m.group(3), int(m.group(4)))
        for m in re.finditer(r"^\$([A-Za-z]{2})\$ & (.*?) & (G\d\d) & ([0-4])\\\\", raw, re.M)}
apps = []
for f in glob.glob("/root/DefiElements/expansion/*/specs/*.json"):
    d = json.load(open(f))
    con = sorted(set(c for c in d.get("construction", []) if c in ELEM))
    if con: apps.append((d.get("app", f), con))

def minfill(G):
    H = G.copy(); w = 0
    while H.number_of_nodes():
        best, bf = None, None
        for v in H:
            nb = list(H.neighbors(v))
            f = sum(1 for a, b in itertools.combinations(nb, 2) if not H.has_edge(a, b))
            if bf is None or f < bf: bf, best = f, v
        nb = list(H.neighbors(best)); w = max(w, len(nb))
        for a, b in itertools.combinations(nb, 2): H.add_edge(a, b)
        H.remove_node(best)
    return w

COLS = ["A","K","Ks","P","V","U","Q","M","I"]
WT   = [0.22,0.18,0.14,0.11,0.08,0.07,0.08,0.07,0.05]

def build(con, ar, lv):
    G = nx.Graph(); ports = []
    for e in con:
        ps = [(e,"i",i,c) for i,c in enumerate(ar[e][0])] + [(e,"o",i,c) for i,c in enumerate(ar[e][1])]
        ports += ps
        for u,v in itertools.combinations(ps,2): G.add_edge(u,v)
    for p in ports:
        for q in ports:
            if p[0]==q[0] or p[1]==q[1] or p[3]!=q[3]: continue
            if not (lv[p[0]] & lv[q[0]]): continue
            G.add_edge(p,q)
    return G

def mkar(abar, Acap, rng):
    ar = {}
    for e in ELEM:
        a = max(2, min(Acap, int(round(rng.gauss(abar, 1.1)))))
        nin = max(1,a//2); nout = max(1,a-nin)
        ar[e] = ([rng.choices(COLS,WT)[0] for _ in range(nin)],
                 [rng.choices(COLS,WT)[0] for _ in range(nout)])
    return ar

def mklv(iw):
    return {e: set(range(max(0,ELEM[e][1]-iw+1), min(5,ELEM[e][1]+1))) for e in ELEM}

def summ(tag, xs):
    xs=sorted(xs)
    print("%-38s p50=%d p90=%d p95=%d max=%d" % (tag, xs[len(xs)//2], xs[int(.9*len(xs))], xs[int(.95*len(xs))], xs[-1]))

rng = random.Random(23)
print("=== max-arity sensitivity (abar=3.0, width-2 interval l), 150 draws ===")
for Acap in (4,6,8,10,12):
    out=[]
    for _ in range(150):
        ar=mkar(3.0,Acap,rng); lv=mklv(2); _,con=rng.choice(apps)
        out.append(minfill(build(con,ar,lv)))
    summ("  A_max=%d" % Acap, out)

print("\n=== max-arity sensitivity (abar=3.0, point l) ===")
for Acap in (4,6,8,10,12):
    out=[]
    for _ in range(150):
        ar=mkar(3.0,Acap,rng); lv=mklv(1); _,con=rng.choice(apps)
        out.append(minfill(build(con,ar,lv)))
    summ("  A_max=%d" % Acap, out)

print("\n=== degenerate table check: all elements same 1-colour row (A)->(A) ===")
ar0 = {e: (["A"],["A"]) for e in ELEM}
out=[minfill(build(con,ar0,mklv(5))) for _,con in apps]
summ("  constant ar, no l", out)
print("\n=== paranoid table: every element a unique colour pair (max selectivity) ===")
rng2=random.Random(5)
arP={}
for i,e in enumerate(ELEM):
    c1=COLS[i%9]; c2=COLS[(i*4+3)%9]
    arP[e]=([c1,c1],[c2,c2])
out=[minfill(build(con,arP,mklv(5))) for _,con in apps]
summ("  paranoid ar, no l", out)

print("\n=== global 58-element instance (abar=3.0) ===")
allc = sorted(ELEM)
for iw,tag in ((1,"point l"),(2,"interval-2 l"),(5,"no l")):
    ws=[]
    for _ in range(6):
        ar=mkar(3.0,8,rng)
        ws.append(minfill(build(allc,ar,mklv(iw))))
    print("  %-14s widths=%s" % (tag, ws))
