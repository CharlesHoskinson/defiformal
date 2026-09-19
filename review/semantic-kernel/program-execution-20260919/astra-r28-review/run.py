import subprocess,json,datetime,hashlib,pathlib,sys
out=pathlib.Path(__file__).parent
cmd=sys.argv[1:]; ident=datetime.datetime.now(datetime.timezone.utc).strftime('%H%M%S%f'); log=out/(ident+'.log'); start=datetime.datetime.now(datetime.timezone.utc).isoformat()
with log.open('w') as f:
 p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
entry=dict(argv=cmd,cwd=str(pathlib.Path.cwd()),start=start,end=datetime.datetime.now(datetime.timezone.utc).isoformat(),exit_code=p.returncode,raw_output=str(log),sha256=hashlib.sha256(log.read_bytes()).hexdigest())
pth=out/'commands.json'; rows=json.loads(pth.read_text()) if pth.exists() else []; rows.append(entry); pth.write_text(json.dumps(rows,indent=2)+'\n'); print(json.dumps(entry)); print(log.read_text()[-18000:]); sys.exit(p.returncode)
