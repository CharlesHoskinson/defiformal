#!/usr/bin/env python3
"""Read-only reconciliation of proof inventory, scenario evidence and revision bindings."""
import datetime, hashlib, json, pathlib, re, subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3]
OUT=ROOT/'review/semantic-kernel/sprint7'
def read(p): return json.loads(p.read_text())
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def git(rev,p): return subprocess.check_output(['git','show',rev+':'+p],cwd=ROOT)
results=[]
def check(n,v):
 results.append({'id':n,'passed':bool(v)})
 if not v: print('FAIL',n)
i=read(OUT/'proof-inventory.json');m=read(OUT/'scenario-map.json');snap=read(OUT/'inventory-r1/snapshot.json')
candidate='bea105ec72e633a2dd66c663b96d0b552e1814a8'
check('candidate.same',i['candidate']==m['candidate']==candidate)
for p,h in snap['sha256'].items(): check('r1.snapshot.'+p,sha(OUT/'inventory-r1'/p)==h)
for p,b in i['source_bindings'].items():
 check('source.sha256.'+p,sha(ROOT/p)==b['sha256'])
 check('source.git.'+p,(ROOT/p).read_bytes()==git(candidate,p))
allowed={'propext','Classical.choice','Quot.sound'}
proofs={p['name']:p for p in i['theorems']}
for p in i['theorems']+i['supplemental']:
 check('axioms.'+p['name'],set(p['axioms'])<=allowed)
 check('statement.full.'+p['name'],bool(p['statement']) and '⋯' not in p['statement'])
 if p.get('declaration_origin')=='explicit' and 'line' in p:
  check('source.line.'+p['name'],p['source_statement'].splitlines()[0].strip() in (ROOT/p['source']).read_text().splitlines()[p['line']-1])
raw=(OUT/'proof-types.log').read_text().splitlines()
for prefix,key in [('INTERLEAVING_PROOF_JSON ','theorems'),('INTERLEAVING_SUPPLEMENTAL_JSON ','supplemental')]:
 parsed=[json.loads(s[len(prefix):]) for s in raw if s.startswith(prefix)]
 check('raw.count.'+key,len(parsed)==len(i[key]))
 check('raw.exact.'+key,{p['name']:(p['statement'],p['axioms'],p['module']) for p in parsed}=={p['name']:(p['statement'],p['axioms'],p['module']) for p in i[key]})
check('count.theorems',len(i['theorems'])==262)
check('count.supplemental',len(i['supplemental'])==271)
check('count.explicit',sum(p['declaration_origin']=='explicit' for p in i['theorems'])==127)
check('count.generic',sum(p['category']=='genericproof' for p in i['theorems'])==107)
rows=re.findall(r'^(interleaving\.[a-z0-9.-]+): (true|false)$',(OUT/'integration-final/01.log').read_text(),re.M)
runtime=dict(rows)
check('runtime.exact116',len(rows)==len(runtime)==116 and all(v=='true' for v in runtime.values()) and set(runtime)==set(m['runtime_inventory']))
evidence={e['id']:e for e in m['evidence']}
for e in m['evidence']:
 n=e['id']
 if e.get('name','').startswith('DefiKernel.'):
  check('proof.exists.'+n,e['name'] in proofs)
  p=proofs[e['name']]
  check('proof.exact.'+n,all(e[k]==p[k] for k in ['statement','source','line','axioms']))
 if e.get('name','').startswith('interleaving.'):
  check('runtime.true.'+n,runtime.get(e['name'])=='true')
  check('runtime.line.'+n,(ROOT/e['source']).read_text().splitlines()[e['line']-1]==e['source_line'])
 for p in e.get('artifacts',[]): check('artifact.exists.'+n+'.'+p,(ROOT/p).exists())
 for p,h in e.get('artifact_hashes',{}).items(): check('artifact.hash.'+n+'.'+p,sha(ROOT/p)==h)
for p,h in m['spec_sha256'].items(): check('spec.sha256.'+p,sha(ROOT/p)==h)
for s in m['scenarios']:
 n=s['id'];check('scenario.exists.'+n,s['scenario'] in (ROOT/s['spec']).read_text().splitlines()[s['line']-1])
 check('scenario.nonempty.'+n,bool(s['evidence']) and all(e in evidence for e in s['evidence']))
 check('scenario.pending.honest.'+n,bool(s['pending'])==(s['status']!='verified-at-frozen-source'))
check('scenarios.exact43',len(m['scenarios'])==len({s['id'] for s in m['scenarios']})==43)
check('scenarios.pending42and43',{s['id'] for s in m['scenarios'] if s['pending']}=={'S42','S43'})
check('completion.admission.S12',any('runInterleaving_admission_refusal' in e for e in m['scenarios'][11]['evidence']))
check('completion.active.S25',any('runPrefix_complete_active_exhaustion' in e for e in m['scenarios'][24]['evidence']))
check('completion.refusal.S25',any('runPrefix_complete_exhausted_or_refused' in e for e in m['scenarios'][24]['evidence']))
b=read(OUT/'implementation/proof-supplement-binding.json')
check('runtime.binding28',len(b['files'])==28)
for f in b['files']:
 p=f['path'];check('runtime.equivalence.'+p,git(b['runtime_execution_candidate'],p)==git(b['final_proof_candidate'],p)==(ROOT/p).read_bytes())
for p in ['proof-inventory-driver.lean','proof-types.log','proof-inventory.json','proof-inventory-execution.json','scenario-map.json','coverage.md','build-proof-inventory.py','build-scenario-map.py','validate-coverage.py']:
 check('input.exists.'+p,(OUT/p).exists())
report={'candidate':candidate,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':len(results),'passed':sum(r['passed'] for r in results),'all_passed':all(r['passed'] for r in results),'scope':'Read-only reconciliation of final proof candidate and scenario evidence. Mutation, runner-control and legacy regression execution identities remain at 6de24fe; only 28 explicit runtime inputs are claimed equal across revisions. Native adjudication and delivery remain pending.','input_sha256':{p:sha(OUT/p) for p in ['proof-inventory-driver.lean','proof-types.log','proof-inventory.json','proof-inventory-execution.json','scenario-map.json','coverage.md','build-proof-inventory.py','build-scenario-map.py','validate-coverage.py']},'results':results}
(OUT/'coverage-validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['results','input_sha256']},indent=2))
raise SystemExit(not report['all_passed'])
