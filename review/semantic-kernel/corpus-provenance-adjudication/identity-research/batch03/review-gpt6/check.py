#!/usr/bin/env python3
"""Independent read-only reconciliation of the frozen batch03 research packet."""
import datetime,hashlib,json,pathlib,subprocess,sys
from bs4 import BeautifulSoup
H=pathlib.Path(__file__).resolve().parent;B=H.parent;R=B.parents[4]
def sha(b):return hashlib.sha256(b).hexdigest()
def load(p):return json.loads(p.read_bytes())
def git(*args):
 p=subprocess.run(['git',*args],cwd=R,capture_output=True,text=True);return p.stdout.strip() if p.returncode==0 else None
def ptr(x,p):
 for v in p.strip('/').split('/'):x=x[int(v)] if isinstance(x,list) else x[v.replace('~1','/').replace('~0','~')]
 return x
checks=[]
def check(name,v):
 checks.append({'check':name,'passed':bool(v)})
 if not v:raise AssertionError(name)
expected='48f011b36b5a85773566b3442a27d386bbf6e41325471fbef38804abf9b33452'
check('frozen manifest sha before',sha((B/'artifact-manifest.json').read_bytes())==expected)
m=load(B/'artifact-manifest.json');check('91 unique frozen files',m['count']==len(m['files'])==len({x['path'] for x in m['files']})==91)
for x in m['files']:check('manifest:'+x['path'],len((R/x['path']).read_bytes())==x['bytes'] and sha((R/x['path']).read_bytes())==x['sha256'])
check('frozen REPORT sha',sha((B/'REPORT.md').read_bytes())=='3168ef51029122816e6adea0538fad31469e93d4df5f8adf1bf653f987e23ac6')
q=load(R/'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/remaining-research-queue.json')['remaining'][32:51];us=load(B/'selected-units.json')['units'];cs=load(B/'cards.json')['cards'];os=load(B/'observations.json')['units']
check('19 exact full queue records',len(q)==19 and [{k:v for k,v in u.items() if k!='target_urls'} for u in us]==q)
check('19 unique ordered cards',[c['unit_id'] for c in cs]==[u['unit_id'] for u in q] and len({c['unit_id'] for c in cs})==19)
records=load(B/'retrievals.json')['records'];by={x['source_id']:x for x in records};attempts=[]
check('target union exact',set(r['requested_url'] for r in records)=={url for u in us for url in u['target_urls']} and len(records)==26)
for u,c,o in zip(us,cs,os):
 uid=u['unit_id'];check('three target bound:'+uid,0<len(set(u['target_urls']))<=3)
 check('unaccepted:'+uid,c['accepted_identity'] is False and c['verified_deployment'] is False and c['verified_code_pin'] is False and c['accepted_facet_changes']==[] and c['inherited_facets_from_parent'] is False and c['evaluation_role']=='development')
 check('card row binding:'+uid,c['canonical_record']==u['canonical_record'] and c['source_row']==u['source_row'] and c['original_label']==u['label'])
 for kind in ['canonical_record','source_row']:
  ref=u[kind];raw=(R/ref['path']).read_bytes();check('original file:'+uid+kind,sha(raw)==ref['sha256'] and len(raw)==ref['bytes']);check('original extract:'+uid+kind,ptr(json.loads(raw),ref['pointer'])==o['originals'][kind])
 for a in o['annotations']:
  ref=a['binding'];raw=(R/ref['path']).read_bytes();check('A/B original:'+uid+ref['annotator_id'],sha(raw)==ref['sha256'] and ptr(json.loads(raw),ref['pointer'])==a['original'])
 for l in c['locators']:
  r=by[l['source_id']];a=r['attempts'][-1];e=a['extraction'];check('locator unit/source link:'+uid,r['requested_url']==l['requested_url'] and r['requested_url'] in u['target_urls'] and a['status']=='retained_response_unassessed')
  check('locator raw/derived link:'+uid,l['capture_path']==a['capture_path'] and l['capture_sha256']==a['body_sha256'] and l['derived_path']==e['path'] and l['derived_sha256']==e['sha256'])
  lines=(R/e['path']).read_text().splitlines();check('locator bounds:'+uid,1<=l['line_start']<=l['line_end']<=len(lines));text='\n'.join(lines[l['line_start']-1:l['line_end']]);check('exact locator:'+uid,text==l['excerpt'] and sha(text.encode())==l['excerpt_sha256'])
for r in records:
 check('retained response metadata:'+r['source_id'],load(B/'responses'/(r['source_id']+'.json'))==r and r['accepted_evidence'] is False)
 check('attempt limit:'+r['source_id'],1<=len(r['attempts'])<=2)
 for a in r['attempts']:
  attempts.append(a);elapsed=(datetime.datetime.fromisoformat(a['finished_utc'])-datetime.datetime.fromisoformat(a['started_utc'])).total_seconds();check('actual observed<=30 seconds:'+r['source_id'],0<=elapsed<=30)
  if a['status']=='failed_no_support':check('honest failed metadata:'+r['source_id'],bool(a.get('error')) and not a.get('capture_path'));continue
  raw=(R/a['capture_path']).read_bytes();check('body bound/hash:'+r['source_id'],0<len(raw)<=5242880 and len(raw)==a['body_bytes'] and sha(raw)==a['body_sha256'])
  e=a.get('extraction')
  if e:
   s=BeautifulSoup(raw,'html.parser')
   for t in s(['script','style','noscript','svg']):t.decompose()
   chosen=s.find('main') or s.find('article') or s.body or s;extracted=chosen.get_text('\n',strip=True).encode();check('offline extraction replay:'+r['source_id'],extracted==(R/e['path']).read_bytes() and sha(extracted)==e['sha256'] and len(extracted)==e['bytes'])
code=(B/'capture.py').read_text();check('implemented body/retry/redirect/socket limits',all(v in code for v in ['MAX_BODY = 5 * 1024 * 1024','max_redirections = 5','range(1, 3)','open(req, timeout=30)','response.read(MAX_BODY + 1)']))
check('timeout/failed-body qualification in report',all(s in (B/'REPORT.md').read_text() for s in ['not a strict whole-attempt deadline','HTTP failure bodies were not retained']))
centrifuge=cs[8];commit='6b9d36eabee48728486f377ea2766a5cd233c555';check('corrected Centrifuge candidate',len(commit)==40 and commit in (B/'extracted/5f66738afbf8b34c.txt').read_text() and '40-character source-published commit candidate' in centrifuge['version_scope'] and centrifuge['verified_code_pin'] is False)
check('USDG empty-derived source gap',cs[15]['locators']==[] and by['c0931b5548352f9c']['attempts'][-1]['extraction']['bytes']==0)
check('Azuro shell qualification','tagline' in cs[17]['author_observation'] and 'unresolved' in cs[17]['unresolved_residue'])
before=load(B/'before.json');head=git('rev-parse','HEAD');bindings=[]
for path,digest in before['protected'].items():
 check('protected bytes:'+path,sha((R/path).read_bytes())==digest);bindings.append({'path':path,'sha256':digest,'git_object_at_capture_head':git('rev-parse',before['head']+':'+path),'git_object_at_review_head':git('rev-parse',head+':'+path)})
for ref in load(R/'review/semantic-kernel/sprint10/planning/r2-candidate.json')['inputs']:check('S10 frozen:'+ref['path'],sha((R/ref['path']).read_bytes())==ref['sha256'])
for f in m['files']:check('manifest after:'+f['path'],sha((R/f['path']).read_bytes())==f['sha256'])
check('manifest sha after',sha((B/'artifact-manifest.json').read_bytes())==expected)
result={'status':'PASS_INDEPENDENT_BYTE_AND_SCOPE_CHECKS','reviewed_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'manifest_sha256':expected,'head_at_capture':before['head'],'head_at_review':head,'head_movement_allowed':True,'checks_passed':len(checks),'counts':{'units':19,'urls':26,'attempts':len(attempts),'failed_targets':sum(r['status']=='failed_no_support' for r in records),'failed_attempts':sum(a['status']=='failed_no_support' for a in attempts),'successful_bodies':sum(a['status']=='retained_response_unassessed' for a in attempts),'locators':sum(len(c['locators']) for c in cs),'protected':len(bindings),'s10':88},'scope':'No network/reacquisition or factual/deployed verification; no execution of author capture/assessment/verification helpers.','checks':checks,'protected_git_bindings':bindings,'checker_sha256':sha(pathlib.Path(__file__).read_bytes()),'python':sys.version}
with (H/'checks.json').open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['checks','protected_git_bindings']},indent=2))
