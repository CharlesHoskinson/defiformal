from pathlib import Path
import json,hashlib,datetime,subprocess,gzip,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p27-source-grok-r1';F=O/'original-terminal';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox');V=B/'p27-source-review-root-bindings';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py');inputs=read(F/'inputs.json');original=read(F/'root-seal.json')
for p,d in inputs['files'].items():assert h(S/p)==d,p
for p,d in original['files'].items():
 assert h(F/p)==d,p
 if p!='native.jsonl.gz':assert h(O/p)==d,('parent changed',p)
process=read(F/'process.json');assert process['process_exit']==1 and process['reported_models']==['grok-4.6-build'];raw=gzip.decompress((F/'native.jsonl.gz').read_bytes());assert hashlib.sha256(raw).hexdigest()==process['log_sha256'];events=[json.loads(x) for x in raw.decode().splitlines() if x.startswith('{')];calls=[e for e in events if e.get('type')=='tool_call' and e.get('kind')=='execute'];assert len(calls)==3
pythoncall=[e for e in calls if e['rawInput']['command'].endswith('/probes/python_identity.py')];assert len(pythoncall)==1;updates=[e for e in events if e.get('type')=='tool_call_update' and e.get('toolCallId')==pythoncall[0]['toolCallId']];put(V/'python-identity-native-evidence.json',{'call':pythoncall[0],'updates':updates,'separate_raw_stdout_file_exists':False})
cmds=read(F/'commands.json')['commands'];assert len(cmds)==3
for row in cmds:
 meta=read(F/row['record']);assert meta['argv']==row.get('inner_argv',row['argv'])
 for k in ['cwd','started_utc','finished_utc','exit','script_sha256','python_sha256']:assert meta[k]==row[k],(row['name'],k)
 assert h(Path(row['python_executable']))==row['python_sha256'];assert h(F/'probes'/Path(row['script_path']).name)==row['script_sha256'];assert row['exit']==0
 if row['name']!='python_identity':
  for k in ['stdout','stderr']:assert h(F/row[k+'_path'])==row[k+'_sha256']==meta[k+'_sha256']
# Replay only read-only probe bodies; wrappers and python_identity write parent files and are not run.
records=[]
for name in ['identity_probe','observation_extract']:
 script=F/'probes'/(name+'.py');argv=['/usr/bin/python3.14',str(script)];start=now();p=subprocess.run(argv,cwd=S,capture_output=True,timeout=120);(V/(name+'.stdout')).write_bytes(p.stdout);(V/(name+'.stderr')).write_bytes(p.stderr);record={'actor':'root','argv':argv,'cwd':str(S),'started_utc':start,'finished_utc':now(),'exit':p.returncode,'python_sha256':h(Path(argv[0])),'script_sha256':h(script),'stdout_sha256':h(V/(name+'.stdout')),'stderr_sha256':h(V/(name+'.stderr'))};records.append(record);put(V/'commands.json',records);assert p.returncode==0
 actual=json.loads(p.stdout);prior=read(F/'raw'/(name+'.stdout'))
 for k in ['started_utc','finished_utc']:actual.pop(k);prior.pop(k)
 assert actual==prior,name
identity=read(V/'identity_probe.stdout');observations=read(V/'observation_extract.stdout');assert identity['check_count']==106 and not identity['failures'] and observations['excerpt_count']==12 and not observations['failures']
SRC=S/'review/semantic-kernel/program-execution-20260908/p27-gmx-source-preparation-attempt2'
for row in observations['excerpts']:
 p=SRC/row['path'];assert h(p)==row['sha256'];lines=p.read_text().splitlines();assert row['text']=='\n'.join(f'{i}|{lines[i-1]}' for i in range(row['start'],row['end']+1))
# A real binding predicate, applied to all intact inputs and altered bytes, supplies the root control.
manifest=read(SRC/'source-manifest.json')
def validate(data,row):
 assert len(data)==row['bytes'],'byte length mismatch'
 assert hashlib.sha256(data).hexdigest()==row['sha256'],'SHA256 mismatch'
 assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==row['git_blob_sha1'],'Git blob mismatch'
for row in manifest['files']:validate((SRC/row['path']).read_bytes(),row)
row=next(r for r in manifest['files'] if r['path']=='source/contracts/position/PositionUtils.sol');data=(SRC/row['path']).read_bytes();mutated=bytes([data[0]^1])+data[1:]
try:validate(mutated,row)
except AssertionError as e:reason=str(e)
else:raise AssertionError('Altered source accepted')
assert reason=='SHA256 mismatch';validate(data,row)
correction={'reviewer_control':'The reviewer altered-byte block raises ValueError on both branches after checking that bytes differ. It does not rerun the source binding validator. No gate-negative-test credit is assigned to that block.','root_control':'The same actual byte/sha256/git-blob validator accepted all89intact sources, rejected a same-length changed PositionUtils byte by SHA256 mismatch, then accepted the intact source again. No disk source writes.','root_intact_sources':len(manifest['files']),'root_altered_byte_rejected':True,'root_negative_failure':reason,'source_unchanged':h(SRC/row['path'])==row['sha256'],'excerpt_limit':'Reviewer needles search the whole source file; root separately verifies actual excerpt bytes. Excerpts do not establish runtime reachability.'};put(V/'control-correction.json',correction)
# Bind the actual healthy-liquidation refusal and full residual return, beyond excerpt cutoffs.
extra=[]
for rel,a,z in [('source/contracts/position/DecreasePositionUtils.sol',213,240),('source/contracts/position/DecreasePositionCollateralUtils.sol',635,667)]:
 p=SRC/rel;extra.append({'path':rel,'sha256':h(p),'start':a,'end':z,'text':'\n'.join(p.read_text().splitlines()[a-1:z])+'\n'})
put(V/'supplemental-source-excerpts.json',extra)
for p,d in inputs['files'].items():assert h(S/p)==d,p
for p,d in original['files'].items():assert h(F/p)==d,p
result={'utc':now(),'status':'original_review_evidence_root_verified_closeout_pending','frozen_input_bindings':len(inputs['files']),'original_terminal_files':len(original['files']),'native_shell_calls':3,'reviewer_probe_records':3,'separately_saved_reviewer_streams':4,'python_identity_native_evidence_preserved':True,'root_replayed_readonly_probes':2,'identity_assertions_replayed':106,'reviewer_altered_control_gate_credit':False,'root_actual_control_rejected':True,'source_excerpts_bound':12,'extra_source_excerpts':2,'source_candidate':'a85ea3491c19c93bb4b5a002d9b358fb769b7849','P27_accepted':False};put(V/'result.json',result);put(V/'root-seal.json',{'utc':now(),'files':{p.name:h(p) for p in V.iterdir() if p.is_file()},'acceptance':False});print(json.dumps(result))
