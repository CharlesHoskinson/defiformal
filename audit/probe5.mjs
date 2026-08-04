import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E=T.MECH;
// Monte-Carlo density of Adm at 58 elements, over several inclusion probabilities
for(const p of [0.1,0.15,0.2,0.3,0.5]){
  let a=0,N=400000;
  for(let r=0;r<N;r++){const X=new Set(E.filter(()=>Math.random()<p)); if(T.admissible(X))a++;}
  console.log(`p=${p}: admissible ${a}/${N} = ${(a/N).toExponential(2)}`);
}
// crude lower bound on |Adm|: count admissible sets of size <=3 and <=4
let c=0;
(function rec(s,cur){ if(cur.length&&T.admissible(new Set(cur)))c++; if(cur.length===3)return;
  for(let i=s;i<E.length;i++){cur.push(E[i]);rec(i+1,cur);cur.pop();}})(0,[]);
console.log("admissible sets of size<=3:",c);
// anti-exchange: PROVE-style check over ALL closed sets of the definite closure in a random sample
const DEF=[]; for(const law of T.PARSED_NEW) for(const s of law.subjects) for(const t of law.terms)
  if(!t.external&&t.alts.length===1&&t.alts[0]!==s) DEF.push([s,t.alts[0]]);
const Cn=X=>{const Y=new Set(X);let ch=true;while(ch){ch=false;for(const[b,h]of DEF) if(Y.has(b)&&!Y.has(h)){Y.add(h);ch=true;}}return Y;};
const isClosed=X=>DEF.every(([b,h])=>!X.has(b)||X.has(h));
let tested=0,viol=0;
for(let r=0;r<200000;r++){
  const A=Cn(new Set(E.filter(()=>Math.random()<0.4)));
  const out=E.filter(e=>!A.has(e)); if(out.length<2) continue;
  const x=out[Math.floor(Math.random()*out.length)]; let y=out[Math.floor(Math.random()*out.length)];
  if(x===y) continue;
  if(Cn(new Set([...A,y])).has(x)){ tested++; if(Cn(new Set([...A,x])).has(y)) viol++; }
}
console.log(`anti-exchange over RANDOM closed sets (not just <=2-generated): premise held ${tested}, violations ${viol}`);
console.log("bodies∩heads empty =>", "Cn(A∪{y}) = A∪{y}∪heads(y); heads are never bodies");
