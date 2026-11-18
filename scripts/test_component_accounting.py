"""Behavioral controls for the real read-only component accounting CLI."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / 'scripts/check_component_accounting.py'
MANIFEST = ROOT / 'benchmarks/component-accounting/manifest.json'


class AccountingTests(unittest.TestCase):
    def run_cli(self, root, manifest):
        return subprocess.run([sys.executable, str(CHECKER), '--root', str(root),
                               '--manifest', str(manifest)], capture_output=True, text=True)

    def test_intact_real_scope_is_nonempty_and_read_only(self):
        data = json.loads(MANIFEST.read_text())
        paths = [MANIFEST] + [ROOT / entry['path'] for section in
            ['components', 'support_files', 'evidence_files'] for entry in data[section]]
        before = [(p.read_bytes(), p.stat().st_mtime_ns) for p in paths]
        result = self.run_cli(ROOT, MANIFEST)
        self.assertEqual(result.returncode, 0, result.stderr)
        report = json.loads(result.stdout)
        self.assertEqual(len(report['components']), 2)
        self.assertEqual([r['physical_lines'] for r in report['components']], [394, 351])
        self.assertTrue(all(r['counts']['model'] > 0 and r['counts']['specification'] > 0
                            and r['counts']['guidance'] > 0 for r in report['components']))
        self.assertEqual(report['agenda_I_3_status'], 'unmet')
        self.assertEqual(before, [(p.read_bytes(), p.stat().st_mtime_ns) for p in paths])

    def fixture(self, folder):
        root = Path(folder)
        path = root / 'Source.lean'
        path.write_text('def value := 1\n\ntheorem law : value = 1 := rfl\n')
        data = {'schema_version': 1, 'source_revision': 'fixture',
                'required_components': ['fixture'], 'agenda_I_3_status': 'unmet',
                'components': [{'id': 'fixture', 'path': 'Source.lean',
                  'sha256': hashlib.sha256(path.read_bytes()).hexdigest(), 'physical_lines': 3,
                  'ranges': [[1, 1, 'model'], [2, 2, 'blank'], [3, 3, 'specification']],
                  'authoring_effort_seconds': None, 'human_authoring_effort_seconds': None}],
                'support_files': [], 'evidence_files': []}
        manifest = root / 'manifest.json'
        manifest.write_text(json.dumps(data))
        return root, path, manifest, data

    def test_source_drift_and_missing_source_are_blocked(self):
        for missing in [False, True]:
            with self.subTest(missing=missing), tempfile.TemporaryDirectory() as tmp:
                root, source, manifest, data = self.fixture(tmp)
                if missing: source.unlink()
                else: source.write_text(source.read_text().replace('1', '2'))
                result = self.run_cli(root, manifest)
                self.assertEqual(result.returncode, 3, result.stderr)
                self.assertIn('BLOCKED', result.stderr)

    def test_omitted_overlapping_and_unknown_classification_fail(self):
        for mutation in ['omitted', 'overlap', 'unknown', 'false_blank']:
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as tmp:
                root, source, manifest, data = self.fixture(tmp)
                ranges = data['components'][0]['ranges']
                if mutation == 'omitted': ranges.pop()
                if mutation == 'overlap': ranges.append([1, 1, 'guidance'])
                if mutation == 'unknown': ranges[0][2] = 'unclassified'
                if mutation == 'false_blank': ranges[0][2] = 'blank'
                manifest.write_text(json.dumps(data))
                result = self.run_cli(root, manifest)
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertIn('FAILED', result.stderr)

    def test_empty_or_partial_component_scope_is_blocked(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, source, manifest, data = self.fixture(tmp)
            data['components'] = []
            manifest.write_text(json.dumps(data))
            result = self.run_cli(root, manifest)
            self.assertEqual(result.returncode, 3)
            self.assertIn('scope', result.stderr)

    def test_partial_real_two_component_scope_is_blocked(self):
        data = json.loads(MANIFEST.read_text())
        data['components'].pop()
        with tempfile.TemporaryDirectory() as tmp:
            manifest = Path(tmp) / 'partial.json'
            manifest.write_text(json.dumps(data))
            result = self.run_cli(ROOT, manifest)
            self.assertEqual(result.returncode, 3, result.stderr)
            self.assertIn('scope', result.stderr)

    def test_unknown_effort_cannot_be_promoted_to_measured_zero_or_completion(self):
        for mutation in ['zero', 'complete']:
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as tmp:
                root, source, manifest, data = self.fixture(tmp)
                if mutation == 'zero': data['components'][0]['authoring_effort_seconds'] = 0
                else: data['agenda_I_3_status'] = 'complete'
                manifest.write_text(json.dumps(data))
                result = self.run_cli(root, manifest)
                self.assertEqual(result.returncode, 1, result.stderr)


if __name__ == '__main__':
    unittest.main()
