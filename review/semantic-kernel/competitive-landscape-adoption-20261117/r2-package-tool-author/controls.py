from pathlib import Path
import subprocess,shutil,json,time,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-r2-package-author');original=Path('/private/tmp/defiformal-amm-r2-author/public-final');rows=[]
for name,want,diagnostic in [('missing-artifact',3,'BLOCKED:'),('empty-source',3,'BLOCKED: empty R2 replay input:'),('changed-source',1,'FAIL: generated R2 source differs from recipe: R2Replay'),('missing-log',3,'BLOCKED:'),('empty-denominator',3,'BLOCKED: empty R2 replay command inventory'),('unreadable-source',3,'BLOCKED:')]:
 d=e/('input-'+name);shutil.copytree(original,d)
 if name=='missing-artifact':(d/'R2Replay.olean').unlink()
 elif name=='empty-source':(d/'R2Replay.lean').write_bytes(b'')
 elif name=='changed-source':
  p=d/'R2Replay.lean';p.write_bytes(p.read_bytes()+b'\n-- changed generated source\n')
 elif name=='missing-log':(d/'audit.stdout').unlink()
 elif name=='empty-denominator':
  p=d/'result.json';data=json.loads(p.read_text());data['commands']=[];p.write_text(json.dumps(data))
 elif name=='unreadable-source':(d/'R2Replay.lean').chmod(0o200)
 a=['python3',str(r/'tools/compiled-evidence/build.py'),'--repo',str(r),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64','--r2-replay',str(d),'--output',str(e/('output-'+name)),'--archive',str(e/('output-'+name+'.tar.gz'))]
 t=time.monotonic();q=subprocess.run(a,cwd=r,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=120);log=q.stdout+q.stderr;(e/(name+'.log')).write_bytes(log);ok=q.returncode==want and diagnostic.encode() in log;rows.append(dict(name=name,argv=a,exit=q.returncode,expected_exit=want,required_diagnostic=diagnostic,pass_=ok,wall_seconds=time.monotonic()-t,log_sha256=hashlib.sha256(log).hexdigest()));print(name,q.returncode,ok,flush=True)
 if name=='unreadable-source':(d/'R2Replay.lean').chmod(0o644)
(e/'controls.json').write_text(json.dumps(dict(status='PASS' if len(rows)==6 and all(q['pass_'] for q in rows) else 'FAIL',controls=rows),indent=2)+'\n');assert len(rows)==6 and all(q['pass_'] for q in rows)
