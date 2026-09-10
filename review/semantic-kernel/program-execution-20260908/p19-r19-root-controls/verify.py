from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
w=Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909')
o=b/'p19-r19-root-controls';o.mkdir(exist_ok=False)
author=w/'review/semantic-kernel/certificates/p19/implementation/agy-r19-proof'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
write=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
tool=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin')
manifest=json.loads((b/'p19-roundtrip-proof-agy-r19-terminal-manifest.json').read_text())
for f in manifest['files']:assert h(w/f['path'])==f['sha256']
commands=json.loads((author/'commands.json').read_text())
for c in commands:
 assert c['exit']==0
 for k in ['stdout','stderr']:assert h(author/c['raw'+k])==c[k+'_sha256'],c['id']
sourcehashes={str(p.relative_to(w/'lean')):h(p) for p in (w/'lean/DefiKernel/Certificates').glob('*.lean')}
def run(label,src,cwd,expected=None):
 p=o/label;p.mkdir();probe=p/'Probe.lean';probe.write_text(src)
 argv=[str(tool/'lake'),'env',str(tool/'lean'),str(probe)];start=now()
 x=subprocess.run(argv,cwd=cwd,capture_output=True,timeout=120)
 (p/'stdout').write_bytes(x.stdout);(p/'stderr').write_bytes(x.stderr)
 rec={'started_utc':start,'finished_utc':now(),'argv':argv,'cwd':str(cwd),'exit':x.returncode,
      'probe_sha256':h(probe),'stdout_sha256':h(p/'stdout'),'stderr_sha256':h(p/'stderr'),
      'lean_sha256':h(tool/'lean'),'lake_sha256':h(tool/'lake'),
      'source_hashes':{str(q.relative_to(cwd)):h(q) for q in (cwd/'DefiKernel/Certificates').glob('*.lean')},
      'matches_expected_stdout':None if expected is None else h(p/'stdout')==expected,'acceptance':False}
 write(p/'receipt.json',rec);assert x.returncode==0
 if expected:assert rec['matches_expected_stdout'],label
 return x.stdout.decode()
run('mixed-six',(author/'probes/mixed_error_precedence.lean').read_text(),w/'lean','0ec3c792debf9f40328a2f78e0cd97b21303911262542cf2939ab3ca21d25d02')
run('c0-controls',(author/'probes/c0_controls.lean').read_text(),w/'lean','6caac5c24bbef54474ebc6635ba526341a58169148fd2c8470407aa78f90df6d')
cases=[('unterminated_value_space','{"a": "unterminated'),('unterminated_value_no_space','{"a":"unterminated'),
       ('unterminated_key_space','{"a":1, "unterminated'),('unterminated_key_no_space','{"a":1,"unterminated')]
src='import DefiKernel.Certificates.Correspondence\nopen DefiKernel.Certificates\n'
for name,s in cases:
 src+='#eval '+json.dumps(name)+' ++ ";scan=" ++ reprStr (scanLexical '+json.dumps(s)+'.toUTF8) ++ ";decode=" ++ reprStr (decodeBytes '+json.dumps(s)+'.toUTF8)\n'
r19=run('unterminated-r19',src,w/'lean')
r15=run('unterminated-r15',src,b/'p19-byte-pipeline-grok-r1/private-lean')
write(o/'assessment.json',{'utc':now(),'frozen_archive_sha256':manifest['sha256'],
 'six_mixed_error_cases_restored':True,'c0_controls_match_r16':True,'author_command_raw_stream_bindings':len(commands)*2,
 'unterminated_probe_cases':cases,'unterminated_outputs_equal':r19==r15,'final_decode_outputs_equal': [s.split(';decode=')[1] for s in r19.splitlines()] == [s.split(';decode=')[1] for s in r15.splitlines()],
 'r19_output':r19,'r15_output':r15,'acceptance':False})
assert [s.split(';decode=')[1] for s in r19.splitlines()] == [s.split(';decode=')[1] for s in r15.splitlines()]
shutil.copy2(__file__,o/'verify.py')
write(o/'root-seal.json',{'files':{str(p.relative_to(o)):h(p) for p in sorted(o.rglob('*')) if p.is_file()},'acceptance':False})
print(json.dumps({'six_mixed_restored':True,'c0_controls_match':True,'unterminated_outputs_equal':r19==r15,'final_decode_outputs_equal': [s.split(';decode=')[1] for s in r19.splitlines()] == [s.split(';decode=')[1] for s in r15.splitlines()],'r19':r19,'r15':r15}))
