from pathlib import Path
import json,hashlib,datetime
r=Path('/private/tmp/defiformal-ci-author');files=[]
def add(name,ranges):
 p=r/name;n=len(p.read_text().splitlines());covered=[];parts=[]
 for start,end,cat in ranges:
  end=n if end is None else end;covered+=list(range(start,end+1));parts.append(dict(start=start,end=end,category=cat,lines=end-start+1))
 assert covered==list(range(1,n+1)),name
 files.append(dict(path=name,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),physical_lines=n,classification=parts))
add('lean/DefiKernel/Margin/Funding.lean',[(1,5,'guidance_support'),(6,103,'funding_model_and_provisioning'),(104,449,'mathematical_contracts_proofs_and_correspondence_support'),(450,455,'signed_valuation_model'),(456,493,'mathematical_contracts_and_proofs'),(494,None,'guidance_support')])
add('lean/DefiKernel/Margin/FundingAudit.lean',[(1,None,'finite_controls')])
add('scripts/replay_margin_funding.py',[(1,None,'replay_implementation')])
add('docs/examples/margin-funding.md',[(1,None,'guidance')])
base=json.loads((r/'benchmarks/component-accounting/margin-payment-settlement.json').read_text());base.update(schema='defiformal-margin-funding-accounting/v1',accepted_native_dependency_revision='3df7bdcc6c953c0155d27310de67f1305149cc1b',accepted_payment_settlement_dependency_revision='6e8c30cc1979992597ea25ecf1aeea35bc785812',scope='Declared Funding quote/actual payment/holding-counter/receipt/valuation proofs, controls, replay and guide; shared payment/kernel/source/runtime dependencies excluded, not full Margin/P27 totals',files=files)
base['shared_support']=[dict(path=name,sha256=hashlib.sha256((r/name).read_bytes()).hexdigest(),excluded_from_funding_totals=True) for name in ['lean/DefiKernel/Margin/Types.lean','lean/DefiKernel/Margin/Payment.lean','lean/DefiKernel/Margin/PaymentSettlement.lean']]
base['dependencies_not_recounted']=['Accepted Native Payment and actual PaymentSettlement','Typed kernel/Mathlib','Original GMX source/helper/runtime and new evidence-only probes']
base['prospective_shared_interval']=dict(observed_implementation_boundary_utc='2026-11-17T19:10:52Z',ended_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),earlier_funding_implementation_not_timed=True,active_effort=None,human_person_hours=None,per_component_effort=None,limitation='Observed boundary to accounting freeze is shared wall time including commands/waits/repairs, excludes earlier funding investigation/first implementation, and is not complete author effort or allocated person-hours.')
base['open']=['Caller owner funding-claim/snapshot commit and getEmptyFees exceptional-close integration','Funded positive-PnL realization and explicit positive-impact preprocessing boundary','Selected source financial refusal/allowed bankruptcy and source-bound branch campaign','Ordered close, separate constructive lifecycle solvency, full IV.3/P27','I.3 historical effort','II.1 separate effort scenario','Universal/deployed source refinement','Outside reproduction/adoption']
(r/'benchmarks/component-accounting/margin-funding.json').write_text(json.dumps(base,indent=2)+'\n')
print('accounting explicit ranges intact, exhaustive and nonoverlapping',len(files))
