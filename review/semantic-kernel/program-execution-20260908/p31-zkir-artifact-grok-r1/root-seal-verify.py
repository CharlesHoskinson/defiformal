from pathlib import Path
import datetime, gzip, hashlib, json, os, shutil

r = Path('/home/charl/defiformal')
b = r / 'review/semantic-kernel/program-execution-20260908'
o = b / 'p31-zkir-artifact-grok-r1'
c = o / 'closeout'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
read = lambda p: json.loads(p.read_text())
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not (o / 'root-seal.json').exists()
assert not Path('/proc/1927454').exists() and not Path('/proc/1950365').exists()
first, last = read(o / 'process.json'), read(c / 'process.json')
assert first['process_exit'] == 1
assert first['sessions'] == last['sessions'] == ['01a08c26-f918-7f31-9a38-b0eeade61fac']
assert first['reported_models'] == last['reported_models'] == ['grok-4.6-build']
assert sha(o / 'native.jsonl') == first['log_sha256']
assert sha(c / 'native.jsonl') == last['log_sha256']
i = read(o / 'inputs.json')
s = Path(i['sandbox'])
for p in Path('/proc').iterdir():
    if not p.name.isdigit(): continue
    try:
        cwd = str((p / 'cwd').resolve())
        comm = (p / 'comm').read_text().strip()
    except (OSError, RuntimeError): continue
    assert not ((cwd.startswith(str(s)) or cwd.startswith(str(o))) and comm in ['grok', 'lean', 'lake', 'node']), (p.name, comm, cwd)
for name, digest in i['files'].items(): assert sha(s / name) == digest, name
for name in ['verdict.json', 'findings.json', 'commands.json']:
    assert (o / name).read_bytes() == (c / name).read_bytes()
manifest = read(c / 'MANIFEST.json')['files']
for name, digest in manifest.items(): assert sha(c / name) == digest, name
root = read(o / 'root-verification/verification.json')
assert root['valid_mock_compiles'] == 2 and root['negative_format_refusals'] == 3
assert root['materialized_files_exact'] == 9 and root['frozen_inputs_verified_before_after'] == 97
assert all(x['exit'] == x['expected_exit'] and x['stdout_exact_match'] and x['stderr_path_normalized_exact_match'] for x in root['mock_controls'])
for name, expected in [('zkir', '5443f87db07b7f19cc273380c224b77b4b7ca124deac6d54f7a165628fc5e1fc'),
                       ('compactc.bin', '3054ffa89d7a4dfe24afd31c27ef37e87a95757de0fc24485f335635e26dce57')]:
    assert sha(Path('/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl') / name) == expected
with (c / 'native.jsonl.gz').open('xb') as f:
    with gzip.GzipFile(filename='', mode='wb', fileobj=f, mtime=0) as z:
        z.write((c / 'native.jsonl').read_bytes())
shutil.copy2('/tmp/defiformal-p31-zkir-artifact-grok-closeout.py', o / 'closeout-launcher.py')
shutil.copy2(__file__, o / 'root-seal-verify.py')
write(o / 'root-adjudication.json', {
    'schema': 'defiformal-root-review-adjudication/v1', 'utc': now(),
    'scope': 'P31 generated ZKIR artifact/interface preparation and bounded format controls',
    'decision': 'usable_scoped_evidence', 'requested_model': 'grok-4.6',
    'reported_model': 'grok-4.6-build', 'review_session': first['sessions'][0],
    'original_process_exit': first['process_exit'], 'closeout_process_exit': last['process_exit'],
    'reporting_closeout_is_second_review': False,
    'frozen_input_hashes_verified': len(i['files']), 'review_manifest_bindings_verified': len(manifest),
    'root_replay': 'root-verification/verification.json', 'valid_mock_compiles': 2,
    'negative_format_refusals': 3, 'materialized_files_exact': 9,
    'stderr_difference': 'Raw path differences preserved; exact match after replacing only each input path.',
    'report_metadata_corrections': [
        'Parent returned_model is requested alias; actual native identity is grok-4.6-build.',
        'Report top-level fixed utc is author metadata, not a measured command timestamp.',
        'brief-sha256 stdout_sha256 field hashes brief content, not observed stdout.'
    ],
    'previous_readiness_32_1_to_32_4_accepted': True,
    'remaining': [
        'Bind a verified ZKIR interface/semantic contract including opcode semantics and public-input/witness layout.',
        'Prove Compact kernel/harness to ZKIR correspondence; materialization identity is insufficient.',
        'Implement and independently verify adapter32.7; record snapshot wrappers differ from pure transitions.',
        'PCT certificate consumption requires accepted P20.'
    ], 'adapter_32_7_status': 'blocked_unavailable', 'adapter_32_7_accepted': False,
    'keys_generated': False, 'proofs_generated': False, 'ledger_execution': False,
    'acceptance': False, 'whole_p31_accepted': False, 'whole_program_complete': False})
files = {}
for parent, dirs, names in os.walk(o):
    dirs[:] = [x for x in dirs if x not in ['node_modules', '.lake', '__pycache__', '.git']]
    for name in names:
        p = Path(parent) / name
        if p.is_symlink() or not p.is_file() or name == 'native.jsonl': continue
        files[str(p.relative_to(o))] = sha(p)
write(o / 'root-seal.json', {'utc': now(), 'files': dict(sorted(files.items())),
    'excluded': ['growing logs excluded; both terminal native logs preserved as hashed gzip', 'symlinks and caches'],
    'frozen_inputs_verified': len(i['files']), 'manifest_bindings_verified': len(manifest),
    'acceptance': False})
print(json.dumps({'sealed_files': len(files), 'manifest_bindings': len(manifest),
                  'root_valid': 2, 'root_negative': 3, 'materialized_files': 9, 'acceptance': False}))
