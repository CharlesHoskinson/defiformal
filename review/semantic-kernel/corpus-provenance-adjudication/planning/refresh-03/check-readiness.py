"""Author-only refresh03: snapshot reconciliation and fresh read-only planning checks."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,re,shutil,subprocess,sys,time
R=Path(__file__).resolve().parents[5];E=Path(__file__).resolve().parent;P=R/'openspec/changes/corpus-provenance-adjudication'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):return json.loads(p.read_text())
def bind(p):return {'path':str(p.relative_to(R)),'sha256':h(p),'bytes':p.stat().st_size}
def write(n,v):
 with (E/n).open('x') as f:json.dump(v,f,indent=2);f.write('\n')
def utc():return datetime.now(timezone.utc).isoformat()
checks=[]
def check(n,v):
 checks.append({'name':n,'pass':bool(v)})
 if not v:raise AssertionError(n)
before=load(E/'before.json');head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();check('HEAD unchanged before refresh validation',head==before['head'])
allowed={str(p.relative_to(R)) for p in P.rglob('*.md')}|{'wiki-llm/corpus-provenance-adjudication.md','wiki-llm/corpus-provenance-planning-draft.md'}
for row in before['prior_plan']:
 p=R/row['path'];snapshot=E/'before'/row['path'];check('before-snapshot:'+row['path'],h(snapshot)==row['sha256'])
 if row['path'] not in allowed:check('prior-author-artifact-immutable:'+row['path'],h(p)==row['sha256'])
for p,v in before['protected'].items():check('protected-before:'+p,h(R/p)==v)
candidate_path=R/'review/semantic-kernel/sprint10/planning/r2-candidate.json';candidate=load(candidate_path)
check('S10 manifest unchanged',h(candidate_path)==before['candidate_manifest_sha256'])
check('S10 frozen input count88',len(candidate['inputs'])==88)
for row in candidate['inputs']:check('S10 frozen:'+row['path'],h(R/row['path'])==row['sha256'])
# Scope identities and task mapping, without replacing older author maps.
sc=[];requirements=[];specs=[]
for p in sorted((P/'specs').glob('*/spec.md')):
 specs.append(bind(p));current=None
 for line in p.read_text().splitlines():
  if line.startswith('### Requirement: '):current=line[17:];requirements.append((p.parent.name,current))
  if line.startswith('#### Scenario: '):sc.append({'scenario_id':line.split(': ',1)[1].split()[0],'capability':p.parent.name,'requirement':current,'spec':bind(p)})
tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) ',(P/'tasks.md').read_text(),re.M)
check('5/20/48/28 unchanged unchecked scope',len(specs)==5 and len(requirements)==20 and len(sc)==len({x['scenario_id']for x in sc})==48 and len(tasks)==28 and all(x==' 'for x,_ in tasks))
oldmap=load(P/'scenario-map.json')['scenarios'];check('same scenario identities', {(x['scenario_id'],x['capability'],x['requirement'])for x in oldmap}=={(x['scenario_id'],x['capability'],x['requirement'])for x in sc})
for item in sc:item['task_ids']=next(x['task_ids']for x in oldmap if x['scenario_id']==item['scenario_id']);check('task references:'+item['scenario_id'],set(item['task_ids'])<={n for _,n in tasks})
write('scenario-map.json',{'status':'author_planned_no_implementation_or_review_pass','scenarios':sc,'counts':{'capabilities':5,'requirements':20,'scenarios':48,'tasks':28},'tasks':[n for _,n in tasks]})
inv=load(P/'dispute-inventory.json');actual=load(R/'corpus/normalized/generated/corpus.json');expected={(r['id'],label)for r in inv['disagreements']for label in r['disputed_labels']}
check('29 facets32 label instances24units',len(inv['disagreements'])==29 and len(expected)==32 and len({r['unit_id']for r in inv['disagreements']})==24)
check('Liquity actual facet not AGREE',actual['adjudications'][77]['rule']=='INTERSECTION_UNRESOLVED' and actual['adjudications'][77]['unresolved_labels']==['redemption'] and 'liquidation' in actual['adjudications'][77]['a'] and 'liquidation' in actual['adjudications'][77]['b'])
check('task5.1 exact rule', 'retained AGREE versus' not in (P/'tasks.md').read_text() and 'INTERSECTION_UNRESOLVED' in (P/'tasks.md').read_text())
oldrules=[l for l in (E/'before'/P.relative_to(R)/'design.md').read_text().splitlines()if l.startswith('| `R-')];newrules=[l for l in (P/'design.md').read_text().splitlines()if l.startswith('| `R-')];check('18 literal proposed rule rows unchanged',oldrules==newrules and len(newrules)==18)
# Inspect every actual unaccepted source proposal, not its old URL-only lead.
research=R/'review/semantic-kernel/corpus-provenance-adjudication/source-research';entries=[];covered=set();challenge=[]
for p in sorted(research.glob('*/proposed-adjudication.json')):
 d=load(p);check('draft source packet:'+p.parent.name,d['process_status']=='draft_review_pending')
 if d.get('challenge_id'):
  challenge.append({'challenge_id':d['challenge_id'],'packet':bind(p)});continue
 claims=d.get('dispositions')
 if claims is None:
  claims=[x for x in d.get('claims',[])if 'dispute_id' in x and 'label' in x]
  if not claims:claims=[{'dispute_id':d['dispute_id'],'label':d.get('label',d.get('disputed_label')),'proposed_disposition':d.get('proposed_disposition',d.get('scoped_source_reading'))}]
 for c in claims:
  did=c.get('dispute_id',d.get('dispute_id'));key=(did,c['label']);check('source claim belongs to inventory:'+str(key),key in expected);check('source claim unique:'+str(key),key not in covered);covered.add(key)
  check('no accepted disposition:'+str(key),c.get('accepted_disposition') is None and d.get('accepted_disposition') is None)
  entries.append({'dispute_id':did,'label':c['label'],'proposed_disposition':c.get('proposed_disposition'),'accepted':False,'packet':bind(p),'unit_id':d['unit_id']})
check('complete draft source inventory29/32',covered==expected)
check('one separate unaccepted Liquity challenge',len(challenge)==1 and challenge[0]['challenge_id']=='SPRINT3-LIQUITY-V1-LIQUIDATION')
write('research-input-inventory.json',{'status':'available_unaccepted_source_inputs_not_collector_runs','facet_disagreements':29,'disputed_label_instances':32,'claims':entries,'separate_challenge':challenge,'rule_rows_unchanged':newrules,'limits':'Nominal claim coverage only; no author refresh independently re-adjudicates source propositions. Research packet snapshots and actual failures/limits remain immutable.'})
exposure_path=R/'review/semantic-kernel/evaluation-preparation/proposed-twelve-exposure/assessment.json';exposure=load(exposure_path)
check('all12 proposed cases exposed none untouched',len(exposure['cases'])==12 and all(x['conservative_eligibility']=='development_exposed_do_not_present_as_untouched' and not x['untouched_certified'] and x['proposed_replacement'] is None for x in exposure['cases']))
delivery_path=R/'review/semantic-kernel/sprint9/archive-delivery.json';delivery=load(delivery_path)
check('accepted S9 exact archive delivery',delivery['source_candidate']=='eec499d613688137a341f3556cd80ca461dd2ee9' and delivery['archive_commit']==delivery['remote_head']=='9908d9b56be2d5ed2b58a16fa8d28b23f33733ff' and delivery['remote_matches'])
for p in ['scripts/corpus_adjudicate.py','scripts/test_corpus_adjudication.py','scripts/corpus_adjudication','corpus/adjudicated/v1','lean/DefiKernel/Interface']:check('implementation remains absent:'+p,not(R/p).exists())
commands=[]
for label,argv in [('strict-validation',['openspec','validate','corpus-provenance-adjudication','--strict','--json','--no-interactive']),('normalization-check',['/usr/bin/python3','scripts/corpus_normalize.py','check','--repo','.'])]:
 start=utc();t=time.monotonic();r=subprocess.run(argv,cwd=R,capture_output=True,timeout=60);end=utc()
 (E/(label+'.stdout.log')).write_bytes(r.stdout);(E/(label+'.stderr.log')).write_bytes(r.stderr)
 commands.append({'label':label,'argv':argv,'cwd':str(R),'started_utc':start,'finished_utc':end,'elapsed_seconds':time.monotonic()-t,'exit':r.returncode,'stdout':bind(E/(label+'.stdout.log')),'stderr':bind(E/(label+'.stderr.log'))});check('actual exit0:'+label,r.returncode==0)
write('commands.json',commands)
tools={}
for name in ['python3','openspec','git']:
 p=Path(shutil.which(name)).resolve();tools[name]={'path':str(p),'sha256':h(p)}
write('tools.json',{'executables':tools,'python_version':sys.version,'author_helper':bind(Path(__file__)),'native_review_calls':0})
# Current context is distinct from immutable prior author context manifests.
contextpaths={R/r['path'] for r in load(P/'context-files.json')['files']};contextpaths|={P/'proposal.md',P/'design.md',P/'tasks.md',delivery_path,candidate_path,exposure_path};contextpaths|={R/x['packet']['path']for x in entries+challenge};contextpaths|={R/r['path']for r in specs}
for p in [R/'wiki-llm/corpus-provenance-adjudication.md',R/'wiki-llm/corpus-provenance-planning-draft.md']:contextpaths.add(p)
write('context-files.json',{'captured_utc':utc(),'head':head,'official_review_frozen':False,'files':[bind(p) for p in sorted(contextpaths)],'historical_context_manifest':bind(P/'context-files.json'),'limits':'Roadmap/progress are live informational context; parent must freeze exact candidate again. Prior author context is not overwritten.'})
deltas=[]
for row in before['prior_plan']:
 if h(R/row['path'])!=row['sha256']:check('change within authorized docs/wiki:'+row['path'],row['path']in allowed);deltas.append({'before':row,'after':bind(R/row['path'])})
for p,v in before['protected'].items():check('protected-after:'+p,h(R/p)==v)
check('HEAD unchanged after',subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()==head)
write('readiness-checks.json',{'status':'AUTHOR_REVIEW_READY_DRAFT_NOT_GATE_ACCEPTANCE','created_utc':utc(),'head':head,'checks':checks,'check_count':len(checks),'all_passed':True,'deltas':deltas,'protected_files':len(before['protected']),'s10_frozen_inputs':88,'planning_review':'not_performed','implementation_started':False,'scope':{'capabilities':5,'requirements':20,'scenarios':48,'unchecked_tasks':28},'author_identity':'Stock GPT-6 original normative author; requested identity, actual model telemetry unavailable','independence':'This author is ineligible for the nonauthor GPT-6 planning gate review.'})
print(json.dumps({'all_passed':True,'checks':len(checks),'changed_docs':len(deltas),'protected_files':len(before['protected']),'scope':[5,20,48,28],'source_claims':len(entries)},indent=2))
