from pathlib import Path
import json,hashlib,subprocess,shutil
root=Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal'); src=Path('/private/tmp/defiformal-ci-author'); ev=Path('/private/tmp/defiformal-margin-close-author'); dst=Path('/private/tmp/defiformal-ci-baseline'); out=root/'review/semantic-kernel/competitive-landscape-adoption-20261117/margin-close-public-review';out.mkdir(exist_ok=True)
h=lambda b:hashlib.sha256(b).hexdigest()
f=json.loads((ev/'FREEZE.json').read_text());proof=json.loads((ev/'PROOF-FREEZE.json').read_text());rows=[]
for x in f['files']:
 b=(src/x['path']).read_bytes();assert h(b)==x['sha256'] and len(b)==x['bytes'];p=dst/x['path'];p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b);rows.append(x)
for x in proof['files']:assert x in f['files']
for x in f['evidence']:assert h((ev/x['path']).read_bytes())==x['sha256']
for x in proof['evidence']:assert h((ev/x['path']).read_bytes())==x['sha256']
acc=json.loads((src/'benchmarks/component-accounting/margin-close.json').read_text());total=0
for x in acc['files']:
 b=(src/x['path']).read_bytes();n=len(b.splitlines());assert h(b)==x['sha256'] and n==x['physical_lines'];cover=[]
 for c in x['classification']:assert c['lines']==c['end']-c['start']+1;cover+=list(range(c['start'],c['end']+1))
 assert cover==list(range(1,n+1));total+=n
assert total==1773
controls=json.loads((ev/'cli-controls.json').read_text())
for c in controls['controls']:assert h((ev/('cli-'+c['name']+'.log')).read_bytes())==c['log_sha256']
for name in ['lean/DefiKernel/Margin/Close.lean','lean/DefiKernel/Margin/CloseAudit.lean','scripts/replay_margin_close.py']:assert (ev/'cli-fixture'/name).read_bytes()==(src/name).read_bytes()
assert (ev/'cli-fixture/lean/.lake/build').resolve()!=(src/'lean/.lake/build').resolve()
inputs={'freeze_path':str(ev/'FREEZE.json'),'freeze_sha256':h((ev/'FREEZE.json').read_bytes()),'baseline':f['detached_author_head'],'files':rows,'proof_freeze_sha256':h((ev/'PROOF-FREEZE.json').read_bytes()),'requested_model':'gpt-6-astra','requested_effort':'medium','reported_model':None,'provider_attestation_available':False}
(out/'INPUTS.json').write_text(json.dumps(inputs,indent=2)+'\n')
p=dst/'lean/DefiKernel/Margin/CloseAudit.lean';original=p.read_bytes();mode=p.stat().st_mode;results=[]
a=['python3',str(dst/'scripts/replay_margin_close.py'),'--toolchain','/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64']
try:
 for name,want in [('positive',0),('wrong-expected',1),('empty',3),('missing',3),('unreadable',3),('empty-inventory',3)]:
  if p.exists():p.chmod(mode)
  p.write_bytes(original)
  if name=='wrong-expected':p.write_bytes(original.replace(b'r.progress.fees.fundingFee=10',b'r.progress.fees.fundingFee=11',1))
  elif name=='empty':p.write_bytes(b'')
  elif name=='missing':p.unlink()
  elif name=='unreadable':p.chmod(0o200)
  elif name=='empty-inventory':
   s=original.decode();p.write_text(s.split('private def checks :')[0]+'private def checks : List (String × Bool) := []\n#eval do'+s.split('#eval do',1)[1])
  q=subprocess.run(a,cwd=dst,capture_output=True,timeout=180);log=q.stdout+q.stderr;(out/(name+'.log')).write_bytes(log)
  assert q.returncode==want,(name,q.returncode,log[-2000:])
  if name=='positive':assert b'CLOSE_CONTROL PASSED 26/26' in log
  elif name=='wrong-expected':assert b'FAIL: actual first close comparison' in log
  else:assert b'BLOCKED:' in log
  results.append({'name':name,'exit':q.returncode,'expected_exit':want,'log_sha256':h(log)});print(name,q.returncode,flush=True)
finally:
 if p.exists():p.chmod(mode)
 p.write_bytes(original);p.chmod(mode)
(out/'independent-verification.json').write_text(json.dumps({'status':'PASS','argv':a,'controls':results,'classified_physical_lines':total,'ranges_complete_disjoint':True,'author_control_log_hashes_verified':5,'author_fixture_exact':True,'math_files_unchanged':3},indent=2)+'\n')
