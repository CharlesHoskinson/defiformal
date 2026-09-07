#!/usr/bin/env python3
"""Render an author OpenSpec inventory, not arithmetic implementation."""
from pathlib import Path
import json

HERE=Path(__file__).resolve().parent
ROOT=next(p for p in HERE.parents if (p/'.git').exists())
CHANGE=ROOT/'openspec/changes/checked-integer-financial-arithmetic'

CAPABILITIES={
 'checked-unsigned-arithmetic':[
  ('UW01','Bound words without silent coercion','Construction SHALL return the exact natural value below2^w or inputOverflow, with no modular truncation.',[
   ('W01','255 and256 are constructed at width8','255 succeeds unchanged and256 returns inputOverflow.'),
   ('W02','width0 is used as a mathematical boundary case','only0 is representable; no hardware-width claim follows.')]),
  ('UW02','Check addition and subtraction','Addition and subtraction SHALL characterize overflow and underflow before returning bounded words.',[
   ('W03','254+1 and255+1 are evaluated at width8','the first returns255 and the second addOverflow.'),
   ('W04','0-1 is evaluated','subUnderflow is returned rather than zero or a wrapped value.')]),
  ('UW03','Distinguish checked multiplication from full-product division','Checked multiplication SHALL reject an out-of-range product, while mulDiv SHALL preserve the exact intermediate natural product.',[
   ('W05','16*16 is checked at width8','mulOverflow is returned.'),
   ('W06','200*2/2 is evaluated by full-product mulDiv at width8','200 is returned although the intermediate product exceeds255.')]),
  ('UW04','Prove exact success and refusal contracts','Every exported arithmetic operation SHALL have a universal specification with exact result bounds and error conditions, independent of sampled tests.',[
   ('W07','an arbitrary valid pair of words is evaluated','success iff the mathematical result fits and the correct operation-specific refusal otherwise is proved.'),
   ('W08','a four-bit exhaustive comparison passes','it remains bounded execution and does not replace the generic Lean theorem.')]),
 ],
 'directed-rounding-fees':[
  ('RF01','Specify directed quotient results','For a positive denominator, floor and ceiling SHALL satisfy their independent quotient inequalities; zero denominator SHALL be refused first.',[
   ('R01','7*5/3 is rounded in both directions','floor returns11 and ceiling12.'),
   ('R02','denominator0 is supplied even when the product is large','divisionByZero precedes any quotient-overflow decision.')]),
  ('RF02','Handle exactness and final overflow','Ceiling SHALL add one exactly for nonzero remainder and SHALL check the rounded final word bound.',[
   ('R03','6*5/3 is rounded upward','10 is returned without an extra unit.'),
   ('R04','254*254/253 is rounded at width8','floor255 succeeds and ceiling returns quotientOverflow.')]),
  ('RF03','Keep fee conventions explicit','feeFromGross and feeOnTop SHALL validate the rate first and retain their distinct charged/received definitions.',[
   ('R05','gross100 at rate1/3 is charged downward and upward','gross charging returns net67/fee33 or net66/fee34 respectively.'),
   ('R06','principal100 at rate1/3 is charged on top upward','charged134, received100 and fee34 are returned.'),
   ('R07','denominator0 or numerator greater than denominator is supplied to a fee API','invalidRate is returned before any arithmetic subcall failure.')]),
  ('RF04','Prove fee conservation and qualified representability','Successful quotes SHALL satisfy charged=received+fee; a valid gross-based quote SHALL fit, while an on-top quote MAY refuse addition overflow.',[
   ('R08','principal255 and rate1/1 are charged on top at width8','addOverflow is returned.'),
   ('R09','gross0 or a valid rate300/600 is used at width8','zero remains zero; the wide natural rate yields fee50/net50 for gross100 without word truncation.'),
   ('R10','rounded output is compared with exact rational division','the directed error bound is proved and equality is claimed only under divisibility or the explicitly rounded specification.')]),
 ],
 'integer-quantity-correspondence':[
  ('IQ01','Convert with explicit asset scale','Quantity conversion SHALL preserve the named asset and positive scale, and inverse conversion SHALL reject negative, fractional or overflowing values.',[
   ('Q01','word7 is converted at scale1/4 and converted back','amount7/4 and the original word7 are obtained.'),
   ('Q02','amount7/8 at scale1/4 is converted to a word','nonIntegralQuantity is returned.'),
   ('Q03','nonpositive scale and negative amount occur together','nonPositiveScale takes precedence; with positive scale the negative amount returns negativeQuantity.')]),
  ('IQ02','Prove conversion and dimensional boundaries','Same-scale round trips and exact successful conversion SHALL be proved, while cross-asset misuse SHALL remain a separate typing control.',[
   ('Q04','an in-range natural multiple of a positive scale is supplied','successful inverse conversion is characterized exactly.'),
   ('Q05','a quantity of one asset is supplied where another indexed asset is required','the deliberate type mismatch is reported as compiler rejection, not a runtime semantic mutant.')]),
  ('IQ03','Connect quotes to the actual typed executor','A registered quote-derived reference template SHALL use the existing typed executor and retain full state/capability results and exact refusals.',[
   ('Q06','a valid downward gross100 fee transfer starts with payer200 and empty recipient/collector','the actual executor succeeds with balances100/67/33 and the unchanged capability store.'),
   ('Q07','recipient and collector are the same cell','the actual aggregate credit is100 and accounting remains balanced.'),
   ('Q08','balance is99 or invoke authority exists but the required debit is unauthorized','the exact insufficientFunds or unauthorizedDebit refusal is observed with the original inputs preserved.')]),
  ('IQ04','Limit the reference correspondence','Reference results SHALL expose quote/template/scale/authority premises and SHALL NOT imply dynamic pricing, arbitrary template correctness, sequential token-debit fidelity or deployment verification.',[
   ('Q09','the fee collector credit is dropped from the constructed template','the actual executor fails the expected successful full-state comparison and a balanced sibling succeeds.'),
   ('Q10','a rational conservation proof is presented as a deployed protocol refinement','the claim is rejected as outside the encoded arithmetic/reference evidence.')]),
 ],
 'integer-arithmetic-evidence':[
  ('IE01','Freeze a complete executable evidence contract','Before implementation the candidate SHALL bind all runtime fixtures, literal mutants, runner controls, dependency inputs and proof/audit roots and pass both required planning reviews.',[
   ('E01','only author OpenSpec validation has passed','implementation and scientific acceptance remain pending.'),
   ('E02','a helper or audit root is absent from the package manifest','official freeze or evidence acceptance is blocked rather than inferred from directory names.')]),
  ('IE02','Require actual mutation sensitivity','Every semantic mutant SHALL compile, change production behavior, fail its designated independent observation and preserve global and separate sibling positives.',[
   ('E03','a source edit compiles but all observations still pass','the mutation is not counted as detected.'),
   ('E04','a mutant cannot compile or its positive controls fail','the attempt is classified separately and cannot certify mutation sensitivity.')]),
  ('IE03','Audit proof closure and nonempty observations','Acceptance SHALL dynamically audit imported theorem/supplemental declarations and bind nonempty actual runtime, compiler and runner results to exact source/tool identities.',[
   ('E05','a forbidden axiom, unbound source, forged summary or zero-check report is supplied','acceptance fails or blocks at the appropriate declared evidence boundary.'),
   ('E06','a bounded independent arithmetic oracle agrees','its precise finite domain and interpreter are retained and no chain-fidelity claim follows.')]),
  ('IE04','Deliver only the independently reviewed scope','Final native Grok/Fable reviews, scenario reconciliation and branch delivery SHALL precede scoped completion, while later signed/protocol/runtime work remains explicit.',[
   ('E07','a native reviewer is unavailable or returns no substantive verdict','the review remains open and the response is preserved.'),
   ('E08','unsigned arithmetic and reference results pass','only their scope is archived; signed funding, protocol libraries and deployed adapters remain separate obligations.')]),
 ]}

FIXTURES=[
 ('F01','ofNat',{'w':8,'n':255},{'ok':255}),('F02','ofNat',{'w':8,'n':256},{'error':'inputOverflow'}),
 ('F03','add',{'w':8,'a':254,'b':1},{'ok':255}),('F04','add',{'w':8,'a':255,'b':1},{'error':'addOverflow'}),
 ('F05','sub',{'w':8,'a':0,'b':1},{'error':'subUnderflow'}),('F06','mul',{'w':8,'a':16,'b':16},{'error':'mulOverflow'}),
 ('F07','mulDiv',{'w':8,'a':200,'b':2,'d':2,'mode':'down'},{'ok':200}),
 ('F08','mulDiv',{'w':8,'a':255,'b':255,'d':0,'mode':'down'},{'error':'divisionByZero'}),
 ('F09','mulDiv',{'w':8,'a':7,'b':5,'d':3,'mode':'down'},{'ok':11}),
 ('F10','mulDiv',{'w':8,'a':7,'b':5,'d':3,'mode':'up'},{'ok':12}),
 ('F11','mulDiv',{'w':8,'a':6,'b':5,'d':3,'mode':'up'},{'ok':10}),
 ('F12','mulDiv',{'w':8,'a':254,'b':254,'d':253,'mode':'down'},{'ok':255}),
 ('F13','mulDiv',{'w':8,'a':254,'b':254,'d':253,'mode':'up'},{'error':'quotientOverflow'}),
 ('F14','feeFromGross',{'w':8,'gross':100,'num':1,'den':3,'mode':'down'},{'principal':100,'fee':33,'charged':100,'received':67}),
 ('F15','feeFromGross',{'w':8,'gross':100,'num':1,'den':3,'mode':'up'},{'principal':100,'fee':34,'charged':100,'received':66}),
 ('F16','feeOnTop',{'w':8,'principal':100,'num':1,'den':3,'mode':'up'},{'principal':100,'fee':34,'charged':134,'received':100}),
 ('F17','feeOnTop',{'w':8,'principal':255,'num':1,'den':1,'mode':'up'},{'error':'addOverflow'}),
 ('F18','feeFromGross',{'w':8,'gross':100,'num':0,'den':0,'mode':'down'},{'error':'invalidRate'}),
 ('F19','feeFromGross',{'w':8,'gross':100,'num':2,'den':1,'mode':'down'},{'error':'invalidRate'}),
 ('F20','feeFromGross',{'w':8,'gross':0,'num':1,'den':3,'mode':'up'},{'principal':0,'fee':0,'charged':0,'received':0}),
 ('F21','quantityRoundTrip',{'w':8,'word':7,'scale':'1/4'},{'amount':'7/4','word':7}),
 ('F22','fromRat',{'w':8,'amount':'7/8','scale':'1/4'},{'error':'nonIntegralQuantity'}),
 ('F23','fromRat',{'w':8,'amount':'-1','scale':'0'},{'error':'nonPositiveScale'}),
 ('F24','fromRat',{'w':8,'amount':'-1','scale':'1'},{'error':'negativeQuantity'}),
 ('F25','referenceTransfer',{'gross':100,'num':1,'den':3,'mode':'down','payer_balance':200,'same_recipient_collector':False},{'balances':[100,67,33],'capabilities':'exact_entry_store','other_cells':'unchanged','result':'ok'}),
 ('F26','referenceTransfer',{'gross':100,'num':1,'den':3,'mode':'down','payer_balance':200,'same_recipient_collector':True},{'payer':100,'recipient_and_collector':100,'capabilities':'exact_entry_store','other_cells':'unchanged','result':'ok'}),
 ('F27','referenceTransfer',{'gross':100,'num':1,'den':3,'mode':'down','payer_balance':99,'same_recipient_collector':False},{'error':'insufficientFunds','original_inputs':'preserved'}),
 ('F28','referenceTransfer',{'gross':100,'payer_balance':200,'invoke_allowed':True,'debit_allowed':False},{'error':'unauthorizedDebit','original_inputs':'preserved'}),
 ('F29','feeFromGross',{'w':8,'gross':100,'num':300,'den':600,'mode':'down'},{'principal':100,'fee':50,'charged':100,'received':50}),
 ('F30','ofNat',{'w':0,'n':0},{'ok':0}),('F31','ofNat',{'w':0,'n':1},{'error':'inputOverflow'}),
]

MUTATIONS=[
 ('M01','Operations.add','wrap overflowing addition','F04','F14'),
 ('M02','Operations.sub','skip underflow check and return natural subtraction','F05','F14'),
 ('M03','Rounding.mulDiv','truncate intermediate product modulo2^w','F07','F14'),
 ('M04','Rounding.mulDiv','return zero for zero denominator','F08','F14'),
 ('M05','Rounding.floor branch','round nonexact floor upward','F09','F11'),
 ('M06','Rounding.ceiling branch','round nonexact ceiling downward','F10','F14'),
 ('M07','Rounding.ceiling branch','add one on exact division','F11','F14'),
 ('M08','Rounding.final bound','wrap the overflowing final quotient','F13','F14'),
 ('M09','Fees.rate check','accept an over-unit rate by clamping it','F19','F14'),
 ('M10','Fees.feeFromGross','return gross as received without subtracting fee','F14','F07'),
 ('M11','Quantity.toQuantity','ignore the positive scale','F21','F14'),
 ('M12','Reference.template','omit collector credit','F25','F14'),
]

TASKS=[
 ('1.1','Finish exact fixture environments, quoted mutation edits, projection inventory and literal runner controls; bind current Typed/runner/toolchain inputs before official freeze.'),
 ('1.2','Validate this OpenSpec candidate and obtain nonauthor GPT-6/native Fable5.1 medium planning verdicts on the identical complete bundle.'),
 ('1.3','Run the accepted current Lean and relevant runner baseline before implementation, saving actual commands and dependency bytes.'),
 ('2.1','Create Arithmetic/Word.lean and Operations.lean with ofNat/add/sub/mul; implement F01–F06/F30–F31 and universal exact success/refusal proofs.'),
 ('2.2','Create Rounding.lean with independent unbounded quotient specifications and full-product mulDiv; implement F07–F13 and prove zero-denominator precedence.'),
 ('2.3','Prove independent floor/ceiling inequalities, exactness, directed rational error bounds and qualified monotonicity, including final-word overflow.'),
 ('2.4','Create Fees.lean with natural rate parameters and separate gross/on-top policies; implement F14–F20/F29 and prove charged=received+fee and qualified fit.'),
 ('2.5','Create Quantity.lean with toQuantity/fromRat; implement F21–F24 and prove scale-aware round trips and exact conversion characterization.'),
 ('3.1','Create Reference.lean with quote-derived registered templates over the actual accepted Typed API and explicit authority/scale/footprint premises.'),
 ('3.2','Create independent full-result fixture worlds and capabilities for F25–F28; verify exact aggregate state, unchanged store and located refusal semantics without a replacement trusted executor.'),
 ('3.3','Prove reference effect accounting and actual-executor correspondence, including coincident targets and the current net-effect interpretation.'),
 ('3.4','Add isolated wrong-asset compiler controls with a valid same-asset sibling; record compiler rejection separately from semantic mutations.'),
 ('4.1','Create Examples.lean/Tests.lean and evaluate every frozen named literal fixture; retain complete input/results and no self-generated expected observations.'),
 ('4.2','Run the independently coded finite Python divmod diagnostic oracle against named Lean observations on its exact frozen domain; keep this separate from universal proof and chain fidelity.'),
 ('4.3','Create Arithmetic/Audit.lean and Verify.lean, with explicit package roots, dynamic theorem/supplemental inventories, full types and transitive axiom checks.'),
 ('4.4','Implement the dedicated mutation projection and actual runtime edits M01–M12; require designated failures, F01/F03 global positives and separate sibling positives.'),
 ('4.5','Implement literal runner controls for empty, missing, malformed, drifted and forged evidence, wrong-world observations, missing package members and audit-root errors; verify declared exits and positive siblings.'),
 ('5.1','Run lake build DefiKernel.Arithmetic.Verify and lake env lean DefiKernel/Arithmetic/Verify.lean from lean/, plus the complete new runner/control suite.'),
 ('5.2','Run relevant prior regressions for imported/changed runner and kernel integration paths, binding actual source identities and preserving all prior evidence.'),
 ('5.3','Reconcile every scenario to actual generic/instance/finite/compiler/mutation/assumption evidence and record failed development attempts without changing their bytes.'),
 ('5.4','Freeze final source and complete evidence; obtain substantive native Grok/Fable5.1 medium reviews and fix concrete findings before scoped acceptance.'),
 ('5.5','Deliver the accepted branch through parent-owned commit/push/readback, synchronize the four main specs and archive the OpenSpec change with remaining arithmetic/protocol limitations explicit.'),
]

def main():
    scenarios=[]
    for capability,requirements in CAPABILITIES.items():
        path=CHANGE/'specs'/capability/'spec.md';path.parent.mkdir(parents=True,exist_ok=True)
        text='## ADDED Requirements\n\n'
        for rid,title,requirement,cases in requirements:
            text+=f'### Requirement: {rid} {title}\n\n{requirement}\n\n'
            for sid,when,then in cases:
                text+=f'#### Scenario: {sid} {when}\n\n- **WHEN** {when}\n- **THEN** {then}\n\n'
                scenarios.append({'id':sid,'capability':capability,'requirement':rid,'when':when,'then':then,'status':'planned_not_executed'})
        with path.open('x') as f:f.write(text)
    tasks='''# Checked integer financial arithmetic implementation plan

> For agentic workers: use superpowers:executing-plans or the authorized stock-harness subagent workflow after the required planning gate.

**Goal:** Implement checked unsigned arithmetic, directed fees and a dimensioned reference accounting bridge.

**Architecture:** Pure bounded-word operations have independent mathematical specifications; fee quotes and scale conversion feed a registered existing-kernel reference template. Proof, finite execution, typing and mutation evidence remain separate.

**Tech stack:** Pinned Lean/mathlib, Python3 diagnostic/runner scripts, OpenSpec and native Grok/Fable reviews. Existing source/tool identities must be bound before implementation.

All new source paths are listed in design section5. Function signatures, numeric/error contracts and fixture inputs are fixed in the design and fixture-inventory.json. This author draft is not the final runner-control freeze.

'''
    for tid,task in TASKS:tasks+=f'- [ ] {tid} {task}\n'
    with (CHANGE/'tasks.md').open('x') as f:f.write(tasks)
    objects={
        'scenario-map.json':{'status':'AUTHOR_DRAFT_NOT_ACCEPTANCE','scenarios':scenarios},
        'fixture-inventory.json':{'status':'PROPOSED_LITERAL_EXPECTATIONS_NOT_RUN','fixtures':[{'id':i,'operation':op,'inputs':args,'expected':out,'execution':'not_run'} for i,op,args,out in FIXTURES],
          'pre_freeze_obligation':'Complete literal reference worlds/capability IDs/configuration and typing controls; no symbolic expected-store placeholder may remain in official executable expectations.'},
        'mutation-inventory.json':{'status':'PROPOSED_RUNTIME_TARGETS_NOT_RUN','global_positives':['F01','F03'],
            'mutants':[{'id':i,'target':target,'change':change,'designated':designated,'separate_sibling':sibling,'execution':'not_run'} for i,target,change,designated,sibling in MUTATIONS],
            'pre_freeze_obligation':'Bind literal production edits and complete projection/runner controls before official planning review.'}}
    for name,obj in objects.items():
        with (CHANGE/name).open('x') as f:json.dump(obj,f,indent=2);f.write('\n')
    print(json.dumps({'capabilities':len(CAPABILITIES),'requirements':sum(len(r) for r in CAPABILITIES.values()),
        'scenarios':len(scenarios),'unchecked_tasks':len(TASKS),'planned_fixtures':len(FIXTURES),'planned_mutations':len(MUTATIONS)}))

if __name__=='__main__':main()
