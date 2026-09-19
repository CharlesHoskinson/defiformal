import pathlib,json,re,hashlib
out=pathlib.Path(__file__).parent
names=[x['name'] for x in json.loads((out/'new-declarations.json').read_text())]
raw=(out/'171601015310.log').read_text(); matches=re.findall(r"'DefiKernel.Certificates.(\w+)' (does not depend on any axioms|depends on axioms: \[([^\]]*)\])",raw,re.S)
assert len(matches)==38 and set(n for n,_,_ in matches)==set(names)
rows=[]
for n,s,a in matches:
 axioms=[x.strip() for x in a.split(',') if x.strip()]; assert set(axioms)<={'propext','Classical.choice','Quot.sound'}; rows.append(dict(name=n,axioms=axioms))
(out/'axiom-inventory.json').write_text(json.dumps(rows,indent=2)+'\n')
p=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/astra-r28-inputs.json'); j=json.loads(p.read_text()); bad=[n for n,h in j['files'].items() if hashlib.sha256((pathlib.Path(j['sandbox'])/n).read_bytes()).hexdigest()!=h]; assert len(j['files'])==211 and not bad
commands=json.loads((out/'commands.json').read_text()); assert len(commands)>=7
for c in commands: assert hashlib.sha256(pathlib.Path(c['raw_output']).read_bytes()).hexdigest()==c['sha256']
print(json.dumps(dict(axiom_inventory_count=len(rows),axiom_free=sum(not r['axioms'] for r in rows),allowed_axioms_only=True,frozen_files_rechecked=len(j['files']),mismatches=bad,command_logs_checked=len(commands))))
