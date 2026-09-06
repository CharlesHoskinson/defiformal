#!/usr/bin/env python3
"""Exercise source-lift mutations of the bounded check API.

All check-based Acceptance contracts are included; execute and sequence tests are
excluded explicitly. No repository writes. A clean or dirty source snapshot is
identified by input hashes, HEAD, and captured git status, never by HEAD alone.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--repo', type=Path, required=True, help='Repository containing lean/')
parser.add_argument('--output', type=Path, required=True, help='Directory for generated sources/logs')
args = parser.parse_args()
repo = args.repo.resolve()
root = repo / 'lean'
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)

def git(*args):
    return subprocess.check_output(['git', *args], cwd=repo, text=True).rstrip('\n')

def digest(data):
    return hashlib.sha256(data).hexdigest()

input_paths = ['lean/DefiKernel/Core.lean', 'lean/DefiKernel/Examples.lean',
               'lean/DefiKernel/Acceptance.lean']
input_bytes = {name: (repo / name).read_bytes() for name in input_paths}
core, examples, acceptance = [input_bytes[name].decode() for name in input_paths]
status = git('status', '--porcelain=v1', '--untracked-files=all')
source_status = git('status', '--porcelain=v1', '--untracked-files=all', '--', *input_paths)
metadata = {
    'schema': 'defikernel-source-lift-mutations/v2',
    'repo': str(repo),
    'git_head_at_capture': git('rev-parse', 'HEAD'),
    'working_tree_status_at_capture': status,
    'working_tree_dirty_at_capture': bool(status),
    'input_source_status_at_capture': source_status,
    'input_sources_dirty_at_capture': bool(source_status),
    'inputs': {name: digest(data) for name, data in input_bytes.items()},
    'recipe_sha256': digest(Path(__file__).read_bytes()),
    'toolchain': (root / 'lean-toolchain').read_text().strip(),
    'lakefile_sha256': digest((root / 'lakefile.toml').read_bytes()),
    'lake_manifest_sha256': digest((root / 'lake-manifest.json').read_bytes()),
    'scope': 'All check-based Acceptance theorems; no execute or sequence source mutation',
}
markers = [('/-- The explicit conjunction checked by `check`', core),
           ('/-- Constructor accounting holds', examples),
           ('theorem transfer_post :', acceptance)]
for marker, source in markers:
    assert source.count(marker) == 1, marker
parts = [core.split(markers[0][0])[0] + '\nend DefiKernel\n',
         examples.split(markers[1][0])[0] + '\nend DefiKernel.Examples\n',
         acceptance.split(markers[2][0])[0] + '\nend DefiKernel\n']
pattern = r'^theorem (\w+)\s*:(.*?)\s*:=\s*by decide \+kernel'
contracts = re.findall(pattern, parts[2], re.S | re.M)
all_contracts = re.findall(pattern, acceptance, re.S | re.M)
all_check_contracts = [(name, prop) for name, prop in all_contracts
                       if prop.strip().startswith('check ')]
assert contracts == all_check_contracts, 'Some check contracts fall outside the captured prefix'
assert len(contracts) == len(re.findall(r'^theorem ', parts[2], re.M))
assert len(contracts) >= 22, 'Incomplete expected check contract suite'
metadata['contract_names'] = [name for name, _ in contracts]
metadata['contract_count'] = len(contracts)
imports = sorted(set(line for s in parts for line in s.splitlines()
                     if line.startswith('import ') and 'DefiKernel' not in line))
body = '\n'.join('\n'.join(line for line in s.splitlines()
                           if not line.startswith('import ')) for s in parts)
assert body.count('def check ') == 1
runtime = '\nnamespace DefiKernel\nopen Examples\n'
for name, proposition in contracts:
    runtime += '#eval IO.println ("MUTATION_RUNTIME ' + name + ' " ++ toString (decide ('
    runtime += proposition + ')))\n'
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
    'positive_price_only': ('oracle.feed = 7 ∧ 0 < oracle.price ∧', 'oracle.feed = 7 ∧'),
}
metadata['mutations'] = mutations
results = []
for name, mutation in mutations.items():
    content = lift
    if mutation:
        old, new = mutation
        assert content.count(old) == 1
        content = content.replace(old, new)
    path = out / (name + '.lean')
    path.write_text(content)
    command = ['lake', 'env', 'lean', str(path)]
    run = subprocess.run(command, cwd=root, text=True, capture_output=True)
    output = run.stdout + run.stderr
    (out / (name + '.log')).write_text(output)
    observed = re.findall(r'^MUTATION_RUNTIME (\w+) (true|false)$', output, re.M)
    assert [key for key, _ in observed] == metadata['contract_names'], output
    false_names = [key for key, value in observed if value == 'false']
    row = {'name': name, 'source_sha256': digest(content.encode()), 'command': command,
           'exit': run.returncode, 'expected_exit': 0 if name == 'control' else 1,
           'runtime_count': len(observed), 'runtime_false': false_names,
           'errors': re.findall(r'^.*error:.*$', output, re.M)}
    results.append(row)
    print(json.dumps(row), flush=True)
    assert run.returncode == row['expected_exit'], row
    if name == 'control':
        assert not false_names, row
    else:
        assert false_names, 'A compiler error alone is not a mutant discrimination'
    if name == 'positive_price_only':
        assert false_names == ['isolated_zero_price_refused'], row
for name, data in input_bytes.items():
    assert (repo / name).read_bytes() == data, 'Input changed during mutation run: ' + name
metadata['input_hashes_unchanged_after_run'] = True
metadata['results'] = results
(out / 'results.json').write_text(json.dumps(metadata, indent=2) + '\n')
print(f'Control: {len(contracts)}/{len(contracts)} true; source mutants discriminated: 7/7')
