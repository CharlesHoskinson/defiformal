from pathlib import Path
import subprocess,datetime,time,hashlib,json,sys
r=Path('/private/tmp/defiformal-ci-baseline');e=Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal/review/semantic-kernel/competitive-landscape-adoption-20261117/amm-word-delivery-review');source=r/'lean/DefiKernel/AMM/CheckedAudit.lean';original=source.read_bytes();runs=[];argv=[sys.executable,str(r/'scripts/replay_amm_checked.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64']
def run(name,code,diagnostics):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();p=subprocess.run(argv,cwd='/private/tmp',stdout=subprocess.PIPE,stderr=subprocess.PIPE);(e/(name+'.stdout.log')).write_bytes(p.stdout);(e/(name+'.stderr.log')).write_bytes(p.stderr);assert p.returncode==code,(name,p.returncode,p.stdout[-500:],p.stderr[-500:]);assert all(text.encode() in p.stdout+p.stderr for text in diagnostics),(name,p.stdout[-500:],p.stderr[-500:]);runs.append(dict(name=name,argv=argv,cwd='/private/tmp',started_utc=start,wall_seconds=time.monotonic()-tick,exit=p.returncode,required_diagnostics=diagnostics,stdout_sha256=hashlib.sha256(p.stdout).hexdigest(),stderr_sha256=hashlib.sha256(p.stderr).hexdigest()));print(name,p.returncode,flush=True)
run('public-cli-intact',0,['WORD_CONTROL PASSED 15/15','"assertions": 15'])
try:
 text=original.decode();old='(swapPool ⟨ten, twenty⟩ one ⟨one, two⟩) 0 11 20';assert text.count(old)==1;source.write_text(text.replace(old,'(swapPool ⟨ten, twenty⟩ one ⟨one, two⟩) 1 11 20'));run('public-cli-wrong-expected',1,['WORD_CONTROL zero_output_without_early_fee_rounding false','FAIL: Word control comparison','FAIL: native Lean replay exited 1'])
finally:source.write_bytes(original)
try:
 text=original.decode();a=text.index('private def checks : List (String × Bool) := [');b=text.index('\n#eval do',a);source.write_text(text[:a]+'private def checks : List (String × Bool) := []\n'+text[b:]);run('public-cli-empty',3,['BLOCKED: empty Word control inventory','BLOCKED: AMM checked assertion inventory missing or duplicated'])
finally:source.write_bytes(original)
mode=source.stat().st_mode
try:
 source.chmod(0o200);run('public-cli-unreadable',3,['BLOCKED:'])
finally:source.chmod(mode)
assert source.read_bytes()==original
(e/'public-cli-controls.json').write_text(json.dumps(dict(status='PASS',runs=runs,scope='Actual delivery CLI. Freshly builds immutable Checked API then evaluates current source audit; changed expectations, empty inventory and unreadability are distinct from altered-model runtime/proof mutations.'),indent=2)+'\n');print('PASS',len(runs),'delivery CLI controls')
