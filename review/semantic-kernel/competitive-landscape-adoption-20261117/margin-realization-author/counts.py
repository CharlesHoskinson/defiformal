from pathlib import Path
import json,hashlib,datetime
r=Path('/private/tmp/defiformal-ci-author');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();files=[]
def add(name,ranges):
 p=r/name;n=len(p.read_text().splitlines());covered=[];parts=[]
 for start,end,cat in ranges:
  end=n if end is None else end;covered+=list(range(start,end+1));parts.append(dict(start=start,end=end,category=cat,lines=end-start+1))
 assert covered==list(range(1,n+1)),name
 files.append(dict(path=name,sha256=h(p),physical_lines=n,classification=parts))
add('lean/DefiKernel/Margin/Realization.lean',[(1,4,'guidance_support'),(5,51,'realization_model_quote_and_provisioning'),(52,309,'mathematical_contracts_proofs_and_correspondence_support'),(310,None,'guidance_support')])
add('lean/DefiKernel/Margin/RealizationAudit.lean',[(1,None,'finite_controls')])
add('scripts/replay_margin_realization.py',[(1,None,'replay_implementation')])
add('docs/examples/margin-realization.md',[(1,None,'guidance')])
base=json.loads((r/'benchmarks/component-accounting/margin-funding.json').read_text());base.update(schema='defiformal-margin-realization-accounting/v1',accepted_funding_dependency_revision='b90182135ea979c3a8fd5899fb28ca8822a1c9d0',scope='Declared pool-funded realization model/proofs/controls/replay/guide; shared funding/payment/kernel/source/runtime excluded, not full Margin/P27 totals',files=files)
base['shared_support']=[dict(path=name,sha256=h(r/name),excluded_from_realization_totals=True) for name in ['lean/DefiKernel/Margin/Types.lean','lean/DefiKernel/Margin/Payment.lean','lean/DefiKernel/Margin/PaymentSettlement.lean','lean/DefiKernel/Margin/Funding.lean']]
base['dependencies_not_recounted']=['Accepted Funding/Payment/PaymentSettlement','Typed kernel/Mathlib','Original GMX source/campaign/runtime']
base['prospective_shared_interval']=dict(observed_implementation_boundary_utc='2026-11-17T19:23:39Z',ended_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),earlier_realization_implementation_not_timed=True,active_effort=None,human_person_hours=None,per_component_effort=None,limitation='Observed implementation boundary to accounting is shared wall time including commands/repairs/waits and excludes earlier first implementation; not complete author effort or allocated person-hours.')
base['open']=['Explicit upstream marked valuation/close base PnL observation relationship','Positive impact preprocessing and virtual index-impact-pool bookkeeping boundary','Caller owner funding-claim/snapshot commit and exceptional getEmptyFees integration','Selected financial refusal/allowed bankruptcy and source-bound branch campaign','Ordered close, separate constructive lifecycle solvency, full IV.3/P27','I.3 historical effort','II.1 separate effort scenario','Universal/deployed source refinement','Outside reproduction/adoption']
(r/'benchmarks/component-accounting/margin-realization.json').write_text(json.dumps(base,indent=2)+'\n')
print('accounting explicit ranges intact, exhaustive and nonoverlapping',len(files))
