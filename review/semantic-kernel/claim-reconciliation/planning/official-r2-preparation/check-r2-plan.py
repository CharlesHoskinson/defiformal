#!/usr/bin/env python3
"""Static author-draft reconciliation only; no implementation or semantic run."""
from pathlib import Path
import hashlib, json, re, subprocess, sys
from datetime import datetime, timezone
ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).resolve().parent
PLAN = ROOT / 'openspec/changes/historical-claim-reconciliation'
def read(p): return json.loads(p.read_text())
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def record(p): return {'path':str(p.relative_to(ROOT)), 'bytes':p.stat().st_size, 'sha256':sha(p)}
checks=[]
def check(name, value):
 checks.append({'name':name,'passed':bool(value)})
 if not value: print('FAILED:',name, file=sys.stderr)
before=read(OUT/'before.json')
for r in before['plan_inputs']:
 p=OUT/'before'/r['path']; check('preserved original plan '+r['path'],sha(p)==r['sha256'])
for r in before['held_inputs']:
 check('unchanged held current '+r['path'],sha(ROOT/r['path'])==r['sha256'])
old=read(OUT/'before/openspec/changes/historical-claim-reconciliation/claim-disposition-map.json')
ledger=read(PLAN/'claim-disposition-map.json')
check('18 original claim IDs', [r['id'] for r in ledger['entries']]==[f'CL{i:02d}' for i in range(1,19)])
check('ten immutable original register mappings',old['register_rows']==ledger['register_rows'] and len(ledger['register_rows'])==10)
for a,b in zip(old['entries'],ledger['entries']):
 for k in ['id','topic','original_pointer','original_path','original_disposition','original_sites','limit','scenario']:
  check(a['id']+' preserved '+k,a[k]==b[k])
 check(a['id']+' implementation not started',b['implementation_status']=='not_started')
sites=[s for r in ledger['entries'] for s in r['original_sites']]
check('63 original sites',len(sites)==63);check('22 original source files',len({s['path'] for s in sites})==22)
source_claims=read(ROOT/'review/semantic-kernel/claim-reconciliation/preparation-r2/claims.json')
for r in ledger['entries']:
 original=source_claims['entries'][int(r['original_pointer'].split('/')[-1])]
 check(r['id']+' original pointer resolves',original['id']==r['id'])
 check(r['id']+' disposition preserved',original['disposition']==r['original_disposition'])
scenario=read(PLAN/'scenario-map.json'); controls=read(PLAN/'control-inventory.json'); contracts=read(PLAN/'revision-contracts.json')
parsed=[];requirements=[]
for p in sorted((PLAN/'specs').glob('*/spec.md')):
 s=p.read_text()
 for req,body in re.findall(r'^### Requirement: (\w+) [^\n]+\n(.*?)(?=^### Requirement:|\Z)',s,re.M|re.S):
  requirements.append(req)
  for sid,b in re.findall(r'^#### Scenario: (\w+) [^\n]+\n(.*?)(?=^#### Scenario:|\Z)',body,re.M|re.S):
   parsed.append({'id':sid,'requirement':req,'path':str(p.relative_to(ROOT)),**{k:re.search(r'\*\*'+v+r'\*\* (.*)',b).group(1) for k,v in [('when','WHEN'),('then','THEN')]}})
check('four capabilities',len(list((PLAN/'specs').glob('*/spec.md')))==4)
check('18 requirements',len(requirements)==len(set(requirements))==18)
check('45 actual normative scenarios',len(parsed)==len({r['id'] for r in parsed})==45)
check('45 mapped scenarios',len(scenario['scenarios'])==scenario['scenario_count']==45)
by={r['id']:r for r in scenario['scenarios']}
for r in parsed:
 for k,v in r.items():check(r['id']+' exact '+k,by[r['id']][k]==v)
 check(r['id']+' evidence still pending',by[r['id']]['evidence_status']=='pending_implementation' and not by[r['id']]['acceptance_evidence'])
 for c in by[r['id']]['claims']:check(r['id']+' valid '+c,c in {v['id'] for v in ledger['entries']})
check('26 unique controls',len(controls['controls'])==controls['count']==26 and len({r['id'] for r in controls['controls']})==26)
for c in controls['controls']:
 check(c['id']+' has exact scenario',c['scenario'] in by and c['id'] in by[c['scenario']]['controls'])
 check(c['id']+' unexecuted expected exit and sibling',c['status']=='planned_not_executed' and c['expected_exit'] in [0,1,3] and bool(c['successful_sibling']))
check('all control links exact',sorted(c for r in by.values() for c in r['controls'])==sorted(c['id'] for c in controls['controls']))
tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) ',(PLAN/'tasks.md').read_text(),re.M)
check('27 unchecked implementation tasks',len(tasks)==27 and all(flag==' ' for flag,_ in tasks))
# Literal source lexical inventory, not an execution of the historical parser.
pattern=r'\{\s*id:\s*"([^"]+)",\s*sym:\s*"([^"]+)",\s*name:\s*"([^"]*)",\s*group:\s*"([^"]+)",\s*stratum:\s*(\d),\s*atom:\s*"([NRI])",\s*status:\s*"([a-z]+)"'
elements=re.findall(pattern,(ROOT/'viz/src/data.ts').read_text())
check('59 matched unique literal symbols',len(elements)==len({r[1] for r in elements})==59)
check('58 status-filtered literal mechanisms',len([r for r in elements if r[6]!='limit'])==58)
check('actual excluded literal CSM',[(r[1],r[6]) for r in elements if r[6]=='limit']==[('CSM','limit')])
check('no obsolete Cs literal',not any(re.search(r'\bCs\b',p.read_text()) for p in PLAN.rglob('*') if p.is_file()))
observed=sorted(set(re.findall(r'\\begin\{([^}]+)\}',(ROOT/'paper/atlas.tex').read_text())))
check('17 observed literal TeX names',len(observed)==17)
check('closed TeX inventory exact',observed==contracts['tex']['observed_literal_environment_names'])
check('every observed name classified',set(observed)==set(contracts['tex']['frozen_base_environments']+contracts['tex']['eligible_wrappers']))
for section,key in [('library','configuration'),('tex','source'),('vocabulary','source'),('vocabulary','parser')]:
 r=contracts[section][key];check('contract exact source '+r['path'],record(ROOT/r['path'])==r)
node=contracts['node'];check('standalone historical Node binary actual SHA',sha(Path(node['path']))==node['sha256'])
check('Data export same Data module',contracts['lean_data_export']['owner_module']=='DefiHistorical.Convex.Data' and contracts['lean_data_export']['export_module']=='DefiHistorical.Convex.DataExport')
check('future library source not implemented',not (ROOT/'lean/DefiHistorical').exists())
check('current lakefile only original two libraries',(ROOT/'lean/lakefile.toml').read_text().count('[[lean_lib]]')==2)
# Machine-readable full scenario/task/control planning projection.
projection=[]
for r in scenario['scenarios']:
 sid=r['id']; n=int(sid[1:])
 if sid.startswith('H'):
  ts=['2.1','2.2', '2.3' if n<=5 else '2.4' if n<=10 else '2.5' if n<=14 else '2.6']
  if sid in ['H04','H06','H09','H16','H17','H18']: ts.append('2.7')
 elif sid.startswith('B'):
  ts=({'B01':['3.1'],'B02':['3.1'],'B03':['3.2','3.3'],'B04':['3.2','3.3'],'B05':['3.4'],'B06':['3.4','3.6'],'B07':['3.5'],'B08':['3.5','3.6'],'B09':['3.7'],'B10':['3.7']})[sid]
 elif sid.startswith('E'): ts=['1.3','4.1'] if n<=3 else ['4.2'] if n<=6 else ['4.3']
 else: ts={'A01':['5.1'],'A02':['2.1','5.1','5.3'],'A03':['4.4','5.2'],'A04':['4.4','5.2'],'A05':['5.4'],'A06':['5.4'],'A07':['1.1','1.2','5.5'],'A08':['5.6']}[sid]
 check(r['id']+' mapped task group nonempty',bool(ts))
 projection.append({'scenario':r['id'],'requirement':r['requirement'],'source':r['path'],'tasks':ts,'controls':r['controls'],'claims':r['claims'],'planned_evidence_kinds':r['planned_evidence_kinds'],'status':'pending_implementation'})
check('all27 task IDs mapped', {t for r in projection for t in r['tasks']}=={tid for _,tid in tasks})
resolution=read(OUT/'resolution-matrix.json')
check('four required and six minor finding resolutions',len(resolution['findings'])==10 and resolution['required_findings']==4 and resolution['minor_findings']==6)
for row in resolution['findings']:
 check(row['finding']+' source exists',(ROOT/row['plan_path']).is_file())
 check(row['finding']+' scenario IDs valid',all(s in by for s in row['scenarios']))
 check(row['finding']+' control IDs valid',all(c in {v['id'] for v in controls['controls']} for c in row['controls']))
 check(row['finding']+' task IDs valid',all(t in {tid for _,tid in tasks} for t in row['tasks']))
(OUT/'scenario-control-task-map.json').write_text(json.dumps({'status':'AUTHOR_DRAFT_MAPPING_ONLY','scenarios':projection},indent=2)+'\n')
result={'status':'PASS' if all(r['passed'] for r in checks) else 'FAIL','scope':'static author reconciliation; no Lean, m5, TeX build, or future control execution','start_head':before['head'],'observed_end_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'checked_utc':datetime.now(timezone.utc).isoformat(),'counts':{'capabilities':4,'requirements':18,'scenarios':45,'claims':18,'original_sites':63,'original_files':22,'register_rows':10,'unchecked_tasks':27,'planned_controls':26,'held_current_files':len(before['held_inputs']),'checks':len(checks)},'checks':checks,'plan_inputs':[record(p) for p in sorted(PLAN.rglob('*')) if p.is_file()],'source_inputs':[record(ROOT/p) for p in ['AGENTS.md','lean/lakefile.toml','paper/atlas.tex','viz/src/data.ts','formal/v2/tables.mjs','formal/v3/lib.mjs','formal/v3/m5-convex.mjs','lean/Defialgebra/ConvexGeometry.lean','review/semantic-kernel/claim-reconciliation/planning/official-r1/review-fable-after-reset.md','review/semantic-kernel/claim-reconciliation/preparation-r2/claims.json']]}
(OUT/'checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['status','counts','start_head','observed_end_head']}))
sys.exit(0 if result['status']=='PASS' else 1)
