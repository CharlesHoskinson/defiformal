import hashlib, json, sys
from pathlib import Path
sandbox = Path(sys.argv[1])
inputs = json.loads(Path(sys.argv[2]).read_bytes())
rows=[]
bad=0
for rel, expected in inputs["files"].items():
    p = sandbox/rel
    actual = hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
    match = actual==expected
    if not match: bad += 1
    rows.append({"path":rel,"expected":expected,"actual":actual,"match":match,"bytes": p.stat().st_size if p.is_file() else None})
print(json.dumps({"declared":len(inputs["files"]),"match":sum(1 for r in rows if r["match"]),"mismatch":bad,"all_match":bad==0,"rows":rows}, indent=2))
sys.exit(0 if bad==0 else 1)
