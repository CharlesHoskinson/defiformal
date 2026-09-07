from pathlib import Path
import json,hashlib,subprocess,datetime,re,sys
R=Path('/home/charl/defiformal');E=Path(__file__).resolve().parent;C=R/'openspec/changes/finite-participant-causal-composition';S='b165bc586080d668f689fbc18dfa09eb8739d688'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,x):p.write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
def binding(p):return {'path':str(p.relative_to(R)),'sha256':sha(p),'bytes':p.stat().st_size}
# Preserve the complete old author evidence as immutable context by hashes, not by rewriting it.
write(E/'prior-author-evidence.json',{'scope':'original provisional evidence; untouched','files':[binding(p)for p in sorted((E.parent/'author-draft').rglob('*'))if p.is_file()]})
selected={'Regions':['Region','Region.WellFormed','balanceSum','receiptCellEffect','receiptDelta','ValueSupports','WritesWithin','NeutralOn'], 'Bindings':['Binding','resolveExport','checkBindings','bindingsHold','EdgeAgrees','Agrees'], 'Accounting':['step_receipt_cell','step_receipt_region','step_total_preserved'], 'BindingPreservation':['EffectPaired','step_binding_preserved'], 'Preservation':['LocalPreserves','RegionObligations','BindingObligations','region_localPreserves','binding_localPreserves'], 'TypedPreservation':['TypedTotalContract','step_typed_total_preserved','typed_total_localPreserves']}
api=[];sources=[]
for module,names in selected.items():
 p=R/f'lean/DefiKernel/Interface/{module}.lean';raw=p.read_bytes();assert raw==subprocess.check_output(['git','show',S+':'+str(p.relative_to(R))],cwd=R);sources.append(binding(p));text=raw.decode();decls=list(re.finditer(r'^(?:@\[[^\n]*\]\s*)?(?:def|abbrev|structure|theorem) ([\w.]+)',text,re.M))
 for name in names:
  matches=[(i,m)for i,m in enumerate(decls)if m.group(1)==name]
  if not matches:raise RuntimeError((module,name))
  i,m=matches[0];end=decls[i+1].start()if i+1<len(decls)else len(text);chunk=text[m.start():end];signature=chunk.split(':=',1)[0].rstrip();api.append({'name':'DefiKernel.Interface.'+name,'path':str(p.relative_to(R)),'line':text[:m.start()].count('\n')+1,'source_signature':signature,'source_sha256':sha(p),'kind':'actual accepted declaration; source binders/instances remain in module'})
write(C/'accepted-api.json',{'status':'accepted_M2_source_read_not_new_API','source_candidate':S,'common_binders':'P A D : Type; DecidableEq P/A/D and Fintype P/A/D as declared in source; all compared runs share the same instances','declarations':api,'source_files':sources})
refs=['review/semantic-kernel/sprint10/delivery.json','review/semantic-kernel/sprint10/archive-delivery.json','review/semantic-kernel/sprint10/integration-r1/verification.json','review/semantic-kernel/sprint10/integration-r1/lean-runs.json','review/semantic-kernel/sprint10/integration-r1/source-before.json','review/semantic-kernel/sprint10/implementation/runner-controls-r1/summary.json','review/semantic-kernel/sprint10/implementation/runner-controls-r1/cases.json','review/semantic-kernel/sprint10/implementation/legacy-dependency-equivalence.json','review/semantic-kernel/sprint10/acceptance/sprint9-regression-carry.json']
delivery=json.loads((R/refs[1]).read_text());assert delivery['source_candidate']==S and delivery['remote_matches'];integ=json.loads((R/refs[2]).read_text());assert integ['all_commands_passed'] and integ['commands_run']==18
write(C/'dependency-baseline.json',{'status':'accepted_dependency_bound; no M3 execution or planning gate','source_candidate':S,'source_evidence_commit':'1db00deb6e27cd59bf838f5152578c44e294921e','archive_commit':'ec8f163c3a69a0df04b300a158c03ed6f9d0224f','delivery_checkpoint':'35603f1b9067f10180ad88c1636ef621966f89f0','remote_verification':'retained actual prior push/readback records; this author did not rerun git ls-remote','baseline_Lean':{'actual_candidate':S,'commands':18,'all_pass':True,'runtime_counts':integ['runtime_extraction_checks'],'tools':integ['tools']},'baseline_references':[binding(R/p)for p in refs],'retention_limits':['Existing runs retain original revisions; none is relabeled as M3 execution.','Current root integration may include unrelated later arithmetic. M3 runtime API/closure equality is checked separately; fresh root integration is required at implementation freeze.','No live deployment, collector, or untouched-evaluation claim.']})
# Literal every-line driver transformations, preserving checker algorithms and diagnostics.
mappings=[]
for f in ['scripts/run_interface_mutations.py','scripts/test_interface_mutation_runner.py']:
 p=R/f;assert p.read_bytes()==subprocess.check_output(['git','show',S+':'+f],cwd=R)
 lines=[]
 for i,line in enumerate(p.read_text().splitlines(),1):
  target=line.replace('Interface','Nary').replace('interface','nary')
  if target!=line:lines.append({'line':i,'old':line,'new':target})
 mappings.append({'old':f,'new':f.replace('interface','nary'),'sha256':sha(p),'edits':lines,'unchanged_lines':'All other lines retained except reviewed new sixteen-mutant production specification supplied separately; no new parser algorithm or exemptions.'})
cases=json.loads((R/refs[6]).read_text());assert len(cases)==65 and all(c['passed']for c in cases)
rows=[]
for c in cases:
 name=c['name'];p=R/f'review/semantic-kernel/sprint10/implementation/runner-controls-r1/{name}-spec.json'
 row={'id':name,'successor_id':name.replace('interface','nary'),'kind':'inherited actual CLI control; successor planned_not_executed','expected_exit':c['expected_exit'],'expected_diagnostic':c['expected_message'].replace('Interface','Nary').replace('interface','nary'),'actual_predecessor_exit':c['actual_exit'],'predecessor_passed':c['passed'],'predecessor_command':c['command'],'successor_command':['python3','scripts/test_nary_mutation_runner.py','--repo','ROOT','--out','NEW_EXTERNAL_OUTPUT'],'predecessor_spec':binding(p) if p.exists()else None}
 if p.exists():
  raw=p.read_text(); row['successor_spec_text']=raw.replace('Interface','Nary').replace('interface','nary')
 rows.append(row)
write(C/'runner-adaptation.json',{'status':'literal adopted65 controls; Nary adaptation not executed','accepted_predecessor':S,'runtime_timeout_seconds':600,'harness_timeout_seconds':1500,'error_classification':'Compiler/setup/timeout/malformed/empty blocked; actual prescribed false comparisons and protected true siblings required for semantic detection.','driver_mappings':mappings,'marker':'\n-- BEGIN PROOFS\n','module_regex':r'DefiKernel\.Nary(?:\.[A-Za-z][A-Za-z0-9]*)+','namespace_end_regex':r'\n(end DefiKernel\.Nary(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$','error_line':'error: Nary runtime comparisons failed: {len(false)}','audit_root':'DefiKernel.Nary.Audit','inherited_count':len(rows),'new_control_count':0,'controls':rows,'production_roots':['DefiKernel.Nary.Schedule','DefiKernel.Nary.Execution','DefiKernel.Nary.Observation','DefiKernel.Nary.CausalRuntime','DefiKernel.Nary.Examples','DefiKernel.Nary.Tests','DefiKernel.Nary.Audit'],'proof_roots_excluded_from_runtime':['DefiKernel.Nary.Soundness','DefiKernel.Nary.BinaryCorrespondence','DefiKernel.Nary.Interference','DefiKernel.Nary.Causal','DefiKernel.Nary.InterfaceInstances','DefiKernel.Nary.Verify'],'old_dependencies':'Discover all actual local imports recursively, preserve unchanged historical proof suffixes. Runtime may import Interface.Regions/Bindings/Examples, never Interface.Tests/Fixtures/Accounting/Preservation or Nary proof helpers.'})
write(E/'refresh-inputs.json',{'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'accepted_source':S,'inputs':sources+[binding(R/p)for p in refs]+[binding(R/x['old'])for x in mappings]})
print('API',len(api),'controls',len(rows),'mapped lines',sum(len(x['edits'])for x in mappings))
