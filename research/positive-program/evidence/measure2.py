import re, json, glob, itertools, random
import networkx as nx
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


raw = open(str(_REPO / "paper/formal-data.tex")).read()
MID = "$" + chr(92) + "mid$"
ELEM = {m.group(1): (m.group(3), int(m.group(4)))
        for m in re.finditer(r"^\$([A-Za-z]{2})\$ & (.*?) & (G\d\d) & ([0-4])\\\\", raw, re.M)}
sec = raw.split("Requirements: the recorded rows")[1].split("Warrants")[0]
R = []
for line in sec.splitlines():
    m = re.match(r"\$(L\d+)\$ & (.*?) & (.*?)\\\\\s*$", line.strip())
    if not m: continue
    rid, subj, terms = m.groups()
    S = [s.strip() for s in subj.split(",") if s.strip()]
    T = [[a.strip() for a in t.split(MID) if a.strip()]
         for t in re.findall(r"\((.*?)\)", terms)]
    T = [t for t in T if t]
    R.append((rid, S, T))

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

def summ(name, xs):
    xs = sorted(xs)
    print("%-34s n=%d min=%d p50=%d p90=%d p95=%d max=%d mean=%.2f"
          % (name, len(xs), xs[0], xs[len(xs)//2], xs[int(.9*len(xs))],
             xs[int(.95*len(xs))], xs[-1], sum(xs)/len(xs)))

# ---- cross-horizon edge fraction of G0
for tag, clq in (("star", False), ("clique", True)):
    E = set()
    for rid, S, T in R:
        for u, v in itertools.combinations(sorted(set(S)), 2): E.add((u, v))
        for t in T:
            if clq:
                for u, v in itertools.combinations(sorted(set(S) | set(t)), 2): E.add((u, v))
            else:
                for s in S:
                    for a in t:
                        if s != a: E.add(tuple(sorted((s, a))))
    within = sum(1 for u, v in E if ELEM[u][1] == ELEM[v][1])
    print("G0[%s]: |E|=%d within-horizon=%d (%.1f%%) cross-horizon=%d (%.1f%%)"
          % (tag, len(E), within, 100*within/len(E), len(E)-within, 100*(len(E)-within)/len(E)))
    if not clq: G0 = nx.Graph(); G0.add_edges_from(E)
    # adjacent-horizon-only survival (interval l of width 2)
    adj = sum(1 for u, v in E if abs(ELEM[u][1]-ELEM[v][1]) <= 1)
    print("        survive under width-2 interval l: %d (%.1f%%)" % (adj, 100*adj/len(E)))

# ---- applications
apps = []
for f in glob.glob(str(_REPO / "expansion/*/specs/*.json")):
    d = json.load(open(f))
    con = sorted(set(c for c in d.get("construction", []) if c in ELEM))
    if con: apps.append((d.get("app", f), con))

L = []
for name, con in apps:
    L.append(max(sum(1 for e in con if ELEM[e][1] == h) for h in range(5)))
print("\nL = max_h n_h over %d apps:" % len(apps))
summ("  L", L)
print("\nArity budget: pw_port <= abar*L - 1 <= 12  <=>  abar*L <= 13")
for abar in (2.0, 2.5, 3.0, 3.5, 4.0):
    ok = sum(1 for x in L if abar*x <= 13)
    print("  abar=%.1f : passes on %d/%d apps (%.0f%%);  worst-case width = %.0f"
          % (abar, ok, len(L), 100*ok/len(L), abar*max(L)-1))

# ---- direct port-graph blow-up simulation
COLS = ["A","K","Ks","P","V","U","Q","M","I"]
# skew: A,K,Ks dominant (linear value flow); P,V,M,I thinner
WT = [0.22,0.18,0.14,0.11,0.08,0.07,0.08,0.07,0.05]
random.seed(11)

def sim(abar, trials=120, interval_l=1):
    out = []
    for _ in range(trials):
        # arity per element: split abar into in/out, min 1 each
        ar = {}
        for e in ELEM:
            a = max(2, min(8, int(round(random.gauss(abar, 0.8)))))
            nin = max(1, a//2); nout = max(1, a-nin)
            ar[e] = ([random.choices(COLS, WT)[0] for _ in range(nin)],
                     [random.choices(COLS, WT)[0] for _ in range(nout)])
        lv = {}
        for e in ELEM:
            s = ELEM[e][1]
            lv[e] = set(range(max(0, s-interval_l+1), min(5, s+1)))
        name, con = random.choice(apps)
        G = nx.Graph()
        ports = []
        for e in con:
            ps = [(e, "i", i, c) for i, c in enumerate(ar[e][0])] + \
                 [(e, "o", i, c) for i, c in enumerate(ar[e][1])]
            ports += ps
            for u, v in itertools.combinations(ps, 2): G.add_edge(u, v)   # element clique
        for p in ports:
            for q in ports:
                if p[0] == q[0] or p[1] == q[1]: continue
                if p[3] != q[3]: continue
                if not (lv[p[0]] & lv[q[0]]): continue
                G.add_edge(p, q)                                          # admissible wire
        out.append(minfill(G) if G.number_of_nodes() else 0)
    return out

print("\nPort-graph G1 min-fill width, per application (120 draws each):")
for abar in (2.0, 2.5, 3.0, 3.5, 4.0):
    for iw, tag in ((1, "point l"), (2, "width-2 interval l"), (5, "no l / all-live")):
        summ("  abar=%.1f, %-18s" % (abar, tag), sim(abar, 120, iw))
