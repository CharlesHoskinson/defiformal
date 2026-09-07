#!/usr/bin/env python3
"""Independent static planning review; never executes future Lean/runner suites."""
import ast, collections, datetime, hashlib, json, pathlib, re, subprocess
from fractions import Fraction as Q
ROOT=pathlib.Path(__file__).resolve().parents[6]
OUT=pathlib.Path(__file__).resolve().parent
PLAN=ROOT/'openspec/changes/checked-integer-financial-arithmetic'
checks=[]
def ck(name, ok, details=None):
 checks.append({'name':name,'passed':bool(ok),'details':details})
def j(p):return json.loads(p.read_text())
def sha(b):return hashlib.sha256(b).hexdigest()
def adapt(s):
 return s.replace('DefiKernel.Metatheory.Audit','DefiKernel.Arithmetic.RuntimeAudit').replace("'Audit.lean'","'RuntimeAudit.lean'").replace('metatheory','arithmetic').replace('Metatheory','Arithmetic')
manifest=j(OUT.parent/'manifest.json'); bundle=(OUT.parent/'bundle.md').read_bytes()
ck('bundle.hash',sha(bundle)=='a2dea712b95d15080eb7906bc9e43b47894c37b840f8200ed5bb06dcf9f8b4f6')
ck('bundle.size',len(bundle)==363567);ck('inputs.count',len(manifest['inputs'])==33)
bind=[]
for row in manifest['inputs']:
 p=ROOT/row['path'];raw=p.read_bytes();old=subprocess.check_output(['git','show',manifest['candidate']+':'+row['path']],cwd=ROOT)
 rendered=(json.dumps(json.loads(raw),ensure_ascii=False,separators=(',',':'))+'\n').encode() if row['representation']=='lossless_compact_json' else raw
 for k,v in [('bytes',len(raw)==row['bytes']),('hash',sha(raw)==row['sha256']),('git',sha(old)==row['sha256']),('rendered_hash',sha(rendered)==row['rendered_sha256']),('rendered_bytes',len(rendered)==row['rendered_bytes']),('rendered_in_bundle',rendered in bundle)]:ck(row['path']+'.'+k,v)
 bind.append({'path':row['path'],'sha256':sha(raw)})
fs=j(PLAN/'fixture-inventory.json')['fixtures'];ck('fixtures.ids',[f['id'] for f in fs]==[f'F{i:02}' for i in range(1,46)])
ck('fixtures.labels',len({f['label'] for f in fs})==45)
for f in fs:
 i=f['inputs'];op=f['operation'];expected=f['expected'];w=i.get('w',i.get('word_width'));lim=2**w if w is not None else None
 err=lambda e:{'error':e}
 def fit(n,e):return {'ok':n} if n<lim else err(e)
 def divide(n,d,m):return n//d+(m=='up' and n%d!=0)
 if op=='ofNat':actual=fit(i['n'],'inputOverflow')
 elif op in ['add','sub','mul']:
  a,b=i['a'],i['b'];ck(f['id']+'.operands',0<=a<lim and 0<=b<lim)
  actual=fit(a+b,'addOverflow') if op=='add' else fit(a*b,'mulOverflow') if op=='mul' else err('subUnderflow') if b>a else {'ok':a-b}
 elif op in ['mulDiv','divideNat']:
  n=i['a']*i['b'] if op=='mulDiv' else i['numerator'];d=i['d'] if op=='mulDiv' else i['denominator']
  actual=err('divisionByZero') if d==0 else fit(divide(n,d,i['mode']),'quotientOverflow') if op=='mulDiv' else {'ok':divide(n,d,i['mode'])}
 elif op in ['feeFromGross','feeOnTop']:
  a=i.get('gross',i.get('principal'));n,d=i['num'],i['den']
  if d==0 or n>d:actual=err('invalidRate')
  else:
   fee=divide(a*n,d,i['mode']);charged=a if op=='feeFromGross' else a+fee;received=a-fee if op=='feeFromGross' else a
   actual=err('addOverflow') if charged>=lim else dict(principal=a,fee=fee,charged=charged,received=received)
 elif op=='quantityRoundTrip':actual={'amount':str(Q(i['word'])*Q(i['scale'])),'word':i['word']}
 elif op=='fromRat':
  a,s=Q(i['amount']),Q(i['scale'])
  actual=err('nonPositiveScale') if s<=0 else err('negativeQuantity') if a<0 else err('nonIntegralQuantity') if (a/s).denominator!=1 else fit(int(a/s),'inputOverflow')
 elif op=='referenceTransfer':
  state={tuple(x['cell']):Q(x['balance']) for x in i['state']};ck(f['id']+'.16cells',len(state)==16)
  ck(f['id']+'.input_record',expected['input_observation']=={k:i[k] for k in ['state','capabilities']})
  ck(f['id']+'.4capabilities',len(i['capabilities'])==4)
  q=i['quote_call'];fee=divide(q['basis']*q['num'],q['den'],q['mode']);charged=q['basis'] if q['policy']=='gross' else q['basis']+fee;received=q['basis']-fee if q['policy']=='gross' else q['basis'];scale=Q(i['scale']);delta=collections.defaultdict(Q)
  for party,amount in [(i['payer'],-charged),(i['recipient'],received),(i['collector'],fee)]:delta[(i['domain'],party,i['asset'])]+=amount*scale
  def auth(right):
   return any(cap['live'] and cap['holder']==i['context']['principal'] and cap['domain']==i['context']['domain'] and cap['operation']==i['request']['operation'] and cap['right']==right for idx in i['request']['capabilityIds'] for cap in [i['capabilities'][idx]])
  ck(f['id']+'.invoke',auth({'invoke':True}));ck(f['id']+'.accounting',sum(delta.values())==0)
  refusal='unauthorizedDebit' if any(v<0 and not auth({'debit':list(c)}) for c,v in delta.items()) else 'insufficientFunds' if any(v+delta[c]<0 for c,v in state.items()) else None
  if refusal:actual={'input_observation':expected['input_observation'],'execution':err(refusal)}
  else:
   post=[{'cell':x['cell'],'balance':str(Q(x['balance'])+delta[tuple(x['cell'])])} for x in i['state']]
   actual={'input_observation':expected['input_observation'],'execution':{'ok':{'state':post,'capabilities':i['capabilities']}}}
 else:raise ValueError(op)
 ck(f['id']+'.independent_literal',actual==expected,{'computed':actual} if actual!=expected else None)
 ck(f['id']+'.honest_status',f['execution']=='not_run')
mut=j(PLAN/'mutation-inventory.json');ck('mutants.12',len(mut['mutants'])==12)
for m in mut['mutants']:
 ck(m['id']+'.references',m['designated'] in {f['id'] for f in fs} and m['separate_sibling'] in {f['id'] for f in fs})
 ck(m['id']+'.real_proposed_edit',m['needle']!=m['replacement'] and m['execution']=='not_run')
 ck(m['id']+'.global_disjoint',m['designated'] not in mut['global_positives'])
mp=j(PLAN/'runner-literal-adaptation-map.json');ck('adaptation.37',sum(x['literal_count'] for x in mp['files'])==37)
for f in mp['files']:
 raw=(ROOT/f['old_path']).read_text();actual=adapt(raw);ck(f['old_path']+'.adapted_hash',sha(actual.encode())==f['planned_text_sha256']);ck(f['old_path']+'.literal_inventory',len(re.findall('metatheory|Metatheory',raw))==f['literal_count'])
 for o in f['occurrences']:
  line=raw.splitlines()[o['line']-1];ck(f['old_path']+f'.line{o["line"]}.column{o["column"]}',line==o['source_line'] and sha(line.encode())==o['line_sha256'] and adapt(line)==o['adapted_line'])
 if f['old_path'].endswith('test_metatheory_mutation_runner.py'):
  # Execute only three inspected pure record constructors and literal assignments.
  tree=ast.parse(actual);nodes=[]
  for node in tree.body:
   if isinstance(node,ast.Assign) and all(isinstance(t,ast.Name) and t.id in ['INPUT_MODULE','AUDIT_MODULE','CHECKS'] for t in node.targets):nodes.append(node)
   elif isinstance(node,ast.FunctionDef) and node.name in ['mutation','specification','cases']:nodes.append(node)
  env={};exec(compile(ast.Module(body=nodes,type_ignores=[]),'<review-only-pure-case-records>','exec'),env);cases=env['cases']()
rc=j(PLAN/'runner-contract.json');ck('runner.literal65_records',cases==rc['cases']);ck('runner.exit_counts',dict(collections.Counter(str(c['exit']) for c in cases))=={'0':10,'1':5,'3':50});ck('runner.distinct65',len({c['name'] for c in cases})==65)
sc=j(PLAN/'scenario-map.json')['scenarios'];specs=list((PLAN/'specs').glob('*/spec.md'));text='\n'.join(p.read_text() for p in specs)
ids=re.findall(r'^#### Scenario: (\w\d+) ',text,re.M);ck('scenarios.exact36',len(sc)==36 and set(ids)=={s['id'] for s in sc});ck('requirements.16',len(re.findall(r'^### Requirement:',text,re.M))==16);ck('capabilities.4',len(specs)==4)
ck('tasks.22unchecked',len(re.findall(r'^- \[ \] ',(PLAN/'tasks.md').read_text(),re.M))==22)
ck('diagnostic.cartesian_count',16*16*3+16*16*17*2+16*17*17*2*2==27968)
for s in sc:ck(s['id']+'.fixtures_exist',set(s['fixtures'])<={f['id'] for f in fs});ck(s['id']+'.pending',s['status']=='planned_not_executed' and s['evidence_hash'] is None)
summary=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),kind='independent_static_planning_reconciliation',candidate=manifest['candidate'],actual_head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),count=len(checks),passed=sum(x['passed'] for x in checks),checks=checks,input_bindings=bind,limits=['No Lean implementation exists or was executed.','65 case constructors reconstructed statically; no CLI suite run.','45 literal expectations recomputed by review-only Python, not future production outputs.','27968 count is combinatorial, not a fresh diagnostic execution.'])
(OUT/'checks.json').write_text(json.dumps(summary,indent=2)+'\n');print(summary['count'],summary['passed']);print([x for x in checks if not x['passed']]);raise SystemExit(0 if all(x['passed'] for x in checks) else 1)
