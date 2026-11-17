import pathlib,json,hashlib,subprocess,tarfile,sys
root=pathlib.Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal');integ=root/'review/semantic-kernel/competitive-landscape-adoption-20261117/margin-close-package-integration';out=integ.parent/'margin-close-package-review';out.mkdir(exist_ok=True);own=pathlib.Path('/private/tmp/defiformal-margin-close-package-review');own.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();f=json.loads((integ/'FREEZE.json').read_text())
for x in f['files']:
 b=(root/x['path']).read_bytes();assert sha(b)==x['sha256'] and len(b)==x['bytes']
a=pathlib.Path(f['archive']['path']);assert a.stat().st_size==f['archive']['bytes'] and sha(a.read_bytes())==f['archive']['sha256'];print('freeze/archive verified',flush=True)
with tarfile.open(a) as t:t.extractall(own/'receiver',filter='data')
p=own/'receiver/defiformal-evidence';m=json.loads((p/'manifest.json').read_text());assert sha((p/'manifest.json').read_bytes())==f['files'][5]['sha256'];assert len(m['targets'])==43 and len(m['modules'])==2496
prior=json.loads((root/'docs/evidence/compiled-margin-realization-macos-arm64/manifest.json').read_text());added=set(m['targets'])-set(prior['targets']);assert added=={'DefiKernel.Margin.Close','DefiKernel.Margin.CloseAudit'};assert len(set(x['module'] for x in m['modules'])-set(x['module'] for x in prior['modules']))==2
repo_checked=[]
for x in m['modules']:
 b=(p/x['source']).read_bytes();assert sha(b)==x['source_sha256']
 if x['module'].startswith('DefiKernel.'):
  path='lean/'+x['module'].replace('.','/')+'.lean';assert b==subprocess.check_output(['git','show',f['baseline']+':'+path],cwd=root);repo_checked.append(path)
for q in (p/'evidence/repository').rglob('*'):
 if q.is_file():
  rel=q.relative_to(p/'evidence/repository').as_posix();assert q.read_bytes()==subprocess.check_output(['git','show',f['baseline']+':'+rel],cwd=root)
for rel,source in [('replay.sh','tools/compiled-evidence/replay.sh'),('recheck.py','tools/compiled-evidence/recheck.py')]:assert (p/rel).read_bytes()==(root/source).read_bytes()
assert sha((root/'tools/compiled-evidence/build.py').read_bytes())=='99d10e444a58f6c4525ed6866afbb7a3b3a031a577e417bbf996d65b2eb22db28'.replace('bbf996','bb996')
(out/'INPUTS.json').write_text(json.dumps({'freeze':f,'freeze_sha256':sha((integ/'FREEZE.json').read_bytes()),'integration_evidence_hashes':{n:sha((integ/n).read_bytes()) for n in f['evidence']},'added_targets':sorted(added),'repo_module_sources_checked':repo_checked,'module_source_hashes_verified':len(m['modules'])},indent=2)+'\n')
runs=[]
def run(name,argv,exit,diag):
 r=subprocess.run(argv,cwd='/private/tmp',env={'PATH':'/usr/bin:/bin'},stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(out/(name+'.log')).write_bytes(r.stdout);row={'name':name,'argv':argv,'exit':r.returncode,'expected':exit,'diagnostic':diag,'log_sha256':sha(r.stdout)};runs.append(row);print(name,r.returncode,flush=True);assert r.returncode==exit and diag in r.stdout.decode(),r.stdout[-3000:]
run('replay',['/bin/sh',str(p/'replay.sh'),str(own/'intact-results')],0,'PASS: 43 selected modules replayed')
run('inventory',[sys.executable,str(p/'recheck.py'),'--verify-only'],0,'"targets": 43')
run('token0',[sys.executable,str(p/'evidence/repository/docs/correspondence/token0/verify.py')],0,'"bound_files": 101')
q=p/'lib/lean/DefiKernel/Margin/Close.olean';b=q.read_bytes()
try:
 q.unlink();run('missing',['/bin/sh',str(p/'replay.sh'),str(own/'missing-results')],3,'BLOCKED: missing artifact: lib/lean/DefiKernel/Margin/Close.olean')
 q.write_bytes(b+b'x');run('altered',['/bin/sh',str(p/'replay.sh'),str(own/'altered-results')],1,'FAIL: checksum mismatch')
finally:q.write_bytes(b)
(out/'independent-verification.json').write_text(json.dumps({'status':'PASS','runs':runs,'artifact_restored':sha(q.read_bytes())==sha(b)},indent=2)+'\n')
