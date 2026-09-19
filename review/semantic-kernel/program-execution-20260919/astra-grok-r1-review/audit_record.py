import subprocess,json,hashlib,datetime,pathlib,sys
out=pathlib.Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260919/astra-grok-r1-review')
label,cwd,*argv=sys.argv[1:]; start=datetime.datetime.now(datetime.timezone.utc).isoformat()
p=subprocess.run(argv,cwd=cwd,capture_output=True)
record={'label':label,'argv':argv,'cwd':cwd,'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'exit':p.returncode}
for name,data in [('stdout',p.stdout),('stderr',p.stderr)]:
 f=out/(label+'.'+name);f.write_bytes(data);record[name]={'path':f.name,'sha256':hashlib.sha256(data).hexdigest()}
f=out/'commands.json'; items=json.loads(f.read_text()) if f.exists() else [];items.append(record);f.write_text(json.dumps(items,indent=2)+'\n');print(json.dumps(record));print(p.stdout.decode());print(p.stderr.decode());sys.exit(p.returncode)
