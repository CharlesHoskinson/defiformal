"""Final direct CoW documentation link correction; preserves all previous records."""
import sys
sys.dont_write_bytecode=True
import importlib.util,json
from pathlib import Path
p=Path(__file__).with_name('capture-batch.py');spec=importlib.util.spec_from_file_location('batch06_capture',p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
r=m.capture('cow-solver-collateral/enforcement-correction',{'unit':'unit:lane2:c3:p7','disputes':[24],'targets':[('enforcement','https://docs.cow.fi/cow-protocol/reference/core/auctions/ebbo-rules')]})
m.write(m.OUT/'enforcement-capture-results.json',r);print(json.dumps(r))
