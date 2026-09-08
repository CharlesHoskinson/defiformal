#!/usr/bin/env python3
import datetime,json,pathlib,subprocess,time,signal,os
OUT=pathlib.Path(__file__).resolve().parent
CWD=pathlib.Path('/home/charl/defiformal-wt-lifecycle-grok-gpt6-20260908/lean')
rows=[]
commands=[('lean-version',['lake','env','lean','--version']),('lake-build',['lake','build']+['DefiKernel.CapabilityProvenance.'+n for n in ['Origins','Observation','Trace','FoundationChecks']])]
commands += [('direct-'+n.lower(),['lake','env','lean','DefiKernel/CapabilityProvenance/'+n+'.lean']) for n in ['Origins','Observation','Trace','FoundationChecks']]
for name,argv in commands:
 start=datetime.datetime.now(datetime.timezone.utc).isoformat(); tick=time.monotonic()
 with (OUT/'logs'/f'{name}.stdout').open('wb') as stdout,(OUT/'logs'/f'{name}.stderr').open('wb') as stderr:
  p=subprocess.Popen(argv,cwd=CWD,stdout=stdout,stderr=stderr,start_new_session=True)
  try:rc=p.wait(timeout=600)
  except subprocess.TimeoutExpired:
   os.killpg(p.pid,signal.SIGTERM);p.wait();rc=124
 row=dict(name=name,argv=argv,cwd=str(CWD),start_utc=start,end_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),seconds=round(time.monotonic()-tick,3),exit=rc)
 rows.append(row);(OUT/'commands.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True)
 if rc:raise SystemExit(rc)
