"""Preserve first attempts; retrieve corrected routes and one nonempty BTCB publisher source."""
import importlib.util,json
from pathlib import Path
p=Path(__file__).with_name('capture-batch.py');spec=importlib.util.spec_from_file_location('batch06_capture',p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
# Fresh subdirectories preserve every initial capture/record. At most three substantive bodies per unit.
items={
 'cow-solver-collateral/routing-correction':{'unit':'unit:lane2:c3:p7','disputes':[24],'targets':[(s,'https://docs.cow.fi/cow-protocol/reference/core/auctions/'+slug) for s,slug in [('bonding','bonding-pools'),('rules','competition-rules'),('enforcement','ebbo-specifics')]]},
 'btcb-cross-domain/nonempty-fallback':{'unit':'unit:lane2:c2:p4','disputes':[23],'targets':[('btcb-blog','https://www.bnbchain.org/en/blog/4-ways-to-do-more-with-btc-on-binance-smart-chain')]},
}
from concurrent.futures import ThreadPoolExecutor
with ThreadPoolExecutor(max_workers=2) as pool:results=list(pool.map(lambda x:m.capture(*x),items.items()))
m.write(m.OUT/'supplemental-capture-results.json',results)
print(json.dumps(results,indent=2))
