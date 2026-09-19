import pathlib,json,hashlib,re
root=pathlib.Path.cwd(); e=root/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r1'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
cs=json.loads((e/'commands.json').read_text());assert len(cs)==24
for c in cs:
 d=e/'logs'/c['id'];assert json.loads((d/'command.json').read_text())==c
 start=json.loads((d/'started.json').read_text()); assert all(c[k]==v for k,v in start.items())
 assert c['started_utc']<=c['finished_utc'];assert not c['timed_out'] and c['launch_error'] is None
 for stream in ['stdout','stderr']:assert h(e/c[stream+'_path'])==c[stream+'_sha256']
print('24/24 command final receipts match commands.json and started metadata;48/48 raw stream hashes match; no timeouts or launch errors.')
close=next(c for c in cs if c['id']=='closeout-manifests');manifest=json.loads((e/'MANIFEST.json').read_text());print('Closeout timing:',close['started_utc'],manifest['timestamp_utc'],close['finished_utc'])
assert close['started_utc']<manifest['timestamp_utc']<close['finished_utc']
assert all(h(root/p)==v for p,v in close['source_sha256_after'].items())
print('Closeout final15source hashes match.')
s=(root/'baseline-r28/lean/DefiKernel/Certificates/Roundtrip.lean').read_text();print('Roundtrip theorems',len(re.findall(r'^theorem ',s,re.M)),'definitions',len(re.findall(r'^def ',s,re.M)))
for module in ['DepthBridge','IRDepth']:
 s=(root/f'lean/DefiKernel/Certificates/{module}.lean').read_text();assert not re.search(r'\b(sorry|native_decide|axiom|unsafe)\b',s)
print('New source: no sorry/native_decide/axiom/unsafe tokens.')
print('Dependency/build symlinks:',list((root/'lean/.lake').rglob('nonexistent')))
for target in ['packages','build']:
 p=root/'lean/.lake'/target;assert not p.is_symlink();print(target,'private directory',p.resolve())
