#!/usr/bin/env python3
"""Execute the actual driver's static capture/edit preparation, never its subprocess block."""
import argparse
import ast
from collections import Counter
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--financial-inventory', required=True, type=Path)
    args = parser.parse_args()
    assert not args.out.exists()
    driver = ROOT / 'scripts/run_interface_mutations.py'
    spec_path = ROOT / 'mutations/interface.json'
    spec = json.loads(spec_path.read_text())
    bound = json.loads((ROOT / 'review/semantic-kernel/sprint10/planning/r2-preparation/runner-adaptation.json').read_text())
    adaptations = []
    for old, new in [('scripts/check_metatheory_mutations.py', 'scripts/run_interface_mutations.py'),
                     ('scripts/test_metatheory_mutation_runner.py', 'scripts/test_interface_mutation_runner.py')]:
        old_raw = (ROOT / old).read_bytes()
        assert sha(old_raw) == bound['source_hashes'][old]
        expected = old_raw.decode().replace('check_metatheory_mutations.py', 'run_interface_mutations.py').replace('Metatheory', 'Interface').replace('metatheory', 'interface')
        actual = (ROOT / new).read_bytes()
        assert actual.decode() == expected
        adaptations.append({'old': old, 'new': new, 'old_sha256': sha(old_raw), 'new_sha256': sha(actual)})
    imported = importlib.util.spec_from_file_location('interface_driver_preflight', driver)
    module = importlib.util.module_from_spec(imported)
    imported.loader.exec_module(module)
    tree = ast.parse(driver.read_text())
    entry = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'main')
    starts = [i for i, n in enumerate(entry.body) if isinstance(n, ast.Assign) and ast.unparse(n.targets[0]) == '(blobs, ordered, visiting)']
    ends = [i for i, n in enumerate(entry.body) if isinstance(n, ast.Expr) and ast.unparse(n).startswith('out.mkdir(')]
    assert len(starts) == len(ends) == 1 and starts[0] < ends[0]
    statements = entry.body[starts[0]:ends[0]]
    assert not any(isinstance(n, ast.Attribute) and isinstance(n.value, ast.Name) and n.value.id == 'subprocess' for s in statements for n in ast.walk(s))
    ns = {**vars(module), 'repo': ROOT, 'modules': spec['modules'], 'mutations': spec['mutations']}
    exec(compile(ast.Module(body=statements, type_ignores=[]), str(driver), 'exec'), ns)
    prefixes, ordered, variants, blobs = (ns[k] for k in ('prefixes', 'ordered', 'variants', 'blobs'))
    assert len(variants) == 15
    forbidden = [m for m in ordered if (not m.startswith('DefiKernel.Interface.') and m.endswith(('Tests', 'Audit', 'Verify', 'Fixtures'))) or m in ['DefiKernel.Interface.Accounting','DefiKernel.Interface.Preservation','DefiKernel.Interface.BindingPreservation','DefiKernel.Interface.Verify']]
    assert not forbidden, forbidden
    finance_path = args.financial_inventory.resolve()
    finance = json.loads(finance_path.read_text())
    for path, record in finance['sources'].items():
        assert sha((ROOT / path).read_bytes()) == (record if isinstance(record, str) else record['sha256']), path
    inventory = finance['runtime_inventory']
    assert inventory and len(set(inventory)) == len(inventory)
    literals = re.findall(r'\("(interface\.[a-z0-9_.-]+)"\s*,', '\n'.join(prefixes[m] for m in ordered if m.startswith('DefiKernel.Interface.')))
    assert Counter(literals) == Counter(inventory)
    required = [name for m in spec['mutations'] for name in m['required_false']]
    assert len(required) == 14 and set(required) <= set(inventory)
    assert len(spec['positive_checks']) == 2 and set(spec['positive_checks']) <= set(inventory)
    matrix = json.loads((Path(__file__).parent / 'mutation-sites-development.json').read_text())['mutations']
    assert all(row['sibling'] in inventory for row in matrix)
    sites = []
    joined = '\n'.join(prefixes.values())
    for i, mutation in enumerate(spec['mutations'], 1):
        before = prefixes[mutation['module']]
        after = variants[mutation['name']][mutation['module']]
        assert before.count(mutation['needle']) == joined.count(mutation['needle']) == 1
        assert after == before.replace(mutation['needle'], mutation['replacement'], 1)
        changed = [m for m in ordered if variants[mutation['name']][m] != prefixes[m]]
        assert changed == [mutation['module']]
        sites.append({'id': f'M{i:02}', 'name': mutation['name'], 'changed_modules': changed, 'full_projection_needle_count': 1, 'required_false': mutation['required_false'], 'sibling': matrix[i-1]['sibling']})
    record = {'status': 'STATIC_PREFLIGHT_PASS_NOT_EXECUTION', 'utc': datetime.now(timezone.utc).isoformat(), 'git_head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip(), 'source_context': 'worktree preparation; final source Git binding requires production freeze', 'driver_sha256': sha(driver.read_bytes()), 'spec_sha256': sha(spec_path.read_bytes()), 'preflight_sha256': sha(Path(__file__).read_bytes()), 'adaptations': adaptations, 'actual_driver_ast_slice': {'first_line': statements[0].lineno, 'last_line': statements[-1].end_lineno, 'scope': 'actual source capture/proof-prefix/edit preparation only'}, 'source_hashes': {p:sha(b) for p,b in blobs.items()}, 'projection_order': ordered, 'forbidden_runtime_imports': forbidden, 'financial_inventory_path': str(finance_path.relative_to(ROOT)), 'financial_inventory_sha256': sha(finance_path.read_bytes()), 'inventory_count': len(inventory), 'required_false': required, 'distinct_designated_count': len(set(required)), 'protected_true': spec['positive_checks'], 'sites': sites, 'production_status': 'PENDING_FROZEN_EXECUTION', 'full_control_suite_status': 'PENDING_FROZEN_EXECUTION'}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps({'status':record['status'],'modules':len(ordered),'comparisons':len(inventory),'mutants':len(sites),'distinct_designated':len(set(required))}))


if __name__ == '__main__':
    main()
