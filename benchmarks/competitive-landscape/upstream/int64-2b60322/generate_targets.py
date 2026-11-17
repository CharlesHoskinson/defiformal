"""AI-authored target templates; generated proof text is separately inventoried."""
from pathlib import Path
HERE=Path(__file__).resolve().parent
STATEMENTS={'P1':'(b : Ledger) (t : Instruction) : P1 b t','P2':'(x y d : Word) : P2 x y d','P3_N4':'(b : Ledger) (ts : List Instruction) : P3 4 b ts','P3_N16':'(b : Ledger) (ts : List Instruction) : P3 16 b ts'}
def render():
 files={}
 for name,statement in STATEMENTS.items():
  files[name+'_automatic.lean']='import Model\nnamespace Benchmark\n theorem established '+statement+' := by benchmark_auto\n#print axioms established\nend Benchmark\n'
 for name,n in [('P3_N4',4),('P3_N16',16)]:
  guided='  intro _ _ h\n  exact sequenceLaw b ts h\n'
  files[name+'_assisted.lean']='import SequenceHelper\nnamespace Benchmark\n theorem established (b : Ledger) (ts : List Instruction) : P3 '+str(n)+' b ts := by\n'+guided+'#print axioms established\nend Benchmark\n'
 return files
if __name__=='__main__':
 for name,text in render().items():
  if (HERE/name).read_text()!=text:raise SystemExit('Generated target differs: '+name)
 print('All generated targets match their retained templates')
