from pathlib import Path
import json,hashlib,subprocess,re
R=Path.cwd();S=R/'review/semantic-kernel/sprint11';O=S/'final-delivery-gpt6-evidence';p=S/'post-delivery-document-transition.json';raw=p.read_bytes();t=json.loads(raw);inputs={str(p):{'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw)}};checks=[];states={}
for x in t['changes']:
 b=states.get(x['path'])
 if b is None:b=subprocess.check_output(['git','show',t['verified_archive_commit']+':'+x['path']],cwd=R)
 assert hashlib.sha256(b).hexdigest()==x['before_sha256'];s=b.decode()
 for rep in x['replacements']:
  assert s.count(rep['old'])==1,(x['path'],rep['old'],s.count(rep['old']));s=s.replace(rep['old'],rep['new'])
 b=s.encode();assert hashlib.sha256(b).hexdigest()==x['after_sha256'];states[x['path']]=b;checks.append({'path':x['path'],'replacements':len(x['replacements']),'before':x['before_sha256'],'after':x['after_sha256']})
for path,b in states.items():
 assert (R/path).read_bytes()==b;inputs[str(R/path)]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
tasks=states[t['changes'][0]['path']].decode();assert len(re.findall(r'^- \[x\]',tasks,re.M))==35 and len(re.findall(r'^- \[ \]',tasks,re.M))==0;assert 'Pending actual parent publish/archive/remote-byte verification' not in tasks
r={'status':'PASS_EXACT_ADMINISTRATIVE_TRANSITION_C_TRANSPORT_AND_PRIMARY_PENDING','changes':checks,'tasks_checked':35,'tasks_unchecked':0,'no_new_mathematical_claims':True,'inputs':inputs};(O/'transition-check.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:v for k,v in r.items() if k!='inputs'},indent=2))
