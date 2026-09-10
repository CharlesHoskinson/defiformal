from pathlib import Path, PurePosixPath
import datetime, hashlib, json, urllib.request, tarfile, shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
D=B/'p26-ibc-source-discovery'; O=B/'p26-ibc-source-preparation'
C=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p26-ibc-source')
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
sha=lambda b:hashlib.sha256(b).hexdigest()
def put(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
c=json.loads((D/'commit.json').read_text()); t=json.loads((D/'tree.json').read_text())
assert not t['truncated'] and t['sha']==c['commit']['tree']['sha']
blobs={x['path']:x for x in t['tree'] if x['type']=='blob'}
selected=['LICENSE','NOTICE','README.md','go.mod','go.sum','Makefile',
'modules/core/04-channel/keeper/packet.go','modules/core/04-channel/keeper/timeout.go','modules/core/04-channel/keeper/keeper.go','modules/core/04-channel/keeper/packet_test.go','modules/core/04-channel/keeper/timeout_test.go',
'modules/core/04-channel/types/errors.go','modules/core/04-channel/types/packet.go','modules/core/04-channel/types/timeout.go','modules/core/04-channel/types/keys.go',
'modules/core/02-client/keeper/client.go','modules/core/02-client/keeper/keeper.go','modules/core/02-client/types/errors.go',
'modules/core/03-connection/keeper/verify.go','modules/core/keeper/msg_server.go',
'modules/apps/transfer/keeper/relay.go','modules/apps/transfer/keeper/keeper.go','modules/apps/transfer/ibc_module.go','modules/apps/transfer/keeper/relay_test.go','modules/apps/transfer/types/packet.go','modules/apps/transfer/types/errors.go',
'modules/light-clients/07-tendermint/client_state.go','modules/light-clients/07-tendermint/light_client_module.go','modules/light-clients/07-tendermint/misbehaviour.go','modules/light-clients/07-tendermint/misbehaviour_handle.go','modules/light-clients/07-tendermint/update.go','modules/light-clients/07-tendermint/misbehaviour_handle_test.go',
'docs/docs/03-light-clients/01-developer-guide/05-updates-and-misbehaviour.md']
missing=[p for p in selected if p not in blobs]
assert not missing,missing
O.mkdir(exist_ok=False); C.mkdir(exist_ok=False); shutil.copytree(D,O/'discovery')
pin=c['sha']; arc=C/(pin+'.tar.gz'); url='https://codeload.github.com/cosmos/ibc-go/tar.gz/'+pin;start=now()
with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'DeFiFormal-source-evidence'}),timeout=50) as r:
 status=r.status;headers=dict(r.headers);final=r.url;size=0
 with arc.open('xb') as f:
  while data:=r.read(1024*1024):
   size+=len(data);assert size<=100*1024*1024;f.write(data)
put(O/'archive-http.json',{'url':url,'final_url':final,'status':status,'headers':headers,'started_utc':start,'finished_utc':now(),'bytes':size,'sha256':sha(arc.read_bytes()),'archive_cache_path':str(arc),'archive_published':False})
assert status==200
records=[]
with tarfile.open(arc) as tar:
 members={};links=[]
 for m in tar.getmembers():
  parts=PurePosixPath(m.name).parts
  assert parts and not m.name.startswith('/') and '..' not in parts,m.name
  if m.isfile():
   path='/'.join(parts[1:]);assert path not in members,path;members[path]=m
  elif m.issym() or m.islnk():links.append({'path':m.name,'target':m.linkname,'type':'symlink' if m.issym() else 'hardlink','extracted':False})
 for path in selected:
  data=tar.extractfile(members[path]).read()
  blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
  assert blob==blobs[path]['sha'],path
  target=O/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
  records.append({'path':'source/'+path,'upstream_path':path,'sha256':sha(data),'git_blob_sha1':blob,'bytes':len(data),'url':'https://github.com/cosmos/ibc-go/blob/'+pin+'/'+path,'role':'unexecuted_reference_test' if path.endswith('_test.go') else 'selected_source_or_configuration'})
put(O/'source-manifest.json',{'schema':'defiformal-p26-source-candidate/v1','utc':now(),'repository':'https://github.com/cosmos/ibc-go','commit':pin,'tree':t['sha'],'selection':'Observed official main HEAD. Candidate classic ICS-04/ICS-20 and Tendermint light-client source navigation; no deployed chain identity or accepted workflow selection.','files':records,'file_count':len(records),'archive_regular_members':len(members),'archive_links_not_extracted':links,'import_closure_claimed':False,'compiler_runtime_dependencies_resolved':False,'source_execution':False,'P26_accepted':False,'P29_accepted':False})
shutil.copy2(__file__,O/'capture.py')
print(json.dumps({'source_candidate':pin,'selected_files':len(records),'archive_regular_members':len(members),'archive_bytes':size,'source_execution':False,'acceptance':False}))
