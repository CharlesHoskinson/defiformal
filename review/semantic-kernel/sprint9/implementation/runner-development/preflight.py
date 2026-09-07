#!/usr/bin/env python3
"""Run only the actual driver's source capture/projection/edit preparation block.

This is static preparation, not a mutation execution or a compiler test. The AST
slice ends before output creation and every subprocess/Git/Lean invocation.
"""
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
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--financial-inventory', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    driver = ROOT / 'scripts/check_metatheory_mutations.py'
    spec_path = ROOT / 'mutations/metatheory.json'
    spec = json.loads(spec_path.read_text())
    mapping = json.loads((ROOT / 'review/semantic-kernel/sprint9/planning/runner-literal-adaptation-map.json').read_text())
    adaptation = []
    for entry in mapping['adaptations']:
        old = (ROOT / entry['source']).read_bytes()
        new = (ROOT / entry['planned_destination']).read_bytes()
        assert sha(new) == entry['planned_text_sha256']
        assert new.decode() == re.sub('atomic', lambda m: {'Atomic': 'Metatheory',
                                                          'atomic': 'metatheory'}[m.group()],
                                      old.decode(), flags=re.I)
        adaptation.append({'source': entry['source'], 'destination': entry['planned_destination'],
                           'old_sha256': sha(old), 'new_sha256': sha(new),
                           'exact_planned_text': True})
    imported = importlib.util.spec_from_file_location('metatheory_driver_preflight', driver)
    module = importlib.util.module_from_spec(imported)
    imported.loader.exec_module(module)
    tree = ast.parse(driver.read_text())
    main_node = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'main')
    starts = [i for i, node in enumerate(main_node.body) if isinstance(node, ast.Assign)
              and ast.unparse(node.targets[0]) == '(blobs, ordered, visiting)']
    ends = [i for i, node in enumerate(main_node.body) if isinstance(node, ast.Expr)
            and ast.unparse(node).startswith('out.mkdir(')]
    assert len(starts) == len(ends) == 1 and starts[0] < ends[0]
    statements = main_node.body[starts[0]:ends[0]]
    assert not any(isinstance(n, ast.Attribute) and isinstance(n.value, ast.Name)
                   and n.value.id == 'subprocess' for s in statements for n in ast.walk(s))
    namespace = {**vars(module), 'repo': ROOT, 'modules': spec['modules'],
                 'mutations': spec['mutations']}
    exec(compile(ast.Module(body=statements, type_ignores=[]), str(driver), 'exec'), namespace)
    prefixes, ordered, variants, blobs = (namespace[k] for k in ('prefixes', 'ordered', 'variants', 'blobs'))
    assert len(variants) == 15
    forbidden = [name for name in ordered if (
        (not name.startswith('DefiKernel.Metatheory.') and name.endswith(('Tests', 'Fixtures')))
        or name in {'DefiKernel.Metatheory.ConfigurationFixtures',
                    'DefiKernel.Metatheory.Verify'})]
    assert not forbidden, forbidden
    finance_path = args.financial_inventory.resolve()
    finance = json.loads(finance_path.read_text())
    for path, record in finance['sources'].items():
        assert sha((ROOT / path).read_bytes()) == record['sha256'], path
    inventory = finance['runtime_inventory']
    assert inventory and len(inventory) == len(set(inventory))
    literals = re.findall(r'\("(metatheory\.[a-z0-9_.-]+)"\s*,',
                          '\n'.join(prefixes[name] for name in ordered
                                    if name.startswith('DefiKernel.Metatheory.')))
    assert Counter(literals) == Counter(inventory)
    required = [label for change in spec['mutations'] for label in change['required_false']]
    assert len(required) == len(set(required)) == 14 and set(required) <= set(inventory)
    assert len(spec['positive_checks']) == 2 and set(spec['positive_checks']) <= set(inventory)
    joined = '\n'.join(prefixes.values())
    sites = []
    for i, change in enumerate(spec['mutations'], 1):
        before, after = prefixes[change['module']], variants[change['name']][change['module']]
        assert before.count(change['needle']) == 1
        assert after == before.replace(change['needle'], change['replacement'], 1)
        changed = [name for name in ordered if variants[change['name']][name] != prefixes[name]]
        assert changed == [change['module']]
        sites.append({'id': f'M{i:02}', 'name': change['name'], 'module': change['module'],
                      'target_prefix_needle_count': before.count(change['needle']),
                      'full_projection_needle_count': joined.count(change['needle']),
                      'changed_modules': changed, 'required_false': change['required_false'],
                      'evidence_class': 'executor-routing' if i <= 8 else 'synthetic-observer-sensitivity'})
    assert all(site['full_projection_needle_count'] == 1 for site in sites)
    record = {'status': 'STATIC_PREFLIGHT_PASS_NOT_EXECUTION',
              'utc': datetime.now(timezone.utc).isoformat(),
              'git_head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip(),
              'driver_sha256': sha(driver.read_bytes()), 'spec_sha256': sha(spec_path.read_bytes()),
              'preflight_sha256': sha(Path(__file__).read_bytes()), 'literal_substitutions': 37,
              'adaptations': adaptation, 'actual_driver_ast_slice': {
                  'first_line': statements[0].lineno, 'last_line': statements[-1].end_lineno,
                  'purpose': 'Actual source capture, proof-prefix projection and variant edit preparation only; no runner output directory or subprocess.'},
              'source_hashes': {p: sha(raw) for p, raw in blobs.items()},
              'projection_order': ordered, 'forbidden_runtime_imports': forbidden,
              'financial_inventory_path': str(finance_path.relative_to(ROOT)),
              'financial_inventory_sha256': sha(finance_path.read_bytes()),
              'inventory_count': len(inventory), 'required_false': required,
              'protected_true': spec['positive_checks'], 'sites': sites,
              'compiler_status': 'PENDING_FROZEN_EXECUTION',
              'production_status': 'PENDING_FROZEN_EXECUTION',
              'control_suite_status': 'PENDING_FROZEN_EXECUTION'}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps({'status': record['status'], 'modules': len(ordered),
                      'named_comparisons': len(inventory), 'mutants': len(sites),
                      'report_sha256': sha(args.out.read_bytes())}))


if __name__ == '__main__':
    main()
