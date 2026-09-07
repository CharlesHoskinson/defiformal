from pathlib import Path
import subprocess,json,hashlib,datetime,sys,shutil
repo=Path('/home/charl/defiformal');out=repo/'review/semantic-kernel/sprint8/final-review';provider=sys.argv[1];bundle=out/'bundle.md';data=bundle.read_bytes();manifest=json.loads((out/'candidate.json').read_text());candidate=manifest['candidate']
assert provider in ['opus','grok']
assert hashlib.sha256(data).hexdigest()==manifest['bundle_sha256']
assert all(hashlib.sha256((repo/x['path']).read_bytes()).hexdigest()==x['sha256'] for x in manifest['inputs'])
if provider=='opus':
 argv=['claude','--print','--model','opus','--effort','medium','--output-format','json','--tools','','--strict-mcp-config','--mcp-config','{"mcpServers":{}}','--setting-sources','','--disable-slash-commands','--no-session-persistence'];requested='opus'
else:
 argv=['grok','--model','grok-4.6','--reasoning-effort','medium','--no-subagents','--disable-web-search','--tools','','--output-format','json','--prompt-file',str(bundle)];requested='grok-4.6'
prefix=out/f'final-{provider}';meta={'provider':provider,'requested_model':requested,'argv':argv,'candidate':candidate,'bundle_sha256':hashlib.sha256(data).hexdigest(),'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'review_kind':'native revised-source and final evidence review; no independent execution claimed; no Foreman'}
cli_path=Path(shutil.which(argv[0])).resolve();version=subprocess.run([argv[0],'--version'],capture_output=True,text=True,timeout=30)
meta['cli_identity']={'path':str(cli_path),'sha256':hashlib.sha256(cli_path.read_bytes()).hexdigest(),'version_exit':version.returncode,'version_output':version.stdout+version.stderr}
def save():Path(str(prefix)+'.invocation.json').write_text(json.dumps(meta,indent=2)+'\n')
save()
try:
 p=subprocess.run(argv,cwd=repo,input=data if provider=='opus' else None,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1500);response=p.stdout;errors=p.stderr;meta['exit_code']=p.returncode
except subprocess.TimeoutExpired as e:response=e.stdout or b'';errors=e.stderr or b'';meta['exit_code']=None;meta['status']='timeout; no accepted verdict'
Path(str(prefix)+'.json').write_bytes(response);Path(str(prefix)+'.stderr').write_bytes(errors);meta.update(finished_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),response_sha256=hashlib.sha256(response).hexdigest(),response_bytes=len(response))
try:
 parsed=json.loads(response);meta['reported_models']=list(parsed.get('modelUsage',{}));meta['is_error']=parsed.get('is_error');final=parsed.get('result','') if provider=='opus' else parsed.get('text','');Path(str(prefix)+'.md').write_text(final+'\n');print(final[:24000],flush=True)
except Exception as e:meta['parse_error']=type(e).__name__;print('No parseable substantive final JSON',flush=True)
meta['bundle_unchanged']=hashlib.sha256(bundle.read_bytes()).hexdigest()==meta['bundle_sha256']
meta['inputs_unchanged']=all(hashlib.sha256((repo/x['path']).read_bytes()).hexdigest()==x['sha256'] for x in manifest['inputs'])
save();print('native exit',meta['exit_code'],'reported models',meta.get('reported_models',[]),flush=True)
