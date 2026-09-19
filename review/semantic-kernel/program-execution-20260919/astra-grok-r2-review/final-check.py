import json,pathlib,hashlib,re,collections
O=pathlib.Path(__file__).parent;S=pathlib.Path('/home/charl/.cache/defiformal-program/program-execution-20260919/astra-grok-r2');H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
rows=json.loads((O/'compiled-inventory.json').read_text());s=(O/'commands/exact-compiled-axioms/stdout').read_text();parsed={}
for m in re.finditer(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)",s,re.S):parsed[m[1]]=[x.strip() for x in (m[2] or '').split(',') if x.strip()]
assert set(parsed)=={x['name'] for x in rows},(len(parsed),len(rows),set(x['name'] for x in rows)-set(parsed))
assert all(set(v)<={'propext','Classical.choice','Quot.sound'} for v in parsed.values());assert json.loads((O/'commands/exact-compiled-axioms/receipt.json').read_text())['exit']==0
r=(S/'lean/DefiKernel/Certificates/Roundtrip.lean').read_text();r=re.sub(r'/\-.*?\-/','',r,flags=re.S);r=re.sub(r'--[^\n]*','',r)
counts=collections.Counter(re.findall(r'^\s*(?:private\s+|protected\s+|noncomputable\s+)?(theorem|def|instance|lemma)\s+',r,re.M))
assert counts['theorem']==246;assert counts['def']==45
for d in (O/'commands').iterdir():
 if not (d/'receipt.json').exists():
  assert d.name=='final-validation'; continue
 c=json.loads((d/'receipt.json').read_text());assert c['start']<=c['end']
 for n,h in c['sha256'].items():assert H(d/n)==h
summary={'explicit_authored_prints':78,'compiled_exact_prints':len(parsed),'all_compiled_names_covered':True,'forbidden_axioms':0,'roundtrip_authored_inventory':dict(counts),'review_receipts_verified':len(list((O/'commands').iterdir()))}
(O/'verification-summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
