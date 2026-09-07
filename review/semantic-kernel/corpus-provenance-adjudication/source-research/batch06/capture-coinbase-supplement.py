"""One last primary cbBTC issuance description; two prior substantive bodies retained."""
import sys
sys.dont_write_bytecode=True
import importlib.util,json
from pathlib import Path
p=Path(__file__).with_name('capture-batch.py');s=importlib.util.spec_from_file_location('cap',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
r=m.capture('coinbase-cbbtc/issuance-supplement',{'unit':'unit:lane2:c2:p2','disputes':[21,22],'targets':[('issuance','https://www.coinbase.com/en-ca/bytes/archive/is-btc-poised-for-a-bigger-rally')]})
m.write(m.OUT/'coinbase-supplement-results.json',r);print(json.dumps(r))
