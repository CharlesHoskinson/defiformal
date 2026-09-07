import subprocess,json,hashlib,datetime
from pathlib import Path
repo=Path('/home/charl/defiformal');out=repo/'review/semantic-kernel/sprint7/implementation';bundle=out/'evidence-fable-final-bundle.md';data=bundle.read_bytes()
argv=['claude','--print','--model','claude-fable-5-1[1m]','--effort','medium','--output-format','json','--tools','','--strict-mcp-config','--mcp-config','{"mcpServers":{}}','--setting-sources','','--disable-slash-commands','--no-session-persistence']
meta={'provider':'fable','requested_model':'claude-fable-5-1[1m]','argv':argv,'candidate':json.loads((out/'evidence-fable-final-candidate.json').read_text())['candidate'],'bundle_sha256':hashlib.sha256(data).hexdigest(),'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'review_kind':'native final proof supplement and evidence review, no independent execution claimed; no Foreman'}
(out/'evidence-fable.invocation.json').write_text(json.dumps(meta,indent=2)+'\n')
try:
    p=subprocess.run(argv,cwd=repo,input=data,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1500)
    response=p.stdout;errors=p.stderr;meta['exit_code']=p.returncode
except subprocess.TimeoutExpired as e:
    response=e.stdout or b'';errors=e.stderr or b'';meta['exit_code']=None;meta['status']='timeout; no accepted verdict'
(out/'evidence-fable.json').write_bytes(response);(out/'evidence-fable.stderr').write_bytes(errors)
meta.update({'finished_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'response_sha256':hashlib.sha256(response).hexdigest(),'response_bytes':len(response)})
try:
    parsed=json.loads(response);meta['reported_models']=list(parsed.get('modelUsage',{}));meta['is_error']=parsed.get('is_error');print(parsed.get('result','No final report')[:18000],flush=True)
except Exception: print('No parseable final JSON',flush=True)
(out/'evidence-fable.invocation.json').write_text(json.dumps(meta,indent=2)+'\n');print('native exit',meta['exit_code'],'reported models',meta.get('reported_models',[]),flush=True)
