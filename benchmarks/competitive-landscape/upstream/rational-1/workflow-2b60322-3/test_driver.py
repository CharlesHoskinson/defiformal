"""Protocol controls and real helper recompilation for the workflow adapter."""
from pathlib import Path
import tempfile
import unittest

try:
    import driver
except ImportError:
    driver = None


class DriverTests(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(driver, 'The workflow replay driver is not implemented')

    def test_accepts_only_the_requested_checked_declaration(self):
        good = {'returncode': 0, 'stdout': "'Case.canonical' depends on axioms: [propext]\n", 'stderr': ''}
        self.assertEqual(driver.classify(good, 'Case.canonical'), 'success')
        no_axioms = dict(good, stdout="'Case.canonical' does not depend on any axioms\n")
        self.assertEqual(driver.classify(no_axioms, 'Case.canonical'), 'success')
        self.assertEqual(driver.classify(dict(good, stdout=good['stdout'] + no_axioms['stdout']),
                                         'Case.canonical'), 'incomplete')
        self.assertEqual(driver.classify(good, 'Different.canonical'), 'incomplete')
        for expected, record in {
            'failed_obligations': dict(good, stdout=good['stdout'].replace('propext', 'sorryAx')),
            'untrusted_axioms': dict(good, stdout=good['stdout'].replace('propext', 'oracle')),
            'timeout': dict(good, timeout=True, returncode=None),
            'cached_skip': dict(good, cached=True),
            'incomplete': dict(good, stdout=''),
            'malformed': dict(good, returncode=1, stderr='missing module'),
        }.items():
            with self.subTest(expected=expected):
                self.assertEqual(driver.classify(record, 'Case.canonical'), expected)

    def test_new_helpers_are_recompiled_and_not_hidden_in_retained_cache(self):
        with tempfile.TemporaryDirectory(dir=driver.workspace()) as directory:
            base = Path(directory)
            source, work = base / 'source', base / 'work'
            source.mkdir()
            (source / 'Helper.lean').write_text('def helperValue : Nat := 1\n')
            (source / 'Target.lean').write_text(
                'import Helper\nnamespace Case\n'
                'theorem canonical : helperValue = 1 := by rfl\n'
                '#print axioms canonical\nend Case\n')
            records, result = driver.compile_modules(source, work, ['Helper', 'Target'], 'Case.canonical')
            self.assertEqual(result, 'success', records)
            first = driver.setup.digest(work / 'Helper.olean')
            (source / 'Helper.lean').write_text('def helperValue : Nat := 2\n')
            records, result = driver.compile_modules(source, work, ['Helper', 'Target'], 'Case.canonical')
            self.assertEqual(result, 'failed_obligations', records)
            self.assertNotEqual(first, driver.setup.digest(work / 'Helper.olean'))

    def test_failed_dependency_cannot_be_hidden_by_a_success_marker(self):
        with tempfile.TemporaryDirectory(dir=driver.workspace()) as directory:
            base = Path(directory)
            source = base / 'source'
            source.mkdir()
            (source / 'Broken.lean').write_text('theorem broken : False := by decide\n')
            (source / 'Target.lean').write_text(
                'theorem canonical : True := trivial\n#print axioms canonical\n')
            records, result = driver.compile_modules(source, base / 'work', ['Broken', 'Target'], 'canonical')
            self.assertNotEqual(result, 'success')
            self.assertEqual(len(records), 1)


if __name__ == '__main__':
    unittest.main()
