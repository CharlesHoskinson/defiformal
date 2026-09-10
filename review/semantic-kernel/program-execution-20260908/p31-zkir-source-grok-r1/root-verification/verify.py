from pathlib import Path
import json,hashlib,datetime,subprocess,shutil
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
o=b/'p31-zkir-source-grok-r1';p=o/'root-verification';p.mkdir(exist_ok=False)
read=lambda q:json.loads(q.read_text())
h=lambda q:hashlib.sha256(q.read_bytes()).hexdigest()
write=lambda q,d:q.write_text(json.dumps(d,indent=2)+'\n')
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
original=o/'probes/identity-recompute-20260910T1818.py'
original_text=original.read_text();old='OUT = REVIEW / "probes" / "identity-recompute-20260910T1818.json"'
assert original_text.count(old)==1
new='OUT = REVIEW / "root-verification" / "identity-recompute.json"'
probe=p/'identity-recompute.py';probe.write_text(original_text.replace(old,new))
assert not (p/'identity-recompute.json').exists()
inputs=read(o/'inputs.json');sandbox=Path(inputs['sandbox'])
for n,digest in inputs['files'].items():assert h(sandbox/n)==digest,n
argv=['/usr/bin/python3',str(probe)];start=now()
x=subprocess.run(argv,cwd=sandbox,capture_output=True,timeout=120)
(p/'stdout.log').write_bytes(x.stdout);(p/'stderr.log').write_bytes(x.stderr)
write(p/'receipt.json',{'started_utc':start,'finished_utc':now(),'argv':argv,'cwd':str(sandbox),
 'exit':x.returncode,'python_sha256':h(Path('/usr/bin/python3')),
 'original_probe_sha256':h(original),'probe_sha256':h(probe),
 'change':'Only output path changed to preserve reviewer results.',
 'stdout_sha256':h(p/'stdout.log'),'stderr_sha256':h(p/'stderr.log'),'acceptance':False})
assert x.returncode==0
prior=read(o/'probes/identity-recompute-20260910T1818.json');current=read(p/'identity-recompute.json')
volatile=['started_utc','finished_utc','argv']
assert {k:v for k,v in prior.items() if k not in volatile}=={k:v for k,v in current.items() if k not in volatile}
assert current['inputs_file_count']==current['sha256_match_count']==138
assert not current['sha256_mismatch'] and not current['missing_from_disk'] and not current['extra_sandbox_files']
assert current['crate_archive']['matches_registry_checksum'] and current['crate_archive']['matches_registry_size']
assert len(current['crate_extracted_vs_disk'])==9 and all(q['match'] for q in current['crate_extracted_vs_disk'])
assert len(current['comparable_files'])==6
assert all(q['commits']['crate-vcs']['matches_crate'] for q in current['comparable_files'])
rel=current['release_binding']
assert rel['matches_github_asset_digest'] and rel['matches_github_asset_size'] and rel['matches_binding_archive']
assert len(rel['installed'])==6 and all(q['exact_match_zip_installed'] and q['exact_match_installed_claimed'] and q['exact_match_zip_claimed'] for q in rel['installed'])
for n,digest in inputs['files'].items():assert h(sandbox/n)==digest,n
write(p/'assessment.json',{'utc':now(),'identity_result_equal_except':volatile,
 'reviewer_original_result_sha256':h(o/'probes/identity-recompute-20260910T1818.json'),
 'root_result_sha256':h(p/'identity-recompute.json'),'inputs_verified':138,
 'crate_archive_and_nine_members_match':True,'six_crate_vcs_git_blobs_match':True,
 'release_archive_and_six_installed_members_match':True,
 'reviewer_receipt_limit':'Reviewer retains decoded stdout in commands.json and structured result; raw stderr/tool hash absent. Root replay supplies separate captured streams and interpreter hash; not relabelled as reviewer capture.',
 'semantic_contract_accepted':False,'adapter_accepted':False,'acceptance':False})
shutil.copy2(__file__,p/'verify.py')
write(p/'root-seal.json',{'files':{str(q.relative_to(p)):h(q) for q in sorted(p.iterdir()) if q.is_file()},'acceptance':False})
print(json.dumps({'inputs':138,'crate_members':9,'git_comparable_files':6,'installed_release_members':6,'structured_replay_matches':True,'acceptance':False}))
