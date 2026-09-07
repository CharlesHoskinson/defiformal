"""Extract the final two retained sources without replacing the first extraction record."""
import sys
sys.dont_write_bytecode=True
import importlib.util,json
from pathlib import Path
p=Path(__file__).with_name('extract.py');s=importlib.util.spec_from_file_location('ext',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
for name,child,sid in [('coinbase-cbbtc','issuance-supplement','issuance'),('cow-solver-collateral','enforcement-correction','enforcement')]:
 out=m.BASE/name;rp=out/child/'retrievals.json';row=json.loads(rp.read_text())['records'][0];a=row['attempts'][-1];assert a['status']=='retained' and a['body_bytes']
 body=(m.ROOT/a['capture_path']).read_bytes();p=m.Text();p.feed(body.decode());data=('\n'.join(p.nodes)+'\n').encode();dest=out/(sid+'.txt')
 with dest.open('xb') as f:f.write(data)
 records=json.loads((out/'extraction.json').read_text());records.append({'source_id':sid,'retrieval_record':str(rp.relative_to(m.ROOT)),'capture_path':a['capture_path'],'capture_sha256':m.sha(body),'output_path':str(dest.relative_to(m.ROOT)),'output_sha256':m.sha(data),'text_nodes':len(p.nodes),'method':m.__doc__,'extractor_path':str(Path(m.__file__).relative_to(m.ROOT)),'extractor_sha256':m.sha(Path(m.__file__).read_bytes())})
 with (out/'extraction-final.json').open('x') as f:json.dump(records,f,indent=2);f.write('\n')
