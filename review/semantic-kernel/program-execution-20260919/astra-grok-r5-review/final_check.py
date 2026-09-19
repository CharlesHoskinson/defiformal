import pathlib,json,hashlib,subprocess,re
out=pathlib.Path(__file__).parent;root=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r5')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
f=json.loads((out.parent/'grok-r5-frozen-inputs.json').read_text())
r={'frozen_count':len(f['files']),'frozen_mismatches':[p for p,h in f['files'].items() if not (root/p).exists() or sha(root/p)!=h],'archive_matches':sha(out.parent/f['archive'])==f['archive_sha256'],'author':{},'command_hash_mismatches':[],'dependency_pins':[]}
a=root/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r5'
for name,base in [('MANIFEST.json',a),('source-manifest.json',root)]:
 d=json.loads((a/name).read_text())['files'];r['author'][name]={'count':len(d),'mismatches':[p for p,h in d.items() if not (base/p).exists() or sha(base/p)!=h['sha256'] or (base/p).stat().st_size!=h['bytes']]}
commands=[json.loads(x) for x in (out/'commands.jsonl').read_text().splitlines()]
for c in commands:
 for p,h in c['raw_sha256'].items():
  if sha(out/p)!=h:r['command_hash_mismatches'].append(p)
r['commands']=[{'label':c['label'],'exit':c['exit']} for c in commands]
manifest=json.loads((root/'lean/lake-manifest.json').read_text())
for p in manifest['packages']:
 q=root/'lean/.lake/packages'/p['name'];cp=subprocess.run(['git','rev-parse','HEAD'],cwd=q,capture_output=True,text=True)
 r['dependency_pins'].append({'name':p['name'],'expected':p.get('rev'),'actual':cp.stdout.strip(),'match':cp.returncode==0 and cp.stdout.strip()==p.get('rev')})
r['tool_sha256']={p:sha(pathlib.Path(p)) for p in ['/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lake','/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lean']}
expected=re.findall(r'^#print axioms (.+)$',(out/'AuditR5.lean').read_text(),re.M); actual=re.findall(r"^'([^']+)' depends on axioms:",(out/'audit-r5-corrected.stdout').read_text(),re.M)
r['named_axiom_inventory']={'expected':expected,'actual':actual,'exact':expected==actual}
r['checks_pass']=not r['frozen_mismatches'] and r['archive_matches'] and all(not x['mismatches'] for x in r['author'].values()) and not r['command_hash_mismatches'] and all(x['match'] for x in r['dependency_pins']) and expected==actual
(out/'final-verification.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2));assert r['checks_pass']
