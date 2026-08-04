import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E = T.MECH, D = T.DeltaInf;
const G = X => T.gammaOpen(X).length === 0;
const key = S => [...S].sort().join(",");

// ---- invariance at full 58 elements, same sampler style as f11 but on the SCORED family
let tot=0, held=0; const w=[];
function test(X){ if(!G(X)) return; tot++; const d=D(X); if(G(d)) held++; else if(w.length<6) w.push([key(X),key(d),JSON.stringify(T.gammaOpen(d))]); }
for(let i=0;i<E.length;i++){ test(new Set([E[i]]));
  for(let j=i+1;j<E.length;j++){ test(new Set([E[i],E[j]]));
    for(let k=j+1;k<E.length;k++) test(new Set([E[i],E[j],E[k]])); } }
console.log(`[all subsets of size<=3 over 58] Gamma-closed: ${tot}, Delta-invariance held ${held} = ${(100*held/tot).toFixed(2)}%  FAILURES ${tot-held}`);
for(const x of w) console.log(`   X={${x[0]}} Delta(X)={${x[1]}} now open ${x[2]}`);

let rtot=0,rheld=0;
for(let r=0;r<300000;r++){ const X=new Set(E.filter(()=>Math.random()<0.25)); if(!G(X))continue; rtot++; if(G(D(X)))rheld++; }
console.log(`[300k random] Gamma-closed ${rtot}, invariance ${rheld} = ${rtot?(100*rheld/rtot).toFixed(2):"n/a"}%`);

// lanes
let ltot=0,lheld=0;
for(const p of T.lanes){ const X=new Set(p.syms.filter(s=>T.SYMS.has(s))); if(!G(X))continue; ltot++; if(G(D(X)))lheld++; }
console.log(`[72 live lanes] Gamma-closed ${ltot}, invariance ${lheld}`);

// ---- U20 of f11 vs a universe containing Op/Tp
const U20=["Fl","Xm","Xf","Rl","Of","Bs","Sl","Au","Gs","Uc","Aw","At","Cp","Cl","Pl","Cd","Ix","Sh","Ct","Li"];
console.log("\nf11 U20 contains Op?", U20.includes("Op"), " Tp?", U20.includes("Tp"), " Pf?", U20.includes("Pf"), " Sv?", U20.includes("Sv"), " Py?", U20.includes("Py"), " Rb?", U20.includes("Rb"), " Ad?", U20.includes("Ad"));

function sweep(U,label){
  let t=0,h=0,ic=0,icv=0,uc=0,ucv=0; const cl=[];
  for(let m=0;m<(1<<U.length);m++){ const S=new Set(U.filter((_,i)=>m&(1<<i)));
    if(G(S)){ t++; cl.push(S); if(G(D(S)))h++; } }
  for(let i=0;i<cl.length;i++) for(let j=i+1;j<cl.length;j++){
    ic++; const I=new Set([...cl[i]].filter(x=>cl[j].has(x))); if(!G(I)) icv++;
    uc++; const Un=new Set([...cl[i],...cl[j]]); if(!G(Un)) ucv++; }
  console.log(`${label}: |Fix(G)|=${t} invariance ${h}/${t} (${(100*h/t).toFixed(2)}%)  intersection-closed violations ${icv}/${ic}  union-closed violations ${ucv}/${uc}`);
}
sweep(U20,"f11 U20                 ");
sweep([...U20.slice(0,18),"Op","Tp"],"U20 with Op,Tp swapped in");
