#!/usr/bin/env python3
"""Read-only independent reconciliation of the frozen Sprint7 implementation evidence."""
from pathlib import Path
import hashlib,json,re,subprocess,datetime,collections
ROOT=Path('/home/charl/defiformal'); BASE=ROOT/'review/semantic-kernel/sprint7'; OUT=BASE/'implementation'
CANDIDATE='bea105ec72e633a2dd66c663b96d0b552e1814a8'
checks=[]; inputs={}; findings=[]; working_deltas=[]
def digest(raw):return hashlib.sha256(raw).hexdigest()
def read(path):
 p=ROOT/path if isinstance(path,str) else path;raw=p.read_bytes();inputs[str(p.relative_to(ROOT))]=digest(raw);return raw
def js(path):return json.loads(read(path))
def check(name,value):
 checks.append({'check':name,'passed':bool(value)})
 if not value:findings.append(name)
def gitbytes(rev,path):return subprocess.check_output(['git','show',rev+':'+path],cwd=ROOT)
def source(path,sha,rev=CANDIDATE):
 raw=read(path); frozen=gitbytes(rev,path);check('source '+path,digest(frozen)==sha)
 if raw!=frozen:working_deltas.append(path)

for rel in ['planning/r1-candidate.json','implementation/lean-review-candidate.json']:
 m=js(BASE/rel);bundle=read((BASE/rel).parent/m['bundle']);check(rel+' bundle identity',digest(bundle)==m['bundle_sha256'] and len(bundle)==m['bundle_bytes'])
 sections={a.decode():b for a,b in re.findall(rb'--- BEGIN FILE ([^\n]+) ---\n(.*?)\n--- END FILE \1 ---',bundle,re.S)}
 sections.update({a.decode():b for a,b in re.findall(rb'--- BEGIN EVIDENCE ([^\n]+) ---\n(.*?)\n--- END EVIDENCE ---',bundle,re.S)})
 check(rel+' exact embedded inventory',len(sections)==len(m['files']) and set(sections)=={f['path'] for f in m['files']})
 for f in m['files']:
  raw=sections[f['path']];check(rel+' embedded '+f['path'],digest(raw)==f['sha256'] and len(raw)==f['bytes'])
  if 'fresh parent execution' in f.get('binding',''):expected=read(f['path'])
  else:expected=gitbytes(m['candidate'],f['path'])
  check(rel+' frozen '+f['path'],raw==expected)
planning=js(BASE/'planning/r1-candidate.json')
for f in planning['files']:
 if '/specs/' in f['path'] or f['path'].endswith(('/proposal.md','/design.md')):source(f['path'],f['sha256'])

i=js(BASE/'integration-final/source-manifest.json');check('integration candidate',i['candidate']==CANDIDATE)
for p,h in i['files'].items():source(p,h)
runs=js(BASE/'integration-final/lean-runs.json');check('12 integration commands passed',len(runs['runs'])==12 and all(r['exit_code']==0 for r in runs['runs']))
for r in runs['runs']:check('integration log '+r['log'],digest(read(BASE/'integration-final'/r['log']))==r['log_sha256'])
runtime=read(BASE/'integration-final/01.log').decode();pairs=re.findall(r'^(interleaving\.[a-z0-9_.-]+): (true|false)$',runtime,re.M)
check('116 unique all true runtime comparisons',len(pairs)==len(dict(pairs))==116 and all(v=='true' for _,v in pairs))
proof=js(BASE/'proof-inventory.json');raw=read(BASE/'proof-types.log').decode();audit=read(BASE/'integration-final/02.log').decode()
for key,marker,n,pat in [('theorems','INTERLEAVING_PROOF_JSON ',262,r'AXIOM AUDIT theorem: ([^;]+);'),('supplemental','INTERLEAVING_SUPPLEMENTAL_JSON ',271,r'AXIOM AUDIT declaration: ([^;]+);')]:
 observed=[json.loads(l[len(marker):]) for l in raw.splitlines() if l.startswith(marker)]
 check(key+' exact count and distinct names',len(observed)==len({r['name'] for r in observed})==len(proof[key])==n)
 expected={r['name']:r for r in proof[key]}
 check(key+' exact elaborated statements and axioms',all(all(expected[r['name']][k]==v for k,v in r.items()) for r in observed))
 check(key+' exact Verify imported names',set(re.findall(pat,audit))==set(expected))
 check(key+' only standard axioms',all(set(r['axioms'])<={'propext','Classical.choice','Quot.sound'} for r in observed))
 for row in proof[key]:
  if row.get('declaration_origin')=='explicit' and key=='theorems':
   source_text=read(row['source']).decode();check('explicit source '+row['name'],row['source_statement'] in source_text and source_text.splitlines()[row['line']-1].startswith(('theorem ','lemma ')))
check('127 explicit theorem rows',sum(r['declaration_origin']=='explicit' for r in proof['theorems'])==127)
for p,b in proof['source_bindings'].items():source(p,b['sha256'])
execution=js(BASE/'proof-inventory-execution.json');check('inventory log and driver identities',execution['exit']==0 and digest(read(BASE/'proof-types.log'))==execution['log_sha256'] and digest(read(BASE/'proof-inventory-driver.lean'))==execution['driver_sha256'])

mapping=js(BASE/'scenario-map.json');check('map candidate',mapping['candidate']==CANDIDATE)
expected_scenarios=[]
for path,h in mapping['spec_sha256'].items():
 source(path,h);text=read(path).decode();requirement=None
 for number,line in enumerate(text.splitlines(),1):
  if line.startswith('### Requirement: '):requirement=line.removeprefix('### Requirement: ')
  if line.startswith('#### Scenario: '):expected_scenarios.append((path,requirement,line.removeprefix('#### Scenario: '),number))
actual=[(s['spec'],s['requirement'],s['scenario'],s['line']) for s in mapping['scenarios']]
check('43 exact normative scenarios',len(actual)==len(set(actual))==43 and set(actual)==set(expected_scenarios))
check('15 exact requirements',len({(p,r) for p,r,_,_ in actual})==15)
check('map runtime exact inventory',set(mapping['runtime_inventory'])==set(dict(pairs)) and len(mapping['runtime_inventory'])==116)
evidence={r['id']:r for r in mapping['evidence']};check('unique exact evidence records',len(evidence)==len(mapping['evidence'])==mapping['counts']['evidence_records'])
proofs={r['name']:r for r in proof['theorems']}
mutations=js(BASE/'mutations/results.json')['results'];mutation_spec=js(BASE/'mutation-spec.json')
runner_cases={r['name']:r for r in js(BASE/'runner-controls/summary.json')['cases']}
legacy_runs={r['label']:r for r in js(BASE/'regression-runs.json')['runs']}
for name in ['runInterleaving_admission_refusal','runPrefix_complete_active_exhaustion','runPrefix_complete_exhausted_or_refused']:
 check('explicit generic completion '+name,proofs['DefiKernel.Interleaving.'+name]['category']=='genericproof')

for row in mapping['evidence']:
 eid=row['id'];kind=row['class']
 if kind in ['genericproof','referenceinstance','counterexample','counterexample-corollary']:
  check(eid+' exact statement/category',row['name'] in proofs and row['statement']==proofs[row['name']]['statement'] and kind==proofs[row['name']]['category'])
 if kind=='boundedruntime' and 'name' in row:check(eid+' observed true',dict(pairs).get(row['name'])=='true')
 if kind=='semanticmutation':
  name=eid.split(':',1)[1];specrow=next(r for r in mutation_spec['mutations'] if r['name']==name)
  check(eid+' exact actual mutation evidence',row['required_false']==specrow['required_false'] and row['false_comparisons']==mutations[name]['false_comparisons'] and all(mutations[name]['checks'][k]==v=='true' for k,v in row['protected_checks'].items()))
 if kind=='runnercontrol':
  original=runner_cases[eid.split(':',1)[1]]
  check(eid+' exact actual CLI evidence',all(row[k]==original[k] for k in ['command','expected_exit','actual_exit','expected_message']))
 if kind=='regression':
  original=legacy_runs[eid.split(':',1)[1]]
  check(eid+' exact legacy command and exit',row['command']==original['command'] and row['exit']==original['exit'])
 for p,h in row.get('artifact_hashes',{}).items():check(eid+' artifact '+p,digest(read(p))==h)
 for p in row.get('artifacts',[]):check(eid+' artifact exists '+p,(ROOT/p).is_file())
 if 'source_line' in row:check(eid+' exact source line',read(row['source']).decode().splitlines()[row['line']-1]==row['source_line'])
for row in mapping['scenarios']:check(row['id']+' nonempty resolved evidence',bool(row['evidence']) and set(row['evidence'])<=set(evidence))
check('map leaves acceptance open',mapping['validation']['all_acceptance_gates_passed'] is False and mapping['validation']['all_tasks_complete'] is False)
for p,b in mapping['source_bindings'].items():source(p,b['sha256'])
gate=js(BASE/'planning/gate.json');check('same-candidate planning gate passed',gate['status']=='passed' and gate['candidate']==planning['candidate'] and gate['bundle_sha256']==planning['bundle_sha256'])
check('GPT6 planning report binding',digest(read(BASE/'planning'/gate['gpt6']['report']))==gate['gpt6']['report_sha256'])
check('Fable planning response binding',digest(read(BASE/'planning'/gate['fable']['response']))==gate['fable']['response_sha256'])
# Only hash the native report for binding; do not read its substantive findings here.
baseline=js(BASE/'planning/baseline/verification.json');check('planning baseline nonempty pass',baseline.get('all_passed') is True)
historical=subprocess.check_output(['git','diff','--name-status',planning['base'],CANDIDATE,'--','lean','scripts','corpus','corpus50'],cwd=ROOT,text=True).splitlines()
allowed=[]
for row in historical:
 status,path=row.split('\t',1)
 allowed.append((status=='A' and (path.startswith('lean/DefiKernel/Interleaving/') or path in ['scripts/check_interleaving_mutations.py','scripts/test_interleaving_mutation_runner.py'])) or (status=='M' and path=='lean/DefiKernel.lean'))
check('historical sources only declared root/additions changed',all(allowed))

legacy_binding=js(BASE/'regressions/source-binding.json');legacy_differences=[]
for path,oldhash in legacy_binding.items():
 old=gitbytes('6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c',path);new=gitbytes(CANDIDATE,path)
 check('old legacy capture '+path,digest(old)==oldhash['sha256'])
 if old!=new:legacy_differences.append(path)
check('one accurately disclosed legacy input change',legacy_differences==['lean/DefiKernel/Interleaving/Verify.lean'])
for label in ['typed-mutations','composition-mutations','parallel-mutations']:
 closure=js(BASE/'regressions'/label/'source-manifest.json')['sources']
 check(label+' unchanged actual legacy closure',bool(closure) and not set(closure).intersection(legacy_differences))
check('all source inputs stayed stable through independent check',all(digest((ROOT/path).read_bytes())==h for path,h in inputs.items()))
check('only authorized supplemental working source delta',not working_deltas)
summary={'authorized_working_source_deltas':sorted(set(working_deltas)),'candidate':CANDIDATE,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'all_passed':not findings,'assertion_count':len(checks),'checks':checks,'failed_checks':findings,'input_sha256':inputs,'historical_source_diff':historical,'scope':'Independent reconciliation of existing frozen evidence; not reexecution of parent Lean integration or native implementation audit. Source inspection and supplemental corollary compilation are separate actual checks.','scenario_snapshot_counts':mapping['counts'],'evidence_snapshot_limits':'Map is a preacceptance snapshot with pending regression/mutation/review/delivery gates; latest external completion must be integrated by parent.'}
(OUT/'independent-artifact-check.json').write_text(json.dumps(summary,indent=2)+'\n')
print('PASS' if not findings else 'FAIL',len(checks),'checks; failed',findings)
