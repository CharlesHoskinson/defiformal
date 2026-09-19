import sys,subprocess,json,datetime,hashlib,pathlib
root=pathlib.Path(__file__).parent
label,cwd,*argv=sys.argv[1:]; d=root/'commands'/label; d.mkdir(parents=True,exist_ok=False)
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
r={'argv':argv,'cwd':cwd,'start':now()}; (d/'started.json').write_text(json.dumps(r,indent=2))
with (d/'stdout').open('wb') as o,(d/'stderr').open('wb') as e:
 p=subprocess.Popen(argv,cwd=cwd,stdout=o,stderr=e); r['pid']=p.pid; r['exit']=p.wait()
r['end']=now();r['sha256']={n:hashlib.sha256((d/n).read_bytes()).hexdigest() for n in ['stdout','stderr']};(d/'receipt.json').write_text(json.dumps(r,indent=2));print(json.dumps(r));print((d/'stdout').read_text());print((d/'stderr').read_text(),file=sys.stderr);sys.exit(r['exit'])
