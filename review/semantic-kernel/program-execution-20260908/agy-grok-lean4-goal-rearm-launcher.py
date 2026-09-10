import subprocess,json,selectors,time
from pathlib import Path
from datetime import datetime,timezone
thread='01a086a8-f46d-76a1-b40c-49a984f8f6d4'
objective='Resume and continuously advance the full authorized DeFiFormal core roadmap in /home/charl/defiformal: native AGY Gemini 3.8 Flash High (gemini-3.8-flash-high, effort high) implements; fresh native Grok4.6 (grok-4.6, reasoning effort high) independently audits. P17 and P18 are accepted and delivered. Resume P19 from frozen R11: AGY R12 repairs and finishes production codec proofs while fresh Grok audits isolated frozen R11. Continue every remaining authorized core milestone under the accepted roadmap using cameronfreer/lean4-skills. Preserve exact proof/execution/source identities and historical reviewer attribution. Root verifies, adjudicates, integrates and publishes accepted core and clearly unaccepted evidence only to semantic-kernel-pivot. Use semantic-kernel-pivot as the sole local and GitHub branch; isolated workers use detached working copies. No Foreman or extra windows. Atlas remains parked until explicitly resumed.'
out=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/agy-grok-lean4-goal-rearm-20260910.json')
p=subprocess.Popen(['codex','app-server','--listen','stdio://'],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=open('/tmp/defiformal-agy-grok-lean4-goal.stderr','w'),text=True,bufsize=1)
sel=selectors.DefaultSelector();sel.register(p.stdout,selectors.EVENT_READ)
def send(d):p.stdin.write(json.dumps(d)+'\n');p.stdin.flush()
def req(i,m,a):
 send({'id':i,'method':m,'params':a});deadline=time.monotonic()+40
 while time.monotonic()<deadline:
  if not sel.select(1):continue
  line=p.stdout.readline()
  if not line:raise RuntimeError('app-server closed')
  d=json.loads(line)
  if d.get('id')==i:
   if 'error' in d:raise RuntimeError(str(d['error']))
   return d['result']
 raise TimeoutError(m)
try:
 req(1,'initialize',{'clientInfo':{'name':'defiformal-user-authorized-resume','version':'1.0'},'capabilities':{'experimentalApi':True}});send({'method':'initialized','params':{}})
 before=req(2,'thread/goal/get',{'threadId':thread})
 after=req(3,'thread/goal/set',{'threadId':thread,'objective':objective,'status':'active'})
 readback=req(4,'thread/goal/get',{'threadId':thread})
 result={'schema':'user-authorized-goal-resume/v1','utc':datetime.now(timezone.utc).isoformat(),'user_instruction':'re-arm the loop and begin implementing with AGY Gemini writing and grok reviewing','method':'thread/goal/set','before':before,'after':after,'readback':readback,'transport':'codex app-server stdio','no_budget_change_requested':True}
 out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
finally:
 p.terminate()
 try:p.wait(timeout=5)
 except subprocess.TimeoutExpired:p.kill();p.wait()
