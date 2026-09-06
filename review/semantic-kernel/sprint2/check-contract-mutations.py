#!/usr/bin/env python3
"""Replay source-bound contract mutations; accepted proof modules are never changed.

Usage: python3 replay_contract_mutations.py --repo REPO --out NEW_OUTPUT_DIR
       [--expected PREVIOUS_OUTPUT_DIR/source-manifest.json]
Exit 0 = nonempty control passes and both mutants explicitly fail comparisons;
exit 1 = sensitivity assertion fails; exit 3 = setup/source binding/execution blocked.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--expected', type=Path)
    args = parser.parse_args()
    repo = args.repo.resolve()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    rels = [f'lean/DefiKernel/{name}.lean' for name in
            ['Core', 'Examples', 'Contracts', 'ContractExamples',
             'ContractAcceptance', 'ContractAudit']]
    rels += ['lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml']
    # Projects with a Lean Lake configuration are equally replayable.
    if not (repo / rels[-1]).exists():
        rels[-1] = 'lean/lakefile.lean'
    blobs = {rel: (repo / rel).read_bytes() for rel in rels}
    sources = {rel: sha(data) for rel, data in blobs.items()}
    if args.expected:
        expected = json.loads(args.expected.read_text())['sources']
        if expected != sources:
            raise RuntimeError('Source hashes differ from the expected manifest')
    for rel, data in blobs.items():
        target = out / 'inputs' / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
    manifest = {'sources': sources, 'repo': str(repo), 'script_sha256': sha(Path(__file__).read_bytes())}
    records = []

    def command(label, argv):
        proc = subprocess.run(argv, cwd=repo / 'lean', text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        (out / (label + '.log')).write_text(proc.stdout)
        records.append({'label': label, 'argv': argv, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(proc.stdout.encode())})
        return proc

    version = command('lean-version', ['lake', 'env', 'lean', '--version'])
    if version.returncode != 0:
        raise RuntimeError('Lean version command failed; tool identity is unavailable')
    manifest['lean_version'] = version.stdout.strip()

    def git_identity(stage):
        head = command('git-head-' + stage, ['git', '-C', str(repo), 'rev-parse', 'HEAD'])
        status = command('git-status-' + stage,
                         ['git', '-C', str(repo), 'status', '--porcelain=v1',
                          '--untracked-files=all', '--'] + rels)
        if head.returncode or status.returncode:
            raise RuntimeError('Git input identity could not be recorded')
        changed = {line[3:]: line[:2] for line in status.stdout.splitlines()}
        return {'head': head.stdout.strip(), 'porcelain': status.stdout,
                'per_input_status': {rel: changed.get(rel, 'clean') for rel in rels}}

    manifest['git_before'] = git_identity('before')
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    base = command('base-build', ['lake', 'build', 'DefiKernel.Examples'])
    if base.returncode:
        raise RuntimeError('Unchanged base build failed; mutation evidence is blocked')

    def executable_prefix(name):
        source = blobs[f'lean/DefiKernel/{name}.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        if source.count(marker) != 1:
            raise RuntimeError(f'{name}: expected one explicit executable/proof boundary')
        prefix, proofs = source.split(marker)
        if not proofs.rstrip().endswith(f'end DefiKernel.{name}'):
            raise RuntimeError(f'{name}: unexpected namespace closure')
        # This bounded extraction excludes proof declarations only. It uses no theorem regex.
        if not prefix.startswith('import ') or f'namespace DefiKernel.{name}\n' not in prefix:
            raise RuntimeError(f'{name}: executable prefix has unexpected structure')
        prefix = '\n'.join(line for line in prefix.splitlines() if not line.startswith('import '))
        return prefix + f'\n\nend DefiKernel.{name}\n'

    contracts = executable_prefix('Contracts')
    examples = executable_prefix('ContractExamples')
    audit = blobs['lean/DefiKernel/ContractAudit.lean'].decode()
    audit_import = 'import DefiKernel.ContractAcceptance\n'
    if not audit.startswith(audit_import) or audit.count(audit_import) != 1:
        raise RuntimeError('Unexpected audit import; refusing broad source rewriting')
    audit = audit[len(audit_import):]
    combined = 'import DefiKernel.Examples\n' + contracts + examples + audit
    changes = {
        'contract-bypass': ('if contract.accepts s env t then', 'if true then'),
        'borrow-condition-bypass': ('decide (BorrowConditions actor q s oracle)', 'true'),
    }
    variants = {'control': combined}
    for label, (old, new) in changes.items():
        if combined.count(old) != 1:
            raise RuntimeError(f'{label}: expected exactly one mutation site')
        variants[label] = combined.replace(old, new, 1)
    results = {}
    for label, source in variants.items():
        fixture = out / (label.replace('-', '_') + '.lean')
        fixture.write_text(source)
        proc = command(label, ['lake', 'env', 'lean', str(fixture)])
        observations = re.findall(r'^([a-z_]+): (true|false)$', proc.stdout, re.MULTILINE)
        checks = dict(observations)
        if not checks or len(observations) != len(checks):
            raise RuntimeError(f'{label}: empty or duplicated runtime observations')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in proc.stdout.splitlines() if ': error:' in line]
        if label == 'control':
            assert proc.returncode == 0 and not false and not errors, 'control did not pass'
        else:
            if set(checks) != set(results['control']['checks']):
                raise RuntimeError(f'{label}: incomplete comparison execution')
            # Require the exact runtime failure diagnostic, excluding compiler-only failures.
            expected_error = f'error: Contract runtime comparisons failed: {len(false)}'
            if len(errors) != 1 or not errors[0].endswith(expected_error):
                raise RuntimeError(f'{label}: did not fail solely with the expected comparison error')
            required = 'vault_drain_refused' if label == 'contract-bypass' else 'forged_isolated_zero_price_refused'
            assert proc.returncode != 0 and required in false, f'{label}: missing explicit false comparison'
            for positive in ['transfer_post', 'deposit_post', 'withdraw_post', 'borrow_post',
                             'forged_fresh_post', 'zero_borrow_positive_price_post']:
                assert checks[positive] == 'true', f'{label}: positive control failed'
        results[label] = {'exit': proc.returncode, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        print(f'{label}: exit {proc.returncode}; {len(checks)} comparisons; false={false}')
    manifest['sources_after'] = {rel: sha((repo / rel).read_bytes()) for rel in rels}
    manifest['git_after'] = git_identity('after')
    manifest['input_sources_unchanged'] = manifest['sources_after'] == sources
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
    if not manifest['input_sources_unchanged']:
        raise RuntimeError('Input source bytes changed during replay; evidence is blocked')
    assert len(results) == 3
    print('DISCRIMINATES: unchanged positive control and both required source mutants')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {exc}', file=sys.stderr)
        sys.exit(3)
