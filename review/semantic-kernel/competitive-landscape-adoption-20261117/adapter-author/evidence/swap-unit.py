from pathlib import Path
from argparse import Namespace
import runpy,unittest
root=Path('/private/tmp/defiformal-adapter-author')
wrapper=runpy.run_path(str(root/'benchmarks/competitive-landscape/reproduce.py'))
args=Namespace(adapter='swap',lean_bin=str(root/'runtime/lean-4.33.0-rc2-darwin_aarch64/bin/lean'),dependency_root=str(root/'runtime/upstream/lean'),output=str(root/'units'/'swap'),historical_runtime=None)
identity=wrapper['validate_environment'](args)
adapter=wrapper['configure'](args,identity)
result=unittest.TextTestRunner(verbosity=2).run(unittest.TestLoader().discover(str(adapter)))
raise SystemExit(0 if result.wasSuccessful() else 1)
