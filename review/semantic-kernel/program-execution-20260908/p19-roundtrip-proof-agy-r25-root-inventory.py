"""Run only after R25 freezes. Inventory evidence is separate from theorem-scope review."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import subprocess

ROOT = Path('/home/charl/defiformal')
BASE = ROOT / 'review/semantic-kernel/program-execution-20260908'
WORK = Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909')
OUT = BASE / 'p19-r25-root-inventory'
TOOL = Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin')

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def read(path):
    return json.loads(path.read_text())

def write(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')

def utc():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()

def main():
    manifest_path = BASE / 'p19-roundtrip-proof-agy-r25-terminal-manifest.json'
    if not manifest_path.exists():
        raise SystemExit('R25 terminal freeze required; no author files inspected.')
    manifest = read(manifest_path)
    dispatch = read(BASE / 'p19-roundtrip-proof-agy-r25-dispatch.json')
    assert not Path('/proc', str(dispatch['pid'])).exists(), 'Author still present'
    for proc in Path('/proc').iterdir():
        if not proc.name.isdigit():
            continue
        try:
            cwd = str((proc / 'cwd').resolve())
            name = (proc / 'comm').read_text().strip()
        except (OSError, RuntimeError):
            continue
        assert not (cwd.startswith(str(WORK)) and name in ['lean', 'lake', 'agy', 'node']), (proc.name, name)
    assert digest(BASE / manifest['archive']) == manifest['sha256']
    for item in manifest['files']:
        assert digest(WORK / item['path']) == item['sha256'], item['path']
    OUT.mkdir(exist_ok=False)
    names, counts, sources = [], {}, {}
    for module in ['CanonicalJson', 'Correspondence', 'Roundtrip']:
        path = WORK / f'lean/DefiKernel/Certificates/{module}.lean'
        text = path.read_text()
        found = re.findall(r'^\s*(?:@\[[^\n]*\]\s*)?(?:theorem|lemma)\s+(\S+)', text, re.M)
        counts[module] = len(found)
        sources[str(path.relative_to(WORK))] = digest(path)
        names.extend(found)
    assert names and len(names) == len(set(names)), 'Missing or duplicate source inventory'
    qualified = ['DefiKernel.Certificates.' + name for name in names]
    probe = OUT / 'Axioms.lean'
    probe.write_text('import DefiKernel.Certificates.Roundtrip\n' + ''.join('#print axioms ' + name + '\n' for name in qualified))
    argv = [str(TOOL / 'lake'), 'env', str(TOOL / 'lean'), str(probe)]
    started = utc()
    timed_out = False
    try:
        run = subprocess.run(argv, cwd=WORK / 'lean', capture_output=True, timeout=180)
        stdout, stderr, code = run.stdout, run.stderr, run.returncode
    except subprocess.TimeoutExpired as error:
        stdout, stderr, code = error.stdout or b'', error.stderr or b'', None
        timed_out = True
    finished = utc()
    (OUT / 'axioms.stdout').write_bytes(stdout)
    (OUT / 'axioms.stderr').write_bytes(stderr)
    text = stdout.decode(errors='replace')
    records = re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", text, re.S)
    zero = re.findall(r"'([^']+)' does not depend on any axioms", text)
    got = [name for name, _ in records] + zero
    forbidden = [{'name': name, 'axioms': axioms} for name, axioms in records if set(x.strip() for x in axioms.split(',') if x.strip()) - {'propext', 'Classical.choice', 'Quot.sound'}]
    receipt = {'started_utc': started, 'finished_utc': finished, 'argv': argv, 'cwd': str(WORK / 'lean'), 'exit': code, 'timed_out': timed_out, 'candidate_archive_sha256': manifest['sha256'], 'probe_sha256': digest(probe), 'source_sha256': sources, 'lean_sha256': digest(TOOL / 'lean'), 'lake_sha256': digest(TOOL / 'lake'), 'stdout_sha256': digest(OUT / 'axioms.stdout'), 'stderr_sha256': digest(OUT / 'axioms.stderr'), 'source_counts': counts, 'theorem_lemma_total': len(names), 'standard_axiom_records': len(records), 'zero_axiom_records': len(zero), 'exact_names_match': len(got) == len(qualified) and set(got) == set(qualified), 'forbidden': forbidden, 'scope': 'Explicit theorem/lemma names in the three frozen source modules, imported from terminal author build. Definitions and generated declarations excluded. Fresh reviewer build and semantic scope require separate evidence.', 'acceptance': False}
    write(OUT / 'command.json', receipt)
    assert code == 0 and receipt['exact_names_match'] and not forbidden, receipt
    for item in manifest['files']:
        assert digest(WORK / item['path']) == item['sha256'], item['path']
    write(OUT / 'inventory.json', {'sources': sources, 'names': qualified, 'counts': counts, 'acceptance': False})
    (OUT / 'verify.py').write_bytes(Path(__file__).read_bytes())
    files = {str(path.relative_to(OUT)): digest(path) for path in OUT.iterdir() if path.is_file()}
    write(OUT / 'root-seal.json', {'utc': utc(), 'files': files, 'file_count': len(files), 'acceptance': False})
    print(json.dumps({'theorem_lemma_total': len(names), 'standard_axiom_records': len(records), 'zero_axiom_records': len(zero), 'acceptance': False}))

if __name__ == '__main__':
    main()
