from pathlib import Path
import json,gzip,hashlib,datetime,shutil,subprocess
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p26-source-grok-r1';F=O/'original-terminal';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p26-source-grok-r1-sandbox');V=B/'p26-source-review-root-bindings-attempt2';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
V.mkdir(exist_ok=False);shutil.copy2(__file__,V/'verify.py')
seal=read(F/'root-seal.json')
for p,d in seal['files'].items():assert h(F/p)==d,p
inputs=read(F/'inputs.json')
for p,d in inputs['files'].items():assert h(S/p)==d,p
for stem in ['identity_probe','observation_extract']:
 c=read(F/f'raw/{stem}.command.json');assert c['exit']==0 and c['finished_utc']>=c['started_utc']
 for k in ['stdout','stderr']:assert h(F/f'raw/{stem}.{k}')==c[k+'_sha256']
 assert h(F/f'probes/{stem}.py')==c['script_sha256'];assert h(Path(c['python_executable']))==c['python_sha256']
d=read(F/'raw/identity_probe.stdout');assert d['passed'] and d['check_count']==len(d['checks'])==38 and not d['failures'] and all(x['passed'] for x in d['checks']);assert d['control']['altered_source_rejected'] and d['control']['source_file_unmodified']
e=read(F/'raw/observation_extract.stdout');assert e['excerpt_count']==len(e['excerpts'])==30 and e['failure_count']==0
prep=S/'review/semantic-kernel/program-execution-20260908/p26-ibc-source-preparation'
for row in e['excerpts']:
 lines=(prep/row['path']).read_text().splitlines()
 assert [x['text'] for x in row['lines']]==lines[row['start_line']-1:row['end_line']]
 assert [x['n'] for x in row['lines']]==list(range(row['start_line'],row['end_line']+1))
native=[json.loads(l) for l in gzip.open(F/'native.jsonl.gz','rt')];calls=[x for x in native if x.get('type')=='tool_call'];executions=[]
for c in calls:
 if c.get('toolName')=='run_terminal_command':
  final=[x for x in native if x.get('toolCallId')==c['toolCallId'] and x.get('status')=='completed'];assert len(final)==1
  executions.append({'call':c,'completed':final[0]})
put(V/'native-execution-events.json',executions)
assert any('run_identity_probe.py' in c['call']['rawInput']['command'] for c in executions)
assert any('run_observation_extract.py' in c['call']['rawInput']['command'] for c in executions)
pi=[c for c in executions if c['call']['rawInput']['command'].startswith('/usr/bin/python3.14 '+str(O/'probes/python_identity.py')+' && ')];assert len(pi)==1
piout=pi[0]['completed']['rawOutput'];assert piout['exit_code']==0
raw=bytes(piout['output']);assert json.loads(raw)==read(F/'raw/python_identity.command.json');(V/'python_identity.native.stdout').write_bytes(raw)
probe=F/'probes/identity_probe.py';argv=['/usr/bin/python3.14',str(probe)];start=now();run=subprocess.run(argv,cwd=S,capture_output=True,timeout=60);(V/'identity.stdout').write_bytes(run.stdout);(V/'identity.stderr').write_bytes(run.stderr);put(V/'command.json',{'argv':argv,'cwd':str(S),'started_utc':start,'finished_utc':now(),'exit':run.returncode,'script_sha256':h(probe),'python_sha256':h(Path(argv[0])),'stdout_sha256':h(V/'identity.stdout'),'stderr_sha256':h(V/'identity.stderr'),'actor':'root','scope':'Fresh root replay of read-only source identity probe; not Grok execution or Go runtime.'});assert run.returncode==0
replayed=json.loads(run.stdout)
for key in ['checks','failures','control','anchor_hits','check_count','failure_count','passed']:assert replayed[key]==d[key],key
keeper=prep/'source/modules/core/02-client/keeper/keeper.go';lines=keeper.read_text().splitlines();assert 'VerifyNonMembership' in lines[350] and 'status != exported.Active' in lines[356]
put(V/'nonmembership-source-supplement.json',{'path':str(keeper.relative_to(S)),'sha256':h(keeper),'lines':[{'line':i,'text':lines[i-1]} for i in range(351,362)],'finding':'The selected source also requires Active for VerifyNonMembership. This is root source reading, not reviewer execution. Packet NOOP/earlier guard paths require their own branch conditions.','proof_or_runtime':False})
result={'utc':now(),'frozen_input_bindings':len(inputs['files']),'original_sealed_bindings':len(seal['files']),'reviewer_identity_checks':38,'reviewer_source_excerpts':30,'reviewer_recorded_probes_with_raw_streams':2,'reviewer_tool_identity_command_native_stdout_verified':True,'native_tool_calls':len(calls),'native_shell_executions':len(executions),'root_replay_checks_match_reviewer':True,'source_execution':False,'P26_accepted':False,'P29_accepted':False};put(V/'result.json',result);put(V/'root-seal.json',{'files':{p.name:h(p) for p in V.iterdir() if p.is_file()},'acceptance':False});print(json.dumps(result))
