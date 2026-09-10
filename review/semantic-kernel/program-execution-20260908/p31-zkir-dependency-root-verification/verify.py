from pathlib import Path
import datetime,hashlib,json,tarfile,tomllib,shutil
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');src=b/'p31-zkir-dependency-source-preparation';o=b/'p31-zkir-dependency-root-verification';o.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');start=now();shutil.copy2(__file__,o/'verify.py')
seal=json.loads((src/'root-seal.json').read_text())['files'];assert seal;assert {str(p.relative_to(src)) for p in src.rglob('*') if p.is_file()}==set(seal)|{'root-seal.json'}
for n,h in seal.items():assert sha(src/n)==h,n
lock=tomllib.loads((src/'inputs/Cargo.lock').read_text());expected={(p['name'],p['version']):p for p in lock['package'] if p['name'].startswith('midnight-') and p['name']!='midnight-zkir'};seen=set();checks=[]
for rp in sorted(src.glob('midnight-*/receipt.json')):
 r=json.loads(rp.read_text());key=(r['package'],r['version']);assert key in expected and key not in seen;seen.add(key);a=src/r['archive'];reg=json.loads((rp.parent/'registry.json').read_text())['version'];assert sha(a)==expected[key]['checksum']==reg['checksum']==r['archive_sha256'];assert a.stat().st_size==reg['crate_size'];files={f['tar_member']:f for f in r['source_files']}
 with tarfile.open(a) as t:
  members=[m for m in t.getmembers() if m.isfile()];assert {m.name for m in members}==set(files) and len(members)==len(files)
  for m in members:
   f=files[m.name];assert hashlib.sha256(t.extractfile(m).read()).hexdigest()==sha(src/f['path'])==f['sha256'];assert m.size==(src/f['path']).stat().st_size==f['bytes']
 for name in ['registry.json',a.name]:
  http=json.loads((rp.parent/(name+'.http.json')).read_text());assert http['status']==200 and sha(rp.parent/name)==http['sha256']
 checks.append({'package':key[0],'version':key[1],'archive_sha256':sha(a),'members_checked':len(files)})
assert seen==set(expected) and len(seen)==12
res={'schema':'defiformal-offline-source-verification/v1','started_utc':start,'finished_utc':now(),'source_seal_sha256':sha(src/'root-seal.json'),'sealed_files_checked':len(seal),'packages':checks,'source_members_checked':sum(p['members_checked'] for p in checks),'exact_locked_midnight_set':True,'all_passed':True,'network_requests':0,'downloaded_code_executions':0,'acceptance':False,'scope':'Offline archive, extracted bytes, registry metadata, HTTP receipts and exact lock selection binding only; no semantic/build/adapter acceptance.'};put(o/'result.json',res);put(o/'root-seal.json',{'files':{str(p.relative_to(o)):sha(p) for p in o.rglob('*') if p.is_file()},'acceptance':False});print(json.dumps({k:v for k,v in res.items() if k!='packages'}))
