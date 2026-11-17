from pathlib import Path
import datetime,hashlib,json,subprocess,sys,time
repo=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-ordering-author');source=repo/'lean/DefiKernel/Interleaving/OrderingReplay.lean';original=source.read_bytes();runs=[];argv=[sys.executable,str(repo/'scripts/replay_ordering.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64']
def run(name,expected,diagnostics):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();p=subprocess.run(argv,cwd='/private/tmp',stdout=subprocess.PIPE,stderr=subprocess.PIPE);combined=p.stdout+p.stderr;(e/(name+'.stdout.log')).write_bytes(p.stdout);(e/(name+'.stderr.log')).write_bytes(p.stderr);assert p.returncode==expected,(name,p.returncode,combined[-500:]);assert all(s.encode() in combined for s in diagnostics),(name,combined[-500:]);runs.append(dict(name=name,argv=argv,cwd='/private/tmp',started_utc=start,wall_seconds=time.monotonic()-tick,exit=p.returncode,required_diagnostics=diagnostics,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest() if source.stat().st_mode&0o400 else None,stdout_sha256=hashlib.sha256(p.stdout).hexdigest(),stderr_sha256=hashlib.sha256(p.stderr).hexdigest()));print(name,p.returncode,flush=True)
run('intact',0,['ORDERING PASSED 12/12','"assertions": 12'])
s=original.decode();needle='(sharedBalance 7 0 3)\n    withdrawalLeft';assert s.count(needle)==1
try:
 source.write_text(s.replace(needle,'(sharedBalance 8 0 2)\n    withdrawalLeft'));run('wrong-expected-ledger',1,['ORDERING left_right_full_result false','FAIL: ordering comparison','FAIL: native Lean replay exited 1'])
finally:source.write_bytes(original)
start=s.index('def checks : List (String × Bool) := [');end=s.index('\ndef printActual',start)
try:
 source.write_text(s[:start]+'def checks : List (String × Bool) := []\n'+s[end:]);run('empty-inventory',3,['BLOCKED: empty ordering inventory','BLOCKED: ordering assertion inventory missing or duplicated'])
finally:source.write_bytes(original)
mode=source.stat().st_mode
try:
 source.chmod(0o200);run('unreadable-source',3,['BLOCKED:'])
finally:source.chmod(mode)
assert source.read_bytes()==original
(e/'controls.json').write_text(json.dumps(dict(status='PASS',runs=runs,scope='Real replay CLI; mutations of only the new source restored. No historical source changed.'),indent=2)+'\n')
print('PASS',len(runs),'actual replay CLI controls')
