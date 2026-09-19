import json,pathlib,hashlib,re,difflib
root=pathlib.Path.cwd(); out=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/astra-grok-r1-review')
frozen=json.loads(pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/grok-r1-frozen-inputs.json').read_text())
hashf=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
bad=[p for p,h in frozen['files'].items() if hashf(root/p)!=h]
assert len(frozen['files'])==335 and not bad
print('Frozen:335/335 matched')
base=root/'baseline-r28'; changes=[]
for p in base.rglob('*'):
 if p.is_file():
  rel=p.relative_to(base); q=root/rel
  if q.read_bytes()!=p.read_bytes():
   changes.append(str(rel));print(''.join(difflib.unified_diff(p.read_text().splitlines(True),q.read_text().splitlines(True),fromfile=str(rel),tofile=str(rel))))
print('Changed baseline paths:',changes)
p=root/'lean/DefiKernel/Certificates/Roundtrip.lean'; old=(base/p.relative_to(root)).read_text();new=p.read_text();assert new.replace('import DefiKernel.Certificates.DepthBridge\n','')==old
print('Roundtrip bytes identical after removing only new import; declaration count:',len(re.findall(r'^(?:private )?(?:theorem|lemma|def|instance|abbrev)\b',old,re.M)))
e=root/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r1'; man=json.loads((e/'MANIFEST.json').read_text());bad=[]
for x in man['files']:
 p=root/x['path']
 if hashf(p)!=x['sha256']:bad.append(x['path'])
print('Author manifest stale:',json.dumps(bad));assert len(bad)==2
src=json.loads((e/'source-manifest.json').read_text());assert all(hashf(root/p)==x['sha256'] for p,x in src['sources'].items());print('Source bindings:',len(src['sources']))
cmds=json.loads((e/'commands.json').read_text()); print('Author commands:',len(cmds))
for c in cmds:
 print(c['id'],c['exit'],c.get('finished_utc'),{k:v for k,v in c.items() if 'stdout' in k or 'stderr' in k})
inventory=[]
for module in ['DepthBridge','IRDepth']:
 s=(root/f'lean/DefiKernel/Certificates/{module}.lean').read_text()
 decl=re.findall(r'^(?:(private) )?(theorem|lemma|def|instance|abbrev)\s+(\S+)',s,re.M)
 print(module,len(decl),decl);inventory.extend({'module':module,'kind':kind,'name':'DefiKernel.Certificates.'+name,'private':bool(priv)} for priv,kind,name in decl)
(out/'declarations.json').write_text(json.dumps(inventory,indent=2)+'\n')
(root/'lean/AuditR1.lean').write_text('import DefiKernel.Certificates.IRDepth\n'+''.join('#print axioms '+d['name']+'\n' for d in inventory))
(out/'input-checks.json').write_text(json.dumps({'frozen_count':335,'mismatches':[],'baseline_changed':changes,'author_manifest_stale':bad,'source_bindings':len(src['sources']),'new_declarations':len(inventory)},indent=2)+'\n')
