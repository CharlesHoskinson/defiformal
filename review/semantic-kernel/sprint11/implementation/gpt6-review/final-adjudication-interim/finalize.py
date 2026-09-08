from pathlib import Path
import json,hashlib,datetime,subprocess,copy
R=Path.cwd();I=R/'review/semantic-kernel/sprint11/implementation';G=I/'gpt6-review';O=G/'final-adjudication-interim';C='94f70e502c75132656bd0902a17be60ca45ab1c2';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();j=lambda p:json.loads(Path(p).read_text())
coverage=j(O/'coverage-map-interim.json');ca=j(O/'coverage-audit-results.json');ia=j(O/'audit-results.json');ma=j(O/'mutation-audit-results.json');aa=j(O/'archive-audit-results.json');inv=j(I/'proof-inventory-final-r2/proof-inventory.json');native=j(O/'native-final-lanes.json');assert aa['status']=='PASS_EXACT_ARCHIVE_AND_ALL16_REVIEW_BINDINGS' and len(ma['results'])==16
actual={r['name']:r for kind in ['theorems','supplemental'] for r in inv[kind]}
# Recheck immutable input hashes at final gate; do not run Lean/cache commands.
inputs={}
for data in [ca,ia,ma]:
 for path,row in data['inputs'].items():
  assert sha(path)==row['sha256'],path
  inputs[path]={'sha256':row['sha256'],'bytes':row['bytes']}
for row in j(I/'candidate-source-freeze-r2.json')['integrated_sources']:
 p=R/row['path'];assert sha(p)==row['sha256'];assert subprocess.check_output(['git','show',C+':'+row['path']],cwd=R)==p.read_bytes()
scenarios=[]
for s in coverage['scenarios']:
 t=[]
 for ref in s['theorems']:
  name=ref if isinstance(ref,str) else ref['name'];r=actual[name]
  t.append({'name':name,'module':r['module'],'source':r['source'],'source_sha256':r['source_sha256'],'axioms':r['axioms'],'full_statement_inventory':'proof-inventory-final-r2/proof-inventory.json','narrow_review_reference':ref})
 statuses=[z for z in s['statuses'] if z not in ['unresolved']]
 if s['id']=='finite-participant-regression-evidence:S03':statuses=['runtime','source_mutation_detection']
 if s['id']=='finite-participant-regression-evidence:S04':statuses=['recorded','runtime','blocked_attempt_no_credit']
 if s['id']=='finite-participant-regression-evidence:S06':statuses=['recorded','actual_full_inventory','runtime_projection_verified']
 if s['id']=='finite-participant-regression-evidence:S08':statuses=['recorded','independent_final_adjudication']
 note=s['limits_or_remaining']
 replacements={
 'finite-participant-regression-evidence:S03':'All sixteen separate SPEC invocations independently verified: exact inlined current runtime source, single actual mutation,310 complete observations, named false checks and each SPEC protected positive;624 archive files bind these runs.',
 'finite-participant-regression-evidence:S04':'Earlier M01 control-label failure is preserved with exit3,zero mutants and zero detection credit. Final16 invocations have no timeout/compiler/setup failure; only expected nonzero runtime-comparison failure receives detection credit. Raw child stdout/stderr are combined by the frozen runner.',
 'finite-participant-regression-evidence:S06':'Actual final inventory contains1459 theorem and1131 supplemental rows, with full statements, exact fresh-audit equality, standard axioms and immutable57-source bindings.317 theorem source-owner attributions remain explicitly unresolved, not missing proofs. Exact runtime projection retains all runtime declarations and strips permitted proof tails only.',
 'finite-participant-regression-evidence:S08':'All source, narrow mathematical reviews, integrated execution, full inventory, controls and mutations bind candidate94f70e5. Independent final GPT6 adjudication accepts code/evidence readiness for authorized release. Publication and remote-byte verification remain task8.5.'}
 note=replacements.get(s['id'],note)
 scenarios.append({'id':s['id'],'requirement_id':s['requirement_id'],'title':s['title'],'spec_path':s['spec_path'],'line':s['line'],'status':'ACCEPTED_FOR_CODE_AND_EVIDENCE_SCOPE','evidence_classes':statuses,'theorems':t,'runtime_check_ids':s['runtime_check_ids'],'runtime_evidence':'review/semantic-kernel/sprint11/implementation/fixtures-r5/logs/eval-Audit.stdout','fixture_ids':s['fixture_ids'],'scope_and_limits':note})
requirements=[{'id':r['id'],'title':r['title'],'spec':r['spec'],'path':r['path'],'scenario_ids':r['scenario_ids'],'status':'ACCEPTED_FOR_CODE_AND_EVIDENCE_SCOPE','delivery_claim':False} for r in coverage['requirements']]
tasks=[]
for t in coverage['tasks']:
 q={'id':t['id'],'text':t['text'],'status':'ACCEPTED_FOR_RELEASE','evidence_classes':t['status'].replace('/unresolved','').replace('unresolved','recorded_and_verified'),'normative_checkbox_unchanged':True}
 if t['id']=='8.5':q['status']='PENDING_AUTHORIZED_DELIVERY_AND_REMOTE_BYTE_VERIFICATION';q['evidence_classes']='post_adjudication_delivery';q['disposition']='Code/evidence accepted here; publishing, archive transport and remote verification remain parent work. M3 delivery completion is not asserted.'
 elif t['id']=='8.4':q['disposition']='Current explicit user nativeGrok author/GPT6 checker assignment supersedes historical Grok/Fable role wording. Eleven directly verified final native Grok lane identities and independent nonauthor GPT6 gates support this acceptance.'
 elif t['id'] in ['7.3','7.4']:q['disposition']='Sixteen actual independent SPEC detections and retained blocked-r1 disposition; exact archive/outer commands in production-mutations-r2 manifest.'
 elif t['id']=='8.1':q['disposition']='Five integrated-r2 commands exit0;164 exact inputs;141 prior Lean files unchanged except root import, plus3 config pins.'
 elif t['id']=='8.2':q['disposition']='Actual final-r2 inventory1459+1131; full raw statements/axioms/source/tool binding independently verified.'
 elif t['id']=='8.3':q['disposition']='This final map retains19requirements/52scenarios/35tasks/19fixtures/310r5IDs/16mutants/65actual inherited controls.'
 else:q['disposition']=t['evidence_or_open_work']
 tasks.append(q)
fixtures=[]
for f in coverage['fixtures']:
 q={k:copy.deepcopy(f[k]) for k in ['id','name','classification','scenario_ids','runtime_check_ids','runtime_check_definition']}
 if f['id']=='F18':q['classification']='actual accepted M2 API instantiation; six funded schedules plus universal conditional preservation proof'
 if f['id']=='F19':q['classification']='actual accepted M2 checkBindings/bindingsHold API funded negative'
 q['status']='ACCEPTED_WITH_STATED_FIXTURE_CLASS';q['source']='lean/DefiKernel/Nary/Tests.lean';q['source_sha256']=inv['source_bindings']['lean/DefiKernel/Nary/Tests.lean']['sha256'];q['runtime_evidence']='review/semantic-kernel/sprint11/implementation/fixtures-r5/logs/eval-Audit.stdout';fixtures.append(q)
premises=copy.deepcopy(coverage['explicit_premises'])
for p in premises:
 if p['id']=='generic_causal':p['discharge']='Concrete Funded r3 independently discharges initialized K, derivation, local actual-success, inclusion/stability and skip/refusal/success-update obligations. The four arbitrary-current-world helpers and live-selected reachable-K bridge establish actual execution success without assuming desired final reserve or future success.'
evidence=copy.deepcopy(coverage['evidence'])
for key,name in [('runtime_r5','fixtures-r5-review.md'),('funded_final','funded-causal-r3-review.md'),('historical_lean','../../../program-loop-20260908/historical-lean-ed94-gpt6-review.md')]:
 p=(G/name).resolve()
 if not p.exists() and key=='historical_lean':p=R/'review/semantic-kernel/program-loop-20260908/historical-lean-ed94-gpt6-review.md'
 evidence[key]={'path':str(p.relative_to(R)),'sha256':sha(p),'bytes':p.stat().st_size}
limits=['Acceptance is exact Sprint11/M3 code and evidence readiness for authorized release; task8.5 publication and remote verification remain pending. No claim that remote delivery already happened.',
 'Generic proofs retain initialization, local-success/guarantee, cross-inclusion, stability, current external-state, support/frame and monitor-update premises. Actual enabledness is separately proved for fixed F10; generic soundness does not imply arbitrary progress.',
 'Fixed financial examples use rational arithmetic and fixed configuration/capability/boundary/store assumptions. Synthetic comparators and logical counterexamples are not funded executions. No deployed-system fidelity or holdout/corpus evaluation claim.',
 'Full statements are authoritative.317 theorem source-owner attributions remain unresolved/ambiguous, although actual names,module/file hashes,types and axioms are present. Role categories are not counts of independently authored mathematical claims.',
 'Inventory covers imported theorem constants and supplemental definitions,opaque constants,axioms; it does not claim every ConstantInfo kind such as constructors/recursors. External Lean/Mathlib packages remain pinned toolchain/configuration trust, without an entire external cache inventory.',
 'Public F10 admission and S10 ledger conservation are accepted proof compositions; the former has a retained reviewer-only kernel-checked corollary. Neither requires an additional named native feature export.',
 'Historical ed94 Lean bridge is separately accepted within its bounded mathematical scope and retains original GPT authorship. Historical tooling/corpus acceptance and unaccepted later worktrees are excluded.',
 'M4 participant-tree regrouping, later milestones, and complete FormalDeFi program acceptance remain open. Original planning packages, Fable no-verdict, blocked runs and failed reviewer probes retain their identities.']
final={'schema_version':1,'status':'ACCEPT_WITH_LIMITATIONS_CODE_AND_EVIDENCE_READY_FOR_AUTHORIZED_RELEASE','candidate':C,'reviewer':{'model':'GPT-6 / gpt-6-astra','agent':'/root/causal_check','nonauthor_of_feature_code':True},'created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'source_or_plan_edits_in_final_review':False,'Lean_or_cache_commands_in_final_review':False,'required_fixes':[],'delivery_task_8_5':'PENDING','remote_delivery_claim':False,'counts':{'requirements':19,'scenarios':52,'tasks':35,'tasks_accepted_for_release':34,'delivery_tasks_pending':1,'fixtures':19,'runtime_rows':310,'runtime_false':0,'theorems':1459,'supplemental':1131,'source_config_inventory':57,'integrated_source_inputs':164,'production_mutations_accepted':16,'inherited_actual_controls':65},'requirements':requirements,'scenarios':scenarios,'tasks':tasks,'fixtures':fixtures,'explicit_premises':premises,'complete_runtime_inventory':coverage['complete_frozen_runtime_inventory'],'supplemental_runtime_checks':coverage['supplemental_runtime_checks'],'r5_label_transition':coverage['r5_runtime_transition'],'production_mutations':ma['results'],'mutation_archive':aa,'blocked_r1':j(O/'blocked-r1-audit.json'),'inherited_actual_cli_controls':coverage['exact_cli_controls'],'native_author_lanes':native,'narrow_evidence':evidence,'inventory_checks':ia['data_checks'],'inventory_attribution_counts':ia['counts'],'source_bindings':inv['source_bindings'],'integrated_commands':ca['integrated_commands'],'baseline_equivalence':{'prior_Lean_files':141,'config_pins':3,'only_changed_prior_Lean':'lean/DefiKernel.lean','change':'added import DefiKernel.Nary.Verify','historical_ed94_is_unchanged_ancestor':True},'planning_transition':{'accepted_manifest_sha256':'3da1ced3f2ed23b77ec328432406d8b2442f5a5ea62197a570ec7cee865352cf','sealed_files_unchanged':112,'normative_plan_files_unchanged':15,'role_contract':'review/semantic-kernel/sprint11/implementation/execution-contract.json','current_user_roles':'Native Grok4.6 author; independent GPT6 checker; no Foreman','old_pending_worker_artifacts_remain_historical':True},'gate_disposition':[{'id':'G'+str(k),'status':'CLOSED_FOR_CODE_AND_EVIDENCE_READY_SCOPE','delivery_pending':k==6} for k in range(1,7)],'limitations':limits,'preserved_previous_reconciliation':'review/semantic-kernel/sprint11/implementation/gpt6-review/final-gates-reconciliation-r1.json','interim_audit_directory':str(O.relative_to(R))}
assert len(final['requirements'])==19 and len(final['scenarios'])==52 and len(final['tasks'])==35 and len(final['fixtures'])==19
(G/'final-adjudication-r1.json').write_text(json.dumps(final,indent=2)+'\n')
# The human review is written below; input manifest will be finalized afterward.
(O/'final-inputs-collected.json').write_text(json.dumps(inputs,indent=2)+'\n')
print('JSON',sha(G/'final-adjudication-r1.json'),'reviewedinputs',len(inputs))
