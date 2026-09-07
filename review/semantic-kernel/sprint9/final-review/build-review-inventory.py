#!/usr/bin/env python3
"""Project the frozen full inventory for review without changing the complete original."""
import datetime
import hashlib
import json
from pathlib import Path

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[3]
BASE = OUT.parent
FULL = BASE / 'proof-inventory.json'
EXECUTION = BASE / 'proof-inventory-execution.json'

def digest(data):
    return hashlib.sha256(data).hexdigest()

original = FULL.read_bytes()
inventory = json.loads(original)
assert inventory['execution']['status'] == 'PASS'
explicit = [r for r in inventory['theorems'] if r['declaration_origin'] == 'explicit']
generated = [r for r in inventory['theorems'] if r['declaration_origin'] != 'explicit']
assert explicit and generated and inventory['supplemental']

def project(row, retain_statement):
    fields = ['name', 'user_name', 'module', 'source', 'line', 'source_sha256',
              'source_git_blob', 'kind', 'category', 'declaration_origin',
              'is_private_name', 'private', 'axioms']
    result = {key: row[key] for key in fields if key in row}
    encoded = row['statement'].encode()
    result.update(statement_sha256=digest(encoded), statement_bytes=len(encoded))
    if retain_statement:
        result['statement'] = row['statement']
        result['premises'] = row['premises']
    else:
        result['statement_omitted_from_projection'] = True
    return result

projection = {key: inventory[key] for key in [
    'candidate', 'counts', 'validation', 'private_source_name_mapping',
    'source_bindings', 'premise_and_scope_limits']}
projection.update(
    kind='bounded-metatheory-native-review-projection',
    full_inventory={'path': str(FULL.relative_to(ROOT)), 'sha256': digest(original),
                    'bytes': len(original)},
    execution_record={'path': str(EXECUTION.relative_to(ROOT)),
                      'sha256': digest(EXECUTION.read_bytes())},
    projection_rule='Every explicit theorem retains its complete exact elaborated statement, '
        'including all binders and premises. Every generated theorem and supplemental '
        'declaration retains identity, module/source/Git/hash metadata, axioms and the hash '
        'of its complete elaborated type. Only expanded generated/supplemental types and '
        'duplicate source-context prose are omitted here. Complete original inventory and '
        'full source are separate retained artifacts. This is a presentation projection, '
        'not a replacement or independent audit of the complete inventory.',
    evidence_class_note='No explicit negative theorem is declared in these modules. '
        'Actual runtime counterexamples and synthetic observer pairs belong to the separately '
        'executed fixture evidence and scenario map; their Boolean declarations are not '
        'promoted into generic theorems by this inventory.',
    explicit_theorems=[project(row, True) for row in explicit],
    generated_theorems=[project(row, False) for row in generated],
    supplemental=[project(row, False) for row in inventory['supplemental']])

assert len(explicit) == inventory['counts']['explicit_theorems']
for originals, projected in [
    (explicit, projection['explicit_theorems']),
    (generated, projection['generated_theorems']),
    (inventory['supplemental'], projection['supplemental'])]:
    assert len(originals) == len(projected)
    assert {r['name'] for r in originals} == {r['name'] for r in projected}
    for source, target in zip(originals, projected):
        assert target['statement_sha256'] == digest(source['statement'].encode())
        for key in ['name', 'user_name', 'module', 'source', 'source_sha256',
                    'source_git_blob', 'axioms', 'is_private_name']:
            assert source[key] == target[key]
        if 'statement' in target:
            assert source['statement'] == target['statement']

for name, binding in inventory['source_bindings'].items():
    assert digest((ROOT / name).read_bytes()) == binding['sha256'], name
for tool in inventory['execution']['tools']:
    assert digest(Path(tool['path']).read_bytes()) == tool['sha256'], tool['path']
assert digest((BASE / 'proof-inventory-driver.lean').read_bytes()) == \
    inventory['execution']['driver_sha256']
assert digest((BASE / 'build-proof-inventory.py').read_bytes()) == \
    inventory['execution']['builder_sha256']
assert FULL.read_bytes() == original

target = OUT / 'proof-inventory-review.json'
target.write_text(json.dumps(projection, separators=(',', ':'), ensure_ascii=False) + '\n')
checks = {'status': 'PASS', 'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
          'candidate': inventory['candidate'], 'counts': inventory['counts'],
          'full_inventory_sha256': digest(original),
          'projection_sha256': digest(target.read_bytes()), 'projection_bytes': target.stat().st_size,
          'explicit_statements_exact': True, 'all_names_axioms_source_bindings_exact': True,
          'all_statement_hashes_exact': True, 'complete_original_unchanged': True,
          'source_tool_driver_builder_exit_bindings_unchanged': True,
          'builder_sha256': digest(Path(__file__).read_bytes())}
(OUT / 'proof-inventory-projection-checks.json').write_text(json.dumps(checks, indent=2) + '\n')
print(json.dumps(checks, indent=2))
