import pathlib,json,hashlib,subprocess,gzip,shutil,re
R=pathlib.Path('/home/charl/defiformal');W=pathlib.Path('/home/charl/defiformal-wt-certificates-grok-gpt6-20260908');X=R/'review/semantic-kernel/program-execution-20260908';O=X/'p19-r3-planning-review';P=W/'openspec/changes/serialized-kernel-certificates'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def save(n,x):(O/n).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
f={x['id']:x for x in json.loads((P/'fixtures.json').read_text())['fixtures']};c=json.loads((P/'correspondence-theorems.json').read_text());a=json.loads((P/'result-algebra.json').read_text())
assert f['F25']['inputs']['payload']==f['F36']['inputs']['payload']==f['F37']['inputs']['payload']==f['F41']['inputs']['payload']
save('remaining-contract-findings.json',{'evidence_class':'stored-value and contract comparison; no kernel/checker execution','R1':{'identical_kernel_payload_rows':['F25','F36','F37','F41'],'normalized_payload_sha256':hashlib.sha256(json.dumps(f['F25']['inputs']['payload'],sort_keys=True,separators=(',',':')).encode()).hexdigest(),'rows':{i:f[i] for i in ['F25','F36','F37','F41']},'contract':c,'finding':'F37 source_identity precheck leaves world pre/receipt null; T-kernel-execute-ok nonetheless demands post world and invoked receipt from kernelProjection(checkIR ir). Companion error/step/run claims need the same prior-domain restriction. Observation-mismatch needs prior source_identity. Accepted policy must explicitly include requested library/invariant discharge checks from result algebra.'},'R3':{'rows':{i:f[i] for i in ['F17','F18','F24','F49']},'aggregation':a['staged_family_aggregation'],'finding':'Accounting guard is a reached successful stage in F17/F18, so combine_one_command yields true; both stored expected accountingCorrect remain not_reached.'}})
rows=[]
for i in ['F09','F17','F18','F19','F23','F40','F47']:
 q=f[i]['inputs']['payload'];r=q.get('request',q.get('step',{}).get('invocation'));s=q.get('store',q.get('pre',{}).get('capabilities'));ctx=q.get('ctx',q.get('boundary',{}).get('ctx'));hits=[j for j in r['capabilityIds'] if j<len(s['entries']) and s['entries'][j]['live'] and s['entries'][j]['operation']==r['operation'] and s['entries'][j]['holder']==ctx['principal'] and s['entries'][j]['domain']==ctx['domain'] and s['entries'][j]['right']=={'tag':'invoke'}];assert hits
 post=f[i]['expected']['world']['capabilities'];assert post==s
 rows.append({'id':i,'request':r,'ctx':ctx,'matching_invoke_ids':hits,'store':s,'expected_full_store_matches':True,'expected':f[i]['expected']})
save('repaired-authority-observations.json',{'evidence_class':'source-shaped precondition/literal comparison, not kernel execution','rows':rows,'F18_env':f['F18']['inputs']['payload']['env'],'F47_template':next(t for t in f['F47']['inputs']['payload']['config']['registry']['entries'] if t['id']==4)})
old=json.loads((X/'p19-planning-review/dependency-closure.json').read_text());mods={}
for name,v in old['modules'].items():
 p=W/v['path'];assert h(p)==v['sha256'];assert h(R/v['path'])==h(p);mods[name]={**v,'primary_equal_current':True}
save('dependency-closure.json',{**old,'modules':mods,'current_primary_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()})
proj=json.loads((P/'mutation-projection.json').read_text());allow=proj['proof_only_allowlist'];assert len(allow)==4
for x in allow:assert h(W/x['source'])==x['input_sha256']
save('projection-and-mutants.json',{'projection':proj,'mutants':[m for m in json.loads((P/'planned-mutations.json').read_text())['mutations'] if m['id'] in ['M03','M06','M09','M10','M15']],'allowlist_hashes_match':True,'names_match_prior_four_declaration_inventory':True,'limit':'No projection driver or mutants executed; legacy consumers_in_closure lists are overinclusive closure lists, not exact reverse import edges.'})
ends={}
for kind in ['attempt1','closeout']:
 p=X/f'p19-planning-author-r3-{kind}.jsonl.gz';raw=gzip.decompress(p.read_bytes());ev=[json.loads(l) for l in raw.splitlines()];last=[e for e in ev if e.get('type')=='end'];assert len(last)==1;ends[kind]={'path':str(p),'compressed_sha256':h(p),'raw_sha256':hashlib.sha256(raw).hexdigest(),'terminal':last[0]}
assert ends['attempt1']['terminal']['stopReason']=='cancelled' and ends['closeout']['terminal']['stopReason']=='end_turn'
save('native-identity.json',{'requested':'grok-4.6','actual_key':'grok-4.6-build','events':ends,'process_exit_evidence':{'attempt1':json.loads((X/'p19-planning-author-r3-attempt1-terminal.json').read_text())['process_exit'],'closeout':json.loads((X/'p19-candidate-r3-manifest.json').read_text())['native_process_exit']},'reviewer_requested':'gpt-6-astra','reviewer_actual_provider_telemetry':None,'metadata_alias_not_actual_telemetry':True})
# Exact input snapshots and preserved failure streams.
manifest=json.loads((X/'p19-candidate-r3-manifest.json').read_text());paths=[W/k for k in manifest['read_only_inputs']]+[W/v['path'] for v in mods.values()]+[R/'AGENTS.md',R/'openspec/changes/reusable-verification-platform-program/tasks.md',R/'openspec/changes/reusable-verification-platform-program/sprint-index.json',X/'PLAN-ACCEPTANCE.md',X/'p19-planning-review/REVIEW.md',X/'p19-planning-review/verdict.json',X/'p19-planning-review/evidence-manifest.json']
paths += [p for p in X.glob('p19-*') if p.is_file()]
snap={}
for p in dict.fromkeys(paths):
 base=W if p.is_relative_to(W) else R;rel=('worktree/' if base==W else 'primary/')+str(p.relative_to(base));dest=O/'inputs'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest);snap[str(p)]={'snapshot':str(dest.relative_to(O)),'sha256':h(p)}
save('input-snapshots.json',snap)
print(json.dumps({'authority_rows':len(rows),'all_full_expected_stores_match':True,'actual_closure':len(mods),'primary_dependencies_match':True,'allowlist':len(allow),'native_stops':{k:v['terminal']['stopReason'] for k,v in ends.items()},'snapshots':len(snap)},indent=2))
