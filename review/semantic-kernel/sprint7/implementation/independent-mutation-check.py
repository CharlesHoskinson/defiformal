#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,re,subprocess,datetime
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/sprint7';O=B/'implementation'
OLD='6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c';FINAL='bea105ec72e633a2dd66c663b96d0b552e1814a8'; checks=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def js(p):return json.loads(p.read_text())
def check(label,ok):
 checks.append({'check':label,'passed':bool(ok)})
 if not ok:raise AssertionError(label)
def git(rev,p):return subprocess.check_output(['git','show',rev+':'+p],cwd=R)
manifest=js(B/'mutations/source-manifest.json');check('25 nonempty production closure inputs',len(manifest['sources'])==25)
for p,h in manifest['sources'].items():
 check('old/current/final closure '+p,git(OLD,p)==git(FINAL,p)==(R/p).read_bytes() and sha(R/p)==h)
check('source manifests unchanged',manifest['sources']==manifest['sources_after'] and manifest['git_head']==manifest['git_head_after']==OLD and manifest['input_sources_unchanged'] and manifest['specification_unchanged'] and manifest['runner_unchanged'])
for row in js(B/'mutations/driver-spec-git-bindings.json')['bindings']:
 p=row['path'];check('driver/spec preserved '+p,git(OLD,p)==git(FINAL,p)==(R/p).read_bytes() and sha(R/p)==row['sha256'])
res=js(B/'mutations/results.json');spec=js(B/'mutations/mutation-spec.json');control=(B/'mutations/control.lean').read_text()
check('14 exact mutants and control',len(spec['mutations'])==14 and set(res['results'])=={'control'}|{r['name'] for r in spec['mutations']})
controlnames=set(res['results']['control']['checks'])
for name,result in res['results'].items():
 log=(B/'mutations'/(name+'.log')).read_text();observed=re.findall(r'^(interleaving\.[a-z0-9_.-]+): (true|false)$',log,re.M);check(name+' 116 exact unique observations',len(observed)==len(dict(observed))==116 and dict(observed)==result['checks'] and set(dict(observed))==controlnames)
 check(name+' source hash',sha(B/'mutations'/(name+'.lean'))==result['fixture_sha256'])
 errors=[l for l in log.splitlines() if re.search(r': error(?:\([^)]*\))?:',l)]
 if name=='control':check('unchanged nonempty control executes all true',result['exit']==0 and not errors and all(v=='true' for _,v in observed));continue
 mutation=next(m for m in spec['mutations'] if m['name']==name)
 check(name+' exact actual unique source edit',control.count(mutation['needle'])==1 and (B/'mutations'/(name+'.lean')).read_text()==control.replace(mutation['needle'],mutation['replacement'],1) and mutation['needle']!=mutation['replacement'])
 check(name+' designated false protected true',result['exit']==1 and all(result['checks'][x]=='false' for x in mutation['required_false']) and all(result['checks'][x]=='true' for x in spec['positive_checks']))
 false=[n for n,v in observed if v=='false'];check(name+' no compiler-only credit',len(errors)==1 and errors[0].endswith('error: Interleaving runtime comparisons failed: '+str(len(false))) and set(false)==set(result['false_comparisons']))
for run in res['runs']:
 check('mutation command log '+run['label'],sha(B/'mutations'/(run['label']+'.log'))==run['log_sha256'])
runner=js(B/'runner-controls/summary.json');check('52 exact actual runner controls',len(runner['cases'])==len({r['name'] for r in runner['cases']})==runner['passed']==runner['total']==52)
for row in runner['cases']:
 path=B/'runner-controls'/Path(row['log']).name;check('runner '+row['name'],row['passed'] and row['actual_exit']==row['expected_exit'] and sha(path)==row['log_sha256'] and row['expected_message'] in path.read_text() and row['cli_output']==path.read_text())
count=0
for label in ['mutations','runner-controls']:
 inventory=js(B/label/'artifact-inventory.json');check(label+' nonempty unique artifact inventory',len(inventory)>0 and len({x['path'] for x in inventory})==len(inventory))
 for row in inventory:
  count+=1;p=B/label/row['path'];check(label+' artifact '+row['path'],p.is_file() and p.stat().st_size==row['bytes'] and sha(p)==row['sha256'])
check('629 exact artifact hashes',count==629)
bundle=js(B/'runner-controls/fixture-bundle-verification.json');check('fixture Git bundle binding',bundle['create_exit']==bundle['verify_exit']==0 and sha(B/'runner-controls/fixture-history.bundle')==bundle['sha256'])
check('no embedded Git repository',not list((B/'runner-controls').rglob('.git')))
summary={'executed_revision':OLD,'final_revision':FINAL,'all_passed':True,'assertion_count':len(checks),'checks':checks,'mutation_count':14,'comparisons_each':116,'runner_controls':52,'artifact_hashes':count,'runtime_source_closure_unchanged_files':25,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Independent saved-evidence/source/artifact reconciliation. No duplicate mutation or runner execution. Compile failures are runner rejection controls, not production semantic detections.'}
(O/'independent-mutation-check.json').write_text(json.dumps(summary,indent=2)+'\n');print('PASS',len(checks),'checks; 14 actual mutations, 52 runner controls, 629 artifacts, 25 unchanged closure inputs')
