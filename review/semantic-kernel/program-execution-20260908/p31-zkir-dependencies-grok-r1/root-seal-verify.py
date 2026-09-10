from pathlib import Path
import json,hashlib,datetime,gzip,shutil,os
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');o=b/'p31-zkir-dependencies-grok-r1';c=o/'closeout';r=o/'root-verification'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not (o/'root-seal.json').exists()
for pid in [2134960,2149280]:assert not Path('/proc',str(pid)).exists()
for base,m in [(c,read(c/'MANIFEST.json')),(r,read(r/'root-seal.json'))]:
 for n,digest in m['files'].items():assert h(base/n)==digest,n
p=read(o/'process.json');q=read(c/'process.json');assert p['process_exit']==1 and q['process_exit']==0
assert p['sessions']==q['sessions'] and p['reported_models']==q['reported_models']==['grok-4.6-build']
assert read(c/'verdict.json')['decision']=='usable' and not read(c/'verdict.json')['changes_required']
for base,rec in [(o,p),(c,q)]:assert h(base/'native.jsonl')==rec['log_sha256']
with (c/'native.jsonl.gz').open('xb') as f:
 with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write((c/'native.jsonl').read_bytes())
assert hashlib.sha256(gzip.decompress((o/'attempt1-native.jsonl.gz').read_bytes())).hexdigest()==p['log_sha256']
a=read(r/'assessment.json');assert a['inputs_verified']==749 and a['manifest_bindings_verified']==19 and a['corrected_substantive_result_equal_reviewer'] and a['path_regression_control_exit']==1
record={'schema':'defiformal-p31-zkir-dependencies-root-adjudication/v1','utc':now,'decision':'USABLE_SCOPED_LOCKED_SOURCE_IDENTITY_AND_STATIC_NAVIGATION','requested_model':'grok-4.6','effort':'high','reported_models':q['reported_models'],'sessions':q['sessions'],'initial_process_exit':1,'same_session_closeout_exit':0,'independent_review_count':1,'root_verification':'root-verification/root-seal.json','inputs_verified':749,'manifest_bindings_verified':19,'reviewer_raw_stream_bindings':4,'midnight_members':464,'blst_members':159,'navigation_sources':9,'navigation_anchors':14,'parent_probe':'Original unconditional exit0 with false member/static flags is preserved. Root replay reproduces them; no all-checks credit.','corrected_probe':'Root replay matches all substantive corrected data, with26 asserted booleans. Restoring the actual faulty path expression returns exit1 and midnight_members_match failure.','identity_note':'Reviewer returned_model grok-4.6 is the requested alias. Native terminal reports grok-4.6-build; closeout is the same independent review.','timestamp_note':'Reviewer fixed utc metadata is explicitly not command timing. Bind actual recorded start/end fields and native process times.','closure':'13 named dependency crates plus earlier root ZKIR source;333 other locked packages uncaptured. Source-to-installed-binary and native build selection remain assumptions.','next_obligations':['AGY designs the actual JSON2.0 subset contract: opcode meanings, witness/public-input layout, PiSkip and communications commitment; fresh Grok reviews.','Derive or explicitly assume required dependency semantics, source index/resource validity and bounded-integer-to-Fq refinement.','Prove actual Compact/harness-to-ZKIR correspondence and implement adapter32.7; distinguish snapshot recordN from transitionN.','PCT consumes accepted P20; actual adapter review32.9 remains open.'],'historical_readiness_32_1_to_32_4':'Preserved unchanged','semantic_contract_accepted':False,'adapter_32_7_accepted':False,'adapter_32_9_accepted':False,'P19_accepted':False,'P20_accepted':False,'P31_accepted':False,'whole_program_complete':False}
put(o/'root-adjudication.json',record);shutil.copy2(__file__,o/'root-seal-verify.py');files={}
for parent,dirs,names in os.walk(o):
 dirs[:]=[d for d in dirs if d not in ['__pycache__','.lake','private-lean']]
 for name in names:
  path=Path(parent)/name
  if name=='native.jsonl' or path==o/'root-seal.json':continue
  assert path.is_file() and not path.is_symlink();files[str(path.relative_to(o))]=h(path)
put(o/'root-seal.json',{'utc':now,'files':files,'file_count':len(files),'manifest_bindings':19,'acceptance_scope':'Locked source identity and static navigation only','P31_accepted':False});print(json.dumps({'sealed_files':len(files),'decision':record['decision'],'manifest_bindings':19}))
