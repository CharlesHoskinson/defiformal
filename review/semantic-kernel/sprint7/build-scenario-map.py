#!/usr/bin/env python3
"""Map frozen normative scenarios to inspected proof/runtime evidence, retaining pending gates."""
import datetime, hashlib, json, pathlib, re, subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3]; OUT=ROOT/'review/semantic-kernel/sprint7'
CANDIDATE='bea105ec72e633a2dd66c663b96d0b552e1814a8'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def save(n,o): (OUT/n).write_text(json.dumps(o,indent=2,ensure_ascii=False)+'\n')
proof_inventory=json.loads((OUT/'proof-inventory.json').read_text())
proofs={x['name']:x for x in proof_inventory['theorems']}
runtime_log=OUT/'integration-final/01.log';runtime_rows=re.findall(r'^(interleaving\.[a-z0-9.-]+): (true|false)$',runtime_log.read_text(),re.M)
assert runtime_rows and len(dict(runtime_rows))==len(runtime_rows) and all(v=='true' for _,v in runtime_rows)
runtime=dict(runtime_rows)
lean_runs=json.loads((OUT/'integration-final/lean-runs.json').read_text());assert lean_runs['candidate']==CANDIDATE
for run in lean_runs['runs']:
 assert run['exit_code']==0
 assert sha(OUT/'integration-final'/run['log'])==run['log_sha256']
assert any(x['argv']==['lake','build'] for x in lean_runs['runs'])
checks_source=(ROOT/'lean/DefiKernel/Interleaving/Tests.lean').read_text().splitlines()
schedule_source=(ROOT/'lean/DefiKernel/Interleaving/ScheduleTests.lean').read_text().splitlines()
def runtime_location(label):
 path='lean/DefiKernel/Interleaving/'+('ScheduleTests.lean' if label.startswith('interleaving.schedule.') else 'Tests.lean')
 lines=schedule_source if label.startswith('interleaving.schedule.') else checks_source
 matches=[(i,s) for i,s in enumerate(lines,1) if '"'+label+'"' in s]
 if not matches:
  prefix=next(p for p in ['interleaving.fixture.disjoint.','interleaving.observe.receipt.','interleaving.observe.request.'] if label.startswith(p))
  matches=[(i,s) for i,s in enumerate(lines,1) if '"'+prefix+'"' in s]
 assert matches,label
 return {'source':path,'line':matches[0][0],'source_line':matches[0][1],'generated_label':('"'+label+'"') not in matches[0][1]}
E={}
def p(short):
 name='DefiKernel.Interleaving.'+short; row=proofs[name]; key=row['category']+':'+name
 E[key]={'id':key,'class':row['category'],'name':name,'source':row['source'],'line':row['line'],'statement':row['statement'],'source_statement':row.get('source_statement'),'section_variables':row.get('section_variables',[]),'axioms':row['axioms'],'artifacts':['review/semantic-kernel/sprint7/proof-types.log','review/semantic-kernel/sprint7/proof-inventory.json'],'status':'verified-at-frozen-source'}
 return key

def t(pattern):
 matched=[n for n in runtime if n.startswith('interleaving.'+pattern)]
 assert matched,pattern
 result=[]
 for n in matched:
  key='boundedruntime:'+n;E[key]={'id':key,'class':'boundedruntime','name':n,**runtime_location(n),'artifacts':['review/semantic-kernel/sprint7/integration-final/01.log','review/semantic-kernel/sprint7/integration-final/lean-runs.json'],'status':'true-at-frozen-source','scope':'Finite exact-rational development comparison; not a general theorem or fidelity result.'};result.append(key)
 return result

def source(path,needle,note):
 lines=(ROOT/path).read_text().splitlines(); n=next(i for i,s in enumerate(lines,1) if needle in s)
 key='sourceinspection:'+path+':'+str(n);E[key]={'id':key,'class':'sourceinspection','source':path,'line':n,'source_line':lines[n-1],'note':note,'status':'inspected','artifacts':[path]};return key

def artifact(label,paths,kind='integratedaudit',status='verified',note=''):
 for path in paths: assert (ROOT/path).exists(),path
 key=kind+':'+label;E[key]={'id':key,'class':kind,'artifacts':paths,'artifact_hashes':{x:sha(ROOT/x) for x in paths},'status':status,'note':note};return key
M={}
def add(title,ps=(),ts=(),tasks=(),extras=(),pending=(),note=''):
 M[title]={'evidence':[p(x) for x in ps]+sum([t(x) for x in ts],[])+list(extras),'tasks':list(tasks),'pending':list(pending),'note':note}
add('All disjoint schedules',['runInterleaving_recovers','runInterleaving_matchesParallel','runInterleaving_matchesSerialLR','runInterleaving_matchesSerialRL'],tasks=['5.3','5.4'])
add('Disjoint refusal',['Recovery.advance_simulates','runInterleaving_recovers'],['fixture.disjoint.'],['5.3','5.4','5.5'],note='Each of the six schedules has separate refused.complete/refused.parallel checks; the theorem permits refusals and imposes no success premise.')
add('Six concrete schedules',ts=['fixture.disjoint.'],tasks=['5.5','6.1'])
add('Empty peer',['runInterleaving_empty_right','runInterleaving_empty_left'],['fixture.empty.'],['5.5'],note='The generic specializations include successful or refused nonempty branches under actual Parallel admission.')
add('Full-block schedules',['complete_blockLR','complete_blockRL','runInterleaving_blockLR','runInterleaving_blockRL'],['fixture.disjoint.llrr.','fixture.disjoint.rrll.'],['5.5'])
add('Order-sensitive shared state',ts=['fixture.shared.lr','fixture.shared.rl','fixture.shared.order'],tasks=['3.2','5.5'],note='Runtime counterexample to unrestricted equivalence; not advertised as a separately named theorem.')
add('Balanced schedule',['checkSchedule_ok_iff','runPrefix_complete_counts','Reachable.local_order'],['schedule.balanced','fixture.disjoint.lrlr.complete'],['2.1','2.3','3.1'])
add('Missing and excess slots',['checkSchedule_error_iff'],['schedule.missing-','schedule.excess-','schedule.empty-extra-','schedule.both-wrong-counts','fixture.malformed.schedule'],['2.1','2.2'])
add('Empty schedules',['complete_empty_iff','runInterleaving_empty'],['fixture.empty.both','schedule.empty-admitted'],['2.1','3.1','5.5'])
add('Overlapping funded branches',['admit_of_checks','InterferenceFixtures.shared_overlap'],['schedule.overlap-','fixture.shared.lr','fixture.shared.rl'],['2.2','3.2'])
add('Unreachable malformed suffix',ts=['schedule.unreachable-','fixture.malformed.suffix'],tasks=['2.2'],extras=[source('lean/DefiKernel/Interleaving/Schedule.lean','def admit','Whole branch analyses precede schedule count and runtime execution.')])
add('Preflight precedence',ps=['runInterleaving_admission_refusal'],ts=['schedule.precedence-'],tasks=['2.2'],extras=[source('lean/DefiKernel/Interleaving/Execution.lean','def runInterleaving','Admission failure constructor contains reason, unchanged initial world and supplied schedule; has no attempt or output fields.')])
add('Competing liquidity',['Reachable.store'],['fixture.shared.lr','fixture.shared.rl','fixture.shared.attempts'],['3.2','6.1'])
add('Replenishment order',['continueRun_refusal_stable'],['fixture.replenish.'],['3.2','3.3'])
add('Local boundary identity',['Reachable.attempts','Reachable.attempt_index'],['fixture.boundary.local'],['3.2','3.5'],note='AttemptSound fixes branch/local index and executeStep; trusted environment/time authenticity remains input assumption.')
add('Revoked authority',['Reachable.authority','Reachable.initial_store_authority'],['fixture.capability.revoked','fixture.capability.live'],['4.4','6.1'])
add('Retained prefix and peer continuation',['continueRun_refusal_stable','Reachable.local_order','Reachable.local_history'],['fixture.refusal.immediate','fixture.refusal.middle','fixture.refusal.skips','fixture.replenish.attempts'],['3.3','4.2'])
add('Dual refusal',['Reachable.failure_index','continueRun_refusal_stable'],['fixture.refusal.dual','fixture.refusal.skips'],['3.3','4.2'])
add('Different snapshots at the same key',['Reachable.local_history'],['fixture.snapshot.'],['3.5'],extras=[source('lean/DefiKernel/Interleaving/Execution.lean','def Machine.accept','Append actual frozen own result.outputs; no recomputation or peer output concatenation.')])
add('Peer-only history',['Reachable.local_history'],['fixture.history.peer.only','fixture.history.funded.literal','fixture.history.own','fixture.history.unit'],['3.5'],note='Peer-only producer and literal/own controls share USD unit and independent funding.')
add('Attempt continuity',['Reachable.attempt_chain','Reachable.branch_projection','Reachable.attempts'],['fixture.shared.attempts','fixture.replenish.attempts'],['3.4','4.1','4.2'])
add('Observation sensitivity',['matchesParallel_iff'],['observe.'],['3.4'],extras=[source('lean/DefiKernel/Interleaving/Execution.lean','def LocalState.observe','Canonical branch projection retains exact events, history, nextIndex and failure.'),source('lean/DefiKernel/Interleaving/Execution.lean','def observationsEqual','Public comparison checks complete ledger/store plus both exact local projections.')])
add('Skipped tokens',['skip_world','skip_attempts','AdvanceSound.consumed','advance_refusal_stable'],['fixture.refusal.skips','fixture.replenish.attempts','schedule.empty-extra-'],['3.3','4.2'],extras=[source('lean/DefiKernel/Interleaving/Execution.lean','def advance','Halted and exhausted branches both invoke Machine.skip; public invalid counts are rejected before replay.')])
add('Prefix soundness',['advance_sound','runPrefix_reachable','Reachable.attempt_chain','Reachable.branch_projection','Reachable.local_history','Reachable.local_order'],tasks=['4.1','4.2'])
add('Complete slot consumption',['runPrefix_complete_active_exhaustion','runPrefix_complete_exhausted_or_refused','Complete.left_slot','Complete.right_slot','runPrefix_complete_counts','Reachable.active_index','Reachable.failure_index'],['fixture.refusal.skips','fixture.disjoint.'],['2.3','4.2'],note='Explicit Completion corollaries now state active exhaustion and exhausted-or-exactly-refused outcomes for every complete schedule.')
add('Supply and refusal',['AdvanceSound.accounting','Reachable.accounting','runPrefix_accounting'],['fixture.supply.'],['4.3'])
add('Authority at execution',['Reachable.authority','Reachable.initial_store_authority','Reachable.before_stores'],['fixture.capability.unauthorized','fixture.capability.debit','fixture.capability.live'],['4.4'])
add('Reached worlds',['runPrefix_nonnegative'],['fixture.collateral.protected'],['4.4'],note='The generic result reuses proof-carrying State.nonneg; every intermediate world itself has that State type. Runtime collateral does not establish generic nonnegativity.')
add('Protected collateral',['Reachable.locality','Reachable.analyzed_locality','Reachable.predicate_frame','Reachable.analyzed_predicate_frame','InterferenceFixtures.collateral_supported','InterferenceFixtures.protected_collateral_all_tokens'],['fixture.collateral.protected'],['4.5','5.2'])
add('Missing support counterexample',['InterferenceFixtures.missing_frame_support_counterexample','InterferenceFixtures.empty_support_is_false'],tasks=['4.5'])
add('Overlapping invariant instance',['Reachable.two_invariants','every_prefix_two_invariants','InterferenceFixtures.shared_supply_free','InterferenceFixtures.shared_step_total','InterferenceFixtures.shared_local_obligation','InterferenceFixtures.shared_cross','InterferenceFixtures.shared_stable','InterferenceFixtures.shared_initialized','InterferenceFixtures.shared_every_prefix'],tasks=['5.1','5.2'],note='Universal local R/G premise is mandatory in the generic rule. This concrete no-supply step-total lemma does not need the own-invariant antecedent.')
add('Initialization is necessary',['InterferenceFixtures.missing_initialization_counterexample'],tasks=['5.2'])
add('Peer stability is necessary',['InterferenceFixtures.fragile_local_obligation','InterferenceFixtures.fragile_initialized','InterferenceFixtures.missing_peer_stability_counterexample','InterferenceFixtures.fragile_not_stable'],tasks=['5.2'],note='Both branches are nonempty. Left Bob=0 is locally preserved by vault→Alice; right preserves total USD10 but changes Bob to6, violating peer stability.')
fullrun=artifact('frozen-runtime',['review/semantic-kernel/sprint7/integration-final/01.log','review/semantic-kernel/sprint7/integration-final/lean-runs.json'],note=f'{len(runtime)} named comparisons all true at the frozen candidate.')
add('Full financial oracle',ts=['fixture.'],tasks=['6.1','6.2'],extras=[fullrun],note='All seven exact-rational developer fixture families; complete expected finite ledgers/stores and branch observations are direct definitions.')
add('Live versus frozen values',ts=['fixture.live.complete','fixture.snapshot.'],tasks=['3.5','6.1'])
add('Semantic mutation',tasks=['7.1','7.2','7.3','7.5'],extras=[source('scripts/check_interleaving_mutations.py','def main','Production mutation runner source is frozen; final execution artifacts remain pending.'),artifact('mutation-spec',['review/semantic-kernel/sprint7/mutation-spec.json'],'sourceinspection','inspected')],pending=['Fresh final fourteen-mutation execution and per-variant designated/protected checks are running; development results are not acceptance evidence.'])
add('Runner controls',tasks=['7.4','7.5'],extras=[source('scripts/test_interleaving_mutation_runner.py','def main','Actual CLI control suite exists; final execution and assertion report are pending.')],pending=['Final 52-control execution and exact artifact validation pending.'])
add('Source drift',tasks=['7.1','7.4','7.5'],extras=[source('scripts/check_interleaving_mutations.py','def main','Runner source binding is inspected; actual source-drift control outcomes must be supplied.')],pending=['Final frozen-byte/during-run source-drift CLI controls pending.'])
proofaudit=artifact('frozen-imported-proof-audit',['review/semantic-kernel/sprint7/integration-final/00.log','review/semantic-kernel/sprint7/integration-final/02.log','review/semantic-kernel/sprint7/proof-inventory.json','review/semantic-kernel/sprint7/proof-types.log','review/semantic-kernel/sprint7/proof-inventory-execution.json'],note='Full build and Verify exit0; exact 262 theorem/271 supplemental name sets match fresh independent environment inventory; zero forbidden dependencies.')
add('Imported proof coverage',tasks=['6.2','6.3','8.1','8.2'],extras=[proofaudit])
add('Legacy preservation',tasks=['8.1','8.2'],extras=[artifact('fresh-lean-regression-prefix',['review/semantic-kernel/sprint7/integration-final/lean-runs.json'],'integratedaudit','partial','Only completed listed commands are evidence; complete historical source/9-suite reconciliation remains pending.')],pending=['Complete legacy mutation/runner/compiler/axiom/corpus regressions and historical-byte preservation reconciliation pending.'])
planning=artifact('planning-gate',['review/semantic-kernel/sprint7/planning/gate.json','review/semantic-kernel/sprint7/planning/ADJUDICATION.md','review/semantic-kernel/sprint7/planning/r1-gpt6.md','review/semantic-kernel/sprint7/planning/r1-fable.json','review/semantic-kernel/sprint7/planning/baseline/verification.json'],'advisoryreview','planning-gate-passed','Both planning verdicts bind bf3fb509; model/build-identity limits preserved. Baseline execution is separate measurement.')
add('Planning gate',tasks=['1.1','1.2','1.3'],extras=[planning])
add('Unavailable reviewer',tasks=['8.3','8.4'],extras=[source('AGENTS.md','An unavailable reviewer','Repository policy requires substantive exact-identity reviews and treats unavailable review as open.'),planning],pending=['Native implementation reviews are in progress; do not infer approval from availability or policy. Any unavailable/incomplete attempt and final status must be recorded.'])
add('Accepted delivery',tasks=['8.3','8.4','9.1','9.2','9.3','9.4'],extras=[planning,proofaudit,fullrun],pending=['Final mutation/control/regression completion, native implementation adjudication, roadmap/wiki status, push/readback and approved archive delivery are pending.'])
# Completed execution evidence retains its original revision. Only the proof supplement is new.
RUNTIME_CANDIDATE='6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c'
equiv_path='review/semantic-kernel/sprint7/implementation/proof-supplement-binding.json'
equiv=json.loads((ROOT/equiv_path).read_text())
assert equiv['runtime_execution_candidate']==RUNTIME_CANDIDATE
assert equiv['final_proof_candidate']==CANDIDATE and equiv['all_runtime_driver_spec_bytes_identical']
for row in equiv['files']:
 assert row['same_git_object'] and sha(ROOT/row['path'])==row['sha256']
 old=subprocess.check_output(['git','rev-parse',RUNTIME_CANDIDATE+':'+row['path']],cwd=ROOT)
 new=subprocess.check_output(['git','rev-parse',CANDIDATE+':'+row['path']],cwd=ROOT)
 assert old==new
runtime_equiv=artifact('proof-only-runtime-binding',[equiv_path], 'sourceinspection','verified',
 'Twenty-five production projection/setup inputs plus driver, CLI harness and spec are identical Git objects between actual execution6de24fe and final proofbea105ec. Does not claim all128 legacy manifest entries are identical.')
old_runtime=artifact('original-frozen-runtime',['review/semantic-kernel/sprint7/integration/01.log','review/semantic-kernel/sprint7/integration/lean-runs.json'], 'boundedruntime','verified',
 'Actual original116-comparison execution at6de24fe retained; fresh final Audit independently reruns the same116 comparisons atbea105ec.')
M['Full financial oracle']['evidence'] += [runtime_equiv,old_runtime]
mutations=json.loads((OUT/'mutations/summary.json').read_text())
mutation_results=json.loads((OUT/'mutations/results.json').read_text())['results']
assert mutations['source_revision']==RUNTIME_CANDIDATE
assert mutations['invocation']['exit']==0 and mutations['mutation_count']==14
assert mutations['control_comparisons']==116 and mutations['post_run_source_spec_driver_git_bindings_unchanged']
mutant_evidence=[]
for variant in mutations['variants']:
 name=variant['name'];actual=mutation_results[name]
 assert variant['exit']==1 and variant['comparison_count']==116
 assert variant['whole_projection_exact_one_edit']
 assert set(variant['required_false'])<=set(variant['false_comparisons'])
 assert variant['protected_checks'] and all(v=='true' for v in variant['protected_checks'].values())
 assert actual['exit']==1 and len(actual['checks'])==116
 assert all(actual['checks'][n]=='false' for n in variant['required_false'])
 assert all(actual['checks'][n]=='true' for n in variant['protected_checks'])
 logpath='review/semantic-kernel/sprint7/mutations/'+name+'.log'
 assert sha(ROOT/logpath)==variant['log_sha256']
 key=artifact(name,[logpath,'review/semantic-kernel/sprint7/mutations/summary.json',
  'review/semantic-kernel/sprint7/mutations/results.json'], 'semanticmutation','discriminated',
  'Actual compiled production edit;116 comparisons; designated false and protected true controls. Execution revision remains6de24fe.')
 E[key]['design_number']=variant['design_number'];E[key]['module']=variant['module']
 E[key]['required_false']=variant['required_false'];E[key]['false_comparisons']=variant['false_comparisons']
 E[key]['protected_checks']=variant['protected_checks'];E[key]['execution_candidate']=RUNTIME_CANDIDATE
 mutant_evidence.append(key)
M['Semantic mutation']['evidence']=mutant_evidence+[runtime_equiv]
M['Semantic mutation']['pending']=[]
controls=json.loads((OUT/'runner-controls/summary.json').read_text())
assert controls['git_head']==RUNTIME_CANDIDATE and controls['total']==controls['passed']==52
control_evidence=[];drift_evidence=[]
for case in controls['cases']:
 assert case['passed'] and case['actual_exit']==case['expected_exit']
 logpath='review/semantic-kernel/sprint7/runner-controls/'+pathlib.Path(case['log']).name
 assert sha(ROOT/logpath)==case['log_sha256']
 key=artifact(case['name'],[logpath,'review/semantic-kernel/sprint7/runner-controls/summary.json'],
  'runnercontrol','expected-outcome-verified','Actual installed CLI controls using synthetic fixture computations; not production financial theorems.')
 E[key]['command']=case['command'];E[key]['expected_exit']=case['expected_exit'];E[key]['actual_exit']=case['actual_exit'];E[key]['expected_message']=case['expected_message'];E[key]['execution_candidate']=RUNTIME_CANDIDATE
 control_evidence.append(key)
 if case['name'] in ['dirty-source-before-run','staged-source-before-run','source-drift-during-run','source-drift-during-mutant','specification-drift-during-run']:
  drift_evidence.append(key)
M['Runner controls']['evidence']=control_evidence+[runtime_equiv];M['Runner controls']['pending']=[]
M['Source drift']['evidence']=drift_evidence+[runtime_equiv];M['Source drift']['pending']=[]
regressions=json.loads((OUT/'regression-runs.json').read_text())
assert regressions['source_revision']==RUNTIME_CANDIDATE and regressions['all_commands_exit_zero']
assert regressions['sources_unchanged'] and len(regressions['runs'])==regressions['required_suite_count']==9
legacy=[]
for run in regressions['runs']:
 assert run['status']=='complete' and run['exit']==0 and run['script_unchanged']
 logpath='review/semantic-kernel/sprint7/'+run['log'];assert sha(ROOT/logpath)==run['log_sha256']
 key=artifact(run['label'],[logpath,'review/semantic-kernel/sprint7/regression-runs.json',
  'review/semantic-kernel/sprint7/regressions/source-binding.json'],'regression','completed-original-frozen-execution',
  'Actual nine-suite execution at6de24fe. The128-entry captured source manifest includes old Verify; it is not relabeled as an all-input byte-identical run atbea105ec. Final twelve-command Lean integration separately checks the added proof/import.')
 E[key]['command']=run['command'];E[key]['exit']=run['exit'];E[key]['execution_candidate']=RUNTIME_CANDIDATE
 legacy.append(key)
preserved=artifact('historical-byte-preservation',['review/semantic-kernel/sprint7/preservation.json'],
 'sourceinspection','verified-original-candidate','Protected1118 paths from850d785:1117 byte-identical, sole declared DefiKernel.lean import-root change. Proof supplement adds a new file and changes new Interleaving.Verify only.')
final_lean=artifact('final-twelve-lean-commands',['review/semantic-kernel/sprint7/integration-final/lean-runs.json',
 'review/semantic-kernel/sprint7/integration-final/verification.json'],'integratedaudit','verified',
 'Twelve actual final-source commands pass, including full build, new and legacy Lean audits; source manifest unchanged during execution.')
M['Legacy preservation']['evidence']=legacy+[preserved,final_lean,runtime_equiv]
M['Legacy preservation']['pending']=[]
M['Legacy preservation']['note']='Nine Python regression suites retain exact6de24fe run identities. Finalbea105ec changes only new Completion and its Verify import; fresh final Lean integration tests that proof extension. No all128-entry byte-equivalence assertion is made.'
M['Accepted delivery']['pending']=['Native implementation adjudication, roadmap/wiki status, push/readback and approved archive delivery are pending. Completed mutation/control/regression evidence is linked separately.']
M['Accepted delivery']['evidence'] += [final_lean,runtime_equiv]

scenarios=[]; specs={};requirements=set()
for spec in sorted((ROOT/'openspec/changes/shared-state-interleaving/specs').glob('*/spec.md')):
 text=spec.read_text();path=spec.relative_to(ROOT).as_posix();specs[path]=sha(spec)
 for match in re.finditer(r'^#### Scenario: (.+)$',text,re.M):
  title=match.group(1);assert title in M,title
  req=re.findall(r'^### Requirement: (.+)$',text[:match.start()],re.M)[-1]; requirements.add((spec.parent.name,req))
  tail=text[match.end():]; criteria=re.split(r'\n###',tail,maxsplit=1)[0].strip()
  row={'id':f'S{len(scenarios)+1:02}','capability':spec.parent.name,'requirement':req,'scenario':title,'spec':path,'line':text[:match.start()].count('\n')+1,'criteria':criteria,**M[title]}
  row['status']='pending-final-evidence' if row['pending'] else 'verified-at-frozen-source'
  assert row['evidence'],title
  scenarios.append(row)
assert len(scenarios)==43 and len(M)==43 and len({x['scenario'] for x in scenarios})==43
referenced={key for row in scenarios for key in row['evidence']}
E={key:value for key,value in E.items() if key in referenced}
for item in E.values():
 for path in item.get('artifacts',[]): assert (ROOT/path).exists(),path
record={'schema_version':1,'kind':'scenario-evidence-map','candidate':CANDIDATE,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'claim_scope':'Proof and runtime coverage at final proof source; original production mutation/control/regression executions retain their earlier source identity with explicit runtime closure binding. Native review and delivery remain pending. This is not sprint acceptance.','counts':{'capabilities':len(specs),'requirements':len(requirements),'scenarios':len(scenarios),'evidence_records':len(E),'runtime_comparisons':len(runtime),'verified_scenarios':sum(not x['pending'] for x in scenarios),'pending_scenarios':sum(bool(x['pending']) for x in scenarios)},'validation':{'all43_unique_scenarios_mapped':True,'all_scenarios_have_nonempty_evidence':True,'all_referenced_theorems_in_fresh_environment_inventory':True,'all_runtime_ids_found_true_in_frozen_audit':True,'all_current_artifact_paths_exist':True,'all_tasks_complete':False,'all_acceptance_gates_passed':False},'spec_sha256':specs,'runtime_inventory':list(runtime),'source_bindings':proof_inventory['source_bindings'],'execution_revision_binding':equiv,'scenarios':scenarios,'evidence':list(E.values()),'premise_and_scope_limits':proof_inventory['premise_and_scope_limits']}
save('scenario-map.json',record)
lines=['All 43 normative scenarios have nonempty evidence mappings at frozen source','`'+CANDIDATE+'`. This is a coverage snapshot, not final sprint acceptance.','',f"Fresh imported inventory: 262 theorem constants, 271 supplemental declarations, zero forbidden dependencies. The 127 explicit theorems comprise 107 generic proofs (one specialized to finite fixture identity types), 15 reference instances, three counterexample constructions and two counterexample corollaries. Another 135 theorem constants are generated.",'',f"The frozen runtime audit executes {len(runtime)} unique comparisons, all true. {record['counts']['verified_scenarios']} scenarios currently have verified proof/runtime/planning evidence; {record['counts']['pending_scenarios']} remain pending native review or delivery artifacts. The production results for 14 mutations, 52 controls and nine regression suites retain their actual `6de24fe` execution identities. The proof supplement has an explicit binding to the unchanged runtime inputs.",'','[Proof inventory](proof-inventory.json) retains full elaborated statements, source statements, section variables, module provenance and axioms. [Scenario map](scenario-map.json) links exact theorem names and runtime IDs to source lines and hash-bound artifacts. Generic premises and limits are explicit in both records.','','| ID | Capability | Scenario | Status |','| --- | --- | --- | --- |']
for r in scenarios: lines.append(f"| {r['id']} | {r['capability']} | {r['scenario']} | {'Pending final evidence' if r['pending'] else 'Verified frozen evidence'} |")
lines+=['','The USD10 no-supply instance does not exercise necessity of the own-invariant antecedent in its local total lemma. The generic rely/guarantee rule still requires universal local obligations, initialized invariants, cross-inclusion and independent peer stability. Recovery is restricted to actual disjoint admission and complete schedules; no arbitrary shared-state commutation is claimed. Authority assumes trusted fixed initial stores and authenticated boundaries. Nonnegativity reuses State witnesses. Financial examples remain exact-rational development fixtures with no deployed fidelity claim.','']
(OUT/'coverage.md').write_text('\n'.join(lines));print(json.dumps(record['counts'],indent=2))
