from pathlib import Path
import datetime, hashlib, json, shutil, subprocess

r = Path('/home/charl/defiformal')
b = r / 'review/semantic-kernel/program-execution-20260908'
o = b / 'p19-scanner-repair-grok-r1'
dest = o / 'root-verification/controls'
dest.mkdir(exist_ok=False)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
tool = Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin')
records = []
for label, original, private, fix_comments in [
    ('c0-r16', o / 'probes/c0-replay/Probe.lean', o / 'private-lean', False),
    ('limits-r16', o / 'probes/limits/Probe.lean', o / 'private-lean', True),
    ('limits-r15', o / 'probes/limits/Probe.lean', b / 'p19-byte-pipeline-grok-r1/private-lean', True)]:
    folder = dest / label
    folder.mkdir()
    shutil.copy2(original, folder / 'Original.lean')
    source = original.read_text()
    if fix_comments:
        source = source.replace('/--', '/-')
    probe = folder / 'Probe.lean'
    probe.write_text(source)
    argv = [str(tool / 'lake'), 'env', str(tool / 'lean'), str(probe)]
    start = now()
    x = subprocess.run(argv, cwd=private, capture_output=True, timeout=120)
    (folder / 'stdout.log').write_bytes(x.stdout)
    (folder / 'stderr.log').write_bytes(x.stderr)
    rec = {'label': label, 'argv': argv, 'cwd': str(private), 'started_utc': start,
        'finished_utc': now(), 'exit': x.returncode, 'original_probe_sha256': sha(original),
        'probe_sha256': sha(probe), 'source_change': 'Doc comments changed to ordinary comments before #eval commands' if fix_comments else 'none',
        'lean_sha256': sha(tool / 'lean'), 'lake_sha256': sha(tool / 'lake'),
        'stdout_sha256': sha(folder / 'stdout.log'), 'stderr_sha256': sha(folder / 'stderr.log'),
        'source_hashes': {n: sha(private / 'DefiKernel/Certificates' / (n + '.lean')) for n in ['Decode', 'CanonicalJson', 'Correspondence', 'Encode', 'Schema']},
        'acceptance': False}
    if label == 'c0-r16':
        rec['reviewer_stdout_exact_match'] = x.stdout == (o / 'logs/c0-replay/stdout').read_bytes()
        rec['reviewer_stderr_exact_match'] = x.stderr == (o / 'logs/c0-replay/stderr').read_bytes()
    write(folder / 'receipt.json', rec)
    records.append(rec)
    assert x.returncode == 0, label + ': original source and failed output retained'
    if label == 'c0-r16': assert rec['reviewer_stdout_exact_match'] and rec['reviewer_stderr_exact_match']
shutil.copy2(__file__, dest / 'verify.py')
write(dest / 'commands.json', records)
print(json.dumps({'commands': [{'label': x['label'], 'exit': x['exit'], 'stdout_sha256': x['stdout_sha256']} for x in records], 'acceptance': False}))
