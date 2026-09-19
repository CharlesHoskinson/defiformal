import pathlib,json,re,hashlib,difflib,collections
O=pathlib.Path(__file__).parent;R=O.parent;S=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r2');E=S/'review/semantic-kernel/certificates/p19/implementation/grok-20260919-r2';H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((E/'MANIFEST.json').read_text());assert H(E/'MANIFEST.json')==json.loads((R/'grok-r2-frozen-inputs.json').read_text())['author_manifest_sha256']
for x in m['files']:
 p=(S if x['path'].startswith('lean/') else E)/x['path']; assert H(p)==x['sha256'];assert p.stat().st_size==x['bytes']
commands=json.loads((E/'commands.json').read_text());assert len(commands)==14
for c in commands:
 assert json.loads((E/'logs'/c['id']/'command.json').read_text())==c
 for n in ['stdout','stderr']:assert H(E/c[n+'_path'])==c[n+'_sha256']
 assert c['finished_utc']<m['timestamp_utc'];assert c['started_utc']<=c['finished_utc'];assert c['source_sha256_before']==c['source_sha256_after'];assert c['recorder_sha256']==H(E/'record-author-r2-command.py')
root=(R/'record-author-r2-command.py').read_text();local=(E/'record-author-r2-command.py').read_text();diff=''.join(difflib.unified_diff(root.splitlines(True),local.splitlines(True)));(O/'recorder.diff').write_text(diff)
a=(S/'baseline-grok-r1/lean/DefiKernel/Certificates/Verify.lean').read_text();b=(S/'lean/DefiKernel/Certificates/Verify.lean').read_text();vd=''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True)));(O/'verify.diff').write_text(vd)
rows=[]
for mt in re.finditer(r'AXIOM AUDIT (theorem|declaration): (.*?); module=DefiKernel.Certificates.(CompositionDepth|Lexical);(?: kind=(.*?);)? axioms=\[([^\]]*)\]',(O/'commands/build/stdout').read_text(),re.S):
 # names never span lines
 if '\n' in mt[2]:raise ValueError(mt[2])
 rows.append({'name':mt[2],'module':mt[3],'kind':mt[4] or 'theorem','axioms':[x.strip() for x in mt[5].split(',') if x.strip()]})
assert len(rows)==len(set(x['name'] for x in rows));assert all(set(x['axioms'])<={'propext','Classical.choice','Quot.sound'} for x in rows)
assert {x['name'] for x in json.loads((O/'inventory.json').read_text())}<={x['name'] for x in rows}
(O/'compiled-inventory.json').write_text(json.dumps(rows,indent=2));(O/'AllAxioms.lean').write_text('import DefiKernel.Certificates.Lexical\n'+''.join('#print axioms '+x['name']+'\n' for x in rows))
summary={'author_manifest_files':len(m['files']),'author_commands':len(commands),'command_results':{c['id']:c['exit'] for c in commands},'compiled_declarations':len(rows),'compiled_modules':dict(collections.Counter(x['module'] for x in rows)),'compiled_kinds':dict(collections.Counter(x['kind'] for x in rows)),'forbidden_axioms':0,'recorder_diff':diff,'verify_diff':vd}
(O/'evidence-summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
