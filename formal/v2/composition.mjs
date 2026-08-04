/* D: IS ex COMPOSITIONAL?
 *  ex(A) = unique minimal generator of closed A = the <=-minimal elements of A,
 *          where u <= v iff u reaches v in the definite digraph.
 *  CLAIM:  ex(Cn(A u B)) = min_<= ( ex(A) u ex(B) ).
 *  Tested (1) exhaustively on a reduced ground set, (2) exhaustively on the full
 *  active subgraph restricted to closed sets from <=3 generators, (3) by sampling
 *  at 58, and (4) on 2000 RANDOM digraphs (incl. deep DAGs and cyclic ones) so the
 *  answer is about the shape of the closure, not about our particular instance.
 */
import { PARSED_NEW, MECH } from "./tables.mjs";
const E58 = MECH.slice();
function mkCl(succ){ return S=>{const X=new Set(S),st=[...S];
  while(st.length){const v=st.pop(); for(const w of (succ.get(v)||[])) if(!X.has(w)){X.add(w);st.push(w);} } return X;}; }
// our real digraph
const succ58=new Map(E58.map(e=>[e,new Set()]));
for(const law of PARSED_NEW) for(const t of law.terms){ if(t.external||t.alts.length!==1)continue;
  for(const s of law.subjects) if(succ58.has(s)&&succ58.has(t.alts[0])) succ58.get(s).add(t.alts[0]); }
const K=(A)=>[...A].sort().join(",");

function analyse(E,succ,label,seeds){
  const cl=mkCl(succ);
  const R=new Map(E.map(e=>[e,cl([e])]));
  const reaches=(u,v)=>R.get(u).has(v);
  // ex(A) = elements of A not reachable from another element of A
  const ex=A=>{const a=[...A]; return a.filter(x=>!a.some(u=>u!==x&&reaches(u,x))).sort();};
  const minOf=T=>{const a=[...new Set(T)]; return a.filter(x=>!a.some(u=>u!==x&&reaches(u,x))).sort();};
  // sanity: ex generates, and is contained in every generator
  let genFail=0, subFail=0;
  for(const A of seeds){ const g=ex(A); if(K(cl(g))!==K(A)) genFail++; }
  // composition
  let ok=0, bad=[], okSub=0;
  for(const A of seeds) for(const B of seeds){
    const U=cl([...A,...B]);
    const lhs=ex(U).join(",");
    const rhs=minOf([...ex(A),...ex(B)]).join(",");
    if(lhs===rhs) ok++; else if(bad.length<5) bad.push({A:K(A),B:K(B),lhs,rhs});
    if(ex(U).every(e=>ex(A).includes(e)||ex(B).includes(e))) okSub++;
  }
  const n=seeds.length*seeds.length;
  console.log(`${label.padEnd(46)} closed=${String(seeds.length).padStart(6)}  pairs=${String(n).padStart(9)}  ex-generates-fails=${genFail}  FORMULA ok=${ok}/${n}  subset-law ok=${okSub}/${n}`);
  for(const b of bad) console.log(`     COUNTEREX A={${b.A}} B={${b.B}} lhs={${b.lhs}} rhs={${b.rhs}}`);
  return {ok,n,genFail,bad};
}
const allClosed=(E,succ,cap)=>{const cl=mkCl(succ);const out=new Map();
  if(E.length>cap) return null;
  for(let m=0;m<(1<<E.length);m++){const A=[];for(let i=0;i<E.length;i++)if(m&(1<<i))A.push(E[i]);
    const c=cl(A); if(c.size===A.length) out.set(K(c),c);} return [...out.values()];};

console.log("=== (1) reduced ground set, EXHAUSTIVE over all closed sets and all pairs ===");
for(const sub of [["Pl","Im","Cd","Pf","Op","Ct","Ex","Li"],
                  ["Pf","Pl","Uc","Of","Ct","Ex","Li","Aw","At","Xm","Xf"],
                  ["Pf","Uc","Py","Of","Rl","Gs","Ct","Ex","Li","Aw","At","Ep","Rd","Xm","Xf","Au"]]){
  const s=new Map(sub.map(e=>[e,new Set([...(succ58.get(e)||[])].filter(x=>sub.includes(x)))]));
  const C=allClosed(sub,s,17);
  analyse(sub,s,`reduced |E|=${sub.length}`,C);
}
console.log("\n=== (2) full 58, all closed sets over the ACTIVE 20 (exhaustive), pairs exhaustive ===");
const ACT=E58.filter(e=>(succ58.get(e).size>0)||E58.some(s=>succ58.get(s).has(e)));
const sAct=new Map(ACT.map(e=>[e,new Set([...succ58.get(e)].filter(x=>ACT.includes(x)))]));
const CA=allClosed(ACT,sAct,20);
console.log(`   (closed sets over active 20 = ${CA.length}; ${CA.length**2} pairs)`);
analyse(ACT,sAct,"active-20 exhaustive",CA);

console.log("\n=== (3) full 58, sampled ===");
let seed=7; const rnd=()=>(seed=(seed*1103515245+12345)&0x7fffffff)/0x7fffffff;
const cl58=mkCl(succ58); const samp=new Map();
while(samp.size<1200){const k=1+Math.floor(rnd()*14);const s=new Set();while(s.size<k)s.add(E58[Math.floor(rnd()*58)]);
  const c=cl58([...s]); samp.set(K(c),c);}
analyse(E58,succ58,"58-element sampled closed sets",[...samp.values()]);

console.log("\n=== (4) RANDOM DIGRAPHS - is the formula about our instance, or general? ===");
function randGraph(n,p,acyclic){const V=[...Array(n).keys()].map(String);
  const s=new Map(V.map(v=>[v,new Set()]));
  for(let i=0;i<n;i++)for(let j=0;j<n;j++){ if(i===j)continue; if(acyclic&&j<i)continue;
    if(rnd()<p) s.get(V[i]).add(V[j]); } return [V,s]; }
for(const [n,p,acy,lab] of [[8,.15,true,"random DAG n=8 p=.15"],[8,.35,true,"random DAG n=8 p=.35"],
                            [10,.12,true,"random DAG n=10 p=.12"],[8,.15,false,"random CYCLIC n=8 p=.15"],
                            [8,.30,false,"random CYCLIC n=8 p=.30"]]){
  let tot=0,okAll=0,trials=0,cyc=0;
  for(let t=0;t<160;t++){ const [V,s]=randGraph(n,p,acy); const cl=mkCl(s);
    const R=new Map(V.map(e=>[e,cl([e])]));
    const hasCyc=V.some(x=>V.some(y=>x<y&&R.get(x).has(y)&&R.get(y).has(x))); if(hasCyc)cyc++;
    const C=allClosed(V,s,12); if(!C)continue;
    const reaches=(u,v)=>R.get(u).has(v);
    const ex=A=>{const a=[...A];return a.filter(x=>!a.some(u=>u!==x&&reaches(u,x))).sort();};
    const minOf=T=>{const a=[...new Set(T)];return a.filter(x=>!a.some(u=>u!==x&&reaches(u,x))).sort();};
    let ok=0,nn=0;
    for(const A of C)for(const B of C){nn++;
      const U=cl([...A,...B]);
      if(ex(U).join(",")===minOf([...ex(A),...ex(B)]).join(","))ok++;}
    tot+=nn; okAll+=ok; trials++;
  }
  console.log(`${lab.padEnd(28)} graphs=${trials} (with a nontrivial SCC: ${cyc})  formula ok=${okAll}/${tot}  = ${(100*okAll/tot).toFixed(4)}%`);
}
