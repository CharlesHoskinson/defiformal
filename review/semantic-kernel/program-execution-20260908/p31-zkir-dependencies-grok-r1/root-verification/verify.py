from pathlib import Path
import json,hashlib,datetime,subprocess,sys,shutil
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');o=b/'p31-zkir-dependencies-grok-r1';c=o/'closeout';r=o/'root-verification'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
assert not (r/'assessment.json').exists()
for pid in [2134960,2149280]:assert not Path('/proc',str(pid)).exists()
m=read(c/'MANIFEST.json');assert len(m['files'])==m['file_count']==19
for n,digest in m['files'].items():assert h(c/n)==digest,n
inputs=read(o/'inputs.json');sandbox=Path(inputs['sandbox'])
for n,digest in inputs['files'].items():assert h(sandbox/n)==digest,n
process=read(o/'process.json');close=read(c/'process.json')
assert process['process_exit']==1 and close['process_exit']==0
assert process['sessions']==close['sessions']==['01a08cb3-a2c6-7432-9c84-cd973ca6efcd']
assert process['reported_models']==close['reported_models']==['grok-4.6-build']
for d,p in [(process,o),(close,c)]:assert h(p/'native.jsonl')==d['log_sha256']
cmds=read(c/'commands.json')['commands'];assert len(cmds)==2
for row in cmds:
 p=Path(row['argv'][1]);prefix=p.with_suffix('');run=read(Path(str(prefix)+'-run.json'))
 assert h(p)==row['probe_script_sha256']
 for kind in ['stdout','stderr']:
  q=Path(str(prefix)+'.'+kind);assert h(q)==row['raw_'+kind+'_sha256'];assert q.stat().st_size==row['raw_'+kind+'_bytes']
 for k in ['argv','cwd','started_utc','finished_utc','exit']:assert row[k]==run[k],(k,run)
 assert h(Path(row['argv'][0]))==row['python_executable_sha256']
source=c/'probes/binding-probe-corrected.py';text=source.read_text();old='OUT = REVIEW / "closeout/probes/binding-probe-corrected.json"';assert text.count(old)==1
runs=[]
for name,negative in [('corrected',False),('path-regression-control',True)]:
 script=r/(name+'-replay.py');output=r/(name+'-result.json');body=text.replace(old,'OUT = Path('+repr(str(output))+')')
 if negative:
  needle='extracted = extracted_root / rec["path"]';assert body.count(needle)==1;body=body.replace(needle,'extracted = packet / rec["path"]')
 script.write_text(body);argv=[str(Path(sys.executable).resolve()),str(script)];start=now()
 with (r/(name+'.stdout')).open('xb') as out,(r/(name+'.stderr')).open('xb') as err:q=subprocess.run(argv,cwd=sandbox,stdout=out,stderr=err)
 result=read(output);expected=1 if negative else 0;assert q.returncode==expected,(name,q.returncode)
 if negative:assert result['failed_assertions']==['midnight_members_match']
 else:
  assert not result['failed_assertions'] and all(result['asserted'].values())
  prior=read(c/'probes/binding-probe-corrected.json');actual=json.loads(json.dumps(result))
  for d in [prior,actual]:
   for k in ['started_utc','finished_utc','argv','probe_source_sha256','probe_source_bytes']:d.pop(k,None)
  assert prior==actual
 runs.append({'name':name,'argv':argv,'cwd':str(sandbox),'started_utc':start,'finished_utc':now(),'exit':q.returncode,'python_sha256':h(Path(argv[0])),'reviewer_probe_sha256':h(source),'root_probe_sha256':h(script),'output_sha256':h(output),'stdout_sha256':h(r/(name+'.stdout')),'stderr_sha256':h(r/(name+'.stderr')),'changes':['Output destination only']+(['Restore original faulty extracted-member path expression'] if negative else []),'failed_assertions':result['failed_assertions']})
assert read(r/'original-replay-receipt.json')['substantive_result_equal_reviewer']
assessment={'utc':now(),'inputs_verified':len(inputs['files']),'manifest_bindings_verified':len(m['files']),'reviewer_commands_verified':2,'reviewer_raw_streams_verified':4,'original_probe_false_flags_reproduced':True,'corrected_substantive_result_equal_reviewer':True,'corrected_assertions':len(result['asserted']),'path_regression_control_exit':1,'midnight_members_verified':464,'blst_members_verified':159,'navigation_sources':9,'navigation_anchors':14,'scope':'Locked source identity and static source navigation only','semantic_contract_accepted':False,'P31_accepted':False,'runs':runs}
put(r/'assessment.json',assessment);shutil.copy2(__file__,r/'verify.py');files={str(p.relative_to(r)):h(p) for p in r.iterdir() if p.is_file()};put(r/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({k:v for k,v in assessment.items() if k!='runs'}))
