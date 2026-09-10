from pathlib import Path
import json,hashlib,datetime,gzip,tarfile,posixpath,base64,re,shutil,sys
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p25-source-grok-r1';R=O/'root-verification-attempt3';R.mkdir(exist_ok=False);read=lambda p:json.loads(p.read_text());h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');start=datetime.datetime.now(datetime.timezone.utc).isoformat();assert not Path('/proc/2195873').exists()
proc=read(O/'process.json');assert proc['process_exit']==1 and proc['terminal_events'][-1]['num_turns']==25;assert h(O/'native.jsonl')==proc['log_sha256'];m=read(O/'MANIFEST.json');bindings=m['files']+m['references']
for row in bindings:assert h(O/row['path'])==row['sha256'] and (O/row['path']).stat().st_size==row['bytes']
i=read(O/'inputs.json');S=Path(i['sandbox']);P=S/'review/semantic-kernel/program-execution-20260908'
for n,digest in i['files'].items():assert h(S/n)==digest,n
rows=read(O/'commands.json')['this_session'];raw=read(O/'logs/solc-repro/commands-run.json');assert len(rows)==len(raw)==2
for row,original in zip(rows,raw):
 for k in ['argv','cwd','started_utc','finished_utc','exit','stdout_sha256','stderr_sha256']:assert row[k]==original[k],k
 assert h(Path(row['argv'][0]))==row['compiler_sha256']
 for stream in ['stdout','stderr']:assert h(O/row[stream+'_path'])==row[stream+'_sha256'];assert (O/row[stream+'_path']).stat().st_size==row[stream+'_bytes']
assert rows[1]['input_sha256']==raw[1]['stdin_sha256'];
for n in ['input.json','stdout.json','stderr.txt']:assert (O/'logs/solc-repro'/n).read_bytes()==gzip.decompress((P/'p25-balancer-compiler-baseline'/(n+'.gz')).read_bytes())
output=read(O/'logs/solc-repro/stdout.json');inp=read(O/'logs/solc-repro/input.json');assert len(inp['sources'])==98 and set(inp['sources'])==set(output['sources']);assert sum(len(x) for x in output['contracts'].values())==96;assert sum(bool(x['evm']['bytecode']['object']) for group in output['contracts'].values() for x in group.values())==44;assert not [e for e in output['errors'] if e['severity']=='error'];assert len(output['errors'])==4
source=P/'p25-balancer-source-preparation';sm=read(source/'source-manifest.json');tree=read(P/'p25-balancer-tree-identity-followup/tree.json');blobs={x['path']:x for x in tree['tree'] if x['type']=='blob'};assert tree['tree']==read(source/'discovery/tree.json')['tree'];assert tree['sha']==read(source/'discovery/commit.json')['commit']['tree']['sha'];aliases=sm['package_aliases'];counts={'traversal_local':0,'traversal_external':0,'test_only_local':0,'test_only_external':0}
for row in sm['files']:
 p=source/row['path'];data=p.read_bytes();assert h(p)==row['sha256'];assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==blobs[row['upstream_path']]['sha']
 if p.suffix!='.sol':continue
 group='traversal' if row['role']=='import_traversal_source' else 'test_only'
 for match in re.finditer(r'\bimport\s+(?:[^;]*?\bfrom\s+)?["\']([^"\']+)["\']\s*;',data.decode()):
  spec=match.group(1);target=None
  if spec.startswith('.'):target=posixpath.normpath(posixpath.join(posixpath.dirname(row['upstream_path']),spec))
  else:
   for alias,base in aliases.items():
    if spec.startswith(alias+'/'):target=base+spec[len(alias):];break
  counts[group+('_local' if target in blobs else '_external')]+=1
assert counts=={'traversal_local':210,'traversal_external':72,'test_only_local':25,'test_only_external':1}
symlinks=[]
with tarfile.open(S/'source-archives/balancer.tar.gz') as tar:
 regular={ '/'.join(Path(x.name).parts[1:]):x for x in tar.getmembers() if x.isfile()};assert len(regular)==1081
 for x in tar.getmembers():
  assert not x.name.startswith('/') and '\0' not in x.name and '..' not in Path(x.name).parts
  if x.issym():
   target=posixpath.normpath(posixpath.join(posixpath.dirname(x.name),x.linkname));prefix=x.name.split('/')[0];assert target.startswith(prefix+'/') and not x.linkname.startswith('/') and '\0' not in x.linkname;symlinks.append({'path':x.name,'target':x.linkname,'resolved':target})
 for row in sm['files']:assert tar.extractfile(regular[row['upstream_path']]).read()==(source/row['path']).read_bytes()
assert len(symlinks)==10
D=P/'p25-balancer-dependency-preparation';registry=read(D/'openzeppelin/registry.json');oz=(D/'openzeppelin/archive.tgz').read_bytes();assert registry['dist']['integrity']=='sha512-'+base64.b64encode(hashlib.sha512(oz).digest()).decode();assert registry['dist']['shasum']==hashlib.sha1(oz).hexdigest();identity=read(D/'identity.json');assert type(identity['permit2_all_archive_file_git_blobs_verified']) is int and identity['permit2_all_archive_file_git_blobs_verified']==104
imports=read(D/'imports.json');selected_oz=[]
for package,arc in [('openzeppelin','archive.tgz'),('permit2','archive.tar.gz')]:
 with tarfile.open(D/package/arc) as tar:
  regular={ '/'.join(Path(x.name).parts[1:]):x for x in tar.getmembers() if x.isfile()}
  if package=='openzeppelin':assert len(regular)==registry['dist']['fileCount']==423
  else:
   ptree=read(D/'permit2/tree.json');pb={x['path']:x for x in ptree['tree'] if x['type']=='blob'};assert len(regular)==104
   for n,member in regular.items():
    data=tar.extractfile(member).read();assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==pb[n]['sha']
  for row in imports['files']:
   if row['package']!=package:continue
   data=tar.extractfile(regular[row['path']]).read();assert hashlib.sha256(data).hexdigest()==row['sha256']
   if package=='openzeppelin':selected_oz.append(regular[row['path']].name)
failed=read(O/'logs/probe-results.json')['summary'];assert failed['checks_passed']==26 and len(failed['checks_failed'])==4;assert h(O/'logs/probe-results.json')==h(O/'logs/failed-attempts/probe-results-overstrict-conditions.json');assert set(read(O/'logs/corrected-checks.json'))-{'note'}==set(failed['checks_failed'])
result={'started_utc':start,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':[str(Path(sys.executable).resolve()),str(Path(__file__).resolve())],'cwd':str(Path.cwd()),'python_sha256':h(Path(sys.executable).resolve()),'input_bindings':len(i['files']),'manifest_bindings':len(bindings),'reviewer_commands':2,'reviewer_raw_stream_bindings':4,'compiler_input_stdout_stderr_byte_equal_frozen':True,'source_members_git_blobs_verified':78,'counts':counts,'internal_archive_symlinks':symlinks,'oz_registry_archive_members':423,'oz_selected_member_names':selected_oz,'permit2_git_blob_members':104,'four_overstrict_predicates_independently_resolved':True,'first_python_wrapper_failure_limit':'No separate failed script revision, raw error stream or wrapper start/end/exit receipt is retained; native log remains. Do not credit reconstructed command identity/timing.','oz_path_wording_correction':'corrected-checks says package/contracts/...; actual selected member paths are package/access/..., package/interfaces/..., package/token/... and package/utils/... without an extra contracts segment. Member bytes match.','root_attempt1_correction':'Failed first root verifier assumed a compiler_sha256 field in raw child receipts. Its failure note incorrectly says raw tool_sha256 exists; neither digest field exists there. Final commands compiler_sha256 is checked directly against the pinned binary. Actual argv/timing/streams and stdin digest bind raw child receipts separately.','review_reference_test_count_correction':'Two reference tests have26imports total:25local and1external forge-std/Test.sol, not26local/0external as reviewerfollowup says. They are excluded from original68traversal and selected98compile sets; original210local/72external and final308edges remain correct.','root_attempt2':'Failed on expectedreviewtestcounts; actualtestscope correction above. Preserve both failed root attempts with zero credit.','full_P25_accepted':False}
put(R/'assessment.json',result);shutil.copy2(__file__,R/'verify.py');files={p.name:h(p) for p in R.iterdir() if p.is_file()};put(R/'root-seal.json',{'utc':result['finished_utc'],'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({k:v for k,v in result.items() if k in ['input_bindings','manifest_bindings','reviewer_commands','reviewer_raw_stream_bindings','compiler_input_stdout_stderr_byte_equal_frozen','four_overstrict_predicates_independently_resolved','full_P25_accepted']}))
