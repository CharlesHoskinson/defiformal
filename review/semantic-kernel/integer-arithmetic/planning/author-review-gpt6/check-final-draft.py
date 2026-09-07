#!/usr/bin/env python3
"""Read-only plan checks with evidence output; no Lean or production runner runs."""
from pathlib import Path
from fractions import Fraction
import json,hashlib,re,collections,datetime,subprocess,sys
R=next(p for p in Path(__file__).resolve().parents if (p/'lean/lean-toolchain').is_file());P=R/'openspec/changes/checked-integer-financial-arithmetic';E=Path(__file__).resolve().parent
checks=[]
def check(b,label):
 checks.append({'label':label,'passed':bool(b)})
 if not b:raise AssertionError(label)
def read(n):return json.loads((P/n).read_text())
def sha(b):return hashlib.sha256(b).hexdigest()
def dump(n,d):(E/n).write_text(json.dumps(d,indent=2)+'\n')
before=json.loads((E/'input-binding-before.json').read_text())
for f in before['held_unique']:
 b=(R/f['path']).read_bytes();check(len(b)==f['bytes'] and sha(b)==f['sha256'],'held unchanged '+f['path'])
for f in before['review_inputs']:
 if not f['path'].startswith('openspec/'):
  check(sha((R/f['path']).read_bytes())==f['sha256'],'old source unchanged '+f['path'])
 check(sha((E/'before'/f['path']).read_bytes())==f['sha256'],'initial review snapshot '+f['path'])
fixtures=read('fixture-inventory.json')['fixtures'];check(len(fixtures)==45,'45 fixtures')
check(len(set(f['id'] for f in fixtures))==45,'unique45IDs');check(len(set(f['label'] for f in fixtures))==45,'unique45labels')
for f in fixtures:
 check(f['execution']=='not_run','unexecuted '+f['id'])
 x=f['inputs']; op=f['operation']; expected=f['expected'];actual=None
 if op=='referenceTransfer':
  c=x['quote_call'];n=c['basis']*c['num'];q,r=divmod(n,c['den']);fee=q+(c['mode']=='up' and r!=0);charged=c['basis'] if c['policy']=='gross' else c['basis']+fee;net=c['basis']-fee if c['policy']=='gross' else c['basis'];scale=Fraction(x['scale']);initial={tuple(z['cell']):Fraction(z['balance']) for z in x['state']};delta=collections.defaultdict(Fraction)
  for p,a in [(x['payer'],-charged),(x['recipient'],net),(x['collector'],fee)]:delta[(x['domain'],p,x['asset'])]+=a*scale
  check(len(initial)==16,'full16 entry cells '+f['id']);check(len(x['capabilities'])==4,'full4 caps '+f['id']);check(x['capabilities'][2]['live'] is False,'tombstone '+f['id'])
  error='unauthorizedDebit' if 1 not in x['request']['capabilityIds'] and any(v<0 for v in delta.values()) else 'insufficientFunds' if any(v+delta[c]<0 for c,v in initial.items()) else None
  out=expected['execution'];check(out.get('error')==error if error else 'ok' in out,'exact literal reference result '+f['id'])
  if not error:
   table={tuple(z['cell']):Fraction(z['balance']) for z in out['ok']['state']};check(set(table)==set(initial),'complete output cells '+f['id']);check(all(table[c]==v+delta[c] for c,v in initial.items()),'independent rational ledger sums '+f['id']);check(out['ok']['capabilities']==x['capabilities'],'full output store '+f['id'])
  check(expected['input_observation']=={'state':x['state'],'capabilities':x['capabilities']},'literal retained input '+f['id']);continue
 if op=='ofNat':actual={'ok':x['n']} if x['n']<2**x['w'] else {'error':'inputOverflow'}
 elif op in ['add','mul','sub']:
  n=x['a']+x['b'] if op=='add' else x['a']*x['b'] if op=='mul' else x['a']-x['b'];error='subUnderflow' if n<0 else op+'Overflow' if n>=2**x['w'] else None;actual={'error':error} if error else {'ok':n}
 elif op in ['mulDiv','divideNat']:
  n=x['a']*x['b'] if op=='mulDiv' else x['numerator'];d=x['d'] if op=='mulDiv' else x['denominator']
  if d==0:actual={'error':'divisionByZero'}
  else:
   q,r=divmod(n,d);q+=x['mode']=='up' and r!=0;actual={'error':'quotientOverflow'} if op=='mulDiv' and q>=2**x['w'] else {'ok':q}
 elif op in ['feeFromGross','feeOnTop']:
  if x['den']==0 or x['num']>x['den']:actual={'error':'invalidRate'}
  else:
   basis=x.get('gross',x.get('principal'));q,r=divmod(basis*x['num'],x['den']);fee=q+(x['mode']=='up' and r!=0);charged=basis if op=='feeFromGross' else basis+fee;received=basis-fee if op=='feeFromGross' else basis;actual={'error':'addOverflow'} if charged>=2**x['w'] else dict(principal=basis,fee=fee,charged=charged,received=received)
 elif op=='quantityRoundTrip':actual={'amount':str(Fraction(x['word'])*Fraction(x['scale'])),'word':x['word']}
 elif op=='fromRat':
  amount,scale=Fraction(x['amount']),Fraction(x['scale']);error='nonPositiveScale' if scale<=0 else 'negativeQuantity' if amount<0 else 'nonIntegralQuantity' if (amount/scale).denominator!=1 else 'inputOverflow' if amount/scale>=2**x['w'] else None;actual={'error':error} if error else {'ok':int(amount/scale)}
 check(actual==expected,'literal mathematical expectation '+f['id'])
mutants=read('mutation-inventory.json');check(len(mutants['mutants'])==12,'12 mutations')
labels={f['label'] for f in fixtures}
for m in mutants['mutants']:
 check(m['needle'] and m['replacement']!=m['needle'],'nonidentity proposed edit '+m['id']);check(set(m['required_false'])<=labels,'designated exists '+m['id']);check(m['sibling_check'] in labels and m['sibling_check'] not in m['required_false'],'separate sibling exists '+m['id']);check(not set(m['required_false'])&set(mutants['global_positive_checks']),'global protected differs '+m['id'])
# Exact text transformation only: compile Python in memory, do not run the adapted harness.
def adapt(s):return s.replace('DefiKernel.Metatheory.Audit','DefiKernel.Arithmetic.RuntimeAudit').replace('check_metatheory_mutations.py','check_integer_arithmetic_mutations.py').replace('test_metatheory_mutation_runner.py','test_integer_arithmetic_runner.py').replace('Metatheory','Arithmetic').replace('metatheory','arithmetic').replace("'Audit.lean'","'RuntimeAudit.lean'")
lm=read('runner-literal-adaptation-map.json');check(lm['count']==37,'37 namespace-family literals')
for f in lm['files']:
 source=(R/f['old_path']).read_text();check(sha(source.encode())==f['old_sha256'],'old runner binding '+f['old_path']);planned=adapt(source);check(sha(planned.encode())==f['planned_text_sha256'],'planned adaptation SHA '+f['new_path']);compile(planned,f['new_path'],'exec');check(True,'planned Python syntax only '+f['new_path']);check('Metatheory' not in planned and 'metatheory' not in planned,'all old namespace literals adapted '+f['new_path']);check("'Audit.lean'" not in planned,'runtime root filename coherent '+f['new_path'])
 for hit in f['occurrences']:
  line=source.splitlines()[hit['line']-1];check(line==hit['source_line'] and line[hit['column']-1:hit['column']-1+len(hit['literal'])]==hit['literal'] and adapt(line)==hit['adapted_line'],'literal exact position '+str(hit['line'])+' '+f['old_path'])
c=read('runner-contract.json');check(len(c['cases'])==65,'65 cases');check(collections.Counter(x['exit'] for x in c['cases'])=={0:10,1:5,3:50},'10/5/50 cases');check(len(set(x['name'] for x in c['cases']))==65,'unique65names');check(len(c['typing_controls'])==2 and len(c['artifact_reconciliation_controls'])==4,'separate2typing4artifactcontrols');check(len(read('projection-inventory.json')['modules'])==9,'9 production module roots');check(len(read('proof-contract.json')['proofs'])==16,'16 universal obligations')
sc=read('scenario-map.json')['scenarios'];check(len(sc)==36,'36 scenarios');tasktext=(P/'tasks.md').read_text();check(tasktext.count('- [ ] ')==22 and '- [x]' not in tasktext,'22 unchecked tasks');check(tasktext.count('  - Verification: ')==22,'all22 tasks verification')
for row in sc:check(row['tasks'] and row['categories'] and row['evidence_hash'] is None and row['status']=='planned_not_executed','scenario honest '+row['id'])
check(16*16*3+16*16*17*2+16*17*17*4==27968,'finite diagnostic domain count only')
proc=subprocess.run(['openspec','validate','checked-integer-financial-arithmetic','--strict','--json'],cwd=R,capture_output=True,text=True);dump('strict-validation.json',{'command':proc.args,'exit':proc.returncode,'stdout':proc.stdout,'stderr':proc.stderr});check(proc.returncode==0,'strict OpenSpec valid')
context=[]
for f in before['review_inputs']:
 if not f['path'].startswith('openspec/'):context.append(f['path'])
context+=['AGENTS.md','lean/DefiKernel/AxiomAudit.lean','lean/DefiKernel.lean','lean/lakefile.toml','lean/lean-toolchain','lean/lake-manifest.json','docs/research/semantic-kernel-progress.md']
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();bindings=[]
for path in sorted(set(context)):
 b=(R/path).read_bytes();blob=subprocess.check_output(['git','rev-parse',head+':'+path],cwd=R,text=True).strip();check(subprocess.check_output(['git','cat-file','blob',blob],cwd=R)==b,'source actual Git bytes '+path);bindings.append(dict(path=path,sha256=sha(b),bytes=len(b),git_blob=blob))
dump('source-bindings.json',dict(head=head,inputs=bindings,dependency_status='Current accepted Typed/Metatheory APIs only; no pending S10 runtime dependency. Refreeze exact source context and review status before official planning review.'))
dump('final-checks.json',{'status':'PASS_AUTHOR_DRAFT_ONLY','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head_before':before['head'],'head_after':head,'held_counts':before['held_sets'],'held_unique_unchanged':len(before['held_unique']),'checks_passed':len(checks),'checks':checks,'counts':{'capabilities':4,'requirements':16,'scenarios':36,'tasks':22,'fixtures':45,'mutants':12,'inherited_cli_controls':65,'typing_controls':2,'artifact_controls':4,'planned_universal_obligations':16},'execution_limits':'Python Fraction/integer recomputation validates authored literals only; no Lean build, production mutant, inherited CLI execution, or new27968-case diagnostic execution performed. Planned Python text syntax checked in memory, no new scripts implemented.','python':sys.version})
print('PASS author checks',len(checks))
