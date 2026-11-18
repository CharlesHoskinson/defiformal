from pathlib import Path
import datetime,hashlib,json,subprocess,tempfile,time,sys,shutil
b=Path('/private/tmp/defiformal-compiled-package-author');root=Path('/private/tmp/defiformal-package-receiver-r4/defiformal-evidence');records=[]
def run(name,argv,code,diagnostic):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic();out=subprocess.run(argv,cwd='/private/tmp',env={'PATH':'/usr/bin:/bin','HOME':'/private/tmp'},stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert out.returncode==code,(name,out.returncode,out.stderr[-500:]);combined=out.stdout+out.stderr;assert diagnostic.encode() in combined,(name,combined[-500:]);(b/(name+'.stdout.log')).write_bytes(out.stdout);(b/(name+'.stderr.log')).write_bytes(out.stderr);records.append(dict(name=name,argv=argv,cwd='/private/tmp',environment={'PATH':'/usr/bin:/bin','HOME':'/private/tmp'},started_utc=start,wall_seconds=time.monotonic()-tick,exit=out.returncode,expected_exit=code,required_diagnostic=diagnostic,stdout_sha256=hashlib.sha256(out.stdout).hexdigest(),stderr_sha256=hashlib.sha256(out.stderr).hexdigest()));print(name,code,flush=True)
run('final-intact-shell',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-package-final-results-r4'],0,'PASS: 5 selected modules replayed')
unreadable=root/'README.md';original_mode=unreadable.stat().st_mode;unreadable.chmod(0o200)
try:
 run('unreadable-shell',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-package-unreadable-results-r4'],3,'BLOCKED: unreadable artifact: README.md')
 run('unreadable-optional-python',[sys.executable,str(root/'recheck.py'),'--verify-only'],3,'BLOCKED:')
finally:unreadable.chmod(original_mode)
target=root/'lib/lean/DefiKernel/Vault/ComputedDeposit.olean';saved=b/'saved-ComputedDeposit.olean';target.rename(saved)
try:run('missing-target-shell',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-package-missing-results-r4'],3,'BLOCKED: missing artifact: lib/lean/DefiKernel/Vault/ComputedDeposit.olean')
finally:saved.rename(target)
data=target.read_bytes();target.write_bytes(data+b'corrupt')
try:run('altered-byte-shell',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-package-altered-results-r4'],1,'FAIL: checksum mismatch')
finally:target.write_bytes(data)
targets=root/'targets.txt';saved_targets=targets.read_bytes();targets.write_bytes(b'')
try:run('empty-targets-shell',['/bin/sh',str(root/'replay.sh'),'/private/tmp/defiformal-package-empty-results-r4'],3,'BLOCKED: empty or missing target inventory')
finally:targets.write_bytes(saved_targets)
run('final-optional-inventory',[sys.executable,str(root/'recheck.py'),'--verify-only'],0,'"status": "PASS"')
run('final-packaged-token0',[sys.executable,str(root/'evidence/repository/docs/correspondence/token0/verify.py')],0,'"bound_files": 101')
with tempfile.TemporaryDirectory(prefix='empty-builder-targets-') as temp:
 temp=Path(temp);shutil.copy2('/private/tmp/defiformal-ci-author/tools/compiled-evidence/build.py',temp/'build.py');(temp/'targets.json').write_text('[]\n')
 run('empty-builder-targets',[sys.executable,str(temp/'build.py'),'--repo','/private/tmp/defiformal-ci-author','--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64','--output',str(temp/'output'),'--archive',str(temp/'archive.tar.gz')],3,'BLOCKED: empty target set')
with tempfile.TemporaryDirectory(prefix='unreadable-builder-targets-') as temp:
 temp=Path(temp);shutil.copy2('/private/tmp/defiformal-ci-author/tools/compiled-evidence/build.py',temp/'build.py');targets=temp/'targets.json';targets.write_text('[]\n');targets.chmod(0o200)
 try:run('unreadable-builder-targets',[sys.executable,str(temp/'build.py'),'--repo','/private/tmp/defiformal-ci-author','--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64','--output',str(temp/'output'),'--archive',str(temp/'archive.tar.gz')],3,'BLOCKED:')
 finally:targets.chmod(0o600)
record=dict(schema='defiformal-compiled-package-controls/v1',python=sys.version,archive_sha256=hashlib.sha256((b/'candidate-r4.tar.gz').read_bytes()).hexdigest(),archive_bytes=(b/'candidate-r4.tar.gz').stat().st_size,package_manifest_sha256=hashlib.sha256((root/'manifest.json').read_bytes()).hexdigest(),runs=records,status='PASS',scope='Actual extracted package shell and optional consistency commands. Controlled artifact mutations restored. No new source financial runtime or EVM campaign. No actual outside developer reproduction.')
(b/'verification-r4.json').write_text(json.dumps(record,indent=2)+'\n')
print('PASS all',len(records),'commands')
