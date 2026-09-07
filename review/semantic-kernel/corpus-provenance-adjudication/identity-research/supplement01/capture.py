#!/usr/bin/env python3
"""Separate bounded source-gap pass; earlier packets remain immutable."""
from pathlib import Path
import importlib.util
import sys
sys.dont_write_bytecode = True
import hashlib
import json
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
SOURCE=HERE.parent/'batch03'/'capture.py'
TARGETS={
 'unit:lane3:c1:p2': ['https://www.hegic.co/app'],
 'unit:lane3:c2:p3': ['https://www.paxos.com/newsroom/paxos-introduces-global-dollar-usdg',
                    'https://www.paxos.com/terms-and-conditions/usdg-eu-whitepaper'],
 'unit:lane3:c3:p2': ['https://gem.azuro.org/knowledge-hub/introduction/what-is-azuro',
                    'https://gem.azuro.org/knowledge-hub/how-azuro-works/components/pools'],
 'unit:lane3:c3:p3': ['https://www.steakhouse.financial/'],
}

def sha(data):return hashlib.sha256(data).hexdigest()

def save(name,obj):
    with (HERE/name).open('x') as out:json.dump(obj,out,ensure_ascii=False,indent=2);out.write('\n')

def main():
    selected=json.loads((HERE.parent/'batch03'/'selected-units.json').read_bytes())['units']
    by_id={u['unit_id']:u for u in selected}
    assert set(TARGETS)<=set(by_id),set(TARGETS)-set(by_id)
    for name in ['captures','extracted','responses']:(HERE/name).mkdir(exist_ok=False)
    protected={}
    for batch in ['batch01','batch02','batch03']:
        for path in (HERE.parent/batch).rglob('*'):
            if path.is_file() and 'review-gpt6' not in path.parts:
                protected[str(path.relative_to(ROOT))]=sha(path.read_bytes())
    for manifest in ['review/semantic-kernel/sprint10/planning/r2-candidate.json',
                     'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r1/manifest.json']:
        for row in json.loads((ROOT/manifest).read_bytes())['inputs']:protected[row['path']]=sha((ROOT/row['path']).read_bytes())
    save('before.json',{'utc':datetime.now(timezone.utc).isoformat(),'protected':protected,
        'parent_capture_helper':str(SOURCE.relative_to(ROOT)),'parent_capture_helper_sha256':sha(SOURCE.read_bytes()),
        'helper_sha256':sha(Path(__file__).read_bytes()),
        'scope':'Separately recorded source-gap pass under continuing user authorization; at most3 new URLs per unit and2 attempts per URL. Search snippets select targets only.'})
    save('targets.json',{'units':[{'unit_id':i,'label':by_id[i]['label'],'original_binding':by_id[i]['canonical_record'],
        'target_urls':urls,'prior_packet':'batch03','accepted':False} for i,urls in TARGETS.items()]})
    spec=importlib.util.spec_from_file_location('bounded_capture',SOURCE)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);module.HERE=HERE
    urls=sorted({u for v in TARGETS.values() for u in v})
    with ThreadPoolExecutor(max_workers=4) as pool:records=list(pool.map(module.capture,urls))
    unchanged=all(sha((ROOT/p).read_bytes())==h for p,h in protected.items())
    save('retrievals.json',{'status':'UNASSESSED_SUPPLEMENT_NOT_ACCEPTANCE','records':records})
    save('after.json',{'utc':datetime.now(timezone.utc).isoformat(),'protected_unchanged':unchanged})
    assert unchanged
    print(json.dumps({'units':len(TARGETS),'urls':len(urls),'statuses':[r['status'] for r in records]}))

if __name__=='__main__':main()
