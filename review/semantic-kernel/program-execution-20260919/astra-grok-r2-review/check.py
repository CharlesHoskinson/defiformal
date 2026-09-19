import pathlib,json,hashlib,tarfile,re,sys
R=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919'); S=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r2'); O=pathlib.Path(__file__).parent
H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R/'grok-r2-frozen-inputs.json').read_text());bad=[p for p,h in m['files'].items() if H(S/p)!=h];assert not bad,bad
assert H(R/m['archive'])==m['archive_sha256']
with tarfile.open(R/m['archive']) as t:
 d={x.name.removeprefix('./'):hashlib.sha256(t.extractfile(x).read()).hexdigest() for x in t.getmembers() if x.isfile()}
 assert all(d.get(p)==h for p,h in m['files'].items())
old=json.loads((R/'grok-r1-frozen-inputs.json').read_text()); changes=[p for p,h in old['files'].items() if p.startswith('lean/') and H(S/p)!=h];assert changes==['lean/DefiKernel/Certificates/Verify.lean'],changes
for n in ['Roundtrip','IRDepth','DepthBridge']:assert H(S/f'lean/DefiKernel/Certificates/{n}.lean')==H(S/f'baseline-grok-r1/lean/DefiKernel/Certificates/{n}.lean')
inv=[]
for n in ['CompositionDepth','Lexical']:
 s=(S/f'lean/DefiKernel/Certificates/{n}.lean').read_text();s=re.sub(r'/\-.*?\-/','',s,flags=re.S);s=re.sub(r'--[^\n]*','',s)
 for mt in re.finditer(r'^\s*(?:(private|protected|noncomputable)\s+)?(theorem|lemma|def|instance|abbrev)\s+([^\s(:]+)',s,re.M):inv.append({'module':n,'kind':mt[2],'name':'DefiKernel.Certificates.'+mt[3],'modifier':mt[1]})
(O/'inventory.json').write_text(json.dumps(inv,indent=2)); (O/'Audit.lean').write_text('import DefiKernel.Certificates.CompositionDepth\nimport DefiKernel.Certificates.Lexical\n'+''.join('#print axioms '+x['name']+'\n' for x in inv))
print(json.dumps({'files':len(m['files']),'archive_verified':True,'changed_inherited_sources':changes,'inventory_count':len(inv),'per_module':{n:sum(x['module']==n for x in inv) for n in ['CompositionDepth','Lexical']},'names':inv},indent=2))
