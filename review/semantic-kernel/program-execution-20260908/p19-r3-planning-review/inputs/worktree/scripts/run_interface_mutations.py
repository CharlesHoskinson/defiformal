#!/usr/bin/env python3
"""Replay the actual interface Lean implementation under explicit source mutations.

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
import time
from datetime import datetime, timezone


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


def proof_tail_code(source, module):
    """Mask comments and literals for a conservative, bounded command-token guard.

    This is not Lean parsing or macro expansion. In particular an invocation of
    an arbitrary command macro defined before the marker needs source review.
    Masking preserves newlines and cannot join separate tokens accidentally.
    """
    masked = list(source)
    raw_pattern = re.compile(r'r(#+)?"')
    char_pattern = re.compile(r"'(?:\\(?:x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|.)|[^'\\\n])'")
    index = 0
    while index < len(source):
        start = index
        if source.startswith('--', index):
            end = source.find('\n', index)
            index = len(source) if end < 0 else end
        elif source.startswith('/-', index):
            depth = 1
            index += 2
            while index < len(source) and depth:
                if source.startswith('/-', index):
                    depth += 1
                    index += 2
                elif source.startswith('-/', index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
            require(depth == 0, f'{module}: unterminated proof-tail comment')
        else:
            raw = raw_pattern.match(source, index) if (
                index == 0 or not (source[index - 1].isalnum() or source[index - 1] == '_')) else None
            char = char_pattern.match(source, index)
            if raw:
                closing = '"' + (raw.group(1) or '')
                end = source.find(closing, raw.end())
                require(end >= 0, f'{module}: unterminated proof-tail raw string')
                index = end + len(closing)
            elif char:
                index = char.end()
            elif source[index] == '"':
                index += 1
                while index < len(source) and source[index] != '"':
                    index += 2 if source[index] == '\\' else 1
                require(index < len(source), f'{module}: unterminated proof-tail string')
                index += 1
            else:
                index += 1
                continue
        masked[start:index] = ['\n' if c == '\n' else ' ' for c in source[start:index]]
    return ''.join(masked)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--timeout-seconds', type=int, default=600,
                        help='Per Lean/Git command timeout (default: 600 seconds)')
    args = parser.parse_args()
    require(args.timeout_seconds > 0, 'timeout must be positive')
    started = datetime.now(timezone.utc).isoformat()
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
    require('DefiKernel.Interface.Audit' in modules, 'missing Interface audit root')
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
    # Discover and inline every local import, including split Interface modules
    # absent from the mutation-site inventory; never load local cached oleans.
    blobs, ordered, visiting = {}, [], set()
    def capture(module):
        require(re.fullmatch(r'[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*', module),
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
                local_path = repo / 'lean' / (imported.replace('.', '/') + '.lean')
                if imported.startswith('DefiKernel.') or local_path.exists():
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Interface(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
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
        if marker in source and module.startswith('DefiKernel.Interface.'):
            source, suffix = source.split(marker)
            # This bounded projection removes theorem tails only. Silently
            # dropping a late runtime declaration would change the computation.
            tail_code = proof_tail_code(suffix, module)
            # Token matching catches same-line attributes/comments and command
            # declarations. Imported namespaces are deliberately not stripped.
            forbidden = re.search(
                r'\b(?:def|abbrev|opaque|instance|structure|inductive|class|axiom|constant|'
                r'macro|macro_rules|syntax|declare_syntax_cat|elab|elab_rules|'
                r'initialize|builtin_initialize|run_cmd|attribute|notation|infix|infixl|'
                r'infixr|prefix|postfix)\b|#(?:eval|reduce|run)\b', tail_code)
            require(not forbidden,
                    f'{module}: runtime declaration after proof boundary')
            closure = re.search(r'\n(end DefiKernel\.Interface(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
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
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True,
                              timeout=args.timeout_seconds)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        records.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(log.encode()),
                        'elapsed_seconds': round(time.monotonic() - tick, 6),
                        'timeout_seconds': args.timeout_seconds})
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
    git_bindings = {}
    for relative, raw in blobs.items():
        command = ['git', '-C', str(repo), 'rev-parse', f'{head.strip()}:{relative}']
        identity = subprocess.run(command, capture_output=True, timeout=args.timeout_seconds)
        require(identity.returncode == 0, f'input absent from frozen Git revision: {relative}')
        object_id = identity.stdout.decode().strip()
        blob_command = ['git', '-C', str(repo), 'cat-file', 'blob', object_id]
        committed = subprocess.run(blob_command, capture_output=True, timeout=args.timeout_seconds)
        require(committed.returncode == 0, f'Git input object unavailable: {relative}')
        require(committed.stdout == raw, f'input differs from frozen Git revision: {relative}')
        git_bindings[relative] = {'git_object': object_id, 'sha256': sha(committed.stdout),
                                  'identity_command': command, 'blob_command': blob_command,
                                  'identity_exit': identity.returncode, 'blob_exit': committed.returncode}
    manifest = {'sources': sources, 'script_sha256': script_sha256,
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'git_input_bindings': git_bindings, 'started_utc': started,
                'timeout_seconds_per_command': args.timeout_seconds,
                'binding_scope': 'Captured Lean/config inputs equal HEAD Git objects; external spec/driver '
                                 'are byte-hashed and checked for drift, with production freeze binding separate.',
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Interface proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'proof_tail_guard': 'Conservative declaration/command token guard outside nested comments and '
                                    'ordinary/raw strings and character literals; not arbitrary command-macro expansion.',
                'projection_order': ordered, 'module_roots': modules,
                'audit_root': 'DefiKernel.Interface.Audit', 'python_version': sys.version}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    def verify_inputs():
        # Clear the prior variant's success flags before any read can fail.
        manifest.update(input_sources_unchanged=False, specification_unchanged=False,
                        runner_unchanged=False, git_head_unchanged=False)
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
        manifest['spec_sha256_after'] = sha(read(args.spec))
        manifest['script_sha256_after'] = sha(read(Path(__file__)))
        current_head = subprocess.run(['git', '-C', str(repo), 'rev-parse', 'HEAD'],
                                      capture_output=True, text=True, timeout=args.timeout_seconds)
        manifest['git_head_after'] = current_head.stdout.strip()
        manifest['input_sources_unchanged'] = manifest['sources_after'] == sources
        manifest['specification_unchanged'] = manifest['spec_sha256_after'] == sha(spec_raw)
        manifest['runner_unchanged'] = manifest['script_sha256_after'] == script_sha256
        manifest['git_head_unchanged'] = (current_head.returncode == 0 and
                                          manifest['git_head_after'] == head.strip())
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        require(manifest['input_sources_unchanged'], 'input sources changed during replay')
        require(manifest['specification_unchanged'], 'specification changed during replay')
        require(manifest['runner_unchanged'], 'runner changed during replay')
        require(manifest['git_head_unchanged'], 'Git revision changed during replay')

    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in ordered)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        verify_inputs()
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
            expected_error = f'error: Interface runtime comparisons failed: {len(false)}'
            require(not errors or (false and len(errors) == 1 and errors[0].endswith(expected_error)),
                    'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Interface runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            check(code != 0 and set(required) <= set(false), f'{label}: required mutation not detected')
        check(all(checks[name] == 'true' for name in positives), f'{label}: positive control failed')
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    verify_inputs()
    manifest['finished_utc'] = datetime.now(timezone.utc).isoformat()
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
