from pathlib import Path
import datetime,hashlib,json,posixpath,re,shutil,sys
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');P=B/'p27-gmx-source-preparation-attempt2';O=B/'p27-gmx-root-verification'
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda b:hashlib.sha256(b).hexdigest();read=lambda p:json.loads(p.read_text())
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def match(body,digest,label):assert sha(body)==digest,label
start=now();O.mkdir(exist_ok=False);shutil.copy2(__file__,O/'verify.py')
m=read(P/'source-manifest.json');seal=read(P/'root-seal.json');t=read(P/'discovery/tree.json');c=read(P/'discovery/commit.json')
assert t['sha']==c['commit']['tree']['sha']==m['tree'] and c['sha']==m['commit'] and not t['truncated']
assert len(seal['files'])==seal['file_count']==188 and len(m['files'])==m['file_count']==89
for path,digest in seal['files'].items():match((P/path).read_bytes(),digest,path)
blobs={r['path']:r['sha'] for r in t['tree'] if r['type']=='blob'}
local=[];external=[];sources={};roles={}
for r in m['files']:
 body=(P/r['path']).read_bytes();match(body,r['sha256'],r['path']);assert len(body)==r['bytes']
 blob=hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest();assert blob==r['git_blob_sha1']==blobs[r['upstream_path']]
 h=read(P/r['http_receipt']);assert h['status']==200 and h['sha256']==r['sha256'] and h['git_blob_sha1']==blob and h['bytes']==len(body)
 assert h['url']=='https://raw.githubusercontent.com/gmx-io/gmx-synthetics/'+m['commit']+'/'+r['upstream_path'] and h['final_url']==h['url']
 assert datetime.datetime.fromisoformat(h['finished_utc'])>=datetime.datetime.fromisoformat(h['started_utc'])
 roles[r['role']]=roles.get(r['role'],0)+1
 if r['role']!='selected_import_source':continue
 sources[r['upstream_path']]=body
for path,body in sources.items():
 text=body.decode()
 for mt in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',text):
  spec=mt.group(1);target=posixpath.normpath(posixpath.join(posixpath.dirname(path),spec)) if spec.startswith('.') else spec
  r={'from':path,'import':spec,'line':text[:mt.start()].count('\n')+1,'resolved':target if target in blobs else None}
  (local if target in blobs else external).append(r)
key=lambda row:json.dumps(row,sort_keys=True)
assert sorted(local,key=key)==sorted(m['local_import_edges'],key=key) and len(local)==213
assert sorted(external,key=key)==sorted(m['unresolved_external_imports'],key=key) and len(external)==22
seen=set();queue=m['seeds'][:]
while queue:
 p=queue.pop()
 if p in seen:continue
 assert p in sources;seen.add(p);queue.extend(r['resolved'] for r in local if r['from']==p)
assert seen==set(sources) and len(seen)==m['traversed_source_files']==78
assert roles=={'configuration_or_documentation':8,'selected_import_source':78,'unexecuted_reference_test':3}
assert sum(r['bytes'] for r in m['files'])==m['source_bytes']==1535718
nav=read(P/'source-navigation.json');assert len(nav['anchors'])==nav['anchor_count']==16
for a in nav['anchors']:
 body=(P/a['path']).read_bytes();match(body,a['sha256'],a['id']);lines=body.decode().splitlines();actual=[i+1 for i,line in enumerate(lines) if a['needle'] in line];assert actual==a['matching_lines'] and actual and a['proof_or_execution'] is False
failed=B/'p27-gmx-source-preparation';fs=read(failed/'root-seal.json')
for path,digest in fs['files'].items():match((failed/path).read_bytes(),digest,path)
# Exercise the same byte verifier on changed data, without changing retained sources.
r=next(x for x in m['files'] if x['upstream_path']=='contracts/position/PositionUtils.sol');body=(P/r['path']).read_bytes();changed=body+b'\n// root integrity negative control\n'
try:match(changed,r['sha256'],r['path'])
except AssertionError:negative=True
else:negative=False
assert negative
result={'schema':'defiformal-root-source-verification/v1','started_utc':start,'finished_utc':now(),'argv':[sys.executable,str(Path(__file__).resolve())],'cwd':str(Path.cwd()),'verifier_sha256':sha(Path(__file__).read_bytes()),'commit':m['commit'],'tree':m['tree'],'packet_sha256':sha((P/'root-seal.json').read_bytes()),'packet_bindings_verified':len(seal['files']),'source_git_blobs_and_http_verified':len(m['files']),'source_roles':roles,'source_bytes':m['source_bytes'],'reachable_solidity_sources':len(seen),'lexical_local_import_edges':len(local),'unresolved_external_import_occurrences':len(external),'static_anchor_bindings':len(nav['anchors']),'failed_archive_packet_bindings':len(fs['files']),'altered_source_control':{'same_verifier_rejected':negative,'source_path':r['path'],'original_sha256':r['sha256'],'altered_sha256':sha(changed),'mutation':'append comment to in-memory bytes; sealed source unmodified'},'scope':'Root byte/provenance/lexical import/static anchor validation only. Not semantic correctness, compiler closure, Solidity execution, independent review or formal proof.','P27_accepted':False}
put(O/'result.json',result);put(O/'root-seal.json',{'utc':now(),'files':{p.name:sha(p.read_bytes()) for p in O.iterdir() if p.is_file()},'acceptance':False});print(json.dumps(result))
