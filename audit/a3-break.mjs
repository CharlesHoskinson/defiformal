import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E=T.MECH, key=S=>[...S].sort().join(","), D=T.DeltaInf;
const Gcond=X=>T.gammaOpen(X).length===0;
const DEF=[]; for (const law of T.PARSED_NEW) for (const s of law.subjects) for (const t of law.terms)
  if (!t.external && t.alts.length===1 && t.alts[0]!==s) DEF.push([s,t.alts[0]]);
const Cn=X=>{const Y=new Set(X);let ch=true;while(ch){ch=false;for(const[b,h]of DEF)if(Y.has(b)&&!Y.has(h)){Y.add(h);ch=true;}}return Y;};

function sweep(U,label){
  const n=U.length, setOf=m=>new Set(U.filter((_,i)=>m&(1<<i)));
  let tot=0,held=0,moved=0; const w=[];
  const seenCn=new Set(); let cnTot=0,cnHeld=0,cnMoved=0; const cw=[];
  for(let m=0;m<(1<<n);m++){
    const X=setOf(m);
    if(Gcond(X)){tot++; const d=D(X); if(d.size!==X.size)moved++;
      if(Gcond(d))held++; else if(w.length<6)w.push([key(X),key(d),JSON.stringify(T.gammaOpen(d))]);}
    const C=Cn(X), k=key(C);
    if(!seenCn.has(k)){seenCn.add(k);cnTot++;const d=D(C);if(d.size!==C.size)cnMoved++;
      if(key(Cn(d))===key(d))cnHeld++; else if(cw.length<6)cw.push([key(C),key(d),key(Cn(d))]);}
  }
  console.log(`\n### ${label}  (2^${n} = ${1<<n})`);
  console.log(`  SCORED closure cond: ${held}/${tot} = ${tot?(100*held/tot).toFixed(3):"-"}%   Delta moved on ${moved}`);
  for(const x of w) console.log(`    *** COUNTEREXAMPLE X={${x[0]}} Delta(X)={${x[1]}} now-open ${x[2]}`);
  console.log(`  Cn closures: ${cnHeld}/${cnTot} = ${cnTot?(100*cnHeld/cnTot).toFixed(3):"-"}%   Delta moved on ${cnMoved}`);
  for(const x of cw) console.log(`    *** COUNTEREXAMPLE C={${x[0]}} Delta(C)={${x[1]}} Cn(Delta C)={${x[2]}}`);
}

// the papers universe
sweep(["Fl","Xm","Xf","Rl","Of","Bs","Sl","Au","Gs","Uc","Aw","At","Cp","Cl","Pl","Cd","Ix","Sh","Ct","Li"],"U20 as used in f11.mjs");
// a universe centred on the elements where the residual property FAILS
sweep(["Pl","Im","Cd","Pf","Op","Ct","Li","Ad","Sl","Bs","Sh","Ix","Rb","Tp","Ex","Sv","Cl","Cp","Tr","Ob"],"U20-B (residual-violating elements)");
sweep(["Py","Ep","Rd","Sh","Ix","Rb","Of","Xm","Xf","Sl","Bs","Rl","Au","Gs","In","Uc","Aw","At","Ft","Ct"],"U20-C (Py/Of/Uc cluster)");
