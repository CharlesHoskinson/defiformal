from pathlib import Path
import subprocess,datetime,time,hashlib,json
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-amm-author');tc=Path('/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64');model=(r/'lean/DefiKernel/AMM/Rational.lean').read_text();audit=(r/'lean/DefiKernel/AMM/RationalAudit.lean').read_text();prefix=model.split('-- BEGIN SPECIFICATION')[0]+'\nend DefiKernel.AMM.Rational\n';tail='\n'.join(audit.splitlines()[1:]);runs=[]
def run(name,source,code,diagnostics):
 path=e/(name+'.lean');path.write_text(source);argv=[str(tc/'bin/lake'),'env','lean',str(path)];start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();p=subprocess.run(argv,cwd=r/'lean',env={'PATH':str(tc/'bin')+':/usr/bin:/bin','HOME':str(Path.home())},stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(e/(name+'.log')).write_bytes(p.stdout);assert p.returncode==code,(name,p.returncode,p.stdout[-600:]);assert all(text.encode() in p.stdout for text in diagnostics),(name,p.stdout[-600:]);runs.append(dict(name=name,argv=argv,cwd=str(r/'lean'),started_utc=start,wall_seconds=time.monotonic()-tick,exit=p.returncode,source_sha256=hashlib.sha256(source.encode()).hexdigest(),required_diagnostics=diagnostics,output_sha256=hashlib.sha256(p.stdout).hexdigest()));print(name,p.returncode,flush=True)
run('intact-model-prefix',prefix+tail,0,['AMM_RATIONAL PASSED 16/16'])
mutations={
 'fee-removed':('⟨output, ⟨pool.reserveX + amount, pool.reserveY - output⟩⟩','⟨output, ⟨pool.reserveX + effectiveInput amount fee, pool.reserveY - output⟩⟩'),
 'wrong-denominator':('(pool.reserveX + effectiveInput amount fee)','pool.reserveX')}
for name,(old,new) in mutations.items():
 assert old in prefix
 mutated=prefix.replace(old,new,1)+tail
 run(name+'-runtime-prefix',mutated,1,['AMM_RATIONAL fee_retained_and_denominator false','FAIL: AMM rational comparison'])
 run(name+'-full-proofs',model.replace(old,new,1),1,['error:'])
(e/'mutations.json').write_text(json.dumps(dict(status='PASS',runs=runs,scope='Intact/mutant runtime programs extract the actual model-definition prefix and use the actual audit assertions; full model mutants retain unchanged generic proofs and are compiler-rejected. Neither successful prefix compilation nor finite controls are universal proofs.'),indent=2)+'\n')
print('PASS all',len(runs),'mutation commands')
