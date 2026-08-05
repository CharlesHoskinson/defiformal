"""Every figure in expansion/graphify-out/GRAPHS.md, re-derived.

The document makes two claims that matter and are easy to get backwards: that
the merged graph has no cross-lane links, and that the domain graph joins every
category pair. Both are checked here against the graphs themselves.
"""
import io, json, os, re, sys
from collections import Counter, defaultdict

ROOT = "/root/defiformal/expansion"
OUT = "%s/graphify-out" % ROOT
LANES = ["01-spot-exchange", "02-lending", "03-cdp-stablecoins", "04-liquid-staking",
         "05-perpetuals", "06-yield-vaults", "07-bridges", "08-intents", "09-rwa",
         "10-options", "11-fiat-stablecoins", "12-prediction"]

fail = []


def check(label, got, want):
    ok = got == want
    if not ok:
        fail.append("%s: document says %r, graphs say %r" % (label, want, got))
    print("  %s %-52s %s" % ("ok  " if ok else "FAIL", label, got))


def load(p):
    return json.load(io.open(p, encoding="utf-8"))


doc = io.open("%s/GRAPHS.md" % OUT, encoding="utf-8").read()


def stated(pat):
    m = re.search(pat, doc)
    assert m, "GRAPHS.md no longer states: %s" % pat
    return int(m.group(1).replace(",", ""))


# ---- the twelve lanes exist -------------------------------------------------
print("lane graphs")
have, sn, se = 0, 0, 0
thin = []
for s in LANES:
    p = "%s/%s/graphify-out/graph.json" % (ROOT, s)
    if not os.path.exists(p):
        fail.append("%s: no graph" % s)
        continue
    g = load(p)
    n, e = len(g["nodes"]), len(g["links"])
    have += 1
    sn += n
    se += e
    deg = set()
    for l in g["links"]:
        deg.add(str(l["source"]))
        deg.add(str(l["target"]))
    iso = n - len(deg)
    if iso:
        thin.append((s, iso))
    print("    %-20s nodes=%-4d links=%-4d isolated=%d" % (s, n, e, iso))
check("lanes with a graph", have, 12)

# ---- merged: a union, and nothing more -------------------------------------
print("\nmerged-graph.json")
m = load("%s/merged-graph.json" % OUT)
check("nodes", len(m["nodes"]), stated(r"`merged-graph\.json` — ([\d,]+) nodes"))
check("links", len(m["links"]), stated(r"`merged-graph\.json` — [\d,]+ nodes, ([\d,]+) links"))
check("nodes equal the sum of the lanes", len(m["nodes"]), sn)
check("links equal the sum of the lanes", len(m["links"]), se)


def lane(nid):
    s = str(nid)
    return s.split("::")[0] if "::" in s else None


cross = sum(1 for l in m["links"]
            if lane(l["source"]) and lane(l["target"])
            and lane(l["source"]) != lane(l["target"]))
check("cross-lane links", cross, 0)

adj = defaultdict(set)
for l in m["links"]:
    adj[str(l["source"])].add(str(l["target"]))
    adj[str(l["target"])].add(str(l["source"]))
seen, comps = set(), []
for n in (str(x["id"]) for x in m["nodes"]):
    if n in seen:
        continue
    st, cur = [n], 0
    seen.add(n)
    while st:
        x = st.pop()
        cur += 1
        for y in adj[x]:
            if y not in seen:
                seen.add(y)
                st.append(y)
    comps.append(cur)
check("connected components", len(comps), stated(r"its (\d+) connected components"))
check("largest component", max(comps), stated(r"the largest has (\d+) nodes"))
check("isolated nodes", sum(1 for c in comps if c == 1),
      stated(r"(\d+) isolated nodes across \d+"))

# ---- domain: the real cross-category graph ---------------------------------
print("\ndomain-graph.json")
d = load("%s/domain-graph.json" % OUT)
N = {str(x["id"]): x for x in d["nodes"]}
check("nodes", len(d["nodes"]), stated(r"`domain-graph\.json` — ([\d,]+) nodes"))
check("links", len(d["links"]), stated(r"`domain-graph\.json` — [\d,]+ nodes, ([\d,]+) links"))

kinds = Counter(x.get("kind") for x in d["nodes"])
for k, want_pat in [("obligation", r"\| `obligation` \| (\d+) \|"),
                    ("protocol", r"\| `protocol` \| (\d+) \|"),
                    ("element", r"\| `element` \| (\d+) \|"),
                    ("category", r"\| `category` \| (\d+) \|")]:
    check("nodes of kind %s" % k, kinds[k], stated(want_pat))

rels = Counter(l.get("relation") for l in d["links"])
for r, want_pat in [("owes", r"\| `owes` \| (\d+) \|"),
                    ("dischargedBy", r"\| `dischargedBy` \| (\d+) \|"),
                    ("carries", r"\| `carries` \| (\d+) \|"),
                    ("has", r"\| `has` \| (\d+) \|")]:
    check("links of relation %s" % r, rels[r], stated(want_pat))

cat = {i: x.get("category") for i, x in N.items() if x.get("kind") == "protocol"}
check("protocols carrying a category", sum(1 for v in cat.values() if v), 60)

el_cats = defaultdict(set)
for l in d["links"]:
    if l.get("relation") == "carries" and cat.get(str(l["source"])):
        el_cats[str(l["target"])].add(cat[str(l["source"])])
check("elements carried in >1 category",
      sum(1 for v in el_cats.values() if len(v) > 1),
      stated(r"\*\*Forty of the 53|Forty\b")) if False else None
check("elements carried in >1 category", sum(1 for v in el_cats.values() if len(v) > 1), 40)
check("elements carried at all", len(el_cats), 53)

pairs = set()
for v in el_cats.values():
    vs = sorted(v)
    for i in range(len(vs)):
        for j in range(i + 1, len(vs)):
            pairs.add((vs[i], vs[j]))
check("category pairs sharing an element", len(pairs), stated(r"\*\*all (\d+) category pairs share"))
check("category pairs sharing nothing", 66 - len(pairs), 0)

span = {N[e]["label"]: len(v) for e, v in el_cats.items()}
for lab, want in [("Up", 12), ("Fd", 11), ("Gp", 11), ("Sh", 10), ("Xf", 10), ("Aw", 10)]:
    check("element %s spans" % lab, span.get(lab), want)

deg = Counter()
for l in d["links"]:
    deg[str(l["source"])] += 1
    deg[str(l["target"])] += 1
top = [(N[i]["label"], c, N[i]["kind"]) for i, c in deg.most_common(6)]
check("top-degree node is an element", all(t[2] == "element" for t in top), True)
check("god-node Gp degree", deg[[i for i in N if N[i].get("label") == "Gp"][0]], 94)
check("god-node Aw degree", deg[[i for i in N if N[i].get("label") == "Aw"][0]], 94)
hp = max((c for i, c in deg.items() if N[i].get("kind") == "protocol"))
check("highest-degree protocol", hp, 43)

ob = defaultdict(set)
for l in d["links"]:
    if l.get("relation") == "owes" and cat.get(str(l["source"])):
        ob[(N[str(l["target"])].get("label") or "").strip().lower()].add(cat[str(l["source"])])
check("distinct obligation texts", len(ob), stated(r"\*\*0 of (\d+) distinct"))
check("obligation texts recurring across categories",
      sum(1 for v in ob.values() if len(v) > 1), 0)

# ---- the thin spots the document admits to ---------------------------------
print("\nthin spots")
g3 = load("%s/03-cdp-stablecoins/graphify-out/graph.json" % ROOT)
check("03-cdp-stablecoins nodes", len(g3["nodes"]), stated(r"So 03 has the fewest nodes of any lane, (\d+),"))
check("07-bridges nodes", len(load("%s/07-bridges/graphify-out/graph.json" % ROOT)["nodes"]), stated(r"same levels\) and yields (\d+) nodes"))
check("lanes with isolated nodes", len(thin), 4)
check("lanes with none", 12 - len(thin), 8)

print("\n%s" % ("GRAPH CLAIMS VERIFIED" if not fail else "GRAPH CLAIMS VIOLATED"))
for f in fail:
    print("  ", f)
sys.exit(1 if fail else 0)
