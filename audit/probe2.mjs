import { LSTAR, CONSUME, gammaOpen, Delta1, DeltaInf, MECH } from "/root/DefiElements/formal/v2/tables.mjs";
const closed = S => gammaOpen(S).length === 0;
const show = S => "{" + [...S].sort().join(",") + "}";

// ---- B. hand-built counterexample to thm:invariance
const X = new Set(["Op","Ct","Tp"]);
console.log("X =", show(X));
console.log("  gammaOpen(X) =", JSON.stringify(gammaOpen(X)));
console.log("  Gamma-closed:", closed(X));
const D = Delta1(X);
console.log("  Delta1(X) =", show(D));
console.log("  gammaOpen(Delta1(X)) =", JSON.stringify(gammaOpen(D)));
console.log("  Delta1(X) Gamma-closed:", closed(D));
console.log("  ==> INVARIANCE VIOLATED:", closed(X) && !closed(D));
console.log("  DeltaInf(X) =", show(DeltaInf(X)), "closed:", closed(DeltaInf(X)));

// ---- exhaustive search over subsets of a 14-element universe
const U = ["Op","Ct","Tp","Pl","Im","Cd","Pf","Sh","Ix","Rb","Ex","Cp","Li","Ad"];
let nClosed=0, nViol=0; const ex=[];
for (let m=0;m<(1<<U.length);m++){
  const S=new Set(); for(let i=0;i<U.length;i++) if(m>>i&1) S.add(U[i]);
  if(!closed(S)) continue; nClosed++;
  const d=Delta1(S);
  if(!closed(d)){ nViol++; if(ex.length<8) ex.push([show(S),show(d),JSON.stringify(gammaOpen(d))]); }
}
console.log(`\n== exhaustive over 2^${U.length}: Gamma-closed sets ${nClosed}, Delta1-invariance violations ${nViol} (${(100*nViol/nClosed).toFixed(1)}%)`);
for(const e of ex) console.log("   X="+e[0]+"  Delta1(X)="+e[1]+"  open="+e[2]);

// same for DeltaInf
let nViol2=0; const ex2=[];
for (let m=0;m<(1<<U.length);m++){
  const S=new Set(); for(let i=0;i<U.length;i++) if(m>>i&1) S.add(U[i]);
  if(!closed(S)) continue;
  const d=DeltaInf(S);
  if(!closed(d)){ nViol2++; if(ex2.length<5) ex2.push([show(S),show(d)]); }
}
console.log(`DeltaInf-invariance violations: ${nViol2}`);
for(const e of ex2) console.log("   X="+e[0]+"  DeltaInf(X)="+e[1]);

// ---- C. prop:moore -- is Fix(Gamma) closed under intersection?
let interViol=0; const exI=[]; const closedSets=[];
for (let m=0;m<(1<<U.length);m++){
  const S=new Set(); for(let i=0;i<U.length;i++) if(m>>i&1) S.add(U[i]);
  if(closed(S)) closedSets.push(S);
}
for(let i=0;i<closedSets.length;i++) for(let j=i+1;j<closedSets.length;j++){
  const I=new Set([...closedSets[i]].filter(x=>closedSets[j].has(x)));
  if(!closed(I)){ interViol++; if(exI.length<5) exI.push([show(closedSets[i]),show(closedSets[j]),show(I),JSON.stringify(gammaOpen(I))]); }
}
console.log(`\n== prop:moore -- Fix(Gamma) intersection-closure violations: ${interViol} of ${closedSets.length*(closedSets.length-1)/2} pairs`);
for(const e of exI) console.log("   X="+e[0]+" Y="+e[1]+" X∩Y="+e[2]+" open="+e[3]);

// ---- D. Fix(Delta) union-closure
const dfix=[];
for (let m=0;m<(1<<U.length);m++){
  const S=new Set(); for(let i=0;i<U.length;i++) if(m>>i&1) S.add(U[i]);
  const d=Delta1(S); if(d.size===S.size) dfix.push(S);
}
let uViol=0; const exU=[];
for(let i=0;i<dfix.length;i++) for(let j=i+1;j<dfix.length;j++){
  const Uu=new Set([...dfix[i],...dfix[j]]);
  const d=Delta1(Uu); if(d.size!==Uu.size){ uViol++; if(exU.length<3) exU.push([show(dfix[i]),show(dfix[j])]); }
}
console.log(`\n== Fix(Delta) union-closure violations: ${uViol} of ${dfix.length*(dfix.length-1)/2} pairs`);

// ---- E. Delta monotone?
let mViol=0;
for(let t=0;t<200000;t++){
  const S=new Set(), T=new Set();
  for(const e of MECH){ const r=Math.random(); if(r<0.25){S.add(e);T.add(e);} else if(r<0.5) T.add(e); }
  const a=Delta1(S), b=Delta1(T);
  for(const x of a) if(!b.has(x)){ mViol++; break; }
}
console.log(`\n== Delta1 monotonicity violations in 200000 random X<=Y: ${mViol}`);
