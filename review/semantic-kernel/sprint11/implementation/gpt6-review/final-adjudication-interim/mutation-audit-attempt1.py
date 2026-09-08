from pathlib import Path
import json,hashlib,subprocess,re,sys
R=Path.cwd();I=R/'review/semantic-kernel/sprint11/implementation';O=I/'gpt6-review/final-adjudication-interim';BASE=Path('/home/charl/.cache/defiformal-sprint11-mutations-94f70e5-r2');C='94f70e502c75132656bd0902a17be60ca45ab1c2';inputs={}
def sha(b):return hashlib.sha256(b).hexdigest()
def rd(p):
 p=Path(p);b=p.read_bytes();inputs[str(p)]={'sha256':sha(b),'bytes':len(b)};return b
def js(p):return json.loads(rd(p))
rd(__file__);plan=js(R/'openspec/changes/finite-participant-causal-composition/planned-mutations.json')['mutations'];assert len(plan)==16
expectedout=rd(I/'fixtures-r5/logs/eval-Audit.stdout');grammar=r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*';expected=dict(re.findall(rf'^({grammar}): (true|false)$',expectedout.decode(),re.M));assert len(expected)==310
runner=rd(R/'scripts/run_nary_mutations.py');runnerhash=sha(runner);assert runnerhash=='4528dde870fdb3e4c408e4646f70dcc5f8d31a84623e488103eee528a2e020be'
results=[];committed={};projected=None
for planned in plan:
 mid=planned['id'];d=BASE/mid;outer=js(I/f'verification-commands-r2/{mid}.json');assert outer['exit_code']==0 and not outer['timed_out'];assert outer['timeout_seconds']>0 and outer['duration_seconds']>=0
 for ext in ['stdout','stderr']:assert sha(rd(I/f'verification-commands-r2/{mid}.{ext}'))==outer[ext+'_sha256']
 assert rd(I/f'verification-commands-r2/{mid}.stdout').decode().strip().endswith('DISCRIMINATES: 1 mutants and one nonempty unchanged control')
 spec=js(d/'mutation-spec.json');assert rd(d/'mutation-spec.json')==rd(I/f'runner-r1/specs/{mid}.json')
 assert len(spec['mutations'])==1;mut=spec['mutations'][0];name=mut['name'];assert mut['needle']==planned['needle'] and mut['replacement']==planned['replacement'] and mut['required_false']==planned['required_false'] and spec['positive_checks']==[planned['expected_protected_check']]
 man=js(d/'source-manifest.json');run=js(d/'results.json');assert man['git_head']==man['git_head_after']==C and man['input_status']==''
 assert man['sources']==man['sources_after'] and man['script_sha256']==man['script_sha256_after']==runnerhash and man['spec_sha256']==man['spec_sha256_after']==sha(rd(d/'mutation-spec.json'))
 assert all(man[k] for k in ['input_sources_unchanged','specification_unchanged','runner_unchanged','git_head_unchanged'])
 for path,hashval in man['sources'].items():
  b=rd(d/'inputs'/path)
  if path not in committed:committed[path]=subprocess.check_output(['git','show',C+':'+path],cwd=R)
  assert b==committed[path] and sha(b)==hashval and rd(R/path)==b
  binding=man['git_input_bindings'][path];assert binding['sha256']==hashval and binding['identity_exit']==binding['blob_exit']==0
  assert hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()==binding['git_object']
 assert len(man['sources'])==28
 # Reconstruct exact inlined control from captured committed sources and ordered closure.
 imports=[];parts={}
 for module in man['projection_order']:
  text=committed['lean/'+module.replace('.','/')+'.lean'].decode();marker='\n-- BEGIN PROOFS\n'
  if marker in text and module.startswith('DefiKernel.Nary.'):
   text,tail=text.split(marker);end=re.search(r'\n(end DefiKernel\.Nary(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$',tail);assert end;text+='\n\n'+end[1]+'\n'
  lines=[]
  for line in text.splitlines():
   if line.startswith('import '):
    imp=line[7:].strip()
    if imp not in man['projection_order'] and line not in imports:assert not imp.startswith('DefiKernel.');imports.append(line)
   else:lines.append(line)
  parts[module]='\n'.join(lines)+'\n'
 control='\n'.join(imports)+'\n\n'+'\n'.join(parts[m] for m in man['projection_order']);assert control.encode()==rd(d/'control.lean')
 assert parts[mut['module']].count(mut['needle'])==1
 variant=dict(parts);variant[mut['module']]=variant[mut['module']].replace(mut['needle'],mut['replacement'],1)
 mutated='\n'.join(imports)+'\n\n'+'\n'.join(variant[m] for m in man['projection_order']);assert mutated.encode()==rd(d/(name+'.lean'))
 if projected is None:projected=control
 else:assert control==projected
 assert set(run['results'])=={'control',name};assert len(run['runs'])==6
 for rec in run['runs']:
  log=rd(d/(rec['label']+'.log'));assert sha(log)==rec['log_sha256'] and rec['elapsed_seconds']>=0 and rec['timeout_seconds']==man['timeout_seconds_per_command']
  if rec['label'] not in ['control',name]:assert rec['exit']==0
 for label in ['control',name]:
  log=rd(d/(label+'.log')).decode();raw=re.findall(rf'^({grammar}): (true|false)$',log,re.M);assert len(raw)==len(dict(raw))==310
  row=run['results'][label];checks=dict(raw);assert row['checks']==checks and checks.keys()==expected.keys()
  assert row['fixture_sha256']==sha(rd(d/(label+'.lean')))
  false=sorted(n for n,v in checks.items() if v=='false');assert false==row['false_comparisons']
  errors=[l for l in log.splitlines() if re.search(r': error(?:\([^)]*\))?:',l)]
  if label=='control':assert row['exit']==0 and not false and not errors and log.encode()==expectedout
  else:assert row['exit']!=0 and set(mut['required_false'])<=set(false) and len(errors)==1 and errors[0].endswith(f'error: Nary runtime comparisons failed: {len(false)}')
  assert all(checks[n]=='true' for n in spec['positive_checks'])
 results.append({'id':mid,'name':name,'outer_exit':outer['exit_code'],'outer_duration_seconds':outer['duration_seconds'],'outer_timeout_seconds':outer['timeout_seconds'],'source_count':len(man['sources']),'source_manifest_sha256':sha(rd(d/'source-manifest.json')),'results_sha256':sha(rd(d/'results.json')),'required_false':mut['required_false'],'protected_positive':spec['positive_checks'],'false_count':len(run['results'][name]['false_comparisons']),'all_false_names':run['results'][name]['false_comparisons'],'control_stdout_sha256':sha(rd(d/'control.log')),'mutant_stdout_stderr_combined_sha256':sha(rd(d/(name+'.log'))),'reconstructed_exact_source_projection_and_single_mutation':True,'accepted_detection':True})
assert len(results)==16
(O/'mutation-audit-results.json').write_text(json.dumps({'status':'ALL16_SEMANTIC_DETECTIONS_VERIFIED_ARCHIVE_BINDING_SEPARATE','candidate':C,'results':results,'inputs':inputs,'scope':'No new mutation or Lean execution; independently checked saved exact per-SPEC source/log evidence. Child stdout/stderr are combined by frozen runner.'},indent=2)+'\n');print(json.dumps({'mutants':len(results),'false_counts':{x['id']:x['false_count'] for x in results}},indent=2))
