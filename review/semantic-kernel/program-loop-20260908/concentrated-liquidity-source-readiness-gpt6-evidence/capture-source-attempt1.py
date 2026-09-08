from pathlib import Path
import urllib.request,json,hashlib,datetime,re,posixpath,concurrent.futures
r=Path.cwd();e=r/'review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence'; commit='e3589b192d0be27e100cd0daaf6c97204fdb1899';tree={x['path']:x for x in json.loads((e/'tree.json').read_text())['tree']};rows=json.loads((e/'retrievals.json').read_text());got={};edges={}
def fetch(name):
 url=f'https://raw.githubusercontent.com/Uniswap/v3-core/{commit}/{name}';start=datetime.datetime.now(datetime.timezone.utc).isoformat()
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'FormalDeFi-source-readiness-audit'}),timeout=30) as x:b=x.read();status=x.status;headers=dict(x.headers);final=x.url
 blob=hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest();assert blob==tree[name]['sha'],name
 p=e/'upstream'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
 return name,b,{'url':url,'final_url':final,'retrieved_utc':start,'status':status,'path':str(p.relative_to(r)),'upstream_path':name,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'git_blob_sha1':blob,'git_tree_blob_matches':True,'headers':headers}
roots=['contracts/UniswapV3Pool.sol','contracts/libraries/SwapMath.sol','contracts/libraries/TickMath.sol','contracts/libraries/TickBitmap.sol'];pending=roots+['LICENSE','contracts/libraries/LICENSE','contracts/libraries/LICENSE_MIT','contracts/interfaces/LICENSE','README.md','package.json','hardhat.config.ts','yarn.lock']
while pending:
 with concurrent.futures.ThreadPoolExecutor(max_workers=6) as ex: batch=list(ex.map(fetch,pending))
 pending=[]
 for name,b,row in batch:
  got[name]=row;rows.append(row)
  if name.endswith('.sol'):
   imports=re.findall(r'import\s+[\'"]([^\'"]+)[\'"]\s*;',b.decode());edges[name]=[posixpath.normpath(posixpath.join(posixpath.dirname(name),x)) for x in imports]
  else:edges[name]=[]
 for deps in edges.values():
  for name in deps:
   if name not in got and name not in pending:pending.append(name)
 (e/'retrievals.json').write_text(json.dumps(rows,indent=2)+'\n')
(e/'source-closure.json').write_text(json.dumps({'commit':commit,'roots':roots,'source_files':got,'imports':edges,'local_imports_complete':all(d in got for deps in edges.values() for d in deps),'scope':'Static Solidity import closure of Pool and explicit math/tick roots; not whole repository, npm package, tests, compiler installation, or deployed bytecode.'},indent=2)+'\n')
print(json.dumps({'files':len(got),'solidity':sum(p.endswith('.sol') for p in got),'imports_complete':True,'bytes':sum(x['bytes'] for x in got.values())}))
