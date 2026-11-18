from pathlib import Path
import datetime,hashlib,json,subprocess,time,sys
b=Path('/private/tmp/defiformal-ordering-package-author');root=Path('/private/tmp/defiformal-ordering-package-receiver-r2/defiformal-evidence');records=[]
def run(name,argv,code,diagnostic):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();out=subprocess.run(argv,cwd='/private/tmp',env={'PATH':'/usr/bin:/bin','HOME':'/private/tmp'},stdout=subprocess.PIPE,stderr=subprocess.PIPE);(b/(name+'.stdout.log')).write_bytes(out.stdout);(b/(name+'.stderr.log')).write_bytes(out.stderr);assert out.returncode==code,(name,out.returncode,out.stderr[-500:]);assert diagnostic.encode() in out.stdout+out.stderr,(name,out.stderr[-500:]);records.append(dict(name=name,argv=argv,cwd='/private/tmp',environment={'PATH':'/usr/bin:/bin','HOME':'/private/tmp'},started_utc=start,wall_seconds=time.monotonic()-tick,exit=out.returncode,expected_exit=code,required_diagnostic=diagnostic,stdout_sha256=hashlib.sha256(out.stdout).hexdigest(),stderr_sha256=hashlib.sha256(out.stderr).hexdigest()));print(name,code,flush=True)
run('six-target-shell',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-ordering-package-intact-results-r2'],0,'PASS: 6 selected modules replayed')
unreadable=root/'README.md';mode=unreadable.stat().st_mode;unreadable.chmod(0o200)
try:
 run('unreadable-shell',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-ordering-package-unreadable-results-r2'],3,'BLOCKED: unreadable artifact: README.md')
 run('unreadable-optional-python',[sys.executable,str(root/'recheck.py'),'--verify-only'],3,'BLOCKED:')
finally:unreadable.chmod(mode)
target=root/'lib/lean/DefiKernel/Interleaving/OrderingReplay.olean';saved=b/'saved-OrderingReplay.olean';target.rename(saved)
try:run('missing-ordering-target',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-ordering-package-missing-results-r2'],3,'BLOCKED: missing artifact: lib/lean/DefiKernel/Interleaving/OrderingReplay.olean')
finally:saved.rename(target)
data=target.read_bytes();target.write_bytes(data+b'corrupt')
try:run('altered-ordering-byte',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-ordering-package-altered-results-r2'],1,'FAIL: checksum mismatch')
finally:target.write_bytes(data)
targets=root/'targets.txt';data=targets.read_bytes();targets.write_bytes(b'')
try:run('empty-targets',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-ordering-package-empty-results-r2'],3,'BLOCKED: empty or missing target inventory')
finally:targets.write_bytes(data)
run('optional-inventory',[sys.executable,str(root/'recheck.py'),'--verify-only'],0,'"targets": 6')
run('packaged-token0',[sys.executable,str(root/'evidence/repository/docs/correspondence/token0/verify.py')],0,'"bound_files": 101')
archive=b/'defiformal-evidence-65a47d8e-ordering-macos-arm64-r2.tar.gz'
record=dict(schema='defiformal-compiled-ordering-package-controls/v1',python=sys.version,archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),archive_bytes=archive.stat().st_size,package_manifest_sha256=hashlib.sha256((root/'manifest.json').read_bytes()).hexdigest(),runs=records,status='PASS',scope='Actual extracted six-target package shell/default kernel replay and optional consistency commands. Controlled payload mutations restored. No new financial source runtime or EVM campaign. No real outside developer reproduction.')
(b/'verification.json').write_text(json.dumps(record,indent=2)+'\n');print('PASS',len(records),'commands')
