from pathlib import Path
import json, hashlib, subprocess, datetime, sys, re
R=Path('/home/charl/defiformal');E=Path(__file__).resolve().parent;P=E.parent
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((P/'manifest.json').read_bytes()); bundle=(P/'bundle.md').read_bytes(); rows=[]
assert m['candidate']=='abf81ef6379a51727f825208f2234e2f28d37358'
assert sha(bundle)==m['bundle_sha256']=='13363626584c780d93691a1dc1dbcb6a707252d005954e9a3429b50096408ef5'
assert len(bundle)==m['bundle_bytes']==1367949
assert len(m['inputs'])==76
for i in m['inputs']:
 raw=(R/i['path']).read_bytes(); git=subprocess.check_output(['git','show',m['candidate']+':'+i['path']],cwd=R)
 assert len(raw)==i['bytes'] and sha(raw)==i['sha256'] and raw==git,i['path']
 if i['representation']=='lossless_compact_json':
  rendered=(json.dumps(json.loads(raw),ensure_ascii=False,separators=(',',':'))+'\n').encode()
 else:rendered=raw
 assert len(rendered)==i['rendered_bytes'] and sha(rendered)==i['rendered_sha256'],i['path']
 marker=('## INPUT '+i['path']+'\nSource SHA256 '+i['sha256']+'\nRendered SHA256 '+i['rendered_sha256']+'\n\n').encode()
 assert bundle.count(marker)==1
 pos=bundle.index(marker)+len(marker);assert bundle[pos:pos+len(rendered)]==rendered,i['path']
 rows.append({'path':i['path'],'sha256':sha(raw),'git_object':subprocess.check_output(['git','rev-parse',m['candidate']+':'+i['path']],cwd=R,text=True).strip(),'bytes':len(raw),'render_sha256':sha(rendered),'current_candidate_render_equal':True})
# Reconstruct the complete file, preserving the reviewed prompt and exact section separators.
first=bundle.index(b'## INPUT '); parts=[]
for x in m['inputs']:
 raw=(R/x['path']).read_bytes()
 body=(json.dumps(json.loads(raw),ensure_ascii=False,separators=(',',':'))+'\n').encode() if x['representation']=='lossless_compact_json'else raw
 header=('## INPUT '+x['path']+'\nSource SHA256 '+x['sha256']+'\nRendered SHA256 '+x['rendered_sha256']+'\n\n').encode()
 parts.append(header+body)
assert bundle[:first]+b'\n\n'.join(parts)==bundle
assert len(re.findall(b'^## INPUT ',bundle,re.M))==76
C=R/'openspec/changes/historical-claim-reconciliation';specs=list((C/'specs').glob('*/spec.md'));actual=[];reqs=[]
for p in specs:
 t=p.read_text();reqs+=re.findall(r'^### Requirement: (\w+)',t,re.M);req=None
 for line in t.splitlines():
  if line.startswith('### Requirement: '):req=line.split()[2]
  if line.startswith('#### Scenario: '):actual.append((line.split()[2],req,str(p.relative_to(R))))
sc=json.loads((C/'scenario-map.json').read_text())['scenarios'];assert sorted(actual)==sorted((x['id'],x['requirement'],x['path'])for x in sc)
tasks=re.findall(r'^- \[ \] ([0-9.]+) ',(C/'tasks.md').read_text(),re.M);cs=json.loads((C/'control-inventory.json').read_text())['controls'];cl=json.loads((R/'review/semantic-kernel/claim-reconciliation/preparation-r2/claims.json').read_text())['entries'];cm=json.loads((C/'claim-disposition-map.json').read_text());sites=[s for x in cl for s in x['sites']]
assert len(specs)==4 and len(reqs)==18 and len(actual)==45 and len(tasks)==27 and len(cs)==26
assert len(cl)==18 and len(sites)==63 and len(set(s['path']for s in sites))==22 and len(cm['register_rows'])==10
assert len({x['id']for x in cs})==len(cs) and all(x['scenario']in {a[0]for a in actual}for x in cs)
assert all(x['evidence_status']=='pending_implementation'and not x['acceptance_evidence']for x in sc)
res={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'candidate':m['candidate'],'bundle_sha256':sha(bundle),'manifest_sha256':sha((P/'manifest.json').read_bytes()),'inputs':rows,'counts':{'inputs':len(rows),'capabilities':len(specs),'requirements':len(reqs),'scenarios':len(actual),'unchecked_tasks':len(tasks),'planned_controls':len(cs),'claims':len(cl),'excerpts':len(sites),'claim_source_files':len(set(s['path']for s in sites)),'register_rows':len(cm['register_rows'])},'all_checks_pass':True,'scope':'Independent byte/Git/render/schema inventory checks; no implementation, historical numerical rerun or native call.'}
(E/(sys.argv[1] if len(sys.argv)>1 else 'bindings-before.json')).write_text(json.dumps(res,indent=2)+'\n');print(json.dumps({'all_checks_pass':True,'counts':res['counts']}))
