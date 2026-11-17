#!/usr/bin/env python3
"""Replay byte-preserved IOG adapters with explicit dependencies and isolated output."""
import argparse
import hashlib
import importlib
import json
import os
import platform
from pathlib import Path
import re
import runpy
import subprocess
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ADAPTERS = {
    'int64': 'int64-2b60322',
    'transfer': 'rational-1/transfer-2b60322-2',
    'swap': 'rational-1/swap-2b60322-2',
    'workflow': 'rational-1/workflow-2b60322-3',
}
KINDS = ('canonical', 'witnesses', 'mutants', 'parser', 'cache', 'proof', 'trust')


class Blocked(RuntimeError):
    pass


def digest(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def verify_sources():
    manifest = json.loads((HERE / 'PROVENANCE.json').read_text())
    entries = manifest['files']
    expected = {entry['path'] for entry in entries}
    actual = {str(path.relative_to(HERE)) for path in (HERE / 'upstream').rglob('*') if path.is_file()}
    if not entries or len(expected) != len(entries) or actual != expected:
        raise Blocked('source inventory missing, extra, duplicate or empty')
    for entry in entries:
        path = HERE / entry['path']
        if path.is_symlink() or not path.resolve().is_relative_to(HERE / 'upstream'):
            raise Blocked('source path escapes import: ' + entry['path'])
        if path.stat().st_size != entry['bytes'] or digest(path) != entry['sha256']:
            raise Blocked('source bytes changed: ' + entry['path'])
    return dict(status='passed', files_checked=len(entries), origin_revision=manifest['origin_revision'])


def disjoint_output(output, dependency):
    for protected in [HERE, dependency]:
        if output.is_relative_to(protected) or protected.is_relative_to(output):
            raise Blocked('output overlaps source or dependency tree')


def validate_environment(args):
    if sys.flags.optimize:
        raise Blocked('Python assertions must be enabled for upstream acceptance checks')
    lean, dependency = Path(args.lean_bin).resolve(), Path(args.dependency_root).resolve()
    output = Path(args.output).resolve()
    disjoint_output(output, dependency)
    disjoint_output(output, lean.parent)
    if not lean.is_file() or not (lean.parent / 'leanchecker').is_file():
        raise Blocked('Lean compiler and sibling leanchecker are required')
    version = subprocess.check_output([str(lean), '--version'], text=True).strip()
    if not re.search(r'\bversion 4\.33\.0-rc2,', version):
        raise Blocked('incorrect Lean version: ' + version)
    if args.historical_runtime:
        historical = Path(args.historical_runtime).resolve()
        if (lean != historical / 'lean-4.33.0-rc2-darwin_aarch64/bin/lean'
                or dependency != historical / 'upstream/lean'):
            raise Blocked('historical runtime must match the invoked compiler and dependency root')
    source_hashes = json.loads((HERE / 'dependency-sources.json').read_text())['files']
    for name, sha in source_hashes.items():
        path = dependency / name
        if not path.is_file() or digest(path) != sha:
            raise Blocked('pinned dependency source mismatch: ' + name)
    lock = json.loads((dependency / 'lake-manifest.json').read_text())
    mathlib = [p for p in lock['packages'] if p['name'] == 'mathlib']
    if len(mathlib) != 1 or mathlib[0]['rev'] != '51e6992efd06126df61a496bebf8f49482a4e129':
        raise Blocked('incorrect mathlib revision')
    for name in ['Core', 'Examples', 'Typed/Types', 'Typed/Expr', 'Arithmetic/Operations', 'Arithmetic/Rounding']:
        if not (dependency / '.lake/build/lib/lean/DefiKernel' / (name + '.olean')).is_file():
            raise Blocked('missing compiled native dependency: ' + name)
    return dict(lean=str(lean), dependency=str(dependency), version=version,
                lean_sha256=digest(lean), leanchecker_sha256=digest(lean.parent / 'leanchecker'),
                native_sources=source_hashes, python=sys.version, platform=platform.platform(),
                entrypoint_sha256=digest(HERE / 'reproduce.py'),
                provenance_sha256=digest(HERE / 'PROVENANCE.json'),
                dependency_boundary='Pinned native source bytes; imported compiled dependencies trusted. No closure rebuild claimed.')


def configure(args, identity):
    """Redirect the preserved adapter setup module without editing its source."""
    adapter = HERE / 'upstream' / ADAPTERS[args.adapter]
    sys.path.insert(0, str(adapter))
    setup = importlib.import_module('setup')
    output = Path(args.output).resolve()
    runtime = Path(args.historical_runtime).resolve() if args.historical_runtime else output / 'runtime'
    setup.runtime = lambda: runtime
    setup.lean = lambda: Path(identity['lean'])
    setup.install = lambda: identity['version']
    def environment(extra=None):
        dependency = Path(identity['dependency'])
        paths = [dependency / '.lake/build/lib/lean']
        paths.extend(sorted((dependency / '.lake/packages').glob('*/.lake/build/lib/lean')))
        if extra is not None:
            paths.insert(0, Path(extra))
        env = os.environ.copy()
        env['LEAN_PATH'] = os.pathsep.join(map(str, paths))
        env['PATH'] = str(Path(identity['lean']).parent) + os.pathsep + env.get('PATH', '')
        env['LEAN_NUM_THREADS'] = '1'
        return env
    setup.environment = environment
    os.environ['XDG_CACHE_HOME'] = str(output / 'cache')
    os.environ['RATIONAL_ACCEPTANCE_EVIDENCE_ROOT'] = str(output)
    os.environ.pop('MEASUREMENT_OUTPUT', None)
    return adapter


def run_one(args):
    verify_sources()
    identity = validate_environment(args)
    adapter = configure(args, identity)
    if args.kind == 'trust' and not args.historical_runtime:
        raise Blocked('trust requires --historical-runtime; original native locks bind exact Darwin artifacts')
    if args.kind == 'proof':
        if args.adapter == 'int64':
            driver = importlib.import_module('adapter')
            driver.prepare(args.case, 'assisted')
            result = driver.replay(args.case, 'assisted')
            if driver.classify(result) != 'success':
                raise RuntimeError(json.dumps(result))
            report = driver.check_proof(args.case)
        else:
            driver = importlib.import_module('driver')
            work, records, verdict = driver.compile_target('assisted', case_id=args.case)
            if verdict != 'success':
                raise RuntimeError(json.dumps(records))
            report = driver.check_proof(args.case, work)
        print(json.dumps(dict(status='passed', check='proof', case_id=args.case, details=report)))
    else:
        sys.argv = [str(adapter / 'acceptance.py'), args.kind, args.case]
        runpy.run_path(str(adapter / 'acceptance.py'), run_name='__main__')


def check(args):
    inventory = verify_sources()
    identity = validate_environment(args)
    output = Path(args.output).resolve()
    if args.kind == 'trust' and not args.historical_runtime:
        raise Blocked('trust requires --historical-runtime; original native locks bind exact Darwin artifacts')
    if output.exists() and any(output.iterdir()):
        raise Blocked('output must be fresh and empty')
    output.mkdir(parents=True, exist_ok=True)
    records = []
    adapters = ADAPTERS if args.adapter == 'all' else [args.adapter]
    for name in adapters:
        adapter = HERE / 'upstream' / ADAPTERS[name]
        cases = json.loads((adapter / 'manifest.json').read_text())['cases']
        selected = list(cases) if not args.case else [args.case]
        if any(case not in cases for case in selected):
            raise Blocked('case absent from adapter manifest')
        contracts = json.loads((adapter / 'checks.json').read_text())['checks']
        for case in selected:
            available = [entry['kind'] for entry in contracts if entry['case_id'] == case]
            kinds = [kind for kind in available if kind != 'trust'] + ['proof'] if args.kind == 'all' else [args.kind]
            if args.historical_runtime and args.kind == 'all': kinds.append('trust')
            for kind in kinds:
                if kind != 'proof' and kind not in available:
                    raise Blocked('check absent from adapter contract: ' + kind)
                destination = output / name / case / kind
                command = [sys.executable, str(HERE / 'reproduce.py'), '_run', '--adapter', name,
                           '--case', case, '--kind', kind, '--lean-bin', args.lean_bin,
                           '--dependency-root', args.dependency_root, '--output', str(destination)]
                if args.historical_runtime:
                    command += ['--historical-runtime', args.historical_runtime]
                try:
                    result = subprocess.run(command, capture_output=True, text=True, timeout=900)
                    destination.mkdir(parents=True, exist_ok=True)
                    (destination / 'stdout.json').write_text(result.stdout)
                    (destination / 'stderr.txt').write_text(result.stderr)
                    payload = json.loads(result.stdout) if result.returncode == 0 else {}
                    expected = 'rejected' if kind == 'mutants' else 'passed'
                    passed = result.returncode == 0 and payload.get('status') == expected
                    records.append(dict(adapter=name, case=case, kind=kind, returncode=result.returncode,
                                        passed=passed, expected_status=expected,
                                        evidence=str(destination.relative_to(output))))
                except subprocess.TimeoutExpired:
                    records.append(dict(adapter=name, case=case, kind=kind, passed=False, timeout=True))
                print(json.dumps(records[-1]), flush=True)
                (output / 'summary.json').write_text(json.dumps(dict(inventory=inventory, identity=identity,
                    checks=records, checks_completed=len(records), status='running'), indent=2) + '\n')
                if not records[-1]['passed']:
                    summary = json.loads((output / 'summary.json').read_text())
                    summary['status'] = 'blocked' if records[-1].get('returncode') == 3 else 'failed'
                    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
                    if summary['status'] == 'blocked':
                        raise Blocked('check blocked; see ' + str(destination))
                    raise RuntimeError('check failed; see ' + str(destination))
    if not records: raise Blocked('empty check selection')
    verify_sources()
    (output / 'summary.json').write_text(json.dumps(dict(inventory=inventory, identity=identity,
        checks=records, checks_completed=len(records), status='passed'), indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('verify-sources')
    for name in ['check', '_run']:
        sub = commands.add_parser(name, help=argparse.SUPPRESS if name == '_run' else 'fresh adapter checks')
        sub.add_argument('--adapter', choices=[*ADAPTERS, 'all'] if name == 'check' else list(ADAPTERS), default='all')
        sub.add_argument('--case')
        sub.add_argument('--kind', choices=[*KINDS, 'all'] if name == 'check' else KINDS, default='all')
        sub.add_argument('--lean-bin', required=True)
        sub.add_argument('--dependency-root', required=True, help='pinned upstream lean/ directory with .lake dependencies')
        sub.add_argument('--output', required=True)
        sub.add_argument('--historical-runtime', help='optional exact Darwin archive runtime for original native-lock checks')
    args = parser.parse_args()
    try:
        if args.command == 'verify-sources': print(json.dumps(verify_sources()))
        elif args.command == 'check': check(args)
        else: run_one(args)
    except (Blocked, OSError, ValueError, KeyError, subprocess.SubprocessError) as exc:
        print('BLOCKED: ' + str(exc), file=sys.stderr)
        return 3
    except (AssertionError, RuntimeError) as exc:
        print('FAILED: ' + str(exc), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
