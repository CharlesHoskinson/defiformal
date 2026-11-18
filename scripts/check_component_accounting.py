#!/usr/bin/env python3
"""Check a reviewed physical-line classification; emit counts without writing files.

Exit 0: nonempty accounting is consistent. Exit 1: classification/effort claim
is inconsistent. Exit 3: source/evidence is unavailable, changed, or scope empty.
A pass establishes neither semantic classification correctness nor I.3 completion.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROLES = {'model', 'specification', 'guidance', 'excluded', 'blank'}


class Blocked(RuntimeError):
    pass


class Invalid(RuntimeError):
    pass


def bound_source(root, entry):
    relative = Path(entry['path'])
    path = (root / relative).resolve()
    if relative.is_absolute() or not path.is_relative_to(root):
        raise Invalid('source path escapes root')
    data = path.read_bytes()
    if hashlib.sha256(data).hexdigest() != entry['sha256']:
        raise Blocked('source/evidence hash drift: ' + entry['path'])
    return data.decode('utf-8').splitlines()


def check(root, manifest):
    if manifest['schema_version'] != 1:
        raise Invalid('unsupported manifest schema')
    required, components = manifest['required_components'], manifest['components']
    ids = [component['id'] for component in components]
    if not required or not components or len(set(required)) != len(required) or set(ids) != set(required):
        raise Blocked('empty or incomplete component scope')
    if len(set(ids)) != len(ids):
        raise Invalid('duplicate component')
    if manifest['agenda_I_3_status'] != 'unmet':
        raise Invalid('this baseline cannot claim I.3 completion')
    report, paths = [], set()
    for component in components:
        if component['path'] in paths:
            raise Invalid('component source counted twice')
        paths.add(component['path'])
        for field in ['authoring_effort_seconds', 'human_authoring_effort_seconds']:
            if component[field] is not None:
                raise Invalid('unavailable historical effort must remain null, not a measured value')
        lines = bound_source(root, component)
        if not lines or len(lines) != component['physical_lines']:
            raise Blocked('empty or changed physical line scope')
        assigned = [None] * len(lines)
        for start, end, role in component['ranges']:
            if type(start) is not int or type(end) is not int or not 1 <= start <= end <= len(lines):
                raise Invalid('invalid inclusive line range')
            if role not in ROLES:
                raise Invalid('unknown line role: ' + str(role))
            for index in range(start - 1, end):
                if assigned[index] is not None:
                    raise Invalid('overlapping classification at ' + component['path'] + ':' + str(index + 1))
                assigned[index] = role
        if any(role is None for role in assigned):
            raise Invalid('omitted classification in ' + component['path'])
        for line, role in zip(lines, assigned):
            if (not line.strip()) != (role == 'blank'):
                raise Invalid('blank/nonblank classification mismatch')
        counts = {role: assigned.count(role) for role in sorted(ROLES)}
        if not sum(counts[role] for role in ['model', 'specification', 'guidance']):
            raise Blocked('empty measured role scope')
        report.append(dict(id=component['id'], path=component['path'], physical_lines=len(lines),
                           counts=counts, authoring_effort_seconds=None,
                           human_authoring_effort_seconds=None))
    support_paths = set()
    for entry in manifest['support_files']:
        if entry['path'] in paths or entry['path'] in support_paths:
            raise Invalid('duplicate or double-charged support source')
        support_paths.add(entry['path'])
        lines = bound_source(root, entry)
        if len(lines) != entry['physical_lines']:
            raise Blocked('changed support line scope')
        if not entry['used_by'] or not set(entry['used_by']) <= set(ids):
            raise Invalid('invalid support consumer scope')
    for entry in manifest['evidence_files']:
        bound_source(root, entry)
    return dict(status='consistent', source_revision=manifest['source_revision'], components=report,
                support_files_checked=len(support_paths), support_allocation='not charged to adapters',
                evidence_files_checked=len(manifest['evidence_files']), agenda_I_3_status='unmet',
                interpretation='Accounting consistency only; manually reviewed role assignments and unavailable effort do not establish I.3 completion.')


def main():
    repo = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=repo)
    parser.add_argument('--manifest', type=Path, default=repo / 'benchmarks/component-accounting/manifest.json')
    args = parser.parse_args()
    try:
        result = check(args.root.resolve(), json.loads(args.manifest.read_text()))
        print(json.dumps(result, indent=2))
        return 0
    except (Blocked, OSError, UnicodeError) as error:
        print('BLOCKED: ' + str(error), file=sys.stderr)
        return 3
    except (Invalid, ValueError, KeyError, TypeError) as error:
        print('FAILED: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
