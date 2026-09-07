#!/usr/bin/env python3
"""Compare a fresh finite Lean run with an independent Python integer oracle."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import itertools
import json
from pathlib import Path
import re
import subprocess
import sys
import time


def sha(raw): return hashlib.sha256(raw).hexdigest()


def expected_records():
    expected = {}
    for a, b in itertools.product(range(16), repeat=2):
        for op in ['add', 'sub', 'mul']:
            value = {'add': a+b, 'sub': a-b, 'mul': a*b}[op]
            result = ('error', 'subUnderflow') if value < 0 else (
                ('error', op+'Overflow') if value >= 16 else ('ok', str(value)))
            expected[('basic', op, str(a), str(b))] = result
        for d, mode in itertools.product(range(17), ['down', 'up']):
            if d == 0:
                result = ('error', 'divisionByZero')
            else:
                quotient, remainder = divmod(a*b, d)
                value = quotient + int(mode == 'up' and remainder != 0)
                result = ('error', 'quotientOverflow') if value >= 16 else ('ok', str(value))
            expected[('division', mode, str(a), str(b), str(d))] = result
    for amount, num, den, mode, convention in itertools.product(
            range(16), range(17), range(17), ['down', 'up'], ['gross', 'top']):
        if den == 0 or num > den:
            result = ('error', 'invalidRate')
        else:
            quotient, remainder = divmod(amount*num, den)
            fee = quotient + int(mode == 'up' and remainder != 0)
            charged = amount if convention == 'gross' else amount+fee
            received = amount-fee if convention == 'gross' else amount
            result = ('error', 'addOverflow') if charged >= 16 else (
                'ok', str(amount), str(fee), str(charged), str(received))
        expected[('fee', convention, mode, str(amount), str(num), str(den))] = result
    assert Counter(key[0] for key in expected) == {'basic': 768, 'division': 8704, 'fee': 18496}
    assert len(expected) == 27968
    return expected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--candidate', required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    root = args.repo.resolve(); out = args.out.absolute()
    if out.exists() or out.is_symlink(): raise RuntimeError('Output exists')
    diagnostic = root/'review/semantic-kernel/integer-arithmetic/diagnostics/Diagnostic.lean'
    paths = set(); queue = ['DefiKernel.Arithmetic.Operations', 'DefiKernel.Arithmetic.Fees']
    while queue:
        module = queue.pop(); path = root/'lean'/(module.replace('.', '/')+'.lean')
        if path in paths: continue
        paths.add(path)
        queue.extend(re.findall(r'^import (DefiKernel\.[\w.]+)', path.read_text(), re.M))
    paths.update(root/'lean'/p for p in ['lean-toolchain', 'lakefile.toml', 'lake-manifest.json'])
    bindings = {}
    for path in sorted(paths):
        relative = str(path.relative_to(root)); raw = path.read_bytes()
        frozen = subprocess.check_output(['git', 'show', args.candidate+':'+relative], cwd=root)
        if frozen != raw: raise RuntimeError('Candidate source differs: '+relative)
        bindings[relative] = {'sha256': sha(raw), 'bytes': len(raw)}
    out.mkdir(parents=True)
    expectation = expected_records()
    (out/'expected.json').write_text(json.dumps([
        {'input': key, 'expected': value} for key, value in expectation.items()], separators=(',', ':'))+'\n')
    argv = ['lake', 'env', 'lean', str(diagnostic)]
    started = datetime.now(timezone.utc).isoformat(); tick = time.monotonic()
    try:
        proc = subprocess.run(argv, cwd=root/'lean', capture_output=True, timeout=600)
    except subprocess.TimeoutExpired as err:
        proc = subprocess.CompletedProcess(argv, 124, err.stdout or b'', err.stderr or b'')
    (out/'stdout.log').write_bytes(proc.stdout); (out/'stderr.log').write_bytes(proc.stderr)
    actual = {}; malformed = []
    for line in proc.stdout.decode().splitlines():
        if not line.startswith('DIAG,'): continue
        pieces = line.split(',')[1:]
        key_length = {'basic': 4, 'division': 5, 'fee': 6}.get(pieces[0])
        if key_length is None or len(pieces) <= key_length:
            malformed.append(line); continue
        key, value = tuple(pieces[:key_length]), pieces[key_length:]
        if value[0] == 'error' and len(value) == 2:
            value[1] = value[1].removeprefix('DefiKernel.Arithmetic.Failure.')
        if key in actual: malformed.append('duplicate '+line)
        actual[key] = tuple(value)
    differences = [{'input': key, 'expected': value, 'actual': actual.get(key)}
                   for key, value in expectation.items() if actual.get(key) != value]
    extra = sorted(set(actual)-set(expectation))
    after = {p: sha((root/p).read_bytes()) == row['sha256'] for p, row in bindings.items()}
    passed = proc.returncode == 0 and not differences and not extra and not malformed and all(after.values())
    polarities = Counter((key[0], value[0]) for key, value in actual.items())
    passed = passed and all(polarities[(family, kind)] > 0
                           for family in ['basic', 'division', 'fee'] for kind in ['ok', 'error'])
    lean = Path(subprocess.check_output(['elan', 'which', 'lean'], cwd=root/'lean', text=True).strip())
    record = {'status': 'PASS' if passed else 'FAIL', 'candidate': args.candidate,
        'command': argv, 'cwd': str(root/'lean'), 'exit': proc.returncode, 'timeout_seconds': 600,
        'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
        'elapsed_seconds': time.monotonic()-tick, 'source_before': bindings, 'source_unchanged': after,
        'expected_count': len(expectation), 'actual_count': len(actual),
        'differences': differences, 'extra_inputs': extra, 'malformed': malformed,
        'polarities': {'.'.join(key): value for key, value in polarities.items()},
        'tools': {str(p): sha(p.read_bytes()) for p in [lean, Path(sys.executable).resolve()]},
        'helper_bindings': {str(p.relative_to(root)): sha(p.read_bytes()) for p in [diagnostic, Path(__file__).resolve()]},
        'outputs': {p.name: sha(p.read_bytes()) for p in out.iterdir() if p.is_file()},
        'scope': '27968 finite width4 executions against independent Python divmod, not a generic proof or chain implementation comparison.'}
    (out/'result.json').write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps({k: record[k] for k in ['status', 'candidate', 'exit', 'expected_count', 'actual_count', 'polarities']}))
    return 0 if passed else (3 if proc.returncode not in [0, 1] or malformed or extra else 1)


if __name__ == '__main__':
    raise SystemExit(main())
