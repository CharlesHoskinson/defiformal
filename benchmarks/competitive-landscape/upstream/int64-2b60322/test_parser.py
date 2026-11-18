import importlib,unittest
class ParserTests(unittest.TestCase):
 def test_tool_statuses_cannot_be_promoted_to_a_proof(self):
  try:module=importlib.import_module('adapter')
  except ImportError:self.fail('Adapter result parser is not implemented')
  good=dict(returncode=0,stdout="'Benchmark.established' depends on axioms: [propext, Classical.choice, Quot.sound]\n",stderr='',verification_executed=True,artifact_exists=True,artifact_sha256='a'*64)
  fixtures={'success':good,'failed_obligations':dict(good,returncode=1,stdout='error: unsolved goals'),'incomplete':dict(good,stdout=''),'timeout':dict(good,returncode=124),'cached_skip':dict(good,verification_executed=False),'malformed':{'returncode':'0'}}
  for expected,data in fixtures.items():
   with self.subTest(expected=expected):self.assertEqual(module.classify(data),expected)
  self.assertEqual(module.classify(dict(good,stdout="'Benchmark.established' depends on axioms: [sorryAx]")),'incomplete')
  self.assertEqual(module.classify(dict(good,artifact_exists=False)),'incomplete')
if __name__=='__main__':unittest.main()
