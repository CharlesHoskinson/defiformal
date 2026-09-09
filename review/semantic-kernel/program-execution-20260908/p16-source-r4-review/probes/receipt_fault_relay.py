import sys,os,subprocess,json,hashlib
from pathlib import Path
args=sys.argv[1:];name=args[args.index('--name')+1];mode=os.environ['P16_R4_REVIEW_FAULT'];original='/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16/record_cmd.py'
r=subprocess.run([sys.executable,'-B',original,*args])
if name=='T0-ID-SKIP-designated-P16-I-ADD' and r.returncode==0:
 p=Path(args[args.index('--out')+1]);v=json.loads(p.read_text())
 if mode=='unknown-error-output':
  so=Path(v['stdout_path']);so.write_text('error: unrecognized diagnostic failure\n');b=so.read_bytes();v['stdout_sha256']=hashlib.sha256(b).hexdigest();v['stdout_bytes']=len(b)
 elif mode=='wrong-status':v['classification']='failure'
 elif mode=='wrong-argv':v['argv']=['wrong']
 elif mode=='wrong-cwd':v['cwd']='/wrong'
 elif mode=='wrong-type':v['exit']=False
 elif mode=='wrong-hash':v['stdout_sha256']='0'*64
 p.write_text(json.dumps(v,indent=2)+'\n')
sys.exit(r.returncode)
