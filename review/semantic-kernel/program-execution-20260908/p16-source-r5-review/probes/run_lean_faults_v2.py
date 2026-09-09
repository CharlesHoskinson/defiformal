import subprocess,json,os,time
from pathlib import Path
R=Path(__file__).resolve().parent.parent;summary=[]
for mode in ['compiler-nonzero','malformed-extra']:
 d=R/'faults'/mode;d.mkdir(parents=True,exist_ok=True);argv=['python3','-B',str(R/'probes/lean_failure_campaign.py'),mode,str(d)];start=time.monotonic()
 with (d/'wrapper.stdout').open('w') as so,(d/'wrapper.stderr').open('w') as se:r=subprocess.run(argv,stdout=so,stderr=se,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),timeout=30)
 v={'mode':mode,'argv':argv,'actual_exit':r.returncode,'seconds':time.monotonic()-start,'score':json.loads((d/'campaign-score.json').read_text())};(d/'wrapper-receipt.json').write_text(json.dumps(v,indent=2)+'\n');summary.append(v)
(R/'logs/lean-fault-summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps([{'mode':r['mode'],'actual_exit':r['actual_exit'],'lean_score':r['score']['lean_bindings']} for r in summary],indent=2))
