import pathlib,json,hashlib,subprocess,gzip,shutil
R=pathlib.Path('/home/charl/defiformal');W=pathlib.Path('/home/charl/defiformal-wt-certificates-grok-gpt6-20260908');X=R/'review/semantic-kernel/program-execution-20260908';O=X/'p19-r4-planning-review';P=W/'openspec/changes/serialized-kernel-certificates';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def save(n,x):(O/n).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
c=json.loads((P/'correspondence-theorems.json').read_text());a=json.loads((P/'result-algebra.json').read_text());f={x['id']:x for x in json.loads((P/'fixtures.json').read_text())['fixtures']};oldP=X/'p19-r3-planning-review/sandbox/openspec/changes/serialized-kernel-certificates'
assert (P/'fixtures.json').read_bytes()==(oldP/'fixtures.json').read_bytes()
for name in ['planned-mutations.json','mutation-projection.json','baseline.json','schema.json','observation-contract.json']:assert (P/name).read_bytes()==(oldP/name).read_bytes()
assert f['F25']['inputs']['payload']==f['F36']['inputs']['payload']==f['F37']['inputs']['payload']==f['F41']['inputs']['payload']
rows=[]
for i in ['F17','F18','F24','F49']:
 outcome=next(x['outcome'] for x in f[i]['expected']['judgments'] if x['family']=='accountingCorrect');assert outcome==('not_reached' if i in ['F17','F18'] else 'false');rows.append({'id':i,'accountingCorrect':outcome,'fixture':f[i]})
raw=[x for x in c['statements'] if x['id'].startswith('T-raw-')];connections=[x for x in c['statements'] if x['id'].startswith('T-checkIR-')];assert len(raw)==5 and len(connections)==6
assert all('supported ir' in t['statement'] for t in raw);assert all('source_identity' in t['statement'] for t in connections)
save('scoped-contract-audit.json',{'evidence_class':'independent source/contract review and stored-value comparison; not theorem elaboration','raw_execution_api':c['raw_execution_api'],'raw_theorems':raw,'guarded_report_connections':connections,'full_correspondence_contract':c,'policy_rows':{i:f[i] for i in ['F25','F36','F37','F41']},'staged_accounting':{'contract':a['staged_family_aggregation'],'complete_refused':a['truth_table_complete_for_increment']['complete_refused'],'rows':rows},'unchanged_repaired_inputs':['fixtures.json','planned-mutations.json','mutation-projection.json','baseline.json','schema.json','observation-contract.json'],'planning_interpretations':['recorded compiler predicates consume the exact matching external candidate/compiler/audit records required by audit.identity_split; certificate-supplied strings/exit claims alone do not discharge','T-checkIR typed/step error conclusions govern kernel refusal after source identity; successful-execution policy checks cannot replace these error constructors']})
old=json.loads((X/'p19-r3-planning-review/dependency-closure.json').read_text());mods={}
for n,v in old['modules'].items():
 p=W/v['path'];assert h(p)==v['sha256'] and h(R/v['path'])==h(p);mods[n]=v
save('dependency-closure.json',{**old,'modules':mods,'current_primary_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'source_bytes_reverified':True})
p=X/'p19-planning-author-r4.jsonl.gz';rawbytes=gzip.decompress(p.read_bytes());ev=[json.loads(l) for l in rawbytes.splitlines()];end=[e for e in ev if e.get('type')=='end'];assert len(end)==1 and end[0]['stopReason']=='end_turn' and end[0]['num_turns']==27
save('native-identity.json',{'requested_model':'grok-4.6','actual_model_keys':list(end[0]['modelUsage']),'session_id':end[0]['sessionId'],'terminal':end[0],'compressed_stream_sha256':h(p),'raw_sha256':hashlib.sha256(rawbytes).hexdigest(),'process_exit':json.loads((X/'p19-candidate-r4-manifest.json').read_text())['native_process_exit'],'process_receipt':'p19-candidate-r4-manifest.json','reviewer_requested_model':'gpt-6-astra','reviewer_actual_provider_telemetry':None,'cancelled_prior_attempts_are_historical_not_acceptance':True})
manifest=json.loads((X/'p19-candidate-r4-manifest.json').read_text());paths=[W/k for k in manifest['read_only_inputs']]+[W/v['path'] for v in mods.values()]+[R/'AGENTS.md',R/'openspec/changes/reusable-verification-platform-program/tasks.md',R/'openspec/changes/reusable-verification-platform-program/sprint-index.json',X/'PLAN-ACCEPTANCE.md']
paths += [X/'p19-r3-planning-review'/k for k in ['REVIEW.md','verdict.json','evidence-manifest.json','remaining-contract-findings.json']]
paths += [p for p in X.glob('p19-*') if p.is_file()]
snap={}
for p in dict.fromkeys(paths):
 base=W if p.is_relative_to(W) else R;rel=('worktree/' if base==W else 'primary/')+str(p.relative_to(base));dest=O/'inputs'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest);snap[str(p)]={'snapshot':str(dest.relative_to(O)),'sha256':h(p)}
save('input-snapshots.json',snap)
print(json.dumps({'raw_theorem_obligations':len(raw),'guarded_report_connections':len(connections),'staged_rows':len(rows),'source_modules':len(mods),'snapshots':len(snap),'native_turns':end[0]['num_turns'],'native_stop':end[0]['stopReason']},indent=2))
