from pathlib import Path
import json,re,hashlib,math,datetime,subprocess,shutil,time
R=Path('/home/charl/defiformal');O=Path(__file__).resolve().parent;C=R/'openspec/changes/historical-claim-reconciliation';checks=[]
def ck(n,v):checks.append({'check':n,'passed':bool(v)})
sp=list((C/'specs').glob('*/spec.md'));req=[];sc=[]
for p in sp:
 s=p.read_text();req+=re.findall(r'^### Requirement: (\S+)',s,re.M);sc+=re.findall(r'^#### Scenario: (\S+)',s,re.M)
tasks=re.findall(r'^- \[ \] (\d+\.\d+)',(C/'tasks.md').read_text(),re.M)
ctrl=json.loads((C/'control-inventory.json').read_text())['controls']; cm=json.loads((C/'claim-disposition-map.json').read_text());sm=json.loads((C/'scenario-map.json').read_text())
ck('scope 4/18/45/27/22',list(map(len,[sp,req,sc,tasks,ctrl]))==[4,18,45,27,22])
ck('unique requirement/scenario/task/control IDs',all(len(x)==len(set(x)) for x in [req,sc,tasks,[c['id'] for c in ctrl]]))
ck('all controls map existing scenarios',all(c['scenario'] in sc for c in ctrl))
# A planning-local independent structural calculation, not execution of m5 or a universal proof.
s=(R/'viz/src/data.ts').read_text();t=(R/'formal/v2/tables.mjs').read_text()
el=re.findall(r'\{\s*id:\s*"([^\"]+)",\s*sym:\s*"([^\"]+)",\s*name:\s*"([^\"]*)",\s*group:\s*"([^\"]+)",\s*stratum:\s*(\d),\s*atom:\s*"([NRI])",\s*status:\s*"([a-z]+)"',s)
syms={r[1] for r in el};E=[r[1] for r in el if r[6]!='limit'];ck('58 unique mechanism symbols',len(E)==len(set(E))==58)
vars={k:json.loads(v) for k,v in re.findall(r'const (PRICE|INDEX|LOSS|TERMINAL) = (\[[^;]+);',t)}
raw=re.search(r'export const LSTAR = (\[.*?\n\]);',t,re.S).group(1)
for k,v in vars.items():raw=re.sub(r'\b'+k+r'\b',json.dumps(v),raw)
L=json.loads(re.sub(r',\s*([\]}])',r'\1',raw));P=[];decisions=[]
bare=lambda q:re.sub(r'[()]','',re.sub(r'\{[^}]*\}','',q)).strip()
for id,rule in re.findall(r'\{\s*id:\s*"(L\d+)",\s*rule:\s*"([^\"]+)"',s):
 lhs,rhs=(rule.split('→')+[''])[:2];subs=[x for x in map(bare,lhs.split('|')) if x in syms];terms=[]
 for chunk in rhs.split('+'):
  parts=list(map(bare,chunk.strip().split('|')));alts=[x for x in parts if x in syms];external=not alts or len(alts)<len(parts)
  decisions.append({'id':id,'subjects':subs,'raw':chunk.strip(),'alternatives':alts,'external':external})
  if not external:terms.append(alts)
 P.append([id,subs,terms])
results=[]
for label,laws,expected in [('LSTAR',L,(13,12,1700,5169336,49)),('PARSED_NEW',P,(16,15,1697,5142758,48))]:
 occ=[(a,term[0],id) for id,subs,terms in laws for term in terms if len(term)==1 for a in subs if a!=term[0]];edges=set((a,b) for a,b,id in occ)
 ck(label+' endpoint membership',all(a in E and b in E for a,b in edges))
 # Independently materialize paths by a Boolean relation fixed point; no historical Node run.
 reach={a:{a} for a in E}
 for a,b in edges:reach[a].add(b)
 for k in E:
  for a in E:
   if k in reach[a]:reach[a]|=reach[k]
 ck(label+' antisymmetry',all(a==b or a not in reach[b] for a in E for b in reach[a]))
 rank={a:len([b for b in E if a in reach[b]])-1 for a in E}
 ck(label+' literal rank possible',all(rank[a]<rank[b] for a,b in edges))
 close=lambda seed:frozenset().union(*(reach[a] for a in seed))
 states={close([a,b]) for i,a in enumerate(E) for b in E[i:]}|{frozenset()};outside=sum((58-len(A))*(57-len(A)) for A in states);own=sum(len(reach[a])==1 for a in E)
 ck(label+' independent structural expected counters',(len(occ),len(edges),len(states),outside,own)==expected)
 essential=[]
 for a,b in sorted(edges):
  # Both graphs have sink heads; still check omission changes a reachable target.
  seen={a}
  for _ in E:
   seen|={v for u,v in edges-{(a,b)} if u in seen}
  if b not in seen:essential.append([a,b])
 ck(label+' nonvacuous edge omission available',bool(essential))
 results.append({'label':label,'occurrences':occ,'edges':sorted(edges),'rank':rank,'closed_states_including_empty':len(states),'ordered_outside_pairs':outside,'principal_singleton_count':own,'essential_edges':essential})
ck('seed/split/index-pair arithmetic',[58+math.comb(58,2)+math.comb(58,3),math.comb(58,3),58*59//2,(58*59//2)*(58*59//2+1)//2]==[32567,30856,1711,1464616])
cmd=[shutil.which('openspec'),'validate','historical-claim-reconciliation','--strict'];start=time.monotonic();p=subprocess.run(cmd,cwd=R,capture_output=True);duration=time.monotonic()-start
(O/'strict.stdout').write_bytes(p.stdout);(O/'strict.stderr').write_bytes(p.stderr);ck('fresh strict OpenSpec',p.returncode==0)
report={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':dict(zip(['capabilities','requirements','scenarios','unchecked_tasks','planned_controls'],map(len,[sp,req,sc,tasks,ctrl]))),'scenario_map_keys':list(sm),'claim_map_keys':list(cm),'requirements':req,'scenarios':sc,'tasks':tasks,'checks':checks,'structural_graph_calculation':results,'parsed_term_decisions':decisions,'strict':{'command':cmd,'exit':p.returncode,'seconds':duration,'stdout_sha256':hashlib.sha256(p.stdout).hexdigest(),'stderr_sha256':hashlib.sha256(p.stderr).hexdigest()},'limits':'Source-derived Python planning calculation only; no actual m5, Lean build, new kernel proof, or production control run.'}
(O/'plan-checks.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'passed':all(c['passed'] for c in checks),'checks':len(checks),'scope':report['scope'],'maps':report['scenario_map_keys']}));assert all(c['passed'] for c in checks)
