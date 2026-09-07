#!/usr/bin/env python3
"""Verify saved evidence and protected inputs offline; writes only local verification output."""
from pathlib import Path
import hashlib,json,subprocess,datetime,re
OUT=Path(__file__).resolve().parent
ROOT=next(p for p in OUT.parents if (p/'AGENTS.md').exists())
sha=lambda b:hashlib.sha256(b).hexdigest()
def load(p):return json.loads(p.read_text())
checks=[]
def check(label,yes):
 checks.append({'label':label,'passed':bool(yes)})
 if not yes:raise AssertionError(label)
before=load(OUT/'input-protection-before.json')
head_after=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
check('original source candidate remains ancestor',subprocess.run(['git','merge-base','--is-ancestor',before['candidate'],head_after],cwd=ROOT).returncode==0)
root_update=load(OUT/'root-post-review-update.json')
drift=[]
context_drift=[]
archived=[]
candidate=ROOT/'review/semantic-kernel/sprint9/native-review-r2/candidate.json'
check('active native manifest unchanged',sha(candidate.read_bytes())==before['active_native_candidate_manifest_sha256'])
check('3683 nonempty protected inputs',len(before['bound_inputs'])==3683)
for row in before['bound_inputs']:
 p=ROOT/row['path']
 if not p.exists():
  check('only expected postreview S9 archive movement',row['path'].startswith('openspec/changes/operational-continuation-congruence/'))
  p=ROOT/row['path'].replace('openspec/changes/operational-continuation-congruence/','openspec/changes/archive/2026-09-07-operational-continuation-congruence/')
  check('archived input is present',p.is_file())
  archived.append({'original_path':row['path'],'archived_path':str(p.relative_to(ROOT)),'original_sha256':row['sha256'],'archived_sha256':sha(p.read_bytes()),'bytes_equal':sha(p.read_bytes())==row['sha256']})
 unchanged=sha(p.read_bytes())==row['sha256'] and p.stat().st_mtime_ns==row['mtime_ns']
 if not unchanged:
  check('only root-authorized postreview input change',row['path']==root_update['expected_path'])
  original=subprocess.check_output(['git','show',before['candidate']+':'+row['path']],cwd=ROOT)
  current=p.read_bytes()
  normalized=lambda b:re.sub(rb'(?m)^(- )\[[ x]\]( \d+\.\d+ )',rb'\1[ ]\2',b)
  check('root checkbox update exact frozen old bytes',sha(original)==row['sha256'])
  check('root postreview checkbox-only advance',normalized(original)==normalized(current) and original.count(b'- [x]')==26 and current.count(b'- [x]') in (34,35))
  drift.append({'path':row['path'],'before_sha256':row['sha256'],'after_sha256':sha(current),'reason':'Root-reported post-native-review checklist advance; independently checked checkbox-only bytes.','old_checked':26,'new_checked':current.count(b'- [x]')})
 else:check('bound input unchanged '+row['path'],True)
for path,row in before['research_context'].items():
 p=ROOT/path;unchanged=sha(p.read_bytes())==row['sha256'] and p.stat().st_mtime_ns==row['mtime_ns']
 if unchanged:check('context unchanged '+path,True)
 else:
  check('only observed concurrent proposal/design edit',path in {'openspec/changes/corpus-provenance-adjudication/proposal.md','openspec/changes/corpus-provenance-adjudication/design.md'})
  original=subprocess.check_output(['git','show',before['candidate']+':'+path],cwd=ROOT)
  check('initial planning bytes recovered exactly from Git '+path,sha(original)==row['sha256'])
  saved=OUT/'planning-context-original'/Path(path).name;saved.parent.mkdir(exist_ok=True)
  if not saved.exists():saved.write_bytes(original)
  check('saved original planning context '+path,saved.read_bytes()==original)
  context_drift.append({'path':path,'original_sha256':row['sha256'],'current_sha256':sha(p.read_bytes()),'original_snapshot_path':str(saved.relative_to(OUT)),'scope':'Concurrent planning-context change, outside active S9 bundle; exact original Git bytes retained, no research edit.'})
records=sum([load(OUT/n)['records'] for n in ['retrievals.json','retrievals-repay.json']],[])
check('exact four scoped primary sources',len(records)==4 and {r['source_id'] for r in records}=={'v1-liquidation-faq','trove-manager','stability-pool','borrower-operations'})
for r in records:
 a=r['attempts'][-1];p=OUT/a['capture_path'];raw=p.read_bytes()
 check('retained exact bytes '+r['source_id'],a['http_status']==200 and r['status']=='retained' and sha(raw)==a['body_sha256']==p.name and len(raw)==a['body_bytes']>0)
 check('actual attempt bound '+r['source_id'],1<=len(r['attempts'])<=3 and all(x['started_utc']<=x['finished_utc'] and x['elapsed_seconds']>=0 for x in r['attempts']))
 check('version-specific source '+r['source_id'],'liquity-v1/' in a['requested_url'] if r['source_revision'] is None else r['source_revision']=='3e64ee1b52c50d51587c64c1cf75e0ba82934979' and r['source_revision'] in a['requested_url'])
 if r['source_revision']:
  check('computed Git blob '+r['source_id'],hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==a['git_blob_sha1'])
locators=load(OUT/'evidence-locators.json')['locators']
check('20 distinct nonempty evidence locators',len(locators)==len({x['id'] for x in locators})==20)
for row in locators:
 raw=(OUT/row['capture_path']).read_bytes();span=raw[row['byte_start']:row['byte_end_exclusive']]
 check('exact evidence span '+row['id'],bool(span) and sha(span)==row['span_sha256'] and sha(raw)==row['capture_sha256'])
 if 'line_start' in row:check('line range '+row['id'],row['line_start']==raw[:row['byte_start']].count(b'\n')+1 and row['line_end']==raw[:row['byte_end_exclusive']].count(b'\n')+1)
adj=load(OUT/'proposed-adjudication.json')
check('only draft source-scoped decision',adj['proposed_disposition']=='supported' and adj['process_status']=='draft_review_pending' and adj['original_stored_status_unchanged']=='open_targeted_source_evidence' and adj['deployment_status']=='unresolved' and adj['fidelity_status']=='source_inspected')
check('exact source challenge',adj['exact_original_challenge']['record']==load(ROOT/adj['exact_original_challenge']['path'])['items'][0])
for row in adj['observations']['raw_annotations']:
 p=ROOT/row['path'];index=int(row['pointer'].split('/')[-1]);check('raw annotation preserved '+row['annotator_id'],sha(p.read_bytes())==row['sha256'] and load(p)['annotations'][index]==row['unchanged_record'])
f=adj['observations']['historical_facet_record'];check('actual facet rule preserved',f['record']==load(ROOT/f['path'])['adjudications'][77] and f['record']['rule']=='INTERSECTION_UNRESOLVED' and f['record']['unresolved_labels']==['redemption'] and adj['observations']['agreed_label_membership'])
check('quoted liquidation predicate remains unchanged',adj['rule']['exact_rule_row'] in (ROOT/adj['rule']['path']).read_text())
check('all cited source locators exist',all(x in {r['id'] for r in locators} for v in adj['evidence'].values() for x in v))
summary={'status':'PASS_SOURCE_CAPTURE_INTEGRITY_WITH_RECORDED_POST_REVIEW_CHECKLIST_CHANGE','scope':'Author offline evidence integrity, not independent adjudication acceptance or contract execution','checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'candidate':before['candidate'],'protected_native_inputs':3683,'head_after':head_after,'all_original_protected_paths_bytes_and_mtimes_unchanged':not drift and not archived,'byte_and_mtime_equal_inputs_including_archive_resolutions':3683-len(drift),'original_paths_still_present':3683-len(archived),'post_review_parent_changes':drift,'post_review_archived_paths':archived,'concurrent_planning_context_changes':context_drift,'source_captures':4,'source_body_bytes':sum(r['attempts'][-1]['body_bytes'] for r in records),'source_locators':20,'assertion_count':len(checks),'all_passed':True,'checks':checks,'checker_sha256':sha(Path(__file__).read_bytes()),'proposed_adjudication_sha256':sha((OUT/'proposed-adjudication.json').read_bytes())}
(OUT/'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
manifest={str(p.relative_to(OUT)):{'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size} for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='artifact-manifest.json'}
(OUT/'artifact-manifest.json').write_text(json.dumps({'files':manifest,'self_excluded':True},indent=2)+'\n')
print('PASS',len(checks),'assertions;',len(manifest),'artifacts;',summary['source_body_bytes'],'captured bytes; no research writes to protected inputs')
