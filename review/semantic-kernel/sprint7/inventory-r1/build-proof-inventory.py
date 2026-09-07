#!/usr/bin/env python3
"""Read-only source inventory; writes only Sprint7 evidence files."""
import collections, datetime, hashlib, json, pathlib, re, subprocess
ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = ROOT / 'review/semantic-kernel/sprint7'
CANDIDATE = '6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c'
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def rel(path): return path.relative_to(ROOT).as_posix()
def save(name, obj): (OUT/name).write_text(json.dumps(obj, indent=2, ensure_ascii=False)+'\n')
log=(OUT/'proof-types.log').read_text()
def rows(marker):
 return [json.loads(l.split(marker,1)[1]) for l in log.splitlines() if marker in l]
proofs=rows('INTERLEAVING_PROOF_JSON ')
supplemental=rows('INTERLEAVING_SUPPLEMENTAL_JSON ')
explicit={}; declarations={}; sources={}
for path in sorted((ROOT/'lean/DefiKernel/Interleaving').rglob('*.lean')):
 text=path.read_text(); lines=text.splitlines(); module='.'.join(path.relative_to(ROOT/'lean').with_suffix('').parts)
 frozen=subprocess.check_output(['git','show',f'{CANDIDATE}:{rel(path)}'],cwd=ROOT)
 assert frozen==path.read_bytes(),f'Source drift: {path}'
 sources[rel(path)]={'sha256':sha(path),'git_blob':subprocess.check_output(['git','rev-parse',f'{CANDIDATE}:{rel(path)}'],cwd=ROOT,text=True).strip(),'frozen_bytes_match':True}
 namespace=re.search(r'^namespace (\S+)',text,re.M).group(1) if re.search(r'^namespace (\S+)',text,re.M) else ''
 for match in re.finditer(r'^(?:(private|protected) )?(theorem|lemma|def|abbrev|structure|inductive) ([\w.]+)',text,re.M):
  private,kind,name=match.groups(); full=namespace+'.'+name
  start=match.start(); tail=text[start:]; statement=tail.split(':=',1)[0].strip() if kind in ('theorem','lemma') else tail.split('\n\n',1)[0]
  line=text[:start].count('\n')+1
  variables=[]
  for v in re.finditer(r'^variable[^\n]*(?:\n[ ]+[^\n]*)*',text[:start],re.M): variables.append(v.group(0))
  before=lines[max(0,line-4):line-1]
  decl={'name':full,'module':module,'source':rel(path),'line':line,'source_statement':statement,
        'section_variables':variables,'immediately_preceding_lines':before,'kind':kind,'private':bool(private)}
  declarations[full]=decl
  if kind in ('theorem','lemma'): explicit[full]=decl
allowed={'propext','Classical.choice','Quot.sound'}
assert proofs and supplemental
assert len({r['name'] for r in proofs})==len(proofs)
assert set(explicit)<=set(r['name'] for r in proofs),set(explicit)-set(r['name'] for r in proofs)
for row in proofs+supplemental: assert set(row['axioms'])<=allowed,row['name']
counterexamples={'missing_initialization_counterexample','missing_peer_stability_counterexample','missing_frame_support_counterexample'}
corollaries={'fragile_not_stable','empty_support_is_false'}
for row in proofs:
 name=row['name']; base=name.rsplit('.',1)[-1]
 if name in explicit:
  row.update(explicit[name]);row['declaration_origin']='explicit'
  if base in counterexamples: category='counterexample'
  elif base in corollaries: category='counterexample-corollary'
  elif '.InterferenceFixtures.' in name and base!='sound_target_frame': category='referenceinstance'
  else: category='genericproof'
  row['category']=category
  row['premises']='The elaborated statement is authoritative and includes section typeclass parameters. The source statement and prior section variables are retained for readability.'
  if base=='sound_target_frame': row['scope_note']='Generic in cfg, boundary, history, invocation, pre/post worlds and analyzed footprint; identity types are the finite Party/Asset/Domain fixture types.'
  if base in ['shared_step_total','shared_local_obligation']:
   row['scope_note']='No-supply total equality is proved without the own-invariant antecedent; local_obligation uses that equality to transport its parameterized invariant.'
 else:
  row['declaration_origin']='generated';row['category']='generated'
  row['source']='lean/'+row['module'].replace('.','/')+'.lean'
  owners=[n for n in declarations if declarations[n]['module']==row['module'] and (name.startswith(n+'.') or (name.startswith('_private.') and ('.'+n+'.') in name))]
  owner=max(owners,key=len) if owners else None
  row['source_owner']=owner
  row['line']=declarations[owner]['line'] if owner else None
  row['scope_note']='Generated theorem constant; owner line is attribution to the originating declaration when identifiable, not an explicit theorem statement line.'
for row in supplemental:
 name=row['name']; row['source']='lean/'+row['module'].replace('.','/')+'.lean'
 if name in declarations: row['source_declaration']=declarations[name];row['declaration_origin']='explicit'
 else: row['declaration_origin']='generated-or-private-elaboration'
verify=(OUT/'integration/02.log').read_text()
audit_names=re.findall(r'AXIOM AUDIT theorem: ([^;]+);',verify)
audit_supp=re.findall(r'AXIOM AUDIT declaration: ([^;]+);',verify)
assert set(audit_names)==set(x['name'] for x in proofs)
assert set(audit_supp)==set(x['name'] for x in supplemental)
limits={
 'worlds':'Every State carries a pointwise nonnegativity witness; runPrefix_nonnegative reuses this witness and is not a guard-inference or solvency theorem.',
 'authority':'Registry, catalog, domain administrator, authenticated local boundary and initial capability-store authenticity are trusted inputs. Only invocation branches execute; capabilities remain the initial complete store. No concurrent issue/revoke or consumed allowance semantics.',
 'arithmetic':'Exact mathematical rationals; no machine-width overflow, chain rounding, oracle truth or deployed source fidelity.',
 'rg':'LocalObligation quantifies over all selected positions, arbitrary histories/pre-worlds and successful StepSound results under its own invariant alone. Initialization, cross-inclusion and peer stability are independent mandatory premises; not automatically inferred.',
 'recovery':'Universal schedule recovery requires actual Parallel.admit success (including compatibility) and Complete counts; failures and retained prefixes are included. It does not assume successful-only execution or the desired observational equivalence.',
 'observation':'ProjectedEquivalent retains pointwise full ledger equality, complete capability store and exact labeled branch observations. Global order/attempt trace, consumed skipped slots and foreign raw event worlds are deliberately omitted.',
 'locality':'Actual/analyzed write framing requires exclusion of writes; lifting to predicates requires explicit Supports. The missing-support counterexample refutes unsupported framing.',
 'termination':'Finite provided token lists only; complete public schedules are checked. Exhausted/failed internal slots skip. No liveness, fairness, atomic rollback, generic shared commutation or arbitrary associativity.',
 'concrete_total':'USD10 relies on both actual no-supply templates; total-equality local proof does not need the own-invariant antecedent. All financial examples are development fixtures, not untouched holdouts.'}
record={'schema_version':1,'kind':'imported-interleaving-proof-inventory','candidate':CANDIDATE,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'discovery':'Lean environment importedTheorems/importedSupplemental with exact module provenance under DefiKernel.Interleaving, imported via Verify.lean','execution':json.loads((OUT/'proof-inventory-execution.json').read_text()),'counts':{'theorems':len(proofs),'supplemental':len(supplemental),'explicit_theorems':len(explicit),'categories':dict(collections.Counter(x['category'] for x in proofs)),'counterexample_families':3},'validation':{'nonempty':True,'all_explicit_source_theorems_imported':True,'theorem_names_exactly_match_fresh_verify':True,'supplemental_names_exactly_match_fresh_verify':True,'forbidden_axioms':0,'frozen_sources_match':True,'no_pretty_statement_ellipsis':all('⋯' not in r['statement'] for r in proofs)},'source_bindings':sources,'premise_and_scope_limits':limits,'theorems':proofs,'supplemental':supplemental}
save('proof-inventory.json',record)
print(json.dumps(record['counts'],indent=2))
