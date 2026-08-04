import re, json, itertools, os
ROOT = "/root/DefiElements"
src = open(f"{ROOT}/viz/src/data.ts").read()

# ---- elements
ELEMS = {}
_e = re.compile(r'\{\s*id:\s*"([^"]+)",\s*sym:\s*"([^"]+)",\s*name:\s*"([^"]*)",\s*group:\s*"([^"]+)",\s*stratum:\s*(\d),\s*atom:\s*"([NRI])",\s*status:\s*"([a-z]+)"')
for m in _e.finditer(src):
    eid, sym, name, grp, st, atom, status = m.groups()
    ELEMS[sym] = dict(id=eid, sym=sym, name=name, group=grp, stratum=int(st), atom=atom, status=status)
SYMS = set(ELEMS)

# ---- laws
LAWS = []
for m in re.finditer(r'\{\s*id:\s*"(L\d+)",\s*rule:\s*"([^"]+)"', src):
    LAWS.append(dict(id=m.group(1), rule=m.group(2)))

# ---- hazards
HAZ = []
for m in re.finditer(r'\{\s*id:\s*"(X\d+[ab]?)",\s*combo:\s*"([^"]+)",\s*cls:\s*"([FHU])"', src):
    HAZ.append(dict(id=m.group(1), combo=m.group(2), cls=m.group(3)))


def bare(s):
    return re.sub(r"\{[^}]*\}", "", s).replace("(", "").replace(")", "").strip()


PARSED = []
for l in LAWS:
    lhs, _, rhs = l["rule"].partition("→")
    subs = [bare(x) for x in lhs.split("|")]
    subs = [s for s in subs if s in SYMS]
    terms = []
    for chunk in rhs.split("+"):
        raw = chunk.strip()
        alts = [bare(a) for a in raw.split("|")]
        alts = [a for a in alts if a in SYMS]
        terms.append(dict(alts=alts, prose=raw, external=len(alts) == 0))
    PARSED.append(dict(id=l["id"], rule=l["rule"], subjects=subs, terms=terms))

NEGRE = re.compile(r"\b(no|without|absent|lacking|missing|never)\b", re.I)


def haz_named(h):
    return [x for x in dict.fromkeys(re.findall(r"\b[A-Z][a-z]{1,2}\b", h["combo"])) if x in SYMS]


def closes_ref(X):
    S = set(X)
    open_ = []
    for law in PARSED:
        if not any(s in S for s in law["subjects"]):
            continue
        for t in law["terms"]:
            if t["external"]:
                continue
            if not any(a in S for a in t["alts"]):
                open_.append((law["id"], t["prose"]))
                break
    return open_


def armed_ref(X):
    S = set(X)
    out = []
    for h in HAZ:
        named = haz_named(h)
        if len(named) < 2:
            continue
        if NEGRE.search(h["combo"]):
            continue
        if all(m in S for m in named):
            out.append(h["id"])
    return out


# ---- corpora
blind = json.load(open(f"{ROOT}/algebra/blind-test-set.json"))["cases"]
lanes = []
for f in sorted(os.listdir(f"{ROOT}/corpus50/lanes")):
    d = json.load(open(f"{ROOT}/corpus50/lanes/{f}"))
    for c in d["categories"]:
        for p in c["protocols"]:
            lanes.append(dict(name=p["name"], cat=c["category"], syms=sorted(set(p["elements"]))))
LANESETS = {}
for p in lanes:
    LANESETS.setdefault(frozenset(p["syms"]), []).append(p["name"])
