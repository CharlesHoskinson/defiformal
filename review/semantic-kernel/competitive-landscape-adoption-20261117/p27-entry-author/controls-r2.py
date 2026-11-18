from pathlib import Path
import json,subprocess,shutil,hashlib,sys,time,datetime
packet=Path(__file__).resolve().parent;root=Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal');fixture=packet/'control-fixture-r2';repo=fixture/'repo';draft=fixture/'packet';draft.mkdir(parents=True)
bindings=json.loads((packet/'SOURCE-BINDINGS.json').read_text())
for path in list(bindings['sources'])+list(bindings['prior_preparation_records'])+[bindings['retained_terms']['path']]:
 p=repo/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((root/path).read_bytes())
for name in ['SOURCE-BINDINGS.json','OBSERVATIONS.json']:shutil.copy2(packet/name,draft/name)
shutil.copytree(packet/'excerpts',draft/'excerpts')
source=repo/next(iter(bindings['sources']));original=source.read_bytes();mode=source.stat().st_mode
obs=draft/'OBSERVATIONS.json';original_obs=obs.read_bytes();excerpt=draft/bindings['excerpts'][0]['excerpt'];original_excerpt=excerpt.read_bytes();rows=[]
a=[sys.executable,str(packet/'verify.py'),'--repo-root',str(repo),'--packet',str(draft)]
try:
 for name,want,diagnostic in [('intact',0,'"status": "PASS"'),('missing-source',3,'BLOCKED:'),('empty-source',3,'BLOCKED: empty input'),('unreadable-source',3,'BLOCKED:'),('changed-source',1,'FAIL: source hash mismatch'),('empty-excerpt',3,'BLOCKED: empty input'),('empty-observations',3,'BLOCKED: empty observation inventory'),('empty-denominator',3,'BLOCKED: empty/invalid funding denominator'),('changed-expected',1,'FAIL: payment worksheet contradiction')]:
  if source.exists():source.chmod(mode)
  source.write_bytes(original);source.chmod(mode);obs.write_bytes(original_obs);excerpt.write_bytes(original_excerpt)
  if name=='missing-source':source.unlink()
  elif name=='empty-source':source.write_bytes(b'')
  elif name=='unreadable-source':source.chmod(0o200)
  elif name=='changed-source':source.write_bytes(bytes([original[0]^1])+original[1:])
  elif name=='empty-excerpt':excerpt.write_bytes(b'')
  elif name in ['empty-observations','empty-denominator','changed-expected']:
   data=json.loads(original_obs)
   if name=='empty-observations':data['cases']=[]
   elif name=='empty-denominator':data['cases'][0]['input']['denominator']=0
   else:next(row for row in data['cases'] if row['id']=='zero_source_residual_does_not_discharge_exact_cost')['expected']['source_remainingCostUsd']=1
   obs.write_text(json.dumps(data))
  started=datetime.datetime.now(datetime.timezone.utc).isoformat();t=time.monotonic();q=subprocess.run(a,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=20);log=q.stdout+q.stderr;(packet/('control-r2-'+name+'.log')).write_bytes(log);passed=q.returncode==want and diagnostic.encode() in log;rows.append(dict(name=name,argv=a,started_utc=started,wall_seconds=time.monotonic()-t,exit=q.returncode,expected_exit=want,diagnostic=diagnostic,pass_=passed,log_sha256=hashlib.sha256(log).hexdigest()));print(name,q.returncode,passed,flush=True)
finally:
 if source.exists():source.chmod(mode)
 source.write_bytes(original);source.chmod(mode);obs.write_bytes(original_obs);excerpt.write_bytes(original_excerpt)
(packet/'controls-r2.json').write_text(json.dumps(dict(status='PASS' if len(rows)==9 and all(row['pass_'] for row in rows) else 'FAIL',checker_sha256=hashlib.sha256((packet/'verify.py').read_bytes()).hexdigest(),python=sys.version,python_executable=sys.executable,runs=rows,scope='Actual read-only entry checker CLI gates only; no Solidity/EVM/Lean execution or entry approval'),indent=2)+'\n');assert len(rows)==9 and all(row['pass_'] for row in rows)
