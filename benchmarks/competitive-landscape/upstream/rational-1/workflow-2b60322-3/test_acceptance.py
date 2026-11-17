"""Acceptance output must discriminate an executed semantic counterexample."""
import unittest

try:
    import acceptance
except ImportError:
    acceptance = None


class AcceptanceTests(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(acceptance, 'Workflow acceptance is not implemented')

    def test_witness_markers_require_execution_and_exact_case(self):
        record = dict(returncode=0, stdout='WITNESS sample passed\nOBSERVATION actual=1\n', stderr='')
        acceptance.witness_markers(record, ['sample'])
        for bad in [dict(record, returncode=1), dict(record, timeout=True),
                    dict(record, stdout=''), dict(record, stdout='WITNESS other passed\n'),
                    dict(record, stdout=record['stdout'] * 2)]:
            with self.assertRaises(AssertionError):
                acceptance.witness_markers(bad, ['sample'])

    def test_mutation_requires_true_original_and_false_compiled_mutant(self):
        good = dict(returncode=0, stdout='CONTROL defect true\n', stderr='')
        broken = dict(returncode=0, stdout='CONTROL defect false\n', stderr='')
        acceptance.counterexample_pair(good, broken, 'defect')
        for original, mutant in [(broken, broken), (good, good),
                                  (good, dict(broken, returncode=1)),
                                  (good, dict(broken, timeout=True)),
                                  (good, dict(broken, stdout='syntax error'))]:
            with self.assertRaises(AssertionError):
                acceptance.counterexample_pair(original, mutant, 'defect')

    def test_mutation_replacements_are_bound_to_the_expected_source(self):
        self.assertEqual(acceptance.replace_source('x + x', {'find': 'x', 'replace': 'y', 'count': 2}), 'y + y')
        for spec in [{'find': 'x', 'replace': 'y', 'count': 1},
                     {'find': 'missing', 'replace': 'y', 'count': 1},
                     {'find': 'x', 'replace': 'x', 'count': 2}]:
            with self.assertRaises(AssertionError):
                acceptance.replace_source('x + x', spec)


if __name__ == '__main__':
    unittest.main()
