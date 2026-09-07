#!/usr/bin/env python3
"""Offline integrity checks for this single draft disagreement; no network or source edits."""
from pathlib import Path
import datetime,hashlib,json,subprocess
OUT=Path(__file__).resolve().parent
ROOT=next(p for p in OUT.parents if (p/'AGENTS.md').exists())
sha=lambda b:hashlib.sha256(b).hexdigest()
def load(p):return json.loads(p.read_text())
checks=[]
def check(label,value):
 checks.append({'label':label,'passed':bool(value)})
 if not value:raise AssertionError(label)
before=load(OUT/'input-protection-before.json')
check('27 nonempty protected files',len(before['files'])==27)
for path,row in before['files'].items():
 p=ROOT/path;check('prior input bytes and mtime unchanged '+path,sha(p.read_bytes())==row['sha256'] and len(p.read_bytes())==row['bytes'] and p.stat().st_mtime_ns==row['mtime_ns'])
provenance=load(OUT/'source-provenance.json');sources=provenance['sources']
check('exact four sources',set(sources)=={'trove-manager','borrower-operations','liquity-base','v1-redemption-faq'})
shared,fresh=[],[]
for ident,s in sources.items():
 manifest=ROOT/s['source_manifest'];check('source manifest retained '+ident,sha(manifest.read_bytes())==s['source_manifest_sha256'])
 original=next(r for r in load(manifest)['records'] if r['source_id']==ident)
 check('actual original retrieval identity '+ident,original==s['original_retrieval_record'])
 a=original['attempts'][-1];raw=(ROOT/s['capture_path']).read_bytes()
 check('exact retained body '+ident,sha(raw)==s['capture_sha256']==a['body_sha256'] and len(raw)==s['capture_bytes']==a['body_bytes']>0 and a['http_status']==200 and original['status']=='retained')
 if ident in ('trove-manager','borrower-operations'):
  check('shared capture uses prior package path '+ident,'source-research/liquity-v1/captures/' in s['capture_path'] and 'not fetched again' in s['acquisition']);shared.append(s)
 else:
  check('fresh capture uses new package path '+ident,'source-research/liquity-v1-redemption/captures/' in s['capture_path']);fresh.append(s)
check('two fresh and two reused bodies',len(shared)==len(fresh)==2)
check('no shared body duplicated',set(p.name for p in (OUT/'captures').iterdir())=={s['capture_sha256'] for s in fresh})
prior=provenance['shared_package_manifest'];check('prior liquidation manifest untouched',sha((ROOT/prior['path']).read_bytes())==prior['sha256'])
locators=load(OUT/'evidence-locators.json')['locators'];ids={l['id'] for l in locators};check('21 unique source locators',len(locators)==len(ids)==21)
for l in locators:
 raw=(ROOT/l['capture_path']).read_bytes();span=raw[l['byte_start']:l['byte_end_exclusive']]
 check('exact locator '+l['id'],bool(span) and sha(span)==l['span_sha256'] and sha(raw)==l['capture_sha256'] and l['line_start']==raw[:l['byte_start']].count(b'\n')+1 and l['line_end']==raw[:l['byte_end_exclusive']].count(b'\n')+1)
a=load(OUT/'proposed-adjudication.json');check('only draft disposition',a['dispute_id']=='dispute-04' and a['label']=='redemption' and a['process_status']=='draft_review_pending' and a['proposed_disposition']=='supported' and not a['proposed_overlay_effect_if_later_accepted']['current_changes_applied'])
for r in a['raw_annotations']:
 p=ROOT/r['path'];i=int(r['pointer'].split('/')[-1]);check('exact original annotator '+r['annotator_id'],sha(p.read_bytes())==r['sha256'] and load(p)['annotations'][i]==r['raw_record'])
check('actual A absent B present', 'redemption' not in a['raw_annotations'][0]['raw_record']['facets']['mechanisms'] and 'redemption' in a['raw_annotations'][1]['raw_record']['facets']['mechanisms'])
f=a['actual_facet_decision'];p=ROOT/f['path'];i=int(f['pointer'].split('/')[-1]);check('original facet difference preserved',sha(p.read_bytes())==f['sha256'] and load(p)['adjudications'][i]==f['raw_record'] and f['raw_record']['rule']=='INTERSECTION_UNRESOLVED' and f['raw_record']['unresolved_labels']==['redemption'])
inv=load(ROOT/'openspec/changes/corpus-provenance-adjudication/dispute-inventory.json');check('29 differences remain untouched',len(inv['disagreements'])==29 and next(r for r in inv['disagreements'] if r['id']=='dispute-04')==a['actual_inventory_record'])
r=a['rule'];p=ROOT/r['path'];check('existing proposed predicate exact',sha(p.read_bytes())==r['sha256'] and p.read_text().splitlines()[r['line']-1]==r['exact_rule_row'] and r['id']=='R-redemption')
check('all rule applications have retained source locators',all(i in ids for values in a['rule_application'].values() for i in values))
check('no deployment or fidelity promotion',a['provenance_status']['deployment']=='unresolved' and a['provenance_status']['model_fidelity']=='not_evaluated')
report={'status':'PASS_INTEGRITY_ONLY','scope':'Author offline source/observation integrity; no contract execution, independent semantic review, corpus mutation or accepted adjudication.','checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head_at_start':before['head_observed'],'head_at_end':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'protected_files':27,'all_protected_bytes_and_mtimes_unchanged':True,'fresh_captures':2,'reused_captures':2,'fresh_body_bytes':sum(s['capture_bytes'] for s in fresh),'reused_body_bytes':sum(s['capture_bytes'] for s in shared),'source_locators':21,'assertion_count':len(checks),'all_checks_passed':True,'checks':checks,'checker_sha256':sha(Path(__file__).read_bytes()),'proposed_adjudication_sha256':sha((OUT/'proposed-adjudication.json').read_bytes())}
(OUT/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
manifest={str(p.relative_to(OUT)):{'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size} for p in sorted(OUT.rglob('*')) if p.is_file() and p.name!='artifact-manifest.json'}
(OUT/'artifact-manifest.json').write_text(json.dumps({'files':manifest,'self_excluded':True},indent=2)+'\n')
print('PASS',len(checks),'integrity assertions; 21 locators; 2 fresh/2 shared captures; prior package unchanged')
