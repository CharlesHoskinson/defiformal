import pathlib,json,hashlib,re,subprocess
O=pathlib.Path(__file__).parent;M=json.loads((O.parent/'grok-r4-frozen-inputs.json').read_text());R=pathlib.Path(M['sandbox']);bad=[p for p,h in M['files'].items() if hashlib.sha256((R/p).read_bytes()).hexdigest()!=h];assert not bad
records=[json.loads(x) for x in (O/'commands.jsonl').read_text().splitlines()]
for rec in records:
 for p,h in rec['raw_sha256'].items(): assert hashlib.sha256((O/p).read_bytes()).hexdigest()==h
build=(O/'build.stdout').read_text();assert 'Build completed successfully (948 jobs).' in build
assert re.findall(r'AXIOM AUDIT PASSED: (\d+)/(\d+) theorems; forbidden=0',build)==[('2517','2517'),('420','420'),('287','287')]
for rec in records:
 if rec['label']!='probes':assert rec['exit']==0
pins=json.loads((R/'lean/lake-manifest.json').read_text())['packages']; heads=[]
for p in pins:
 q=subprocess.run(['git','rev-parse','HEAD'],cwd=R/'lean/.lake/packages'/p['name'],capture_output=True,text=True);assert q.returncode==0 and q.stdout.strip()==p['rev'];heads.append({'name':p['name'],'head':q.stdout.strip()})
r={'frozen_files':len(M['files']),'mismatches':bad,'archive_sha256':M['archive_sha256'],'dependency_heads':heads,'recorded_commands':[(x['label'],x['exit']) for x in records],'fresh_build_jobs':948,'audit_forbidden':0}
(O/'final-verification.json').write_text(json.dumps(r,indent=2));print(json.dumps(r,indent=2))
