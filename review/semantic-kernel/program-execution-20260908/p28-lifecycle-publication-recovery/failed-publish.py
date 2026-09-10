from pathlib import Path
import json,hashlib,datetime,subprocess
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';C=B.parent/'strategy-audit-20260908/CURRENT.json'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=R,text=True).strip()
paths={B/'p28-depeg-lifecycle-diagnostic-scope.md',B/'STATE.json',C}
for n in ['p28-depeg-lifecycle-diagnostic','p28-depeg-lifecycle-root-verification']:
 o=B/n;s=read(o/'root-seal.json');paths.add(o/'root-seal.json')
 for p,d in s['files'].items():assert h(o/p)==d,p;paths.add(o/p)
v=read(B/'p28-depeg-lifecycle-root-verification/result.json');record={**v,'packet':'p28-depeg-lifecycle-diagnostic/root-seal.json','root_verification':'p28-depeg-lifecycle-root-verification/root-seal.json','scope_record':'p28-depeg-lifecycle-diagnostic-scope.md','scope_record_sha256':h(B/'p28-depeg-lifecycle-diagnostic-scope.md'),'full_workflow_accepted':False}
for p in [B/'STATE.json',C]:
 s=read(p);s['updated_utc']=now();s['p28_source_preparation']['public_lifecycle_diagnostic']=record;put(p,s)
subprocess.run(['git','add','-f','--',*[str(p.relative_to(R)) for p in sorted(paths)]],cwd=R,check=True);subprocess.run(['git','-c','core.whitespace=-blank-at-eol,-blank-at-eof','diff','--cached','--check'],cwd=R,check=True);print(json.dumps({'staged_paths':len(paths),'scenarios':11,'full_workflow_accepted':False}));subprocess.run(['git','diff','--cached','--stat'],cwd=R,check=True)
