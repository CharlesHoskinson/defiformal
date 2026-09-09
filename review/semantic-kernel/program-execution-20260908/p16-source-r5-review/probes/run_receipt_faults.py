import subprocess,json,os,time
from pathlib import Path
R=Path(__file__).resolve().parent.parent;rows=[]
for mode in ['unknown-error-output','wrong-status','wrong-argv','wrong-cwd','wrong-type','wrong-hash']:
 d=R/'receipt-faults'/mode;d.mkdir(parents=True,exist_ok=True);argv=['python3','-B',str(R/'probes/receipt_fault_campaign.py'),mode,str(d)];start=time.monotonic()
 with (d/'wrapper.stdout').open('w') as so,(d/'wrapper.stderr').open('w') as se:r=subprocess.run(argv,stdout=so,stderr=se,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),timeout=30)
 v={'mode':mode,'argv':argv,'actual_exit':r.returncode,'seconds':time.monotonic()-start,'score':json.loads((d/'campaign-score.json').read_text())};(d/'wrapper-receipt.json').write_text(json.dumps(v,indent=2)+'\n');rows.append(v)
(R/'logs/receipt-fault-summary.json').write_text(json.dumps(rows,indent=2)+'\n');print([(v['mode'],v['actual_exit']) for v in rows])
