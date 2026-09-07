"""Author-only planning reconciliation. Does not implement or execute adjudication behavior."""
from pathlib import Path
import json,re,hashlib,subprocess,datetime,shutil,time
R=Path('/home/charl/defiformal');P=R/'openspec/changes/corpus-provenance-adjudication';E=Path(__file__).resolve().parent
utc=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def bind(p):return {'path':str(p.relative_to(R)),'sha256':sha(p),'bytes':p.stat().st_size}
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
before=json.loads((E/'before.json').read_text());checks=[]
def check(n,v):
 checks.append({'name':n,'pass':bool(v)})
 if not v:
  write(E/'attempt-failure.json',{'utc':utc(),'checks':checks});raise AssertionError(n)
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
for x in before['plan_files']:check('before-copy:'+x['path'],sha(E/'before'/x['path'])==x['sha256'])
for x in before['protected']:check('protected-before:'+x['path'],sha(R/x['path'])==x['sha256'])
# Actual independent denominator comes from normalized rule records, not copied counters.
corpus_path=R/'corpus/normalized/generated/corpus.json';corpus=json.loads(corpus_path.read_text())
actual=[]
for i,row in enumerate(corpus['adjudications']):
 if row['rule']=='INTERSECTION_UNRESOLVED':
  labels=sorted(set(row['a'])^set(row['b']));check('raw-symmetric-difference:'+str(i),labels==sorted(row['unresolved_labels']))
  actual.append({'pointer':f'#/adjudications/{i}','unit_id':row['unit_id'],'facet':row['facet'],'a':row['a'],'b':row['b'],'labels':labels})
inv=json.loads((P/'dispute-inventory.json').read_text()); expected={(x['unit_id'],x['facet'],label)for x in actual for label in x['labels']};queued={(x['unit_id'],x['facet'],label)for x in inv['disagreements']for label in x['disputed_labels']}
check('actual-exact-queue-label-tuples',expected==queued)
check('actual-exact-queue-facet-tuples',{(x['unit_id'],x['facet'])for x in actual}=={(x['unit_id'],x['facet'])for x in inv['disagreements']})
counts={'facet_disagreements':len(actual),'disputed_label_instances':len(expected),'affected_units':len({x['unit_id']for x in actual}),'distinct_labels':len({x[2]for x in expected})}
check('observed-baseline29-32-24-17',list(counts.values())==[29,32,24,17])
write(E/'actual-disputes.json',{'status':'read_only_derivation_no_adjudication','source':bind(corpus_path),'counts':counts,'records':actual})
inv['derivation']={'source':bind(corpus_path),'filter':'adjudications where rule == INTERSECTION_UNRESOLVED; labels = set(a) symmetric_difference set(b)','counts':counts,'comparison':'Exact unit/facet/label tuples match inventory; not inferred from its counters.'};write(P/'dispute-inventory.json',inv)
# Literal rule payload equals old and new table, including parsed row fields.
rules=json.loads((P/'rules.json').read_text());rows=[l for l in (P/'design.md').read_text().splitlines()if l.startswith('| `R-')]
old=[l for l in (E/'before'/P.relative_to(R)/'design.md').read_text().splitlines()if l.startswith('| `R-')]
check('18-literal-predicates-preserved',rows==old and len(rows)==18)
check('authoritative-rules-equal-table',[x['literal_markdown_row']for x in rules['rules']]==rows)
for r in rules['rules']:
 cols=[x.strip()for x in r['literal_markdown_row'].strip('|').split('|')]
 check('parsed-rule-row:'+r['id'],cols==[f"`{r['id']}` / {r['facet']}",r['positive_evidence'],r['insufficient_alone']])
# Precise normative scenario inventory and task links; every block retained verbatim.
oldmap=json.loads((E/'before'/P.relative_to(R)/'scenario-map.json').read_text())['scenarios'];taskmap={x['scenario_id']:x['task_ids']for x in oldmap}
taskmap.update({'SRC-11':['2.3','7.3'],'SRC-12':['2.3','7.3'],'SRC-13':['2.2','7.3'],'SRC-14':['2.4','7.3'],'ADJ-12':['5.2','5.5'],'ADJ-13':['5.2','5.3'],'ADJ-14':['5.3','5.5'],'ADJ-15':['5.3','5.5'],'ADJ-16':['5.3','7.3'],'ADJ-17':['5.3','7.3'],'EV-07':['6.1'],'EV-08':['6.1','2.4','7.3'],'CHK-11':['7.1','7.3'],'CHK-12':['7.1','7.3'],'CHK-13':['2.4','5.5','7.2'],'CHK-14':['1.1','5.2','7.3'],'CHK-15':['1.1','8.1']})
scenarios=[];reqs=[]
for p in sorted((P/'specs').glob('*/spec.md')):
 text=p.read_text();req=None
 for line in text.splitlines():
  if line.startswith('### Requirement: '):req=line.split(': ',1)[1];reqs.append({'capability':p.parent.name,'requirement':req})
  if line.startswith('#### Scenario: '):
   title=line.split(': ',1)[1];sid=title.split()[0];start=text.index(line);end=text.find('\n###',start+1);block=text[start:end if end>=0 else len(text)].strip()
   scenarios.append({'scenario_id':sid,'title':title,'capability':p.parent.name,'requirement':req,'spec':bind(p),'normative_block':block,'task_ids':taskmap[sid],'status':'planned_not_executed','planned_control_families':[]})
tasks=[{'id':m.group(2),'checked':m.group(1)=='x','text':m.group(3)}for m in re.finditer(r'^- \[([ x])\] (\d+\.\d+) (.*)$',(P/'tasks.md').read_text(),re.M)]
check('all-28-tasks-unchecked',len(tasks)==28 and not any(x['checked']for x in tasks));check('20-requirements-65-unique-scenarios',len(reqs)==20 and len(scenarios)==len({x['scenario_id']for x in scenarios})==65)
for s in scenarios:check('task-link:'+s['scenario_id'],set(s['task_ids'])<={t['id']for t in tasks})
# Concrete proposed real-CLI control families. These are designs, not executions.
F=[]
def family(fid,sc,mode,good,bad,code,reason):
 F.append({'family_id':fid,'scenarios':sc.split(),'entry_point':'scripts/corpus_adjudicate.py '+mode,'fixture_scope':'isolated multi-record local fixture; literals independent of production projection','cases':[{'name':fid+'.valid','input':good,'expected_exit':0,'expected_observation':'full declared inventory; named property holds'},{'name':fid+'.defeating','input':bad,'expected_exit':code,'expected_observation':reason}],'status':'planned_no_execution'})
family('C01','SRC-01 CHK-03','build','all bound original rows and duplicate-token occurrences','omit one occurrence but retain other records',1,'missing_reference_occurrence')
family('C02','SRC-02 SRC-04','build','new support retains unresolved original token','guessed URL/rebuilt CSV marked recovered_original',1,'unsupported_original_recovery')
family('C03','SRC-03 SRC-13','build','original-byte fixture with explicit trusted-origin assumption and mapping span','recovered transcript mapping omits origin assumption/custody assessment',1,'missing_origin_trust_assumption')
family('C04','SRC-05 SRC-06 CHK-07','check','substantive retained body and exact locator bytes','delete required retained body',3,'missing_retained_body')
family('C05','SRC-11','build','nonempty substantive body eligible for support','legacy zero-byte202 falsely remains retained rather than normalized empty_or_non_substantive',1,'retained_body_not_substantive')
family('C06','SRC-11','build','old wrapper imported with new non-substantive status and raw bytes untouched','locator uses redirect-only/access-wrapper body for support',1,'ineligible_locator_body')
family('C07','SRC-12','check','retained derived bytes/hash and original body bind a nonempty span','delete extraction output but keep extractor version',3,'missing_extraction_output')
family('C08','SRC-12','check','span0:4 into retained substantive 8-byte fixture','empty0:0 or out-of-range0:9 span',1,'invalid_locator_span')
family('C09','SRC-07 ADJ-14 ADJ-15','check','current_documentation_only support stays source-scoped and historical unresolved','same source-only support added to historical facet/closure count',1,'historical_applicability_required')
family('C10','SRC-08 SRC-14 CHK-08','collect','three requested local targets with one same-target retry','fourth target attempted after failed guessed slug and corrected target',3,'target_budget_exhausted; no fourth request observed')
family('C11','SRC-08 SRC-14 CHK-08','collect','one target one retry plus five server redirect hops within30s','third total attempt or sixth hop or30s deadline exceeded',3,'attempt_or_redirect_or_deadline_exhausted; exact failed bound retained')
family('C12','SRC-09 CHK-08','collect','local fixture serves permitted body within size/pass bounds','local response unavailable or size/pass bound exceeded',3,'unavailable_or_capture_budget_exhausted; no fabricated body')
family('C13','SRC-10 EV-02 EV-08','collect','exact registered development member passes eligibility','request role development but manifest membership reserved/absent',1,'nondevelopment_request; zero network requests')
family('C14','ID-01','build','75 exact baseline IDs and separate historical version/deployment counters','replace one original ID while retaining75 rows',1,'baseline_membership_mismatch')
family('C15','ID-02 ID-07','build','source pin leaves deployment candidate/unresolved','brand/version/code pin promoted to deployment verified',1,'deployment_evidence_incomplete')
family('C16','ID-03 ID-04','build','source-backed child or explicit unresolved_bundle retains parent bytes','assign unscoped parent mechanism/residue to child',1,'unsupported_child_scope')
family('C17','ID-05 ID-06 ADJ-04','build','typed cyclic dependency evidence plus explicit not_evidenced assessment','infer child facet or independence from dependency/empty-edge list',1,'unsupported_dependency_inference')
family('C18','ID-08 ID-09','check','synthetic retained direct/proxy code and exact build correspondence','remove required proxy implementation-at-block record',3,'missing_proxy_evidence')
family('C19','ID-08 ID-09','check','bound direct code/build bytes match','readable code differs from claimed build',1,'deployment_code_mismatch')
family('C20','ID-10 ID-11','build','source_inspected or justified offchain not_applicable only','verified deployment promoted to refinement_checked without external proof/run',1,'unsupported_fidelity_promotion')
family('C21','ADJ-01 ADJ-02 CHK-03','build','29/32/24 independently match actual rule-filtered records; separate Liquity challenge','queue changes one raw observation or treats challenge as30th facet',1,'dispute_tuple_mismatch')
family('C22','ADJ-03 ADJ-05 CHK-14','build','all18 authoritative rows literally equal table and decisions bind correct version/hash','unknown predicate or changed displayed row/payload hash',1,'rule_payload_mismatch')
family('C23','ADJ-06 ADJ-07 ADJ-08 ADJ-11','build','reviewed silence/conflict remains historically unresolved','absence/empty agreement/partial facet promoted to resolved',1,'unsupported_semantic_closure')
family('C24','ADJ-09','build','imported Liquity code/doc scopes retain original acquisition identity and pending review','packet silently accepted or import relabelled production collector',1,'unsupported_import_promotion')
family('C25','ADJ-10 ADJ-16','check','accepted reconciliation supersedes every same-key head; draft does not retire old head','timestamp chooses winner among two accepted heads',1,'effective_head_conflict_mismatch')
family('C26','ADJ-17','build','same-key acyclic supersession graph','missing/self/cyclic/cross-scope supersession reference',1,'invalid_supersession_graph')
family('C27','ADJ-12','build','all accepted rule-version decisions cite one selected reviewed ruling','second unit cites different or missing interpretation',1,'nonuniform_rule_interpretation')
family('C28','ADJ-13','build','ambiguous appchain packet stays pending then reviewed_unresolved without promotion','conditional proposed support becomes accepted absent reviewed ruling',1,'unresolved_interpretation_promotion')
family('C29','EV-01 EV-02 EV-06','build','original/child/renamed source exposure stays development and first result immutable','rename/version split hides development or overwrites first result',1,'exposure_or_first_result_violation')
family('C30','EV-03 EV-04 EV-05','build','not_selected zero evaluation with blocked readiness, or synthetic complete reservation','empty evaluation counted passed or reservation omits freeze prerequisites',1,'unsupported_evaluation_promotion')
family('C31','EV-07','build','third-party publisher/product descriptions have exact retained locators and unresolved aliases','manifest drops described provider because request unit differs',1,'source_description_exposure_omitted')
family('C32','CHK-01 CHK-02','check','two independently built canonical directories match and read-only check preserves mtimes','readable generated value changed while input binding remains',1,'generated_projection_mismatch; no repair')
family('C33','CHK-04','check','nonempty complete bound input fixture','required input absent/unreadable/malformed/empty',3,'required_input_unverifiable')
family('C34','CHK-05','check','unrelated HEAD movement with exact relevant bytes/objects retained','relevant body/rule/schema/driver bytes drift during command',3,'relevant_input_drift')
family('C35','CHK-06','build','fresh external nonexistent output path','existing/overlapping/symlink-traversing output',3,'unsafe_output_destination; no writes')
family('C36','CHK-11 CHK-12','check','OS wrapper denies child socket probe while local file and valid check succeed','namespace/seccomp launcher unavailable or denial self-test fails',3,'offline_isolation_unavailable; no unenforced fallback')
family('C37','CHK-13','build','all items carry one of four terminal dispositions with required evidence/reasons','at least one not_attempted/review_pending remains among valid siblings',3,'incomplete_work_queue')
family('C38','CHK-13','build','closed enum dispositions counted by item kind','unknown queue disposition or reviewed_resolved counted despite unsupported historical scope',1,'invalid_work_disposition_or_resolution')
family('C39','CHK-15','check','current complete generated manifests exactly bind changed plan/spec bytes','current scenario/artifact map still binds prior version',1,'stale_current_inventory')
# Expand every alternative into an exact independently named one-defect case now.
variants={
'C08':['zero-length0:0 span into8bytes','out-of-range0:9 span into8bytes'],
'C11':['third total attempt for one target','sixth redirect hop','30-second attempt deadline exceeded'],
'C12':['source returns unavailable','single body exceeds20MiB','pass exceeds512MiB'],
'C13':['spoofed development role for reserved member','spoofed development role for absent member'],
'C15':['brand alone promoted verified','version label alone promoted verified','code pin alone promoted verified'],
'C16':['unscoped parent mechanism assigned to child','historical parent residue assigned to child without evidence'],
'C17':['dependency label inherited into child facet','empty dependency list asserted to prove independence'],
'C21':['one raw A/B observation swapped','Liquity challenge incorrectly adds30th facet'],
'C22':['unknown predicate','displayed table row differs from rules payload','decision rule hash differs'],
'C23':['source silence promoted refuted','empty A/B agreement promoted supported','partially resolved facet promoted complete'],
'C24':['imported packet automatically accepted','import validation relabelled as production collector acquisition'],
'C25':['timestamp picks one of two accepted heads','draft successor incorrectly retires accepted predecessor'],
'C26':['missing supersession target','self-supersession','two-record supersession cycle','cross-scope supersession'],
'C27':['second current decision references different ruling','second current decision omits selected ruling'],
'C29':['renamed development unit promoted untouched','development version child promoted untouched','first frozen result overwritten by adaptation'],
'C30':['zero evaluation cases counted passed','reserved synthetic case lacks required freeze binding'],
'C33':['required input absent','required input unreadable','required input malformed','required input empty'],
'C34':['retained source bytes drift during run','rule payload bytes drift during run','schema bytes drift during run','driver bytes drift during run'],
'C35':['output already exists','output overlaps protected input root','output traverses symlink'],
'C36':['pinned launcher absent','network namespace unsupported','seccomp unsupported','socket-denial self-test fails'],
'C37':['one not_attempted item among terminal siblings','one review_pending item among terminal siblings'],
'C38':['unknown work-disposition enum','reviewed_resolved claims historical closure with current-only applicability'],
'C39':['scenario map binds prior spec bytes','artifact map binds prior plan bytes']}
for f in F:
 if f['family_id'] in variants:
  bad=f['cases'][1];f['cases']=f['cases'][:1]+[{**bad,'name':f['family_id']+'.defeating.'+str(i+1),'input':v}for i,v in enumerate(variants[f['family_id']])]
control_count=sum(len(f['cases']) for f in F)
check('unique-exact-control-names',len({c['name']for f in F for c in f['cases']})==control_count)
for f in F:
 for s in scenarios:
  if s['scenario_id']in f['scenarios']:s['planned_control_families'].append(f['family_id'])
manual={'CHK-09':'Independent exact candidate/model/artifact reconciliation, not a substitute CLI review.', 'CHK-10':'Human acceptance/delivery scope and remaining factual obligations reconciled to actual evidence.'}
for s in scenarios:
 if s['scenario_id']in manual:s['independent_evidence_obligation']=manual[s['scenario_id']]
 check('scenario-has-concrete-verification:'+s['scenario_id'],bool(s['planned_control_families'])or s['scenario_id']in manual)
write(P/'control-inventory.json',{'status':'planned_actual_entry_point_controls_not_executed','family_count':len(F),'case_count':sum(len(x['cases'])for x in F),'families':F,'variant_execution':'Every alternative is separately named with its exact expected exit. These are planned real-CLI controls, not executed results. Freeze concrete multi-record fixture bytes before execution. No compile-only or schema-only test substitutes for the specified actual CLI observation.','independent_evidence_obligations':manual})
write(P/'scenario-map.json',{'schema_version':2,'status':'r2_current_author_plan_not_acceptance','scenario_count':len(scenarios),'requirements':reqs,'scenarios':scenarios,'task_count':len(tasks),'tasks':tasks})
resolution=json.loads((E/'resolution.json').read_text())
check('all14-native-findings-addressed',len(resolution['findings'])==14 and {x['finding']for x in resolution['findings']}==set(range(1,15)))
for item in resolution['findings']:
 check('finding-scenario-links:'+str(item['finding']),set(item['scenarios'])<={x['scenario_id']for x in scenarios})
 check('finding-task-links:'+str(item['finding']),set(item['tasks'])<={x['id']for x in tasks})
# Commands are read-only planning/current-baseline checks, not production implementation.
commands=[]
for label,args in [('strict-validation',['openspec','validate','corpus-provenance-adjudication','--strict','--json','--no-interactive']),('planning-status',['openspec','status','--change','corpus-provenance-adjudication','--json']),('normalization-check',['/usr/bin/python3','scripts/corpus_normalize.py','check','--repo','.'])]:
 t=time.monotonic();start=utc();p=subprocess.run(args,cwd=R,capture_output=True,timeout=90)
 (E/(label+'.stdout')).write_bytes(p.stdout);(E/(label+'.stderr')).write_bytes(p.stderr)
 rec={'command':args,'cwd':str(R),'utc_start':start,'utc_end':utc(),'seconds':time.monotonic()-t,'exit_code':p.returncode,'stdout':bind(E/(label+'.stdout')),'stderr':bind(E/(label+'.stderr'))};commands.append(rec);check('command-pass:'+label,p.returncode==0)
 write(P/(label+'.json'),{'status':'r2_fresh_author_command_not_implementation','record':rec,'parsed_stdout':json.loads(p.stdout)if p.stdout.strip().startswith(b'{')else p.stdout.decode()})
write(E/'commands.json',commands)
# Current context snapshots distinguish HEAD identity from immutable relevant bytes.
oldcontext=json.loads((E/'before'/P.relative_to(R)/'context-files.json').read_text())['files'];contexts={R/x['path']for x in oldcontext if (R/x['path']).is_file() and not (R/x['path']).is_relative_to(P)}
contexts|={R/'wiki-llm/corpus-plan-review-r2.md',E/'resolution.json',corpus_path,R/'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r1/manifest.json',R/'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r1/review-fable-after-reset.md',R/'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r1/review-gpt6/structured.json',R/'review/semantic-kernel/sprint10/planning/r2-gate-acceptance.json'}
write(P/'context-files.json',{'status':'r2_author_context_refresh_official_freeze_pending','head_observed':head,'utc':utc(),'files':[bind(p)for p in sorted(contexts)],'limits':'Live roadmap/progress observed only; parent must freeze new review candidate. Research packet context identities remain original, not rewritten.'})
for x in before['protected']:check('protected-after:'+x['path'],sha(R/x['path'])==x['sha256'])
endhead=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
for p in ['scripts/corpus_adjudicate.py','scripts/test_corpus_adjudication.py','scripts/corpus_adjudication','corpus/adjudicated/v1']:check('no-corpus-implementation:'+p,not(R/p).exists())
result={'status':'AUTHOR_R2_READY_NOT_INDEPENDENT_ACCEPTANCE','utc':utc(),'head_before':before['head'],'head_validation_start':head,'head_after':endhead,'head_movement_allowed_with_relevant_bytes_bound':True,'checks':checks,'check_count':len(checks),'protected_files':len(before['protected']),'all_passed':True,'counts':{'capabilities':5,'requirements':len(reqs),'scenarios':len(scenarios),'unchecked_tasks':len(tasks),'control_families':len(F),'planned_control_cases':control_count,**counts},'reviews':'Historical r1 GPT6 ACCEPT WITH LIMITATIONS and Fable REQUEST CHANGES preserved; r2 independent reviews pending.','author':'Requested stock GPT-6; independent provider-build telemetry unavailable. This author is not eligible as nonauthor reviewer.','implementation':False,'native_calls':0,'scope':'Static author checks and existing normalization check only; no collector, source acquisition, packet acceptance, or factual adjudication.'}
write(E/'author-check.json',result);write(P/'author-check.json',{k:v for k,v in result.items()if k!='checks'} | {'full_check_record':bind(E/'author-check.json')})
write(E/'tools.json',{'executables':{n:{'resolved':str(Path(shutil.which(n)).resolve()),'sha256':sha(Path(shutil.which(n)).resolve())}for n in ['python3','openspec','git']},'helper':bind(Path(__file__))})
# Explicitly mark old attempt files as historical without altering their original bytes.
write(P/'artifact-inventory.json',{'schema_version':2,'status':'r2_current_inventory_excludes_itself','historical_artifacts':['author-check-attempt1.json','author-check-attempt2.json'],'artifacts':[bind(p)for p in sorted(P.rglob('*'))if p.is_file()and p.name!='artifact-inventory.json'],'original_before_copies':bind(E/'before.json'),'official_review_freeze_pending':True})
print(json.dumps({'status':result['status'],'checks':len(checks),'counts':result['counts']},indent=2))
