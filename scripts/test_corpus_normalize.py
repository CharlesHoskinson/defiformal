#!/usr/bin/env python3
"""Real CLI controls and corruptions, isolated from live annotations and outputs."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
SCRIPT = REPO / 'scripts/corpus_normalize.py'
BASE = Path('corpus/normalized')


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n')


class CorpusCLI(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='corpus-cli-')
        self.addCleanup(self.tmp.cleanup)
        self.repo = Path(self.tmp.name)
        for relative in ('corpus50/lanes', str(BASE / 'inputs')):
            shutil.copytree(REPO / relative, self.repo / relative)
        for relative in (BASE / 'corpus.schema.json', Path('docs/research/2026-09-06-defi-source-plan.md')):
            if (REPO / relative).exists():
                (self.repo / relative).parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(REPO / relative, self.repo / relative)
        neutral = self.repo / BASE / 'inputs/annotation-input.json'
        data = json.loads(neutral.read_text())
        for annotator in ('a', 'b'):
            rows = [{'unit_id': u['identity']['unit_id'],
                     'facets': {f: [] for f in data['taxonomy']['facets']},
                     'rationale': 'Synthetic CLI fixture; no empirical coding claim.',
                     'uncertainty': ['Synthetic evidence only.']} for u in data['units']]
            rows[0]['facets']['economic_functions'] = ['exchange']
            rows[0]['facets']['mechanisms'] = (['amm', 'auction'] if annotator == 'a'
                                                else ['auction', 'routing'])
            rows[1]['facets']['mechanisms'] = (['amm', 'routing'] if annotator == 'a'
                                                else ['routing', 'amm'])
            write(self.repo / BASE / f'annotations/{annotator}.json', {
                'schema_version': '0.1.0', 'annotator_id': annotator,
                'model_requested': 'gpt-6-astra',
                'input_sha256': hashlib.sha256(neutral.read_bytes()).hexdigest(),
                'annotations': rows})
        self.out = self.repo / BASE / 'generated'

    def cli(self, command, status=0, diagnostic='', out=None):
        args = [sys.executable, str(SCRIPT), command, '--repo', str(self.repo)]
        if command == 'build':
            args += ['--out', str(out or self.out)]
        elif out is not None:
            args += ['--data', str(out)]
        result = subprocess.run(args, capture_output=True, text=True)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, status, output)
        self.assertIn(diagnostic, output)
        if command == 'build' and status == 3:
            self.assertFalse((out or self.out).exists(), 'blocked build created output directory')
        print(f'{self._testMethodName}: exit={status}: {output.strip()}', flush=True)
        return output

    def mutate(self, relative, change):
        path = self.repo / relative
        data = json.loads(path.read_text())
        change(data)
        write(path, data)

    def snapshot(self):
        return {str(p.relative_to(self.repo)): (p.read_bytes(), p.stat().st_mtime_ns)
                for p in self.repo.rglob('*') if p.is_file()}

    def test_positive_reproducible_read_only(self):
        self.cli('build', diagnostic='72 source rows; 75 candidate units; 375 facet decisions')
        before = self.snapshot()
        self.cli('check', diagnostic='374 provisional agreements; 1 unresolved differences')
        self.assertEqual(before, self.snapshot())
        second = self.repo / 'second'
        self.cli('build', out=second)
        self.cli('check', out=second)
        self.assertEqual({p.name: p.read_bytes() for p in self.out.iterdir()},
                         {p.name: p.read_bytes() for p in second.iterdir()})
        self.cli('build', 1, 'output directory already exists')
        corpus = json.loads((self.out / 'corpus.json').read_text())
        self.assertEqual(len(corpus['source_records']), 72)
        self.assertEqual(len(corpus['units']), 75)
        self.assertEqual(len(corpus['adjudications']), 375)
        self.assertEqual(len(corpus['input_bindings']), 7)
        self.assertEqual({b['path'] for b in corpus['input_bindings']}, {
            'corpus/normalized/corpus.schema.json',
            'corpus/normalized/inputs/source-manifest.json',
            'corpus/normalized/inputs/identity-map.json',
            'corpus/normalized/inputs/taxonomy.json',
            'corpus/normalized/inputs/annotation-input.json',
            'corpus/normalized/annotations/a.json',
            'corpus/normalized/annotations/b.json'})
        self.assertEqual(corpus['units'][0]['facets']['economic_functions'], ['exchange'])
        self.assertEqual(corpus['units'][0]['facets']['mechanisms'], ['auction'])
        decisions = {(d['unit_id'], d['facet']): d for d in corpus['adjudications']}
        self.assertEqual(decisions[('unit:lane1:c0:p0', 'mechanisms')], {
            'unit_id': 'unit:lane1:c0:p0', 'facet': 'mechanisms',
            'a': ['amm', 'auction'], 'b': ['auction', 'routing'],
            'retained': ['auction'], 'unresolved_labels': ['amm', 'routing'],
            'rule': 'INTERSECTION_UNRESOLVED', 'status': 'unresolved_difference'})
        self.assertEqual(decisions[('unit:lane1:c0:p1', 'mechanisms')], {
            'unit_id': 'unit:lane1:c0:p1', 'facet': 'mechanisms',
            'a': ['amm', 'routing'], 'b': ['amm', 'routing'],
            'retained': ['amm', 'routing'], 'unresolved_labels': [],
            'rule': 'AGREE', 'status': 'provisional_agreement'})

    def test_coverage_distinguishes_empty_agreements(self):
        self.cli('build')
        coverage = json.loads((self.out / 'coverage.json').read_text())
        self.assertEqual(coverage['provisional_agreements'], 374)
        self.assertEqual(coverage['unresolved_differences'], 1)
        self.assertIn('agreed_empty', coverage)
        self.assertEqual(coverage['agreed_empty'], 372)
        self.assertEqual(coverage['agreed_nonempty'], 2)
        self.assertEqual(coverage['per_facet'], {
            'economic_functions': {'decisions': 75, 'provisional_agreements': 75,
                                   'agreed_empty': 74, 'agreed_nonempty': 1, 'unresolved_differences': 0},
            'mechanisms': {'decisions': 75, 'provisional_agreements': 74,
                           'agreed_empty': 73, 'agreed_nonempty': 1, 'unresolved_differences': 1},
            **{f: {'decisions': 75, 'provisional_agreements': 75,
                   'agreed_empty': 75, 'agreed_nonempty': 0, 'unresolved_differences': 0}
               for f in ('instruments', 'execution', 'trust')}})
        self.assertIn('Mutual empty agreement is not positive facet evidence.', coverage['limits'])

    def test_derived_corruptions(self):
        self.cli('build')
        good = (self.out / 'corpus.json').read_bytes()
        cases = [
            ('dropped source', lambda d: d['source_records'].pop(), 'schema corpus.json/source_records: minItems=72; observed length=71'),
            ('omitted unit', lambda d: d['units'].pop(), 'schema corpus.json/units: minItems=75; observed length=74'),
            ('duplicate unit', lambda d: d['units'].__setitem__(1, d['units'][0]), 'duplicate unit_id'),
            ('duplicate source', lambda d: d['source_records'].__setitem__(1, d['source_records'][0]), 'duplicate legacy_id'),
            ('wrong source mapping', lambda d: d['units'][0].__setitem__('legacy_id', d['units'][1]['legacy_id']), 'deterministic mismatch at /units/0/legacy_id'),
            ('wrong provenance hash', lambda d: d['source_records'][0].__setitem__('source_sha256', '0'*64), 'deterministic mismatch at /source_records/0/source_sha256'),
            ('modified residue', lambda d: d['source_records'][0]['original']['residue'].append('changed'), 'deterministic mismatch at /source_records/0/original/residue/length'),
            ('holdout promotion', lambda d: d['units'][0].__setitem__('evaluation_role', 'holdout'), "schema corpus.json/units/0/evaluation_role: 'development' was expected"),
            ('unknown facet', lambda d: d['units'][0]['facets']['trust'].append('imaginary'), "schema corpus.json/units/0/facets/trust/0: 'imaginary' is not one of"),
            ('false agreement', lambda d: next(a for a in d['adjudications'] if a['rule'] == 'INTERSECTION_UNRESOLVED').__setitem__('rule', 'AGREE'), "schema corpus.json/adjudications/2/status: 'provisional_agreement' was expected"),
            ('binding drift', lambda d: d['input_bindings'][0].__setitem__('sha256', '0'*64), 'deterministic mismatch at /input_bindings/0/sha256'),
            ('annotation reference drift', lambda d: d['units'][0]['annotation_refs'][0].__setitem__('pointer', '/annotations/1'), 'deterministic mismatch at /units/0/annotation_refs/0/pointer'),
            ('duplicate decision', lambda d: d['adjudications'].__setitem__(1, d['adjudications'][0]), 'duplicate unit/facet'),
            ('unknown derived field', lambda d: d['units'][0].__setitem__('verified', True), "schema corpus.json/units/0: Additional properties are not allowed ('verified' was unexpected)"),
        ]
        for label, change, diagnostic in cases:
            with self.subTest(label=label):
                (self.out / 'corpus.json').write_bytes(good)
                self.mutate(BASE / 'generated/corpus.json', change)
                before = self.snapshot()
                print(label, flush=True)
                self.cli('check', 1, diagnostic)
                self.assertEqual(before, self.snapshot())
        (self.out / 'corpus.json').write_bytes(good)
        self.cli('check')
        for filename in ('crosswalk.csv', 'coverage.json'):
            path = self.out / filename
            original = path.read_bytes()
            path.write_bytes(original + b'\n')
            self.cli('check', 1, filename)
            path.write_bytes(original)
        self.mutate(BASE / 'generated/coverage.json', lambda d: d.__setitem__('unresolved_differences', 0))
        self.cli('check', 1, 'coverage.json')

    def test_annotation_corruptions(self):
        path = BASE / 'annotations/b.json'
        good = (self.repo / path).read_bytes()
        cases = [
            (lambda d: d['annotations'].pop(), 'annotation unit coverage'),
            (lambda d: d['annotations'].__setitem__(1, d['annotations'][0]), 'duplicate unit_id'),
            (lambda d: d['annotations'][0]['facets']['trust'].append('imaginary'), 'unknown facet label'),
            (lambda d: d.__setitem__('input_sha256', '0'*64), 'annotation input hash'),
            (lambda d: d.__setitem__('annotator_id', 'a'), 'annotator_id'),
            (lambda d: d['annotations'][0].pop('rationale'), "annotations/0: 'rationale' is a required property"),
            (lambda d: d['annotations'][0]['facets']['economic_functions'].append('exchange'), "annotations/0/facets/economic_functions: ['exchange', 'exchange'] has non-unique elements"),
        ]
        for change, diagnostic in cases:
            with self.subTest(diagnostic=diagnostic):
                (self.repo / path).write_bytes(good)
                self.mutate(path, change)
                self.cli('build', 1, diagnostic)
                self.assertFalse(self.out.exists())

    def test_missing_and_empty_inputs(self):
        self.cli('check', 3, 'missing/unreadable')
        for relative in (BASE / 'inputs/taxonomy.json', BASE / 'annotations/a.json',
                         Path('corpus50/lanes/lane1-dex-lending-cdp-lsd.json')):
            path = self.repo / relative
            original = path.read_bytes()
            path.unlink()
            self.cli('build', 3, 'missing/unreadable')
            path.write_bytes(b'')
            self.cli('build', 3, 'empty required input')
            path.write_bytes(original)
        self.cli('build')

    def test_source_drift_and_partial_walk(self):
        source = self.repo / 'corpus50/lanes/lane1-dex-lending-cdp-lsd.json'
        source.write_bytes(source.read_bytes() + b'\n')
        self.cli('build', 3, 'source SHA256 mismatch')
        shutil.copyfile(REPO / source.relative_to(self.repo), source)
        self.mutate(BASE / 'inputs/source-manifest.json', lambda d: d['files'].pop())
        self.cli('build', 3, 'source inventory')

    def test_partial_source_content_even_with_updated_manifest_hash(self):
        relative = Path('corpus50/lanes/lane1-dex-lending-cdp-lsd.json')
        self.mutate(relative, lambda d: d['categories'][0]['protocols'].pop())
        sha = hashlib.sha256((self.repo / relative).read_bytes()).hexdigest()
        self.mutate(BASE / 'inputs/source-manifest.json',
                    lambda d: next(e for e in d['files'] if e['path'] == relative.as_posix()).__setitem__('sha256', sha))
        self.cli('build', 3, 'source row count mismatch')

    def test_same_count_source_edit_with_updated_manifest_hash(self):
        relative = Path('corpus50/lanes/lane1-dex-lending-cdp-lsd.json')
        self.mutate(relative, lambda d: d['categories'][0]['protocols'][0]['residue'].append('Changed source context.'))
        sha = hashlib.sha256((self.repo / relative).read_bytes()).hexdigest()
        self.mutate(BASE / 'inputs/source-manifest.json',
                    lambda d: next(e for e in d['files'] if e['path'] == relative.as_posix()).__setitem__('sha256', sha))
        self.cli('build', 1, 'neutral annotation input does not match identity map, taxonomy or source rows')
        self.assertFalse(self.out.exists())

    def test_neutral_binding_preserves_original_json_types(self):
        relative = Path('corpus50/lanes/lane1-dex-lending-cdp-lsd.json')
        self.mutate(relative, lambda d: d['categories'][0]['protocols'][0].__setitem__('arbitrary_field', True))
        sha = hashlib.sha256((self.repo / relative).read_bytes()).hexdigest()
        self.mutate(BASE / 'inputs/source-manifest.json',
                    lambda d: next(e for e in d['files'] if e['path'] == relative.as_posix()).__setitem__('sha256', sha))
        neutral = BASE / 'inputs/annotation-input.json'
        self.mutate(neutral, lambda d: d['units'][0]['source_record']['original'].__setitem__('arbitrary_field', 1))
        sha = hashlib.sha256((self.repo / neutral).read_bytes()).hexdigest()
        for annotator in ('a', 'b'):
            self.mutate(BASE / f'annotations/{annotator}.json', lambda d: d.__setitem__('input_sha256', sha))
        self.cli('build', 1, 'neutral annotation input does not match identity map, taxonomy or source rows')
        self.assertFalse(self.out.exists())
        self.mutate(neutral, lambda d: d['units'][0]['source_record']['original'].__setitem__('arbitrary_field', True))
        sha = hashlib.sha256((self.repo / neutral).read_bytes()).hexdigest()
        for annotator in ('a', 'b'):
            self.mutate(BASE / f'annotations/{annotator}.json', lambda d: d.__setitem__('input_sha256', sha))
        self.cli('build')
        corpus = json.loads((self.out / 'corpus.json').read_text())
        self.assertIs(corpus['source_records'][0]['original']['arbitrary_field'], True)

    def test_identity_corruptions(self):
        relative = BASE / 'inputs/identity-map.json'
        good = (self.repo / relative).read_bytes()
        for change, diagnostic in (
            (lambda d: d['units'].pop(), 'identity unit coverage'),
            (lambda d: d['units'].__setitem__(1, d['units'][0]), 'duplicate unit_id'),
            (lambda d: d['units'][0].__setitem__('legacy_id', d['units'][1]['legacy_id']), 'parent-child coverage'),
            (lambda d: d['units'][0].__setitem__('evaluation_role', 'holdout'), "schema identity map/evaluation_role: 'development' was expected")):
            (self.repo / relative).write_bytes(good)
            self.mutate(relative, change)
            self.cli('build', 1, diagnostic)

    def test_coherent_split_payload_corruptions(self):
        identity_path = self.repo / BASE / 'inputs/identity-map.json'
        neutral_path = self.repo / BASE / 'inputs/annotation-input.json'
        good_identity, good_neutral = identity_path.read_bytes(), neutral_path.read_bytes()
        v1, v2 = 'unit:lane1:c2:p4:v1', 'unit:lane1:c2:p4:v2'
        usdy, ousg = 'unit:lane3:c0:p0:usdy', 'unit:lane3:c0:p0:ousg'

        def swap(units, a, b, key):
            units[a][key], units[b][key] = units[b][key], units[a][key]

        cases = [
            ('duplicate-version', lambda u: u[v2].__setitem__('version', u[v1]['version']), 'identity split version mismatch'),
            ('swapped-version', lambda u: swap(u, v1, v2, 'version'), 'identity split version mismatch'),
            ('wrong-shared-product', lambda u: [u[x]['product'].__setitem__('id', 'product:changed') for x in (v1, v2)], 'identity split product mismatch'),
            ('duplicate-product', lambda u: u[ousg].__setitem__('product', u[usdy]['product']), 'identity split product mismatch'),
            ('swapped-product', lambda u: swap(u, usdy, ousg, 'product'), 'identity split product mismatch'),
        ]
        for label, change, diagnostic in cases:
            with self.subTest(label=label):
                identity, neutral = json.loads(good_identity), json.loads(good_neutral)
                units = {u['unit_id']: u for u in identity['units']}
                change(units)
                for context in neutral['units']:
                    context['identity'] = units[context['identity']['unit_id']]
                write(identity_path, identity)
                write(neutral_path, neutral)
                sha = hashlib.sha256(neutral_path.read_bytes()).hexdigest()
                for annotator in ('a', 'b'):
                    self.mutate(BASE / f'annotations/{annotator}.json', lambda d: d.__setitem__('input_sha256', sha))
                out = self.repo / label
                self.cli('build', 1, diagnostic, out=out)
                self.assertFalse(out.exists())

    def test_adjudication_schema_and_distinct_annotation_refs(self):
        self.cli('build')
        path = self.out / 'corpus.json'
        good = path.read_bytes()
        cases = [
            (lambda d: d['units'][0]['annotation_refs'].__setitem__(1, d['units'][0]['annotation_refs'][0]),
             "schema corpus.json/units/0/annotation_refs/1/annotator_id: 'b' was expected"),
            (lambda d: d['adjudications'][0].__setitem__('status', 'unresolved_difference'),
             "schema corpus.json/adjudications/0/status: 'provisional_agreement' was expected"),
            (lambda d: d['adjudications'][0]['unresolved_labels'].append('exchange'),
             'schema corpus.json/adjudications/0/unresolved_labels: maxItems=0; observed length=1'),
            (lambda d: d['adjudications'][2].__setitem__('status', 'provisional_agreement'),
             "schema corpus.json/adjudications/2/status: 'unresolved_difference' was expected"),
            (lambda d: d['adjudications'][2].__setitem__('unresolved_labels', []),
             'schema corpus.json/adjudications/2/unresolved_labels: minItems=1; observed length=0'),
        ]
        for change, diagnostic in cases:
            with self.subTest(diagnostic=diagnostic):
                path.write_bytes(good)
                self.mutate(BASE / 'generated/corpus.json', change)
                self.cli('check', 1, diagnostic)
        path.write_bytes(good)
        self.cli('check')

    def test_unreadable_and_empty_generated(self):
        self.cli('build')
        path = self.out / 'crosswalk.csv'
        path.write_bytes(b'')
        self.cli('check', 3, 'empty required input')
        path.unlink()
        path.mkdir()
        self.cli('check', 3, 'missing/unreadable')

    def test_symlink_escape(self):
        path = self.repo / BASE / 'inputs/taxonomy.json'
        path.unlink()
        path.symlink_to(REPO / BASE / 'inputs/taxonomy.json')
        self.cli('build', 3, 'path escape')

    def test_duplicate_json_keys_and_malformed_json(self):
        path = self.repo / BASE / 'annotations/a.json'
        path.write_text('{"x":1,"x":2}')
        self.cli('build', 1, 'duplicate JSON key')
        path.write_text('{broken')
        self.cli('build', 1, 'malformed JSON')

    def test_duplicate_key_in_generated_corpus(self):
        self.cli('build')
        path = self.out / 'corpus.json'
        path.write_text(path.read_text().replace('{', '{"status":"provisional_source_bound",', 1))
        self.cli('check', 1, 'duplicate JSON key')

    def test_neutral_source_and_identity_binding(self):
        path = BASE / 'inputs/annotation-input.json'
        good = (self.repo / path).read_bytes()
        for change in (
            lambda d: d['units'][0]['identity'].__setitem__('label', 'changed'),
            lambda d: d['units'][0]['source_record']['original'].__setitem__('residue', []),
            lambda d: d['taxonomy']['facets']['trust'].append('invented')):
            (self.repo / path).write_bytes(good)
            self.mutate(path, change)
            self.cli('build', 1, 'neutral annotation input')

    def test_path_escape(self):
        self.mutate(BASE / 'inputs/source-manifest.json',
                    lambda d: d['files'][0].__setitem__('path', '../outside.json'))
        self.cli('build', 3, 'path escape')

    def test_schema_is_checked(self):
        self.mutate(BASE / 'corpus.schema.json', lambda d: d.__setitem__('type', 'nonsense'))
        self.cli('build', 1, 'invalid JSON Schema')

    def test_schema_broken_local_reference(self):
        self.mutate(BASE / 'corpus.schema.json',
                    lambda d: d['$defs']['identity'].__setitem__('$ref', '#/$defs/missing'))
        self.cli('build', 1, 'invalid JSON Schema: unresolved local reference')


if __name__ == '__main__':
    unittest.main(verbosity=2)
