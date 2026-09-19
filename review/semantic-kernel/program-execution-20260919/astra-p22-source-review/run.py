import pathlib, subprocess, sys, json, hashlib, datetime
O=pathlib.Path(__file__).parent
def h(b): return hashlib.sha256(b).hexdigest()
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
tag=sys.argv[1]; argv=[sys.executable,str(O/'probe.py')]+sys.argv[2:]
start=now(); p=subprocess.run(argv,cwd=str(O),capture_output=True); end=now()
(O/(tag+'.stdout')).write_bytes(p.stdout); (O/(tag+'.stderr')).write_bytes(p.stderr)
record={'argv':argv,'cwd':str(O),'start_utc':start,'end_utc':end,'exit':p.returncode,'stdout':tag+'.stdout','stderr':tag+'.stderr','stdout_sha256':h(p.stdout),'stderr_sha256':h(p.stderr),'script_sha256':h((O/'probe.py').read_bytes()),'runner_sha256':h(pathlib.Path(__file__).read_bytes()),'python_executable':sys.executable,'python_version':sys.version,'python_binary_sha256':h(pathlib.Path(sys.executable).read_bytes())}
(O/(tag+'.command.json')).write_text(json.dumps(record,indent=2)+'\n')
print(p.stdout.decode()); print(p.stderr.decode(),file=sys.stderr); sys.exit(p.returncode)
