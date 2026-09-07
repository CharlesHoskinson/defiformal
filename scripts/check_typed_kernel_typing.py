#!/usr/bin/env python3
"""Compile one positive and three deliberately ill-typed expressions with real Lean.

These are typing refusals, not executed financial counterexamples. Exit 0 means
all four expected outcomes were observed; 1 means a negative term was accepted;
3 means evidence was unavailable or failed for another reason.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    if out.is_relative_to(repo) or out.exists():
        raise RuntimeError('output must be new and outside the repository')
    prefix = '''import DefiKernel.Typed.Expr
open DefiKernel.Typed
abbrev E := Expr Bool Bool Bool []
'''
    fixtures = {
        'positive': '''def accepted : E (.amount false) :=
  .binary (.convert true false) (.lit 3) (.lit 2)
#eval IO.println (if accepted.eval ⟨⟨fun _ => 0, by intro c; decide⟩,
  (fun _ => none), false, [], .nil, 0⟩ == .ok 6 then "typing_positive: true"
  else "typing_positive: false")
''',
        'mixed-assets': '''def rejected : E (.amount false) :=
  .binary (.add (.amount false)) (.lit 1)
    (.lit 2 : E (.amount true))
''',
        'reversed-price': '''def rejected : E (.amount false) :=
  .binary (.convert true false) (.lit 3)
    (.lit 2 : E (.price false true))
''',
        'implicit-debt-conversion': '''def rejected : E (.amount false) :=
  .binary (.scale (.amount true)) (.lit 1) (.lit 2)
''',
    }
    out.mkdir(parents=True)
    def digest(path):
        return hashlib.sha256(path.read_bytes()).hexdigest()
    paths = [repo / ('lean/DefiKernel/Typed/' + n + '.lean') for n in ['Types', 'Expr']]
    paths += [repo / ('lean/' + n) for n in ['lean-toolchain', 'lakefile.toml', 'lake-manifest.json']]
    before = {str(p.relative_to(repo)): digest(p) for p in paths}
    results = {'script_sha256': digest(Path(__file__)), 'sources': before, 'runs': {}}
    results['git_head'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=repo, text=True).strip()
    results['lean_version'] = subprocess.check_output(['lake', 'env', 'lean', '--version'],
                                                     cwd=repo / 'lean', text=True).strip()
    executable = subprocess.check_output(['lake', 'env', 'which', 'lean'], cwd=repo / 'lean', text=True).strip()
    results['lean_executable_sha256'] = digest(Path(executable))
    for name, body in fixtures.items():
        path = out / (name + '.lean')
        path.write_text(prefix + body)
        command = ['lake', 'env', 'lean', str(path)]
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True, timeout=120)
        log = proc.stdout + proc.stderr
        (out / (name + '.log')).write_text(log)
        results['runs'][name] = {'command': command, 'exit': proc.returncode,
                                'fixture_sha256': digest(path),
                                'log_sha256': digest(out / (name + '.log'))}
        (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
        if name == 'positive':
            if (proc.returncode != 0 or 'typing_positive: true' not in log or
                    re.search(r': error(?:\([^)]*\))?:', log)):
                raise RuntimeError('positive typing control failed')
        else:
            assert proc.returncode != 0, f'{name}: deliberately ill-typed expression accepted'
            if proc.returncode != 1 or not any(x in log.lower() for x in
                                             ['type mismatch', 'application type mismatch']):
                raise RuntimeError(f'{name}: failure was not the expected typing refusal')
        print(f'{name}: expected outcome observed (exit {proc.returncode})')
    after = {str(p.relative_to(repo)): digest(p) for p in paths}
    if after != before:
        raise RuntimeError('source changed during typing checks')
    results['input_sources_unchanged'] = True
    results['scope'] = 'One executed positive and three compiler-rejected unit mismatches; no financial counterexample claim.'
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)
