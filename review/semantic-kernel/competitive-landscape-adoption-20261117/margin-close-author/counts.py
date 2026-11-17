from pathlib import Path
import json,hashlib,datetime
r=Path('/private/tmp/defiformal-ci-author');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();files=[]
def add(name,ranges):
 p=r/name;n=len(p.read_text().splitlines());covered=[];parts=[]
 for start,end,category in ranges:
  end=n if end is None else end;covered+=list(range(start,end+1));parts.append(dict(start=start,end=end,category=category,lines=end-start+1))
 assert covered==list(range(1,n+1)),name
 files.append(dict(path=name,sha256=h(p),physical_lines=n,classification=parts))
add('lean/DefiKernel/Margin/Close.lean',[(1,4,'guidance_support'),(5,163,'selected_prefix_model_and_provisioning'),(164,1309,'mathematical_contracts_proofs_and_specification_support'),(1310,None,'guidance_support')])
add('lean/DefiKernel/Margin/CloseAudit.lean',[(1,176,'finite_controls_and_observation_output'),(177,188,'formal_nonvacuity_witness'),(189,None,'guidance_support')])
add('scripts/replay_margin_close.py',[(1,None,'replay_implementation')])
add('docs/examples/margin-close.md',[(1,None,'guidance')])
add('docs/research/competitive-landscape-2026-11/liquidation-library-addendum-2026-11-17.md',[(1,None,'dated_capability_guidance')])
base=json.loads((r/'benchmarks/component-accounting/margin-realization.json').read_text());base.update(schema='defiformal-margin-close-accounting/v1',accepted_dependency_delivery_revision='63e827d5cb37cd834c2a2cfd24b7f8f2802baf06',scope='Declared selected admission/two-funded-cash-leg/ordered-payment-prefix model, mathematical correctness/conditional solvency, controls, replay, guide and dated addendum; shared dependencies and source-observation tooling excluded, not full Margin/GMX/P27 program totals',files=files)
base['shared_support']=[dict(path=name,sha256=h(r/name),excluded_from_close_totals=True) for name in ['lean/DefiKernel/Margin/Types.lean','lean/DefiKernel/Margin/Payment.lean','lean/DefiKernel/Margin/PaymentSettlement.lean','lean/DefiKernel/Margin/Funding.lean','lean/DefiKernel/Margin/Realization.lean']]
base['dependencies_not_recounted']=['Accepted Types/Payment/PaymentSettlement/Funding/Realization','Typed kernel/Mathlib','Original GMX sources and frozen source branch/compiler/runtime campaign; source/ABI stubs and probe code are evidence, not counted as original library source']
base['prospective_shared_interval']=dict(observed_implementation_boundary_utc='2026-11-17T19:48:55Z',ended_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),earlier_close_design_campaign_and_first_implementation_not_timed=True,active_effort=None,human_person_hours=None,per_component_effort=None,limitation='Shared observed implementation-to-accounting wall interval includes commands, repairs, review waits, controls/docs and excludes earlier design/source campaign/first implementation. Not complete active author effort or allocated person-hours.')
base['source_evidence']=dict(frozen_campaign='16 values,6 financial reverts,1 arithmetic Panic; conditional source excerpts/stubs and actual unchanged internal helpers',fresh_native_close_admission_pairs=2,new_evm_executions_for_native_close_pairs=0,comparison_scope='Exact nine projected admission words/error fields only, not whole handler/context/storage/source refinement')
base['open']=['Source index-impact-pool capping/debit and upstream observation validity/relationship','Subsequent GMX fee receiver/pool/UI-fee/rebate allocations beyond reference escrow','Caller claim/snapshot/size commit, removal, withdrawal/output suffix, handler/authorization/bank refinement','Final independent public/package acceptance and effective IV.3 cell reconciliation are separate delivery gates','I.3 historical effort','II.1 separate effort scenario','Universal/deployed source refinement','Outside reproduction/adoption','Wider roadmap']
(r/'benchmarks/component-accounting/margin-close.json').write_text(json.dumps(base,indent=2)+'\n')
print('accounting explicit ranges intact, exhaustive and nonoverlapping',len(files))
