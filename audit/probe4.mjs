import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E=T.MECH, D=T.DeltaInf, G=X=>T.gammaOpen(X).length===0;
const Dfix=X=>T.Delta1(X).size===X.size;
const key=S=>[...S].sort().join(",");

// (a) is Fix(G) ∩ Fix(D) union-closed  => complete lattice?  (the "over-retraction" test)
let n=0,uv=0,iv=0,emptyOK=G(new Set())&&Dfix(new Set());
const pool=[];
for(let r=0;r<600000 && pool.length<3000;r++){const X=new Set(E.filter(()=>Math.random()<0.18)); if(G(X)&&Dfix(X)) pool.push(X);}
for(let i=0;i<pool.length;i++)for(let j=i+1;j<Math.min(pool.length,i+60);j++){n++;
  const U=new Set([...pool[i],...pool[j]]); if(!(G(U)&&Dfix(U))) uv++;
  const I=new Set([...pool[i]].filter(x=>pool[j].has(x))); if(!(G(I)&&Dfix(I))) iv++;}
console.log(`(a) Fix(G)&Fix(D): empty set is a member? ${emptyOK};  pairs ${n}: UNION violations ${uv}, INTERSECTION violations ${iv}`);
const TOP=new Set(E); console.log(`    TOP in Fix(G)&Fix(D)? ${G(TOP)&&Dfix(TOP)}`);

// (b) reproduce prop:notresidual "33 of 63"
function residualCount(laws,label){
  const pairs=new Set(), bad=new Set(); let mult=0, mbad=0;
  for(const [id,subs,terms] of laws) for(const t of terms) for(const e of t){ if(!T.CONSUME[e])continue;
    for(const s of subs){ mult++; pairs.add(s+">"+e); if(!T.CONSUME[e].includes(s)){mbad++; bad.add(s+">"+e);} } }
  console.log(`(b) ${label}: with multiplicity ${mbad}/${mult};  distinct (s,e) pairs ${bad.size}/${pairs.size}`);
}
residualCount(T.LSTAR,"LSTAR");
const parsedLaws=T.PARSED_NEW.map(l=>[l.id,l.subjects,l.terms.filter(t=>!t.external).map(t=>t.alts)]);
residualCount(parsedLaws,"PARSED_NEW (data.ts law strings)");
// term-level variant: (subject, term) pairs where SOME alternative violates
{let tot=0,bad=0; for(const[id,subs,terms] of T.LSTAR) for(const t of terms) for(const s of subs){tot++;
  if(t.some(e=>T.CONSUME[e]&&!T.CONSUME[e].includes(s))) bad++;}
 console.log(`(b) LSTAR (subject,term) pairs: ${bad}/${tot}`);}

// (c) meas:noinvariance 116 / 224025 over subsets of size<=4
let tot4=0,fail4=0;
(function rec(start,cur){ if(cur.length){const S=new Set(cur); if(G(S)){tot4++; if(!G(D(S)))fail4++;}}
  if(cur.length===4)return; for(let i=start;i<E.length;i++){cur.push(E[i]);rec(i+1,cur);cur.pop();}})(0,[]);
console.log(`(c) size<=4 (nonempty): |Fix(G)| = ${tot4}; invariance failures = ${fail4}   [paper: 116 of 224025]`);

// (d) meas:access minimal counterexample
console.log(`(d) admissible({Ex,Op}) = ${T.admissible(new Set(["Ex","Op"]))}; {Ex} = ${T.admissible(new Set(["Ex"]))}; {Op} = ${T.admissible(new Set(["Op"]))}`);

// (e) definite fragment: is DEF acyclic / height 1?
const DEF=[];
for(const law of T.PARSED_NEW) for(const s of law.subjects) for(const t of law.terms)
  if(!t.external && t.alts.length===1 && t.alts[0]!==s) DEF.push([s,t.alts[0]]);
const bodies=new Set(DEF.map(d=>d[0])), heads=new Set(DEF.map(d=>d[1]));
const overlap=[...bodies].filter(b=>heads.has(b));
console.log(`(e) definite rules ${DEF.length}; bodies ${bodies.size}; heads ${heads.size}; body∩head = [${overlap.join(",")}]  => height1 = ${overlap.length===0}`);
// cycle check
const adj=new Map(); for(const[b,h]of DEF){ if(!adj.has(b))adj.set(b,[]); adj.get(b).push(h); }
let cyc=false; const seen=new Map();
function dfs(v){ seen.set(v,1); for(const w of adj.get(v)||[]){ if(seen.get(w)===1){cyc=true;} else if(!seen.has(w)) dfs(w);} seen.set(v,2);}
for(const v of adj.keys()) if(!seen.has(v)) dfs(v);
console.log(`    definite implication digraph has a cycle? ${cyc}`);
