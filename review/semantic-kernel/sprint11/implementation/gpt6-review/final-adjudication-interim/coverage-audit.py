from pathlib import Path
import json,hashlib,subprocess,re,copy
R=Path.cwd();I=R/'review/semantic-kernel/sprint11/implementation';O=I/'gpt6-review/final-adjudication-interim';C='94f70e502c75132656bd0902a17be60ca45ab1c2';B='ed94e6050d092e67f945df7b9762d3096ab0feda';inputs={}
def sha(b):return hashlib.sha256(b).hexdigest()
def rd(p):
 p=Path(p);b=p.read_bytes();inputs[str(p)]={'sha256':sha(b),'bytes':len(b)};return b
def js(p):return json.loads(rd(p))
def git(*a):return subprocess.check_output(['git',*a],cwd=R)
rd(__file__)
x=js(I/'gpt6-review/final-gates-reconciliation-r1.json');original=copy.deepcopy(x);inv=js(I/'proof-inventory-final-r2/proof-inventory.json');rows={a['name']:a for k in ['theorems','supplemental'] for a in inv[k]}
for a in x['evidence'].values():assert sha(rd(R/a['path']))==a['sha256']
# Retain exact old review references; append current candidate transition only.
refs=[]
for s in x['scenarios']:
 for t in s['theorems']:
  n=t if isinstance(t,str) else t['name'];assert n in rows;refs.append(n)
  if isinstance(t,dict):assert t['module']==rows[n]['module']
assert (len(x['requirements']),len(x['scenarios']),len(x['tasks']),len(x['fixtures']),len(x['production_mutations']),len(x['exact_cli_controls']))==(19,52,35,19,16,65)
plan=R/'openspec/changes/finite-participant-causal-composition';req=[];sc=[]
for p in sorted((plan/'specs').glob('*/spec.md')):
 text=rd(p).decode();req += re.findall(r'^### Requirement: (.*)$',text,re.M);sc += re.findall(r'^#### Scenario: (.*)$',text,re.M)
assert len(req)==19 and len(sc)==52 and sorted(req)==sorted(a['title'] for a in x['requirements']) and sorted(sc)==sorted(a['title'] for a in x['scenarios'])
tasks=re.findall(r'^- \[ \] (\d+\.\d+) ',rd(plan/'tasks.md').decode(),re.M);assert len(tasks)==35 and set(tasks)=={a['id'] for a in x['tasks']}
for a in x['requirements']:assert set(a['scenario_ids'])=={s['id'] for s in x['scenarios'] if s['requirement_id']==a['id']}
bij=js(I/'gpt6-review/fixtures-r5-evidence/independent-bijection.json');mapping={r['old']:r['new'] for r in bij};newids=set(mapping.values());assert len(mapping)==len(newids)==310
for group in ['scenarios','fixtures']:
 for a in x[group]:
  a['runtime_check_ids']=[mapping[n] for n in a['runtime_check_ids']]
  assert all(n in newids for n in a['runtime_check_ids'])
  a['current_runtime_evidence']='review/semantic-kernel/sprint11/implementation/fixtures-r5/logs/eval-Audit.stdout'
for a in x['complete_frozen_runtime_inventory']:a['id']=mapping[a['id']]
x['supplemental_runtime_checks']=[mapping[n] for n in x['supplemental_runtime_checks']]
assert {a['id'] for a in x['complete_frozen_runtime_inventory']}==newids
x['candidate']=C;x['status']='INTERIM_NOT_FINAL_ACCEPTANCE_PENDING_COMPLETE_MUTATION_EVIDENCE';x['r5_runtime_transition']={'mapping_path':str((I/'gpt6-review/fixtures-r5-evidence/independent-bijection.json').relative_to(R)),'mapping_sha256':sha(rd(I/'gpt6-review/fixtures-r5-evidence/independent-bijection.json')),'old_runtime_evidence_preserved':True,'old_reconciliation_sha256':sha(rd(I/'gpt6-review/final-gates-reconciliation-r1.json')),'current_stdout_sha256':'4bf0c4ca9a8d15a421bfea40e1520e93ce037e271faba937188e33b39658f8f4','current_fixture_source_sha256':inv['source_bindings']['lean/DefiKernel/Nary/Tests.lean']['sha256'],'prior_runtime_delta_fields_remain_historical':True}
(O/'coverage-map-interim.json').write_text(json.dumps(x,indent=2)+'\n')
# Exact five integrated commands and all measured sources match the candidate.
a=js(I/'integrated-r2/sources-before.json');b=js(I/'integrated-r2/sources-after.json');assert a==b and len(a)==164
for row in a:
 data=git('show',C+':'+row['path']);assert sha(data)==row['sha256'] and len(data)==row['bytes']
cmds=[]
for p in sorted((I/'integrated-r2').glob('0*.json')):
 v=js(p);assert v['exit_code']==0 and v['sources_unchanged'] and not v['timed_out']
 for ext in ['stdout','stderr']:assert sha(rd(p.with_suffix('.'+ext)))==v[ext+'_sha256']
 cmds.append(v)
assert len(cmds)==5 and sha(rd(I/'integrated-r2/05-Nary-Audit.stdout'))==x['r5_runtime_transition']['current_stdout_sha256']
# Old Lean sources retain bytes except the authorized root import.
oldfiles=git('ls-tree','-r','--name-only',B,'lean').decode().splitlines();oldfiles=[p for p in oldfiles if p.endswith('.lean')];changed=[]
for p in oldfiles:
 if git('show',B+':'+p)!=git('show',C+':'+p):changed.append(p)
assert changed==['lean/DefiKernel.lean'];oldroot=git('show',B+':lean/DefiKernel.lean');newroot=git('show',C+':lean/DefiKernel.lean');assert newroot.replace(b'import DefiKernel.Nary.Verify\n',b'')==oldroot
# Historical Lean accepted separately and ancestor bytes untouched.
assert subprocess.run(['git','merge-base','--is-ancestor',B,C],cwd=R).returncode==0
historical=R/'review/semantic-kernel/program-loop-20260908/historical-lean-ed94-gpt6-review.md';rd(historical);rd(historical.with_name('historical-lean-ed94-gpt6-inputs.json'))
# Frozen package is historical, externally accepted; do not invoke planning-only check against changed root.
pkg=R/'review/semantic-kernel/sprint11/planning/grok-gpt6-r1';assert sha(rd(pkg/'MANIFEST.json'))=='3da1ced3f2ed23b77ec328432406d8b2442f5a5ea62197a570ec7cee865352cf';pm=js(pkg/'MANIFEST.json')
for row in pm['files']:
 data=rd(R/row['path']);assert sha(data)==row['sha256'] and len(data)==row['bytes']
rd(R/'review/semantic-kernel/sprint11/planning/grok-gpt6-acceptance/gpt6-package-accepted.md');rd(I/'execution-contract.json');rd(R/'AGENTS.md')
# Normative change bytes unchanged since accepted source candidate; role transition is recorded separately.
sealed=js(pkg/'source-inventory.json');planrows=[r for r in sealed['rows'] if r['path'] in sealed['expected_plan_paths']]
assert len(planrows)==15
for row in planrows:
 data=rd(R/row['path']);assert sha(data)==row['sha256'] and len(data)==row['bytes']
 assert git('show',C+':'+row['path'])==data
# Check exact inherited controls and archives under the unchanged runner/harness.
compact=js(I/'runner-r1/controls-compact.json');assert compact['total']==compact['passed']==65
for p,key in [('scripts/run_nary_mutations.py','runner_sha256'),('scripts/test_nary_mutation_runner.py','harness_sha256')]:assert sha(rd(R/p))==compact[key]
cm=js(I/'runner-r1/copy-manifest.json');regular=0
for row in cm['copied']:
 p=I/'runner-r1'/row['path']
 if p.is_file():
  data=rd(p);assert sha(data)==row['sha256'] and len(data)==row['bytes'];regular+=1
for case in compact['cases']:
 assert case['passed'] and case['actual_exit']==case['expected_exit']
 p=I/'runner-r1/controls'/Path(case['log']).name;assert sha(rd(p))==case['log_sha256']
match={a['name']:a for a in compact['cases']}
for c in x['exact_cli_controls']:assert c['expected_exit']==match[c['name']]['expected_exit'] and c['actual_exit']==match[c['name']]['actual_exit'] and c['log_sha256']==match[c['name']]['log_sha256']
oldinv=js(I/'proof-inventory-final-r1/proof-inventory.json')
for k in ['theorems','supplemental']:
 old={a['name']:a for a in oldinv[k]};new={a['name']:a for a in inv[k]}
 assert all(all(old[n][f]==new[n][f] for f in ['statement','axioms','module']) for n in old)
 if k=='theorems':assert set(old)==set(new)
 else:assert set(new)-set(old)=={'DefiKernel.Nary.Tests.emitSchedTag'}
res={'status':'INTERIM_PENDING_ALL_MUTATIONS','candidate':C,'requirement_count':19,'scenario_count':52,'task_count':35,'fixture_count':19,'theorem_reference_count':len(set(refs)),'all_referenced_theorems_in_actual_inventory':True,'r5_active_id_map_complete':True,'integrated_sources':164,'integrated_commands':cmds,'baseline_lean_file_count':len(oldfiles),'baseline_changed_only_root_import':changed,'historical_ed94_ancestor_unchanged':True,'planning_manifest_files':len(pm['files']),'normative_plan_files_equal_accepted_package':len(planrows),'inherited_runner_controls':65,'copied_regular_control_artifacts_checked':regular,'old_inventory_types_axioms_unchanged':True,'only_new_supplemental':'DefiKernel.Nary.Tests.emitSchedTag','inputs':inputs}
(O/'coverage-audit-results.json').write_text(json.dumps(res,indent=2)+'\n');print(json.dumps({k:v for k,v in res.items() if k not in ['inputs','integrated_commands']},indent=2))
