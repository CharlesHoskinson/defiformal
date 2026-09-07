#!/usr/bin/env python3
"""Execute exact pure source slices while the Reference import is still being proved."""
from pathlib import Path
import hashlib,json,subprocess,time,re
from datetime import datetime,timezone
R=Path(__file__).resolve().parents[5];D=Path(__file__).parent/'pure-development-r1';assert not D.exists();D.mkdir()
E=R/'lean/DefiKernel/Arithmetic/Examples.lean';T=R/'lean/DefiKernel/Arithmetic/Tests.lean'
e=E.read_text();t=T.read_text()
cut=e.index('def referenceCases :');prefix=e[:cut].replace('import DefiKernel.Arithmetic.Reference','import DefiKernel.Arithmetic.Fees\nimport DefiKernel.Arithmetic.Quantity\nimport DefiKernel.Typed.Transition')
checks=t[:t.index('def referenceObservationEq')].replace('import DefiKernel.Arithmetic.Examples\n','')
code=prefix+'\nend DefiKernel.Arithmetic.Examples\n'+checks+'''\n#eval do
  for (name, actual) in Examples.pureCases do
    let passed := match Examples.expectedPureCases.lookup name with
      | some expected => pureObservationEq actual expected
      | none => false
    IO.println s!"{name}: {passed}"
end DefiKernel.Arithmetic.Tests
'''
p=D/'PureDevelopment.lean';p.write_text(code)
start=datetime.now(timezone.utc).isoformat();tick=time.monotonic();x=subprocess.run(['lake','env','lean',str(p)],cwd=R/'lean',capture_output=True,timeout=600)
(D/'stdout.log').write_bytes(x.stdout);(D/'stderr.log').write_bytes(x.stderr)
obs=re.findall(r'^(arithmetic\.fixture\.f\d+): (true|false)$',x.stdout.decode(),re.M)
record={'scope':'Development execution of exact pure Examples/Tests source slices; all8 Reference calls omitted and pending, not the official45 Audit or mutation projection','command':['lake','env','lean',str(p)],'cwd':str(R/'lean'),'started_utc':start,'elapsed_seconds':time.monotonic()-tick,'exit':x.returncode,'observations':obs,'source_hashes':{str(q.relative_to(R)):hashlib.sha256(q.read_bytes()).hexdigest() for q in [E,T]},'slice_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'omitted_reference_ids':['F25','F26','F27','F28','F40','F41','F42','F43'],'passed':x.returncode==0 and len(obs)==37 and len(dict(obs))==37 and all(v=='true' for _,v in obs)}
(D/'verification.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record));print(x.stdout.decode() if x.returncode else '')
