"""Offline extraction; whole HTML text nodes, excluding script/style/noscript; one trimmed node per LF line."""
from html.parser import HTMLParser
from pathlib import Path
import hashlib,json
BASE=Path(__file__).resolve().parent.parent;ROOT=BASE.parents[3]
sha=lambda b:hashlib.sha256(b).hexdigest()
class Text(HTMLParser):
 def __init__(self):super().__init__(convert_charrefs=True);self.skip=0;self.nodes=[]
 def handle_starttag(self,t,a):
  if t in ['script','style','noscript']:self.skip+=1
 def handle_endtag(self,t):
  if t in ['script','style','noscript']:self.skip=max(0,self.skip-1)
 def handle_data(self,data):
  if not self.skip and data.strip():self.nodes.append(data.strip())
if __name__=='__main__':
 for name in ['coinbase-cbbtc','btcb-cross-domain','cow-solver-collateral']:
  out=BASE/name;records=[]
  for path in sorted(out.rglob('retrievals.json')):
   d=json.loads(path.read_text())
   for row in d['records']:
    a=row['attempts'][-1]
    if a['status']!='retained' or not a['body_bytes']:continue
    body=(ROOT/a['capture_path']).read_bytes();p=Text();p.feed(body.decode('utf-8'));text=('\n'.join(p.nodes)+'\n').encode()
    dest=out/(row['source_id']+'.txt')
    with dest.open('xb') as f:f.write(text)
    records.append({'source_id':row['source_id'],'retrieval_record':str(path.relative_to(ROOT)),'capture_path':a['capture_path'],'capture_sha256':sha(body),'output_path':str(dest.relative_to(ROOT)),'output_sha256':sha(text),'text_nodes':len(p.nodes),'method':__doc__,'extractor_path':str(Path(__file__).resolve().relative_to(ROOT)),'extractor_sha256':sha(Path(__file__).read_bytes())})
  with (out/'extraction.json').open('x') as f:json.dump(records,f,indent=2);f.write('\n')
  print(name,len(records))
