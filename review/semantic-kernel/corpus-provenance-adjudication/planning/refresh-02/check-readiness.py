#!/usr/bin/env python3
"""Read-only provisional planning checks; writes only its unbound evidence directory."""
from pathlib import Path
import collections,datetime,hashlib,importlib.metadata,json,re,shutil,subprocess,sys,time
R=Path(__file__).resolve().parents[5]
E=Path(__file__).resolve().parent
P=R/'openspec/changes/corpus-provenance-adjudication'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):return json.loads(p.read_text())
def dump(name,d): (E/name).write_text(json.dumps(d,indent=2)+'\n')
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def git(*a):return subprocess.check_output(['git',*a],cwd=R,text=True).strip()
head=git('rev-parse','HEAD');before=load(E/'before.json');checks=[]
def check(label,ok):
 checks.append({'label':label,'passed':bool(ok)})
 if not ok:raise AssertionError(label)
cpath=R/'review/semantic-kernel/sprint10/planning/r2-candidate.json';candidate=load(cpath);bound={x['path']:x for x in candidate['inputs']}
check('evidence directory is unbound',not any(x.startswith(str(E.relative_to(R))+'/')for x in bound))
check('frozen candidate manifest unchanged',sha(cpath)==before['candidate_manifest_sha256'])
check('HEAD retained',head==before['head']==candidate['candidate'])
context=load(P/'context-files.json'); paths={x['path']for x in context['files']}
paths.update(str(x.relative_to(R))for x in P.rglob('*')if x.is_file())
paths.add('wiki-llm/corpus-provenance-adjudication.md')
paths.update(['review/semantic-kernel/sprint9/regressions/regression-runs.json','review/semantic-kernel/sprint9/regressions/source-binding.json','review/semantic-kernel/sprint9/regressions/verified-outcomes.json','review/semantic-kernel/sprint9/implementation/legacy-dependency-equivalence.json'])
for n in ['corpus-controls.log','corpus-controls.stdout.log','corpus-controls.stderr.log','corpus-controls-help.log']:paths.add('review/semantic-kernel/sprint9/regressions/'+n)
inputs=[]
for p in sorted(paths):
 f=R/p;check('input exists/'+p,f.is_file());blob=subprocess.run(['git','rev-parse',head+':'+p],cwd=R,capture_output=True,text=True)
 observed=git('hash-object',p)
 inputs.append({'path':p,'bytes':f.stat().st_size,'sha256':sha(f),'git_blob_at_head':blob.stdout.strip()if blob.returncode==0 else None,'worktree_blob':observed,'matches_head':blob.returncode==0 and observed==blob.stdout.strip(),'role':'normative_plan'if p.endswith('.md')and p.startswith(str(P.relative_to(R)))else 'context_or_retained_evidence'})
dump('inputs.json',{'head':head,'captured_utc':utc(),'inputs':inputs,'official_review_freeze':False})
# Count exact normative identities and reconcile the retained planning map.
sc=[];req=[]
for f in sorted((P/'specs').glob('*/spec.md')):
 current=None
 for line in f.read_text().splitlines():
  if line.startswith('### Requirement: '):current=line.removeprefix('### Requirement: ');req.append((f.parent.name,current))
  if line.startswith('#### Scenario: '):sc.append({'scenario_id':line.split(': ',1)[1].split()[0],'capability':f.parent.name,'requirement':current})
tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) ',(P/'tasks.md').read_text(),re.M); sm=load(P/'scenario-map.json')['scenarios']; ids={x['scenario_id']for x in sc}
check('5 capabilities /20 requirements /48 unique scenarios /28 unchecked tasks',len({x[0]for x in req})==5 and len(req)==20 and len(sc)==len(ids)==48 and len(tasks)==28 and all(s==' 'for s,_ in tasks))
check('all mapped scenario capability and requirement identities match', {(x['scenario_id'],x['capability'],x['requirement'])for x in sm}=={(x['scenario_id'],x['capability'],x['requirement'])for x in sc})
check('all mapped task references exist',all(set(x['task_ids'])<={t for _,t in tasks}for x in sm))
dump('scope.json',{'capabilities':5,'requirements':req,'scenarios':sm,'tasks':[t for _,t in tasks],'counts':{'requirements':len(req),'scenarios':len(sc),'tasks':len(tasks)},'status':'planned_no_implementation_evidence'})
# Independently check the exact baseline source closure, Git objects and original logs.
reg=R/'review/semantic-kernel/sprint9/regressions';runs=load(reg/'regression-runs.json');run=next(x for x in runs['runs']if x['label']=='corpus-controls'); equiv=load(R/'review/semantic-kernel/sprint9/implementation/legacy-dependency-equivalence.json');old=next(x for x in equiv['suites']if x['label']=='corpus-controls'); deps=[]
for p,v in old['source_closure'].items():
 oldbytes=subprocess.check_output(['git','show',run['head_at_start']+':'+p],cwd=R);newbytes=subprocess.check_output(['git','show',head+':'+p],cwd=R)
 ok=oldbytes==newbytes==(R/p).read_bytes() and sha(R/p)==v['original']['sha256'];check('regression dependency/'+p,ok);deps.append({'path':p,'sha256':sha(R/p),'old_git_blob':git('rev-parse',run['head_at_start']+':'+p),'current_git_blob':git('rev-parse',head+':'+p),'equal':ok})
for name,hashkey in [('stdout_log','stdout_sha256'),('stderr_log','stderr_sha256'),('log','log_sha256')]:check('retained log/'+run[name],sha(reg/run[name])==run[hashkey])
stdout=(reg/run['stdout_log']).read_text();stderr=(reg/run['stderr_log']).read_text();calls=re.findall(r'^test_[^\n]+: exit=(\d+):',stdout,re.M)
check('20 tests and76 actual CLI rows retained',len(calls)==76 and 'Ran 20 tests' in stderr and stderr.rstrip().endswith('OK')and run['exit']==0)
check('20 distinct executed test cases',len(set(re.findall(r'^(test_\w+) \(__main__',stderr,re.M)))==20)
check('retained Python executable unchanged',sha(Path(runs['tools']['python_executable']))==runs['tools']['python_executable_sha256'])
dump('baseline-reuse.json',{'status':'PASS_scoped_reuse_not_rerun','actual_run':run,'actual_execution_candidate':run['head_at_start'],'readiness_head':head,'dependencies':deps,'tests':20,'actual_cli_calls':len(calls),'cli_exit_counts':dict(collections.Counter(calls)),'python_from_original_run':{k:v for k,v in runs['tools'].items()if k.startswith('python')},'limits':['Synthetic fixture annotations; this run does not adjudicate real annotations or verify primary sources.','Historical installed transitive Python package bytes were not bound by that run. Current package identities below describe this readiness check only.','No corpus control rerun was performed; actual run identity remains c880acf.']})
# Fresh local tools and read-only commands.
tools={}
for name in ['python3','openspec','git']:
 p=Path(shutil.which(name)).resolve();tools[name]={'path':str(p),'sha256':sha(p)}
packages=[]
for name in ['jsonschema','jsonschema-specifications','referencing','rpds-py','attrs']:
 d=importlib.metadata.distribution(name);fs=[]
 for f in d.files or []:
  p=Path(d.locate_file(f))
  if p.is_file()and p.suffix not in ['.pyc']:fs.append({'path':str(p),'sha256':sha(p)})
 packages.append({'name':name,'version':d.version,'files':fs})
dump('tools.json',{'python_version':sys.version,'executables':tools,'current_python_packages':packages,'helper_sha256':sha(Path(__file__))})
protected=[x for x in inputs if x['path'].startswith(('corpus/','corpus50/'))or x['path'] in ['scripts/corpus_normalize.py','scripts/test_corpus_normalize.py','docs/research/2026-09-06-defi-source-plan.md']];stats={x['path']:(sha(R/x['path']),(R/x['path']).stat().st_mtime_ns)for x in protected}
commands=[('openspec-version',['openspec','--version']),('strict-validation',['openspec','validate','corpus-provenance-adjudication','--strict','--json','--no-interactive']),('normalization-check',['/usr/bin/python3','scripts/corpus_normalize.py','check','--repo','.'])];actual=[]
for label,argv in commands:
 start=utc();t=time.monotonic();p=subprocess.run(argv,cwd=R,capture_output=True,timeout=60);end=utc()
 (E/(label+'.stdout.log')).write_bytes(p.stdout);(E/(label+'.stderr.log')).write_bytes(p.stderr)
 actual.append({'label':label,'argv':argv,'cwd':str(R),'started_utc':start,'finished_utc':end,'elapsed_seconds':round(time.monotonic()-t,6),'exit':p.returncode,'stdout_sha256':sha(E/(label+'.stdout.log')),'stderr_sha256':sha(E/(label+'.stderr.log'))});check(label+' actual exit0',p.returncode==0)
dump('commands.json',actual)
check('protected corpus bytes and mtimes unchanged',all((sha(R/p),(R/p).stat().st_mtime_ns)==s for p,s in stats.items()))
inventory=load(P/'dispute-inventory.json'); actual=load(R/'corpus/normalized/generated/corpus.json')
for row in inventory['disagreements']:
 observed=next(a for a in actual['adjudications'] if a['unit_id']==row['unit_id'] and a['facet']==row['facet'])
 check('disputed facet actual/'+row['id'],observed['rule']=='INTERSECTION_UNRESOLVED')
challenge=inventory['separate_challenges'][0]; observation=actual['adjudications'][77]
check('CP01 exact facet rule',challenge['observation_rule']==observation['rule']=='INTERSECTION_UNRESOLVED')
check('CP01 shared liquidation label',challenge['label_membership_agreement'] and 'liquidation' in observation['a'] and 'liquidation' in observation['b'])
check('CP01 distinct redemption difference',observation['unresolved_labels']==['redemption'])
data=load(R/'corpus/normalized/generated/corpus.json');coverage=load(R/'corpus/normalized/generated/coverage.json');dis=[x for x in data['adjudications']if x['rule']=='INTERSECTION_UNRESOLVED'];facts={'rows':len(data['source_records']),'units':len(data['units']),'facet_decisions':len(data['adjudications']),'disputes':len(dis),'affected_units':len({x['unit_id']for x in dis}),'development_units':sum(x['evaluation_role']=='development'for x in data['units']),'verified_deployments':sum(x['deployment']['status']=='verified'for x in data['units']),'coverage':coverage,'originals_status':'62 citation occurrences/45 groups and2 attachments remain unresolved per preserved original inventory; no recovery/acquisition performed'}
check('actual corpus denominators72/75/375/29/24 and75development0verified', [facts[k]for k in ['rows','units','facet_decisions','disputes','affected_units','development_units','verified_deployments']]==[72,75,375,29,24,75,0]);dump('current-corpus-facts.json',facts)
for p in ['scripts/corpus_adjudicate.py','scripts/test_corpus_adjudication.py','scripts/corpus_adjudication','corpus/adjudicated/v1']:check('new implementation absent/'+p,not(R/p).exists())
for x in before['prior_plan']:
 if x['path']not in before['allowed_edits']:check('historical author artifact unchanged/'+x['path'],sha(R/x['path'])==x['sha256'])
for p,x in bound.items():check('frozen S10 input/'+p,sha(R/p)==x['sha256'])
check('HEAD unchanged at end',git('rev-parse','HEAD')==head)
dump('readiness-checks.json',{'status':'PROVISIONAL_AUTHOR_READINESS','head':head,'captured_utc':utc(),'check_count':len(checks),'all_passed':all(x['passed']for x in checks),'checks':checks,'frozen_S10_input_count':len(bound),'planning_review':'not_performed_for_this_package','future_reviewer_request':{'GPT':'nonauthor GPT-6 stock Codex harness','Fable':'claude-fable-5-1[1m]','effort':'medium','actual_returned_model':None},'development_failures':[{'operation':'readiness helper initially resolved one parent above repository','exit':1,'inner_git_exit':128,'resolution':'corrected root from parents[5] to parents[5]; initial helper saved; no result outputs existed'},{'operation':'initial read-only metadata inspection used unavailable python alias','exit':127,'resolution':'used python3; no verification claim from failed inspection'}]})
print('PASS provisional author readiness:',len(checks),'checks; scope5/20/48/28; reused20tests/76CLI at original c880acf; fresh normalization check; frozenS10',len(bound),'inputs unchanged.')
