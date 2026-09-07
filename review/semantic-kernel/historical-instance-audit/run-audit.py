import json,hashlib,subprocess,shutil,time,platform,os
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/charl/defiformal');O=R/'review/semantic-kernel/historical-instance-audit';now=lambda:datetime.now(timezone.utc).isoformat();h=lambda b:hashlib.sha256(b).hexdigest()
def write(p,v):
 with p.open('x') as f:json.dump(v,f,indent=2);f.write('\n')
def bind(p):
 b=p.read_bytes();return {'path':str(p.relative_to(R)),'sha256':h(b),'bytes':len(b)}
closure=[R/x for x in ['formal/v3/m5-convex.mjs','formal/v3/lib.mjs','formal/v2/tables.mjs','viz/src/data.ts','algebra/blind-test-set.json']]+sorted((R/'corpus50/lanes').iterdir());assert all(p.is_file() for p in closure)
context=[R/x for x in ['lean/Defialgebra/ConvexGeometry.lean','paper/atlas.tex','formal/v3/VERIFICATION.md']]
s10path=R/'review/semantic-kernel/sprint10/planning/r2-candidate.json';s10=json.loads(s10path.read_text());protected={x['path']:x['sha256'] for x in s10['inputs']}
for root in [R/'corpus/normalized',R/'corpus50']:
 for p in root.rglob('*'):
  if p.is_file():protected[str(p.relative_to(R))]=h(p.read_bytes())
for p in closure+context:protected[str(p.relative_to(R))]=h(p.read_bytes())
assert all(h((R/p).read_bytes())==v for p,v in protected.items())
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();sources=[]
for p in closure+context:
 rel=str(p.relative_to(R));b=p.read_bytes();gb=subprocess.check_output(['git','show',head+':'+rel],cwd=R);assert b==gb
 dest=O/'inputs'/rel;dest.parent.mkdir(parents=True,exist_ok=True)
 with dest.open('xb') as f:f.write(b)
 sources.append({**bind(p),'snapshot':str(dest.relative_to(R)),'role':'runtime_read_dependency' if p in closure else 'comparison_context','git_blob':subprocess.check_output(['git','rev-parse',head+':'+rel],cwd=R,text=True).strip()})
node=Path(shutil.which('node')).resolve();env={'PATH':'/usr/local/bin:/usr/bin:/bin','LC_ALL':'C','TZ':'UTC','DEFIFORMAL_ROOT':str(R)};command=[str(node),'formal/v3/m5-convex.mjs'];before={'created_utc':now(),'git_head':head,'sources':sources,'runtime_dependency_count':len(closure),'lane_directory_entries':[p.name for p in sorted((R/'corpus50/lanes').iterdir())],'s10_manifest':bind(s10path),'s10_frozen_candidate':s10['candidate'],'s10_input_count':len(s10['inputs']),'protected':protected,'tool':{'node_path':str(node),'node_sha256':h(node.read_bytes()),'node_version':subprocess.check_output([str(node),'--version'],text=True).strip(),'python_version':platform.python_version(),'platform':platform.platform()},'command':command,'cwd':str(R),'environment':env,'environment_scope':'Exact subprocess environment; no inherited NODE_OPTIONS or alternate DEFIFORMAL_ROOT','timeout_seconds':300,'side_effect_review':'m5/lib/tables only compute and log; tables reads listed corpus/data files at module load. No writes, subprocesses, network or dynamic imports found. Blind/lane files load eagerly although unused by m5 numerical computations.'};write(O/'before.json',before)
a=now();t=time.monotonic();status='completed'
with (O/'stdout.log').open('xb') as so,(O/'stderr.log').open('xb') as se:
 proc=subprocess.Popen(command,cwd=R,env=env,stdout=so,stderr=se)
 try:code=proc.wait(timeout=300)
 except subprocess.TimeoutExpired:
  proc.kill();code=proc.wait();status='timeout'
after={path:h((R/path).read_bytes()) for path in protected};unchanged=all(after[x]==y for x,y in protected.items());head_after=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
write(O/'execution.json',{'started_utc':a,'finished_utc':now(),'elapsed_seconds':time.monotonic()-t,'process_status':status,'returncode':code,'command':command,'cwd':str(R),'environment':env,'stdout':bind(O/'stdout.log'),'stderr':bind(O/'stderr.log'),'source_head_before':head,'source_head_after':head_after,'protected_after':after,'all_protected_unchanged':unchanged,'protected_count':len(protected),'s10_input_count':88,'exit_status_is_not_verdict':True});print(json.dumps({'status':status,'returncode':code,'seconds':time.monotonic()-t,'unchanged':unchanged}),flush=True)
