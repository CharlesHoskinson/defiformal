from pathlib import Path
import json,hashlib,tarfile,re
root=Path('/private/tmp/defiformal-ci-author');base=Path('review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6');dest=root/'docs/correspondence/token0';bindings={}

def pin(relative, archive=False, allow_empty=False):
 relative=str(relative);p=root/relative;data=p.read_bytes();entry={'path':relative,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}
 if archive:entry['archive_member']=relative
 if allow_empty:entry['allow_empty']=True
 if relative in bindings:
  old=bindings[relative]
  assert all(old[k]==entry[k] for k in ['path','sha256','bytes']),relative
  entry={**old,**entry}
 bindings[relative]=entry
 return relative

archive_path=Path('review/semantic-kernel/program-execution-20260908/p16-source-candidate-r6.tar.gz');pin(archive_path)
with tarfile.open(root/archive_path) as tar:
 def archived(relative, allow_empty=False):
  relative=Path(relative);name=pin(relative,True,allow_empty);assert tar.extractfile(name).read()==(root/relative).read_bytes(),name;return name
 rows=json.loads((root/base/'evm/baseline/rows.json').read_text());archived(base/'evm/baseline/rows.json')
 compiler=json.loads((root/base/'compiler/baseline/compile.json').read_text());archived(base/'compiler/baseline/compile.json')
 for name in ['source-hashes.json','solc-receipt.json','standard-json-input.json','standard-json-output.json','abi.json','methodIdentifiers.json','runtime.hex','creation.hex']:
  archived(base/'compiler/baseline'/name)
 for name,sha in compiler['source_hashes'].items():
  relative=base/'compiler/baseline/overlay'/name;archived(relative);assert bindings[str(relative)]['sha256']==sha
 archived(base/'genesis/istanbul-genesis.json')
 stdout=archived(base/'lean/bindings/stdout.bin');archived(base/'lean/bindings/receipt.json');archived(base/'lean/P16SourceBindings.lean')
 model={}
 for line in (root/stdout).read_text().splitlines():
  m=re.fullmatch(r'(P16-[A-Z0-9-]+) sqrtP=(\d+) L=(\d+) amount=(\d+) add=(true|false) model=(ok:\d+|error:\w+) match=(true|false)',line)
  if m:model[m[1]]=m.groups()[1:]
 cases=[]
 for row in rows:
  folder=base/'evm/baseline'/row['id'];obs=json.loads((root/folder/'observation.json').read_text());run={
   'id':'p16-r6-source-'+row['id'],'case':row['id'],'inputs':row['inputs'],
   'original_start_utc':obs['start_utc'],'original_end_utc':obs['end_utc'],
   'historical_role':'Native Grok 4.6 author campaign, reused accepted P16 evidence',
   'observation_record':archived(folder/'observation.json'),'receipt':archived(folder/'record/receipt.json'),
   'stdout':archived(folder/'record/stdout.bin'),'stderr':archived(folder/'record/stderr.bin',True),
   'calldata':archived(folder/'calldata.hex'),'semantic_class':obs['observation']['class'],
   'raw_returndata':obs['observation']['returndata'],'model_result':model[row['id']][4],
   'relation_level':'exact successful uint160' if obs['observation']['class']=='success' else 'coarse semantic refusal only; model label not inferred from empty payload'};cases.append(run)

packet_path='review/semantic-kernel/platform-increment/p18/packets/p18.token0.next-price.packet.json';packet=json.loads((root/packet_path).read_text());pin(packet_path)
index_path='review/semantic-kernel/platform-increment/p18/validation/evidence-binding-index.json';index=json.loads((root/index_path).read_text());pin(index_path);by_id={x['id']:x for x in index['runtime_bindings']};model_runs=[]
for run in packet['executions']['model_runs']:
 b=by_id[run['id']];p=Path(b['log_path']);pin(p);receipt=Path(b.get('receipt_path',str(p.parent/'receipt.json')));pin(receipt);r=json.loads((root/receipt).read_text());model_runs.append({'id':run['id'],'class':'model-only invocation, not source execution','stdout':str(p),'receipt':str(receipt),'original_start_utc':r.get('start_utc'),'original_end_utc':r.get('end_utc'),'original_name':r.get('name'),'notes':run['notes']});assert bindings[str(p)]['sha256']==run['log_sha256']
for p in ['lean/DefiKernel/ConcentratedLiquidity/Token0Proofs.lean','lean/DefiKernel/ConcentratedLiquidity/SqrtPriceMath.lean','lean/lean-toolchain','lean/lake-manifest.json','examples/platform-increment/README.md','examples/platform-increment/VERSION.json','review/semantic-kernel/program-execution-20260908/P16-SOURCE-ACCEPTANCE.md','review/semantic-kernel/program-execution-20260908/P16-PROOF-RECORDER-ACCEPTANCE.md','review/semantic-kernel/program-execution-20260908/P18-ACCEPTANCE.md','review/semantic-kernel/program-execution-20260908/p16-source-r6-review/verdict.json','review/semantic-kernel/program-execution-20260908/p16-source-r6-review/execution/intact/campaign-score.json']:
 pin(p)
record={'schema':'defiformal-token0-observation-relation/v1','base_revision':'0694a5c36fc12e95ca0085a4ebae4ac418b7aefa','evidence_status':'reused accepted historical observations; no fresh Solidity campaign','source_revision':'e3589b192d0be27e100cd0daaf6c97204fdb1899','archive':str(archive_path),'compiler_record':str(base/'compiler/baseline/compile.json'),'model_binding_stdout':stdout,'model_theorem':{'declaration':'DefiKernel.ConcentratedLiquidity.SqrtPriceMath.add_result_le','owning_module':'DefiKernel.ConcentratedLiquidity.Token0Proofs','source':'lean/DefiKernel/ConcentratedLiquidity/Token0Proofs.lean','source_sha256':bindings['lean/DefiKernel/ConcentratedLiquidity/Token0Proofs.lean']['sha256'],'boundary':'Successful add in the Lean model implies output sqrtP <= input sqrtP; no source outcome premise or universal EVM claim.'},'relation':{'selector':'6c84a8a2','calldata_bytes':132,'encoding':'4-byte selector followed by four canonical 32-byte big-endian words','input_bounds':{'sqrtPX96_bits':160,'liquidity_bits':128,'amount_bits':256,'add_values':[0,1]},'success':'semantic success, exactly 32 returndata bytes with uint160 bound, same integer as Lean.ok q','refusal':'semantic EVM revert can match Lean.error at coarse refusal level only; preserve raw bytes; empty 0x does not identify a unique Lean failure','excluded':['malformed output','missing evidence','timeout','cancellation','infrastructure failure','out-of-gas or other nonsemantic execution error'],'pure_scope':'No ledger/storage/history/fees/deployment identity relation.'},'tools_recorded':{'solc_version':'0.7.6+commit.7338295f','solc_sha256':compiler['solc_sha256'],'settings':compiler['settings'],'runtime_bytecode_sha256':compiler['runtime_bytecode_sha256'],'runtime_hex_file_sha256':compiler['runtime_hex_sha256'],'creation_bytecode_sha256':compiler['creation_bytecode_sha256'],'evm_sha256':json.loads((root/base/'evm/baseline/P16-ADD/observation.json').read_text())['evm_sha256'],'execution_fork':'istanbul','gas':10000000000,'identity_scope':'Historical recorded binary identities; no claim those Solidity/EVM tools were rerun here.'},'denominators':{'source_invocations':12,'source_successes':8,'source_coarse_reverts':4,'model_only_invocations':4,'source_plus_model_invocations':16},'source_invocations':cases,'model_only_invocations':model_runs,'acceptance_authority':{'P16_source':'review/semantic-kernel/program-execution-20260908/P16-SOURCE-ACCEPTANCE.md','P16_model':'review/semantic-kernel/program-execution-20260908/P16-PROOF-RECORDER-ACCEPTANCE.md','P18':'review/semantic-kernel/program-execution-20260908/P18-ACCEPTANCE.md','roles':'P16 native Grok 4.6 author requested grok-4.6/high, returned grok-4.6-build; independent nonauthor root GPT-6 stock harness (no separate returned-model field). P18 independent native Grok review requested grok-4.6/high, returned grok-4.6-build as recorded by its acceptance. Frozen pending Opus/false-credit metadata remains untouched historical data.'},'independent_replay_corroboration':{'record':'review/semantic-kernel/program-execution-20260908/p16-source-r6-review/execution/intact/campaign-score.json','role':'Independent GPT-6 reviewer replay at original 16:00 UTC, separate from archived author 15:52 UTC campaign','denominator_effect':'Not added or substituted for the 12 primary source invocations.'},'bound_files':list(bindings.values()),'refinement_status':'open; see refinement-obligation.md'}
(dest/'differential-observations.json').write_text(json.dumps(record,indent=2)+'\n');print('bound files',len(bindings),'source',len(cases),'models',len(model_runs))
