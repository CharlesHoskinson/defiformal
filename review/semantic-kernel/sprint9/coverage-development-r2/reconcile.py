#!/usr/bin/env python3
"""Reconcile actual source declarations/check labels with all approved normative scenarios."""
from pathlib import Path
import re, json, hashlib, subprocess, datetime
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent
PLAN=ROOT/'review/semantic-kernel/sprint9/planning/scenario-planning-map.json'
PREFIX='DefiKernel.Metatheory.'
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def record(path):
 p=ROOT/path
 return {'path':path,'sha256':digest(p),'bytes':p.stat().st_size}
planning=json.loads(PLAN.read_text())
runtime=dict(re.findall(r'^(metatheory\.[^:]+): (true|false)$',(OUT/'runtime.log').read_text(),re.M))
assert len(runtime)==148 and set(runtime.values())=={'true'}
checks={}; declarations={}
for p in sorted((ROOT/'lean/DefiKernel/Metatheory').glob('*.lean')):
 text=p.read_text(); relative=str(p.relative_to(ROOT))
 namespace=PREFIX+('ConfigurationFixtures.' if p.stem=='ConfigurationFixtures' else '')
 for m in re.finditer(r'\b(theorem|structure|inductive|def)\s+([A-Za-z_][\w.]*)',text):
  if text[text.rfind('\n',0,m.start())+1:m.start()].lstrip().startswith(('--','/','*')): continue
  name=namespace+m.group(2)
  if p.stem in ['Tests','Examples','OperatorFixtures','Audit']: name=PREFIX+p.stem+'.'+m.group(2)
  tail=text[m.start():]; stop=tail.find(':=')
  if stop<0: stop=tail.find('\n\n')
  statement=tail[:stop].strip()
  if m.group(1)!='theorem': statement=tail.split('\n\n')[0]
  declarations[name]={'name':name,'kind':m.group(1),'path':relative,
   'line':text.count('\n',0,m.start())+1,'source_statement':statement,
   'source_sha256':digest(p), 'module_section_variables':re.findall(r'^variable .*$',text,re.M)}
 for m in re.finditer(r'\("(metatheory\.[^"]+)"',text):
  label=m.group(1); assert label not in checks
  i=m.start(); depth=0; quoted=False; escape=False; end=i
  for end in range(i,len(text)):
   c=text[end]
   if quoted:
    if escape: escape=False
    elif c=='\\': escape=True
    elif c=='"': quoted=False
   elif c=='"': quoted=True
   elif c=='(': depth+=1
   elif c==')':
    depth-=1
    if depth==0: break
  checks[label]={'id':label,'path':relative,'line':text.count('\n',0,i)+1,
   'source_expression':text[i:end+1], 'source_sha256':digest(p),
   'actual_result':runtime[label], 'runtime_log':'runtime.log'}
assert set(checks)==set(runtime)
# Concrete author mapping; '*' expands only to existing actual runtime labels.
M={}
def put(n,theorems='',labels='',defs=''):
 M[n]={'theorems':theorems.split(), 'labels':labels.split(), 'defs':defs.split()}
put(1,'runGroup_config_eq ConfigurationFixtures.extension_agreement ConfigurationFixtures.main_group_extension','fixture.catalog config.extended.valid config.extended.group')
put(2,'issueCapability_config_eq executeStep_config_eq','config.grant-only.*','SupportedStep ConfigAgreement')
put(3,'executeStep_config_eq runGroup_config_eq ConfigurationFixtures.extension_agreement','','ConfigAgreement SupportedStep SupportedGroup')
put(4,'executeStep_config_eq','positive.single-leaf config.extended.step group.forward-refusal config.extended.refusal')
put(5,'issueCapability_config_eq revokeCapability_config_eq executeStep_config_eq','group.admin.* config.issue.* config.revoke.* config.extended.admin')
put(6,'executeStep_config_eq','config.lookup.absent.*')
put(7,'analyzeBranchFrom_config_eq parallel_admit_config_eq interleaving_admit_config_eq atomic_admit_config_eq','operator.*.admission.*','SupportedList SupportedBranch')
put(8,'runGroup_config_eq ConfigurationFixtures.administration_group_extension','group.admin.denied config.extended.admin')
put(9,'runParallel_config_eq runInterleaving_config_eq','operator.parallel.* operator.interleaving.*')
put(10,'runAtomic_config_eq atomic_advance_config_eq atomic_runPrefix_config_eq','operator.atomic.*')
put(11,'ConfigurationFixtures.changedRegistry_admins_remaining','positive.single-leaf config.registry.*')
put(12,'ConfigurationFixtures.changedOutput_registry_remaining ConfigurationFixtures.changedOutput_admins_remaining','positive.single-leaf config.lookup.valid config.lookup.changed config.lookup.remaining config.lookup.all-admins')
put(13,'','positive.single-leaf config.invalid.*')
put(14,'ConfigurationFixtures.grantOnly_catalog_remaining ConfigurationFixtures.grantOnly_invoked_registry_remaining ConfigurationFixtures.grantOnly_admins_remaining','config.grant-only.*')
put(15,'ConfigurationFixtures.changedAdmin_registry_remaining','config.issue.original config.admin.*')
put(16,'','config.issue.original config.issue.empty-store context.store.material')
put(17,'cursorEq_iff','observe.world-diff')
put(18,'cursorEq_iff','observe.store-diff observe.store.tombstone')
put(19,'cursorEq_iff','observe.output-diff observe.output.*')
put(20,'eventEq_iff cursorEq_iff','observe.receipt-diff observe.request.* observe.receipt.* observe.event.evaluated observe.event.issue-id observe.event.revoke-id')
put(21,'cursorEq_iff','observe.failure-diff observe.failure.*')
put(22,'cursorEq_iff','observe.next-index-diff')
put(23,'cursorEq_iff CursorEquivalent.refl CursorEquivalent.symm CursorEquivalent.trans','positive.equal-observation observe.raw-before.omitted observe.raw-post.omitted')
put(24,'runGroup_preserves','observe.raw-before.omitted observe.raw-post.omitted context.raw-*')
put(25,'GroupEquivalent.fill runGroup_preserves','context.fill.original context.fill.replacement group.continuation')
put(26,'GroupEquivalent.fill groupEquivalent_empty_left','context.fill.original context.fill.replacement','SeqContext fill GroupEquivalent')
put(27,'GroupEquivalent.fill runGroup_failed','context.fill.failed.* group.failed-entry')
put(28,'','context.history.*')
put(29,'','context.index.*')
put(30,'','config.issue.original config.issue.empty-store context.store.material')
put(31,'','context.one-entry.* context.funded.*','GroupEquivalent')
put(32)
put(33)
put(34,'runGroup_eq_continueRun','group.world-chain group.history-chain group.boundary-index group.index-chain','Examples.fullCursorEq Examples.rawTransfer Examples.afterThird Examples.worldChainExpected Examples.historyChainExpected Examples.indexChainExpected Examples.childExecutionExpected')
put(35,'runGroup_eq_continueRun','group.store-chain group.admin.*','Examples.adminInitial Examples.adminDenied')
put(36,'','boundary.*','OperatorFixtures.splitSecond OperatorFixtures.splitExpected OperatorFixtures.batchAbortObservation')
put(37,'','group.world-chain group.store-chain group.history-chain group.index-chain group.refusal-absorption group.child-executed group.ordered group.boundary-index positive.single-leaf positive.equal-observation')
put(38,'','observe.world-diff observe.store-diff observe.output-diff observe.failure-diff observe.receipt-diff observe.next-index-diff positive.equal-observation')
put(39)
put(40)
put(41)
put(42)
put(43)
put(44)
put(45,'runGroup_eq_continueRun','group.ordered context.prefix-suffix.left context.prefix-suffix.right group.flat.success')
put(46,'runGroup_empty runGroup_empty_left runGroup_empty_right','group.empty group.empty.left group.empty.right')
put(47,'runGroup_eq_continueRun','group.admin.* group.store-chain')
put(48,'runGroup_failed','group.refusal-absorption group.funded-suffix')
put(49,'runGroup_failed','group.failed-entry')
put(50,'runGroup_eq_continueRun','group.boundary-index context.index.*')
put(51,'runGroup_eq_continueRun','context.prefix-suffix.left group.flat.success')
put(52,'runGroup_eq_continueRun','group.admin.denied group.flat.admin')
put(53,'runGroup_eq_continueRun','group.continuation group.flat.admin','Examples.afterFirst Examples.adminInitial')
put(54,'runGroup_assoc groupEquivalent_assoc','context.prefix-suffix.left context.prefix-suffix.right group.ordered group.assoc.failure.*')
put(55,'','group.forward-refusal group.reverse-refusal')
assert set(M)==set(range(1,56))
import fnmatch
pending={37:'Official 14-mutant production run pending frozen source.',38:'Official six production omission variants pending frozen source.',39:'Full defensive controls and blocked-attempt reconciliation pending; four development smoke controls do not close this gate.',40:'Official complete65 control suite pending.',41:'Official complete65 controls including all12 proof-tail-related and both production forms pending.',42:'Final frozen imported full theorem/supplemental statement/axiom/Git inventory pending.',43:'Fresh final-candidate prior Lean/Python regressions pending; planning baseline is distinct.',44:'Native Grok/Fable source and evidence verdicts, adjudication, archive and verified branch delivery pending.'}
artifact_paths={32:['review/semantic-kernel/sprint9/planning/ADJUDICATION.md','review/semantic-kernel/sprint9/planning/gate.json'],33:['review/semantic-kernel/sprint9/planning/gate.json','review/semantic-kernel/sprint9/planning/ADJUDICATION.md'],37:['mutations/metatheory.json','review/semantic-kernel/sprint9/implementation/runner-development/mutation-sites-initial.json'],38:['mutations/metatheory.json'],39:['scripts/check_metatheory_mutations.py','review/semantic-kernel/sprint9/implementation/runner-development/adaptation-and-smoke.json'],40:['scripts/test_metatheory_mutation_runner.py','review/semantic-kernel/sprint9/implementation/runner-development/adaptation-and-smoke.json'],41:['scripts/test_metatheory_mutation_runner.py','review/semantic-kernel/sprint9/implementation/runner-development/adaptation-and-smoke.json'],42:['lean/DefiKernel/Metatheory/Verify.lean','lean/DefiKernel/AxiomAudit.lean'],43:['review/semantic-kernel/sprint9/planning/gate.json']}
rows=[]
for scenario in planning['scenarios']:
 n=int(scenario['id'].split('-')[1]); mapping=M[n]; row={k:scenario[k] for k in ['id','capability','requirement','scenario','when','then','source','line']}
 source=ROOT/row['source']; lines=source.read_text().splitlines()
 assert lines[row['line']-1]=='#### Scenario: '+row['scenario'],row['id']
 row['normative_source_sha256']=digest(source)
 row['theorems']=[]
 for short in mapping['theorems']:
  d=declarations[PREFIX+short]; assert d['kind']=='theorem'
  row['theorems'].append({**d,'evidence_class':'concrete_reference_or_remaining_premise' if 'ConfigurationFixtures.' in short else 'generic_conditional_Lean_theorem'})
 row['declarations']=[declarations[PREFIX+x] for x in mapping['defs']]
 labels=[]
 for pattern in mapping['labels']:
  found=sorted(x for x in checks if fnmatch.fnmatchcase(x,'metatheory.'+pattern)); assert found,(n,pattern)
  labels+=found
 row['runtime_checks']=[checks[x] for x in sorted(set(labels))]
 row['artifacts']=[record(p) for p in artifact_paths.get(n,[])]
 row['status']='pending_official_evidence' if n in pending else ('accepted_planning_gate' if n in [32,33] else 'implemented_development_verified')
 row['pending']=pending.get(n,'Final frozen imported audit and independent acceptance remain separate global gates.' if n not in [32,33] else '')
 if n in [11,12,13,14,15,16,28,29,30,31,36,55]: row['runtime_evidence_class']='actual_execution_counterexample_with_independent_expected_outcomes'
 elif n in range(17,25) or n==38: row['runtime_evidence_class']='synthetic_observer_pairs; raw-world continuation uses actual execution on synthetic cursors'
 elif n==37: row['runtime_evidence_class']='actual_financial_oracles_ready; official_mutant_detections_pending'
 else: row['runtime_evidence_class']='actual_execution_with_independent_expectations' if labels else 'not_runtime_evidence'
 rows.append(row)
# Validate that statement records are source-level only; final elaboration belongs to frozen inventory.
inputs=sorted({x['path'] for row in rows for x in row['theorems']+row['declarations']+row['runtime_checks']+row['artifacts']} | {str(PLAN.relative_to(ROOT))} | {x['source'] for x in rows} | {'openspec/changes/operational-continuation-congruence/design.md','openspec/changes/operational-continuation-congruence/tasks.md'})
report={'schema_version':1,'kind':'development_implementation_coverage_not_final_acceptance','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'git_head_observed':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'authorship':'GPT-6 stock-harness author reconciliation of own fixtures; not independent reproduction or provider acceptance','counts':{'scenarios':len(rows),'requirements':len({(r['capability'],r['requirement']) for r in rows}),'runtime_checks_executed':len(runtime),'implemented_development_verified':sum(r['status']=='implemented_development_verified' for r in rows),'accepted_planning_gate':2,'pending_official_evidence':len(pending)},'execution':{'cwd':'lean','build_argv':['lake','build','DefiKernel.Metatheory.Tests'],'build_exit':0,'build_log':'build.log','runtime_argv':['lake','env','lean','DefiKernel/Metatheory/Audit.lean'],'runtime_exit':0,'runtime_log':'runtime.log','results':runtime},'inputs':[record(p) for p in inputs],'statement_scope':'Source statements and section-variable binders mechanically located; complete elaborated imported inventory is pending and not claimed here.','closed_source_gaps':['Explicit moved Atomic commit-boundary counterexample, with independently expected complete public and diagnostic results.','Actual old/new config lane-supply abort plus full speculative attempt/outstanding expectations.','All-domain remaining-admin and changedAdmin catalog-validity comparisons; seven proof-only remaining-premise facts.','Actual SeqContext.fill nonempty prefix/suffix/replacement/refusal cases.','Actual continuation on synthetic old-raw-world-only pairs, including full expected raw cursor.','M09 designated protected collateral sensitivity and M13 designated evaluated-receipt sensitivity aligned with accepted design; request-argument sensitivity retained separately.'],'uncovered_source_requirements':[],'global_limits':['No final candidate acceptance, official production detections, final regressions, final imported inventory or native verdict is inferred from these development passes.','Configuration agreement is a universal strong premise over one shared identity universe; it is not a checker, arbitrary extension or deployed fidelity.','Full cursor observation intentionally omits old raw worlds. Synthetic observer pairs are not claims of two reachable traces.','Named executed counterexamples are runtime evidence, not newly certified counterexample theorems.','Generic simulation/associativity proofs preserve actual full cursor and leaf order; no boundary movement or shared commutation follows.'],'scenarios':rows}
(OUT/'coverage.json').write_text(json.dumps(report,indent=2)+'\n')
md=['All 55 approved scenarios are reconciled with exact source declarations, source statements, runtime IDs and artifacts in `coverage.json`. This is author development reconciliation, not final acceptance.','',f"Current execution: **{len(runtime)}/{len(runtime)}** unique named Audit comparisons passed. The focused Tests build passed. Sources are held fixed after closing the six listed coverage gaps.",'','| Scenario | Status | Theorems | Runtime checks |','| --- | --- | ---: | ---: |']
for r in rows: md.append(f"| {r['id']} — {r['scenario']} | {r['status']} | {len(r['theorems'])} | {len(r['runtime_checks'])} |")
md += ['','Eight evidence scenarios remain open: S9-037–044 (14 production mutants, blocked classification/full65 controls, final imported inventory, fresh prior regressions, native acceptance and delivery). Four prior development CLI controls and the accepted planning baseline are retained with their actual scope; neither substitutes for final runs.','','No remaining source-level scenario gap was found in this bounded reconciliation. Source statements here are locators, not a substitute for the full elaborated proof inventory. The seven concrete remaining-premise facts are in ConfigurationFixtures; complete imported type/axiom/Git binding remains a post-freeze obligation.','','The graph/README task did not contribute semantic evidence. No commit or native/official mutation call was made by this task.']
(OUT/'coverage.md').write_text('\n'.join(md)+'\n')
print(json.dumps(report['counts']))
print('coverage.json SHA256',digest(OUT/'coverage.json'))
