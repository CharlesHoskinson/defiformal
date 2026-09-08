from pathlib import Path
import runpy,sys
sys.dont_write_bytecode=True
w=Path('/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908')
a=w/'review/semantic-kernel/uniswap-token0/p16/planning/grok-r2'
r=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-r2-planning-review/logs')
redirect={a/'logs/diagnose_r2.json':r/'diagnose_r2.json',a/'logs/diagnose-r1-replay.json':r/'diagnose-r1-replay.json'}
write,read,exists=Path.write_text,Path.read_text,Path.exists
def mapped(p): return redirect.get(p.resolve(),p)
def safe_write(p,*args,**kwargs):
 q=mapped(p)
 if q==p: raise PermissionError('unapproved replay write '+str(p))
 return write(q,*args,**kwargs)
Path.write_text=safe_write
Path.read_text=lambda p,*args,**kwargs:read(mapped(p),*args,**kwargs)
Path.exists=lambda p:exists(mapped(p))
sys.argv=[str(a/'diagnose_r2.py'),*sys.argv[1:]]
runpy.run_path(str(a/'diagnose_r2.py'),run_name='__main__')
