#!/usr/bin/env python3
"""Create a finite, byte-exact local artifact inventory, without network access."""
import hashlib,json,pathlib
B=pathlib.Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not list(B.rglob('__pycache__'))
assert not any(p.is_symlink() for p in B.rglob('*'))
recheck=json.loads((B/'verification-recheck.json').read_text());assert recheck['status']=='PASS' and recheck['checks_passed']==1810
records=[{'path':str(p.relative_to(B)),'bytes':p.stat().st_size,'sha256':sha(p)} for p in sorted(B.rglob('*')) if p.is_file() and p.name!='artifact-manifest.json']
obj={'status':'PASS; unaccepted bounded research artifacts','file_count':len(records),'total_bytes':sum(p['bytes'] for p in records),'self_excluded':'artifact-manifest.json','no_symlinks_or_nested_git':not any('.git' in p.parts for p in B.rglob('*')),'records':records}
p=B/'artifact-manifest.json';data=json.dumps(obj,indent=2)+'\n'
if p.exists():assert p.read_text()==data
else:p.write_text(data)
print(json.dumps({'files':len(records),'bytes':obj['total_bytes'],'manifest_sha256':sha(p),'report_sha256':sha(B/'REPORT.md'),'cards_sha256':sha(B/'provisional-cards.json'),'verification_sha256':sha(B/'verification.json')},indent=2))
