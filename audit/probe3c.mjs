import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E = T.MECH, D = T.DeltaInf;
const G = X => T.gammaOpen(X).length === 0;
const key = S => [...S].sort().join(",");
let tot=0, held=0; const w=[];
function test(X){ if(!G(X)) return; tot++; const d=D(X); if(G(d)) held++; else if(w.length<6) w.push([key(X),key(d),JSON.stringify(T.gammaOpen(d))]); }
for(let i=0;i<E.length;i++){ test(new Set([E[i]]));
  for(let j=i+1;j<E.length;j++){ test(new Set([E[i],E[j]]));
    for(let k=j+1;k<E.length;k++) test(new Set([E[i],E[j],E[k]])); } }
console.log(`[subsets size<=3 of 58] Gamma-closed ${tot}; invariance held ${held} (${(100*held/tot).toFixed(2)}%); FAILURES ${tot-held}`);
for(const x of w) console.log(`   X={${x[0]}} -> Delta={${x[1]}} open ${x[2]}`);
let rtot=0,rheld=0;
for(let r=0;r<200000;r++){ const X=new Set(E.filter(()=>Math.random()<0.2)); if(!G(X))continue; rtot++; if(G(D(X)))rheld++; }
console.log(`[200k random p=0.2] Gamma-closed ${rtot}; invariance ${rheld}`);
let ltot=0,lheld=0;
for(const p of T.lanes){ const X=new Set(p.syms.filter(s=>T.SYMS.has(s))); if(!G(X))continue; ltot++; if(G(D(X)))lheld++; }
console.log(`[live lanes] Gamma-closed ${ltot}; invariance ${lheld}`);
// random pair test of Fix(G) closure properties at 58 elements
let ic=0,icv=0,ucv=0; const pool=[];
for(let r=0;r<400000 && pool.length<4000;r++){ const X=new Set(E.filter(()=>Math.random()<0.15)); if(G(X)) pool.push(X); }
for(let i=0;i<pool.length;i++) for(let j=i+1;j<Math.min(pool.length,i+50);j++){ ic++;
  if(!G(new Set([...pool[i]].filter(x=>pool[j].has(x))))) icv++;
  if(!G(new Set([...pool[i],...pool[j]])))ucv++; }
console.log(`[58-elt Fix(G) pairs n=${ic}] intersection-closure violations ${icv}; union-closure violations ${ucv}`);
