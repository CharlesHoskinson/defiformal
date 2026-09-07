#!/usr/bin/env python3
"""Independent frozen-input and planning-inventory checks; not new corpus tooling."""
from pathlib import Path
import json, hashlib, subprocess, re, sys
from datetime import datetime, timezone
ROOT=Path(__file__).resolve().parents[6]
OUT=Path(__file__).resolve().parent
OFFICIAL=OUT.parent
PLAN=ROOT/'openspec/changes/corpus-provenance-adjudication'
def read(p):return json.loads(p.read_text())
def digest(b):return hashlib.sha256(b).hexdigest()
def file_record(p):
 b=p.read_bytes();return {'path':str(p.relative_to(ROOT)),'bytes':len(b),'sha256':digest(b)}
checks=[]
def ck(name,ok):
 checks.append({'name':name,'passed':bool(ok)})
 if not ok:print('FAIL',name,file=sys.stderr)
m=read(OFFICIAL/'manifest.json');bundle=(OFFICIAL/'bundle.md').read_bytes();before=read(OUT/'before.json')
ck('fixed candidate',m['candidate']=='b4705b074d7b2d205eb8ad1e2a9ded34ef4ca32f')
ck('exact bundle SHA',digest(bundle)==m['bundle_sha256']=='ec22fe017a7547011f28003f065b89be8e612597cd185ecc28c5953b4fc61a79')
ck('exact bundle bytes',len(bundle)==m['bundle_bytes']==2098076)
ck('71 unique inputs',len(m['inputs'])==m['input_count']==len({r['path'] for r in m['inputs']})==71)
ck('manifest unchanged from before',digest((OFFICIAL/'manifest.json').read_bytes())==before['manifest_sha256'])
headers=list(re.finditer(rb'^===== FILE (.+?) \| SOURCE SHA256 ([a-f0-9]+) \| RENDERING (.+?) =====\n',bundle,re.M))
ck('71 rendered sections',len(headers)==71)
for r,h in zip(m['inputs'],headers):
 b=(ROOT/r['path']).read_bytes();gitb=subprocess.check_output(['git','show',m['candidate']+':'+r['path']],cwd=ROOT)
 ck(r['path']+' actual bytes/hash',len(b)==r['bytes'] and digest(b)==r['sha256'])
 ck(r['path']+' Git candidate bytes',gitb==b)
 blob=subprocess.check_output(['git','rev-parse',m['candidate']+':'+r['path']],cwd=ROOT,text=True).strip()
 ck(r['path']+' Git blob identity',blob==r['git_blob'])
 ck(r['path']+' rendered header',(h.group(1).decode(),h.group(2).decode(),h.group(3).decode())==(r['path'],r['sha256'],r['rendering']))
 rendered=b if r['rendering']=='verbatim' else json.dumps(json.loads(b),ensure_ascii=False,separators=(',',':')).encode()
 ck(r['path']+' independent render hash',digest(rendered)==r['rendered_sha256'] and len(rendered)==r['rendered_bytes'])
 ck(r['path']+' actual rendered bytes',bundle[h.end():h.end()+len(rendered)]==rendered)
 ck(r['path']+' end marker',bundle[h.end()+len(rendered):].startswith(b'\n===== END FILE ====='))
# Recompute original corpus inventory directly, not from author count fields.
corpus=read(ROOT/'corpus/normalized/generated/corpus.json');ann={a:{r['unit_id']:r for r in read(ROOT/f'corpus/normalized/annotations/{a}.json')['annotations']} for a in ['a','b']}
actual=[]
for i,r in enumerate(corpus['adjudications']):
 for a in ['a','b']:ck(f'adjudication{i} raw {a}',r[a]==sorted(ann[a][r['unit_id']]['facets'][r['facet']]))
 sym=sorted(set(r['a'])^set(r['b']))
 ck(f'adjudication{i} actual rule',r['rule']==('INTERSECTION_UNRESOLVED' if sym else 'AGREE'))
 ck(f'adjudication{i} retained intersection',r['retained']==sorted(set(r['a'])&set(r['b'])))
 ck(f'adjudication{i} unresolved labels',r['unresolved_labels']==sym)
 if r['rule']=='INTERSECTION_UNRESOLVED':actual.append({'unit_id':r['unit_id'],'facet':r['facet'],'a':r['a'],'b':r['b'],'labels':sym,'generated_pointer':f'/adjudications/{i}'})
ck('29 actual disputed facets',len(actual)==29);ck('32 actual disputed labels',sum(len(r['labels']) for r in actual)==32)
ck('24 actual affected units',len({r['unit_id'] for r in actual})==24)
ck('17 actual distinct labels',len({x for r in actual for x in r['labels']})==17)
disputes=read(PLAN/'dispute-inventory.json')
ck('queue exact observation tuples',sorted((r['unit_id'],r['facet'],tuple(r['a']),tuple(r['b']),tuple(r['labels'])) for r in actual)==sorted((r['unit_id'],r['facet'],tuple(r['a']),tuple(r['b']),tuple(r['disputed_labels'])) for r in disputes['disagreements']))
liq=corpus['adjudications'][77];ck('Liquity challenge is shared label not extra facet',liq['unit_id']=='unit:lane1:c2:p4:v1' and liq['facet']=='mechanisms' and liq['rule']=='INTERSECTION_UNRESOLVED' and liq['unresolved_labels']==['redemption'] and all('liquidation' in liq[a] for a in ['a','b']))
ck('72 source rows and75 original units',len(corpus['source_records'])==72 and len(corpus['units'])==75)
ck('all75 development',all(r['evaluation_role']=='development' for r in corpus['units']))
ck('zero verified deployments',sum(r['deployment']['status']=='verified' for r in corpus['units'])==0)
ck('11 version labels and64 unresolved',sum(r['version']['value'] is not None for r in corpus['units'])==11 and sum(r['version']['status']=='unresolved' for r in corpus['units'])==64)
# Exact literal rules and normative scenario/control inventory.
design=(PLAN/'design.md').read_text();rules=read(PLAN/'rules.json');ck('18 unique predicates',len(rules['rules'])==len({r['id'] for r in rules['rules']})==18)
for r in rules['rules']:
 row=f"| `{r['id']}` / {r['facet']} | {r['positive_evidence']} | {r['insufficient_alone']} |"
 ck(r['id']+' parsed and literal row equality',row==r['literal_markdown_row'] and design.splitlines().count(row)==1)
ck('all17 disputed labels plusliquidation haveexactrules',{r['id'] for r in rules['rules']}=={'R-'+x for r in actual for x in r['labels']}|{'R-liquidation'})
scenarios=[];requirements=[]
for p in sorted((PLAN/'specs').glob('*/spec.md')):
 for title,body in re.findall(r'^### Requirement: ([^\n]+)\n(.*?)(?=^### Requirement:|\Z)',p.read_text(),re.S|re.M):
  requirements.append((p.parent.name,title))
  for title,body in re.findall(r'^#### Scenario: ([^\n]+)\n(.*?)(?=^#### Scenario:|\Z)',body,re.S|re.M):
   scenarios.append({'id':title.split()[0],'path':str(p.relative_to(ROOT)),'block':('#### Scenario: '+title+'\n'+body).strip()})
ck('five capabilities20requirements65scenarios',len(list((PLAN/'specs').glob('*/spec.md')))==5 and len(requirements)==20 and len(scenarios)==65 and len({r['id'] for r in scenarios})==65)
sm=read(PLAN/'scenario-map.json');by={r['scenario_id']:r for r in sm['scenarios']}
for s in scenarios:
 r=by[s['id']];ck(s['id']+' exact normative block',r['normative_block']==s['block']);ck(s['id']+' exact spec hash',r['spec']==file_record(ROOT/s['path']));ck(s['id']+' planned only',r['status']=='planned_not_executed')
tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) (.+)$',(PLAN/'tasks.md').read_text(),re.M)
ck('28 unchecked tasks',len(tasks)==28 and all(x==' ' for x,_,_ in tasks))
ck('exact task map',[(r['id'],r['text'],r['checked']) for r in sm['tasks']]==[(tid,text,x=='x') for x,tid,text in tasks])
ci=read(PLAN/'control-inventory.json');cs=[c for f in ci['families'] for c in f['cases']]
ck('39families116unique planned cases',len(ci['families'])==39 and len(cs)==len({r['name'] for r in cs})==116)
for f in ci['families']:
 ck(f['family_id']+' positive and negative',any(c['expected_exit']==0 for c in f['cases']) and any(c['expected_exit']!=0 for c in f['cases']))
 ck(f['family_id']+' normative scenarios exist',all(s in by for s in f['scenarios']))
 ck(f['family_id']+' actual CLI planned',f['entry_point'].startswith('scripts/corpus_adjudicate.py ') and f['status']=='planned_no_execution')
 for c in f['cases']:ck(c['name']+' explicit outcome',c['expected_exit'] in [0,1,3] and bool(c['input']) and bool(c['expected_observation']))
for sid,r in by.items():ck(sid+' exact family mapping',r['planned_control_families']==[f['family_id'] for f in ci['families'] if sid in f['scenarios']])
covered={s for f in ci['families'] for s in f['scenarios']}
ck('all65 scenarios CLI or actual human evidence',covered|set(ci['independent_evidence_obligations'])==set(by))
for name,key in [('artifact-inventory.json','artifacts'),('context-files.json','files')]:
 for r in read(PLAN/name)[key]:ck(name+' exact '+r['path'],file_record(ROOT/r['path'])==r)
res=read(ROOT/'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r2-preparation/resolution.json');ck('all14 priorfindings mapped',len(res['findings'])==14 and {r['finding'] for r in res['findings']}==set(range(1,15)))
for r in res['findings']:ck('finding'+str(r['finding'])+' scenario/task references',all(s in by for s in r['scenarios']) and all(t in {tid for _,tid,_ in tasks} for t in r['tasks']))
# Additional local exposure record, explicitly outside the71 rendered inputs.
expath=ROOT/'review/semantic-kernel/evaluation-preparation/proposed-twelve-exposure/assessment.json';ex=read(expath)
ck('12 historical exposure records remain development',len(ex['cases'])==12 and all(r['conservative_eligibility']=='development_exposed_do_not_present_as_untouched' for r in ex['cases']))
result={'status':'PASS' if all(r['passed'] for r in checks) else 'FAIL','utc':datetime.now(timezone.utc).isoformat(),'candidate':m['candidate'],'actual_head':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'checks':checks,'check_count':len(checks),'actual_disagreements':actual,'additional_local_inputs':[file_record(expath)],'counts':{'inputs':71,'capabilities':5,'requirements':20,'scenarios':65,'tasks':28,'rules':18,'families':39,'planned_cases':116,'disputed_facets':29,'disputed_labels':32,'affected_units':24},'scope':'read-only independent static planning checks, not implementation/control execution/source adjudication'}
(OUT/'checks.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k] for k in ['status','check_count','actual_head','counts']}));sys.exit(0 if result['status']=='PASS' else 1)
