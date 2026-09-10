from pathlib import Path
import datetime, hashlib, json, shutil, subprocess

r = Path('/home/charl/defiformal')
o = r / 'review/semantic-kernel/program-execution-20260908/p31-zkir-artifact-grok-r1'
dest = o / 'root-verification'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
inputs = read(o / 'inputs.json')
sandbox = Path(inputs['sandbox'])
for name, digest in inputs['files'].items():
    assert sha(sandbox / name) == digest, name
dest.mkdir(exist_ok=False)
shutil.copy2(__file__, dest / 'verify.py')
toolinfo = read(o / 'replay/tool-identity.json')
tool = Path(toolinfo['path'])
assert sha(tool) == toolinfo['sha256']
results = []

def run(argv, cwd, folder):
    start = now()
    timed_out = False
    try:
        x = subprocess.run(argv, cwd=cwd, capture_output=True, timeout=120)
        code, stdout, stderr = x.returncode, x.stdout, x.stderr
    except subprocess.TimeoutExpired as e:
        code, stdout, stderr, timed_out = None, e.stdout or b'', e.stderr or b'', True
    (folder / 'stdout.log').write_bytes(stdout)
    (folder / 'stderr.log').write_bytes(stderr)
    receipt = {'argv': argv, 'cwd': str(cwd), 'started_utc': start,
        'finished_utc': now(), 'exit': code, 'timeout': timed_out,
        'tool_sha256': sha(Path(argv[0])), 'stdout_sha256': sha(folder / 'stdout.log'),
        'stderr_sha256': sha(folder / 'stderr.log'), 'acceptance': False}
    write(folder / 'command.json', receipt)
    return receipt

for label in ['valid-record0', 'valid-record1', 'invalid-version999',
              'unsupported-inrange-version255', 'invalid-opcode']:
    original = o / 'replay/mock-compile' / label
    prior = read(original / 'command.json')
    assert sha(original / 'input.zkir') == prior['input_sha256']
    for stream in ['stdout', 'stderr']:
        assert sha(original / (stream + '.log')) == prior[stream + '_sha256']
    for f in prior['artifacts']:
        assert sha(original / f['path']) == f['sha256']
    folder = dest / label
    folder.mkdir()
    copied = folder / 'input.zkir'
    shutil.copy2(original / 'input.zkir', copied)
    rec = run([str(tool), 'mock-compile', str(copied)], folder, folder)
    rec['input_sha256'] = sha(copied)
    rec['stdout_exact_match'] = (folder / 'stdout.log').read_bytes() == (original / 'stdout.log').read_bytes()
    rec['stderr_path_normalized_exact_match'] = (
        (folder / 'stderr.log').read_text().replace(str(copied), '<input>') ==
        (original / 'stderr.log').read_text().replace(str(original / 'input.zkir'), '<input>'))
    rec['expected_exit'] = prior['exit']
    rec['artifacts'] = []
    for f in prior['artifacts']:
        output = folder / f['path']
        rec['artifacts'].append({'path': f['path'], 'sha256': sha(output),
                                'expected_sha256': f['sha256'], 'exact_match': sha(output) == f['sha256']})
    write(folder / 'command.json', rec)
    results.append(rec)
    assert not rec['timeout'] and rec['exit'] == prior['exit']
    assert rec['stdout_exact_match'] and rec['stderr_path_normalized_exact_match']
    assert all(f['exact_match'] for f in rec['artifacts'])

prior = read(o / 'replay/materialize-replay.json')
argv = list(prior['command']['argv'])
mapper = Path(argv[1])
assert sha(mapper) == prior['mapper_sha256']
node = Path(argv[0])
assert sha(node) == read(o / 'verdict.json')['node']['sha256']
folder = dest / 'materialize-command'
folder.mkdir()
argv[2] = str(dest / 'materialize')
rec = run(argv, dest, folder)
rec['mapper_sha256'] = sha(mapper)
rec['files'] = []
for f in prior['files']:
    p = dest / 'materialize' / f['path']
    rec['files'].append({'path': f['path'], 'sha256': sha(p),
                        'expected_sha256': f['frozen_generated_sha256'],
                        'exact_match': sha(p) == f['frozen_generated_sha256']})
rec['stdout_exact_match'] = (folder / 'stdout.log').read_bytes() == (o / 'replay/materialize.stdout').read_bytes()
rec['stderr_exact_match'] = (folder / 'stderr.log').read_bytes() == (o / 'replay/materialize.stderr').read_bytes()
write(folder / 'command.json', rec)
assert rec['exit'] == 0 and not rec['timeout']
assert len(rec['files']) == 9 and all(f['exact_match'] for f in rec['files'])
assert rec['stdout_exact_match'] and rec['stderr_exact_match']
for name, digest in inputs['files'].items():
    assert sha(sandbox / name) == digest, name
summary = {'utc': now(), 'frozen_inputs_verified_before_after': len(inputs['files']),
    'mock_controls': results, 'materialization': rec, 'valid_mock_compiles': 2,
    'negative_format_refusals': 3, 'materialized_files_exact': 9,
    'raw_stderr_path_difference_preserved': True, 'acceptance': False,
    'scope': 'Source/materialization/artifact and format controls only; no semantic correspondence, keys, proofs, or ledger execution'}
write(dest / 'verification.json', summary)
print(json.dumps({k: v for k, v in summary.items() if k not in ['mock_controls', 'materialization']}))
