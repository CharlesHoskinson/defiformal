from pathlib import Path
import subprocess,datetime,time,json,hashlib
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-amm-word-roundtrip-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64')
model=(r/'lean/DefiKernel/AMM/CheckedRoundTrip.lean').read_text();controls=(r/'lean/DefiKernel/AMM/CheckedRoundTripAudit.lean').read_text();marker='/-- The reverse retained-input reserve';tail='\n'.join(controls.splitlines()[1:]);runs=[]
def run(name,source,code,diagnostics):
 p=e/(name+'.lean');p.write_text(source);argv=[str(tc/'bin/lake'),'env','lean','-R',str(e),str(p)];t=time.monotonic();s=datetime.datetime.now(datetime.timezone.utc).isoformat();q=subprocess.run(argv,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);(e/(name+'.log')).write_bytes(q.stdout)
 assert q.returncode==code and all(d.encode() in q.stdout for d in diagnostics),(name,q.returncode,q.stdout[-500:])
 runs.append(dict(name=name,argv=argv,cwd=str(r/'lean'),started_utc=s,wall_seconds=time.monotonic()-t,exit=q.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.encode()).hexdigest(),log_sha256=hashlib.sha256(q.stdout).hexdigest()));print(name,q.returncode,flush=True)
def prefix(s):return s[:s.index(marker)]+'\nend DefiKernel.AMM.CheckedRoundTrip\n'+tail
run('intact-prefix',prefix(model),0,['WORD_ROUNDTRIP_CONTROL PASSED 9/9'])
for name,mutant in [('no-reserve-flip',model.replace('⟨pool.reserveY, pool.reserveX⟩','⟨pool.reserveX, pool.reserveY⟩',1)),('wrong-reverse-input',model.replace('let reverse ← swapPool (flip forward.post) forward.output fee','let reverse ← swapPool (flip forward.post) amount fee',1))]:
 assert mutant!=model
 run(name+'-runtime-prefix',prefix(mutant),1,['WORD_ROUNDTRIP_CONTROL zero_fee_floor_loss false','FAIL: Word roundtrip comparison'])
 run(name+'-full-proofs',mutant,1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',model_sha256=hashlib.sha256(model.encode()).hexdigest(),control_sha256=hashlib.sha256(controls.encode()).hexdigest(),runs=runs,scope='Actual altered roundTrip/flip API prefixes with intact Checked import; controls appended after removal of own-module import. Actual false runtime comparison is distinct from unchanged full-proof rejection.'),indent=2)+'\n')
