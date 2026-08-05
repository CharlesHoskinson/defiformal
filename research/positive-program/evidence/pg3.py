import re, itertools, networkx as nx
raw = open("/root/DefiElements/paper/formal-data.tex").read()
sec = raw.split("Requirements: the recorded rows")[1].split("Warrants")[0]
MID = "$" + chr(92) + "mid$"
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
    R.append((rid, S, T))

def clq(sc, E):
    for u, v in itertools.combinations(sorted(sc), 2):
        E.add((u, v))

def minfill(G):
    H = G.copy(); w = 0
    while H.number_of_nodes():
        best = None; bf = None
        for v in H:
            nb = list(H.neighbors(v))
            f = sum(1 for a, b in itertools.combinations(nb, 2) if not H.has_edge(a, b))
            if bf is None or f < bf:
                bf = f; best = v
        nb = list(H.neighbors(best)); w = max(w, len(nb))
        for a, b in itertools.combinations(nb, 2):
            H.add_edge(a, b)
        H.remove_node(best)
    return w

def stats(name, E):
    G = nx.Graph(); G.add_edges_from(E)
    nn = [v for v in G if G.degree(v) > 0]
    mc = max(len(c) for c in nx.find_cliques(G))
    print(f"{name}: V={len(nn)} E={G.number_of_edges()} maxclique={mc} minfill_w={minfill(G)}")
    return G

# H: subject clique per row + subject-to-alternative edges (disjunction NOT cliqued)
E = set()
for rid, S, T in R:
    clq(set(S), E)
    for t in T:
        for s in S:
            for a in t:
                E.add(tuple(sorted((s, a))))
E = {e for e in E if e[0] != e[1]}
stats("H subjclique + subj-alt", E)

# per-row scope sizes for the hypergraph
print("row scopes:", [(rid, len(set(S) | set().union(*[set(t) for t in T]) if T else set(S))) for rid, S, T in R if T])
