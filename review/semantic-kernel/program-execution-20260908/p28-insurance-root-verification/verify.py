from pathlib import Path
import collections,datetime,gzip,hashlib,json,re,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p28-insurance-root-verification';O.mkdir(exist_ok=False);now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();sha=lambda x:hashlib.sha256(x).hexdigest();read=lambda p:json.loads(p.read_text())
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def verify_bytes(body,digest,label):assert sha(body)==digest,label
start=now();bindings={}
for name in ['p28-esusfarm-source-preparation','p28-depeg-source-preparation','p28-depeg-dependency-preparation','p28-depeg-license-source','p28-depeg-compiler-preparation','p28-depeg-compiler-baseline','p28-depeg-lifecycle-scope']:
 p=B/name;s=read(p/'root-seal.json');assert s['files']
 for n,d in s['files'].items():verify_bytes((p/n).read_bytes(),d,name+'/'+n)
 bindings[name]=len(s['files'])
initial_counts={};http_count=0;git_count=0
for name in ['p28-esusfarm-source-preparation','p28-depeg-source-preparation']:
 p=B/name;m=read(p/'source-manifest.json');t=read(p/'discovery/tree.json');c=read(p/'discovery/commit.json');assert t['sha']==m['tree']==c['commit']['tree']['sha'] and c['sha']==m['commit'] and not t['truncated'];blobs={x['path']:x['sha'] for x in t['tree'] if x['type']=='blob'};assert len(m['files'])==m['file_count']>0
 for row in m['files']:
  body=(p/row['path']).read_bytes();verify_bytes(body,row['sha256'],row['path']);assert len(body)==row['bytes'];blob=hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest();assert blob==row['git_blob_sha1']==blobs[row['upstream_path']];http=read(p/row['http_receipt']);assert http['sha256']==row['sha256'] and http['git_blob_sha1']==blob and http['status']==200;http_count+=1;git_count+=1
 initial_counts[name]=len(m['files'])
d=B/'p28-depeg-dependency-preparation';m=read(d/'identity.json');pins={x['alias']:x for x in m['pins']};trees={}
for alias,pin in pins.items():
 t=read(d/'discovery'/pin['directory']/'tree.json');c=read(d/'discovery'/pin['directory']/'commit.json');assert c['sha']==pin['commit'] and c['commit']['tree']['sha']==t['sha']==pin['tree'] and not t['truncated'];trees[alias]={x['path']:x['sha'] for x in t['tree'] if x['type']=='blob'}
for row in m['selected_dependency_files']:
 body=(d/row['path']).read_bytes();verify_bytes(body,row['sha256'],row['path']);blob=hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest();assert blob==row['git_blob_sha1']==trees[row['alias']][row['upstream_path']];http=read(d/row['http_receipt']);assert http['status']==200 and http['sha256']==row['sha256'] and http['git_blob_sha1']==blob;assert row['commit']==pins[row['alias']]['commit'];git_count+=1;http_count+=1
license=B/'p28-depeg-license-source';l=read(license/'identity.json');body=(license/'LicenseController.sol').read_bytes();verify_bytes(body,l['sha256'],'LicenseController');assert hashlib.sha1(b'blob '+str(len(body)).encode()+b'\0'+body).hexdigest()==l['git_blob_sha1']==trees['@etherisc/gif-contracts'][l['upstream_path']];assert read(license/'http.json')['sha256']==l['sha256'];git_count+=1;http_count+=1
assert l['compiler_source_count']==len(l['source_locations'])==len(l['source_hashes'])==71
for name,path in l['source_locations'].items():verify_bytes((B/path).read_bytes(),l['source_hashes'][name],name)
assert len(m['lexical_import_edges'])==179 and len(l['additional_lexical_import_edges'])==5 and not m['unresolved_imports']
for edge in m['lexical_import_edges']+l['additional_lexical_import_edges']:assert edge['from'] in l['source_locations'] and edge['resolved'] in l['source_locations']
anchor_count=0
for name,kind in [('p28-depeg-source-preparation','initial'),('p28-depeg-lifecycle-scope','core')]:
 p=B/name;nav=read(p/'source-navigation.json');assert nav['anchors']
 for a in nav['anchors']:
  src=p/a['path'] if kind=='initial' else B/a['source_path_from_program_root'];verify_bytes(src.read_bytes(),a['sha256'],a['id']);assert [i+1 for i,line in enumerate(src.read_text().splitlines()) if a['needle'] in line]==a['matching_lines'];anchor_count+=1
p=B/'p28-depeg-compiler-baseline';cmd=read(p/'command.json');result=read(p/'result.json');compiler=read(B/'p28-depeg-compiler-preparation/compiler.json');verify_bytes(Path(compiler['binary_path']).read_bytes(),compiler['binary_sha256'],'solc');assert compiler['binary_sha256']==cmd['compiler_sha256']==compiler['official_build']['sha256'].removeprefix('0x');assert cmd['exit']==0 and not cmd['timed_out'];raw={}
for n in ['input.json','stdout.json','stderr.txt']:
 raw[n]=gzip.decompress((p/(n+'.gz')).read_bytes());verify_bytes(raw[n],cmd['raw_files'][n]['sha256'],n);assert len(raw[n])==cmd['raw_files'][n]['bytes']
request=json.loads(raw['input.json']);output=json.loads(raw['stdout.json']);normalized=[];assert len(request['sources'])==71
for row in result['source_bindings']:
 source=Path(row['path']).read_bytes();verify_bytes(source,row['sha256'],row['source_name']);text=request['sources'][row['source_name']]['content'];assert source.decode().replace('\r\n','\n').replace('\r','\n')==text
 if source.decode()!=text:normalized.append({'source':row['source_name'],'raw_sha256':row['sha256'],'compiler_content_sha256':sha(text.encode()),'transformation':'Python universal newline normalization CRLF to LF'})
assert len(normalized)==6 and request['settings']['optimizer']=={'enabled':True,'runs':200};errors=[e for e in output.get('errors',[]) if e['severity']=='error'];warnings=[e for e in output.get('errors',[]) if e['severity']=='warning'];assert not errors and len(warnings)==10
contracts=[obj for cs in output['contracts'].values() for obj in cs.values()];assert len(contracts)==71;evms=collections.Counter(json.loads(obj['metadata'])['settings']['evmVersion'] for obj in contracts);assert evms=={'istanbul':71};bytecode=sum(bool(obj.get('evm',{}).get('bytecode',{}).get('object','')) for obj in contracts);assert bytecode==26
flow=next(a for a in output['contracts']['@etherisc/gif-contracts/contracts/flows/PolicyDefaultFlow.sol']['PolicyDefaultFlow']['abi'] if a.get('name')=='processPayout');iface=next(a for a in output['contracts']['@etherisc/gif-interface/contracts/services/IProductService.sol']['IProductService']['abi'] if a.get('name')=='processPayout');assert flow['inputs']==iface['inputs'];assert [x['type'] for x in flow['outputs']]==['bool','uint256','uint256'] and [x['type'] for x in iface['outputs']]==['uint256','uint256'];put(O/'payout-abi-comparison.json',{'flow':flow,'interface':iface,'compiled_stdout_sha256':cmd['stdout_sha256'],'scope':'Actual compiler ABI comparison. Runtime behavior not executed; return types are not part of the function selector.'})
control=B/'p28-depeg-source-preparation/source/contracts/DepegProduct.sol';mutated=control.read_bytes()+b'\n// root byte-integrity negative control\n'
try:verify_bytes(mutated,sha(control.read_bytes()),'altered DepegProduct')
except AssertionError:negative=True
else:negative=False
assert negative
record={'started_utc':start,'finished_utc':now(),'sealed_bindings':bindings,'initial_source_counts':initial_counts,'git_blob_bindings_verified':git_count,'source_http_bindings_verified':http_count,'dependency_repositories':4,'compiler_source_bindings':71,'lexical_import_occurrences_with_present_targets':184,'lexical_scope':'Regex also sees commented imports; conservative selected-source set, not compiler AST edge count.','static_source_anchors':anchor_count,'root_negative_control_rejected':negative,'compiler_sha256':compiler['binary_sha256'],'compiler_command_started_utc':cmd['started_utc'],'compiler_command_finished_utc':cmd['finished_utc'],'compiler_source_newline_normalizations':normalized,'compiler_contracts':71,'nonempty_creation_objects':26,'errors':0,'warnings':10,'metadata_evm_versions':dict(evms),'compiled_payout_ABI_mismatch':True,'scope':'Root provenance, source binding, static navigation and actual standalone Solidity0.8.2/optimizer200 compile. No full Brownie/npm installation, EVM execution, deployed identity, independent review or Lean proof. eSusFarm mock rejected; depeg remains candidate.','P28_accepted':False};put(O/'result.json',record);shutil.copy2(__file__,O/'verify.py');put(O/'root-seal.json',{'utc':now(),'files':{p.name:sha(p.read_bytes()) for p in O.iterdir() if p.is_file()},'acceptance':False});print(json.dumps({k:v for k,v in record.items() if k not in ['compiler_source_newline_normalizations','sealed_bindings']}))
