import json,pathlib,hashlib,re
root=pathlib.Path.cwd(); parent=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919');out=parent/'astra-grok-r1-review';sha=lambda b:hashlib.sha256(b).hexdigest()
baseline=json.loads((parent/'author-source-baseline.json').read_text())['files'];frozen=json.loads((parent/'grok-r1-frozen-inputs.json').read_text());changed=[];missing=[]
for p,h in baseline.items():
 if p.startswith('lean/'):
  if p not in frozen['files']:missing.append(p)
  elif h!=frozen['files'][p]:changed.append(p)
print('Pre-author Lean baseline comparison:',len([p for p in baseline if p.startswith('lean/')]),'changed',changed,'missing',missing)
assert not missing and set(changed)=={'lean/DefiKernel/Certificates/Roundtrip.lean','lean/DefiKernel/Certificates/Verify.lean'}
assert sha((parent/frozen['archive']).read_bytes())==frozen['archive_sha256'];print('Archive sha256 matches root inventory')
e=root/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r1';cs=json.loads((e/'commands.json').read_text());before=[c for c in cs if c['id']!='closeout-manifests'];hh=sha((json.dumps(before,indent=2)+'\n').encode());expected=frozen['author_manifest_mismatches'][0]['expected'];print('Reconstructed pre-closeout23receipt hash',hh,'matches stale author binding',hh==expected);assert hh==expected
s=(out/'axioms.stdout').read_text();items=re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]",s);assert len(items)==38
allowed={'propext','Classical.choice','Quot.sound'};assert all(set(x.strip() for x in axioms.split(',') if x.strip())<=allowed for name,axioms in items)
print('38/38 explicit transitive #print axioms closures standard only')
inventory=json.loads((out/'declarations.json').read_text());assert {d['name'] for d in inventory}=={n for n,a in items}
bs=(out/'build.stdout').read_text();built=re.findall(r'Built ([\w.]+)',bs);assert all('DefiKernel.Certificates.'+m in built for m in ['DepthBridge','IRDepth','Roundtrip','Verify']);print('Actually built modules:',built)
print('Audit summaries:');print('\n'.join(x for x in bs.splitlines() if 'PASSED:' in x))
assert all(sha((root/p).read_bytes())==h for p,h in frozen['files'].items());print('Post-build frozen integrity335/335')
summary={'baseline_lean_count':len([p for p in baseline if p.startswith('lean/')]),'changed_existing_lean':changed,'archive_sha256':frozen['archive_sha256'],'reconstructed_old_commands_sha256':hh,'print_axioms_count':len(items),'allowed_axioms':sorted(allowed),'actually_built_modules':built,'post_build_frozen_count':335}
(out/'verification-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
