/* D: IS ex COMPOSITIONAL?
 *  ex(A) = unique minimal generator of closed A = the <=-minimal elements of A
 *          (u <= v iff u reaches v in the definite digraph).
 *  CLAIM: ex(Cn(A u B)) = min_<= ( ex(A) u ex(B) ).
 *  Note the trivial reading first: ex is a BIJECTION closed-sets <-> antichains,
 *  so "is it a function of ex(A),ex(B)" is yes for vacuous reasons. The content
 *  is the FORMULA: local, pairwise, no reference to A or B beyond their extremes.
 */
import { PARSED_NEW, MECH } from "./tables.mjs";
const E58 = MECH.slice();
const mkCl = succ => S => { const X=new Set(S), st=[...S];
  while(st.length){const v=st.pop(); for(const w of (succ.get(v)||[])) if(!X.has(w)){X.add(w);st.push(w);}} return X; };
const succ58=new Map(E58.map(e=>[e,new Set()]));
for(const law of PARSED_NEW) for(const t of law.terms){ if(t.external||t.alts.length!==1)continue;
  for(const s of law.subjects) if(succ58.has(s)&&succ58.has(t.alts[0])) succ58.get(s).add(t.alts[0]); }
const K=A=>[...A].sort().join(",");
let seed=7; const rnd=()=>(seed=(seed*1103515245+12345)&0x7fffffff)/0x7fffffff;

function make(E,succ){
  const cl=mkCl(succ), R=new Map(E.map(e=>[e,cl([e])]));
  const rc=(u,v)=>R.get(u).has(v);
  const min=T=>{const a=[...new Set(T)];return a.filter(x=>!a.some(u=>u!==x&&rc(u,x))).sort();};
  return {cl,R,rc,ex:A=>min([...A]),min,
    cyclic:E.some(x=>E.some(y=>x<y&&R.get(x).has(y)&&R.get(y).has(x)))};
}
function allClosed(E,succ){const cl=mkCl(succ),out=new Map();
  for(let m=0;m<(1<<E.length);m++){const A=[];for(let i=0;i<E.length;i++)if(m&(1<<i))A.push(E[i]);
    const c=cl(A); if(c.size===A.length) out.set(K(c),c);} return [...out.values()];}

function run(E,succ,label,C,cap){
  const g=make(E,succ);
  let genFail=0, bijFail=0; const seenEx=new Map();
  for(const A of C){ const e=g.ex(A);
    if(K(g.cl(e))!==K(A)) genFail++;                       // ex generates
    const k=e.join(","); if(seenEx.has(k)&&seenEx.get(k)!==K(A)) bijFail++; seenEx.set(k,K(A));
  }
  let pairs=[]; const N=C.length;
  if(N*N<=cap){ for(const A of C) for(const B of C) pairs.push([A,B]); }
  else { for(let i=0;i<cap;i++) pairs.push([C[Math.floor(rnd()*N)],C[Math.floor(rnd()*N)]]); }
  let ok=0, sub=0; const bad=[];
  for(const [A,B] of pairs){
    const U=g.cl([...A,...B]);
    const lhs=g.ex(U).join(","), rhs=g.min([...g.ex(A),...g.ex(B)]).join(",");
    if(lhs===rhs) ok++; else if(bad.length<5) bad.push({A:K(A),B:K(B),lhs,rhs});
    if(g.ex(U).every(e=>g.ex(A).includes(e)||g.ex(B).includes(e))) sub++;
  }
  const mode=N*N<=cap?"EXHAUSTIVE":"sampled";
  console.log(`${label.padEnd(30)} closed=${String(N).padStart(6)} pairs=${String(pairs.length).padStart(8)}(${mode}) ex-gen-fail=${genFail} ex-inj-fail=${bijFail} FORMULA=${ok}/${pairs.length} subset-law=${sub}/${pairs.length}`);
  for(const b of bad) console.log(`     *** COUNTEREXAMPLE A={${b.A}} B={${b.B}} lhs={${b.lhs}} rhs={${b.rhs}}`);
  return {ok,n:pairs.length,bad};
}

console.log("=== (1) reduced ground sets, EXHAUSTIVE over all closed sets AND all pairs ===");
for(const sub of [["Pl","Im","Cd","Pf","Op","Ct","Ex","Li"],
                  ["Pf","Pl","Uc","Of","Ct","Ex","Li","Aw","At","Xm","Xf"],
                  ["Pf","Uc","Py","Of","Rl","Gs","Ct","Ex","Li","Aw","At","Ep","Rd","Xm","Xf","Au"]]){
  const s=new Map(sub.map(e=>[e,new Set([...(succ58.get(e)||[])].filter(x=>sub.includes(x)))]));
  run(sub,s,`reduced |E|=${sub.length}`,allClosed(sub,s),4000000);
}
console.log("\n=== (2) the ACTIVE 20 of the real atlas: all 52,500 closed sets, 4M sampled pairs ===");
const ACT=E58.filter(e=>succ58.get(e).size>0||E58.some(s=>succ58.get(s).has(e)));
const sAct=new Map(ACT.map(e=>[e,new Set([...succ58.get(e)].filter(x=>ACT.includes(x)))]));
run(ACT,sAct,"active-20",allClosed(ACT,sAct),4000000);

console.log("\n=== (3) full 58, sampled closed sets ===");
const cl58=mkCl(succ58); const samp=new Map();
while(samp.size<1500){const k=1+Math.floor(rnd()*14);const s=new Set();while(s.size<k)s.add(E58[Math.floor(rnd()*58)]);
  const c=cl58([...s]); samp.set(K(c),c);}
run(E58,succ58,"58-element",[...samp.values()],4000000);

console.log("\n=== (4) RANDOM DIGRAPHS: is the formula general, or about our instance? ===");
function randGraph(n,p,acyclic){const V=[...Array(n).keys()].map(String);
  const s=new Map(V.map(v=>[v,new Set()]));
  for(let i=0;i<n;i++)for(let j=0;j<n;j++){if(i===j)continue;if(acyclic&&j<i)continue;if(rnd()<p)s.get(V[i]).add(V[j]);}
  return [V,s];}
for(const [n,p,acy,lab] of [[8,.15,true,"random DAG n=8 p=.15"],[9,.35,true,"random DAG n=9 p=.35"],
                            [10,.20,true,"random DAG n=10 p=.20"],[7,.20,false,"random CYCLIC n=7 p=.20"],
                            [7,.35,false,"random CYCLIC n=7 p=.35"]]){
  let tot=0,okAll=0,graphs=0,cyc=0,exGenFail=0;
  for(let t=0;t<120;t++){const [V,s]=randGraph(n,p,acy); const g=make(V,s); if(g.cyclic)cyc++;
    const C=allClosed(V,s); graphs++;
    for(const A of C) if(K(g.cl(g.ex(A)))!==K(A)) exGenFail++;
    for(const A of C)for(const B of C){tot++;
      const U=g.cl([...A,...B]);
      if(g.ex(U).join(",")===g.min([...g.ex(A),...g.ex(B)]).join(","))okAll++;}}
  console.log(`${lab.padEnd(24)} graphs=${graphs} (nontrivial SCC: ${cyc})  ex-generates-fails=${exGenFail}  formula=${okAll}/${tot} = ${(100*okAll/tot).toFixed(4)}%`);
}
