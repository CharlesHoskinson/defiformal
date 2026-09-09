from pathlib import Path
import subprocess,json,os,time
R=Path(__file__).resolve().parent.parent
summary=[]
for mode in ['intact','mismatch','empty-selection','missing-tool','malformed','fixture-omission','fixture-type-error','fixture-extra','lean-text','recorder-controls']:
 d=R/'fresh'/mode;d.mkdir(parents=True,exist_ok=True);ev=R/'fresh/intact' if mode=='mismatch' else d
 argv=['python3','-B',str(R/'probes/private_campaign.py'),'--mode',mode,'--evidence',str(ev)];start=time.monotonic()
 with (d/'wrapper.stdout').open('w') as so,(d/'wrapper.stderr').open('w') as se:r=subprocess.run(argv,stdout=so,stderr=se,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),timeout=35)
 v={'mode':mode,'argv':argv,'actual_exit':r.returncode,'seconds':time.monotonic()-start};(d/'wrapper-receipt.json').write_text(json.dumps(v,indent=2)+'\n');summary.append(v)
(R/'logs/fresh-cli-controls.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2))
