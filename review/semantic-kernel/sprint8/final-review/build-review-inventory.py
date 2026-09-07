from pathlib import Path
import json,hashlib
base=Path('/home/charl/defiformal/review/semantic-kernel/sprint8');out=base/'final-review';out.mkdir(exist_ok=True)
p=base/'proof-inventory.json';data=p.read_bytes();v=json.loads(data)
w={k:x for k,x in v.items() if k not in ['theorems','supplemental']}
w['review_projection']={'full_inventory_path':str(p.relative_to(base.parent.parent.parent)),'full_inventory_sha256':hashlib.sha256(data).hexdigest(),'full_inventory_bytes':len(data),'rule':'All 106 explicit theorem rows retain full exact elaborated/source statements. All 251 generated theorem rows and 496 supplemental rows retain identity, source path, axiom metadata and SHA256 of full statement; source SHA/Git identities remain in source_bindings, omitting expanded statement and duplicated source-context fields from this native prompt. Complete original inventory is saved unchanged; these omissions are not empty or missing source declarations. Full source modules and mechanical reconciliation supplied separately.'}
def project(x):
 if x.get('declaration_origin')=='explicit' and x.get('kind')=='theorem':return x
 return {**{k:y for k,y in x.items() if k in ['name','kind','axioms','source','declaration_origin','category','is_private_name']},'statement_sha256':hashlib.sha256(x['statement'].encode()).hexdigest(),'statement_bytes':len(x['statement'].encode()),'statement_omitted_from_prompt':True}
w['theorems']=[project(x) for x in v['theorems']];w['supplemental']=[project(x) for x in v['supplemental']]
assert sum('statement' in x for x in w['theorems'])==106
p=out/'proof-inventory-review.json';p.write_text(json.dumps(w,separators=(',',':'))+'\n');print(p.stat().st_size)
p=base/'regressions/verified-outcomes.json';raw=p.read_bytes();v=json.loads(raw)
w={k:x for k,x in v.items() if k!='checks'}
w['original_artifact']={'path':'review/semantic-kernel/sprint8/regressions/verified-outcomes.json','sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw),'omission':'The 2477 individual hash/assertion rows are saved in the original artifact, omitted from this prompt; all11 outcomes retained. Native review is an artifact review, not independent reexecution of these checks.'}
(out/'regression-outcomes-review.json').write_text(json.dumps(w,indent=2)+'\n')
