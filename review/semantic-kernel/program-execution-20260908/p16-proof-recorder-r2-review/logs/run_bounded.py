from pathlib import Path
import subprocess,time,os,signal,json,sys,datetime
r=Path(__file__).parent;cwd=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p16-proof-diagnostic-sandbox/lean')
name=sys.argv[1];limit=float(sys.argv[2]);argv=sys.argv[3:];t=time.monotonic();p=subprocess.Popen(argv,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True);expired=False
try:o,e=p.communicate(timeout=limit)
except subprocess.TimeoutExpired:
 expired=True;os.killpg(p.pid,signal.SIGKILL);o,e=p.communicate()
(r/(name+'.stdout')).write_bytes(o);(r/(name+'.stderr')).write_bytes(e)
d={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':argv,'cwd':str(cwd),'timeout_limit':limit,'timeout':expired,'exit':p.returncode,'seconds':time.monotonic()-t,'process_group_killed_on_timeout':expired}
(r/(name+'.json')).write_text(json.dumps(d,indent=2)+'\n');print(json.dumps(d));print(o.decode(errors='replace')[-6500:]);print(e.decode(errors='replace')[-1000:])
