#!/usr/bin/env python3
"""Render frozen literal fixtures; expected records never call a production computation."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
plan=ROOT/'openspec/changes/checked-integer-financial-arithmetic/fixture-inventory.json'
data=json.loads(plan.read_text());fixtures=data['fixtures'];assert len(fixtures)==45
OUT=ROOT/'lean/DefiKernel/Arithmetic'
def rat(s): return '('+str(s)+')'
def word(n,w=8): return f'(⟨{n}, by decide⟩ : Word {w})'
def caps(cs):
 rows=[]
 for c in cs:
  right='.invoke' if 'invoke' in c['right'] else '.debit ('+', '.join('.'+x for x in c['right']['debit'])+')'
  rows.append('⟨⟨.'+c['holder']+', .'+c['domain']+', ⟨'+str(c['operation'])+'⟩, '+right+'⟩, '+str(c['live']).lower()+'⟩')
 return '⟨['+',\n    '.join(rows)+']⟩'
def state(name,rows):
 assert [r['cell'] for r in rows]==data['finite_universe']['ordered_cells']
 text=f'def {name} : State Party Asset Domain where\n  balance\n'
 for row in rows:text+='    | ('+', '.join('.'+x for x in row['cell'])+') => '+rat(row['balance'])+'\n'
 text+='  nonneg := by\n    intro ⟨d, p, a⟩\n    cases d <;> cases p <;> cases a <;> norm_num\n\n'
 return text
s='''import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Reference

/-! Frozen F01–F45 literal fixtures. Expected values are separate literal tables.
All reference ledgers cover sixteen cells, including protected cells with balance nine.
F40/F41 use aggregate net effects with payer coincidence, not gross debit-order semantics. -/
namespace DefiKernel.Arithmetic.Examples
open Typed

inductive Party | alice | bob | treasury | observer
  deriving DecidableEq, Repr
inductive Asset | usd | alt
  deriving DecidableEq, Repr
inductive Domain | «local» | remote
  deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.alice, .bob, .treasury, .observer}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .alt}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.local, .remote}, by intro d; cases d <;> simp⟩

abbrev C := Cell Party Asset Domain
abbrev WordResult := Except Arithmetic.Failure Nat
abbrev QuoteResult := Except Arithmetic.Failure (Nat × Nat × Nat × Nat)
abbrev ReferenceObservation := (State Party Asset Domain × CapabilityStore Party Asset Domain) ×
  Except Refusal (ExecutionResult Party Asset Domain)

inductive PureObservation
  | word (result : WordResult)
  | quote (result : QuoteResult)
  | quantity (amount : ℚ) (result : WordResult)

'''
s+='def allCells : List C :=\n  ['+',\n    '.join('('+', '.join('.'+x for x in c)+')' for c in data['finite_universe']['ordered_cells'])+']\n\n'
s+='def literalInputs : List String :=\n  ['+',\n    '.join(json.dumps(f['label']) for f in fixtures)+']\n\n'
refs=[f for f in fixtures if f['operation']=='referenceTransfer']
cs=refs[0]['inputs']['capabilities'];assert len(cs)==4
assert all(f['inputs']['capabilities']==cs and f['expected']['input_observation']['capabilities']==cs for f in refs)
s+='def entryStore : CapabilityStore Party Asset Domain :=\n  '+caps(cs)+'\n\n'
s+='def expectedStore : CapabilityStore Party Asset Domain :=\n  '+caps(refs[0]['expected']['input_observation']['capabilities'])+'\n\n'
s+='def referenceContext : InvocationContext Party Domain := ⟨.alice, .local⟩\n\n'
s+='def referenceEnvironment : Environment Asset Domain := fun _ ↦ none\n\n'
actual=[];expected=[]
for f in fixtures:
 i=f['inputs'];e=f['expected'];op=f['operation'];w=i.get('w',8);label=f['label']
 if op=='referenceTransfer':continue
 if op=='ofNat':exp=f'ofNat {w} {i["n"]}'
 elif op in ['add','sub','mul']:exp=f'Operations.{op}\n        {word(i["a"],w)} {word(i["b"],w)}'
 elif op=='mulDiv':exp=f'Rounding.mulDiv .{i["mode"]}\n        {word(i["a"],w)} {word(i["b"],w)} {i["d"]}'
 elif op=='fromRat':exp=f'Quantity.fromRat {w} {rat(i["scale"])} {rat(i["amount"])}'
 elif op=='divideNat':exp=f'Rounding.divideNat .{i["mode"]} {i["numerator"]} {i["denominator"]}'
 elif op in ['feeFromGross','feeOnTop']:
  basis=i.get('gross',i.get('principal'));exp=f'Fees.{op} .{i["mode"]} {word(basis,w)} {i["num"]} {i["den"]}'
 elif op=='quantityRoundTrip':
  exp=f'let q := Quantity.toQuantity Asset.usd {rat(i["scale"])} (by norm_num) {word(i["word"],w)}\n      .quantity q.amount ((Quantity.fromRat {w} {rat(i["scale"])} q.amount).map Word.value)'
 else:raise ValueError(op)
 if op in ['feeFromGross','feeOnTop']:
  value='.quote (('+exp+').map\n      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))'
  expect='.quote (.error .'+e['error']+')' if 'error' in e else '.quote (.ok ('+', '.join(str(e[k]) for k in ['principal','fee','charged','received'])+'))'
 elif op=='quantityRoundTrip':value=exp;expect=f'.quantity {rat(e["amount"])} (.ok {e["word"]})'
 else:
  value='.word ('+exp+')' if op=='divideNat' else '.word (('+exp+').map Word.value)'
  expect='.word (.error .'+e['error']+')' if 'error' in e else '.word (.ok '+str(e['ok'])+')'
 actual.append('('+json.dumps(label)+',\n      '+value+')');expected.append('('+json.dumps(label)+', '+expect+')')
s+='def pureCases : List (String × PureObservation) :=\n  ['+',\n    '.join(actual)+']\n\n'
s+='def expectedPureCases : List (String × PureObservation) :=\n  ['+',\n    '.join(expected)+']\n\n'
refactual=[];refexpected=[]
for f in refs:
 tag=f['id'].lower();i=f['inputs'];e=f['expected'];q=i['quote_call']
 s+=state('input'+f['id'],i['state']);s+=state('expectedInput'+f['id'],e['input_observation']['state'])
 if 'ok' in e['execution']:
  assert e['execution']['ok']['capabilities']==cs
  s+=state('expectedPost'+f['id'],e['execution']['ok']['state'])
  result='.ok ⟨expectedPost'+f['id']+', expectedStore⟩'
 else:result='.error .'+e['execution']['error']
 quote=f'Fees.{"feeFromGross" if q["policy"]=="gross" else "feeOnTop"} .{q["mode"]} {word(q["basis"])} {q["num"]} {q["den"]}'
 ids='['+', '.join('⟨'+str(n)+'⟩' for n in i['request']['capabilityIds'])+']'
 call='(do\n      let quote ← '+quote+'\n      return Reference.observeExecution\n        (Reference.registry ⟨7⟩ quote '+rat(i['scale'])+' .local .usd\n          .'+i['payer']+' .'+i['recipient']+' .'+i['collector']+')\n        entryStore referenceContext referenceEnvironment 23\n        (Reference.request ⟨7⟩ '+ids+') input'+f['id']+')'
 refactual.append('('+json.dumps(f['label'])+', '+call+')')
 refexpected.append('('+json.dumps(f['label'])+',\n      .ok ((expectedInput'+f['id']+', expectedStore), '+result+'))')
s+='def referenceCases : List (String × Except Arithmetic.Failure ReferenceObservation) :=\n  ['+',\n    '.join(refactual)+']\n\n'
s+='def expectedReferenceCases : List (String × Except Arithmetic.Failure ReferenceObservation) :=\n  ['+',\n    '.join(refexpected)+']\n\n-- BEGIN PROOFS\n\ntheorem allCells_complete (cell : C) : cell ∈ allCells := by\n  rcases cell with ⟨d, p, a⟩\n  cases d <;> cases p <;> cases a <;> simp [allCells]\n\nend DefiKernel.Arithmetic.Examples\n'
(OUT/'Examples.lean').write_text(s)
t='''import DefiKernel.Arithmetic.Examples

/-! Full observations are independent of production query/executor implementation. -/
namespace DefiKernel.Arithmetic.Tests
open Typed Examples

def wordResultEq (actual expected : WordResult) : Bool := decide (actual = expected)

def quoteResultEq (actual expected : QuoteResult) : Bool := decide (actual = expected)

def quantityEq (actualAmount expectedAmount : ℚ) (actualWord expectedWord : WordResult) : Bool :=
  decide (actualAmount = expectedAmount) && wordResultEq actualWord expectedWord

def pureObservationEq (actual expected : PureObservation) : Bool :=
  match actual, expected with
  | .word a, .word e => wordResultEq a e
  | .quote a, .quote e => quoteResultEq a e
  | .quantity a aw, .quantity e ew => quantityEq a e aw ew
  | _, _ => false

def stateEq (actual expected : State Party Asset Domain) : Bool :=
  allCells.all (fun cell ↦ decide (actual.balance cell = expected.balance cell))

def executionResultEq (actual expected : Except Refusal (ExecutionResult Party Asset Domain)) :
    Bool :=
  match actual, expected with
  | .error a, .error e => decide (a = e)
  | .ok a, .ok e => stateEq a.state e.state && decide (a.capabilities = e.capabilities)
  | _, _ => false

def referenceObservationEq (actual expected : Except Arithmetic.Failure ReferenceObservation) :
    Bool :=
  match actual, expected with
  | .error a, .error e => decide (a = e)
  | .ok a, .ok e => stateEq a.1.1 e.1.1 && decide (a.1.2 = e.1.2) &&
      executionResultEq a.2 e.2
  | _, _ => false

def runtimeChecks : List (String × Bool) :=
  literalInputs.map fun name ↦
    (name, match pureCases.lookup name, expectedPureCases.lookup name with
      | some actual, some expected => pureObservationEq actual expected
      | none, none => match referenceCases.lookup name, expectedReferenceCases.lookup name with
        | some actual, some expected => referenceObservationEq actual expected
        | _, _ => false
      | _, _ => false)

-- BEGIN PROOFS

theorem stateEq_iff (actual expected : State Party Asset Domain) :
    stateEq actual expected = true ↔ actual = expected := by
  unfold stateEq
  rw [List.all_eq_true]
  constructor
  · intro h
    have balances : actual.balance = expected.balance := by
      funext cell
      exact of_decide_eq_true (h cell (allCells_complete cell))
    cases actual
    cases expected
    simp_all
  · rintro rfl
    intro cell _
    simp

end DefiKernel.Arithmetic.Tests
'''
(OUT/'Tests.lean').write_text(t)
a=(ROOT/'lean/DefiKernel/Interface/Audit.lean').read_text().replace('Interface','Arithmetic').replace('Arithmetic.Audit','Arithmetic.RuntimeAudit')
(OUT/'RuntimeAudit.lean').write_text(a)
(OUT/'ProofAudit.lean').write_text('''import DefiKernel.Arithmetic.Word
import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Rounding
import DefiKernel.Arithmetic.Fees
import DefiKernel.Arithmetic.Quantity
import DefiKernel.Arithmetic.Reference
import DefiKernel.Arithmetic.RuntimeAudit
import DefiKernel.AxiomAudit

/-! Enumerate imported arithmetic declarations by module provenance. This root has no helpers. -/
#audit_axioms DefiKernel.Arithmetic
''')
(OUT/'Verify.lean').write_text('import DefiKernel.Arithmetic.RuntimeAudit\nimport DefiKernel.Arithmetic.ProofAudit\n')
Path(__file__).with_name('fixture-rendering.json').write_text(json.dumps({'fixture_plan_sha256':hashlib.sha256(plan.read_bytes()).hexdigest(),'fixture_count':45,'pure':37,'reference':8,'cells':16,'capability_records':4,'source_files':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [OUT/(n+'.lean') for n in ['Examples','Tests','RuntimeAudit','ProofAudit','Verify']]},'status':'RENDERED_NOT_EXECUTED','expected_derivation':'literal frozen expected JSON values; no production computation'},indent=2)+'\n')
print('Rendered45 literal fixtures,37 pure and8 actual reference calls; execution pending')
