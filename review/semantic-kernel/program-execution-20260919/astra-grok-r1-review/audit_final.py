import pathlib,json,hashlib
r=pathlib.Path.cwd();o=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/astra-grok-r1-review');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for c in json.loads((o/'commands.json').read_text()):
 assert c['exit']==0 and pathlib.Path(c['cwd']).is_absolute()
 for t in ['stdout','stderr']:assert sha(o/c[t]['path'])==c[t]['sha256']
f=json.loads((o/'grok-r1-frozen-inputs.json').read_text());assert len(f['files'])==335
assert all(sha(r/p)==h for p,h in f['files'].items())
v=json.loads((o/'verdict.json').read_text());assert v['verdict']=='ACCEPT_WITH_LIMITATIONS' and not any(v[x] for x in ['P19_accepted','P20_accepted','P37_accepted']);assert len(json.loads((o/'declarations.json').read_text()))==38
print('Final verification: all recorded verification exits0/raw hashes valid; frozen335/335; verdict correctly scoped;38declarations accounted.')
