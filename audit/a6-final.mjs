import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E=T.MECH;
console.log("|MECH| =",E.length," |CONSUME rows| =",Object.keys(T.CONSUME).length);

// --- Delta1 idempotence (meas:notidem)
let nonIdem=0,w=null;
for(let r=0;r<200000;r++){const X=new Set(E.filter(()=>Math.random()<0.3));
  const a=T.Delta1(X),b=T.Delta1(a);
  if(a.size!==b.size){nonIdem++; if(!w)w=[[...X].sort().join(","),[...a].sort().join(","),[...b].sort().join(",")];}}
console.log("\nmeas:notidem  Delta1 non-idempotent on",nonIdem,"of 200000 random sets; witness:",JSON.stringify(w));

// --- the two rival 31-clause systems
const arity=[];
for(const l of T.LAWS){const [lhs,rhs=""]=l.rule.split("→");
  const bare=s=>s.replace(/\{[^}]*\}/g,"").replace(/[()]/g,"").trim();
  const subj=(lhs||"").split("|").map(bare).filter(s=>T.SYMS.has(s)); if(!subj.length)continue;
  for(const ch of rhs.split("+")){const parts=ch.split("|").map(bare);const alts=parts.filter(a=>T.SYMS.has(a));
    if(!alts.length||alts.length<parts.length)continue;
    for(const s of subj) arity.push(`${l.id}:${s}->${alts.join("|")}`);}}
const lstar=[];
for(const [id,subs,terms] of T.LSTAR) for(const s of subs) for(const t of terms) lstar.push(`${id}:${s}->${t.join("|")}`);
console.log("\narity.ts requirement clauses:",arity.length,"  LSTAR closure clauses:",lstar.length);
const norm=x=>x.split(":")[1];
const A=new Set(arity.map(norm)), B=new Set(lstar.map(norm));
console.log("identical as (subject->term) sets?", A.size===B.size&&[...A].every(x=>B.has(x)));
console.log("in arity.ts but NOT in LSTAR:", [...A].filter(x=>!B.has(x)).join("  ||  "));
console.log("in LSTAR but NOT in arity.ts:", [...B].filter(x=>!A.has(x)).join("  ||  "));
const wA=Math.max(...arity.map(c=>1+norm(c).split("->")[1].split("|").length));
const wB=Math.max(...lstar.map(c=>1+norm(c).split("->")[1].split("|").length));
console.log("widest clause: arity.ts =",wA," LSTAR/f10-CNF =",wB);
const biA=arity.filter(c=>1+norm(c).split("->")[1].split("|").length<=2).length;
const biB=lstar.filter(c=>1+norm(c).split("->")[1].split("|").length<=2).length;
console.log("bijunctive: arity.ts",biA,"/",arity.length,"   LSTAR",biB,"/",lstar.length);
// dropped terms and their widths (bias check)
let dropped=0; const dw=[];
for(const l of T.LAWS){const [lhs,rhs=""]=l.rule.split("→");
  const bare=s=>s.replace(/\{[^}]*\}/g,"").replace(/[()]/g,"").trim();
  const subj=(lhs||"").split("|").map(bare).filter(s=>T.SYMS.has(s)); if(!subj.length)continue;
  for(const ch of rhs.split("+")){const parts=ch.split("|").map(bare);const alts=parts.filter(a=>T.SYMS.has(a));
    if(!alts.length||alts.length<parts.length){dropped+=subj.length; if(alts.length) dw.push(`${l.id} "${ch.trim()}" keeps ${alts.join("|")}`);}}}
console.log("\n(subject,term) pairs DROPPED as prose/mixed:",dropped,"  of which MIXED (had >=1 element alt):",dw.length);
for(const d of dw) console.log("   mixed-dropped:",d);

// --- blocker over the ACTUALLY ENFORCED bans
const bans=[["Fl","Xf"],["Fl","Rl"],["Fl","Of"]];
for(const c of ["Cp","Cl"]) for(const p of ["Pl","Cd","Im"]) bans.push(["Fl",c,p]);
const G=[...new Set(bans.flat())];
const cov=[]; for(let m=1;m<(1<<G.length);m++){const S=G.filter((_,i)=>m&(1<<i)); if(bans.every(b=>b.some(e=>S.includes(e)))) cov.push(S);}
const mc=cov.filter((s,i)=>!cov.some((t,j)=>j!==i&&t.length<s.length&&t.every(x=>s.includes(x))));
console.log("\nblocker of the ACTUALLY ENFORCED prohibition clutter (X2+X21 as minimal forbidden sets):");
console.log("  ground:",G.join(","),"  |Haz|=",bans.length,"  |b(Haz)| =",mc.length);
