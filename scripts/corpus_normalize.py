#!/usr/bin/env python3
"""Deterministic provisional crosswalk. check is read-only; statuses are 0/1/3.

Source manifests bind bytes, not external truth. Annotation agreement is model
agreement only. This schema version deliberately fixes the 72-to-75 inventory.
"""
import argparse
import csv
import hashlib
import importlib.metadata
import io
import json
from pathlib import Path
import sys

BASE = Path('corpus/normalized')
INPUTS = ('source-manifest.json', 'identity-map.json', 'taxonomy.json', 'annotation-input.json')
LANES = ('lane1-dex-lending-cdp-lsd.json', 'lane2-perps-yield-bridges-intents.json',
         'lane3-rwa-options-stables-prediction.json')
FACETS = ('economic_functions', 'instruments', 'mechanisms', 'execution', 'trust')
SPLITS = {'legacy:lane1:c2:p4': ('v1', 'v2'),
          'legacy:lane3:c0:p0': ('usdy', 'ousg', 'global-markets')}


class ContractError(Exception):
    def __init__(self, message, status=1):
        super().__init__(message)
        self.status = status


def require(condition, message, status=1):
    if not condition:
        raise ContractError(message, status)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def within(repo, relative):
    require(isinstance(relative, str) and relative, 'invalid source path', 3)
    path = Path(relative)
    require(not path.is_absolute() and '..' not in path.parts,
            f'path escape: {relative}', 3)
    target = (repo / path).resolve()
    require(target.is_relative_to(repo), f'path escape: {relative}', 3)
    return target


def read_bytes(path):
    try:
        raw = path.read_bytes()
    except OSError as exc:
        raise ContractError(f'missing/unreadable required input {path}: {exc}', 3) from exc
    require(raw.strip(), f'empty required input: {path}', 3)
    return raw


def parse(raw, path):
    def pairs(items):
        value = {}
        for key, item in items:
            require(key not in value, f'duplicate JSON key {key!r} in {path}')
            value[key] = item
        return value

    def constant(value):
        raise ContractError(f'malformed JSON: nonfinite {value} in {path}')

    try:
        return json.loads(raw, object_pairs_hook=pairs, parse_constant=constant)
    except (ValueError, UnicodeError) as exc:
        raise ContractError(f'malformed JSON in {path}: {exc}') from exc


def unique(items, key, context):
    seen = set()
    for item in items:
        value = item[key]
        require(value not in seen, f'duplicate {key} {value!r} in {context}')
        seen.add(value)
    return seen


def json_bytes(value):
    return (json.dumps(value, indent=2, sort_keys=True, ensure_ascii=False, allow_nan=False) + '\n').encode()


def validate(value, schema, validator, context, definition=None):
    active = schema if definition is None else {'$ref': '#/$defs/' + definition, '$defs': schema['$defs']}
    error = next(validator(active).iter_errors(value), None)
    if error:
        path = '/'.join(map(str, error.absolute_path)) or '<root>'
        message = (f'{error.validator}={error.validator_value}; observed length={len(error.instance)}'
                   if error.validator in ('minItems', 'maxItems') else error.message[:350])
        raise ContractError(f'schema {context}/{path}: {message}')


def source_rows(repo, manifest):
    for entry in manifest['files']:
        within(repo, entry['path'])  # Refuse escapes before comparing inventories.
    expected_paths = {str(Path('corpus50/lanes') / name) for name in LANES}
    paths = unique(manifest['files'], 'path', 'source manifest')
    actual_paths = {str(p.relative_to(repo)) for p in (repo / 'corpus50/lanes').glob('*.json')}
    require(paths == expected_paths and actual_paths <= expected_paths,
            'source inventory: expected exactly all three pinned lanes', 3)
    require(manifest['expected_legacy_rows'] == 72 and manifest['expected_candidate_units'] == 75,
            'source inventory: expected 72 legacy rows and 75 candidate units', 3)
    rows = []
    entries = {e['path']: e for e in manifest['files']}
    for lane, name in enumerate(LANES, 1):
        relative = str(Path('corpus50/lanes') / name)
        entry = entries[relative]
        raw = read_bytes(within(repo, relative))
        require(digest(raw) == entry['sha256'], f'source SHA256 mismatch: {relative}', 3)
        source = parse(raw, relative)
        require(source['source'] == entry['legacy_source_statement'],
                f'source statement mismatch: {relative}', 3)
        start = len(rows)
        require(source['categories'], f'empty source categories: {relative}', 3)
        for ci, category in enumerate(source['categories']):
            require(category['protocols'], f'empty source category {relative}/categories/{ci}', 3)
            for pi, original in enumerate(category['protocols']):
                rows.append({'legacy_id': f'legacy:lane{lane}:c{ci}:p{pi}',
                             'source_path': relative, 'source_sha256': entry['sha256'],
                             'pointer': f'/categories/{ci}/protocols/{pi}',
                             'category': category['category'], 'original': original})
        require(len(rows) - start == entry['legacy_rows'] == (22, 30, 20)[lane-1],
                f'source row count mismatch: {relative}', 3)
    require(len(rows) == 72, 'source coverage: expected 72 rows', 3)
    proposal = manifest['proposal']
    require(digest(read_bytes(within(repo, proposal['path']))) == proposal['sha256'],
            'source SHA256 mismatch: proposal', 3)
    return rows


def expected_outputs(repo):
    try:
        import jsonschema
        require(importlib.metadata.version('jsonschema') == '4.19.2',
                'requires jsonschema==4.19.2; install corpus/normalized/requirements.txt', 3)
    except ImportError as exc:
        raise ContractError('missing jsonschema==4.19.2; install corpus/normalized/requirements.txt', 3) from exc
    schema_path = BASE / 'corpus.schema.json'
    schema_raw = read_bytes(within(repo, str(schema_path)))
    schema = parse(schema_raw, schema_path)
    require(schema.get('$schema') == 'https://json-schema.org/draft/2020-12/schema',
            'invalid JSON Schema: Draft 2020-12 required')
    # The checked-in schema is self-contained; refuse network or filesystem refs.
    def local_refs(node):
        if isinstance(node, dict):
            for key, value in node.items():
                if key in ('$ref', '$dynamicRef'):
                    require(isinstance(value, str) and value.startswith('#/'),
                            'invalid JSON Schema: only local references are allowed')
                    target = schema
                    try:
                        for part in value[2:].split('/'):
                            part = part.replace('~1', '/').replace('~0', '~')
                            target = target[int(part)] if isinstance(target, list) else target[part]
                    except (KeyError, IndexError, TypeError, ValueError) as exc:
                        raise ContractError(f'invalid JSON Schema: unresolved local reference {value}') from exc
                local_refs(value)
        elif isinstance(node, list):
            for value in node:
                local_refs(value)
    local_refs(schema)
    validator = jsonschema.Draft202012Validator
    try:
        validator.check_schema(schema)
    except jsonschema.SchemaError as exc:
        raise ContractError(f'invalid JSON Schema: {exc.message}') from exc
    bindings = [{'path': str(schema_path), 'sha256': digest(schema_raw)}]
    inputs = {}
    for name in INPUTS:
        relative = BASE / 'inputs' / name
        raw = read_bytes(within(repo, str(relative)))
        inputs[name] = parse(raw, relative)
        require(inputs[name]['schema_version'] == '0.1.0', f'unsupported input schema_version: {relative}')
        bindings.append({'path': str(relative), 'sha256': digest(raw)})
    manifest, identities, taxonomy, neutral = (inputs[n] for n in INPUTS)
    rows = source_rows(repo, manifest)
    ids = identities['units']
    unique(ids, 'unit_id', 'identity map')
    require(len(ids) == 75, 'identity unit coverage: expected 75 units')
    source_ids = {r['legacy_id'] for r in rows}
    expected_pairs = {(legacy.replace('legacy:', 'unit:', 1) + (':' + suffix if suffix else ''), legacy)
                      for legacy in source_ids for suffix in SPLITS.get(legacy, ('',))}
    require({(u['unit_id'], u['legacy_id']) for u in ids} == expected_pairs,
            'identity parent-child coverage mismatch: require all 72 sources and exact 75 candidate IDs')
    for unit in ids:
        validate(unit, schema, validator, 'identity map', 'identity')
        split = SPLITS.get(unit['legacy_id'])
        rule = ('explicit-version-split' if unit['legacy_id'] == 'legacy:lane1:c2:p4'
                else 'explicit-product-split') if split else 'identity-candidate'
        require(unit['split_rule'] == rule and unit['normalization_status'] ==
                ('split_candidate' if split else 'needs_identity_review'),
                f'identity split status mismatch: {unit["unit_id"]}')
    for kind in ('organization', 'product'):
        entities = {}
        for unit in ids:
            entity = unit[kind]
            require(entity['id'] not in entities or entities[entity['id']] == entity,
                    f'inconsistent {kind} identity {entity["id"]}')
            entities[entity['id']] = entity
    require(set(taxonomy['facets']) == set(FACETS), 'taxonomy must define the five required facets')
    require(taxonomy['facets'] == {f: schema['$defs']['facets']['properties'][f]['items']['enum'] for f in FACETS},
            'taxonomy labels do not match schema vocabulary')
    by_source = {r['legacy_id']: {k: v for k, v in r.items() if k != 'source_sha256'} for r in rows}
    expected_neutral = {'schema_version': '0.1.0', 'source_commit': manifest['source_commit'],
                        'taxonomy': taxonomy,
                        'units': [{'identity': u, 'source_record': by_source[u['legacy_id']]} for u in ids]}
    require(neutral == expected_neutral, 'neutral annotation input does not match identity map, taxonomy or source rows')
    neutral_hash = next(b['sha256'] for b in bindings if b['path'].endswith('/annotation-input.json'))
    annotations, references = {}, {}
    for annotator in ('a', 'b'):
        relative = str(BASE / 'annotations' / (annotator + '.json'))
        raw = read_bytes(within(repo, relative))
        envelope = parse(raw, relative)
        require(envelope['annotator_id'] == annotator, f'annotator_id mismatch in {relative}')
        require(envelope['input_sha256'] == neutral_hash, f'annotation input hash mismatch: {relative}')
        unit_ids = unique(envelope['annotations'], 'unit_id', relative)
        require(unit_ids == {u['unit_id'] for u in ids}, f'annotation unit coverage mismatch: {relative}')
        for annotation in envelope['annotations']:
            require(set(annotation['facets']) == set(FACETS), f'annotation facet coverage mismatch: {relative}')
            for facet, labels in annotation['facets'].items():
                require(isinstance(labels, list) and all(isinstance(label, str) and label in taxonomy['facets'][facet] for label in labels),
                        f'unknown facet label: {relative}/{annotation["unit_id"]}/{facet}')
        validate(envelope, schema, validator, relative, 'annotation_envelope')
        annotations[annotator] = {a['unit_id']: a for a in envelope['annotations']}
        references[annotator] = {a['unit_id']: {'annotator_id': annotator, 'path': relative,
                                               'pointer': f'/annotations/{i}', 'sha256': digest(raw)}
                                 for i, a in enumerate(envelope['annotations'])}
        bindings.append({'path': relative, 'sha256': digest(raw)})
    units, decisions = [], []
    for identity in ids:
        uid = identity['unit_id']
        facets = {}
        for facet in FACETS:
            a, b = (set(annotations[x][uid]['facets'][facet]) for x in ('a', 'b'))
            retained, unresolved = sorted(a & b), sorted(a ^ b)
            facets[facet] = retained
            decisions.append({'unit_id': uid, 'facet': facet, 'a': sorted(a), 'b': sorted(b),
                              'retained': retained, 'unresolved_labels': unresolved,
                              'rule': 'INTERSECTION_UNRESOLVED' if unresolved else 'AGREE',
                              'status': 'unresolved_difference' if unresolved else 'provisional_agreement'})
        units.append({**identity, 'facets': facets,
                      'annotation_refs': [references[x][uid] for x in ('a', 'b')]})
    corpus = {'schema_version': '0.1.0', 'status': 'provisional_source_bound',
              'input_bindings': sorted(bindings, key=lambda b: b['path']),
              'source_records': rows, 'units': units, 'adjudications': decisions}
    validate(corpus, schema, validator, 'built corpus')
    agreements = sum(d['rule'] == 'AGREE' for d in decisions)
    coverage = {'schema_version': '0.1.0', 'status': 'provisional_source_bound',
                'source_files': 3, 'source_rows': len(rows), 'mapped_source_rows': len(source_ids),
                'candidate_units': len(units), 'facet_decisions': len(decisions),
                'provisional_agreements': agreements, 'unresolved_differences': len(decisions)-agreements,
                'development_units': len(units), 'untouched_holdouts': 0, 'verified_deployments': 0,
                'per_source': [{'path': str(Path('corpus50/lanes') / name),
                                'source_rows': sum(r['source_path'].endswith(name) for r in rows)} for name in LANES],
                'per_facet': {f: {'decisions': len(units),
                                 'provisional_agreements': sum(d['facet'] == f and d['rule'] == 'AGREE' for d in decisions),
                                 'unresolved_differences': sum(d['facet'] == f and d['rule'] != 'AGREE' for d in decisions)} for f in FACETS},
                'limits': ['Historical source claims are not reverified financial facts.',
                           'Model agreement is not semantic accuracy; intersections leave differences unresolved.',
                           'Empty label sets mean not evidenced, not proof of absence.',
                           'All candidates are development cases; deployment identities remain unresolved.']}
    stream = io.StringIO(newline='')
    fields = ['legacy_id', 'unit_id', 'label', 'source_path', 'source_sha256', 'pointer', 'category',
              'organization_id', 'product_id', 'version', 'version_status', 'deployment_status',
              'normalization_status', 'split_rule', 'evaluation_role', 'uncertainty', *FACETS]
    writer = csv.DictWriter(stream, fieldnames=fields, lineterminator='\n')
    writer.writeheader()
    by_id = {r['legacy_id']: r for r in rows}
    for unit in units:
        source = by_id[unit['legacy_id']]
        row = {k: source[k] for k in ('source_path', 'source_sha256', 'pointer', 'category')}
        row.update({k: unit[k] for k in ('legacy_id', 'unit_id', 'label', 'normalization_status', 'split_rule', 'evaluation_role')})
        row.update(organization_id=unit['organization']['id'], product_id=unit['product']['id'],
                   version=unit['version']['value'] or '', version_status=unit['version']['status'],
                   deployment_status=unit['deployment']['status'], uncertainty=json.dumps(unit['uncertainty'], ensure_ascii=False))
        row.update({f: json.dumps(unit['facets'][f], ensure_ascii=False) for f in FACETS})
        writer.writerow(row)
    outputs = {'corpus.json': json_bytes(corpus), 'crosswalk.csv': stream.getvalue().encode(),
               'coverage.json': json_bytes(coverage)}
    return outputs, schema, validator, coverage


def first_difference(actual, expected, path=''):
    if type(actual) is not type(expected):
        return path or '<root>'
    if isinstance(expected, dict):
        if actual.keys() != expected.keys():
            return path + '/keys'
        for key in expected:
            if actual[key] != expected[key]:
                return first_difference(actual[key], expected[key], path + '/' + key)
    elif isinstance(expected, list):
        if len(actual) != len(expected):
            return path + '/length'
        for index, (a, e) in enumerate(zip(actual, expected)):
            if a != e:
                return first_difference(a, e, path + '/' + str(index))
    return path or '<root>'


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    for command in ('build', 'check'):
        child = sub.add_parser(command)
        child.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
        child.add_argument('--out' if command == 'build' else '--data', type=Path, required=command == 'build')
    args = parser.parse_args(argv)
    try:
        repo = args.repo.resolve()
        if args.command == 'build':
            require(not args.out.exists() and not args.out.is_symlink(),
                    f'output directory already exists: {args.out}')
        outputs, schema, validator, coverage = expected_outputs(repo)
        if args.command == 'build':
            args.out.mkdir(parents=True, exist_ok=False)
            for name, raw in outputs.items():
                (args.out / name).write_bytes(raw)
        else:
            data = args.data if args.data is not None else repo / BASE / 'generated'
            for name, expected in outputs.items():
                actual = read_bytes(data / name)
                if name == 'corpus.json':
                    value = parse(actual, data / name)
                    validate(value, schema, validator, 'corpus.json')
                    unique(value['source_records'], 'legacy_id', 'source_records')
                    unique(value['units'], 'unit_id', 'units')
                    unique(value['input_bindings'], 'path', 'input_bindings')
                    pairs = [(d['unit_id'], d['facet']) for d in value['adjudications']]
                    require(len(set(pairs)) == len(pairs), 'duplicate unit/facet adjudication')
                    expected_value = parse(expected, 'expected corpus')
                    require(value == expected_value,
                            'corpus.json deterministic mismatch at ' + first_difference(value, expected_value))
                elif name == 'coverage.json':
                    parse(actual, data / name)
                require(actual == expected, f'{name}: bytes differ from deterministic projection; build into a new directory to inspect')
        print(f'OK {args.command}: 72 source rows; 75 candidate units; 375 facet decisions; '
              f'{coverage["provisional_agreements"]} provisional agreements; '
              f'{coverage["unresolved_differences"]} unresolved differences. No semantic accuracy claim.')
        return 0
    except ContractError as exc:
        print(('BLOCKED' if exc.status == 3 else 'FAIL') + ': ' + str(exc), file=sys.stderr)
        return exc.status
    except (KeyError, TypeError, AttributeError, ValueError) as exc:
        print(f'FAIL: malformed required structure: {type(exc).__name__}: {exc}', file=sys.stderr)
        return 1
    except OSError as exc:
        print(f'BLOCKED: filesystem operation failed: {exc}', file=sys.stderr)
        return 3


if __name__ == '__main__':
    sys.exit(main())
