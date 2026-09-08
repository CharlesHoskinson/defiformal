import subprocess,sys,time,json,os
from pathlib import Path
R=Path(__file__).resolve().parent.parent;out=[]
for mode in ['missing-receipt','unknown-stdout','crash-partial','stale-receipt','malformed-receipt','missing-fixture','lean-false']:
 d=R/'faults'/mode;d.mkdir(parents=True,exist_ok=True);argv=[sys.executable,'-B',str(R/'probes/fault_campaign.py'),mode,str(d)];start=time.monotonic()
 with (d/'wrapper.stdout').open('w') as so,(d/'wrapper.stderr').open('w') as se:r=subprocess.run(argv,stdout=so,stderr=se,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),timeout=25)
 score=json.loads((d/'campaign-score.json').read_text()) if (d/'campaign-score.json').exists() else None
 row={'mode':mode,'argv':argv,'actual_exit':r.returncode,'seconds':time.monotonic()-start,'score':score};(d/'wrapper-receipt.json').write_text(json.dumps(row,indent=2)+'\n');out.append(row)
(R/'logs/fault-campaign-summary.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps([{'mode':r['mode'],'exit':r['actual_exit'],'status':r['score']['status'] if r['score'] else None,'baseline':r['score']['baseline'] if r['score'] else None,'mutants':r['score']['mutants'] if r['score'] else None} for r in out],indent=2))
