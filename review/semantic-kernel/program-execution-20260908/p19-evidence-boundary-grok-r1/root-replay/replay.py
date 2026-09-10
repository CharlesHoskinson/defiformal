from pathlib import Path
import json,hashlib,subprocess,datetime,os
p=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-evidence-boundary-grok-r1');out=p/'root-replay';out.mkdir(exist_ok=False)
h=lambda q:hashlib.sha256(q.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
commands=json.loads((p/'commands.json').read_text())['commands'];wanted=['check/neutral_in.json','check/F43_in.json','decode/F13_in.dat','decode/neutral_in.dat','audit/claimed_one_without_compiler','audit/F46_prod'];results=[]
env=os.environ.copy();env['ELAN_TOOLCHAIN']='leanprover/lean4:v4.33.0-rc2';env['PATH']='/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin:'+env['PATH']
for name in wanted:
 c=next(c for c in commands if c['id']==name);start=now();r=subprocess.run(c['argv'],cwd=c['cwd'],env=env,capture_output=True,timeout=180);stem=name.replace('/','--');so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(r.stdout);se.write_bytes(r.stderr)
 result={'id':name,'argv':c['argv'],'cwd':c['cwd'],'started_utc':start,'finished_utc':now(),'exit':r.returncode,'stdout_sha256':h(so),'stderr_sha256':h(se),'matches_grok_stdout':h(so)==c['stdout_sha256'],'matches_grok_stderr':h(se)==c['stderr_sha256']};results.append(result);(out/'commands.json').write_text(json.dumps(results,indent=2)+'\n');print(json.dumps(result),flush=True)
assert all(r['exit']==0 and r['matches_grok_stdout'] and r['matches_grok_stderr'] for r in results)
m=json.loads((p/'MANIFEST.json').read_text());inp=json.loads((p/'inputs.json').read_text());s=Path(inp['sandbox'])
for n,v in inp['files'].items():assert h(s/n)==v,n
for f in m['files']:assert h(p/f['path'])==f['sha256'],f['path']
rec={'schema':'defiformal-root-evidence-boundary-replay/v1','utc':now(),'exit':0,'probes':len(results),'matches_grok_outputs':True,'frozen_inputs_verified':len(inp['files']),'reviewer_files_verified':len(m['files']),'scope':'Six bounded actual RunFixtures probes. Filename-dependent check/decoded-label output and audit claimed-one/claimed-zero behavior. No full P19 acceptance or universal proof.','acceptance':False};(out/'process.json').write_text(json.dumps(rec,indent=2)+'\n');print(json.dumps(rec),flush=True)
