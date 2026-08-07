import re, json, glob, itertools, random, statistics as st
import networkx as nx

raw = open("/root/DefiElements/paper/formal-data.tex").read()
MID = "$" + chr(92) + "mid$"

# --- element table: symbol -> (group, stratum)
ELEM = {}
for m in re.finditer(r"^\$([A-Za-z]{2})\$ & (.*?) & (G\d\d) & ([0-4])\\\\", raw, re.M):
    ELEM[m.group(1)] = (m.group(3), int(m.group(4)))
print("elements:", len(ELEM))
strat = {}
for e, (g, s) in ELEM.items():
    strat.setdefault(s, []).append(e)
print("stratum sizes:", {k: len(v) for k, v in sorted(strat.items())})

# --- requirement rows
sec = raw.split("Requirements: the recorded rows")[1].split("Warrants")[0]
R = []
for line in sec.splitlines():
    m = re.match(r"\$(L\d+)\$ & (.*?) & (.*?)\\\\\s*$", line.strip())
    if not m:
        continue
    rid, subj, terms = m.groups()
    S = [s.strip() for s in subj.split(",") if s.strip()]
    T = []
    for t in re.findall(r"\((.*?)\)", terms):
        alts = [a.strip() for a in t.split(MID) if a.strip()]
        if alts:
            T.append(alts)
    nempty = terms.count("()")
    R.append((rid, S, T, nempty))
print("rows:", len(R), "fully-empty rows:", sum(1 for r in R if not r[2]))
print("total empty [ext]() slots:", sum(r[3] for r in R))


def build(rows, clique_disjunctions=False):
    E = set()
    for rid, S, T, _ in rows:
        for u, v in itertools.combinations(sorted(set(S)), 2):
            E.add((u, v))
        for t in T:
            if clique_disjunctions:
                for u, v in itertools.combinations(sorted(set(S) | set(t)), 2):
                    E.add((u, v))
            else:
                for s in S:
                    for a in t:
                        if s != a:
                            E.add(tuple(sorted((s, a))))
    G = nx.Graph()
    G.add_edges_from(E)
    return G


def minfill(G):
    H = G.copy()
    w = 0
    while H.number_of_nodes():
        best, bf = None, None
        for v in H:
            nb = list(H.neighbors(v))
            f = sum(1 for a, b in itertools.combinations(nb, 2) if not H.has_edge(a, b))
            if bf is None or f < bf:
                bf, best = f, v
        nb = list(H.neighbors(best))
        w = max(w, len(nb))
        for a, b in itertools.combinations(nb, 2):
            H.add_edge(a, b)
        H.remove_node(best)
    return w


G0 = build(R)
print("\nG0 (star-encoded disjunctions): V=%d E=%d omega=%d minfill=%d"
      % (G0.number_of_nodes(), G0.number_of_edges(),
         max(len(c) for c in nx.find_cliques(G0)), minfill(G0)))
G0c = build(R, True)
print("G0c (clique-encoded disjunctions): V=%d E=%d omega=%d minfill=%d"
      % (G0c.number_of_nodes(), G0c.number_of_edges(),
         max(len(c) for c in nx.find_cliques(G0c)), minfill(G0c)))

# --- PO-SYN-7: fill the empty [ext]() slots with random singleton terms, remeasure
syms = list(ELEM)
random.seed(7)
res_star, res_clq = [], []
for trial in range(400):
    rows2 = []
    for rid, S, T, ne in R:
        T2 = list(T) + [[random.choice(syms)] for _ in range(ne)]
        S2 = S if S else [random.choice(syms)]
        rows2.append((rid, S2, T2, 0))
    res_star.append(minfill(build(rows2)))
    res_clq.append(minfill(build(rows2, True)))


def summ(name, xs):
    xs = sorted(xs)
    print("%-28s min=%d p50=%d p90=%d p95=%d max=%d mean=%.2f"
          % (name, xs[0], xs[len(xs) // 2], xs[int(.9 * len(xs))],
             xs[int(.95 * len(xs))], xs[-1], sum(xs) / len(xs)))


print("\nPO-SYN-7 simulated fill of 41 empty slots (400 trials):")
summ("  width, star-encoded", res_star)
summ("  width, clique-encoded", res_clq)

# --- per-stratum induced subgraph widths of G0
print("\nStratum-induced subgraphs of G0 (single-horizon l):")
for s in sorted(strat):
    sub = G0.subgraph([v for v in G0 if ELEM.get(v, (None, -1))[1] == s])
    sub = nx.Graph(sub)
    if sub.number_of_nodes() == 0:
        print("  h%d: empty" % s); continue
    print("  h%d: V=%d E=%d omega=%d minfill=%d"
          % (s, sub.number_of_nodes(), sub.number_of_edges(),
             max((len(c) for c in nx.find_cliques(sub)), default=1), minfill(sub)))

# --- per-application horizon load
apps = []
for f in glob.glob("/root/DefiElements/expansion/*/specs/*.json"):
    d = json.load(open(f))
    con = [c for c in d.get("construction", []) if c in ELEM]
    if con:
        apps.append((d.get("app", f), con))
print("\napplications parsed:", len(apps))
sizes = [len(c) for _, c in apps]
summ("  construction size", sizes)

maxload, spread = [], []
for name, con in apps:
    load = {h: sum(1 for e in con if ELEM[e][1] == h) for h in range(5)}
    maxload.append(max(load.values()))
    spread.append(sum(1 for h in load if load[h] > 0))
summ("  max_h n_h (point l)", maxload)
summ("  #occupied horizons", spread)
print("  => pathwidth bound pw <= max_h n_h - 1 ; p95 =", sorted(maxload)[int(.95 * len(maxload))] - 1)

# per-application G0-induced width vs stratum-blocked width
w_full, w_block = [], []
for name, con in apps:
    sub = nx.Graph(G0.subgraph(con))
    if sub.number_of_nodes() == 0:
        continue
    w_full.append(minfill(sub))
    wb = 0
    for h in range(5):
        s2 = nx.Graph(sub.subgraph([v for v in sub if ELEM[v][1] == h]))
        if s2.number_of_nodes():
            wb = max(wb, minfill(s2))
    w_block.append(wb)
summ("  per-app width, no l", w_full)
summ("  per-app width, point l", w_block)

# colour selectivity reference curve
print("\nselectivity sigma = 1 - sum_c p_c q_c for uniform over k colours:")
for k in (1, 2, 3, 5, 9):
    print("  k=%d -> sigma=%.3f" % (k, 1 - 1.0 / k))
