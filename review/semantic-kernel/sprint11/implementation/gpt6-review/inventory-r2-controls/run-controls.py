from pathlib import Path
import runpy,json,hashlib,subprocess,re,ast
from unittest.mock import patch
out=Path(__file__).resolve().parent
root=Path(subprocess.check_output(['git','rev-parse','--show-toplevel'],cwd=out,text=True).strip())
builder=root/'review/semantic-kernel/sprint11/implementation/proof-inventory-r1/build-proof-inventory.py'
n=runpy.run_path(str(builder)); rows=[]
def record(name,passed,detail): rows.append({'name':name,'passed':bool(passed),'detail':detail})
identity=n['resolve_candidate'](root,'HEAD')
expected=subprocess.check_output(['git','rev-parse','--verify','HEAD^{commit}'],cwd=root,text=True).strip()
record('immutable_HEAD_resolution',identity['requested_ref']=='HEAD' and identity['resolved_commit']==expected and len(expected)==40,identity)
g=n['snapshot'].__globals__; original=g['run_git']; calls=[]
def traced(r,args,*a,**kw):
 calls.append(args); return original(r,args,*a,**kw)
with patch.dict(g,{'run_git':traced}):
 a=n['snapshot'](root,expected,[root/'lean/lean-toolchain'])
 b=n['snapshot'](root,expected,[root/'lean/lean-toolchain'])
record('both_snapshots_bind_commit',a==b and all(expected+':lean/lean-toolchain' in c for c in calls),calls)
for label,before,after in [('equal',[{'path':'lean','sha256':'a','bytes':1}],[{'path':'lean','sha256':'a','bytes':1}]),('hash',[{'path':'lean','sha256':'a','bytes':1}],[{'path':'lean','sha256':'b','bytes':1}]),('path',[{'path':'lean','sha256':'a','bytes':1}],[{'path':'lake','sha256':'a','bytes':1}])]:
 try: n['assert_tool_hashes_stable'](before,after); status='PASS'
 except n['InventoryFailed'] as e: status=e.status
 record('binary_comparison_'+label,status==('PASS' if label=='equal' else 'FAIL_TOOL_BINARY_DRIFT'),status)
for module,name,origin,private,want in [('Execution','advance_sound','explicit',False,'genericproof'),('Observation','machineEq_iff','explicit',False,'genericproof'),('Schedule','checkSchedule_ok_iff','explicit',False,'genericproof'),('CausalRuntime','continueMonitored_nil','explicit',False,'genericproof'),('Examples','f10_world','explicit',False,'referenceinstance'),('FundedCausal','f10_start_K','explicit',False,'concreteproof'),('InterfaceInstances','f13_unsafe','explicit',False,'counterexample'),('Causal','helper','explicit',True,'privatehelper'),('Causal','foo.eq_1','generated',False,'generated')]:
 row={'module':'DefiKernel.Nary.'+module,'user_name':'DefiKernel.Nary.'+name,'is_private_name':private}; got=n['classify_claim'](row,origin)[0]
 record('class_'+module+'_'+name,got==want,got)
src='''namespace A
variable (outer : Nat)
section old
variable (obsolete : Nat)
namespace Inner
theorem prior : True := trivial
end Inner
end old
section new
variable (current : Nat)
theorem fresh : True := trivial
end new
theorem final : True := trivial
end A
'''
d,notes=n['index_source_text'](src,'Control','Control.lean',{'sha256':'x','git_blob':'y'})
contexts={k[1]:v['section_variables'] for k,v in d.items()}
record('nested_sibling_scopes',not notes and contexts['A.Inner.prior']==['variable (outer : Nat)','variable (obsolete : Nat)'] and contexts['A.fresh']==['variable (outer : Nat)','variable (current : Nat)'] and contexts['A.final']==['variable (outer : Nat)'],{'contexts':contexts,'notes':notes})
for label,src,local,unsupported in [('multi','import DefiKernel.One DefiKernel.Two\n',[],True),('comments','/- import DefiKernel.Bad /- nested -/ -/\n  public import DefiKernel.Good -- ignored\n',['DefiKernel.Good'],False),('external','import Mathlib.Tactic.Ring\n',[],False)]:
 got=n['local_imports_from_text'](src); record('imports_'+label,got[0]==local and bool(got[2])==unsupported,got)
# Record a known boundary without claiming general Lean syntax support.
multiline=n['local_imports_from_text']('import\n  DefiKernel.One\n')
record('document_multiline_import_boundary',multiline==([],[],[]),{'result':multiline,'limitation':'No general import parser; final candidate needs independent one-module-on-one-line validation.'})
modules=['DefiKernel.Nary.Causal','DefiKernel.Nary.Execution']; explicit={(m,'DefiKernel.Nary.helper'):{'private':True} for m in modules}; mapped={(m,'DefiKernel.Nary.helper'):m+'.privateName' for m in modules}
private=n['private_identities'](explicit,mapped)
record('private_same_user_two_modules',len(private)==2 and {r['module'] for r in private}==set(modules),private)
try:
 selfcheck=n['run_self_checks'](); (out/'self-check-observed.json').write_text(json.dumps(selfcheck,indent=2)+'\n'); self_status={'status':'PASS','count':len(selfcheck['checks'])}
except AssertionError as e: self_status={'status':'FAIL_CURRENT_LIVE_CONTEXT','error':str(e)}
record('author_selfcheck_reexecution_observation',True,self_status)
# Independent bounded source convention audit, including bare import commands the tool regex misses.
violations=[]; scanned=[]
for path in sorted((root/'lean/DefiKernel').rglob('*.lean')):
 text=n['mask_lean_comments'](path.read_text()); scanned.append(str(path.relative_to(root)))
 for lineno,line in enumerate(text.splitlines(),1):
  if re.match(r'^\s*(?:public\s+)?import\b',line):
   if not re.fullmatch(r'\s*(?:public\s+)?import[ \t]+[A-Za-z_][\w.]*[ \t]*',line): violations.append({'file':str(path.relative_to(root)),'line':lineno,'text':line})
record('current_all_DefiKernel_single_line_import_convention',not violations,{'files':len(scanned),'violations':violations})
verify=root/'lean/DefiKernel/Nary/Verify.lean'
record('parent_Verify_not_created',not verify.exists(),{'present':verify.exists()})
comp=n['classify_claim']({'module':'DefiKernel.Nary.FundedCompanions','user_name':'DefiKernel.Nary.FundedCompanions.f12_example'},'explicit')[0]
record('new_companion_role_explicitly_unresolved',comp=='unresolved_module_class',comp)
(out/'results.json').write_text(json.dumps({'reviewer':'independent GPT-6','no_Lean_execution':True,'builder_sha256':hashlib.sha256(builder.read_bytes()).hexdigest(),'checks':rows},indent=2)+'\n')
print(json.dumps({'controls':len(rows),'failed':[r for r in rows if not r['passed']],'selfcheck':self_status},indent=2))
