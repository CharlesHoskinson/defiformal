"""Behavioral controls for the public adapter entrypoint."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent


class ReproductionTests(unittest.TestCase):
    def cli(self, *args, root=HERE):
        return subprocess.run([sys.executable, str(root / 'reproduce.py'), *args],
                              capture_output=True, text=True)

    def test_intact_nonempty_import_is_accepted(self):
        result = self.cli('verify-sources')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)['files_checked'], 168)

    def test_missing_modified_extra_and_empty_imports_are_rejected(self):
        for change in ['missing', 'modified', 'extra', 'empty']:
            with self.subTest(change=change), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp) / 'bundle'
                shutil.copytree(HERE, root, ignore=shutil.ignore_patterns('__pycache__'))
                sources = root / 'upstream'
                target = next(sources.rglob('Model.lean'))
                if change == 'missing': target.unlink()
                if change == 'modified': target.write_text(target.read_text() + '\n-- changed\n')
                if change == 'extra': (sources / 'unrecorded.lean').write_text('-- extra\n')
                if change == 'empty': shutil.rmtree(sources)
                result = self.cli('verify-sources', root=root)
                self.assertEqual(result.returncode, 3, result.stdout + result.stderr)
                self.assertIn('BLOCKED', result.stderr)

    def test_no_output_inside_source_or_dependency(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            dependency = root / 'deps'
            dependency.mkdir()
            result = self.cli('check', '--lean-bin', '/missing/lean',
                              '--dependency-root', str(dependency),
                              '--output', str(dependency / 'writes'))
            self.assertEqual(result.returncode, 3)
            self.assertIn('output overlaps', result.stderr)
            self.assertFalse((dependency / 'writes').exists())

    def test_unknown_adapter_is_rejected_without_running_lean(self):
        result = self.cli('check', '--adapter', 'unknown', '--lean-bin', '/missing/lean',
                          '--dependency-root', '/missing/deps', '--output', '/missing/output')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('invalid choice', result.stderr)

    def test_wrong_version_is_blocked_before_proof_execution(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            lean = root / 'bin/lean'
            lean.parent.mkdir()
            lean.write_text('#!/bin/sh\nprintf "Lean (version 4.32.0, test)\\n"\n')
            lean.chmod(0o755)
            (lean.parent / 'leanchecker').write_text('checker')
            result = self.cli('check', '--lean-bin', str(lean),
                              '--dependency-root', str(root / 'deps'), '--output', str(root / 'out'))
            self.assertEqual(result.returncode, 3, result.stderr)
            self.assertIn('incorrect Lean version', result.stderr)
            self.assertFalse((root / 'out').exists())

    def test_python_optimization_cannot_disable_upstream_assertions(self):
        result = subprocess.run([sys.executable, '-O', str(HERE / 'reproduce.py'), 'check',
            '--lean-bin', '/missing/lean', '--dependency-root', '/missing/deps',
            '--output', '/missing/out'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 3)
        self.assertIn('assertions must be enabled', result.stderr)

    def test_missing_tool_is_blocked(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.cli('check', '--lean-bin', '/missing/lean',
                              '--dependency-root', str(Path(tmp) / 'deps'),
                              '--output', str(Path(tmp) / 'output'))
            self.assertEqual(result.returncode, 3)
            self.assertIn('BLOCKED', result.stderr)


if __name__ == '__main__':
    unittest.main()
