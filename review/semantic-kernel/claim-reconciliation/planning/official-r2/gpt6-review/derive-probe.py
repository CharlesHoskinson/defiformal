from pathlib import Path
import json,math,hashlib,sys
E=Path(__file__).resolve().parent;x=json.loads((E/'probe-source.stdout').read_bytes());result=[]
M=x['mechanisms']; assert len(M)==58 and len(set(M))==58 and len(x['symbols'])==59
for name,rows in [('LSTAR',x['lstar']),('PARSED_NEW',[(l['id'],l['subjects'],[t['alts']for t in l['terms']if not t['external']])for l in x['parsed']])]:
 allrows=rows if name=='LSTAR'else[(l['id'],l['subjects'],[t['alts']for t in l['terms']])for l in x['parsed']]
 outside=[{'law':i,'name':n}for i,ss,tt in allrows for n in ss+sum(tt,[])if n not in M];assert not outside
 arcs=[(s,t[0])for i,ss,tt in rows for t in tt if len(t)==1 for s in ss if s!=t[0]];edges=set(arcs)
 def close(S):
  S=set(S)
  while True:
   N=S|{v for u,v in edges if u in S}
   if N==S:return frozenset(S)
   S=N
 gens=[close([a,b])for i,a in enumerate(M)for b in M[i:]];closed=set(gens)|{frozenset()}
 rank={v:0 for v in M}
 for _ in M:
  for u,v in sorted(edges):rank[v]=max(rank[v],rank[u]+1)
 assert all(rank[u]<rank[v]for u,v in edges)
 counts=[len(arcs),len(edges),len(closed),sum((58-len(s))*(57-len(s))for s in closed),sum(len(close([v]))==1 for v in M)]
 assert counts==([13,12,1700,5169336,49]if name=='LSTAR'else[16,15,1697,5142758,48])
 result.append({'name':name,'counts':counts,'rank':rank,'edges':sorted(edges),'outside':outside})
assert all(all(c[k]for k in ['adm','requirements','warrants','hazards','grounded'])for c in x['candidates'])
assert 'X2'in x['union_bans']
out={'all_pass':True,'instances':result,'equality_seeds':58+math.comb(58,2)+math.comb(58,3),'union_splits':math.comb(58,3),'composition_pairs':1711*1712//2,'python_executable':sys.executable,'python_sha256':hashlib.sha256(Path(sys.executable).read_bytes()).hexdigest(),'python_version':sys.version,'scope':'Finite source-derived planning probe; no m5 execution, no universal theorem or deployment claim.'}
(E/'derived-probe.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({'all_pass':True,'instances':[{'name':i['name'],'counts':i['counts']}for i in result]}))
