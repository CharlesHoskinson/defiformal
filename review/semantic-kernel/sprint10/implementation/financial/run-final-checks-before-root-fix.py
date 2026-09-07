#!/usr/bin/env python3
import datetime,hashlib,json,pathlib,re,subprocess,time
root=pathlib.Path(__file__).resolve().parents[6]
out=pathlib.Path(__file__).resolve().parent
sources={}
def capture(module):
 p='lean/'+module.replace('.','/')+'.lean'
 if p in sources:return
 path=root/p
 if not path.exists():return
 raw=path.read_bytes();sources[p]=hashlib.sha256(raw).hexdigest()
 for imported in re.findall(r'^import (\S+)$',raw.decode(),re.M):capture(imported)
for name in ['DefiKernel.Interface.Audit','DefiKernel.Interface.Fixtures','DefiKernel.AxiomAudit']:capture(name)
for p in ['lean/lean-toolchain','lean/lakefile.toml','lean/lake-manifest.json']:
 sources[p]=hashlib.sha256((root/p).read_bytes()).hexdigest()
records=[];before={'git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sources':sources};(out/'final-r2-before.json').write_text(json.dumps(before,indent=2)+'\n')
for label,cmd in [('build-final-r2',['lake','build','DefiKernel.Interface.Audit','DefiKernel.Interface.Fixtures']),('audit-final-r2',['lake','env','lean','DefiKernel/Interface/Audit.lean']),('proof-audit-final-r2',['lake','env','lean',str(out/'proof-audit.lean')])]:
 utc=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();run=subprocess.run(cmd,cwd=root/'lean',capture_output=True,text=True);raw=run.stdout+run.stderr;(out/(label+'.log')).write_text(raw);records.append(dict(label=label,command=cmd,cwd=str(root/'lean'),utc=utc,finished_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),elapsed_seconds=time.monotonic()-tick,exit=run.returncode,log_sha256=hashlib.sha256(raw.encode()).hexdigest()));(out/'targeted-runs-r2.json').write_text(json.dumps(records,indent=2)+'\n');print(label,run.returncode,flush=True)
 if run.returncode:break
after={p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in sources};summary=dict(git_head_after=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),source_count=len(sources),sources=after,sources_unchanged=after==sources,changed=[p for p in sources if sources[p]!=after[p]],runs=records,passed=all(r['exit']==0 for r in records) and len(records)==3 and after==sources);(out/'final-r2-validation.json').write_text(json.dumps(summary,indent=2)+'\n');print('final',summary['passed'],summary['changed']);raise SystemExit(0 if summary['passed'] else 1)
