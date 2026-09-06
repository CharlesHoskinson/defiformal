#!/usr/bin/env python3
"""Bounded source lift: actual checker/types/examples + actual first 14 acceptance theorems.
No repository writes. Control must pass before six single-branch mutants are judged.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess

root = Path('/home/charl/defiformal/lean')
out = Path('/tmp/defiformal-kernel-mutations')
out.mkdir(exist_ok=True)
core = (root / 'DefiKernel/Core.lean').read_text()
examples = (root / 'DefiKernel/Examples.lean').read_text()
acceptance = (root / 'DefiKernel/Acceptance.lean').read_text()
markers = [('/-- The explicit conjunction checked by `check`', core),
           ('/-- Constructor accounting holds', examples),
           ('theorem wrong_feed_refused', acceptance)]
for marker, source in markers:
    assert source.count(marker) == 1, marker
parts = [core.split(markers[0][0])[0] + '\nend DefiKernel\n',
         examples.split(markers[1][0])[0] + '\nend DefiKernel.Examples\n',
         acceptance.split(markers[2][0])[0] + '\nend DefiKernel\n']
imports = sorted(set(line for s in parts for line in s.splitlines()
                     if line.startswith('import ') and 'DefiKernel' not in line))
body = '\n'.join('\n'.join(line for line in s.splitlines()
                           if not line.startswith('import ')) for s in parts)
assert body.count('def check ') == 1
assert len(re.findall(r'^theorem ', parts[2], re.M)) == 14
contracts = re.findall(r'theorem (\w+) :(.*?) := by decide \+kernel', parts[2], re.S)
assert len(contracts) == 14
runtime = '\nnamespace DefiKernel\nopen Examples\n'
for name, proposition in contracts:
    runtime += '#eval IO.println ("MUTATION_RUNTIME ' + name + ' " ++ toString (decide (' + proposition + ')))\n'
runtime += 'end DefiKernel\n'
lift = '\n'.join(imports) + '\n' + body + runtime
mutations = {
    'control': None,
    'guard': ('if t.guard s env = false then', 'if False then'),
    'debit': ('else if ¬ DebitAuthorized p t then', 'else if False then'),
    'supply': ('else if ¬ SupplyAuthorized p t then', 'else if False then'),
    'nonnegative': ('else if ¬ NonnegativeUpdate s t then', 'else if False then'),
    'accounting': ('else if ¬ Accounted t then', 'else if False then'),
    'footprint': ('else if ¬ Local t then', 'else if False then'),
}
results = []
for name, mutation in mutations.items():
    content = lift
    if mutation:
        old, new = mutation
        assert content.count(old) == 1
        content = content.replace(old, new)
    path = out / (name + '.lean')
    path.write_text(content)
    run = subprocess.run(['lake', 'env', 'lean', str(path)], cwd=root,
                         text=True, capture_output=True)
    output = run.stdout + run.stderr
    (out / (name + '.log')).write_text(output)
    errors = re.findall(r'^.*error:.*$', output, re.M)
    row = dict(name=name, source_sha256=hashlib.sha256(content.encode()).hexdigest(),
               command=['lake', 'env', 'lean', str(path)], exit=run.returncode,
               errors=errors, expected_exit=0 if name == 'control' else 1)
    results.append(row)
    print(json.dumps(row), flush=True)
    assert run.returncode == row['expected_exit'], row
    if name != 'control':
        observed = re.findall(r'^MUTATION_RUNTIME (\w+) (true|false)$', output, re.M)
        assert len(observed) == 14, output
        assert any(value == 'false' for _, value in observed), output
        row['runtime_false'] = [name for name, value in observed if value == 'false']
    else:
        observed = re.findall(r'^MUTATION_RUNTIME (\w+) (true|false)$', output, re.M)
        assert len(observed) == 14 and all(value == 'true' for _, value in observed), output
(out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
