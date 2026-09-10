from pathlib import Path
import datetime, hashlib, json, shutil, subprocess

b = Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908')
o = b / 'p19-r16-error-precedence-diagnostic'
o.mkdir(exist_ok=False)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
cases = [
    ('bad_escape_then_scientific', r'{"a":"\x","b":1e2}'),
    ('whitespace_then_bad_escape', r'{"a": "\x"}'),
    ('bad_escape_then_duplicate', r'{"a":"\x","b":1,"b":2}'),
    ('bad_escape_then_depth', r'{"a":"\x","b":' + '[' * 64 + '0' + ']' * 64 + '}'),
    ('scientific_then_bad_escape', r'{"b":1e2,"a":"\x"}'),
    ('duplicate_then_bad_escape', r'{"b":1,"b":2,"a":"\x"}')]
entries = ',\n'.join('(' + json.dumps(n) + ', ' + json.dumps(s) + ')' for n, s in cases)
source = '''import DefiKernel.Certificates.Correspondence
namespace DefiKernel.Certificates
set_option maxRecDepth 500000
set_option maxHeartbeats 4000000
def mixedErrorInputs : List (String × String) := [
''' + entries + ''']
#eval mixedErrorInputs.map fun (name, s) =>
  let scan := match scanLexical s.toUTF8 with | .ok _ => "ok" | .error e => reprStr e
  let dec := match decodeBytes s.toUTF8 with | .ok _ => "ok" | .error e => reprStr e
  s!"{name};scan={scan};decode={dec}"
end DefiKernel.Certificates
'''
(o / 'Probe.lean').write_text(source)
write(o / 'inputs.json', [{'case': n, 'raw_json': s} for n, s in cases])
tool = Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin')
results = {}
for label, directory in [('r15', 'p19-byte-pipeline-grok-r1'), ('r16', 'p19-scanner-repair-grok-r1')]:
    private = b / directory / 'private-lean'
    folder = o / label
    folder.mkdir()
    argv = [str(tool / 'lake'), 'env', str(tool / 'lean'), str(o / 'Probe.lean')]
    start = now()
    x = subprocess.run(argv, cwd=private, capture_output=True, timeout=120)
    (folder / 'stdout.log').write_bytes(x.stdout)
    (folder / 'stderr.log').write_bytes(x.stderr)
    rec = {'argv': argv, 'cwd': str(private), 'started_utc': start, 'finished_utc': now(),
        'exit': x.returncode, 'probe_sha256': sha(o / 'Probe.lean'), 'lean_sha256': sha(tool / 'lean'),
        'lake_sha256': sha(tool / 'lake'), 'stdout_sha256': sha(folder / 'stdout.log'),
        'stderr_sha256': sha(folder / 'stderr.log'), 'source_hashes': {
            n: sha(private / 'DefiKernel/Certificates' / (n + '.lean')) for n in ['Decode', 'CanonicalJson', 'Correspondence', 'Encode', 'Schema']},
        'acceptance': False}
    write(folder / 'receipt.json', rec)
    assert x.returncode == 0, label + ': failure retained'
    results[label] = json.loads(x.stdout)
differences = [{'case': cases[n][0], 'r15': before, 'r16': after}
               for n, (before, after) in enumerate(zip(results['r15'], results['r16'])) if before != after]
write(o / 'assessment.json', {'utc': now(), 'case_count': len(cases), 'results': results,
    'differences': differences, 'scope': 'Concrete malformed mixed-error inputs; not an admissible-IR counterexample or a universal theorem',
    'acceptance': False})
shutil.copy2(__file__, o / 'verify.py')
write(o / 'root-seal.json', {'utc': now(), 'files': {
    str(p.relative_to(o)): sha(p) for p in sorted(o.rglob('*')) if p.is_file()}, 'acceptance': False})
print(json.dumps({'case_count': len(cases), 'differences': differences, 'acceptance': False}))
