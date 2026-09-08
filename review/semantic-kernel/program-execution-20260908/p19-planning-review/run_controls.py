#!/usr/bin/env python3
import pathlib,json,subprocess,time,datetime,os,hashlib,shutil
O=pathlib.Path(__file__).resolve().parent
W=pathlib.Path('/home/charl/defiformal-wt-certificates-grok-gpt6-20260908')
S=O/'sandbox';rel='review/semantic-kernel/certificates/planning/grok-gpt6-official-r2'
PKG=S/rel;PLAN=S/'openspec/changes/serialized-kernel-certificates';SCRIPT=W/rel/'package.py'
sha=lambda b:hashlib.sha256(b).hexdigest()
rows=[]
def run(name,argv,cwd,expected,needle):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();tick=time.monotonic()
 env={**os.environ,'PYTHONDONTWRITEBYTECODE':'1','CERT_ISOLATED':'1','NO_COLOR':'1'}
 p=subprocess.run(argv,cwd=cwd,env=env,capture_output=True,timeout=60)
 (O/'logs'/(name+'.stdout')).write_bytes(p.stdout);(O/'logs'/(name+'.stderr')).write_bytes(p.stderr)
 r=dict(name=name,argv=argv,cwd=str(cwd),start_utc=start,end_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),seconds=round(time.monotonic()-tick,3),exit=p.returncode,expected_exit=expected,expected_text=needle,passed=p.returncode==expected and needle in (p.stdout+p.stderr).decode(),stdout_sha256=sha(p.stdout),stderr_sha256=sha(p.stderr),environment_overrides={k:env[k] for k in ['PYTHONDONTWRITEBYTECODE','CERT_ISOLATED','NO_COLOR']});rows.append(r);(O/'commands.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(r),flush=True)
 if not r['passed']:raise SystemExit(1)
argv=['python3',str(SCRIPT),'--check','--root',str(W),'--plan',str(PLAN),'--package',str(PKG)]
run('intact',argv,S,0,'PASS_SEALED_PLANNING_PACKAGE')
target=PKG/'STATUS.json';old=target.read_bytes()
try:
 target.write_bytes(old+b'\n');run('changed-bound',argv,S,1,'manifest mismatch')
finally:target.write_bytes(old)
try:
 target.unlink();run('missing-bound',argv,S,3,'manifest missing')
finally:target.write_bytes(old)
target=PLAN/'fixtures.json';old=target.read_bytes()
try:
 target.write_text('{"fixtures": [], "count": 0}\n');run('empty-fixtures',argv,S,3,'fixtures: empty (0 of 0)')
finally:target.write_bytes(old)
target=PLAN/'specs/serialized-module-format/spec.md';old=target.read_bytes()
try:
 assert old.count(b'### Requirement: SF01 ')==1
 target.write_bytes(old.replace(b'### Requirement: SF01 ',b'### Requirement: ZZ99 ',1));run('changed-requirement',argv,S,1,'31 requirements')
finally:target.write_bytes(old)
run('restored',argv,S,0,'PASS_SEALED_PLANNING_PACKAGE')
run('strict',['openspec','validate','serialized-kernel-certificates','--strict'],S,0,"is valid")
before=json.loads((O/'before.json').read_text())
assert all(sha((S/rel).read_bytes())==expected for rel,expected in before['members'].items())
print('All sandbox archive members restored exactly',flush=True)
