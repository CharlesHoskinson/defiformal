import subprocess,sys,datetime,json,hashlib,pathlib
r=pathlib.Path(__file__).parent
label,cwd,*argv=sys.argv[1:]
start=datetime.datetime.now(datetime.timezone.utc).isoformat()
p=subprocess.run(argv,cwd=cwd,capture_output=True)
end=datetime.datetime.now(datetime.timezone.utc).isoformat()
files={}
for ext,data in [('stdout',p.stdout),('stderr',p.stderr)]:
 f=r/(label+'.'+ext);f.write_bytes(data);files[f.name]=hashlib.sha256(data).hexdigest()
with (r/'commands.jsonl').open('a') as f:f.write(json.dumps(dict(label=label,argv=argv,cwd=cwd,start=start,end=end,exit=p.returncode,raw_sha256=files))+'\n')
print(p.stdout.decode(errors='replace'));print(p.stderr.decode(errors='replace'),file=sys.stderr);sys.exit(p.returncode)
