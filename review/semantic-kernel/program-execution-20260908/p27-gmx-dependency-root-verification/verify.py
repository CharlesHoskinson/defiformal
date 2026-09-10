from pathlib import Path
import base64,datetime,hashlib,io,json,re,tarfile,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');P=B/'p27-gmx-dependency-preparation';O=B/'p27-gmx-dependency-root-verification';h=lambda b:hashlib.sha256(b).hexdigest();read=lambda p:json.loads(p.read_text());now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
O.mkdir(exist_ok=False);start=now();m=read(P/'identity.json');s=read(P/'root-seal.json');assert len(s['files'])>0
for p,d in s['files'].items():assert h((P/p).read_bytes())==d,p
lock=(P/m['lock_path']).read_bytes();assert h(lock)==m['lock_sha256'];total_members=0;selected=0
for pkg in m['packages']:
 archive=(P/pkg['archive']).read_bytes();assert h(archive)==pkg['archive_sha256'];assert hashlib.sha1(archive).hexdigest()==pkg['lock_sha1'];assert 'sha512-'+base64.b64encode(hashlib.sha512(archive).digest()).decode()==pkg['lock_integrity_sha512'];entry=(P/pkg['archive']).parent/'lock-entry.txt';assert entry.read_bytes() in lock
 with tarfile.open(fileobj=io.BytesIO(archive),mode='r:gz') as t:
  regular=[x for x in t.getmembers() if x.isfile()];assert len(regular)==len(pkg['members'])==pkg['regular_members']
  byname={r['path']:r for r in pkg['members']};assert len(byname)==len(regular)
  for member in regular:
   data=t.extractfile(member).read();r=byname[member.name];assert h(data)==r['sha256'] and len(data)==r['bytes']
  for r in pkg['selected_files']:
   data=t.extractfile(r['archive_member']).read();assert data==(P/r['path']).read_bytes();assert h(data)==r['sha256']==m['source_hashes'][r['compiler_path']];selected+=1
 total_members+=len(regular)
assert len(m['source_locations'])==len(m['source_hashes'])==m['compiler_source_count']==91
for p,loc in m['source_locations'].items():assert h((B/loc).read_bytes())==m['source_hashes'][p]
assert len(m['lexical_import_edges'])==243 and not m['unresolved_imports']
for edge in m['lexical_import_edges']:assert edge['from'] in m['source_locations'] and edge['resolved'] in m['source_locations']
assert selected==13 and total_members==408
result={'started_utc':start,'finished_utc':now(),'packet_bindings':len(s['files']),'packages':2,'package_members_verified':total_members,'selected_dependency_sources':selected,'source_bindings_verified':91,'recorded_import_targets_verified':243,'unresolved_recorded_imports':0,'lock_sha256':m['lock_sha256'],'source_packet_sha256':m['source_packet_seal_sha256'],'scope':'Root package/archive/lock/source integrity and recorded import-target verification. Compiler resolves actual imports separately. Not independent review, EVM execution or proof.','acceptance':False};put(O/'result.json',result);shutil.copy2(__file__,O/'verify.py');put(O/'root-seal.json',{'utc':now(),'files':{p.name:h(p.read_bytes()) for p in O.iterdir() if p.is_file()},'acceptance':False});print(json.dumps(result))
