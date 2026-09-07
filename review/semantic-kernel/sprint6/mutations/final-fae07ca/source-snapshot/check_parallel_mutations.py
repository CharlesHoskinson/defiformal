#!/usr/bin/env python3
"""Replay the actual parallel Lean implementation under explicit source mutations.

The specification names an ordered, nonempty list of source modules, mutation
sites, required false observations and protected positive controls. Proof-only
suffixes are excluded from temporary execution copies, never from accepted files.
Exit 0: nonempty control and all sensitivity assertions pass; 1: failed assertion;
3: unavailable evidence, malformed specification or compilation/setup failure.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


CHECK_NAME = r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*'


class Blocked(Exception):
    pass


def require(value, message):
    if not value:
        raise Blocked(message)


def check(value, message):
    if not value:
        raise AssertionError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    raw = path.read_bytes()
    require(raw.strip(), f'empty required input: {path}')
    return raw


def parse(raw):
    def pairs(items):
        value = {}
        for key, item in items:
            require(key not in value, f'duplicate JSON key: {key}')
            value[key] = item
        return value
    return json.loads(raw, object_pairs_hook=pairs)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    require(not out.is_relative_to(repo), 'evidence output must be outside the repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'output already exists')
    spec_raw = read(args.spec)
    spec = parse(spec_raw)
    require(isinstance(spec, dict) and set(spec) ==
            {'schema_version', 'modules', 'mutations', 'positive_checks'},
            'invalid mutation specification fields')
    require(type(spec['schema_version']) is int and spec['schema_version'] == 1,
            'unsupported mutation specification version')
    modules, mutations, positives = spec['modules'], spec['mutations'], spec['positive_checks']
    require(isinstance(modules, list) and modules, 'empty module inventory')
    require(isinstance(mutations, list) and mutations, 'empty mutation inventory')
    require(isinstance(positives, list) and positives, 'empty positive-control inventory')
    require(len(set(modules)) == len(modules), 'duplicate source module')
    require(len(set(positives)) == len(positives), 'duplicate positive control')
    require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                for name in positives), 'invalid positive check name')
    require('DefiKernel.Parallel.Audit' in modules, 'missing Parallel audit root')
    names = [m['name'] for m in mutations]
    require(len(set(names)) == len(names), 'duplicate mutation name')
    for m in mutations:
        require(isinstance(m, dict) and set(m) ==
                {'name', 'module', 'needle', 'replacement', 'required_false'},
                'invalid mutation fields')
        require(re.fullmatch(r'[a-z][a-z0-9-]*', m['name']), 'invalid mutation name')
        require(m['name'] not in {'control', 'lean-version', 'lean-path', 'git-head',
                                  'git-root-input-status'}, 'reserved variant name')
        require(m['module'] in modules, 'mutation module outside inventory')
        require(isinstance(m['needle'], str) and m['needle'], 'empty mutation needle')
        require(isinstance(m['replacement'], str) and m['replacement'] != m['needle'],
                'mutation must actually change the source')
        require(isinstance(m['required_false'], list) and m['required_false'],
                'mutation has no required false observations')
        require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                    for name in m['required_false']), 'invalid required check name')
        require(len(set(m['required_false'])) == len(m['required_false']),
                'duplicate required check')
    # Discover and inline every local import, including split Parallel modules
    # absent from the mutation-site inventory; never load local cached oleans.
    blobs, ordered, visiting = {}, [], set()
    def capture(module):
        require(re.fullmatch(r'DefiKernel\.[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*', module),
                f'invalid scoped module: {module}')
        require(module not in visiting, f'cyclic local dependency: {module}')
        if module in ordered:
            return
        visiting.add(module)
        relative = 'lean/' + module.replace('.', '/') + '.lean'
        path = (repo / relative).resolve()
        require(path.is_relative_to(repo), f'source path escape: {relative}')
        raw = read(path)
        blobs[relative] = raw
        for line in raw.decode().splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported.startswith('DefiKernel.'):
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Parallel(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
            f'invalid scoped module: {module}')
        capture(module)
    for relative in ('lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'):
        blobs[relative] = read(repo / relative)
    sources = {name: sha(raw) for name, raw in blobs.items()}
    script_sha256 = sha(read(Path(__file__)))
    imports, prefixes = [], {}
    for module in ordered:
        source = blobs['lean/' + module.replace('.', '/') + '.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        require(source.count(marker) <= 1, f'{module}: duplicate proof boundary')
        if marker in source and module.startswith('DefiKernel.Parallel.'):
            source, suffix = source.split(marker)
            closure = re.search(r'\n(end DefiKernel\.Parallel(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
            require(closure, f'{module}: proof suffix lacks exact namespace closure')
            namespace = closure.group(1)[4:]
            require(f'namespace {namespace}\n' in source, f'{module}: unmatched namespace')
            source += '\n\n' + closure.group(1) + '\n'
        lines = []
        for line in source.splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported not in ordered and line not in imports:
                    require(not imported.startswith('DefiKernel.'),
                            f'{module}: omitted internal dependency {imported}')
                    imports.append(line)
            else:
                lines.append(line)
        prefixes[module] = '\n'.join(lines) + '\n'
    require(imports, 'no external dependency imports captured')
    variants = {'control': dict(prefixes)}
    for m in mutations:
        source = prefixes[m['module']]
        require(source.count(m['needle']) == 1, f'{m["name"]}: mutation did not apply exactly once')
        variants[m['name']] = {**prefixes, m['module']: source.replace(m['needle'], m['replacement'], 1)}
    out.mkdir(parents=True, exist_ok=False)
    records, results = [], {}

    def run(label, command):
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True, timeout=240)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        records.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(log.encode())})
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        return proc.returncode, log

    status, version = run('lean-version', ['lake', 'env', 'lean', '--version'])
    require(status == 0, 'Lean tool identity unavailable')
    status, executable = run('lean-path', ['lake', 'env', 'which', 'lean'])
    require(status == 0, 'Lean executable path unavailable')
    executable_sha = sha(read(Path(executable.strip())))
    status, head = run('git-head', ['git', 'rev-parse', 'HEAD'])
    require(status == 0, 'Git revision unavailable')
    status, dirty = run('git-root-input-status', ['git', '-C', str(repo), 'status', '--porcelain',
                                                '--untracked-files=all', '--', *blobs])
    require(status == 0, 'Git source status unavailable')
    manifest = {'sources': sources, 'script_sha256': script_sha256,
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Parallel proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'projection_order': ordered, 'module_roots': modules,
                'audit_root': 'DefiKernel.Parallel.Audit', 'python_version': sys.version}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in ordered)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        observations = re.findall(rf'^({CHECK_NAME}): (true|false)$', log, re.MULTILINE)
        # Lean's unused-variable diagnostics contain standalone Hint:/Note:
        # continuation lines. These exact diagnostic prefixes are not observations.
        diagnostic_prefixes = ('Hint: The binding can be removed (if unused) or named ',
                               'Note: This linter can be disabled with ')
        candidates = [line for line in log.splitlines()
                      if re.match(r'^[A-Za-z0-9_.-]+:', line)
                      and not line.startswith(diagnostic_prefixes)]
        require(len(candidates) == len(observations), f'{label}: malformed observation')
        checks = dict(observations)
        require(checks and len(checks) == len(observations), f'{label}: empty/duplicate observations')
        require(set(positives) <= checks.keys(), f'{label}: missing positive controls')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in log.splitlines()
                  if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            expected_error = f'error: Parallel runtime comparisons failed: {len(false)}'
            require(not errors or (false and len(errors) == 1 and errors[0].endswith(expected_error)),
                    'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Parallel runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            check(code != 0 and set(required) <= set(false), f'{label}: required mutation not detected')
        check(all(checks[name] == 'true' for name in positives), f'{label}: positive control failed')
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
    require(manifest['sources_after'] == sources, 'input sources changed during replay')
    require(sha(read(args.spec)) == sha(spec_raw), 'specification changed during replay')
    require(sha(read(Path(__file__))) == script_sha256, 'runner changed during replay')
    manifest['input_sources_unchanged'] = True
    manifest['specification_unchanged'] = True
    manifest['runner_unchanged'] = True
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'DISCRIMINATES: {len(mutations)} mutants and one nonempty unchanged control')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)
