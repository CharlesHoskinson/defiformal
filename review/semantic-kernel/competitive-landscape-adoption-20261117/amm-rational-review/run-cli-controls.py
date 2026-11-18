from pathlib import Path
import subprocess,datetime,time,hashlib,json,sys
r=Path('/private/tmp/defiformal-ci-baseline');e=Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal/review/semantic-kernel/competitive-landscape-adoption-20261117/amm-rational-review');audit=r/'lean/DefiKernel/AMM/RationalAudit.lean';model=r/'lean/DefiKernel/AMM/Rational.lean';audit_data=audit.read_bytes();model_data=model.read_bytes();argv=[sys.executable,str(r/'scripts/replay_amm_rational.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64'];runs=[]
def run(name,code,diagnostics):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();p=subprocess.run(argv,cwd='/private/tmp',stdout=subprocess.PIPE,stderr=subprocess.PIPE);(e/(name+'.stdout.log')).write_bytes(p.stdout);(e/(name+'.stderr.log')).write_bytes(p.stderr);assert p.returncode==code,(name,p.returncode,p.stdout[-500:],p.stderr[-500:]);assert all(text.encode() in p.stdout+p.stderr for text in diagnostics),(name,p.stdout[-500:],p.stderr[-500:]);runs.append(dict(name=name,argv=argv,cwd='/private/tmp',started_utc=start,wall_seconds=time.monotonic()-tick,exit=p.returncode,required_diagnostics=diagnostics,stdout_sha256=hashlib.sha256(p.stdout).hexdigest(),stderr_sha256=hashlib.sha256(p.stderr).hexdigest()));print(name,p.returncode,flush=True)
run('cli-intact',0,['AMM_RATIONAL PASSED 16/16','"assertions": 16'])
try:
 text=audit_data.decode();old=' (20/11) 12 (200/11)';assert text.count(old)==1;audit.write_text(text.replace(old,' (20/11) 11 (200/11)'));run('cli-wrong-expected',1,['AMM_RATIONAL fee_retained_and_denominator false','FAIL: AMM rational comparison','FAIL: native Lean replay exited 1'])
finally:audit.write_bytes(audit_data)
try:
 text=audit_data.decode();a=text.index('def checks : List (String × Bool) := [');b=text.index('\ndef runChecks',a);audit.write_text(text[:a]+'def checks : List (String × Bool) := []\n'+text[b:]);run('cli-empty-inventory',3,['BLOCKED: empty AMM rational inventory','BLOCKED: AMM rational assertion inventory missing or duplicated'])
finally:audit.write_bytes(audit_data)
mode=audit.stat().st_mode
try:
 audit.chmod(0o200);run('cli-unreadable',3,['BLOCKED:'])
finally:audit.chmod(mode)
try:
 text=model_data.decode();old='⟨output, ⟨pool.reserveX + amount, pool.reserveY - output⟩⟩';assert text.count(old)==1;model.write_text(text.replace(old,'⟨output, ⟨pool.reserveX + effectiveInput amount fee, pool.reserveY - output⟩⟩'));run('cli-altered-model-proof-rejected',1,['error:','FAIL: AMM rational library build exited 1'])
finally:model.write_bytes(model_data)
run('cli-restored-intact',0,['AMM_RATIONAL PASSED 16/16','"assertions": 16'])
assert model.read_bytes()==model_data and audit.read_bytes()==audit_data
(e/'cli-controls.json').write_text(json.dumps(dict(status='PASS',runs=runs,scope='Actual CLI builds the current Rational dependency before fresh source Audit execution. Changed expected-value failure, absent inventory and unreadability, and altered actual model generic-proof rejection remain distinct. All new-source mutations restored.'),indent=2)+'\n');print('PASS',len(runs),'actual CLI commands')
