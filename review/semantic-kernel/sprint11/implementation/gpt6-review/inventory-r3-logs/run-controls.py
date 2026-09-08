from pathlib import Path
import runpy,subprocess,json,hashlib,copy,re
out=Path(__file__).resolve().parent;root=Path(subprocess.check_output(['git','rev-parse','--show-toplevel'],cwd=out,text=True).strip());base=root/'review/semantic-kernel/sprint11/implementation'
builder=base/'proof-inventory-r1/build-proof-inventory.py';driver=builder.parent/'proof-inventory-driver.lean'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
n=runpy.run_path(str(builder));checks=[]
def check(name,passed,detail):checks.append({'name':name,'passed':bool(passed),'detail':detail})
source_before={str(p.relative_to(root)):digest(p) for p in (root/'lean/DefiKernel').rglob('*.lean')};tools_before={str(p.relative_to(root)):digest(p) for p in [builder,driver]}
for module in ['FundedCompanions','FundedEnabledness']:
 for short,private,origin,want in [('f10_positive',False,'explicit','concreteproof'),('f12_negative',False,'explicit','counterexample'),('f16_negative',False,'explicit','counterexample'),('f17_negative',False,'explicit','counterexample'),('helper',True,'explicit','privatehelper'),('helper.eq_1',False,'generated','generated')]:
  row={'module':'DefiKernel.Nary.'+module,'user_name':'DefiKernel.Nary.'+module+'.'+short,'is_private_name':private};category,note=n['classify_claim'](row,origin)
  check('class_'+module+'_'+short,category==want,{'category':category,'note':note})
for label,text,want_local,want_unsupported in [('bare','import\n',[],True),('bare_following','import\n  DefiKernel.One\n',[],True),('public_bare','  public import\n DefiKernel.One\n',[],True),('comment_only','/- import\nDefiKernel.Bad\n-/\nimport DefiKernel.Good\n',['DefiKernel.Good'],False),('nested_comment','/- import /- import -/ -/\n public import DefiKernel.Good -- note\n',['DefiKernel.Good'],False),('two_tokens','import DefiKernel.One DefiKernel.Two\n',[],True),('trailing_comment','import DefiKernel.One /- note -/\n',['DefiKernel.One'],False)]:
  got=n['local_imports_from_text'](text);check('imports_'+label,got[0]==want_local and bool(got[2])==want_unsupported,got)
closure=n['local_source_closure_report'](root,root/'lean',root/'lean/DefiKernel/Nary');(out/'closure-observed.json').write_text(json.dumps(closure,indent=2)+'\n')
check('live_closure_structurally_valid',n['closure_invariant_holds'](closure),{k:v for k,v in closure.items() if k!='files'})
future=copy.deepcopy(closure);future['reachable_count']+=1;future['nary_present_count']+=1
check('future_Verify_count_growth_not_brittle',n['closure_invariant_holds'](future),{'reachable_count':future['reachable_count'],'nary_present_count':future['nary_present_count'],'limit':'Predicate test only; actual future Verify import coverage must pass source_paths.'})
for field,bad in [('required_missing',['FundedEnabledness.lean']),('nary_missing_from_closure',['lean/DefiKernel/Nary/FundedCompanions.lean']),('unsupported',[{'reason':'bare_or_multiline_import'}]),('nonempty',False),('unique',False)]:
  changed=copy.deepcopy(closure);changed[field]=bad;check('closure_rejects_'+field,not n['closure_invariant_holds'](changed),bad)
try:n['source_paths'](root,root/'lean');status='UNEXPECTED_PASS'
except n['InventoryBlocked'] as e:status=e.status
check('actual_execution_still_blocks_absent_parent_Verify',status=='BLOCKED_MISSING_VERIFY',status)
selfcheck=n['run_self_checks']();(out/'self-check-observed.json').write_text(json.dumps(selfcheck,indent=2)+'\n')
check('current_selfcheck_pass',selfcheck['status']=='PASS' and all(x['passed'] for x in selfcheck['checks']),{'count':len(selfcheck['checks']),'status':selfcheck['status']})
source_after={str(p.relative_to(root)):digest(p) for p in (root/'lean/DefiKernel').rglob('*.lean')};tools_after={str(p.relative_to(root)):digest(p) for p in [builder,driver]}
check('tool_bytes_unchanged',tools_before==tools_after,{'before':tools_before,'after':tools_after})
source_drift=[p for p in set(source_before)|set(source_after) if source_before.get(p)!=source_after.get(p)]
(out/'source-bindings.json').write_text(json.dumps({'before':source_before,'after':source_after,'drift':source_drift,'source_not_candidate_frozen':True},indent=2)+'\n')
(out/'results.json').write_text(json.dumps({'reviewer':'independent GPT-6','no_Lean_execution':True,'no_cache_commands':True,'tool_before':tools_before,'tool_after':tools_after,'source_drift':source_drift,'checks':checks},indent=2)+'\n')
print(json.dumps({'checks':len(checks),'failed':[r for r in checks if not r['passed']],'selfcheck_entries':len(selfcheck['checks']),'current_closure_files':closure['reachable_count'],'source_drift':source_drift,'builder_sha256':digest(builder)},indent=2))
