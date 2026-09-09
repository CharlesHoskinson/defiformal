"""Diagnostic output corruption after real invocation; no production-mutant credit."""
import os,sys,subprocess,json,hashlib
from pathlib import Path
review=Path(__file__).resolve().parents[1]
args=sys.argv[1:];name=args[args.index('--name')+1]
original=review/'candidate/scripts/token0_p16/record_cmd.py'
r=subprocess.run([sys.executable,'-B',str(original),*args])
if name=='T0-ID-SKIP-designated-P16-I-ADD' and r.returncode==0:
 p=Path(args[args.index('--out')+1]);v=json.loads(p.read_text());so=Path(v['stdout_path'])
 error=os.environ['P16_R6_REVIEW_ERROR']
 assert error in ('error: execution reverted','error: invalid opcode: INVALID')
 before={'receipt':v,'stdout_hex':so.read_bytes().hex()}
 p.with_name('reviewer-relay-original.json').write_text(json.dumps(before,indent=2)+'\n')
 so.write_text('0x\n0x\n'+error+'\n');b=so.read_bytes()
 v['stdout_sha256']=hashlib.sha256(b).hexdigest();v['stdout_bytes']=len(b)
 p.write_text(json.dumps(v,indent=2)+'\n')
sys.exit(r.returncode)
