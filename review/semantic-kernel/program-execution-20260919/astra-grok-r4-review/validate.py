import json,pathlib,hashlib,importlib.util,re,tarfile
R=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r4');O=pathlib.Path(__file__).parent
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('runner',R/'scripts/run_certificate_fixtures.py'); runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
print('HOST REAL:',runner.verify_trusted_host(R,'lean/DefiKernel/Certificates/trusted-host-records.json'))
print('HOST MISSING ACCEPTED:',runner.verify_trusted_host(R,'missing-review-host.json'))
fix=json.loads((R/'openspec/changes/serialized-kernel-certificates/fixtures.json').read_text())['fixtures']
a=R/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r4'
fres=json.loads((a/'fixtures-full-r2/fixture-results.json').read_text())
assert len(fix)==len(fres['fixtures'])==54
for f,e in zip(fix,fres['fixtures']):
 assert f['id']==e['id']; assert runner.independent_expected(f)==e['expected'];assert e['actual']==e['expected'];assert e['exit_code']==0
print('FIXTURES 54 actuals equal independently recomputed expectations; codec successful:',[e['id'] for e in fres['fixtures'] if e['kind']=='codec' and e['actual']['result']['status']=='ok'])
for f in fix:
 if f['id'] in ['F13','F28','F53']: print(f['id'],'original',f['expected']['result']['status'],'new',runner.independent_expected(f)['result'])
mutants=[]
for i in range(1,17):
 p=R/f'root-supplement/mutants-all/M{i:02}';m=json.loads((p/'source-manifest.json').read_text());s=json.loads((p/'mutation-spec.json').read_text());res=json.loads((p/'results.json').read_text())
 assert h(p/'mutation-spec.json')==m['spec_sha256'];assert h(R/'scripts/run_certificate_mutations.py')==m['script_sha256']
 for rel,d in m['sources'].items(): assert h(R/rel)==h(p/'inputs'/rel)==d
 assert m['sources']==m['sources_after'];assert all(m[k] for k in ['input_sources_unchanged','specification_unchanged','runner_unchanged','git_head_unchanged'])
 for run in res['runs']: assert h(p/(run['label']+'.log'))==run['log_sha256']
 for label,result in res['results'].items():
  assert h(p/(label+'.lean'))==result['fixture_sha256']
  obs=dict(re.findall(r'^([a-z][a-z0-9_.-]*): (true|false)$',(p/(label+'.log')).read_text(),re.M));assert obs==result['checks']
  assert all(obs[x]=='true' for x in s['positive_checks'])
  if label=='control': assert result['exit']==0 and not result['false_comparisons']
  else:
   mm=next(x for x in s['mutations'] if x['name']==label); assert result['exit']==1; assert all(obs[x]=='false' for x in mm['required_false'])
   control=(p/'control.lean').read_text(); mutant=(p/(label+'.lean')).read_text();assert control.count(mm['needle'])==1;assert control.replace(mm['needle'],mm['replacement'],1)==mutant
 mutants.append({'id':f'M{i:02}','checks':len(res['results']['control']['checks']),'false':{k:v['false_comparisons'] for k,v in res['results'].items() if k!='control'}})
print('MUTANTS',json.dumps(mutants))
sc=json.loads((a/'fixtures-full-r2/scenario-results.json').read_text());assert len(sc['scenarios'])==99
print('SCENARIOS',json.dumps(sc['scenarios']))
for name in ['MANIFEST.json','source-manifest.json']:
 d=json.loads((a/name).read_text());print('MANIFEST SHAPE',name,list(d))
base=json.loads((O.parent/'grok-r4-start-baseline.json').read_text());print('BASELINE SHAPE',list(base))
(O/'validation-summary.json').write_text(json.dumps({'mutants':mutants,'fixtures':54,'codec_successes':0,'scenarios':99},indent=2))
