from pathlib import Path
import datetime, gzip, hashlib, json, os, re, shutil

b = Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
o = b / 'p19-scanner-repair-grok-r1'
c = o / 'closeout'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
read = lambda p: json.loads(p.read_text())
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not (o / 'root-seal.json').exists()
assert not Path('/proc/1962071').exists() and not Path('/proc/1992821').exists()
first, last = read(o / 'process.json'), read(c / 'process.json')
assert first['process_exit'] == 1 and last['process_exit'] == 0
assert first['sessions'] == last['sessions'] == ['01a08c3a-3869-7af0-99e5-d158d774830d']
assert first['reported_models'] == last['reported_models'] == ['grok-4.6-build']
assert sha(o / 'native.jsonl') == first['log_sha256']
assert sha(c / 'native.jsonl') == last['log_sha256']
inputs = read(o / 'inputs.json')
s = Path(inputs['sandbox'])
for p in Path('/proc').iterdir():
    if not p.name.isdigit(): continue
    try: cwd, comm = str((p / 'cwd').resolve()), (p / 'comm').read_text().strip()
    except (OSError, RuntimeError): continue
    assert not ((cwd.startswith(str(s)) or cwd.startswith(str(o))) and comm in ['grok', 'lean', 'lake', 'node']), (p.name, comm, cwd)
for name, digest in inputs['files'].items(): assert sha(s / name) == digest, name
manifest = read(c / 'MANIFEST.json')['files']
for f in manifest: assert sha(c / f['path']) == f['sha256'], f['path']
bindings = []
for meta in sorted((o / 'logs').rglob('meta.json')):
    d = read(meta)
    for stream in ['stdout', 'stderr']:
        key = 'raw' + stream + '_sha256'
        if key in d and stream + '_path' in d:
            p = o / d[stream + '_path']
            assert sha(p) == d[key], str(meta)
            bindings.append({'metadata': str(meta.relative_to(o)), 'stream': stream, 'sha256': d[key]})
pin = read(c / 'commands.json')['compiler_pin']
for name in ['lean_bin', 'lake_bin']: assert sha(Path(pin[name])) == pin[name + '_sha256']
assert sha(Path(pin['lean_bin']).parent.parent / 'lib/lean/libleanshared.so') == pin['libleanshared_so_sha256']
v = o / 'root-verification'
for name, digest in read(v / 'root-seal.json')['files'].items(): assert sha(v / name) == digest, name
axioms = read(v / 'axioms269-command.json')
assert axioms['exit'] == 0 and axioms['exact_names_match'] and not axioms['forbidden']
assert axioms['axiom_records'] == 258 and axioms['zero_axiom_records'] == 11
controls = read(v / 'controls/commands.json')
assert len(controls) == 3 and all(x['exit'] == 0 for x in controls)
assert controls[0]['reviewer_stdout_exact_match'] and controls[0]['reviewer_stderr_exact_match']
zero = re.findall(r"'([^']+)' does not depend on any axioms", (v / 'axioms269.stdout').read_text())
assert len(zero) == 11
regression = read(b / 'p19-r16-root-error-precedence-finding.json')
assert regression['final_decode_failure_changes'] == 4
with (c / 'native.jsonl.gz').open('xb') as f:
    with gzip.GzipFile(filename='', mode='wb', fileobj=f, mtime=0) as z: z.write((c / 'native.jsonl').read_bytes())
shutil.copy2(__file__, o / 'root-seal-verify.py')
write(o / 'root-adjudication.json', {'schema': 'defiformal-root-review-adjudication/v1', 'utc': now(),
    'candidate': 'AGY R16', 'candidate_archive_sha256': inputs['candidate_archive_sha256'],
    'verdict': 'CHANGES_REQUIRED', 'reviewer_model': 'grok-4.6-build', 'reviewer_session': first['sessions'][0],
    'original_review_exit': 1, 'reporting_closeout_exit': 0, 'same_session_closeout_is_second_review': False,
    'frozen_inputs_verified': len(inputs['files']), 'manifest_bindings_verified': len(manifest),
    'raw_command_bindings_verified': bindings, 'compiler_binary_hashes_verified': 3,
    'original_review_failed_probes': ['probe-axioms269', 'encode-sourcemap'],
    'failed_probe_success_credit': False, 'original_review_limits_probe_executed': False,
    'separate_root_verification': 'root-verification/axioms269-command.json',
    'root_named_theorems': 269, 'standard_axioms_only': 258, 'zero_axioms': 11,
    'actual_zero_axiom_names': zero, 'root_c0_replay_exact': True,
    'root_ordinary_boundary_cases': 20, 'root_mixed_error_cases': 6, 'root_mixed_error_regressions': 4,
    'root_regression_record': '../p19-r16-root-error-precedence-finding.json',
    'review_root_verification_absence_note': 'Review preserves an earlier absence observation; separately completed root checks and mixed-error findings are bound here, not relabeled as reviewer execution.',
    'remaining': [
        'Restore mixed-error precedence while retaining escaped-key repair and true duplicate refusal.',
        'Prove general lexical/parser inverse and close actual universal byte roundtrip without assumed success.',
        'Correct author zero-axiom name list and invalid-escape description against actual code/compiler output.',
        'Bind Verify totals by prefix: Certificates1415/2533, Typed420/677, Composition287/408 are historical author scopes, separate from exact269.'
    ], 'acceptance': False, 'whole_p19_accepted': False, 'whole_program_complete': False})
files = {}
for parent, dirs, names in os.walk(o):
    dirs[:] = [n for n in dirs if n not in ['private-lean', '.lake', 'node_modules', '__pycache__', '.git']]
    for name in names:
        p = Path(parent) / name
        if p.is_symlink() or not p.is_file() or name == 'native.jsonl': continue
        files[str(p.relative_to(o))] = sha(p)
write(o / 'root-seal.json', {'utc': now(), 'files': dict(sorted(files.items())),
    'excluded': ['private build sources/cache', 'raw native streams separately preserved as hashed terminal gzip', 'symlinks'],
    'frozen_inputs_verified': len(inputs['files']), 'manifest_bindings_verified': len(manifest), 'acceptance': False})
print(json.dumps({'sealed_files': len(files), 'manifest_bindings': len(manifest),
    'command_stream_bindings': len(bindings), 'root_theorems': 269, 'mixed_error_regressions': 4, 'acceptance': False}))
