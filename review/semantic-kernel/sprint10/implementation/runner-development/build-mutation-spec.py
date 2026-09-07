#!/usr/bin/env python3
"""Bind proposed S10 mutations to actual runtime needles; does not execute variants."""
from pathlib import Path
import json,hashlib
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'lean/lean-toolchain').is_file())
regions='DefiKernel.Interface.Regions'; bindings='DefiKernel.Interface.Bindings'
mutations=[];rows=[]
def add(mid,name,module,needle,replacement,label,sibling):
 source=(ROOT/'lean'/Path(module.replace('.','/')).with_suffix('.lean')).read_text();prefix=source.split('\n-- BEGIN PROOFS\n')[0];assert prefix.count(needle)==1,(mid,prefix.count(needle))
 mutations.append({'name':name,'module':module,'needle':needle,'replacement':replacement,'required_false':['interface.'+label]});rows.append({'id':mid,'name':name,'module':module,'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'prefix_needle_count':1,'designated':'interface.'+label,'sibling':'interface.'+sibling,'status':'actual_source_site_bound_execution_pending'})
add('M01','maximum-instead-of-sum',regions,'region.cells.sum state.balance','region.cells.fold max 0 state.balance','region.sum','region.empty')
add('M02','negated-receipt-delta',regions,'region.cells.sum (receiptCellEffect receipt)','-(region.cells.sum (receiptCellEffect receipt))','region.transfer-out','region.neutral-delta')
add('M03','first-repeated-target-only',regions,'(e.deltas.map (fun d ↦ if d.1 = cell then d.2 else 0)).sum','((e.deltas.find? (fun d ↦ decide (d.1 = cell))).map Prod.snd).getD 0','region.repeated','region.single-target-delta')
add('M04','supply-masks-region-delta',regions,'region.cells.sum (receiptCellEffect receipt)','if receipt.supply region.domain region.asset ≠ 0 then 0\n  else region.cells.sum (receiptCellEffect receipt)','region.mint','region.neutral-delta')
add('M05','whole-supply-as-region-delta',regions,'region.cells.sum (receiptCellEffect receipt)','receipt.supply region.domain region.asset','region.transfer-out','region.mint')
add('M06','drop-final-binding',bindings,'checkEdgesFrom cfg.catalog state 0 edges','checkEdgesFrom cfg.catalog state 0 edges.dropLast','binding.unequal','binding.equal')
add('M07','compare-left-with-itself',bindings,'state.balance left ≠ state.balance right','state.balance left ≠ state.balance left','binding.unequal','binding.equal')
add('M08','omit-asset-comparison',bindings,'left.2.2 ≠ right.2.2 then .error (.assetMismatch index left right)','False then .error (.assetMismatch index left right)','binding.asset','binding.equal')
add('M09','omit-domain-comparison',bindings,'left.1 ≠ right.1 then .error (.domainMismatch index left right)','False then .error (.domainMismatch index left right)','binding.domain','binding.equal')
add('M10','global-port-lookup',bindings,'catalog.find? (fun component ↦ decide (component.id = name.component))','catalog.find? (fun component ↦\n    component.exports.any (fun port ↦ decide (port.id = name.port)))','binding.unequal','binding.self-edge')
add('M11','missing-port-fallback',bindings,'| none => .error (.missingPort name)','| none => match component.exports.head? with\n      | none => .error (.missingPort name)\n      | some port => .ok port.cell','binding.missing-port','binding.existing-port')
add('M12','tail-before-current-edge',bindings,'match checkEdge catalog edge state index with\n    | .error reason => .error reason\n    | .ok _ => checkEdgesFrom catalog state (index + 1) rest','match checkEdgesFrom catalog state (index + 1) rest with\n    | .error reason => .error reason\n    | .ok _ => checkEdge catalog edge state index','binding.first-failure','binding.existing-port')
add('M13','bypass-catalog-validation',bindings,'if validateCatalog cfg.registry cfg.catalog then checkEdgesFrom','if true then checkEdgesFrom','binding.invalid-empty','binding.valid-empty')
add('M14','issue-adds-region-effect',regions,'| .issued _ | .revoked _ => 0','| .issued _ => 1\n  | .revoked _ => 0','admin.issued-delta','region.neutral-delta')
spec={'schema_version':1,'modules':[regions,bindings,'DefiKernel.Interface.Examples','DefiKernel.Interface.Tests','DefiKernel.Interface.Audit'],'mutations':mutations,'positive_checks':['interface.positive.transfer','interface.positive.empty-query']}
(ROOT/'mutations/interface.json').write_text(json.dumps(spec,indent=2)+'\n')
(Path(__file__).parent/'mutation-sites-development.json').write_text(json.dumps({'status':'ACTUAL_NEEDLES_BOUND_NOT_EXECUTED','spec_sha256':hashlib.sha256((ROOT/'mutations/interface.json').read_bytes()).hexdigest(),'mutations':rows,'sibling_labels_status':'actual_financial_source_labels_bound_pending_final_execution_inventory','global_positives':spec['positive_checks'],'scope':'14 new Interface runtime mutations; no old runtime source changes'},indent=2)+'\n')
print('Bound14 unique actual runtime needles; production execution pending')
