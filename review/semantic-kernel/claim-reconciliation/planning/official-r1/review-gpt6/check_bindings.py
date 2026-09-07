from pathlib import Path
import json,hashlib,subprocess,datetime,sys
R=Path('/home/charl/defiformal'); O=Path(__file__).resolve().parent; P=O.parent
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((P/'manifest.json').read_bytes());b=(P/'bundle.md').read_bytes(); checks=[];rows=[]
def ck(name,v):
 checks.append({'check':name,'passed':bool(v)})
ck('candidate exact',m['candidate']=='bbbc303ada632685520c416adda50a6f8aace710')
ck('70 inputs',len(m['inputs'])==m['input_count']==70)
ck('bundle exact SHA',sha(b)==m['bundle_sha256']=='02853a5322e617e08995e8962c57cbbc24ada35f7755dfbb5016d44f0b51aa5f')
ck('bundle size',len(b)==m['bundle_bytes']); head=b.split(b'\n\n## INPUT ',1)[0];parts=[head]
for r in m['inputs']:
 p=R/r['path'];data=p.read_bytes(); gitdata=subprocess.check_output(['git','show',m['candidate']+':'+r['path']],cwd=R)
 rendered=(json.dumps(json.loads(data),ensure_ascii=False,separators=(',',':'))+'\n').encode() if p.suffix=='.json' else data
 ck(r['path']+' source hash/length',sha(data)==r['sha256'] and len(data)==r['bytes'])
 ck(r['path']+' exact Git bytes',data==gitdata)
 ck(r['path']+' render hash/length',sha(rendered)==r['rendered_sha256'] and len(rendered)==r['rendered_bytes'])
 if p.suffix=='.json':ck(r['path']+' lossless JSON',json.loads(data)==json.loads(rendered))
 parts.extend([('\n\n## INPUT '+r['path']+'\nSource SHA256 '+sha(data)+'\nRendered SHA256 '+sha(rendered)+'\n\n').encode(),rendered])
 rows.append({'path':r['path'],'sha256':sha(data),'bytes':len(data),'git_blob':subprocess.check_output(['git','rev-parse',m['candidate']+':'+r['path']],cwd=R,text=True).strip()})
ck('whole bundle exact reconstruction',b==b''.join(parts))
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'candidate':m['candidate'],'bundle_sha256':sha(b),'manifest_sha256':sha((P/'manifest.json').read_bytes()),'checks':checks,'inputs':rows,'passed':all(x['passed'] for x in checks)}
(O/(sys.argv[1]+'.json')).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:v for k,v in result.items() if k not in ['checks','inputs']}));print('checks',len(checks));assert result['passed']
