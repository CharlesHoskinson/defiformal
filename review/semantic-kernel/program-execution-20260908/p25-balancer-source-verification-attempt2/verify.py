from pathlib import Path
import json,hashlib,tarfile,datetime,tomllib,shutil,sys
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');P=B/'p25-balancer-source-preparation';O=B/'p25-balancer-source-verification-attempt2';O.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');start=datetime.datetime.now(datetime.timezone.utc).isoformat()
seal=read(P/'root-seal.json')
for name,digest in seal['files'].items():assert h(P/name)==digest,name
m=read(P/'source-manifest.json');commit=read(P/'discovery/commit.json');tree=read(P/'discovery/tree.json');assert commit['sha']==m['commit'];explicit=read(B/'p25-balancer-tree-identity-followup/tree.json');assert commit['commit']['tree']['sha']==explicit['sha'];assert explicit['tree']==tree['tree'] and not explicit['truncated'];assert not tree['truncated'];blobs={x['path']:x for x in tree['tree'] if x['type']=='blob'}
for name in ['commit.json','tree.json']:
 rec=read(P/'discovery'/ (name+'.http.json'));assert rec['sha256']==h(P/'discovery'/name);assert rec['status']==200
receipt=read(P/'archive-http.json');archive=Path(receipt['archive_cache_path']);assert h(archive)==receipt['sha256'];assert archive.stat().st_size==receipt['bytes']
with tarfile.open(archive) as tar:
 members={ '/'.join(Path(x.name).parts[1:]):x for x in tar.getmembers() if x.isfile()}
 for item in m['files']:
  path=P/item['path'];data=path.read_bytes();assert h(path)==item['sha256'];assert len(data)==item['bytes'];assert data==tar.extractfile(members[item['upstream_path']]).read();blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest();assert blob==item['git_blob_sha1']==blobs[item['upstream_path']]['sha']
assert len(m['files'])==m['file_count']==78
for edge in m['local_import_edges']+m['unresolved_external_imports']:
 lines=(P/'source'/edge['from']).read_text().splitlines();line=edge['line'];assert any(edge['import'] in x for x in lines[line-1:line+20]),edge
 if edge['resolved'] is not None:assert (P/'source'/edge['resolved']).is_file()
config=tomllib.loads((P/'source/pkg/vault/foundry.toml').read_text())['profile']['default'];assert config['solc_version']=='0.8.27' and config['evm_version']=='cancun' and config['optimizer_runs']==999
anchors=[]
for path,startline,endline,needle,topic in [
 ('Vault.sol',94,131,'modifier transient()', 'Outermost unlock checks nonzero deltas before relocking; nested unlock behavior is distinct.'),
 ('Vault.sol',133,155,'function settle(', 'Settle reads balance minus prior reserves and caps credited amount by amountHint.'),
 ('Vault.sol',158,163,'function sendTo(', 'sendTo records debt and reduces reserves before SafeERC20 transfer.'),
 ('VaultCommon.sol',75,119,'function _accountDelta(', 'Credit is negative delta, debt positive; counter tracks zero/nonzero transitions.'),
 ('Vault.sol',529,596,'shouldCallBeforeAddLiquidity()', 'Before hook can change balances/rates; reload precedes liquidity accounting and after hook.'),
 ('lib/HooksConfigLib.sol',322,348,'function callAfterAddLiquidityHook(', 'After hook false or wrong return length triggers AfterAddLiquidityHookFailed.'),
]:
 p=P/'source/pkg/vault/contracts'/path;lines=p.read_text().splitlines();excerpt='\n'.join(lines[startline-1:endline])+'\n';assert needle in excerpt,(path,needle);anchors.append({'path':str(p.relative_to(P)),'source_sha256':h(p),'start_line':startline,'end_line':endline,'excerpt':excerpt,'excerpt_sha256':hashlib.sha256(excerpt.encode()).hexdigest(),'navigation_topic':topic})
put(O/'navigation.json',{'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'commit':m['commit'],'anchors':anchors,'compiler_configuration_observed':config,'external_import_occurrences':len(m['unresolved_external_imports']),'external_import_specifiers':sorted({x['import'] for x in m['unresolved_external_imports']}),'future_contract_concerns':['Define actual balances, stored reserves, signed transient debt/credit, pool balances, fees and excess-token residue separately; settle caps credit by hint.','Distinguish outer unlock settlement from nested unlock callbacks and session boundaries.','Before/after add hooks surround actual accounting updates and can alter balances/rates; model whole transaction rollback at the real EVM call boundary.','Resolve external token, proxy, SafeERC20 and Permit2 behavior and compiler/runtime assumptions before source-execution claims.'],'formal_proof':False,'execution':False,'P25_accepted':False})
put(O/'result.json',{'started_utc':start,'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':[str(Path(sys.executable).resolve()),str(Path(__file__).resolve())],'cwd':str(Path.cwd()),'python_sha256':h(Path(sys.executable).resolve()),'source_packet_sealed_files':len(seal['files']),'archive_members_and_git_blobs_verified':78,'local_import_edges_verified':len(m['local_import_edges']),'external_occurrences_recorded':len(m['unresolved_external_imports']),'anchors':len(anchors),'source_execution':False,'network_requests':0,'explicit_tree_followup_sha256':h(B/'p25-balancer-tree-identity-followup/tree.json'),'initial_identity_check_failure':'p25-balancer-source-verification/failure.json','acceptance':False})
shutil.copy2(__file__,O/'verify.py');files={str(p.relative_to(O)):h(p) for p in O.iterdir() if p.is_file()};put(O/'root-seal.json',{'files':files,'file_count':len(files),'acceptance':False});print(json.dumps({'sealed_source_files':len(seal['files']),'member_blob_checks':78,'local_import_edges':len(m['local_import_edges']),'navigation_anchors':len(anchors),'acceptance':False}))
