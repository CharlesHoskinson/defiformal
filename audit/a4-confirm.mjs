import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const S=new Set(["Ct","Op","Tp"]);
console.log("X = {Ct,Op,Tp}  (all three are in MECH:", ["Ct","Op","Tp"].every(e=>T.MECH.includes(e)), ")");
console.log("  gammaOpen(X)        =", JSON.stringify(T.gammaOpen(S)), "  -> X in Fix(Gamma)?", T.gammaOpen(S).length===0);
console.log("  unwarranted(X)      =", JSON.stringify(T.unwarranted(S)));
const d=T.DeltaInf(S);
console.log("  Delta^omega(X)      =", JSON.stringify([...d]));
console.log("  gammaOpen(Delta X)  =", JSON.stringify(T.gammaOpen(d)), "  -> in Fix(Gamma)?", T.gammaOpen(d).length===0);
console.log("  ==> Gamma-INVARIANCE OF Delta FAILS ON THE ACTUAL SCORED OPERATORS");
console.log("  Delta(X) is a fixpoint of Delta?", T.unwarranted(d).length===0);
console.log("  admissible(X)?", T.admissible(S), " admissible(Delta X)?", T.admissible(d));
console.log("  consumers(Tp) =", JSON.stringify(T.CONSUME.Tp), " ; Op demands term containing Tp but Op is not a consumer of Tp");

// how common over the full 58-element vocabulary?
const E=T.MECH; let tot=0,fail=0; const ws=[];
for(let r=0;r<400000;r++){const X=new Set(E.filter(()=>Math.random()<0.12));
  if(T.gammaOpen(X).length) continue; tot++; const dd=T.DeltaInf(X);
  if(T.gammaOpen(dd).length){fail++; if(ws.length<5)ws.push([[...X].sort().join(","),[...dd].sort().join(",")]);}}
console.log(`\nrandom search over the FULL 58 (p=0.12, 400k draws): Fix(Gamma) hits ${tot}, invariance FAILURES ${fail} (${(100*fail/tot).toFixed(3)}%)`);
for(const w of ws) console.log("   fail X={"+w[0]+"} -> Delta X={"+w[1]+"}");

// exhaustive over all subsets of size <= 4 of the 58
let t2=0,f2=0; const w2=[];
(function rec(i,cur){ if(cur.length){const X=new Set(cur);
    if(T.gammaOpen(X).length===0){t2++; const dd=T.DeltaInf(X); if(T.gammaOpen(dd).length){f2++; if(w2.length<8)w2.push([cur.join(","),[...dd].sort().join(",")]);}}}
  if(cur.length===4) return; for(let j=i;j<E.length;j++){cur.push(E[j]);rec(j+1,cur);cur.pop();}})(0,[]);
console.log(`\nEXHAUSTIVE over all nonempty subsets of size<=4 of the 58: Fix(Gamma) members ${t2}, invariance FAILURES ${f2}`);
for(const w of w2) console.log("   fail X={"+w[0]+"} -> Delta X={"+w[1]+"}");
