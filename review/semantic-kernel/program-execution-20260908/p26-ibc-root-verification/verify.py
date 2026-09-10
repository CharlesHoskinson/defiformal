from pathlib import Path, PurePosixPath
import datetime, hashlib, json, tarfile, shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908'); O=B/'p26-ibc-source-preparation'; R=B/'p26-ibc-root-verification'
R.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def verify_bytes(data,row):
 if len(data)!=row['bytes'] or hashlib.sha256(data).hexdigest()!=row['sha256']:raise ValueError('source byte identity mismatch')
 if hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()!=row['git_blob_sha1']:raise ValueError('Git blob identity mismatch')
s=read(O/'root-seal.json');assert s['file_count']==len(s['files'])>0
for path,digest in s['files'].items():assert h(O/path)==digest,path
m=read(O/'source-manifest.json'); assert m['file_count']==len(m['files'])==33
c=read(O/'discovery/commit.json');t=read(O/'discovery/tree.json');assert c['sha']==m['commit'] and c['commit']['tree']['sha']==t['sha']==m['tree'] and not t['truncated']
for name in ['commit','tree']:
 http=read(O/f'discovery/{name}-http.json'); assert http['status']==200 and h(O/f'discovery/{name}.json')==http['sha256']
a=read(O/'archive-http.json');arc=Path(a['archive_cache_path']);assert h(arc)==a['sha256'] and arc.stat().st_size==a['bytes'] and a['status']==200
blobs={x['path']:x for x in t['tree'] if x['type']=='blob'}
with tarfile.open(arc) as tar:
 members={}
 for member in tar.getmembers():
  parts=PurePosixPath(member.name).parts;assert parts and '..' not in parts and not member.name.startswith('/')
  if member.isfile():
   path='/'.join(parts[1:]);assert path not in members;members[path]=member
 assert len(members)==m['archive_regular_members']==1890
 for row in m['files']:
  data=(O/row['path']).read_bytes();verify_bytes(data,row)
  assert data==tar.extractfile(members[row['upstream_path']]).read() and row['git_blob_sha1']==blobs[row['upstream_path']]['sha']
nav=read(O/'source-navigation.json'); assert nav['anchor_count']==len(nav['anchors'])==15
for row in nav['anchors']:
 p=O/row['path'];assert h(p)==row['sha256']
 assert [i+1 for i,line in enumerate(p.read_text().splitlines()) if row['needle'] in line]==row['matching_lines']
row=next(r for r in m['files'] if r['upstream_path']=='modules/core/04-channel/keeper/packet.go');control=(O/row['path']).read_bytes();assert control
bad=bytes([control[0]^1])+control[1:]
try:verify_bytes(bad,row)
except ValueError as error:rejected=str(error)
else:raise AssertionError('Altered source bytes were accepted')
result={'utc':now(),'packet_bindings_verified':len(s['files']),'selected_source_files_verified':len(m['files']),'static_anchor_bindings_verified':len(nav['anchors']),'archive_regular_members':len(members),'selected_git_blobs_verified':33,'control':{'scope':'Same verify_bytes function used for intact files and one altered in-memory packet.go byte string. No source file was modified.','intact_sources_accepted':33,'altered_source_rejected':True,'error':rejected},'source_execution':False,'Go_tests_executed':False,'proof_credit':False,'P26_accepted':False,'P29_accepted':False}
put(R/'assessment.json',result);shutil.copy2(__file__,R/'verify.py');print(json.dumps(result))
