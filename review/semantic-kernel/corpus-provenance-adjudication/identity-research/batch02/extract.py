#!/usr/bin/env python3
"""Offline reproducible text extraction. No network, no script execution."""
import hashlib,html.parser,json,pathlib,datetime
B=pathlib.Path(__file__).resolve().parent
class Text(html.parser.HTMLParser):
 def __init__(self):super().__init__(convert_charrefs=True);self.skip=0;self.parts=[]
 def handle_starttag(self,t,a):
  if t in ('script','style','noscript'):self.skip+=1
 def handle_endtag(self,t):
  if t in ('script','style','noscript') and self.skip:self.skip-=1
 def handle_data(self,d):
  if not self.skip and d.strip():self.parts.append(d.strip())
def sha(b):return hashlib.sha256(b).hexdigest()
if __name__=='__main__':
 records=[];(B/'derived').mkdir(exist_ok=True)
 for p in sorted((B/'captures').glob('*/capture.json')):
  x=json.loads(p.read_text());a=x['attempts'][-1]
  if not a['transport_body_success']:continue
  body=next(f for f in a['files'] if f['path'].endswith('.body'));raw=(B/body['path']).read_bytes();s=raw.decode('utf-8',errors='replace')
  if '<html' in s[:2000].lower() or '<!doctype html' in s[:2000].lower():
   parser=Text();parser.feed(s);data=('\n'.join(parser.parts)+'\n').encode();method='Python HTMLParser; skip script/style/noscript; stripped data nodes joined LF'
  else:data=raw;method='Identity bytes (JSON, Markdown or source code); no transformation'
  dest=B/'derived'/f"{x['id']}.txt"
  if dest.exists():assert dest.read_bytes()==data
  else:dest.write_bytes(data)
  records.append({'target_id':x['id'],'url':x['url'],'original':body,'derived':{'path':str(dest.relative_to(B)),'sha256':sha(data),'bytes':len(data)},'method':method})
 out=B/'extraction.json'
 obj={'extractor_sha256':sha(pathlib.Path(__file__).read_bytes()),'sources':records}
 if out.exists():assert json.loads(out.read_text())==obj
 else:out.write_text(json.dumps(obj,indent=2)+'\n')
 print(len(records),'extractions')
