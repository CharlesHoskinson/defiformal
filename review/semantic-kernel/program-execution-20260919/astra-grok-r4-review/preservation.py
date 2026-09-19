import json,pathlib,hashlib,tarfile
O=pathlib.Path(__file__).parent;R=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r4');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();A=R/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r4'
for name,base in [('MANIFEST.json',A),('source-manifest.json',R)]:
 d=json.loads((A/name).read_text());bad=[p for p,x in d['files'].items() if h(base/p)!=x['sha256'] or (base/p).stat().st_size!=x['bytes']];assert not bad;print(name,'valid',len(d['files']))
b=json.loads((O.parent/'grok-r4-start-baseline.json').read_text());assert h(O.parent/b['archive'])==b['archive_sha256'];print('baseline archive validated',b['archive_sha256'])
for mod in ['Roundtrip','Lexical','IRDepth','CompositionDepth','Correspondence','Decode','Schema']:
 p=f'lean/DefiKernel/Certificates/{mod}.lean';v=b['files'].get(p);print('preserved',p,h(R/p),v);assert h(R/p)==(v if isinstance(v,str) else v['sha256'])
manifest=json.loads((R/'lean/lake-manifest.json').read_text());print('dependencies',[(x['name'],x['rev']) for x in manifest['packages']])
