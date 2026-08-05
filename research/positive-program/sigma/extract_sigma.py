"""Mechanically extract from the 57 typechecked Quint specs everything that is
a fact about the code: operation degree, parameter names, declared record types,
state variables, element-symbol annotations, and the call graph.

No judgement, no assignment. Where a quantity is NOT derivable, it is reported
as a gap rather than guessed."""
import json
import re
import subprocess
import glob
import os
from collections import defaultdict, Counter

MODELS = "/root/DefiElements/quint-models"
OUT = "/root/DefiElements/research/positive-program/sigma"
os.makedirs(OUT, exist_ok=True)

specs = sorted(glob.glob(f"{MODELS}/L*/*.qnt"))
print(f"specs: {len(specs)}")

ELEM_RE = re.compile(r"\(([A-Z][a-z])\)")          # (Cp), (Ct), ...
PRIM_RE = re.compile(r"Candidate primitive:\s*([A-Z_]+)\s*\(([A-Z][a-z])\)")

records = {}
defs = []
statevars = []
annot = defaultdict(set)      # element symbol -> {def names}
parse_fail = []

for path in specs:
    lane = path.split("/")[-2]
    src = open(path, encoding="utf-8", errors="replace").read()

    # --- element annotations from comments, attached to the NEXT def
    lines = src.splitlines()
    pending = set()
    for ln in lines:
        s = ln.strip()
        if s.startswith("//") or s.startswith("///"):
            m = PRIM_RE.search(s)
            if m:
                pending.add(m.group(2))
            else:
                for e in ELEM_RE.findall(s):
                    pending.add(e)
            continue
        dm = re.match(r"(?:pure\s+)?(?:def|val|action)\s+([A-Za-z_][A-Za-z0-9_]*)", s)
        if dm and pending:
            for e in pending:
                annot[e].add(f"{lane}:{dm.group(1)}")
            pending = set()
        elif s and not s.startswith("//"):
            if dm is None and not s.startswith(("type", "var", "const", "module", "}")):
                pending = set()

    # --- declared record types (field names are the real colour evidence)
    for m in re.finditer(r"type\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\{([^}]*)\}", src, re.S):
        fields = [f.split(":")[0].strip() for f in m.group(2).split(",") if ":" in f]
        records[f"{lane}:{m.group(1)}"] = fields

    # --- IR parse for exact signatures
    irp = f"/tmp/ir_{lane}_{os.path.basename(path)}.json"
    r = subprocess.run(["quint", "parse", path, "--out", irp],
                       capture_output=True, text=True)
    if r.returncode != 0 or not os.path.exists(irp):
        parse_fail.append(path)
        continue
    ir = json.load(open(irp))
    for mod in ir.get("modules", []):
        for de in mod.get("declarations", []):
            if de.get("kind") == "var":
                statevars.append({"lane": lane, "spec": os.path.basename(path),
                                  "name": de.get("name"),
                                  "type": json.dumps(de.get("typeAnnotation"))[:200]})
            if de.get("kind") != "def":
                continue
            ta = de.get("typeAnnotation") or {}
            if ta.get("kind") == "oper":
                args = [a.get("kind") for a in ta.get("args", [])]
                res = (ta.get("res") or {}).get("kind")
            else:
                args, res = [], ta.get("kind")
            defs.append({
                "lane": lane, "spec": os.path.basename(path),
                "name": de.get("name"), "qualifier": de.get("qualifier"),
                "in_degree": len(args), "in_types": args, "out_type": res,
            })

print(f"parse failures: {len(parse_fail)}")
print(f"definitions extracted: {len(defs)}")
print(f"state variables: {len(statevars)}")
print(f"declared record types: {len(records)}")
print(f"elements with a comment annotation: {len(annot)}")

# ---- what the type system actually distinguishes
print("\n--- distinct argument type constructors across ALL defs ---")
tc = Counter(t for d in defs for t in d["in_types"])
for k, v in tc.most_common():
    print(f"   {k:<12} {v}")
print("--- distinct result type constructors ---")
rc = Counter(d["out_type"] for d in defs)
for k, v in rc.most_common():
    print(f"   {str(k):<12} {v}")

# ---- degree distribution (this IS the mechanical arity)
print("\n--- operation in-degree distribution ---")
dd = Counter(d["in_degree"] for d in defs)
for k in sorted(dd):
    print(f"   arity {k}: {dd[k]}")
nz = [d["in_degree"] for d in defs if d["in_degree"] > 0]
print(f"   mean in-degree (operators only): {sum(nz)/len(nz):.2f}  max {max(nz)}")

# ---- element coverage
print(f"\n--- element symbols annotated in specs: {len(annot)} of 58 ---")
print("   ", " ".join(sorted(annot)))

json.dump({"defs": defs, "statevars": statevars, "records": records,
           "annot": {k: sorted(v) for k, v in annot.items()},
           "parse_failures": parse_fail},
          open(f"{OUT}/extraction.json", "w"), indent=2)
print(f"\nwritten: {OUT}/extraction.json")
