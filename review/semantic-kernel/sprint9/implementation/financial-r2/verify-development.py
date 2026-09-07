#!/usr/bin/env python3
from pathlib import Path
import datetime,hashlib,json,re,subprocess,time
ROOT=Path(__file__).resolve().parents[5]
OUT=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
sources={str(p.relative_to(ROOT)):{'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size} for p in [ROOT/'lean/DefiKernel/Metatheory'/n for n in ['Examples.lean','Tests.lean','OperatorFixtures.lean']]}
runs=[]
for label,argv in [('build',['lake','build','DefiKernel.Metatheory.Tests']),('runtime',['lake','env','lean','DefiKernel/Metatheory/Audit.lean'])]:
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic()
 proc=subprocess.run(argv,cwd=ROOT/'lean',stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 for stream in ['stdout','stderr']:(OUT/(label+'.'+stream+'.log')).write_bytes(getattr(proc,stream))
 row={'argv':argv,'cwd':str(ROOT/'lean'),'started_utc':start,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-tick,'exit':proc.returncode,'stdout_sha256':sha(proc.stdout),'stderr_sha256':sha(proc.stderr)}
 (OUT/(label+'.json')).write_text(json.dumps(row,indent=2)+'\n');runs.append(row)
 if proc.returncode:raise RuntimeError(proc.stdout.decode()+proc.stderr.decode())
text=(OUT/'runtime.stdout.log').read_text();pairs=re.findall(r'^(metatheory\.[^:]+): (true|false)$',text,re.M)
old=json.loads((ROOT/'review/semantic-kernel/sprint9/implementation/financial/runtime-inventory-148.json').read_text())
assert len(pairs)==len(dict(pairs))==148 and all(v=='true' for _,v in pairs)
assert [n for n,_ in pairs]==old['runtime_inventory']
for path,binding in sources.items():assert sha((ROOT/path).read_bytes())==binding['sha256']
report={'schema_version':1,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'source_status':'Uncommitted successor development source; no frozen production claim','implementation_identity':'GPT-6 stock Codex harness; no provider telemetry inferred','lean_version':subprocess.check_output(['lake','env','lean','--version'],cwd=ROOT/'lean',text=True).strip(),'sources':sources,'runtime_inventory':[n for n,_ in pairs],'runtime_results':dict(pairs),'runs':runs,'preserved_old_inventory_sha256':sha((ROOT/'review/semantic-kernel/sprint9/implementation/financial/runtime-inventory-148.json').read_bytes()),'inventory_unchanged':True,'sources_unchanged_during_execution':True,'limitations':['Development execution only; official successor mutations and native acceptance remain separate.','Preserved first build failure used nonexistent Evaluated.declaredReads field; corrected to declaredStateReads before passing build.']}
(OUT/'runtime-inventory-148.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS 148/148; original ordered IDs preserved');print(json.dumps(sources,indent=2))
