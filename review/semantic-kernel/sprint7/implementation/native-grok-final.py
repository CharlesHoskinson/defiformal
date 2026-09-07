import subprocess,json,hashlib,datetime
from pathlib import Path
repo=Path('/home/charl/defiformal');out=repo/'review/semantic-kernel/sprint7/implementation';bundle=out/'evidence-review-bundle.md';data=bundle.read_bytes()
argv=['grok','--model','grok-4.6','--reasoning-effort','medium','--no-subagents','--disable-web-search','--tools','','--output-format','json','--prompt-file',str(bundle)]
meta={'provider':'grok','requested_model':'grok-4.6','argv':argv,'candidate':json.loads((out/'evidence-review-candidate.json').read_text())['candidate'],'bundle_sha256':hashlib.sha256(data).hexdigest(),'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'review_kind':'native final proof supplement and evidence review, no independent execution claimed; no Foreman'}
(out/'evidence-grok.invocation.json').write_text(json.dumps(meta,indent=2)+'\n')
try:
    p=subprocess.run(argv,cwd=repo,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1500)
    response=p.stdout;errors=p.stderr;meta['exit_code']=p.returncode
except subprocess.TimeoutExpired as e:
    response=e.stdout or b'';errors=e.stderr or b'';meta['exit_code']=None;meta['status']='timeout; no accepted verdict'
(out/'evidence-grok.json').write_bytes(response);(out/'evidence-grok.stderr').write_bytes(errors)
meta.update({'finished_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'response_sha256':hashlib.sha256(response).hexdigest(),'response_bytes':len(response)})
try:
    parsed=json.loads(response);meta['reported_models']=list(parsed.get('modelUsage',{}));meta['is_error']=parsed.get('is_error');print(parsed.get('text',parsed.get('result','No final report'))[:22000],flush=True)
except Exception: print('No parseable final JSON',flush=True)
(out/'evidence-grok.invocation.json').write_text(json.dumps(meta,indent=2)+'\n');print('native exit',meta['exit_code'],'reported models',meta.get('reported_models',[]),flush=True)
