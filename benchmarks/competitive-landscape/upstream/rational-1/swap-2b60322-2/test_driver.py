"""Parser checks for the protocol's actual trust and execution distinctions."""
import unittest

from driver import classify, compile_target, DECLARED_CASES


class ParserTests(unittest.TestCase):
    def test_rejects_nonstandard_axioms_and_missing_execution(self):
        good = {'returncode': 0, 'stdout': "'RationalTransfer.canonical' depends on axioms: [propext, Classical.choice, Quot.sound]\n", 'stderr': ''}
        self.assertEqual(classify(good), 'success')
        self.assertEqual(classify(dict(good, stdout=good['stdout'].replace('Quot.sound', 'sorryAx'))), 'failed_obligations')
        self.assertEqual(classify(dict(good, stdout=good['stdout'].replace('Quot.sound', 'untrustedOracle'))), 'untrusted_axioms')
        self.assertEqual(classify(dict(good, stdout='')), 'incomplete')
        self.assertEqual(classify(dict(good, cached=True)), 'cached_skip')
        self.assertEqual(classify(dict(good, timeout=True, returncode=None)), 'timeout')
        swap = dict(good, stdout=good['stdout'].replace('RationalTransfer', 'RationalSwap'))
        self.assertEqual(classify(swap), 'incomplete')
        self.assertEqual(classify(swap, 'R2-SWAP'), 'success')

    def test_undeclared_case_is_rejected_before_execution(self):
        for case in ('R1-TRANSFER', 'R2-SWAP'):
            if case not in DECLARED_CASES:
                with self.assertRaisesRegex(ValueError, 'not declared'):
                    compile_target('assisted', case_id=case)


if __name__ == '__main__':
    unittest.main()
