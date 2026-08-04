"""Atlas loader: parses viz/src/data.ts directly (no TS toolchain) and
re-implements the reference law semantics of viz/src/laws.ts in Python.

OP-LOG. Everything downstream imports from here so that the propositional
encoding is derived from the source of truth, not retyped.
"""
import re, json, os, glob

ROOT = "/root/DefiElements"
DATA = os.path.join(ROOT, "viz/src/data.ts")

_src = open(DATA, encoding="utf8").read()

# ---------------------------------------------------------------- elements
_el_re = re.compile(
    r'\{\s*id:\s*"(?P<id>[^"]+)",\s*sym:\s*"(?P<sym>[^"]+)",\s*name:\s*"(?P<name>[^"]*)",'
    r'\s*group:\s*"(?P<group>[^"]+)",\s*stratum:\s*(?P<stratum>\d),\s*atom:\s*"(?P<atom>[NRI])",'
    r'\s*status:\s*"(?P<status>[a-z]+)"')

ELEMENTS = []
for m in _el_re.finditer(_src):
    d = m.groupdict()
    d["stratum"] = int(d["stratum"])
    ELEMENTS.append(d)

# CSM has status "limit" and declares itself not an element.
MECHANISMS = [e for e in ELEMENTS if e["status"] != "limit"]
SYMS = [e["sym"] for e in MECHANISMS]
SYMSET = set(SYMS)
BY_SYM = {e["sym"]: e for e in MECHANISMS}
GROUP = {e["sym"]: e["group"] for e in MECHANISMS}
STRATUM = {e["sym"]: e["stratum"] for e in MECHANISMS}
ATOM = {e["sym"]: e["atom"] for e in MECHANISMS}
STATUS = {e["sym"]: e["status"] for e in MECHANISMS}

# -------------------------------------------------------------------- laws
_law_re = re.compile(r'\{\s*id:\s*"(?P<id>L\d+)",\s*rule:\s*"(?P<rule>[^"]+)"')
LAWS = [m.groupdict() for m in _law_re.finditer(_src)]

_haz_re = re.compile(r'\{\s*id:\s*"(?P<id>X[0-9ab]+)",\s*combo:\s*"(?P<combo>[^"]+)",\s*cls:\s*"(?P<cls>[FHU])"')
HAZARDS = [m.groupdict() for m in _haz_re.finditer(_src)]


def _bare(s):
    return re.sub(r"\{[^}]*\}", "", s).replace("(", "").replace(")", "").strip()


def _parse_side(side):
    terms = []
    for chunk in side.split("+"):
        raw = chunk.strip()
        alts = [a for a in (_bare(x) for x in raw.split("|")) if a in SYMSET]
        terms.append({"alts": alts, "prose": raw, "external": len(alts) == 0})
    return terms


PARSED = []
for l in LAWS:
    lhs, _, rhs = l["rule"].partition("→")
    subjects = [s for s in (_bare(x) for x in lhs.split("|")) if s in SYMSET]
    PARSED.append({"id": l["id"], "rule": l["rule"], "subjects": subjects,
                   "terms": _parse_side(rhs)})

FIREABLE = [p for p in PARSED if p["subjects"]]


def closure_violations(S):
    """Reference closure predicate (laws.ts `closes`). Returns list of
    (law_id, term_index, alts) for every fired law with an unsatisfied internal term."""
    S = set(S)
    out = []
    for law in FIREABLE:
        if not any(s in S for s in law["subjects"]):
            continue
        for i, t in enumerate(law["terms"]):
            if t["external"]:
                continue
            if not any(a in S for a in t["alts"]):
                out.append((law["id"], i, tuple(t["alts"])))
    return out


def closes(S):
    return not closure_violations(S)


_NEG = re.compile(r"\b(no|without|absent|lacking|missing|never)\b", re.I)


def armed_written_hazards(S):
    """laws.ts `armedHazards`."""
    S = set(S)
    out = []
    for h in HAZARDS:
        named = []
        for m in re.findall(r"\b[A-Z][a-z]{1,2}\b", h["combo"]):
            if m in SYMSET and m not in named:
                named.append(m)
        if len(named) < 2:
            continue
        if _NEG.search(h["combo"]):
            continue
        if all(m in S for m in named):
            out.append(h["id"])
    return out


# ------------------------------------------------------------------ corpus
def real_protocols():
    out = []
    for f in sorted(glob.glob(os.path.join(ROOT, "corpus50/lanes/*.json"))):
        d = json.load(open(f, encoding="utf8"))
        for c in d["categories"]:
            for p in c["protocols"]:
                out.append({"name": p["name"], "category": c["category"],
                            "lane": os.path.basename(f),
                            "syms": sorted(set(p["elements"]))})
    return out


def blind_cases():
    d = json.load(open(os.path.join(ROOT, "algebra/blind-test-set.json"), encoding="utf8"))
    return d["cases"]


if __name__ == "__main__":
    print("mechanisms", len(MECHANISMS), "laws", len(LAWS), "fireable", len(FIREABLE),
          "hazards", len(HAZARDS))
    R = real_protocols()
    print("real protocols", len(R))
    print("closes:", sum(1 for r in R if closes(r["syms"])), "/", len(R))
    B = blind_cases()
    print("blind", len(B), "closes:", sum(1 for b in B if closes(b["elements"])))
    print("unknown syms in blind:",
          sorted({s for b in B for s in b["elements"]} - SYMSET))
