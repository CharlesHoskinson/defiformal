import sys
from pathlib import Path
sys.path.insert(0,'/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16')
import source_campaign as s
s.ROOT=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p16-proof-diagnostic-sandbox')
original=s.write_source_bindings_lean
mode=sys.argv[1]
def corrupt(path,fixtures=None):
 original(path,fixtures)
 if mode=='compiler-nonzero':path.write_text(path.read_text()+'\n#check P16ReviewNonexistentDeclaration\n')
 elif mode=='malformed-extra':path.write_text(path.read_text()+'\n#eval IO.println "P16-ADD malformed extra protocol row"\n')
s.write_source_bindings_lean=corrupt
raise SystemExit(s.mode_intact(Path(sys.argv[2])))
