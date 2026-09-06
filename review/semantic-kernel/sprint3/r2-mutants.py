import importlib.util
import io
from pathlib import Path
import sys
import tempfile
import unittest
sys.dont_write_bytecode = True
path = Path('/home/charl/defiformal/scripts/test_corpus_normalize.py')
spec = importlib.util.spec_from_file_location('corpus_tests', path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
original = module.SCRIPT.read_text()
needle = 'retained, unresolved = sorted(a & b), sorted(a ^ b)'
assert original.count(needle) == 1
mutations = {
    'always-A retained set': 'retained, unresolved = sorted(a), sorted(a ^ b)',
    'drop every differing retained set': 'retained, unresolved = ([] if a != b else sorted(a & b)), sorted(a ^ b)',
    'one-sided difference': 'retained, unresolved = sorted(a & b), sorted(a - b)',
}
with tempfile.TemporaryDirectory(prefix='corpus-adjudication-mutants-') as directory:
    for label, replacement in mutations.items():
        mutant = Path(directory) / 'normalizer.py'
        mutant.write_text(original.replace(needle, replacement))
        module.SCRIPT = mutant
        result = unittest.TextTestRunner(verbosity=2).run(unittest.TestSuite([
            module.CorpusCLI('test_positive_reproducible_read_only')]))
        assert len(result.failures) == 1 and not result.errors, label
        print('DISCRIMINATES:', label, flush=True)
