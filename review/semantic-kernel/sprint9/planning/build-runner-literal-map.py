#!/usr/bin/env python3
"""Reproduce the planning-only, exhaustive predecessor literal adaptation map.

Reads frozen Git objects and verifies current input bytes. Does not import or
execute either runner, create adapted scripts, or execute any Lean control.
"""
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess


HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
ACCEPTED = '99e2e2c61a1a3c5249026921efdc6cd41ac8f21d'
PLANNING = '47cd83136ab69b0975594a77c519f6611f6fb555'
FILES = ('scripts/check_atomic_mutations.py', 'scripts/test_atomic_mutation_runner.py')
SPEC = 'review/semantic-kernel/sprint8/mutation-spec.json'
PATTERN = re.compile('atomic', re.IGNORECASE)
REPLACEMENTS = {'Atomic': 'Metatheory', 'atomic': 'metatheory'}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=REPO)


def binding(path):
    data = (REPO / path).read_bytes()
    revisions = {}
    for revision in (ACCEPTED, PLANNING):
        frozen = git('show', f'{revision}:{path}')
        assert data == frozen, (path, revision, 'input bytes differ')
        revisions[revision] = {
            'git_blob': git('rev-parse', f'{revision}:{path}').decode().strip(),
            'sha256': sha(frozen), 'bytes': len(frozen),
        }
    return data, {'path': path, 'sha256': sha(data), 'bytes': len(data),
                  'current_bytes_equal_both_revisions': True, 'revisions': revisions}


def reason(line):
    if 'discovered-atomic-dependency' in line:
        return ('case-identity', 'Rename both the case declaration and exact-observation verification tuple member.')
    if 'runtime comparison' in line or 'missing Atomic audit root' in line:
        return ('diagnostic-protocol', 'Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.')
    if "'scope':" in line:
        return ('manifest-description', 'Describe only Metatheory proof tails as excluded; imported predecessor proofs remain retained.')
    if "'audit_root':" in line:
        return ('manifest-audit-root', 'Bind the new Metatheory Audit module in the manifest.')
    if 'check_atomic_mutations.py' in line or 'DefiKernel/Atomic' in line:
        return ('filesystem-path', 'Point the new harness to its new driver or Metatheory fixture source path.')
    if 'DefiKernel' in line:
        return ('namespace-or-projection-scope', 'Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.')
    return ('documentation', 'Describe the new Metatheory implementation and its local modules.')


def controls(source):
    tree = ast.parse(source)
    function = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'cases')
    expression = next(n.value for n in function.body if isinstance(n, ast.Return))
    assert isinstance(expression, ast.List)
    result = []
    for entry in expression.elts:
        fields = {k.value: v for k, v in zip(entry.keys, entry.values) if isinstance(k, ast.Constant)}
        result.append({'name': ast.literal_eval(fields['name']), 'exit': ast.literal_eval(fields['exit'])})
    assert len(result) == len({c['name'] for c in result}) == 65
    assert Counter(c['exit'] for c in result) == {0: 10, 1: 5, 3: 50}
    return result


def main():
    occurrences, inputs, adaptations, sources = [], [], [], {}
    for path in FILES:
        data, bound = binding(path)
        inputs.append(bound)
        source = data.decode('utf-8')
        sources[path] = source
        adapted = PATTERN.sub(lambda m: REPLACEMENTS[m.group()], source)
        ast.parse(source)
        ast.parse(adapted)
        assert not PATTERN.search(adapted)
        for match in PATTERN.finditer(source):
            start = source.rfind('\n', 0, match.start()) + 1
            end = source.find('\n', match.end())
            end = len(source) if end < 0 else end
            line = source[start:end]
            category, rationale = reason(line)
            occurrences.append({
                'id': f'L{len(occurrences) + 1:03}', 'file': path,
                'source_sha256': bound['sha256'],
                'line': source.count('\n', 0, match.start()) + 1,
                'column': match.start() - start + 1,
                'byte_column': len(source[start:match.start()].encode()) + 1,
                'character_offset': match.start(), 'byte_offset': len(source[:match.start()].encode()),
                'matched_literal': match.group(), 'source_line': line,
                'source_line_sha256': sha(line.encode()), 'decision': 'rename',
                'replacement': REPLACEMENTS[match.group()], 'category': category, 'rationale': rationale,
                'replacement_line': PATTERN.sub(lambda m: REPLACEMENTS[m.group()], line),
            })
        adaptations.append({'source': path, 'planned_destination': PATTERN.sub('metatheory', path),
                            'planned_text_sha256': sha(adapted.encode()),
                            'planned_text_python_ast_parse': 'PASS',
                            'remaining_case_insensitive_atomic_occurrences': 0,
                            'adapted_script_written_or_executed': False})
    spec_data, spec_bound = binding(SPEC)
    old_spec = json.loads(spec_data)
    assert old_spec['schema_version'] == 1 and len(old_spec['mutations']) == 18
    inherited = controls(sources[FILES[1]])
    planned = [{**c, 'name': PATTERN.sub('metatheory', c['name'])} for c in inherited]
    required = {
        'lowercase_case_declaration_and_verification_tuple': ('discovered-atomic-dependency', 2),
        'exact_error_one_literal': ('error: Atomic runtime comparisons failed: 1', 1),
        'manifest_audit_root': ("'audit_root': 'DefiKernel.Atomic.Audit'", 1),
        'manifest_scope_description': ('Atomic proof tails excluded', 1),
        'default_driver_path': ('scripts/check_atomic_mutations.py', 1),
        'extra_source_path': ('lean/DefiKernel/Atomic/SplitComputation.lean', 1),
    }
    required_coverage = {}
    for label, (needle, expected) in required.items():
        found = [o['id'] for o in occurrences if needle in o['source_line']]
        assert len(found) == expected, (label, found)
        required_coverage[label] = {'source_literal': needle, 'occurrence_ids': found,
                                    'expected_occurrences': expected, 'status': 'PASS'}
    assert len(occurrences) == sum(len(list(PATTERN.finditer(s))) for s in sources.values())
    result = {
        'schema_version': 1, 'status': 'AUTHOR_PLANNING_INVENTORY_ONLY',
        'scope': 'Exhaustive case-insensitive literal Atomic substrings in both accepted predecessor scripts. No runtime implementation, test execution, or planning acceptance.',
        'accepted_predecessor_revision': ACCEPTED, 'planning_revision': PLANNING,
        'generator': {'path': str(Path(__file__).resolve().relative_to(REPO)),
                      'sha256': sha(Path(__file__).read_bytes())},
        'reproduce_command': 'python3 review/semantic-kernel/sprint9/planning/build-runner-literal-map.py',
        'position_convention': 'One-based line/Unicode and UTF-8 byte columns; zero-based offsets. Source-line hashes exclude newline. Each substring match gets a separate record, including two matches on driver line 139.',
        'replacement_policy': REPLACEMENTS, 'keep_decisions': [],
        'keep_rationale': 'No literal in these two scripts identifies historical evidence that the new driver must retain; all identify the old namespace, protocol, fixture, path, case, or description.',
        'inputs': inputs, 'adaptations': adaptations,
        'historical_spec': {**spec_bound, 'schema_version': old_spec['schema_version'],
                            'mutation_count': len(old_spec['mutations']), 'modules': old_spec['modules'],
                            'decision': 'keep historical file and bytes unchanged; use as schema predecessor only',
                            'planned_new_spec_path': 'mutations/metatheory.json',
                            'new_spec_requires_fourteen_actual_Metatheory_edits': True},
        'counts': {'total': len(occurrences), 'rename': len(occurrences), 'keep': 0,
                   'by_file': dict(Counter(o['file'] for o in occurrences)),
                   'by_literal': dict(Counter(o['matched_literal'] for o in occurrences))},
        'required_coverage': required_coverage, 'occurrences': occurrences,
        'control_inventory': {'method': 'Read cases() list via Python AST; no import or execution.',
                              'count': 65, 'exit_counts': {'0': 10, '1': 5, '3': 50},
                              'predecessor': inherited, 'planned': planned,
                              'changed_names': [{'old': a['name'], 'new': b['name']}
                                                for a, b in zip(inherited, planned) if a != b]},
    }
    output = HERE / 'runner-literal-adaptation-map.json'
    output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps({'output': str(output.relative_to(REPO)), 'sha256': sha(output.read_bytes()),
                      'counts': result['counts'], 'controls': 65}, sort_keys=True))


if __name__ == '__main__':
    main()
