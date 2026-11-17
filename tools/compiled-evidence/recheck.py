#!/usr/bin/env python3
"""Verify this package's checksums and replay selected modules with its bundled Lean kernel."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import platform
import subprocess
import sys
import tempfile
import time


class Blocked(Exception):
    pass


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024*1024), b''):
            h.update(chunk)
    return h.hexdigest()


def inspect_package(root):
    manifest_bytes = (root / 'manifest.json').read_bytes()
    if not manifest_bytes:
        raise Blocked('empty manifest')
    manifest = json.loads(manifest_bytes)
    allowed_empty = set(manifest['allowed_empty_evidence_files'])
    checksums = (root / 'SHA256SUMS').read_text().splitlines()
    if not checksums:
        raise Blocked('empty checksum inventory')
    names = set()
    for line in checksums:
        expected, name = line.split('  ', 1)
        if Path(name).is_absolute() or '..' in Path(name).parts or name in names:
            raise ValueError('unsafe or duplicate checksum path: ' + name)
        names.add(name)
        path = root / name
        if not path.is_file() or (path.stat().st_size == 0 and name not in allowed_empty):
            raise Blocked('missing or empty artifact: ' + name)
        if digest(path) != expected:
            raise ValueError('checksum mismatch: ' + name)
    actual = {str(p.relative_to(root)) for p in root.rglob('*') if p.is_file()}
    if actual != names | {'SHA256SUMS'}:
        raise ValueError('checksum inventory differs from package files')
    if not manifest['targets']:
        raise Blocked('empty target set')
    targets = manifest['targets']
    if targets != json.loads((root/'provenance/builder/targets.json').read_text()) or len(set(targets)) != len(targets):
        raise ValueError('required target inventory differs')
    modules = {entry['module']: entry for entry in manifest['modules']}
    if not modules:
        raise Blocked('empty import closure')
    for name in targets:
        if name not in modules:
            raise Blocked('missing target in closure: ' + name)
    for module in modules.values():
        if not module['parts']:
            raise Blocked('empty module artifact inventory: ' + module['module'])
        for name in module['parts']:
            if name not in names:
                raise Blocked('unchecksummed compiled artifact: ' + name)
        if any(name not in modules for name in module['imports']):
            raise Blocked('incomplete metadata import closure: ' + module['module'])
    for name in ['bin/lean', 'bin/leanchecker']:
        if name not in names:
            raise Blocked('missing runtime executable: ' + name)
    return manifest, len(names)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument('--results', type=Path, help='new output directory outside the package')
    parser.add_argument('--verify-only', action='store_true')
    args = parser.parse_args()
    root = args.package.resolve()
    try:
        manifest, count = inspect_package(root)
        if platform.system() != 'Darwin' or platform.machine() != 'arm64':
            raise Blocked('runtime requires macOS arm64')
        if args.verify_only:
            print(json.dumps({'status': 'PASS', 'checksummed_files': count, 'targets': len(manifest['targets']), 'scope': 'bytes/inventory only; no kernel replay'}))
            return 0
        if args.results is None:
            raise Blocked('--results must name a new directory outside the package')
        results = args.results.resolve()
        if results == root or root in results.parents:
            raise ValueError('results directory must be outside package')
        results.mkdir(parents=True, exist_ok=False)
        records = []
        with tempfile.TemporaryDirectory(prefix='defiformal-replay-') as unrelated:
            env = {'PATH': str(root / 'bin') + ':/usr/bin:/bin', 'HOME': unrelated}
            for target in manifest['targets']:
                argv = [str(root / 'bin/leanchecker'), '-v', target]
                started = datetime.datetime.now(datetime.timezone.utc).isoformat()
                tick = time.monotonic()
                completed = subprocess.run(argv, cwd=unrelated, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stem = results / target
                Path(str(stem)+'.stdout.log').write_bytes(completed.stdout)
                Path(str(stem)+'.stderr.log').write_bytes(completed.stderr)
                observed = [line for line in completed.stdout.decode().splitlines() if line.startswith('replaying ')]
                passed = completed.returncode == 0 and observed == ['replaying ' + target]
                records.append(dict(target=target, argv=argv, cwd=unrelated, env=env,
                    started_utc=started, wall_seconds=time.monotonic()-tick,
                    exit=completed.returncode, observed_replay_lines=observed, passed=passed,
                    stdout_sha256=hashlib.sha256(completed.stdout).hexdigest(),
                    stderr_sha256=hashlib.sha256(completed.stderr).hexdigest()))
                print(target + ': ' + ('PASS' if passed else 'FAIL'), flush=True)
        report = dict(status='PASS' if all(r['passed'] for r in records) else 'FAIL',
            package_manifest_sha256=digest(root/'manifest.json'), checksummed_files=count,
            runs=records, scope=manifest['check_scope'],
            third_party_reproduction='Not established by an author/agent execution.')
        (results/'result.json').write_text(json.dumps(report, indent=2)+'\n')
        return 0 if report['status'] == 'PASS' else 1
    except (FileNotFoundError, PermissionError, Blocked) as error:
        print('BLOCKED: ' + str(error), file=sys.stderr)
        return 3
    except (ValueError, FileExistsError) as error:
        print('FAIL: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
